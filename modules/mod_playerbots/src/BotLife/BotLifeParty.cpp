/*
 * Bot life: parties of random bots. A party has a bot leader that keeps living its bot life
 * (travel, quests, grinding); the members follow and assist the leader, loot, rest and share
 * the leader's quests. Parties are formed and disbanded on the world thread (map threads idle).
 */

#include "BotLife.h"

#include "Creature.h"
#include "DatabaseEnv.h"
#include "Group.h"
#include "GroupMgr.h"
#include "Log.h"
#include "LootMgr.h"
#include "Map.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "Playerbots.h"
#include "QuestDef.h"
#include "Random.h"
#include "RandomPlayerbotMgr.h"
#include "Timer.h"

#include <algorithm>
#include <map>
#include <sstream>
#include <random>
#include <tuple>
#include <unordered_map>
#include <sstream>
#include <mutex>
#include "PlayerbotSpec.h"
#include "Map.h"
#include "Action.h"
#include "AiObjectContext.h"

namespace
{
    constexpr float PARTY_GATHER_DIST = 45.0f;       // leader waits when a member is further away
    constexpr float PARTY_FAR_DIST = 200.0f;         // member is summoned after being this far for a while
    constexpr uint32 PARTY_FAR_SUMMON_MS = 90000;
    constexpr uint32 PARTY_MAX_WAIT_MS = 25000;
    constexpr uint32 PARTY_MAX_NEW_PER_TICK = 6;

    std::mt19937& PartyRng()
    {
        static std::mt19937 rng(std::random_device{}());   // world thread only
        return rng;
    }

    bool IsSoloCandidate(Player* bot)
    {
        if (!bot || !bot->IsInWorld() || !bot->GetSession() || bot->GetGroup())
            return false;
        if (!bot->IsAlive() || bot->IsInCombat() || bot->IsBeingTeleported() || bot->IsInFlight() || bot->InBattleground()
            || bot->GetVehicle() || bot->GetLevel() < 10)
            return false;
        Map* map = bot->GetMap();
        if (!map || map->Instanceable())
            return false;
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI || botAI->IsRealPlayer() || botAI->HasRealPlayerMaster() || botAI->life.party)
            return false;
        return sRandomPlayerbotMgr->IsRandomBot(bot);
    }

    void ResetPartyState(Player* bot)
    {
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI)
            return;
        BotLifeInfo& t = botAI->life;
        t.party = BOTLIFE_PARTY_NONE;
        t.partyWaitSince = 0;
        t.state = BotLifeState::IDLE;
        t.hasDest = false;
        t.path.clear();
        t.pathIdx = 0;
        t.questId = 0;
        t.npcEntry = 0;
        t.nextThink = 0;
        t.dungeonTarget = 0;
        t.dungeonTargetSince = 0;
        t.dungeonEngageSince = 0;
        t.dungeonSkip.clear();
        t.dungeonDone = false;
        t.dungeonKills = 0;
        t.dungeonBosses = 0;
        t.ResetDungeonExtras();
    }

    // back to a solo random bot
    void ReleaseBot(Player* bot)
    {
        ResetPartyState(bot);
        if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot))
        {
            botAI->SetMaster(nullptr);
            botAI->ResetStrategies();
        }
    }
}

// ---------------------------------------------------------------------------------------------
// world thread

void BotLifeMgr::PartyUpdate(uint32 now)
{
    // 1. maintain the existing parties
    uint32 members = 0;
    for (auto it = _parties.begin(); it != _parties.end();)
    {
        BotLifeParty& party = it->second;
        Group* group = sGroupMgr->GetGroupByGUID(it->first);
        if (!group)
        {
            for (ObjectGuid const& guid : party.members)
                if (Player* member = ObjectAccessor::FindConnectedPlayer(guid))
                    if (!member->GetGroup())
                        ReleaseBot(member);
            it = _parties.erase(it);
            continue;
        }

        // a real player joined: the party is theirs now, bot life lets go
        bool realPlayer = false;
        for (Group::MemberSlot const& slot : group->GetMemberSlots())
        {
            Player* member = ObjectAccessor::FindConnectedPlayer(slot.guid);
            PlayerbotAI* memberAI = member ? GET_PLAYERBOT_AI(member) : nullptr;
            if (member && (!memberAI || memberAI->IsRealPlayer()))
                realPlayer = true;
        }
        if (realPlayer)
        {
            for (ObjectGuid const& guid : party.members)
                if (Player* member = ObjectAccessor::FindConnectedPlayer(guid))
                    if (PlayerbotAI* memberAI = GET_PLAYERBOT_AI(member))
                        memberAI->life.party = BOTLIFE_PARTY_NONE;
            it = _parties.erase(it);
            continue;
        }

        Player* leader = ObjectAccessor::FindConnectedPlayer(group->GetLeaderGUID());
        bool disband = !leader || !leader->IsInWorld() || group->GetMembersCount() < 2 || leader->GetGUID() != party.leader;
        if (!disband && party.type != BOTLIFE_PARTY_WORLD)
        {
            // dungeon / raid: resurrect, regroup, wipes, cleared or out of time
            if (!party.until || MaintainInstanceParty(group, party, leader, now))
                disband = true;
            else
            {
                members += group->GetMembersCount();
                ++it;
                continue;
            }
        }
        if (!disband && now >= party.until && !leader->IsInCombat())
            disband = true;

        if (!disband)
        {
            // stragglers (different map or far away for a while) are brought back to the leader
            for (Group::MemberSlot const& slot : group->GetMemberSlots())
            {
                if (slot.guid == party.leader)
                    continue;
                Player* member = ObjectAccessor::FindConnectedPlayer(slot.guid);
                if (!member || !member->IsInWorld())
                    continue;
                bool far = member->FindMap() != leader->FindMap() || member->GetExactDist(leader) > PARTY_FAR_DIST;
                if (!far || !member->IsAlive() || member->IsInCombat() || leader->IsInCombat() || member->IsBeingTeleported()
                    || leader->IsBeingTeleported() || leader->IsInFlight() || !leader->IsAlive())
                {
                    party.farSince.erase(slot.guid);
                    continue;
                }
                auto far_it = party.farSince.find(slot.guid);
                if (far_it == party.farSince.end())
                    party.farSince[slot.guid] = now;
                else if (now - far_it->second > PARTY_FAR_SUMMON_MS)
                {
                    party.farSince.erase(far_it);
                    QueueTeleport(member, leader->GetMapId(), leader->GetPositionX() + frand(-3.0f, 3.0f),
                        leader->GetPositionY() + frand(-3.0f, 3.0f), leader->GetPositionZ() + 0.5f, leader->GetOrientation());
                    Count(BLC_PARTY_SUMMON);
                }
            }
            members += group->GetMembersCount();
            ++it;
            continue;
        }

        DisbandParty(it->first, party);
        it = _parties.erase(it);
    }

    if (now < _nextPartyForm)
        return;
    _nextPartyForm = now + 20000;

    DisbandOrphanGroups();

    // 2. dungeon and raid groups
    if (_dungeonsEnabled && _dungeonParties)
        FormInstanceParties(now, false);
    if (_raidsEnabled && _raidParties)
        FormInstanceParties(now, true);

    // 3. new world parties up to the wanted share of the random bots
    if (!_partiesEnabled)
        return;
    uint32 total = uint32(sRandomPlayerbotMgr->GetAllBots().size());
    uint32 target = total * _partyShare / 100;
    if (members + 1 < target)
        FormWorldParties(now, target - members);
}

