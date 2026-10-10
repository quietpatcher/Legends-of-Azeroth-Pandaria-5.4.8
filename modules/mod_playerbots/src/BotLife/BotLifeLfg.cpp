/*
 * BotLife dungeon finder. A real player alone in the dungeon finder queue gets bots of the missing roles in
 * the same queue (one tank, one healer, three damage dealers minus the player's own role), so the queue forms a full
 * party instead of sending the player in alone (SoloCraft). The LFG manager auto-answers the role check and the
 * proposal for bots (LFGMgr ). Everything here runs on the world thread.
 */

#include "BotLife.h"
#include "DBCStores.h"
#include "ScriptMgr.h"
#include <sstream>

#include "Group.h"
#include "LFGMgr.h"
#include "Log.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "PlayerbotSpec.h"
#include "Playerbots.h"
#include "RandomPlayerbotMgr.h"
#include "World.h"
#include "WorldSession.h"

#include <algorithm>
#include <set>
#include <unordered_set>

namespace
{
    // the first queue of this guid that is waiting (queued, role check or proposal); 0 = none
    uint32 WaitingQueue(ObjectGuid guid, lfg::LfgState* stateOut = nullptr)
    {
        lfg::PlayerQueueDataMap const* queues = sLFGMgr->GetPlayerQueues(guid);
        if (!queues)
            return 0;
        for (auto const& q : *queues)
        {
            lfg::LfgState state = sLFGMgr->GetState(guid, q.first);
            if (state == lfg::LFG_STATE_QUEUED || state == lfg::LFG_STATE_ROLECHECK || state == lfg::LFG_STATE_PROPOSAL)
            {
                if (stateOut)
                    *stateOut = state;
                return q.first;
            }
        }
        return 0;
    }

    uint8 RoleOf(Player* bot)
    {
        if (PlayerBotSpec::IsTank(bot, true))
            return lfg::PLAYER_ROLE_TANK;
        if (PlayerBotSpec::IsHeal(bot, true))
            return lfg::PLAYER_ROLE_HEALER;
        return lfg::PLAYER_ROLE_DAMAGE;
    }
}

// synchronous LFGMgr::FillMissingRoles hook (see LFGMgr.h/.cpp) - same eligibility/role logic as the
// polling version below, but called once, right at join time, with the queueId/dungeons/roles already known,
// so it wins the race against LFGSolo.Enabled's instant same-tick matching (see LfgUpdate() for why polling can't).
void BotLifeMgr::FillLfgRolesSync(Player* player, uint32 queueId, std::set<uint32> const& dungeonIds)
{
    if (!_lfgFill || dungeonIds.empty())
        return;

    uint8 playerRoles = sLFGMgr->GetRoles(player->GetGUID(), queueId);
    uint32 need[3] = { 1, 1, 3 };   // tank, healer, damage
    if (playerRoles & lfg::PLAYER_ROLE_HEALER)
        need[1] = 0;
    else if (playerRoles & lfg::PLAYER_ROLE_TANK)
        need[0] = 0;
    else
        need[2] = 2;

    std::vector<Player*> bots;
    for (auto const& bp : sRandomPlayerbotMgr->GetAllBots())
        if (Player* bot = bp.second)
            bots.push_back(bot);
    std::shuffle(bots.begin(), bots.end(), RandomEngine::Instance());

    uint32 joined = 0, tries = 0;
    // bots of the player's own level first, the others within three levels fill what is left
    for (uint32 pass = 0; pass < 2; ++pass)
    {
        for (Player* bot : bots)
        {
            if ((!need[0] && !need[1] && !need[2]) || tries >= 40)
                break;
            if (!bot->IsInWorld() || !bot->IsAlive() || bot->GetGroup() || bot->InBattleground() || bot->InBattlegroundQueue()
                || bot->IsBeingTeleported() || bot->IsInCombat() || bot->GetMap()->Instanceable() || bot->GetTeam() != player->GetTeam()
                || IsBanker(bot->GetGUID()) || IsLfgBot(bot->GetGUID()) || WaitingQueue(bot->GetGUID()) || IsWalker(bot))
                continue;
            if (std::abs(int32(bot->GetLevel()) - int32(player->GetLevel())) > 3)
                continue;
            if ((pass == 0) != (bot->GetLevel() == player->GetLevel()))
                continue;
            PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
            if (!botAI || botAI->HasRealPlayerMaster())
                continue;
            uint8 role = RoleOf(bot);
            uint32 slot = role == lfg::PLAYER_ROLE_TANK ? 0 : role == lfg::PLAYER_ROLE_HEALER ? 1 : 2;
            if (!need[slot])
                continue;
            ++tries;
            lfg::LfgDungeonSet botDungeons = dungeonIds;
            sLFGMgr->JoinLfg(bot, lfg::LfgRoles(role), botDungeons, "");
            if (!WaitingQueue(bot->GetGUID()))
                continue;   // locked out of these dungeons (level, item level, deserter)
            --need[slot];
            _lfgBots[bot->GetGUID()] = { player->GetGUID(), role, getMSTime() };
            ++joined;
        }
    }
    if (joined)
    {
        Count(BLC_LFG_BOT_QUEUED, joined);
        if (_debug)
            TC_LOG_INFO("playerbots", "BotLife: {} bots instantly joined the dungeon finder with {}", joined, player->GetName());
    }
    if (need[0] || need[1] || need[2])
        Count(BLC_LFG_SHORT);
}

