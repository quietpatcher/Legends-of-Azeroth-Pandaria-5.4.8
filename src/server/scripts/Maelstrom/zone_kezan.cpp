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
#include "TemporarySummon.h"
#include "Vehicle.h"
#include "CombatAI.h"
#include "SpellScript.h"

struct npc_sister_goldskimmer : public ScriptedAI
{
    npc_sister_goldskimmer(Creature* creature) : ScriptedAI(creature) { }

    void MoveInLineOfSight(Unit* who) override
    {
        if (who->GetTypeId() == TYPEID_PLAYER && me->IsFriendlyTo(who) && me->isInFrontInMap(who, 7) && !who->HasAura(74973))
        {
            Talk(0, who);
            me->CastSpell(who, 74973, true);
        }
    }
};

/*######
## Quest 14071: Rolling with my Homies
##
## The Keys to the Hot Rod (item 46856, spell 66393) summon the Hot Rod with the player at the wheel and give the
## credit "Keys to the Hot Rod used". Ace, Gobber and Izzy stand in the streets of Kezan, each behind an invisibility
## of his own (66403, 66404, 66405). A player on the quest sees them; drive the Hot Rod up to one and he hops in: a
## rider is summoned for the player (66597, 66599, 66600), gives the credit and takes a seat, and the one in the
## street disappears for that player. Later the three ride along whenever the player takes the Hot Rod (66644-66646).
######*/

namespace RollingWithMyHomies
{
    enum
    {
        QUEST_ROLLING_WITH_MY_HOMIES    = 14071,
        NPC_HOT_ROD                     = 34840,
        SPELL_HOT_ROD_KNOCKBACK         = 66301,
        SEAT_DRIVER                     = 0,
        PICKUP_RANGE                    = 10,
        CHECK_INTERVAL                  = 500
    };

    struct Homie
    {
        uint32 streetEntry;     // stands in the street, behind his invisibility
        uint32 riderEntry;      // summoned for the player: the credit of the quest, rides along
        uint32 summonSpell;     // at the one in the street (conditions: implicit target)
        uint32 resummonSpell;   // next to the player, for a later ride
        uint32 detectSpell;     // lets the player see the one in the street
        int8   seat;
    };

    Homie const Homies[] =
    {
        // the generic detection spells of the three types; 73593 / 73595 / 73597 belong to a quest on
        // the Lost Isles and cannot be held on Kezan (area requirement), so nobody saw the homies
        { 34892, 34957, 66597, 66644, 49416, 1 },   // Ace,    invisibility type 7
        { 34954, 34958, 66599, 66645, 49417, 2 },   // Gobber, invisibility type 8
        { 34890, 34959, 66600, 66646, 60922, 3 },   // Izzy,   invisibility type 9
    };

    Homie const* ByRider(uint32 entry)
    {
        for (Homie const& homie : Homies)
            if (homie.riderEntry == entry)
                return &homie;
        return nullptr;
    }

    // the credit for this homie is in (or the quest is past that point)
    bool PickedUp(Player* player, Homie const& homie)
    {
        QuestStatus status = player->GetQuestStatus(QUEST_ROLLING_WITH_MY_HOMIES);
        if (status == QUEST_STATUS_COMPLETE || status == QUEST_STATUS_REWARDED)
            return true;
        if (status != QUEST_STATUS_INCOMPLETE)
            return false;
        if (Quest const* quest = sObjectMgr->GetQuestTemplate(QUEST_ROLLING_WITH_MY_HOMIES))
            for (QuestObjective const& objective : quest->GetObjectives())
                if (objective.Type == QUEST_OBJECTIVE_MONSTER && uint32(objective.ObjectID) == homie.riderEntry)
                    return player->IsQuestObjectiveComplete(quest, objective);
        return false;
    }

    // a player on the quest sees the homies he still has to pick up, nobody else sees them
    void SyncVision(Player* player)
    {
        bool onQuest = player->GetQuestStatus(QUEST_ROLLING_WITH_MY_HOMIES) == QUEST_STATUS_INCOMPLETE;
        for (Homie const& homie : Homies)
        {
            if (onQuest && !PickedUp(player, homie))
            {
                if (!player->HasAura(homie.detectSpell))
                    player->AddAura(homie.detectSpell, player);
            }
            else
                player->RemoveAurasDueToSpell(homie.detectSpell);
        }
    }

    // the rider that was summoned for this player
    Creature* FindRider(Creature* hotRod, Player* player, Homie const& homie)
    {
        std::list<Creature*> riders;
        hotRod->GetCreatureListWithEntryInGrid(riders, homie.riderEntry, 40.0f);
        for (Creature* rider : riders)
            if (TempSummon* summon = rider->ToTempSummon())
                if (summon->GetSummonerGUID() == player->GetGUID())
                    return rider;
        return nullptr;
    }
}

struct npc_kezan_hot_rod : public ScriptedAI
{
    npc_kezan_hot_rod(Creature* creature) : ScriptedAI(creature), _checkTimer(RollingWithMyHomies::CHECK_INTERVAL) { }

    void PassengerBoarded(Unit* who, int8 seatId, bool apply) override
    {
        Player* player = who->ToPlayer();
        if (!player || seatId != RollingWithMyHomies::SEAT_DRIVER || !apply)
            return;

        RollingWithMyHomies::SyncVision(player);

        // the homies he picked up before take their seats again
        for (RollingWithMyHomies::Homie const& homie : RollingWithMyHomies::Homies)
        {
            if (!RollingWithMyHomies::PickedUp(player, homie))
                continue;
            if (Creature* rider = RollingWithMyHomies::FindRider(me, player, homie))
                rider->EnterVehicle(me, homie.seat);
            else
                player->CastSpell(player, homie.resummonSpell, true);
        }
    }

    void UpdateAI(uint32 diff) override
    {
        if (_checkTimer > diff)
        {
            _checkTimer -= diff;
            return;
        }
        _checkTimer = RollingWithMyHomies::CHECK_INTERVAL;

        Vehicle* kit = me->GetVehicleKit();
        Unit* driver = kit ? kit->GetPassenger(RollingWithMyHomies::SEAT_DRIVER) : nullptr;
        Player* player = driver ? driver->ToPlayer() : nullptr;
        if (!player)
            return;

        // whoever stands in the way of a driving Hot Rod is thrown aside
        if (me->HasUnitMovementFlag(MOVEMENTFLAG_FORWARD))
            player->CastSpell(player, RollingWithMyHomies::SPELL_HOT_ROD_KNOCKBACK, true);

        if (player->GetQuestStatus(RollingWithMyHomies::QUEST_ROLLING_WITH_MY_HOMIES) != QUEST_STATUS_INCOMPLETE)
            return;

        for (RollingWithMyHomies::Homie const& homie : RollingWithMyHomies::Homies)
        {
            if (RollingWithMyHomies::PickedUp(player, homie) || RollingWithMyHomies::FindRider(me, player, homie))
                continue;
            if (!me->FindNearestCreature(homie.streetEntry, float(RollingWithMyHomies::PICKUP_RANGE)))
                continue;
            // the rider gives the credit when he appears (npc_kezan_homie_rider)
            player->CastSpell(player, homie.summonSpell, true);
            player->RemoveAurasDueToSpell(homie.detectSpell);
        }
    }

private:
    uint32 _checkTimer;
};

struct npc_kezan_homie_rider : public ScriptedAI
{
    npc_kezan_homie_rider(Creature* creature) : ScriptedAI(creature) { }