void BotLifeMgr::DisbandOrphanGroups()
{
    std::unordered_set<uint32> seen;
    std::vector<Group*> orphans;
    for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
    {
        Player* bot = pair.second;
        Group* group = bot ? bot->GetGroup() : nullptr;
        if (!group || !seen.insert(group->GetLowGUID()).second || _parties.count(group->GetLowGUID()))
            continue;
        if (group->isBGGroup() || group->isBFGroup() || group->isLFGGroup())
            continue;
        bool real = false;
        for (Group::MemberSlot const& slot : group->GetMemberSlots())
        {
            Player* member = ObjectAccessor::FindConnectedPlayer(slot.guid);
            PlayerbotAI* memberAI = member ? GET_PLAYERBOT_AI(member) : nullptr;
            // offline members: only random bots are allowed to be dropped (a real player's group stays)
            if (!member)
            {
                if (!sRandomPlayerbotMgr->IsRandomBot(slot.guid.GetCounter()))
                    real = true;
                continue;
            }
            if (!memberAI || memberAI->IsRealPlayer() || !sRandomPlayerbotMgr->IsRandomBot(member))
                real = true;
        }
        if (!real)
            orphans.push_back(group);
    }

    for (Group* group : orphans)
    {
        std::vector<ObjectGuid> guids;
        for (Group::MemberSlot const& slot : group->GetMemberSlots())
            guids.push_back(slot.guid);
        group->Disband(true);
        for (ObjectGuid const& guid : guids)
            if (Player* member = ObjectAccessor::FindConnectedPlayer(guid))
                if (!member->GetGroup())
                    ReleaseBot(member);
        Count(BLC_ORPHAN_GROUP);
    }
}

void BotLifeMgr::RecordDungeonRun(BotLifeDungeon const& d, BotLifeParty const& party, Player* leader, char const* result, uint32 now)
{
    PlayerbotAI* leaderAI = leader ? GET_PLAYERBOT_AI(leader) : nullptr;
    uint32 bossesKilled = leaderAI ? leaderAI->life.dungeonBosses : 0;
    if (!strcmp(result, "already-done"))
    {
        // (finished-instance) neither a failed run nor a success
    }
    else if (!bossesKilled && strcmp(result, "cleared"))
        ++_dungeonRecord[d.id].first;
    else
        ++_dungeonRecord[d.id].second;
    std::string name = d.name;
    PlayerbotsDatabase.EscapeString(name);
    PlayerbotsDatabase.PExecute("INSERT INTO tt_botlife_dungeon_runs (ts, dungeon, name, raid, leader_level, result, kills, bosses, bosses_total, wipes, minutes) "
        "VALUES (UNIX_TIMESTAMP(), {}, '{}', {}, {}, '{}', {}, {}, {}, {}, {})", d.id, name, d.raid ? 1 : 0, leader ? uint32(leader->GetLevel()) : 0,
        result, leaderAI ? leaderAI->life.dungeonKills : 0, leaderAI ? leaderAI->life.dungeonBosses : 0, d.bosses, party.wipes,
        (now - party.formedAt) / MINUTE / IN_MILLISECONDS);
    LogRunEnd(d, party, leader, result);
}

bool BotLifeDungeonHandInPending(Player* leader);   // , BotLifeDungeon.cpp
bool BotLifeFinalBossDown(Player* leader, uint32 dungeonId);   // , BotLifeDungeon.cpp
bool BotLifeHasFinalBoss(uint32 dungeonId);   // (final-clear) BotLifeDungeon.cpp

