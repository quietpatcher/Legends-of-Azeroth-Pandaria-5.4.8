/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "AttackersValue.h"
#include "BotLife.h"   // (avoid-in-dungeon)

#include "CellImpl.h"
#include "GridObject.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "ObjectMgr.h"
#include "Playerbots.h"
#include "ReputationMgr.h"
#include "ServerFacade.h"

// An NPC that fights next to the bot in a dungeon and that the bot may assist (an escort such as Muyoh in Wailing Caverns):
// its attackers are the group's enemies, as they are for players (382). Escort scripts often switch the NPC to a neutral
// escortee faction, so the friend check is IsValidAssistTarget, not IsFriendlyTo. An NPC that the player side attacks is
// skipped, and only attackers hostile to the bot and not controlled by a player are taken.
static void AddAttackersOfEscort(Player* bot, std::unordered_set<Unit*>& targets)
{
    std::list<Unit*> nearby;
    float const range = 40.0f;
    Trinity::AnyUnitInObjectRangeCheck check(bot, range);
    Trinity::UnitListSearcher<Trinity::AnyUnitInObjectRangeCheck> searcher(bot, nearby, check);
    bot->VisitNearbyGridObject(range, searcher);
    for (Unit* unit : nearby)
    {
        Creature* creature = unit->ToCreature();
        if (!creature || !creature->IsAlive() || !creature->IsInCombat() || creature->IsControlledByPlayer() || creature->IsTotem() ||
            creature->IsTrigger() || creature->GetCreatureType() == CREATURE_TYPE_CRITTER)
            continue;
        if (bot->IsHostileTo(creature) || !bot->IsValidAssistTarget(creature))
            continue;
        bool attackedByPlayerSide = false;
        for (Unit* attacker : creature->getAttackers())
            if (attacker->GetCharmerOrOwnerPlayerOrPlayerItself())
                attackedByPlayerSide = true;
        if (attackedByPlayerSide)
            continue;
        for (Unit* attacker : creature->getAttackers())
            if (attacker->IsAlive() && bot->IsHostileTo(attacker) && bot->GetDistance(attacker) < sPlayerbotAIConfig->sightDistance)
                targets.insert(attacker);
    }
}

GuidVector AttackersValue::Calculate()
{
    std::unordered_set<Unit*> targets;

    GuidVector result;
    if (!botAI->AllowActivity(ALL_ACTIVITY))
        return result;

    AddAttackersOf(bot, targets);

    if (Group* group = bot->GetGroup())
        AddAttackersOf(group, targets);

    if (bot->GetMap()->IsDungeon())
        AddAttackersOfEscort(bot, targets);

    RemoveNonThreating(targets);

    // prioritized target
    GuidVector prioritizedTargets = AI_VALUE(GuidVector, "prioritized targets");
    for (ObjectGuid target : prioritizedTargets)
    {
        Unit* unit = botAI->GetUnit(target);
        if (unit && IsValidTarget(unit, bot))
        {
            targets.insert(unit);
        }
    }
    if (Group* group = bot->GetGroup())
    {
        ObjectGuid skullGuid = group->GetTargetIcon(7);
        Unit* skullTarget = botAI->GetUnit(skullGuid);
        if (skullTarget && IsValidTarget(skullTarget, bot))
        {
            targets.insert(skullTarget);
        }
    }

    for (Unit* unit : targets)
        result.push_back(unit->GetGUID());

    if (bot->duel && bot->duel->opponent)
        result.push_back(bot->duel->opponent->GetGUID());

    // workaround for bots of same faction not fighting in arena
    if (bot->InArena())
    {
        GuidVector possibleTargets = AI_VALUE(GuidVector, "possible targets");
        for (ObjectGuid const guid : possibleTargets)
        {
            Unit* unit = botAI->GetUnit(guid);
            if (unit && unit->IsPlayer() && IsValidTarget(unit, bot))
            {
                result.push_back(unit->GetGUID());
            }
        }
    }

    return result;
}

