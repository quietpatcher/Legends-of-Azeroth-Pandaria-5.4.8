/*
 * Bot life: "bot life" - per-bot state for traveling, questing, looting, resting and social behaviour
 * of random bots the server. See BotLife.h for the manager.
 */

#ifndef _BOTLIFE_INFO_H
#define _BOTLIFE_INFO_H

#include <utility>
#include "Define.h"
#include "ObjectGuid.h"

#include <deque>
#include <map>
#include <set>
#include <unordered_map>
#include <vector>

enum class BotLifeState : uint8
{
    IDLE = 0,
    GO_GRIND,        // traveling to a grind spot
    AT_GRIND,        // grinding around a spot (engine does the fighting)
    GO_QUESTGIVER,   // traveling to a quest giver
    DO_QUEST,        // working on quest objectives
    GO_TURNIN,       // traveling to the quest ender
    REST,            // short break (sitting)
    TOWN,            // visiting a city: vendors, trainers, bank, auction house
    DIG              // archaeology - riding to / working at a dig site of the bot
};

struct BotLifePoint
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
};

struct BotLifeInfo
{
    BotLifeState state = BotLifeState::IDLE;
    uint32 stateSince = 0;
    uint32 stateUntil = 0;           // 0 = no timeout
    uint32 nextThink = 0;
    uint32 lastCombat = 0;
    uint32 targetWaitSince = 0;      // since when a grind target keeps us from traveling
    uint32 ignoreTargetsUntil = 0;

    // travel
    bool hasDest = false;
    uint32 destMap = 0;
    float destX = 0.0f;
    float destY = 0.0f;
    float destZ = 0.0f;
    float arriveDist = 8.0f;
    std::vector<BotLifePoint> path;
    uint32 pathIdx = 0;
    uint32 lastMoveOrder = 0;
    uint32 lastProgressCheck = 0;
    float lastDist = 0.0f;
    uint8 stuck = 0;
    float bestDist = 0.0f;           // 6-10 bestdist: shortest distance to the destination reached so far
    uint32 bestDistAt = 0;           // when that was
    uint32 graveyardRevive = 0;      // 6-10 graveyardrevive: ms time from which the dead bot revives at the graveyard instead of its corpse
    ObjectGuid fightVictim;          // 6-10 fruitlessfight: victim of the running fight, its health and ours, since when
    float fightVictimHp = 0.0f;
    float fightBotHp = 0.0f;
    uint32 fightSince = 0;

    // pending cross-thread actions. World-thread formation code must NOT mutate another bot directly
    // (TeleportTo/CombatStop/Reset interrupt spells + touch combat state while the bot runs on its own map thread ->
    // spell-target-list corruption -> Spell::~Spell _M_clear hang / jemalloc free crash). The world thread queues here;
    // the bot performs them on its OWN map thread from RunPendingActions (combat-stop, reset, then teleport).
    bool teleQueued = false;
    bool resetQueued = false;
    bool combatStopQueued = false;
    uint8 relevelTo = 0;             // (level-balance) set by the world thread: the bot gets this level on its own map thread
    uint32 teleMap = 0;
    float teleX = 0.0f, teleY = 0.0f, teleZ = 0.0f, teleO = 0.0f;