bool BotLifeMgr::MaintainInstanceParty(Group* group, BotLifeParty& party, Player* leader, uint32 now)
{
    if (party.dungeon < 0 || uint32(party.dungeon) >= _dungeons.size())
        return true;
    BotLifeDungeon const& d = _dungeons[party.dungeon];
    PlayerbotAI* leaderAI = GET_PLAYERBOT_AI(leader);
    // the last encounter of this dungeon finder entry is down - that is the clear (maps with several
    // wings counted the other wings' bosses too); the dungeon's quests are handed in first (up to three minutes)
    bool const finalDown = leaderAI && leader->GetMapId() == d.map && BotLifeFinalBossDown(leader, d.id);
    if (finalDown && !leaderAI->life.dungeonDone && !leader->IsInCombat())
    {
        static std::unordered_map<uint32, uint32> s_finalSince;
        uint32& since = s_finalSince[group->GetLowGUID()];
        if (!since)
            since = now;
        if (!BotLifeDungeonHandInPending(leader) || now - since >= 3 * MINUTE * IN_MILLISECONDS)
        {
            s_finalSince.erase(group->GetLowGUID());
            leaderAI->life.dungeonDone = true;
        }
    }
    if (leaderAI && leaderAI->life.dungeonDone)
    {
        // (finished-instance) the last boss was already dead when the party came in and it killed nothing: not a clear
        if (finalDown && !leaderAI->life.dungeonKills && !leaderAI->life.dungeonBosses)
        {
            RecordDungeonRun(d, party, leader, "already-done", now);
            TC_LOG_INFO("playerbots", "BotLife: {} entered a finished {} (last boss already dead, nothing killed)", leader->GetName(), d.name);
            return true;
        }
        Count(BLC_DUNGEON_CLEARED);
        // nothing left to fight but bosses still standing is not a clear
        // (final-clear) with a known last encounter only its death is a clear; otherwise all bosses of the entry
        bool const incomplete = finalDown ? false : BotLifeHasFinalBoss(d.id) || (d.bosses && leaderAI->life.dungeonBosses < d.bosses);
        RecordDungeonRun(d, party, leader, incomplete ? "incomplete" : "cleared", now);
        TC_LOG_INFO("playerbots", "BotLife: {} {} {} ({} kills, {} bosses of {}, {} wipes, {} min)", leader->GetName(),
            incomplete ? "ends without the last boss:" : "cleared", d.name,
            leaderAI->life.dungeonKills, leaderAI->life.dungeonBosses, d.bosses, party.wipes, (now - party.formedAt) / MINUTE / IN_MILLISECONDS);
        return true;
    }
    if (now >= party.until)
    {
        Count(BLC_DUNGEON_TIMEOUT);
        RecordDungeonRun(d, party, leader, "timeout", now);
        TC_LOG_INFO("playerbots", "BotLife: {} ran out of time in {} ({} kills, {} bosses of {}, {} wipes)", leader->GetName(), d.name,
            leaderAI ? leaderAI->life.dungeonKills : 0, leaderAI ? leaderAI->life.dungeonBosses : 0, d.bosses, party.wipes);
        return true;
    }

    // (kill-first-adds) an add the party has to kill during a boss fight, as a real group does: the leader puts the skull on
    // the nearest one and the damage dealers switch to it (their dps target takes the skull first). Echo of Sylvanas (End
    // Time): one Risen Ghoul of Calling of the Highborne has to die before the ring reaches her.
    if (leaderAI && leader->GetMapId() == d.map && leader->IsAlive() && leader->IsInCombat())
    {
        static std::pair<uint32, uint32> const killFirst[] = { { 54123, 54191 } };   // boss, add
        for (auto const& kf : killFirst)
        {
            Creature* boss = leader->FindNearestCreature(kf.first, 100.0f, true);
            if (!boss || !boss->IsInCombat())
                continue;
            ObjectGuid const marked = group->GetTargetIcon(7);
            Creature* current = marked ? ObjectAccessor::GetCreature(*leader, marked) : nullptr;
            if (current && current->IsAlive() && current->GetEntry() == kf.second)
                break;
            if (Creature* add = leader->FindNearestCreature(kf.second, 60.0f, true))
            {
                group->SetTargetIcon(7, leader->GetGUID(), add->GetGUID(), 0);
                TC_LOG_INFO("playerbots", "BotLife: {} marks {} ({}) with the skull in {} ({} in combat)", leader->GetName(),
                    add->GetName(), add->GetEntry(), d.name, boss->GetName());
            }
            break;
        }
    }

    // once a minute where the run stands: the stall detail only exists at the end of the run
    {
        static thread_local std::unordered_map<uint32, uint32> s_beat;
        uint32& lastBeat = s_beat[group->GetLowGUID()];
        if (leaderAI && leader->GetMapId() == d.map && now - lastBeat >= 60000)
        {
            lastBeat = now;
            BotLifeInfo const& lt = leaderAI->life;
            std::ostringstream members;
            for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                if (Player* m = ref->GetSource())
                    members << ' ' << m->GetName() << (m->IsAlive() ? ':' : '!') << (m->IsInCombat() ? 'c' : '-')
                        << int(m->GetExactDist(leader)) << "yd/" << int(m->GetHealthPct()) << "%/"
                        << (m->GetMaxPower(POWER_MANA) ? int(100 * m->GetPower(POWER_MANA) / m->GetMaxPower(POWER_MANA)) : -1);
            TC_LOG_INFO("playerbots", "DUNGEONBEAT {}: leader {} at {:.0f} {:.0f} {:.0f}, state {}, moving {}, target spawn {} hasDest {} dist {:.0f}, engage {} s, partywait {} s, "
                "kills {}, no kill for {} s, victim {}, combat {} |{}",
                d.name, leader->GetName(), leader->GetPositionX(), leader->GetPositionY(), leader->GetPositionZ(), uint32(lt.state),
                leader->isMoving() ? 1 : 0, lt.dungeonTarget, lt.hasDest ? 1 : 0,
                lt.hasDest ? leader->GetExactDist(lt.destX, lt.destY, lt.destZ) : -1.0f,
                lt.dungeonEngageSince ? (now - lt.dungeonEngageSince) / IN_MILLISECONDS : 0,
                lt.partyWaitSince ? (now - lt.partyWaitSince) / IN_MILLISECONDS : 0, lt.dungeonKills,
                party.lastKillTime ? (now - party.lastKillTime) / IN_MILLISECONDS : 0,
                leader->GetVictim() ? leader->GetVictim()->GetName() : std::string("-"), leader->IsInCombat() ? 1 : 0, members.str());
        }
    }

    // stalled: no kill for a long time (closed doors, scripted events the bots cannot start)
    uint32 kills = leaderAI ? leaderAI->life.dungeonKills : 0;
    if (kills != party.lastKills || !party.lastKillTime)
    {
        party.lastKills = kills;
        party.lastKillTime = now;
    }
    // with every boss down the run is a clear, and three quiet minutes are enough (Shadowfang Keep: 5 of
    // 5 bosses after 7 minutes, then 8 more looking at trash nobody could reach, and booked as "stalled" 13 times of 14)
    else if (now - party.lastKillTime > ((leaderAI && d.bosses && leaderAI->life.dungeonBosses >= d.bosses) ? 3u : 8u) * MINUTE * IN_MILLISECONDS
        && !leader->IsInCombat())
    {
        bool const allBossesDown = leaderAI && d.bosses && leaderAI->life.dungeonBosses >= d.bosses;
        // the quests of the dungeon are handed in first - up to three more minutes (world thread)
        {
            static std::unordered_map<uint32, uint32> s_handInSince;
            if (allBossesDown && leader->GetMapId() == d.map && BotLifeDungeonHandInPending(leader))
            {
                uint32& since = s_handInSince[group->GetLowGUID()];
                if (!since)
                    since = now;
                if (now - since < 3 * MINUTE * IN_MILLISECONDS)
                    return false;
            }
            s_handInSince.erase(group->GetLowGUID());
        }
        Count(allBossesDown ? BLC_DUNGEON_CLEARED : BLC_DUNGEON_STALLED);
        RecordDungeonRun(d, party, leader, allBossesDown ? "cleared" : "stalled", now);
        TC_LOG_INFO("playerbots", "BotLife: {} stalled in {} ({} kills, {} bosses of {}, {} wipes, {} min)", leader->GetName(), d.name,
            kills, leaderAI ? leaderAI->life.dungeonBosses : 0, d.bosses, party.wipes, (now - party.formedAt) / MINUTE / IN_MILLISECONDS);
        if (leaderAI)
        {
            BotLifeInfo const& lt = leaderAI->life;
            TC_LOG_INFO("playerbots", "BotLife: stall detail {}: pos {} {} {}, target spawn {}, hasDest {} dest {} {} {} dist {}, waitSince {}, skipped {}, combat {}",
                leader->GetName(), leader->GetPositionX(), leader->GetPositionY(), leader->GetPositionZ(), lt.dungeonTarget, lt.hasDest,
                lt.destX, lt.destY, lt.destZ, lt.hasDest ? leader->GetExactDist(lt.destX, lt.destY, lt.destZ) : -1.0f,
                lt.partyWaitSince ? (now - lt.partyWaitSince) / IN_MILLISECONDS : 0, uint32(lt.dungeonSkip.size()), leader->IsInCombat());
        }
        if (!kills)
            MarkBadDungeon(d, "stalled");
        return true;
    }

    // bosses left that the bots cannot start (scripted events, e.g. Vazruden in Hellfire Ramparts, the Sunken
    // Temple statues) kept a party killing trash until the 50 min timeout. With a boss down and no boss for 15 min
    // (raids 25) the run ends as "partial" - it still counts as a run with a boss, so the dungeon stays in rotation.
    uint32 bosses = leaderAI ? leaderAI->life.dungeonBosses : 0;
    if (bosses != party.lastBosses || !party.lastBossTime)
    {
        party.lastBosses = bosses;
        party.lastBossTime = now;
    }
    // a party that still kills is on its way to the next boss: it gets ten minutes more
    // (party.lastKillTime is kept by the stall check above)
    uint32 const sinceBoss = now - party.lastBossTime;
    bool const idle = now - party.lastKillTime > 3u * MINUTE * IN_MILLISECONDS;
    if (bosses && !leader->IsInCombat() && bosses == party.lastBosses
        && ((idle && sinceBoss > (d.raid ? 25u : 15u) * MINUTE * IN_MILLISECONDS)
            || sinceBoss > (d.raid ? 35u : 25u) * MINUTE * IN_MILLISECONDS))
    {
        Count(BLC_DUNGEON_STALLED);
        RecordDungeonRun(d, party, leader, "partial", now);
        TC_LOG_INFO("playerbots", "BotLife: {} ends {} partially ({} kills, {} bosses of {}, {} wipes, {} min)", leader->GetName(), d.name,
            kills, bosses, d.bosses, party.wipes, (now - party.formedAt) / MINUTE / IN_MILLISECONDS);
        return true;
    }

    // a run with no boss down at all after 18 minutes is unwinnable for the bots (an untriggered scripted
    // event or an unreachable first boss). The 8-minute stall check misses it when the party keeps killing trash/adds (its
    // kill count keeps rising) or stays in perpetual combat, so it otherwise runs to the 50-minute hard timeout with a full
    // party stuck. End it early, free the party, and take the dungeon out of rotation until the encounter is fixed.
    // 
    // (end-time-30-min) End Time too: its echoes stand far apart, Jaina comes after sixteen staff fragments
    if (!bosses && now - party.formedAt > (HasKillGate(d.map) || d.map == 938 ? 30u : 18u) * MINUTE * IN_MILLISECONDS)
    {
        Count(BLC_DUNGEON_STALLED);
        RecordDungeonRun(d, party, leader, "stalled", now);
        TC_LOG_INFO("playerbots", "BotLife: {} stuck with no boss in {} ({} kills, 0 bosses of {}, {} min) - ending early",
            leader->GetName(), d.name, kills, d.bosses, (now - party.formedAt) / MINUTE / IN_MILLISECONDS);
        MarkBadDungeon(d, "no boss in 18 min");
        return true;
    }

    std::vector<Player*> players;
    for (Group::MemberSlot const& slot : group->GetMemberSlots())
        if (Player* p = ObjectAccessor::FindConnectedPlayer(slot.guid))
            if (p->IsInWorld())
                players.push_back(p);

    // diagnostics: the minute after a wipe, every member every 3 seconds (world thread only)
    static std::unordered_map<ObjectGuid::LowType, std::pair<uint32, uint32>> s_wipeDiag;   // leader -> (until, next log)
    auto diagIt = s_wipeDiag.find(leader->GetGUID().GetCounter());
    if (diagIt != s_wipeDiag.end())
    {
        if (now > diagIt->second.first)
            s_wipeDiag.erase(diagIt);
        else if (now >= diagIt->second.second)
        {
            diagIt->second.second = now + 3000;
            for (Player* p : players)
            {
                PlayerbotAI* pAI = GET_PLAYERBOT_AI(p);
                TC_LOG_INFO("playerbots", "BotLife: after-wipe {}: map {} at {:.0f} {:.0f} {:.0f}, alive {}, ghost {}, health {}/{}, teleporting {}, queued {}",
                    p->GetName(), p->GetMapId(), p->GetPositionX(), p->GetPositionY(), p->GetPositionZ(), p->IsAlive() ? 1 : 0,
                    p->HasAuraType(SPELL_AURA_GHOST) ? 1 : 0, p->GetHealth(), p->GetMaxHealth(), p->IsBeingTeleported() ? 1 : 0,
                    pAI && pAI->life.teleQueued ? 1 : 0);
            }
        }
    }

    // the one everybody gathers at: the leader when alive inside, otherwise another living member inside
    Player* anchor = nullptr;
    bool combat = false;
    bool teleporting = false;
    for (Player* p : players)
    {
        if (p->IsBeingTeleported())
        {
            teleporting = true;
            continue;
        }
        if (p->IsAlive() && p->GetMapId() == d.map && (!anchor || p == leader))
            anchor = p;
        if (p->IsInCombat())
            combat = true;
    }
    if (teleporting)
        return false;

    // in combat for minutes while the rest is dead or outside (unreachable attacker, evading boss): start over
    bool someoneMissing = false;
    for (Player* p : players)
        if (!p->IsAlive() || p->GetMapId() != d.map)
            someoneMissing = true;
    // only an attackable attacker counts (not Summon Enabler Stalker and other triggers)
    auto HasFightableAttackerP = [](Player* member)
    {
        for (Unit* a : member->getAttackers())
            if (a && a->IsAlive() && !a->HasUnitFlag(UNIT_FLAG_NON_ATTACKABLE) && !a->HasUnitFlag(UNIT_FLAG_NOT_SELECTABLE)
                && !a->HasUnitFlag(UNIT_FLAG_IMMUNE_TO_PC)
                && !(a->ToCreature() && (a->ToCreature()->GetCreatureTemplate()->flags_extra & CREATURE_FLAG_EXTRA_TRIGGER)))
                return true;
        return false;
    };
    // everybody alive and inside, in combat for a minute with no victim and no attacker
    // (a lingering combat state after a wipe recovery): say what holds them and clear it
    if (anchor && combat && !someoneMissing)
    {
        bool phantom = true;
        for (Player* p : players)
            if (p->GetVictim() || HasFightableAttackerP(p) || (p->GetPet() && p->GetPet()->GetVictim()))   // (attackerfilter)
                phantom = false;
        static std::unordered_map<ObjectGuid::LowType, uint32> s_phantomSince;   // leader -> since
        uint32& since = s_phantomSince[leader->GetGUID().GetCounter()];
        if (!phantom)
            since = 0;
        else if (!since)
            since = now;
        else if (now - since > 60000)
        {
            since = 0;
            for (Player* p : players)
            {
                TC_LOG_INFO("playerbots", "BotLife: phantom combat {} in {}: victim {}, attackers {}, pet {}, in combat {} - clearing",
                    p->GetName(), d.name, p->GetVictim() ? p->GetVictim()->GetName() : "-", uint32(p->getAttackers().size()),
                    p->GetPet() ? (p->GetPet()->IsInCombat() ? "in combat" : "idle") : "none", p->IsInCombat() ? 1 : 0);
                QueueCombatStop(p);
            }
        }
    }
    if (anchor && combat && someoneMissing)
    {
        // somebody is dead or outside and nobody inside fights any more (no victim, no attacker that can be
        // fought): the combat state lingers. Clear it after 20 s so the dead get up at the anchor - no restart at the entrance and
        // no wipe counted (a dead leader released outside left the rest standing for two minutes)
        bool lingering = true;
        for (Player* p : players)
            if (p->IsAlive() && p->GetMapId() == d.map && (p->GetVictim() || HasFightableAttackerP(p) || (p->GetPet() && p->GetPet()->GetVictim())))
                lingering = false;
        static std::unordered_map<ObjectGuid::LowType, uint32> s_lingerSince;   // leader -> since
        uint32& lingerSince = s_lingerSince[leader->GetGUID().GetCounter()];
        if (!lingering)
            lingerSince = 0;
        else if (!lingerSince)
            lingerSince = now;
        else if (now - lingerSince > 20000)
        {
            lingerSince = 0;
            uint32 cleared = 0;
            for (Player* p : players)
                if (p->IsAlive() && p->IsInCombat())
                {
                    QueueCombatStop(p);
                    ++cleared;
                }
            party.stuckCombatSince = 0;
            TC_LOG_INFO("playerbots", "BotLife: lingering combat in {} with members down (leader {}): cleared for {} - the dead get up, no wipe",
                d.name, leader->GetName(), cleared);
            return false;
        }
        if (!party.stuckCombatSince)
            party.stuckCombatSince = now;
        else if (now - party.stuckCombatSince > 120000)
        {
            party.stuckCombatSince = 0;
            for (Player* p : players)
                QueueCombatStop(p);   // CombatStop(true) interrupts casts; run on the bot own thread
            anchor = nullptr;
            party.allDeadSince = now - 15000;
        }
    }
    else
        party.stuckCombatSince = 0;

    if (!anchor)
    {
        // everybody dead (or outside): wipe, everybody back to the entrance
        if (!party.allDeadSince)
        {
            party.allDeadSince = now;
            return false;
        }
        if (now - party.allDeadSince < 15000)
            return false;
        party.allDeadSince = 0;
        // a "wipe" with nobody inside is an entrance that refuses the party, not a fight that was lost
        {
            uint32 inside = 0, alive = 0;
            for (Player* p : players)
            {
                if (p->GetMapId() == d.map)
                    ++inside;
                if (p->IsAlive())
                    ++alive;
            }
            TC_LOG_INFO("playerbots", "BotLife: wipe {} in {}: {} of {} inside, {} alive, leader {} on map {} at {:.0f} {:.0f} {:.0f}, {} kills",
                party.wipes + 1, d.name, inside, uint32(players.size()), alive, leader->GetName(), leader->GetMapId(),
                leader->GetPositionX(), leader->GetPositionY(), leader->GetPositionZ(), kills);
            // every member - where the way back after a wipe fails
            for (Player* p : players)
                TC_LOG_INFO("playerbots", "BotLife:   {} {} map {} at {:.0f} {:.0f} {:.0f}, health {}/{}, ghost {}, death state {}, in combat {}",
                    p->GetName(), p->IsAlive() ? "alive" : "dead", p->GetMapId(), p->GetPositionX(), p->GetPositionY(), p->GetPositionZ(),
                    p->GetHealth(), p->GetMaxHealth(), p->HasAuraType(SPELL_AURA_GHOST) ? 1 : 0, uint32(p->getDeathState()), p->IsInCombat() ? 1 : 0);
        }
        if (++party.wipes >= 4)
        {
            Count(BLC_DUNGEON_WIPEOUT);
            RecordDungeonRun(d, party, leader, "wipeout", now);
            // wiping without a single kill: something about this dungeon (water, falling, scripted start) is beyond the bots
            if (!leaderAI || !leaderAI->life.dungeonKills)
                MarkBadDungeon(d, "wipeout");
            TC_LOG_INFO("playerbots", "BotLife: {} gives up {} after {} wipes ({} kills, {} bosses)", leader->GetName(), d.name, party.wipes,
                leaderAI ? leaderAI->life.dungeonKills : 0, leaderAI ? leaderAI->life.dungeonBosses : 0);
            return true;
        }
        Count(BLC_DUNGEON_WIPE);
        s_wipeDiag[leader->GetGUID().GetCounter()] = { now + 60000, now };   // diagnostics: 
        for (Player* p : players)
        {
            if (!p->IsAlive())
            {
                p->ResurrectPlayer(1.0f);
                p->SpawnCorpseBones();
                TC_LOG_INFO("playerbots", "BotLife: after-wipe rez {}: alive {}, ghost {}, health {}/{}", p->GetName(), p->IsAlive() ? 1 : 0,
                    p->HasAuraType(SPELL_AURA_GHOST) ? 1 : 0, p->GetHealth(), p->GetMaxHealth());
            }
            QueueTeleport(p, d.map, d.x + frand(-2.0f, 2.0f), d.y + frand(-2.0f, 2.0f), d.z, d.o);
        }
        if (leaderAI)
        {
            leaderAI->life.dungeonTarget = 0;
            leaderAI->life.hasDest = false;
        }
        return false;
    }
    party.allDeadSince = 0;
    if (combat)
        return false;

    // after the fight: the dead get up, stragglers come back
    for (Player* p : players)
    {
        if (p == anchor)
            continue;
        bool inHarm = false;
        if (!p->IsAlive())
        {
            // died in lava or slime - gets up at the anchor, not in it again (Ragefire Chasm death loop)
            inHarm = (p->GetMap()->GetLiquidStatus(p->GetPhaseMask(), p->GetPositionX(), p->GetPositionY(), p->GetPositionZ(),
                MAP_LIQUID_TYPE_MAGMA | MAP_LIQUID_TYPE_SLIME, nullptr, p->GetCollisionHeight()) & MAP_LIQUID_STATUS_IN_CONTACT) != 0;
            p->ResurrectPlayer(0.7f);
            p->SpawnCorpseBones();
            Count(BLC_DUNGEON_REZ);
        }
        if (inHarm || p->FindMap() != anchor->FindMap() || p->GetExactDist(anchor) > 60.0f)
            QueueTeleport(p, anchor->GetMapId(), anchor->GetPositionX() + frand(-2.0f, 2.0f), anchor->GetPositionY() + frand(-2.0f, 2.0f),
                anchor->GetPositionZ() + 0.5f, anchor->GetOrientation());
    }
    return false;
}

