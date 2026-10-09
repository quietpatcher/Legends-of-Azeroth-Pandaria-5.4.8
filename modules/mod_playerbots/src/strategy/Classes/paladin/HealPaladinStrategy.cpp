/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "HealPaladinStrategy.h"

#include "Playerbots.h"
#include "Strategy.h"

class HealPaladinStrategyActionNodeFactory : public NamedObjectFactory<ActionNode>
{
public:
    // HealPaladinStrategyActionNodeFactory()
    // {
    //     creators["concentration aura"] = &concentration_aura;
    // }

private:
    // ACTION_NODE_A(concentration_aura, "concentration aura", "devotion aura");
};

HealPaladinStrategy::HealPaladinStrategy(PlayerbotAI* botAI) : GenericPaladinStrategy(botAI)
{
    actionNodeFactories.Add(new HealPaladinStrategyActionNodeFactory());
}

NextAction** HealPaladinStrategy::getDefaultActions()
{
    // MoP priority list (the port had WotLK or empty rotations); resources and cooldowns gate each
    // entry through CanCastSpell, so the first castable spell wins
    return NextAction::array(0,
        new NextAction("judgment", ACTION_DEFAULT + 0.50f),
        new NextAction("crusader strike", ACTION_DEFAULT + 0.40f),
        new NextAction("melee", ACTION_DEFAULT + 0.00f),
        nullptr);
}

void HealPaladinStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    GenericPaladinStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("seal", NextAction::array(0, new NextAction("seal of insight", ACTION_HIGH), nullptr)));
    triggers.push_back(new TriggerNode("medium mana", NextAction::array(0, new NextAction("divine illumination", ACTION_HIGH + 2), nullptr)));
    triggers.push_back(new TriggerNode("low mana", NextAction::array(0, new NextAction("divine favor", ACTION_HIGH + 1), nullptr)));
    triggers.push_back(new TriggerNode("party member to heal out of spell range", NextAction::array(0, new NextAction("reach party member to heal", ACTION_EMERGENCY + 3), nullptr)));

    triggers.push_back(
        new TriggerNode("medium group heal setting", NextAction::array(0, 
            new NextAction("divine sacrifice", ACTION_CRITICAL_HEAL + 5),
            new NextAction("avenging wrath", ACTION_HIGH + 4), 
            nullptr)));

    triggers.push_back(
        new TriggerNode("party member critical health", NextAction::array(0,
            new NextAction("holy shock on party", ACTION_CRITICAL_HEAL + 6),
            new NextAction("divine sacrifice", ACTION_CRITICAL_HEAL + 5),
            new NextAction("holy light on party", ACTION_CRITICAL_HEAL + 4), nullptr)));

    triggers.push_back(
        new TriggerNode("party member low health",
                        NextAction::array(0, new NextAction("holy light on party", ACTION_MEDIUM_HEAL + 5), nullptr)));

    triggers.push_back(
        new TriggerNode("party member medium health",
                        NextAction::array(0, new NextAction("holy light on party", ACTION_LIGHT_HEAL + 9),
                                          new NextAction("flash of light on party", ACTION_LIGHT_HEAL + 8), nullptr)));

    triggers.push_back(new TriggerNode(
        "party member almost full health",
        NextAction::array(0, new NextAction("flash of light on party", ACTION_LIGHT_HEAL + 3), nullptr)));

    triggers.push_back(new TriggerNode(
        "beacon of light on main tank",
        NextAction::array(0, new NextAction("beacon of light on main tank", ACTION_CRITICAL_HEAL + 7), nullptr)));

    triggers.push_back(new TriggerNode(
        "sacred shield on main tank",
        NextAction::array(0, new NextAction("sacred shield on main tank", ACTION_CRITICAL_HEAL + 6), nullptr)));
}
