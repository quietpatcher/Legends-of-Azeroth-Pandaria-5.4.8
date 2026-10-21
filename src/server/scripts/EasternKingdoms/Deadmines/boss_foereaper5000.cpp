/*
* This file is part of the Pandaria 5.4.8 Project. See THANKS file for Copyright information
*
* Encounter logic ported from the TrinityCore/CPP project (Cataclysm-Preservation-Project),
* src/server/scripts/EasternKingdoms/Deadmines/boss_foe_reaper_5000.cpp
* (This file is part of the TrinityCore Project. See AUTHORS file for Copyright information)
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

// Foe Reaper 5000 (Deadmines), ported from the TrinityCore/CPP project to the 5.4.8 script API of this core.
//
// Differences against the reference (all on purpose, see NOTES.txt):
//  - No instance data is needed: the intro state, the harvest bunny and the announcer bunny are kept in the AI.
//  - Acquiring Target / Harvest and Fixate are driven from the AI instead of spell scripts (no spell_script_names rows).
//  - Molten Slag are summoned directly (the summon spells 91839-91843 have no target conditions / bunnies in our DB).
//  - EventMap::RepeatEvent() of this core is not usable (it re-times the NEXT event), so every repeat is ScheduleEvent().
//  - Boss is not despawned on evade (reference: _DespawnAtEvade).

#include "ScriptPCH.h"
#include "deadmines.h"

namespace FoeReaper5000
{

enum Texts
{
    // Foe Reaper 5000 (creature_text 43778)
    SAY_ON_LINE                         = 0,
    SAY_ANNOUNCE_OVERDRIVE              = 1,
    SAY_OVERDRIVE                       = 2,
    SAY_ACQUIRING_TARGET                = 3,
    SAY_HARVEST                         = 4,
    SAY_SAFETY_RESTRICTIONS_OFFLINE     = 5,
    SAY_ANNOUNCE_RESTRICTIONS_OFFLINE   = 6,
    SAY_SLAY                            = 7,
    SAY_DEATH                           = 8
};

enum BunnyTexts
{
    // General Purpose Bunny JMF (creature_text 45979)
    SAY_ANNOUNCE_FOUNDRY_DISRUPTED      = 0,
    SAY_ANNOUNCE_MOLTEN_SLAG            = 1
};

enum Spells
{
    // Foe Reaper 5000
    SPELL_ENERGIZE                      = 89132,
    SPELL_ON_LINE                       = 89198,
    SPELL_ON_LINE_2                     = 89121,
    SPELL_RED_EYES                      = 24263,
    SPELL_REAPER_STRIKE                 = 88490,
    SPELL_OVERDRIVE                     = 88481,
    SPELL_ACQUIRING_TARGET              = 88492,
    SPELL_HARVEST                       = 88495, // summons the targeting bunny on the target + triggers 88497 on the boss
    SPELL_HARVEST_AURA                  = 88497, // periodic damage while the boss runs to the bunny
    SPELL_HARVEST_SWEEP                 = 88521,
    SPELL_SAFETY_RESTRICTIONS_OFFLINE   = 88522,

    // Targeting bunny
    SPELL_TARGET_BUNNY                  = 71371, // rocket artillery ring

    // Molten Slag (heroic)
    SPELL_MOLTEN_SHIELD                 = 91815,
    SPELL_FIXATE                        = 91830, // marker aura on the player (cast by the slag)
    SPELL_FIXATE_TAUNT                  = 91829  // taunt aura, cast by the player on the slag
};

enum Npcs
{
    NPC_TARGETING_BUNNY                 = 47468,
    NPC_MOLTEN_SLAG                     = 49229,
    NPC_PROTOTYPE_REAPER                = 49208,
    NPC_GENERAL_PURPOSE_BUNNY           = 45979  // General Purpose Bunny JMF
};

enum Events
{
    // Foe Reaper 5000, in combat (EventMap events)
    EVENT_OVERDRIVE = 1,
    EVENT_MOVE_OVERDRIVE,
    EVENT_END_OVERDRIVE,
    EVENT_ACQUIRING_TARGET,
    EVENT_HARVEST,
    EVENT_HARVEST_SWEEP,
    EVENT_HARVEST_FAILSAFE,
    EVENT_ANNOUNCE_SAFETY_RESTRICTIONS_OFFLINE,
    EVENT_ANNOUNCE_DISRUPTING_FOUNDRY,
    EVENT_ANNOUNCE_MOLTEN_SLAG,
    EVENT_SUMMON_MOLTEN_SLAG,

    // Foe Reaper 5000, on-line sequence (separate EventMap, runs outside combat as well)
    EVENT_CHECK_ENERGY,
    EVENT_ON_LINE,
    EVENT_RED_EYES,
    EVENT_ON_LINE_2,

    // Molten Slag
    EVENT_MOLTEN_SHIELD,
    EVENT_FIXATE_PLAYER
};

enum Points
{
    POINT_MOVE_OVERDRIVE    = 1,
    POINT_MOVE_HARVEST      = 2
};

// Pits of the foundry (the ring around the centre of the room)
static Position const moltenSlagPos[4] =
{
    { -205.582f, -572.034f, 20.97f, 1.59f },
    { -199.143f, -579.843f, 20.97f, 6.16f },
    { -206.385f, -585.898f, 20.97f, 5.17f },
    { -212.704f, -579.072f, 20.97f, 3.09f }
};

// Used only as the speaker of the two heroic announcements when no General Purpose Bunny JMF is near the boss
// (the only one in the DB stands on the ship, 250 yards away).
static Position const foundryCenterPos = { -205.8f, -579.0f, 21.0f, 0.0f };

class boss_foereaper5000 : public CreatureScript
{
    public:
        boss_foereaper5000() : CreatureScript("boss_foereaper5000") { }

        struct boss_foereaper5000AI : public BossAI
        {
            boss_foereaper5000AI(Creature* creature) : BossAI(creature, DATA_FOEREAPER)
            {
                me->SetPowerType(POWER_ENERGY);
                me->SetMaxPower(POWER_ENERGY, 100);
            }

            void InitializeAI() override
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
                me->CastSpell(me, SPELL_OFF_LINE, true);
                // Only when the aura really sticks do we wait for its removal (see UpdateIntro)
                _offlineCast = me->HasAura(SPELL_OFF_LINE);
                Reset();
            }

            void Reset() override
            {
                _Reset();

                if (instance)
                    instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);

                _safetyRestrictionsOffline = false;
                _overdriveActive = false;
                _harvestActive = false;
                _harvestBunnyGuid = ObjectGuid::Empty;
                me->SetReactState(REACT_AGGRESSIVE);

                if (_introStarted)
                {
                    // Evade after the On-line sequence started: the boss stays on-line (evade removed the auras)
                    _introEvents.Reset();
                    _introDone = true;
                    me->RemoveAurasDueToSpell(SPELL_OFF_LINE);
                    DoCastSelf(SPELL_RED_EYES, true);
                    me->SetPower(POWER_ENERGY, 100);
                }
                else if (_offlineCast)
                    me->SetPower(POWER_ENERGY, 0);
            }

            // --- On-line sequence (reference: Energize -> 3s -> On-line -> 8.4s -> Red Eyes -> 2.4s -> On-line + yell) ---

            void StartIntro(bool energized)
            {
                if (_introStarted)
                    return;

                _introStarted = true;
                if (energized)
                    _introEvents.ScheduleEvent(EVENT_ON_LINE, 3000);
                else
                    _introEvents.ScheduleEvent(EVENT_RED_EYES, 500); // Off-line was already removed from outside, skip the long wait
            }

            void UpdateIntro(uint32 diff)
            {
                // Our instance script removes Off-line after the fourth Defias kill (it does not cast Energize on the boss).
                if (_offlineCast && !_introStarted && !me->HasAura(SPELL_OFF_LINE))
                    StartIntro(false);

                if (_introEvents.Empty())
                    return;

                _introEvents.Update(diff);

                while (uint32 eventId = _introEvents.ExecuteEvent())
                {
                    switch (eventId)
                    {
                        case EVENT_CHECK_ENERGY:
                            if (me->GetPower(POWER_ENERGY) >= 100)
                                StartIntro(true);
                            break;
                        case EVENT_ON_LINE:
                            // triggered: the boss is still stunned by Off-line
                            DoCastSelf(SPELL_ON_LINE, true);
                            _introEvents.ScheduleEvent(EVENT_RED_EYES, 8400);
                            break;
                        case EVENT_RED_EYES:
                            DoCastSelf(SPELL_RED_EYES, true);
                            _introEvents.ScheduleEvent(EVENT_ON_LINE_2, 2400);
                            break;
                        case EVENT_ON_LINE_2:
                            me->RemoveAurasDueToSpell(SPELL_OFF_LINE);
                            me->SetPower(POWER_ENERGY, 100);
                            DoCastSelf(SPELL_ON_LINE_2, true);
                            Talk(SAY_ON_LINE);
                            _introDone = true;
                            break;
                        default:
                            break;
                    }
                }
            }

            void SpellHit(Unit* /*caster*/, SpellInfo const* spell) override
            {
                if (spell->Id == SPELL_ENERGIZE && !_introStarted)
                    _introEvents.ScheduleEvent(EVENT_CHECK_ENERGY, 200); // the energy is added after the AI hook
            }

            // --- Combat ---

            void JustEngagedWith(Unit* who) override
            {
                BossAI::JustEngagedWith(who);

                if (instance)
                    instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);

                me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_STUNNED);

                events.ScheduleEvent(EVENT_OVERDRIVE, 9000);
                events.ScheduleEvent(EVENT_ACQUIRING_TARGET, 35000);

                if (IsHeroic())
                {
                    GetAnnouncer(); // make sure the speaker exists before the first announcement
                    events.ScheduleEvent(EVENT_ANNOUNCE_DISRUPTING_FOUNDRY, 4000);
                    events.ScheduleEvent(EVENT_ANNOUNCE_MOLTEN_SLAG, 6400);
                    events.ScheduleEvent(EVENT_SUMMON_MOLTEN_SLAG, 17000);
                }
            }

            void JustDied(Unit* /*killer*/) override
            {
                _JustDied();
                _introEvents.Reset();
                Talk(SAY_DEATH);

                if (instance)
                    instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);

                if (IsHeroic())
                    if (Creature* prototype = me->FindNearestCreature(NPC_PROTOTYPE_REAPER, 200.0f, true))
                        prototype->DespawnOrUnsummon(5000);
            }

            void KilledUnit(Unit* victim) override
            {
                if (victim && victim->GetTypeId() == TYPEID_PLAYER)
                    Talk(SAY_SLAY);
            }

            void JustSummoned(Creature* summon) override
            {
                switch (summon->GetEntry())
                {
                    case NPC_TARGETING_BUNNY:
                        summons.Summon(summon);
                        StartHarvest(summon);
                        break;
                    case NPC_GENERAL_PURPOSE_BUNNY:
                        summons.Summon(summon);
                        break;
                    default: // Molten Slag: BossAI puts them in combat
                        BossAI::JustSummoned(summon);
                        break;
                }
            }

            void MovementInform(uint32 type, uint32 pointId) override
            {
                if (type != POINT_MOTION_TYPE)
                    return;

                switch (pointId)
                {
                    case POINT_MOVE_OVERDRIVE:
                        if (_overdriveActive)
                            events.RescheduleEvent(EVENT_MOVE_OVERDRIVE, 700);
                        break;
                    case POINT_MOVE_HARVEST:
                        if (_harvestActive)
                        {
                            me->RemoveAurasDueToSpell(SPELL_HARVEST_AURA);
                            events.CancelEvent(EVENT_HARVEST_FAILSAFE);
                            events.ScheduleEvent(EVENT_HARVEST_SWEEP, 1000);
                        }
                        break;
                    default:
                        break;
                }
            }

            void DamageTaken(Unit* /*attacker*/, uint32& damage) override
            {
                if (damage < me->GetHealth())
                    CheckSafetyRestrictions(damage);
            }

            void CheckSafetyRestrictions(uint32 damage)
            {
                if (_safetyRestrictionsOffline || !me->HealthBelowPctDamaged(30, damage))
                    return;

                _safetyRestrictionsOffline = true;
                Talk(SAY_SAFETY_RESTRICTIONS_OFFLINE);
                DoCastSelf(SPELL_SAFETY_RESTRICTIONS_OFFLINE, true);
                events.ScheduleEvent(EVENT_ANNOUNCE_SAFETY_RESTRICTIONS_OFFLINE, 3800);
            }

            // --- Harvest ---

            void StartHarvest(Creature* bunny)
            {
                _harvestActive = true;
                _harvestBunnyGuid = bunny->GetGUID();

                me->StopMoving();
                me->AttackStop();
                me->SetReactState(REACT_PASSIVE);
                me->SetFacingToObject(bunny);

                Talk(SAY_HARVEST);
                events.ScheduleEvent(EVENT_HARVEST, 2000);
                events.ScheduleEvent(EVENT_HARVEST_FAILSAFE, 14000); // path failed / boss stuck
            }

            void EndHarvest()
            {
                _harvestActive = false;
                _harvestBunnyGuid = ObjectGuid::Empty;

                events.CancelEvent(EVENT_HARVEST);
                events.CancelEvent(EVENT_HARVEST_FAILSAFE);
                me->RemoveAurasDueToSpell(SPELL_HARVEST_AURA);
                summons.DespawnEntry(NPC_TARGETING_BUNNY);

                me->resetAttackTimer();
                me->SetReactState(REACT_AGGRESSIVE); // UpdateVictim() picks the victim again and chases
            }

            // --- Overdrive ---

            bool GetOverdriveDestination(float& x, float& y, float& z)
            {
                for (uint8 i = 0; i < 5; ++i)
                {
                    me->GetRandomPoint(me->GetPosition(), 15.0f, x, y, z);
                    if (std::fabs(z - me->GetPositionZ()) <= 10.0f)
                        return true;
                }
                return false;
            }

            void EndOverdrive()
            {
                _overdriveActive = false;
                events.CancelEvent(EVENT_MOVE_OVERDRIVE);
                events.CancelEvent(EVENT_END_OVERDRIVE);
                me->RemoveAurasDueToSpell(SPELL_OVERDRIVE);
                me->GetMotionMaster()->Clear();
                me->SetReactState(REACT_AGGRESSIVE);
            }

            // --- Heroic speaker ---

            Creature* GetAnnouncer()
            {
                if (Creature* bunny = ObjectAccessor::GetCreature(*me, _announcerGuid))
                    if (bunny->IsAlive())
                        return bunny;

                if (Creature* bunny = me->FindNearestCreature(NPC_GENERAL_PURPOSE_BUNNY, 100.0f, true))
                {
                    _announcerGuid = bunny->GetGUID();
                    return bunny;
                }

                if (Creature* bunny = me->SummonCreature(NPC_GENERAL_PURPOSE_BUNNY, foundryCenterPos, TEMPSUMMON_MANUAL_DESPAWN))
                {
                    _announcerGuid = bunny->GetGUID();
                    return bunny;
                }

                return nullptr;
            }

            void ExecuteEvent(uint32 eventId) override
            {
                switch (eventId)
                {
                    case EVENT_OVERDRIVE:
                        if (_harvestActive)
                        {
                            events.ScheduleEvent(EVENT_OVERDRIVE, 3000);
                            break;
                        }
                        DoCastSelf(SPELL_OVERDRIVE);
                        Talk(SAY_ANNOUNCE_OVERDRIVE);
                        Talk(SAY_OVERDRIVE);
                        _overdriveActive = true;
                        me->AttackStop();
                        me->SetReactState(REACT_PASSIVE);
                        events.ScheduleEvent(EVENT_MOVE_OVERDRIVE, 2000);
                        events.ScheduleEvent(EVENT_END_OVERDRIVE, 10000);
                        events.ScheduleEvent(EVENT_OVERDRIVE, 53000);
                        break;
                    case EVENT_MOVE_OVERDRIVE:
                    {
                        if (!_overdriveActive)
                            break;
                        float x, y, z;
                        if (GetOverdriveDestination(x, y, z))
                        {
                            me->GetMotionMaster()->MovePoint(POINT_MOVE_OVERDRIVE, x, y, z, true);
                            events.RescheduleEvent(EVENT_MOVE_OVERDRIVE, 3000); // fallback if the move never reports back
                        }
                        else
                            events.RescheduleEvent(EVENT_MOVE_OVERDRIVE, 1000);
                        break;
                    }
                    case EVENT_END_OVERDRIVE:
                        EndOverdrive();
                        break;
                    case EVENT_ACQUIRING_TARGET:
                        if (_overdriveActive || _harvestActive)
                        {
                            events.ScheduleEvent(EVENT_ACQUIRING_TARGET, 3000);
                            break;
                        }
                        if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 0.0f, true))
                        {
                            Talk(SAY_ACQUIRING_TARGET, target);
                            DoCastSelf(SPELL_ACQUIRING_TARGET, true);
                            DoCast(target, SPELL_HARVEST); // JustSummoned(targeting bunny) starts the run
                        }
                        events.ScheduleEvent(EVENT_ACQUIRING_TARGET, 55000);
                        break;
                    case EVENT_HARVEST:
                        if (!_harvestActive)
                            break;
                        if (Creature* bunny = ObjectAccessor::GetCreature(*me, _harvestBunnyGuid))
                            me->GetMotionMaster()->MovePoint(POINT_MOVE_HARVEST, bunny->GetPositionX(), bunny->GetPositionY(), bunny->GetPositionZ(), true);
                        else
                            EndHarvest();
                        break;
                    case EVENT_HARVEST_SWEEP:
                        if (!_harvestActive)
                            break;
                        DoCastAOE(SPELL_HARVEST_SWEEP);
                        EndHarvest();
                        break;
                    case EVENT_HARVEST_FAILSAFE:
                        if (_harvestActive)
                            EndHarvest();
                        break;
                    case EVENT_ANNOUNCE_SAFETY_RESTRICTIONS_OFFLINE:
                        Talk(SAY_ANNOUNCE_RESTRICTIONS_OFFLINE);
                        break;
                    case EVENT_ANNOUNCE_DISRUPTING_FOUNDRY:
                        if (Creature* bunny = GetAnnouncer())
                            if (bunny->AI())
                                bunny->AI()->Talk(SAY_ANNOUNCE_FOUNDRY_DISRUPTED);
                        break;
                    case EVENT_ANNOUNCE_MOLTEN_SLAG:
                        if (Creature* bunny = GetAnnouncer())
                            if (bunny->AI())
                                bunny->AI()->Talk(SAY_ANNOUNCE_MOLTEN_SLAG);
                        break;
                    case EVENT_SUMMON_MOLTEN_SLAG:
                        me->SummonCreature(NPC_MOLTEN_SLAG, moltenSlagPos[urand(0, 3)], TEMPSUMMON_MANUAL_DESPAWN);
                        events.ScheduleEvent(EVENT_SUMMON_MOLTEN_SLAG, urand(21000, 22000));
                        break;
                    default:
                        break;
                }
            }

            void UpdateAI(uint32 diff) override
            {
                UpdateIntro(diff);

                if (!UpdateVictim())
                    return;

                events.Update(diff);

                if (me->HasUnitState(UNIT_STATE_CASTING))
                    return;

                CheckSafetyRestrictions(0); // DamageTaken fires before the damage is applied, so check here as well

                while (uint32 eventId = events.ExecuteEvent())
                {
                    ExecuteEvent(eventId);
                    if (me->HasUnitState(UNIT_STATE_CASTING))
                        return;
                }

                // Reaper Strike replaces the white swing (as in the reference)
                if (me->GetVictim() && !me->HasReactState(REACT_PASSIVE))
                    DoSpellAttackIfReady(SPELL_REAPER_STRIKE);
            }

        private:
            EventMap _introEvents;
            ObjectGuid _harvestBunnyGuid;
            ObjectGuid _announcerGuid;
            bool _offlineCast = false;
            bool _introStarted = false;
            bool _introDone = false;
            bool _safetyRestrictionsOffline = false;
            bool _overdriveActive = false;
            bool _harvestActive = false;
        };

        CreatureAI* GetAI(Creature* creature) const override
        {
            return GetInstanceAI<boss_foereaper5000AI>(creature);
        }
};

