/*
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

#include "Chat.h"
#include "CreatureAI.h"   // .botlife qt gossip
#include "PlayerbotMgr.h"
#include "PerformanceMonitor.h"
#include "PlayerbotAIConfig.h"
#include "RandomPlayerbotMgr.h"
#include "ScriptMgr.h"
#include "BotLife.h"
#include "Playerbots.h"
#include "PlayerbotAI.h"
#include "Vehicle.h"
#include "MoveSpline.h"
#include "PathGenerator.h"
#include <set>
#include "Player.h"
#include "GossipDef.h"
#include "ChatPackets.h"
#include "NPCPackets.h"
#include "GameObjectPackets.h"
#include "AreaTriggerPackets.h"
#include "DBCStores.h"
#include "SpellMgr.h"
#include "WorldSession.h"
#include "Opcodes.h"
#include "WorldPacket.h"
#include "DB2Stores.h"
#include "BattlePetMgr.h"
#include <algorithm>
#include <atomic>
#include <map>
#include <sstream>
#include <vector>

// bots a test holds still: '.botlife qt hold'. Written in the world thread, read in the map threads.
struct QtHold
{
    std::atomic<uint32> guid{0};
    std::atomic<uint32> until{0};
};
static QtHold g_qtHold[16];
bool QtIsHeld(uint32 guidLow)
{
    for (QtHold& h : g_qtHold)
        if (h.guid.load(std::memory_order_relaxed) == guidLow)
            return int32(h.until.load(std::memory_order_relaxed) - getMSTime()) > 0;
    return false;
}

class playerbots_commandscript : public CommandScript
{
public:
    playerbots_commandscript() : CommandScript("playerbots_commandscript") {}

    std::vector<ChatCommand> GetCommands() const override
    {
        static std::vector<ChatCommand> commandTable =
        {
            { "npcbot", &HandlePlayerbotCommand, rbac::RBAC_PERM_COMMAND_NPCBOT, Trinity::ChatCommands::Console::Yes },
            { "pmon",   &HandlePerfMonCommand,   rbac::RBAC_PERM_COMMAND_PMON,   Trinity::ChatCommands::Console::Yes },
            { "botlife", &HandleBotLifeCommand,  rbac::RBAC_PERM_COMMAND_PMON,   Trinity::ChatCommands::Console::Yes },
        };
        return commandTable;
    }

    static bool HandlePlayerbotCommand(ChatHandler* handler, char const* args)
    {
        return PlayerbotMgr::HandlePlayerbotMgrCommand(handler, args);
    }

    // .botlife [stats|reset|reload]
    static bool HandleBotLifeCommand(ChatHandler* handler, char const* args)
    {
        if (args && !strcmp(args, "reset"))
        {
            sBotLife->ResetStats();
            handler->SendSysMessage("BotLife stats reset");
            return true;
        }
        if (args && !strcmp(args, "reload"))
        {
            sBotLife->ReloadConfig();
            handler->SendSysMessage("BotLife config reloaded (call .reload config first for changed files)");
            return true;
        }
        if (args && !strncmp(args, "bgtest ", 7))
        {
            uint32 bgType = 0, level = 0;
            if (sscanf(args + 7, "%u %u", &bgType, &level) != 2)
            {
                handler->SendSysMessage("usage: .botlife bgtest <bgTypeId> <level>");
                return true;
            }
            sBotLife->TestBattleground(handler, bgType, level);
            return true;
        }
        if (args && !strcmp(args, "mapstats"))
        {
            sBotLife->PrintMapStats(handler);
            return true;
        }
        if (args && !strcmp(args, "questcoverage"))
        {
            sBotLife->PrintQuestCoverage(handler);
            return true;
        }
        if (args && !strncmp(args, "creature ", 9))
        {
            sBotLife->PrintCreatureStats(handler, uint32(atoi(args + 9)));
            return true;
        }
        // movement diagnostics - the bots hop over the terrain and fly through the air
        if (args && !strcmp(args, "pathstats"))
        {
            extern std::atomic<uint32> tt_pathStats[8];   // BotLife.cpp
            std::ostringstream out;
            out << "travel orders sampled " << tt_pathStats[0].load() << ": normal " << tt_pathStats[5].load() << ", incomplete "
                << tt_pathStats[3].load() << ", no navmesh/tile (straight line) " << tt_pathStats[1].load() << ", no path "
                << tt_pathStats[2].load() << ", shortcut " << tt_pathStats[4].load() << ", other " << tt_pathStats[6].load()
                << " | start far from the mesh " << tt_pathStats[7].load();
            handler->SendSysMessage(out.str().c_str());
            return true;
        }
        // ".botlife pathtest <map> <x> <y> <z> [spawnId]" - the navmesh path from the bots on that map (or
        // from that creature) to a point, the ground and the water there
        if (args && !strncmp(args, "pathtest ", 9))
        {
            uint32 mapId = 0;
            float x = 0.0f, y = 0.0f, z = 0.0f;
            unsigned long long spawnId = 0;
            if (sscanf(args + 9, "%u %f %f %f %llu", &mapId, &x, &y, &z, &spawnId) < 4)
            {
                handler->SendSysMessage("usage: .botlife pathtest <map> <x> <y> <z> [spawnId]");
                return true;
            }
            std::set<uint32> instances;
            for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
            {
                Player* bot = pair.second;
                if (!bot || !bot->IsInWorld() || bot->GetMapId() != mapId || !instances.insert(bot->GetInstanceId()).second || instances.size() > 3)
                    continue;
                Map* map = bot->GetMap();
                Unit* from = bot;
                if (spawnId)
                {
                    auto range = map->GetCreatureBySpawnIdStore().equal_range(spawnId);
                    from = range.first != range.second ? range.first->second : nullptr;
                    if (!from)
                        continue;
                }
                PathGenerator path(from);
                path.CalculatePath(x, y, z, false);
                Movement::PointsArray const& points = path.GetPath();
                float length = 0.0f;
                for (size_t i = 1; i < points.size(); ++i)
                    length += (points[i] - points[i - 1]).length();
                G3D::Vector3 const& end = path.GetActualEndPosition();
                std::ostringstream out;
                out.setf(std::ios::fixed);
                out.precision(1);
                out << from->GetName() << " (instance " << bot->GetInstanceId() << ") at " << from->GetPositionX() << ' ' << from->GetPositionY() << ' '
                    << from->GetPositionZ() << ": type 0x" << std::hex << uint32(path.GetPathType()) << std::dec << ", " << points.size() << " points, "
                    << length << " yd, end " << end.x << ' ' << end.y << ' ' << end.z << " (" << (end - G3D::Vector3(x, y, z)).length()
                    << " yd short) | ground at the point " << map->GetHeight(from->GetPhaseMask(), x, y, z + 2.0f, true, 50.0f)
                    << ", in water " << map->IsInWater(from->GetPhaseMask(), x, y, z) << ", under water " << map->IsUnderWater(from->GetPhaseMask(), x, y, z);
                handler->SendSysMessage(out.str().c_str());
            }
            if (instances.empty())
                handler->SendSysMessage("no bot on that map");
            return true;
        }
        if (args && !strcmp(args, "moveflags"))
        {
            std::map<uint32, uint32> flags;
            uint32 total = 0, moving = 0, onSpline = 0, mounted = 0;
            for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
            {
                Player* bot = pair.second;
                if (!bot || !bot->IsInWorld())
                    continue;
                ++total;
                ++flags[bot->m_movementInfo.GetMovementFlags()];
                if (bot->isMoving())
                    ++moving;
                if (!bot->movespline->Finalized())
                    ++onSpline;
                if (bot->IsMounted())
                    ++mounted;
            }
            std::vector<std::pair<uint32, uint32>> top(flags.begin(), flags.end());
            std::sort(top.begin(), top.end(), [](auto const& a, auto const& b) { return a.second > b.second; });
            std::ostringstream out;
            out << "bots " << total << ", moving " << moving << ", on a spline " << onSpline << ", mounted " << mounted << " | movement flags:";
            for (size_t i = 0; i < top.size() && i < 14; ++i)
                out << " 0x" << std::hex << top[i].first << std::dec << '=' << top[i].second;
            handler->SendSysMessage(out.str().c_str());
            return true;
        }
        if (args && !strcmp(args, "casts"))
        {
            sBotLife->PrintCastStats(handler);
            return true;
        }
        if (args && !strncmp(args, "castdiag", 8))
        {
            int32 n = args[8] ? std::max(1, atoi(args + 8)) : 12;
            sBotLife->StartCastDiag(n);
            handler->PSendSysMessage("castdiag: next %d caster bots in combat log CASTDIAG lines", n);
            return true;
        }
        if (args && !strncmp(args, "aggrodiag", 9))
        {
            int32 n = args[9] ? std::max(1, atoi(args + 9)) : 12;
            sBotLife->StartAggroDiag(n);
            handler->PSendSysMessage("aggrodiag: next %d bots fighting neutral creatures log AGGRODIAG lines", n);
            return true;
        }
        if (args && !strncmp(args, "testlevel", 9))   // ".botlife testlevel <level> <count>" (test lab)
        {
            uint32 level = 0;
            int32 count = 0;
            if (sscanf(args + 9, "%u %d", &level, &count) != 2 || level < 2 || level > 90 || count < 1)
            {
                handler->PSendSysMessage("usage: .botlife testlevel <level 2-90> <count>");
                return true;
            }
            sBotLife->StartTestLevel(level, count);
            handler->PSendSysMessage("testlevel: the next %d solo bots below level %u are raised to it (TESTLEVEL lines)", count, level);
            return true;
        }
        if (args && !strncmp(args, "movediag", 8))   // to-do #64: creature spline speeds (MOVEDIAG)
        {
            extern std::atomic<int32> g_ttMoveDiagLeft;
            extern std::atomic<uint32> g_ttMoveDiagEntry;
            int32 count = 0;
            uint32 entry = 0;
            if (sscanf(args + 8, "%d %u", &count, &entry) < 1 || count < 1)
            {
                handler->PSendSysMessage("usage: .botlife movediag <count> [entry]");
                return true;
            }
            g_ttMoveDiagEntry = entry;
            g_ttMoveDiagLeft = count;
            handler->PSendSysMessage("movediag: the next %d creature splines%s go to Server.log (MOVEDIAG)", count, entry ? " of that entry" : "");
            return true;
        }
        if (args && !strncmp(args, "lfgtest", 7))   // dungeon finder test with five bots
        {
            char sub[16] = {0};
            uint32 dungeon = 0;
            int const n = sscanf(args + 7, "%15s %u", sub, &dungeon);
            std::string result;
            if (n >= 1 && !strcmp(sub, "status"))
                result = sBotLife->LfgTestStatus();
            else if (n == 2 && !strcmp(sub, "queue"))
                result = sBotLife->LfgTestQueue(dungeon);
            else
                result = "usage: .botlife lfgtest queue <dungeonId> | status";
            std::istringstream lines(result);
            for (std::string line; std::getline(lines, line);)
                handler->SendSysMessage(line.c_str());
            return true;
        }
        if (args && !strncmp(args, "walk", 4))   // walkers - a test bot per starting area
        {
            char sub[16] = {0}, name[64] = {0}, zones[256] = {0};
            int const n = sscanf(args + 4, "%15s %63s %255s", sub, name, zones);
            std::string result;
            if (n >= 1 && !strcmp(sub, "status"))
                result = sBotLife->WalkStatus();
            else if (n >= 2 && !strcmp(sub, "remove"))
                result = sBotLife->WalkRemove(name);
            else if (n == 3 && !strcmp(sub, "add"))
                result = sBotLife->WalkAdd(name, zones);
            else if (n >= 2 && !strcmp(sub, "clear"))
                result = sBotLife->WalkClear(name);
            else
                result = "usage: .botlife walk add <bot> <questSort,...> | remove <bot> | status";
            std::istringstream lines(result);
            for (std::string line; std::getline(lines, line);)
                handler->SendSysMessage(line.c_str());
            return true;
        }
        if (args && !strncmp(args, "qt ", 3))   // quest script test with a bot (dev realm)
        {
            char sub[16] = {}, name[64] = {};
            if (sscanf(args + 3, "%15s %63s", sub, name) != 2)
            {
                handler->PSendSysMessage("usage: .botlife qt add|gossip|status <bot> ...");
                return true;
            }
            Player* bot = ObjectAccessor::FindPlayerByName(name);
            if (!bot || !bot->IsInWorld())
            {
                handler->PSendSysMessage("qt: %s is not online", name);
                return true;
            }
            char const* rest = strstr(args + 3, name) + strlen(name);
            if (!strcmp(sub, "add"))
            {
                uint32 questId = 0, map = 0;
                float x = 0.0f, y = 0.0f, z = 0.0f;
                Quest const* quest = nullptr;
                if (sscanf(rest, "%u %u %f %f %f", &questId, &map, &x, &y, &z) != 5 || !(quest = sObjectMgr->GetQuestTemplate(questId)))
                {
                    handler->PSendSysMessage("usage: .botlife qt add <bot> <questId> <map> <x> <y> <z>");
                    return true;
                }
                for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)   // no second slot for the same quest
                    if (bot->GetQuestSlotQuestId(slot) == questId && bot->GetQuestStatus(questId) == QUEST_STATUS_NONE)
                        bot->SetQuestSlot(slot, 0);
                if (bot->GetQuestStatus(questId) == QUEST_STATUS_NONE && bot->FindQuestSlot(0) < MAX_QUEST_LOG_SIZE)
                    bot->AddQuestAndCheckCompletion(quest, nullptr);
                // the teleport runs in the bot's own update (BotLife teleport queue), as for every bot teleport
                if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot))
                {
                    botAI->life.teleMap = map;
                    botAI->life.teleX = x;
                    botAI->life.teleY = y;
                    botAI->life.teleZ = z;
                    botAI->life.teleO = bot->GetOrientation();
                    botAI->life.teleQueued = true;
                }
                handler->PSendSysMessage("qt: %s has quest %u (status %u), teleport queued", name, questId, uint32(bot->GetQuestStatus(questId)));
                return true;
            }
            if (!strcmp(sub, "accept"))   // (4-10: from the NPC, its accept scripts run)
            {
                uint32 entry = 0, questId = 0;
                Quest const* quest = nullptr;
                if (sscanf(rest, "%u %u", &entry, &questId) != 2 || !(quest = sObjectMgr->GetQuestTemplate(questId)))
                {
                    handler->PSendSysMessage("usage: .botlife qt accept <bot> <npcEntry> <questId>");
                    return true;
                }
                Creature* npc = bot->FindNearestCreature(entry, 100.0f);
                if (!npc)
                {
                    handler->PSendSysMessage("qt: no creature %u within 100 yd of %s", entry, name);
                    return true;
                }
                if (bot->GetQuestStatus(questId) != QUEST_STATUS_NONE)
                {
                    uint16 slot = bot->FindQuestSlot(questId);
                    if (slot < MAX_QUEST_LOG_SIZE)
                        bot->SetQuestSlot(slot, 0);
                    bot->RemoveActiveQuest(questId, false);
                    bot->RemoveRewardedQuest(questId);
                }
                bot->AddQuestAndCheckCompletion(quest, npc);
                handler->PSendSysMessage("qt: %s took quest %u from %s (status %u)", name, questId, npc->GetName().c_str(), uint32(bot->GetQuestStatus(questId)));
                return true;
            }
            if (!strcmp(sub, "battlepet"))   // a battle pet in the bot's journal, to test the battle pet quests
            {
                uint32 species = 0, level = 1;
                if (sscanf(rest, "%u %u", &species, &level) < 1 || !species || level < 1 || level > 25 || !sBattlePetSpeciesStore.LookupEntry(species))
                {
                    handler->PSendSysMessage("usage: .botlife qt battlepet <bot> <speciesId> <level 1-25>");
                    return true;
                }
                bot->GetBattlePetMgr().Create(species, uint8(level));
                uint32 pets = 0, highest = 0;
                for (BattlePet* pet : bot->GetBattlePetMgr().BattlePets)
                    if (pet)
                    {
                        ++pets;
                        highest = std::max<uint32>(highest, pet->GetLevel());
                    }
                handler->PSendSysMessage("qt: %s has %u battle pets, highest level %u", name, pets, highest);
                return true;
            }
            if (!strcmp(sub, "offer"))   // what this quest giver offers the bot right now
            {
                uint32 entry = 0;
                if (sscanf(rest, "%u", &entry) != 1)
                {
                    handler->PSendSysMessage("usage: .botlife qt offer <bot> <npcEntry>");
                    return true;
                }
                Creature* npc = bot->FindNearestCreature(entry, 100.0f);
                if (!npc)
                {
                    handler->PSendSysMessage("qt: no creature %u within 100 yd of %s", entry, name);
                    return true;
                }
                uint32 offered = 0, listed = 0;
                for (uint32 questId : sObjectMgr->GetCreatureQuestRelations(entry))
                {
                    Quest const* q = sObjectMgr->GetQuestTemplate(questId);
                    if (!q)
                        continue;
                    QuestStatus const st = bot->GetQuestStatus(questId);
                    bool const can = st == QUEST_STATUS_NONE && bot->CanTakeQuest(q, false);
                    handler->PSendSysMessage("qt:   %u %s (min level %u): %s", questId, q->GetLogTitle().c_str(), uint32(q->GetMinLevel()),
                        can ? "OFFERED" : st == QUEST_STATUS_REWARDED ? "done before" : st != QUEST_STATUS_NONE ? "in the log" : "not offered");
                    ++listed;
                    if (can)
                        ++offered;
                }
                uint32 handIn = 0;
                for (uint32 questId : sObjectMgr->GetCreatureQuestInvolvedRelations(entry))
                    if (bot->GetQuestStatus(questId) == QUEST_STATUS_COMPLETE)
                    {
                        handler->PSendSysMessage("qt:   %u can be handed in here", questId);
                        ++handIn;
                    }
                handler->PSendSysMessage("qt: %s (%u) offers %s %u of its %u quests, %u to hand in", npc->GetName().c_str(), entry, name, offered, listed, handIn);
                return true;
            }
            if (!strcmp(sub, "hello"))   // the gossip hello of a client, through the session handler
            {
                uint32 entry = 0;
                if (sscanf(rest, "%u", &entry) != 1)
                {
                    handler->PSendSysMessage("usage: .botlife qt hello <bot> <npcEntry>");
                    return true;
                }
                Creature* npc = bot->FindNearestCreature(entry, 100.0f);
                if (!npc)
                {
                    handler->PSendSysMessage("qt: no creature %u within 100 yd of %s", entry, name);
                    return true;
                }
                float const dist = bot->GetDistance(npc);
                WorldPackets::NPC::GossipHello hello{ WorldPacket(CMSG_GOSSIP_HELLO, 8) };
                hello.Unit = npc->GetGUID();
                bot->GetSession()->HandleGossipHelloOpcode(hello);
                // the menu the bot was shown
                std::ostringstream options;
                GossipMenu& helloMenu = bot->PlayerTalkClass->GetGossipMenu();
                for (auto const& menuItem : helloMenu.GetMenuItems())
                    options << " [" << menuItem.first << "] " << menuItem.second.Message.substr(0, 30);
                handler->PSendSysMessage("qt: %s said hello to %s (%u) at %.0f yd; menu %u:%s", name, npc->GetName().c_str(), entry, dist,
                    helloMenu.GetMenuId(), options.str().empty() ? " no options" : options.str().c_str());
                return true;
            }
            if (!strcmp(sub, "hold"))   // the bot stands still and plans nothing for a while
            {
                uint32 seconds = 0;
                if (sscanf(rest, "%u", &seconds) != 1 || seconds > 3600)
                {
                    handler->PSendSysMessage("usage: .botlife qt hold <bot> <seconds, 0 = release>");
                    return true;
                }
                uint32 const guid = bot->GetGUID().GetCounter();
                uint32 const until = seconds ? getMSTime() + seconds * 1000 : 0;
                bool stored = false;
                for (QtHold& h : g_qtHold)   // the bot's own slot first, then a free or expired one
                    if (h.guid.load() == guid)
                    {
                        h.until.store(until);
                        stored = true;
                    }
                for (QtHold& h : g_qtHold)
                    if (!stored && (!h.guid.load() || int32(h.until.load() - getMSTime()) <= 0))
                    {
                        h.until.store(until);
                        h.guid.store(guid);
                        stored = true;
                    }
                if (seconds)
                    bot->StopMoving();
                handler->PSendSysMessage(stored ? "qt: %s holds still for %u s" : "qt: no free hold slot for %s (%u s asked)", name, seconds);
                return true;
            }
            if (!strcmp(sub, "reward"))   // a quest done and rewarded without a quest giver, for test set-ups
            {
                uint32 questId = 0;
                Quest const* q = sscanf(rest, "%u", &questId) == 1 ? sObjectMgr->GetQuestTemplate(questId) : nullptr;
                if (!q)
                {
                    handler->PSendSysMessage("usage: .botlife qt reward <bot> <questId>");
                    return true;
                }
                if (!bot->GetQuestRewardStatus(questId))
                {
                    if (bot->GetQuestStatus(questId) == QUEST_STATUS_NONE)
                        bot->AddQuest(q, nullptr);
                    bot->CompleteQuest(questId);
                    bot->RewardQuest(q, 0, bot, false);
                }
                handler->PSendSysMessage("qt: quest %u of %s: status %u, rewarded %u", questId, name, uint32(bot->GetQuestStatus(questId)),
                    uint32(bot->GetQuestRewardStatus(questId)));
                return true;
            }
            if (!strcmp(sub, "handin"))   // the reward packet of a client, through the session handler
            {
                uint32 entry = 0, questId = 0, reward = 0;
                if (sscanf(rest, "%u %u %u", &entry, &questId, &reward) < 2 || !sObjectMgr->GetQuestTemplate(questId))
                {
                    handler->PSendSysMessage("usage: .botlife qt handin <bot> <npcEntry> <questId> [rewardItemId]");
                    return true;
                }
                WorldObject* npc = bot->FindNearestCreature(entry, 100.0f);
                if (!npc)
                    npc = bot->FindNearestGameObject(entry, 100.0f);   // a quest object
                if (!npc)
                {
                    handler->PSendSysMessage("qt: no creature or object %u within 100 yd of %s", entry, name);
                    return true;
                }
                ObjectGuid guid = npc->GetGUID();
                WorldPacket data(CMSG_QUESTGIVER_CHOOSE_REWARD, 4 + 4 + 1 + 8);
                data << uint32(reward);
                data << uint32(questId);
                data.WriteBit(guid[2]);
                data.WriteBit(guid[6]);
                data.WriteBit(guid[0]);
                data.WriteBit(guid[5]);
                data.WriteBit(guid[1]);
                data.WriteBit(guid[3]);
                data.WriteBit(guid[7]);
                data.WriteBit(guid[4]);
                data.FlushBits();
                data.WriteByteSeq(guid[1]);
                data.WriteByteSeq(guid[2]);
                data.WriteByteSeq(guid[5]);
                data.WriteByteSeq(guid[7]);
                data.WriteByteSeq(guid[0]);
                data.WriteByteSeq(guid[3]);
                data.WriteByteSeq(guid[6]);
                data.WriteByteSeq(guid[4]);
                uint32 const before = uint32(bot->GetQuestStatus(questId));
                float const dist = bot->GetDistance(npc);
                bot->GetSession()->HandleQuestgiverChooseRewardOpcode(data);
                handler->PSendSysMessage("qt: %s sent the hand-in of quest %u to %s at %.0f yd: status %u -> %u, rewarded %u", name, questId,
                    npc->GetName().c_str(), dist, before, uint32(bot->GetQuestStatus(questId)), uint32(bot->GetQuestRewardStatus(questId)));
                return true;
            }
            if (!strcmp(sub, "take"))   // the accept packet of a client, through the session handler
            {
                uint32 entry = 0, questId = 0;
                if (sscanf(rest, "%u %u", &entry, &questId) != 2 || !sObjectMgr->GetQuestTemplate(questId))
                {
                    handler->PSendSysMessage("usage: .botlife qt take <bot> <npcEntry> <questId>");
                    return true;
                }
                WorldObject* npc = bot->FindNearestCreature(entry, 100.0f);
                if (!npc)
                    npc = bot->FindNearestGameObject(entry, 100.0f);   // a quest object
                if (!npc)
                {
                    handler->PSendSysMessage("qt: no creature or object %u within 100 yd of %s", entry, name);
                    return true;
                }
                ObjectGuid guid = npc->GetGUID();
                WorldPacket data(CMSG_QUESTGIVER_ACCEPT_QUEST, 4 + 2 + 8);
                data << uint32(questId);
                data.WriteBit(guid[6]);
                data.WriteBit(guid[0]);
                data.WriteBit(0);   // startCheat
                data.WriteBit(guid[2]);
                data.WriteBit(guid[7]);
                data.WriteBit(guid[5]);
                data.WriteBit(guid[4]);
                data.WriteBit(guid[3]);
                data.WriteBit(guid[1]);
                data.FlushBits();
                data.WriteByteSeq(guid[5]);
                data.WriteByteSeq(guid[4]);
                data.WriteByteSeq(guid[0]);
                data.WriteByteSeq(guid[1]);
                data.WriteByteSeq(guid[6]);
                data.WriteByteSeq(guid[2]);
                data.WriteByteSeq(guid[3]);
                data.WriteByteSeq(guid[7]);
                float const dist = bot->GetDistance(npc);
                bot->GetSession()->HandleQuestgiverAcceptQuestOpcode(data);
                handler->PSendSysMessage("qt: %s sent the accept of quest %u to %s at %.0f yd: status %u", name, questId, npc->GetName().c_str(), dist,
                    uint32(bot->GetQuestStatus(questId)));
                return true;
            }
            if (!strcmp(sub, "item"))   // the bot uses an item from its bags, as a player does
            {
                uint32 itemEntry = 0, entry = 0;
                if (sscanf(rest, "%u %u", &itemEntry, &entry) < 1 || !itemEntry)
                {
                    handler->PSendSysMessage("usage: .botlife qt item <bot> <itemEntry> [creatureEntry]");
                    return true;
                }
                Item* item = bot->GetItemByEntry(itemEntry);
                if (!item)
                {
                    handler->PSendSysMessage("qt: %s has no item %u", name, itemEntry);
                    return true;
                }
                SpellCastTargets targets;
                Creature* target = entry ? bot->FindNearestCreature(entry, 60.0f) : nullptr;
                if (entry && !target)
                {
                    handler->PSendSysMessage("qt: no creature %u within 60 yd of %s", entry, name);
                    return true;
                }
                if (target)
                    targets.SetUnitTarget(target);
                bot->StopMoving();
                bot->CastItemUseSpell(item, targets, 0, 0);
                handler->PSendSysMessage("qt: %s used item %u%s at %.0f %.0f %.0f", name, itemEntry, target ? (" on " + target->GetName()).c_str() : "",
                    bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ());
                return true;
            }
            if (!strcmp(sub, "click"))   // the bot right-clicks a spell click creature, as a player does
            {
                uint32 entry = 0;
                if (sscanf(rest, "%u", &entry) != 1)
                {
                    handler->PSendSysMessage("usage: .botlife qt click <bot> <npcEntry>");
                    return true;
                }
                std::list<Creature*> list;
                bot->GetCreatureListWithEntryInGrid(list, entry, 60.0f);
                Creature* target = nullptr;
                for (Creature* c : list)
                    if (c->IsAlive() && !c->GetVehicle() && (!target || bot->GetExactDist(c) < bot->GetExactDist(target)))
                        target = c;
                if (!target)
                {
                    handler->PSendSysMessage("qt: no creature %u (alive, not carried) within 60 yd of %s", entry, name);
                    return true;
                }
                bool const flag = target->HasFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK);
                float const dist = bot->GetDistance(target);
                bot->TalkedToCreature(target->GetEntry(), target->GetGUID());
                bool const cast = target->HandleSpellClick(bot);
                handler->PSendSysMessage("qt: %s clicked %s (%u) at %.0f yd: spell click flag %u, click spell cast %u", name, target->GetName().c_str(),
                    entry, dist, uint32(flag), uint32(cast));
                return true;
            }
            if (!strcmp(sub, "trigger"))   // the bot steps into an area trigger, as a client reports it
            {
                uint32 triggerId = 0;
                AreaTriggerEntry const* at = sscanf(rest, "%u", &triggerId) == 1 ? sAreaTriggerStore.LookupEntry(triggerId) : nullptr;
                if (!at)
                {
                    handler->PSendSysMessage("usage: .botlife qt trigger <bot> <areaTriggerId>");
                    return true;
                }
                if (bot->GetMapId() != at->ContinentID || bot->GetExactDist(at->Pos.X, at->Pos.Y, at->Pos.Z) > 300.0f)
                {
                    handler->PSendSysMessage("qt: %s is not within 300 yd of area trigger %u (map %u %.0f %.0f %.0f)", name, triggerId, uint32(at->ContinentID),
                        at->Pos.X, at->Pos.Y, at->Pos.Z);
                    return true;
                }
                bot->NearTeleportTo(at->Pos.X, at->Pos.Y, at->Pos.Z, bot->GetOrientation());
                WorldPackets::AreaTrigger::AreaTrigger packet{ WorldPacket(CMSG_AREATRIGGER, 6) };
                packet.AreaTriggerID = triggerId;
                packet.Entered = true;
                packet.FromClient = true;
                bot->GetSession()->HandleAreaTriggerOpcode(packet);
                handler->PSendSysMessage("qt: %s entered area trigger %u at %.0f %.0f %.0f", name, triggerId, at->Pos.X, at->Pos.Y, at->Pos.Z);
                return true;
            }
            if (!strcmp(sub, "emote"))   // a text emote at a creature, through the session handler
            {
                uint32 entry = 0, emote = 0;
                if (sscanf(rest, "%u %u", &entry, &emote) != 2)
                {
                    handler->PSendSysMessage("usage: .botlife qt emote <bot> <npcEntry> <textEmoteId>   (22 chicken, 34 dance, 41 flex, 264 train)");
                    return true;
                }
                Creature* npc = bot->FindNearestCreature(entry, 100.0f);
                if (!npc)
                {
                    handler->PSendSysMessage("qt: no creature %u within 100 yd of %s", entry, name);
                    return true;
                }
                float const dist = bot->GetDistance(npc);
                WorldPackets::Chat::CTextEmote textEmote{ WorldPacket(CMSG_TEXT_EMOTE, 16) };
                textEmote.Target = npc->GetGUID();
                textEmote.EmoteID = emote;
                bot->GetSession()->HandleTextEmoteOpcode(textEmote);
                handler->PSendSysMessage("qt: %s did text emote %u at %s (%u) at %.0f yd", name, emote, npc->GetName().c_str(), entry, dist);
                return true;
            }
            if (!strcmp(sub, "give"))   // an item into the bags of the bot, as .additem does for a selected player
            {
                uint32 itemId = 0, count = 1;
                if (sscanf(rest, "%u %u", &itemId, &count) < 1 || !count || !sObjectMgr->GetItemTemplate(itemId))
                {
                    handler->PSendSysMessage("usage: .botlife qt give <bot> <itemId> [count]");
                    return true;
                }
                ItemPosCountVec dest;
                uint32 noSpace = 0;
                InventoryResult const msg = bot->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, itemId, count, &noSpace);
                if (msg != EQUIP_ERR_OK)
                    count -= std::min(count, noSpace);
                if (!count || dest.empty())
                {
                    handler->PSendSysMessage("qt: %s has no room for item %u (inventory result %u)", name, itemId, uint32(msg));
                    return true;
                }
                bot->StoreNewItem(dest, itemId, true, Item::GenerateItemRandomPropertyId(itemId));
                handler->PSendSysMessage("qt: %s got %u of item %u, has %u now", name, count, itemId, bot->GetItemCount(itemId));
                return true;
            }
            if (!strcmp(sub, "kill"))   // the bot kills a creature at once: the kill objective without the fight
            {
                uint32 entry = 0;
                if (sscanf(rest, "%u", &entry) != 1)
                {
                    handler->PSendSysMessage("usage: .botlife qt kill <bot> <npcEntry>");
                    return true;
                }
                std::list<Creature*> list;
                bot->GetCreatureListWithEntryInGrid(list, entry, 60.0f);
                Creature* target = nullptr;
                for (Creature* c : list)
                    if (c->IsAlive() && (!target || bot->GetExactDist(c) < bot->GetExactDist(target)))
                        target = c;
                if (!target)
                {
                    handler->PSendSysMessage("qt: no living creature %u within 60 yd of %s", entry, name);
                    return true;
                }
                std::string const targetName = target->GetName();
                uint32 const level = target->GetLevel(), health = target->GetHealth(), maxHealth = target->GetMaxHealth();
                float const dist = bot->GetDistance(target);
                bool const onBot = target->GetVictim() == bot;
                bot->DealDamage(target, target->GetHealth(), nullptr, DIRECT_DAMAGE, SPELL_SCHOOL_MASK_NORMAL, nullptr, false);
                handler->PSendSysMessage("qt: %s (level %u) killed %s (%u) of level %u with %u of %u health at %.0f yd; it was attacking the bot: %u",
                    name, uint32(bot->GetLevel()), targetName.c_str(), entry, level, health, maxHealth, dist, uint32(onBot));
                return true;
            }
            if (!strcmp(sub, "open"))   // the bot opens a container and takes what is in it
            {
                uint32 itemEntry = 0;
                if (sscanf(rest, "%u", &itemEntry) != 1)
                {
                    handler->PSendSysMessage("usage: .botlife qt open <bot> <itemId>");
                    return true;
                }
                Item* item = bot->GetItemByEntry(itemEntry);
                if (!item)
                {
                    handler->PSendSysMessage("qt: %s has no item %u", name, itemEntry);
                    return true;
                }
                ObjectGuid const itemGuid = item->GetGUID();
                WorldPacket data(CMSG_OPEN_ITEM, 2);
                data << uint8(item->GetBagSlot()) << uint8(item->GetSlot());
                bot->GetSession()->HandleOpenItemOpcode(data);
                std::ostringstream got;
                uint32 taken = 0;
                if (bot->GetLootGUID() == itemGuid)
                {
                    Loot* loot = &item->loot;
                    uint32 const slots = uint32(loot->items.size() + loot->quest_items.size());
                    for (uint32 slot = 0; slot < slots; ++slot)
                    {
                        if (slot < loot->items.size() && !loot->items[slot].is_looted)
                            got << " " << loot->items[slot].itemid << "x" << uint32(loot->items[slot].count);
                        bot->StoreLootItem(uint8(slot), loot);
                        ++taken;
                    }
                    bot->GetSession()->DoLootRelease(itemGuid);
                }
                handler->PSendSysMessage("qt: %s opened item %u, %u loot slots taken:%s", name, itemEntry, taken, got.str().c_str());
                return true;
            }
            if (!strcmp(sub, "cast"))   // the bot, or the vehicle it rides, casts a spell
            {
                uint32 spellId = 0;
                float x = 0.0f, y = 0.0f, z = 0.0f;
                int const n = sscanf(rest, "%u %f %f %f", &spellId, &x, &y, &z);
                if ((n != 1 && n != 4) || !sSpellMgr->GetSpellInfo(spellId))
                {
                    handler->PSendSysMessage("usage: .botlife qt cast <bot> <spellId> [x y z]");
                    return true;
                }
                Unit* caster = bot->GetVehicleBase() ? bot->GetVehicleBase() : bot;
                if (n == 4)
                    caster->CastSpell(x, y, z, spellId, false);
                else
                    caster->CastSpell(caster, spellId, false);
                handler->PSendSysMessage("qt: %s cast %u %s", caster->GetName().c_str(), spellId, n == 4 ? "at the spot" : "on itself");
                return true;
            }
            if (!strcmp(sub, "use"))   // the bot clicks a game object, as a player does
            {
                uint32 entry = 0;
                if (sscanf(rest, "%u", &entry) != 1)
                {
                    handler->PSendSysMessage("usage: .botlife qt use <bot> <goEntry>");
                    return true;
                }
                GameObject* go = bot->FindNearestGameObject(entry, 60.0f);
                if (!go)
                {
                    handler->PSendSysMessage("qt: no game object %u within 60 yd of %s", entry, name);
                    return true;
                }
                float const dist = bot->GetDistance(go);
                ObjectGuid const goGuid = go->GetGUID();
                std::string const goName = go->GetGOInfo()->name;
                uint32 const goType = uint32(go->GetGoType());
                go->Use(bot);
                // a client sends the report-use right after the use; scripts hang on it
                WorldPackets::GameObject::GameObjReportUse report{ WorldPacket(CMSG_GAMEOBJ_REPORT_USE, 8) };
                report.Guid = goGuid;
                bot->GetSession()->HandleGameobjectReportUse(report);
                // a chest is opened with the spell its lock asks for, as a client does
                uint32 openSpell = 0;
                if (goType == GAMEOBJECT_TYPE_CHEST && bot->GetLootGUID() != goGuid)
                    if (GameObject* locked = bot->GetMap()->GetGameObject(goGuid))
                    {
                        if (LockEntry const* lock = sLockStore.LookupEntry(locked->GetGOInfo()->GetLockId()))
                            for (uint8 i = 0; i < MAX_LOCK_CASE && !openSpell; ++i)
                            {
                                if (lock->Type[i] != LOCK_KEY_SKILL)
                                    continue;
                                for (auto const& known : bot->GetSpellMap())
                                {
                                    if (!known.second || known.second->state == PLAYERSPELL_REMOVED || known.second->disabled)
                                        continue;
                                    SpellInfo const* info = sSpellMgr->GetSpellInfo(known.first);
                                    if (!info)
                                        continue;
                                    for (uint8 e = 0; e < MAX_SPELL_EFFECTS && !openSpell; ++e)
                                        if (info->Effects[e].Effect == SPELL_EFFECT_OPEN_LOCK && uint32(info->Effects[e].MiscValue) == lock->Index[i])
                                            openSpell = known.first;
                                    if (openSpell)
                                        break;
                                }
                            }
                        if (openSpell)
                            bot->CastSpell(locked, openSpell, true);
                    }
                // a chest shows its loot; a client then takes every slot and closes the window
                std::ostringstream got;
                GameObject* chest = bot->GetLootGUID() == goGuid ? bot->GetMap()->GetGameObject(goGuid) : nullptr;
                if (chest)
                {
                    Loot* loot = &chest->loot;
                    for (LootItem const& li : loot->items)
                        if (!li.is_looted)
                            got << " " << li.itemid << "x" << uint32(li.count);
                    for (LootItem const& li : loot->quest_items)
                        if (!li.is_looted)
                            got << " quest " << li.itemid << "x" << uint32(li.count);
                    uint32 const slots = uint32(loot->items.size() + loot->quest_items.size());
                    for (uint32 slot = 0; slot < slots; ++slot)
                        bot->StoreLootItem(uint8(slot), loot);
                    bot->GetSession()->DoLootRelease(goGuid);
                }
                if (goType == GAMEOBJECT_TYPE_CHEST && !chest)
                    got << (openSpell ? "; the loot window did not open (opening spell " : "; no opening spell for its lock (") << openSpell << ")";
                handler->PSendSysMessage("qt: %s used %s (%u, type %u) at %.0f yd%s%s", name, goName.c_str(), entry, goType, dist,
                    chest ? "; loot in it:" : "", got.str().c_str());
                return true;
            }
            if (!strcmp(sub, "gossip"))
            {
                uint32 entry = 0, menu = 0, option = 0;
                if (sscanf(rest, "%u %u %u", &entry, &menu, &option) != 3)
                {
                    handler->PSendSysMessage("usage: .botlife qt gossip <bot> <npcEntry> <menuId> <option>");
                    return true;
                }
                Creature* npc = bot->FindNearestCreature(entry, 100.0f);
                if (!npc || !npc->AI())
                {
                    handler->PSendSysMessage("qt: no creature %u within 100 yd of %s", entry, name);
                    return true;
                }
                // a client can only pick an option of the menu it was shown (qt hello first); when it is
                // there the pick goes the way of the session handler, otherwise straight to the AI as before
                GossipMenu& shownMenu = bot->PlayerTalkClass->GetGossipMenu();
                bool const shown = shownMenu.GetMenuId() == menu && shownMenu.GetItem(option);
                if (shown)
                {
                    if (!sScriptMgr->OnGossipSelect(bot, npc, bot->PlayerTalkClass->GetGossipOptionSender(option), bot->PlayerTalkClass->GetGossipOptionAction(option))
                        && !npc->AI()->OnGossipSelect(bot, menu, option))
                        bot->OnGossipSelect(npc, option, menu);
                }
                else
                    npc->AI()->OnGossipSelect(bot, menu, option);
                handler->PSendSysMessage("qt: %s picked option %u of menu %u at %s (%s)", name, option, menu, npc->GetName().c_str(),
                    shown ? "shown in the open menu" : "NOT in the open menu, sent to the AI directly");
                return true;
            }
            if (!strcmp(sub, "status"))
            {
                uint32 questId = 0;
                Quest const* quest = nullptr;
                if (sscanf(rest, "%u", &questId) != 1 || !(quest = sObjectMgr->GetQuestTemplate(questId)))
                {
                    handler->PSendSysMessage("usage: .botlife qt status <bot> <questId>");
                    return true;
                }
                std::ostringstream out;
                out << "qt: " << name << " quest " << questId << " status " << uint32(bot->GetQuestStatus(questId))
                    << " at " << bot->GetMapId() << " " << int32(bot->GetPositionX()) << " " << int32(bot->GetPositionY())
                    << " " << int32(bot->GetPositionZ()) << (bot->GetVehicle() ? " (on a vehicle)" : "");
                out << " auras:";   // (4-10: which link of a spell chain is there)
                for (auto const& ap : bot->GetAppliedAuras())
                    if (Aura const* aura = ap.second->GetBase())
                        out << " " << aura->GetId() << "(" << aura->GetDuration() / 1000 << "s)";
                if (Unit* base = bot->GetVehicleBase())
                {
                    out << " seat " << int32(bot->GetTransSeat()) << " of " << base->GetName();
                    if (Vehicle* kit = base->GetVehicleKit())
                        for (int8 seat = 0; seat < 2; ++seat)
                        {
                            Unit* p = kit->GetPassenger(seat);
                            out << " [" << int32(seat) << ": " << (p ? p->GetName() : std::string("-")) << "]";
                        }
                }
                out << " |";
                for (QuestObjective const& obj : quest->GetObjectives())
                    out << " obj " << obj.ObjectID << " " << bot->GetQuestObjectiveCounter(obj.ID) << "/" << obj.Amount;
                handler->PSendSysMessage("%s", out.str().c_str());
                return true;
            }
            if (!strcmp(sub, "z"))
            {
                std::istringstream in(rest);
                float x = 0.0f, y = 0.0f;
                uint32 n = 0;
                while (in >> x >> y)
                {
                    float const z = bot->GetMap()->GetHeight(bot->GetPhaseMask(), x, y, 600.0f, true, 1000.0f);
                    TC_LOG_INFO("playerbots", "QTZ {} {} {:.2f} {:.2f} {:.2f}", name, n++, x, y, z);
                }
                handler->PSendSysMessage("qt: %u heights on map %u (QTZ lines)", n, bot->GetMapId());
                return true;
            }
            if (!strcmp(sub, "near"))
            {
                uint32 entry = 0;
                if (sscanf(rest, "%u", &entry) != 1)
                {
                    handler->PSendSysMessage("usage: .botlife qt near <bot> <npcEntry>");
                    return true;
                }
                Creature* c = bot->FindNearestCreature(entry, 1000.0f, true);
                if (!c)
                {
                    handler->PSendSysMessage("qt: no creature %u within 1000 yd of %s", entry, name);
                    return true;
                }
                handler->PSendSysMessage("qt: %s (%u) at %.0f %.0f %.0f dist %.0f, %s, %s, motion %u, react %u, passengers %u",
                    c->GetName().c_str(), entry, c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), bot->GetDistance(c),
                    c->IsAlive() ? "alive" : "dead", c->IsInCombat() ? "in combat" : "out of combat",
                    uint32(c->GetMotionMaster()->GetCurrentMovementGeneratorType()), uint32(c->GetReactState()),
                    c->GetVehicleKit() ? uint32(c->GetVehicleKit()->Seats.size() - c->GetVehicleKit()->GetAvailableSeatCount()) : 0u);
                // (4-10) why nobody fights it
                handler->PSendSysMessage("qt:   level %u, hp %u%%, victim %s, unit_flags 0x%X, flying %u, visible %u, faction %u, bot may attack %u, hostile %u, bot victim %s",
                    uint32(c->GetLevel()), uint32(c->GetHealthPct()), c->GetVictim() ? c->GetVictim()->GetName().c_str() : "-", c->GetUInt32Value(UNIT_FIELD_FLAGS),
                    c->IsFlying() ? 1u : 0u, c->IsVisible() ? 1u : 0u, c->GetFaction(), bot->IsValidAttackTarget(c) ? 1u : 0u,
                    c->IsHostileTo(bot) ? 1u : 0u, bot->GetVictim() ? bot->GetVictim()->GetName().c_str() : "-");
                return true;
            }
            if (!strcmp(sub, "reset"))
            {
                uint32 questId = 0;
                if (sscanf(rest, "%u", &questId) != 1)
                {
                    handler->PSendSysMessage("usage: .botlife qt reset <bot> <questId>");
                    return true;
                }
                // the log slots too, else a ghost entry stays and a later add takes a second slot
                for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
                    if (bot->GetQuestSlotQuestId(slot) == questId)
                        bot->SetQuestSlot(slot, 0);
                bot->RemoveActiveQuest(questId, true, true);
                bot->RemoveRewardedQuest(questId);
                handler->PSendSysMessage("qt: quest %u removed from %s (status %u)", questId, name, uint32(bot->GetQuestStatus(questId)));
                return true;
            }
            if (!strcmp(sub, "path"))
            {
                float x = 0.0f, y = 0.0f, z = 0.0f;
                if (sscanf(rest, "%f %f %f", &x, &y, &z) != 3)
                {
                    handler->PSendSysMessage("usage: .botlife qt path <bot> <x> <y> <z>");
                    return true;
                }
                PathGenerator path(bot);
                path.SetUseStraightPath(true);
                path.CalculatePath(x, y, z, false);
                Movement::PointsArray const& points = path.GetPath();
                float length = 0.0f;
                for (size_t i = 0; i < points.size(); ++i)
                {
                    if (i)
                        length += (points[i] - points[i - 1]).length();
                    TC_LOG_INFO("playerbots", "QTPATH {} {} {:.2f} {:.2f} {:.2f}", name, uint32(i), points[i].x, points[i].y, points[i].z);
                }
                handler->PSendSysMessage("qt: path from %s - type 0x%X, %u points, length %.1f (QTPATH lines)", name,
                    uint32(path.GetPathType()), uint32(points.size()), length);
                return true;
            }
            handler->PSendSysMessage("usage: .botlife qt add|accept|take|handin|hello|reward|hold|offer|use|cast|open|give|kill|emote|trigger|click|item|battlepet|gossip|status|near|reset|path <bot> ...");
            return true;
        }
        if (args && !strncmp(args, "pathprobe", 9))   // ".botlife pathprobe <map> <x> <y> <z>"
        {
            uint32 map = 0;
            float x = 0.0f, y = 0.0f, z = 0.0f;
            if (sscanf(args + 9, "%u %f %f %f", &map, &x, &y, &z) != 4)
            {
                handler->PSendSysMessage("usage: .botlife pathprobe <map> <x> <y> <z>");
                return true;
            }
            sBotLife->StartPathProbe(map, x, y, z);
            handler->PSendSysMessage("pathprobe queued: the next bot on map %u logs PATHPROBE lines", map);
            return true;
        }
        if (args && !strncmp(args, "rangetest", 9))
        {
            int32 n = 10;
            uint32 entry = 0, maxLevel = 0;
            if (args[9])
                sscanf(args + 9, "%d %u %u", &n, &entry, &maxLevel);
            sBotLife->StartRangeTest(std::max(1, n), entry, maxLevel);
            handler->PSendSysMessage("rangetest: %d caster bots shoot a neutral creature, RANGETEST lines follow", n);
            return true;
        }
        if (args && !strcmp(args, "guilds"))
        {
            sBotLife->PrintGuilds(handler);
            return true;
        }
        if (args && !strncmp(args, "bot ", 4))
        {
            sBotLife->PrintBot(handler, std::string(args + 4));
            return true;
        }
        sBotLife->PrintStats(handler);
        return true;
    }

    static bool HandlePerfMonCommand(ChatHandler* handler, char const* args)
    {
        if (!strcmp(args, "reset"))
        {
            sPerformanceMonitor->Reset();
            return true;
        }

        if (!strcmp(args, "tick"))
        {
            sPerformanceMonitor->PrintStats(true, false);
            return true;
        }

        if (!strcmp(args, "stack"))
        {
            sPerformanceMonitor->PrintStats(false, true);
            return true;
        }

        if (!strcmp(args, "toggle"))
        {
            sPlayerbotAIConfig->perfMonEnabled = !sPlayerbotAIConfig->perfMonEnabled;
            if (sPlayerbotAIConfig->perfMonEnabled)
                TC_LOG_INFO("playerbots", "Performance monitor enabled");
            else
                TC_LOG_INFO("playerbots", "Performance monitor disabled");
            return true;
        }

        sPerformanceMonitor->PrintStats();
        return true;
    }
};

void AddSC_playerbots_commandscript() { new playerbots_commandscript(); }
