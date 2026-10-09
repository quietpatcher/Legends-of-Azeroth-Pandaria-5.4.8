/*
 * monk class AI (see MonkTriggers.h).
 *
 * Resource costs (chi, energy, mana) are not modelled here: PlayerbotAI::CanCastSpell checks the power cost,
 * so an ability the monk cannot pay for is skipped and the engine falls through to the next one.
 */

#include "MonkStrategies.h"

#include "Playerbots.h"

// -- shared brewmaster / windwalker

void GenericMonkStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    MeleeCombatStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("spear hand strike", NextAction::array(0, new NextAction("spear hand strike", ACTION_INTERRUPT + 2), nullptr)));
    triggers.push_back(new TriggerNode("touch of death", NextAction::array(0, new NextAction("touch of death", ACTION_HIGH + 9), nullptr)));
    triggers.push_back(new TriggerNode("tiger power", NextAction::array(0, new NextAction("tiger palm", ACTION_HIGH + 3), nullptr)));

    triggers.push_back(new TriggerNode("medium health", NextAction::array(0, new NextAction("expel harm", ACTION_HIGH + 4), nullptr)));
    triggers.push_back(new TriggerNode("low health", NextAction::array(0,
        new NextAction("fortifying brew", ACTION_HIGH + 8),
        new NextAction("surging mist", ACTION_HIGH + 7), nullptr)));
    triggers.push_back(new TriggerNode("critical health", NextAction::array(0,
        new NextAction("fortifying brew", ACTION_EMERGENCY + 1),
        new NextAction("expel harm", ACTION_EMERGENCY), nullptr)));
}

// -- brewmaster (tank)

NextAction** BrewmasterMonkStrategy::getDefaultActions()
{
    return NextAction::array(0,
        new NextAction("keg smash", ACTION_DEFAULT + 0.6f),
        new NextAction("blackout kick", ACTION_DEFAULT + 0.4f),
        new NextAction("jab", ACTION_DEFAULT + 0.3f),
        new NextAction("tiger palm", ACTION_DEFAULT + 0.2f),   // free for brewmasters: filler without energy
        new NextAction("melee", ACTION_DEFAULT), nullptr);
}

void BrewmasterMonkStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    GenericMonkStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("stance of the sturdy ox", NextAction::array(0, new NextAction("stance of the sturdy ox", ACTION_HIGH + 9), nullptr)));
    triggers.push_back(new TriggerNode("lose aggro", NextAction::array(0, new NextAction("provoke", ACTION_INTERRUPT + 1), nullptr)));
    triggers.push_back(new TriggerNode("shuffle", NextAction::array(0, new NextAction("blackout kick", ACTION_HIGH + 5), nullptr)));
    triggers.push_back(new TriggerNode("heavy stagger", NextAction::array(0, new NextAction("purifying brew", ACTION_HIGH + 8), nullptr)));
    triggers.push_back(new TriggerNode("elusive brew", NextAction::array(0, new NextAction("elusive brew", ACTION_HIGH + 6), nullptr)));
    triggers.push_back(new TriggerNode("medium health", NextAction::array(0, new NextAction("guard", ACTION_HIGH + 6), nullptr)));
}

// -- windwalker (melee dps, also monks without specialization and solo mistweavers)

NextAction** WindwalkerMonkStrategy::getDefaultActions()
{
    return NextAction::array(0,
        new NextAction("rising sun kick", ACTION_DEFAULT + 0.8f),
        new NextAction("fists of fury", ACTION_DEFAULT + 0.6f),
        new NextAction("blackout kick", ACTION_DEFAULT + 0.5f),
        new NextAction("jab", ACTION_DEFAULT + 0.3f),
        new NextAction("melee", ACTION_DEFAULT), nullptr);
}

void WindwalkerMonkStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    GenericMonkStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("stance of the fierce tiger", NextAction::array(0, new NextAction("stance of the fierce tiger", ACTION_HIGH + 9), nullptr)));
    triggers.push_back(new TriggerNode("rising sun kick", NextAction::array(0, new NextAction("rising sun kick", ACTION_HIGH + 6), nullptr)));
    triggers.push_back(new TriggerNode("combo breaker: blackout kick", NextAction::array(0, new NextAction("blackout kick", ACTION_HIGH + 5), nullptr)));
    triggers.push_back(new TriggerNode("combo breaker: tiger palm", NextAction::array(0, new NextAction("tiger palm", ACTION_HIGH + 5), nullptr)));
    triggers.push_back(new TriggerNode("tigereye brew", NextAction::array(0, new NextAction("tigereye brew", ACTION_HIGH + 7), nullptr)));
    triggers.push_back(new TriggerNode("energizing brew", NextAction::array(0, new NextAction("energizing brew", ACTION_HIGH + 7), nullptr)));
    triggers.push_back(new TriggerNode("low health", NextAction::array(0, new NextAction("touch of karma", ACTION_HIGH + 8), nullptr)));
}

