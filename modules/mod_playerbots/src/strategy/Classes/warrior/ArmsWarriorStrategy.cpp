/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "ArmsWarriorStrategy.h"

#include "Playerbots.h"

class ArmsWarriorStrategyActionNodeFactory : public NamedObjectFactory<ActionNode>
{
public:
    ArmsWarriorStrategyActionNodeFactory()
    {
        creators["mortal strike"] = &mortal_strike;
        creators["slam"] = &slam;

        creators["overpower"] = &overpower;
        creators["sweeping strikes"] = &sweeping_strikes;
        creators["demoralizing banner"] = &demoralizing_banner;
    }

private:
    ACTION_NODE(mortal_strike, "mortal strike");
    ACTION_NODE(slam, "slam");
    ACTION_NODE(overpower, "overpower");
    ACTION_NODE(sweeping_strikes, "sweeping strikes");
    ACTION_NODE(demoralizing_banner, "demoralizing banner");
};

ArmsWarriorStrategy::ArmsWarriorStrategy(PlayerbotAI* botAI) : GenericWarriorStrategy(botAI)
{
    actionNodeFactories.Add(new ArmsWarriorStrategyActionNodeFactory());
}

NextAction** ArmsWarriorStrategy::getDefaultActions()
{
    // MoP priority list (the port had WotLK or empty rotations); resources and cooldowns gate each
    // entry through CanCastSpell, so the first castable spell wins
    return NextAction::array(0,
        new NextAction("recklessness", ACTION_DEFAULT + 0.97f),
        new NextAction("bloodbath", ACTION_DEFAULT + 0.95f),
        new NextAction("colossus smash", ACTION_DEFAULT + 0.90f),
        new NextAction("execute", ACTION_DEFAULT + 0.85f),
        new NextAction("mortal strike", ACTION_DEFAULT + 0.80f),
        new NextAction("overpower", ACTION_DEFAULT + 0.70f),
        new NextAction("dragon roar", ACTION_DEFAULT + 0.65f),
        new NextAction("storm bolt", ACTION_DEFAULT + 0.60f),
        new NextAction("slam", ACTION_DEFAULT + 0.50f),
        new NextAction("heroic strike", ACTION_DEFAULT + 0.30f),
        new NextAction("battle shout", ACTION_DEFAULT + 0.20f),
        new NextAction("melee", ACTION_DEFAULT + 0.00f),
        nullptr);
}

void ArmsWarriorStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    GenericWarriorStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("battle shout", NextAction::array(0, new NextAction("battle shout", ACTION_HIGH + 9), nullptr)));
    triggers.push_back(new TriggerNode("high rage available",NextAction::array(0, new NextAction("mortal strike", ACTION_HIGH + 3), nullptr)));
    triggers.push_back(new TriggerNode("overpower", NextAction::array(0, new NextAction("overpower", ACTION_HIGH + 4), nullptr)));
    triggers.push_back(new TriggerNode("taste for blood", NextAction::array(0, new NextAction("overpower", ACTION_HIGH + 4), nullptr)));
}
