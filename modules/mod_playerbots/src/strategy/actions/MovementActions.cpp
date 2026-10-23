/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#include "MovementActions.h"

#include <cmath>
#include <cstdlib>
#include <iomanip>
#include <string>
#include <algorithm>

#include "Event.h"
#include "PositionValue.h"
#include "G3D/Vector3.h"
#include "GameObject.h"
#include "LastMovementValue.h"
#include "Map.h"
#include "MotionMaster.h"
#include "MoveSplineInitArgs.h"
#include "MoveSpline.h"
#include "MovementGenerator.h"
#include "ObjectDefines.h"
#include "ObjectGuid.h"
#include "PathGenerator.h"
#include "PlayerbotAI.h"
#include "PlayerbotAIConfig.h"
#include "Playerbots.h"
#include "PlayerbotSpec.h"
#include "Position.h"

#include "Random.h"
#include "ServerFacade.h"
#include "SharedDefines.h"
#include "SpellAuraEffects.h"
#include "CellImpl.h"
#include "DynamicObject.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "SpellAuras.h"
#include "SpellMgr.h"
#include "SpellInfo.h"

#include "Timer.h"
#include "Transport.h"
#include "Unit.h"
#include "Vehicle.h"
#include "WaypointMovementGenerator.h"
#include "Corpse.h"

MovementAction::MovementAction(PlayerbotAI* botAI, std::string const name) : Action(botAI, name)
{
    bot = botAI->GetBot();
}

void MovementAction::ClearIdleState()
{
    context->GetValue<time_t>("stay time")->Set(0);
    context->GetValue<PositionMap&>("position")->Get()["random"].Reset();
}

void MovementAction::WaitForReach(float distance)
{
    float delay = 1000.0f * MoveDelay(distance);

    if (delay > sPlayerbotAIConfig->maxWaitForMove)
        delay = sPlayerbotAIConfig->maxWaitForMove;

    Unit* target = *botAI->GetAiObjectContext()->GetValue<Unit*>("current target");
    Unit* player = *botAI->GetAiObjectContext()->GetValue<Unit*>("enemy player target");
    if ((player || target) && delay > sPlayerbotAIConfig->globalCoolDown)
        delay = sPlayerbotAIConfig->globalCoolDown;

    if (delay < 0)
        delay = 0;

    botAI->SetNextCheckDelay((uint32)delay);
}

void MovementAction::UpdateMovementState()
{
    auto botInLiquidState = bot->GetLiquidStatus();

    if ((botInLiquidState & LIQUID_MAP_IN_WATER) || (botInLiquidState & LIQUID_MAP_UNDER_WATER))
    {
        bot->SetSwim(true);
    }
    else
    {
        bot->SetSwim(false);
    }

    bool onGround = bot->GetPositionZ() < bot->GetMapWaterOrGroundLevel(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ()) + 1.0f;

    // Keep bot->SendMovementFlagUpdate() withing the if statements to not intefere with bot behavior on ground/(shallow) waters
    if (!bot->HasUnitMovementFlag(MOVEMENTFLAG_FLYING) &&
        bot->HasAuraType(SPELL_AURA_MOD_INCREASE_MOUNTED_FLIGHT_SPEED) && !onGround)
    {
        bot->AddUnitMovementFlag(MOVEMENTFLAG_FLYING);
        bot->SendMovementFlagUpdate();
    }

    else if (bot->HasUnitMovementFlag(MOVEMENTFLAG_FLYING) &&
        (!bot->HasAuraType(SPELL_AURA_MOD_INCREASE_MOUNTED_FLIGHT_SPEED) || onGround))
    {
        bot->RemoveUnitMovementFlag(MOVEMENTFLAG_FLYING);
        bot->SendMovementFlagUpdate();
    }
}

bool MovementAction::ChaseTo(WorldObject* obj, float distance, float angle)
{
    if (!IsMovingAllowed())
    {
        return false;
    }

    // never chase an object of another map (follower set of the target, other map thread)
    if (!obj || !obj->IsInWorld() || bot->FindMap() != obj->FindMap())
        return false;

    if (Vehicle* vehicle = bot->GetVehicle())
    {
        VehicleSeatEntry const* seat = vehicle->GetSeatForPassenger(bot);
        if (!seat || !seat->CanControl())
            return false;

        // vehicle->GetMotionMaster()->Clear();
        vehicle->GetBase()->GetMotionMaster()->MoveChase((Unit*)obj, 30.0f);
        return true;
    }

    UpdateMovementState();

    if (!bot->IsStandState())
        bot->SetStandState(UNIT_STAND_STATE_STAND);

    if (bot->IsNonMeleeSpellCasted(true))
    {
        bot->CastStop();
        botAI->InterruptSpell();
    }

    bot->GetMotionMaster()->MoveChase((Unit*)obj, distance);

    // TODO shouldnt this use "last movement" value?
    WaitForReach(bot->GetExactDist2d(obj) - distance);
    return true;
}

bool MovementAction::ReachCombatTo(Unit* target, float distance)
{
    if (!IsMovingAllowed(target))
        return false;

    float bx = bot->GetPositionX();
    float by = bot->GetPositionY();
    float bz = bot->GetPositionZ();

    float tx = target->GetPositionX();
    float ty = target->GetPositionY();
    float tz = target->GetPositionZ();
    float combatDistance = bot->GetCombatReach() + target->GetCombatReach();
    distance += combatDistance;

    if (bot->GetExactDist(tx, ty, tz) <= distance)
        return false;

    PathGenerator path(bot);
    path.CalculatePath(tx, ty, tz, false);
    PathType type = path.GetPathType();
    int typeOk = PATHFIND_NORMAL | PATHFIND_INCOMPLETE | PATHFIND_SHORTCUT;
    if (!(type & typeOk))
        return false;
    float shortenTo = distance;

    // Avoid walking too far when moving towards each other
    float disToGo = bot->GetExactDist(tx, ty, tz) - distance;
    if (disToGo >= 10.0f)
        shortenTo = disToGo / 2 + distance;

    path.ShortenPathUntilDist(G3D::Vector3(tx, ty, tz), shortenTo);
    G3D::Vector3 endPos = path.GetPath().back();
    return MoveTo(target->GetMapId(), endPos.x, endPos.y, endPos.z, false, false, false, false,
        MovementPriority::MOVEMENT_COMBAT, true);
}

bool MovementAction::IsDuplicateMove(uint32 mapId, float x, float y, float z)
{
    LastMovement& lastMove = *context->GetValue<LastMovement&>("last movement");

    // heuristic 5s
    if (lastMove.msTime + sPlayerbotAIConfig->maxWaitForMove < getMSTime() ||
        lastMove.lastMoveShort.GetExactDist(x, y, z) > 0.01f)
        return false;

    return true;
}

bool MovementAction::IsWaitingForLastMove(MovementPriority priority)
{
    LastMovement& lastMove = *context->GetValue<LastMovement&>("last movement");

    if (priority > lastMove.priority)
        return false;

    // heuristic 5s
    if (lastMove.lastdelayTime + lastMove.msTime > getMSTime())
        return true;

    return false;
}

float MovementAction::MoveDelay(float distance, bool backwards)
{
    float speed;
    if (bot->isSwimming())
    {
        speed = backwards ? bot->GetSpeed(MOVE_SWIM_BACK) : bot->GetSpeed(MOVE_SWIM);
    }
    else if (bot->IsFlying())
    {
        speed = backwards ? bot->GetSpeed(MOVE_FLIGHT_BACK) : bot->GetSpeed(MOVE_FLIGHT);
    }
    else
    {
        speed = backwards ? bot->GetSpeed(MOVE_RUN_BACK) : bot->GetSpeed(MOVE_RUN);
    }
    float delay = distance / speed;
    return delay;
}

bool MovementAction::MoveTo(WorldObject* target, float distance, MovementPriority priority)
{
    if (!IsMovingAllowed(target))
        return false;

    float bx = bot->GetPositionX();
    float by = bot->GetPositionY();
    float bz = bot->GetPositionZ();

    float tx = target->GetPositionX();
    float ty = target->GetPositionY();
    float tz = target->GetPositionZ();

    float distanceToTarget = bot->GetDistance(target);
    float angle = bot->GetAngle(target);
    float needToGo = distanceToTarget - distance;

    float maxDistance = sPlayerbotAIConfig->spellDistance;
    if (needToGo > 0 && needToGo > maxDistance)
        needToGo = maxDistance;
    else if (needToGo < 0 && needToGo < -maxDistance)
        needToGo = -maxDistance;

    float dx = cos(angle) * needToGo + bx;
    float dy = sin(angle) * needToGo + by;
    float dz;  // = std::max(bz, tz); // calc accurate z position to avoid stuck
    if (distanceToTarget > CONTACT_DISTANCE)
    {
        dz = bz + (tz - bz) * (needToGo / distanceToTarget);
    }
    else
    {
        dz = tz;
    }
    return MoveTo(target->GetMapId(), dx, dy, dz, false, false, false, false, priority);
}