namespace
{
    // trampoline: LFGMgr::FillMissingRoles is a plain C-style function pointer, it cannot bind a member function
    void FillMissingRolesTrampoline(Player* player, uint32 queueId, lfg::LfgDungeonSet const& dungeons)
    {
        sBotLife->FillLfgRolesSync(player, queueId, dungeons);
    }

    struct FillMissingRolesRegistrar
    {
        FillMissingRolesRegistrar() { lfg::LFGMgr::FillMissingRoles = &FillMissingRolesTrampoline; }
    } const fillMissingRolesRegistrar;
}

bool BotLifeMgr::IsLfgBot(ObjectGuid guid) const
{
    return _lfgBots.count(guid) != 0;
}

// when a real player's dungeon finder run is done the bots thank the group and leave it, one at
// a time (world thread)
static void LfgThanksAndLeave(uint32 now)
{
    static std::unordered_map<ObjectGuid, uint32> s_finishedSince;   // group -> first seen finished
    static std::unordered_set<ObjectGuid> s_thanked;
    std::unordered_set<ObjectGuid> current;
    for (auto const& pair : sWorld->GetAllSessions())
    {
        WorldSession* session = pair.second;
        Player* player = session ? session->GetPlayer() : nullptr;
        if (!player || session->IsBot() || !player->IsInWorld())
            continue;
        Group* group = player->GetGroup();
        if (!group || !group->isLFGGroup() || current.count(group->GetGUID()))
            continue;
        uint32 const queueId = sLFGMgr->GetActiveQueueId(group->GetGUID());
        if (!queueId || sLFGMgr->GetState(group->GetGUID(), queueId) != lfg::LFG_STATE_FINISHED_DUNGEON)
            continue;
        current.insert(group->GetGUID());
        uint32& since = s_finishedSince[group->GetGUID()];
        if (!since)
            since = now;
        if (now - since < 45 * IN_MILLISECONDS)
            continue;   // loot and rolls first
        std::vector<Player*> bots;
        bool fighting = false;
        for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
            if (Player* member = ref->GetSource())
            {
                if (member->IsInCombat())
                    fighting = true;
                if (member->GetSession() && member->GetSession()->IsBot() && member->IsInWorld() && !member->IsBeingTeleported())
                    bots.push_back(member);
            }
        if (fighting || bots.empty())
            continue;
        if (!s_thanked.count(group->GetGUID()))
        {
            static char const* const lines[] = { "Thanks for the group!", "ty all, gg", "Thanks, that was fun!",
                "gg, thanks for the run!", "Thanks everyone, good luck out there!", "That went well, thanks all!" };
            Player* speaker = bots[urand(0, bots.size() - 1)];
            if (PlayerbotAI* ai = GET_PLAYERBOT_AI(speaker))
                ai->SayToParty(lines[urand(0, sizeof(lines) / sizeof(lines[0]) - 1)]);
            s_thanked.insert(group->GetGUID());
            continue;   // the goodbyes start on the next round
        }
        // one bot per round: out of the dungeon and out of the group
        Player* bot = bots.front();
        if (bot->GetMap()->IsDungeon())
            sLFGMgr->TeleportPlayer(bot, true);
        bot->RemoveFromGroup();
        TC_LOG_INFO("playerbots", "BotLife: {} leaves the finished dungeon finder group of {}", bot->GetName(), player->GetName());
    }
    for (auto itr = s_finishedSince.begin(); itr != s_finishedSince.end();)
    {
        if (!current.count(itr->first))
        {
            s_thanked.erase(itr->first);
            itr = s_finishedSince.erase(itr);
        }
        else
            ++itr;
    }
}

