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
#include <algorithm>
#include <atomic>
#include <map>
#include <sstream>
#include <vector>

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
                npc->AI()->OnGossipSelect(bot, menu, option);
                handler->PSendSysMessage("qt: %s picked option %u of menu %u at %s", name, option, menu, npc->GetName().c_str());
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
                handler->PSendSysMessage("qt:   hp %u%%, victim %s, unit_flags 0x%X, flying %u, visible %u, faction %u, bot may attack %u, hostile %u, bot victim %s",
                    uint32(c->GetHealthPct()), c->GetVictim() ? c->GetVictim()->GetName().c_str() : "-", c->GetUInt32Value(UNIT_FIELD_FLAGS),
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
            handler->PSendSysMessage("usage: .botlife qt add|gossip|status|path <bot> ...");
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
