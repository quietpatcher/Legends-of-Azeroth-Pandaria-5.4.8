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

/* ScriptData
SDName: Silverpine_Forest
SD%Complete: 100
SDComment: Quest support: 435
SDCategory: Silverpine Forest
EndScriptData */

/* ContentData
npc_deathstalker_erland
EndContentData */

#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "ScriptedEscortAI.h"
#include "Player.h"
#include "SpellInfo.h"
#include "Vehicle.h"
#include "ObjectAccessor.h"
#include "MotionMaster.h"

/*######
## npc_deathstalker_erland
######*/

enum eErland
{
    SAY_QUESTACCEPT     = 0,
    SAY_START           = 1,
    SAY_AGGRO           = 2,
    SAY_PROGRESS        = 3,
    SAY_LAST            = 4,

    SAY_RANE            = 0,
    SAY_RANE_ANSWER     = 5,
    SAY_MOVE_QUINN      = 6,

    SAY_QUINN           = 7,
    SAY_QUINN_ANSWER    = 0,
    SAY_BYE             = 8,

    QUEST_ESCORTING     = 435,
    NPC_RANE            = 1950,
    NPC_QUINN           = 1951
};

class npc_deathstalker_erland : public CreatureScript
{
public:
    npc_deathstalker_erland() : CreatureScript("npc_deathstalker_erland") { }

    struct npc_deathstalker_erlandAI : public EscortAI
    {
        npc_deathstalker_erlandAI(Creature* creature) : EscortAI(creature) { }

        void WaypointReached(uint32 waypointId, uint32 pathId) override
        {
            Player* player = GetPlayerForEscort();
            if (!player)
                return;

            switch (waypointId)
            {
                case 1:
                    Talk(SAY_START, player);
                    break;
                case 10:
                    Talk(SAY_PROGRESS);
                    break;
                case 13:
                    Talk(SAY_LAST, player);
                    player->GroupEventHappens(QUEST_ESCORTING, me);
                    break;
                case 15:
                    if (Creature* rane = me->FindNearestCreature(NPC_RANE, 20.0f))
                        rane->AI()->Talk(SAY_RANE);
                    break;
                case 16:
                    Talk(SAY_RANE_ANSWER);
                    break;
                case 17:
                    Talk(SAY_MOVE_QUINN);
                    break;
                case 24:
                    Talk(SAY_QUINN);
                    break;
                case 25:
                    if (Creature* quinn = me->FindNearestCreature(NPC_QUINN, 20.0f))
                        quinn->AI()->Talk(SAY_QUINN_ANSWER);
                    break;
                case 26:
                    Talk(SAY_BYE);
                    break;
            }
        }

        void Reset() override { }

        void JustEngagedWith(Unit* who) override
        {
            Talk(SAY_AGGRO, who);
        }
    };

    bool OnQuestAccept(Player* player, Creature* creature, Quest const* quest) override
    {
        if (quest->GetQuestId() == QUEST_ESCORTING)
        {
            creature->AI()->Talk(SAY_QUESTACCEPT, player);

            if (EscortAI* pEscortAI = CAST_AI(npc_deathstalker_erland::npc_deathstalker_erlandAI, creature->AI()))
                pEscortAI->Start(true, player->GetGUID());
        }

        return true;
    }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_deathstalker_erlandAI(creature);
    }
};

enum FenwickThatros
{
    SAY_FENWICK_AGGRO          = 0,

    SPELL_DRINK_HEALING_POTION = 54633,
    SPELL_POTION_OF_STRENGTH   = 80471,
    SPELL_ELIXIR_OF_AGILITY    = 80472,
    SPELL_TONIC_OF_HEALTH      = 80473,

    EVENT_BUFF_STRENGTH        = 1,
    EVENT_BUFF_AGILITY         = 2,
    EVENT_BUFF_STAMINA         = 3,
    EVENT_HEALING              = 4
};

struct npc_fenwick_thatros : public ScriptedAI
{
    npc_fenwick_thatros(Creature* creature) : ScriptedAI(creature) {}

    void Reset() override
    {
        half_hp_reached_once = false;
        events.Reset();
    }

