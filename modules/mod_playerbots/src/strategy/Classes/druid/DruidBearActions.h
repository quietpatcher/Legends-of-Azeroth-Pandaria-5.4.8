/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#ifndef _PLAYERBOT_DRUIDBEARACTIONS_H
#define _PLAYERBOT_DRUIDBEARACTIONS_H

#include "GenericSpellActions.h"
#include "ReachTargetActions.h"

class PlayerbotAI;

class CastFeralChargeBearAction : public CastReachTargetSpellAction
{
public:
    CastFeralChargeBearAction(PlayerbotAI* botAI) : CastReachTargetSpellAction(botAI, "feral charge - bear", 1.5f) {}
};

class CastGrowlAction : public CastSpellAction
{
public:
    CastGrowlAction(PlayerbotAI* botAI) : CastSpellAction(botAI, "growl") {}
};

class CastMaulAction : public CastMeleeSpellAction
{
public:
    CastMaulAction(PlayerbotAI* botAI) : CastMeleeSpellAction(botAI, "maul") {}

    bool isUseful() override;
};

class CastBashAction : public CastMeleeSpellAction
{
public:
    CastBashAction(PlayerbotAI* botAI) : CastMeleeSpellAction(botAI, "bash") {}
};

class CastSwipeAction : public CastMeleeSpellAction
{
public:
    CastSwipeAction(PlayerbotAI* botAI) : CastMeleeSpellAction(botAI, "swipe") {}
};

class CastDemoralizingRoarAction : public CastMeleeDebuffSpellAction
{
public:
    CastDemoralizingRoarAction(PlayerbotAI* botAI) : CastMeleeDebuffSpellAction(botAI, "demoralizing roar") {}
};

class CastMangleBearAction : public CastMeleeSpellAction
{
public:
    CastMangleBearAction(PlayerbotAI* botAI) : CastMeleeSpellAction(botAI, "mangle") {}
};

class CastSwipeBearAction : public CastMeleeSpellAction
{
public:
    CastSwipeBearAction(PlayerbotAI* botAI) : CastMeleeSpellAction(botAI, "swipe (bear)") {}
};

class CastLacerateAction : public CastMeleeSpellAction
{
public:
    CastLacerateAction(PlayerbotAI* botAI) : CastMeleeSpellAction(botAI, "lacerate") {}
};

// the bear's bleed with area threat, and its active mitigation
class CastThrashBearAction : public CastMeleeSpellAction
{
public:
    CastThrashBearAction(PlayerbotAI* botAI) : CastMeleeSpellAction(botAI, "thrash") {}
};

class CastSavageDefenseAction : public CastBuffSpellAction
{
public:
    CastSavageDefenseAction(PlayerbotAI* botAI) : CastBuffSpellAction(botAI, "savage defense") {}
};

class CastBashOnEnemyHealerAction : public CastSpellOnEnemyHealerAction
{
public:
    CastBashOnEnemyHealerAction(PlayerbotAI* botAI) : CastSpellOnEnemyHealerAction(botAI, "bash") {}
};

#endif