void AttackersValue::AddAttackersOf(Group* group, std::unordered_set<Unit*>& targets)
{
    Group::MemberSlotList const& groupSlot = group->GetMemberSlots();
    for (Group::member_citerator itr = groupSlot.begin(); itr != groupSlot.end(); itr++)
    {
        Player* member = ObjectAccessor::FindPlayer(itr->guid);
        if (!member || !member->IsAlive() || member == bot || member->FindMap() != bot->FindMap() ||
            sServerFacade->GetDistance2d(bot, member) > sPlayerbotAIConfig->sightDistance)
            continue;

        AddAttackersOf(member, targets);
    }
}

struct AddGuardiansHelper
{
    explicit AddGuardiansHelper(std::vector<Unit*>& units) : units(units) {}

    void operator()(Unit* target) const { units.push_back(target); }

    std::vector<Unit*>& units;
};

void AttackersValue::AddAttackersOf(Player* player, std::unordered_set<Unit*>& targets)
{
    if (!player || !player->IsInWorld() || player->IsBeingTeleported())
        return;

    for (auto const& pair : player->GetThreatManager().GetThreatenedByMeList())
    {
        Unit* attacker = pair.second->GetThreatManager().GetOwner();
        if (!attacker)
            continue;

        if (player->IsValidAttackTarget(attacker) &&
            player->GetDistance2d(attacker) < sPlayerbotAIConfig->sightDistance)
        {
            targets.insert(attacker);
        }
    }
}

void AttackersValue::RemoveNonThreating(std::unordered_set<Unit*>& targets)
{
    for (std::unordered_set<Unit*>::iterator tIter = targets.begin(); tIter != targets.end();)
    {
        Unit* unit = *tIter;
        if (bot->FindMap() != unit->FindMap() || !hasRealThreat(unit) || !IsValidTarget(unit, bot))
        {
            std::unordered_set<Unit*>::iterator tIter2 = tIter;
            ++tIter;
            targets.erase(tIter2);
        }
        else
            ++tIter;
    }
}

bool AttackersValue::hasRealThreat(Unit* attacker)
{
    return attacker && attacker->IsInWorld() && attacker->IsAlive() && !attacker->IsPolymorphed() &&
        // !attacker->isInRoots() &&
        !attacker->IsFriendlyTo(bot);
    (attacker->GetThreatManager().GetCurrentVictim() || dynamic_cast<Player*>(attacker));
}

