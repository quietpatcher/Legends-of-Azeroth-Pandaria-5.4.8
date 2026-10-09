/*
 * monk class AI (see MonkTriggers.h).
 */

#include "MonkAiObjectContext.h"

#include "HealthTriggers.h"
#include "MonkActions.h"
#include "MonkStrategies.h"
#include "MonkTriggers.h"
#include "NamedObjectContext.h"
#include "GenericTriggers.h"
#include "Playerbots.h"

class MonkStrategyFactoryInternal : public NamedObjectContext<Strategy>
{
public:
    MonkStrategyFactoryInternal()
    {
        creators["nc"] = &MonkStrategyFactoryInternal::nc;
        creators["aoe"] = &MonkStrategyFactoryInternal::aoe;
        creators["cure"] = &MonkStrategyFactoryInternal::cure;
    }

private:
    static Strategy* nc(PlayerbotAI* botAI) { return new MonkNonCombatStrategy(botAI); }
    static Strategy* aoe(PlayerbotAI* botAI) { return new MonkAoeStrategy(botAI); }
    static Strategy* cure(PlayerbotAI* botAI) { return new MonkCureStrategy(botAI); }
};

class MonkCombatStrategyFactoryInternal : public NamedObjectContext<Strategy>
{
public:
    MonkCombatStrategyFactoryInternal() : NamedObjectContext<Strategy>(false, true)
    {
        creators["tank"] = &MonkCombatStrategyFactoryInternal::tank;
        creators["dps"] = &MonkCombatStrategyFactoryInternal::dps;
        creators["heal"] = &MonkCombatStrategyFactoryInternal::heal;
    }

private:
    static Strategy* tank(PlayerbotAI* botAI) { return new BrewmasterMonkStrategy(botAI); }
    static Strategy* dps(PlayerbotAI* botAI) { return new WindwalkerMonkStrategy(botAI); }
    static Strategy* heal(PlayerbotAI* botAI) { return new MistweaverMonkStrategy(botAI); }
};

class MonkTriggerFactoryInternal : public NamedObjectContext<Trigger>
{
public:
    MonkTriggerFactoryInternal()
    {
        creators["stance of the sturdy ox"] = &MonkTriggerFactoryInternal::stance_of_the_sturdy_ox;
        creators["stance of the fierce tiger"] = &MonkTriggerFactoryInternal::stance_of_the_fierce_tiger;
        creators["stance of the wise serpent"] = &MonkTriggerFactoryInternal::stance_of_the_wise_serpent;
        creators["legacy of the emperor"] = &MonkTriggerFactoryInternal::legacy_of_the_emperor;

        creators["tiger power"] = &MonkTriggerFactoryInternal::tiger_power;
        creators["shuffle"] = &MonkTriggerFactoryInternal::shuffle;
        creators["heavy stagger"] = &MonkTriggerFactoryInternal::heavy_stagger;
        creators["elusive brew"] = &MonkTriggerFactoryInternal::elusive_brew;
        creators["tigereye brew"] = &MonkTriggerFactoryInternal::tigereye_brew;
        creators["energizing brew"] = &MonkTriggerFactoryInternal::energizing_brew;
        creators["mana tea"] = &MonkTriggerFactoryInternal::mana_tea;

        creators["combo breaker: blackout kick"] = &MonkTriggerFactoryInternal::combo_breaker_blackout_kick;
        creators["combo breaker: tiger palm"] = &MonkTriggerFactoryInternal::combo_breaker_tiger_palm;
        creators["rising sun kick"] = &MonkTriggerFactoryInternal::rising_sun_kick;
        creators["touch of death"] = &MonkTriggerFactoryInternal::touch_of_death;
        creators["spear hand strike"] = &MonkTriggerFactoryInternal::spear_hand_strike;

        creators["monk group heal"] = &MonkTriggerFactoryInternal::monk_group_heal;
        creators["monk group heal critical"] = &MonkTriggerFactoryInternal::monk_group_heal_critical;
        creators["party member dead"] = &MonkTriggerFactoryInternal::party_member_dead;

        creators["detox poison"] = &MonkTriggerFactoryInternal::detox_poison;
        creators["detox disease"] = &MonkTriggerFactoryInternal::detox_disease;
        creators["detox poison on party"] = &MonkTriggerFactoryInternal::detox_poison_on_party;
        creators["detox disease on party"] = &MonkTriggerFactoryInternal::detox_disease_on_party;
    }

private:
    static Trigger* stance_of_the_sturdy_ox(PlayerbotAI* botAI) { return new StanceOfTheSturdyOxTrigger(botAI); }
    static Trigger* stance_of_the_fierce_tiger(PlayerbotAI* botAI) { return new StanceOfTheFierceTigerTrigger(botAI); }
    static Trigger* stance_of_the_wise_serpent(PlayerbotAI* botAI) { return new StanceOfTheWiseSerpentTrigger(botAI); }
    static Trigger* legacy_of_the_emperor(PlayerbotAI* botAI) { return new LegacyOfTheEmperorTrigger(botAI); }