bool MovementAction::MoveTo(uint32 mapId, float x, float y, float z, bool idle, bool react, bool normal_only,
    bool exact_waypoint, MovementPriority priority, bool lessDelay, bool backwards)
{
    UpdateMovementState();
    if (!IsMovingAllowed(mapId, x, y, z))
    {
        return false;
    }
    if (IsDuplicateMove(mapId, x, y, z))
    {
        return false;
    }
    if (IsWaitingForLastMove(priority))
    {
        return false;
    }
    bool generatePath = !bot->IsFlying() && !bot->IsUnderWater() && !bot->IsInWater();
    bool disableMoveSplinePath = sPlayerbotAIConfig->disableMoveSplinePath >= 2 ||
        (sPlayerbotAIConfig->disableMoveSplinePath == 1 && bot->InBattleground());
    if (Vehicle* vehicle = bot->GetVehicle())
    {
        VehicleSeatEntry const* seat = vehicle->GetSeatForPassenger(bot);
        Unit* vehicleBase = vehicle->GetBase();
        generatePath = vehicleBase->CanFly();
        if (!vehicleBase || !seat || !seat->CanControl())  // is passenger and cant move anyway
            return false;

        float distance = vehicleBase->GetExactDist(x, y, z);  // use vehicle distance, not bot
        if (distance > 0.01f)
        {
            MotionMaster& mm = *vehicleBase->GetMotionMaster();  // need to move vehicle, not bot
            mm.Clear();
            if (!backwards)
            {
                mm.MovePoint(0, x, y, z, generatePath);
            }
            else
            {
                mm.MovePointBackwards(0, x, y, z, generatePath);
            }
            float speed = backwards ? vehicleBase->GetSpeed(MOVE_RUN_BACK) : vehicleBase->GetSpeed(MOVE_RUN);
            float delay = 1000.0f * (distance / speed);
            if (lessDelay)
            {
                delay -= botAI->GetReactDelay();
            }
            delay = std::max(.0f, delay);
            delay = std::min((float)sPlayerbotAIConfig->maxWaitForMove, delay);
            AI_VALUE(LastMovement&, "last movement").Set(mapId, x, y, z, bot->GetOrientation(), delay, priority);
            return true;
        }
    }
    else if (exact_waypoint || disableMoveSplinePath || !generatePath)
    {
        float distance = bot->GetExactDist(x, y, z);
        if (distance > 0.01f)
        {
            if (bot->IsSitState())
                bot->SetStandState(UNIT_STAND_STATE_STAND);

            MotionMaster& mm = *bot->GetMotionMaster();
            mm.Clear();
            if (!backwards)
            {
                mm.MovePoint(0, x, y, z, generatePath);
            }
            else
            {
                mm.MovePointBackwards(0, x, y, z, generatePath);
            }
            float delay = 1000.0f * MoveDelay(distance, backwards);
            if (lessDelay)
            {
                delay -= botAI->GetReactDelay();
            }
            delay = std::max(.0f, delay);
            delay = std::min((float)sPlayerbotAIConfig->maxWaitForMove, delay);
            AI_VALUE(LastMovement&, "last movement").Set(mapId, x, y, z, bot->GetOrientation(), delay, priority);
            return true;
        }
    }
    else
    {
        float modifiedZ;
        Movement::PointsArray path = SearchForBestPath(x, y, z, modifiedZ, sPlayerbotAIConfig->maxMovementSearchTime, normal_only);
        if (modifiedZ == INVALID_HEIGHT)
        {
            return false;
        }
        float distance = bot->GetExactDist(x, y, modifiedZ);
        if (distance > 0.01f)
        {
            if (bot->IsSitState())
                bot->SetStandState(UNIT_STAND_STATE_STAND);

            MotionMaster& mm = *bot->GetMotionMaster();
            G3D::Vector3 endP = path.back();
            mm.Clear();
            if (!backwards)
            {
                mm.MovePoint(0, x, y, z, generatePath);
            }
            else
            {
                mm.MovePointBackwards(0, x, y, z, generatePath);
            }
             float delay = 1000.0f * MoveDelay(distance, backwards);
            if (lessDelay)
            {
                delay -= botAI->GetReactDelay();
            }
            delay = std::max(.0f, delay);
            delay = std::min((float)sPlayerbotAIConfig->maxWaitForMove, delay);
            AI_VALUE(LastMovement&, "last movement").Set(mapId, x, y, z, bot->GetOrientation(), delay, priority);
            return true;
        }
    }
    return false;
}

bool MoveRandomAction::Execute(Event event)
{
    float distance = sPlayerbotAIConfig->tooCloseDistance + urand(10, 30);
    const float x = bot->GetPositionX();
    const float y = bot->GetPositionY();
    const float z = bot->GetPositionZ();
    int attempts = 5;
    Map* map = bot->GetMap();
    while (--attempts)
    {
        float angle = (float)rand_norm() * 2 * static_cast<float>(M_PI);
        float dx = x + distance * cos(angle);
        float dy = y + distance * sin(angle);
        float dz = z;
        if (!map->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(),
            dx, dy, dz))
            continue;

        if (map->IsInWater(bot->GetPhaseMask(), dx, dy, dz))
            continue;

        bool moved = MoveTo(bot->GetMapId(), dx, dy, dz, false, false, false, true);
        if (moved)
            return true;
    }

    return false;
}

bool MovementAction::MoveNear(uint32 mapId, float x, float y, float z, float distance, MovementPriority priority)
{
    float angle = GetFollowAngle();
    return MoveTo(mapId, x + cos(angle) * distance, y + sin(angle) * distance, z, false, false, false, false, priority);
}

bool MovementAction::MoveNear(WorldObject* target, float distance, MovementPriority priority)
{
    if (!target)
        return false;

    distance += target->GetCombatReach();

    float x = target->GetPositionX();
    float y = target->GetPositionY();
    float z = target->GetPositionZ();
    float followAngle = GetFollowAngle();

    for (float angle = followAngle; angle <= followAngle + static_cast<float>(2 * M_PI);
        angle += static_cast<float>(M_PI / 4.f))
    {
        float x = target->GetPositionX() + cos(angle) * distance;
        float y = target->GetPositionY() + sin(angle) * distance;
        float z = target->GetPositionZ();

        if (!bot->IsWithinLOS(x, y, z))
            continue;

        bool moved = MoveTo(target->GetMapId(), x, y, z, false, false, false, false, priority);
        if (moved)
            return true;
    }

    // botAI->TellError("All paths not in LOS");
    return false;
}

float MovementAction::GetFollowAngle()
{
    Player* master = GetMaster();
    Group* group = master ? master->GetGroup() : bot->GetGroup();
    if (!group)
        return 0.0f;

    uint32 index = 1;
    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        if (ref->GetSource() == master)
            continue;

        if (ref->GetSource() == bot)
            return 2 * M_PI / (group->GetMembersCount() - 1) * index;

        ++index;
    }

    return 0;
}

bool MoveRandomAction::isUseful()
{
    return true;
}

bool MovementAction::IsMovingAllowed(WorldObject* target)
{
    if (!target)
        return false;

    if (bot->FindMap() != target->FindMap())
        return false;

    return IsMovingAllowed();
}

bool MovementAction::IsMovingAllowed(uint32 mapId, float x, float y, float z)
{
    return IsMovingAllowed();
}

bool MovementAction::IsMovingAllowed()
{
    // do not allow if not vehicle driver
    if (botAI->IsInVehicle() && !botAI->IsInVehicle(true))
        return false;

    if (bot->isFrozen() || bot->IsPolymorphed() || (bot->isDead() && !bot->HasPlayerFlag(PLAYER_FLAGS_GHOST)) ||
        bot->IsBeingTeleported() || bot->HasRootAura() || bot->HasSpiritOfRedemptionAura() ||
        bot->HasConfuseAura() || bot->IsCharmed() || bot->HasStunAura() ||
        bot->IsInFlight() || bot->HasUnitState(UNIT_STATE_LOST_CONTROL))
        return false;

    if (bot->GetMotionMaster()->GetMotionSlotType(MOTION_SLOT_CONTROLLED) != NULL_MOTION_TYPE)
    {
        return false;
    }

    return bot->GetMotionMaster()->GetCurrentMovementGeneratorType() != FLIGHT_MOTION_TYPE;
}

bool MoveRandomAction::isPossible()
{
    if (bot->IsInCombat() ||
        !AI_VALUE(bool, "can move around") ||
        !bot->CanFreeMove() ||
        !botAI->CanMove()) return false;

    return true;
}

