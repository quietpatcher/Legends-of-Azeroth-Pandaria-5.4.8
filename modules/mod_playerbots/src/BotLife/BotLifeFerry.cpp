/*
 * Bot life: bots ride boats and zeppelins between continents instead of being teleported (BotLife.Ferry, default off).
 *
 * RelocateForLevel() moves a bot to another continent with a teleport. FerryPlan() asks first: a bot that stands within
 * BotLife.FerryDockRange of a stop of a continent transport that also stops on the destination map walks to that stop,
 * waits for the transport, boards, rides, and is then put at the parked destination. Every failure (no transport in time,
 * the bot left the transport, a timeout) ends in the teleport the bot would have got anyway, so a trip never strands a bot.
 *
 * The docks come from the transport itself: the stop frames of its TransportTemplate (flag 2) and the map of each frame.
 */

#include "BotLife.h"
#include "Map.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "Playerbots.h"
#include "RandomPlayerbotMgr.h"
#include "Transport.h"
#include "TransportMgr.h"
#include "DatabaseEnv.h"
#include "Group.h"
#include "Log.h"
#include "Config.h"
#include <sstream>

namespace
{
    struct FerryStop
    {
        uint32 map;
        float x, y, z;
    };

    struct FerryTransport
    {
        uint32 guid;
        uint32 entry;
        std::vector<FerryStop> stops;   // the stop frames, in path order
    };

    std::vector<FerryTransport> const& FerryTransports()
    {
        static std::vector<FerryTransport> list;
        static bool loaded = false;
        if (loaded)
            return list;
        loaded = true;   // map threads: the first caller fills it under the BotLife tick; a race only repeats an idempotent read
        if (QueryResult result = WorldDatabase.Query("SELECT guid, entry FROM transports"))
        {
            do
            {
                uint32 const guid = (*result)[0].GetUInt32();
                uint32 const entry = (*result)[1].GetUInt32();
                TransportTemplate const* tpl = sTransportMgr->GetTransportTemplate(entry);
                if (!tpl || tpl->inInstance || tpl->mapsUsed.size() < 2 || !tpl->phases.empty())
                    continue;
                FerryTransport ft;
                ft.guid = guid;
                ft.entry = entry;
                for (KeyFrame const& frame : tpl->keyFrames)
                    if (frame.IsStopFrame())
                        ft.stops.push_back({ frame.Node->MapId, frame.Node->LocX, frame.Node->LocY, frame.Node->LocZ });
                if (ft.stops.size() >= 2)
                    list.push_back(std::move(ft));
            } while (result->NextRow());
        }
        return list;
    }

    float Dist2(float x1, float y1, float x2, float y2)
    {
        return std::sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
    }
}

Transport* BotLifeMgr::FerryFind(Player* bot, uint32 guid)
{
    return bot->GetMap()->GetTransport(ObjectGuid::Create<HighGuid::Mo_Transport>(guid));
}