    static Trigger* tiger_power(PlayerbotAI* botAI) { return new TigerPowerTrigger(botAI); }
    static Trigger* shuffle(PlayerbotAI* botAI) { return new ShuffleTrigger(botAI); }
    static Trigger* heavy_stagger(PlayerbotAI* botAI) { return new HeavyStaggerTrigger(botAI); }
    static Trigger* elusive_brew(PlayerbotAI* botAI) { return new ElusiveBrewTrigger(botAI); }
    static Trigger* tigereye_brew(PlayerbotAI* botAI) { return new TigereyeBrewTrigger(botAI); }
    static Trigger* energizing_brew(PlayerbotAI* botAI) { return new EnergizingBrewTrigger(botAI); }
    static Trigger* mana_tea(PlayerbotAI* botAI) { return new ManaTeaTrigger(botAI); }

    static Trigger* combo_breaker_blackout_kick(PlayerbotAI* botAI) { return new ComboBreakerBlackoutKickTrigger(botAI); }
    static Trigger* combo_breaker_tiger_palm(PlayerbotAI* botAI) { return new ComboBreakerTigerPalmTrigger(botAI); }
    static Trigger* rising_sun_kick(PlayerbotAI* botAI) { return new RisingSunKickTrigger(botAI); }
    static Trigger* touch_of_death(PlayerbotAI* botAI) { return new TouchOfDeathTrigger(botAI); }
    static Trigger* spear_hand_strike(PlayerbotAI* botAI) { return new SpearHandStrikeInterruptTrigger(botAI); }

    static Trigger* monk_group_heal(PlayerbotAI* botAI) { return new MonkGroupHealTrigger(botAI, "monk group heal", 70, 3); }
    static Trigger* monk_group_heal_critical(PlayerbotAI* botAI) { return new MonkGroupHealTrigger(botAI, "monk group heal critical", 40, 3); }
    static Trigger* party_member_dead(PlayerbotAI* botAI) { return new PartyMemberDeadTrigger(botAI); }

    static Trigger* detox_poison(PlayerbotAI* botAI) { return new DetoxPoisonTrigger(botAI); }
    static Trigger* detox_disease(PlayerbotAI* botAI) { return new DetoxDiseaseTrigger(botAI); }
    static Trigger* detox_poison_on_party(PlayerbotAI* botAI) { return new DetoxPoisonOnPartyTrigger(botAI); }
    static Trigger* detox_disease_on_party(PlayerbotAI* botAI) { return new DetoxDiseaseOnPartyTrigger(botAI); }
};