    void IsSummonedBy(Unit* summoner) override
    {
        Player* player = summoner->ToPlayer();
        RollingWithMyHomies::Homie const* homie = RollingWithMyHomies::ByRider(me->GetEntry());
        if (!player || !homie)
            return;

        me->SetReactState(REACT_PASSIVE);
        player->KilledMonsterCredit(me->GetEntry());

        if (Unit* base = player->GetVehicleBase())
            if (base->GetEntry() == RollingWithMyHomies::NPC_HOT_ROD)
                me->EnterVehicle(base, homie->seat);
    }

    void UpdateAI(uint32 /*diff*/) override { }
};

class quest_rolling_with_my_homies : public QuestScript
{
public:
    quest_rolling_with_my_homies() : QuestScript("quest_rolling_with_my_homies") { }

    void OnQuestStatusChange(Player* player, Quest const* /*quest*/, QuestStatus /*oldStatus*/, QuestStatus /*newStatus*/) override
    {
        RollingWithMyHomies::SyncVision(player);
    }
};

/*######
## Quest 14121: Robbing Hoods
##
## Trade Prince Gallywix has sent Hired Looters into the streets. The player runs them over with the Hot Rod: a looter
## that is hit by the knockback of the car (66301) throws his Stolen Loot to the driver (67041 creates the item in the
## bags of the player) and does not get up again. On foot a looter is an ordinary enemy that throws torches and drops
## the loot.
######*/

namespace RobbingHoods
{
    enum
    {
        QUEST_ROBBING_HOODS         = 14121,
        NPC_HIRED_LOOTER            = 35234,
        ITEM_STOLEN_LOOT            = 47530,
        LOOT_NEEDED                 = 12,
        SPELL_CREATE_STOLEN_LOOT    = 67041,
        SPELL_TORCH_TOSS            = 6257,
        DATA_LOOT_DELIVERED         = 1,
        DEATH_DELAY                 = 2000
    };

    bool NeedsLoot(Player* player)
    {
        return player->GetQuestStatus(QUEST_ROBBING_HOODS) == QUEST_STATUS_INCOMPLETE
            && !player->HasItemCount(ITEM_STOLEN_LOOT, LOOT_NEEDED, true);
    }
}

struct npc_kezan_hired_looter : public ScriptedAI
{
    npc_kezan_hired_looter(Creature* creature) : ScriptedAI(creature), _torchTimer(0), _deathTimer(0), _runOver(false), _lootSent(false), _lootDelivered(false) { }

    void Reset() override
    {
        _torchTimer = urand(5000, 11000);
        // an evade between the hit and the fall does not put him back on his feet
        if (_runOver)
            return;
        _deathTimer = 0;
        _runOver = false;
        _lootSent = false;
        _lootDelivered = false;
        _driverGUID.Clear();
    }

    void SpellHit(Unit* caster, SpellInfo const* spell) override
    {
        if (spell->Id != RollingWithMyHomies::SPELL_HOT_ROD_KNOCKBACK || _runOver || !me->IsAlive())
            return;

        // the knockback comes from the driver, or from the car itself
        Player* player = caster->ToPlayer();
        if (!player)
            if (Vehicle* kit = caster->GetVehicleKit())
                if (Unit* driver = kit->GetPassenger(RollingWithMyHomies::SEAT_DRIVER))
                    player = driver->ToPlayer();
        if (!player)
            return;

        _runOver = true;
        _driverGUID = player->GetGUID();
        _deathTimer = RobbingHoods::DEATH_DELAY;
        me->SetReactState(REACT_PASSIVE);
        me->AttackStop();

        if (RobbingHoods::NeedsLoot(player))
        {
            _lootSent = true;
            me->CastSpell(player, RobbingHoods::SPELL_CREATE_STOLEN_LOOT, true);
        }
    }

    // spell_kezan_create_stolen_loot: the loot arrived at the driver
    void SetData(uint32 type, uint32 /*value*/) override
    {
        if (type == RobbingHoods::DATA_LOOT_DELIVERED)
            _lootDelivered = true;
    }

    void UpdateAI(uint32 diff) override
    {
        if (_runOver)
        {
            if (_deathTimer > diff)
            {
                _deathTimer -= diff;
                return;
            }

            // the throw did not reach the driver (out of sight, not a valid target on his seat): hand it over directly
            if (_lootSent && !_lootDelivered)
                if (Player* player = ObjectAccessor::GetPlayer(*me, _driverGUID))
                    if (RobbingHoods::NeedsLoot(player))
                    {
                        TC_LOG_INFO("scripts", "Robbing Hoods: Create Stolen Loot (67041) of looter {} did not reach {}, the loot is handed over directly",
                            me->GetGUID().GetCounter(), player->GetName());
                        player->AddItem(RobbingHoods::ITEM_STOLEN_LOOT, 1);
                    }

            // run over: no kill for anybody, nothing left to loot
            _runOver = false;
            me->Kill(me);
            return;
        }

        if (!UpdateVictim())
            return;

        if (_torchTimer <= diff)
        {
            DoCastVictim(RobbingHoods::SPELL_TORCH_TOSS);
            _torchTimer = urand(7800, 21300);
        }
        else
            _torchTimer -= diff;

        DoMeleeAttackIfReady();
    }

private:
    uint32 _torchTimer;
    uint32 _deathTimer;
    bool _runOver;
    bool _lootSent;
    bool _lootDelivered;
    ObjectGuid _driverGUID;
};

// 67041 Robbing Hoods: Create Stolen Loot
class spell_kezan_create_stolen_loot : public SpellScript
{
    PrepareSpellScript(spell_kezan_create_stolen_loot);

    void HandleCreateItem(SpellEffIndex /*effIndex*/)
    {
        Creature* looter = GetCaster() ? GetCaster()->ToCreature() : nullptr;
        if (looter && looter->GetEntry() == RobbingHoods::NPC_HIRED_LOOTER && looter->IsAIEnabled && GetHitPlayer())
            looter->AI()->SetData(RobbingHoods::DATA_LOOT_DELIVERED, 1);
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_kezan_create_stolen_loot::HandleCreateItem, EFFECT_0, SPELL_EFFECT_CREATE_ITEM);
    }
};

/*######
## Quests 24503 / 28414: Fourth and Goal
##
## The player gets into the Bilgewater Buccaneer again (spell click on the parked shredder, 70075 summons 37213) and
## kicks a footbomb (70051 -> 70052) between the goal posts high above the field, where the Fourth And Goal Target
## (37203) hangs. A kick that lands near the target is the goal: quest credit, and Deathwing comes over the field,
## for this player only. He roars, the ground shakes, and the player is thrown out of the shredder.
######*/

namespace FourthAndGoal
{
    enum
    {
        QUEST_FOURTH_AND_GOAL_OLD   = 24503,
        QUEST_FOURTH_AND_GOAL       = 28414,
        NPC_BUCCANEER               = 37213,
        NPC_GOAL_TARGET             = 37203,
        NPC_DEATHWING               = 48572,
        SPELL_SEE_GOAL_TARGET       = 94568,    // Generic Quest Invisibility Detection 7, by spell_area while on the quest
        SPELL_DEATHWINGS_ATTACK     = 66858,
        SPELL_DEATHWING_SOUND       = 69988,
        SPELL_CATACLYSM             = 68707,    // the ground shakes
        SOUND_GOAL                  = 17467,
        SOUND_DEATHWING_ROAR        = 23227,
        SOUND_DEATHWING_ATTACK      = 23229,
        SOUND_SHREDDER_EXIT         = 14559,
        SEAT_DRIVER                 = 0,
        GOAL_RANGE                  = 35,       // yards around the target, measured on the ground