bool BotLifeMgr::FerryPlan(Player* bot, BotLifeInfo& t, uint32 destMap, float x, float y, float z, uint32 now, bool forced)
{
    if (!_ferry || t.ferryPhase)
        return false;
    if (!bot->IsAlive() || bot->IsInCombat() || bot->IsInFlight() || bot->IsBeingTeleported() || bot->GetGroup() || bot->GetVehicle()
        || bot->GetTransport() || bot->InBattleground() || bot->InBattlegroundQueue() || bot->GetMap()->Instanceable()
        || !bot->m_taxi.empty() || IsWalker(bot) || t.banker || destMap == bot->GetMapId())
        return false;
    PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
    if (!botAI || botAI->HasRealPlayerMaster())
        return false;
    if (!forced && (now < t.ferryNextAllowed || urand(0, 99) >= _ferryChance))
        return false;

    FerryTransport const* best = nullptr;
    FerryStop const* bestDock = nullptr;
    float bestDist = _ferryDockRange;
    for (FerryTransport const& ft : FerryTransports())
    {
        bool reachesDest = false;
        for (FerryStop const& s : ft.stops)
            if (s.map == destMap)
                reachesDest = true;
        if (!reachesDest)
            continue;
        for (FerryStop const& s : ft.stops)
        {
            if (s.map != bot->GetMapId())
                continue;
            float const d = Dist2(bot->GetPositionX(), bot->GetPositionY(), s.x, s.y);
            if (d < bestDist)
            {
                bestDist = d;
                best = &ft;
                bestDock = &s;
            }
        }
    }
    if (!best)
        return false;

    t.ferryPhase = 1;
    t.ferryGuid = best->guid;
    t.ferrySince = now;
    t.ferryDockMap = bestDock->map;
    t.ferryDockX = bestDock->x;
    t.ferryDockY = bestDock->y;
    t.ferryDockZ = bestDock->z;
    t.ferryDestMap = destMap;
    t.ferryDestX = x;
    t.ferryDestY = y;
    t.ferryDestZ = z;
    SetDest(t, bot->GetMapId(), bestDock->x, bestDock->y, bestDock->z, 6.0f);
    TC_LOG_INFO("playerbots", "BotLife ferry: {} ({}) walks {:.0f} yd to the dock of transport {} on map {} for a trip to map {}", bot->GetName(),
        uint32(bot->GetLevel()), bestDist, best->entry, bot->GetMapId(), destMap);
    return true;
}

void BotLifeMgr::FerryFinish(Player* bot, BotLifeInfo& t, uint32 now, char const* why, bool failed)
{
    if (failed)
    {
        t.ferryNextAllowed = now + _ferryRetryAfterFail * MINUTE * IN_MILLISECONDS;
        TC_LOG_INFO("playerbots", "BotLife ferry: {} gives up in phase {} ({}), teleport instead", bot->GetName(), uint32(t.ferryPhase), why);
    }
    uint32 const map = t.ferryDestMap;
    float const x = t.ferryDestX, y = t.ferryDestY, z = t.ferryDestZ;
    t.ferryPhase = 0;
    t.hasDest = false;
    if (!bot->IsBeingTeleported())
        bot->TeleportTo(map, x, y, z + 0.5f, frand(0.0f, 2 * float(M_PI)));   // the relocation the bot would have got anyway
}