// bots of a real player's dungeon finder group that are still outside after 20 seconds are revived if
// needed and teleported in, the way a player would press 'teleport to dungeon' (world thread)
static void LfgBringInBots(uint32 now)
{
    static std::unordered_map<ObjectGuid, uint32> s_outsideSince;   // bot -> first seen outside
    std::unordered_set<ObjectGuid> seen;
    std::unordered_set<ObjectGuid> groups;
    for (auto const& pair : sWorld->GetAllSessions())
    {
        WorldSession* session = pair.second;
        Player* player = session ? session->GetPlayer() : nullptr;
        if (!player || session->IsBot() || !player->IsInWorld())
            continue;
        Group* group = player->GetGroup();
        if (!group || !group->isLFGGroup() || !groups.insert(group->GetGUID()).second)
            continue;
        uint32 const queueId = sLFGMgr->GetActiveQueueId(group->GetGUID());
        if (!queueId || sLFGMgr->GetState(group->GetGUID(), queueId) != lfg::LFG_STATE_DUNGEON)
            continue;
        for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
        {
            Player* bot = ref->GetSource();
            if (!bot || !bot->GetSession() || !bot->GetSession()->IsBot() || !bot->IsInWorld() || bot->IsBeingTeleported()
                || bot->GetMap()->IsDungeon())
                continue;
            seen.insert(bot->GetGUID());
            uint32& since = s_outsideSince[bot->GetGUID()];
            if (!since)
                since = now;
            if (now - since < 20 * IN_MILLISECONDS)
                continue;
            since = now;   // next try in 20 seconds if this one does not work
            if (!bot->IsAlive())
            {
                bot->ResurrectPlayer(1.0f);
                bot->SpawnCorpseBones();
            }
            if (bot->GetVehicle())
                bot->ExitVehicle();
            bot->CombatStop(true);
            TC_LOG_INFO("playerbots", "BotLife: {} (map {}) brought into the dungeon finder dungeon of {}", bot->GetName(),
                bot->GetMapId(), player->GetName());
            sLFGMgr->TeleportPlayer(bot, false);
        }
    }
    for (auto itr = s_outsideSince.begin(); itr != s_outsideSince.end();)
        itr = seen.count(itr->first) ? std::next(itr) : s_outsideSince.erase(itr);
}

