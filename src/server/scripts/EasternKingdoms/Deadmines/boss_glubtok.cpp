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

/*
 * Glubtok (Deadmines) - encounter logic ported from the TrinityCore/CPP project
 * (Cataclysm-Preservation-Project, src/server/scripts/EasternKingdoms/Deadmines/boss_glubtok.cpp,
 * GPL-2.0) to the 5.4.8 script API of this core.
 *
 * Differences against the reference (see NOTES_glubtok.txt):
 *  - the Firewall Platter (48974) is the one spawned in the DB (creature guid 326770, waypoint path),
 *    it is NOT summoned from the script; Level 2 platters are vehicle accessories (SQL) and are found
 *    through the vehicle chain when the Fire Wall starts.
 *  - Blossom targeting is done in code (no spell_glubtok_blossom_targeting SpellScript needed).
 *  - fall-backs for missing DB spawns (General Purpose Bunny L2 beams, JMF dummy for the explosion,
 *    blossom bunnies for the beam visuals like the old script did).
 */

#include "ScriptPCH.h"
#include "ObjectAccessor.h"
#include "MoveSplineInit.h"
#include "TemporarySummon.h"
#include "deadmines.h"

namespace
{

enum GTTexts
{
    GT_SAY_AGGRO                = 0,
    GT_SAY_FISTS_OF_FLAME       = 1,
    GT_SAY_FISTS_OF_FROST       = 2,
    GT_SAY_PHASE_TWO_INTRO_1    = 3,
    GT_SAY_PHASE_TWO_INTRO_2    = 4,
    GT_SAY_ARCANE_POWER         = 5,
    GT_SAY_ANNOUNCE_FIRE_WALL   = 6,
    GT_SAY_DEATH                = 7,
    GT_SAY_KILL                 = 8     // new group, see quest_data_fix_241.sql
};

enum GTSpells
{
    // Glubtok
    GT_SPELL_BLINK                      = 87925,
    GT_SPELL_FISTS_OF_FROST             = 87861,
    GT_SPELL_FISTS_OF_FLAME             = 87859,
    GT_SPELL_TELEPORT                   = 88002,
    GT_SPELL_EMOTE_TALK                 = 79506,
    GT_SPELL_EMOTE_ROAR                 = 48350,
    GT_SPELL_ARCANE_POWER               = 88009,
    GT_SPELL_ARCANE_FIRE_BEAM           = 88072,
    GT_SPELL_ARCANE_FROST_BEAM          = 88093,
    GT_SPELL_STUN_SELF                  = 88040,
    GT_SPELL_FROST_BLOSSOM              = 88169,
    GT_SPELL_FROST_BLOSSOM_VISUAL       = 88165,
    GT_SPELL_FIRE_BLOSSOM               = 88129,
    GT_SPELL_FIRE_BLOSSOM_VISUAL        = 88164,
    GT_SPELL_ARCANE_OVERLOAD            = 88183,
    GT_SPELL_TRANSITION_INVISIBILITY    = 90424,
    GT_SPELL_ARCANE_OVERLOAD_INSTAKILL  = 88185,

    // Fire Wall Platter
    GT_SPELL_FIRE_WALL                  = 91398,

    // General Purpose Bunny JMF
    GT_SPELL_ARCANE_OVERLOAD_EXPLOSION  = 90520,

    // Old script beam visuals (cast by the Fire/Frost Blossom Bunnies on Glubtok), used as fall-back
    GT_SPELL_OLD_FIRE_BEAM_VISUAL       = 45576,
    GT_SPELL_OLD_FROST_BEAM_VISUAL      = 99490
};

enum GTEvents
{
    GT_EVENT_BLINK = 1,
    GT_EVENT_ELEMENTAL_FISTS,
    GT_EVENT_PHASE_TWO_INTRO_1,
    GT_EVENT_PHASE_TWO_INTRO_2,
    GT_EVENT_ARCANE_POWER,
    GT_EVENT_STUN_SELF,
    GT_EVENT_ANNOUNCE_FIRE_WALL,
    GT_EVENT_FIRE_WALL,
    GT_EVENT_BLOSSOM_TARGETING,
    GT_EVENT_KILL_SELF
};

enum GTPhases
{
    GT_PHASE_1 = 1,
    GT_PHASE_2 = 2
};

enum GTFists
{
    GT_FISTS_OF_FLAME = 0,
    GT_FISTS_OF_FROST = 1
};

enum GTNpcs
{
    NPC_GT_JMF_DUMMY            = 45979,    // General Purpose Bunny JMF
    NPC_GT_FIREWALL_PLATTER     = 48974,
    NPC_GT_FIREWALL_PLATTER_2A  = 48976,
    NPC_GT_FIREWALL_PLATTER_2B  = 49041,
    NPC_GT_FIREWALL_PLATTER_2C  = 49042,
    NPC_GT_BUNNY_L2             = 47242,    // General Purpose Bunny JMF (Look 2), beam targets
    NPC_GT_FIRE_BLOSSOM         = 48957,    // summoned by Fire Blossom (88129 -> 91301)
    NPC_GT_FROST_BLOSSOM        = 48958     // summoned by Frost Blossom (88169 -> 91302)
};

Position const GTLeftSideReference = { -210.840f, -443.449f, 61.179f };

} // namespace