bool BotLifeMgr::FerryTick(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (!t.ferryPhase)
        return false;
    if (!bot->IsAlive() || bot->IsInCombat() || bot->GetGroup() || bot->IsBeingTeleported())
    {
        if (bot->IsBeingTeleported())
            return true;
        FerryFinish(bot, t, now, bot->IsAlive() ? "combat or group" : "dead", true);
        return true;
    }

    uint32 const elapsed = now - t.ferrySince;
    switch (t.ferryPhase)
    {
        case 1:   // walk to the dock
        {
            if (bot->GetMapId() != t.ferryDockMap)
            {
                FerryFinish(bot, t, now, "map changed", true);
                return true;
            }
            if (Dist2(bot->GetPositionX(), bot->GetPositionY(), t.ferryDockX, t.ferryDockY) < 10.0f)
            {
                t.ferryPhase = 2;
                t.ferrySince = now;
                t.hasDest = false;
                return true;
            }
            if (elapsed > 3 * MINUTE * IN_MILLISECONDS)
                FerryFinish(bot, t, now, "walk too slow", true);
            return false;   // the usual travel logic walks to the dock (SetDest)
        }
        case 2:   // wait for the transport at the dock
        {
            Transport* tr = FerryFind(bot, t.ferryGuid);
            if (!tr)
            {
                FerryFinish(bot, t, now, "transport not on this map", true);
                return true;
            }
            if (Dist2(tr->GetPositionX(), tr->GetPositionY(), t.ferryDockX, t.ferryDockY) < 20.0f && std::fabs(tr->GetPositionZ() - t.ferryDockZ) < 25.0f)
            {
                float px = bot->GetPositionX(), py = bot->GetPositionY(), pz = bot->GetPositionZ(), po = bot->GetOrientation();
                tr->CalculatePassengerOffset(px, py, pz, &po);
                if (std::fabs(px) > 70.0f || std::fabs(py) > 70.0f || std::fabs(pz) > 30.0f)   // the dock is not next to the deck
                {
                    FerryFinish(bot, t, now, "deck out of reach", true);
                    return true;
                }
                bot->m_movementInfo.transport.guid = tr->GetGUID();
                bot->m_movementInfo.transport.pos.Relocate(px, py, pz, po);
                bot->m_movementInfo.transport.seat = -1;
                tr->AddPassenger(bot);
                bot->StopMoving();
                t.ferryPhase = 3;
                t.ferrySince = now;
                TC_LOG_INFO("playerbots", "BotLife ferry: {} boards transport {}", bot->GetName(), tr->GetEntry());
                return true;
            }
            if (elapsed > _ferryDockWait * MINUTE * IN_MILLISECONDS)
                FerryFinish(bot, t, now, "transport did not come", true);
            return true;   // stand and wait: no other order moves the bot
        }
        case 3:   // ride
        {
            if (!bot->GetTransport())
            {
                FerryFinish(bot, t, now, "left the transport", true);
                return true;
            }
            if (bot->GetMapId() == t.ferryDestMap && elapsed > 30 * IN_MILLISECONDS)
            {
                // arrived on the destination map: the transport stands at a stop there (or any moment will do after the minimum ride)
                Transport* tr = bot->GetTransport();
                bool atStop = false;
                for (FerryTransport const& ft : FerryTransports())
                    if (ft.guid == t.ferryGuid)
                        for (FerryStop const& s : ft.stops)
                            if (s.map == t.ferryDestMap && Dist2(tr->GetPositionX(), tr->GetPositionY(), s.x, s.y) < 25.0f)
                                atStop = true;
                if (atStop)
                {
                    TC_LOG_INFO("playerbots", "BotLife ferry: {} arrived on map {}", bot->GetName(), t.ferryDestMap);
                    FerryFinish(bot, t, now, "arrived", false);
                    return true;
                }
            }
            if (elapsed > _ferryRide * MINUTE * IN_MILLISECONDS)
                FerryFinish(bot, t, now, "ride too long", true);
            return true;
        }
        default:
            break;
    }
    t.ferryPhase = 0;
    return false;
}

std::string BotLifeMgr::FerryTest(std::string const& name, uint32 destMap)
{
    Player* bot = ObjectAccessor::FindPlayerByName(name);
    if (!bot || !bot->IsInWorld())
        return "ferry: " + name + " is not online";
    PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
    if (!botAI || !sRandomPlayerbotMgr->IsRandomBot(bot))
        return "ferry: " + name + " is not a random bot";
    if (!_ferry)
        return "ferry: BotLife.Ferry is off";
    BotLifeInfo& t = botAI->life;
    if (t.ferryPhase)
        return "ferry: " + name + " is already on a trip (phase " + std::to_string(t.ferryPhase) + ")";
    if (!FerryPlan(bot, t, destMap, bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), getMSTime(), true))
        return "ferry: no transport within BotLife.FerryDockRange of " + name + " that also stops on map " + std::to_string(destMap) + ", or the bot cannot travel now";
    return "ferry: " + name + " walks to the dock of transport " + std::to_string(t.ferryGuid) + "; '.botlife ferry status' shows the trips";
}

std::string BotLifeMgr::FerryStatus()
{
    std::ostringstream out;
    out << "ferry: " << (_ferry ? "on" : "off") << ", chance " << _ferryChance << "%, " << FerryTransports().size() << " transports with stops on 2+ maps";
    return out.str();
}
