/*
 * Bot life: battlegrounds. The LoA playerbots port has no battleground support at all, so a real player
 * in a battleground queue would wait forever. The world thread fills the queue (both teams, the player's
 * bracket) with random bots, accepts their invitations, and takes them out of the queue again when no
 * real player waits anymore. Inside, bots fight enemy players, roam between the battleground's graveyards
 * (spread over the objectives) and click banners they pass (Arathi Basin, Battle for Gilneas, ...).
 */

#include "BotLife.h"

#include <memory>
#include "DBCStructure.h"
#include "Player.h"

#include "CellImpl.h"
#include "Chat.h"
#include "DBCStores.h"
#include "GameObject.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "Log.h"
#include "Map.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "Playerbots.h"
#include "Random.h"
#include "RandomPlayerbotMgr.h"
#include "Timer.h"
#include "World.h"
#include "WorldPacket.h"
#include "WorldSession.h"
#include "Battleground.h"
#include "BattlegroundMgr.h"

#include <array>
#include <cmath>
#include <map>

namespace
{
    bool IsBgCandidate(Player* bot, uint32 minLevel, uint32 maxLevel)
    {
        if (!bot || !bot->IsInWorld() || !bot->GetSession() || bot->GetGroup() || bot->InBattleground() || bot->InBattlegroundQueue())
            return false;
        if (sBotLife->IsWalker(bot))
            return false;   // a walker stays on its quests
        if (!bot->IsAlive() || bot->IsInCombat() || bot->IsBeingTeleported() || bot->IsInFlight() || bot->GetVehicle())
            return false;
        if (bot->GetLevel() < minLevel || bot->GetLevel() > maxLevel)
            return false;
        Map* map = bot->GetMap();
        if (!map || map->Instanceable())
            return false;
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI || botAI->IsRealPlayer() || botAI->HasRealPlayerMaster() || botAI->life.party)
            return false;
        return sRandomPlayerbotMgr->IsRandomBot(bot);
    }

    // CMSG_BATTLEFIELD_PORT: action 1 = enter, 0 = leave the queue
    void SendPort(Player* bot, uint32 queueSlot, uint8 action)
    {
        WorldPacket packet(CMSG_BATTLEFIELD_PORT, 20);
        packet << uint8(action) << uint32(queueSlot) << uint32(0) << uint32(0);
        for (int i = 0; i < 8; ++i)
            packet.WriteBit(false);
        packet.FlushBits();
        bot->GetSession()->HandleBattleFieldPortOpcode(packet);
    }

    struct BgWant
    {
        BattlegroundTypeId bgTypeId = BATTLEGROUND_TYPE_NONE;
        uint32 minLevel = 0, maxLevel = 0;
        uint32 perTeam = 0;
        uint32 real[2] = { 0, 0 };   // real players waiting: [0] alliance, [1] horde
    };
}

bool BotLifeMgr::QueueBotForBattleground(Player* bot, uint32 queueType, uint32 bgType)
{
    BattlegroundQueueTypeId qt = BattlegroundQueueTypeId(queueType);
    BattlegroundTypeId bgTypeId = BattlegroundTypeId(bgType);
    Battleground* bg = sBattlegroundMgr->GetBattlegroundTemplate(bgTypeId);
    if (!bg || !bot->HasFreeBattlegroundQueueId() || !bot->CanJoinToBattleground(bg))
        return false;
    PvPDifficultyEntry const* bracket = sDBCManager.GetBattlegroundBracketByLevel(bg->GetMapId(), bot->GetLevel());
    if (!bracket)
        return false;
    BattlegroundQueue& bgQueue = sBattlegroundMgr->GetBattlegroundQueue(qt);
    GroupQueueInfo* ginfo = bgQueue.AddGroup(bot, nullptr, bgTypeId, bracket, 0, false, false, 0, 0);
    bot->AddBattlegroundQueueId(qt);
    bot->AddBattlegroundQueueJoinTime(bgTypeId, ginfo->JoinTime);
    sBattlegroundMgr->ScheduleQueueUpdate(0, 0, qt, bgTypeId, bracket->GetBracketId());
    if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot))
    {
        botAI->life.bgQueueType = queueType;
        botAI->life.bgQueuedAt = getMSTime();
        botAI->life.bgEnteredAt = 0;
        botAI->life.bgNoRealSince = 0;
        if (botAI->life.state == BotLifeState::TOWN)
            botAI->life.state = BotLifeState::IDLE;
    }
    _bgBots.insert(bot->GetGUID());
    Count(BLC_BG_QUEUED);
    return true;
}