void BotLifeMgr::FormWorldParties(uint32 now, uint32 wanted)
{
    // candidates grouped by map + zone + team
    std::map<std::tuple<uint32, uint32, uint32>, std::vector<Player*>> buckets;
    for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
    {
        Player* bot = pair.second;
        if (IsBanker(bot->GetGUID()) || IsLfgBot(bot->GetGUID()) || IsWalker(bot) || !IsSoloCandidate(bot))
            continue;
        buckets[std::make_tuple(bot->GetMapId(), bot->GetZoneId(), uint32(bot->GetTeam()))].push_back(bot);
    }

    uint32 formed = 0;
    std::vector<std::vector<Player*>*> order;
    for (auto& b : buckets)
        if (b.second.size() >= 2)
            order.push_back(&b.second);
    std::shuffle(order.begin(), order.end(), PartyRng());

    for (std::vector<Player*>* bucket : order)
    {
        if (formed >= PARTY_MAX_NEW_PER_TICK || wanted < 2)
            break;
        std::vector<Player*>& bots = *bucket;
        std::shuffle(bots.begin(), bots.end(), PartyRng());
        std::vector<bool> used(bots.size(), false);
        for (size_t i = 0; i < bots.size() && formed < PARTY_MAX_NEW_PER_TICK && wanted >= 2; ++i)
        {
            if (used[i])
                continue;
            Player* leader = bots[i];
            uint32 size = urand(2, 3);
            // nearest bots of about the same level
            std::vector<std::pair<float, size_t>> near;
            for (size_t j = 0; j < bots.size(); ++j)
            {
                if (j == i || used[j])
                    continue;
                int32 diff = int32(bots[j]->GetLevel()) - int32(leader->GetLevel());
                if (diff < -3 || diff > 3)
                    continue;
                // a guild mate in the zone before a stranger next door
                bool const mate = _guildGroups && leader->GetGuildId() && bots[j]->GetGuildId() == leader->GetGuildId();
                near.emplace_back(leader->GetExactDist(bots[j]) + (mate ? 0.0f : 100000.0f), j);
            }
            if (near.empty())
                continue;
            std::sort(near.begin(), near.end());
            std::vector<Player*> members;
            for (auto const& n : near)
            {
                if (members.size() + 1 >= size)
                    break;
                members.push_back(bots[n.second]);
                used[n.second] = true;
            }
            used[i] = true;
            uint32 minutes = urand(_partyMinutesMin, _partyMinutesMax);
            if (CreateParty(leader, members, BOTLIFE_PARTY_WORLD, minutes * MINUTE * IN_MILLISECONDS))
            {
                ++formed;
                wanted = wanted > members.size() + 1 ? wanted - uint32(members.size() + 1) : 0;
            }
        }
    }
}

