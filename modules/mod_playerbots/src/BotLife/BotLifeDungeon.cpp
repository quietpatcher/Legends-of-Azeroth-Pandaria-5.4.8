/*
 * Bot life: dungeons and raids for random bot parties.
 * The world thread forms a party (tank leads, healer(s), dps) of bots that fit a dungeon's level range
 * and teleports it to the dungeon entrance. Inside, the leader walks from hostile spawn to hostile spawn
 * and engages; the engine does the fighting, members follow / assist / heal / loot. The world thread
 * resurrects the dead after combat, handles wipes, and brings everybody back when the dungeon is cleared
 * or the time is up (BotLifeParty.cpp: MaintainInstanceParty).
 */

#include "BotLife.h"

#include "Config.h"

#include "Creature.h"
#include "DatabaseEnv.h"
#include "DBCStores.h"
#include "CellImpl.h"
#include "GameTime.h"
#include "InstanceScript.h"
#include "GameObject.h"
#include "QuestDef.h"
#include "GossipDef.h"
#include "ScriptMgr.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "Group.h"
#include "GroupMgr.h"
#include "LFGMgr.h"
#include "Log.h"
#include "Map.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "PlayerbotSpec.h"
#include "Playerbots.h"
#include "Random.h"
#include "RandomPlayerbotMgr.h"
#include "PathGenerator.h"
#include "Timer.h"

#include <algorithm>
#include <cmath>
#include <set>
#include <mutex>
#include <sstream>
#include <tuple>

namespace
{
    constexpr uint32 DUNGEON_TARGET_TIMEOUT = 120000;     // walking to one spawn
    constexpr uint32 DUNGEON_ENGAGE_TIMEOUT = 20000;      // near a target without getting into combat

    bool IsInstanceCandidate(Player* bot)
    {
        if (!bot || !bot->IsInWorld() || !bot->GetSession() || bot->GetGroup())
            return false;
        if (!bot->IsAlive() || bot->IsInCombat() || bot->IsBeingTeleported() || bot->IsInFlight() || bot->InBattleground()
            || bot->GetVehicle() || bot->GetLevel() < 15)
            return false;
        Map* map = bot->GetMap();
        if (!map || map->Instanceable())
            return false;
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI || botAI->IsRealPlayer() || botAI->HasRealPlayerMaster() || botAI->life.party)
            return false;
        return sRandomPlayerbotMgr->IsRandomBot(bot);
    }

    bool FactionFits(int32 faction, Player* bot)
    {
        if (faction < 0)
            return true;
        return (faction == 0) == (bot->GetTeam() == HORDE);
    }

    // a MoP boss that stays UNIT_FLAG_NON_ATTACKABLE until a set of gate creatures has been killed.
    // The gate mobs are passive/neutral, so after a bot disengages they evade and the normal target filter skips them,
    // ending the run with 0 bosses. The kill-gate re-engages the nearest living gate mob until the boss opens up.
    struct BotLifeKillGate { uint32 bossEntry; std::set<uint32> gateEntries; };
    static const std::unordered_map<uint32, BotLifeKillGate> s_killGates =
    {
        // Stormstout Brewery (961): Ook-Ook (56637) unseals after 40 hozen die (the 7 hozen entries the instance counts)
        { 961, { 56637, { 56862, 56863, 56924, 59605, 59684, 57097, 56927 } } },
        // Deadmines (36): Foe Reaper 5000 (43778) comes on line after 4 Defias Watchers / Reapers died
        { 36, { 43778, { 47403, 47404 } } },
    };

    // quest givers and enders inside the dungeons (map -> spawns); filled once by LoadDungeons
    struct DungeonQuestNpc { uint32 spawnId; uint32 entry; float x, y, z; };
    std::unordered_map<uint32, std::vector<DungeonQuestNpc>> s_dungeonQuestNpcs;
    // scripted gossip NPCs of each instance map (event starters: Brann in the Halls of Stone, ...)
    std::unordered_map<uint32, std::vector<DungeonQuestNpc>> s_eventNpcs;

    // dungeon finder id -> creature entry of its last encounter, and that entry's spawns (filled once by
    // LoadDungeons; read-only afterwards)
    std::unordered_map<uint32, uint32> s_finalBoss;
    std::unordered_map<uint32, std::vector<uint32>> s_finalBossSpawns;
    // kills of last encounters by instance - a summoned one (Vazruden) has no spawn to look at
    std::mutex s_finalKilledLock;
    std::set<std::pair<uint32, uint32>> s_finalKilled;   // instance id, creature entry

    // what a leader did about the quests of the current run (map thread of the leader)
    struct DungeonQuestRun { std::set<uint32> visited; std::set<uint32> handInVisited; uint32 walkTo = 0; uint32 walkSince = 0; uint32 nextScan = 0; };

    bool IsKillGateEntry(uint32 map, uint32 entry)
    {
        auto it = s_killGates.find(map);
        return it != s_killGates.end() && it->second.gateEntries.count(entry) > 0;
    }
}

// the last encounter of this dungeon finder entry lies dead in the leader's instance (world thread, while
// the maps stand still): killed and waiting for a respawn, or its corpse still there
bool BotLifeFinalBossDown(Player* leader, uint32 dungeonId)
{
    auto fb = s_finalBoss.find(dungeonId);
    if (fb == s_finalBoss.end() || !leader || !leader->IsInWorld())
        return false;
    {
        std::lock_guard<std::mutex> lock(s_finalKilledLock);
        if (s_finalKilled.count({ leader->GetInstanceId(), fb->second }))
            return true;
    }
    auto spawns = s_finalBossSpawns.find(fb->second);
    if (spawns == s_finalBossSpawns.end())
        return false;
    Map* map = leader->GetMap();
    for (uint32 spawnId : spawns->second)
    {
        if (map->GetCreatureRespawnTime(spawnId))
            return true;
        auto bounds = map->GetCreatureBySpawnIdStore().equal_range(spawnId);
        for (auto itr = bounds.first; itr != bounds.second; ++itr)
            if (itr->second->IsInWorld() && !itr->second->IsAlive())
                return true;
    }
    return false;
}

// a last encounter died (map thread)
void BotLifeNoteFinalBossKill(Creature* killed)
{
    uint32 const entry = killed->GetEntry();
    bool last = false;
    for (auto const& fb : s_finalBoss)
        if (fb.second == entry)
        {
            last = true;
            break;
        }
    if (!last)
        return;
    std::lock_guard<std::mutex> lock(s_finalKilledLock);
    if (s_finalKilled.size() > 20000)
        s_finalKilled.clear();
    s_finalKilled.emplace(killed->GetInstanceId(), entry);
}

// a member of the leader's party has a completed quest that an NPC of this dungeon takes (world thread,
// while the maps stand still)
bool BotLifeDungeonHandInPending(Player* leader)
{
    if (!leader || !leader->IsInWorld())
        return false;
    auto it = s_dungeonQuestNpcs.find(leader->GetMapId());
    Group* group = leader->GetGroup();
    if (it == s_dungeonQuestNpcs.end() || !group)
        return false;
    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        Player* member = ref->GetSource();
        if (!member || !member->IsInWorld() || member->GetMap() != leader->GetMap() || !member->IsAlive())
            continue;
        for (DungeonQuestNpc const& qn : it->second)
            for (uint32 questId : sObjectMgr->GetCreatureQuestInvolvedRelations(qn.entry))
                if (member->GetQuestStatus(questId) == QUEST_STATUS_COMPLETE)
                    return true;
    }
    return false;
}

// ---------------------------------------------------------------------------------------------
// caches

// (real-bosses) the maps on which a boss that is only an encounter credit counts, and the spawns that belong to a game event
static std::map<uint32, std::set<uint32>> s_encounterBossMaps;
static std::set<uint32> s_eventSpawnIds;