// world thread
void BotLifeMgr::BattlegroundUpdate(uint32 now)
{
    // 1. what is wanted: real players waiting (and ".botlife bgtest" requests)
    std::map<std::pair<uint32, uint32>, BgWant> wants;   // (queue type, bracket id)
    for (auto const& sessionPair : sWorld->GetAllSessions())
    {
        WorldSession* session = sessionPair.second;
        Player* player = session ? session->GetPlayer() : nullptr;
        if (!player || session->IsBot() || !player->IsInWorld() || !player->InBattlegroundQueue())
            continue;
        for (uint32 slot = 0; slot < PLAYER_MAX_BATTLEGROUND_QUEUES; ++slot)
        {
            BattlegroundQueueTypeId qt = player->GetBattlegroundQueueTypeId(slot);
            if (qt == BATTLEGROUND_QUEUE_NONE || qt > BATTLEGROUND_QUEUE_RB || player->IsInvitedForBattlegroundQueueType(qt))
                continue;
            BattlegroundTypeId bgTypeId = BattlegroundMgr::BGTemplateId(qt);
            Battleground* bg = sBattlegroundMgr->GetBattlegroundTemplate(bgTypeId);
            PvPDifficultyEntry const* bracket = bg ? sDBCManager.GetBattlegroundBracketByLevel(bg->GetMapId(), player->GetLevel()) : nullptr;
            if (!bracket)
                continue;
            BgWant& w = wants[{ uint32(qt), uint32(bracket->GetBracketId()) }];
            w.bgTypeId = bgTypeId;
            w.minLevel = bracket->MinLevel;
            w.maxLevel = bracket->MaxLevel;
            w.perTeam = std::min<uint32>(bg->GetMaxPlayersPerTeam(), 15);
            ++w.real[player->GetTeam() == HORDE ? 1 : 0];
        }
    }
    // the bots play battlegrounds among themselves too. Every BotLife.BgAutoMinutes a match is
    // queued for the bracket of a random bot (both teams are filled, exactly like ".botlife bgtest").
    if (_bgAutoMinutes)
    {
        if (!_nextAutoBg)
            _nextAutoBg = now + 5 * MINUTE * IN_MILLISECONDS;   // let the bots log in first
        else if (now >= _nextAutoBg)
        {
            _nextAutoBg = now + MINUTE * IN_MILLISECONDS;   // nothing that fits: look again in a minute
            auto const& bots = sRandomPlayerbotMgr->GetAllBots();
            if (_bgTests.size() < _bgAutoMax && !bots.empty())
            {
                static uint32 const types[] = { BATTLEGROUND_WS, BATTLEGROUND_AB, BATTLEGROUND_EY, BATTLEGROUND_TP, BATTLEGROUND_BFG };
                for (uint32 attempt = 0; attempt < 12; ++attempt)
                {
                    auto it = bots.begin();
                    std::advance(it, urand(0, uint32(bots.size()) - 1));
                    Player* sample = it->second;
                    uint32 const bgType = types[urand(0, 4)];
                    Battleground* bg = sBattlegroundMgr->GetBattlegroundTemplate(BattlegroundTypeId(bgType));
                    if (!sample || !bg || !sDBCManager.GetBattlegroundBracketByLevel(bg->GetMapId(), sample->GetLevel()))
                        continue;
                    BotLifeBgTest test;
                    test.bgType = bgType;
                    test.level = sample->GetLevel();
                    test.until = now + 10 * MINUTE * IN_MILLISECONDS;
                    _bgTests.push_back(test);
                    _nextAutoBg = now + _bgAutoMinutes * MINUTE * IN_MILLISECONDS;
                    TC_LOG_INFO("playerbots", "BotLife: bot battleground {} for the bracket of level {} queued", bgType, test.level);
                    break;
                }
            }
        }
    }
    _bgTestsActive = !_bgTests.empty();
    for (auto it = _bgTests.begin(); it != _bgTests.end();)
    {
        if (now >= it->until)
        {
            it = _bgTests.erase(it);
            continue;
        }
        Battleground* bg = sBattlegroundMgr->GetBattlegroundTemplate(BattlegroundTypeId(it->bgType));
        PvPDifficultyEntry const* bracket = bg ? sDBCManager.GetBattlegroundBracketByLevel(bg->GetMapId(), it->level) : nullptr;
        if (bracket)
        {
            BgWant& w = wants[{ uint32(BattlegroundMgr::BGQueueTypeId(BattlegroundTypeId(it->bgType), 0)), uint32(bracket->GetBracketId()) }];
            w.bgTypeId = BattlegroundTypeId(it->bgType);
            w.minLevel = bracket->MinLevel;
            w.maxLevel = bracket->MaxLevel;
            w.perTeam = std::min<uint32>(bg->GetMaxPlayersPerTeam(), 10);
        }
        ++it;
    }

    // 2. our queued bots: accept invitations, drop the ones nobody waits for anymore
    // per bracket. Counted per battleground type, a bot match in another bracket filled the count for
    // the bracket of a real player, who then got five bots per team and never a battleground.
    std::map<std::pair<uint32, uint32>, std::array<uint32, 2>> queued;   // (queue type, bracket id) -> alliance, horde
    auto bracketOf = [](Player* bot, BattlegroundQueueTypeId queueType) -> uint32
    {
        Battleground* bg = sBattlegroundMgr->GetBattlegroundTemplate(BattlegroundMgr::BGTemplateId(queueType));
        PvPDifficultyEntry const* bracket = bg ? sDBCManager.GetBattlegroundBracketByLevel(bg->GetMapId(), bot->GetLevel()) : nullptr;
        return bracket ? uint32(bracket->GetBracketId()) : 0;
    };
    for (auto it = _bgBots.begin(); it != _bgBots.end();)
    {
        Player* bot = ObjectAccessor::FindConnectedPlayer(*it);
        PlayerbotAI* botAI = bot ? GET_PLAYERBOT_AI(bot) : nullptr;
        if (!botAI || (!bot->InBattlegroundQueue() && !bot->InBattleground()))
        {
            if (botAI)
                botAI->life.bgQueueType = 0;
            it = _bgBots.erase(it);
            continue;
        }
        BattlegroundQueueTypeId qt = BattlegroundQueueTypeId(botAI->life.bgQueueType);
        // bots already playing count for their battleground type (otherwise new games keep getting filled)
        if (bot->InBattleground() && qt != BATTLEGROUND_QUEUE_NONE && qt < MAX_BATTLEGROUND_QUEUE_TYPES)
            ++queued[{ uint32(qt), bracketOf(bot, qt) }][bot->GetBGTeam() == HORDE ? 1 : 0];
        // (inside the battleground the queue slot stays "invited": porting again would pull the bot out)
        if (bot->InBattlegroundQueue() && !bot->InBattleground() && qt != BATTLEGROUND_QUEUE_NONE && !bot->IsBeingTeleported())
        {
            uint32 slot = bot->GetBattlegroundQueueIndex(qt);
            if (slot < PLAYER_MAX_BATTLEGROUND_QUEUES)
            {
                if (bot->IsInvitedForBattlegroundQueueType(qt))
                {
                    bot->StopMoving();
                    SendPort(bot, slot, 1);
                    Count(BLC_BG_JOINED);
                }
                else
                {
                    bool wanted = false;
                    for (auto const& w : wants)
                        if (w.first.first == uint32(qt) && bot->GetLevel() >= w.second.minLevel && bot->GetLevel() <= w.second.maxLevel)
                            wanted = true;
                    if (!wanted && now - botAI->life.bgQueuedAt > 60000)
                        SendPort(bot, slot, 0);   // leave the queue
                    else
                        ++queued[{ uint32(qt), bracketOf(bot, qt) }][bot->GetTeam() == HORDE ? 1 : 0];
                }
            }
        }
        ++it;
    }

    // 3. top up the queues
    if (wants.empty())
        return;
    uint32 added = 0;
    std::vector<Player*> pool;
    for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
        pool.push_back(pair.second);
    for (auto const& wp : wants)
    {
        BgWant const& w = wp.second;
        uint32 qt = wp.first.first;
        for (uint32 team = 0; team < 2 && added < 20; ++team)
        {
            uint32 have = queued[{ qt, wp.first.second }][team] + w.real[team];
            // one guild first - the bots queue with their guild mates like a premade
            if (_guildGroups)
            {
                uint32 guildId = 0;
                for (Player* bot : pool)
                    if ((bot->GetTeam() == HORDE ? 1u : 0u) == team && bot->GetGuildId() && IsBgCandidate(bot, w.minLevel, w.maxLevel))
                    {
                        guildId = bot->GetGuildId();
                        break;
                    }
                if (guildId)
                    std::stable_partition(pool.begin(), pool.end(), [&](Player* bot) { return bot->GetGuildId() == guildId; });
            }
            for (Player* bot : pool)
            {
                if (have >= w.perTeam || added >= 20)
                    break;
                if ((bot->GetTeam() == HORDE ? 1u : 0u) != team || !IsBgCandidate(bot, w.minLevel, w.maxLevel) || IsBanker(bot->GetGUID()) || IsLfgBot(bot->GetGUID()))
                    continue;
                if (QueueBotForBattleground(bot, qt, uint32(w.bgTypeId)))
                {
                    ++have;
                    ++added;
                }
            }
        }
    }
    if (added && _debug)
        TC_LOG_INFO("playerbots", "BotLife: {} bots queued for battlegrounds ({} queues wanted)", added, wants.size());
}