bool BotLifeMgr::CreateParty(Player* leader, std::vector<Player*> const& members, uint8 type, uint32 durationMs)
{
    if (!leader || members.empty() || leader->GetGroup())
        return false;

    Group* group = new Group();
    if (!group->Create(leader))
    {
        delete group;
        return false;
    }
    sGroupMgr->AddGroup(group);
    group->SetLootMethod(NEED_BEFORE_GREED);   // FFA never rolled, BotRollChoice hook never fired - need/greed requires a real roll method
    if (type == BOTLIFE_PARTY_RAID)
        group->ConvertToRaid();
    else if (type == BOTLIFE_PARTY_DUNGEON)
        group->SetDungeonDifficulty(DUNGEON_DIFFICULTY_NORMAL);

    BotLifeParty party;
    party.type = type;
    party.leader = leader->GetGUID();
    party.members.push_back(leader->GetGUID());
    party.formedAt = getMSTime();
    party.until = party.formedAt + durationMs;

    for (Player* member : members)
    {
        if (!member || member->GetGroup() || group->IsFull())
            continue;
        if (!group->AddMember(member))
            continue;
        party.members.push_back(member->GetGUID());
        if (PlayerbotAI* memberAI = GET_PLAYERBOT_AI(member))
        {
            ResetPartyState(member);
            memberAI->life.party = type;
            memberAI->SetMaster(leader);
            memberAI->ResetStrategies();
            memberAI->ChangeStrategy("+follow", BOT_STATE_NON_COMBAT);
        }
        // members of a world party meet up with the leader
        if (type == BOTLIFE_PARTY_WORLD && (member->FindMap() != leader->FindMap() || member->GetExactDist(leader) > 120.0f))
            QueueTeleport(member, leader->GetMapId(), leader->GetPositionX() + frand(-3.0f, 3.0f),
                leader->GetPositionY() + frand(-3.0f, 3.0f), leader->GetPositionZ() + 0.5f, leader->GetOrientation());
    }

    if (party.members.size() < 2)
    {
        group->Disband(true);
        return false;
    }

    if (PlayerbotAI* leaderAI = GET_PLAYERBOT_AI(leader))
    {
        ResetPartyState(leader);
        leaderAI->life.party = type;
        leaderAI->ResetStrategies();   // the group strategies (tank, threat), as the members get
    }

    Count(BLC_PARTY_FORMED);
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife: party {} formed by {} (lvl {}, zone {}) with {} members, {} min",
            uint32(type), leader->GetName(), uint32(leader->GetLevel()), leader->GetZoneId(), party.members.size(), durationMs / MINUTE / IN_MILLISECONDS);
    _parties[group->GetLowGUID()] = std::move(party);
    return true;
}

