/*
 * monk class AI (see MonkTriggers.h).
 */

#include "MonkTriggers.h"

#include "Group.h"
#include "Playerbots.h"

bool LegacyOfTheEmperorTrigger::IsActive()
{
    // the 5% stats raid buffs do not stack: with one of these active the legacy never sticks and would be recast forever
    if (botAI->HasAura("mark of the wild", bot) || botAI->HasAura("blessing of kings", bot) ||
        botAI->HasAura("embrace of the shale spider", bot))
        return false;

    return BuffTrigger::IsActive();
}

bool TigerPowerTrigger::IsActive()
{
    if (!bot->HasSpell(100787))  // tiger palm
        return false;

    Unit* target = AI_VALUE(Unit*, "current target");
    if (!target || !bot->IsWithinMeleeRange(target))
        return false;

    Aura* aura = botAI->GetAura("tiger power", bot);
    return !aura || (aura->GetDuration() >= 0 && aura->GetDuration() < 3000);
}

bool ShuffleTrigger::IsActive()
{
    if (bot->GetSpecialization() != Specializations::SPEC_MONK_BREWMASTER || !bot->HasSpell(100784))  // blackout kick
        return false;

    Aura* aura = bot->GetAura(115307);  // shuffle
    return !aura || (aura->GetDuration() >= 0 && aura->GetDuration() < 2000);
}

bool HeavyStaggerTrigger::IsActive()
{
    if (bot->HasAura(124273))  // heavy stagger
        return true;

    // moderate stagger while the tank is already getting low
    return bot->HasAura(124274) && AI_VALUE2(uint8, "health", "self target") < 60;
}

bool BrewStacksTrigger::IsActive()
{
    if (bot->HasAura(activeAura))
        return false;

    Aura* stacks = bot->GetAura(stackAura);
    return stacks && stacks->GetStackAmount() >= minStacks;
}

bool ElusiveBrewTrigger::IsActive()
{
    // dodge buff: only while something is actually hitting the tank
    return BrewStacksTrigger::IsActive() && bot->IsInCombat() && !bot->getAttackers().empty();
}

bool ManaTeaTrigger::IsActive()
{
    return BrewStacksTrigger::IsActive() && AI_VALUE2(uint8, "mana", "self target") < 70;
}

bool EnergizingBrewTrigger::IsActive()
{
    return bot->HasSpell(115288) && bot->IsInCombat() && AI_VALUE2(uint8, "energy", "self target") < 30;
}

bool MonkChiFullTrigger::IsActive()
{
    // (healer-mana) chi only becomes Mana Tea when it is spent
    return bot->IsInCombat() && bot->GetMaxPower(POWER_CHI) > 0 && bot->GetPower(POWER_CHI) >= bot->GetMaxPower(POWER_CHI);
}

bool MonkGroupHealTrigger::IsActive()
{
    Group* group = bot->GetGroup();
    if (!group)
        return false;

    uint32 hurt = 0;
    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        Player* member = ref->GetSource();
        if (!member || !member->IsInWorld() || !member->IsAlive() || member->FindMap() != bot->FindMap())
            continue;

        if (member->GetHealthPct() < healthPct && bot->GetDistance(member) < 40.0f)
            ++hurt;
    }

    return hurt >= count;
}