void BotLifeMgr::TestBattleground(ChatHandler* handler, uint32 bgType, uint32 level)
{
    BotLifeBgTest test;
    test.bgType = bgType;
    test.level = level;
    test.until = getMSTime() + 10 * MINUTE * IN_MILLISECONDS;
    _bgTests.push_back(test);
    handler->PSendSysMessage("BotLife: battleground %u test for level %u queued (bots of both teams, 10 min)", bgType, level);
}

// ---------------------------------------------------------------------------------------------
// map thread: bots inside a battleground

namespace
{
    // capture-the-flag battlegrounds: flag stands (SetupBattleground) and capture area triggers, [0] alliance, [1] horde
    struct FlagBg
    {
        uint32 map;
        float stand[2][3];
        uint32 trigger[2];
    };
    constexpr FlagBg FLAG_BGS[] = {
        { 489, { { 1540.423f, 1481.325f, 351.8284f }, { 916.0226f, 1434.405f, 345.413f } }, { 3646, 3647 } },   // Warsong Gulch
        { 726, { { 2118.210f, 191.621f, 44.052f }, { 1578.380f, 344.037f, 2.419f } }, { 5904, 5905 } },        // Twin Peaks
    };
    constexpr uint32 CARRIED_FLAG_AURA[2] = { 23333, 23335 };   // what an alliance / horde carrier has (WSG and TP)

