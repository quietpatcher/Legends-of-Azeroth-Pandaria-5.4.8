/*
 * diagnostic for the recurring dangling-ThreatReference crash (ThreatReference::ShouldBeOffline on a
 * freed reference in a creature's own threat list). Combat/threat bookkeeping of a unit may only change on the thread
 * that updates the unit's map; a map-updater worker that touches a unit of another map is logged with a backtrace
 * (TT-THREADCHECK in Server.log, offsets relative to the worldserver image for addr2line).
 */
#ifndef TT_THREAD_OWNER_CHECK_H
#define TT_THREAD_OWNER_CHECK_H

class Map;
class Unit;
class ObjectGuid;

// the map the current map-updater worker thread is updating (nullptr on every other thread)
Map const*& TTCurrentUpdateMap();
void TTCheckThreadOwner(Unit const* owner, char const* what, ObjectGuid const& other);
// guild XP earned on map-updater threads is applied here, on the world thread (Guild.cpp, called from World::Update)
void TTFlushPendingGuildXP();
void TTFlushPendingGuildCriteria();   // Guild.cpp
// MapUpdater.cpp: how long the update of a map takes - a moving average per map id, and the peak since it was last read
void TTRecordMapUpdateTime(unsigned int mapId, unsigned int ms);
unsigned int TTMapUpdateTime(unsigned int mapId, bool peak);

#endif