        POINT_ENTER                 = 1,
        POINT_TURN,
        POINT_HOVER,
        POINT_BACK,
        POINT_FRONT,
        POINT_DIVE,
        POINT_AWAY,

        EVENT_ROAR                  = 1,
        EVENT_ATTACK,
        EVENT_LEAVE_HOVER,
        EVENT_SOUND,
        EVENT_THROW_OUT,
        EVENT_SHAKE,
        EVENT_GONE
    };

    Position const DeathwingStart = { -8230.59f, 1482.14f, 110.92f, 3.14f };

    bool OnQuest(Player* player)
    {
        return player->GetQuestStatus(QUEST_FOURTH_AND_GOAL) == QUEST_STATUS_INCOMPLETE
            || player->GetQuestStatus(QUEST_FOURTH_AND_GOAL_OLD) == QUEST_STATUS_INCOMPLETE;
    }
}

// 70052 Kick Footbomb
class spell_kezan_kick_footbomb : public SpellScript
{
    PrepareSpellScript(spell_kezan_kick_footbomb);

    void HandleAfterCast()
    {
        Unit* caster = GetCaster();
        WorldLocation const* dest = GetExplTargetDest();
        Vehicle* kit = caster ? caster->GetVehicleKit() : nullptr;
        Unit* driver = kit ? kit->GetPassenger(FourthAndGoal::SEAT_DRIVER) : nullptr;
        Player* player = driver ? driver->ToPlayer() : nullptr;
        // (goal-kick-log) where the kick of this player lands, next to the goal (diagnostics)
        if (player)
        {
            Creature* goal = caster->FindNearestCreature(FourthAndGoal::NPC_GOAL_TARGET, 300.0f);
            TC_LOG_INFO("scripts", "Fourth and Goal: {} kicks from {:.1f} {:.1f} {:.1f} to {:.1f} {:.1f} {:.1f} ({}), goal at {:.1f} yd (2D) of the landing, limit {}, on the quest {}",
                player->GetName(), caster->GetPositionX(), caster->GetPositionY(), caster->GetPositionZ(),
                dest ? dest->GetPositionX() : 0.0f, dest ? dest->GetPositionY() : 0.0f, dest ? dest->GetPositionZ() : 0.0f,
                dest ? "destination" : "no destination", goal && dest ? goal->GetExactDist2d(dest->GetPositionX(), dest->GetPositionY()) : -1.0f,
                uint32(FourthAndGoal::GOAL_RANGE), FourthAndGoal::OnQuest(player) ? 1 : 0);
        }
        if (!dest || !player || !FourthAndGoal::OnQuest(player))
            return;

        Creature* target = caster->FindNearestCreature(FourthAndGoal::NPC_GOAL_TARGET, 300.0f);
        if (!target)
            return;
        // the client sends the destination on the camera ray (~300 yd out, high up), so a landing next to the goal is
        // not reachable from the fixed shredder: accept either a landing near the goal or a destination inside the
        // box around the goal (Y 1437..1527, Z 100..300, X -8520..-8300)
        bool const nearGoal = target->GetExactDist2d(dest->GetPositionX(), dest->GetPositionY()) <= float(FourthAndGoal::GOAL_RANGE);
        bool const inBox = dest->GetPositionX() > -8520.0f && dest->GetPositionX() < -8300.0f
            && dest->GetPositionY() > 1437.0f && dest->GetPositionY() < 1527.0f
            && dest->GetPositionZ() > 100.0f && dest->GetPositionZ() < 300.0f;
        if (!nearGoal && !inBox)
            return;

        // goal: the credit, and Deathwing for this player alone
        player->KilledMonsterCredit(FourthAndGoal::NPC_GOAL_TARGET);
        player->RemoveAurasDueToSpell(FourthAndGoal::SPELL_SEE_GOAL_TARGET);
        player->PlayDirectSound(FourthAndGoal::SOUND_GOAL, player);
        player->SummonCreature(FourthAndGoal::NPC_DEATHWING, FourthAndGoal::DeathwingStart, TEMPSUMMON_TIMED_DESPAWN, 90s, 0, player->GetGUID());
    }

    void Register() override
    {
        AfterCast += SpellCastFn(spell_kezan_kick_footbomb::HandleAfterCast);
    }
};

struct npc_kezan_deathwing : public ScriptedAI
{
    npc_kezan_deathwing(Creature* creature) : ScriptedAI(creature) { }

    void IsSummonedBy(Unit* summoner) override
    {
        _playerGUID = summoner->GetGUID();
        me->SetReactState(REACT_PASSIVE);
        me->setActive(true);
        me->SetDisableGravity(true);
        me->SetSpeed(MOVE_RUN, 2.0f, true);
        me->SetSpeed(MOVE_FLIGHT, 2.0f, true);
        me->GetMotionMaster()->MovePoint(FourthAndGoal::POINT_ENTER, -8320.0f, 1473.0f, 110.0f);
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type != POINT_MOTION_TYPE)
            return;

        switch (id)
        {
            case FourthAndGoal::POINT_ENTER:
                if (Player* player = GetPlayer())
                    player->PlayDirectSound(FourthAndGoal::SOUND_DEATHWING_ROAR, player);
                me->GetMotionMaster()->MovePoint(FourthAndGoal::POINT_TURN, -8320.0f, 1480.0f, 110.0f);
                break;
            case FourthAndGoal::POINT_TURN:
                // slowly over the field, looking down at the goblins
                me->SetSpeed(MOVE_RUN, 0.4f, true);
                me->SetSpeed(MOVE_FLIGHT, 0.4f, true);
                _events.ScheduleEvent(FourthAndGoal::EVENT_ROAR, 2000);
                me->GetMotionMaster()->MovePoint(FourthAndGoal::POINT_HOVER, -8330.0f, 1500.0f, 110.0f);
                break;
            case FourthAndGoal::POINT_HOVER:
                _events.ScheduleEvent(FourthAndGoal::EVENT_ATTACK, 3000);
                _events.ScheduleEvent(FourthAndGoal::EVENT_LEAVE_HOVER, 6500);
                break;
            case FourthAndGoal::POINT_BACK:
                me->GetMotionMaster()->MovePoint(FourthAndGoal::POINT_FRONT, -8320.0f, 1500.0f, 110.0f);
                break;
            case FourthAndGoal::POINT_FRONT:
                _events.ScheduleEvent(FourthAndGoal::EVENT_SOUND, 2000);
                me->GetMotionMaster()->MovePoint(FourthAndGoal::POINT_DIVE, -8250.0f, 1480.0f, 90.0f);
                break;
            case FourthAndGoal::POINT_DIVE:
                // right over the shredder, then away over the town
                _events.ScheduleEvent(FourthAndGoal::EVENT_THROW_OUT, 2000);
                _events.ScheduleEvent(FourthAndGoal::EVENT_SHAKE, 6000);
                me->GetMotionMaster()->MovePoint(FourthAndGoal::POINT_AWAY, -7900.0f, 1460.0f, 90.0f);
                break;
            case FourthAndGoal::POINT_AWAY:
                _events.ScheduleEvent(FourthAndGoal::EVENT_GONE, 8000);
                break;
            default:
                break;
        }
    }

    void UpdateAI(uint32 diff) override
    {
        _events.Update(diff);
        while (uint32 eventId = _events.ExecuteEvent())
        {
            Player* player = GetPlayer();
            switch (eventId)
            {
                case FourthAndGoal::EVENT_ROAR:
                    if (player)
                        player->PlayDirectSound(23228, player);
                    break;
                case FourthAndGoal::EVENT_ATTACK:
                    me->CastSpell(me, FourthAndGoal::SPELL_DEATHWINGS_ATTACK, true);
                    if (player)
                        player->PlayDirectSound(FourthAndGoal::SOUND_DEATHWING_ATTACK, player);
                    break;
                case FourthAndGoal::EVENT_LEAVE_HOVER:
                    me->SetSpeed(MOVE_RUN, 2.0f, true);
                    me->SetSpeed(MOVE_FLIGHT, 2.0f, true);
                    me->GetMotionMaster()->MovePoint(FourthAndGoal::POINT_BACK, -8330.0f, 1460.0f, 110.0f);
                    break;
                case FourthAndGoal::EVENT_SOUND:
                    me->CastSpell(me, FourthAndGoal::SPELL_DEATHWING_SOUND, true);
                    break;
                case FourthAndGoal::EVENT_THROW_OUT:
                    if (player)
                    {
                        if (Unit* base = player->GetVehicleBase())
                            if (base->GetEntry() == FourthAndGoal::NPC_BUCCANEER)
                            {
                                player->ExitVehicle();
                                player->PlayDirectSound(FourthAndGoal::SOUND_SHREDDER_EXIT, player);
                            }
                    }
                    break;
                case FourthAndGoal::EVENT_SHAKE:
                    if (player)
                        player->CastSpell(player, FourthAndGoal::SPELL_CATACLYSM, true);
                    break;
                case FourthAndGoal::EVENT_GONE:
                    me->DespawnOrUnsummon();
                    break;
                default:
                    break;
            }
        }
    }