bool MovementAction::Follow(Unit* target, float distance) { return Follow(target, distance, GetFollowAngle()); }
bool MovementAction::Follow(Unit* target, float distance, float angle)
{
    UpdateMovementState();

    if (!target)
        return false;

    // a follow target on another map (a group master that travelled ahead, or another instance of
    // the same map id where the raw coordinates look close) belongs to another map thread; MoveFollow would insert
    // this bot into its follower set and the code below reads its AI context (cross-thread write, heap corruption)
    if (!target->IsInWorld() || bot->FindMap() != target->FindMap())
        return false;

    if (!bot->InBattleground() && sServerFacade->IsDistanceLessOrEqualThan(sServerFacade->GetDistance2d(bot, target),
        sPlayerbotAIConfig->followDistance))
    {
        // botAI->TellError("No need to follow");
        return false;
    }

    // Move to target corpse if alive.
    if (!target->IsAlive() && bot->IsAlive() && target->GetGUID().IsPlayer())
    {
        Player* pTarget = (Player*)target;

        Corpse* corpse = pTarget->GetCorpse();

        if (corpse)
        {
            WorldPosition botPos(bot);
            WorldPosition cPos(corpse);

            if (botPos.fDist(cPos) > sPlayerbotAIConfig->spellDistance)
                return MoveTo(cPos.getMapId(), cPos.getX(), cPos.getY(), cPos.getZ());
        }
    }

    if (sServerFacade->IsDistanceGreaterOrEqualThan(sServerFacade->GetDistance2d(bot, target),
        sPlayerbotAIConfig->sightDistance))
    {
        if (target->GetGUID().IsPlayer())
        {
            Player* pTarget = (Player*)target;

            PlayerbotAI* targetBotAI = GET_PLAYERBOT_AI(pTarget);
            if (targetBotAI)  // Try to move to where the bot is going if it is closer and in the same direction.
            {
                WorldPosition botPos(bot);
                WorldPosition tarPos(target);
                WorldPosition longMove =
                    targetBotAI->GetAiObjectContext()->GetValue<WorldPosition>("last long move")->Get();

                if (longMove)
                {
                    float lDist = botPos.fDist(longMove);
                    float tDist = botPos.fDist(tarPos);
                    float ang = botPos.getAngleBetween(tarPos, longMove);
                    if ((lDist * 1.5 < tDist && ang < static_cast<float>(M_PI) / 2) ||
                        target->HasUnitState(UNIT_STATE_IN_FLIGHT))
                    {
                        return MoveTo(longMove.getMapId(), longMove.getX(), longMove.getY(), longMove.getZ());
                    }
                }
            }
            else
            {
                if (pTarget->HasUnitState(UNIT_STATE_IN_FLIGHT))  // Move to where the player is flying to.
                {
                    TaxiPathNodeList const& tMap = static_cast<FlightPathMovementGenerator*>(pTarget->GetMotionMaster()->top())->GetPath();
                    if (!tMap.empty())
                    {
                        /*const TaxiPathNodeEntry& tEnd = tMap[tMap.GetTotalLength()];
                        return MoveTo(tEnd.MapId, tEnd.LocX, tEnd.LocY, tEnd.LocZ);*/
                    }
                }
            }
        }

        if (!target->HasUnitState(UNIT_STATE_IN_FLIGHT))
            return MoveTo(target, sPlayerbotAIConfig->followDistance);
    }

    if (sServerFacade->IsDistanceLessOrEqualThan(sServerFacade->GetDistance2d(bot, target),
        sPlayerbotAIConfig->followDistance))
    {
        // botAI->TellError("No need to follow");
        return false;
    }

    if (target->IsFriendlyTo(bot) && bot->IsMounted() && AI_VALUE(GuidVector, "all targets").empty())
        distance += angle;

    if (!bot->InBattleground() && sServerFacade->IsDistanceLessOrEqualThan(sServerFacade->GetDistance2d(bot, target),
        sPlayerbotAIConfig->followDistance))
    {
        // botAI->TellError("No need to follow");
        return false;
    }

    bot->HandleEmoteCommand(0);

    if (bot->IsSitState())
        bot->SetStandState(UNIT_STAND_STATE_STAND);

    if (bot->IsNonMeleeSpellCasted(true))
    {
        bot->CastStop();
        botAI->InterruptSpell();
    }

    // AI_VALUE(LastMovement&, "last movement").Set(target);
    ClearIdleState();

    if (bot->GetMotionMaster()->GetCurrentMovementGeneratorType() == FOLLOW_MOTION_TYPE)
    {
        Unit* currentTarget = sServerFacade->GetChaseTarget(bot);
        if (currentTarget && currentTarget->GetGUID() == target->GetGUID())
            return false;
    }

    if (bot->GetMotionMaster()->GetCurrentMovementGeneratorType() != FOLLOW_MOTION_TYPE)
        bot->GetMotionMaster()->Clear();

    bot->GetMotionMaster()->MoveFollow(target, distance, angle);
    return true;
}

const Movement::PointsArray MovementAction::SearchForBestPath(float x, float y, float z, float& modified_z,
    int maxSearchCount, bool normal_only, float step)
{
    bool found = false;
    modified_z = INVALID_HEIGHT;
    float tempZ = bot->GetMapHeight(x, y, z);
    PathGenerator gen(bot);
    gen.CalculatePath(x, y, tempZ);
    Movement::PointsArray result = gen.GetPath();
    float min_length = gen.getPathLength();
    int typeOk = PATHFIND_NORMAL | PATHFIND_INCOMPLETE;
    if ((gen.GetPathType() & typeOk) && abs(tempZ - z) < 0.5f)
    {
        modified_z = tempZ;
        return result;
    }
    // Start searching
    if (gen.GetPathType() & typeOk)
    {
        modified_z = tempZ;
        found = true;
    }
    int count = 1;
    for (float delta = step; count < maxSearchCount / 2 + 1; count++, delta += step)
    {
        tempZ = bot->GetMapHeight(x, y, z + delta);
        if (tempZ == INVALID_HEIGHT)
        {
            continue;
        }
        PathGenerator gen(bot);
        gen.CalculatePath(x, y, tempZ);
        if ((gen.GetPathType() & typeOk) && gen.getPathLength() < min_length)
        {
            found = true;
            min_length = gen.getPathLength();
            result = gen.GetPath();
            modified_z = tempZ;
        }
    }
    for (float delta = -step; count < maxSearchCount; count++, delta -= step)
    {
        tempZ = bot->GetMapHeight(x, y, z + delta);
        if (tempZ == INVALID_HEIGHT)
        {
            continue;
        }
        PathGenerator gen(bot);
        gen.CalculatePath(x, y, tempZ);
        if ((gen.GetPathType() & typeOk) && gen.getPathLength() < min_length)
        {
            found = true;
            min_length = gen.getPathLength();
            result = gen.GetPath();
            modified_z = tempZ;
        }
    }
    if (!found && normal_only)
    {
        modified_z = INVALID_HEIGHT;
        return Movement::PointsArray{};
    }
    if (!found && !normal_only)
    {
        return result;
    }
    return result;
}

bool MovementAction::MoveAway(Unit* target, float distance, bool backwards)
{
    if (!target)
    {
        return false;
    }
    float init_angle = target->GetAngle(bot);
    for (float delta = 0; delta <= M_PI / 2; delta += M_PI / 8)
    {
        float angle = init_angle + delta;
        float dx = bot->GetPositionX() + cos(angle) * distance;
        float dy = bot->GetPositionY() + sin(angle) * distance;
        float dz = bot->GetPositionZ();
        bool exact = true;
        if (!bot->GetMap()->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(),
            bot->GetPositionZ(), dx, dy, dz))
        {
            // disable prediction if position is invalid
            dx = bot->GetPositionX() + cos(angle) * distance;
            dy = bot->GetPositionY() + sin(angle) * distance;
            dz = bot->GetPositionZ();
            exact = false;
        }
        if (MoveTo(target->GetMapId(), dx, dy, dz, false, false, true, exact, MovementPriority::MOVEMENT_COMBAT, false, backwards))
        {
            return true;
        }
        if (delta == 0)
        {
            continue;
        }
        exact = true;
        angle = init_angle - delta;
        dx = bot->GetPositionX() + cos(angle) * distance;
        dy = bot->GetPositionY() + sin(angle) * distance;
        dz = bot->GetPositionZ();
        if (!bot->GetMap()->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(),
            bot->GetPositionZ(), dx, dy, dz))
        {
            // disable prediction if position is invalid
            dx = bot->GetPositionX() + cos(angle) * distance;
            dy = bot->GetPositionY() + sin(angle) * distance;
            dz = bot->GetPositionZ();
            exact = false;
        }
        if (MoveTo(target->GetMapId(), dx, dy, dz, false, false, true, exact, MovementPriority::MOVEMENT_COMBAT, false, backwards))
        {
            return true;
        }
    }
    return false;
}

bool MovementAction::Move(float angle, float distance)
{
    float x = bot->GetPositionX() + cos(angle) * distance;
    float y = bot->GetPositionY() + sin(angle) * distance;

    //TODO do we need GetMapWaterOrGroundLevel() if we're using CheckCollisionAndGetValidCoords() ?
    float z = bot->GetMapWaterOrGroundLevel(x, y, bot->GetPositionZ());
    if (z == -100000.0f || z == -200000.0f)
        z = bot->GetPositionZ();
    if (!bot->GetMap()->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(),
        bot->GetPositionZ(), x, y, z, false))
        return false;

    return MoveTo(bot->GetMapId(), x, y, z);
}

// just calculates average position of group and runs away from that position
bool MovementAction::MoveFromGroup(float distance)
{
    if (Group* group = bot->GetGroup())
    {
        uint32 mapId = bot->GetMapId();
        float closestDist = FLT_MAX;
        float x = 0.0f;
        float y = 0.0f;
        uint32 count = 0;

        for (GroupReference* gref = group->GetFirstMember(); gref; gref = gref->next())
        {
            Player* player = gref->GetSource();
            if (!player || player == bot || !player->IsAlive() || player->GetMapId() != mapId)
                continue;
            float dist = bot->GetDistance2d(player);
            if (closestDist > dist)
                closestDist = dist;
            x += player->GetPositionX();
            y += player->GetPositionY();
            count++;
        }

        if (count && closestDist < distance)
        {
            x /= count;
            y /= count;
            // x and y are now average position of the group members
            float angle = bot->GetAngle(x, y) + M_PI;
            return Move(angle, distance - closestDist);
        }
    }
    return false;
}

