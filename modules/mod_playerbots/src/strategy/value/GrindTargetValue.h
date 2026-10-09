#ifndef _PLAYERBOT_GRINDTARGETVALUE_H
#define _PLAYERBOT_GRINDTARGETVALUE_H

#include "TargetValue.h"

class PlayerbotAI;
class Unit;

class GrindTargetValue : public TargetValue
{
public:
    GrindTargetValue(PlayerbotAI* botAI, std::string const name = "grind target") : TargetValue(botAI, name) {}

    Unit* Calculate() override;
    Unit* Get() override;   // 1 s cache (was recalculated on every Get: 23% of all bot AI time)

private:
    ObjectGuid _cachedGuid;
    uint32 _cachedAt = 0;
    uint32 GetTargetingPlayerCount(Unit* unit);
    Unit* FindTargetForGrinding(uint32 assistCount);
    bool needForQuest(Unit* target);
};

#endif