private:
    Player* GetPlayer() const { return ObjectAccessor::GetPlayer(*me, _playerGUID); }

    EventMap _events;
    ObjectGuid _playerGUID;
};

/*######
## Quest 14070: Do it Yourself
##
## Bruno Flameretardant, Frankie Gearslipper, Jack the Hammer and Sudsy Magee owe protection money. The player beats
## them down; they do not die. At the last blow the deadbeat gives up, says so, and everybody who fought him has the
## credit. He walks back to his spot and can be beaten again by the next player.
######*/

struct npc_kezan_deadbeat : public ScriptedAI
{
    npc_kezan_deadbeat(Creature* creature) : ScriptedAI(creature), _beaten(false), _firstSpell(0), _secondSpell(0) { }

    enum
    {
        SAY_AGGRO       = 0,
        SAY_BEATEN      = 1,
        GIVE_UP_PCT     = 10
    };

    void Reset() override
    {
        _firstSpell = urand(3000, 6000);
        _secondSpell = urand(8000, 12000);
    }

    void EnterCombat(Unit* /*who*/) override
    {
        Talk(SAY_AGGRO);
    }

    void JustReachedHome() override
    {
        _beaten = false;
        me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC);
    }

    void DamageTaken(Unit* attacker, uint32& damage) override
    {
        if (_beaten)
        {
            damage = 0;
            return;
        }
        if (damage < me->GetHealth() && !me->HealthBelowPctDamaged(GIVE_UP_PCT, damage))
            return;

        // beaten, not killed
        damage = 0;
        _beaten = true;
        Talk(SAY_BEATEN);
        if (Player* player = attacker ? attacker->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr)
            player->RewardPlayerAndGroupAtEvent(me->GetEntry(), me);
        me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC);
        EnterEvadeMode();
    }

    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim())
            return;

        if (uint32 spell = me->GetCreatureTemplate()->spells[0])
        {
            if (_firstSpell <= diff)
            {
                DoCastVictim(spell);
                _firstSpell = urand(7000, 11000);
            }
            else
                _firstSpell -= diff;
        }
        if (uint32 spell = me->GetCreatureTemplate()->spells[1])
        {
            if (_secondSpell <= diff)
            {
                DoCastVictim(spell);
                _secondSpell = urand(12000, 18000);
            }
            else
                _secondSpell -= diff;
        }

        DoMeleeAttackIfReady();
    }

private:
    bool _beaten;
    uint32 _firstSpell;
    uint32 _secondSpell;
};

/*######
## Quest 14122: The Great Bank Heist
##
## A click on the vault of the First Bank of Kezan (game object 195449, spell 67555) puts the player at the controls
## of a vault bunny (67488 summons 35486, the Vault Cracking Toolset 67476 is the ride). The vault calls for one of
## five tools; the player has a few seconds to press the matching button on the vehicle bar. Right: the Vault
## Breaking progress goes up by ten, wrong or too late: down by ten. At a hundred the vault is open: the player gets
## his Personal Riches and the quest credit.
######*/

namespace GreatBankHeist
{
    enum
    {
        QUEST_THE_GREAT_BANK_HEIST  = 14122,
        NPC_VAULT                   = 35486,
        ITEM_PERSONAL_RICHES        = 46858,
        SPELL_SUMMON_VAULT          = 67488,
        SPELL_TOOLSET               = 67476,
        SPELL_POWER_CORRECT         = 67493,
        SPELL_POWER_INCORRECT       = 67494,
        SPELL_TIMER                 = 67502,    // CasterAuraSpell of the five tool spells (SpellAuraRestrictions)

        SAY_INTRO_1                 = 0,
        SAY_INTRO_2                 = 1,
        SAY_INTRO_3                 = 2,
        SAY_GOOD_LUCK               = 3,
        SAY_SUCCESS                 = 4,
        SAY_TOOL_FIRST              = 5,    // 5-9: the call for each tool, in the order of Tools below

        EVENT_INTRO_2               = 1,
        EVENT_INTRO_3,
        EVENT_GOOD_LUCK,
        EVENT_NEXT_TOOL,
        EVENT_TOO_LATE,
        EVENT_DONE,

        STEP                        = 10,
        GOAL                        = 100,
        ANSWER_TIME_MS              = 5000,
        PAUSE_MS                    = 1500,
        ACTION_TOOL_FIRST           = 100   // DoAction(ACTION_TOOL_FIRST + index of the tool)
    };

    struct Tool
    {
        uint32 button;      // on the vehicle bar of the vault
        uint32 aura;        // on the vault while it asks for this tool
    };

    Tool const Tools[] =
    {
        { 67522, 67495 },   // Kaja'mite Drill
        { 67508, 67496 },   // Blastcrackers
        { 67524, 67497 },   // Ear-O-Scope!
        { 67525, 67498 },   // Infinifold Lockpick
        { 67526, 67499 },   // Amazing G-Ray
    };
    uint32 const ToolCount = sizeof(Tools) / sizeof(Tools[0]);
}

struct npc_kezan_bank_vault : public VehicleAI
{
    npc_kezan_bank_vault(Creature* creature) : VehicleAI(creature), _progress(0), _wanted(-1), _running(false) { }