void BotLifeMgr::LoadDungeons()
{
    _dungeons.clear();
    _instanceSpawns.clear();
    _bossEntries.clear();
    _gateSpawns.clear();
    _sealedBossSpawns.clear();
    _instanceSpawnIds.clear();

    // dungeons under repair (LfgDungeons ids): picked first, whatever their record, so that every fix
    // gets runs to measure
    _dungeonFocus.clear();
    {
        std::stringstream ss(sConfigMgr->GetStringDefault("BotLife.DungeonFocus", ""));
        std::string id;
        while (std::getline(ss, id, ','))
        {
            id.erase(0, id.find_first_not_of(' '));
            id.erase(id.find_last_not_of(' ') + 1);
            if (!id.empty())
                _dungeonFocus.insert(uint32(std::atoi(id.c_str())));
        }
    }

    // dungeons where the last boss needs a manual gossip click bots cannot do (e.g. Wailing Caverns'
    // Naralex escort event that unlocks Mutanus the Devourer): without this, a bot party reforms here over and
    // over, gets stuck at n-2 bosses, and only frees the slot after the full dungeon timeout.
    _dungeonExcludeMaps.clear();
    {
        std::stringstream ss(sConfigMgr->GetStringDefault("BotLife.DungeonExcludeMaps", "43"));   // 43 = Wailing Caverns
        std::string id;
        while (std::getline(ss, id, ','))
        {
            id.erase(0, id.find_first_not_of(' '));
            id.erase(id.find_last_not_of(' ') + 1);
            if (!id.empty())
                _dungeonExcludeMaps.insert(uint32(std::atoi(id.c_str())));
        }
    }

    // bosses: encounter kill credit, boss scripts, world boss rank, dungeon boss flag
    // the encounter that completes each dungeon finder entry
    s_finalBoss.clear();
    s_finalBossSpawns.clear();
    if (QueryResult result = WorldDatabase.Query("SELECT lastEncounterDungeon, creditEntry FROM instance_encounters WHERE creditType = 0 AND lastEncounterDungeon > 0"))
        do { s_finalBoss[result->Fetch()[0].GetUInt32()] = result->Fetch()[1].GetUInt32(); } while (result->NextRow());
    // (real-bosses) a boss only through instance_encounters counts on the maps of those encounters (DungeonEncounter.dbc):
    // High Inquisitor Fairbanks is credit of encounter 449 of the old Scarlet Monastery (map 189) and no boss on map 1004
    s_encounterBossMaps.clear();
    if (QueryResult result = WorldDatabase.Query("SELECT entry, creditEntry FROM instance_encounters WHERE creditType = 0"))
        do
        {
            uint32 const credit = result->Fetch()[1].GetUInt32();
            _bossEntries.insert(credit);
            DungeonEncounterEntry const* de = sDungeonEncounterStore.LookupEntry(result->Fetch()[0].GetUInt32());
            s_encounterBossMaps[credit].insert(de ? de->mapId : 0u);
        } while (result->NextRow());
    for (auto const& ctPair : *sObjectMgr->GetCreatureTemplates())
    {
        CreatureTemplate const& ct = ctPair.second;
        bool const ownBoss = ct.rank == CREATURE_ELITE_WORLDBOSS || sObjectMgr->GetScriptName(ct.ScriptID).rfind("boss_", 0) == 0;
        if (ownBoss || (ct.flags_extra & CREATURE_FLAG_EXTRA_DUNGEON_BOSS))
            _bossEntries.insert(ct.Entry);
        // (real-bosses) a boss by itself counts on every map; the dungeon-boss flag does not say so: the core sets it on every
        // encounter credit (High Inquisitor Fairbanks)
        if (ownBoss)
            s_encounterBossMaps.erase(ct.Entry);
    }
    // (real-bosses) spawns of a game event (the Headless Horseman in Scarlet Monastery, Hallow's End) are no boss of the dungeon
    s_eventSpawnIds.clear();
    if (QueryResult result = WorldDatabase.Query("SELECT guid FROM game_event_creature"))
        do { s_eventSpawnIds.insert(result->Fetch()[0].GetUInt32()); } while (result->NextRow());

    std::set<uint32> maps;
    for (uint32 i = 0; i < sLFGDungeonStore.GetNumRows(); ++i)
    {
        LFGDungeonEntry const* dbc = sLFGDungeonStore.LookupEntry(i);
        if (!dbc || dbc->MapID <= 0 || dbc->scenario || (dbc->Flags & lfg::LFG_FLAG_SEASONAL))
            continue;
        bool raid = dbc->TypeID == lfg::LFG_TYPE_RAID;
        if (dbc->TypeID != lfg::LFG_TYPE_DUNGEON && !raid)
            continue;
        // nobody runs heroics: the heroic version is a dungeon of its own in the rotation, for
        // the levels the dungeon finder gives it (the level cap of its expansion)
        bool const heroic = !raid && dbc->DifficultyID == DUNGEON_DIFFICULTY_HEROIC;
        if (!raid && dbc->DifficultyID != DUNGEON_DIFFICULTY_NORMAL && !(heroic && _heroicDungeons))
            continue;
        if (raid && dbc->DifficultyID != RAID_DIFFICULTY_10MAN_NORMAL && dbc->DifficultyID != RAID_DIFFICULTY_40MAN)
            continue;
        MapEntry const* mapEntry = sMapStore.LookupEntry(dbc->MapID);
        if (!mapEntry || !mapEntry->Instanceable())
            continue;
        if (_dungeonExcludeMaps.count(uint32(dbc->MapID)))
            continue;
        lfg::LFGDungeonData const* data = sLFGMgr->GetLFGDungeon(dbc->ID);
        if (!data || (data->x == 0.0f && data->y == 0.0f))
            continue;

        BotLifeDungeon d;
        d.id = dbc->ID;
        d.map = uint32(dbc->MapID);
        d.difficulty = uint8(dbc->DifficultyID);
        d.minLevel = uint8(dbc->recminlevel ? dbc->recminlevel : dbc->minlevel);
        d.maxLevel = uint8(dbc->recmaxlevel ? dbc->recmaxlevel : dbc->maxlevel);
        if (d.minLevel < dbc->minlevel)
            d.minLevel = uint8(dbc->minlevel);
        // bot parties run a dungeon a little above its recommendation - from its top up to the finder's
        // maximum; at the bottom of the range they wiped at every boss
        if (!raid && dbc->maxlevel > d.maxLevel)
        {
            d.minLevel = uint8(std::min<uint32>(uint32(d.maxLevel) + 1, dbc->maxlevel));
            d.maxLevel = uint8(dbc->maxlevel);
        }
        // the entrance can ask for a higher level than the dungeon finder; such a party is refused
        if (AccessRequirement const* ar = sObjectMgr->GetAccessRequirement(d.map, Difficulty(d.difficulty)))
            if (ar->levelMin > d.minLevel)
                d.minLevel = ar->levelMin;
        if (!d.minLevel || d.maxLevel < d.minLevel)
            continue;
        d.raid = raid;
        d.faction = dbc->faction;
        d.x = data->x;
        d.y = data->y;
        d.z = data->z;
        d.o = data->o;
        d.name = dbc->name ? dbc->name : "";
        if (heroic)
            d.name += " (heroic)";
        _dungeons.push_back(d);
        maps.insert(d.map);
    }

    uint32 spawnCount = 0;
    if (!maps.empty())
    {
        std::ostringstream ids;
        for (uint32 m : maps)
            ids << (ids.tellp() ? "," : "") << m;
        s_dungeonQuestNpcs.clear();
        s_eventNpcs.clear();
        if (QueryResult result = WorldDatabase.PQuery("SELECT guid, id, map, spawnMask, position_x, position_y, position_z FROM creature "
            "WHERE (phaseMask & 1) = 1 AND phaseGroup = 0 AND map IN ({})", ids.str()))
        {
            do
            {
                Field* f = result->Fetch();
                CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(f[1].GetUInt32());
                if (!ct)
                    continue;
                uint32 const mapId = f[2].GetUInt32();
                // a scripted gossip NPC without a service role - an event starter
                {
                    uint32 const roles = UNIT_NPC_FLAG_VENDOR | UNIT_NPC_FLAG_TRAINER | UNIT_NPC_FLAG_FLIGHTMASTER | UNIT_NPC_FLAG_INNKEEPER
                        | UNIT_NPC_FLAG_BANKER | UNIT_NPC_FLAG_AUCTIONEER | UNIT_NPC_FLAG_REPAIR | UNIT_NPC_FLAG_SPIRITHEALER | UNIT_NPC_FLAG_SPIRITGUIDE;
                    if ((ct->npcflag & UNIT_NPC_FLAG_GOSSIP) && !(ct->npcflag & roles) && ct->ScriptID)
                        s_eventNpcs[mapId].push_back({ f[0].GetUInt32(), ct->Entry, f[4].GetFloat(), f[5].GetFloat(), f[6].GetFloat() });
                }
                // an NPC that gives or takes quests
                {
                    auto starts = sObjectMgr->GetCreatureQuestRelations(ct->Entry);
                    auto ends = sObjectMgr->GetCreatureQuestInvolvedRelations(ct->Entry);
                    if (starts.begin() != starts.end() || ends.begin() != ends.end())
                        s_dungeonQuestNpcs[mapId].push_back({ f[0].GetUInt32(), ct->Entry, f[4].GetFloat(), f[5].GetFloat(), f[6].GetFloat() });
                }
                // spawns of a last encounter
                for (auto const& fb : s_finalBoss)
                    if (fb.second == ct->Entry)
                    {
                        s_finalBossSpawns[ct->Entry].push_back(f[0].GetUInt32());
                        break;
                    }
                BotLifeInstanceSpawn s;
                s.spawnId = f[0].GetUInt32();
                s.entry = ct->Entry;
                s.spawnMask = f[3].GetUInt32();
                s.x = f[4].GetFloat();
                s.y = f[5].GetFloat();
                s.z = f[6].GetFloat();
                s.boss = _bossEntries.count(ct->Entry) > 0;
                // (real-bosses) only on the maps of its encounters, and never a spawn of a game event
                if (s.boss)
                {
                    auto em = s_encounterBossMaps.find(ct->Entry);
                    if (em != s_encounterBossMaps.end() && !em->second.count(mapId) && !em->second.count(0u))
                        s.boss = false;
                    if (s_eventSpawnIds.count(s.spawnId))
                        s.boss = false;
                }
                FactionTemplateEntry const* ft = sFactionTemplateStore.LookupEntry(ct->faction);
                bool const pullTarget = !ct->npcflag
                    && ct->type != CREATURE_TYPE_CRITTER && ct->type != CREATURE_TYPE_NON_COMBAT_PET && ct->type != CREATURE_TYPE_TOTEM
                    && !(ct->unit_flags & (UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_IMMUNE_TO_PC))
                    // triggers/bunnies (invisible, not meant to be fought) are no pull targets
                    && (!(ct->flags_extra & CREATURE_FLAG_EXTRA_TRIGGER) || s.boss)
                    // a boss neutral to all is fought as well (Kresh, Wailing Caverns)
                    && ft && (ft->IsHostileToPlayers() || (s.boss && ft->IsNeutralToAll()));
                // the mobs of a kill-gate are listed apart, the neutral ones too. Stormstout Brewery: 45 of
                // the 52 hozen that count for Ook-Ook are faction 190 and were in no list - the gate could reach 7 of 40.
                if (IsKillGateEntry(mapId, ct->Entry) && !(ct->unit_flags & (UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE)))
                    _gateSpawns[mapId].push_back(s);
                if (!pullTarget)
                {
                    // a boss that starts out sealed, friendly or talking: the leader walks up to it when
                    // nothing else is left (VisitSealedBoss), and fights it once it has opened up (PickUnlistedTarget)
                    if (s.boss)
                        _sealedBossSpawns[mapId].push_back(s);
                    continue;
                }
                _instanceSpawns[mapId].push_back(s);
                _instanceSpawnIds.insert(s.spawnId);
                ++spawnCount;
            } while (result->NextRow());
        }
    }

    // dungeons need something to fight
    _dungeons.erase(std::remove_if(_dungeons.begin(), _dungeons.end(), [this](BotLifeDungeon& d)
    {
        auto it = _instanceSpawns.find(d.map);
        if (it == _instanceSpawns.end())
            return true;
        uint32 bit = 1u << d.difficulty;
        uint32 count = 0;
        for (BotLifeInstanceSpawn const& s : it->second)
            if (s.spawnMask & bit)   // spawnMask 0 is never loaded by the core
            {
                ++count;
                if (s.boss)
                    ++d.bosses;
            }
        return count < 10;
    }), _dungeons.end());

    // dungeons the bots keep wiping in and never clear: leave them to real players
    _dungeonRecord.clear();
    if (QueryResult result = PlayerbotsDatabase.Query("SELECT dungeon, CAST(SUM(bosses = 0 AND result <> 'cleared') AS UNSIGNED), CAST(SUM(bosses > 0 OR result = 'cleared') AS UNSIGNED) "
        "FROM tt_botlife_dungeon_runs WHERE result <> 'marker' "
        // a 'reset' marker (after core/script fixes) gives every dungeon a clean record
        "AND ts > COALESCE((SELECT MAX(m.ts) FROM (SELECT ts FROM tt_botlife_dungeon_runs WHERE result = 'marker' AND name LIKE '%reset%') m), 0) "
        "GROUP BY dungeon"))
        do
        {
            Field* f = result->Fetch();
            _dungeonRecord[f[0].GetUInt32()] = { uint32(f[1].GetUInt64()), uint32(f[2].GetUInt64()) };
        } while (result->NextRow());

    // dungeons the bots could not do (stalled or wiped without a kill, no boss in time), remembered across restarts.
    // the mark runs out (after the record: how long depends on whether the bots ever beat the dungeon)
    _badDungeons.clear();
    if (QueryResult result = PlayerbotsDatabase.Query("SELECT id, ts FROM tt_botlife_bad_dungeon"))
        do
        {
            Field* f = result->Fetch();
            uint32 const until = BadDungeonUntil(f[0].GetUInt32(), f[1].GetUInt32());
            if (until > uint32(GameTime::GetGameTime()))
                _badDungeons[f[0].GetUInt32()] = until;
        } while (result->NextRow());

    _dungeonFocusMaps.clear();
    for (BotLifeDungeon const& d : _dungeons)
        if (_dungeonFocus.count(d.id))
            _dungeonFocusMaps.insert(d.map);

    uint32 raids = uint32(std::count_if(_dungeons.begin(), _dungeons.end(), [](BotLifeDungeon const& d) { return d.raid; }));
    TC_LOG_INFO("server.loading", ">> BotLife: {} dungeons + {} raids for bot parties, {} hostile instance spawns, {} out of rotation for now",
        uint32(_dungeons.size()) - raids, raids, spawnCount, uint32(_badDungeons.size()));
}

bool BotLifeMgr::IsBadDungeon(uint32 id) const
{
    auto it = _badDungeons.find(id);
    return it != _badDungeons.end() && it->second > uint32(GameTime::GetGameTime());
}

// a dungeon the bots have beaten before is tried again after a few hours, one they never got a boss in after a few days
uint32 BotLifeMgr::BadDungeonUntil(uint32 id, uint32 markedAt) const
{
    auto rec = _dungeonRecord.find(id);
    bool const proven = rec != _dungeonRecord.end() && rec->second.second > 0;
    return markedAt + (proven ? _badDungeonHours * HOUR : _badDungeonDays * DAY);
}

void BotLifeMgr::MarkBadDungeon(BotLifeDungeon const& d, char const* reason)
{
    if (IsBadDungeon(d.id))
        return;
    uint32 const marked = uint32(GameTime::GetGameTime());
    _badDungeons[d.id] = BadDungeonUntil(d.id, marked);
    std::string name = d.name;
    PlayerbotsDatabase.EscapeString(name);
    PlayerbotsDatabase.PExecute("REPLACE INTO tt_botlife_bad_dungeon (id, name, reason, ts) VALUES ({}, '{}', '{}', {})",
        d.id, name, reason, marked);
}

// ---------------------------------------------------------------------------------------------
// world thread: forming dungeon / raid parties