class npc_foereaper_targeting_bunny : public CreatureScript
{
    public:
        npc_foereaper_targeting_bunny() : CreatureScript("npc_foereaper_targeting_bunny") { }

        struct npc_foereaper_targeting_bunnyAI : public ScriptedAI
        {
            npc_foereaper_targeting_bunnyAI(Creature* creature) : ScriptedAI(creature)
            {
                SetCombatMovement(false);
            }

            void Reset() override
            {
                DoCast(SPELL_TARGET_BUNNY);
            }
        };

        CreatureAI* GetAI(Creature* creature) const override
        {
            return GetInstanceAI<npc_foereaper_targeting_bunnyAI>(creature);
        }
};

// Players that sit in a vehicle (Prototype Reaper) are not fixated
class FixateTargetCheck
{
    public:
        bool operator()(Unit* target) const
        {
            return target && target->GetTypeId() == TYPEID_PLAYER && target->IsAlive() && !target->GetVehicle();
        }
};

// Molten Slag 49229 (heroic): 3s after the summon Molten Shield + aggressive, every 12s a new fixate target
class npc_foereaper_molten_slag : public CreatureScript
{
    public:
        npc_foereaper_molten_slag() : CreatureScript("npc_foereaper_molten_slag") { }

        struct npc_foereaper_molten_slagAI : public ScriptedAI
        {
            npc_foereaper_molten_slagAI(Creature* creature) : ScriptedAI(creature) { }