    void PassengerBoarded(Unit* who, int8 /*seatId*/, bool apply) override
    {
        Player* player = who->ToPlayer();
        if (!player)
            return;

        if (!apply)
        {
            // left before the vault was open: the next click starts over
            ClearTool();
            _events.Reset();
            _running = false;
            me->DespawnOrUnsummon(500);
            return;
        }

        _playerGUID = player->GetGUID();
        _progress = 0;
        _wanted = -1;
        _running = true;
        ShowProgress();
        Talk(GreatBankHeist::SAY_INTRO_1, player);
        _events.ScheduleEvent(GreatBankHeist::EVENT_INTRO_2, 3000);
        _events.ScheduleEvent(GreatBankHeist::EVENT_INTRO_3, 7000);
        _events.ScheduleEvent(GreatBankHeist::EVENT_GOOD_LUCK, 11000);
        _events.ScheduleEvent(GreatBankHeist::EVENT_NEXT_TOOL, 13000);
    }

    // a tool button of the vehicle bar (spell_kezan_vault_tool)
    void DoAction(int32 action) override
    {
        int32 tool = action - GreatBankHeist::ACTION_TOOL_FIRST;
        if (!_running || tool < 0 || tool >= int32(GreatBankHeist::ToolCount) || _wanted < 0)
            return;

        _events.CancelEvent(GreatBankHeist::EVENT_TOO_LATE);
        Answer(tool == _wanted);
    }

    void UpdateAI(uint32 diff) override
    {
        if (!_running)
            return;

        _events.Update(diff);
        while (uint32 eventId = _events.ExecuteEvent())
        {
            Player* player = GetPlayer();
            if (!player)
            {
                _running = false;
                me->DespawnOrUnsummon(500);
                return;
            }

            switch (eventId)
            {
                case GreatBankHeist::EVENT_INTRO_2:
                    Talk(GreatBankHeist::SAY_INTRO_2, player);
                    break;
                case GreatBankHeist::EVENT_INTRO_3:
                    Talk(GreatBankHeist::SAY_INTRO_3, player);
                    break;
                case GreatBankHeist::EVENT_GOOD_LUCK:
                    Talk(GreatBankHeist::SAY_GOOD_LUCK, player);
                    break;
                case GreatBankHeist::EVENT_NEXT_TOOL:
                    _wanted = int32(urand(0, GreatBankHeist::ToolCount - 1));
                    me->AddAura(GreatBankHeist::Tools[_wanted].aura, me);
                    me->AddAura(GreatBankHeist::SPELL_TIMER, me);
                    player->AddAura(GreatBankHeist::SPELL_TIMER, player);
                    Talk(GreatBankHeist::SAY_TOOL_FIRST + _wanted, player);
                    _events.ScheduleEvent(GreatBankHeist::EVENT_TOO_LATE, GreatBankHeist::ANSWER_TIME_MS);
                    break;
                case GreatBankHeist::EVENT_TOO_LATE:
                    Answer(false);
                    break;
                case GreatBankHeist::EVENT_DONE:
                    _running = false;
                    player->ExitVehicle();
                    me->DespawnOrUnsummon(500);
                    return;
                default:
                    break;
            }
        }
    }

private:
    Player* GetPlayer() const { return ObjectAccessor::GetPlayer(*me, _playerGUID); }

    void ClearTool()
    {
        me->RemoveAurasDueToSpell(GreatBankHeist::SPELL_TIMER);
        if (Player* p = GetPlayer())
            p->RemoveAurasDueToSpell(GreatBankHeist::SPELL_TIMER);
        if (_wanted >= 0)
            me->RemoveAurasDueToSpell(GreatBankHeist::Tools[_wanted].aura);
        _wanted = -1;
    }

    // the vehicle bar shows the power of the vault: that is the Vault Breaking progress
    void ShowProgress()
    {
        me->SetPowerType(POWER_MANA);
        me->SetMaxPower(POWER_MANA, GreatBankHeist::GOAL);
        me->SetPower(POWER_MANA, _progress);
    }

    void Answer(bool right)
    {
        ClearTool();
        me->CastSpell(me, right ? GreatBankHeist::SPELL_POWER_CORRECT : GreatBankHeist::SPELL_POWER_INCORRECT, true);
        _progress = std::max<int32>(0, std::min<int32>(GreatBankHeist::GOAL, _progress + (right ? GreatBankHeist::STEP : -GreatBankHeist::STEP)));
        ShowProgress();

        Player* player = GetPlayer();
        if (_progress < GreatBankHeist::GOAL || !player)
        {
            _events.ScheduleEvent(GreatBankHeist::EVENT_NEXT_TOOL, GreatBankHeist::PAUSE_MS);
            return;
        }

        // open
        Talk(GreatBankHeist::SAY_SUCCESS, player);
        if (player->GetQuestStatus(GreatBankHeist::QUEST_THE_GREAT_BANK_HEIST) == QUEST_STATUS_INCOMPLETE)
        {
            player->KilledMonsterCredit(GreatBankHeist::NPC_VAULT);
            if (!player->HasItemCount(GreatBankHeist::ITEM_PERSONAL_RICHES, 1, true))
                player->AddItem(GreatBankHeist::ITEM_PERSONAL_RICHES, 1);
        }
        _events.Reset();
        _events.ScheduleEvent(GreatBankHeist::EVENT_DONE, 3000);
    }

    EventMap _events;
    ObjectGuid _playerGUID;
    int32 _progress;
    int32 _wanted;
    bool _running;
};

// 67555 The Great Bank Heist: Vault Interact (the click on the vault)
class spell_kezan_vault_interact : public SpellScript
{
    PrepareSpellScript(spell_kezan_vault_interact);

    void HandleScript(SpellEffIndex /*effIndex*/)
    {
        Player* player = GetCaster() ? GetCaster()->ToPlayer() : nullptr;
        if (!player)
            player = GetHitPlayer();
        if (!player || player->GetVehicleBase())
            return;
        if (player->GetQuestStatus(GreatBankHeist::QUEST_THE_GREAT_BANK_HEIST) != QUEST_STATUS_INCOMPLETE)
            return;

        // a toolset ride aura left over from a logout inside the vault blocks the new ride
        player->RemoveAurasDueToSpell(GreatBankHeist::SPELL_TOOLSET);
        player->RemoveAurasDueToSpell(GreatBankHeist::SPELL_TIMER);
        player->CastSpell(player, GreatBankHeist::SPELL_SUMMON_VAULT, true);
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_kezan_vault_interact::HandleScript, EFFECT_0, SPELL_EFFECT_SCRIPT_EFFECT);
    }
};

// A logout inside the vault saves the ride aura (Vault Cracking Toolset 67476) and the Timer; with them the next click
// on the vault (67555) is refused by the client, so they go at login when the player is not on a vehicle.
class player_kezan_vault_logout : public PlayerScript
{
public:
    player_kezan_vault_logout() : PlayerScript("player_kezan_vault_logout") { }

    void OnLogin(Player* player) override
    {
        if (player->GetVehicleBase())
            return;
        player->RemoveAurasDueToSpell(GreatBankHeist::SPELL_TOOLSET);
        player->RemoveAurasDueToSpell(GreatBankHeist::SPELL_TIMER);
    }
};

// 67522, 67508, 67524, 67525, 67526: the five tools on the vehicle bar of the vault
class spell_kezan_vault_tool : public SpellScript
{
    PrepareSpellScript(spell_kezan_vault_tool);

