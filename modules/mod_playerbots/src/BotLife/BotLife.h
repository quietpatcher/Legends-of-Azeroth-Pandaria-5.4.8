/*
 * Bot life: "bot life" for random bots on the LoA MoP server.
 *  - travel to level-appropriate grind spots (and away from zones that do not fit the bot's level)
 *  - pick up quests, work on kill/collect objectives, turn them in
 *  - loot own kills, keep bags usable, rest to regenerate
 *  - chat and emote (guild chat, say near real players, zone channel)
 *  - guild events: sign up for guild calendar events and join the organizer's raid when it starts
 *
 * Only random bots without a real-player master are driven by this system; bots added by a
 * player (addclass/addspec) or grouped with a player keep the normal follow/assist behaviour.
 */

#ifndef _BOTLIFE_H
#define _BOTLIFE_H

#include "Define.h"
#include "ObjectGuid.h"
#include "BotLifeInfo.h"

#include <array>
#include <set>
#include <atomic>
#include <memory>
#include <mutex>
#include <shared_mutex>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

class ChatHandler;
class Creature;
class GameObject;
class Group;
class Guild;
class Item;
class Map;
class Player;
class PlayerbotAI;
class Quest;
class Unit;
class WorldObject;
struct QuestObjective;

struct BotLifeSpawn
{
    uint32 entry = 0;
    uint16 map = 0;
    uint16 zone = 0;
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    bool go = false;                 // batch 11i: a game object (quest giver / ender)
    uint32 phaseMask = 1;            // creature spawns: the phases it stands in, 0 = by phase id
    uint32 phaseId = 0;              // MoP phase id of the spawn (creature.phaseId), 0 = none
};

// who gives a kill credit without being killed, and how: a spell that has to hit it, or (spell 0) a talk
struct BotLifeCreditSource
{
    uint32 creature = 0;
    uint32 spell = 0;
    bool fight = false;              // the credit comes while fighting it (at a health percentage)
    float visit = 0.0f;              // batch 11k: the credit comes for standing within this range
    bool click = false;              // batch 11o: a click on it hands out an item of the quest
    uint32 emote = 0;                // the credit comes for this text emote at the creature
    bool follow = false;             // batch 11z: an escort - walk along with it (with visit)
};

// the item of a quest that has to be used, and where
struct BotLifeQuestUse
{
    uint32 item = 0;                 // the item the quest hands out
    uint32 spell = 0;                // its spell
    uint32 makes = 0;                // the objective item the spell creates (0 = the spell completes the quest)
    bool corpse = false;             // the creature has to be dead (batch 11f): fight it first
    uint32 credit = 0;               // batch 11j: the spell summons this credit creature (a helper: totem, pot of stew)
    std::vector<uint32> objects;     // spell focus objects to stand at
    std::vector<uint32> creatures;   // creatures to use it on (neither: wherever the bot is)
    bool tool = false;               // batch 11o: not handed out - the bot fetches it first (chest, creature, vendor)
    uint32 summoned = 0;             // batch 11s: the spell calls up this creature, which drops the objective item
    uint32 hitCredit = 0;            // 6-10: the creature the spell hits gives this kill credit (SmartAI)
    uint32 companion = 0;            // 6-10 questcompanion: the spell calls up this companion (not an objective); used again when ours is gone
};

struct BotLifeGrindSpot
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    uint16 zone = 0;
    uint32 faction = 0;              // faction template of the creature at this spot (0 = farm spot)
    uint32 teamDisabled = 0;         // farm spots only (Team value, 0 = both)
};

struct BotLifeTownSpot
{
    uint16 map = 0;
    uint16 zone = 0;
    float x = 0.0f, y = 0.0f, z = 0.0f;
    uint32 faction = 0;              // faction template of the NPC standing there
    uint8 band = 0;                  // 0 capitals, 1 Shattrath, 2 Dalaran, 3 Pandaria shrines
};

struct BotLifeZoneLevels
{
    uint8 low = 0;                   // ~10th percentile of grindable creature levels
    uint8 high = 0;                  // ~90th percentile
};

struct BotLifeQuestPlan
{
    bool supported = false;
    std::unordered_set<uint32> targetCreatures;   // kill objectives + creatures that drop objective items
};

struct BotLifePendingChat
{
    uint32 at = 0;                   // getMSTime
    ObjectGuid bot;
    uint8 type = 0;                  // BotLifeChatType
    std::string text;
    ObjectGuid target;               // for emotes / whispers
    uint32 emote = 0;
};

enum BotLifePartyType : uint8
{
    BOTLIFE_PARTY_NONE = 0,
    BOTLIFE_PARTY_WORLD = 1,         // questing / grinding together in the open world
    BOTLIFE_PARTY_DUNGEON = 2,
    BOTLIFE_PARTY_RAID = 3
};

struct BotLifeInstanceSpawn
{
    uint32 spawnId = 0;
    uint32 entry = 0;
    uint32 spawnMask = 0;
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    bool boss = false;
};

struct BotLifeDungeon
{
    uint32 id = 0;                   // LfgDungeons.dbc
    uint32 map = 0;
    uint8 difficulty = 0;
    uint8 minLevel = 0;
    uint8 maxLevel = 0;
    bool raid = false;
    int32 faction = -1;              // -1 both, 0 horde, 1 alliance
    float x = 0.0f, y = 0.0f, z = 0.0f, o = 0.0f;
    uint32 bosses = 0;
    std::string name;
};

struct BotLifeBgTest
{
    uint32 bgType = 0;
    uint32 level = 0;
    uint32 until = 0;
};

struct BotLifeLocation
{
    uint32 map = 0;
    float x = 0.0f, y = 0.0f, z = 0.0f, o = 0.0f;
};

struct BotLifeParty
{
    uint8 type = BOTLIFE_PARTY_NONE;
    ObjectGuid leader;
    std::vector<ObjectGuid> members;               // including the leader
    uint32 formedAt = 0;
    uint32 until = 0;
    std::unordered_map<ObjectGuid, uint32> farSince;   // member -> ms since it is far from the leader

