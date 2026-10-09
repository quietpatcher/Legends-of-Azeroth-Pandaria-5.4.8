/*
 * monk class AI. The LoA MoP playerbots port shipped without any monk strategies, so monk bots
 * (brewmaster tanks, mistweaver healers, windwalkers) had no abilities in combat at all.
 */

#ifndef _PLAYERBOT_MONKTRIGGERS_H
#define _PLAYERBOT_MONKTRIGGERS_H

#include "CureTriggers.h"
#include "GenericTriggers.h"
#include "SharedDefines.h"

class PlayerbotAI;

// -- stances / buffs
BUFF_TRIGGER(StanceOfTheSturdyOxTrigger, "stance of the sturdy ox");
BUFF_TRIGGER(StanceOfTheFierceTigerTrigger, "stance of the fierce tiger");
BUFF_TRIGGER(StanceOfTheWiseSerpentTrigger, "stance of the wise serpent");

class LegacyOfTheEmperorTrigger : public BuffTrigger
{
public:
    LegacyOfTheEmperorTrigger(PlayerbotAI* botAI) : BuffTrigger(botAI, "legacy of the emperor", 5) {}
    bool IsActive() override;
};

// -- self buffs refreshed by an ability
class TigerPowerTrigger : public Trigger
{
public:
    TigerPowerTrigger(PlayerbotAI* botAI) : Trigger(botAI, "tiger power") {}
    bool IsActive() override;
};

class ShuffleTrigger : public Trigger
{
public:
    ShuffleTrigger(PlayerbotAI* botAI) : Trigger(botAI, "shuffle") {}
    bool IsActive() override;
};

class HeavyStaggerTrigger : public Trigger
{
public:
    HeavyStaggerTrigger(PlayerbotAI* botAI) : Trigger(botAI, "heavy stagger") {}
    bool IsActive() override;
};

// stacking brews: only worth it with enough stacks and when the effect is not already running
class BrewStacksTrigger : public Trigger
{
public:
    BrewStacksTrigger(PlayerbotAI* botAI, std::string const name, uint32 stackAura, uint32 activeAura, uint8 minStacks)
        : Trigger(botAI, name), stackAura(stackAura), activeAura(activeAura), minStacks(minStacks) {}
    bool IsActive() override;

protected:
    uint32 stackAura;
    uint32 activeAura;
    uint8 minStacks;
};

class ElusiveBrewTrigger : public BrewStacksTrigger
{
public:
    ElusiveBrewTrigger(PlayerbotAI* botAI) : BrewStacksTrigger(botAI, "elusive brew", 128939, 115308, 8) {}
    bool IsActive() override;
};

class TigereyeBrewTrigger : public BrewStacksTrigger
{
public:
    TigereyeBrewTrigger(PlayerbotAI* botAI) : BrewStacksTrigger(botAI, "tigereye brew", 125195, 116740, 10) {}
};

class ManaTeaTrigger : public BrewStacksTrigger
{
public:
    ManaTeaTrigger(PlayerbotAI* botAI) : BrewStacksTrigger(botAI, "mana tea", 115867, 115294, 2) {}
    bool IsActive() override;
};

class EnergizingBrewTrigger : public Trigger
{
public:
    EnergizingBrewTrigger(PlayerbotAI* botAI) : Trigger(botAI, "energizing brew") {}
    bool IsActive() override;
};

// -- procs / debuffs
HAS_AURA_TRIGGER(ComboBreakerBlackoutKickTrigger, "combo breaker: blackout kick");
HAS_AURA_TRIGGER(ComboBreakerTigerPalmTrigger, "combo breaker: tiger palm");
DEBUFF_TRIGGER(RisingSunKickTrigger, "rising sun kick");
CAN_CAST_TRIGGER(TouchOfDeathTrigger, "touch of death");
INTERRUPT_TRIGGER(SpearHandStrikeInterruptTrigger, "spear hand strike");

// -- mistweaver: several group members hurt at once
class MonkGroupHealTrigger : public Trigger
{
public:
    MonkGroupHealTrigger(PlayerbotAI* botAI, std::string const name, uint8 healthPct, uint32 count)
        : Trigger(botAI, name, 2), healthPct(healthPct), count(count) {}
    bool IsActive() override;

protected:
    uint8 healthPct;
    uint32 count;
};

// -- cure
CURE_TRIGGER(DetoxPoisonTrigger, "detox", DISPEL_POISON);
CURE_TRIGGER(DetoxDiseaseTrigger, "detox", DISPEL_DISEASE);
CURE_PARTY_TRIGGER(DetoxPoisonOnPartyTrigger, "detox", DISPEL_POISON);
CURE_PARTY_TRIGGER(DetoxDiseaseOnPartyTrigger, "detox", DISPEL_DISEASE);

#endif