void BotLifeMgr::LfgUpdate(uint32 now)
{
    LfgThanksAndLeave(now);
    LfgBringInBots(now);

    // forget bots that are out of the queue (matched into a dungeon, or the player left the queue)
    for (auto itr = _lfgBots.begin(); itr != _lfgBots.end();)
    {
        Player* bot = ObjectAccessor::FindConnectedPlayer(itr->first);
        Player* player = ObjectAccessor::FindConnectedPlayer(itr->second.player);
        bool botWaiting = bot && WaitingQueue(bot->GetGUID());
        bool playerWaiting = player && WaitingQueue(player->GetGUID());
        if (bot && botWaiting && !playerWaiting && !bot->GetGroup())
        {
            // the player is gone from the queue (joined, left, logged out): the bot leaves it too
            if (uint32 queueId = WaitingQueue(bot->GetGUID()))
                sLFGMgr->LeaveLfg(bot->GetGUID(), queueId);
            botWaiting = false;
        }
        if (!botWaiting)
            itr = _lfgBots.erase(itr);
        else
            ++itr;
    }

    std::vector<Player*> bots;
    bool botsCollected = false;
    uint32 joinedTotal = 0;

    SessionMap const& sessions = sWorld->GetAllSessions();
    for (auto const& pair : sessions)
    {
        WorldSession* session = pair.second;
        Player* player = session ? session->GetPlayer() : nullptr;
        if (!player || session->IsBot() || !player->IsInWorld() || player->GetGroup())
            continue;   // solo players only: a group of real players fills itself
        lfg::LfgState state = lfg::LFG_STATE_NONE;
        uint32 queueId = WaitingQueue(player->GetGUID(), &state);
        if (!queueId || state != lfg::LFG_STATE_QUEUED)
            continue;   // normally already handled synchronously by FillLfgRolesSync at join time; this loop is
                        // just a backfill net (bot dropped out later, more slots freed up, etc.)
        lfg::PlayerQueueData const& data = sLFGMgr->GetPlayerQueueData(player->GetGUID(), queueId);
        if (time(nullptr) - data.JoinTime < _lfgDelaySeconds)
            continue;   // real players first
        lfg::LfgDungeonSet dungeons = sLFGMgr->GetSelectedDungeons(player->GetGUID(), queueId);
        if (dungeons.empty())
            continue;

        // what the party still needs: the player takes healer, else tank, else damage
        uint8 playerRoles = sLFGMgr->GetRoles(player->GetGUID(), queueId);
        uint32 need[3] = { 1, 1, 3 };   // tank, healer, damage
        if (playerRoles & lfg::PLAYER_ROLE_HEALER)
            need[1] = 0;
        else if (playerRoles & lfg::PLAYER_ROLE_TANK)
            need[0] = 0;
        else
            need[2] = 2;
        for (auto const& lb : _lfgBots)
            if (lb.second.player == player->GetGUID())
            {
                uint32 slot = lb.second.role == lfg::PLAYER_ROLE_TANK ? 0 : lb.second.role == lfg::PLAYER_ROLE_HEALER ? 1 : 2;
                if (need[slot])
                    --need[slot];
            }
        if (!need[0] && !need[1] && !need[2])
            continue;

        if (!botsCollected)
        {
            botsCollected = true;
            for (auto const& bp : sRandomPlayerbotMgr->GetAllBots())
                if (Player* bot = bp.second)
                    bots.push_back(bot);
            std::shuffle(bots.begin(), bots.end(), RandomEngine::Instance());
        }

        uint32 tries = 0;
        // bots of the player's own level first, the others within three levels fill what is left
        for (uint32 pass = 0; pass < 2; ++pass)
        {
            for (Player* bot : bots)
            {
                if ((!need[0] && !need[1] && !need[2]) || tries >= 40)
                    break;
                if (!bot->IsInWorld() || !bot->IsAlive() || bot->GetGroup() || bot->InBattleground() || bot->InBattlegroundQueue()
                    || bot->IsBeingTeleported() || bot->IsInCombat() || bot->GetMap()->Instanceable() || bot->GetTeam() != player->GetTeam()
                    || IsBanker(bot->GetGUID()) || IsLfgBot(bot->GetGUID()) || WaitingQueue(bot->GetGUID()) || IsWalker(bot))
                    continue;
                if (std::abs(int32(bot->GetLevel()) - int32(player->GetLevel())) > 3)
                    continue;
                if ((pass == 0) != (bot->GetLevel() == player->GetLevel()))
                    continue;
                PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
                if (!botAI || botAI->HasRealPlayerMaster())
                    continue;
                uint8 role = RoleOf(bot);
                uint32 slot = role == lfg::PLAYER_ROLE_TANK ? 0 : role == lfg::PLAYER_ROLE_HEALER ? 1 : 2;
                if (!need[slot])
                    continue;
                ++tries;
                lfg::LfgDungeonSet botDungeons = dungeons;
                sLFGMgr->JoinLfg(bot, lfg::LfgRoles(role), botDungeons, "");
                if (!WaitingQueue(bot->GetGUID()))
                    continue;   // locked out of these dungeons (level, item level, deserter)
                --need[slot];
                _lfgBots[bot->GetGUID()] = { player->GetGUID(), role, now };
                ++joinedTotal;
                Count(BLC_LFG_BOT_QUEUED);
            }
        }
        if (need[0] || need[1] || need[2])
            Count(BLC_LFG_SHORT);
    }
    if (joinedTotal && _debug)
        TC_LOG_INFO("playerbots", "BotLife: {} bots joined the dungeon finder for real players", joinedTotal);
}

