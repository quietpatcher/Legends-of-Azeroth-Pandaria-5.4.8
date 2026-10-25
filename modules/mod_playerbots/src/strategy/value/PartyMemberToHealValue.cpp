/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "PartyMemberToHealValue.h"

#include "Playerbots.h"
#include "PlayerbotSpec.h"
#include "ServerFacade.h"
#include "CellImpl.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "GameTime.h"
#include <unordered_map>

class IsTargetOfHealingSpell : public SpellEntryPredicate
{
public:
    bool Check(SpellInfo const* spellInfo) override
    {
        for (uint8 i = 0; i < 3; ++i)
        {
            if (spellInfo->Effects[i].Effect == SPELL_EFFECT_HEAL ||
                spellInfo->Effects[i].Effect == SPELL_EFFECT_HEAL_MAX_HEALTH ||
                spellInfo->Effects[i].Effect == SPELL_EFFECT_HEAL_MECHANICAL)
                return true;
        }

        return false;
    }
};

inline bool compareByHealth(Unit const* u1, Unit const* u2) { return u1->GetHealthPct() < u2->GetHealthPct(); }

Unit* PartyMemberToHeal::Calculate()
{
    IsTargetOfHealingSpell predicate;

    Group* group = bot->GetGroup();
    if (!group)
        return bot;

    bool isRaid = bot->GetGroup()->isRaidGroup();
    MinValueCalculator calc(100);

    for (GroupReference* gref = group->GetFirstMember(); gref; gref = gref->next())
    {
        Player* player = gref->GetSource();
        // only inspect/heal a group member updated on our own map thread; a member in another instance
        // runs on a different thread -> cross-thread read + heal/aura write = heap corruption (the WRITE-analog of the
        // PartyMemberValue guard). Also null-safe before the IsGameMaster() deref below.
        if (!player || !player->IsInWorld() || player->FindMap() != bot->FindMap())
            continue;
        if (player->IsGameMaster())
            continue;
        if (player && player->IsAlive())
        {
            uint8 health = player->GetHealthPct();
            if (isRaid || health < sPlayerbotAIConfig->mediumHealth || !IsTargetOfSpellCast(player, predicate))
            {
                uint32 probeValue = 100;
                if (player->GetDistance2d(bot) > sPlayerbotAIConfig->healDistance)
                {
                    probeValue = health + 30;
                }
                else
                {
                    probeValue = health + player->GetDistance2d(bot) / 10;
                }
                // delay Check player to here for better performance
                if (probeValue < calc.minValue && Check(player))
                {
                    calc.probe(probeValue, player);
                }
            }
        }

        Pet* pet = player->GetPet();
        if (pet && pet->IsAlive())
        {
            uint8 health = ((Unit*)pet)->GetHealthPct();
            uint32 probeValue = 100;
            if (isRaid || health < sPlayerbotAIConfig->mediumHealth)
                probeValue = health + 30;
            // delay Check pet to here for better performance
            if (probeValue < calc.minValue && Check(pet))
            {
                calc.probe(probeValue, pet);
            }
        }

        Unit* charm = player->GetCharm();
        if (charm && charm->IsAlive())
        {
            uint8 health = charm->GetHealthPct();
            uint32 probeValue = 100;
            if (isRaid || health < sPlayerbotAIConfig->mediumHealth)
                probeValue = health + 30;
            // delay Check charm to here for better performance
            if (probeValue < calc.minValue && Check(charm))
            {
                calc.probe(probeValue, charm);
            }
        }
    }

    // an NPC that fights next to the group in a dungeon (an escort such as Muyoh in Wailing Caverns): players heal it, the
    // healer only looked at group members, their pets and charms (382). Escort scripts often switch the NPC to a neutral
    // escortee faction (Muyoh: 250), so a friendly-only search never returned it; take every unit the bot may assist and
    // accept a non-friendly one only while it fights enemies of the bot and nobody on the player side attacks it.
    if (bot->GetMap()->IsDungeon())
    {
        std::list<Unit*> nearby;
        float const range = sPlayerbotAIConfig->healDistance;
        Trinity::AnyUnitInObjectRangeCheck check(bot, range);
        Trinity::UnitListSearcher<Trinity::AnyUnitInObjectRangeCheck> searcher(bot, nearby, check);
        bot->VisitNearbyGridObject(range, searcher);
        for (Unit* unit : nearby)
        {
            Creature* creature = unit->ToCreature();
            if (!creature || creature->IsControlledByPlayer() || creature->IsTotem() || creature->IsTrigger() || creature->GetCreatureType() == CREATURE_TYPE_CRITTER || !creature->IsInCombat())
                continue;
            if (bot->IsHostileTo(creature) || !bot->IsValidAssistTarget(creature))
                continue;
            if (!bot->IsFriendlyTo(creature))
            {
                bool fightsEnemy = false, attackedByPlayerSide = false;
                if (Unit* victim = creature->GetVictim())
                    fightsEnemy = bot->IsHostileTo(victim);
                for (Unit* attacker : creature->getAttackers())
                {
                    if (attacker->GetCharmerOrOwnerPlayerOrPlayerItself())
                        attackedByPlayerSide = true;
                    else if (bot->IsHostileTo(attacker))
                        fightsEnemy = true;
                }
                if (!fightsEnemy || attackedByPlayerSide)
                    continue;
            }
            uint8 health = creature->GetHealthPct();
            if (health >= sPlayerbotAIConfig->mediumHealth)
                continue;
            uint32 probeValue = health + 10;
            if (probeValue < calc.minValue && Check(creature))
                calc.probe(probeValue, creature);
        }
        if (Unit* chosen = (Unit*)calc.param)
            if (chosen->GetTypeId() == TYPEID_UNIT && !chosen->IsControlledByPlayer())
            {
                // diag (382): the NPC became the heal target, every 10 s per bot
                thread_local std::unordered_map<ObjectGuid::LowType, uint32> lastChosen;
                uint32 const nowMs = GameTime::GetGameTimeMS();
                uint32& last = lastChosen[bot->GetGUID().GetCounter()];
                if (!last || nowMs - last > 10000)
                {
                    last = nowMs;
                    TC_LOG_INFO("playerbots", "Healer {} picks NPC {} ({}) at {}% as heal target (382)",
                        bot->GetName(), chosen->GetName(), chosen->GetEntry(), uint32(chosen->GetHealthPct()));
                }
            }
    }
    return (Unit*)calc.param;
}