    // quests
    uint32 questId = 0;              // quest for DO_QUEST / GO_TURNIN
    uint32 npcEntry = 0;             // quest giver / ender entry
    bool npcIsGo = false;            // batch 11i: npcEntry is a game object
    uint32 questProgressValue = 0;
    uint32 questProgressTime = 0;
    uint32 questRetarget = 0;        // how often the objective destination was re-picked
    uint32 npcChase = 0;             // times the bot walked after a giver / ender on a path
    uint32 questIdleSince = 0;       // nothing to fight or open at the quest spot since then
    std::unordered_map<uint32, uint32> questStarted;   // questId -> ms accepted
    std::unordered_map<uint32, uint32> avoidNpc;       // creature entry -> ms until retry (as a quest giver)
    std::unordered_map<uint32, uint32> avoidEnder;     // creature entry -> ms until retry (as a quest ender)
    bool questPoint = false;         // the objective destination is a point to stand on (area trigger), not an area
    uint32 interactUntil = 0;        // talking to / using something on a quest NPC until then
    uint32 nextInteractSearch = 0;
    uint32 nextVendorSearch = 0;     // a quest item to buy
    uint32 nextUseSearch = 0;        // the item of the quest to use
    uint32 nextQuestSpell = 0;       // next try of the spell a practice target wants
    std::unordered_map<ObjectGuid, uint32> interacted;   // quest NPC -> ms until it is tried again
    std::set<uint32> skipQuests;
    ObjectGuid questTarget;          // quest creature this bot goes for
    uint32 questTargetSince = 0;
    uint32 nextQuestTargetSearch = 0;
    std::unordered_map<ObjectGuid, uint32> badQuestTargets;   // could not be engaged: ms until retry
    ObjectGuid useGo;                // chest/object to open for an item objective
    uint32 nextGoSearch = 0;
    std::unordered_map<ObjectGuid, uint32> usedGos;   // object -> ms until it may be used again

    // loot
    std::deque<ObjectGuid> lootQueue;
    ObjectGuid lootTarget;
    uint32 lootSince = 0;

    // death
    uint32 deadSince = 0;
    uint32 vehicleCastAt = 0;
    uint32 vehicleVisitIdx = 0;      // which visit creature is next
    uint32 vehicleArriveAt = 0;      // (vehiclevisit) when the vehicle reached it
    uint32 vehicleMoveAt = 0;        // the last move order for a vehicle the bot steers
    std::string scenarioNote;      // last scenario lead note (log throttling)   // last vehicle ability cast (vehicle quests)
    uint32 nextPotion = 0;
    uint32 nextSelfHeal = 0;
    std::unordered_map<uint32, std::pair<uint32, uint32>> deathsBy;   // creature entry -> (count, last ms)
    std::unordered_map<uint32, uint32> avoidCreature;                 // creature entry -> ms until it is left alone

    // battlegrounds
    uint32 bgQueueType = 0;          // BattlegroundQueueTypeId this bot was queued for by bot life
    uint32 bgQueuedAt = 0;
    uint32 bgEnteredAt = 0;
    uint32 bgNoRealSince = 0;
    uint32 bgNextRealCheck = 0;
    uint32 bgCaptureAt = 0;          // "casting" the banner capture until then

    // area triggers (the client sends these; bots have no client)
    uint32 nextTriggerCheck = 0;
    std::vector<uint32> insideTriggers;

    // riding
    uint32 nextRidingCheck = 0;
    bool wantMount = false;          // set by Travel() during this update
    uint32 lastWantMount = 0;

    // rest / regen
    bool resting = false;
    uint32 lastRegen = 0;

    // bags
    uint32 nextBagCheck = 0;

    // social
    uint32 nextSocial = 0;

    // level / zone fit
    uint32 nextZoneCheck = 0;
    uint32 dkChainSince = 0;         // death knight starting chain - last progress
    uint32 dkChainDone = 0;          // rewarded quests then
    uint32 dkChainStalls = 0;
    bool dkChainGivenUp = false;     // closed for this session, nothing marked done
    uint32 dkEyeSince = 0;           // Eye of Acherus (12641) - taken at / looked through since
    uint32 dkEyeTries = 0;
    uint32 dkEyeCast = 0;            // last Siphon of Acherus