class boss_glubtok : public CreatureScript
{
    public:
        boss_glubtok() : CreatureScript("boss_glubtok") { }

        struct boss_glubtokAI : public BossAI
        {
            boss_glubtokAI(Creature* creature) : BossAI(creature, DATA_GLUBTOK),
                _defeated(false), _floating(false), _stunFlag(false),
                _lastFists(GT_FISTS_OF_FLAME), _nextBlossomBunny(NPC_FIRE_BLOSSOM_BUNNY)
            {
                me->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_STUN, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FEAR, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_ROOT, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FREEZE, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_POLYMORPH, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_HORROR, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_SAPPED, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_CHARM, true);
                me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_DISORIENTED, true);
                me->ApplySpellImmune(0, IMMUNITY_STATE, SPELL_AURA_MOD_CONFUSE, true);
                me->setActive(true);
            }

            void Reset() override
            {
                _Reset();

                _defeated = false;
                _lastFists = GT_FISTS_OF_FLAME;
                _nextBlossomBunny = NPC_FIRE_BLOSSOM_BUNNY;

                me->SetCanDualWield(true);
                me->SetReactState(REACT_AGGRESSIVE);

                if (_floating)
                {
                    me->SetDisableGravity(false);
                    _floating = false;
                }

                if (_stunFlag)
                {
                    me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_STUNNED);
                    _stunFlag = false;
                }

                StopBeams();
                StopFireWall();

                if (instance)
                    instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
            }

            void JustEngagedWith(Unit* who) override
            {
                BossAI::JustEngagedWith(who);

                Talk(GT_SAY_AGGRO);

                if (instance)
                    instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);

                events.SetPhase(GT_PHASE_1);
                events.ScheduleEvent(GT_EVENT_BLINK, urand(16000, 18000), 0, GT_PHASE_1);
            }

            void KilledUnit(Unit* victim) override
            {
                if (victim && victim->GetTypeId() == TYPEID_PLAYER)
                    Talk(GT_SAY_KILL);
            }

            void JustDied(Unit* /*killer*/) override
            {
                _JustDied();

                if (instance)
                    instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);

                StopBeams();
                StopFireWall();
            }

            void EnterEvadeMode(EvadeReason why) override
            {
                if (!_EnterEvadeMode(why))
                    return;

                summons.DespawnAll();

                if (instance)
                    instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);

                StopBeams();
                StopFireWall();
                _DespawnAtEvade();
            }

            void JustSummoned(Creature* summon) override
            {
                BossAI::JustSummoned(summon);

                // old script behaviour: the summoned blossom itself gets the visual aura
                switch (summon->GetEntry())
                {
                    case NPC_GT_FIRE_BLOSSOM:
                        summon->CastSpell(summon, GT_SPELL_FIRE_BLOSSOM_VISUAL, true);
                        break;
                    case NPC_GT_FROST_BLOSSOM:
                        summon->CastSpell(summon, GT_SPELL_FROST_BLOSSOM_VISUAL, true);
                        break;
                    default:
                        break;
                }
            }

            void DamageTaken(Unit* /*attacker*/, uint32& damage) override
            {
                if (me->HealthBelowPctDamaged(50, damage) && !events.IsInPhase(GT_PHASE_2) && !_defeated)
                {
                    events.SetPhase(GT_PHASE_2);
                    me->SetReactState(REACT_PASSIVE);
                    me->AttackStop();
                    me->InterruptNonMeleeSpells(true);
                    DoCastSelf(GT_SPELL_TELEPORT, true);
                    me->StopMoving();

                    Position const& home = me->GetHomePosition();
                    me->NearTeleportTo(home.GetPositionX(), home.GetPositionY(), home.GetPositionZ(), home.GetOrientation());

                    events.ScheduleEvent(GT_EVENT_PHASE_TWO_INTRO_1, 3800, 0, GT_PHASE_2);
                }

                if (damage >= me->GetHealth())
                {
                    damage = me->GetHealth() - 1;

                    if (!_defeated)
                    {
                        _defeated = true;
                        Talk(GT_SAY_DEATH);
                        events.Reset();
                        DoCastSelf(GT_SPELL_ARCANE_OVERLOAD);
                        events.ScheduleEvent(GT_EVENT_KILL_SELF, 4800);
                        StartBeams();
                    }
                }
            }

            void UpdateAI(uint32 diff) override
            {
                if (!UpdateVictim())
                    return;

                events.Update(diff);

                if (me->HasUnitState(UNIT_STATE_CASTING))
                    return;

                while (uint32 eventId = events.ExecuteEvent())
                {
                    switch (eventId)
                    {
                        case GT_EVENT_BLINK:
                        {
                            // first try everybody but the tank, like the old script did
                            Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 1, 50.0f, true);
                            if (!target)
                                target = SelectTarget(SELECT_TARGET_RANDOM, 0, 50.0f, true);

                            if (target)
                            {
                                DoCast(target, GT_SPELL_BLINK);
                                if (IsHeroic())
                                    me->GetThreatManager().ResetAllThreat();

                                events.ScheduleEvent(GT_EVENT_ELEMENTAL_FISTS, 800, 0, GT_PHASE_1);
                            }
                            events.ScheduleEvent(GT_EVENT_BLINK, urand(13000, 14000), 0, GT_PHASE_1);
                            break;
                        }
                        case GT_EVENT_ELEMENTAL_FISTS:
                        {
                            bool frost = (_lastFists == GT_FISTS_OF_FLAME);
                            Talk(frost ? GT_SAY_FISTS_OF_FROST : GT_SAY_FISTS_OF_FLAME);
                            me->RemoveAurasDueToSpell(frost ? GT_SPELL_FISTS_OF_FLAME : GT_SPELL_FISTS_OF_FROST);
                            DoCastSelf(frost ? GT_SPELL_FISTS_OF_FROST : GT_SPELL_FISTS_OF_FLAME);
                            _lastFists = frost ? GT_FISTS_OF_FROST : GT_FISTS_OF_FLAME;
                            break;
                        }
                        case GT_EVENT_PHASE_TWO_INTRO_1:
                            Talk(GT_SAY_PHASE_TWO_INTRO_1);
                            DoCastSelf(GT_SPELL_EMOTE_TALK, true);
                            events.ScheduleEvent(GT_EVENT_PHASE_TWO_INTRO_2, 2400, 0, GT_PHASE_2);
                            break;
                        case GT_EVENT_PHASE_TWO_INTRO_2:
                            Talk(GT_SAY_PHASE_TWO_INTRO_2);
                            DoCastSelf(GT_SPELL_EMOTE_ROAR, true);
                            events.ScheduleEvent(GT_EVENT_ARCANE_POWER, 2400, 0, GT_PHASE_2);
                            break;
                        case GT_EVENT_ARCANE_POWER:
                        {
                            Talk(GT_SAY_ARCANE_POWER);
                            DoCastSelf(GT_SPELL_ARCANE_POWER);
                            me->SetDisableGravity(true);
                            _floating = true;

                            Movement::MoveSplineInit init(me);
                            init.MoveTo(me->GetPositionX(), me->GetPositionY(), me->GetPositionZ() + 2.0f, false);
                            init.SetWalk(true);
                            init.SetVelocity(0.8f);
                            init.Launch();

                            StartBeams();

                            events.ScheduleEvent(GT_EVENT_STUN_SELF, 2200, 0, GT_PHASE_2);
                            events.ScheduleEvent(GT_EVENT_BLOSSOM_TARGETING, 6000, 0, GT_PHASE_2);
                            break;
                        }
                        case GT_EVENT_STUN_SELF:
                            DoCastSelf(GT_SPELL_STUN_SELF, true);
                            // Glubtok is mechanic-immune to stuns; if the aura was refused, set the visual state by hand
                            if (!me->HasAura(GT_SPELL_STUN_SELF))
                            {
                                me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_STUNNED);
                                _stunFlag = true;
                            }
                            if (IsHeroic())
                                events.ScheduleEvent(GT_EVENT_ANNOUNCE_FIRE_WALL, 1500, 0, GT_PHASE_2);
                            break;
                        case GT_EVENT_ANNOUNCE_FIRE_WALL:
                            Talk(GT_SAY_ANNOUNCE_FIRE_WALL);
                            events.ScheduleEvent(GT_EVENT_FIRE_WALL, 1400, 0, GT_PHASE_2);
                            break;
                        case GT_EVENT_FIRE_WALL:
                        {
                            std::vector<Creature*> platters;
                            CollectFirewallPlatters(platters);
                            for (Creature* platter : platters)
                                platter->CastSpell(platter, GT_SPELL_FIRE_WALL, true);
                            break;
                        }
                        case GT_EVENT_BLOSSOM_TARGETING:
                            _nextBlossomBunny = (_nextBlossomBunny == NPC_FIRE_BLOSSOM_BUNNY) ? NPC_FROST_BLOSSOM_BUNNY : NPC_FIRE_BLOSSOM_BUNNY;
                            CastBlossom();
                            events.ScheduleEvent(GT_EVENT_BLOSSOM_TARGETING, 2400, 0, GT_PHASE_2);
                            break;
                        case GT_EVENT_KILL_SELF:
                        {
                            Creature* creature = me;
                            me->Kill(me, false);
                            me->m_Events.Schedule(1600, [creature]()
                            {
                                creature->CastSpell(creature, GT_SPELL_TRANSITION_INVISIBILITY, true);
                                creature->CastSpell(creature, GT_SPELL_ARCANE_OVERLOAD_INSTAKILL, true);

                                Creature* bunny = creature->FindNearestCreature(NPC_GT_JMF_DUMMY, 5.0f, true);
                                if (!bunny)
                                    bunny = creature->SummonCreature(NPC_GT_JMF_DUMMY, *creature, TEMPSUMMON_TIMED_DESPAWN, 5000ms);
                                if (bunny)
                                    bunny->CastSpell(bunny, GT_SPELL_ARCANE_OVERLOAD_EXPLOSION, true);
                            });
                            return; // we are dead now, nothing more to do for this tick
                        }
                        default:
                            break;
                    }

                    if (me->HasUnitState(UNIT_STATE_CASTING))
                        return;
                }

                DoMeleeAttackIfReady();
            }

        private:
            // ---- Fire Wall -------------------------------------------------------------------------------------
            // Level 2 platters are the passengers of the Level 1 platters, which are passengers of the central
            // Firewall Platter (vehicle_template_accessory, see quest_data_fix_241.sql). They are not summoned by
            // the boss, so we look them up through the vehicle chain.
            void CollectFirewallPlatters(std::vector<Creature*>& out)
            {
                // Reset() runs while the creature is being initialised, the grid is not usable before it is in the world
                if (!me->IsInWorld())
                    return;

                Creature* root = me->FindNearestCreature(NPC_GT_FIREWALL_PLATTER, 40.0f, true);
                if (!root)
                    return;

                static uint32 const entries[] = { NPC_GT_FIREWALL_PLATTER_2A, NPC_GT_FIREWALL_PLATTER_2B, NPC_GT_FIREWALL_PLATTER_2C };

                std::vector<Creature*> nearby;
                for (uint32 entry : entries)
                {
                    std::list<Creature*> tmp;
                    GetCreatureListWithEntryInGrid(tmp, root, entry, 80.0f);
                    for (Creature* c : tmp)
                    {
                        nearby.push_back(c);
                        Unit* level1 = c->GetVehicleBase();
                        Unit* base = level1 ? level1->GetVehicleBase() : nullptr;
                        if (base == root)
                            out.push_back(c);
                    }
                }

                // chain not intact (other accessory layout): use everything close to the platter
                if (out.empty())
                    for (Creature* c : nearby)
                        if (c->GetExactDist(root) <= 50.0f)
                            out.push_back(c);
            }

            void StopFireWall()
            {
                std::vector<Creature*> platters;
                CollectFirewallPlatters(platters);
                for (Creature* platter : platters)
                    platter->RemoveAurasDueToSpell(GT_SPELL_FIRE_WALL);
            }

            // ---- Arcane beams ----------------------------------------------------------------------------------
            void StartBeams()
            {
                StopBeams();

                std::list<Creature*> bunnies;
                GetCreatureListWithEntryInGrid(bunnies, me, NPC_GT_BUNNY_L2, 30.0f);

                if (!bunnies.empty())
                {
                    for (Creature* bunny : bunnies)
                    {
                        // left side of the room is frost, the rest fire (reference: leftSideDistanceCheck)
                        if (bunny->GetHomePosition().GetExactDist(&GTLeftSideReference) <= 20.0f)
                            bunny->CastSpell(bunny, GT_SPELL_ARCANE_FROST_BEAM, true);
                        else
                            bunny->CastSpell(bunny, GT_SPELL_ARCANE_FIRE_BEAM, true);
                        _beamGUIDs.push_back(bunny->GetGUID());
                    }
                    return;
                }

                // fall-back (old script): 4 random Fire and 3 random Frost Blossom Bunnies channel a beam on Glubtok
                std::list<Creature*> fireList;
                std::list<Creature*> frostList;
                GetCreatureListWithEntryInGrid(fireList, me, NPC_FIRE_BLOSSOM_BUNNY, 100.0f);
                GetCreatureListWithEntryInGrid(frostList, me, NPC_FROST_BLOSSOM_BUNNY, 100.0f);

                if (fireList.size() > 4)
                    Trinity::Containers::RandomResizeList(fireList, 4);
                if (frostList.size() > 3)
                    Trinity::Containers::RandomResizeList(frostList, 3);

                for (Creature* bunny : fireList)
                {
                    bunny->CastSpell(me, GT_SPELL_OLD_FIRE_BEAM_VISUAL, false);
                    _beamGUIDs.push_back(bunny->GetGUID());
                }
                for (Creature* bunny : frostList)
                {
                    bunny->CastSpell(me, GT_SPELL_OLD_FROST_BEAM_VISUAL, false);
                    _beamGUIDs.push_back(bunny->GetGUID());
                }
            }

            void StopBeams()
            {
                for (ObjectGuid const& guid : _beamGUIDs)
                {
                    if (Creature* bunny = ObjectAccessor::GetCreature(*me, guid))
                    {
                        bunny->InterruptNonMeleeSpells(false);
                        bunny->RemoveAurasDueToSpell(GT_SPELL_ARCANE_FIRE_BEAM);
                        bunny->RemoveAurasDueToSpell(GT_SPELL_ARCANE_FROST_BEAM);
                        bunny->RemoveAurasDueToSpell(GT_SPELL_OLD_FIRE_BEAM_VISUAL);
                        bunny->RemoveAurasDueToSpell(GT_SPELL_OLD_FROST_BEAM_VISUAL);
                    }
                }
                _beamGUIDs.clear();
            }

            // ---- Blossoms --------------------------------------------------------------------------------------
            // Phase 2: alternate between Fire and Frost Blossom Bunnies, pick one at random and cast the blossom on it.
            void CastBlossom()
            {
                bool fire = (_nextBlossomBunny == NPC_FIRE_BLOSSOM_BUNNY);
                uint32 spellId = fire ? GT_SPELL_FIRE_BLOSSOM : GT_SPELL_FROST_BLOSSOM;

                std::list<Creature*> bunnies;
                GetCreatureListWithEntryInGrid(bunnies, me, _nextBlossomBunny, 80.0f);
                bunnies.remove_if([](Creature* c) { return !c->IsAlive(); });

                if (!bunnies.empty())
                {
                    std::list<Creature*>::iterator itr = bunnies.begin();
                    std::advance(itr, urand(0, bunnies.size() - 1));
                    Creature* bunny = *itr;

                    DoCast(bunny, spellId, true);
                    bunny->CastSpell(bunny, fire ? GT_SPELL_FIRE_BLOSSOM_VISUAL : GT_SPELL_FROST_BLOSSOM_VISUAL, true);
                    return;
                }

                // fall-back (old script): blossom on a random player
                if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 0.0f, true))
                    DoCast(target, spellId, true);
            }

            bool _defeated;
            bool _floating;
            bool _stunFlag;
            uint8 _lastFists;
            uint32 _nextBlossomBunny;
            std::vector<ObjectGuid> _beamGUIDs;
        };

        CreatureAI* GetAI(Creature* creature) const override
        {
            return GetInstanceAI<boss_glubtokAI>(creature);
        }
};

void AddSC_boss_glubtok()
{
    new boss_glubtok();
}