// dungeon finder test with five bots - the real path (queue, proposal, teleport, LFG group, the boss
// script's FinishDungeon); the tank leads and opens the holiday event as a player does
bool BotLifeMgr::IsLfgTestBot(ObjectGuid guid) const
{
    auto bots = std::atomic_load(&_lfgTestBots);
    return bots && bots->count(guid);
}

std::string BotLifeMgr::LfgTestQueue(uint32 dungeonId)
{
    LFGDungeonEntry const* dbc = sLFGDungeonStore.LookupEntry(dungeonId);
    if (!dbc)
        return "lfgtest: no dungeon " + std::to_string(dungeonId);
    // (round 6) the group of the previous test goes first
    if (auto previous = std::atomic_load(&_lfgTestBots))
    {
        std::set<Group*> groups;
        for (ObjectGuid const& guid : *previous)
            if (Player* p = ObjectAccessor::FindConnectedPlayer(guid))
                if (Group* g = p->GetGroup())
                    groups.insert(g);
        for (Group* g : groups)
            g->Disband(true);
        std::atomic_store(&_lfgTestBots, std::shared_ptr<std::unordered_set<ObjectGuid> const>());
    }
    {
        // (round 7) old test groups from before a restart: dungeon finder groups of bots only in the holiday maps
        std::set<Group*> groups;
        for (auto const& bp : sRandomPlayerbotMgr->GetAllBots())
        {
            Player* p = bp.second;
            Group* g = p ? p->GetGroup() : nullptr;
            if (!g || !g->isLFGGroup())   // (round 8: wherever its members are - after a wipe they are ghosts outside)
                continue;
            bool botsOnly = true;
            for (GroupReference* ref = g->GetFirstMember(); ref; ref = ref->next())
                if (Player* m = ref->GetSource())
                    if (!m->GetSession() || !m->GetSession()->IsBot())
                        botsOnly = false;
            if (botsOnly)
                groups.insert(g);
        }
        for (Group* g : groups)
            g->Disband(true);
        if (!groups.empty())
            TC_LOG_INFO("playerbots", "LFGTEST {} old test groups disbanded", groups.size());
        if (!groups.empty())
            TC_LOG_INFO("playerbots", "LFGTEST previous test group disbanded");
    }
    std::vector<Player*> pool[2][3];   // team, role
    for (auto const& bp : sRandomPlayerbotMgr->GetAllBots())
    {
        Player* bot = bp.second;
        if (!bot || !bot->IsInWorld() || !bot->IsAlive() || bot->GetGroup() || bot->InBattleground() || bot->InBattlegroundQueue()
            || bot->IsBeingTeleported() || bot->IsInCombat() || bot->GetMap()->Instanceable() || IsBanker(bot->GetGUID())
            || IsLfgBot(bot->GetGUID()) || WaitingQueue(bot->GetGUID()) || IsWalker(bot))
            continue;
        if (bot->GetLevel() < dbc->minlevel || bot->GetLevel() > dbc->maxlevel)
            continue;
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI || botAI->HasRealPlayerMaster())
            continue;
        uint8 const role = RoleOf(bot);
        pool[bot->GetTeam() == HORDE ? 1 : 0][role == lfg::PLAYER_ROLE_TANK ? 0 : role == lfg::PLAYER_ROLE_HEALER ? 1 : 2].push_back(bot);
    }
    int team = -1;
    Player* tank = nullptr;
    if (dbc->scenario)
    {
        // a scenario takes any role: start from any idle bot of the level, the queue fills the other two
        std::vector<Player*> any[2];
        for (int t = 0; t < 2; ++t)
            for (int r = 0; r < 3; ++r)
                any[t].insert(any[t].end(), pool[t][r].begin(), pool[t][r].end());
        for (int t = 0; t < 2; ++t)
            if (any[t].size() >= 3 && (team < 0 || any[t].size() > any[team].size()))
                team = t;
        if (team < 0)
            return "lfgtest: not enough idle bots of level " + std::to_string(dbc->minlevel) + "-" + std::to_string(dbc->maxlevel)
                + " for a scenario (3 of one faction, any role)";
        tank = any[team][urand(0, any[team].size() - 1)];
    }
    else
    {
        for (int t = 0; t < 2; ++t)
            if (!pool[t][0].empty() && !pool[t][1].empty() && pool[t][2].size() >= 3 && (team < 0 || pool[t][2].size() > pool[team][2].size()))
                team = t;
        if (team < 0)
            return "lfgtest: not enough idle bots of level " + std::to_string(dbc->minlevel) + "-" + std::to_string(dbc->maxlevel)
                + " (tank, healer, 3 damage of one faction)";
        tank = pool[team][0][urand(0, pool[team][0].size() - 1)];
    }
    lfg::LfgDungeonSet dungeons = { dungeonId };
    sLFGMgr->JoinLfg(tank, lfg::LfgRoles(dbc->scenario ? lfg::PLAYER_ROLE_DAMAGE : lfg::PLAYER_ROLE_TANK), dungeons, "");
    uint32 const queueId = WaitingQueue(tank->GetGUID());
    if (!queueId)
        return "lfgtest: " + tank->GetName() + " could not join " + (dbc->name ? dbc->name : "") + " (locked: event not active, level or item level?)";
    FillLfgRolesSync(tank, queueId, dungeons);
    auto set = std::make_shared<std::unordered_set<ObjectGuid>>();
    set->insert(tank->GetGUID());
    std::string names = tank->GetName() + " (tank)";
    for (auto const& lb : _lfgBots)
        if (lb.second.player == tank->GetGUID())
        {
            set->insert(lb.first);
            if (Player* p = ObjectAccessor::FindConnectedPlayer(lb.first))
                names += ", " + p->GetName() + (lb.second.role == lfg::PLAYER_ROLE_HEALER ? " (healer)" : "");
        }
    if (PlayerbotAI* tankAI = GET_PLAYERBOT_AI(tank))
        tankAI->life.lfgTestAt = 0;
    std::atomic_store(&_lfgTestBots, std::shared_ptr<std::unordered_set<ObjectGuid> const>(std::move(set)));
    _lfgTestDungeon = dungeonId;
    TC_LOG_INFO("playerbots", "LFGTEST queued {} ({}): {} - {} in the queue", dungeonId, dbc->name ? dbc->name : "", names,
        std::atomic_load(&_lfgTestBots)->size());
    return "lfgtest: queued " + std::to_string(dungeonId) + " " + (dbc->name ? dbc->name : "") + ": " + names;
}