void BotLifeMgr::DisbandParty(uint32 groupLow, BotLifeParty& party)
{
    std::vector<Player*> players;
    for (ObjectGuid const& guid : party.members)
        if (Player* member = ObjectAccessor::FindConnectedPlayer(guid))
            players.push_back(member);

    // dungeon / raid parties: everybody back to where they were
    if (party.type != BOTLIFE_PARTY_WORLD)
    {
        for (Player* member : players)
        {
            if (member->IsBeingTeleported())
                continue;
            if (!member->IsAlive())
            {
                member->ResurrectPlayer(1.0f);
                member->SpawnCorpseBones();
            }
            auto loc = party.origin.find(member->GetGUID());
            if (loc != party.origin.end())
                QueueTeleport(member, loc->second.map, loc->second.x, loc->second.y, loc->second.z, loc->second.o);
            else
                QueueTeleport(member, member->m_homebindMapId, member->m_homebindX, member->m_homebindY, member->m_homebindZ, member->GetOrientation());
        }
    }

    if (Group* group = sGroupMgr->GetGroupByGUID(groupLow))
        group->Disband(true);

    for (Player* member : players)
    {
        if (!member->GetGroup())
            ReleaseBot(member);
    }
    Count(BLC_PARTY_DISBANDED);
}

// ---------------------------------------------------------------------------------------------
// map thread (the bot's own map; party members on the same map are updated by the same thread)

