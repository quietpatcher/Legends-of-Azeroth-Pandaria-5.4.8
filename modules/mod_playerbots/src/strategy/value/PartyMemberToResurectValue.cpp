/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "PartyMemberToResurectValue.h"

#include "Playerbots.h"

class IsTargetOfResurrectSpell : public SpellEntryPredicate
{
public:
    bool Check(SpellInfo const* spellInfo) override
    {
        for (uint8 i = 0; i < 3; ++i)
        {
            if (spellInfo->Effects[i].Effect == SPELL_EFFECT_RESURRECT ||
                spellInfo->Effects[i].Effect == SPELL_EFFECT_RESURRECT_NEW ||
                spellInfo->Effects[i].Effect == SPELL_EFFECT_SELF_RESURRECT)
                return true;
        }

        return false;
    }
};

class FindDeadPlayer : public FindPlayerPredicate
{
public:
    FindDeadPlayer(PartyMemberValue* value) : value(value) {}

    bool Check(Unit* unit) override
    {
        Player* player = unit->ToPlayer();
        return player && !player->IsRessurectRequested() && player->getDeathState() == DeathState::CORPSE &&
            !value->IsTargetOfSpellCast(player, predicate);
    }

private:
    PartyMemberValue* value;
    IsTargetOfResurrectSpell predicate;
};

// (rez-no-los) a dead member behind an obstacle is a target too, within sight distance on the same map
bool PartyMemberToResurrect::Check(Unit* player)
{
    if (!player || player->FindMap() != bot->FindMap())
        return false;
    if (player->ToPlayer() && player->ToPlayer()->IsGameMaster())
        return false;
    return bot->GetDistance(player) < sPlayerbotAIConfig->sightDistance;
}

Unit* PartyMemberToResurrect::Calculate()
{
    FindDeadPlayer finder(this);
    return FindPartyMember(finder);
}