    void HandleAfterCast()
    {
        // the cast arrives with the player as caster (seen on the test server 04-11), so the vault is his vehicle base
        Unit* caster = GetCaster();
        Unit* base = caster ? (caster->GetEntry() == GreatBankHeist::NPC_VAULT ? caster : caster->GetVehicleBase()) : nullptr;
        Creature* vault = base ? base->ToCreature() : nullptr;
        if (!vault || vault->GetEntry() != GreatBankHeist::NPC_VAULT || !vault->IsAIEnabled)
            return;

        for (uint32 i = 0; i < GreatBankHeist::ToolCount; ++i)
            if (GreatBankHeist::Tools[i].button == GetSpellInfo()->Id)
                vault->AI()->DoAction(GreatBankHeist::ACTION_TOOL_FIRST + int32(i));
    }

    void Register() override
    {
        AfterCast += SpellCastFn(spell_kezan_vault_tool::HandleAfterCast);
    }
};

/*######
## Quest 14124: Liberate the Kaja'mite
##
## Foreman Dampwick hands out Kablooey Bombs (item 48768, spell 67682, only inside the Kaja'mine). A bomb is tossed up
## to five yards; every Kaja'mite Deposit (195488) within five yards of the landing is blown to smithereens and leaves
## three Kaja'mite Chunks (195492) to pick up, and a Rebellious Troll that stands there is stunned for a moment. The
## deposit grows back after its respawn time.
######*/

namespace LiberateTheKajamite
{
    enum
    {
        GO_KAJAMITE_DEPOSIT     = 195488,
        GO_KAJAMITE_CHUNK       = 195492,
        NPC_REBELLIOUS_TROLL    = 35294,
        SPELL_STUN              = 23454,    // Stun, one second
        CHUNKS_PER_DEPOSIT      = 3,
        CHUNK_TIME              = 120       // seconds a chunk stays when nobody picks it up
    };
}

// 67682 Kablooey Bombs
class spell_kezan_kablooey_bombs : public SpellScript
{
    PrepareSpellScript(spell_kezan_kablooey_bombs);

    void HandleDeposit(SpellEffIndex effIndex)
    {
        GameObject* deposit = GetHitGObj();
        Unit* caster = GetCaster();
        if (!deposit || !caster || deposit->GetEntry() != LiberateTheKajamite::GO_KAJAMITE_DEPOSIT)
            return;

        // the deposit is not used like a button, it is gone
        PreventHitDefaultEffect(effIndex);
        if (!deposit->isSpawned())
            return;

        float const start = frand(0.0f, 2.0f * float(M_PI));
        for (uint32 i = 0; i < LiberateTheKajamite::CHUNKS_PER_DEPOSIT; ++i)
        {
            Position pos = deposit->GetPosition();
            deposit->MovePosition(pos, frand(2.0f, 3.5f), start + float(i) * 2.0f * float(M_PI) / float(LiberateTheKajamite::CHUNKS_PER_DEPOSIT));
            caster->SummonGameObject(LiberateTheKajamite::GO_KAJAMITE_CHUNK, pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(),
                frand(0.0f, 2.0f * float(M_PI)), { }, LiberateTheKajamite::CHUNK_TIME);
        }

        deposit->SetLootState(GO_JUST_DEACTIVATED);
    }

    void HandleTroll(SpellEffIndex /*effIndex*/)
    {
        Unit* caster = GetCaster();
        Creature* troll = GetHitCreature();
        if (caster && troll && troll->GetEntry() == LiberateTheKajamite::NPC_REBELLIOUS_TROLL && troll->IsAlive())
            caster->CastSpell(troll, LiberateTheKajamite::SPELL_STUN, true);
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_kezan_kablooey_bombs::HandleDeposit, EFFECT_0, SPELL_EFFECT_ACTIVATE_OBJECT);
        OnEffectHitTarget += SpellEffectFn(spell_kezan_kablooey_bombs::HandleTroll, EFFECT_1, SPELL_EFFECT_DUMMY);
    }
};

/*######
## Quest 14125: 447
##
## The insurance fraud. Inside the headquarters the player overloads the Defective Generator, opens the Leaky Stove and
## drops a cigar on the Flammable Bed; each of the three objects makes him cast its master spell (70223, 70239, 70251),
## which leaves the sparks, the gas or the smoke at the object for him (70198, 70241, 70249 summon the visual). Back
## outside he uses the Gasbot Control Panel (game object 201736, spell 70253): a Gasbot rolls into the headquarters,
## trailing gas, and blows up at the stove - that is the credit "KTC Headquarters Set Ablaze with Gasbot!".
######*/

namespace Quest447
{
    enum
    {
        QUEST_447                       = 14125,
        NPC_GASBOT                      = 37598,
        GO_LEAKY_STOVE                  = 201733,

        SPELL_GENERATOR_MASTER          = 70223,
        SPELL_STOVE_LEAK_MASTER         = 70239,
        SPELL_SMOLDERING_BED_PRECAST    = 70251,
        SPELL_SUMMON_GENERATOR          = 70198,
        SPELL_SUMMON_STOVE_LEAK         = 70241,
        SPELL_SUMMON_SMOLDERING_BED     = 70249,
        SPELL_GASBOT_GAS_STREAM         = 70256,
        SPELL_GASBOT_EXPLOSION          = 70259,

        POINT_GAS                       = 1,
        ROLL_TIME_MAX                   = 15000
    };

    // next to the control panel in the yard
    Position const GasbotStart = { -8424.35f, 1328.04f, 102.04f, 1.54f };
}

struct npc_kezan_gasbot : public ScriptedAI
{
    npc_kezan_gasbot(Creature* creature) : ScriptedAI(creature), _timer(0), _rolling(false) { }

    void IsSummonedBy(Unit* summoner) override
    {
        Player* player = summoner->ToPlayer();
        if (!player)
            return;

        _playerGUID = player->GetGUID();
        _rolling = true;
        _timer = Quest447::ROLL_TIME_MAX;
        me->SetReactState(REACT_PASSIVE);
        me->CastSpell(me, Quest447::SPELL_GASBOT_GAS_STREAM, true);

        // into the headquarters, towards the leaking stove
        me->SetWalk(false);
        if (GameObject* stove = me->FindNearestGameObject(Quest447::GO_LEAKY_STOVE, 150.0f))
            me->GetMotionMaster()->MovePoint(Quest447::POINT_GAS, stove->GetPositionX(), stove->GetPositionY(), stove->GetPositionZ());
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type == POINT_MOTION_TYPE && id == Quest447::POINT_GAS)
            Explode();
    }

    void UpdateAI(uint32 diff) override
    {
        if (!_rolling)
            return;

        // never leave the player without the credit when the Gasbot gets stuck on the way
        if (_timer <= diff)
            Explode();
        else
            _timer -= diff;
    }

private:
    void Explode()
    {
        if (!_rolling)
            return;
        _rolling = false;

        me->CastSpell(me, Quest447::SPELL_GASBOT_EXPLOSION, true);
        if (Player* player = ObjectAccessor::GetPlayer(*me, _playerGUID))
            if (player->GetQuestStatus(Quest447::QUEST_447) == QUEST_STATUS_INCOMPLETE)
                player->KilledMonsterCredit(Quest447::NPC_GASBOT);
        me->DespawnOrUnsummon(1500);
    }

    ObjectGuid _playerGUID;
    uint32 _timer;
    bool _rolling;
};

// 70253 447: AICast Gasbot Master (the Gasbot Control Panel; the player casts it on himself)
class spell_kezan_gasbot_control_panel : public SpellScript
{
    PrepareSpellScript(spell_kezan_gasbot_control_panel);