class MonkAiObjectContextInternal : public NamedObjectContext<Action>
{
public:
    MonkAiObjectContextInternal()
    {
        creators["stance of the sturdy ox"] = &MonkAiObjectContextInternal::stance_of_the_sturdy_ox;
        creators["stance of the fierce tiger"] = &MonkAiObjectContextInternal::stance_of_the_fierce_tiger;
        creators["stance of the wise serpent"] = &MonkAiObjectContextInternal::stance_of_the_wise_serpent;
        creators["legacy of the emperor"] = &MonkAiObjectContextInternal::legacy_of_the_emperor;

        creators["jab"] = &MonkAiObjectContextInternal::jab;
        creators["tiger palm"] = &MonkAiObjectContextInternal::tiger_palm;
        creators["blackout kick"] = &MonkAiObjectContextInternal::blackout_kick;
        creators["touch of death"] = &MonkAiObjectContextInternal::touch_of_death;
        creators["spear hand strike"] = &MonkAiObjectContextInternal::spear_hand_strike;
        creators["spinning crane kick"] = &MonkAiObjectContextInternal::spinning_crane_kick;
        creators["crackling jade lightning"] = &MonkAiObjectContextInternal::crackling_jade_lightning;
        creators["expel harm"] = &MonkAiObjectContextInternal::expel_harm;
        creators["surging mist"] = &MonkAiObjectContextInternal::surging_mist;
        creators["fortifying brew"] = &MonkAiObjectContextInternal::fortifying_brew;
        creators["provoke"] = &MonkAiObjectContextInternal::provoke;

        creators["keg smash"] = &MonkAiObjectContextInternal::keg_smash;
        creators["breath of fire"] = &MonkAiObjectContextInternal::breath_of_fire;
        creators["guard"] = &MonkAiObjectContextInternal::guard;
        creators["purifying brew"] = &MonkAiObjectContextInternal::purifying_brew;
        creators["elusive brew"] = &MonkAiObjectContextInternal::elusive_brew;

        creators["rising sun kick"] = &MonkAiObjectContextInternal::rising_sun_kick;
        creators["fists of fury"] = &MonkAiObjectContextInternal::fists_of_fury;
        creators["tigereye brew"] = &MonkAiObjectContextInternal::tigereye_brew;
        creators["energizing brew"] = &MonkAiObjectContextInternal::energizing_brew;
        creators["touch of karma"] = &MonkAiObjectContextInternal::touch_of_karma;

        creators["surging mist on party"] = &MonkAiObjectContextInternal::surging_mist_on_party;
        creators["enveloping mist on party"] = &MonkAiObjectContextInternal::enveloping_mist_on_party;
        creators["renewing mist on party"] = &MonkAiObjectContextInternal::renewing_mist_on_party;
        creators["soothing mist on party"] = &MonkAiObjectContextInternal::soothing_mist_on_party;
        creators["life cocoon on party"] = &MonkAiObjectContextInternal::life_cocoon_on_party;
        creators["uplift"] = &MonkAiObjectContextInternal::uplift;
        creators["revival"] = &MonkAiObjectContextInternal::revival;
        creators["mana tea"] = &MonkAiObjectContextInternal::mana_tea;
        creators["resuscitate"] = &MonkAiObjectContextInternal::resuscitate;

        creators["detox"] = &MonkAiObjectContextInternal::detox;
        creators["detox poison on party"] = &MonkAiObjectContextInternal::detox_poison_on_party;
        creators["detox disease on party"] = &MonkAiObjectContextInternal::detox_disease_on_party;
    }

private:
    static Action* stance_of_the_sturdy_ox(PlayerbotAI* botAI) { return new CastStanceOfTheSturdyOxAction(botAI); }
    static Action* stance_of_the_fierce_tiger(PlayerbotAI* botAI) { return new CastStanceOfTheFierceTigerAction(botAI); }
    static Action* stance_of_the_wise_serpent(PlayerbotAI* botAI) { return new CastStanceOfTheWiseSerpentAction(botAI); }
    static Action* legacy_of_the_emperor(PlayerbotAI* botAI) { return new CastLegacyOfTheEmperorAction(botAI); }

