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

#include "AbstractFollower.h"
#include "ThreadOwnerCheck.h"
#include "Unit.h"

void AbstractFollower::SetTarget(Unit* unit)
{
    if (unit == _target)
        return;

    // the follower set belongs to the target; a worker of another map may not change it (diagnostic,
    // TT-THREADCHECK in Server.log)
    if (_target)
    {
        TTCheckThreadOwner(_target, "FollowerRemoved", ObjectGuid::Empty);
        _target->FollowerRemoved(this);
    }
    _target = unit;
    if (_target)
    {
        TTCheckThreadOwner(_target, "FollowerAdded", ObjectGuid::Empty);
        _target->FollowerAdded(this);
    }
}