    void JustEngagedWith(Unit* /*who*/) override
    {
        Talk(SAY_FENWICK_AGGRO);
        events.ScheduleEvent(EVENT_BUFF_STRENGTH, 3000);
    }

    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/) override
    {
        if (!half_hp_reached_once && !HealthAbovePct(50))
        {
            half_hp_reached_once = true;
            me->CastSpell(me, SPELL_DRINK_HEALING_POTION);
            events.ScheduleEvent(EVENT_HEALING, 10000);
        }
    }

    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim())
            return;

        events.Update(diff);
        while (uint32 eventId = events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_BUFF_STRENGTH:
                    me->CastSpell(me, SPELL_POTION_OF_STRENGTH);
                    events.ScheduleEvent(EVENT_BUFF_AGILITY, 3000);
                    break;
                case EVENT_BUFF_AGILITY:
                    me->CastSpell(me, SPELL_ELIXIR_OF_AGILITY);
                    events.ScheduleEvent(EVENT_BUFF_STAMINA, 3000);
                    break;
                case EVENT_BUFF_STAMINA:
                    me->CastSpell(me, SPELL_TONIC_OF_HEALTH);
                    break;
                case EVENT_HEALING:
                    if (!HealthAbovePct(50))
                    {
                        me->CastSpell(me, SPELL_DRINK_HEALING_POTION);
                        events.ScheduleEvent(EVENT_HEALING, 10000);
                    }
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }
private:
    EventMap events;
    bool half_hp_reached_once = false;
};

/*######
## AddSC
######*/

/*######
## Quest 26998: Iterating Upon Success
######*/

// Bat Handler Maggotbreath lends the player a Forsaken Bat (Summon Forsaken Bat, which seats the
// player). The bat flies to the Dawning Isles and circles over the Vile Fin dens while the player throws Blight Concoction from
// its action bar; Go Home (or four minutes in the air) brings it back to Forsaken High Command. The handler himself is the
// credit "Bat requisitioned". The line of flight is a reconstruction over the places where the murlocs are spawned.
enum IteratingUponSuccess
{
    NPC_BAT_HANDLER_MAGGOTBREATH    = 44825,
    SPELL_BAT_GO_HOME               = 83594,

    SAY_BAT_ELIMINATE               = 0,
    SAY_BAT_RETURNING               = 1,

    POINT_BAT_OUT                   = 1,
    POINT_BAT_LOOP                  = 2,
    POINT_BAT_HOME                  = 3,

    BAT_OUTBOUND                    = 0,
    BAT_OVER_THE_ISLES              = 1,
    BAT_HOMEBOUND                   = 2,
    BAT_LANDED                      = 3,

    BAT_FLIGHT_TIME                 = 240 * IN_MILLISECONDS   // the summon lasts five minutes
};

static Position const BatWayOut[] =
{
    { 1400.0f, 950.0f, 72.0f, 0.0f }, { 1350.0f, 800.0f, 74.0f, 0.0f }, { 1290.0f, 600.0f, 70.0f, 0.0f },
    { 1230.0f, 440.0f, 64.0f, 0.0f }, { 1200.0f, 360.0f, 60.0f, 0.0f }
};

static Position const BatOverTheIsles[] =
{
    { 1160.0f, 330.0f, 60.0f, 0.0f }, { 1110.0f, 250.0f, 60.0f, 0.0f }, { 1060.0f, 290.0f, 62.0f, 0.0f }, { 1000.0f, 170.0f, 64.0f, 0.0f },
    { 920.0f, 170.0f, 64.0f, 0.0f }, { 850.0f, 90.0f, 60.0f, 0.0f }, { 800.0f, 130.0f, 62.0f, 0.0f }, { 800.0f, 210.0f, 64.0f, 0.0f },
    { 750.0f, 240.0f, 68.0f, 0.0f }, { 740.0f, 290.0f, 62.0f, 0.0f }, { 830.0f, 200.0f, 60.0f, 0.0f }, { 960.0f, 190.0f, 64.0f, 0.0f },
    { 1080.0f, 300.0f, 62.0f, 0.0f }, { 1190.0f, 390.0f, 60.0f, 0.0f }, { 1200.0f, 360.0f, 60.0f, 0.0f }
};

static Position const BatWayHome[] =
{
    { 1290.0f, 600.0f, 70.0f, 0.0f }, { 1350.0f, 800.0f, 74.0f, 0.0f }, { 1400.0f, 950.0f, 72.0f, 0.0f }, { 1421.0f, 1023.0f, 54.5f, 0.0f }
};