    static Action* jab(PlayerbotAI* botAI) { return new CastJabAction(botAI); }
    static Action* tiger_palm(PlayerbotAI* botAI) { return new CastTigerPalmAction(botAI); }
    static Action* blackout_kick(PlayerbotAI* botAI) { return new CastBlackoutKickAction(botAI); }
    static Action* touch_of_death(PlayerbotAI* botAI) { return new CastTouchOfDeathAction(botAI); }
    static Action* spear_hand_strike(PlayerbotAI* botAI) { return new CastSpearHandStrikeAction(botAI); }
    static Action* spinning_crane_kick(PlayerbotAI* botAI) { return new CastSpinningCraneKickAction(botAI); }
    static Action* crackling_jade_lightning(PlayerbotAI* botAI) { return new CastCracklingJadeLightningAction(botAI); }
    static Action* expel_harm(PlayerbotAI* botAI) { return new CastExpelHarmAction(botAI); }
    static Action* surging_mist(PlayerbotAI* botAI) { return new CastSurgingMistAction(botAI); }
    static Action* fortifying_brew(PlayerbotAI* botAI) { return new CastFortifyingBrewAction(botAI); }
    static Action* provoke(PlayerbotAI* botAI) { return new CastProvokeAction(botAI); }

    static Action* keg_smash(PlayerbotAI* botAI) { return new CastKegSmashAction(botAI); }
    static Action* breath_of_fire(PlayerbotAI* botAI) { return new CastBreathOfFireAction(botAI); }
    static Action* guard(PlayerbotAI* botAI) { return new CastGuardAction(botAI); }
    static Action* purifying_brew(PlayerbotAI* botAI) { return new CastPurifyingBrewAction(botAI); }
    static Action* elusive_brew(PlayerbotAI* botAI) { return new CastElusiveBrewAction(botAI); }

    static Action* rising_sun_kick(PlayerbotAI* botAI) { return new CastRisingSunKickAction(botAI); }
    static Action* fists_of_fury(PlayerbotAI* botAI) { return new CastFistsOfFuryAction(botAI); }
    static Action* tigereye_brew(PlayerbotAI* botAI) { return new CastTigereyeBrewAction(botAI); }
    static Action* energizing_brew(PlayerbotAI* botAI) { return new CastEnergizingBrewAction(botAI); }
    static Action* touch_of_karma(PlayerbotAI* botAI) { return new CastTouchOfKarmaAction(botAI); }

    static Action* surging_mist_on_party(PlayerbotAI* botAI) { return new CastSurgingMistOnPartyAction(botAI); }
    static Action* enveloping_mist_on_party(PlayerbotAI* botAI) { return new CastEnvelopingMistOnPartyAction(botAI); }
    static Action* renewing_mist_on_party(PlayerbotAI* botAI) { return new CastRenewingMistOnPartyAction(botAI); }
    static Action* soothing_mist_on_party(PlayerbotAI* botAI) { return new CastSoothingMistOnPartyAction(botAI); }
    static Action* life_cocoon_on_party(PlayerbotAI* botAI) { return new CastLifeCocoonOnPartyAction(botAI); }
    static Action* uplift(PlayerbotAI* botAI) { return new CastUpliftAction(botAI); }
    static Action* revival(PlayerbotAI* botAI) { return new CastRevivalAction(botAI); }
    static Action* mana_tea(PlayerbotAI* botAI) { return new CastManaTeaAction(botAI); }
    static Action* resuscitate(PlayerbotAI* botAI) { return new CastResuscitateAction(botAI); }

    static Action* detox(PlayerbotAI* botAI) { return new CastDetoxAction(botAI); }
    static Action* detox_poison_on_party(PlayerbotAI* botAI) { return new CastDetoxPoisonOnPartyAction(botAI); }
    static Action* detox_disease_on_party(PlayerbotAI* botAI) { return new CastDetoxDiseaseOnPartyAction(botAI); }
};

MonkAiObjectContext::MonkAiObjectContext(PlayerbotAI* botAI) : AiObjectContext(botAI)
{
    strategyContexts.Add(new MonkStrategyFactoryInternal());
    strategyContexts.Add(new MonkCombatStrategyFactoryInternal());
    actionContexts.Add(new MonkAiObjectContextInternal());
    triggerContexts.Add(new MonkTriggerFactoryInternal());
}