bool MovementAction::Flee(Unit* target)
{
    return true;
    //Player* master = GetMaster();
    //if (!target)
    //    target = master;

    //if (!target)
    //    return false;

    //if (!IsMovingAllowed())
    //{
    //    botAI->TellError("I am stuck while fleeing");
    //    return false;
    //}

    //bool foundFlee = false;
    //time_t lastFlee = AI_VALUE(LastMovement&, "last movement").lastFlee;
    //time_t now = time(0);
    //uint32 fleeDelay = urand(2, sPlayerbotAIConfig->returnDelay / 1000);

    //if (lastFlee)
    //{
    //    if ((now - lastFlee) <= fleeDelay)
    //    {
    //        return false;
    //    }
    //}

    //HostileReference* ref = target->GetThreatManager().getCurrentVictim();
    //if (ref && ref->getTarget() == bot)  // bot is target - try to flee to tank or master
    //{
    //    if (Group* group = bot->GetGroup())
    //    {
    //        Unit* fleeTarget = nullptr;
    //        float fleeDistance = sPlayerbotAIConfig->sightDistance;

    //        for (GroupReference* gref = group->GetFirstMember(); gref; gref = gref->next())
    //        {
    //            Player* player = gref->GetSource();
    //            if (!player || player == bot || !player->IsAlive())
    //                continue;

    //            if (PlayerBotSpec::IsTank(player))
    //            {
    //                float distanceToTank = sServerFacade->GetDistance2d(bot, player);
    //                float distanceToTarget = sServerFacade->GetDistance2d(bot, target);
    //                if (distanceToTank < fleeDistance)
    //                {
    //                    fleeTarget = player;
    //                    fleeDistance = distanceToTank;
    //                }
    //            }
    //        }

    //        if (fleeTarget)
    //            foundFlee = MoveNear(fleeTarget);

    //        if ((!fleeTarget || !foundFlee) && master)
    //        {
    //            foundFlee = MoveNear(master);
    //        }
    //    }
    //}
    //else  // bot is not targeted, try to flee dps/healers
    //{
    //    bool isHealer = PlayerBotSpec::IsHeal(bot);
    //    bool isDps = !isHealer && !PlayerBotSpec::IsTank(bot);
    //    bool isTank = PlayerBotSpec::IsTank(bot);
    //    bool needHealer = !isHealer && AI_VALUE2(uint8, "health", "self target") < 50;
    //    bool isRanged = PlayerBotSpec::IsRanged(bot);

    //    Group* group = bot->GetGroup();
    //    if (group)
    //    {
    //        Unit* fleeTarget = nullptr;
    //        float fleeDistance = botAI->GetRange("shoot") * 1.5f;
    //        Unit* spareTarget = nullptr;
    //        float spareDistance = botAI->GetRange("shoot") * 2.0f;
    //        std::vector<Unit*> possibleTargets;

    //        for (GroupReference* gref = group->GetFirstMember(); gref; gref = gref->next())
    //        {
    //            Player* player = gref->GetSource();
    //            if (!player || player == bot || !player->IsAlive())
    //                continue;

    //            if ((isHealer && PlayerBotSpec::IsHeal(player)) || needHealer)
    //            {
    //                float distanceToHealer = sServerFacade->GetDistance2d(bot, player);
    //                float distanceToTarget = sServerFacade->GetDistance2d(player, target);
    //                if (distanceToHealer < fleeDistance &&
    //                    distanceToTarget >(botAI->GetRange("shoot") / 2 + sPlayerbotAIConfig->followDistance) &&
    //                    (needHealer || player->IsWithinLOSInMap(target)))
    //                {
    //                    fleeTarget = player;
    //                    fleeDistance = distanceToHealer;
    //                    possibleTargets.push_back(fleeTarget);
    //                }
    //            }
    //            else if (isRanged && PlayerBotSpec::IsRanged(player))
    //            {
    //                float distanceToRanged = sServerFacade->GetDistance2d(bot, player);
    //                float distanceToTarget = sServerFacade->GetDistance2d(player, target);
    //                if (distanceToRanged < fleeDistance &&
    //                    distanceToTarget >(botAI->GetRange("shoot") / 2 + sPlayerbotAIConfig->followDistance) &&
    //                    player->IsWithinLOSInMap(target))
    //                {
    //                    fleeTarget = player;
    //                    fleeDistance = distanceToRanged;
    //                    possibleTargets.push_back(fleeTarget);
    //                }
    //            }
    //            // remember any group member in case no one else found
    //            float distanceToFlee = sServerFacade->GetDistance2d(bot, player);
    //            float distanceToTarget = sServerFacade->GetDistance2d(player, target);
    //            if (distanceToFlee < spareDistance &&
    //                distanceToTarget >(botAI->GetRange("shoot") / 2 + sPlayerbotAIConfig->followDistance) &&
    //                player->IsWithinLOSInMap(target))
    //            {
    //                spareTarget = player;
    //                spareDistance = distanceToFlee;
    //                possibleTargets.push_back(fleeTarget);
    //            }
    //        }

    //        if (!possibleTargets.empty())
    //            fleeTarget = possibleTargets[urand(0, possibleTargets.size() - 1)];

    //        if (!fleeTarget)
    //            fleeTarget = spareTarget;

    //        if (fleeTarget)
    //            foundFlee = MoveNear(fleeTarget);

    //        if ((!fleeTarget || !foundFlee) && master && master->IsAlive() && master->IsWithinLOSInMap(target))
    //        {
    //            float distanceToTarget = sServerFacade->GetDistance2d(master, target);
    //            if (distanceToTarget > (botAI->GetRange("shoot") / 2 + sPlayerbotAIConfig->followDistance))
    //                foundFlee = MoveNear(master);
    //        }
    //    }
    //}

    //if ((foundFlee || lastFlee) && bot->GetGroup())
    //{
    //    if (!lastFlee)
    //    {
    //        AI_VALUE(LastMovement&, "last movement").lastFlee = now;
    //    }
    //    else
    //    {
    //        if ((now - lastFlee) > fleeDelay)
    //        {
    //            AI_VALUE(LastMovement&, "last movement").lastFlee = 0;
    //        }
    //        else
    //            return false;
    //    }
    //}

    //FleeManager manager(bot, botAI->GetRange("flee"), bot->GetAngle(target) + M_PI);
    //if (!manager.isUseful())
    //    return false;

    //float rx, ry, rz;
    //if (!manager.CalculateDestination(&rx, &ry, &rz))
    //{
    //    botAI->TellError("Nowhere to flee");
    //    return false;
    //}

    //bool result = MoveTo(target->GetMapId(), rx, ry, rz);

    //if (result)
    //    AI_VALUE(LastMovement&, "last movement").lastFlee = time(nullptr);

    //return result;
}

Position MovementAction::BestPositionForMeleeToFlee(Position pos, float radius)
{
    Unit* currentTarget = AI_VALUE(Unit*, "current target");
    std::vector<CheckAngle> possibleAngles;
    if (currentTarget)
    {
        // Normally, move to left or right is the best position
        bool isTanking = (currentTarget->CanFreeMove()) && (currentTarget->GetVictim() == bot);
        float angle = bot->GetAngle(currentTarget);
        float angleLeft = angle + (float)M_PI / 2;
        float angleRight = angle - (float)M_PI / 2;
        possibleAngles.push_back({ angleLeft, false });
        possibleAngles.push_back({ angleRight, false });
        possibleAngles.push_back({ angle, true });
        if (isTanking)
        {
            possibleAngles.push_back({ angle + (float)M_PI, false });
            possibleAngles.push_back({ bot->GetAngle(&pos) - (float)M_PI, false });
        }
    }
    else
    {
        float angleTo = bot->GetAngle(&pos) - (float)M_PI;
        possibleAngles.push_back({ angleTo, false });
    }
    float farestDis = 0.0f;
    Position bestPos;
    for (CheckAngle& checkAngle : possibleAngles)
    {
        float angle = checkAngle.angle;
        std::list<FleeInfo>& infoList = AI_VALUE(std::list<FleeInfo>&, "recently flee info");
        if (!CheckLastFlee(angle, infoList))
        {
            continue;
        }
        bool strict = checkAngle.strict;
        float fleeDis = std::min(radius + 1.0f, sPlayerbotAIConfig->fleeDistance);
        float dx = bot->GetPositionX() + cos(angle) * fleeDis;
        float dy = bot->GetPositionY() + sin(angle) * fleeDis;
        float dz = bot->GetPositionZ();
        if (!bot->GetMap()->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(),
            bot->GetPositionZ(), dx, dy, dz))
        {
            continue;
        }
        Position fleePos{ dx, dy, dz };
        if (strict && currentTarget &&
            fleePos.GetExactDist(currentTarget) - currentTarget->GetCombatReach() >
            sPlayerbotAIConfig->tooCloseDistance &&
            bot->IsWithinMeleeRange(currentTarget))
        {
            continue;
        }
        if (pos.GetExactDist(fleePos) > farestDis)
        {
            farestDis = pos.GetExactDist(fleePos);
            bestPos = fleePos;
        }
    }
    if (farestDis > 0.0f)
    {
        return bestPos;
    }
    return Position();
}