void BotLifeMgr::FormInstanceParties(uint32 now, bool raid)
{
    uint8 type = raid ? BOTLIFE_PARTY_RAID : BOTLIFE_PARTY_DUNGEON;
    uint32 active = 0;
    for (auto const& p : _parties)
        if (p.second.type == type)
            ++active;
    uint32 wanted = raid ? _raidParties : _dungeonParties;
    if (active >= wanted)
        return;

    // candidates by team and role
    struct Pool { std::vector<Player*> tanks, heals, dps; };
    Pool pools[2];
    for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
    {
        Player* bot = pair.second;
        if (IsBanker(bot->GetGUID()) || IsLfgBot(bot->GetGUID()) || IsWalker(bot) || !IsInstanceCandidate(bot))
            continue;
        Pool& pool = pools[bot->GetTeam() == HORDE ? 1 : 0];
        if (PlayerBotSpec::IsTank(bot, true))
            pool.tanks.push_back(bot);
        else if (PlayerBotSpec::IsHeal(bot, true))
            pool.heals.push_back(bot);
        else
            pool.dps.push_back(bot);
    }

    uint32 size = raid ? _raidSize : 5;
    uint32 needTanks = raid ? 2 : 1;
    uint32 needHeals = raid ? (size >= 20 ? 5 : 3) : 1;

    for (uint32 attempt = 0; attempt < 30 && active < wanted; ++attempt)
    {
        Pool& pool = pools[urand(0, 1)];
        if (pool.tanks.size() < needTanks || pool.heals.size() < needHeals || pool.dps.size() < size - needTanks - needHeals)
            continue;
        Player* leader = pool.tanks[urand(0, pool.tanks.size() - 1)];
        // a dungeon under repair first (BotLife.DungeonFocus), led by a tank of its level
        int32 focusIndex = -1;
        if (!_dungeonFocus.empty() && urand(1, 100) <= _dungeonFocusChance)
        {
            std::vector<uint32> wantedDungeons;
            for (uint32 i = 0; i < _dungeons.size(); ++i)
                if (_dungeons[i].raid == raid && _dungeonFocus.count(_dungeons[i].id))
                    wantedDungeons.push_back(i);
            if (!wantedDungeons.empty())
            {
                uint32 const wantedIndex = wantedDungeons[urand(0, wantedDungeons.size() - 1)];
                BotLifeDungeon const& fd = _dungeons[wantedIndex];
                std::vector<Player*> fitTanks;
                for (Player* tank : pool.tanks)
                    if (tank->GetLevel() >= fd.minLevel && tank->GetLevel() <= fd.maxLevel && FactionFits(fd.faction, tank))
                        fitTanks.push_back(tank);
                if (!fitTanks.empty())
                {
                    leader = fitTanks[urand(0, fitTanks.size() - 1)];
                    focusIndex = int32(wantedIndex);
                }
            }
        }
        // of a handful of tanks, the one whose guild has the most healers and damage dealers of
        // about its level waiting - so that the group really is a guild group and not two guild mates with strangers
        if (_guildGroups && focusIndex < 0)
        {
            uint32 bestScore = 0;
            for (uint32 sample = 0; sample < 8; ++sample)
            {
                Player* tank = pool.tanks[urand(0, pool.tanks.size() - 1)];
                uint32 const guildId = tank->GetGuildId();
                if (!guildId)
                    continue;
                auto mates = [&](std::vector<Player*> const& from, uint32 cap)
                {
                    uint32 n = 0;
                    for (Player* bot : from)
                    {
                        if (n >= cap)
                            break;
                        int32 const diff = int32(bot->GetLevel()) - int32(tank->GetLevel());
                        if (bot != tank && bot->GetGuildId() == guildId && diff >= -4 && diff <= 4)
                            ++n;
                    }
                    return n;
                };
                uint32 const score = mates(pool.heals, needHeals) + mates(pool.dps, size - needTanks - needHeals) + mates(pool.tanks, needTanks - 1);
                if (score > bestScore)
                {
                    bestScore = score;
                    leader = tank;
                }
            }
        }
        uint32 level = leader->GetLevel();

        // dungeons that fit the leader; raids: old content (the bots out-level it a bit) or current level
        std::vector<uint32> fits;
        for (uint32 i = 0; i < _dungeons.size(); ++i)
        {
            BotLifeDungeon const& d = _dungeons[i];
            if (d.raid != raid || IsBadDungeon(d.id) || !FactionFits(d.faction, leader))
                continue;
            auto rec = _dungeonRecord.find(d.id);
            if (rec != _dungeonRecord.end() && rec->second.first >= 3 && !rec->second.second)
                continue;   // 3+ runs without a single boss, never a success
            // raids: only content the bots out-level (current raids are beyond bot tactics)
            // pre-MoP raids also at their own level cap (60/70/80/85), as a group of that level; MoP raids
            // still only out-levelled (never, at 90)
            uint32 raidMin = uint32(d.maxLevel) + (d.maxLevel < 90 ? 0 : 3);
            if (raid ? (level >= raidMin && level <= uint32(d.maxLevel) + 25) : (level >= d.minLevel && level <= d.maxLevel))
                fits.push_back(i);
        }
        if (focusIndex >= 0)
        {
            fits.clear();
            fits.push_back(uint32(focusIndex));
        }
        if (fits.empty())
            continue;
        uint32 index = fits[urand(0, fits.size() - 1)];
        BotLifeDungeon const& d = _dungeons[index];
        uint32 minL = d.minLevel, maxL = raid ? 255 : d.maxLevel;

        auto pick = [&](std::vector<Player*>& from, uint32 count, std::vector<Player*>& out) -> bool
        {
            std::vector<Player*> chosen;
            std::vector<size_t> order(from.size());
            for (size_t i = 0; i < order.size(); ++i)
                order[i] = i;
            for (size_t i = order.size(); i > 1; --i)
                std::swap(order[i - 1], order[urand(0, uint32(i - 1))]);
            // guild mates of the leader first - players run dungeons and raids with their guild,
            // and a group of one guild is a guild group (guild experience, guild challenges, the Guild Run achievements)
            if (_guildGroups && leader->GetGuildId())
                std::stable_partition(order.begin(), order.end(), [&](size_t i) { return from[i]->GetGuildId() == leader->GetGuildId(); });
            for (size_t i : order)
            {
                Player* bot = from[i];
                if (bot == leader || std::find(out.begin(), out.end(), bot) != out.end())
                    continue;
                int32 diff = int32(bot->GetLevel()) - int32(level);
                if (bot->GetLevel() < minL || bot->GetLevel() > maxL || diff < -4 || diff > 4)
                    continue;
                chosen.push_back(bot);
                if (chosen.size() >= count)
                    break;
            }
            if (chosen.size() < count)
                return false;
            out.insert(out.end(), chosen.begin(), chosen.end());
            return true;
        };

        std::vector<Player*> members;
        if (!pick(pool.tanks, needTanks - 1, members) || !pick(pool.heals, needHeals, members)
            || !pick(pool.dps, size - needTanks - needHeals, members))
            continue;

        // remember where everybody was
        std::vector<Player*> all = members;
        all.push_back(leader);
        std::unordered_map<ObjectGuid, BotLifeLocation> origin;
        for (Player* p : all)
        {
            BotLifeLocation loc;
            loc.map = p->GetMapId();
            loc.x = p->GetPositionX();
            loc.y = p->GetPositionY();
            loc.z = p->GetPositionZ();
            loc.o = p->GetOrientation();
            origin[p->GetGUID()] = loc;
        }

        uint32 minutes = raid ? _raidMinutes : _dungeonMinutes;
        if (!CreateParty(leader, members, type, minutes * MINUTE * IN_MILLISECONDS))
            continue;
        Group* group = leader->GetGroup();
        if (!group)
            continue;
        // the difficulty of the dungeon that was picked (CreateParty sets normal)
        if (!raid && d.difficulty != DUNGEON_DIFFICULTY_NORMAL)
        {
            group->SetDungeonDifficulty(Difficulty(d.difficulty));
            Count(BLC_HEROIC_START);
        }
        BotLifeParty& party = _parties[group->GetLowGUID()];
        party.dungeon = int32(index);
        party.origin = std::move(origin);

        // teleports deferred to each bot own map thread (QueueTeleport) to remove the cross-thread
        // TeleportTo race. The leader-refused-entry abort relied on TeleportTo's immediate bool, which a deferred
        // teleport cannot return; an unenterable dungeon is now pruned by the normal stall/disband + MarkBadDungeon path.
        // (bot-raid-unbind) a bot keeps no lockout of the instance its party is about to enter. A bot that killed a boss of a raid
        // stays bound to that instance until the reset; a party of bots bound to different instances was refused at the door
        // (measured 12-10 in Ahn'Qiraj Ruins: six of ten members bound to five different instances, nobody got in, four
        // "wipes" in eighty seconds and the party gave up). The dungeon finder side does the same for heroics (lfg-bot-unbind).
        uint32 released = 0;
        for (Player* p : all)
        {
            if (p->GetMapId() == d.map)
                continue;
            bool bound = false;
            for (uint8 difficulty = 0; difficulty < MAX_DIFFICULTY; ++difficulty)
                if (p->GetBoundInstance(d.map, Difficulty(difficulty)))
                {
                    p->UnbindInstance(d.map, Difficulty(difficulty));   // nothing happens when the bind sits under the other raid size
                    bound = true;
                }
            if (bound)
                ++released;
        }
        if (released)
            TC_LOG_INFO("playerbots", "BotLife: {} of {} bots released their lockout of {} for the party of {}", released, all.size(), d.name, leader->GetName());

        QueueTeleport(leader, d.map, d.x, d.y, d.z, d.o);
        for (Player* member : members)
            QueueTeleport(member, d.map, d.x + frand(-2.0f, 2.0f), d.y + frand(-2.0f, 2.0f), d.z, d.o);

        for (Player* p : all)
        {
            for (auto& v : { &pool.tanks, &pool.heals, &pool.dps })
                v->erase(std::remove(v->begin(), v->end(), p), v->end());
        }
        ++active;
        Count(raid ? BLC_RAID_START : BLC_DUNGEON_START);
        TC_LOG_INFO("playerbots", "BotLife: {} party led by {} (lvl {}) enters {} ({} map {}, lvl {}-{}, {} bosses)",
            raid ? "raid" : "dungeon", leader->GetName(), level, d.name, d.id, d.map, uint32(d.minLevel), uint32(d.maxLevel), d.bosses);
    }
}

// ---------------------------------------------------------------------------------------------
// map thread: the leader crawls through the instance

Creature* BotLifeMgr::SpawnCreature(Map* map, uint32 spawnId) const
{
    auto bounds = map->GetCreatureBySpawnIdStore().equal_range(spawnId);
    Creature* any = nullptr;
    for (auto it = bounds.first; it != bounds.second; ++it)
    {
        Creature* c = it->second;
        if (!c || !c->IsInWorld())
            continue;
        if (c->IsAlive())
            return c;
        any = c;
    }
    return any;
}

bool BotLifeMgr::DungeonTargetValid(Player* bot, BotLifeInfo const& t, BotLifeInstanceSpawn const& s, uint32 diffBit, Creature*& creature) const
{
    creature = nullptr;
    if (t.dungeonSkip.count(s.spawnId))
        return false;
    if (!(s.spawnMask & diffBit))   // spawnMask 0 is never loaded by the core
        return false;
    creature = SpawnCreature(bot->GetMap(), s.spawnId);
    if (!creature)
        return bot->GetMap()->GetCreatureRespawnTime(s.spawnId) == 0;   // grid not loaded yet: walk there - unless it was killed and its respawn timer runs
    if (!creature->IsAlive() || creature->IsInEvadeMode())
        return false;
    if (creature->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE))
        return false;
    // trash far above the party (mis-levelled decoration/trigger spawns, e.g. Scarlet Halls "Books" lvl 86) is never a pull target
    if (!s.boss && creature->GetLevel() > bot->GetLevel() + 10)
        return false;
    // far away spawns are out of sight: only the faction / flags matter here, not visibility
    return bot->IsValidAttackTarget(creature, nullptr, nullptr, true);
}

namespace
{
    struct ClosedDoorCheck
    {
        WorldObject const* obj;
        float range;
        bool operator()(GameObject* go) const
        {
            return go->GetGoType() == GAMEOBJECT_TYPE_DOOR && go->GetGoState() == GO_STATE_READY && obj->IsWithinDist(go, range, false);
        }
    };
}

// closed doors near a stuck leader: the bots cannot run the encounter scripts that open them
uint32 BotLifeMgr::OpenDoorsNear(Player* bot, float range)
{
    std::list<GameObject*> doors;
    ClosedDoorCheck check{ bot, range };
    Trinity::GameObjectListSearcher<ClosedDoorCheck> searcher(bot, doors, check);
    bot->VisitNearbyGridObject(range, searcher);
    uint32 opened = 0;
    for (GameObject* door : doors)
    {
        door->SetGoState(GO_STATE_ACTIVE);
        ++opened;
        if (_debug)
            TC_LOG_INFO("playerbots", "BotLife {}: opened door {} ({}) on map {}", bot->GetName(), door->GetName(), door->GetEntry(), bot->GetMapId());
    }
    if (opened)
        Count(BLC_DOOR_OPEN, opened);
    return opened;
}

void BotLifeMgr::SkipDungeonTarget(Player* bot, BotLifeInfo& t, char const* reason)
{
    ++t.dungeonSkipWhy[reason];
    bool boss = false;
    auto spawnsIt = _instanceSpawns.find(bot->GetMapId());
    if (spawnsIt != _instanceSpawns.end())
        for (BotLifeInstanceSpawn const& s : spawnsIt->second)
            if (s.spawnId == t.dungeonTarget)
            {
                boss = s.boss;
                break;
            }
    if (boss)
        ++t.dungeonSkipWhy["boss"];
    if (_debug || boss || t.dungeonSkipWhy[reason] <= 12)
    {
        Creature* c = SpawnCreature(bot->GetMap(), t.dungeonTarget);
        TC_LOG_INFO("playerbots", "BotLife {}: dungeon map {} skips spawn {} ({} {}) at dist {:.0f}: {}", bot->GetName(), bot->GetMapId(),
            t.dungeonTarget, c ? c->GetEntry() : 0, c ? c->GetName() : std::string("not loaded"), c ? bot->GetExactDist(c) : -1.0f, reason);
    }
    if (t.dungeonGateTarget)
        t.dungeonGateSkip.insert(t.dungeonTarget);   // the gate re-engages what the normal flow skipped
    else
        t.dungeonSkip.insert(t.dungeonTarget);
}

