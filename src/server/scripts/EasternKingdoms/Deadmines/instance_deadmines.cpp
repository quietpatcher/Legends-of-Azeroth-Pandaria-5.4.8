/*
* This file is part of the Pandaria 5.4.8 Project. See THANKS file for Copyright information
*
* This program is free software; you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the
* Free Software Foundation; either version 2 of the License, or (at your
* option) any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include "ScriptPCH.h"
#include "deadmines.h"

#define MAX_ENCOUNTER 6

// deadmines 314b-events: events of the nightmare controller (second timings: CPP reference, sniff based)
enum VanessaNightmareEvents
{
    EVENT_NM_GLUBTOK_SETUP = 1,
    EVENT_NM_GLUBTOK_TALK_1,
    EVENT_NM_GLUBTOK_TALK_2,
    EVENT_NM_GLUBTOK_ENTER,
    EVENT_NM_GLUBTOK_BACK_TO_SHIP,
    EVENT_NM_GLUBTOK_SUMMON,
    EVENT_NM_HELIX_SHIFTS,
    EVENT_NM_HELIX_SETUP,
    EVENT_NM_HELIX_TALK_1,
    EVENT_NM_HELIX_TALK_2,
    EVENT_NM_HELIX_ATTACKABLE,
    EVENT_NM_HELIX_ENTER,
    EVENT_NM_HELIX_SPIDERS,
    EVENT_NM_HELIX_SPIDERS_TALK,
    EVENT_NM_REAPER_SHIFTS,
    EVENT_NM_REAPER_SETUP,
    EVENT_NM_REAPER_TALK_1,
    EVENT_NM_REAPER_TALK_2,
    EVENT_NM_REAPER_ENTER,
    EVENT_NM_REAPER_SUMMON,
    EVENT_NM_RIPSNARL_SHIFTS,
    EVENT_NM_RIPSNARL_SETUP,
    EVENT_NM_RIPSNARL_TALK_1,
    EVENT_NM_RIPSNARL_TALK_2,
    EVENT_NM_RIPSNARL_ENTER,
    EVENT_NM_RIPSNARL_ADRENALINE,
    EVENT_NM_SUMMON_EMME,
    EVENT_NM_ANNOUNCE_EMME,
    EVENT_NM_ANNOUNCE_ERIK,
    EVENT_NM_SUMMON_ERIK,
    EVENT_NM_SUMMON_JAMES,
    EVENT_NM_CALISSA_DYING,
    EVENT_NM_ANNOUNCE_CALISSA,
    EVENT_NM_ELIXIR_OFF,
    EVENT_NM_VANESSA_APPEARS,
    EVENT_NM_CHECK_PLAYERS,
};

static std::vector<DoorData> const doordata =
{
    {GO_FACTORY_DOOR,   DATA_GLUBTOK,   DOOR_TYPE_PASSAGE,    BOUNDARY_NONE},
    {GO_MAST_ROOM_DOOR, DATA_HELIX,     DOOR_TYPE_PASSAGE,    BOUNDARY_NONE},
    {GO_HEAVY_DOOR,     DATA_HELIX,     DOOR_TYPE_ROOM,       BOUNDARY_NONE},
    {GO_FOUNDRY_DOOR,   DATA_FOEREAPER, DOOR_TYPE_PASSAGE,    BOUNDARY_NONE},
    {GO_HEAVY_DOOR_2,   DATA_FOEREAPER, DOOR_TYPE_ROOM,       BOUNDARY_NONE},
};

class instance_deadmines : public InstanceMapScript
{
    public:
        instance_deadmines() : InstanceMapScript("instance_deadmines", 36) { }

        struct instance_deadmines_InstanceMapScript : public InstanceScript
        {
            instance_deadmines_InstanceMapScript(Map* map) : InstanceScript(map) 
            {
                SetBossNumber(MAX_ENCOUNTER);
                LoadDoorData(doordata);
                
                uiGlubtokGUID = ObjectGuid::Empty;
                uiHelixGUID = ObjectGuid::Empty;
                uiOafGUID = ObjectGuid::Empty;
                uiFoereaperGUID = ObjectGuid::Empty;
                uiAdmiralGUID = ObjectGuid::Empty;
                uiCaptainGUID = ObjectGuid::Empty;

                GoblinTeleporterGUID = ObjectGuid::Empty;
                HeavyDoorGUID = ObjectGuid::Empty;
                HeavyDoor2GUID       = ObjectGuid::Empty;
                IronCladDoorGUID = ObjectGuid::Empty;
                DefiasCannonGUID = ObjectGuid::Empty;
                DoorLeverGUID = ObjectGuid::Empty;
                TeamInInstance       = 0;
                uiVanessaEvent       = 0;
                OverchargeCount      = 0;
                nmWorgenDead         = 0;   // deadmines 314b-ctor: 
                State                = CANNON_NOT_USED;
                instance->SetWorldState(WORLDSTATE_PROTOTYPE_PRODIGY, 1);
            };

            void OnPlayerEnter(Player* player) override
            {
                if (!TeamInInstance)
                {
                    TeamInInstance = player->GetTeam();
                    HideOtherTeamSet();
                }
            }

            // deadmines 347-team: only the entrance set of the instance team exists.
            // Hiding alone is not enough: a hidden creature still sees and attacks players.
            void HideTeamNpc(Creature* creature)
            {
                if (!creature->IsVisible())
                    return;
                creature->SetVisible(false);
                creature->SetReactState(REACT_PASSIVE);
                creature->SetRespawnDelay(7 * DAY);
                creature->DespawnOrUnsummon(1);
            }

            void HideOtherTeamSet()
            {
                GuidVector const& set = TeamInInstance == ALLIANCE ? hordeSet : allianceSet;
                for (ObjectGuid const& guid : set)
                    if (Creature* creature = instance->GetCreature(guid))
                        HideTeamNpc(creature);
            }

            void OnCreatureCreate(Creature* creature) override
            {
                if (!TeamInInstance)
                {
                    Map::PlayerList const &players = instance->GetPlayers();
                    if (!players.isEmpty())
                        if (Player* player = players.begin()->GetSource())
                            TeamInInstance = player->GetTeam();
                    if (TeamInInstance)
                        HideOtherTeamSet();
                }

                switch (creature->GetEntry())
                {
                    case NPC_GLUBTOK:
                        uiGlubtokGUID = creature->GetGUID();
                        break;
                    case NPC_HELIX_GEARBREAKER:
                        uiHelixGUID = creature->GetGUID();
                        break;
                    case NPC_LUMBERING_OAF:
                        uiOafGUID = creature->GetGUID();
                        break;
                    case NPC_FOE_REAPER_5000:
                        uiFoereaperGUID = creature->GetGUID();
                        break;
                    case NPC_ADMIRAL_RIPSNARL:
                        uiAdmiralGUID = creature->GetGUID();
                        break;
                    case NPC_CAPTAIN_COOKIE:
                        uiCaptainGUID = creature->GetGUID();
                        break;
                    // deadmines 314b-create: 
                    case NPC_VANESSA_VANCLEEF:
                        uiVanessaGUID = creature->GetGUID();
                        break;
                    case NPC_NM_EMME:
                        nmEmmeGUID = creature->GetGUID();
                        break;
                    case NPC_NM_ERIK:
                        nmErikGUID = creature->GetGUID();
                        break;
                    case NPC_NM_CALISSA:
                        nmCalissaGUID = creature->GetGUID();
                        break;
                    case NPC_NM_JAMES:
                        nmJamesGUID = creature->GetGUID();
                        break;
                    case NPC_KAGTHA:
                    case NPC_SLINKY_SHARPSHIV:
                    case NPC_MISS_MAYHEM:
                    case NPC_MAYHEM_REAPER:
                    case NPC_HAND_ASSASIN:
                        hordeSet.push_back(creature->GetGUID());
                        if (TeamInInstance == ALLIANCE)
                            HideTeamNpc(creature);
                        break;
                    case NPC_HORATIO_LAINE:
                    case NPC_DEFENDER:
                    case NPC_INVESTIGATOR:
                    case NPC_CRIME_SCENE_BOT:
                        allianceSet.push_back(creature->GetGUID());
                        if (TeamInInstance == HORDE)
                            HideTeamNpc(creature);
                        break;
                }
            }

            void OnUnitDeath(Unit* unit) override
            {
                // deadmines 314b-death: the nightmare fails when the whole group is dead
                if (unit->GetTypeId() == TYPEID_PLAYER && NightmareRunning())
                    nmEvents.ScheduleEvent(EVENT_NM_CHECK_PLAYERS, 200);

                if (unit->ToCreature())
                {
                    switch (unit->GetEntry())
                    {
                        // deadmines 314b: stage transitions (order: Warcraft Wiki Nightmare Gauntlet)
                        case NPC_NM_GLUBTOK:
                            if (uiVanessaEvent == NIGHTMARE_STAGE_GLUBTOK)
                            {
                                unit->ToCreature()->DespawnOrUnsummon(4000);
                                SetData(DATA_VANESSA_EVENT, NIGHTMARE_STAGE_HELIX);
                            }
                            break;
                        case NPC_NM_HELIX:
                            if (uiVanessaEvent == NIGHTMARE_STAGE_HELIX)
                            {
                                unit->ToCreature()->DespawnOrUnsummon(5500);
                                SetData(DATA_VANESSA_EVENT, NIGHTMARE_STAGE_FOE_REAPER);
                            }
                            break;
                        case NPC_NM_FOE_REAPER:
                            if (uiVanessaEvent == NIGHTMARE_STAGE_FOE_REAPER)
                            {
                                unit->ToCreature()->DespawnOrUnsummon(3600);
                                SetData(DATA_VANESSA_EVENT, NIGHTMARE_STAGE_RIPSNARL);
                            }
                            break;
                        case NPC_NM_ENRAGED_WORGEN:
                            if (uiVanessaEvent != NIGHTMARE_STAGE_RIPSNARL)
                                break;
                            unit->ToCreature()->DespawnOrUnsummon(5000);
                            if (++nmWorgenDead < 3)
                                break;
                            nmWorgenDead = 0;
                            // three worgen down: the saved Harrington grants Adrenaline, then the next one
                            if (Creature* emme = instance->GetCreature(nmEmmeGUID))
                            {
                                emme->CastSpell(emme, SPELL_NM_ADRENALINE, true);
                                emme->DespawnOrUnsummon(1000);
                                nmEmmeGUID.Clear();
                                nmEvents.ScheduleEvent(EVENT_NM_ANNOUNCE_ERIK, 4000);
                            }
                            else if (Creature* erik = instance->GetCreature(nmErikGUID))
                            {
                                erik->CastSpell(erik, SPELL_NM_ADRENALINE, true);
                                erik->DespawnOrUnsummon(1000);
                                nmErikGUID.Clear();
                                nmEvents.ScheduleEvent(EVENT_NM_SUMMON_JAMES, 200);
                            }
                            break;
                        case NPC_NM_JAMES:
                            if (uiVanessaEvent != NIGHTMARE_STAGE_RIPSNARL)
                                break;
                            unit->ToCreature()->AI()->Talk(NM_SAY_JAMES_SORRY);
                            unit->ToCreature()->DespawnOrUnsummon(2300);
                            if (Creature* calissa = instance->GetCreature(nmCalissaGUID))
                            {
                                calissa->RemoveAllAuras();
                                calissa->ExitVehicle();
                            }
                            nmEvents.ScheduleEvent(EVENT_NM_ELIXIR_OFF, 250);
                            break;
                        case NPC_NM_EMME:
                        case NPC_NM_ERIK:
                        case NPC_NM_CALISSA:
                            if (NightmareRunning())
                                SetData(DATA_VANESSA_EVENT, FAIL);
                            break;
                        case NPC_MINING_POWDER:
                            unit->CastSpell(unit, SPELL_EXPLODE_MINE, false);
                            break;
                        case NPC_DEFIAS_WATCHER:
                        case NPC_DEFIAS_REAPER:
                            OverchargeCount++;

                            if (OverchargeCount >= 4)
                                if (Creature* FoeReaper = instance->GetCreature(GetGuidData(DATA_FOEREAPER)))
                                    FoeReaper->RemoveAurasDueToSpell(SPELL_OFF_LINE);
                            break;
                    }
                }
            }

            void OnGameObjectCreate(GameObject* go) override
            {
                switch (go->GetEntry())
                {
                    case GO_HEAVY_DOOR:
                        HeavyDoorGUID = go->GetGUID();
                        AddDoor(go, true);
                        break;
                    case GO_HEAVY_DOOR_2:
                        HeavyDoor2GUID = go->GetGUID();
                        AddDoor(go, true);
                        break;
                    case GO_FACTORY_DOOR:
                    case GO_MAST_ROOM_DOOR:
                    case GO_FOUNDRY_DOOR:
                        AddDoor(go, true);
                        break;
                    case GO_GOBLIN_TELEPORTER:
                        GoblinTeleporterGUID = go->GetGUID();
                        break;
                    case GO_IRONCLAD_DOOR:
                        IronCladDoorGUID = go->GetGUID();
                        break;
                    case GO_DEFIAS_CANNON:
                        DefiasCannonGUID = go->GetGUID();
                        break;
                    case GO_DOOR_LEVER:
                        DoorLeverGUID = go->GetGUID();
                        break;
                }
            }

            void ShootCannon()
            {
                if (GameObject* pDefiasCannon = instance->GetGameObject(DefiasCannonGUID))
                {
                    pDefiasCannon->SetGoState(GO_STATE_ACTIVE);
                    pDefiasCannon->PlayDirectSound(SOUND_CANNONFIRE);
                }
            }

            void BlastOutDoor()
            {
                if (GameObject* pIronCladDoor = instance->GetGameObject(IronCladDoorGUID))
                {
                    pIronCladDoor->SetGoState(GO_STATE_ACTIVE_ALTERNATIVE);
                    pIronCladDoor->PlayDirectSound(SOUND_DESTROYDOOR);
                }
            }

            void SetData(uint32 type, uint32 data) override
            {
                switch (type)
                {
                    case DATA_CANNON_EVENT:
                        State = data;
                        if (data == CANNON_BLAST_INITIATED)
                        {
                            ShootCannon();
                            BlastOutDoor();
                        }    
                        break;
                    case DATA_VANESSA_EVENT:
                        uiVanessaEvent = data;
                        if (data == DONE)
                            SaveToDB();
                        // deadmines 314b-controller: nightmare stages
                        switch (data)
                        {
                            case NIGHTMARE_STAGE_GLUBTOK:
                                NightmareStart();
                                break;
                            case NIGHTMARE_STAGE_HELIX:
                                nmEvents.ScheduleEvent(EVENT_NM_HELIX_SHIFTS, 2900);
                                break;
                            case NIGHTMARE_STAGE_FOE_REAPER:
                                nmEvents.ScheduleEvent(EVENT_NM_REAPER_SHIFTS, 2000);
                                break;
                            case NIGHTMARE_STAGE_RIPSNARL:
                                nmEvents.ScheduleEvent(EVENT_NM_RIPSNARL_SHIFTS, 2500);
                                break;
                            case FAIL:
                                NightmareFail();
                                break;
                            default:
                                break;
                        }
                        break;
                }
            }

            // deadmines 314b: nightmare controller --------------------------------------------------------
            bool NightmareRunning() const
            {
                return uiVanessaEvent >= NIGHTMARE_STAGE_GLUBTOK && uiVanessaEvent <= NIGHTMARE_STAGE_RIPSNARL;
            }

            Creature* NmSummon(uint32 entry, Position const& pos)
            {
                Creature* summon = instance->SummonCreature(entry, pos);
                if (summon)
                    nmSummons.insert(summon->GetGUID());
                return summon;
            }

            // one narrator per stage; the previous one goes
            void NmNewNarrator(uint8 index)
            {
                if (Creature* old = instance->GetCreature(nmNarratorGUID))
                    old->DespawnOrUnsummon();
                nmNarratorGUID.Clear();
                if (Creature* narrator = NmSummon(NPC_NM_NARRATOR, nmNarratorPos[index]))
                    nmNarratorGUID = narrator->GetGUID();
            }

            void NmNarratorTalk(uint8 group)
            {
                if (Creature* narrator = instance->GetCreature(nmNarratorGUID))
                    narrator->AI()->Talk(group);
            }

            void NmDespawnAll()
            {
                for (GuidSet::const_iterator itr = nmSummons.begin(); itr != nmSummons.end(); ++itr)
                    if (Creature* creature = instance->GetCreature(*itr))
                        creature->DespawnOrUnsummon();
                nmSummons.clear();
                nmNarratorGUID.Clear();
                nmEmmeGUID.Clear();
                nmErikGUID.Clear();
                nmCalissaGUID.Clear();
                nmJamesGUID.Clear();
                nmWorgenDead = 0;
            }

            // the nightmare boss figures carry the template flags immune to PC/NPC; the real copy loses them
            static void NmMakeAttackable(Creature* creature)
            {
                creature->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_IMMUNE_TO_NPC | UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE);
                creature->RemoveAurasDueToSpell(SPELL_OFF_LINE);
                creature->SetReactState(REACT_AGGRESSIVE);
            }

            void NightmareStart()
            {
                nmEvents.Reset();
                NmDespawnAll();
                DoCastSpellOnPlayers(SPELL_NM_ELIXIR);
                DoCastSpellOnPlayers(SPELL_NM_AURA);
                // the trap that lowers the group into the forge is not implemented: the players are moved to the forge floor
                Map::PlayerList const& players = instance->GetPlayers();
                for (Map::PlayerList::const_iterator itr = players.begin(); itr != players.end(); ++itr)
                    if (Player* player = itr->GetSource())
                        if (!player->IsGameMaster())
                            player->NearTeleportTo(nmForgeFloorPos.GetPositionX(), nmForgeFloorPos.GetPositionY(), nmForgeFloorPos.GetPositionZ(), nmForgeFloorPos.GetOrientation());
                nmEvents.ScheduleEvent(EVENT_NM_GLUBTOK_SETUP, 4800);
            }

            void NightmareFail()
            {
                nmEvents.Reset();
                NmDespawnAll();
                DoRemoveAurasDueToSpellOnPlayers(SPELL_NM_ELIXIR);
                DoRemoveAurasDueToSpellOnPlayers(SPELL_NM_AURA);
                uiVanessaEvent = NOT_STARTED;
                // the note can be read again, the run restarts from the ship
                instance->SummonCreature(NPC_NOTE_FROM_VANESSA, notePos);
            }

            void Update(uint32 diff) override
            {
                if (nmEvents.Empty())
                    return;

                nmEvents.Update(diff);

                while (uint32 eventId = nmEvents.ExecuteEvent())
                {
                    switch (eventId)
                    {
                        // ---- Glubtok's nightmare
                        case EVENT_NM_GLUBTOK_SETUP:
                            NmNewNarrator(0);
                            NmSummon(NPC_NM_GLUBTOK, nmGlubtokIntroPos);     // the figure on the ledge
                            nmEvents.ScheduleEvent(EVENT_NM_GLUBTOK_TALK_1, 1000);
                            nmEvents.ScheduleEvent(EVENT_NM_GLUBTOK_SUMMON, 14400);
                            break;
                        case EVENT_NM_GLUBTOK_TALK_1:
                            NmNarratorTalk(NM_SAY_GLUBTOK_1);
                            nmEvents.ScheduleEvent(EVENT_NM_GLUBTOK_TALK_2, 8400);
                            break;
                        case EVENT_NM_GLUBTOK_TALK_2:
                            NmNarratorTalk(NM_SAY_GLUBTOK_2);
                            nmEvents.ScheduleEvent(EVENT_NM_GLUBTOK_ENTER, 4600);
                            break;
                        case EVENT_NM_GLUBTOK_ENTER:
                            NmNarratorTalk(NM_SAY_GLUBTOK_ENTER);
                            nmEvents.ScheduleEvent(EVENT_NM_GLUBTOK_BACK_TO_SHIP, 4800);
                            break;
                        case EVENT_NM_GLUBTOK_BACK_TO_SHIP:
                            NmNarratorTalk(NM_SAY_BACK_TO_SHIP);
                            break;
                        case EVENT_NM_GLUBTOK_SUMMON:
                            for (GuidSet::const_iterator itr = nmSummons.begin(); itr != nmSummons.end(); ++itr)
                                if (Creature* figure = instance->GetCreature(*itr))
                                    if (figure->GetEntry() == NPC_NM_GLUBTOK)
                                        figure->DespawnOrUnsummon();
                            if (Creature* glubtok = NmSummon(NPC_NM_GLUBTOK, nmGlubtokPos))
                                NmMakeAttackable(glubtok);
                            break;
                        // ---- Helix' nightmare
                        case EVENT_NM_HELIX_SHIFTS:
                            NmNarratorTalk(NM_SAY_SHIFTS);
                            nmEvents.ScheduleEvent(EVENT_NM_HELIX_SETUP, 3200);
                            break;
                        case EVENT_NM_HELIX_SETUP:
                            NmNewNarrator(1);
                            NmSummon(NPC_NM_HELIX, nmHelixPos);
                            nmEvents.ScheduleEvent(EVENT_NM_HELIX_TALK_1, 1000);
                            nmEvents.ScheduleEvent(EVENT_NM_HELIX_ATTACKABLE, 7700);
                            nmEvents.ScheduleEvent(EVENT_NM_HELIX_ENTER, 17800);
                            break;
                        case EVENT_NM_HELIX_TALK_1:
                            NmNarratorTalk(NM_SAY_HELIX_1);
                            nmEvents.ScheduleEvent(EVENT_NM_HELIX_TALK_2, 6000);
                            break;
                        case EVENT_NM_HELIX_TALK_2:
                            NmNarratorTalk(NM_SAY_HELIX_2);
                            break;
                        case EVENT_NM_HELIX_ATTACKABLE:
                            for (GuidSet::const_iterator itr = nmSummons.begin(); itr != nmSummons.end(); ++itr)
                                if (Creature* helix = instance->GetCreature(*itr))
                                    if (helix->GetEntry() == NPC_NM_HELIX)
                                        NmMakeAttackable(helix);
                            break;
                        case EVENT_NM_HELIX_ENTER:
                            for (GuidSet::const_iterator itr = nmSummons.begin(); itr != nmSummons.end(); ++itr)
                                if (Creature* helix = instance->GetCreature(*itr))
                                    if (helix->GetEntry() == NPC_NM_HELIX)
                                        helix->AI()->Talk(NM_SAY_HELIX_ENTER);
                            nmEvents.ScheduleEvent(EVENT_NM_HELIX_SPIDERS, 600);
                            break;
                        case EVENT_NM_HELIX_SPIDERS:
                            for (uint8 i = 0; i < NM_SKITTERLING_COUNT; ++i)
                                NmSummon(NPC_NM_SKITTERLING, nmSkitterlingPos[i]);
                            for (uint8 i = 0; i < 3; ++i)
                                NmSummon(NPC_NM_DARKWEB_DEVOURER, nmDarkwebPos[i]);
                            NmSummon(NPC_NM_CHATTERING_HORROR, nmChatteringHorrorPos);
                            nmEvents.ScheduleEvent(EVENT_NM_HELIX_SPIDERS_TALK, 800);
                            break;
                        case EVENT_NM_HELIX_SPIDERS_TALK:
                            for (GuidSet::const_iterator itr = nmSummons.begin(); itr != nmSummons.end(); ++itr)
                                if (Creature* helix = instance->GetCreature(*itr))
                                    if (helix->GetEntry() == NPC_NM_HELIX)
                                        helix->AI()->Talk(NM_SAY_HELIX_SPIDERS);
                            break;
                        // ---- the mechanical nightmare
                        case EVENT_NM_REAPER_SHIFTS:
                            for (GuidSet::const_iterator itr = nmSummons.begin(); itr != nmSummons.end(); ++itr)
                                if (Creature* spider = instance->GetCreature(*itr))
                                    if (spider->GetEntry() == NPC_NM_SKITTERLING || spider->GetEntry() == NPC_NM_DARKWEB_DEVOURER || spider->GetEntry() == NPC_NM_CHATTERING_HORROR)
                                        spider->DespawnOrUnsummon();
                            NmNarratorTalk(NM_SAY_SHIFTS);
                            nmEvents.ScheduleEvent(EVENT_NM_REAPER_SETUP, 2600);
                            break;
                        case EVENT_NM_REAPER_SETUP:
                            NmNewNarrator(2);
                            NmSummon(NPC_NM_FOE_REAPER, nmFoeReaperIntroPos);   // the figure at the tunnel entrance
                            nmEvents.ScheduleEvent(EVENT_NM_REAPER_TALK_1, 1000);
                            nmEvents.ScheduleEvent(EVENT_NM_REAPER_SUMMON, 9500);
                            break;
                        case EVENT_NM_REAPER_TALK_1:
                            NmNarratorTalk(NM_SAY_MECHANICAL_1);
                            nmEvents.ScheduleEvent(EVENT_NM_REAPER_TALK_2, 3600);
                            break;
                        case EVENT_NM_REAPER_TALK_2:
                            NmNarratorTalk(NM_SAY_MECHANICAL_2);
                            nmEvents.ScheduleEvent(EVENT_NM_REAPER_ENTER, 3400);
                            break;
                        case EVENT_NM_REAPER_ENTER:
                            NmNarratorTalk(NM_SAY_MECHANICAL_ENTER);
                            break;
                        case EVENT_NM_REAPER_SUMMON:
                            for (GuidSet::const_iterator itr = nmSummons.begin(); itr != nmSummons.end(); ++itr)
                                if (Creature* figure = instance->GetCreature(*itr))
                                    if (figure->GetEntry() == NPC_NM_FOE_REAPER)
                                        figure->DespawnOrUnsummon();
                            if (Creature* reaper = NmSummon(NPC_NM_FOE_REAPER, nmFoeReaperPos))
                                NmMakeAttackable(reaper);
                            break;
                        // ---- Ripsnarl's nightmare
                        case EVENT_NM_RIPSNARL_SHIFTS:
                            NmNarratorTalk(NM_SAY_SHIFTS);
                            nmEvents.ScheduleEvent(EVENT_NM_RIPSNARL_SETUP, 2800);
                            break;
                        case EVENT_NM_RIPSNARL_SETUP:
                            NmNewNarrator(3);
                            NmSummon(NPC_NM_RIPSNARL, nmRipsnarlPos);           // the figure at the cove entrance (cosmetic)
                            nmEvents.ScheduleEvent(EVENT_NM_RIPSNARL_TALK_1, 2200);
                            nmEvents.ScheduleEvent(EVENT_NM_SUMMON_EMME, 14400);
                            break;
                        case EVENT_NM_RIPSNARL_TALK_1:
                            NmNarratorTalk(NM_SAY_RIPSNARL_1);
                            nmEvents.ScheduleEvent(EVENT_NM_RIPSNARL_TALK_2, 7150);
                            break;
                        case EVENT_NM_RIPSNARL_TALK_2:
                            NmNarratorTalk(NM_SAY_RIPSNARL_2);
                            nmEvents.ScheduleEvent(EVENT_NM_RIPSNARL_ENTER, 4600);
                            break;
                        case EVENT_NM_RIPSNARL_ENTER:
                            NmNarratorTalk(NM_SAY_RIPSNARL_ENTER);
                            nmEvents.ScheduleEvent(EVENT_NM_RIPSNARL_ADRENALINE, 2000);
                            break;
                        case EVENT_NM_RIPSNARL_ADRENALINE:
                            DoCastSpellOnPlayers(SPELL_NM_ADRENALINE);
                            break;
                        case EVENT_NM_SUMMON_EMME:
                            nmWorgenDead = 0;
                            NmSummon(NPC_NM_EMME, nmEmmePos);
                            for (uint8 i = 0; i < 3; ++i)
                                NmSummon(NPC_NM_ENRAGED_WORGEN, nmWorgenEmmePos[i]);
                            nmEvents.ScheduleEvent(EVENT_NM_ANNOUNCE_EMME, 3500);
                            break;
                        case EVENT_NM_ANNOUNCE_EMME:
                            NmNarratorTalk(NM_SAY_SAVE_EMME);
                            break;
                        case EVENT_NM_ANNOUNCE_ERIK:
                            NmNarratorTalk(NM_SAY_SAVE_ERIK);
                            nmEvents.ScheduleEvent(EVENT_NM_SUMMON_ERIK, 1800);
                            break;
                        case EVENT_NM_SUMMON_ERIK:
                            nmWorgenDead = 0;
                            NmSummon(NPC_NM_ERIK, nmErikPos);
                            for (uint8 i = 0; i < 3; ++i)
                                NmSummon(NPC_NM_ENRAGED_WORGEN, nmWorgenErikPos[i]);
                            break;
                        case EVENT_NM_SUMMON_JAMES:
                            if (Creature* james = NmSummon(NPC_NM_JAMES, nmJamesPos))
                            {
                                NmMakeAttackable(james);
                                james->SetReactState(REACT_PASSIVE);
                                if (Creature* calissa = NmSummon(NPC_NM_CALISSA, nmCalissaPos))
                                {
                                    calissa->EnterVehicle(james, 0);
                                    calissa->AI()->Talk(NM_SAY_CALISSA_PLEASE);
                                }
                            }
                            nmEvents.ScheduleEvent(EVENT_NM_CALISSA_DYING, 2000);
                            nmEvents.ScheduleEvent(EVENT_NM_ANNOUNCE_CALISSA, 3400);
                            break;
                        case EVENT_NM_CALISSA_DYING:
                            if (Creature* calissa = instance->GetCreature(nmCalissaGUID))
                            {
                                calissa->AI()->Talk(NM_SAY_CALISSA_DYING);
                                calissa->CastSpell(calissa, SPELL_NM_CHOKING, true);
                            }
                            break;
                        case EVENT_NM_ANNOUNCE_CALISSA:
                            NmNarratorTalk(NM_SAY_SAVE_CALISSA);
                            break;
                        // ---- done: the elixir wears off, Vanessa shows herself
                        case EVENT_NM_ELIXIR_OFF:
                            NmNarratorTalk(NM_SAY_ELIXIR_WEARS_OFF);
                            DoRemoveAurasDueToSpellOnPlayers(SPELL_NM_ELIXIR);
                            DoRemoveAurasDueToSpellOnPlayers(SPELL_NM_AURA);
                            if (Creature* calissa = instance->GetCreature(nmCalissaGUID))
                                calissa->DespawnOrUnsummon(2200);
                            nmEvents.ScheduleEvent(EVENT_NM_VANESSA_APPEARS, 2000);
                            break;
                        case EVENT_NM_VANESSA_APPEARS:
                            NmDespawnAll();
                            if (Creature* vanessa = instance->GetCreature(uiVanessaGUID))
                                vanessa->SetVisible(true);
                            SetData(DATA_VANESSA_EVENT, DONE);
                            break;
                        case EVENT_NM_CHECK_PLAYERS:
                        {
                            bool anyAlive = false;
                            Map::PlayerList const& players = instance->GetPlayers();
                            for (Map::PlayerList::const_iterator itr = players.begin(); itr != players.end(); ++itr)
                                if (Player* player = itr->GetSource())
                                    if (!player->IsGameMaster() && player->IsAlive())
                                        anyAlive = true;
                            if (!anyAlive && NightmareRunning())
                                SetData(DATA_VANESSA_EVENT, FAIL);
                            break;
                        }
                        default:
                            break;
                    }
                }
            }
            // deadmines 314b: end ------------------------------------------------------------------------

            uint32 GetData(uint32 type) const override
            {
                if (type == DATA_VANESSA_EVENT)
                    return uiVanessaEvent;
                return 0;
            }

            ObjectGuid GetGuidData(uint32 type) const override
            {
                switch (type)
                {
                    case DATA_GLUBTOK:
                        return uiGlubtokGUID;
                    case DATA_HELIX:
                        return uiHelixGUID;
                    case DATA_OAF:
                        return uiOafGUID;
                    case DATA_FOEREAPER:
                        return uiFoereaperGUID;
                    case DATA_ADMIRAL:
                        return uiAdmiralGUID;
                    case DATA_TEAM_IN_INSTANCE:     
                        return ObjectGuid(uint64(TeamInInstance));
                }
                return ObjectGuid::Empty;
            }
            
            bool SetBossState(uint32 type, EncounterState state) override
            {
                if (!InstanceScript::SetBossState(type, state))
                    return false;
                    
                switch (type)
                {
                    case DATA_HELIX:
                        if (state == IN_PROGRESS)
                        {
                            if (GameObject* go = instance->GetGameObject(HeavyDoorGUID))
                                go->SetFlag(GAMEOBJECT_FIELD_FLAGS, GO_FLAG_NOT_SELECTABLE);
                        }
                        else if (state == DONE)
                            if (GameObject* go = instance->GetGameObject(HeavyDoorGUID))
                                go->RemoveFlag(GAMEOBJECT_FIELD_FLAGS, GO_FLAG_NOT_SELECTABLE);
                        break;
                    case DATA_FOEREAPER:
                        if (state == IN_PROGRESS)
                        {
                            if (GameObject* go = instance->GetGameObject(HeavyDoor2GUID))
                                go->SetFlag(GAMEOBJECT_FIELD_FLAGS, GO_FLAG_NOT_SELECTABLE);
                        }
                        else if (state == DONE)
                            if (GameObject* go = instance->GetGameObject(HeavyDoor2GUID))
                                go->RemoveFlag(GAMEOBJECT_FIELD_FLAGS, GO_FLAG_NOT_SELECTABLE);
                        break;
                }

                return true;
            }

            std::string GetSaveData() override
            {
                OUT_SAVE_INST_DATA;

                std::string str_data;
                std::ostringstream saveStream;
                saveStream << "D M " << GetBossSaveData() << State << " " << uiVanessaEvent << " ";
                str_data = saveStream.str();

                OUT_SAVE_INST_DATA_COMPLETE;
                return str_data;
            }

            void Load(const char* in) override
            {
                if (!in)
                {
                    OUT_LOAD_INST_DATA_FAIL;
                    return;
                }

                OUT_LOAD_INST_DATA(in);

                char dataHead1, dataHead2;

                std::istringstream loadStream(in);
                loadStream >> dataHead1 >> dataHead2;

                if (dataHead1 == 'D' && dataHead2 == 'M')
                {

                    for (uint8 i = 0; i < MAX_ENCOUNTER; ++i)
                    {
                        uint32 tmpState;
                        loadStream >> tmpState;
                        if (tmpState == IN_PROGRESS || tmpState > SPECIAL)
                        tmpState = NOT_STARTED;
                        SetBossState(i, EncounterState(tmpState));
                    }

                    loadStream >> State;

                    if (State == CANNON_BLAST_INITIATED)
                        if (GameObject *pIronCladDoor = instance->GetGameObject(IronCladDoorGUID))
                            pIronCladDoor->SetGoState(GO_STATE_ACTIVE_ALTERNATIVE);

                    loadStream >> uiVanessaEvent;
                    if (uiVanessaEvent != DONE)
                        uiVanessaEvent = NOT_STARTED;

                }
                else OUT_LOAD_INST_DATA_FAIL;

                OUT_LOAD_INST_DATA_COMPLETE;
            }

        private:
            ObjectGuid uiGlubtokGUID;
            ObjectGuid uiHelixGUID;
            ObjectGuid uiOafGUID;
            ObjectGuid uiFoereaperGUID;
            ObjectGuid uiAdmiralGUID;
            ObjectGuid uiCaptainGUID;

            ObjectGuid FactoryDoorGUID;
            ObjectGuid FoundryDoorGUID;
            ObjectGuid MastRoomDoorGUID;
            ObjectGuid GoblinTeleporterGUID;
            ObjectGuid HeavyDoorGUID;
            ObjectGuid HeavyDoor2GUID;
            ObjectGuid IronCladDoorGUID;
            ObjectGuid DefiasCannonGUID;
            ObjectGuid DoorLeverGUID;
            ObjectGuid DefiasPirate1GUID;
            ObjectGuid DefiasPirate2GUID;
            ObjectGuid DefiasCompanionGUID;

            uint32 State;
            uint32 uiVanessaEvent;
            uint32 OverchargeCount;

            // deadmines 314b-members: 
            ObjectGuid uiVanessaGUID;
            ObjectGuid nmNarratorGUID;
            ObjectGuid nmEmmeGUID;
            ObjectGuid nmErikGUID;
            ObjectGuid nmCalissaGUID;
            ObjectGuid nmJamesGUID;
            GuidSet nmSummons;
            EventMap nmEvents;
            uint8 nmWorgenDead;

            uint32 TeamInInstance;
            GuidVector hordeSet, allianceSet;   // deadmines 347-team: 
        };

        InstanceScript* GetInstanceScript(InstanceMap* map) const override
        {
            return new instance_deadmines_InstanceMapScript(map);
        }
};

void AddSC_instance_deadmines()
{
    new instance_deadmines();
}