Position MovementAction::BestPositionForRangedToFlee(Position pos, float radius)
{
    Unit* currentTarget = AI_VALUE(Unit*, "current target");
    std::vector<CheckAngle> possibleAngles;
    float angleToTarget = 0.0f;
    float angleFleeFromCenter = bot->GetAngle(&pos) - (float)M_PI;
    if (currentTarget)
    {
        // Normally, move to left or right is the best position
        angleToTarget = bot->GetAngle(currentTarget);
        float angleLeft = angleToTarget + (float)M_PI / 2;
        float angleRight = angleToTarget - (float)M_PI / 2;
        possibleAngles.push_back({ angleLeft, false });
        possibleAngles.push_back({ angleRight, false });
        possibleAngles.push_back({ angleToTarget + (float)M_PI, true });
        possibleAngles.push_back({ angleToTarget, true });
        possibleAngles.push_back({ angleFleeFromCenter, true });
    }
    else
    {
        possibleAngles.push_back({ angleFleeFromCenter, false });
    }
    float farestDis = 0.0f;
    Position bestPos;
    for (CheckAngle& checkAngle : possibleAngles)
    {
        float angle = checkAngle.angle;
        std::list<FleeInfo>& infoList = AI_VALUE(std::list<FleeInfo>&, "recently flee info");
        if (!CheckLastFlee(angle, infoList))
        {
            continue;
        }
        bool strict = checkAngle.strict;
        float fleeDis = std::min(radius + 1.0f, sPlayerbotAIConfig->fleeDistance);
        float dx = bot->GetPositionX() + cos(angle) * fleeDis;
        float dy = bot->GetPositionY() + sin(angle) * fleeDis;
        float dz = bot->GetPositionZ();
        if (!bot->GetMap()->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(),
            bot->GetPositionZ(), dx, dy, dz))
        {
            continue;
        }
        Position fleePos{ dx, dy, dz };
        if (strict && currentTarget &&
            fleePos.GetExactDist(currentTarget) - currentTarget->GetCombatReach() > sPlayerbotAIConfig->spellDistance)
        {
            continue;
        }
        if (strict && currentTarget &&
            fleePos.GetExactDist(currentTarget) - currentTarget->GetCombatReach() <
            (sPlayerbotAIConfig->tooCloseDistance))
        {
            continue;
        }

        if (pos.GetExactDist(fleePos) > farestDis)
        {
            farestDis = pos.GetExactDist(fleePos);
            bestPos = fleePos;
        }
    }
    if (farestDis > 0.0f)
    {
        return bestPos;
    }
    return Position();
}

// AvoidAoeAction, ported from mod-playerbots
namespace
{
    // a hostile area aura of a dynamic object on the bot
    Aura* AreaDebuff(Player* bot)
    {
        for (auto const& pair : bot->GetAppliedAuras())
        {
            AuraApplication const* app = pair.second;
            Aura* aura = app ? app->GetBase() : nullptr;
            if (!aura || app->IsPositive() || aura->IsRemoved() || aura->IsExpired() || aura->GetType() != DYNOBJ_AURA_TYPE)
                continue;
            Unit* caster = aura->GetCaster();
            if (caster && !caster->IsHostileTo(bot))
                continue;
            return aura;
        }
        return nullptr;
    }

    // a hostile, non-selectable summon of an encounter close to the bot (a bomb before it goes off)
    Unit* SummonedHazardNear(Player* bot, float range)
    {
        std::list<Unit*> units;
        Trinity::AnyUnfriendlyUnitInObjectRangeCheck check(bot, bot, range);
        Trinity::UnitListSearcher<Trinity::AnyUnfriendlyUnitInObjectRangeCheck> searcher(bot, units, check);
        Cell::VisitAllObjects(bot, searcher, range);
        for (Unit* unit : units)
            if (unit->IsSummon() && unit->HasUnitFlag(UNIT_FLAG_NOT_SELECTABLE) && unit->IsAlive() && unit->GetTypeId() == TYPEID_UNIT)
                return unit;
        return nullptr;
    }

    // (sweeping-hazard) a passive hostile summon without a victim that moves along a line over the floor (the Mantid Munitions
    // fire walls of Saboteur Kip'tilak): true when the bot stands within 3.5 yards of the rest of its path and it gets there within
    // 2.5 seconds; 'aside' is then a spot no line reaches in the next 4 seconds
    // (safe-aside) all lines are taken into account, also the four lines a still-standing munition on a line sends out when the
    // line reaches it (in the direction of the line and square to it, 40 yards, same speed): the bot tries 5, 8 and 11 yards in
    // 8 directions, square to its own line first, and takes the first safe spot it can reach
    struct SweepLine
    {
        float x, y;       // where it starts (now, or where the munition stands)
        float ux, uy;     // direction
        float len;        // length
        float speed;
        float t0;         // seconds before it starts
    };

    bool LineReaches(SweepLine const& l, float px, float py, float within)
    {
        float const bx = px - l.x, by = py - l.y;
        float const along = bx * l.ux + by * l.uy;   // behind the start is safe
        if (along < -1.0f || along > l.len + 2.0f || l.t0 + std::max(0.0f, along) / l.speed > within)
            return false;
        return std::fabs(bx * -l.uy + by * l.ux) < 3.5f;
    }

    bool SweepingHazardNear(Player* bot, Position& aside)
    {
        if (!bot->IsInCombat())
            return false;
        std::list<Unit*> units;
        Trinity::AnyUnfriendlyUnitInObjectRangeCheck check(bot, bot, 25.0f);
        Trinity::UnitListSearcher<Trinity::AnyUnfriendlyUnitInObjectRangeCheck> searcher(bot, units, check);
        Cell::VisitAllObjects(bot, searcher, 25.0f);
        std::vector<SweepLine> lines;
        std::vector<Unit*> standing;   // passive summons that do not move: munitions a line can set off
        for (Unit* unit : units)
        {
            Creature* creature = unit->ToCreature();
            if (!creature || !unit->IsSummon() || !unit->IsAlive() || !creature->HasReactState(REACT_PASSIVE) || unit->GetVictim())
                continue;
            if (!unit->movespline || unit->movespline->Finalized())
            {
                standing.push_back(unit);
                continue;
            }
            G3D::Vector3 const end = unit->movespline->FinalDestination();
            float const dx = end.x - unit->GetPositionX(), dy = end.y - unit->GetPositionY();
            float const len = std::sqrt(dx * dx + dy * dy);
            float const speed = unit->movespline->Velocity();
            if (len < 1.0f || speed <= 0.0f)
                continue;
            lines.push_back({ unit->GetPositionX(), unit->GetPositionY(), dx / len, dy / len, len, speed, 0.0f });
        }
        // (volatile-munitions) a munition that goes off on its own in a few seconds (Volatile Munitions of the Krik'thik
        // Demolisher, aura 109986 'Explodes in $d'): its four lines along the world axes count from now on, as if they ran
        for (Unit* m : units)   // whatever its react state: only the entry and that it is still there count
            if (m->GetEntry() == 56896 && m->IsAlive())
                for (std::pair<float, float> const& d : { std::make_pair(1.0f, 0.0f), std::make_pair(-1.0f, 0.0f),
                    std::make_pair(0.0f, 1.0f), std::make_pair(0.0f, -1.0f) })
                    lines.push_back({ m->GetPositionX(), m->GetPositionY(), d.first, d.second, 40.0f, 10.0f, 0.0f });
        if (lines.empty())
            return false;
        // the lines the standing munitions on a line will send out
        size_t const moving = lines.size();
        for (size_t n = 0; n < moving; ++n)
        {
            SweepLine const l = lines[n];
            for (Unit* m : standing)
            {
                float const bx = m->GetPositionX() - l.x, by = m->GetPositionY() - l.y;
                float const along = bx * l.ux + by * l.uy;
                if (along < 0.0f || along > l.len || std::fabs(bx * -l.uy + by * l.ux) > 2.0f)
                    continue;
                float const t0 = along / l.speed;
                for (std::pair<float, float> const& d : { std::make_pair(l.ux, l.uy), std::make_pair(-l.ux, -l.uy),
                    std::make_pair(-l.uy, l.ux), std::make_pair(l.uy, -l.ux) })
                    lines.push_back({ m->GetPositionX(), m->GetPositionY(), d.first, d.second, 40.0f, l.speed, t0 });
            }
        }
        float const px = bot->GetPositionX(), py = bot->GetPositionY();
        SweepLine const* mine = nullptr;
        for (size_t n = 0; n < moving && !mine; ++n)
            if (LineReaches(lines[n], px, py, 2.5f))
                mine = &lines[n];
        if (!mine)
            return false;
        float const side = (px - mine->x) * -mine->uy + (py - mine->y) * mine->ux;
        float const sign = side < 0.0f ? -1.0f : 1.0f;
        float const base = std::atan2(mine->ux * sign, -mine->uy * sign);   // square to its line, on the side the bot stands
        for (float dist : { 5.0f, 8.0f, 11.0f })
            for (int k : { 0, 4, 1, -1, 3, -3, 2, -2 })   // square first (both sides), then slanting, then along the line
            {
                float const a = base + k * float(M_PI) / 4.0f;
                float x = px + std::cos(a) * dist, y = py + std::sin(a) * dist, z = bot->GetPositionZ();
                if (!bot->GetMap()->CheckCollisionAndGetValidCoords(bot, px, py, bot->GetPositionZ(), x, y, z))
                    continue;
                bool safe = true;
                for (SweepLine const& l : lines)
                    if (LineReaches(l, x, y, 4.0f))
                    {
                        safe = false;
                        break;
                    }
                if (safe)
                {
                    aside.Relocate(x, y, z);
                    return true;
                }
            }
        // no safe spot: 5 yards square to its own line, as before
        for (float s : { sign, -sign })
        {
            float const shift = s * 5.0f - side;
            float x = px + -mine->uy * shift, y = py + mine->ux * shift, z = bot->GetPositionZ();
            if (bot->GetMap()->CheckCollisionAndGetValidCoords(bot, px, py, bot->GetPositionZ(), x, y, z))
            {
                aside.Relocate(x, y, z);
                return true;
            }
        }
        return false;
    }