BotLifeInstanceSpawn const* BotLifeMgr::PickKillGate(Player* bot, BotLifeInfo const& t, Map* map, std::vector<BotLifeInstanceSpawn> const& spawns, uint32 now, Creature*& creature)
{
    static thread_local uint32 t_lastKillGateLog = 0;
    auto git = s_killGates.find(map->GetId());
    if (git == s_killGates.end())
        return nullptr;
    BotLifeKillGate const& gate = git->second;

    // is the sealed boss already open (attackable) or dead? then the gate is passed and the normal flow takes over
    bool bossFound = false;
    for (BotLifeInstanceSpawn const& s : spawns)
    {
        if (s.entry != gate.bossEntry)
            continue;
        if (Creature* boss = SpawnCreature(map, s.spawnId))
        {
            bossFound = true;
            if (!boss->IsAlive())
                return nullptr;                 // boss already killed
            if (!boss->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE))
            {
                if (now - t_lastKillGateLog > 30000 || _debug)
                {
                    t_lastKillGateLog = now;
                    TC_LOG_INFO("playerbots", "BotLife {}: kill-gate map {} boss {} is OPEN (attackable) - normal flow should engage it",
                        bot->GetName(), map->GetId(), gate.bossEntry);
                }
                return nullptr;                 // boss is open: let the normal target selection engage it
            }
        }
    }

    // the gate mobs have their own list (the neutral ones are in no other)
    auto gateSpawns = _gateSpawns.find(map->GetId());
    if (gateSpawns == _gateSpawns.end())
        return nullptr;
    uint32 diffBit = 1u << uint32(map->GetDifficulty());
    BotLifeInstanceSpawn const* best = nullptr;
    Creature* bestCreature = nullptr;
    float bestDist = 0.0f;
    uint32 alive = 0;
    for (BotLifeInstanceSpawn const& s : gateSpawns->second)
    {
        if (!gate.gateEntries.count(s.entry) || t.dungeonGateSkip.count(s.spawnId))
            continue;
        if (!(s.spawnMask & diffBit))   // spawnMask 0 is never loaded by the core
            continue;
        Creature* c = SpawnCreature(map, s.spawnId);
        if (!c)
            continue;                           // grid not loaded here; a nearer one will do
        if (!c->IsAlive())
            continue;
        if (c->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE))
            continue;                           // ignore evade and dungeonSkip on purpose: we re-engage gate mobs
        ++alive;
        float d = bot->GetExactDist(c);
        if (!best || d < bestDist)
        {
            best = &s;
            bestCreature = c;
            bestDist = d;
        }
    }
    if (!best)
    {
        if (now - t_lastKillGateLog > 30000 || _debug)
        {
            t_lastKillGateLog = now;
            TC_LOG_INFO("playerbots", "BotLife {}: kill-gate map {} returns none: bossFound={} (no living gate mob in range) - falling through to done",
                bot->GetName(), map->GetId(), bossFound);
        }
        return nullptr;                         // no gate mobs left but boss still sealed -> genuinely stuck
    }

    if (now - t_lastKillGateLog > 30000 || _debug)
    {
        t_lastKillGateLog = now;
        TC_LOG_INFO("playerbots", "BotLife {}: kill-gate map {} boss {} still sealed, {} gate mobs alive, engaging {}",
            bot->GetName(), map->GetId(), gate.bossEntry, alive, bestCreature->GetName());
    }
    creature = bestCreature;
    return best;
}

// an attacker a bot can fight: alive, attackable, no trigger (Summon Enabler Stalker and the
// like are listed as attackers but never die by a player's hand)
static bool IsFightableAttacker(Unit const* u)
{
    if (!u || !u->IsAlive() || u->HasUnitFlag(UNIT_FLAG_NON_ATTACKABLE) || u->HasUnitFlag(UNIT_FLAG_NOT_SELECTABLE) || u->HasUnitFlag(UNIT_FLAG_IMMUNE_TO_PC))
        return false;
    if (Creature const* c = u->ToCreature())
        if (c->GetCreatureTemplate()->flags_extra & CREATURE_FLAG_EXTRA_TRIGGER)
            return false;
    return true;
}
static bool HasFightableAttacker(Player const* member)
{
    for (Unit* a : member->getAttackers())
        if (IsFightableAttacker(a))
            return true;
    return false;
}

// a member of the bot's party within 40 yards on its map is attacked
static bool PartyMemberAttacked(Player* bot)
{
    Group* group = bot->GetGroup();
    if (!group)
        return false;
    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
        if (Player* member = ref->GetSource())
            if (member != bot && member->IsInWorld() && member->GetMap() == bot->GetMap() && member->IsAlive() && member->IsInCombat()
                && HasFightableAttacker(member) && bot->GetExactDist(member) < 40.0f)   // (attackerfilter)
                return true;
    return false;
}

// (bot-areatrigger) the area triggers with a script, per map (built once)
static std::vector<AreaTriggerEntry const*> const& ScriptedAreaTriggers(uint32 mapId)
{
    static std::map<uint32, std::vector<AreaTriggerEntry const*>> s_byMap;
    static bool s_built = false;
    if (!s_built)
    {
        s_built = true;
        for (uint32 i = 0; i < sAreaTriggerStore.GetNumRows(); ++i)
            if (AreaTriggerEntry const* at = sAreaTriggerStore.LookupEntry(i))
                if (sObjectMgr->GetAreaTriggerScriptId(at->ID))
                    s_byMap[at->ContinentID].push_back(at);
    }
    static std::vector<AreaTriggerEntry const*> const s_none;
    auto it = s_byMap.find(mapId);
    return it == s_byMap.end() ? s_none : it->second;
}

