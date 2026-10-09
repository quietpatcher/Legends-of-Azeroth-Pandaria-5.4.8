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
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include "DatabaseEnv.h"
#include "MapUpdater.h"
#include "Map.h"
#include "ThreadOwnerCheck.h"
#include "Timer.h"
#include <array>
#include <atomic>
#include <mutex>

// the world tick is as long as its slowest map (every map is one thread). Per map id a moving average
// (in sixteenths of a millisecond) and the peak since the last read; the instances of one id share a slot.
namespace
{
    constexpr uint32 TT_MAP_SLOTS = 2048;
    std::array<std::atomic<uint32>, TT_MAP_SLOTS> tt_mapAverage;
    std::array<std::atomic<uint32>, TT_MAP_SLOTS> tt_mapPeak;
}

void TTRecordMapUpdateTime(unsigned int mapId, unsigned int ms)
{
    if (mapId >= TT_MAP_SLOTS)
        return;
    uint32 const average = tt_mapAverage[mapId].load(std::memory_order_relaxed);
    tt_mapAverage[mapId].store((average * 7 + ms * 16) / 8, std::memory_order_relaxed);
    if (ms > tt_mapPeak[mapId].load(std::memory_order_relaxed))
        tt_mapPeak[mapId].store(ms, std::memory_order_relaxed);
}

unsigned int TTMapUpdateTime(unsigned int mapId, bool peak)
{
    if (mapId >= TT_MAP_SLOTS)
        return 0;
    return peak ? tt_mapPeak[mapId].exchange(0, std::memory_order_relaxed) : tt_mapAverage[mapId].load(std::memory_order_relaxed) / 16;
}

class MapUpdateRequest
{
    private:

        Map& m_map;
        MapUpdater& m_updater;
        uint32 m_diff;

    public:

        MapUpdateRequest(Map& m, MapUpdater& u, uint32 d)
            : m_map(m), m_updater(u), m_diff(d)
        {
        }

        void call()
        {
            //TC_METRIC_TIMER("map_update_time_diff", TC_METRIC_TAG("map_id", std::to_string(m_map.GetId())));
            TTCurrentUpdateMap() = &m_map;   // see ThreadOwnerCheck.h
            uint32 const started = getMSTime();
            m_map.Update (m_diff);
            TTRecordMapUpdateTime(m_map.GetId(), getMSTimeDiff(started, getMSTime()));
            TTCurrentUpdateMap() = nullptr;
            m_updater.update_finished();
        }
};

void MapUpdater::activate(size_t num_threads)
{
    for (size_t i = 0; i < num_threads; ++i)
    {
        _workerThreads.push_back(std::thread(&MapUpdater::WorkerThread, this));
    }
}

void MapUpdater::deactivate()
{
    _cancelationToken = true;

    wait();

    _queue.Cancel();

    for (auto& thread : _workerThreads)
    {
        thread.join();
    }
}

void MapUpdater::wait()
{
    std::unique_lock<std::mutex> lock(_lock);

    while (pending_requests > 0)
        _condition.wait(lock);

    lock.unlock();
}

void MapUpdater::schedule_update(Map& map, uint32 diff)
{
    std::lock_guard<std::mutex> lock(_lock);

    ++pending_requests;

    _queue.Push(new MapUpdateRequest(map, *this, diff));
}

bool MapUpdater::activated()
{
    return _workerThreads.size() > 0;
}

void MapUpdater::update_finished()
{
    std::lock_guard<std::mutex> lock(_lock);

    --pending_requests;

    _condition.notify_all();
}

void MapUpdater::WorkerThread()
{
    LoginDatabase.WarnAboutSyncQueries(true);
    CharacterDatabase.WarnAboutSyncQueries(true);
    WorldDatabase.WarnAboutSyncQueries(true);

    while (true)
    {
        MapUpdateRequest* request = nullptr;

        _queue.WaitAndPop(request);

        if (_cancelationToken)
            return;

        request->call();

        delete request;
    }
}