// Forsaken Bat 44821
struct npc_silverpine_forsaken_bat : public ScriptedAI
{
    npc_silverpine_forsaken_bat(Creature* creature) : ScriptedAI(creature) { }

    ObjectGuid playerGUID;
    uint32 stage = BAT_OUTBOUND;
    uint32 flown = 0;
    bool started = false;

    void InitializeAI() override
    {
        me->SetReactState(REACT_PASSIVE);
        me->SetCanFly(true);
        me->SetDisableGravity(true);
        me->SetSpeed(MOVE_FLIGHT, 2.4f);
        me->SetSpeed(MOVE_RUN, 2.4f);   // the path was flown at running speed
    }

    void Reset() override { }
    void AttackStart(Unit* /*who*/) override { }
    void MoveInLineOfSight(Unit* /*who*/) override { }
    void EnterEvadeMode(EvadeReason /*why*/) override { }
    void OnCharmed(bool /*apply*/) override { }   // the rider sits on the control seat (for the action bar): this AI stays

    void IsSummonedBy(Unit* summoner) override
    {
        Player* player = summoner->ToPlayer();
        if (!player)
            return;
        playerGUID = player->GetGUID();
        player->KilledMonsterCredit(NPC_BAT_HANDLER_MAGGOTBREATH);   // "Bat requisitioned from Bat Handler Maggotbreath"
    }

    Player* Rider() const
    {
        Vehicle* kit = me->GetVehicleKit();
        Unit* rider = kit ? kit->GetPassenger(0) : nullptr;
        return rider ? rider->ToPlayer() : nullptr;
    }

    template <size_t N>
    void Fly(Position const (&way)[N], uint32 pointId)
    {
        std::vector<Position> path;
        path.push_back(me->GetPosition());
        path.insert(path.end(), way, way + N);
        me->GetMotionMaster()->MoveSmoothPath(pointId, path.data(), path.size(), false, true);
    }

    void PassengerBoarded(Unit* who, int8 /*seatId*/, bool apply) override
    {
        Player* player = who->ToPlayer();
        if (!player)
            return;
        if (!apply)
        {
            if (stage != BAT_LANDED)
                me->DespawnOrUnsummon(1 * IN_MILLISECONDS);   // the rider is gone
            return;
        }
        // the control stays with the rider: without it the client shows no action bar; the spline keeps the reins
        if (!started)
        {
            started = true;
            Fly(BatWayOut, POINT_BAT_OUT);
        }
    }

    void GoHome()
    {
        if (stage == BAT_HOMEBOUND || stage == BAT_LANDED)
            return;
        stage = BAT_HOMEBOUND;
        if (Player* player = Rider())
            Talk(SAY_BAT_RETURNING, player);
        Fly(BatWayHome, POINT_BAT_HOME);
    }

    void SpellHit(Unit* /*caster*/, SpellInfo const* spell) override
    {
        if (spell->Id == SPELL_BAT_GO_HOME)
            GoHome();
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type != EFFECT_MOTION_TYPE)
            return;
        switch (id)
        {
            case POINT_BAT_OUT:
                if (stage != BAT_OUTBOUND)
                    break;
                stage = BAT_OVER_THE_ISLES;
                if (Player* player = Rider())
                    Talk(SAY_BAT_ELIMINATE, player);
                Fly(BatOverTheIsles, POINT_BAT_LOOP);
                break;
            case POINT_BAT_LOOP:
                if (stage == BAT_OVER_THE_ISLES)
                    Fly(BatOverTheIsles, POINT_BAT_LOOP);   // round and round until Go Home
                break;
            case POINT_BAT_HOME:
                stage = BAT_LANDED;
                if (Player* player = Rider())
                    player->ExitVehicle();
                me->DespawnOrUnsummon(1 * IN_MILLISECONDS);
                break;
            default:
                break;
        }
    }

    void UpdateAI(uint32 diff) override
    {
        if (!started || stage == BAT_HOMEBOUND || stage == BAT_LANDED)
            return;
        flown += diff;
        if (flown >= BAT_FLIGHT_TIME)
            GoHome();
    }
};

void AddSC_silverpine_forest()
{
    new npc_deathstalker_erland();
    new creature_script<npc_fenwick_thatros>("npc_fenwick_thatros");
    new creature_script<npc_silverpine_forsaken_bat>("npc_silverpine_forsaken_bat");
}