bool BotLifeMgr::DungeonLeaderUpdate(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    // (bot-areatrigger) a client sends the scripted area triggers its player walks into; a bot has none, so do it here
    if (now >= t.areaTriggerCheck && bot->IsAlive() && bot->GetMap()->IsDungeon())
    {
        t.areaTriggerCheck = now + 1000;
        for (AreaTriggerEntry const* at : ScriptedAreaTriggers(bot->GetMapId()))
            if (!t.areaTriggersFired.count(at->ID) && bot->IsInAreaTrigger(at))
            {
                t.areaTriggersFired.insert(at->ID);
                TC_LOG_INFO("playerbots", "BotLife {}: sets off area trigger {} on map {}", bot->GetName(), at->ID, bot->GetMapId());
                sScriptMgr->OnAreaTrigger(bot, at, true);
            }
    }
    // a boss that does not die by a player's hand never counted (Wise Mari ends herself, councils,
    // bosses that give up): what the instance itself books as done during this run counts as well
    if (InstanceMap* instanceMap = bot->GetMap()->ToInstanceMap())
        if (InstanceScript* script = instanceMap->GetInstanceScript())
        {
            uint32 done = 0;
            for (uint32 i = 0; i < 32; ++i)
                if (script->GetBossState(i) == DONE)
                    ++done;
            if (t.dungeonStateBase < 0)
                t.dungeonStateBase = int32(done);
            else if (done > uint32(t.dungeonStateBase) && done - uint32(t.dungeonStateBase) > t.dungeonBosses)
                t.dungeonBosses = done - uint32(t.dungeonStateBase);
        }
    if (bot->IsInCombat())
    {
        // in combat for 3 minutes without a victim and without a kill: say who attacks, skip them, clear it
        auto& lc = t.leadCombat;   // (kills seen, since), per leader
        if (bot->GetVictim() || lc.first != t.dungeonKills || !lc.second)
        {
            lc.first = t.dungeonKills;
            lc.second = now;
        }
        else if (now - lc.second > 180000)
        {
            lc.second = now;
            uint32 n = 0;
            for (Unit* attacker : bot->getAttackers())
            {
                ++n;
                TC_LOG_INFO("playerbots", "BotLife: leader combat attacker of {}: {} entry {} at {:.0f} {:.0f} {:.0f}, {:.0f} yd, alive {}, flags {:#x}, spawn {}",
                    bot->GetName(), attacker->GetName(), attacker->GetEntry(), attacker->GetPositionX(), attacker->GetPositionY(),
                    attacker->GetPositionZ(), bot->GetExactDist(attacker), attacker->IsAlive() ? 1 : 0, attacker->GetUInt32Value(UNIT_FIELD_FLAGS),
                    attacker->ToCreature() ? attacker->ToCreature()->GetSpawnId() : 0);
                if (Creature* ac = attacker->ToCreature())
                    t.dungeonSkip.insert(uint32(ac->GetSpawnId()));
            }
            TC_LOG_INFO("playerbots", "BotLife: leader {} in combat 3 min without a victim or a kill ({} attackers) - combat stop", bot->GetName(), n);
            QueueCombatStop(bot);
        }
        t.lastCombat = now;
        t.resting = false;
        t.dungeonEngageSince = 0;
        return false;
    }
    // the party fights while the leader is not hit - no looting, resting or walking on (to the next
    // pack): it stands by its party and the engine fights (a tank picks the mobs up)
    if (bot->IsAlive() && PartyMemberAttacked(bot))
    {
        // three minutes of "fighting" without a kill: the fight is stuck (unreachable mob,
        // a member chasing something it cannot hit) - stop it, skip that spawn and go on
        auto& nk = t.noKill;   // (kills seen, since), per leader
        if (nk.first != t.dungeonKills || !nk.second)
        {
            nk.first = t.dungeonKills;
            nk.second = now;
        }
        else if (now - nk.second > 180000)
        {
            nk.second = now;
            TC_LOG_INFO("playerbots", "BotLife: {} stuck fight in dungeon map {} at {:.0f} {:.0f} {:.0f}: party in combat 3 min without a kill - combat stop, target spawn {} skipped",
                bot->GetName(), bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), t.dungeonTarget);
            if (Group* group = bot->GetGroup())
                for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                    if (Player* member = ref->GetSource())
                        if (member != bot && member->GetMap() == bot->GetMap())
                        {
                            // who holds this member in combat
                            for (Unit* attacker : member->getAttackers())
                                TC_LOG_INFO("playerbots", "BotLife: stuck fight attacker of {} ({:.0f} yd from the leader): {} entry {} at {:.0f} {:.0f} {:.0f}, {:.0f} yd from the member, alive {}, flags {:#x}, evading {}",
                                    member->GetName(), bot->GetExactDist(member), attacker->GetName(), attacker->GetEntry(),
                                    attacker->GetPositionX(), attacker->GetPositionY(), attacker->GetPositionZ(), member->GetExactDist(attacker),
                                    attacker->IsAlive() ? 1 : 0, attacker->GetUInt32Value(UNIT_FIELD_FLAGS),
                                    attacker->ToCreature() && attacker->ToCreature()->IsInEvadeMode() ? 1 : 0);
                            QueueCombatStop(member);
                        }
            if (t.dungeonTarget)
                t.dungeonSkip.insert(t.dungeonTarget);
            t.dungeonTarget = 0;
            t.hasDest = false;
            return false;
        }
        t.lastCombat = now;
        t.resting = false;
        t.lootTarget.Clear();
        if (bot->IsSitState())
            bot->SetStandState(UNIT_STAND_STATE_STAND);
        if (bot->isMoving() && bot->GetMotionMaster()->GetCurrentMovementGeneratorType() == POINT_MOTION_TYPE)
            bot->StopMoving();
        return false;
    }
    if (bot->HasUnitState(UNIT_STATE_CASTING))
        return false;

    if (_loot && (!t.lootTarget.IsEmpty() || !t.lootQueue.empty()) && DoLoot(bot, t, now))
        return true;
    if (now >= t.nextBagCheck)
    {
        t.nextBagCheck = now + urand(45000, 75000);
        ManageBags(bot);
    }
    if (_rest && DoRest(bot, t, now))
        return true;

    // stay with an event NPC we started by gossip (escort: Muyoh in Wailing Caverns, ...); the
    // event's adds come to us, the engine fights them
    if (!t.escortNpc.IsEmpty())
    {
        Creature* npc = ObjectAccessor::GetCreature(*bot, t.escortNpc);
        if (!npc || !npc->IsAlive() || !npc->IsInWorld() || now > t.escortUntil)
            t.escortNpc.Clear();
        else
        {
            if (bot->GetExactDist(npc) > 6.0f && (!bot->isMoving() || now - t.lastMoveOrder > 2000))
            {
                bot->GetMotionMaster()->MoveFollow(npc, 3.0f, float(M_PI));
                t.lastMoveOrder = now;
            }
            return true;
        }
    }
    // the quests of the dungeon - taken from the NPCs at the entrance, handed in at the end
    if (bot->IsAlive() && !bot->IsInCombat())
    {
        auto npcsIt = s_dungeonQuestNpcs.find(bot->GetMapId());
        if (npcsIt != s_dungeonQuestNpcs.end())
        {
            // (a map is updated by any worker thread: one shared table, under a lock)
            static std::mutex s_questRunsLock;
            static std::map<std::pair<uint64, uint32>, DungeonQuestRun> s_questRuns;
            std::lock_guard<std::mutex> questRunsGuard(s_questRunsLock);
            if (s_questRuns.size() > 2000)
                s_questRuns.clear();
            DungeonQuestRun& run = s_questRuns[{ bot->GetGUID().GetCounter(), bot->GetInstanceId() }];
            Map* qmap = bot->GetMap();
            std::vector<Player*> members;
            if (Group* group = bot->GetGroup())
                for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                    if (Player* member = ref->GetSource())
                        if (member->GetMap() == qmap && member->IsAlive() && !member->IsInCombat() && GET_PLAYERBOT_AI(member))
                            members.push_back(member);
            // what this NPC has for the party: hand-ins (2) or quests to take (1)
            auto worth = [&](uint32 entry) -> uint32
            {
                uint32 best = 0;
                for (Player* m : members)
                {
                    for (uint32 questId : sObjectMgr->GetCreatureQuestInvolvedRelations(entry))
                        if (m->GetQuestStatus(questId) == QUEST_STATUS_COMPLETE)
                            return 2;
                    if (ActiveQuestCount(m) >= MAX_QUEST_LOG_SIZE - 1)
                        continue;
                    for (uint32 questId : sObjectMgr->GetCreatureQuestRelations(entry))
                    {
                        Quest const* q = sObjectMgr->GetQuestTemplate(questId);
                        if (q && m->GetQuestStatus(questId) == QUEST_STATUS_NONE && (q->GetQuestLevel() <= 0 || q->GetQuestLevel() <= int32(m->GetLevel()) + 3)
                            && m->CanTakeQuest(q, false) && m->CanAddQuest(q, false))
                            best = 1;
                    }
                }
                return best;
            };
            // at it: every member near hands in and takes
            auto talk = [&](Creature* npc)
            {
                uint32 taken = 0, handed = 0;
                for (Player* m : members)
                {
                    if (m->GetExactDist(npc) > 40.0f)
                        continue;
                    for (uint32 questId : sObjectMgr->GetCreatureQuestInvolvedRelations(npc->GetEntry()))
                        if (m->GetQuestStatus(questId) == QUEST_STATUS_COMPLETE && TurnIn(m, npc, questId))
                            ++handed;
                    for (uint32 questId : sObjectMgr->GetCreatureQuestRelations(npc->GetEntry()))
                    {
                        Quest const* q = sObjectMgr->GetQuestTemplate(questId);
                        if (!q || ActiveQuestCount(m) >= MAX_QUEST_LOG_SIZE - 1 || m->GetQuestStatus(questId) != QUEST_STATUS_NONE
                            || (q->GetQuestLevel() > 0 && q->GetQuestLevel() > int32(m->GetLevel()) + 3)
                            || !m->CanTakeQuest(q, false) || !m->CanAddQuest(q, false))
                            continue;
                        m->AddQuestAndCheckCompletion(q, npc);
                        if (m->GetQuestStatus(questId) != QUEST_STATUS_NONE)
                            ++taken;
                    }
                }
                TC_LOG_INFO("playerbots", "BotLife {}: dungeon quests at {} ({}) in map {}: {} taken, {} handed in", bot->GetName(), npc->GetName(),
                    npc->GetEntry(), qmap->GetId(), taken, handed);
            };
            bool const start = t.dungeonKills == 0;
            if (run.walkTo)
            {
                Creature* npc = SpawnCreature(qmap, run.walkTo);
                if (!npc && now - run.walkSince < 15000)
                    return true;   // (part 2: set down at its spawn point - its grid is loading)
                bool const reached = npc && (bot->GetExactDist(npc) <= INTERACTION_DISTANCE
                    || (bot->GetExactDist2d(npc) <= INTERACTION_DISTANCE && std::fabs(bot->GetPositionZ() - npc->GetPositionZ()) < 12.0f));
                if (!npc || !npc->IsAlive() || reached || now - run.walkSince > 30000)
                {
                    if (npc && npc->IsAlive() && reached)
                        talk(npc);
                    (t.dungeonDone ? run.handInVisited : run.visited).insert(run.walkTo);   // (part 3)
                    run.walkTo = 0;
                    if (bot->isMoving())
                        bot->StopMoving();
                }
                else
                {
                    if (!bot->isMoving() || now - t.lastMoveOrder > 2500)
                    {
                        bot->GetMotionMaster()->MovePoint(0, npc->GetPositionX(), npc->GetPositionY(), npc->GetPositionZ(), true);
                        t.lastMoveOrder = now;
                    }
                    return true;
                }
            }
            else if (now >= run.nextScan)
            {
                run.nextScan = now + 5000;
                Creature* pick = nullptr;
                float pickDist = 0.0f;
                std::set<uint32> const& seen = t.dungeonDone ? run.handInVisited : run.visited;   // (part 3)
                for (DungeonQuestNpc const& qn : npcsIt->second)
                {
                    if (seen.count(qn.spawnId))
                        continue;
                    Creature* npc = SpawnCreature(qmap, qn.spawnId);
                    if (!npc || !npc->IsAlive() || npc->IsHostileTo(bot) || npc->IsInCombat())
                        continue;
                    float const d = bot->GetExactDist(npc);
                    uint32 const w = (d <= (start ? 70.0f : 30.0f) || t.dungeonDone) ? worth(npc->GetEntry()) : 0;
                    // at the end only for hand-ins
                    if (!w || (t.dungeonDone && w < 2 && d > 30.0f))
                        continue;
                    if (!pick || d < pickDist)
                    {
                        pick = npc;
                        pickDist = d;
                    }
                }
                if (pick)
                {
                    if (pickDist > 60.0f && t.dungeonDone && !RealPlayerNear(bot, 100000.0f))
                    {
                        // the end of the run, nobody watching: the party is set down next to the NPC
                        for (Player* m : members)
                            QueueTeleport(m, qmap->GetId(), pick->GetPositionX() + frand(-2.0f, 2.0f), pick->GetPositionY() + frand(-2.0f, 2.0f),
                                pick->GetPositionZ() + 0.5f, pick->GetOrientation());
                        TC_LOG_INFO("playerbots", "BotLife {}: sets the party down at quest NPC {} ({}) in map {} to hand in", bot->GetName(),
                            pick->GetName(), pick->GetEntry(), qmap->GetId());
                    }
                    else if (pickDist > 60.0f && t.dungeonDone)
                    {
                        run.handInVisited.insert(pick->GetSpawnId());   // too far with a real player around: left to the player
                        pick = nullptr;
                    }
                    if (pick)
                    {
                        run.walkTo = pick->GetSpawnId();
                        run.walkSince = now;
                        return true;
                    }
                }
                // (part 2) the end of the run: a quest NPC whose grid is no longer loaded counts by its spawn point
                if (!pick && t.dungeonDone && !RealPlayerNear(bot, 100000.0f))
                {
                    DungeonQuestNpc const* far = nullptr;
                    float farDist = 0.0f;
                    for (DungeonQuestNpc const& qn : npcsIt->second)
                    {
                        if (run.handInVisited.count(qn.spawnId) || SpawnCreature(qmap, qn.spawnId) || worth(qn.entry) < 2)
                            continue;
                        float const d = bot->GetExactDist(qn.x, qn.y, qn.z);
                        if (!far || d < farDist)
                        {
                            far = &qn;
                            farDist = d;
                        }
                    }
                    if (far)
                    {
                        for (Player* m : members)
                            QueueTeleport(m, qmap->GetId(), far->x + frand(-2.0f, 2.0f), far->y + frand(-2.0f, 2.0f), far->z + 0.5f, bot->GetOrientation());
                        TC_LOG_INFO("playerbots", "BotLife {}: sets the party down at the spawn of quest NPC {} (not loaded) in map {} to hand in",
                            bot->GetName(), far->entry, qmap->GetId());
                        run.walkTo = far->spawnId;
                        run.walkSince = now;
                        return true;
                    }
                }
            }
        }
    }
    if (t.dungeonDone)
        return false;

    // wait for the group: members far behind, resting, looting, or dead (the world thread resurrects them);
    // waiting does not count against the target / pull timeouts
    bool wait = PartyLeaderWait(bot, t, now);
    if (!wait)
        if (Group* group = bot->GetGroup())
            for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                if (Player* member = ref->GetSource())
                    // (lfg-rez-wait) also for a real player who lies dead on this map and has not released: the healer's own
                    // resurrection needs the group to stay; a player who released is not waited for here
                    if (member != bot && !member->IsAlive() && now - t.lastCombat < 60000 && member->GetSession()
                        && (member->GetSession()->IsBot()
                            || (member->FindMap() == bot->FindMap() && member->getDeathState() == DeathState::CORPSE
                                && !member->HasAuraType(SPELL_AURA_GHOST))))
                    {
                        if (bot->isMoving())
                            bot->StopMoving();
                        wait = true;
                        break;
                    }
    uint32 tickDelta = t.dungeonLastTick ? std::min<uint32>(now - t.dungeonLastTick, 2000) : 0;
    t.dungeonLastTick = now;
    if (wait)
    {
        t.dungeonEngageSince = 0;
        return true;
    }
    t.dungeonTargetActive += tickDelta;

    Map* map = bot->GetMap();
    auto spawnsIt = _instanceSpawns.find(map->GetId());
    if (spawnsIt == _instanceSpawns.end())
    {
        t.dungeonDone = true;
        return false;
    }
    uint32 diffBit = 1u << uint32(map->GetDifficulty());

    // a boss on a part of the map the navmesh does not connect (Lord Serpentis and Verdan on their ledge
    // in Wailing Caverns, Lord Godfrey in Shadowfang Keep). With no real player in the instance the party is set down
    // about 15 yards from the boss, on its own part of the map, at most twice per run (the count is kept in
    // dungeonDynPicks under a key no creature has).
    auto hopToBoss = [&](Creature* boss) -> bool
    {
        static constexpr uint32 BOSS_HOP_KEY = 0xFFFFFFFFu;
        if (!boss || !boss->IsAlive() || !bot->IsValidAttackTarget(boss) || RealPlayerNear(bot, 100000.0f))
            return false;
        uint32& hops = t.dungeonDynPicks[BOSS_HOP_KEY];
        if (hops >= 2)
            return false;
        ++hops;
        float x = boss->GetPositionX(), y = boss->GetPositionY(), z = boss->GetPositionZ();
        PathGenerator path(boss);
        path.CalculatePath(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), false);
        Movement::PointsArray const& points = path.GetPath();
        if ((path.GetPathType() & (PATHFIND_NORMAL | PATHFIND_INCOMPLETE)) && !(path.GetPathType() & PATHFIND_NOT_USING_PATH))
        {
            // 15 yards along the boss's path towards the party
            float walked = 0.0f;
            for (size_t i = 1; i < points.size(); ++i)
            {
                float const seg = (points[i] - points[i - 1]).length();
                if (seg > 0.0f && walked + seg >= 15.0f)
                {
                    G3D::Vector3 const p = points[i - 1] + (points[i] - points[i - 1]) * ((15.0f - walked) / seg);
                    x = p.x;
                    y = p.y;
                    z = p.z;
                    break;
                }
                walked += seg;
                x = points[i].x;
                y = points[i].y;
                z = points[i].z;
            }
        }
        else
        {
            // no path from the boss either: 5 yards from it towards the party, on the ground there
            float const angle = boss->GetAngle(bot);
            x = boss->GetPositionX() + std::cos(angle) * 5.0f;
            y = boss->GetPositionY() + std::sin(angle) * 5.0f;
            float const ground = map->GetHeight(boss->GetPhaseMask(), x, y, boss->GetPositionZ() + 3.0f, true, 10.0f);
            z = ground > INVALID_HEIGHT ? ground : boss->GetPositionZ();
        }
        float const o = std::atan2(boss->GetPositionY() - y, boss->GetPositionX() - x);
        TC_LOG_INFO("playerbots", "BotLife {}: map {} sets the party down at boss {} ({}): no path from {:.0f} {:.0f} {:.0f}, now at {:.0f} {:.0f} {:.0f} ({:.0f} yd from it)",
            bot->GetName(), map->GetId(), boss->GetName(), boss->GetEntry(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(),
            x, y, z, boss->GetExactDist(x, y, z));
        if (Group* group = bot->GetGroup())
            for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                if (Player* member = ref->GetSource())
                    if (member->GetMap() == map && member->IsAlive())
                        QueueTeleport(member, map->GetId(), x + frand(-2.0f, 2.0f), y + frand(-2.0f, 2.0f), z + 0.5f, o);
        t.hasDest = false;
        t.path.clear();
        Count(BLC_UNSTUCK);
        return true;
    };

    // a boss whose grid is not loaded (far away): the party is set down at its spawn point, same rules
    auto hopToSpawn = [&](BotLifeInstanceSpawn const& s) -> bool
    {
        if (RealPlayerNear(bot, 100000.0f))
            return false;
        uint32& hops = t.dungeonDynPicks[0xFFFFFFFFu];
        if (hops >= 2)
            return false;
        ++hops;
        float const o = std::atan2(s.y - bot->GetPositionY(), s.x - bot->GetPositionX());
        TC_LOG_INFO("playerbots", "BotLife {}: map {} sets the party down at the spawn of boss {} (not loaded): no path from {:.0f} {:.0f} {:.0f}",
            bot->GetName(), map->GetId(), s.entry, bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ());
        if (Group* group = bot->GetGroup())
            for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                if (Player* member = ref->GetSource())
                    if (member->GetMap() == map && member->IsAlive())
                        QueueTeleport(member, map->GetId(), s.x + frand(-2.0f, 2.0f), s.y + frand(-2.0f, 2.0f), s.z + 0.5f, o);
        t.hasDest = false;
        t.path.clear();
        Count(BLC_UNSTUCK);
        return true;
    };

    // keep the current target while it is valid
    BotLifeInstanceSpawn const* current = nullptr;
    Creature* creature = nullptr;
    if (t.dungeonTarget && t.dungeonGateTarget)
    {
        // a kill-gate mob stays the target until it is dead (evading or skipped earlier does not matter)
        auto gateSpawns = _gateSpawns.find(map->GetId());
        if (gateSpawns != _gateSpawns.end())
            for (BotLifeInstanceSpawn const& s : gateSpawns->second)
                if (s.spawnId == t.dungeonTarget)
                {
                    current = &s;
                    break;
                }
        creature = current ? SpawnCreature(map, current->spawnId) : nullptr;
        if (!creature || !creature->IsAlive() || t.dungeonGateSkip.count(t.dungeonTarget)
            || creature->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE))
            current = nullptr;
        else if (t.dungeonTargetActive > DUNGEON_TARGET_TIMEOUT)
        {
            SkipDungeonTarget(bot, t, "gate target timeout");
            current = nullptr;
        }
        if (!current)
            creature = nullptr;
    }
    else if (t.dungeonTarget)
    {
        for (BotLifeInstanceSpawn const& s : spawnsIt->second)
            if (s.spawnId == t.dungeonTarget)
            {
                current = &s;
                break;
            }
        if (!current || !DungeonTargetValid(bot, t, *current, diffBit, creature))
            current = nullptr;
        else if (t.dungeonTargetActive > DUNGEON_TARGET_TIMEOUT)
        {
            SkipDungeonTarget(bot, t, "target timeout");
            current = nullptr;
        }
    }

    if (!current)
    {
        t.dungeonTarget = 0;
        t.dungeonGateTarget = false;
        t.dungeonEngageSince = 0;
        bool hasBoss = false, bossLeft = false;
        std::vector<std::tuple<float, BotLifeInstanceSpawn const*, Creature*>> candidates;
        for (BotLifeInstanceSpawn const& s : spawnsIt->second)
        {
            if (s.boss && (s.spawnMask & diffBit))   // spawnMask 0 is never loaded by the core
                hasBoss = true;
            Creature* c = nullptr;
            if (!DungeonTargetValid(bot, t, s, diffBit, c))
                continue;
            if (s.boss)
                bossLeft = true;
            float x = c ? c->GetPositionX() : s.x, y = c ? c->GetPositionY() : s.y, z = c ? c->GetPositionZ() : s.z;
            float dx = bot->GetPositionX() - x, dy = bot->GetPositionY() - y, dz = (bot->GetPositionZ() - z) * 3.0f;
            candidates.emplace_back(dx * dx + dy * dy + dz * dz, &s, c);
        }
        std::sort(candidates.begin(), candidates.end(), [](auto const& a, auto const& b) { return std::get<0>(a) < std::get<0>(b); });
        // a run that already skipped many empty spawns (End Time: 70-100 'nothing at spawn') takes the creatures
        // that really exist first - a spawn of another timeline is not worth the walk
        if (t.dungeonSkip.size() >= 12)
            std::stable_partition(candidates.begin(), candidates.end(), [](auto const& a) { return std::get<2>(a) != nullptr; });
        // nearest one the navmesh can actually reach (floors above / below are close but far away on foot)
        uint32 tried = 0;
        for (auto const& cand : candidates)
        {
            BotLifeInstanceSpawn const* s = std::get<1>(cand);
            Creature* c = std::get<2>(cand);
            float x = c ? c->GetPositionX() : s->x, y = c ? c->GetPositionY() : s->y, z = c ? c->GetPositionZ() : s->z;
            if (++tried > 6)
            {
                current = s;   // stop testing paths, the stuck detection handles the rest
                creature = c;
                break;
            }
            PathGenerator path(bot);
            path.CalculatePath(x, y, z, false);
            G3D::Vector3 const& end = path.GetActualEndPosition();
            float ex = end.x - x, ey = end.y - y, ez = end.z - z;
            // a boss far away up a long ramp (Lord Serpentis): the search stops short of it - a partial
            // path that brings the party at least 25 yards closer is taken, the search from there goes on (a real dead
            // end is found by the stuck detection)
            // (part 2: any target, not only a boss)
            bool const closer = (path.GetPathType() & PATHFIND_INCOMPLETE)
                && std::sqrt(ex * ex + ey * ey + ez * ez) + 25.0f < bot->GetExactDist(x, y, z);
            if (((path.GetPathType() & PATHFIND_NORMAL) && ex * ex + ey * ey + ez * ez < 12.0f * 12.0f) || closer)
            {
                current = s;
                creature = c;
                break;
            }
            if (OpenDoorsNear(bot, 45.0f))
                return true;   // path may be free now: choose again next update
            if (s->boss && (c ? hopToBoss(c) : hopToSpawn(*s)))
            {
                current = s;
                creature = c;
                break;
            }
            t.dungeonTarget = s->spawnId;
            SkipDungeonTarget(bot, t, "no path");
            t.dungeonTarget = 0;
        }
        // all bosses down: the run is done, the leftover trash can stay
        if (current && hasBoss && !bossLeft && t.dungeonBosses)
            current = nullptr;
        // MoP kill-gate - clear the gate mobs so the sealed boss (Ook-Ook e.d.) becomes attackable.
        // (1-10: before the targets outside the spawn list - the first run found 43 hozen and then spent its thirty
        // minutes on summoned hoplings.)
        bool gatePicked = false;
        if (!current)
            if (BotLifeInstanceSpawn const* gate = PickKillGate(bot, t, map, spawnsIt->second, now, creature))
            {
                current = gate;
                gatePicked = true;
                Count(BLC_KILL_GATE);
            }
        // what an encounter summoned, or a boss that opened up during the run, is in no spawn list
        if (!current)
            if (Creature* unlisted = PickUnlistedTarget(bot, t, now, tickDelta))
            {
                if (!EngageUnlistedTarget(botAI, t, unlisted, now))
                {
                    t.dungeonDynSkip.insert(unlisted->GetGUID());
                    t.dungeonDynTarget.Clear();
                }
                t.state = BotLifeState::GO_GRIND;
                return true;
            }
        // nothing to fight - maybe an event has to be started by talking to an NPC first
        if (!current && TryEventGossip(botAI, t, now))
            return true;
        // a boss that is still sealed - walk up to it, many encounters begin when a player comes near
        if (!current && VisitSealedBoss(bot, t, map, diffBit, now, tickDelta))
            return true;
        if (!current)
        {
            t.dungeonDone = true;   // nothing left: the world thread brings us home
            // always say why bosses are left over (scripted encounters: Stormstout Brewery ended 0/2)
            if (_debug || hasBoss)
                for (BotLifeInstanceSpawn const& s : spawnsIt->second)
                {
                    if (!s.boss || (!(s.spawnMask & diffBit)))
                        continue;
                    Creature* c = SpawnCreature(map, s.spawnId);
                    TC_LOG_INFO("playerbots", "BotLife {}: map {} boss spawn {} entry {} left: {}", bot->GetName(), map->GetId(), s.spawnId, s.entry,
                        !c ? "not loaded" : !c->IsAlive() ? "dead" : t.dungeonSkip.count(s.spawnId) ? "skipped"
                        : c->IsInEvadeMode() ? "evading" : c->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE) ? "not attackable"
                        : !bot->IsValidAttackTarget(c, nullptr, nullptr, true) ? "no valid target" : "?");
                }
            if (_debug)
                TC_LOG_INFO("playerbots", "BotLife {}: dungeon map {} cleared ({} kills, {} bosses)", bot->GetName(), map->GetId(),
                    t.dungeonKills, t.dungeonBosses);
            return false;
        }
        t.dungeonTarget = current->spawnId;
        t.dungeonGateTarget = gatePicked;
        t.dungeonTargetSince = now;
        t.dungeonTargetActive = 0;
        t.state = BotLifeState::GO_GRIND;
    }

    float tx = creature ? creature->GetPositionX() : current->x;
    float ty = creature ? creature->GetPositionY() : current->y;
    float tz = creature ? creature->GetPositionZ() : current->z;
    float dist = bot->GetExactDist(tx, ty, tz);

    // close by, the line of sight can be blocked by a step or a railing: pull anyway (the chase finds a path)
    if (creature && (dist < 12.0f || (dist < 30.0f && bot->IsWithinLOSInMap(creature))))
    {
        // pull
        if (!t.dungeonEngageSince)
            t.dungeonEngageSince = now;
        else if (now - t.dungeonEngageSince > DUNGEON_ENGAGE_TIMEOUT)
        {
            SkipDungeonTarget(bot, t, "engage timeout");
            t.dungeonTarget = 0;
            return true;
        }
        botAI->GetAiObjectContext()->GetValue<Unit*>("current target")->Set(creature);
        bot->SetSelection(creature->GetGUID());
        bool ranged = PlayerBotSpec::IsRanged(bot);   // see EngageQuestCreature
        if (bot->GetVictim() != creature)
            bot->Attack(creature, !ranged);
        if (!bot->isMoving() || now - t.lastMoveOrder > 2000)
        {
            bot->GetMotionMaster()->MoveChase(creature, ranged ? 25.0f : 0.0f);
            t.lastMoveOrder = now;
        }
        return true;
    }

    if (!creature && dist < 12.0f)
    {
        // arrived at a spawn point but nothing is there (other difficulty, despawned, scripted)
        SkipDungeonTarget(bot, t, "nothing at spawn");
        t.dungeonTarget = 0;
        return true;
    }

    if (!t.hasDest || t.destMap != map->GetId() || std::fabs(t.destX - tx) > 5.0f || std::fabs(t.destY - ty) > 5.0f)
        SetDest(t, map->GetId(), tx, ty, tz, 8.0f);
    Travel(bot, t, now);
    if (!t.hasDest)
    {
        // stuck: a closed door, or this one is not reachable
        if (OpenDoorsNear(bot, 45.0f))
            return true;
        if (current->boss && hopToBoss(creature))
            return true;
        SkipDungeonTarget(bot, t, "unreachable");
        t.dungeonTarget = 0;
    }
    return true;
}