template <class F>
void BotLifeMgr::ForEachPartyMemberNear(Player* bot, float dist, F&& fn)
{
    Group* group = bot->GetGroup();
    if (!group)
        return;
    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        Player* member = ref->GetSource();
        if (!member || member == bot || !member->IsInWorld() || member->GetMap() != bot->GetMap())
            continue;
        if (bot->GetExactDist(member) > dist)
            continue;
        fn(member);
    }
}

bool BotLifeMgr::PartyFollowerUpdate(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    if (!bot->IsAlive() || bot->IsBeingTeleported() || bot->IsInFlight())
        return false;

    // the party fights - no looting, resting or chatting; the engine (heal / assist) gets the update
    Player* hurt = nullptr;
    bool partyFights = false;
    if (Group* group = bot->GetGroup())
        for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
            if (Player* member = ref->GetSource())
                if (member->GetMap() == bot->GetMap() && member->IsAlive() && bot->GetExactDist(member) < 40.0f)
                {
                    if (member != bot && member->IsInCombat())
                        partyFights = true;
                    if (!hurt || member->GetHealthPct() < hurt->GetHealthPct())
                        hurt = member;
                }
    // diagnostics: what a healer of a dungeon party does while its group fights
    if (partyFights && (t.party == BOTLIFE_PARTY_DUNGEON || t.party == BOTLIFE_PARTY_RAID) && PlayerBotSpec::IsHeal(bot, true))
    {
        static std::mutex s_healDiagLock;
        static std::unordered_map<ObjectGuid::LowType, uint32> s_healDiag;
        bool due = false;
        {
            std::lock_guard<std::mutex> guard(s_healDiagLock);
            uint32& next = s_healDiag[bot->GetGUID().GetCounter()];
            if (now >= next)
            {
                next = now + 15000;
                due = true;
            }
        }
        if (due)
        {
            static char const* const heals[] = { "flash heal", "heal", "renew", "power word: shield", "penance", "healing wave",
                "healing surge", "riptide", "healing touch", "regrowth", "rejuvenation", "holy light", "flash of light",
                "word of glory", "holy shock", "soothing mist", "surging mist", "renewing mist" };
            std::ostringstream known, strategies;
            for (char const* name : heals)
                if (uint32 id = botAI->GetAiObjectContext()->GetValue<uint32>("spell id", name)->Get())
                    known << ' ' << name << ':' << id;
            for (std::string const& s : botAI->GetStrategies(BOT_STATE_COMBAT))
                strategies << ' ' << s;
            // (part 2: whom the engine would heal, and whether the party heal actions can and want to)
            Unit* toHeal = botAI->GetAiObjectContext()->GetValue<Unit*>("party member to heal")->Get();
            known << " | to heal " << (toHeal ? toHeal->GetName() : std::string("-")) << ' ' << (toHeal ? uint32(toHeal->GetHealthPct()) : 0u) << "%";
            if (toHeal && toHeal != bot)
                known << " dist " << uint32(bot->GetExactDist(toHeal)) << " los " << (bot->IsWithinLOSInMap(toHeal) ? 1 : 0);
            known << " moving " << (bot->isMoving() ? 1 : 0) << " motion " << uint32(bot->GetMotionMaster()->GetCurrentMovementGeneratorType()) << " |";
            // (healer-mana) what the mana depends on: chi and Mana Tea stacks (monk), spirit and intellect (all)
            {
                Aura const* tea = bot->GetAura(115867);
                known << " chi " << bot->GetPower(POWER_CHI) << '/' << bot->GetMaxPower(POWER_CHI) << " manatea " << (tea ? uint32(tea->GetStackAmount()) : 0u)
                      << " spi " << uint32(bot->GetStat(STAT_SPIRIT)) << " int " << uint32(bot->GetStat(STAT_INTELLECT)) << " |";
            }
            static char const* const partyHeals[] = { "flash heal on party", "power word: shield on party", "renew on party",
                "lesser healing wave on party", "riptide on party", "soothing mist on party", "renewing mist on party",
                "flash of light on party", "holy light on party", "rejuvenation on party", "regrowth on party", "healing touch on party" };
            for (char const* name : partyHeals)
                if (Action* action = botAI->GetAiObjectContext()->GetAction(name))
                    known << ' ' << name << ':' << (action->isPossible() ? 'P' : 'p') << (action->isUseful() ? 'U' : 'u');
            TC_LOG_INFO("playerbots", "BotLife healdiag {}: cls {} spec {} lvl {}, engine {}, in combat {}, casting {}, resting {}, looting {}, mana {}%, lowest {} {:.0f}% | combat strategies:{} | heals:{}",
                bot->GetName(), uint32(bot->GetClass()), uint32(bot->GetSpecialization()), uint32(bot->GetLevel()), uint32(botAI->GetState()),
                bot->IsInCombat() ? 1 : 0, bot->HasUnitState(UNIT_STATE_CASTING) ? 1 : 0, t.resting ? 1 : 0, t.lootTarget.IsEmpty() ? 0 : 1,
                uint32(bot->GetPowerPct(POWER_MANA)), hurt ? hurt->GetName() : std::string("-"), hurt ? hurt->GetHealthPct() : 100.0f,
                strategies.str(), known.str());
        }
    }
    // a healer keeps up with the leader (the tank) while the party fights - out of reach or sight it cannot
    // heal it; the combat engine does not follow
    if (partyFights && PlayerBotSpec::IsHeal(bot, true) && !bot->HasUnitState(UNIT_STATE_CASTING))
        if (Group* group = bot->GetGroup())
            if (Player* leader = [&]() -> Player*
                {
                    // the tank, not the party leader (who is often a DPS); the leader without a tank
                    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                        if (Player* member = ref->GetSource())
                            if (member != bot && member->IsAlive() && member->GetMap() == bot->GetMap() && PlayerBotSpec::IsTank(member, true))
                                return member;
                    return ObjectAccessor::GetPlayer(*bot, group->GetLeaderGUID());
                }())
                if (leader != bot && leader->IsAlive() && leader->GetMap() == bot->GetMap()
                    && (bot->GetExactDist(leader) > 30.0f || !bot->IsWithinLOSInMap(leader)))
                {
                    if (!bot->isMoving() || now - t.lastMoveOrder > 1500)
                    {
                        bot->GetMotionMaster()->MoveFollow(leader, 10.0f, float(M_PI));
                        t.lastMoveOrder = now;
                    }
                    return true;
                }
    if (partyFights && !bot->IsInCombat())
    {
        t.resting = false;
        t.lootTarget.Clear();
        if (bot->IsSitState())
            bot->SetStandState(UNIT_STAND_STATE_STAND);
        return false;
    }
    if (bot->IsInCombat())
    {
        Dismount(bot);
        CombatPotion(bot, t, now);
        if (CombatSelfHeal(bot, t, now))
            return true;
        t.lastCombat = now;
        t.resting = false;
        return false;
    }
    if (bot->HasUnitState(UNIT_STATE_CASTING))
        return false;

    if (now >= t.nextRidingCheck)
    {
        t.nextRidingCheck = now + urand(8, 12) * MINUTE * IN_MILLISECONDS;
        EnsureRiding(bot);
    }

    if (_loot && (!t.lootTarget.IsEmpty() || !t.lootQueue.empty()) && DoLoot(bot, t, now))
        return true;

    if (now >= t.nextBagCheck)
    {
        t.nextBagCheck = now + urand(45000, 75000);
        ManageBags(bot);
    }

    if (_rest && DoRest(bot, t, now))
        return true;

    if (_chat || _emotes)
        SocialTick(botAI, t, now);

    // ride when the leader rides
    if (Group* group = bot->GetGroup())
        if (Player* leader = ObjectAccessor::GetPlayer(*bot, group->GetLeaderGUID()))
        {
            if (leader->IsMounted() && !bot->IsMounted())
                MountUp(bot);
            else if (!leader->IsMounted() && bot->IsMounted())
                Dismount(bot);
        }

    return false;   // engine: follow + assist the leader
}