    // (highborne-gap) Echo of Sylvanas (End Time), Calling of the Highborne: a ring of eight Risen Ghouls walks in on her and the
    // first to arrive makes her cast Sacrifice on everybody within 11 yards. Once a ghoul is dead its links are gone: the spot
    // in the middle of the widest gap, 8 yards outside the ring and at least 16 yards from her, is safe
    bool HighborneGapSpot(Player* bot, Position& spot)
    {
        if (bot->GetMapId() != 938 || !bot->IsInCombat())
            return false;
        Creature* sylvanas = bot->FindNearestCreature(54123, 80.0f, true);
        if (!sylvanas || !sylvanas->HasAura(100686))   // Call of the Highborne
            return false;
        std::list<Creature*> ghouls;
        bot->GetCreatureListWithEntryInGrid(ghouls, 54191, 80.0f);   // Risen Ghoul
        float const cx = sylvanas->GetPositionX(), cy = sylvanas->GetPositionY();
        std::vector<float> angles;
        float ring = 0.0f;
        for (Creature* ghoul : ghouls)
            if (ghoul->IsAlive())
            {
                angles.push_back(std::atan2(ghoul->GetPositionY() - cy, ghoul->GetPositionX() - cx));
                ring = std::max(ring, sylvanas->GetExactDist2d(ghoul));
            }
        if (angles.empty() || angles.size() >= 8)   // all eight still up: no way out yet, one has to die first (skull)
            return false;
        std::sort(angles.begin(), angles.end());
        float widest = 0.0f, gap = 0.0f;
        for (size_t i = 0; i < angles.size(); ++i)
        {
            float const a = angles[i];
            float const b = i + 1 < angles.size() ? angles[i + 1] : angles[0] + 2.0f * float(M_PI);
            if (b - a > widest)
            {
                widest = b - a;
                gap = (a + b) / 2.0f;
            }
        }
        if (widest < float(M_PI) / 4.0f * 1.5f)   // the ghouls stand 45 degrees apart: no gap of a dead one
            return false;
        float const r = std::max(ring + 8.0f, 40.0f);   // (highborne-far) does not follow the shrinking ring inwards
        float x = cx + std::cos(gap) * r, y = cy + std::sin(gap) * r, z = bot->GetPositionZ();
        if (bot->GetExactDist2d(x, y) < 4.0f)
        {
            spot.Relocate(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ());   // (highborne-hold) there: stay
            return true;
        }
        bot->GetMap()->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), x, y, z);
        spot.Relocate(x, y, z);
        return true;
    }

    // (channel-area) a selectable enemy that channels damage around or in front of it (Frenzied Assault of Commander Ri'mok: its own
    // periodic trigger aura, the triggered spell hits everybody within 9 yards in a cone): the caster when the bot stands in it
    Unit* ChanneledAreaNear(Player* bot, float& radius)
    {
        if (!bot->IsInCombat())
            return nullptr;
        std::list<Unit*> units;
        Trinity::AnyUnfriendlyUnitInObjectRangeCheck check(bot, bot, 20.0f);
        Trinity::UnitListSearcher<Trinity::AnyUnfriendlyUnitInObjectRangeCheck> searcher(bot, units, check);
        Cell::VisitAllObjects(bot, searcher, 20.0f);
        for (Unit* unit : units)
        {
            Creature* creature = unit->ToCreature();
            if (!creature || !unit->IsAlive() || unit->HasUnitFlag(UNIT_FLAG_NOT_SELECTABLE) || creature->IsTrigger())
                continue;   // the invisible triggers are handled by AvoidUnitWithDamageAura
            for (AuraEffect const* aurEff : unit->GetAuraEffectsByType(SPELL_AURA_PERIODIC_TRIGGER_SPELL))
            {
                if (aurEff->GetCasterGUID() != unit->GetGUID())
                    continue;
                int32 const maxDuration = aurEff->GetBase()->GetMaxDuration();   // (channel-area-timed) not a permanent aura
                if (maxDuration <= 0 || maxDuration > 20000)
                    continue;
                SpellInfo const* trigger = sSpellMgr->GetSpellInfo(aurEff->GetSpellInfo()->Effects[aurEff->GetEffIndex()].TriggerSpell);
                if (!trigger || sPlayerbotAIConfig->aoeAvoidSpellWhitelist.count(trigger->Id))
                    continue;
                for (uint8 j = 0; j < MAX_SPELL_EFFECTS; ++j)
                {
                    uint32 const effect = trigger->Effects[j].Effect;
                    if (effect != SPELL_EFFECT_SCHOOL_DAMAGE && effect != SPELL_EFFECT_WEAPON_PERCENT_DAMAGE && effect != SPELL_EFFECT_WEAPON_DAMAGE
                        && effect != SPELL_EFFECT_WEAPON_DAMAGE_NOSCHOOL && effect != SPELL_EFFECT_NORMALIZED_WEAPON_DMG)
                        continue;
                    if (!trigger->Effects[j].IsTargetingArea())
                        continue;
                    float const r = trigger->Effects[j].CalcRadius();
                    if (!r || r > 15.0f || unit->GetDistance(bot) > r + 1.0f)
                        continue;
                    if (trigger->Effects[j].TargetA.GetSelectionCategory() == TARGET_SELECT_CATEGORY_CONE
                        && !unit->isInFront(bot, float(M_PI) * 2.0f / 3.0f))
                        continue;
                    radius = r;
                    return unit;
                }
            }
        }
        return nullptr;
    }

    struct DamageTrapCheck
    {
        WorldObject const* bot;
        float range;
        bool operator()(GameObject* go) const
        {
            return go->GetGoType() == GAMEOBJECT_TYPE_TRAP && go->GetGOInfo()->trap.spellId && go->GetGOInfo()->trap.type == 0
                && bot->IsWithinDistInMap(go, range);
        }
    };
}

bool AvoidAoeAction::isUseful()
{
    if (!bot->IsInWorld() || !bot->GetMap()->Instanceable() || bot->GetMap()->IsBattlegroundOrArena())
        return false;
    Position aside;
    if (getMSTime() - lastMoveTimer >= 300 && SweepingHazardNear(bot, aside))   // (sweeping-hazard) it does not wait
        return true;
    if (getMSTime() - lastMoveTimer >= 300 && HighborneGapSpot(bot, aside))   // (highborne-gap)
        return true;
    float channelRadius = 0.0f;
    if (getMSTime() - lastMoveTimer >= 300 && ChanneledAreaNear(bot, channelRadius))   // (channel-area)
        return true;
    if (getMSTime() - lastMoveTimer < moveInterval)
        return false;
    if (AreaDebuff(bot) || SummonedHazardNear(bot, 3.0f))
        return true;
    GuidVector const triggers = AI_VALUE(GuidVector, "possible triggers");
    if (!triggers.empty())
        return true;
    std::list<GameObject*> traps;
    DamageTrapCheck check{ bot, sPlayerbotAIConfig->maxAoeAvoidRadius };
    Trinity::GameObjectListSearcher<DamageTrapCheck> searcher(bot, traps, check);
    bot->VisitNearbyGridObject(sPlayerbotAIConfig->maxAoeAvoidRadius, searcher);
    return !traps.empty();
}

bool AvoidAoeAction::Execute(Event /*event*/)
{
    // an aura with a dynamic object (Rain of Fire), a trap object with a spell (lava bomb), a trigger unit (shadow
    // fissure, sticky bomb)
    Position aside;
    if (SweepingHazardNear(bot, aside) && MoveTo(bot->GetMapId(), aside.GetPositionX(), aside.GetPositionY(), aside.GetPositionZ(),
        false, false, true, false, MovementPriority::MOVEMENT_COMBAT))
    {
        lastMoveTimer = getMSTime();   // (sweeping-hazard)
        TC_LOG_INFO("playerbots", "BotLife {}: steps aside from a sweeping hazard in map {} at {:.1f} {:.1f} {:.1f}", bot->GetName(),
            bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ());   // (avoid-aoe-registered)
        return true;
    }
    if (HighborneGapSpot(bot, aside) && bot->GetExactDist2d(aside.GetPositionX(), aside.GetPositionY()) < 0.5f)
    {
        bot->StopMoving();   // (highborne-hold) at the safe spot outside the ring: hold still until the ghouls are done
        lastMoveTimer = getMSTime();
        return true;
    }
    if (HighborneGapSpot(bot, aside) && MoveTo(bot->GetMapId(), aside.GetPositionX(), aside.GetPositionY(), aside.GetPositionZ(),
        false, false, true, false, MovementPriority::MOVEMENT_COMBAT))   // (highborne-gap)
    {
        if (getMSTime() - lastMoveTimer > 3000)
            TC_LOG_INFO("playerbots", "BotLife {}: goes out through the gap in the ghoul ring to {:.1f} {:.1f} (from {:.1f} {:.1f})", bot->GetName(),
                aside.GetPositionX(), aside.GetPositionY(), bot->GetPositionX(), bot->GetPositionY());
        lastMoveTimer = getMSTime();
        return true;
    }
    float channelRadius = 0.0f;   // (channel-area) out of a channeled area around or in front of an enemy
    if (Unit* caster = ChanneledAreaNear(bot, channelRadius))
        if (FleePosition(caster->GetPosition(), channelRadius + 2.0f, 0))
        {
            if (getMSTime() - lastMoveTimer > 3000)
                TC_LOG_INFO("playerbots", "BotLife {}: steps out of the channel of {} ({}, {:.0f} yd) in map {}", bot->GetName(),
                    caster->GetName(), caster->GetEntry(), channelRadius, bot->GetMapId());
            lastMoveTimer = getMSTime();
            return true;
        }
    Unit* hazard = SummonedHazardNear(bot, 3.0f);   // (part 3: a bomb before it goes off)
    if (AvoidAuraWithDynamicObj() || AvoidGameObjectWithDamage() || AvoidUnitWithDamageAura()
        || (hazard && FleePosition(hazard->GetPosition(), 5.0f)))
    {
        lastMoveTimer = getMSTime();
        return true;
    }
    return false;
}