            void InitializeAI() override
            {
                me->SetReactState(REACT_PASSIVE);
            }

            void JustDied(Unit* /*killer*/) override
            {
                if (Unit* old = ObjectAccessor::GetUnit(*me, _fixateGuid))
                    old->RemoveAurasDueToSpell(SPELL_FIXATE);

                me->DespawnOrUnsummon(5000);
            }

            void UpdateAI(uint32 diff) override
            {
                if (!_started)
                {
                    _started = true;
                    DoZoneInCombat(); // a passive creature with an empty threat list would evade
                    _events.ScheduleEvent(EVENT_MOLTEN_SHIELD, 3000);
                    _events.ScheduleEvent(EVENT_FIXATE_PLAYER, 3000);
                }

                _events.Update(diff);

                while (uint32 eventId = _events.ExecuteEvent())
                {
                    switch (eventId)
                    {
                        case EVENT_MOLTEN_SHIELD:
                            DoCastSelf(SPELL_MOLTEN_SHIELD, true);
                            me->SetReactState(REACT_AGGRESSIVE);
                            DoZoneInCombat();
                            break;
                        case EVENT_FIXATE_PLAYER:
                            if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, FixateTargetCheck()))
                            {
                                if (Unit* old = ObjectAccessor::GetUnit(*me, _fixateGuid))
                                    old->RemoveAurasDueToSpell(SPELL_FIXATE);

                                me->RemoveAurasDueToSpell(SPELL_FIXATE_TAUNT);
                                target->CastSpell(me, SPELL_FIXATE_TAUNT, true); // the player taunts the slag
                                DoCast(target, SPELL_FIXATE, true);              // visible marker on the player
                                _fixateGuid = target->GetGUID();
                            }
                            _events.ScheduleEvent(EVENT_FIXATE_PLAYER, 12000);
                            break;
                        default:
                            break;
                    }
                }

                if (!UpdateVictim())
                    return;

                if (me->GetVictim() && !me->HasReactState(REACT_PASSIVE))
                    DoMeleeAttackIfReady();
            }

        private:
            EventMap _events;
            ObjectGuid _fixateGuid;
            bool _started = false;
        };

        CreatureAI* GetAI(Creature* creature) const override
        {
            return new npc_foereaper_molten_slagAI(creature);
        }
};

} // namespace FoeReaper5000

void AddSC_boss_foereaper5000()
{
    using namespace FoeReaper5000;
    new boss_foereaper5000();
    new npc_foereaper_targeting_bunny();
    new npc_foereaper_molten_slag();
}