bool BotLifeMgr::PartyLeaderWait(Player* bot, BotLifeInfo& t, uint32 now)
{
    bool wait = false;
    Group* group = bot->GetGroup();
    for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
    {
        Player* member = ref->GetSource();
        if (!member || member == bot || !member->IsInWorld() || member->GetMap() != bot->GetMap() || !member->IsAlive())
            continue;
        PlayerbotAI* memberAI = GET_PLAYERBOT_AI(member);
        if (!memberAI)
            continue;   // real players in the group are not waited for
        float d = bot->GetExactDist(member);
        if (d > PARTY_FAR_DIST)
            continue;   // the world thread summons real stragglers
        if (d > PARTY_GATHER_DIST || member->IsInCombat() || (memberAI && (memberAI->life.resting || !memberAI->life.lootTarget.IsEmpty())))
        {
            wait = true;
            break;
        }
    }

    if (!wait)
    {
        t.partyWaitSince = 0;
        return false;
    }
    if (!t.partyWaitSince)
        t.partyWaitSince = now;
    if (now - t.partyWaitSince > PARTY_MAX_WAIT_MS)
    {
        if (now - t.partyWaitSince > PARTY_MAX_WAIT_MS * 2)
            t.partyWaitSince = 0;   // walk on for a while, then wait again
        return false;
    }
    if (bot->isMoving())
        bot->StopMoving();
    return true;
}

void BotLifeMgr::PartyShareQuest(Player* leader, Quest const* /*quest*/, Creature* npc)
{
    // members take what this quest giver has for them (the leader's quest when they can, otherwise their own step of the chain)
    ForEachPartyMemberNear(leader, 40.0f, [&](Player* member)
    {
        PlayerbotAI* memberAI = GET_PLAYERBOT_AI(member);
        if (!memberAI)
            return;
        for (uint32 questId : sObjectMgr->GetCreatureQuestRelations(npc->GetEntry()))
        {
            if (ActiveQuestCount(member) >= _maxQuests + 1)
                break;
            Quest const* q = sObjectMgr->GetQuestTemplate(questId);
            if (!q || member->GetQuestStatus(questId) != QUEST_STATUS_NONE || memberAI->life.skipQuests.count(questId))
                continue;
            if (!QuestLevelOk(member, q) || !GetPlan(q).supported)
                continue;
            if (!member->CanTakeQuest(q, false) || !member->CanAddQuest(q, false))
                continue;
            member->AddQuestAndCheckCompletion(q, npc);
            if (member->FindQuestSlot(questId) < MAX_QUEST_LOG_SIZE)
            {
                memberAI->life.questStarted[questId] = getMSTime();
                Count(BLC_PARTY_QUEST_SHARED);
            }
        }
    });
}

void BotLifeMgr::PartyTurnIn(Player* leader, Creature* npc, uint32 /*questId*/)
{
    // members hand in everything this NPC takes
    ForEachPartyMemberNear(leader, 40.0f, [&](Player* member)
    {
        for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
        {
            uint32 memberQuest = member->GetQuestSlotQuestId(slot);
            if (!memberQuest || member->GetQuestStatus(memberQuest) != QUEST_STATUS_COMPLETE)
                continue;
            if (!sObjectMgr->GetCreatureQuestInvolvedRelations(npc->GetEntry()).HasQuest(memberQuest))
                continue;
            if (TurnIn(member, npc, memberQuest))
                Count(BLC_PARTY_QUEST_TURNIN);
        }
    });
}

void BotLifeMgr::PartyShareKill(Player* killer, Creature* killed)
{
    ForEachPartyMemberNear(killer, 40.0f, [&](Player* member)
    {
        PlayerbotAI* memberAI = GET_PLAYERBOT_AI(member);
        if (!memberAI || !memberAI->life.party)
            return;
        BotLifeInfo& mt = memberAI->life;
        if (mt.lootQueue.size() >= 6)
            mt.lootQueue.pop_front();
        mt.lootQueue.push_back(killed->GetGUID());
    });
}