bool AvoidAoeAction::AvoidAuraWithDynamicObj()
{
    Aura* aura = AreaDebuff(bot);
    if (!aura)
        return false;
    SpellInfo const* spellInfo = aura->GetSpellInfo();
    if (!spellInfo || sPlayerbotAIConfig->aoeAvoidSpellWhitelist.count(spellInfo->Id))
        return false;
    DynamicObject* dynOwner = aura->GetDynobjOwner();
    if (!dynOwner || !dynOwner->IsInWorld())
        return false;
    float const radius = dynOwner->GetRadius();
    if (!radius || radius > sPlayerbotAIConfig->maxAoeAvoidRadius || bot->GetDistance(dynOwner) > radius)
        return false;
    return FleePosition(dynOwner->GetPosition(), radius);
}

bool AvoidAoeAction::AvoidGameObjectWithDamage()
{
    std::list<GameObject*> traps;
    DamageTrapCheck check{ bot, sPlayerbotAIConfig->maxAoeAvoidRadius };
    Trinity::GameObjectListSearcher<DamageTrapCheck> searcher(bot, traps, check);
    bot->VisitNearbyGridObject(sPlayerbotAIConfig->maxAoeAvoidRadius, searcher);
    for (GameObject* go : traps)
    {
        uint32 const spellId = go->GetGOInfo()->trap.spellId;
        if (sPlayerbotAIConfig->aoeAvoidSpellWhitelist.count(spellId))
            continue;
        SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(spellId);
        if (!spellInfo || spellInfo->IsPositive())
            continue;
        float const radius = float(go->GetGOInfo()->trap.radius) / 2.0f + go->GetObjectSize();
        if (!radius || radius > sPlayerbotAIConfig->maxAoeAvoidRadius || bot->GetDistance(go) > radius)
            continue;
        if (FleePosition(go->GetPosition(), radius))
            return true;
    }
    return false;
}

bool AvoidAoeAction::AvoidUnitWithDamageAura()
{
    // (hazard-field) a trail of damage zones (Scorched Earth of Brother Korloff: a 2 yd patch every 250 ms while he walks): fleeing
    // from one patch at a time lands in the next one. Collect every damage-zone trigger within 15 yards live (the cached trigger
    // list is a second old) and walk to the reachable spot with the largest clearance from all of them.
    std::vector<std::pair<Position, float>> hazards;   // centre, radius + 2 yd margin
    Unit* worst = nullptr;
    float worstRadius = 0.0f;
    std::list<Unit*> nearUnits;
    Trinity::AnyUnitInObjectRangeCheck nearCheck(bot, 15.0f);
    Trinity::UnitListSearcher<Trinity::AnyUnitInObjectRangeCheck> nearSearcher(bot, nearUnits, nearCheck);
    Cell::VisitAllObjects(bot, nearSearcher, 15.0f);
    for (Unit* unit : nearUnits)
    {
        if (!unit || !unit->IsInWorld() || unit == bot)
            continue;
        // (trigger-hazard) not selectable, or an invisible trigger creature
        if (!unit->HasUnitFlag(UNIT_FLAG_NOT_SELECTABLE) && !(unit->ToCreature() && unit->ToCreature()->IsTrigger()))
            continue;
        for (AuraType type : { SPELL_AURA_PERIODIC_TRIGGER_SPELL, SPELL_AURA_PERIODIC_TRIGGER_SPELL_WITH_VALUE })
            for (AuraEffect const* aurEff : unit->GetAuraEffectsByType(type))
            {
                SpellInfo const* spellInfo = aurEff->GetSpellInfo();
                if (!spellInfo)
                    continue;
                SpellInfo const* trigger = sSpellMgr->GetSpellInfo(spellInfo->Effects[aurEff->GetEffIndex()].TriggerSpell);
                if (!trigger || sPlayerbotAIConfig->aoeAvoidSpellWhitelist.count(trigger->Id))
                    continue;
                for (uint8 j = 0; j < MAX_SPELL_EFFECTS; ++j)
                {
                    if (trigger->Effects[j].Effect != SPELL_EFFECT_SCHOOL_DAMAGE)
                        continue;
                    float const radius = trigger->Effects[j].CalcRadius();
                    if (!radius || radius > sPlayerbotAIConfig->maxAoeAvoidRadius)
                        continue;
                    hazards.push_back({ unit->GetPosition(), radius + 2.0f });
                    if (bot->GetExactDist2d(unit) < radius + 2.0f && (!worst || radius > worstRadius))
                    {
                        worst = unit;
                        worstRadius = radius;
                    }
                    break;
                }
            }
    }
    if (worst)
    {
        std::list<FleeInfo>& infoList = AI_VALUE(std::list<FleeInfo>&, "recently flee info");
        uint32 const now = getMSTime();
        if (!infoList.empty() && infoList.back().timestamp + 500 > now)
            return false;
        Unit* target = AI_VALUE(Unit*, "current target");
        bool const melee = PlayerBotSpec::IsMelee(bot);
        float const reach = melee ? 5.0f : 25.0f;
        // candidates by score; the path is only calculated for the best ones until one is reachable
        std::vector<std::pair<float, Position>> candidates;
        for (int a = 0; a < 16; ++a)
            for (float d : { 5.0f, 8.0f, 11.0f })
            {
                float const ang = a * float(M_PI) / 8.0f;
                float x = bot->GetPositionX() + std::cos(ang) * d, y = bot->GetPositionY() + std::sin(ang) * d, z = bot->GetPositionZ();
                bot->UpdateAllowedPositionZ(x, y, z);
                if (std::fabs(z - bot->GetPositionZ()) > 4.0f)
                    continue;
                Position const p(x, y, z);
                float clearance = 100.0f;
                for (auto const& h : hazards)
                    clearance = std::min(clearance, p.GetExactDist2d(&h.first) - h.second);
                if (clearance <= 0.0f)
                    continue;
                float score = std::min(clearance, 6.0f) - 0.05f * d;
                if (target && target->IsInWorld())
                    score -= 0.3f * std::max(0.0f, p.GetExactDist2d(target) - target->GetCombatReach() - reach);
                candidates.push_back({ score, p });
            }
        std::sort(candidates.begin(), candidates.end(), [](auto const& l, auto const& r) { return l.first > r.first; });
        int tested = 0;
        for (auto const& c : candidates)
        {
            if (++tested > 6)
                break;
            PathGenerator path(bot);
            path.CalculatePath(c.second.GetPositionX(), c.second.GetPositionY(), c.second.GetPositionZ(), false);
            if (!(path.GetPathType() & PATHFIND_NORMAL))
                continue;
            if (MoveTo(bot->GetMapId(), c.second.GetPositionX(), c.second.GetPositionY(), c.second.GetPositionZ(), false, false, true,
                false, MovementPriority::MOVEMENT_COMBAT))
            {
                infoList.push_back({ worst->GetPosition(), worstRadius + 2.0f, bot->GetAngle(&c.second), now });
                while (infoList.size() > 10)
                    infoList.pop_front();
                TC_LOG_INFO("playerbots", "BotLife {}: steps out of the damage zone of {} ({}, {:.0f} yd, {} zones near) in map {}",
                    bot->GetName(), worst->GetName(), worst->GetEntry(), worstRadius, hazards.size(), bot->GetMapId());
                return true;
            }
        }
        // no clear spot found: the old step away from the nearest zone
        if (FleePosition(worst->GetPosition(), worstRadius + 2.0f))
            return true;
    }
    GuidVector const triggers = AI_VALUE(GuidVector, "possible triggers");
    for (ObjectGuid const& guid : triggers)
    {
        Unit* unit = botAI->GetUnit(guid);
        if (!unit || !unit->IsInWorld())
            continue;
        if (!unit->HasUnitFlag(UNIT_FLAG_NOT_SELECTABLE) && !(unit->ToCreature() && unit->ToCreature()->IsTrigger()))
            continue;
        // a bomb that explodes by script when someone comes close (Sticky Bomb: 2 yards)
        if (bot->GetDistance(unit) < 3.0f && (!unit->GetAuraEffectsByType(SPELL_AURA_PERIODIC_TRIGGER_SPELL).empty()
            || !unit->GetAuraEffectsByType(SPELL_AURA_PERIODIC_TRIGGER_SPELL_WITH_VALUE).empty()) && FleePosition(unit->GetPosition(), 5.0f))
            return true;
    }
    return false;
}

bool MovementAction::FleePosition(Position pos, float radius, uint32 minInterval)
{
    std::list<FleeInfo>& infoList = AI_VALUE(std::list<FleeInfo>&, "recently flee info");

    if (!infoList.empty() && infoList.back().timestamp + minInterval > getMSTime())
        return false;

    Position bestPos;
    if (PlayerBotSpec::IsMelee(bot))
    {
        bestPos = BestPositionForMeleeToFlee(pos, radius);
    }
    else
    {
        bestPos = BestPositionForRangedToFlee(pos, radius);
    }
    if (bestPos != Position())
    {
        if (MoveTo(bot->GetMapId(), bestPos.GetPositionX(), bestPos.GetPositionY(), bestPos.GetPositionZ(), false,
            false, true, false, MovementPriority::MOVEMENT_COMBAT))
        {
            uint32 curTS = getMSTime();
            while (!infoList.empty())
            {
                if (infoList.size() > 10 || infoList.front().timestamp + 5000 < curTS)
                {
                    infoList.pop_front();
                }
                else
                {
                    break;
                }
            }
            infoList.push_back({ pos, radius, bot->GetAngle(&bestPos), curTS });
            return true;
        }
    }
    return false;
}