bool PartyMemberToHeal::Check(Unit* player)
{
    // return player && player != bot && player->GetMapId() == bot->GetMapId() && player->IsInWorld() &&
    //     sServerFacade->GetDistance2d(bot, player) < (player->IsPlayer() && botAI->IsTank((Player*)player) ? 50.0f
    //     : 40.0f);
    return player->FindMap() == bot->FindMap() && !player->IsCharmed() &&
        bot->GetDistance2d(player) < sPlayerbotAIConfig->healDistance * 2 && bot->IsWithinLOSInMap(player);
}

Unit* PartyMemberToProtect::Calculate()
{
    return nullptr;
    Group* group = bot->GetGroup();
    if (!group)
        return nullptr;

    std::vector<Unit*> needProtect;

    GuidVector attackers = botAI->GetAiObjectContext()->GetValue<GuidVector>("attackers")->Get();
    for (GuidVector::iterator i = attackers.begin(); i != attackers.end(); ++i)
    {
        Unit* unit = botAI->GetUnit(*i);
        if (!unit)
            continue;

        Unit* pVictim = unit->GetVictim();
        if (!pVictim || !pVictim->IsPlayer())
            continue;

        if (pVictim == bot)
            continue;

        float attackDistance = 30.0f;
        if (sServerFacade->GetDistance2d(pVictim, unit) > attackDistance)
            continue;

        if (PlayerBotSpec::IsTank((Player*)pVictim) && pVictim->GetHealthPct() > 10)
            continue;
        else if (pVictim->GetHealthPct() > 30)
            continue;

        if (find(needProtect.begin(), needProtect.end(), pVictim) == needProtect.end())
            needProtect.push_back(pVictim);
    }

    if (needProtect.empty())
        return nullptr;

    sort(needProtect.begin(), needProtect.end(), compareByHealth);

    return needProtect[0];
}
