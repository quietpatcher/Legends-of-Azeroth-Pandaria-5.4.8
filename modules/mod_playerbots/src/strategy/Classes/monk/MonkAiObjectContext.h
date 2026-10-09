/*
 * monk class AI (see MonkTriggers.h).
 */

#ifndef _PLAYERBOT_MONKAIOBJECTCONTEXT_H
#define _PLAYERBOT_MONKAIOBJECTCONTEXT_H

#include "AiObjectContext.h"

class PlayerbotAI;

class MonkAiObjectContext : public AiObjectContext
{
public:
    MonkAiObjectContext(PlayerbotAI* botAI);
};

#endif