// ---------------------------------------------------------------------------------------------
// targets that are not in the spawn list. The leader only walked from listed spawn to listed spawn, so
// whatever an encounter summons (Yan-Zhu, the adds that open a gate) and every boss that is not hostile and attackable
// in its template (sealed until an event, friendly until talked to) did not exist for it.
namespace
{
    struct UnlistedTargetCheck
    {
        Player* bot;
        BotLifeInfo const& t;
        BotLifeMgr const* mgr;
        std::unordered_set<uint32> const& listed;
        float range;

        bool operator()(Creature* c) const
        {
            if (!c->IsAlive() || c->IsInEvadeMode() || (c->GetSpawnId() && listed.count(uint32(c->GetSpawnId())))
                || t.dungeonDynSkip.count(c->GetGUID()))
                return false;
            if (c->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_IMMUNE_TO_PC))
                return false;
            if (c->IsTrigger() || c->IsPet() || c->IsTotem() || c->GetCharmerOrOwnerPlayerOrPlayerItself())
                return false;
            uint32 const type = c->GetCreatureTemplate()->type;
            if (type == CREATURE_TYPE_CRITTER || type == CREATURE_TYPE_NON_COMBAT_PET || type == CREATURE_TYPE_TOTEM)
                return false;
            bool const boss = mgr->IsBossEntry(c->GetEntry());
            if (!boss && c->GetLevel() > bot->GetLevel() + 10)
                return false;
            // an encounter can summon without end (the hoplings and boppers of Stormstout Brewery kept a
            // party busy for the whole run): five of one entry is enough, a boss always counts
            if (!boss)
            {
                auto picks = t.dungeonDynPicks.find(c->GetEntry());
                if (picks != t.dungeonDynPicks.end() && picks->second >= 5)
                    return false;
            }
            if (!bot->IsWithinDistInMap(c, range) || !c->IsHostileTo(bot))
                return false;
            return bot->IsValidAttackTarget(c, nullptr, nullptr, true);
        }
    };

    constexpr uint32 DUNGEON_UNLISTED_TIMEOUT = 60000;    // on one unlisted target without getting into combat
    constexpr uint32 DUNGEON_SEALED_TIMEOUT = 120000;     // walking up to one sealed boss
    constexpr uint32 DUNGEON_SEALED_WAIT = 15000;         // standing next to it
}

Creature* BotLifeMgr::PickUnlistedTarget(Player* bot, BotLifeInfo& t, uint32 now, uint32 tickDelta)
{
    static thread_local uint32 t_lastUnlistedLog = 0;
    UnlistedTargetCheck check{ bot, t, this, _instanceSpawnIds, 80.0f };
    Creature* target = nullptr;
    if (!t.dungeonDynTarget.IsEmpty())
    {
        target = ObjectAccessor::GetCreature(*bot, t.dungeonDynTarget);
        if (target && !check(target))
            target = nullptr;
        if (target)
        {
            t.dungeonDynActive += tickDelta;
            if (t.dungeonDynActive > DUNGEON_UNLISTED_TIMEOUT)
            {
                TC_LOG_INFO("playerbots", "BotLife {}: map {} gives up on unlisted target {} ({}) at dist {:.0f}", bot->GetName(), bot->GetMapId(),
                    target->GetName(), target->GetEntry(), bot->GetExactDist(target));
                t.dungeonDynSkip.insert(t.dungeonDynTarget);
                target = nullptr;
            }
        }
        if (!target)
            t.dungeonDynTarget.Clear();
    }
    if (!target && t.dungeonDynSkip.size() < 8)
    {
        std::list<Creature*> found;
        Trinity::CreatureListSearcher<UnlistedTargetCheck> searcher(bot, found, check);
        CellCoord pair(Trinity::ComputeCellCoord(bot->GetPositionX(), bot->GetPositionY()));
        Cell cell(pair);
        cell.SetNoCreate();
        TypeContainerVisitor<Trinity::CreatureListSearcher<UnlistedTargetCheck>, GridTypeMapContainer> visitor(searcher);
        cell.Visit(pair, visitor, *bot->GetMap(), *bot, check.range);
        for (Creature* c : found)
            if (!target || bot->GetExactDist(c) < bot->GetExactDist(target))
                target = c;
        if (target)
        {
            t.dungeonDynTarget = target->GetGUID();
            t.dungeonDynActive = 0;
            ++t.dungeonDynPicks[target->GetEntry()];
            if (IsBossEntry(target->GetEntry()) || now - t_lastUnlistedLog > 20000 || _debug)
            {
                t_lastUnlistedLog = now;
                TC_LOG_INFO("playerbots", "BotLife {}: map {} unlisted target {} ({}{}) at dist {:.0f}, {} in reach", bot->GetName(), bot->GetMapId(),
                    target->GetName(), target->GetEntry(), target->GetSpawnId() ? "" : ", summoned", bot->GetExactDist(target), uint32(found.size()));
            }
        }
    }
    return target;
}

