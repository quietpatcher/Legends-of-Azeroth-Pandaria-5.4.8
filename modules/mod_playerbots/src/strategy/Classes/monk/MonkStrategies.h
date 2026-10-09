/*
 * monk class AI (see MonkTriggers.h).
 */

#ifndef _PLAYERBOT_MONKSTRATEGIES_H
#define _PLAYERBOT_MONKSTRATEGIES_H

#include "CombatStrategy.h"
#include "MeleeCombatStrategy.h"
#include "NonCombatStrategy.h"
#include "RangedCombatStrategy.h"

class PlayerbotAI;

// shared by brewmaster and windwalker (and monks below level 10 without a specialization)
class GenericMonkStrategy : public MeleeCombatStrategy
{
public:
    GenericMonkStrategy(PlayerbotAI* botAI) : MeleeCombatStrategy(botAI) {}

    void InitTriggers(std::vector<TriggerNode*>& triggers) override;
    std::string const getName() override { return "monk"; }
};

class BrewmasterMonkStrategy : public GenericMonkStrategy
{
public:
    BrewmasterMonkStrategy(PlayerbotAI* botAI) : GenericMonkStrategy(botAI) {}

    void InitTriggers(std::vector<TriggerNode*>& triggers) override;
    NextAction** getDefaultActions() override;
    std::string const getName() override { return "tank"; }
    uint32 GetType() const override { return STRATEGY_TYPE_TANK | STRATEGY_TYPE_MELEE; }
};

class WindwalkerMonkStrategy : public GenericMonkStrategy
{
public:
    WindwalkerMonkStrategy(PlayerbotAI* botAI) : GenericMonkStrategy(botAI) {}

    void InitTriggers(std::vector<TriggerNode*>& triggers) override;
    NextAction** getDefaultActions() override;
    std::string const getName() override { return "dps"; }
    uint32 GetType() const override { return STRATEGY_TYPE_COMBAT | STRATEGY_TYPE_DPS | STRATEGY_TYPE_MELEE; }
};

class MistweaverMonkStrategy : public RangedCombatStrategy
{
public:
    MistweaverMonkStrategy(PlayerbotAI* botAI) : RangedCombatStrategy(botAI) {}

    void InitTriggers(std::vector<TriggerNode*>& triggers) override;
    NextAction** getDefaultActions() override;
    std::string const getName() override { return "heal"; }
    uint32 GetType() const override { return STRATEGY_TYPE_HEAL | STRATEGY_TYPE_RANGED; }
};

class MonkAoeStrategy : public CombatStrategy
{
public:
    MonkAoeStrategy(PlayerbotAI* botAI) : CombatStrategy(botAI) {}

    void InitTriggers(std::vector<TriggerNode*>& triggers) override;
    std::string const getName() override { return "aoe"; }
};

class MonkCureStrategy : public Strategy
{
public:
    MonkCureStrategy(PlayerbotAI* botAI) : Strategy(botAI) {}

    void InitTriggers(std::vector<TriggerNode*>& triggers) override;
    std::string const getName() override { return "cure"; }
};

class MonkNonCombatStrategy : public NonCombatStrategy
{
public:
    MonkNonCombatStrategy(PlayerbotAI* botAI) : NonCombatStrategy(botAI) {}

    void InitTriggers(std::vector<TriggerNode*>& triggers) override;
    std::string const getName() override { return "nc"; }
};

#endif