    void HandleScript(SpellEffIndex /*effIndex*/)
    {
        Player* player = GetCaster() ? GetCaster()->ToPlayer() : nullptr;
        if (!player || player->GetQuestStatus(Quest447::QUEST_447) != QUEST_STATUS_INCOMPLETE)
            return;

        // his own Gasbot, like the summon of 70252 (summon properties 942: only the summoner sees it)
        player->SummonCreature(Quest447::NPC_GASBOT, Quest447::GasbotStart, TEMPSUMMON_TIMED_DESPAWN, 180s, 0, player->GetGUID());
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_kezan_gasbot_control_panel::HandleScript, EFFECT_0, SPELL_EFFECT_SCRIPT_EFFECT);
    }
};

// 70223, 70239: the master spells of the generator and the stove
class spell_kezan_447_sabotage : public AuraScript
{
    PrepareAuraScript(spell_kezan_447_sabotage);

    void HandleApply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        Unit* target = GetTarget();
        uint32 summon = 0;
        switch (GetId())
        {
            case Quest447::SPELL_GENERATOR_MASTER:      summon = Quest447::SPELL_SUMMON_GENERATOR;      break;
            case Quest447::SPELL_STOVE_LEAK_MASTER:     summon = Quest447::SPELL_SUMMON_STOVE_LEAK;     break;
            default:
                return;
        }
        target->CastSpell(target, summon, true);
    }

    void Register() override
    {
        AfterEffectApply += AuraEffectApplyFn(spell_kezan_447_sabotage::HandleApply, EFFECT_0, SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
    }
};

// 70251 447: Smoldering Bed Precast Master. The cigar is a missile to a nearby entry with a range of zero yards, so the
// master aura it should bring (70247) is not relied on; the bed starts to smolder when the cigar has been thrown.
class spell_kezan_447_bed_precast : public SpellScript
{
    PrepareSpellScript(spell_kezan_447_bed_precast);

    void HandleAfterCast()
    {
        if (Unit* caster = GetCaster())
            caster->CastSpell(caster, Quest447::SPELL_SUMMON_SMOLDERING_BED, true);
    }

    void Register() override
    {
        AfterCast += SpellCastFn(spell_kezan_447_bed_precast::HandleAfterCast);
    }
};

/*######
## Quest 14126: Life Savings
##
## The last quest of Kezan. Handing it in on Gallywix's yacht plays the movie of the escape (the reward spell 91847);
## after that the goblin wakes up on the beach of the Lost Isles: 74100 teleports and binds him there. Nothing cast
## that spell, so a goblin stayed behind on Kezan with nowhere to go.
######*/

class quest_kezan_life_savings : public QuestScript
{
public:
    quest_kezan_life_savings() : QuestScript("quest_kezan_life_savings") { }

    enum
    {
        SPELL_TELEPORT_AND_BIND_LOST_ISLES = 74100
    };

    void OnQuestStatusChange(Player* player, Quest const* /*quest*/, QuestStatus /*oldStatus*/, QuestStatus newStatus) override
    {
        if (newStatus != QUEST_STATUS_REWARDED)
            return;

        // after the reward has been handed out
        player->m_Events.AddLambdaEventAtOffset([player]
        {
            player->CastSpell(player, SPELL_TELEPORT_AND_BIND_LOST_ISLES, true);
        }, 1000);
    }
};

/*######
## Quest 14126: Life Savings, the ride to the yacht
##
## "Hand over the keys, boss. I'm driving." The gossip of Sassy Hardwrench makes the goblin cast 70318 (Hand Over the
## Keys): a Hot Rod (37676) with Sassy at the wheel takes him from the headquarters to the dock, runs over whoever is
## in the way, jumps onto the deck of the yacht and skids to a stop. For whoever gets to the dock on his own there
## is the Rope Ladder (70389 -> 70390) and the Last Chance Yacht Boarding Mortar (92629 -> 92633).
######*/

namespace LifeSavings
{
    enum
    {
        QUEST_LIFE_SAVINGS              = 14126,
        NPC_HOT_ROD                     = 37676,

        SPELL_SASSYS_DRIVING            = 66724,
        SPELL_HOT_ROD_SKID              = 70325,
        SPELL_HOT_ROD_KNOCKBACK_TRIGGER = 70329,
        SPELL_ROPE_LADDER_COVER         = 70389,
        SPELL_ROPE_LADDER               = 70390,
        SPELL_MORTAR                    = 92633,

        SEAT_SASSY                      = 0,

        SAY_GO_AROUND                   = 0,
        SAY_OUT_OF_THE_WAY              = 1,
        SAY_DOUBLE_CROSSED              = 2,

        POINT_DRIVE                     = 1,
        POINT_DECK                      = 2,

        STATE_WAIT                      = 0,
        STATE_DRIVE                     = 1,
        STATE_JUMP                      = 2,
        STATE_ARRIVED                   = 3,
        STATE_DONE                      = 4,

        DRIVE_TIME_MAX                  = 150000,
        JUMP_TIME_MAX                   = 5000,
        SKID_TIME                       = 4000
    };

    // where the Hot Rod with Sassy appears in the yard of the headquarters and where it stands on the deck afterwards
    Position const HotRodStart  = { -8408.95f, 1320.89f, 103.07f, 0.57f };
    Position const Deck         = { -7849.34f, 1841.15f, 7.61f, 0.15f };

    // the Kaja'Cola Balloon that came down on the highway, with the pile-up of Hot Rods under it
    Position const BalloonWreck = { -8104.1f, 1488.5f, 10.2f, 0.0f };

    // down the highway to the pile-up, around it to the coast road, along the coast to the dock
    Position const Route[] =
    {
        { -8108.1f, 1480.6f, 10.1f, 0.0f },
        { -8050.2f, 1488.3f, 9.9f,  0.0f },
        { -8004.8f, 1538.9f, 1.8f,  0.0f },
        { -8012.5f, 1634.8f, 2.5f,  0.0f },
        { -8000.6f, 1710.9f, 2.6f,  0.0f },
        { -7956.5f, 1832.7f, 9.3f,  0.0f },
        { -7881.0f, 1827.9f, 4.2f,  0.0f }
    };
    uint32 const RouteSize = sizeof(Route) / sizeof(Route[0]);
}

struct npc_kezan_life_savings_hot_rod : public ScriptedAI
{
    npc_kezan_life_savings_hot_rod(Creature* creature) : ScriptedAI(creature),
        _state(LifeSavings::STATE_WAIT), _anchor(0), _checkTimer(0), _timer(0), _said(0) { }

    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
    }

    void PassengerBoarded(Unit* passenger, int8 /*seatId*/, bool apply) override
    {
        if (!passenger->IsPlayer())
            return;

        if (apply)
        {
            if (_state != LifeSavings::STATE_WAIT)
                return;

            _playerGUID = passenger->GetGUID();
            _state = LifeSavings::STATE_DRIVE;
            _timer = LifeSavings::DRIVE_TIME_MAX;
            _checkTimer = 1000;
            me->SetWalk(false);
            me->CastSpell(me, LifeSavings::SPELL_HOT_ROD_KNOCKBACK_TRIGGER, true);
        }
        else if (_state != LifeSavings::STATE_DONE)
        {
            // the passenger got out on the way
            _state = LifeSavings::STATE_DONE;
            me->DespawnOrUnsummon(1000);
        }
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type == EFFECT_MOTION_TYPE && id == LifeSavings::POINT_DECK && _state == LifeSavings::STATE_JUMP)
            Arrive();
    }

    void UpdateAI(uint32 diff) override
    {
        switch (_state)
        {
            case LifeSavings::STATE_DRIVE:
                if (_timer <= diff)
                {
                    // stuck on the way: never leave the goblin behind on the island
                    me->GetMotionMaster()->Clear();
                    me->NearTeleportTo(LifeSavings::Deck.GetPositionX(), LifeSavings::Deck.GetPositionY(), LifeSavings::Deck.GetPositionZ(), LifeSavings::Deck.GetOrientation());
                    Arrive();
                    return;
                }
                _timer -= diff;

                if (_checkTimer > diff)
                {
                    _checkTimer -= diff;
                    return;
                }
                _checkTimer = 500;
                Drive();
                break;
            case LifeSavings::STATE_JUMP:
                if (_timer <= diff)
                    Arrive();
                else
                    _timer -= diff;
                break;
            case LifeSavings::STATE_ARRIVED:
                if (_timer <= diff)
                    Finish();
                else
                    _timer -= diff;
                break;
            default:
                break;
        }
    }

