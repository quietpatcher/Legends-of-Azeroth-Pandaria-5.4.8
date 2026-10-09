/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "FuryWarriorStrategy.h"

#include "Playerbots.h"

class FuryWarriorStrategyActionNodeFactory : public NamedObjectFactory<ActionNode>
{
public:
    FuryWarriorStrategyActionNodeFactory()
    {
        creators["raging blow"] = &raging_blow;
        creators["bloodthirst"] = &bloodthirst;
        creators["wild strike"] = &wild_strike;
        creators["skull banner"] = &skull_banner;
    }

private:
    ACTION_NODE(raging_blow, "raging blow");
    ACTION_NODE(bloodthirst, "bloodthirst");
    ACTION_NODE(wild_strike, "wild strike");
    ACTION_NODE(skull_banner, "skull banner");
};

FuryWarriorStrategy::FuryWarriorStrategy(PlayerbotAI* botAI) : GenericWarriorStrategy(botAI)
{
    actionNodeFactories.Add(new FuryWarriorStrategyActionNodeFactory());
}

NextAction** FuryWarriorStrategy::getDefaultActions()
{
    // MoP priority list (the port had WotLK or empty rotations); resources and cooldowns gate each
    // entry through CanCastSpell, so the first castable spell wins
    return NextAction::array(0,
        new NextAction("recklessness", ACTION_DEFAULT + 0.97f),
        new NextAction("bloodbath", ACTION_DEFAULT + 0.95f),
        new NextAction("colossus smash", ACTION_DEFAULT + 0.90f),
        new NextAction("execute", ACTION_DEFAULT + 0.85f),
        new NextAction("bloodthirst", ACTION_DEFAULT + 0.80f),
        new NextAction("raging blow", ACTION_DEFAULT + 0.75f),
        new NextAction("dragon roar", ACTION_DEFAULT + 0.65f),
        new NextAction("storm bolt", ACTION_DEFAULT + 0.60f),
        new NextAction("wild strike", ACTION_DEFAULT + 0.50f),
        new NextAction("heroic strike", ACTION_DEFAULT + 0.30f),
        new NextAction("battle shout", ACTION_DEFAULT + 0.20f),
        new NextAction("melee", ACTION_DEFAULT + 0.00f),
        nullptr);
}

void FuryWarriorStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    GenericWarriorStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("battle shout", NextAction::array(0, new NextAction("battle shout", ACTION_HIGH + 9), nullptr)));
    triggers.push_back(new TriggerNode("raging blow", NextAction::array(0, new NextAction("raging blow", ACTION_HIGH + 9), nullptr)));
    triggers.push_back(new TriggerNode("meat cleaver", NextAction::array(0, new NextAction("raging blow", ACTION_HIGH + 9), nullptr)));
    triggers.push_back(new TriggerNode("bloodsurge", NextAction::array(0, new NextAction("wild strike", ACTION_HIGH + 9), nullptr)));
}