    // town visits
    uint32 nextTownVisit = 0;
    uint32 townWaitUntil = 0;
    bool townBusinessDone = false;
    // guild banker (walks guild vault - auctioneer - mailbox in the faction capital)
    bool banker = false;
    uint32 nextBankerCheck = 0;
    uint8 bankerStep = 0;
    bool bankerDestSet = false;
    uint32 bankerWaitUntil = 0;
    uint32 bankerNextTeleport = 0;
    bool lfgMaster = false;            // master set for a dungeon finder group with a real player
    uint32 lfgTestAt = 0;              // dungeon finder test - when the lead opens the event (0: done / not yet in)
    uint32 lfgLeadInstance = 0;        // instance this bot leads a group with a real player through
    std::set<uint32> gossipUsed;       // event NPCs (spawn ids) this run already talked to
    std::set<uint32> areaTriggersFired;   // (bot-areatrigger) scripted area triggers this run already set off
    uint32 areaTriggerCheck = 0;          // (bot-areatrigger) next check (ms, game time)
    std::set<uint32> eventFarVisited;  // far event NPCs the leader already walked up to this run
    ObjectGuid escortNpc;              // event NPC we started and now stay with (escort)
    uint32 escortUntil = 0;
    uint32 nextGossipTry = 0;
    uint32 gossipApproachKey = 0;      // the event NPC / object the bot walks up to, since when
    uint32 gossipApproachSince = 0;
    uint32 gossipApproachTick = 0;     // uldaman-altar 3: last tick of that approach
    std::map<uint32, uint32> gossipEmpty;   // event NPCs with nothing to say yet -> bosses down then
    uint32 noVictimCombatSince = 0;    // phantom-combat watchdog (see BotLife.cpp)
    bool weaponChecked = false;
    uint32 nextGearCheck = 0;          // next EquipBagUpgrades
    std::deque<uint32> recentDeaths;   // death streak detection (msTime of the last deaths)
    bool relocateAfterDeaths = false;
    ObjectGuid gatherTarget;           // node or corpse being gathered
    uint32 gatherSpell = 0;
    uint32 gatherSince = 0;
    uint32 gatherCasts = 0;
    uint32 nextGatherSearch = 0;
    uint32 craftsLeft = 0;             // crafts still to do this town visit
    bool craftSupplied = false;        // the guild bank was asked for reagents this visit
    bool forgeVisited = false;         // looked for the town's anvil / forge this visit
    uint32 craftSupplyAt = 0;          // not before this (the bank / auction business runs first)
    uint32 craftSpell = 0;             // craft cast in progress
    uint32 nextCraft = 0;
    std::set<uint32> craftFailed;      // recipes that failed this visit (focus, tools, bag space)
    bool refined = false;              // herbs milled / ore prospected / gear disenchanted this visit
    bool fireMade = false;             // a cooking fire was lit this visit
    // fishing
    uint32 nextFishCheck = 0;
    uint32 nextFishSession = 0;
    uint32 fishCastsLeft = 0;
    uint32 fishNextCast = 0;
    float fishAngle = 0.0f, fishX = 0.0f, fishY = 0.0f;
    ObjectGuid fishBobber;
    // archaeology
    uint32 nextDig = 0;
    uint32 walkNextLog = 0;   // walker status line
    uint32 digCastAt = 0;              // a survey was cast then
    uint32 digFinds = 0;               // finds of this trip
    uint32 digMisses = 0;              // surveys in a row that dug nothing up
    // stuck detection that tells a detour from a standstill
    float lastPosX = 0.0f, lastPosY = 0.0f;
    uint8 detour = 0;
    float wpX = 0.0f, wpY = 0.0f;       // the waypoint of the last travel order
    uint32 nextMasterQuestSync = 0;  // bots of a real player share its quests
    ObjectGuid rangeTestCreature;    // diag
    uint32 rangeTestAt = 0;
    uint32 rangeTestSpell = 0;
    float rangeTestDist = 0.0f;
    uint8 rangeTestPhase = 0;         // 1 teleported to the test creature, 2 shot fired      // EnsureWeapon ran after login   // guild bank business done this town visit
    uint32 townMap = 0;
    float townX = 0.0f, townY = 0.0f, townZ = 0.0f, townO = 0.0f;   // where the bot came from

    // (bot-duels) when the current duel (request) was first seen, and the next try to challenge another bot
    uint32 duelSeenAt = 0;
    uint32 nextDuelChallenge = 0;