// walks to a creature and pulls it; false when it cannot be reached
// A scenario played by the lead of a dungeon finder test group. A Brewing Storm (map 1005): three chapters that Brewmaster Blanche
// starts from her gossip (actions 1001-1003), each one ends by the instance script (chapter data 0, 1, 2 == DONE). Chapter 1: the
// storm sets kegs on fire - put them out (spell click) and fight the sauroks; chapter 2: follow Blanche on the road; chapter 3:
// defend the refuge and kill Borokhula (the Boomer Brew Strike button when the script hands it out). True while the lead is busy.
bool BotLifeMgr::ScenarioLeadTick(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    if (bot->GetMapId() != 1005)
        return false;
    InstanceScript* script = bot->GetInstanceScript();
    if (!script)
        return false;
    enum { NPC_BLANCHE = 58740, NPC_KEG = 58916, NPC_BOROKHULA = 58739, SPELL_KEG_ON_FIRE = 111995, SPELL_BREW_STRIKE_BUTTON = 115101 };
    static uint32 const hostiles[] = { 58738, 58737, 71353, 58739 };
    uint32 const chapter = script->GetData(0) != DONE ? 1 : script->GetData(1) != DONE ? 2 : script->GetData(2) != DONE ? 3 : 4;
    auto note = [&](std::string const& text)
    {
        if (now - t.lastMoveOrder < 15000 && text == t.scenarioNote)
            return;
        t.scenarioNote = text;
        TC_LOG_INFO("playerbots", "SCENARIO {} (map 1005, chapter {}): {}", bot->GetName(), chapter, text);
    };
    if (!t.lfgTestAt)
    {
        t.lfgTestAt = now + 15000;   // the others come in
        note("lead in");
        return true;
    }
    if (chapter == 4)
    {
        if (t.lfgTestAt != UINT32_MAX)
        {
            t.lfgTestAt = UINT32_MAX;
            note("all chapters done");
        }
        return false;
    }
    if (now < t.lfgTestAt)
        return true;
    // scenariokegs: chapter 1 only ends when the lightning keeps hitting kegs that do not burn (each hit fills the
    // brew bar) and the saurok waves keep coming until then - so a burning keg goes before the fight, for the member nearest to it
    if (chapter == 1 && bot->IsInCombat() && bot->GetHealthPct() > 35.0f)
    {
        enum { SPELL_EXTINGUISHING = 111961 };
        Creature* keg = nullptr;
        float kegDist = 60.0f;
        std::list<Creature*> kegs;
        bot->GetCreatureListWithEntryInGrid(kegs, NPC_KEG, 60.0f);
        for (Creature* k : kegs)
            if (k->IsAlive() && k->HasAura(SPELL_KEG_ON_FIRE) && bot->GetExactDist(k) < kegDist)
            {
                kegDist = bot->GetExactDist(k);
                keg = k;
            }
        bool mine = keg != nullptr;
        if (keg)
            if (Group* group = bot->GetGroup())
                for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                    if (Player* member = ref->GetSource())
                    {
                        if (member == bot || !member->IsAlive() || member->GetMapId() != bot->GetMapId() || member->GetHealthPct() <= 35.0f)
                            continue;
                        float const d = member->GetExactDist(keg);
                        if (d < kegDist - 0.5f || (d <= kegDist + 0.5f && member->GetGUID().GetCounter() < bot->GetGUID().GetCounter()))
                            mine = false;
                    }
        if (mine)
        {
            if (kegDist > 4.0f)
            {
                if (!t.hasDest || t.destMap != bot->GetMapId() || std::fabs(t.destX - keg->GetPositionX()) > 5.0f || std::fabs(t.destY - keg->GetPositionY()) > 5.0f)
                    SetDest(t, bot->GetMapId(), keg->GetPositionX(), keg->GetPositionY(), keg->GetPositionZ(), 3.0f);
                Travel(bot, t, now);
                note("leaves the fight for a burning keg");
                return true;
            }
            bot->StopMoving();
            bot->CastSpell(keg, SPELL_EXTINGUISHING, true);
            note("puts out a keg (in combat)");
            t.lfgTestAt = now + 1500;
            return true;
        }
    }
    if (bot->IsInCombat())
    {
        t.lastCombat = now;
        return false;   // the engine fights
    }
    if (bot->HasUnitState(UNIT_STATE_CASTING))
        return true;
    auto travelTo = [&](WorldObject* target, float arrive)
    {
        if (!t.hasDest || t.destMap != bot->GetMapId() || std::fabs(t.destX - target->GetPositionX()) > 5.0f || std::fabs(t.destY - target->GetPositionY()) > 5.0f)
            SetDest(t, bot->GetMapId(), target->GetPositionX(), target->GetPositionY(), target->GetPositionZ(), arrive);
        Travel(bot, t, now);
    };
    // a saurok (or Borokhula) in reach: fight
    Creature* hostile = nullptr;
    float bestDist = 35.0f;
    for (uint32 entry : hostiles)
        if (Creature* c = bot->FindNearestCreature(entry, 35.0f, true))
            if (bot->IsValidAttackTarget(c) && bot->GetExactDist(c) < bestDist)
            {
                bestDist = bot->GetExactDist(c);
                hostile = c;
            }
    if (hostile)
    {
        if (hostile->GetEntry() == NPC_BOROKHULA && bot->HasSpell(SPELL_BREW_STRIKE_BUTTON) && now - t.vehicleCastAt > 6000)
        {
            bot->CastSpell(hostile, SPELL_BREW_STRIKE_BUTTON, false);
            t.vehicleCastAt = now;
            note("Boomer Brew Strike on Borokhula");
        }
        note("engages " + hostile->GetName());
        return EngageUnlistedTarget(botAI, t, hostile, now);
    }
    // chapter 1: a burning keg - put it out
    if (chapter == 1)
    {
        Creature* keg = nullptr;
        float kegDist = 60.0f;
        std::list<Creature*> kegs;
        bot->GetCreatureListWithEntryInGrid(kegs, NPC_KEG, 60.0f);
        for (Creature* k : kegs)
            if (k->IsAlive() && k->HasAura(SPELL_KEG_ON_FIRE) && bot->GetExactDist(k) < kegDist)
            {
                kegDist = bot->GetExactDist(k);
                keg = k;
            }
        if (keg)
        {
            if (kegDist > 4.0f)
            {
                travelTo(keg, 3.0f);
                note("walks to a burning keg");
                return true;
            }
            bot->StopMoving();
            keg->HandleSpellClick(bot);
            note("puts out a keg");
            t.lfgTestAt = now + 2500;
            return true;
        }
    }
    Creature* blanche = bot->FindNearestCreature(NPC_BLANCHE, 400.0f, true);
    if (!blanche)
    {
        note("no Blanche within 400 yd");
        t.lfgTestAt = now + 10000;
        return true;
    }
    // Blanche offers the next chapter
    if (blanche->HasFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_GOSSIP))
    {
        if (bot->GetExactDist(blanche) > 6.0f)
        {
            travelTo(blanche, 4.0f);
            note("walks to Blanche for chapter " + std::to_string(chapter));
            return true;
        }
        bot->StopMoving();
        bool const took = sScriptMgr->OnGossipSelect(bot, blanche, 1, 1000 + chapter);
        note(std::string("starts chapter ") + std::to_string(chapter) + (took ? " (script took it)" : " (no script answer)"));
        t.lfgTestAt = now + 5000;
        return true;
    }
    // the chapter runs: stay with Blanche (chapter 2 is her road)
    if (bot->GetExactDist(blanche) > (chapter == 2 ? 8.0f : 20.0f))
    {
        travelTo(blanche, chapter == 2 ? 5.0f : 12.0f);
        note("follows Blanche");
        return true;
    }
    note("waits with Blanche");
    return true;
}

bool BotLifeMgr::EngageUnlistedTarget(PlayerbotAI* botAI, BotLifeInfo& t, Creature* creature, uint32 now)
{
    Player* bot = botAI->GetBot();
    float const dist = bot->GetExactDist(creature);
    if (dist < 12.0f || (dist < 30.0f && bot->IsWithinLOSInMap(creature)))
    {
        botAI->GetAiObjectContext()->GetValue<Unit*>("current target")->Set(creature);
        bot->SetSelection(creature->GetGUID());
        bool ranged = PlayerBotSpec::IsRanged(bot);
        if (bot->GetVictim() != creature)
            bot->Attack(creature, !ranged);
        if (!bot->isMoving() || now - t.lastMoveOrder > 2000)
        {
            bot->GetMotionMaster()->MoveChase(creature, ranged ? 25.0f : 0.0f);
            t.lastMoveOrder = now;
        }
        return true;
    }
    float const tx = creature->GetPositionX(), ty = creature->GetPositionY(), tz = creature->GetPositionZ();
    if (!t.hasDest || t.destMap != bot->GetMapId() || std::fabs(t.destX - tx) > 5.0f || std::fabs(t.destY - ty) > 5.0f)
        SetDest(t, bot->GetMapId(), tx, ty, tz, 8.0f);
    Travel(bot, t, now);
    if (!t.hasDest && bot->GetExactDist(creature) > 12.0f)
        return OpenDoorsNear(bot, 45.0f) > 0;   // a closed door, or not reachable
    return true;
}

// A boss that is alive but no target (sealed, friendly, waiting for its event): walk up to it and stand there for a
// moment. True while the leader is busy with that.
bool BotLifeMgr::VisitSealedBoss(Player* bot, BotLifeInfo& t, Map* map, uint32 diffBit, uint32 now, uint32 tickDelta)
{
    if (now < t.dungeonSealedWait)
        return true;
    // a boss down since the last visits can have opened a sealed one (Sunken Temple: the Shade of
    // Eranikus wakes when a player walks up after Hakkar, Jammal'an and the wardens): visit again
    if (t.dungeonBosses != t.dungeonSealedBosses)
    {
        t.dungeonSealedBosses = t.dungeonBosses;
        t.dungeonSealedVisited.clear();
    }
    if (t.dungeonSealedVisited.size() >= 4)
        return false;

    BotLifeInstanceSpawn const* best = nullptr;
    Creature* bestCreature = nullptr;
    float bestDist = 0.0f;
    auto consider = [&](std::unordered_map<uint32, std::vector<BotLifeInstanceSpawn>> const& lists)
    {
        auto it = lists.find(map->GetId());
        if (it == lists.end())
            return;
        for (BotLifeInstanceSpawn const& s : it->second)
        {
            if (!s.boss || (!(s.spawnMask & diffBit)) || t.dungeonSealedVisited.count(s.spawnId))
                continue;
            if (t.dungeonSealedTarget && t.dungeonSealedTarget != s.spawnId)
                continue;   // finish the one we are on our way to
            Creature* c = SpawnCreature(map, s.spawnId);
            if (c && !c->IsAlive())
                continue;
            float const x = c ? c->GetPositionX() : s.x, y = c ? c->GetPositionY() : s.y, z = c ? c->GetPositionZ() : s.z;
            float const d = bot->GetExactDist(x, y, z);
            if (!best || d < bestDist)
            {
                best = &s;
                bestCreature = c;
                bestDist = d;
            }
        }
    };
    consider(_instanceSpawns);
    consider(_sealedBossSpawns);
    if (!best)
    {
        if (!t.dungeonSealedTarget)
            return false;
        t.dungeonSealedTarget = 0;   // the one we were walking to died or is gone: look again next update
        return true;
    }

    auto describe = [&](char const* what)
    {
        TC_LOG_INFO("playerbots", "BotLife {}: map {} sealed boss {} ({}, spawn {}) {}: dist {:.0f}, flags 0x{:X}, faction {}, {}", bot->GetName(),
            map->GetId(), bestCreature ? bestCreature->GetName() : std::string("not loaded"), best->entry, best->spawnId, what, bestDist,
            bestCreature ? bestCreature->GetUInt32Value(UNIT_FIELD_FLAGS) : 0, bestCreature ? bestCreature->GetFaction() : 0,
            !bestCreature ? "?" : bestCreature->IsHostileTo(bot) ? "hostile" : "not hostile");
    };

    if (t.dungeonSealedTarget != best->spawnId)
    {
        t.dungeonSealedTarget = best->spawnId;
        t.dungeonSealedActive = 0;
    }
    t.dungeonSealedActive += tickDelta;
    float const tx = bestCreature ? bestCreature->GetPositionX() : best->x, ty = bestCreature ? bestCreature->GetPositionY() : best->y,
        tz = bestCreature ? bestCreature->GetPositionZ() : best->z;
    if (bestDist < 10.0f)
    {
        describe("reached");
        t.dungeonSealedVisited.insert(best->spawnId);
        t.dungeonSealedTarget = 0;
        t.dungeonSealedWait = now + DUNGEON_SEALED_WAIT;
        if (bot->isMoving())
            bot->StopMoving();
        return true;
    }
    if (t.dungeonSealedActive > DUNGEON_SEALED_TIMEOUT)
    {
        describe("not reached in time");
        t.dungeonSealedVisited.insert(best->spawnId);
        t.dungeonSealedTarget = 0;
        return true;
    }
    if (!t.hasDest || t.destMap != map->GetId() || std::fabs(t.destX - tx) > 5.0f || std::fabs(t.destY - ty) > 5.0f)
        SetDest(t, map->GetId(), tx, ty, tz, 6.0f);
    Travel(bot, t, now);
    if (!t.hasDest && bot->GetExactDist(tx, ty, tz) > 10.0f && !OpenDoorsNear(bot, 45.0f))
    {
        describe("unreachable");
        t.dungeonSealedVisited.insert(best->spawnId);
        t.dungeonSealedTarget = 0;
    }
    t.state = BotLifeState::GO_GRIND;
    return true;
}