// -- mistweaver (healer)

NextAction** MistweaverMonkStrategy::getDefaultActions()
{
    return NextAction::array(0, new NextAction("crackling jade lightning", ACTION_DEFAULT), nullptr);
}

void MistweaverMonkStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    RangedCombatStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("stance of the wise serpent", NextAction::array(0, new NextAction("stance of the wise serpent", ACTION_HIGH + 9), nullptr)));
    triggers.push_back(new TriggerNode("spear hand strike", NextAction::array(0, new NextAction("spear hand strike", ACTION_INTERRUPT + 2), nullptr)));
    triggers.push_back(new TriggerNode("mana tea", NextAction::array(0, new NextAction("mana tea", ACTION_HIGH + 5), nullptr)));

    triggers.push_back(new TriggerNode("party member to heal out of spell range", NextAction::array(0,
        new NextAction("reach party member to heal", ACTION_CRITICAL_HEAL + 10), nullptr)));

    triggers.push_back(new TriggerNode("monk group heal critical", NextAction::array(0,
        new NextAction("revival", ACTION_CRITICAL_HEAL + 8), nullptr)));
    triggers.push_back(new TriggerNode("monk group heal", NextAction::array(0,
        new NextAction("uplift", ACTION_MEDIUM_HEAL + 6),
        new NextAction("renewing mist on party", ACTION_MEDIUM_HEAL + 5), nullptr)));

    triggers.push_back(new TriggerNode("party member critical health", NextAction::array(0,
        new NextAction("life cocoon on party", ACTION_CRITICAL_HEAL + 6),
        new NextAction("enveloping mist on party", ACTION_CRITICAL_HEAL + 4),
        new NextAction("surging mist on party", ACTION_CRITICAL_HEAL + 3),
        new NextAction("soothing mist on party", ACTION_CRITICAL_HEAL + 2), nullptr)));
    triggers.push_back(new TriggerNode("party member low health", NextAction::array(0,
        new NextAction("enveloping mist on party", ACTION_MEDIUM_HEAL + 4),
        new NextAction("surging mist on party", ACTION_MEDIUM_HEAL + 3),
        new NextAction("renewing mist on party", ACTION_MEDIUM_HEAL + 2),
        new NextAction("soothing mist on party", ACTION_MEDIUM_HEAL + 1), nullptr)));
    triggers.push_back(new TriggerNode("party member medium health", NextAction::array(0,
        new NextAction("renewing mist on party", ACTION_LIGHT_HEAL + 6),
        new NextAction("surging mist on party", ACTION_LIGHT_HEAL + 4),
        new NextAction("soothing mist on party", ACTION_LIGHT_HEAL + 3), nullptr)));
    triggers.push_back(new TriggerNode("party member almost full health", NextAction::array(0,
        new NextAction("renewing mist on party", ACTION_LIGHT_HEAL + 2), nullptr)));

    triggers.push_back(new TriggerNode("critical health", NextAction::array(0,
        new NextAction("fortifying brew", ACTION_EMERGENCY + 1), nullptr)));
}

// -- aoe (brewmaster / windwalker)

void MonkAoeStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    triggers.push_back(new TriggerNode("light aoe", NextAction::array(0,
        new NextAction("breath of fire", ACTION_HIGH + 2), nullptr)));
    triggers.push_back(new TriggerNode("medium aoe", NextAction::array(0,
        new NextAction("spinning crane kick", ACTION_HIGH + 4),
        new NextAction("breath of fire", ACTION_HIGH + 3), nullptr)));
}

// -- cure

void MonkCureStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    triggers.push_back(new TriggerNode("detox poison", NextAction::array(0, new NextAction("detox", ACTION_DISPEL + 2), nullptr)));
    triggers.push_back(new TriggerNode("detox disease", NextAction::array(0, new NextAction("detox", ACTION_DISPEL + 2), nullptr)));
    triggers.push_back(new TriggerNode("detox poison on party", NextAction::array(0, new NextAction("detox poison on party", ACTION_DISPEL + 1), nullptr)));
    triggers.push_back(new TriggerNode("detox disease on party", NextAction::array(0, new NextAction("detox disease on party", ACTION_DISPEL + 1), nullptr)));
}

// -- out of combat

void MonkNonCombatStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    NonCombatStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("legacy of the emperor", NextAction::array(0, new NextAction("legacy of the emperor", ACTION_NORMAL + 2), nullptr)));
    triggers.push_back(new TriggerNode("party member dead", NextAction::array(0, new NextAction("resuscitate", ACTION_CRITICAL_HEAL + 10), nullptr)));
}