bool BotLifeMgr::LfgTestLeadTick(Player* bot, BotLifeInfo& t, uint32 now)
{
    uint32 const dungeon = _lfgTestDungeon.load();
    if (dungeon != 287 && dungeon != 285)
        return false;   // no event of its own: the lead logic clears the dungeon
    if (t.lfgTestAt == UINT32_MAX)
        return false;   // opened: the fight is the engine's
    if (!t.lfgTestAt)
    {
        t.lfgTestAt = now + 20000;   // the others come in and catch up
        TC_LOG_INFO("playerbots", "LFGTEST {} leads in map {} instance {} at {:.0f} {:.0f} {:.0f}", bot->GetName(), bot->GetMapId(),
            bot->GetInstanceId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ());
        return true;
    }
    // (round 2) what the lead waits for, every 15 s
    static thread_local uint32 lastWhy = 0;
    auto why = [&](char const* text)
    {
        if (now - lastWhy < 15000)
            return;
        lastWhy = now;
        TC_LOG_INFO("playerbots", "LFGTEST {} waits: {}", bot->GetName(), text);
    };
    if (now < t.lfgTestAt)
    {
        why("the others coming in");
        return true;
    }
    if (bot->IsInCombat() && dungeon != 285)   // (round 9: the hidden Horseman holds the group in combat - a player clicks the shrine anyway)
    {
        why("in combat");
        return true;
    }
    // (round 2) the group first: dead or outside members back to life next to the lead
    if (Group* group = bot->GetGroup())
    {
        uint32 missing = 0;
        for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
        {
            Player* member = ref->GetSource();
            if (!member || member == bot || !member->GetSession())
                continue;
            if (member->IsInWorld() && member->GetMap() == bot->GetMap() && member->IsAlive())
                continue;
            static thread_local std::unordered_map<ObjectGuid, uint32> teleportSince;
            if (member->IsBeingTeleported())
            {
                uint32& since = teleportSince[member->GetGUID()];
                if (!since)
                    since = now;
                if (now - since > 20000)
                    continue;   // (round 3) stuck in a teleport: not waited for
                ++missing;
                static thread_local uint32 lastNote = 0;
                if (now - lastNote > 15000)
                {
                    lastNote = now;
                    TC_LOG_INFO("playerbots", "LFGTEST waits for {}: being teleported (map {})", member->GetName(), member->GetMapId());
                }
                continue;
            }
            teleportSince.erase(member->GetGUID());
            ++missing;
            {
                static thread_local uint32 lastNote2 = 0;
                if (now - lastNote2 > 15000)
                {
                    lastNote2 = now;
                    TC_LOG_INFO("playerbots", "LFGTEST waits for {}: map {} ({}), {}", member->GetName(), member->GetMapId(),
                        member->IsInWorld() && member->GetMap() == bot->GetMap() ? "same map" : "elsewhere", member->IsAlive() ? "alive" : "dead");
                }
            }
            if (member->IsInWorld() && member->GetMap() == bot->GetMap())
            {
                member->ResurrectPlayer(1.0f);
                member->SpawnCorpseBones();
                member->NearTeleportTo(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), bot->GetOrientation());
                TC_LOG_INFO("playerbots", "LFGTEST {} revived next to the lead", member->GetName());
            }
            else
            {
                QueueTeleport(member, bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), bot->GetOrientation());
                TC_LOG_INFO("playerbots", "LFGTEST {} (map {}, {}) brought into the instance", member->GetName(), member->GetMapId(),
                    member->IsAlive() ? "alive" : "dead");
            }
        }
        if (missing)
        {
            t.lfgTestAt = now + 5000;
            why("group members not here yet");
            return true;
        }
    }
    WorldObject* starter = nullptr;
    uint32 action = 1000;
    if (dungeon == 287)
    {
        starter = bot->FindNearestCreature(23872, 250.0f, true);   // Coren Direbrew
        action = 1000 + 1;
    }
    else
    {
        starter = bot->FindNearestGameObject(186267, 250.0f);   // Pumpkin Shrine (the Horseman puts it down)
        action = 1000;
    }
    if (!starter)
    {
        TC_LOG_INFO("playerbots", "LFGTEST {}: no event starter within 250 yd (dungeon {}) - retry in 30 s", bot->GetName(), dungeon);
        t.lfgTestAt = now + 30000;
        return true;
    }
    if (bot->GetExactDist(starter) > 10.0f)   // (round 5: interaction range, the near point keeps the object sizes apart)
    {
        float x, y, z;
        starter->GetNearPoint(bot, x, y, z, 2.5f, starter->GetAbsoluteAngle(bot));
        bot->NearTeleportTo(x, y, z, bot->GetAbsoluteAngle(starter));
        t.lfgTestAt = now + 3000;
        return true;
    }
    bool started = false;
    if (Creature* c = starter->ToCreature())
        started = sScriptMgr->OnGossipSelect(bot, c, 1, action);
    else if (GameObject* go = starter->ToGameObject())
        started = sScriptMgr->OnGossipSelect(bot, go, 1, action);
    TC_LOG_INFO("playerbots", "LFGTEST {} opens the event at {} ({}): {}", bot->GetName(), starter->GetName(), starter->GetEntry(),
        started ? "script took it" : "no script answer");
    t.lfgTestAt = UINT32_MAX;
    return true;
}

std::string BotLifeMgr::LfgTestStatus()
{
    auto bots = std::atomic_load(&_lfgTestBots);
    if (!bots || bots->empty())
        return "lfgtest: no test running";
    std::ostringstream out;
    out << "lfgtest dungeon " << _lfgTestDungeon.load() << "\n";
    for (ObjectGuid const& guid : *bots)
    {
        Player* p = ObjectAccessor::FindConnectedPlayer(guid);
        if (!p)
        {
            out << "  " << guid.GetCounter() << " offline\n";
            continue;
        }
        Group* g = p->GetGroup();
        out << "  " << p->GetName() << " lvl " << uint32(p->GetLevel()) << " map " << p->GetMapId() << " inst " << p->GetInstanceId()
            << (p->IsAlive() ? "" : " DEAD") << (p->IsInCombat() ? " combat" : "") << " hp " << uint32(p->GetHealthPct()) << "%"
            << " group " << (g ? std::to_string(g->GetLowGUID()) : "-") << (g && g->isLFGGroup() ? " lfg" : "")
            << " queue " << WaitingQueue(guid) << "\n";
    }
    return out.str();
}