private:
    void Drive()
    {
        float const toBalloon = me->GetExactDist2d(&LifeSavings::BalloonWreck);
        if (!(_said & 1) && toBalloon < 90.0f)
        {
            _said |= 1;
            SassyTalk(LifeSavings::SAY_GO_AROUND);
        }
        else if (!(_said & 2) && toBalloon < 45.0f)
        {
            _said |= 2;
            SassyTalk(LifeSavings::SAY_OUT_OF_THE_WAY);
        }

        if (me->GetExactDist2d(&LifeSavings::Route[_anchor]) < 10.0f)
        {
            if (++_anchor >= LifeSavings::RouteSize)
            {
                // from the dock onto the deck
                _state = LifeSavings::STATE_JUMP;
                _timer = LifeSavings::JUMP_TIME_MAX;
                me->GetMotionMaster()->MoveJump(LifeSavings::Deck, 25.0f, 12.0f, LifeSavings::POINT_DECK);
                return;
            }

            me->GetMotionMaster()->MovePoint(LifeSavings::POINT_DRIVE, LifeSavings::Route[_anchor]);
        }
        else if (!me->isMoving())
            me->GetMotionMaster()->MovePoint(LifeSavings::POINT_DRIVE, LifeSavings::Route[_anchor]);
    }

    void Arrive()
    {
        _state = LifeSavings::STATE_ARRIVED;
        _timer = LifeSavings::SKID_TIME;
        me->RemoveAurasDueToSpell(LifeSavings::SPELL_HOT_ROD_KNOCKBACK_TRIGGER);
        me->StopMoving();
        me->CastSpell(me, LifeSavings::SPELL_HOT_ROD_SKID, true);
        SassyTalk(LifeSavings::SAY_DOUBLE_CROSSED);
    }

    void Finish()
    {
        _state = LifeSavings::STATE_DONE;
        if (Player* player = ObjectAccessor::GetPlayer(*me, _playerGUID))
            if (player->GetVehicleBase() == me)
                player->ExitVehicle();
        me->DespawnOrUnsummon(3000);
    }

    void SassyTalk(uint8 group)
    {
        Vehicle* kit = me->GetVehicleKit();
        Unit* sassy = kit ? kit->GetPassenger(LifeSavings::SEAT_SASSY) : nullptr;
        if (sassy && sassy->IsCreature())
            sassy->ToCreature()->AI()->Talk(group, ObjectAccessor::GetPlayer(*me, _playerGUID));
    }

    ObjectGuid _playerGUID;
    uint8 _state;
    uint32 _anchor;
    uint32 _checkTimer;
    uint32 _timer;
    uint8 _said;
};

// 70318 Life Savings: Hand Over the Keys (the gossip of Sassy Hardwrench; the player casts it on himself)
class spell_kezan_hand_over_the_keys : public SpellScript
{
    PrepareSpellScript(spell_kezan_hand_over_the_keys);

    void HandleDummy(SpellEffIndex /*effIndex*/)
    {
        Player* player = GetCaster() ? GetCaster()->ToPlayer() : nullptr;
        if (!player || player->GetVehicle())
            return;

        QuestStatus const status = player->GetQuestStatus(LifeSavings::QUEST_LIFE_SAVINGS);
        if (status != QUEST_STATUS_INCOMPLETE && status != QUEST_STATUS_COMPLETE)
            return;

        // as the summon of 70321 (Summon the Hot Rod) does: the Hot Rod with Sassy in it, the player on the seat next to her
        if (Creature* hotRod = player->SummonCreature(LifeSavings::NPC_HOT_ROD, LifeSavings::HotRodStart, TEMPSUMMON_TIMED_DESPAWN, 240s))
            player->CastSpell(hotRod, LifeSavings::SPELL_SASSYS_DRIVING, true);
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_kezan_hand_over_the_keys::HandleDummy, EFFECT_0, SPELL_EFFECT_DUMMY);
    }
};

// 70389 Life Savings: Rope Ladder - Cover, 92629 Life Savings: Last Chance Yacht Boarding Mortar - Cover
class spell_kezan_yacht_boarding : public SpellScript
{
    PrepareSpellScript(spell_kezan_yacht_boarding);

    void HandleScript(SpellEffIndex /*effIndex*/)
    {
        if (Unit* target = GetHitUnit())
            target->CastSpell(target, GetSpellInfo()->Id == LifeSavings::SPELL_ROPE_LADDER_COVER ? LifeSavings::SPELL_ROPE_LADDER : LifeSavings::SPELL_MORTAR, true);
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_kezan_yacht_boarding::HandleScript, EFFECT_0, SPELL_EFFECT_SCRIPT_EFFECT);
    }
};

void AddSC_kezan()
{
    new creature_script<npc_sister_goldskimmer>("npc_sister_goldskimmer");
    new creature_script<npc_kezan_hot_rod>("npc_kezan_hot_rod");
    new creature_script<npc_kezan_homie_rider>("npc_kezan_homie_rider");
    new quest_rolling_with_my_homies();
    new creature_script<npc_kezan_hired_looter>("npc_kezan_hired_looter");
    new spell_script<spell_kezan_create_stolen_loot>("spell_kezan_create_stolen_loot");
    new creature_script<npc_kezan_deathwing>("npc_kezan_deathwing");
    new spell_script<spell_kezan_kick_footbomb>("spell_kezan_kick_footbomb");
    new creature_script<npc_kezan_deadbeat>("npc_kezan_deadbeat");
    new creature_script<npc_kezan_bank_vault>("npc_kezan_bank_vault");
    new spell_script<spell_kezan_vault_interact>("spell_kezan_vault_interact");
    new spell_script<spell_kezan_vault_tool>("spell_kezan_vault_tool");
    new player_kezan_vault_logout();
    new spell_script<spell_kezan_kablooey_bombs>("spell_kezan_kablooey_bombs");
    new creature_script<npc_kezan_gasbot>("npc_kezan_gasbot");
    new spell_script<spell_kezan_gasbot_control_panel>("spell_kezan_gasbot_control_panel");
    new aura_script<spell_kezan_447_sabotage>("spell_kezan_447_sabotage");
    new spell_script<spell_kezan_447_bed_precast>("spell_kezan_447_bed_precast");
    new quest_kezan_life_savings();
    new creature_script<npc_kezan_life_savings_hot_rod>("npc_kezan_life_savings_hot_rod");
    new spell_script<spell_kezan_hand_over_the_keys>("spell_kezan_hand_over_the_keys");
    new spell_script<spell_kezan_yacht_boarding>("spell_kezan_yacht_boarding");
}
