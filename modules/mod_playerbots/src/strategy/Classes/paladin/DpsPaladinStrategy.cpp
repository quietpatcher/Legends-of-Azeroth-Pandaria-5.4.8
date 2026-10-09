/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "DpsPaladinStrategy.h"

#include "Playerbots.h"
#include "Strategy.h"

class DpsPaladinStrategyActionNodeFactory : public NamedObjectFactory<ActionNode>
{
public:
    DpsPaladinStrategyActionNodeFactory()
    {
        
    }

private:
    
};

DpsPaladinStrategy::DpsPaladinStrategy(PlayerbotAI* botAI) : GenericPaladinStrategy(botAI)
{
    actionNodeFactories.Add(new DpsPaladinStrategyActionNodeFactory());
}

NextAction** DpsPaladinStrategy::getDefaultActions()
{
    // MoP priority list (the port had WotLK or empty rotations); resources and cooldowns gate each
    // entry through CanCastSpell, so the first castable spell wins
    return NextAction::array(0,
        new NextAction("inquisition", ACTION_DEFAULT + 0.95f),
        new NextAction("templar's verdict", ACTION_DEFAULT + 0.90f),
        new NextAction("hammer of wrath", ACTION_DEFAULT + 0.85f),
        new NextAction("exorcism", ACTION_DEFAULT + 0.80f),
        new NextAction("crusader strike", ACTION_DEFAULT + 0.75f),
        new NextAction("judgment", ACTION_DEFAULT + 0.70f),
        new NextAction("execution sentence", ACTION_DEFAULT + 0.65f),
        new NextAction("melee", ACTION_DEFAULT + 0.00f),
        nullptr);
}

void DpsPaladinStrategy::InitTriggers(std::vector<TriggerNode*>& triggers)
{
    GenericPaladinStrategy::InitTriggers(triggers);

    triggers.push_back(new TriggerNode("seal", NextAction::array(0, new NextAction("seal of truth", ACTION_HIGH), new NextAction("seal of righteousness", ACTION_HIGH - 1), nullptr)));
    triggers.push_back(new TriggerNode("enemy out of melee", NextAction::array(0, new NextAction("reach melee", ACTION_HIGH + 1), NULL)));
}
