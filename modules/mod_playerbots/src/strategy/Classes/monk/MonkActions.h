/*
 * monk class AI (see MonkTriggers.h).
 */

#ifndef _PLAYERBOT_MONKACTIONS_H
#define _PLAYERBOT_MONKACTIONS_H

#include "AiObject.h"
#include "GenericSpellActions.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "SharedDefines.h"

class PlayerbotAI;

// spells cast on the monk itself that are not an aura of the same name (brews, teas)
class CastMonkSelfSpellAction : public CastSpellAction
{
public:
    CastMonkSelfSpellAction(PlayerbotAI* botAI, std::string const spell) : CastSpellAction(botAI, spell) {}

    std::string const GetTargetName() override { return "self target"; }
};

// -- stances / buffs
BUFF_ACTION(CastStanceOfTheSturdyOxAction, "stance of the sturdy ox");
BUFF_ACTION(CastStanceOfTheFierceTigerAction, "stance of the fierce tiger");
BUFF_ACTION(CastStanceOfTheWiseSerpentAction, "stance of the wise serpent");

class CastLegacyOfTheEmperorAction : public CastBuffSpellAction
{
public:
    CastLegacyOfTheEmperorAction(PlayerbotAI* botAI) : CastBuffSpellAction(botAI, "legacy of the emperor") {}

    bool isUseful() override;
};

// -- all specs
MELEE_ACTION(CastJabAction, "jab");
MELEE_ACTION(CastTigerPalmAction, "tiger palm");
MELEE_ACTION(CastBlackoutKickAction, "blackout kick");
MELEE_ACTION(CastTouchOfDeathAction, "touch of death");
MELEE_ACTION(CastSpearHandStrikeAction, "spear hand strike");
MELEE_ACTION(CastSpinningCraneKickAction, "spinning crane kick");
SPELL_ACTION(CastCracklingJadeLightningAction, "crackling jade lightning");
HEAL_ACTION(CastExpelHarmAction, "expel harm");
HEAL_ACTION(CastSurgingMistAction, "surging mist");
BUFF_ACTION(CastFortifyingBrewAction, "fortifying brew");
SPELL_ACTION_U(CastProvokeAction, "provoke", GetTarget() && GetTarget()->GetTarget() != bot->GetGUID());

// -- brewmaster
MELEE_ACTION(CastKegSmashAction, "keg smash");
MELEE_ACTION(CastBreathOfFireAction, "breath of fire");
BUFF_ACTION(CastGuardAction, "guard");

class CastPurifyingBrewAction : public CastMonkSelfSpellAction
{
public:
    CastPurifyingBrewAction(PlayerbotAI* botAI) : CastMonkSelfSpellAction(botAI, "purifying brew") {}
};

class CastElusiveBrewAction : public CastMonkSelfSpellAction
{
public:
    CastElusiveBrewAction(PlayerbotAI* botAI) : CastMonkSelfSpellAction(botAI, "elusive brew") {}
};

// -- windwalker
MELEE_ACTION(CastRisingSunKickAction, "rising sun kick");
MELEE_ACTION(CastFistsOfFuryAction, "fists of fury");
BUFF_ACTION(CastEnergizingBrewAction, "energizing brew");
SPELL_ACTION(CastTouchOfKarmaAction, "touch of karma");

class CastTigereyeBrewAction : public CastMonkSelfSpellAction
{
public:
    CastTigereyeBrewAction(PlayerbotAI* botAI) : CastMonkSelfSpellAction(botAI, "tigereye brew") {}
};

// -- mistweaver
HEAL_PARTY_ACTION(CastSurgingMistOnPartyAction, "surging mist", 25, HealingManaEfficiency::MEDIUM);
HEAL_PARTY_ACTION(CastEnvelopingMistOnPartyAction, "enveloping mist", 20, HealingManaEfficiency::HIGH);
HEAL_PARTY_ACTION(CastRenewingMistOnPartyAction, "renewing mist", 10, HealingManaEfficiency::VERY_HIGH);
HEAL_PARTY_ACTION(CastSoothingMistOnPartyAction, "soothing mist", 15, HealingManaEfficiency::HIGH);
HEAL_PARTY_ACTION(CastLifeCocoonOnPartyAction, "life cocoon", 40, HealingManaEfficiency::SUPERIOR);
RESS_ACTION(CastResuscitateAction, "resuscitate");

class CastUpliftAction : public CastMonkSelfSpellAction
{
public:
    CastUpliftAction(PlayerbotAI* botAI) : CastMonkSelfSpellAction(botAI, "uplift") {}

    bool isUseful() override;
};

class CastRevivalAction : public CastMonkSelfSpellAction
{
public:
    CastRevivalAction(PlayerbotAI* botAI) : CastMonkSelfSpellAction(botAI, "revival") {}
};

class CastManaTeaAction : public CastMonkSelfSpellAction
{
public:
    CastManaTeaAction(PlayerbotAI* botAI) : CastMonkSelfSpellAction(botAI, "mana tea") {}
};

// -- cure
CURE_ACTION(CastDetoxAction, "detox");

class CastDetoxPoisonOnPartyAction : public CurePartyMemberAction
{
public:
    CastDetoxPoisonOnPartyAction(PlayerbotAI* botAI) : CurePartyMemberAction(botAI, "detox", DISPEL_POISON) {}

    std::string const getName() override { return "detox poison on party"; }
};

class CastDetoxDiseaseOnPartyAction : public CurePartyMemberAction
{
public:
    CastDetoxDiseaseOnPartyAction(PlayerbotAI* botAI) : CurePartyMemberAction(botAI, "detox", DISPEL_DISEASE) {}

    std::string const getName() override { return "detox disease on party"; }
};

#endif