// world thread: what a run that was not a clear looked like at its end - the encounter states of the instance and the
// bosses still standing around the leader
void BotLifeMgr::LogRunEnd(BotLifeDungeon const& d, BotLifeParty const& party, Player* leader, char const* result)
{
    if (!leader || !leader->IsInWorld() || !strcmp(result, "cleared"))
        return;
    std::ostringstream line;
    if (PlayerbotAI* leaderAI = GET_PLAYERBOT_AI(leader))
    {
        BotLifeInfo const& t = leaderAI->life;
        line << ", skipped " << t.dungeonSkip.size() << " gate " << t.dungeonGateSkip.size() << " unlisted " << t.dungeonDynSkip.size()
            << ", sealed visits " << t.dungeonSealedVisited.size() << ", events " << t.gossipUsed.size();
        if (!t.dungeonSkipWhy.empty())
        {
            line << " (skip reasons";
            for (auto const& why : t.dungeonSkipWhy)
                line << ' ' << why.first << ' ' << why.second;
            line << ')';
        }
    }
    if (leader->GetMapId() != d.map)
        line << ", leader not inside";
    else
    {
        Map* map = leader->GetMap();
        if (InstanceMap* instanceMap = map->ToInstanceMap())
            if (InstanceScript* script = instanceMap->GetInstanceScript())
            {
                uint32 last = 0;
                for (uint32 i = 0; i < 32; ++i)
                    if (script->GetBossState(i) != TO_BE_DECIDED)
                        last = i + 1;
                line << ", states";
                for (uint32 i = 0; i < last; ++i)
                    line << ' ' << uint32(script->GetBossState(i));
            }
        std::list<Creature*> bosses;
        auto bossCheck = [&](Creature* c) { return c->IsAlive() && IsBossEntry(c->GetEntry()) && leader->IsWithinDistInMap(c, 300.0f); };
        Trinity::CreatureListSearcher<decltype(bossCheck)> searcher(leader, bosses, bossCheck);
        CellCoord pair(Trinity::ComputeCellCoord(leader->GetPositionX(), leader->GetPositionY()));
        Cell cell(pair);
        cell.SetNoCreate();
        TypeContainerVisitor<Trinity::CreatureListSearcher<decltype(bossCheck)>, GridTypeMapContainer> visitor(searcher);
        cell.Visit(pair, visitor, *map, *leader, 300.0f);
        uint32 shown = 0;
        for (Creature* c : bosses)
        {
            if (++shown > 6)
                break;
            line << " | " << c->GetEntry() << ' ' << c->GetName() << " dist " << uint32(leader->GetExactDist(c)) << " flags 0x" << std::hex
                << c->GetUInt32Value(UNIT_FIELD_FLAGS) << std::dec << " faction " << c->GetFaction()
                << (c->IsHostileTo(leader) ? " hostile" : " not-hostile") << (c->IsInEvadeMode() ? " evading" : "")
                << (c->IsInCombat() ? " in-combat" : "") << (c->GetSpawnId() ? "" : " summoned");
        }
        if (bosses.empty())
            line << " | no living boss within 300 yd";
    }
    TC_LOG_INFO("playerbots", "BotLife: run end {} ({}), {} wipes, leader {} at {:.0f} {:.0f} {:.0f}{}", d.name, result, party.wipes, leader->GetName(),
        leader->GetPositionX(), leader->GetPositionY(), leader->GetPositionZ(), line.str());
}

// ---------------------------------------------------------------------------------------------
// dungeon events that start by talking to an NPC (bots never did). A friendly creature with a C++
// script and a gossip menu (no vendor / trainer / travel roles) within 100 yards: walk there, open the gossip like a
// player, take the first option, then stay with that NPC for the event. At most two per run.
namespace
{
    struct EventNpcCheck
    {
        Player* bot;
        BotLifeInfo const& t;
        bool operator()(Creature* c) const
        {
            uint32 const roles = UNIT_NPC_FLAG_VENDOR | UNIT_NPC_FLAG_TRAINER | UNIT_NPC_FLAG_FLIGHTMASTER | UNIT_NPC_FLAG_INNKEEPER
                | UNIT_NPC_FLAG_BANKER | UNIT_NPC_FLAG_AUCTIONEER | UNIT_NPC_FLAG_REPAIR | UNIT_NPC_FLAG_SPIRITHEALER | UNIT_NPC_FLAG_SPIRITGUIDE;
            return c->IsAlive() && !c->IsInCombat() && c->HasFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_GOSSIP) && !c->HasFlag(UNIT_FIELD_NPC_FLAGS, roles)
                && c->GetScriptId() && !bot->IsHostileTo(c) && !t.gossipUsed.count(c->GetSpawnId()) && bot->IsWithinDistInMap(c, 100.0f)
                && !(t.gossipEmpty.count(c->GetSpawnId()) && t.gossipEmpty.at(c->GetSpawnId()) == t.dungeonBosses);
        }
    };
}

// next to it, or at its foot - an NPC on a rock the navmesh does not cover (the Disciple of Naralex)
// is reached at x/y ten yards lower
static bool GossipReached(Player* bot, WorldObject* target)
{
    return bot->GetExactDist(target) <= INTERACTION_DISTANCE - 1.0f
        || (bot->GetExactDist2d(target) <= INTERACTION_DISTANCE && std::fabs(bot->GetPositionZ() - target->GetPositionZ()) < 12.0f);
}

// 30 seconds at most on the way to an event NPC / object, then the leader gives it up
bool BotLifeMgr::GossipApproachTimedOut(Player* bot, BotLifeInfo& t, uint32 key, std::string const& name, uint32 now)
{
    if (t.gossipApproachKey != key)
    {
        t.gossipApproachKey = key;
        t.gossipApproachSince = now;
        return false;
    }
    if (now - t.gossipApproachSince < 30000)
        return false;
    TC_LOG_INFO("playerbots", "BotLife {}: map {} gives up walking to event {} at {:.0f} {:.0f} {:.0f}", bot->GetName(), bot->GetMapId(), name,
        bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ());
    t.gossipUsed.insert(key);
    t.gossipApproachKey = 0;
    t.nextGossipTry = now + 5000;
    if (bot->isMoving())
        bot->StopMoving();
    return true;
}

bool BotLifeMgr::TryEventGossip(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    if (t.gossipUsed.size() >= 5 || now < t.nextGossipTry)
        return false;

    std::list<Creature*> npcs;
    EventNpcCheck check{ bot, t };
    Trinity::CreatureListSearcher<EventNpcCheck> searcher(bot, npcs, check);
    CellCoord pair(Trinity::ComputeCellCoord(bot->GetPositionX(), bot->GetPositionY()));
    Cell cell(pair);
    cell.SetNoCreate();
    TypeContainerVisitor<Trinity::CreatureListSearcher<EventNpcCheck>, GridTypeMapContainer> visitor(searcher);
    cell.Visit(pair, visitor, *bot->GetMap(), *bot, 100.0f);
    Creature* npc = nullptr;
    for (Creature* c : npcs)
        if (!npc || bot->GetExactDist(c) < bot->GetExactDist(npc))
            npc = c;
    if (!npc)
    {
        // no NPC: a scripted lever / button / goober nearby (Broggok's cells, Sunken Temple statues, ...)
        if (t.gossipUsed.size() < 5)
        {
            GameObject* best = nullptr;
            std::list<GameObject*> gos;
            auto goCheck = [&](GameObject* go)
            {
                return (go->GetGoType() == GAMEOBJECT_TYPE_BUTTON || go->GetGoType() == GAMEOBJECT_TYPE_GOOBER) && go->isSpawned()
                    && go->GetGoState() == GO_STATE_READY && go->GetScriptId() && !t.gossipUsed.count(uint32(go->GetDBTableGUIDLow()) | 0x80000000u)
                    && bot->IsWithinDistInMap(go, 60.0f);
            };
            Trinity::GameObjectListSearcher<decltype(goCheck)> goSearcher(bot, gos, goCheck);
            TypeContainerVisitor<Trinity::GameObjectListSearcher<decltype(goCheck)>, GridTypeMapContainer> goVisitor(goSearcher);
            cell.Visit(pair, goVisitor, *bot->GetMap(), *bot, 60.0f);
            for (GameObject* go : gos)
                if (!best || bot->GetExactDist(go) < bot->GetExactDist(best))
                    best = go;
            if (best)
            {
                uint32 const key = uint32(best->GetDBTableGUIDLow()) | 0x80000000u;
                if (!GossipReached(bot, best))
                {
                    if (GossipApproachTimedOut(bot, t, key, best->GetName(), now))
                        return true;
                    if (!bot->isMoving() || now - t.lastMoveOrder > 2500)
                    {
                        bot->GetMotionMaster()->MovePoint(0, best->GetPositionX(), best->GetPositionY(), best->GetPositionZ(), true);
                        t.lastMoveOrder = now;
                    }
                    return true;
                }
                bot->StopMoving();
                t.gossipUsed.insert(uint32(best->GetDBTableGUIDLow()) | 0x80000000u);
                best->Use(bot);
                Count(BLC_EVENT_GOSSIP);
                TC_LOG_INFO("playerbots", "BotLife {}: used event object {} ({}) in map {}", bot->GetName(), best->GetName(), best->GetEntry(),
                    bot->GetMapId());
                t.nextGossipTry = now + 5000;
                return true;
            }
        }
        // an event NPC farther away in this instance - walk there, the search within 100 yd takes over
        auto en = s_eventNpcs.find(bot->GetMapId());
        if (en != s_eventNpcs.end())
        {
            DungeonQuestNpc const* farNpc = nullptr;
            float bestFar = 0.0f;
            for (DungeonQuestNpc const& s : en->second)
            {
                if (t.gossipUsed.count(s.spawnId) || t.eventFarVisited.count(s.spawnId))
                    continue;
                float const d = bot->GetExactDist(s.x, s.y, s.z);
                if (d <= 100.0f)
                {
                    t.eventFarVisited.insert(s.spawnId);   // reached: the search above takes it when it talks
                    continue;
                }
                if (!farNpc || d < bestFar)
                {
                    farNpc = &s;
                    bestFar = d;
                }
            }
            if (farNpc)
            {
                uint32 const key = farNpc->spawnId | 0x40000000u;
                if (t.gossipApproachKey != key)
                {
                    t.gossipApproachKey = key;
                    t.gossipApproachSince = now;
                    TC_LOG_INFO("playerbots", "BotLife {}: map {} walks to event NPC {} ({:.0f} yd away)", bot->GetName(), bot->GetMapId(),
                        farNpc->entry, bestFar);
                }
                else if (now - t.gossipApproachSince > 150000)
                {
                    TC_LOG_INFO("playerbots", "BotLife {}: map {} gives up walking to event NPC {}", bot->GetName(), bot->GetMapId(), farNpc->entry);
                    t.gossipUsed.insert(farNpc->spawnId);
                    t.gossipApproachKey = 0;
                    return true;
                }
                if (!bot->isMoving() || now - t.lastMoveOrder > 2500)
                {
                    bot->GetMotionMaster()->MovePoint(0, farNpc->x, farNpc->y, farNpc->z, true);
                    t.lastMoveOrder = now;
                }
                return true;
            }
        }
        t.nextGossipTry = now + 60000;
        return false;
    }

    if (!GossipReached(bot, npc))
    {
        if (GossipApproachTimedOut(bot, t, npc->GetSpawnId(), npc->GetName(), now))
            return true;
        if (!bot->isMoving() || now - t.lastMoveOrder > 2500)
        {
            bot->GetMotionMaster()->MovePoint(0, npc->GetPositionX(), npc->GetPositionY(), npc->GetPositionZ(), true);
            t.lastMoveOrder = now;
        }
        return true;
    }

    bot->StopMoving();
    t.gossipUsed.insert(npc->GetSpawnId());
    bot->PlayerTalkClass->ClearMenus();
    if (!sScriptMgr->OnGossipHello(bot, npc))
        bot->PrepareGossipMenu(npc, npc->GetGossipMenuId(), false);
    GossipMenu& menu = bot->PlayerTalkClass->GetGossipMenu();
    if (menu.GetMenuItems().empty())
    {
        bot->PlayerTalkClass->ClearMenus();
        // again after the next boss (the Disciple of Naralex talks once the four fanglords are dead)
        t.gossipUsed.erase(npc->GetSpawnId());
        t.gossipEmpty[npc->GetSpawnId()] = t.dungeonBosses;
        return true;   // nothing to choose (the fanglords may still be alive): try another NPC later
    }
    uint32 item = menu.GetMenuItems().begin()->first;
    uint32 sender = menu.GetMenuItemSender(item);
    uint32 action = menu.GetMenuItemAction(item);
    uint32 menuId = menu.GetMenuId();
    if (!sScriptMgr->OnGossipSelect(bot, npc, sender, action))
        bot->OnGossipSelect(npc, item, menuId);
    bot->PlayerTalkClass->ClearMenus();
    t.escortNpc = npc->GetGUID();
    t.escortUntil = now + 25 * MINUTE * IN_MILLISECONDS;
    Count(BLC_EVENT_GOSSIP);
    TC_LOG_INFO("playerbots", "BotLife {}: started the event of {} ({}) in map {}", bot->GetName(), npc->GetName(), npc->GetEntry(),
        bot->GetMapId());
    return true;
}