bool AttackersValue::IsPossibleTarget(Unit* attacker, Player* bot, float range)
{
    Creature* c = attacker->ToCreature();
    // a training dummy never dies: no target for a bot (Scarlet Monastery zealots train on them)
    if (c && (c->GetName().find("Dummy") != std::string::npos || sObjectMgr->GetScriptName(c->GetCreatureTemplate()->ScriptID) == "npc_training_dummy"))
        return false;
    // (avoid-in-dungeon) a foe the party leaves alone for now (one that cannot be hurt yet, Raigonn before Ri'mok): no target
    if (c && bot->GetMap()->IsDungeon() && sBotLife->IsAvoidedTarget(bot, c))
        return false;
    bool rti = false;
    if (attacker && bot->GetGroup())
        rti = bot->GetGroup()->GetTargetIcon(7) == attacker->GetGUID();

    PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);

    bool leaderHasThreat = false;
    if (attacker && bot->GetGroup() && botAI->GetMaster())
        leaderHasThreat = attacker->GetThreatManager().GetThreat(botAI->GetMaster());

    bool isMemberBotGroup = false;
    if (bot->GetGroup() && botAI->GetMaster())
    {
        PlayerbotAI* masterBotAI = GET_PLAYERBOT_AI(botAI->GetMaster());
        if (masterBotAI && !masterBotAI->IsRealPlayer())
            isMemberBotGroup = true;
    }

    // bool inCannon = botAI->IsInVehicle(false, true);
    // bool enemy = botAI->GetAiObjectContext()->GetValue<Unit*>("enemy player target")->Get();

    return attacker && attacker->IsVisible() && attacker->IsInWorld() && attacker->FindMap() == bot->FindMap() &&
        !attacker->isDead() &&
        !attacker->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NON_ATTACKABLE_2) &&
        // (inCannon || !attacker->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE)) &&
        // attacker->CanSeeOrDetect(bot) &&
        // !(attacker->HasUnitState(UNIT_STATE_STUNNED) && botAI->HasAura("shackle undead", attacker)) &&
        // !((attacker->IsPolymorphed() || botAI->HasAura("sap", attacker) || /*attacker->IsCharmed() ||*/
        // attacker->isFeared()) && !rti) &&
        /*!sServerFacade->IsInRoots(attacker) &&*/
        !attacker->IsFriendlyTo(bot) && !attacker->HasSpiritOfRedemptionAura() &&
        // !(attacker->GetGUID().IsPet() && enemy) &&
        !(attacker->GetCreatureType() == CREATURE_TYPE_CRITTER && !attacker->IsInCombat()) &&
        !attacker->HasUnitFlag(UNIT_FLAG_IMMUNE_TO_PC) && !attacker->HasUnitFlag(UNIT_FLAG_NOT_SELECTABLE) &&
        bot->CanSeeOrDetect(attacker) &&
        !(sPlayerbotAIConfig->IsPvpProhibited(attacker->GetZoneId(), attacker->GetAreaId()) &&
            (attacker->GetGUID().IsPlayer() || attacker->GetGUID().IsPet())) &&
        // a player, or anything a player controls (pet, guardian, totem): no target unless that player is flagged
        !(attacker->GetCharmerOrOwnerPlayerOrPlayerItself() &&
            !attacker->GetCharmerOrOwnerPlayerOrPlayerItself()->IsPvP() &&
            !attacker->GetCharmerOrOwnerPlayerOrPlayerItself()->IsFFAPvP() &&
            (!bot->duel || bot->duel->opponent != attacker->GetCharmerOrOwnerPlayerOrPlayerItself())) &&
        (!c ||
            (!c->IsInEvadeMode() &&
                ((!isMemberBotGroup && botAI->HasStrategy("attack tagged", BOT_STATE_NON_COMBAT)) || leaderHasThreat ||
                    (!c->HasLootRecipient() &&
                        (!c->GetVictim() ||
                            (c->GetVictim() &&
                                ((!c->GetVictim()->IsPlayer() || bot->IsInSameGroupWith(c->GetVictim()->ToPlayer())) ||
                                    (botAI->GetMaster() && c->GetVictim() == botAI->GetMaster()))))) ||
                    c->IsTappedBy(bot))));
}

bool AttackersValue::IsValidTarget(Unit* attacker, Player* bot)
{
    return IsPossibleTarget(attacker, bot) && bot->IsWithinLOSInMap(attacker);
    // (attacker->GetThreatMgr().getCurrentVictim() || attacker->GetGuidValue(UNIT_FIELD_TARGET) ||
    // attacker->GetGUID().IsPlayer() || attacker->GetGUID() ==
    // GET_PLAYERBOT_AI(bot)->GetAiObjectContext()->GetValue<ObjectGuid>("pull target")->Get());
}

bool PossibleAddsValue::Calculate()
{
    GuidVector possible = botAI->GetAiObjectContext()->GetValue<GuidVector>("possible targets no los")->Get();
    GuidVector attackers = botAI->GetAiObjectContext()->GetValue<GuidVector>("attackers")->Get();

    for (ObjectGuid const guid : possible)
    {
        if (find(attackers.begin(), attackers.end(), guid) != attackers.end())
            continue;

        if (Unit* add = botAI->GetUnit(guid))
        {
            if (!add->GetTarget() && !add->GetThreatManager().GetCurrentVictim() && add->IsHostileTo(bot))
            {
                for (ObjectGuid const attackerGUID : attackers)
                {
                    Unit* attacker = botAI->GetUnit(attackerGUID);
                    if (!attacker)
                        continue;

                    float dist = sServerFacade->GetDistance2d(attacker, add);
                    if (sServerFacade->IsDistanceLessOrEqualThan(dist, sPlayerbotAIConfig->aoeRadius * 1.5f))
                        continue;

                    if (sServerFacade->IsDistanceLessOrEqualThan(dist, sPlayerbotAIConfig->aggroDistance))
                        return true;
                }
            }
        }
    }

    return false;
}