    FlagBg const* GetFlagBg(uint32 map)
    {
        for (FlagBg const& f : FLAG_BGS)
            if (f.map == map)
                return &f;
        return nullptr;
    }

    struct FlagCheck
    {
        WorldObject const* obj;
        float range;
        bool operator()(GameObject* go) const
        {
            if (!obj->IsWithinDist(go, range, false) || !go->isSpawned())
                return false;
            GameobjectTypes type = go->GetGoType();
            return type == GAMEOBJECT_TYPE_FLAGSTAND || type == GAMEOBJECT_TYPE_FLAGSTAND_2 || type == GAMEOBJECT_TYPE_FLAGDROP;
        }
    };

    struct BannerCheck
    {
        WorldObject const* obj;
        float range;
        bool operator()(GameObject* go) const
        {
            if (!obj->IsWithinDist(go, range, false) || !go->isSpawned())
                return false;
            if (go->GetGoType() != GAMEOBJECT_TYPE_GOOBER && go->GetGoType() != GAMEOBJECT_TYPE_BUTTON)
                return false;
            std::string const& name = go->GetName();
            return name.find("Banner") != std::string::npos;
        }
    };
}

bool BotLifeMgr::BattlegroundBotUpdate(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    Battleground* bg = bot->GetBattleground();
    if (!bg || bot->IsBeingTeleported())
        return false;
    if (!bot->IsAlive())
    {
        // the engine releases and queues at the spirit guide; if that does not get the bot up, do it here
        if (bot->HasPlayerFlag(PLAYER_FLAGS_GHOST))
        {
            if (!t.deadSince)
                t.deadSince = now;
            else if (now - t.deadSince > 45000)
            {
                t.deadSince = 0;
                bot->ResurrectPlayer(1.0f);
                bot->SpawnCorpseBones();
            }
        }
        return false;
    }
    t.deadSince = 0;
    // bots only play for real players: nobody real inside for a while (or a battle that never ends) -> leave
    if (!t.bgEnteredAt)
        t.bgEnteredAt = now;
    if (now >= t.bgNextRealCheck)
    {
        t.bgNextRealCheck = now + 15000;
        bool real = false;
        Map::PlayerList const& all = bot->GetMap()->GetPlayers();
        for (Map::PlayerList::const_iterator itr = all.begin(); itr != all.end() && !real; ++itr)
            if (Player* p = itr->GetSource())
                if (p->GetSession() && !p->GetSession()->IsBot())
                    real = true;
        if (real)
            t.bgNoRealSince = 0;
        else if (!t.bgNoRealSince)
            t.bgNoRealSince = now;
        // 
        bool noReal = t.bgNoRealSince && now - t.bgNoRealSince > 3 * MINUTE * IN_MILLISECONDS
            && !_bgTestsActive && !_bgAutoMinutes;
        if (noReal || now - t.bgEnteredAt > 45 * MINUTE * IN_MILLISECONDS)
        {
            t.bgEnteredAt = 0;
            t.bgNoRealSince = 0;
            Count(BLC_BG_LEFT);
            bot->LeaveBattleground();
            return true;
        }
    }

    if (bg->GetStatus() != STATUS_IN_PROGRESS)
        return false;   // waiting behind the gates
    if (bot->IsInCombat())
    {
        Dismount(bot);
        CombatPotion(bot, t, now);
        t.bgCaptureAt = 0;   // capture interrupted
        return false;
    }
    if (bot->HasUnitState(UNIT_STATE_CASTING))
        return true;   // e.g. capturing a banner

    uint32 teamIdx = bot->GetBGTeam() == HORDE ? 1 : 0;
    FlagBg const* flagBg = GetFlagBg(bot->GetMapId());
    bool wsg = flagBg != nullptr;
    bool carrier = wsg && bot->HasAura(CARRIED_FLAG_AURA[teamIdx]);
    if (carrier)
    {
        // run home with the flag; the capture is an area trigger the client would send
        float const* home = flagBg->stand[teamIdx];
        if (bot->GetExactDist(home[0], home[1], home[2]) < 5.0f)
        {
            // captures only while our own flag is home; otherwise wait here for the team to bring it back
            if (now >= t.bgCaptureAt)
            {
                t.bgCaptureAt = now + 3000;
                bg->HandleAreaTrigger(bot, flagBg->trigger[teamIdx], true);
                if (!bot->HasAura(CARRIED_FLAG_AURA[teamIdx]))
                {
                    Count(BLC_BG_FLAG_CAPTURE);
                    TC_LOG_INFO("playerbots", "BotLife: {} captured the flag (map {}, instance {})", bot->GetName(), bot->GetMapId(), bot->GetInstanceId());
                }
            }
            return true;
        }
        if (!t.hasDest || std::fabs(t.destX - home[0]) > 1.0f)
            SetDest(t, bot->GetMapId(), home[0], home[1], home[2], 2.0f);
        Travel(bot, t, now);
        return true;
    }

    // flags in reach (stand, dropped flag): pick up / return
    {
        std::list<GameObject*> flags;
        FlagCheck check{ bot, 25.0f };
        Trinity::GameObjectListSearcher<FlagCheck> searcher(bot, flags, check);
        bot->VisitNearbyGridObject(25.0f, searcher);
        for (GameObject* go : flags)
        {
            auto used = t.usedGos.find(go->GetGUID());
            if (used != t.usedGos.end() && now < used->second)
                continue;
            if (!bot->CanUseBattlegroundObject(go))
                continue;
            if (bot->GetExactDist(go) > 3.0f)
            {
                if (!bot->isMoving() || now - t.lastMoveOrder > 1500)
                {
                    bot->GetMotionMaster()->MovePoint(0, go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(), true);
                    t.lastMoveOrder = now;
                }
                return true;
            }
            bot->StopMoving();
            t.usedGos[go->GetGUID()] = now + 10000;
            go->Use(bot);
            Count(BLC_BG_FLAG);
            return true;
        }
    }

    // enemies close by (WSG defenders hunt the enemy flag carrier anywhere on the map)
    Player* enemy = nullptr;
    float best = 45.0f;
    if (wsg && bot->GetGUID().GetCounter() % 3 != 0)
    {
        Map::PlayerList const& pl = bot->GetMap()->GetPlayers();
        for (Map::PlayerList::const_iterator itr = pl.begin(); itr != pl.end(); ++itr)
        {
            Player* p = itr->GetSource();
            if (p && p->IsAlive() && p->GetBGTeamId() != bot->GetBGTeamId() && p->HasAura(CARRIED_FLAG_AURA[1 - teamIdx])
                && bot->IsValidAttackTarget(p))
            {
                enemy = p;
                best = 0.0f;
                break;
            }
        }
    }
    Map::PlayerList const& players = bot->GetMap()->GetPlayers();
    for (Map::PlayerList::const_iterator itr = players.begin(); itr != players.end(); ++itr)
    {
        Player* p = itr->GetSource();
        if (!p || !p->IsAlive() || p->GetBGTeamId() == bot->GetBGTeamId() || !bot->IsValidAttackTarget(p))
            continue;
        float d = bot->GetExactDist(p);
        if (enemy && best == 0.0f)
            break;   // flag carrier found
        if (d < best && bot->IsWithinLOSInMap(p))
        {
            best = d;
            enemy = p;
        }
    }
    if (enemy)
    {
        Dismount(bot);
        botAI->GetAiObjectContext()->GetValue<Unit*>("current target")->Set(enemy);
        bot->SetSelection(enemy->GetGUID());
        if (bot->GetVictim() != enemy)
            bot->Attack(enemy, true);
        if (!bot->isMoving() || now - t.lastMoveOrder > 1500)
        {
            bot->GetMotionMaster()->MoveChase(enemy);
            t.lastMoveOrder = now;
        }
        return true;
    }

    // banners in reach: capture
    if (now >= t.nextGoSearch)
    {
        t.nextGoSearch = now + 3000;
        std::list<GameObject*> banners;
        BannerCheck check{ bot, 30.0f };
        Trinity::GameObjectListSearcher<BannerCheck> searcher(bot, banners, check);
        bot->VisitNearbyGridObject(30.0f, searcher);
        GameObject* banner = nullptr;
        for (GameObject* go : banners)
        {
            auto used = t.usedGos.find(go->GetGUID());
            if (used != t.usedGos.end() && now < used->second)
                continue;
            banner = go;
            break;
        }
        t.useGo = banner ? banner->GetGUID() : ObjectGuid::Empty;
    }
    if (!t.useGo.IsEmpty())
    {
        GameObject* go = ObjectAccessor::GetGameObject(*bot, t.useGo);
        if (!go || !go->isSpawned())
            t.useGo.Clear();
        else if (bot->GetExactDist(go) > 4.0f)
        {
            if (!bot->isMoving() || now - t.lastMoveOrder > 2000)
            {
                Dismount(bot);
                bot->GetMotionMaster()->MovePoint(0, go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(), true);
                t.lastMoveOrder = now;
            }
            return true;
        }
        else
        {
            // like a player: "cast" the opening for a moment, then the battleground handles the click
            // (go->Use() does not capture: the core routes captures through the open-lock spell effect)
            bot->StopMoving();
            Dismount(bot);
            if (!t.bgCaptureAt)
            {
                t.bgCaptureAt = now + 1500;
                bot->SetFacingToObject(go);
                return true;
            }
            if (now < t.bgCaptureAt)
                return true;
            t.bgCaptureAt = 0;
            GameObjectTemplate const* goInfo = go->GetGOInfo();
            bool flag = (goInfo->type == GAMEOBJECT_TYPE_BUTTON && goInfo->button.noDamageImmune)
                || (goInfo->type == GAMEOBJECT_TYPE_GOOBER && goInfo->goober.losOK);
            if (flag && bot->CanUseBattlegroundObject(go))
            {
                bg->EventPlayerClickedOnFlag(bot, go);
                Count(BLC_BG_CAPTURE);
            }
            t.usedGos[go->GetGUID()] = now + 60000;
            t.useGo.Clear();
            return true;
        }
    }

    // WSG: a third of the team goes for the enemy flag
    if (wsg && bot->GetGUID().GetCounter() % 3 == 0)
    {
        float const* enemyStand = flagBg->stand[1 - teamIdx];
        if (bot->GetExactDist(enemyStand[0], enemyStand[1], enemyStand[2]) > 15.0f)
        {
            if (!t.hasDest || std::fabs(t.destX - enemyStand[0]) > 1.0f)
                SetDest(t, bot->GetMapId(), enemyStand[0], enemyStand[1], enemyStand[2], 5.0f);
            Travel(bot, t, now);
            return true;
        }
    }

    // roam between the battleground's graveyards (they sit next to the objectives)
    if (!t.hasDest || Arrived(bot, t) || now >= t.stateUntil)
    {
        std::vector<WorldSafeLocsEntry const*> locs;
        for (uint32 i = 0; i < sWorldSafeLocsStore.GetNumRows(); ++i)
            if (WorldSafeLocsEntry const* loc = sWorldSafeLocsStore.LookupEntry(i))
                if (loc->map_id == bot->GetMapId() && bot->GetExactDist2d(loc->x, loc->y) > 30.0f)
                    locs.push_back(loc);
        if (locs.empty())
            return false;
        WorldSafeLocsEntry const* loc = locs[urand(0, locs.size() - 1)];
        SetDest(t, bot->GetMapId(), loc->x + frand(-8.0f, 8.0f), loc->y + frand(-8.0f, 8.0f), loc->z, 10.0f);
        t.stateUntil = now + urand(60, 120) * IN_MILLISECONDS;
    }
    t.wantMount = true;
    Travel(bot, t, now);
    if (!t.hasDest)
        t.stateUntil = now;   // stuck: another objective next time
    return true;
}
