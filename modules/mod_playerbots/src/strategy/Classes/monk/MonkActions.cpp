/*
 * monk class AI (see MonkTriggers.h).
 */

#include "MonkActions.h"

#include "Group.h"
#include "Playerbots.h"

bool CastLegacyOfTheEmperorAction::isUseful()
{
    // does not stack with the other 5% stats raid buffs
    if (botAI->HasAura("mark of the wild", bot) || botAI->HasAura("blessing of kings", bot) ||
        botAI->HasAura("embrace of the shale spider", bot))
        return false;

    return CastBuffSpellAction::isUseful();
}

bool CastUpliftAction::isUseful()
{
    // uplift only heals targets with our renewing mist on them
    Group* group = bot->GetGroup();
    if (!group)
        return false;

    uint32 count = 0;
    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        Player* member = ref->GetSource();
        if (!member || !member->IsInWorld() || !member->IsAlive() || member->FindMap() != bot->FindMap())
            continue;

        if (member->GetHealthPct() < 85.0f && member->HasAura(119611, bot->GetGUID()))  // renewing mist hot
            ++count;
    }

    return count >= 2 && CastMonkSelfSpellAction::isUseful();
}