bool MovementAction::CheckLastFlee(float curAngle, std::list<FleeInfo>& infoList)
{
    uint32 curTS = getMSTime();
    curAngle = Position::NormalizeOrientation(curAngle);
    while (!infoList.empty())
    {
        if (infoList.size() > 10 || infoList.front().timestamp + 5000 < curTS)
        {
            infoList.pop_front();
        }
        else
        {
            break;
        }
    }
    for (FleeInfo& info : infoList)
    {
        // more than 5 sec
        if (info.timestamp + 5000 < curTS)
        {
            continue;
        }
        float revAngle = Position::NormalizeOrientation(info.angle + M_PI);
        // angle too close
        if (fabs(revAngle - curAngle) < M_PI / 4)
        {
            return false;
        }
    }
    return true;
}

bool RunAwayAction::Execute(Event event) { return Flee(AI_VALUE(Unit*, "master target")); }

bool SetFacingTargetAction::Execute(Event event)
{
    Unit* target = AI_VALUE(Unit*, "current target");
    if (!target)
        return false;

    if (bot->HasUnitState(UNIT_STATE_IN_FLIGHT))
        return true;

    sServerFacade->SetFacingTo(bot, target);
    botAI->SetNextCheckDelay(sPlayerbotAIConfig->reactDelay);
    return true;
}

bool SetFacingTargetAction::isUseful()
{
    return !AI_VALUE2(bool, "facing", "current target");
}

bool SetFacingTargetAction::isPossible()
{
    if (bot->isFrozen() || bot->IsPolymorphed() || (bot->isDead() && !bot->HasPlayerFlag(PLAYER_FLAGS_GHOST)) ||
        bot->IsBeingTeleported() || bot->HasConfuseAura() || bot->IsCharmed() ||
        bot->HasStunAura() || bot->IsInFlight() ||
        bot->HasUnitState(UNIT_STATE_LOST_CONTROL))
        return false;

    return true;
}

bool MoveFromGroupAction::Execute(Event event)
{
    float distance = atoi(event.getParam().c_str());
    if (!distance)
        distance = 20.0f; // flee distance from config is too small for this
    return MoveFromGroup(distance);
}

bool FleeAction::Execute(Event event)
{
    return MoveAway(AI_VALUE(Unit*, "current target"), sPlayerbotAIConfig->fleeDistance, true);
}

bool FleeAction::isUseful()
{
    if (bot->GetCurrentSpell(CURRENT_CHANNELED_SPELL) != nullptr)
    {
        return false;
    }
    return true;
}

bool CombatFormationMoveAction::isUseful()
{
    if (getMSTime() - moveInterval < lastMoveTimer)
    {
        return false;
    }
    if (bot->GetCurrentSpell(CURRENT_CHANNELED_SPELL) != nullptr)
    {
        return false;
    }
    return true;
}

bool CombatFormationMoveAction::Execute(Event event)
{
    float dis = AI_VALUE(float, "disperse distance");
    if (dis <= 0.0f)
        return false;
    Player* playerToLeave = NearestGroupMember(dis);
    if (playerToLeave && bot->GetExactDist(playerToLeave) < dis)
    {
        //if (FleePosition(playerToLeave->GetPosition(), dis))
        {
            //lastMoveTimer = getMSTime();
        }
    }
    return false;
}

Position CombatFormationMoveAction::AverageGroupPos(float dis, bool ranged, bool self)
{
    float averageX = 0, averageY = 0, averageZ = 0;
    int cnt = 0;
    Group* group = bot->GetGroup();
    if (!group)
    {
        return Position();
    }
    Group::MemberSlotList const& groupSlot = group->GetMemberSlots();
    for (Group::member_citerator itr = groupSlot.begin(); itr != groupSlot.end(); itr++)
    {
        Player* member = ObjectAccessor::FindPlayer(itr->guid);
        if (!member)
            continue;

        if (!self && member == bot)
            continue;

        if (ranged && !PlayerBotSpec::IsRanged(member))
            continue;

        if (!member->IsAlive() || member->FindMap() != bot->FindMap() || member->IsCharmed() ||
            sServerFacade->GetDistance2d(bot, member) > dis)
            continue;

        averageX += member->GetPositionX();
        averageY += member->GetPositionY();
        averageZ += member->GetPositionZ();
    }
    averageX /= cnt;
    averageY /= cnt;
    averageZ /= cnt;
    return Position(averageX, averageY, averageZ);
}

float CombatFormationMoveAction::AverageGroupAngle(Unit* from, bool ranged, bool self)
{
    Group* group = bot->GetGroup();
    if (!from || !group)
    {
        return 0.0f;
    }
    // float average = 0.0f;
    float sumX = 0.0f;
    float sumY = 0.0f;
    int cnt = 0;
    Group::MemberSlotList const& groupSlot = group->GetMemberSlots();
    for (Group::member_citerator itr = groupSlot.begin(); itr != groupSlot.end(); itr++)
    {
        Player* member = ObjectAccessor::FindPlayer(itr->guid);
        if (!member)
            continue;

        if (!self && member == bot)
            continue;

        if (ranged && !PlayerBotSpec::IsRanged(member))
            continue;

        if (!member->IsAlive() || member->FindMap() != bot->FindMap() || member->IsCharmed() ||
            sServerFacade->GetDistance2d(bot, member) > sPlayerbotAIConfig->sightDistance)
            continue;

        cnt++;
        sumX += member->GetPositionX() - from->GetPositionX();
        sumY += member->GetPositionY() - from->GetPositionY();
    }
    if (cnt == 0)
        return 0.0f;

    // unnecessary division
    // sumX /= cnt;
    // sumY /= cnt;

    return atan2(sumY, sumX);
}

Position CombatFormationMoveAction::GetNearestPosition(const std::vector<Position>& positions)
{
    Position result;
    for (const Position& pos : positions)
    {
        if (bot->GetExactDist(pos) < bot->GetExactDist(result))
            result = pos;
    }
    return result;
}

Player* CombatFormationMoveAction::NearestGroupMember(float dis)
{
    float nearestDis = 10000.0f;
    Player* result = nullptr;
    Group* group = bot->GetGroup();
    if (!group)
    {
        return result;
    }
    Group::MemberSlotList const& groupSlot = group->GetMemberSlots();
    for (Group::member_citerator itr = groupSlot.begin(); itr != groupSlot.end(); itr++)
    {
        Player* member = ObjectAccessor::FindPlayer(itr->guid);
        if (!member || !member->IsAlive() || member == bot || member->FindMap() != bot->FindMap() ||
            member->IsCharmed() || sServerFacade->GetDistance2d(bot, member) > dis)
            continue;
        if (nearestDis > bot->GetExactDist(member))
        {
            result = member;
            nearestDis = bot->GetExactDist(member);
        }
    }
    return result;
}

bool TankFaceAction::Execute(Event event)
{
    Unit* target = AI_VALUE(Unit*, "current target");
    if (!target)
        return false;

    if (!bot->GetGroup())
        return false;

    if (!bot->IsWithinMeleeRange(target) || target->isMoving())
        return false;

    if (!AI_VALUE2(bool, "has aggro", "current target"))
        return false;

    float averageAngle = AverageGroupAngle(target, true);

    if (averageAngle == 0.0f)
        return false;

    float deltaAngle = Position::NormalizeOrientation(averageAngle - target->GetAngle(bot));
    if (deltaAngle > M_PI)
        deltaAngle -= 2.0f * M_PI; // -PI..PI

    float tolerable = M_PI_2;

    if (fabs(deltaAngle) > tolerable)
        return false;

    float goodAngle1 = Position::NormalizeOrientation(averageAngle + M_PI * 3 / 5);
    float goodAngle2 = Position::NormalizeOrientation(averageAngle - M_PI * 3 / 5);

    // if dist < bot->GetMeleeRange(target) / 2, target will move backward
    float dist = std::max(bot->GetExactDist(target), bot->GetMeleeRange(target) / 2) - bot->GetCombatReach() - target->GetCombatReach();
    std::vector<Position> availablePos;
    float x, y, z;
    target->GetNearPoint(bot, x, y, z, dist, goodAngle1);
    if (bot->GetMap()->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(),
        x, y, z))
    {
        /// @todo: movement control now is a mess, prepare to rewrite
        std::list<FleeInfo>& infoList = AI_VALUE(std::list<FleeInfo>&, "recently flee info");
        Position pos(x, y, z);
        float angle = bot->GetAngle(&pos);
        if (CheckLastFlee(angle, infoList))
        {
            availablePos.push_back(Position(x, y, z));
        }
    }
    target->GetNearPoint(bot, x, y, z, dist, goodAngle2);
    if (bot->GetMap()->CheckCollisionAndGetValidCoords(bot, bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(),
        x, y, z))
    {
        std::list<FleeInfo>& infoList = AI_VALUE(std::list<FleeInfo>&, "recently flee info");
        Position pos(x, y, z);
        float angle = bot->GetAngle(&pos);
        if (CheckLastFlee(angle, infoList))
        {
            availablePos.push_back(Position(x, y, z));
        }
    }
    if (availablePos.empty())
        return false;
    Position nearest = GetNearestPosition(availablePos);
    return MoveTo(bot->GetMapId(), nearest.GetPositionX(), nearest.GetPositionY(), nearest.GetPositionZ(), false, false, false, true, MovementPriority::MOVEMENT_COMBAT);
}