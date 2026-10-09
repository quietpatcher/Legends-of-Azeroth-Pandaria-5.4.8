/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#ifndef _PLAYERBOT_HUNTERTRIGGERS_H
#define _PLAYERBOT_HUNTERTRIGGERS_H

#include "GenericTriggers.h"
#include "Trigger.h"

class PlayerbotAI;

// the port had no hunter triggers at all; "hunters pet dead" was used by the pet strategy but never
// existed, so 149 of 183 hunters kept casting Call Pet on a dead pet. Ported from mod-playerbots (7bae1b5).
class HuntersPetDeadTrigger : public Trigger
{
public:
    HuntersPetDeadTrigger(PlayerbotAI* botAI) : Trigger(botAI, "hunters pet dead", 5 * 1000) {}
    bool IsActive() override;
};

class HuntersPetLowHealthTrigger : public Trigger
{
public:
    HuntersPetLowHealthTrigger(PlayerbotAI* botAI) : Trigger(botAI, "hunters pet low health") {}
    bool IsActive() override;
};

class HuntersPetMediumHealthTrigger : public Trigger
{
public:
    HuntersPetMediumHealthTrigger(PlayerbotAI* botAI) : Trigger(botAI, "hunters pet medium health") {}
    bool IsActive() override;
};

#endif
