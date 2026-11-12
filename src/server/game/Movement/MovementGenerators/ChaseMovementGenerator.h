/*
 * This file is part of the Legends of Azeroth Pandaria Project. See THANKS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TRINITY_CHASEMOVEMENTGENERATOR_H
#define TRINITY_CHASEMOVEMENTGENERATOR_H

#include "AbstractFollower.h"
#include "MovementDefines.h"
#include "MovementGenerator.h"
#include "Optional.h"
#include "Position.h"
#include "Timer.h"

// (botcost) a creature that chases a bot keeps its running spline while the bot stayed within this many yards of the position
// the path was made for and the spline has more than this many ms left (see ChaseMovementGenerator::Update)
#define CHASE_REPATH_DISTANCE 2.0f
#define CHASE_REPATH_MIN_TIME_LEFT 300

class PathGenerator;
class Unit;

class ChaseMovementGenerator : public MovementGenerator, public AbstractFollower
{
    public:
        explicit ChaseMovementGenerator(Unit* target, Optional<ChaseRange> range = {}, Optional<ChaseAngle> angle = {});
        ~ChaseMovementGenerator();

        bool Initialize(Unit*) override;
        bool Reset(Unit*) override;
        bool Update(Unit*, uint32) override;
        void Deactivate(Unit*) override;
        void Finalize(Unit*, bool, bool) override;
        MovementGeneratorType GetMovementGeneratorType() const override { return CHASE_MOTION_TYPE; }

        void unitSpeedChanged() override { _lastTargetPosition.reset(); }

    private:
        static constexpr uint32 RANGE_CHECK_INTERVAL = 100; // time (ms) until we attempt to recalculate

        Optional<ChaseRange> const _range;
        Optional<ChaseAngle> const _angle;

        std::unique_ptr<PathGenerator> _path;
        Optional<Position> _lastTargetPosition;
        TimeTracker _rangeCheckTimer;
        bool _movingTowards = true;
        bool _mutualChase = true;
        uint32 _splineEndMs = 0;   // (botcost) getMSTime() at which the running chase spline ends
};

#endif
