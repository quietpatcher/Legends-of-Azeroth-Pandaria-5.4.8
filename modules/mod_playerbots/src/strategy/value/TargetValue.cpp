/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "TargetValue.h"

#include "LastMovementValue.h"
#include "ObjectGuid.h"
#include "Playerbots.h"
#include "PlayerbotSpec.h"
#include "RtiTargetValue.h"
#include "ScriptedCreature.h"
#include "Log.h"
#include "ThreatManager.h"
#include <atomic>
#include <ctime>

Unit* FindTargetStrategy::GetResult()
{
    return result;
}

Unit* TargetValue::FindTarget(FindTargetStrategy* strategy)
{
    GuidVector attackers = botAI->GetAiObjectContext()->GetValue<GuidVector>("attackers")->Get();

    // to-do gotss: Gate of the Setting Sun (962), Striker Ga'dok (56589): retail tactic - tank and damage dealers
    // stay on the boss, adds only when they hit a healer (source: Wowhead/Wowpedia "Striker Ga'dok"; he summons 2+2 Krik'thik
    // every 20-28 s and the bots kept picking the adds: run 17275, 213 add kills in 43 min, Ga'dok alive). Not while he strafes
    // (REACT_PASSIVE, takes no lethal damage), not when out of reach (flags / hovering high); healers unchanged.
    if (bot->GetMapId() == 962 && !PlayerBotSpec::IsHeal(bot))
    {
        Unit* gadok = nullptr;
        bool healerHit = false;
        for (ObjectGuid const guid : attackers)
        {
            Unit* unit = botAI->GetUnit(guid);
            if (!unit || !unit->IsAlive())
                continue;
            if (unit->GetEntry() == 56589)
                gadok = unit;
            else if (Player* victim = unit->GetVictim() ? unit->GetVictim()->ToPlayer() : nullptr)
                if (victim->GetGroup() == bot->GetGroup() && PlayerBotSpec::IsHeal(victim))
                    healerHit = true;
        }
        Creature* gc = gadok ? gadok->ToCreature() : nullptr;
        if (gc && !healerHit && gc->IsInCombat() && gc->GetReactState() != REACT_PASSIVE &&
            !gc->HasUnitFlag(UNIT_FLAG_NOT_SELECTABLE) && !gc->HasUnitFlag(UNIT_FLAG_NON_ATTACKABLE) &&
            !gc->HasUnitFlag(UNIT_FLAG_IMMUNE_TO_PC) && gc->GetPositionZ() - bot->GetPositionZ() < 12.0f &&
            bot->GetExactDist(gc) < 60.0f)
        {
            static std::atomic<time_t> s_lastLog{0};
            time_t const now = time(nullptr);
            time_t last = s_lastLog.load();
            if (now - last >= 30 && s_lastLog.compare_exchange_strong(last, now))
                TC_LOG_INFO("playerbots", "GotSS focus Ga'dok: {} on Ga'dok (dist {:.0f})", bot->GetName(), bot->GetExactDist(gc));
            return gadok;
        }
    }

    for (ObjectGuid const guid : attackers)
    {
        Unit* unit = botAI->GetUnit(guid);
        if (!unit)
            continue;

        ThreatManager& ThreatMgr = unit->GetThreatManager();
        strategy->CheckAttacker(unit, &ThreatMgr);
    }

    return strategy->GetResult();
}

void FindTargetStrategy::GetPlayerCount(Unit* creature, uint32* tankCount, uint32* dpsCount)
{
    Player* bot = botAI->GetBot();
    if (tankCountCache.find(creature) != tankCountCache.end())
    {
        *tankCount = tankCountCache[creature];
        *dpsCount = dpsCountCache[creature];
        return;
    }

    *tankCount = 0;
    *dpsCount = 0;

    Unit::AttackerSet attackers(creature->getAttackers());
    for (Unit* attacker : attackers)
    {
        if (!attacker || !attacker->IsAlive() || attacker == bot)
            continue;

        Player* player = attacker->ToPlayer();
        if (!player)
            continue;

        if (PlayerBotSpec::IsTank(player))
            ++(*tankCount);
        else
            ++(*dpsCount);
    }

    tankCountCache[creature] = *tankCount;
    dpsCountCache[creature] = *dpsCount;
}

bool FindTargetStrategy::IsHighPriority(Unit* attacker)
{
    if (Group* group = botAI->GetBot()->GetGroup())
    {
        ObjectGuid guid = group->GetTargetIcon(7);
        if (guid && attacker->GetGUID() == guid)
        {
            return true;
        }
    }
    GuidVector prioritizedTargets = botAI->GetAiObjectContext()->GetValue<GuidVector>("prioritized targets")->Get();
    for (ObjectGuid targetGuid : prioritizedTargets)
    {
        if (targetGuid && attacker->GetGUID() == targetGuid)
        {
            return true;
        }
    }
    return false;
}

bool FindNonCcTargetStrategy::IsCcTarget(Unit* attacker)
{
    if (Group* group = botAI->GetBot()->GetGroup())
    {
        Group::MemberSlotList const& groupSlot = group->GetMemberSlots();
        for (Group::member_citerator itr = groupSlot.begin(); itr != groupSlot.end(); itr++)
        {
            Player* member = ObjectAccessor::FindPlayer(itr->guid);
            // a member on another map is updated by another map thread; asking its AI context from
            // here inserts into / reads its value maps concurrently with its own thread (heap corruption)
            if (!member || !member->IsInWorld() || member->FindMap() != botAI->GetBot()->FindMap() || !member->IsAlive())
                continue;

            if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(member))
            {
                if (botAI->GetAiObjectContext()->GetValue<Unit*>("rti cc target")->Get() == attacker)
                    return true;

                std::string const rti = botAI->GetAiObjectContext()->GetValue<std::string>("rti cc")->Get();
                int32 index = RtiTargetValue::GetRtiIndex(rti);
                if (index != -1)
                {
                    if (ObjectGuid guid = group->GetTargetIcon(index))
                        if (attacker->GetGUID() == guid)
                            return true;
                }
            }
        }

        if (ObjectGuid guid = group->GetTargetIcon(4))
            if (attacker->GetGUID() == guid)
                return true;
    }

    return false;
}

// (bot-duels) the opponent of the current duel (AzerothCore DuelTargetValue)
Unit* DuelTargetValue::Calculate() { return bot->duel ? bot->duel->opponent : nullptr; }