    // party (set by BotLifeMgr on the world thread): 0 = none, see BotLifePartyType
    uint8 party = 0;
    uint32 partyWaitSince = 0;

    // dungeon / raid crawl (party leader)
    uint32 dungeonTarget = 0;        // creature spawn id
    uint32 dungeonTargetSince = 0;
    uint32 dungeonTargetActive = 0;  // ms spent on the current target while not waiting for the group
    uint32 dungeonLastTick = 0;
    uint32 dungeonEngageSince = 0;
    std::set<uint32> dungeonSkip;
    bool dungeonDone = false;
    uint32 dungeonKills = 0;
    // these sat in function-static tables that every map thread wrote to without a lock
    std::pair<uint32, uint32> leadCombat{0, 0};   // dungeon leader in combat without a victim: (kills seen, since)
    std::pair<uint32, uint32> noKill{0, 0};       // dungeon leader fighting without a kill: (kills seen, since)
    uint32 rezWaitSince = 0;                       // (rez-wait) the lead waits for a dead real player to be resurrected
    uint32 nextRezOrder = 0;                       // (rez-walk) next walk/cast order of a healer to a dead real player
    uint32 doorBlockedSince = 0;                   // (door-block) every target of the lead lies behind a closed door
    ObjectGuid stuckAttacker;                      // (stuckattacker) attacker of a member the group could not reach: all bots go for it
    uint32 stuckAttackerUntil = 0;
    uint32 nextWalkBring = 0;                      // walker: the next try to bring it to a quest giver of its zones
    uint32 zjDiagNext = 0;                         // diagnostics of the Zar'jira fight: the next log line
    uint32 dungeonBosses = 0;
    uint32 dungeonWingArea = 0;      // (wing-area) set every leader tick from the group: 0 = no area wing
    uint32 dungeonWingList = 0;      // (wing-area) dungeon finder id of a wing from a boss list, 0 = none

    // kill-gate mobs, targets that are not in the spawn list, sealed bosses
    bool dungeonGateTarget = false;          // dungeonTarget is a kill-gate mob
    std::set<uint32> dungeonGateSkip;
    ObjectGuid dungeonDynTarget;             // summoned by an encounter / opened up during the run
    uint32 dungeonDynActive = 0;             // ms spent on it
    std::set<ObjectGuid> dungeonDynSkip;
    uint32 dungeonSealedTarget = 0;          // spawn id of the sealed boss the leader walks up to
    uint32 dungeonSealedActive = 0;
    uint32 dungeonSealedWait = 0;            // stands next to it until then
    std::set<uint32> dungeonSealedVisited;
    uint32 dungeonSealedBosses = 0;          // bosses down at the last visits
    int32 dungeonStateBase = -1;             // encounters the instance already had done when the run began
    std::map<uint32, uint32> dungeonDynPicks;   // unlisted targets taken per creature entry (endless summons)
    std::map<std::string, uint32> dungeonSkipWhy;   // skipped targets per reason

    void ResetDungeonExtras()
    {
        dungeonGateTarget = false;
        dungeonGateSkip.clear();
        dungeonDynTarget.Clear();
        dungeonDynActive = 0;
        dungeonDynSkip.clear();
        dungeonSealedTarget = 0;
        dungeonSealedActive = 0;
        dungeonSealedWait = 0;
        dungeonSealedVisited.clear();
        dungeonSealedBosses = 0;
        dungeonStateBase = -1;
        dungeonDynPicks.clear();
        // the event NPCs of the last run (the spawn ids are the same in every instance)
        dungeonSkipWhy.clear();
        gossipUsed.clear();
        areaTriggersFired.clear();   // (bot-areatrigger)
        gossipEmpty.clear();
        gossipApproachKey = 0;
        gossipApproachSince = 0;
        gossipApproachTick = 0;   // uldaman-altar 3: 
        eventFarVisited.clear();
        nextGossipTry = 0;
        escortNpc.Clear();
        escortUntil = 0;
    }
};

#endif