    // dungeon / raid
    int32 dungeon = -1;                                 // index in _dungeons
    std::unordered_map<ObjectGuid, BotLifeLocation> origin;
    uint32 wipes = 0;
    uint32 allDeadSince = 0;
    uint32 stuckCombatSince = 0;     // in combat while others are dead / outside
    uint32 lastKills = 0;
    uint32 lastKillTime = 0;
    uint32 lastBosses = 0;           // boss progress (partial runs)
    uint32 lastBossTime = 0;
};

enum BotLifeChatType : uint8
{
    BOTLIFE_CHAT_GUILD = 0,
    BOTLIFE_CHAT_SAY = 1,
    BOTLIFE_CHAT_EMOTE = 2,
    BOTLIFE_CHAT_ZONE = 3
};

// statistics (".botlife stats"), counted since startup / last reset
enum BotLifeCounter : uint8
{
    BLC_QUEST_ACCEPT = 0,
    BLC_QUEST_TURNIN,
    BLC_AB_UNSUPPORTED,      // quest in log that bot life cannot do
    BLC_AB_NOENDER,          // no reachable quest ender
    BLC_AB_NODEST,           // no objective spawn found
    BLC_AB_NOPROGRESS,       // no progress after several retargets
    BLC_AB_TIMEOUT,          // quest or state timeout
    BLC_TURNIN_FAIL,         // arrived, but no ender found / turn in refused
    BLC_TURNIN_TIMEOUT,      // did not reach the ender in time
    BLC_TURNIN_BAGS,         // reward did not fit, bags were cleared for it
    BLC_GIVER_NOACCEPT,      // arrived at quest giver, nothing accepted
    BLC_GIVER_TIMEOUT,
    BLC_LOOT_CORPSE,
    BLC_LOOT_ITEM,
    BLC_LOOT_GO,
    BLC_BAG_SELL,
    BLC_RELOCATE,
    BLC_STUCK,
    BLC_REST,
    BLC_KILL,
    BLC_LEVELUP,
    BLC_PARTY_FORMED,
    BLC_PARTY_DISBANDED,
    BLC_PARTY_SUMMON,
    BLC_PARTY_QUEST_SHARED,
    BLC_PARTY_QUEST_TURNIN,
    BLC_DUNGEON_START,
    BLC_DUNGEON_CLEARED,
    BLC_DUNGEON_TIMEOUT,
    BLC_DUNGEON_WIPEOUT,
    BLC_DUNGEON_ABORT,       // teleport refused / leader gone
    BLC_DUNGEON_BOSS,
    BLC_DUNGEON_KILL,
    BLC_DUNGEON_REZ,
    BLC_DUNGEON_WIPE,
    BLC_RAID_START,
    BLC_UNSTUCK,             // stuck while traveling, nobody watching: teleported to the destination
    BLC_GHOST_REVIVE,        // dead for too long: revived at the corpse
    BLC_ORPHAN_GROUP,
    BLC_MOUNT,
    BLC_DEATH,
    BLC_DEATH_BY_CREATURE,
    BLC_DEATH_BY_HIGHER,     // creature 3+ levels above the bot
    BLC_DEATH_BY_ELITE,
    BLC_DEATH_BY_GUARD,      // city guards / faction NPCs
    BLC_DEATH_BY_PLAYER,
    BLC_POTION,
    BLC_DUNGEON_STALLED,
    BLC_AVOID_CREATURE,
    BLC_TOWN_VISIT,
    BLC_DOOR_OPEN,
    BLC_QUEST_ENGAGE,        // bot life picked a quest creature and attacked it
    BLC_QUEST_ENGAGE_FAIL,
    BLC_BG_QUEUED,
    BLC_BG_JOINED,
    BLC_BG_CAPTURE,
    BLC_BG_LEFT,
    BLC_BG_FLAG,
    BLC_BG_FLAG_CAPTURE,
    BLC_AREATRIGGER,
    BLC_SELF_HEAL,             // flag picked up / returned / captured attempt
    BLC_REPAIR,
    BLC_GUILD_CREATED,
    BLC_GUILD_JOIN,
    BLC_PANDAREN_FACTION,
    BLC_GBANK_GOLD,
    BLC_GBANK_ITEM,
    BLC_AH_POST,
    BLC_AH_BUY,
    BLC_GEAR_FIX,
    BLC_GEAR_UPGRADE,
    BLC_DEATH_RELOCATE,
    BLC_PROFESSION_SET,
    BLC_GATHER_NODE,
    BLC_GATHER_SKIN,
    BLC_AH_POST_MAT,
    BLC_TANK_SHIELD,
    BLC_BAGS_GIVEN,
    BLC_STRANDED_OUT,
    BLC_REBALANCE,
    BLC_CAST_CALL,
    BLC_CAST_STRICT_FAIL,
    BLC_CAST_MOVING,
    BLC_CAST_PREPARED,
    BLC_CAST_TIMED,
    BLC_GBANK_SUPPLY,
    BLC_GBANK_EQUIP,
    BLC_GBANK_TREASURE,
    BLC_GBANK_TAB_BOUGHT,
    BLC_BANKER_PICKED,
    BLC_BANKER_HOME,
    BLC_BANKER_WITHDRAW,
    BLC_BANKER_VENDOR,
    BLC_BANKER_GOLD,
    BLC_MAIL_GOLD,
    BLC_LFG_BOT_QUEUED,
    BLC_LFG_SHORT,
    BLC_LFG_MASTER,
    BLC_PHANTOM_COMBAT_CLEARED,
    BLC_CRAFT,                 // crafting professions: craft cast started
    BLC_CRAFT_FAIL,
    BLC_RECIPE_LEARNED,
    BLC_PROFESSION_SWAP,
    BLC_BANKER_SORT,
    BLC_LFG_LEAD,
    BLC_TALENTS,
    BLC_EVENT_GOSSIP,
    BLC_KILL_GATE,
    BLC_CRAFT_SUPPLY,          // reagent stacks a crafter took from the guild bank
    BLC_GUILD_REPAIR,          // repairs paid by the guild bank
    BLC_GBANK_RESORT,          // bank items the banker moved to the tab of their kind
    BLC_REFINE,                // stacks milled / prospected, items disenchanted
    BLC_ENCHANT_SCROLL,        // enchantment cast on a vellum
    BLC_FISH_CAST,
    BLC_FISH_CATCH,
    BLC_HEROIC_START,
    BLC_DAILY_TURNIN,
    BLC_DIG_SURVEY,            // archaeology
    BLC_DIG_FIND,
    BLC_DIG_SOLVE,
    BLC_QUEST_BAD_SKIP,        // quest not accepted / dropped because the bots keep failing it
    BLC_QUEST_ROAM,            // moved on to another spawn of the quest (nothing left at this one)
    BLC_QUEST_SKIP,            // a quest the bot cannot do counts as done (no reward), the chain goes on
    BLC_VENDOR_GEAR,           // an armor piece bought at a vendor for an empty, grey or white slot
    BLC_DK_CHAIN_GIVEUP,       // a death knight stalled in its starting chain moves on
    BLC_DK_PORTAL,             // an Acherus teleport pad / gryphon / portal taken
    BLC_DK_EYE,                // Eye of Acherus taken for Death Comes From On High
    BLC_DK_EYE_SIPHON,         // a building of New Avalon siphoned through the eye
    // dungeon leader opened a closed door the encounter script did not open (etc, see history)
    BLC_MAX
};

class BotLifeMgr
{
public:
    static BotLifeMgr* instance();

    void LoadConfig();
    void LoadCaches();
    bool IsEnabled() const { return _enabled && _loaded; }

    void Count(BotLifeCounter c, uint32 n = 1) { _counters[c].fetch_add(n, std::memory_order_relaxed); }
    // public entry point for the LFGMgr::FillMissingRoles hook (a plain function pointer needs a
    // free-function trampoline; this is the actual member with access to everything it needs).
    void FillLfgRolesSync(Player* player, uint32 queueId, std::set<uint32> const& dungeonIds);
    // ".botlife casts": spells the bot AI actually started (prepared), per spell, since the last read
    void CountCast(uint32 spellId) { std::lock_guard<std::mutex> g(_castStatsLock); ++_castStats[spellId]; }
    void CountStrictFail(uint32 spellId, uint32 code) { std::lock_guard<std::mutex> g(_castStatsLock); ++_strictStats[uint64(code) * 1000000 + spellId]; }
    void PrintCastStats(ChatHandler* handler);
    void PrintMapStats(ChatHandler* handler);
    void PrintCreatureStats(ChatHandler* handler, uint32 entry);   // ".botlife creature <entry>"
    void PrintQuestCoverage(ChatHandler* handler);                  // ".botlife questcoverage"
    void PrintStats(ChatHandler* handler);
    void PrintBot(ChatHandler* handler, std::string const& name);
    std::string SampleQuestBot(uint32 minAgeMs);
    void ResetStats();
    void ReloadConfig() { LoadConfig(); }
    void TestBattleground(ChatHandler* handler, uint32 bgType, uint32 level);
    void StartCastDiag(int32 count) { _castDiagLeft.store(count, std::memory_order_relaxed); }   // diag
    bool HunterAiEnabled() const { return _hunterAi; }
    void StartAggroDiag(int32 count) { _aggroDiagLeft.store(count, std::memory_order_relaxed); }
    void StartRangeTest(int32 count, uint32 entry = 0, uint32 maxLevel = 0);
    void StartPathProbe(uint32 map, float x, float y, float z);
    void StartTestLevel(uint32 level, int32 count);   // test lab, raise bots to a level
    // walkers - one test bot per starting area works through its quests, every step a WALK line
    std::string WalkAdd(std::string const& name, std::string const& sorts);
    std::string WalkRemove(std::string const& name);
    std::string WalkClear(std::string const& name);   // 6-10 walkclear
    std::string WalkStatus();
    // dungeon finder test with five bots (holiday dungeons)
    std::string LfgTestQueue(uint32 dungeonId);
    std::string LfgTestStatus();
    bool IsLfgTestBot(ObjectGuid guid) const;
    bool LfgTestLeadTick(Player* bot, BotLifeInfo& t, uint32 now);
    bool IsWalker(Player* bot) const;
    bool SpawnInPhase(Player* bot, BotLifeSpawn const& spawn) const;
    bool ApproachCreditSpawned(uint32 credit) const;
    // gossipMount: a gossip puts the bot on it; followerEntry/Count: the ability ropes in that many
    // followers; deliverEntry: the NPC the bot then steers the vehicle to
    struct VehicleQuest { uint32 questId; uint32 vehicleEntry; uint32 spellId; std::vector<uint32> targets; float range; bool mount;
        bool gossipMount = false; uint32 followerEntry = 0; uint32 followerCount = 0; uint32 deliverEntry = 0;
        std::vector<uint32> visit; uint32 summonItem = 0; };   // creatures to steer to; the item that calls the vehicle up
    static std::vector<VehicleQuest> const& VehicleQuests();
    static VehicleQuest const* DriveQuest(uint32 questId);
    static bool VisitQuest(uint32 questId);
    bool VehicleDrive(Player* bot, BotLifeInfo& t, Unit* base, VehicleQuest const& q, uint32 now);
    bool VehicleVisit(Player* bot, BotLifeInfo& t, Unit* base, VehicleQuest const& q, uint32 now);
    bool VehicleQuestMount(Player* bot, BotLifeInfo& t, uint32 now);
    bool VehicleQuestAction(Player* bot, BotLifeInfo& t, uint32 now);
    bool WalkAllows(Player* bot, Quest const* quest) const;
    void WalkTick(Player* bot, BotLifeInfo& t, uint32 now);
    bool EnsureWeapon(Player* bot);
    bool EnsureGear(PlayerbotAI* botAI);
    void EnsureBags(Player* bot);
    void EquipBagUpgrades(Player* bot);
    void VendorGear(Player* bot);
    void DeathKnightWeapon(Player* bot);          // Runed Soulblade + runeforging
    bool DeathKnightChainOpen(Player* bot) const;   // the starting chain in the Scarlet Enclave
    bool ChaseWalkingNpc(Player* bot, BotLifeInfo& t);   // a giver / ender on a path
    void DeathKnightChainWatch(Player* bot, BotLifeInfo& t, uint32 now);
    bool DeathKnightEye(Player* bot, BotLifeInfo& t, uint32 now);   // Death Comes From On High
    bool EquipWeaponUpgrade(Player* bot, Item* item, uint16 dest, Item* current);   // weapon kinds
    bool HasWeakArmorSlot(Player* bot) const;     // an armor slot empty or grey / white
    // gathering professions (BotLifeProfession.cpp)
    void LoadProfessionConfig();
    void EnsureProfessions(Player* bot);
    bool GatherBusiness(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    bool CraftBusiness(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    bool FishBusiness(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    bool StartDig(Player* bot, BotLifeInfo& t, uint32 now);              // archaeology
    bool DigBusiness(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    bool TryEventGossip(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    bool GossipApproachTimedOut(Player* bot, BotLifeInfo& t, uint32 key, std::string const& name, uint32 now);
    void MasterQuestSync(Player* bot, Player* master, BotLifeInfo& t, uint32 now);   // bots without a main hand weapon get one (factory leaves ~45% empty)
    void PrintGuilds(ChatHandler* handler);             // guild life (BotLifeGuild.cpp)
    void QueueTownBusiness(ObjectGuid guid);

    // bot AI hook: returns true when this system handled the bot this tick
    bool UpdateBot(PlayerbotAI* botAI, uint32 elapsed);

    // cross-thread-safe bot actions. World-thread formation code queues; the bot runs them on its own
    // map thread from RunPendingActions (called every tick in UpdateAIInternal, before the minimal gate).
    void QueueTeleport(Player* member, uint32 map, float x, float y, float z, float o);
    void QueueReset(Player* member);
    void QueueCombatStop(Player* member);
    bool RunPendingActions(PlayerbotAI* botAI);

    // GrindTargetValue helper: is this unit useful for the bot's current quest
    bool IsQuestTarget(Player* bot, Unit* unit);
    bool IsAvoidedTarget(Player* bot, Unit* unit);

    // script hooks
    void OnCreatureKill(Player* killer, Creature* killed);
    void OnKilledByCreature(Creature* killer, Player* killed);
    void OnKilledByPlayer(Player* killer, Player* killed);
    void OnLevelChanged(Player* player, uint8 oldLevel);
    void OnQuestRewarded(Player* player, Quest const* quest);
    void OnRealPlayerLogin(Player* player);
    void OnRealPlayerLogout(Player* player);
    void OnGuildChat(Player* player, std::string const& msg, Guild* guild);
    void WorldUpdate(uint32 diff);

private:
    BotLifeMgr() = default;

    // --- life (BotLife.cpp)
    void Think(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    void DecideNext(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    bool Act(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    bool ActState(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    void SetState(Player* bot, BotLifeInfo& t, BotLifeState state, uint32 now, uint32 duration);
    void SetDest(BotLifeInfo& t, uint32 map, float x, float y, float z, float arriveDist);
    bool Arrived(Player* bot, BotLifeInfo const& t) const;
    bool Travel(Player* bot, BotLifeInfo& t, uint32 now);
    void BuildPath(Player* bot, BotLifeInfo& t);
    bool HasGrindTarget(PlayerbotAI* botAI);
    bool RealPlayerNear(Player* bot, float dist) const;
    void CheckAreaTriggers(Player* bot, BotLifeInfo& t, uint32 now);
    void LoadAreaTriggers();
    void EnsureRiding(Player* bot);
    bool MountUp(Player* bot);
    void Dismount(Player* bot);
    bool HandleDeath(Player* bot, BotLifeInfo& t, uint32 now);
    void CombatPotion(Player* bot, BotLifeInfo& t, uint32 now);
    bool CombatSelfHeal(Player* bot, BotLifeInfo& t, uint32 now);
    bool TravelBlockedByTarget(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);

    bool FindGrindSpot(Player* bot, BotLifeGrindSpot& out, bool anyZone);
    bool ZoneFitsLevel(Player* bot) const;
    bool RelocateForLevel(Player* bot);
    bool HomeStart(Player* bot, uint32& map, float& x, float& y) const;   // start area of the race

    // town visits
    bool StartTownVisit(Player* bot, BotLifeInfo& t, uint32 now);
    bool NeedsRepair(Player* bot) const;
    bool PickTownSpot(Player* bot, BotLifeInfo& t, bool sameZone);
    void EndTownVisit(Player* bot, BotLifeInfo& t, uint32 now);

    // quests
    BotLifeQuestPlan const& GetPlan(Quest const* quest);
    BotLifeQuestPlan const* FindPlan(uint32 questId);   // the only lookup of _plans
    bool IsQuestSupported(Quest const* quest, char const** why = nullptr);   // why: the reason when it is not
    bool QuestLevelOk(Player* bot, Quest const* quest) const;
    bool QuestDoable(Player* bot, Quest const* quest);
    uint32 ActiveQuestCount(Player* bot) const;
    bool FindQuestGiver(Player* bot, BotLifeInfo& t, BotLifeSpawn& out);
    bool HasAvailableQuest(Player* bot, BotLifeInfo& t, uint32 entry, bool go = false);
    uint32 AcceptQuests(Player* bot, Creature* npc, BotLifeInfo& t, uint32 now);
    bool FindQuestEnder(Player* bot, uint32 questId, BotLifeSpawn& out);
    bool FindQuestEnderNpc(Player* bot, uint32 questId, BotLifeSpawn& out);   // (batch 11i: the NPCs only)
    bool PickObjectiveDest(Player* bot, BotLifeInfo& t, Quest const* quest);
    bool PickRoamDest(Player* bot, BotLifeInfo& t, Quest const* quest);   // on to another spawn
    bool TurnIn(Player* bot, WorldObject* giver, uint32 questId);   // (batch 11i: an NPC or a quest object)
    uint32 AcceptQuestsGo(Player* bot, GameObject* go, BotLifeInfo& t, uint32 now);   // batch 11i: 
    void AbandonQuest(Player* bot, BotLifeInfo& t, uint32 questId, char const* reason, bool record = true);   // reason -> tt_botlife_quest_fail
    bool QuestElsewhere(Player* bot, uint32 questId) const;
    bool CanSkipQuest(Player* bot, Quest const* quest) const;
    bool SkipQuest(Player* bot, Quest const* quest);
    uint32 QuestProgressValue(Player* bot, Quest const* quest) const;
    bool UseQuestObject(Player* bot, BotLifeInfo& t, uint32 now);
    bool EngageQuestCreature(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    void FindQuestObject(Player* bot, BotLifeInfo& t);
    bool NearestSpawn(Player* bot, std::vector<uint32> const& entries, bool gameObjects, BotLifeSpawn& out, float maxDist);
    bool NearestQuestTrigger(Player* bot, uint32 questId, BotLifeSpawn& out) const;
    bool OwnSideCreature(Player* bot, uint32 entry) const;   // an NPC of the bot's own faction (a target for the other side only)
    bool InteractQuestCreature(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);   // talk / use item / spell
    bool BuyQuestItem(Player* bot, BotLifeInfo& t, uint32 now);                    // an objective item a vendor sells
    bool UseQuestItem(Player* bot, BotLifeInfo& t, uint32 now);                    // the item of the quest makes / completes
    bool UseCompanionItem(Player* bot, BotLifeInfo& t, uint32 now);   // 6-10 questcompanion2
    bool ClickEventCreature(Player* bot, BotLifeInfo& t, uint32 now);   // 8-10 eventclick
    bool StartEventCreature(Player* bot, BotLifeInfo& t, uint32 now);   // 8-10 eventstart
    bool AddQuestUseSpots(Quest const* quest, uint32 makes, std::vector<uint32>& creatures, std::vector<uint32>& objects, Player* bot = nullptr) const;
    bool AddQuestHelperSpots(Quest const* quest, uint32 credit, std::vector<uint32>& creatures, std::vector<uint32>& objects) const;   // batch 11j
    bool HasQuestHelper(Quest const* quest, uint32 credit) const;   // batch 11j
    void AddItemVendors(Player* bot, uint32 item, std::vector<uint32>& creatures) const;
    void TalkTo(Player* bot, Creature* npc);

    // loot / bags / rest
    bool DoLoot(Player* bot, BotLifeInfo& t, uint32 now, float maxDist = 40.0f, uint32 maxTime = 20000);   // (batch 11g: reach / time)
    void LootCorpse(Player* bot, Creature* creature, bool area = true);   // (batch 11g: area loot as in MoP)
    void ManageBags(Player* bot, uint32 minFree = 4, bool sellMaterials = true);
    bool BagsFullOfMaterials(Player* bot) const;
    bool DoRest(Player* bot, BotLifeInfo& t, uint32 now);

    // --- parties (BotLifeParty.cpp)
    void PartyUpdate(uint32 now);                                   // world thread
    void FormWorldParties(uint32 now, uint32 wanted);
    void DisbandOrphanGroups();
    bool CreateParty(Player* leader, std::vector<Player*> const& members, uint8 type, uint32 durationMs);
    void DisbandParty(uint32 groupLow, BotLifeParty& party);
    bool MaintainInstanceParty(Group* group, BotLifeParty& party, Player* leader, uint32 now);   // true = finished
    void RecordDungeonRun(BotLifeDungeon const& d, BotLifeParty const& party, Player* leader, char const* result, uint32 now);

    // --- dungeons / raids (BotLifeDungeon.cpp)
    void LoadDungeons();
    void FormInstanceParties(uint32 now, bool raid);
    bool DungeonLeaderUpdate(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);   // map thread
    Creature* SpawnCreature(Map* map, uint32 spawnId) const;
    // MoP event kill-gate (Stormstout e.d.) - nearest living gate mob while the boss stays sealed
    BotLifeInstanceSpawn const* PickKillGate(Player* bot, BotLifeInfo const& t, Map* map, std::vector<BotLifeInstanceSpawn> const& spawns, uint32 now, Creature*& creature);
    // targets outside the spawn list, sealed bosses, the state of a run at its end
    Creature* PickUnlistedTarget(Player* bot, BotLifeInfo& t, uint32 now, uint32 tickDelta);
    bool EngageUnlistedTarget(PlayerbotAI* botAI, BotLifeInfo& t, Creature* creature, uint32 now);
    bool ScenarioLeadTick(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    bool VisitSealedBoss(Player* bot, BotLifeInfo& t, Map* map, uint32 diffBit, uint32 now, uint32 tickDelta);
    void LogRunEnd(BotLifeDungeon const& d, BotLifeParty const& party, Player* leader, char const* result);
    void SkipDungeonTarget(Player* bot, BotLifeInfo& t, char const* reason);
    uint32 OpenDoorsNear(Player* bot, float range);
    bool DungeonTargetValid(Player* bot, BotLifeInfo const& t, BotLifeInstanceSpawn const& s, uint32 diffBit, Creature*& creature) const;
    bool PartyFollowerUpdate(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);   // map thread
    bool PartyLeaderWait(Player* bot, BotLifeInfo& t, uint32 now);
    void PartyShareQuest(Player* leader, Quest const* quest, Creature* npc);
    void PartyTurnIn(Player* leader, Creature* npc, uint32 questId);
    void PartyShareKill(Player* killer, Creature* killed);
    template <class F> void ForEachPartyMemberNear(Player* bot, float dist, F&& fn);

    // --- battlegrounds (BotLifeBattleground.cpp)
    void BattlegroundUpdate(uint32 now);                            // world thread
    bool QueueBotForBattleground(Player* bot, uint32 queueType, uint32 bgType);
    bool BattlegroundBotUpdate(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);   // map thread

    // --- social (BotLifeSocial.cpp)
    void LoadTexts();
    void SocialTick(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    std::string PickText(std::string const& category, Player* bot, Player* other = nullptr);
    std::string Fill(std::string text, Player* bot, Player* other);
    void Queue(uint32 delayMs, Player* bot, uint8 type, std::string const& text, ObjectGuid target = ObjectGuid::Empty, uint32 emote = 0);
    void Deliver(BotLifePendingChat const& chat);
    bool SayInZoneChannel(Player* bot, std::string const& text);
    void DoTextEmote(Player* bot, uint32 textEmote, Unit* target);
    Player* RandomGuildBot(uint32 guildId, Player* exclude = nullptr, uint32 nearLevel = 0);
    bool GuildHasRealPlayerOnline(uint32 guildId) const;
    void GuildChatter(uint32 now);
    void ZoneChatter(uint32 now);
    bool CanBroadcast(uint32 now, uint32 minGapMs);
    void BroadcastLoot(Player* bot, uint32 itemId);
    void UpdateCalendar();
    void StartGuildEvent(Player* creator, uint64 eventId, std::vector<ObjectGuid> const& signedUp);

    // --- state
    bool _loaded = false;
    bool _enabled = true;
    bool _travel = true;
    bool _quests = true;
    bool _loot = true;
    bool _rest = true;
    bool _chat = true;
    bool _emotes = true;
    bool _zoneChat = true;
    bool _guildEvents = true;
    bool _hunterAi = false;
    // guild life (BotLifeGuild.cpp, world thread)
    void LoadGuildConfig();
    void GuildUpdate(uint32 now);
    void PandarenFactionChoice(std::vector<Player*> const& bots, uint32 (&teamCount)[2]);
    void ManageBotGuilds(std::vector<Player*> const& bots, uint32 now);
    void SetupBotGuild(Guild* guild, Player* leader);
    bool IsBotGuild(Guild const* guild) const;
    void ProcessTownBusiness();
    void GuildBankBusiness(Player* bot);
    // guild bank tabs + one banker per bot guild (BotLifeGuild.cpp)
    void LoadBankerSpots();
    void ManageGuildBankers(std::vector<Player*> const& bots);
    void EnsureGuildBankLayout(Guild* guild, Player* banker);
    bool IsBanker(ObjectGuid guid);
    bool BankerUpdate(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);   // map thread
    void QueueBankerBusiness(ObjectGuid guid, uint8 step);
    void BankerBusiness(Player* bot, uint8 step);                        // world thread
    void CollectMailMoney(Player* bot);
    struct BankerSpot { uint32 map = 0; float x = 0.0f, y = 0.0f, z = 0.0f; };
    BankerSpot _bankerSpots[2][3];                                       // alliance/horde: vault, auctioneer, mailbox
    bool _bankerSpotsOk[2] = { false, false };
    bool _guildBankers = true;
    std::mutex _bankerLock;
    std::unordered_set<ObjectGuid> _bankerGuids;                         // map threads read, world thread writes
    std::unordered_map<uint32, std::vector<ObjectGuid>> _guildBanker;    // world thread only 
    bool _naturalProgression = false;                                    // no factory gear
    void RecordBossKill(Creature* killed);                               // for the armory
    std::unordered_set<uint32> _guildLayoutDone;                         // world thread only
    std::vector<std::pair<ObjectGuid, uint8>> _bankerBusiness;           // under _businessLock
    std::vector<ObjectGuid> _craftSupply;                                // under _businessLock 
    void QueueCraftSupply(ObjectGuid guid);
    void CraftSupply(Player* bot);                                       // BotLifeProfession.cpp, world thread
    bool GoToForge(Player* bot, BotLifeInfo& t);                         // BotLifeProfession.cpp 
    // dungeon finder fill for real players (BotLifeLfg.cpp, world thread)
    void LfgUpdate(uint32 now);
    bool IsLfgBot(ObjectGuid guid) const;
    struct LfgBot { ObjectGuid player; uint8 role = 0; uint32 since = 0; };
    std::unordered_map<ObjectGuid, LfgBot> _lfgBots;                     // world thread only
    bool _lfgFill = true;
    uint32 _lfgDelaySeconds = 20;
    uint32 _nextLfgUpdate = 0;
    void LoadAuctionConfig();              // BotLifeAuction.cpp
    void AuctionBusiness(Player* bot, bool banker = false);
    bool _auctions = true;
    uint32 _auctionPostPerVisit = 2;
    uint32 _auctionMaxPerBot = 8;
    uint32 _auctionBuyChance = 30;
    void SeedBattlePetAuctions();          // caged battle pets on the auction house
    uint32 _auctionBattlePets = 150;       // stock to keep (all houses together), 0 = off
    uint32 _nextPetSeed = 0;
    bool _botGuilds = true;
    bool _pandarenFaction = true;
    bool _pandarenIsle = true;       // neutral pandaren quest on the Wandering Isle until level 10
    bool _guildBank = true;
    uint32 _guildSize = 160;
    uint32 _guildJoinLevel = 10;        // BotLife.GuildJoinLevel / GuildFoundLevel / ExtraBotGuildSize
    uint32 _guildFoundLevel = 30;
    uint32 _extraGuildSize = 175;
    uint32 _guildShare = 80;
    uint32 _guildBankGoldPct = 5;
    uint32 _guildBankGoldCap = 20;
    uint32 _guildBankFreeSlots = 30;       // free slots the banker keeps per bot tab (of 98)
    // the bots repair on the guild's account (the Guild Repairs achievements count), up to
    // _guildRepairGold a day per member and only while the bank holds more than _guildRepairMinBank gold
    bool _guildRepair = true;
    uint32 _guildRepairGold = 25;
    uint32 _guildRepairMinBank = 2000;
    void RepairInTown(Player* bot);        // BotLifeGuild.cpp, world thread
    std::vector<std::string> _guildNames[2];
    std::vector<std::string> _extraBotGuilds;   // named guilds (e.g. a player's own) treated like a bot guild too
    uint32 _nextGuildUpdate = 0;
    std::mutex _businessLock;
    std::shared_mutex _planLock;   // _plans is filled from all map threads; every lookup goes through FindPlan
    // quests the bots keep failing, remembered across restarts (tt_botlife_quest_record). The set is
    // replaced as a whole on the world thread and read with atomic_load on the map threads.
    std::shared_ptr<std::unordered_set<uint32> const> _badQuests;
    std::shared_ptr<std::unordered_map<ObjectGuid::LowType, std::set<int32>> const> _walkers;
    std::shared_ptr<std::unordered_set<ObjectGuid> const> _lfgTestBots;
    std::atomic<uint32> _lfgTestDungeon{0};   // bot -> quest zones
    uint32 _nextBadQuestLoad = 0;
    bool _questLearning = true;
    void LoadBadQuests();
    bool IsBadQuest(uint32 questId) const;
    void RecordQuest(uint32 questId, bool success);
    std::vector<ObjectGuid> _townBusiness;
    bool _relocate = true;
    uint32 _homeStartLevel = 10;     // batch 11h: below this level a bot stays near the start area of its race
    bool _townVisits = true;
    uint32 _townMinutesMin = 40;           // between visits
    uint32 _townMinutesMax = 90;
    bool _debug = false;
    bool _partiesEnabled = true;
    uint32 _partyShare = 25;               // percent of the random bots in world parties
    uint32 _partyMinutesMin = 30;
    uint32 _partyMinutesMax = 75;
    bool _dungeonsEnabled = true;
    uint32 _dungeonParties = 6;            // concurrent dungeon groups
    uint32 _dungeonMinutes = 50;
    std::unordered_set<uint32> _dungeonExcludeMaps;   // dungeons bots cannot finish alone (gossip-gated event/boss)
    bool _raidsEnabled = true;
    uint32 _raidParties = 1;
    uint32 _raidSize = 10;
    uint32 _raidMinutes = 75;
    uint32 _maxQuests = 3;
    uint32 _questTimeout = 25 * 60 * 1000;
    uint32 _guildChatInterval = 150;       // seconds (average, unsolicited)
    uint32 _zoneChatInterval = 240;        // seconds (average)
    uint32 _calendarSignups = 20;
    uint32 _eventRaidSize = 20;

    std::atomic<uint64> _counters[BLC_MAX] = {};
    std::mutex _castStatsLock;
    std::unordered_map<uint32, uint32> _castStats;
    std::unordered_map<uint64, uint32> _strictStats;
    std::atomic<int32> _castDiagLeft{0};
    std::atomic<int32> _aggroDiagLeft{0};
    std::atomic<int32> _rangeTestLeft{0};
    std::atomic<bool> _pathProbePending{false};   // ".botlife pathprobe"
    std::atomic<int32> _testLevelLeft{0};          // ".botlife testlevel"
    std::atomic<uint32> _testLevel{0};
    bool TestLevelBot(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    uint32 _pathProbeMap = 0;
    float _pathProbeX = 0.0f, _pathProbeY = 0.0f, _pathProbeZ = 0.0f;
    void PathProbe(Player* bot);
    uint32 _rangeTestEntry = 0;
    uint32 _rangeTestMaxLevel = 255;
    std::vector<std::array<float, 4>> _rangeTestSpawns;   // map, x, y, z
    void RangeTest(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now);
    void AggroDiag(PlayerbotAI* botAI);
    void CastDiag(PlayerbotAI* botAI);
    uint32 _statsSince = 0;

    // caches (read-only after LoadCaches)
    std::unordered_map<uint32, std::vector<BotLifeSpawn>> _creatureSpawns;   // entry -> spawns
    std::unordered_map<uint32, std::vector<BotLifeSpawn>> _goSpawns;         // entry -> spawns
    std::unordered_map<uint32, std::vector<BotLifeSpawn>> _questGivers;      // map -> spawns
    std::unordered_map<uint32, std::vector<uint32>> _killCreditSources;   // credit entry -> creature entries
    std::unordered_map<uint32, std::vector<uint32>> _itemCreatureSources; // item -> creature entries
    std::unordered_map<uint32, std::vector<uint32>> _itemClickSources;    // item -> creatures a click on gives it (batch 11o)
    std::unordered_map<uint32, std::vector<BotLifeCreditSource>> _itemTalkSources;   // item -> NPCs whose script hands it out (batch 11y)
    std::set<uint32> _gossipItemObjects;   // objects whose gossip option hands an objective item out (batch 11z2)
    std::unordered_map<uint32, std::vector<uint32>> _itemGoSources;       // item -> gameobject entries
    std::unordered_map<uint32, std::vector<uint32>> _itemVendorSources;   // item -> vendors that sell it for money 
    std::unordered_map<uint32, std::vector<uint32>> _focusObjects;        // spell focus -> gameobject entries 
    std::unordered_map<uint32, std::vector<BotLifeQuestUse>> _questUse;   // quest -> its item to use 
    std::unordered_map<uint32, std::vector<BotLifeCreditSource>> _questEventSources;   // quest without objectives -> NPCs whose event completes it (batch 11q)
    std::unordered_map<uint32, std::vector<uint32>> _questEventObjects;                 // quest without objectives -> objects whose use completes it (batch 11q)
    void QuestEventSpots(uint32 questId, std::vector<uint32>& creatures, std::vector<uint32>& objects) const;   // batch 11q
    std::unordered_map<uint32, std::vector<uint32>> _creditObjects;      // credit -> objects whose use gives it 
    std::unordered_map<uint32, std::vector<uint32>> _equipCredits;       // credit -> items whose equip spell gives it (batch 11m)
    std::unordered_map<uint32, std::vector<uint32>> _equipItemChests;    // such an item -> chests it is looted from (batch 11m)
    void AddEquipChests(Player* bot, uint32 credit, std::vector<uint32>& objects) const;   // batch 11m
    std::unordered_map<uint32, std::vector<uint32>> _spellTools;         // spell of a credit -> items that cast it on use (batch 11t)
    void AddToolDropSpots(Player* bot, uint32 credit, std::vector<uint32>& creatures) const;   // batch 11t
    bool EquipQuestItem(Player* bot, BotLifeInfo& t, uint32 now);                      // batch 11m
    std::unordered_map<uint32, std::vector<uint32>> _approachCredits;   // credit -> creatures whose script gives it to whoever comes near
    std::unordered_map<uint32, std::vector<BotLifeSpawn>> _questTriggers;  // quest -> area triggers that give its explore credit
    std::unordered_map<uint32, std::vector<BotLifeCreditSource>> _creditSources;   // credit entry -> spawned creatures that give it (SmartAI)
    std::unordered_set<uint32> _gossipTalk;   // gossip NPCs where a talk can do something (options, SAI gossip, C++)
    std::unordered_map<uint32, std::vector<uint32>> _questLeadsIn;   // quest -> quests whose NextQuestID is it
    std::unordered_map<uint32, std::vector<std::vector<BotLifeGrindSpot>>> _grind; // map -> [level] -> spots
    std::unordered_map<uint32, BotLifeZoneLevels> _zoneLevels;              // zone -> level band
    std::vector<BotLifeTownSpot> _townSpots;
    std::unordered_map<uint64, std::vector<uint32>> _triggerCells;         // (map, cell x, cell y) -> area trigger ids
    std::unordered_map<uint32, BotLifeQuestPlan> _plans;                     // lazily filled (map thread)
    std::unordered_map<uint32, std::vector<BotLifeInstanceSpawn>> _instanceSpawns; // map -> hostile spawns
    std::vector<BotLifeDungeon> _dungeons;
    // a bad mark runs out (dungeon id -> unix time it ends). One run without a boss took a dungeon out of
    // rotation for good: 23 dungeons were gone in two days (Deadmines: 41 of 42 runs with a boss) and every raid.
    std::unordered_map<uint32, uint32> _badDungeons;
    uint32 _badDungeonHours = 3;                                            // a dungeon the bots have beaten before
    uint32 _badDungeonDays = 3;                                             // one they never got a boss in
    bool IsBadDungeon(uint32 id) const;
    uint32 BadDungeonUntil(uint32 id, uint32 markedAt) const;
    std::unordered_set<uint32> _dungeonFocus;                               // dungeon ids picked first (under repair)
    uint32 _dungeonFocusChance = 0;
    std::unordered_set<uint32> _dungeonFocusMaps;                           // their maps (death log)
    std::unordered_map<uint32, std::vector<BotLifeInstanceSpawn>> _gateSpawns;       // map -> kill-gate mobs, neutral ones too
    std::unordered_map<uint32, std::vector<BotLifeInstanceSpawn>> _sealedBossSpawns; // map -> bosses that are not a pull target at spawn
    std::unordered_set<uint32> _instanceSpawnIds;                           // every spawn id in _instanceSpawns
    bool HasKillGate(uint32 map) const { return _gateSpawns.count(map) > 0; }
    std::unordered_map<uint32, std::pair<uint32, uint32>> _dungeonRecord;  // dungeon -> (runs without a boss, successes), world thread
    void MarkBadDungeon(BotLifeDungeon const& d, char const* reason);
    std::unordered_set<uint32> _bossEntries;                                // encounter credit / boss scripts
public:
    bool IsBossEntry(uint32 entry) const { return _bossEntries.count(entry) > 0; }
private:                                // world thread: entry refused

    // texts
    std::unordered_map<std::string, std::vector<std::string>> _texts;

    // social runtime (guarded by _lock)
    std::mutex _lock;
    std::vector<BotLifePendingChat> _pending;
    std::unordered_map<uint64, uint32> _realSocialCooldown;               // real player guid -> ms
    uint32 _nextGuildChat = 0;
    uint32 _nextZoneChat = 0;
    uint32 _nextBroadcast = 0;
    uint32 _nextCalendar = 0;
    uint32 _worldTimer = 0;
    bool _professions = true;
    bool _fishing = true;
    uint32 _fishingMinutes = 45;           // between the fishing sessions of a bot (two thirds to four thirds of it)
    bool _archaeology = true;
    uint32 _digMinutes = 60;               // between the dig trips of an archaeologist
    bool _dailyQuests = true;              // daily quests are quests too
    bool _skipQuests = true;               // a quest a bot cannot do counts as done so that its chain goes on
    bool _dkChain = true;                  // death knights play their starting chain
    bool _heroicDungeons = true;           // heroic dungeons in the rotation of the bot parties
    uint32 _craftsPerVisit = 4;
    std::unordered_map<uint32, std::pair<uint32, uint32>> _guildDepositRate;   // guild -> (window start ms, deposits)
    std::unordered_map<uint16, std::vector<std::pair<uint32, uint16>>> _craftRecipes;   // skill -> (craft spell, required skill), from npc_trainer
    // bots per continent (0, 1, 530, 571, 870), counted on the world thread every 30 s while the maps are idle;
    // RelocateForLevel prefers the less crowded fitting continent (the busiest map sets the server tick)
    std::array<std::atomic<uint32>, 6> _mapPop = {};   // 0, 1, 530, 571, 870, 1064 (Isle of Thunder)
    uint32 _mapPopTimer = 0;
    uint32 MapPopulation(uint32 mapId) const;
    void AdjustMapPopulation(uint32 mapId, int32 delta);
    std::unordered_set<uint64> _startedEvents;

    // parties (world thread only)
    std::unordered_map<uint32, BotLifeParty> _parties;                    // group low guid -> party
    uint32 _nextPartyUpdate = 0;
    uint32 _nextPartyForm = 0;

    // battlegrounds (world thread only)
    std::unordered_set<ObjectGuid> _bgBots;
    std::vector<BotLifeBgTest> _bgTests;
    bool _battlegrounds = true;
    bool _bgTestsActive = false;                                          // read by map threads (bool)
    // guild mates first when groups are formed; battlegrounds among the bots themselves
    bool _guildGroups = true;
    uint32 _bgAutoMinutes = 20;                                           // 0 = off; read by map threads
    uint32 _bgAutoMax = 2;
    uint32 _nextAutoBg = 0;
    std::unordered_set<uint64> _seenAnnouncements;
};

#define sBotLife BotLifeMgr::instance()

#endif
