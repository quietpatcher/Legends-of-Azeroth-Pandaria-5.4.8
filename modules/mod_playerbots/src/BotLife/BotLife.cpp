/*
 * Bot life: "bot life" for random bots - travel, grinding, questing, looting, resting.
 * Social behaviour (chat, emotes, guild events) lives in BotLifeSocial.cpp.
 */

#include "BotLife.h"

#include "Chat.h"
#include "PlayerbotSpec.h"

#include "Bag.h"
#include "BotFactory.h"
#include "RandomItemManager.h"
#include "Config.h"
#include "Creature.h"
#include "DatabaseEnv.h"
#include "DBCStores.h"
#include "GameObject.h"
#include "GameObjectAI.h"   // batch 11z2: 
#include "CellImpl.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "GameTime.h"
#include "Group.h"
#include "Item.h"
#include "Log.h"
#include "LootMgr.h"
#include "Map.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "PathGenerator.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "Playerbots.h"
#include "QuestDef.h"
#include "Random.h"
#include "RandomPlayerbotMgr.h"
#include "Timer.h"
#include "AreaTriggerPackets.h"
#include "CreatureAI.h"
#include "GossipDef.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "WorldPacket.h"
#include "WorldSession.h"

#include <algorithm>
#include <mutex>
#include <cmath>
#include <set>
#include <unordered_set>
#include <sstream>

namespace
{
    constexpr uint32 MAX_BOTLIFE_LEVEL = 93;
    constexpr float QUEST_AREA_RADIUS = 45.0f;
    constexpr float MAX_TRAVEL_DIST = 3000.0f;

    float Dist2d(float x1, float y1, float x2, float y2)
    {
        float dx = x1 - x2, dy = y1 - y2;
        return std::sqrt(dx * dx + dy * dy);
    }

    // AreaTable.team: 2 = Alliance territory, 4 = Horde territory (0 = contested/none)
    bool IsEnemyTerritory(Player* bot, uint32 zoneId)
    {
        if (!zoneId)
            return false;
        AreaTableEntry const* area = sAreaTableStore.LookupEntry(zoneId);
        if (!area)
            return false;
        if (bot->GetTeam() == ALLIANCE)
            return area->team == 4;
        return area->team == 2;
    }

    std::string JoinIds(std::vector<uint32> const& ids, size_t from, size_t to)
    {
        std::ostringstream out;
        for (size_t i = from; i < to; ++i)
        {
            if (i != from)
                out << ',';
            out << ids[i];
        }
        return out.str();
    }

    // global limit on level-relocation teleports (token bucket, world wide)
    uint32 relocateTokens = 20;
    uint32 relocateRefill = 0;
}

// Runeforging: Preparation For Battle
enum
{
    QUEST_DK_RUNEFORGING        = 12842,
    NPC_UNWORTHY_INITIATE       = 29519,
    GO_ACHERUS_RUNEFORGE        = 190557,
    SPELL_RUNEFORGING_CREDIT    = 54586,
};

BotLifeMgr* BotLifeMgr::instance()
{
    static BotLifeMgr instance;
    return &instance;
}

void BotLifeMgr::LoadConfig()
{
    _enabled = sConfigMgr->GetBoolDefault("BotLife.Enable", true);
    _travel = sConfigMgr->GetBoolDefault("BotLife.Travel", true);
    _quests = sConfigMgr->GetBoolDefault("BotLife.Quests", true);
    _loot = sConfigMgr->GetBoolDefault("BotLife.Loot", true);
    _rest = sConfigMgr->GetBoolDefault("BotLife.Rest", true);
    _chat = sConfigMgr->GetBoolDefault("BotLife.Chat", true);
    _emotes = sConfigMgr->GetBoolDefault("BotLife.Emotes", true);
    _zoneChat = sConfigMgr->GetBoolDefault("BotLife.ZoneChat", true);
    _guildEvents = sConfigMgr->GetBoolDefault("BotLife.GuildEvents", true);
    _hunterAi = sConfigMgr->GetBoolDefault("BotLife.HunterAI", false);
    LoadGuildConfig();
    LoadProfessionConfig();
    LoadAuctionConfig();
    _relocate = sConfigMgr->GetBoolDefault("BotLife.RelocateForLevel", true);
    _homeStartLevel = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.HomeStartLevel", 10)));
    _townVisits = sConfigMgr->GetBoolDefault("BotLife.TownVisits", true);
    _townMinutesMin = std::max(5, sConfigMgr->GetIntDefault("BotLife.TownMinutesMin", 40));
    _townMinutesMax = std::max<uint32>(_townMinutesMin, sConfigMgr->GetIntDefault("BotLife.TownMinutesMax", 90));
    _debug = sConfigMgr->GetBoolDefault("BotLife.Debug", false);
    _maxQuests = std::max(1, sConfigMgr->GetIntDefault("BotLife.MaxQuests", 3));
    _questTimeout = std::max(300, sConfigMgr->GetIntDefault("BotLife.QuestTimeout", 1500)) * IN_MILLISECONDS;
    _guildChatInterval = std::max(30, sConfigMgr->GetIntDefault("BotLife.GuildChatInterval", 150));
    _zoneChatInterval = std::max(60, sConfigMgr->GetIntDefault("BotLife.ZoneChatInterval", 240));
    _calendarSignups = std::max(0, sConfigMgr->GetIntDefault("BotLife.CalendarSignups", 20));
    _eventRaidSize = std::max(1, sConfigMgr->GetIntDefault("BotLife.EventRaidSize", 20));
    _partiesEnabled = sConfigMgr->GetBoolDefault("BotLife.Parties", true);
    _partyShare = std::min(80, std::max(0, sConfigMgr->GetIntDefault("BotLife.PartyShare", 25)));
    _partyMinutesMin = std::max(5, sConfigMgr->GetIntDefault("BotLife.PartyMinutesMin", 30));
    _partyMinutesMax = std::max<uint32>(_partyMinutesMin, sConfigMgr->GetIntDefault("BotLife.PartyMinutesMax", 75));
    _dungeonsEnabled = sConfigMgr->GetBoolDefault("BotLife.Dungeons", true);
    _heroicDungeons = sConfigMgr->GetBoolDefault("BotLife.HeroicDungeons", true);
    _dailyQuests = sConfigMgr->GetBoolDefault("BotLife.DailyQuests", true);
    _skipQuests = sConfigMgr->GetBoolDefault("BotLife.SkipQuests", true);
    _dkChain = sConfigMgr->GetBoolDefault("BotLife.DeathKnightChain", true);
    _questLearning = sConfigMgr->GetBoolDefault("BotLife.QuestLearning", true);
    _naturalProgression = sConfigMgr->GetBoolDefault("AiPlayerbot.NaturalProgression", false);
    _battlegrounds = sConfigMgr->GetBoolDefault("BotLife.Battlegrounds", true);
    _guildGroups = sConfigMgr->GetBoolDefault("BotLife.GuildGroups", true);
    _bgAutoMinutes = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.BgAutoMinutes", 20)));
    _bgAutoMax = uint32(std::max(1, sConfigMgr->GetIntDefault("BotLife.BgAutoMax", 2)));
    _dungeonParties = std::max(0, sConfigMgr->GetIntDefault("BotLife.DungeonParties", 6));
    _dungeonMinutes = std::max(10, sConfigMgr->GetIntDefault("BotLife.DungeonMinutes", 50));
    _badDungeonHours = uint32(std::max(1, sConfigMgr->GetIntDefault("BotLife.BadDungeonRetryHours", 3)));
    _badDungeonDays = uint32(std::max(1, sConfigMgr->GetIntDefault("BotLife.BadDungeonRetryDays", 3)));
    _dungeonFocusChance = uint32(std::min(100, std::max(0, sConfigMgr->GetIntDefault("BotLife.DungeonFocusChance", 0))));
    _raidsEnabled = sConfigMgr->GetBoolDefault("BotLife.Raids", true);
    _raidParties = std::max(0, sConfigMgr->GetIntDefault("BotLife.RaidParties", 1));
    _raidSize = std::min(25, std::max(6, sConfigMgr->GetIntDefault("BotLife.RaidSize", 10)));
    _raidMinutes = std::max(10, sConfigMgr->GetIntDefault("BotLife.RaidMinutes", 75));
}

void BotLifeMgr::LoadCaches()
{
    uint32 oldMSTime = getMSTime();
    LoadConfig();
    if (!_enabled)
    {
        TC_LOG_INFO("server.loading", ">> BotLife disabled");
        return;
    }

    // spawns that only exist during a game event (seasonal NPCs and objects) are skipped
    std::unordered_set<uint32> eventCreatures, eventObjects;
    if (QueryResult result = WorldDatabase.Query("SELECT guid FROM game_event_creature"))
        do { eventCreatures.insert(result->Fetch()[0].GetUInt32()); } while (result->NextRow());
    if (QueryResult result = WorldDatabase.Query("SELECT guid FROM game_event_gameobject"))
        do { eventObjects.insert(result->Fetch()[0].GetUInt32()); } while (result->NextRow());

    // --- creature spawns (phase 1, open world only)
    uint32 spawnCount = 0;
    if (QueryResult result = WorldDatabase.Query("SELECT guid, id, map, zoneId, position_x, position_y, position_z, phaseMask FROM creature "
        "WHERE (phaseMask & 1) = 1 AND phaseId = 0 AND phaseGroup = 0"))
    {
        do
        {
            Field* f = result->Fetch();
            if (eventCreatures.count(f[0].GetUInt32()))
                continue;
            BotLifeSpawn s;
            s.entry = f[1].GetUInt32();
            s.map = f[2].GetUInt16();
            s.zone = uint16(f[3].GetUInt32());
            s.x = f[4].GetFloat();
            s.y = f[5].GetFloat();
            s.z = f[6].GetFloat();
            s.phaseMask = f[7].GetUInt32();
            MapEntry const* me = sMapStore.LookupEntry(s.map);
            if (!me || me->Instanceable())
                continue;
            _creatureSpawns[s.entry].push_back(s);
            ++spawnCount;
        } while (result->NextRow());
    }
    // batch 11p: a creature that stands only in another phase - the quest puts the player into it
    std::set<uint32> phasedOnly;
    if (QueryResult result = WorldDatabase.Query("SELECT guid, id, map, zoneId, position_x, position_y, position_z, phaseMask, phaseId, phaseGroup FROM creature "
        "WHERE NOT ((phaseMask & 1) = 1 AND phaseId = 0 AND phaseGroup = 0)"))
    {
        std::unordered_map<uint32, std::vector<BotLifeSpawn>> phased;
        do
        {
            Field* f = result->Fetch();
            if (eventCreatures.count(f[0].GetUInt32()))   // also with plain spawns elsewhere
                continue;
            BotLifeSpawn s;
            s.entry = f[1].GetUInt32();
            s.map = f[2].GetUInt16();
            s.zone = uint16(f[3].GetUInt32());
            s.x = f[4].GetFloat();
            s.y = f[5].GetFloat();
            s.z = f[6].GetFloat();
            s.phaseMask = (f[8].GetUInt32() || f[9].GetUInt32()) ? 0 : f[7].GetUInt32();
            s.phaseId = f[8].GetUInt32();
            MapEntry const* me = sMapStore.LookupEntry(s.map);
            if (!me || me->Instanceable())
                continue;
            phased[s.entry].push_back(s);
        } while (result->NextRow());
        for (auto& p : phased)
        {
            spawnCount += uint32(p.second.size());
            auto& list = _creatureSpawns[p.first];
            if (list.empty())
                phasedOnly.insert(p.first);
            list.insert(list.end(), p.second.begin(), p.second.end());   // next to the plain spawns
        }
    }

    // --- quest givers per map
    uint32 giverCount = 0;
    if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT id FROM creature_queststarter"))
    {
        do
        {
            uint32 entry = result->Fetch()[0].GetUInt32();
            auto it = _creatureSpawns.find(entry);
            // a giver that stands only in a phase is in the list as well: FindQuestGiver
            // takes it for a bot that is in that phase
            if (it == _creatureSpawns.end())
                continue;
            for (BotLifeSpawn const& s : it->second)
            {
                _questGivers[s.map].push_back(s);
                ++giverCount;
            }
        } while (result->NextRow());
    }

    // --- kill credit sources
    if (QueryResult result = WorldDatabase.Query("SELECT entry, KillCredit1, KillCredit2 FROM creature_template WHERE KillCredit1 <> 0 OR KillCredit2 <> 0"))
    {
        do
        {
            Field* f = result->Fetch();
            uint32 entry = f[0].GetUInt32();
            for (uint8 i = 1; i <= 2; ++i)
                if (uint32 credit = f[i].GetUInt32())
                    _killCreditSources[credit].push_back(entry);
        } while (result->NextRow());
    }

    // which quests lead into a quest (NextQuestID) - a chain step stays worth doing when it is grey
    _questLeadsIn.clear();
    for (auto const& qp : sObjectMgr->GetQuestTemplates())
        if (uint32 next = qp.second->GetNextQuestId())
            _questLeadsIn[next].push_back(qp.first);

    // --- sources for quest objective items
    std::set<uint32> itemSet;
    std::set<uint32> goEntries;
    for (auto const& qp : sObjectMgr->GetQuestTemplates())
        for (QuestObjective const& obj : qp.second->GetObjectives())
        {
            if (obj.Type == QUEST_OBJECTIVE_ITEM && obj.ObjectID)
                itemSet.insert(obj.ObjectID);
            else if (obj.Type == QUEST_OBJECTIVE_GAMEOBJECT && obj.ObjectID)
                goEntries.insert(obj.ObjectID);   // an object to use
        }
    // batch 11p: spells a C++ script casts, out of sight of the data (tt_botlife_spell_hint)
    std::unordered_map<uint32, std::vector<uint32>> spellHints;
    PlayerbotsDatabase.DirectExecute("CREATE TABLE IF NOT EXISTS tt_botlife_spell_hint (spell INT UNSIGNED NOT NULL, casts INT UNSIGNED NOT NULL, "
        "comment VARCHAR(160) NOT NULL DEFAULT '', PRIMARY KEY (spell, casts))");
    if (QueryResult result = PlayerbotsDatabase.Query("SELECT spell, casts FROM tt_botlife_spell_hint"))
    {
        do
        {
            Field* f = result->Fetch();
            spellHints[f[0].GetUInt32()].push_back(f[1].GetUInt32());
        } while (result->NextRow());
    }
    // batch 11o: tools - items whose use makes an objective item - are looked up as well
    std::unordered_map<uint32, std::vector<std::pair<uint32, uint32>>> toolItems;   // objective item -> (tool, its spell)
    for (auto const& it : *sObjectMgr->GetItemTemplateStore())
    {
        ItemTemplate const& proto = it.second;
        for (uint8 i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
        {
            if (proto.Spells[i].SpellId <= 0 || proto.Spells[i].SpellTrigger != ITEM_SPELLTRIGGER_ON_USE)
                continue;
            std::set<uint32> made;
            std::vector<uint32> chain{ uint32(proto.Spells[i].SpellId) };
            auto hint = spellHints.find(chain[0]);   // (batch 11p: what a script casts for it)
            if (hint != spellHints.end())
                chain.insert(chain.end(), hint->second.begin(), hint->second.end());
            for (size_t n = 0; n < chain.size() && n < 4; ++n)
                if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(chain[n]))
                    for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                    {
                        uint32 const effect = spellInfo->Effects[e].Effect;
                        uint32 const item = spellInfo->Effects[e].ItemType;
                        if ((effect == SPELL_EFFECT_CREATE_ITEM || effect == SPELL_EFFECT_CREATE_ITEM_2) && item && item != it.first && itemSet.count(item))
                            made.insert(item);
                        if (spellInfo->Effects[e].TriggerSpell)
                            chain.push_back(spellInfo->Effects[e].TriggerSpell);
                    }
            for (uint32 item : made)
                toolItems[item].emplace_back(it.first, uint32(proto.Spells[i].SpellId));
        }
    }
    for (auto const& tl : toolItems)
        for (auto const& tool : tl.second)
            itemSet.insert(tool.first);
    std::unordered_map<uint32, std::vector<std::pair<uint32, float>>> itemDrops;   // batch 11x: item -> (creature, chance)
    std::vector<uint32> items(itemSet.begin(), itemSet.end());
    for (size_t from = 0; from < items.size(); from += 1000)
    {
        size_t to = std::min(items.size(), from + 1000);
        std::string ids = JoinIds(items, from, to);
        if (QueryResult result = WorldDatabase.PQuery("SELECT ct.entry, clt.item, clt.ChanceOrQuestChance FROM creature_loot_template clt "
            "JOIN creature_template ct ON ct.lootid = clt.entry WHERE clt.mincountOrRef > 0 AND clt.item IN ({})", ids))
        {
            do
            {
                Field* f = result->Fetch();
                float chance = std::fabs(f[2].GetFloat());
                if (chance <= 0.0f)
                    chance = 20.0f;   // equal chance within a loot group
                itemDrops[f[1].GetUInt32()].emplace_back(f[0].GetUInt32(), chance);   // (batch 11x: filtered below)
            } while (result->NextRow());
        }
        if (QueryResult result = WorldDatabase.PQuery("SELECT gt.entry, glt.item FROM gameobject_loot_template glt "
            "JOIN gameobject_template gt ON gt.data1 = glt.entry WHERE gt.type = 3 AND glt.mincountOrRef > 0 AND glt.item IN ({})", ids))
        {
            do
            {
                Field* f = result->Fetch();
                _itemGoSources[f[1].GetUInt32()].push_back(f[0].GetUInt32());
                goEntries.insert(f[0].GetUInt32());
            } while (result->NextRow());
        }
        // or a vendor sells it for money (Rhapsody Malt for the Beer Basted Boar Ribs)
        if (QueryResult result = WorldDatabase.PQuery("SELECT entry, item FROM npc_vendor WHERE type = 1 AND ExtendedCost = 0 AND item IN ({})", ids))
        {
            do
            {
                Field* f = result->Fetch();
                _itemVendorSources[uint32(f[1].GetInt32())].push_back(f[0].GetUInt32());
            } while (result->NextRow());
        }
    }
    // batch 11x: the creatures that really drop an item - at least a tenth of the best chance (and 1 %)
    uint32 dropsLeftOut = 0;
    for (auto const& drop : itemDrops)
    {
        float best = 0.0f;
        for (auto const& d : drop.second)
            best = std::max(best, d.second);
        float const threshold = best >= 1.0f ? std::max(1.0f, best * 0.1f) : best * 0.5f;
        auto& list = _itemCreatureSources[drop.first];
        for (auto const& d : drop.second)
        {
            if (d.second < threshold)
            {
                ++dropsLeftOut;
                continue;
            }
            if (std::find(list.begin(), list.end(), d.first) == list.end())
                list.push_back(d.first);
        }
    }
    TC_LOG_INFO("playerbots", "BotLife: {} creatures left out as a source of a quest item (a chance far below the best)", dropsLeftOut);
    // batch 11d: spell focus objects the item of a quest has to be used at (the moonwell for a phial)
    {
        std::unordered_map<uint32, std::vector<uint32>> focusObjects;
        for (auto const& gt : *sObjectMgr->GetGameObjectTemplates())
            if (gt.second.type == GAMEOBJECT_TYPE_SPELL_FOCUS && gt.second.spellFocus.focusId)
                focusObjects[gt.second.spellFocus.focusId].push_back(gt.first);
        for (auto const& qp : sObjectMgr->GetQuestTemplates())
        {
            ItemTemplate const* proto = qp.second->GetSrcItemId() ? sObjectMgr->GetItemTemplate(qp.second->GetSrcItemId()) : nullptr;
            if (!proto)
                continue;
            for (uint8 i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
            {
                if (proto->Spells[i].SpellId <= 0 || proto->Spells[i].SpellTrigger != ITEM_SPELLTRIGGER_ON_USE)
                    continue;
                SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(uint32(proto->Spells[i].SpellId));
                auto fo = spellInfo && spellInfo->RequiresSpellFocus ? focusObjects.find(spellInfo->RequiresSpellFocus) : focusObjects.end();
                if (fo == focusObjects.end())
                    continue;
                _focusObjects[spellInfo->RequiresSpellFocus] = fo->second;
                goEntries.insert(fo->second.begin(), fo->second.end());
            }
        }
        for (auto const& tl : toolItems)   // batch 11o: where the tools are used (a runeforge)
            for (auto const& tool : tl.second)
            {
                SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(tool.second);
                auto fo = spellInfo && spellInfo->RequiresSpellFocus ? focusObjects.find(spellInfo->RequiresSpellFocus) : focusObjects.end();
                if (fo == focusObjects.end())
                    continue;
                _focusObjects[spellInfo->RequiresSpellFocus] = fo->second;
                goEntries.insert(fo->second.begin(), fo->second.end());
            }
    }
    // batch 11i: quest objects (a crate, a body, a wanted poster) give and take quests as well
    std::set<uint32> goGiverEntries;
    if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT id FROM gameobject_queststarter"))
    {
        do
        {
            goGiverEntries.insert(result->Fetch()[0].GetUInt32());
        } while (result->NextRow());
    }
    goEntries.insert(goGiverEntries.begin(), goGiverEntries.end());
    // batch 11m: items whose equip spell gives a kill credit, and the chests they are looted from
    _equipCredits.clear();
    _equipItemChests.clear();
    std::vector<uint32> equipChests;   // (batch 11m2: their spawns stand in a class phase)
    {
        std::vector<uint32> equipItems;
        if (QueryResult result = WorldDatabase.Query("SELECT entry FROM item_template WHERE spelltrigger_1 = 1 OR spelltrigger_2 = 1 "
            "OR spelltrigger_3 = 1 OR spelltrigger_4 = 1 OR spelltrigger_5 = 1"))
        {
            do
            {
                uint32 const entry = result->Fetch()[0].GetUInt32();
                ItemTemplate const* proto = sObjectMgr->GetItemTemplate(entry);
                if (!proto)
                    continue;
                for (uint8 i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
                {
                    if (proto->Spells[i].SpellId <= 0 || proto->Spells[i].SpellTrigger != ITEM_SPELLTRIGGER_ON_EQUIP)
                        continue;
                    std::vector<uint32> chain{ uint32(proto->Spells[i].SpellId) };
                    for (size_t n = 0; n < chain.size() && n < 6; ++n)
                        if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(chain[n]))
                            for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                            {
                                if ((spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT || spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT2)
                                    && spellInfo->Effects[e].MiscValue > 0)
                                {
                                    auto& list = _equipCredits[uint32(spellInfo->Effects[e].MiscValue)];
                                    if (std::find(list.begin(), list.end(), entry) == list.end())
                                        list.push_back(entry);
                                    equipItems.push_back(entry);
                                }
                                if (spellInfo->Effects[e].TriggerSpell)
                                    chain.push_back(spellInfo->Effects[e].TriggerSpell);
                            }
                }
            } while (result->NextRow());
        }
        if (!equipItems.empty())
            if (QueryResult result = WorldDatabase.PQuery("SELECT gt.entry, glt.item FROM gameobject_loot_template glt "
                "JOIN gameobject_template gt ON gt.data1 = glt.entry WHERE gt.type = 3 AND glt.mincountOrRef > 0 AND glt.item IN ({})",
                JoinIds(equipItems, 0, std::min<size_t>(equipItems.size(), 1000))))
            {
                do
                {
                    Field* f = result->Fetch();
                    _equipItemChests[f[1].GetUInt32()].push_back(f[0].GetUInt32());
                    goEntries.insert(f[0].GetUInt32());
                    equipChests.push_back(f[0].GetUInt32());
                } while (result->NextRow());
            }
    }
    // batch 11o: items a click on a creature hands out: the click spell makes the item, itself or
    // through a spell it triggers
    _itemClickSources.clear();
    _questEventSources.clear();   // (batch 11q, filled here and with the SmartAI scripts below)
    _questEventObjects.clear();
    if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT npc_entry, spell_id FROM npc_spellclick_spells"))
    {
        do
        {
            Field* f = result->Fetch();
            uint32 const npc = f[0].GetUInt32();
            if (!_creatureSpawns.count(npc))
                continue;
            std::vector<uint32> chain{ f[1].GetUInt32() };
            for (size_t n = 0; n < chain.size() && n < 6; ++n)
                if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(chain[n]))
                    for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                    {
                        if ((spellInfo->Effects[e].Effect == SPELL_EFFECT_CREATE_ITEM || spellInfo->Effects[e].Effect == SPELL_EFFECT_CREATE_ITEM_2)
                            && spellInfo->Effects[e].ItemType)
                        {
                            auto& list = _itemClickSources[spellInfo->Effects[e].ItemType];
                            if (std::find(list.begin(), list.end(), npc) == list.end())
                                list.push_back(npc);
                        }
                        // batch 11q: or the click completes a quest (a launcher to ride)
                        if (spellInfo->Effects[e].Effect == SPELL_EFFECT_QUEST_COMPLETE && spellInfo->Effects[e].MiscValue > 0)
                        {
                            auto& list = _questEventSources[uint32(spellInfo->Effects[e].MiscValue)];
                            if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s) { return s.creature == npc && s.click; }))
                            {
                                BotLifeCreditSource src;
                                src.creature = npc;
                                src.click = true;
                                list.push_back(src);
                            }
                        }
                        if (spellInfo->Effects[e].TriggerSpell)
                            chain.push_back(spellInfo->Effects[e].TriggerSpell);
                    }
        } while (result->NextRow());
    }
    TC_LOG_INFO("playerbots", "BotLife: {} quest items a click on a creature hands out", _itemClickSources.size());
    // batch 11z2: objects that hand an objective item out after a gossip (SmartAI on the object: gossip
    // select / hello -> add item, directly or in the linked row)
    _gossipItemObjects.clear();
    if (QueryResult result = WorldDatabase.Query("SELECT s.entryorguid, IF(s.action_type = 56, s.action_param1, l.action_param1) FROM smart_scripts s "
        "LEFT JOIN smart_scripts l ON l.source_type = 1 AND l.entryorguid = s.entryorguid AND l.id = s.link AND l.event_type = 61 AND l.action_type = 56 "
        "WHERE s.source_type = 1 AND s.entryorguid > 0 AND s.event_type IN (62, 64) AND (s.action_type = 56 OR l.action_type = 56)"))
    {
        do
        {
            Field* f = result->Fetch();
            uint32 const go = uint32(f[0].GetInt32()), item = f[1].GetUInt32();
            if (!itemSet.count(item))
                continue;
            auto& list = _itemGoSources[item];
            if (std::find(list.begin(), list.end(), go) == list.end())
                list.push_back(go);
            goEntries.insert(go);
            _gossipItemObjects.insert(go);
        } while (result->NextRow());
    }
    // batch 11l: objects whose SmartAI gives a kill credit to the player who opens them
    _creditObjects.clear();
    // batch 11n: or that summon the credit creature (a prison, a horn, remains to disturb)
    // ... or that hand the credit out through a timed action list (the Merchant Square Door)
    if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT entryorguid, action_param1, action_type FROM smart_scripts "
        "WHERE source_type = 1 AND entryorguid > 0 AND action_param1 > 0 AND ((event_type = 70 AND action_type = 33) "
        "OR (event_type IN (64, 70) AND action_type IN (12, 15, 26))) "
        "UNION SELECT DISTINCT s.entryorguid, t.action_param1, 33 FROM smart_scripts s "
        "JOIN smart_scripts t ON t.source_type = 9 AND t.action_type = 33 AND t.action_param1 > 0 "
        "AND t.entryorguid IN (s.action_param1, s.action_param2, s.action_param3, s.action_param4, s.action_param5, s.action_param6) "
        "WHERE s.source_type = 1 AND s.entryorguid > 0 AND s.event_type IN (64, 70) AND s.action_type IN (80, 87, 88)"))
    {
        do
        {
            Field* f = result->Fetch();
            if (f[2].GetUInt8() == 15 || f[2].GetUInt8() == 26)
            {
                // batch 11q: the use completes a quest without objectives
                Quest const* quest = sObjectMgr->GetQuestTemplate(f[1].GetUInt32());
                if (quest && quest->GetObjectives().empty())
                {
                    _questEventObjects[f[1].GetUInt32()].push_back(uint32(f[0].GetInt32()));
                    goEntries.insert(uint32(f[0].GetInt32()));
                }
                continue;
            }
            if (f[2].GetUInt8() == 12 && _creatureSpawns.count(f[1].GetUInt32()))
                continue;
            uint32 const go = uint32(f[0].GetInt32());
            _creditObjects[f[1].GetUInt32()].push_back(go);
            goEntries.insert(go);
        } while (result->NextRow());
    }
    // Runeforging: Preparation For Battle (12842) is done at a Runeforge of Acherus
    _questEventObjects[QUEST_DK_RUNEFORGING].push_back(GO_ACHERUS_RUNEFORGE);
    goEntries.insert(GO_ACHERUS_RUNEFORGE);
    // The Endless Hunger (12848) - an Acherus Soul Prison (C++ script) sets the Unworthy Initiate free
    for (uint32 prison = 191577; prison <= 191590; ++prison)
        if (prison != 191578 && prison != 191579)
        {
            _creditObjects[NPC_UNWORTHY_INITIATE].push_back(prison);
            goEntries.insert(prison);
        }
    // batch 11s: objects whose own spell gives the credit (a goober: data10, a spell caster: data0)
    for (auto const& gt : *sObjectMgr->GetGameObjectTemplates())
    {
        uint32 spell = 0;
        if (gt.second.type == GAMEOBJECT_TYPE_GOOBER)
            spell = gt.second.raw.data[10];
        else if (gt.second.type == GAMEOBJECT_TYPE_SPELLCASTER)
            spell = gt.second.raw.data[0];
        if (!spell)
            continue;
        std::vector<uint32> chain{ spell };
        for (size_t n = 0; n < chain.size() && n < 4; ++n)
            if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(chain[n]))
                for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                {
                    // (batch 11u: or summons the creature to kill, one without a spawn of its own)
                    bool const summon = spellInfo->Effects[e].Effect == SPELL_EFFECT_SUMMON && spellInfo->Effects[e].MiscValue > 0
                        && !_creatureSpawns.count(uint32(spellInfo->Effects[e].MiscValue));
                    if (((spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT || spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT2)
                        && spellInfo->Effects[e].MiscValue > 0) || summon)
                    {
                        auto& list = _creditObjects[uint32(spellInfo->Effects[e].MiscValue)];
                        if (std::find(list.begin(), list.end(), gt.first) == list.end())
                            list.push_back(gt.first);
                        goEntries.insert(gt.first);
                    }
                    if (spellInfo->Effects[e].TriggerSpell)
                        chain.push_back(spellInfo->Effects[e].TriggerSpell);
                }
    }
    if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT id FROM gameobject_questender"))
    {
        do
        {
            goEntries.insert(result->Fetch()[0].GetUInt32());
        } while (result->NextRow());
    }
    std::vector<uint32> goList(goEntries.begin(), goEntries.end());
    uint32 goSpawnCount = 0;
    std::string const equipChestIds = equipChests.empty() ? std::string("0") : JoinIds(equipChests, 0, equipChests.size());
    TC_LOG_INFO("playerbots", "BotLife: {} credits for equipping an item, {} chests with such an item", _equipCredits.size(), equipChests.size());
    for (size_t from = 0; from < goList.size(); from += 1000)
    {
        size_t to = std::min(goList.size(), from + 1000);
        // every phase mask, not only phase 1: a quest moves the player into the phase of its objects
        if (QueryResult result = WorldDatabase.PQuery("SELECT guid, id, map, zoneId, position_x, position_y, position_z, phaseMask, "
            "id IN ({}) FROM gameobject WHERE ((phaseId = 0 AND phaseGroup = 0) OR id IN ({})) AND id IN ({})",
            equipChestIds, equipChestIds, JoinIds(goList, from, to)))   // batch 11m2: equip chests in any phase
        {
            do
            {
                Field* f = result->Fetch();
                if (eventObjects.count(f[0].GetUInt32()))
                    continue;
                BotLifeSpawn s;
                s.entry = f[1].GetUInt32();
                s.map = f[2].GetUInt16();
                s.zone = uint16(f[3].GetUInt32());
                s.x = f[4].GetFloat();
                s.y = f[5].GetFloat();
                s.z = f[6].GetFloat();
                MapEntry const* me = sMapStore.LookupEntry(s.map);
                if (!me || me->Instanceable())
                    continue;
                s.go = true;
                s.phaseMask = f[8].GetBool() ? 0xFFFFFFFF : f[7].GetUInt32();
                _goSpawns[s.entry].push_back(s);
                ++goSpawnCount;
                if (goGiverEntries.count(s.entry))
                    _questGivers[s.map].push_back(s);   // batch 11i: 
            } while (result->NextRow());
        }
    }

    // --- area triggers that give the explore credit of a quest (open world only)
    _questTriggers.clear();
    if (QueryResult result = WorldDatabase.Query("SELECT id, quest FROM areatrigger_involvedrelation"))
    {
        do
        {
            Field* f = result->Fetch();
            AreaTriggerEntry const* at = sAreaTriggerStore.LookupEntry(f[0].GetUInt32());
            MapEntry const* me = at ? sMapStore.LookupEntry(at->ContinentID) : nullptr;
            if (!me || me->Instanceable())
                continue;
            BotLifeSpawn s;
            s.entry = at->ID;
            s.map = uint16(at->ContinentID);
            s.x = at->Pos.X;
            s.y = at->Pos.Y;
            s.z = at->Pos.Z;
            _questTriggers[f[1].GetUInt32()].push_back(s);
        } while (result->NextRow());
    }
    // quests whose credit comes from a scripted area trigger: listed by hand
    if (QueryResult result = WorldDatabase.Query("SELECT areatrigger, quest FROM tt_botlife_quest_triggers"))
    {
        do
        {
            Field* f = result->Fetch();
            AreaTriggerEntry const* at = sAreaTriggerStore.LookupEntry(f[0].GetUInt32());
            MapEntry const* me = at ? sMapStore.LookupEntry(at->ContinentID) : nullptr;
            if (!me || me->Instanceable())
                continue;
            BotLifeSpawn s;
            s.entry = at->ID;
            s.map = uint16(at->ContinentID);
            s.x = at->Pos.X;
            s.y = at->Pos.Y;
            s.z = at->Pos.Z;
            _questTriggers[f[1].GetUInt32()].push_back(s);
        } while (result->NextRow());
    }

    // --- creatures that give a kill credit when a spell hits them, when they are talked to or clicked, when a player
    // comes near or while they are fought (SmartAI: event 8 spell hit, 62 gossip select, 64 gossip hello, 73 spell
    // click, 10 line of sight, 2 health percentage -> a credit)
    // the credit can sit in the event itself, in its linked events, in a timed action list (actions
    // 80, 87, 88) or in a spell the script casts (actions 11, 85, 86, 134)
    _creditSources.clear();
    _itemTalkSources.clear();   // (batch 11y)
    // gossip NPCs where talking can do something - the others with a kill objective are fought
    _gossipTalk.clear();
    if (QueryResult result = WorldDatabase.Query("SELECT ct.entry FROM creature_template ct WHERE (ct.npcflag & 1) <> 0 AND ("
        "ct.ScriptName <> '' OR (ct.gossip_menu_id <> 0 AND EXISTS (SELECT 1 FROM gossip_menu_option g WHERE g.MenuID = ct.gossip_menu_id)) "
        "OR EXISTS (SELECT 1 FROM smart_scripts s WHERE s.source_type = 0 AND s.entryorguid = ct.entry AND s.event_type IN (62, 64)) "
        "OR EXISTS (SELECT 1 FROM creature c JOIN smart_scripts s ON s.source_type = 0 AND s.entryorguid = -CAST(c.guid AS SIGNED) "
        "WHERE c.id = ct.entry AND s.event_type IN (62, 64)))"))
        do
        {
            _gossipTalk.insert(result->Fetch()[0].GetUInt32());
        } while (result->NextRow());
    TC_LOG_INFO("playerbots", "BotLife: {} gossip NPCs to talk to", _gossipTalk.size());
    std::unordered_map<uint32, std::set<uint32>> deathSummons;   // batch 11w: summoned -> creatures whose death calls it
    if (QueryResult result = WorldDatabase.Query("SELECT entryorguid, source_type, id, link, event_type, event_param1, action_type, action_param1, "
        "action_param2, action_param3, action_param4, action_param5, action_param6, target_type, target_param1, target_param2 FROM smart_scripts "
        "WHERE (source_type = 0 AND entryorguid > 0) OR source_type = 9 ORDER BY source_type, entryorguid, id"))
    {
        struct Row { uint32 link, event, param, action; uint32 a[6]; uint32 tt, tp1, tp2; };
        std::unordered_map<uint32, std::map<uint32, Row>> scripts, lists;
        do
        {
            Field* f = result->Fetch();
            Row row{ f[3].GetUInt16(), f[4].GetUInt8(), f[5].GetUInt32(), f[6].GetUInt8(),
                { f[7].GetUInt32(), f[8].GetUInt32(), f[9].GetUInt32(), f[10].GetUInt32(), f[11].GetUInt32(), f[12].GetUInt32() },
                f[13].GetUInt8(), f[14].GetUInt32(), f[15].GetUInt32() };
            (f[1].GetUInt8() == 9 ? lists : scripts)[uint32(f[0].GetInt32())][f[2].GetUInt16()] = row;
        } while (result->NextRow());

        // the credits a spell gives, itself or through the spells it triggers
        auto spellCredits = [](uint32 spell, std::set<uint32>& out)
        {
            std::vector<uint32> chain{ spell };
            for (size_t n = 0; n < chain.size() && n < 6; ++n)
                if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(chain[n]))
                    for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                    {
                        if (spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT || spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT2)
                            out.insert(uint32(spellInfo->Effects[e].MiscValue));
                        if (spellInfo->Effects[e].TriggerSpell)
                            chain.push_back(spellInfo->Effects[e].TriggerSpell);
                    }
        };
        // batch 11y: the items a row hands out (add item, or a spell that creates one) - collected
        // while this is set
        std::set<uint32>* rowItems = nullptr;
        auto spellItems = [](uint32 spell, std::set<uint32>& out)
        {
            std::vector<uint32> chain{ spell };
            for (size_t n = 0; n < chain.size() && n < 4; ++n)
                if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(chain[n]))
                    for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                    {
                        if ((spellInfo->Effects[e].Effect == SPELL_EFFECT_CREATE_ITEM || spellInfo->Effects[e].Effect == SPELL_EFFECT_CREATE_ITEM_2)
                            && spellInfo->Effects[e].ItemType)
                            out.insert(spellInfo->Effects[e].ItemType);
                        if (spellInfo->Effects[e].TriggerSpell)
                            chain.push_back(spellInfo->Effects[e].TriggerSpell);
                    }
        };
        // the credits one script row gives
        auto rowCredits = [&](auto&& self, Row const& row, std::set<uint32>& out, uint8 depth, std::set<uint32>* summons,
            std::set<uint32>* quests) -> void
        {
            switch (row.action)
            {
                case 15:    // quest done: area explored or event happens 
                case 26:    // the same for the group
                    if (quests && row.a[0])
                        quests->insert(row.a[0]);
                    break;
                case 33:    // kill credit
                    if (row.a[0])
                        out.insert(row.a[0]);
                    break;
                case 12:    // summon creature 
                    if (summons && row.a[0])
                        summons->insert(row.a[0]);
                    break;
                case 56:    // add item 
                    if (rowItems && row.a[0])
                        rowItems->insert(row.a[0]);
                    break;
                case 11:    // cast
                case 85:    // invoker cast
                case 86:    // cross cast
                case 134:
                    spellCredits(row.a[0], out);
                    if (rowItems)
                        spellItems(row.a[0], *rowItems);   // (batch 11y)
                    break;
                case 80:    // timed action list
                case 87:    // one of up to six lists
                case 88:    // one of a range of lists
                {
                    if (depth >= 3)
                        break;
                    std::vector<uint32> ids;
                    if (row.action == 80)
                        ids.push_back(row.a[0]);
                    else if (row.action == 87)
                    {
                        for (uint32 id : row.a)
                            if (id)
                                ids.push_back(id);
                    }
                    else
                        for (uint32 id = row.a[0]; id && id <= row.a[1] && id < row.a[0] + 20; ++id)
                            ids.push_back(id);
                    for (uint32 id : ids)
                    {
                        auto list = lists.find(id);
                        if (list != lists.end())
                            for (auto const& listRow : list->second)
                                self(self, listRow.second, out, uint8(depth + 1), summons, quests);
                    }
                    break;
                }
                default:
                    break;
            }
        };

        for (auto const& sc : scripts)
        {
            if (!_creatureSpawns.count(sc.first))
                continue;
            CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(sc.first);
            FactionTemplateEntry const* ft = ct ? sFactionTemplateStore.LookupEntry(ct->faction) : nullptr;
            for (auto const& start : sc.second)
            {
                uint32 const event = start.second.event;
                // batch 11k: a timer that credits every player within a range: stand near the NPC
                if ((event == 1 || event == 60) && start.second.action == 33 && start.second.a[0]
                    && (start.second.tt == 17 || start.second.tt == 18))
                {
                    uint32 const range = start.second.tt == 17 ? start.second.tp2 : start.second.tp1;
                    if (range)
                    {
                        auto& list = _creditSources[start.second.a[0]];
                        if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s) { return s.creature == sc.first && s.visit > 0.0f; }))
                        {
                            BotLifeCreditSource src;
                            src.creature = sc.first;
                            src.visit = float(range);
                            list.push_back(src);
                        }
                    }
                    continue;
                }
                // batch 11y: an objective item it hands out after a talk, a click or a spell on it
                if (event == 62 || event == 64 || event == 73 || (event == 8 && start.second.param))
                {
                    std::set<uint32> ignored, items;
                    rowItems = &items;
                    Row const* row = &start.second;
                    for (uint8 depth = 0; row && depth < 10; ++depth)
                    {
                        rowCredits(rowCredits, *row, ignored, 0, nullptr, nullptr);
                        auto next = row->link ? sc.second.find(row->link) : sc.second.end();
                        row = next != sc.second.end() && next->second.event == 61 ? &next->second : nullptr;
                    }
                    rowItems = nullptr;
                    for (uint32 item : items)
                    {
                        if (!itemSet.count(item))
                            continue;   // not an objective item (nor a tool)
                        BotLifeCreditSource src;
                        src.creature = sc.first;
                        if (event == 73)
                            src.click = true;
                        else if (event == 8)
                            src.spell = start.second.param;
                        else if (!ct || !(ct->npcflag & UNIT_NPC_FLAG_GOSSIP))
                            continue;
                        auto& list = _itemTalkSources[item];
                        if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s)
                            { return s.creature == src.creature && s.spell == src.spell && s.click == src.click; }))
                            list.push_back(src);
                    }
                }
                // batch 11w: a creature its death calls up
                if (event == 6)
                {
                    std::set<uint32> ignored, summons;
                    Row const* row = &start.second;
                    for (uint8 depth = 0; row && depth < 10; ++depth)
                    {
                        rowCredits(rowCredits, *row, ignored, 0, &summons, nullptr);
                        auto next = row->link ? sc.second.find(row->link) : sc.second.end();
                        row = next != sc.second.end() && next->second.event == 61 ? &next->second : nullptr;
                    }
                    for (uint32 summoned : summons)
                        if (!_creatureSpawns.count(summoned))
                            deathSummons[summoned].insert(sc.first);
                }
                // batch 11q: the event that completes a quest without objectives: a talk (or the walk it
                // starts), a click, a kill, a spell on the NPC, coming near a friendly one
                if (event == 62 || event == 64 || event == 73 || event == 6 || event == 10 || event == 40 || event == 58
                    || (event == 8 && start.second.param))
                {
                    std::set<uint32> ignored, quests;
                    Row const* row = &start.second;
                    for (uint8 depth = 0; row && depth < 10; ++depth)
                    {
                        rowCredits(rowCredits, *row, ignored, 0, nullptr, &quests);
                        auto next = row->link ? sc.second.find(row->link) : sc.second.end();
                        row = next != sc.second.end() && next->second.event == 61 ? &next->second : nullptr;
                    }
                    bool const gossip = ct && (ct->npcflag & UNIT_NPC_FLAG_GOSSIP) && std::any_of(sc.second.begin(), sc.second.end(),
                        [](auto const& r) { return r.second.event == 62 || r.second.event == 64; });
                    for (uint32 questId : quests)
                    {
                        Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
                        if (!quest || !quest->GetObjectives().empty())
                            continue;
                        BotLifeCreditSource src;
                        src.creature = sc.first;
                        if (event == 73)
                            src.click = true;
                        else if (event == 6)
                            src.fight = true;
                        else if (event == 8)
                            src.spell = start.second.param;
                        else if (event == 10)
                        {
                            if (!ft || ft->IsHostileToPlayers())
                                continue;
                            src.visit = 10.0f;
                        }
                        else if ((event == 40 || event == 58)
                            && std::any_of(sc.second.begin(), sc.second.end(), [](auto const& r) { return r.second.event == 19; }))
                        {
                            src.visit = 10.0f;   // (batch 11z: an escort the quest starts - walk along)
                            src.follow = true;
                        }
                        else if (!gossip)
                            continue;
                        auto& list = _questEventSources[questId];
                        if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s)
                            { return s.creature == src.creature && s.spell == src.spell && s.fight == src.fight && s.click == src.click && s.visit == src.visit; }))
                            list.push_back(src);
                    }
                }
                // batch 11n: the credit creature is summoned - after a talk (or on the walk the talk
                // starts), on accepting the quest, or when a spell hits the summoner. A summoned creature that has
                // spawns of its own is fought where it stands.
                if (event == 62 || event == 64 || event == 19 || event == 40 || event == 58 || (event == 8 && start.second.param))
                {
                    std::set<uint32> ignored, summons;
                    Row const* row = &start.second;
                    for (uint8 depth = 0; row && depth < 10; ++depth)
                    {
                        rowCredits(rowCredits, *row, ignored, 0, &summons, nullptr);
                        auto next = row->link ? sc.second.find(row->link) : sc.second.end();
                        row = next != sc.second.end() && next->second.event == 61 ? &next->second : nullptr;
                    }
                    bool const gossip = ct && (ct->npcflag & UNIT_NPC_FLAG_GOSSIP) && std::any_of(sc.second.begin(), sc.second.end(),
                        [](auto const& r) { return r.second.event == 62 || r.second.event == 64; });
                    for (uint32 summoned : summons)
                    {
                        if (_creatureSpawns.count(summoned))
                            continue;
                        BotLifeCreditSource src;
                        src.creature = sc.first;
                        if (event == 19)
                            src.visit = 10.0f;               // it comes when the quest is taken: stay near the giver
                        else if (event == 8)
                            src.spell = start.second.param;  // the spell that calls it
                        else if (!gossip)
                            continue;                        // a walk nobody starts with a talk
                        auto& list = _creditSources[summoned];
                        if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s)
                            { return s.creature == src.creature && s.spell == src.spell && s.visit == src.visit && !s.fight; }))
                            list.push_back(src);
                    }
                }
                if (event != 8 && event != 62 && event != 64 && event != 73 && event != 10 && event != 2 && event != 6 && event != 4
                    && event != 19)
                    continue;   // (batch 11s: 6 death and 4 aggro - a fight as well; batch 11v: 19 quest accept)
                bool const fight = event == 2 || event == 6 || event == 4;
                if (event == 8 && !start.second.param)
                    continue;   // any spell: nothing to aim for
                // a player who comes near: only a creature that leaves him alone
                if (event == 10 && (!ft || ft->IsHostileToPlayers()))
                    continue;
                // a fight to a health percentage: a creature a player can attack. A friendly faction counts as well: a
                // sparring partner turns hostile through an aura of the quest (2-10, batch 11c: the trainees of
                // the Wandering Isle) - whether the bot can attack shows on the spot.
                if (fight && (!ct || (ct->unit_flags & (UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_IMMUNE_TO_PC))))
                    continue;
                std::set<uint32> credits;
                Row const* row = &start.second;
                for (uint8 depth = 0; row && depth < 10; ++depth)
                {
                    rowCredits(rowCredits, *row, credits, 0, nullptr, nullptr);
                    auto next = row->link ? sc.second.find(row->link) : sc.second.end();
                    row = next != sc.second.end() && next->second.event == 61 ? &next->second : nullptr;
                }
                uint32 const spell = event == 8 ? start.second.param : 0;
                for (uint32 credit : credits)
                {
                    auto& list = _creditSources[credit];
                    BotLifeCreditSource src{ sc.first, spell, fight };
                    if (event == 19)
                        src.visit = 10.0f;   // (batch 11v: it comes after the quest is taken - stay near the giver)
                    if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s)
                        { return s.creature == src.creature && s.spell == src.spell && s.fight == src.fight && s.visit == src.visit; }))
                        list.push_back(src);
                }
            }
        }
    }

    // batch 11r: the same from the script of one spawn (a launcher): its entry stands in for it
    if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT c.id, s.event_type, s.action_param1 FROM smart_scripts s "
        "JOIN creature c ON c.guid = -s.entryorguid WHERE s.source_type = 0 AND s.entryorguid < 0 AND s.action_type IN (15, 26) "
        "AND s.event_type IN (62, 64, 73) AND s.action_param1 > 0"))
    {
        do
        {
            Field* f = result->Fetch();
            uint32 const entry = f[0].GetUInt32(), event = f[1].GetUInt8(), questId = f[2].GetUInt32();
            Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
            CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(entry);
            if (!quest || !quest->GetObjectives().empty() || !ct || !_creatureSpawns.count(entry))
                continue;
            BotLifeCreditSource src;
            src.creature = entry;
            if (event == 73)
                src.click = true;
            else if (!(ct->npcflag & UNIT_NPC_FLAG_GOSSIP))
                continue;
            auto& list = _questEventSources[questId];
            if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s) { return s.creature == entry && s.click == src.click; }))
                list.push_back(src);
        } while (result->NextRow());
    }
    // batch 11t: quests an event completes that the data alone does not show (the conversation in
    // Mortwake's Tower: Secrets of the Tower) - tt_botlife_quest_hint: stand within `visit` yards of this NPC
    PlayerbotsDatabase.DirectExecute("CREATE TABLE IF NOT EXISTS tt_botlife_quest_hint (quest INT UNSIGNED NOT NULL, creature INT UNSIGNED NOT NULL, "
        "visit FLOAT NOT NULL DEFAULT 10, comment VARCHAR(160) NOT NULL DEFAULT '', follow TINYINT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (quest, creature))");
    if (QueryResult result = PlayerbotsDatabase.Query("SELECT quest, creature, visit, follow FROM tt_botlife_quest_hint"))
    {
        do
        {
            Field* f = result->Fetch();
            uint32 const questId = f[0].GetUInt32(), creature = f[1].GetUInt32();
            if (!_creatureSpawns.count(creature))
                continue;
            BotLifeCreditSource src;
            src.creature = creature;
            src.visit = std::max(f[2].GetFloat(), 3.0f);
            src.follow = f[3].GetUInt8() != 0;   // (batch 11z: an escort)
            _questEventSources[questId].push_back(src);
        } while (result->NextRow());
    }
    TC_LOG_INFO("playerbots", "BotLife: {} quests without objectives an NPC completes, {} an object", _questEventSources.size(), _questEventObjects.size());
    // batch 11w: what a creature drops or credits that only the death of another calls up: fight that
    // other one (the summoned creature itself is taken when it shows up - it is a target of the objective)
    for (auto const& ds : deathSummons)
    {
        for (auto& source : _itemCreatureSources)
            if (std::find(source.second.begin(), source.second.end(), ds.first) != source.second.end())
                for (uint32 summoner : ds.second)
                    if (std::find(source.second.begin(), source.second.end(), summoner) == source.second.end())
                        source.second.push_back(summoner);
        auto& list = _creditSources[ds.first];
        for (uint32 summoner : ds.second)
            if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s) { return s.creature == summoner && s.fight; }))
                list.push_back(BotLifeCreditSource{ summoner, 0, true });
    }
    TC_LOG_INFO("playerbots", "BotLife: {} creatures without a spawn that the death of another calls up", deathSummons.size());
    // credits a C++ script gives for a spell of the player himself (a racial: Gift of the Naaru on the
    // Draenei Survivors). Nothing in the data tells which spell, so a table does: tt_botlife_credit_hint.
    PlayerbotsDatabase.DirectExecute("CREATE TABLE IF NOT EXISTS tt_botlife_credit_hint (credit INT UNSIGNED NOT NULL, creature INT UNSIGNED NOT NULL, "
        "spell INT UNSIGNED NOT NULL, comment VARCHAR(160) NOT NULL DEFAULT '', PRIMARY KEY (credit, creature, spell))");
    if (QueryResult result = PlayerbotsDatabase.Query("SELECT credit, creature, spell FROM tt_botlife_credit_hint"))
    {
        do
        {
            Field* f = result->Fetch();
            uint32 const credit = f[0].GetUInt32(), creature = f[1].GetUInt32(), spell = f[2].GetUInt32();
            if (!_creatureSpawns.count(creature))
                continue;
            auto& list = _creditSources[credit];
            if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s) { return s.creature == creature && s.spell == spell; }))
                list.push_back(BotLifeCreditSource{ creature, spell });
        } while (result->NextRow());
    }

    // --- quest items to use on a creature: the spell of the item a quest hands out gives the kill credit
    {
        // creatures the conditions of a spell name: its target (31, unit entry) or one that has to be near (29)
        // batch 11j: creatures that feed a helper - SmartAI "set data" on the helper's entry
        std::unordered_map<uint32, std::set<uint32>> helperFeeders;
        if (QueryResult result = WorldDatabase.Query("SELECT entryorguid, target_param1 FROM smart_scripts "
            "WHERE source_type = 0 AND entryorguid > 0 AND action_type = 45 AND target_type IN (11, 19)"))
        {
            do
            {
                Field* f = result->Fetch();
                helperFeeders[f[1].GetUInt32()].insert(uint32(f[0].GetInt32()));
            } while (result->NextRow());
        }
        // batch 11s: creatures a spell hit makes summon another (SmartAI spell hit -> summon, or an
        // action list that summons): spell -> (the creature hit, the creature summoned)
        std::unordered_map<uint32, std::vector<std::pair<uint32, uint32>>> spellHitSummons;
        if (QueryResult result = WorldDatabase.Query("SELECT s.entryorguid, s.event_param1, IF(s.action_type = 12, s.action_param1, l.action_param1) "
            "FROM smart_scripts s LEFT JOIN smart_scripts l ON s.action_type = 80 AND l.source_type = 9 AND l.entryorguid = s.action_param1 "
            "AND l.action_type = 12 WHERE s.source_type = 0 AND s.entryorguid > 0 AND s.event_type = 8 AND s.event_param1 > 0 "
            "AND (s.action_type = 12 OR l.action_type = 12)"))
        {
            do
            {
                Field* f = result->Fetch();
                if (uint32 summoned = f[2].GetUInt32())
                    spellHitSummons[f[1].GetUInt32()].emplace_back(uint32(f[0].GetInt32()), summoned);
            } while (result->NextRow());
        }
        // creatures that give a kill credit when a spell hits them (SmartAI spell hit ->
        // kill credit, directly or in an action list): spell -> (the creature hit, the credit)
        std::unordered_map<uint32, std::vector<std::pair<uint32, uint32>>> spellHitCredits;
        if (QueryResult result = WorldDatabase.Query("SELECT s.entryorguid, s.event_param1, IF(s.action_type = 33, s.action_param1, l.action_param1) "
            "FROM smart_scripts s LEFT JOIN smart_scripts l ON s.action_type = 80 AND l.source_type = 9 AND l.entryorguid = s.action_param1 "
            "AND l.action_type = 33 WHERE s.source_type = 0 AND s.entryorguid > 0 AND s.event_type = 8 AND s.event_param1 > 0 "
            "AND (s.action_type = 33 OR l.action_type = 33)"))
        {
            do
            {
                Field* f = result->Fetch();
                if (uint32 credit = f[2].GetUInt32())
                    spellHitCredits[f[1].GetUInt32()].emplace_back(uint32(f[0].GetInt32()), credit);
            } while (result->NextRow());
        }
        // batch 11f: spells whose target has to be dead (condition 36 "alive", negated)
        std::set<uint32> corpseSpells;
        if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT SourceEntry FROM conditions "
            "WHERE SourceTypeOrReferenceId IN (13, 17) AND SourceEntry > 0 AND ConditionTypeOrReference = 36 AND NegativeCondition = 1"))
        {
            do
            {
                corpseSpells.insert(uint32(result->Fetch()[0].GetInt32()));
            } while (result->NextRow());
        }
        std::unordered_map<uint32, std::vector<uint32>> spellTargets;
        if (QueryResult result = WorldDatabase.Query("SELECT SourceEntry, ConditionTypeOrReference, ConditionValue1, ConditionValue2 FROM conditions "
            "WHERE SourceTypeOrReferenceId IN (13, 17) AND SourceEntry > 0 AND NegativeCondition = 0 "
            "AND ((ConditionTypeOrReference = 31 AND ConditionValue1 = 3) OR ConditionTypeOrReference = 29)"))
        {
            do
            {
                Field* f = result->Fetch();
                uint32 const entry = f[1].GetInt32() == 31 ? f[3].GetUInt32() : f[2].GetUInt32();
                if (entry)
                    spellTargets[uint32(f[0].GetInt32())].push_back(entry);
            } while (result->NextRow());
        }
        uint32 itemQuests = 0;
        for (auto const& qp : sObjectMgr->GetQuestTemplates())
        {
            Quest const* quest = qp.second;
            ItemTemplate const* proto = quest->GetSrcItemId() ? sObjectMgr->GetItemTemplate(quest->GetSrcItemId()) : nullptr;
            if (!proto)
                continue;
            bool added = false;
            for (uint8 i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
            {
                if (proto->Spells[i].SpellId <= 0 || proto->Spells[i].SpellTrigger != ITEM_SPELLTRIGGER_ON_USE)
                    continue;
                uint32 const spell = uint32(proto->Spells[i].SpellId);
                // the credits the spell gives, itself or through the spells it triggers
                std::set<uint32> credits;
                std::vector<uint32> chain{ spell };
                for (size_t n = 0; n < chain.size() && n < 6; ++n)
                    if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(chain[n]))
                        for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                        {
                            if (spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT || spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT2)
                                credits.insert(uint32(spellInfo->Effects[e].MiscValue));
                            if (spellInfo->Effects[e].TriggerSpell)
                                chain.push_back(spellInfo->Effects[e].TriggerSpell);
                        }
                // batch 11d: the item makes an objective item, or completes a quest without objectives
                if (SpellInfo const* useInfo = sSpellMgr->GetSpellInfo(spell))
                {
                    std::set<uint32> made;
                    bool completes = false;
                    for (uint32 s : chain)
                        if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(s))
                            for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                            {
                                uint32 const effect = spellInfo->Effects[e].Effect;
                                if (effect == SPELL_EFFECT_QUEST_COMPLETE && uint32(spellInfo->Effects[e].MiscValue) == quest->GetQuestId())
                                    completes = true;
                                if ((effect == SPELL_EFFECT_CREATE_ITEM || effect == SPELL_EFFECT_CREATE_ITEM_2) && spellInfo->Effects[e].ItemType)
                                    made.insert(spellInfo->Effects[e].ItemType);
                            }
                    // batch 11j: the spell summons the credit creature of an objective (a helper)
                    {
                        std::set<uint32> summoned;
                        for (uint32 s : chain)
                            if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(s))
                                for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                                    if (spellInfo->Effects[e].Effect == SPELL_EFFECT_SUMMON && spellInfo->Effects[e].MiscValue > 0)
                                        summoned.insert(uint32(spellInfo->Effects[e].MiscValue));
                        for (QuestObjective const& obj : quest->GetObjectives())
                        {
                            if (obj.Type != QUEST_OBJECTIVE_MONSTER || !summoned.count(obj.ObjectID))
                                continue;
                            BotLifeQuestUse use;
                            use.item = proto->ItemId;
                            use.spell = spell;
                            use.credit = obj.ObjectID;
                            auto fd = helperFeeders.find(obj.ObjectID);
                            if (fd != helperFeeders.end())
                                for (uint32 feeder : fd->second)
                                    if (_creatureSpawns.count(feeder))
                                        use.creatures.push_back(feeder);
                            bool usable = true;
                            if (useInfo->RequiresSpellFocus)
                            {
                                auto fo = _focusObjects.find(useInfo->RequiresSpellFocus);
                                if (fo != _focusObjects.end())
                                    for (uint32 entry : fo->second)
                                        if (_goSpawns.count(entry))
                                            use.objects.push_back(entry);
                                usable = !use.objects.empty();
                            }
                            else if (use.creatures.empty() && (useInfo->NeedsExplicitUnitTarget() || useInfo->AreaGroupId > 0))
                                usable = false;   // a place or a target nothing in the data names
                            if (usable)
                                _questUse[quest->GetQuestId()].push_back(use);
                        }
                    }
                    // the spell calls up a companion that is no objective (the Gilnean Mastiff of
                    // From the Shadows): the bot uses the item again whenever its companion is gone, as a player does
                    {
                        std::set<uint32> objectiveMonsters;
                        for (QuestObjective const& obj : quest->GetObjectives())
                            if (obj.Type == QUEST_OBJECTIVE_MONSTER)
                                objectiveMonsters.insert(uint32(obj.ObjectID));
                        for (uint32 s : chain)
                            if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(s))
                                for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                                {
                                    if (spellInfo->Effects[e].Effect != SPELL_EFFECT_SUMMON || spellInfo->Effects[e].MiscValue <= 0)
                                        continue;
                                    uint32 const entry = uint32(spellInfo->Effects[e].MiscValue);
                                    CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(entry);
                                    if (!ct || objectiveMonsters.count(entry) || objectiveMonsters.empty() || ct->type == CREATURE_TYPE_CRITTER)
                                        continue;
                                    BotLifeQuestUse use;
                                    use.item = proto->ItemId;
                                    use.spell = spell;
                                    use.companion = entry;
                                    _questUse[quest->GetQuestId()].push_back(use);
                                    added = true;
                                }
                    }
                    // batch 11s: the spell hits a creature that calls up the one dropping an objective item
                    {
                        auto hs = spellHitSummons.find(spell);
                        if (hs != spellHitSummons.end())
                            for (QuestObjective const& obj : quest->GetObjectives())
                            {
                                if (obj.Type != QUEST_OBJECTIVE_ITEM)
                                    continue;
                                auto drops = _itemCreatureSources.find(obj.ObjectID);
                                if (drops == _itemCreatureSources.end())
                                    continue;
                                for (auto const& hit : hs->second)
                                {
                                    if (!_creatureSpawns.count(hit.first)
                                        || std::find(drops->second.begin(), drops->second.end(), hit.second) == drops->second.end())
                                        continue;
                                    BotLifeQuestUse use;
                                    use.item = proto->ItemId;
                                    use.spell = spell;
                                    use.makes = obj.ObjectID;
                                    use.summoned = hit.second;
                                    use.creatures.push_back(hit.first);
                                    _questUse[quest->GetQuestId()].push_back(use);
                                    added = true;
                                }
                            }
                    }
                    // the spell hits a creature that gives the credit of an objective
                    for (QuestObjective const& obj : quest->GetObjectives())
                    {
                        if (obj.Type != QUEST_OBJECTIVE_MONSTER || credits.count(uint32(obj.ObjectID)))
                            continue;
                        BotLifeQuestUse use;
                        use.item = proto->ItemId;
                        use.spell = spell;
                        use.hitCredit = uint32(obj.ObjectID);
                        for (uint32 s : chain)
                        {
                            auto hc = spellHitCredits.find(s);
                            if (hc == spellHitCredits.end())
                                continue;
                            for (auto const& hit : hc->second)
                                if (hit.second == use.hitCredit && _creatureSpawns.count(hit.first)
                                    && std::find(use.creatures.begin(), use.creatures.end(), hit.first) == use.creatures.end())
                                    use.creatures.push_back(hit.first);
                        }
                        // or the spell has to be used on the objective creature itself
                        // (its target condition names it): a script behind the spell gives the credit
                        for (uint32 s : chain)
                        {
                            auto st = spellTargets.find(s);
                            if (st == spellTargets.end())
                                continue;
                            for (uint32 entry : st->second)
                                if (entry == use.hitCredit && _creatureSpawns.count(entry)
                                    && std::find(use.creatures.begin(), use.creatures.end(), entry) == use.creatures.end())
                                    use.creatures.push_back(entry);
                        }
                        if (!use.creatures.empty())
                        {
                            _questUse[quest->GetQuestId()].push_back(use);
                            added = true;
                        }
                    }
                    std::vector<uint32> wanted;
                    if (completes && quest->GetObjectives().empty())
                        wanted.push_back(0);
                    for (QuestObjective const& obj : quest->GetObjectives())
                        if (obj.Type == QUEST_OBJECTIVE_ITEM && made.count(obj.ObjectID) && uint32(obj.ObjectID) != quest->GetSrcItemId())
                            wanted.push_back(obj.ObjectID);
                    if (!wanted.empty())
                    {
                        BotLifeQuestUse use;
                        use.item = proto->ItemId;
                        use.spell = spell;
                        bool usable = true;
                        if (useInfo->RequiresSpellFocus)
                        {
                            auto fo = _focusObjects.find(useInfo->RequiresSpellFocus);
                            if (fo != _focusObjects.end())
                                for (uint32 entry : fo->second)
                                    if (_goSpawns.count(entry))
                                        use.objects.push_back(entry);
                            usable = !use.objects.empty();
                        }
                        else
                        {
                            for (uint32 s : chain)
                            {
                                auto st = spellTargets.find(s);
                                if (st != spellTargets.end())
                                    for (uint32 creature : st->second)
                                        if (_creatureSpawns.count(creature))
                                            use.creatures.push_back(creature);
                                if (corpseSpells.count(s))
                                    use.corpse = true;
                            }
                            // a target or a place nothing in the data names
                            if (use.creatures.empty() && (useInfo->NeedsExplicitUnitTarget() || useInfo->AreaGroupId > 0))
                                usable = false;
                        }
                        if (usable)
                            for (uint32 item : wanted)
                            {
                                use.makes = item;
                                _questUse[quest->GetQuestId()].push_back(use);
                            }
                    }
                }
                for (QuestObjective const& obj : quest->GetObjectives())
                {
                    if (obj.Type != QUEST_OBJECTIVE_MONSTER)
                        continue;
                    if (!credits.count(obj.ObjectID))
                    {
                        // no credit in the spell itself: a scripted creature (C++) gives it when the
                        // item of the quest hits it (Lazy Peons: the blackjack)
                        CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(obj.ObjectID);
                        if (credits.empty() && ct && ct->ScriptID && _creatureSpawns.count(obj.ObjectID) && !_creditSources.count(obj.ObjectID))
                        {
                            _creditSources[obj.ObjectID].push_back(BotLifeCreditSource{ obj.ObjectID, spell });
                            added = true;
                        }
                        continue;
                    }
                    std::vector<uint32> targets;
                    for (uint32 s : chain)
                    {
                        auto st = spellTargets.find(s);
                        if (st != spellTargets.end())
                            targets.insert(targets.end(), st->second.begin(), st->second.end());
                    }
                    targets.push_back(obj.ObjectID);
                    auto kc = _killCreditSources.find(obj.ObjectID);
                    if (kc != _killCreditSources.end())
                        targets.insert(targets.end(), kc->second.begin(), kc->second.end());
                    for (uint32 creature : targets)
                    {
                        if (!_creatureSpawns.count(creature))
                            continue;
                        auto& list = _creditSources[obj.ObjectID];
                        if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s) { return s.creature == creature && s.spell == spell; }))
                            list.push_back(BotLifeCreditSource{ creature, spell });
                        added = true;
                    }
                }
            }
            if (added)
                ++itemQuests;
        }
        // batch 11o: a tool the quest does not hand out makes the objective item - when the tool lies or
        // drops somewhere in the open world, or a vendor sells it
        uint32 toolQuests = 0;
        for (auto const& qp : sObjectMgr->GetQuestTemplates())
        {
            Quest const* quest = qp.second;
            for (QuestObjective const& obj : quest->GetObjectives())
            {
                auto tl = obj.Type == QUEST_OBJECTIVE_ITEM ? toolItems.find(obj.ObjectID) : toolItems.end();
                if (tl == toolItems.end())
                    continue;
                for (auto const& tool : tl->second)
                {
                    if (tool.first == quest->GetSrcItemId())
                        continue;   // handed out: the uses above
                    auto& uses = _questUse[quest->GetQuestId()];
                    if (std::any_of(uses.begin(), uses.end(), [&](BotLifeQuestUse const& u) { return u.item == tool.first && u.makes == uint32(obj.ObjectID); }))
                        continue;
                    bool source = _itemVendorSources.count(tool.first) != 0;
                    auto gs = _itemGoSources.find(tool.first);
                    if (gs != _itemGoSources.end())
                        for (uint32 go : gs->second)
                            if (_goSpawns.count(go))
                                source = true;
                    auto cs = _itemCreatureSources.find(tool.first);
                    if (cs != _itemCreatureSources.end())
                        for (uint32 creature : cs->second)
                            if (_creatureSpawns.count(creature))
                                source = true;
                    SpellInfo const* useInfo = sSpellMgr->GetSpellInfo(tool.second);
                    if (!source || !useInfo)
                        continue;
                    BotLifeQuestUse use;
                    use.item = tool.first;
                    use.spell = tool.second;
                    use.makes = obj.ObjectID;
                    use.tool = true;
                    if (useInfo->RequiresSpellFocus)
                    {
                        auto fo = _focusObjects.find(useInfo->RequiresSpellFocus);
                        if (fo != _focusObjects.end())
                            for (uint32 entry : fo->second)
                                if (_goSpawns.count(entry))
                                    use.objects.push_back(entry);
                        if (use.objects.empty())
                            continue;
                    }
                    else
                    {
                        auto st = spellTargets.find(tool.second);
                        if (st != spellTargets.end())
                            for (uint32 creature : st->second)
                                if (_creatureSpawns.count(creature))
                                    use.creatures.push_back(creature);
                        use.corpse = corpseSpells.count(tool.second) != 0;
                        if (use.creatures.empty() && (useInfo->NeedsExplicitUnitTarget() || useInfo->AreaGroupId > 0))
                            continue;
                    }
                    uses.push_back(use);
                    ++toolQuests;
                }
            }
        }
        for (auto it = _questUse.begin(); it != _questUse.end();)
            it = it->second.empty() ? _questUse.erase(it) : std::next(it);
        TC_LOG_INFO("playerbots", "BotLife: {} tools that make an objective item", toolQuests);
        // batch 11t: an item no quest hands out whose spell gives the credit of an objective on a named
        // target: that target is a source of the credit with that spell
        {
            std::set<uint32> monsterCredits;
            for (auto const& qp : sObjectMgr->GetQuestTemplates())
                for (QuestObjective const& obj : qp.second->GetObjectives())
                    if (obj.Type == QUEST_OBJECTIVE_MONSTER && obj.ObjectID)
                        monsterCredits.insert(obj.ObjectID);
            for (auto const& it : *sObjectMgr->GetItemTemplateStore())
                for (uint8 i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
                {
                    ItemTemplate const& proto = it.second;
                    if (proto.Spells[i].SpellId <= 0 || proto.Spells[i].SpellTrigger != ITEM_SPELLTRIGGER_ON_USE)
                        continue;
                    uint32 const spell = uint32(proto.Spells[i].SpellId);
                    std::set<uint32> credits;
                    std::vector<uint32> chain{ spell };
                    for (size_t n = 0; n < chain.size() && n < 4; ++n)
                        if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(chain[n]))
                            for (uint8 e = 0; e < MAX_SPELL_EFFECTS; ++e)
                            {
                                if ((spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT || spellInfo->Effects[e].Effect == SPELL_EFFECT_KILL_CREDIT2)
                                    && monsterCredits.count(uint32(spellInfo->Effects[e].MiscValue)))
                                    credits.insert(uint32(spellInfo->Effects[e].MiscValue));
                                if (spellInfo->Effects[e].TriggerSpell)
                                    chain.push_back(spellInfo->Effects[e].TriggerSpell);
                            }
                    if (credits.empty())
                        continue;
                    std::set<uint32> targets;
                    for (uint32 s : chain)
                    {
                        auto st = spellTargets.find(s);
                        if (st != spellTargets.end())
                            for (uint32 creature : st->second)
                                if (_creatureSpawns.count(creature))
                                    targets.insert(creature);
                    }
                    for (uint32 credit : credits)
                        for (uint32 target : targets)
                        {
                            auto& list = _creditSources[credit];
                            if (std::none_of(list.begin(), list.end(), [&](BotLifeCreditSource const& s) { return s.creature == target && s.spell == spell; }))
                                list.push_back(BotLifeCreditSource{ target, spell });
                        }
                }
            // every spell of a credit source: the items that cast it on use, and the creatures that drop them
            std::set<uint32> sourceSpells;
            for (auto const& cs : _creditSources)
                for (BotLifeCreditSource const& src : cs.second)
                    if (src.spell)
                        sourceSpells.insert(src.spell);
            _spellTools.clear();
            std::vector<uint32> toolList;
            for (auto const& it : *sObjectMgr->GetItemTemplateStore())
                for (uint8 i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
                    if (it.second.Spells[i].SpellId > 0 && it.second.Spells[i].SpellTrigger == ITEM_SPELLTRIGGER_ON_USE
                        && sourceSpells.count(uint32(it.second.Spells[i].SpellId)))
                    {
                        _spellTools[uint32(it.second.Spells[i].SpellId)].push_back(it.first);
                        toolList.push_back(it.first);
                    }
            for (size_t from = 0; from < toolList.size(); from += 1000)
                if (QueryResult result = WorldDatabase.PQuery("SELECT ct.entry, clt.item FROM creature_loot_template clt "
                    "JOIN creature_template ct ON ct.lootid = clt.entry WHERE clt.mincountOrRef > 0 AND clt.item IN ({})",
                    JoinIds(toolList, from, std::min(toolList.size(), from + 1000))))
                {
                    do
                    {
                        Field* f = result->Fetch();
                        auto& list = _itemCreatureSources[f[1].GetUInt32()];
                        if (std::find(list.begin(), list.end(), f[0].GetUInt32()) == list.end())
                            list.push_back(f[0].GetUInt32());
                    } while (result->NextRow());
                }
            TC_LOG_INFO("playerbots", "BotLife: {} spells of credit sources an item casts ({} items)", _spellTools.size(), toolList.size());
        }
        TC_LOG_INFO("server.loading", ">> BotLife: {} quests with an item to use on a creature, {} credits that come from a talk, a spell or an item, "
            "{} quests whose item makes the objective or completes the quest", itemQuests, _creditSources.size(), _questUse.size());
    }

    // --- grind spots from creature spawns + zone level bands
    std::unordered_map<uint32, std::vector<uint8>> zoneLevelSamples;
    uint32 grindCount = 0;
    for (auto const& cs : _creatureSpawns)
    {
        CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(cs.first);
        if (!ct || ct->rank != CREATURE_ELITE_NORMAL || !ct->lootid || ct->npcflag || phasedOnly.count(cs.first))   // (batch 11p)
            continue;
        if (ct->type == CREATURE_TYPE_CRITTER || ct->type == CREATURE_TYPE_NON_COMBAT_PET || ct->type == CREATURE_TYPE_TOTEM)
            continue;
        if (ct->unit_flags & (UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_IMMUNE_TO_PC))
            continue;
        if (ct->minlevel < 1 || ct->maxlevel > MAX_BOTLIFE_LEVEL || ct->minlevel > ct->maxlevel)
            continue;
        FactionTemplateEntry const* ft = sFactionTemplateStore.LookupEntry(ct->faction);
        if (!ft || (!ft->IsHostileToPlayers() && !ft->IsNeutralToAll()))
            continue;

        for (BotLifeSpawn const& s : cs.second)
        {
            auto& levels = _grind[s.map];
            if (levels.empty())
                levels.resize(MAX_BOTLIFE_LEVEL + 1);
            BotLifeGrindSpot spot;
            spot.x = s.x;
            spot.y = s.y;
            spot.z = s.z;
            spot.zone = s.zone;
            spot.faction = ct->faction;
            levels[ct->minlevel].push_back(spot);
            if (ct->maxlevel != ct->minlevel)
                levels[ct->maxlevel].push_back(spot);
            ++grindCount;
            if (s.zone)
                zoneLevelSamples[s.zone].push_back(uint8((ct->minlevel + ct->maxlevel) / 2));
        }
    }

    // farm spots from the playerbots database (curated), valid for their whole level range
    if (QueryResult result = PlayerbotsDatabase.Query("SELECT z.MapId, z.ZoneId, s.X, s.Y, s.Z, s.MinLevel, s.MaxLevel, s.TeamsDisabled "
        "FROM playerbot_farming_spot s JOIN playerbot_farming_zone z ON z.ZoneId = s.ZoneId"))
    {
        do
        {
            Field* f = result->Fetch();
            uint32 map = f[0].GetUInt32();
            uint32 minL = std::max<uint32>(1, f[5].GetUInt32());
            uint32 maxL = std::min<uint32>(MAX_BOTLIFE_LEVEL, f[6].GetUInt32());
            if (minL > maxL || maxL - minL > 15)
                continue;
            auto& levels = _grind[map];
            if (levels.empty())
                levels.resize(MAX_BOTLIFE_LEVEL + 1);
            BotLifeGrindSpot spot;
            spot.zone = uint16(f[1].GetUInt32());
            spot.x = f[2].GetFloat();
            spot.y = f[3].GetFloat();
            spot.z = f[4].GetFloat();
            spot.teamDisabled = f[7].GetUInt32();
            for (uint32 l = minL; l <= maxL; ++l)
                levels[l].push_back(spot);
        } while (result->NextRow());
    }

    for (auto& zs : zoneLevelSamples)
    {
        if (zs.second.size() < 12)
            continue;
        std::sort(zs.second.begin(), zs.second.end());
        BotLifeZoneLevels zl;
        zl.low = zs.second[zs.second.size() / 10];
        zl.high = zs.second[(zs.second.size() * 9) / 10];
        _zoneLevels[zs.first] = zl;
    }

    // town spots: service NPCs (vendor, trainer, banker, auctioneer, innkeeper) in the cities
    {
        static std::unordered_map<uint32, uint8> const cities = {
            { 1637, 0 }, { 1638, 0 }, { 1497, 0 }, { 3487, 0 },     // Orgrimmar, Thunder Bluff, Undercity, Silvermoon
            { 1519, 0 }, { 1537, 0 }, { 1657, 0 }, { 3557, 0 },     // Stormwind, Ironforge, Darnassus, Exodar
            { 3703, 1 }, { 4395, 2 }, { 5840, 3 }, { 6553, 3 }, { 6141, 3 } };   // Shattrath, Dalaran, Vale / Shrines
        uint32 flags = UNIT_NPC_FLAG_VENDOR | UNIT_NPC_FLAG_TRAINER | UNIT_NPC_FLAG_BANKER | UNIT_NPC_FLAG_AUCTIONEER | UNIT_NPC_FLAG_INNKEEPER;
        for (auto const& cs : _creatureSpawns)
        {
            CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(cs.first);
            if (!ct || !(ct->npcflag & flags) || phasedOnly.count(cs.first))   // (batch 11p)
                continue;
            for (BotLifeSpawn const& s : cs.second)
            {
                auto city = cities.find(s.zone);
                if (city == cities.end())
                    continue;
                BotLifeTownSpot spot;
                spot.map = s.map;
                spot.zone = s.zone;
                spot.x = s.x;
                spot.y = s.y;
                spot.z = s.z;
                spot.faction = ct->faction;
                spot.band = city->second;
                _townSpots.push_back(spot);
            }
        }
    }

    TC_LOG_INFO("server.loading", ">> BotLife: {} town spots", _townSpots.size());
    LoadBankerSpots();
    LoadAreaTriggers();

    LoadTexts();
    LoadDungeons();
    LoadBadQuests();
    _statsSince = getMSTime();
    _loaded = true;

    TC_LOG_INFO("server.loading", ">> BotLife: {} creature spawns, {} quest giver spawns, {} objective items ({} with creature source, {} with object source, {} object spawns), {} grind spots, {} zone level bands in {} ms",
        spawnCount, giverCount, items.size(), _itemCreatureSources.size(), _itemGoSources.size(), goSpawnCount, grindCount,
        _zoneLevels.size(), GetMSTimeDiffToNow(oldMSTime));
}

// ---------------------------------------------------------------------------------------------
// main bot hook

void BotLifeMgr::QueueTeleport(Player* member, uint32 map, float x, float y, float z, float o)
{
    PlayerbotAI* ai = member ? GET_PLAYERBOT_AI(member) : nullptr;
    if (!ai)
        return;   // only random bots are relocated this way; real players are never touched cross-thread
    BotLifeInfo& mt = ai->life;
    mt.teleQueued = true;
    mt.teleMap = map;
    mt.teleX = x;
    mt.teleY = y;
    mt.teleZ = z;
    mt.teleO = o;
}

void BotLifeMgr::QueueReset(Player* member)
{
    PlayerbotAI* ai = member ? GET_PLAYERBOT_AI(member) : nullptr;
    if (ai)
        ai->life.resetQueued = true;
}

void BotLifeMgr::QueueCombatStop(Player* member)
{
    PlayerbotAI* ai = member ? GET_PLAYERBOT_AI(member) : nullptr;
    if (ai)
        ai->life.combatStopQueued = true;
}

// Runs on the map thread of the bot itself (from PlayerbotAI::UpdateAIInternal, before the minimal gate). Performs any queued
// combat-stop, reset and teleport in that order. Returns true if anything was done so the caller can end the tick early.
bool BotLifeMgr::RunPendingActions(PlayerbotAI* botAI)
{
    if (!botAI)
        return false;
    BotLifeInfo& t = botAI->life;
    if (!t.teleQueued && !t.resetQueued && !t.combatStopQueued)
        return false;
    Player* bot = botAI->GetBot();
    if (!bot || !bot->IsInWorld() || !bot->GetSession())
    {
        t.teleQueued = t.resetQueued = t.combatStopQueued = false;
        return false;
    }
    bool acted = false;
    if (t.combatStopQueued)
    {
        t.combatStopQueued = false;
        if (!bot->IsBeingTeleported())
        {
            bot->CombatStop(true);
            acted = true;
        }
    }
    if (t.resetQueued)
    {
        t.resetQueued = false;
        if (!bot->IsBeingTeleported())
        {
            botAI->Reset();
            acted = true;
        }
    }
    if (t.teleQueued)
    {
        t.teleQueued = false;
        if (!bot->IsBeingTeleported())
        {
            bot->TeleportTo(t.teleMap, t.teleX, t.teleY, t.teleZ, t.teleO);
            acted = true;
        }
    }
    return acted;
}

bool BotLifeMgr::UpdateBot(PlayerbotAI* botAI, uint32 /*elapsed*/)
{
    if (!_enabled || !_loaded || !botAI)
        return false;

    Player* bot = botAI->GetBot();
    if (!bot || !bot->IsInWorld() || !bot->GetSession())
        return false;

    if (!sRandomPlayerbotMgr->IsRandomBot(bot))
        return false;

    BotLifeInfo& t = botAI->life;
    uint32 now = getMSTime();

    if (_castDiagLeft.load(std::memory_order_relaxed) > 0 && bot->IsInCombat())
        CastDiag(botAI);
    if (_aggroDiagLeft.load(std::memory_order_relaxed) > 0 && bot->IsInCombat())
        AggroDiag(botAI);
    if (_testLevelLeft.load(std::memory_order_relaxed) > 0 && TestLevelBot(botAI, t, now))
        return true;
    if (_pathProbePending.load(std::memory_order_acquire) && bot->GetMapId() == _pathProbeMap && !bot->GetMap()->Instanceable())
    {
        bool expected = true;
        if (_pathProbePending.compare_exchange_strong(expected, false))
            PathProbe(bot);
    }
    if (_rangeTestLeft.load(std::memory_order_relaxed) > 0 || t.rangeTestPhase)
        RangeTest(botAI, t, now);

    if (bot->GetClass() == CLASS_DEATH_KNIGHT && bot->GetMapId() == 609 && DeathKnightEye(bot, t, now))
        return true;

    bool const walker = IsWalker(bot);
    if (walker)
        WalkTick(bot, t, now);

    if (bot->IsAlive() && !bot->IsBeingTeleported() && !bot->IsInFlight())
        CheckAreaTriggers(bot, t, now);

    if (!t.weaponChecked && bot->IsAlive() && !bot->IsInCombat())
    {
        t.weaponChecked = true;
        EnsureGear(botAI);
        EnsureWeapon(bot);
        EnsureBags(bot);
    }
    // guild banker - lives at the capital's guild vault, auctioneer and mailbox
    if (now >= t.nextBankerCheck)
    {
        t.nextBankerCheck = now + 10000;
        bool banker = _guildBankers && IsBanker(bot->GetGUID());
        if (banker != t.banker)
        {
            t.banker = banker;
            t.bankerStep = 0;
            t.bankerDestSet = false;
            t.bankerWaitUntil = 0;
            if (banker)
                SetState(bot, t, BotLifeState::IDLE, now, 0);
        }
    }
    if (t.banker && !walker && !bot->GetGroup() && !bot->InBattleground() && !botAI->HasRealPlayerMaster())
        return BankerUpdate(botAI, t, now);
    if (t.relocateAfterDeaths && !walker && bot->IsAlive() && !bot->IsInCombat() && !bot->GetGroup() && !bot->IsBeingTeleported())
    {
        if (RelocateForLevel(bot))
        {
            t.relocateAfterDeaths = false;
            Count(BLC_DEATH_RELOCATE);
            return true;
        }
    }
    if (now >= t.nextGearCheck && bot->IsAlive() && !bot->IsInCombat())
    {
        t.nextGearCheck = now + 60000;
        EquipBagUpgrades(bot);
        EnsureProfessions(bot);
        // bots had a specialization but no talent at all (the WotLK talent links in playerbots.conf are
        // not read by this port; MoP lists added) - fill up what the level allows
        if (bot->GetLevel() >= 15 && bot->GetSpecialization() != Specializations::SPEC_NONE
            && bot->GetUsedTalentCount() < bot->CalculateTalentsPoints())
        {
            BotFactory factory(bot, bot->GetLevel());
            factory.InitTalentsTree(false);
            Count(BLC_TALENTS);
        }
    }
    // gathering also for group members and bots that follow a player, and inside instances
    // (skinning dungeon mobs, ore/herbs there) - not for whoever leads a dungeon run (the run would stall)
    bool leadsRun = bot->GetMap()->Instanceable() && (t.lfgLeadInstance == bot->GetInstanceId()
        || ((t.party == BOTLIFE_PARTY_DUNGEON || t.party == BOTLIFE_PARTY_RAID) && bot->GetGroup() && bot->GetGroup()->GetLeaderGUID() == bot->GetGUID()));
    if (_professions && !walker && bot->IsAlive() && !bot->IsInCombat() && !bot->IsMounted() && !leadsRun
        && GatherBusiness(botAI, t, now))
        return true;
    // a few casts with the fishing line when there is water in front of the bot
    if (_professions && _fishing && !walker && bot->IsAlive() && !bot->IsInCombat() && !bot->IsMounted() && !bot->InBattleground()
        && !bot->GetMap()->Instanceable()   // not in dungeons and raids (a fishing leader stalled the run)
        && !botAI->HasRealPlayerMaster() && FishBusiness(botAI, t, now))
        return true;

    // battlegrounds come first: the battleground raid group is not a bot life party
    if (bot->InBattleground())
        return _battlegrounds && BattlegroundBotUpdate(botAI, t, now);

    // bots that belong to a real player (group / master) keep the normal follow behaviour;
    // in a bot life party only the leader lives, the members follow and assist (and loot / rest)
    Group* group = bot->GetGroup();
    // killed twice by the same creature: release to the graveyard and revive there
    if (t.graveyardRevive && !bot->IsAlive() && !bot->InBattleground() && !bot->GetMap()->Instanceable())
    {
        if (now >= t.graveyardRevive)
        {
            t.graveyardRevive = 0;
            if (!bot->HasPlayerFlag(PLAYER_FLAGS_GHOST))
                bot->BuildPlayerRepop();
            bot->RepopAtGraveyard();
            bot->ResurrectPlayer(0.5f);
            bot->SpawnCorpseBones();
            t.path.clear();
            t.pathIdx = 0;
            t.lastProgressCheck = 0;
            TC_LOG_INFO("playerbots", "BotLife {}: killed again by the same creature, revived at the graveyard ({:.0f} {:.0f} {:.0f} map {})",
                bot->GetName(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), bot->GetMapId());
            Count(BLC_GHOST_REVIVE);
            return true;
        }
        return false;
    }
    if (t.graveyardRevive && bot->IsAlive())
        t.graveyardRevive = 0;   // revived by something else in the meantime

    // a dead bot that follows a real player walks after its master as a ghost and never reaches its corpse:
    // once the master is alive and out of combat, the bot comes back to life where it is
    if ((botAI->HasRealPlayerMaster() || (t.lfgMaster && botAI->GetMaster())) && !bot->IsAlive() && !bot->InBattleground())
    {
        if (!t.deadSince)
            t.deadSince = now;
        Player* master = botAI->GetMaster();
        if (now - t.deadSince > 20000 && master && master->IsAlive() && !master->IsInCombat() && master->FindMap() == bot->FindMap())
        {
            bot->ResurrectPlayer(0.5f);
            bot->SpawnCorpseBones();
            if (bot->GetDistance(master) > 30.0f)
                bot->NearTeleportTo(master->GetPositionX(), master->GetPositionY(), master->GetPositionZ(), master->GetOrientation());
            t.deadSince = 0;
            Count(BLC_GHOST_REVIVE);
        }
        return false;
    }
    if (botAI->HasRealPlayerMaster() && bot->IsAlive())
        if (Player* master = botAI->GetMaster())
            MasterQuestSync(bot, master, t, now);
    // inside a 5-man dungeon a group with a real player does not wait for him - the tank bot
    // leads through the dungeon like a bot dungeon party (real players are not waited for), the other bots follow it
    Player* lfgLeadBot = nullptr;
    if (group && !t.party && bot->IsInWorld() && bot->GetMap()->IsDungeon() && !bot->GetMap()->IsRaid())
    {
        bool hasReal = false;
        Player* tank = nullptr;
        Player* first = nullptr;
        for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
        {
            Player* member = ref->GetSource();
            if (!member || !member->GetSession())
                continue;
            if (!member->GetSession()->IsBot())
            {
                hasReal = true;
                continue;
            }
            if (!member->IsInWorld() || member->GetMap() != bot->GetMap())
                continue;
            if (!first || member->GetGUID() < first->GetGUID())
                first = member;
            if (member->GetRoleForGroup() == ROLES_TANK && (!tank || member->GetGUID() < tank->GetGUID()))
                tank = member;
        }
        if (hasReal || IsLfgTestBot(bot->GetGUID()))
            lfgLeadBot = tank ? tank : first;
    }
    if (lfgLeadBot == bot)
    {
        if (botAI->GetMaster())
        {
            botAI->SetMaster(nullptr);
            botAI->ResetStrategies();
            t.lfgMaster = false;
        }
        if (t.lfgLeadInstance != bot->GetInstanceId())
        {
            t.lfgLeadInstance = bot->GetInstanceId();
            t.dungeonTarget = 0;
            t.dungeonTargetSince = 0;
            t.dungeonEngageSince = 0;
            t.dungeonSkip.clear();
            t.dungeonDone = false;
            t.dungeonKills = 0;
            t.dungeonBosses = 0;
            t.ResetDungeonExtras();
            Count(BLC_LFG_LEAD);
        }
        if (!bot->IsAlive())
        {
            // no world-thread party here: back up next to a living group member after a while
            if (!t.deadSince)
                t.deadSince = now;
            if (now - t.deadSince > 20000)
                for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                {
                    Player* member = ref->GetSource();
                    if (!member || member == bot || !member->IsAlive() || member->IsInCombat() || member->GetMap() != bot->GetMap())
                        continue;
                    bot->ResurrectPlayer(0.5f);
                    bot->SpawnCorpseBones();
                    bot->NearTeleportTo(member->GetPositionX(), member->GetPositionY(), member->GetPositionZ(), member->GetOrientation());
                    t.deadSince = 0;
                    Count(BLC_GHOST_REVIVE);
                    break;
                }
            return false;
        }
        t.deadSince = 0;
        if (bot->IsBeingTeleported())
            return false;
        if (IsLfgTestBot(bot->GetGUID()) && _lfgTestDungeon.load() && LfgTestLeadTick(bot, t, now))
            return true;   // the holiday boss event of a dungeon finder test
        return DungeonLeaderUpdate(botAI, t, now);
    }
    if (lfgLeadBot && botAI->GetMaster() != lfgLeadBot)
    {
        botAI->SetMaster(lfgLeadBot);
        botAI->ResetStrategies();
        botAI->ChangeStrategy("+follow", BOT_STATE_NON_COMBAT);
        botAI->Reset();
        t.lfgMaster = true;
    }

    // a random bot in a group with a real player but no master (a dungeon finder group) follows that player;
    // when the player has left the group the bot is on its own again
    if (group && !t.party && !botAI->GetMaster() && !lfgLeadBot)
        for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
        {
            Player* member = ref->GetSource();
            if (!member || member == bot || !member->GetSession() || member->GetSession()->IsBot())
                continue;
            botAI->SetMaster(member);
            botAI->ResetStrategies();
            botAI->ChangeStrategy("+follow", BOT_STATE_NON_COMBAT);
            botAI->Reset();
            t.lfgMaster = true;
            Count(BLC_LFG_MASTER);
            break;
        }
    if (t.lfgMaster && botAI->GetMaster() && (!group || !group->IsMember(botAI->GetMaster()->GetGUID())))
    {
        botAI->SetMaster(nullptr);
        botAI->ResetStrategies();
        t.lfgMaster = false;
    }
    // bots of a dungeon finder group loot their queue out of combat
    // (2-10, batch 11g: only what lies within reach, and not while the player walks on - they stood still
    // after every pull, walking from corpse to corpse)
    if (t.lfgMaster && _loot && bot->IsAlive() && !bot->IsInCombat() && (!t.lootTarget.IsEmpty() || !t.lootQueue.empty()))
    {
        Player* master = botAI->GetMaster();
        if (master && master->IsInMap(bot) && bot->GetExactDist(master) > 20.0f)
        {
            t.lootTarget.Clear();
            t.lootQueue.clear();
        }
        else if (DoLoot(bot, t, now, 8.0f, 5000))
            return true;
    }
    if (botAI->HasRealPlayerMaster() || (group && !t.party))
    {
        if (t.state != BotLifeState::IDLE)
            SetState(bot, t, BotLifeState::IDLE, now, 0);
        return false;
    }
    if (group && group->GetLeaderGUID() != bot->GetGUID())
        return PartyFollowerUpdate(botAI, t, now);

    bool instanceParty = group && (t.party == BOTLIFE_PARTY_DUNGEON || t.party == BOTLIFE_PARTY_RAID);
    if (!bot->IsAlive())
    {
        if (!instanceParty)   // dungeon / raid parties: the world thread resurrects
            HandleDeath(bot, t, now);
        return false;
    }
    t.deadSince = 0;

    if (bot->IsBeingTeleported() || bot->IsInFlight() || bot->InBattleground() || bot->GetVehicle())
        return false;

    Map* map = bot->GetMap();
    if (!map)
        return false;
    if (map->Instanceable())
    {
        // only the leader of a bot life dungeon / raid party gets here (members returned above)
        if (instanceParty)
            return DungeonLeaderUpdate(botAI, t, now);
        // stranded - alone in a dungeon / raid (the party is not restored after a restart); out to the world
        if (!group && now >= t.nextZoneCheck)
        {
            t.nextZoneCheck = now + urand(20000, 40000);
            if (!bot->IsAlive())
            {
                bot->ResurrectPlayer(0.5f);
                bot->SpawnCorpseBones();
            }
            if (RelocateForLevel(bot))
            {
                Count(BLC_STRANDED_OUT);
                SetState(bot, t, BotLifeState::IDLE, now, 0);
                return true;
            }
        }
        return false;
    }
    if (instanceParty)
        return false;   // outside while the party is inside: the world thread brings us back

    if (now >= t.nextRidingCheck)
    {
        t.nextRidingCheck = now + urand(8, 12) * MINUTE * IN_MILLISECONDS;
        EnsureRiding(bot);
    }

    if (bot->IsInCombat())
    {
        // some fights leave a bot stuck IsInCombat()==true with no victim and nothing attacking it
        // (e.g. a lingering combat reference after its target died the instant it was pulled); the bot then does
        // nothing forever (this branch returns before Think/Act runs), stalling a dungeon party. Force-clear combat
        // after 20s without a victim. CombatStop(true) (includingCast) crashed the server 27-9: interrupting a channel can
        if (!bot->GetVictim())
        {
            if (!t.noVictimCombatSince)
                t.noVictimCombatSince = now;
            else if (now - t.noVictimCombatSince > 20000)
            {
                bot->CombatStop(false);   // 27-9: true (includingCast) crashed - see comment above
                t.noVictimCombatSince = 0;
                Count(BLC_PHANTOM_COMBAT_CLEARED);
                return true;
            }
        }
        else
            t.noVictimCombatSince = 0;

        // a fight that goes nowhere blocks every other order from here: a mob out of reach,
        // one that cannot be hurt, one an NPC is already fighting. Nothing moves for a minute: drop it, leave it alone.
        if (Unit* fightTarget = bot->GetVictim())
        {
            if (fightTarget->GetTypeId() == TYPEID_UNIT && !bot->GetGroup() && !bot->GetMap()->Instanceable())
            {
                float const victimHp = fightTarget->GetHealthPct();
                float const botHp = bot->GetHealthPct();
                if (fightTarget->GetGUID() != t.fightVictim || std::fabs(victimHp - t.fightVictimHp) >= 1.0f
                    || std::fabs(botHp - t.fightBotHp) >= 1.0f)
                {
                    t.fightVictim = fightTarget->GetGUID();
                    t.fightVictimHp = victimHp;
                    t.fightBotHp = botHp;
                    t.fightSince = now;
                }
                else if (now - t.fightSince > 60000)
                {
                    TC_LOG_INFO("playerbots", "BotLife: {} drops a fruitless fight with {} ({}) at {:.0f} yd, its health {:.0f}%, left alone for 5 minutes",
                        bot->GetName(), fightTarget->GetName(), fightTarget->GetEntry(), bot->GetDistance(fightTarget), victimHp);
                    t.avoidCreature[fightTarget->GetEntry()] = now + 5 * MINUTE * IN_MILLISECONDS;
                    t.fightVictim = ObjectGuid::Empty;
                    t.ignoreTargetsUntil = now + 30000;
                    bot->AttackStop();
                    bot->CombatStop(false);
                    return true;
                }
            }
        }
        else
            t.fightVictim = ObjectGuid::Empty;

        // a chase started by BotLife outside combat keeps running and drags casters into melee:
        // in combat the bot AI decides where to stand
        if (bot->GetMotionMaster()->GetCurrentMovementGeneratorType() == CHASE_MOTION_TYPE && PlayerBotSpec::IsRanged(bot))
        {
            bot->GetMotionMaster()->Clear();
            bot->StopMoving();
        }
        Dismount(bot);
        CombatPotion(bot, t, now);
        if (!group && CombatSelfHeal(bot, t, now))
            return true;
        // attacked while traveling: stop the old travel order so the bot fights instead of dragging the mob along
        if (now - t.lastCombat > 3000 && t.lastMoveOrder && now - t.lastMoveOrder < 8000 && bot->isMoving())
            bot->StopMoving();
        t.lastCombat = now;
        t.targetWaitSince = 0;
        if (t.resting)
            t.resting = false;
        return false;
    }

    if (bot->HasUnitState(UNIT_STATE_CASTING))
        return false;

    // loot our kills first
    if (_loot && (!t.lootTarget.IsEmpty() || !t.lootQueue.empty()))
        if (DoLoot(bot, t, now))
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

    if (group && PartyLeaderWait(bot, t, now))
        return true;

    if (now >= t.nextThink)
    {
        t.nextThink = now + urand(2500, 4500);
        Think(botAI, t, now);
    }

    return Act(botAI, t, now);
}

void BotLifeMgr::SetState(Player* bot, BotLifeInfo& t, BotLifeState state, uint32 now, uint32 duration)
{
    if (_debug && t.state != state)
        TC_LOG_INFO("playerbots", "BotLife {} ({}): state {} -> {} (quest {}, npc {})", bot->GetName(), uint32(bot->GetLevel()),
            uint32(t.state), uint32(state), t.questId, t.npcEntry);

    t.state = state;
    t.stateSince = now;
    t.stateUntil = duration ? now + duration : 0;
    t.path.clear();
    t.pathIdx = 0;
    t.stuck = 0;
    t.lastProgressCheck = 0;
    t.targetWaitSince = 0;
    if (state == BotLifeState::IDLE || state == BotLifeState::REST)
    {
        t.hasDest = false;
        t.questId = 0;
        t.npcEntry = 0;
        t.useGo.Clear();
    }
}

void BotLifeMgr::SetDest(BotLifeInfo& t, uint32 map, float x, float y, float z, float arriveDist)
{
    t.hasDest = true;
    t.destMap = map;
    t.destX = x;
    t.destY = y;
    t.destZ = z;
    t.arriveDist = arriveDist;
    t.path.clear();
    t.pathIdx = 0;
    t.stuck = 0;
    t.lastProgressCheck = 0;
}

bool BotLifeMgr::Arrived(Player* bot, BotLifeInfo const& t) const
{
    return t.hasDest && bot->GetMapId() == t.destMap && bot->GetExactDist2d(t.destX, t.destY) <= t.arriveDist
        && std::fabs(bot->GetPositionZ() - t.destZ) < 12.0f;
}

void BotLifeMgr::Think(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();

    // level/zone fit: high level bots do not belong in starter zones (and vice versa)
    if (_relocate && now >= t.nextZoneCheck && t.state != BotLifeState::TOWN)
    {
        t.nextZoneCheck = now + urand(60000, 120000);
        DeathKnightChainWatch(bot, t, now);
        if (!ZoneFitsLevel(bot) && RelocateForLevel(bot))
        {
            SetState(bot, t, BotLifeState::IDLE, now, 0);
            return;
        }
        // active balance between Eastern Kingdoms and Kalimdor (the busiest map sets the server tick): a solo bot
        // whose level fits both moves now and then when its continent carries 25% more bots than the other one
        uint32 level = bot->GetLevel();
        uint32 mapId = bot->GetMapId();
        // Pandaria -> Isle of Thunder. It was off: the island took no bots and every attempt only moved a level-90 bot to
        // another spot in Pandaria. the cause was Player::Update, which sends everybody without the
        // introduction quest of the island back to the shrine; bots are let in now (Player.cpp), so up to 150 of them
        // leave the busiest continent.
        bool pandaria = mapId == 870 && level >= 90 && MapPopulation(1064) < 150;
        if (((mapId == 0 || mapId == 1) && (level < 58 || (level >= 80 && level < 85)) || pandaria) && !bot->GetGroup() && urand(0, 9) == 0)
        {
            uint32 here = MapPopulation(mapId), there = MapPopulation(pandaria ? 1064 : mapId == 0 ? 1 : 0);
            if (here > there + there / 4 + 20 && RelocateForLevel(bot))
            {
                Count(BLC_REBALANCE);
                SetState(bot, t, BotLifeState::IDLE, now, 0);
                return;
            }
        }
    }

    // timeouts
    if (t.state != BotLifeState::IDLE && t.stateUntil && now >= t.stateUntil)
    {
        switch (t.state)
        {
            case BotLifeState::DO_QUEST:
            case BotLifeState::GO_TURNIN:
                if (t.questId)
                {
                    // a quest that cannot be finished or turned in only blocks a quest log slot
                    t.skipQuests.insert(t.questId);
                    Count(t.state == BotLifeState::DO_QUEST ? BLC_AB_TIMEOUT : BLC_TURNIN_TIMEOUT);
                    AbandonQuest(bot, t, t.questId, t.state == BotLifeState::DO_QUEST ? "objective timeout" : "turn-in timeout");
                }
                break;
            case BotLifeState::TOWN:
                EndTownVisit(bot, t, now);
                return;
            case BotLifeState::GO_QUESTGIVER:
                Count(BLC_GIVER_TIMEOUT);
                if (t.npcEntry)
                    t.avoidNpc[t.npcEntry] = now + 30 * MINUTE * IN_MILLISECONDS;
                break;
            default:
                break;
        }
        SetState(bot, t, BotLifeState::IDLE, now, 0);
    }

    switch (t.state)
    {
        case BotLifeState::IDLE:
            DecideNext(botAI, t, now);
            break;
        case BotLifeState::GO_GRIND:
            if (!t.hasDest || Arrived(bot, t))
            {
                bool keepDest = t.hasDest;
                float x = t.destX, y = t.destY, z = t.destZ;
                SetState(bot, t, BotLifeState::AT_GRIND, now, urand(4, 10) * MINUTE * IN_MILLISECONDS);
                if (keepDest)
                    SetDest(t, bot->GetMapId(), x, y, z, 60.0f);
            }
            break;
        case BotLifeState::AT_GRIND:
            // a finished quest is worth the walk
            if (_quests && urand(0, 99) < 10)
            {
                for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
                {
                    uint32 questId = bot->GetQuestSlotQuestId(slot);
                    if (questId && bot->GetQuestStatus(questId) == QUEST_STATUS_COMPLETE)
                    {
                        SetState(bot, t, BotLifeState::IDLE, now, 0);
                        break;
                    }
                }
            }
            break;
        case BotLifeState::GO_QUESTGIVER:
        {
            // batch 11i: a quest object
            if (t.npcIsGo)
            {
                GameObject* nearGo = nullptr;
                if (t.hasDest && bot->GetMapId() == t.destMap && bot->GetExactDist2d(t.destX, t.destY) < 30.0f)
                    nearGo = bot->FindNearestGameObject(t.npcEntry, 30.0f);
                if (nearGo || Arrived(bot, t))
                {
                    uint32 accepted = nearGo ? AcceptQuestsGo(bot, nearGo, t, now) : 0;
                    if (!accepted)
                    {
                        Count(BLC_GIVER_NOACCEPT);
                        t.avoidNpc[t.npcEntry | 0x80000000] = now + 20 * MINUTE * IN_MILLISECONDS;
                    }
                    SetState(bot, t, BotLifeState::IDLE, now, 0);
                }
                break;
            }
            Creature* nearNpc = nullptr;
            if (t.hasDest && bot->GetMapId() == t.destMap && bot->GetExactDist2d(t.destX, t.destY) < 30.0f)
                nearNpc = bot->FindNearestCreature(t.npcEntry, 30.0f, true);
            // a giver that walks a path - after it
            if (!nearNpc && Arrived(bot, t) && ChaseWalkingNpc(bot, t))
                break;
            if (nearNpc || Arrived(bot, t))
            {
                t.npcChase = 0;
                Creature* npc = nearNpc;
                uint32 accepted = npc ? AcceptQuests(bot, npc, t, now) : 0;
                if (!accepted)
                {
                    Count(BLC_GIVER_NOACCEPT);
                    t.avoidNpc[t.npcEntry] = now + 20 * MINUTE * IN_MILLISECONDS;
                }
                SetState(bot, t, BotLifeState::IDLE, now, 0);
            }
            break;
        }
        case BotLifeState::DO_QUEST:
        {
            Quest const* quest = sObjectMgr->GetQuestTemplate(t.questId);
            QuestStatus status = quest ? bot->GetQuestStatus(t.questId) : QUEST_STATUS_NONE;
            if (!quest || status != QUEST_STATUS_INCOMPLETE)
            {
                SetState(bot, t, BotLifeState::IDLE, now, 0);   // complete -> DecideNext sends us to the ender
                break;
            }
            uint32 progress = QuestProgressValue(bot, quest);
            if (progress != t.questProgressValue)
            {
                t.questProgressValue = progress;
                t.questProgressTime = now;
            }
            else if (now - t.questProgressTime > 6 * MINUTE * IN_MILLISECONDS)
            {
                // no progress here: try another spot, give up after a few attempts
                t.questProgressTime = now;
                if (++t.questRetarget > 3 || !PickObjectiveDest(bot, t, quest))
                {
                    Count(BLC_AB_NOPROGRESS);
                    t.skipQuests.insert(t.questId);
                    AbandonQuest(bot, t, t.questId, "no progress");
                    SetState(bot, t, BotLifeState::IDLE, now, 0);
                }
            }
            break;
        }
        case BotLifeState::GO_TURNIN:
            if (bot->GetQuestStatus(t.questId) != QUEST_STATUS_COMPLETE)
            {
                SetState(bot, t, BotLifeState::IDLE, now, 0);
                break;
            }
            // batch 11i: the ender is a quest object
            if (t.npcIsGo)
            {
                GameObject* go = nullptr;
                if (t.hasDest && bot->GetMapId() == t.destMap && bot->GetExactDist2d(t.destX, t.destY) < 30.0f)
                    go = bot->FindNearestGameObject(t.npcEntry, 30.0f);
                if (go || Arrived(bot, t))
                {
                    if (!go || !TurnIn(bot, go, t.questId))
                    {
                        BotLifeSpawn other;
                        t.avoidEnder[t.npcEntry | 0x80000000] = now + 10 * MINUTE * IN_MILLISECONDS;
                        Count(BLC_TURNIN_FAIL);
                        if (!FindQuestEnder(bot, t.questId, other))
                        {
                            t.skipQuests.insert(t.questId);
                            AbandonQuest(bot, t, t.questId, go ? "turn-in refused" : "ender not at its spawn");
                        }
                    }
                    SetState(bot, t, BotLifeState::IDLE, now, 0);
                }
                break;
            }
            if (Arrived(bot, t) || (t.hasDest && bot->GetMapId() == t.destMap && bot->GetExactDist2d(t.destX, t.destY) < 30.0f
                && bot->FindNearestCreature(t.npcEntry, 30.0f, true)))
            {
                Creature* npc = bot->FindNearestCreature(t.npcEntry, 30.0f, true);
                // an ender that walks a path - after it
                if (!npc && !bot->FindNearestCreature(t.npcEntry, 30.0f, false) && ChaseWalkingNpc(bot, t))
                    break;
                t.npcChase = 0;
                // the ender lies dead at its spot (the other faction, a patrol): wait for the respawn
                if (!npc && bot->FindNearestCreature(t.npcEntry, 30.0f, false))
                {
                    Count(BLC_TURNIN_FAIL);
                    SetState(bot, t, BotLifeState::REST, now, 90 * IN_MILLISECONDS);
                    break;
                }
                if (!npc || !TurnIn(bot, npc, t.questId))
                {
                    if (_debug)
                        TC_LOG_INFO("playerbots", "BotLife {}: turn in of quest {} at npc {} failed: {} (bot {} {} {} map {})", bot->GetName(),
                            t.questId, t.npcEntry, npc ? "turn in refused" : "ender not here", bot->GetPositionX(), bot->GetPositionY(),
                            bot->GetPositionZ(), bot->GetMapId());
                    // wrong spawn or not reachable: try another ender spawn next time, otherwise give up
                    BotLifeSpawn other;
                    t.avoidEnder[t.npcEntry] = now + 10 * MINUTE * IN_MILLISECONDS;
                    Count(BLC_TURNIN_FAIL);
                    if (!FindQuestEnder(bot, t.questId, other))
                    {
                        t.skipQuests.insert(t.questId);
                        AbandonQuest(bot, t, t.questId, npc ? "turn-in refused" : "ender not at its spawn");
                    }
                }
                SetState(bot, t, BotLifeState::IDLE, now, 0);
            }
            break;
        case BotLifeState::REST:
            if (now - t.stateSince > t.stateUntil - t.stateSince)
                SetState(bot, t, BotLifeState::IDLE, now, 0);
            break;
        case BotLifeState::DIG:   // (DigBusiness ends the state itself)
            break;
    }
}

void BotLifeMgr::DecideNext(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();

    // now and then a trip to town (sell, train, bank, auction house) - solo bots only
    if (_townVisits && !bot->GetGroup() && bot->GetLevel() >= 10 && !IsWalker(bot))
    {
        if (!t.nextTownVisit)
            t.nextTownVisit = now + urand(5, _townMinutesMax) * MINUTE * IN_MILLISECONDS;   // spread the first visits
        else if ((now >= t.nextTownVisit || NeedsRepair(bot) || BagsFullOfMaterials(bot)) && StartTownVisit(bot, t, now))
            return;
    }

    if (_quests)
    {
        // 1. finished quests -> turn in
        for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
        {
            uint32 questId = bot->GetQuestSlotQuestId(slot);
            if (!questId || bot->GetQuestStatus(questId) != QUEST_STATUS_COMPLETE || t.skipQuests.count(questId))
                continue;
            BotLifeSpawn ender;
            if (FindQuestEnder(bot, questId, ender))
            {
                SetState(bot, t, BotLifeState::GO_TURNIN, now, 12 * MINUTE * IN_MILLISECONDS);
                t.questId = questId;
                t.npcEntry = ender.entry;
                t.npcIsGo = ender.go;
                SetDest(t, ender.map, ender.x, ender.y, ender.z, 4.0f);
                return;
            }
            Count(BLC_AB_NOENDER);
            t.skipQuests.insert(questId);
            if (QuestElsewhere(bot, questId))
                AbandonQuest(bot, t, questId, "quest is on another map", false);   // the bot was moved: not the quest's fault
            else
                AbandonQuest(bot, t, questId, "no ender in reach");
        }

        // 2. unfinished quests -> go work on them
        for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
        {
            uint32 questId = bot->GetQuestSlotQuestId(slot);
            // failed (event, escort or timer): drop it, as a player does. It stayed in the
            // log for good and was never tried again.
            if (questId && bot->GetQuestStatus(questId) == QUEST_STATUS_FAILED && !t.skipQuests.count(questId))
            {
                t.skipQuests.insert(questId);
                AbandonQuest(bot, t, questId, "failed (event, escort or timer)");
                continue;
            }
            if (!questId || bot->GetQuestStatus(questId) != QUEST_STATUS_INCOMPLETE || t.skipQuests.count(questId))
                continue;
            Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
            // no objectives and still incomplete: the core would have completed it on accept
            if (quest && quest->GetObjectives().empty() && bot->GetQuestStatus(questId) == QUEST_STATUS_INCOMPLETE && bot->CanCompleteQuest(questId))
            {
                bot->CompleteQuest(questId);
                if (IsWalker(bot))
                    TC_LOG_INFO("playerbots", "WALK {} lvl {}: completed {} \"{}\" (no objectives, was incomplete)", bot->GetName(), uint32(bot->GetLevel()), questId, quest->GetLogTitle());
                continue;
            }
            // it came with a chain (auto accept) and the bot cannot do it: done, the chain goes on
            if (quest && !GetPlan(quest).supported && SkipQuest(bot, quest))
                continue;
            // a walker tries a quest of the bad list as well: the log has to show why it fails
            if (!quest || !GetPlan(quest).supported || (IsBadQuest(questId) && !IsWalker(bot)))
            {
                Count(BLC_AB_UNSUPPORTED);
                t.skipQuests.insert(questId);
                AbandonQuest(bot, t, questId, !quest ? "no template" : IsBadQuest(questId) ? "marked bad" : "objective not supported");
                continue;
            }
            auto started = t.questStarted.find(questId);
            if (started == t.questStarted.end())
                t.questStarted[questId] = now;
            else if (now - started->second > _questTimeout)
            {
                Count(BLC_AB_TIMEOUT);
                t.skipQuests.insert(questId);
                AbandonQuest(bot, t, questId, "quest timeout");
                continue;
            }
            SetState(bot, t, BotLifeState::DO_QUEST, now, _questTimeout);
            t.questId = questId;
            t.questRetarget = 0;
            t.questIdleSince = 0;
            t.questProgressValue = QuestProgressValue(bot, quest);
            t.questProgressTime = now;
            if (PickObjectiveDest(bot, t, quest))
                return;
            Count(BLC_AB_NODEST);
            t.skipQuests.insert(questId);
            if (QuestElsewhere(bot, questId))
                AbandonQuest(bot, t, questId, "quest is on another map", false);
            else
                AbandonQuest(bot, t, questId, "no objective source in reach");
            SetState(bot, t, BotLifeState::IDLE, now, 0);
        }

        // 3. look for a quest giver 
        if (ActiveQuestCount(bot) < _maxQuests && (urand(0, 99) < 70 || DeathKnightChainOpen(bot) || IsWalker(bot)))
        {
            BotLifeSpawn giver;
            if (FindQuestGiver(bot, t, giver))
            {
                SetState(bot, t, BotLifeState::GO_QUESTGIVER, now, 10 * MINUTE * IN_MILLISECONDS);
                t.npcEntry = giver.entry;
                t.npcIsGo = giver.go;
                SetDest(t, giver.map, giver.x, giver.y, giver.z, 4.0f);
                return;
            }
        }
    }

    // archaeology - a ride to one of the bot's dig sites, now and then
    if (_professions && _archaeology && !bot->GetGroup() && bot->HasSkill(SKILL_ARCHAEOLOGY))
    {
        if (!t.nextDig)
            t.nextDig = now + urand(1, _digMinutes) * MINUTE * IN_MILLISECONDS;   // spread the first trips
        else if (now >= t.nextDig && StartDig(bot, t, now))
            return;
    }

    // 4. a short break now and then
    if (urand(0, 99) < 6)
    {
        Count(BLC_REST);
        SetState(bot, t, BotLifeState::REST, now, urand(20, 45) * IN_MILLISECONDS);
        bot->StopMoving();
        bot->SetStandState(UNIT_STAND_STATE_SIT);
        return;
    }

    // a death knight in its starting chain does not wander off to grind - it waits for its next quest
    // 
    if (DeathKnightChainOpen(bot) || IsWalker(bot))
    {
        SetState(bot, t, BotLifeState::AT_GRIND, now, urand(30, 60) * IN_MILLISECONDS);
        return;
    }

    // 5. go grind somewhere that fits our level
    if (_travel)
    {
        BotLifeGrindSpot spot;
        if (FindGrindSpot(bot, spot, false) || FindGrindSpot(bot, spot, true))
        {
            SetState(bot, t, BotLifeState::GO_GRIND, now, 12 * MINUTE * IN_MILLISECONDS);
            SetDest(t, bot->GetMapId(), spot.x, spot.y, spot.z, 12.0f);
            return;
        }
    }

    // nothing found (e.g. a capital): part of the bots moves on to a fitting area, the rest stays around
    if (_relocate && urand(0, 99) < 35 && !DeathKnightChainOpen(bot) && RelocateForLevel(bot))
    {
        SetState(bot, t, BotLifeState::IDLE, now, 0);
        return;
    }
    SetState(bot, t, BotLifeState::AT_GRIND, now, urand(3, 6) * MINUTE * IN_MILLISECONDS);
}

bool BotLifeMgr::Act(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    t.wantMount = false;
    bool result = ActState(botAI, t, now);
    // off the mount when not traveling for a moment (the engine cannot fight mounted)
    if (t.wantMount)
        t.lastWantMount = now;
    else if (bot->IsMounted() && (now - t.lastWantMount > 4000 || HasGrindTarget(botAI)))
        Dismount(bot);
    return result;
}

bool BotLifeMgr::ActState(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    switch (t.state)
    {
        case BotLifeState::REST:
            if (!bot->IsSitState())
                bot->SetStandState(UNIT_STAND_STATE_SIT);
            return true;
        case BotLifeState::TOWN:
            if (t.hasDest && !Arrived(bot, t))
            {
                Travel(bot, t, now);
                if (!t.hasDest)                 // stuck: another NPC
                    PickTownSpot(bot, t, true);
                return true;
            }
            if (!t.townWaitUntil)
            {
                // at an NPC: do business for a moment
                bot->StopMoving();
                t.townWaitUntil = now + urand(15, 60) * IN_MILLISECONDS;
                if (_emotes && urand(0, 99) < 25)
                    bot->HandleEmoteCommand(urand(0, 1) ? EMOTE_ONESHOT_TALK : EMOTE_ONESHOT_POINT);
            }
            // smiths, engineers and miners work at the anvil / forge of the town (their recipes need
            // one within reach, and no NPC of the town visit stands next to it)
            if (!t.forgeVisited)
            {
                t.forgeVisited = true;
                if (_professions && t.craftsLeft && GoToForge(bot, t))
                {
                    t.townWaitUntil = 0;
                    return true;
                }
            }
            // gatherers come to town because the bags are full, and with full bags no product fits
            // (the first crafters fetched ore from the bank and never smelted it): the bank / auction business first,
            // it takes the materials; then the crafter fetches what its recipe needs
            if (!t.craftSupplied && !t.townBusinessDone && t.craftsLeft && BagsFullOfMaterials(bot)
                && ((bot->GetGuildId() && _guildBank) || _auctions))
            {
                t.townBusinessDone = true;
                QueueTownBusiness(bot->GetGUID());
                t.craftSupplyAt = now + 4000;
                if (t.townWaitUntil < now + 12000)
                    t.townWaitUntil = now + 12000;
                return true;
            }
            if (!t.craftSupplied && now < t.craftSupplyAt)
                return true;
            // a crafter first gets what its best recipe is short of out of the guild bank (the
            // world thread does that, the bank is shared) - with only its own gathering in the bags no recipe ever
            // had all its reagents (0 crafts per hour)
            if (!t.craftSupplied)
            {
                t.craftSupplied = true;
                if (_professions && _guildBank && bot->GetGuildId() && t.craftsLeft)
                {
                    QueueCraftSupply(bot->GetGUID());
                    t.nextCraft = now + 3000;
                    if (t.townWaitUntil < now + 8000)
                        t.townWaitUntil = now + 8000;
                    return true;
                }
            }
            // craft first (with the materials still in the bags), then bank / auction the rest
            if (CraftBusiness(botAI, t, now))
            {
                if (t.townWaitUntil < now + 5000)
                    t.townWaitUntil = now + 5000;
                return true;
            }
            // guild bank (and later the auction house) are shared: the world thread does that business
            if (!t.townBusinessDone && ((bot->GetGuildId() && _guildBank) || _auctions))
            {
                t.townBusinessDone = true;
                QueueTownBusiness(bot->GetGUID());
            }
            if (now >= t.townWaitUntil)
            {
                t.townWaitUntil = 0;
                PickTownSpot(bot, t, true);
            }
            return true;
        case BotLifeState::GO_QUESTGIVER:
        case BotLifeState::GO_TURNIN:
            // on an errand: only fight when attacked
            return Travel(bot, t, now);
        case BotLifeState::GO_GRIND:
            if (TravelBlockedByTarget(botAI, t, now))
                return false;
            return Travel(bot, t, now);
        case BotLifeState::DO_QUEST:
        {
            if (!t.hasDest)
                return false;
            // the companion of the quest is called up before setting out, not among the enemies
            if (!bot->IsInCombat() && UseCompanionItem(bot, t, now))
                return true;
            // an encounter that starts with a conversation (the target is not attackable yet)
            if (StartEventCreature(bot, t, now))
                return true;
            // braziers and the like that the player has to click during an encounter
            if (ClickEventCreature(bot, t, now))
                return true;
            float d = bot->GetMapId() == t.destMap ? bot->GetExactDist(t.destX, t.destY, t.destZ) : 99999.0f;
            if (t.questPoint ? !Arrived(bot, t) : d > QUEST_AREA_RADIUS)
            {
                if (TravelBlockedByTarget(botAI, t, now))
                    return false;
                return Travel(bot, t, now);
            }
            if (t.useGo.IsEmpty() && now >= t.nextGoSearch)
            {
                t.nextGoSearch = now + 5000;
                FindQuestObject(bot, t);
            }
            if (!t.useGo.IsEmpty())
            {
                t.questIdleSince = 0;
                return UseQuestObject(bot, t, now);
            }
            // batch 11m: an item whose equip spell gives the credit, in the bags: put it on
            if (EquipQuestItem(bot, t, now))
            {
                t.questIdleSince = 0;
                return true;
            }
            // batch 11d: the item of the quest makes the objective item or completes the quest
            if (UseQuestItem(bot, t, now))
            {
                t.questIdleSince = 0;
                return true;
            }
            // something a vendor sells
            if (BuyQuestItem(bot, t, now))
            {
                t.questIdleSince = 0;
                return true;
            }
            // somebody to talk to, or to use the quest item on
            if (InteractQuestCreature(botAI, t, now))
            {
                t.questIdleSince = 0;
                return true;
            }
            // go for the quest creatures ourselves: the engine's grind target prefers whatever is closest
            if (EngageQuestCreature(botAI, t, now))
            {
                t.questIdleSince = 0;
                return true;
            }
            // nothing here to fight or to open (dead or looted - other bots work on the same quest):
            // after twenty seconds on to another spawn of what the quest still needs, instead of waiting for a respawn
            if (bot->IsInCombat())
                t.questIdleSince = 0;
            else if (!t.questIdleSince)
                t.questIdleSince = now;
            else if (now - t.questIdleSince > 20000)
            {
                t.questIdleSince = 0;
                if (Quest const* quest = sObjectMgr->GetQuestTemplate(t.questId))
                    if (PickRoamDest(bot, t, quest))
                    {
                        Count(BLC_QUEST_ROAM);
                        return Travel(bot, t, now);
                    }
            }
            return false;   // engine grinds, GrindTargetValue prefers quest targets
        }
        case BotLifeState::AT_GRIND:
            // wandered too far from the spot: walk back
            if (t.hasDest && bot->GetMapId() == t.destMap && bot->GetExactDist(t.destX, t.destY, t.destZ) > 150.0f && !HasGrindTarget(botAI))
            {
                t.arriveDist = 40.0f;
                return Travel(bot, t, now);
            }
            return false;
        case BotLifeState::DIG:
            return DigBusiness(botAI, t, now);
        case BotLifeState::IDLE:
        default:
            return false;
    }
}

// ---------------------------------------------------------------------------------------------
// riding: random bots get the riding skill and a plain mount for their level (ground only)

namespace
{
    uint32 BotMountSpell(Player* bot)
    {
        bool horde = bot->GetTeam() == HORDE;
        if (bot->GetLevel() >= 40)
            return horde ? 23250 : 23229;   // Swift Brown Wolf / Swift Brown Steed
        if (bot->GetLevel() >= 20)
            return horde ? 6654 : 458;      // Brown Wolf / Brown Horse
        return 0;
    }
}

void BotLifeMgr::EnsureRiding(Player* bot)
{
    if (bot->GetLevel() >= 20 && !bot->HasSpell(33388))
        bot->LearnSpell(33388, false);      // Apprentice Riding
    if (bot->GetLevel() >= 40 && !bot->HasSpell(33391))
        bot->LearnSpell(33391, false);      // Journeyman Riding
    if (uint32 spell = BotMountSpell(bot))
        if (!bot->HasSpell(spell))
            bot->LearnSpell(spell, false);
}

bool BotLifeMgr::MountUp(Player* bot)
{
    uint32 spell = BotMountSpell(bot);
    if (!spell || bot->IsMounted() || bot->IsInCombat() || bot->IsInWater() || bot->GetVehicle() || bot->IsInFlight()
        || bot->HasUnitState(UNIT_STATE_CASTING) || !bot->HasSpell(spell))
        return false;
    if (bot->GetShapeshiftForm() != FORM_NONE)
        return false;
    Map* map = bot->GetMap();
    // 
    if ((map->Instanceable() && !map->IsBattleground()) || !map->IsOutdoors(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ()))
        return false;
    bot->CastSpell(bot, spell, true);
    if (!bot->IsMounted())
        return false;
    Count(BLC_MOUNT);
    return true;
}

void BotLifeMgr::Dismount(Player* bot)
{
    if (bot->IsMounted())
        bot->RemoveAurasByType(SPELL_AURA_MOUNTED);
}

// low in a fight: a healing potion of the bot's tier (the class AI hardly heals itself)
void BotLifeMgr::CombatPotion(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (now < t.nextPotion || bot->GetHealthPct() >= 35.0f || !bot->IsAlive())
        return;
    uint32 level = bot->GetLevel();
    uint32 spell = level >= 85 ? 105708     // Master Healing Potion
        : level >= 80 ? 78989                 // Mythical Healing Potion
        : level >= 70 ? 43185                 // Runic Healing Potion
        : level >= 55 ? 28495                 // Super Healing Potion
        : level >= 45 ? 17534                 // Major Healing Potion
        : level >= 35 ? 4042                  // Superior Healing Potion
        : level >= 21 ? 2024                  // Greater Healing Potion
        : level >= 12 ? 441                   // Healing Potion
        : 439;                                // Minor Healing Potion
    t.nextPotion = now + 60000;
    bot->CastSpell(bot, spell, true);
    Count(BLC_POTION);
}

// ---------------------------------------------------------------------------------------------
// town visits

namespace
{
    uint8 TownBand(uint32 level)
    {
        if (level >= 85)
            return 3;
        if (level >= 68)
            return 2;
        if (level >= 58)
            return 1;
        return 0;
    }
}

bool BotLifeMgr::PickTownSpot(Player* bot, BotLifeInfo& t, bool sameZone)
{
    FactionTemplateEntry const* botFaction = bot->GetFactionTemplateEntry();
    uint8 band = TownBand(bot->GetLevel());
    uint32 zone = bot->GetZoneId();
    BotLifeTownSpot const* pick = nullptr;
    uint32 seen = 0;
    for (BotLifeTownSpot const& spot : _townSpots)
    {
        if (sameZone)
        {
            if (spot.map != bot->GetMapId() || spot.zone != zone || bot->GetExactDist2d(spot.x, spot.y) > 250.0f
                || bot->GetExactDist2d(spot.x, spot.y) < 10.0f)
                continue;
        }
        else if (spot.band != band)
            continue;
        // own faction's and neutral cities (Shattrath, Dalaran, Pandaria) - never the other faction's
        FactionTemplateEntry const* ft = sFactionTemplateStore.LookupEntry(spot.faction);
        if (!ft || !botFaction || ft->IsHostileTo(*botFaction) || IsEnemyTerritory(bot, spot.zone))
            continue;
        if (urand(0, seen++) == 0)
            pick = &spot;
    }
    if (!pick)
        return false;
    // stand in front of the NPC, not in it
    float angle = frand(0.0f, 2 * float(M_PI));
    SetDest(t, pick->map, pick->x + std::cos(angle) * 2.5f, pick->y + std::sin(angle) * 2.5f, pick->z, 3.0f);
    return true;
}

bool BotLifeMgr::NeedsRepair(Player* bot) const
{
    for (uint8 slot = EQUIPMENT_SLOT_START; slot < EQUIPMENT_SLOT_END; ++slot)
        if (Item* item = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
        {
            uint32 max = item->GetUInt32Value(ITEM_FIELD_MAX_DURABILITY);
            if (max && item->GetUInt32Value(ITEM_FIELD_DURABILITY) * 5 < max)   // below 20%
                return true;
        }
    return false;
}

bool BotLifeMgr::StartTownVisit(Player* bot, BotLifeInfo& t, uint32 now)
{
    t.nextTownVisit = now + urand(_townMinutesMin, _townMinutesMax) * MINUTE * IN_MILLISECONDS;
    if (bot->IsInCombat() || bot->GetMap()->Instanceable() || RealPlayerNear(bot, 40.0f))
        return false;
    uint32 map = bot->GetMapId();
    float x = bot->GetPositionX(), y = bot->GetPositionY(), z = bot->GetPositionZ(), o = bot->GetOrientation();
    if (!PickTownSpot(bot, t, false))
        return false;
    SetState(bot, t, BotLifeState::TOWN, now, urand(4, 9) * MINUTE * IN_MILLISECONDS);
    PickTownSpot(bot, t, false);   // SetState cleared the destination
    t.townMap = map;
    t.townX = x;
    t.townY = y;
    t.townZ = z;
    t.townO = o;
    t.townWaitUntil = 0;
    t.townBusinessDone = false;
    t.craftsLeft = _craftsPerVisit;
    t.craftSupplied = false;
    t.forgeVisited = false;
    t.craftSupplyAt = 0;
    t.craftSpell = 0;
    t.craftFailed.clear();
    t.refined = false;
    t.fireMade = false;
    // arrive next to the first NPC (a hearthstone / portal trip), sell the junk
    bot->TeleportTo(t.destMap, t.destX, t.destY, t.destZ + 0.5f, frand(0.0f, 2 * float(M_PI)));
    ManageBags(bot, 60, false);   // materials go to the guild bank / auction house this visit, not the vendor
    // at the vendor: repair (paid, like everybody else; broken gear gives no stats)
    // a guild member repairs on the guild's account. The guild bank is shared by all maps, so
    // that happens with the rest of the town business on the world thread (RepairInTown).
    if (!(_guildBank && bot->GetGuildId()))
        bot->DurabilityRepairAll(true, 1.0f, false);
    Count(BLC_TOWN_VISIT);
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): town visit, map {} {} {}", bot->GetName(), uint32(bot->GetLevel()), t.destMap, t.destX, t.destY);
    return true;
}

void BotLifeMgr::EndTownVisit(Player* bot, BotLifeInfo& t, uint32 now)
{
    SetState(bot, t, BotLifeState::IDLE, now, 0);
    t.townWaitUntil = 0;
    if (!t.townMap && t.townX == 0.0f)
        return;
    MapEntry const* me = sMapStore.LookupEntry(t.townMap);
    if (me && !me->Instanceable() && !bot->IsInCombat())
        bot->TeleportTo(t.townMap, t.townX, t.townY, t.townZ + 0.5f, t.townO);
    t.townMap = 0;
    t.townX = t.townY = t.townZ = 0.0f;
}

// ---------------------------------------------------------------------------------------------
// area triggers: a real client reports entering/leaving them (boss events, explore quests, battleground
// objectives); bots have no client, so bot life does it. Teleport and inn triggers are left out.

namespace
{
    constexpr float TRIGGER_CELL = 100.0f;
    uint64 TriggerCellKey(uint32 map, float x, float y)
    {
        int32 cx = int32(std::floor(x / TRIGGER_CELL)), cy = int32(std::floor(y / TRIGGER_CELL));
        return (uint64(map) << 40) | (uint64(uint32(cx + 0x8000) & 0xFFFFF) << 20) | uint64(uint32(cy + 0x8000) & 0xFFFFF);
    }
}

void BotLifeMgr::LoadAreaTriggers()
{
    _triggerCells.clear();
    uint32 count = 0;
    for (uint32 i = 0; i < sAreaTriggerStore.GetNumRows(); ++i)
    {
        AreaTriggerEntry const* at = sAreaTriggerStore.LookupEntry(i);
        if (!at || sObjectMgr->GetAreaTrigger(at->ID) || sObjectMgr->IsTavernAreaTrigger(at->ID))
            continue;
        float reach = std::max(at->Radius, std::max(at->BoxLength, at->BoxWidth) * 0.5f);
        if (reach > 150.0f)
            continue;   // huge zone-wide triggers are not what we are after
        // register in every cell the trigger touches
        for (float x = at->Pos.X - reach; x <= at->Pos.X + reach + TRIGGER_CELL; x += TRIGGER_CELL)
            for (float y = at->Pos.Y - reach; y <= at->Pos.Y + reach + TRIGGER_CELL; y += TRIGGER_CELL)
            {
                auto& v = _triggerCells[TriggerCellKey(at->ContinentID, std::min(x, at->Pos.X + reach), std::min(y, at->Pos.Y + reach))];
                if (std::find(v.begin(), v.end(), at->ID) == v.end())
                    v.push_back(at->ID);
            }
        ++count;
    }
    TC_LOG_INFO("server.loading", ">> BotLife: {} area triggers indexed for bots", count);
}

void BotLifeMgr::CheckAreaTriggers(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (now < t.nextTriggerCheck)
        return;
    t.nextTriggerCheck = now + 1000;

    std::vector<uint32> inside;
    auto it = _triggerCells.find(TriggerCellKey(bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY()));
    if (it != _triggerCells.end())
        for (uint32 id : it->second)
            if (AreaTriggerEntry const* at = sAreaTriggerStore.LookupEntry(id))
                if (bot->IsInAreaTrigger(at))
                    inside.push_back(id);

    auto fire = [&](uint32 id, bool entered)
    {
        WorldPackets::AreaTrigger::AreaTrigger packet{ WorldPacket(CMSG_AREATRIGGER) };
        packet.AreaTriggerID = id;
        packet.Entered = entered;
        packet.FromClient = true;
        bot->GetSession()->HandleAreaTriggerOpcode(packet);
    };
    for (uint32 id : inside)
        if (std::find(t.insideTriggers.begin(), t.insideTriggers.end(), id) == t.insideTriggers.end())
        {
            Count(BLC_AREATRIGGER);
            fire(id, true);
            if (!bot->IsInWorld() || bot->IsBeingTeleported())
                return;
        }
    for (uint32 id : t.insideTriggers)
        if (std::find(inside.begin(), inside.end(), id) == inside.end())
            fire(id, false);
    t.insideTriggers.swap(inside);
}

// solo healers heal themselves when it gets close (the engine only heals group members)
bool BotLifeMgr::CombatSelfHeal(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (now < t.nextSelfHeal || bot->GetHealthPct() >= 45.0f || bot->HasUnitState(UNIT_STATE_CASTING) || !bot->IsAlive())
        return false;
    static std::unordered_map<uint8, std::vector<uint32>> const heals = {
        { CLASS_PRIEST,  { 2061, 2050 } },      // Flash Heal, Heal
        { CLASS_DRUID,   { 8936, 5185 } },      // Regrowth, Healing Touch
        { CLASS_SHAMAN,  { 8004, 331 } },       // Healing Surge, Healing Wave
        { CLASS_PALADIN, { 19750, 85673 } },    // Flash of Light, Word of Glory
        { CLASS_MONK,    { 116694 } } };        // Surging Mist
    auto it = heals.find(bot->GetClass());
    if (it == heals.end())
        return false;
    t.nextSelfHeal = now + 4000;
    for (uint32 spell : it->second)
    {
        if (!bot->HasSpell(spell) || bot->HasSpellCooldown(spell))
            continue;
        // druids in cat / bear form would have to shift out first; leave those to the potion
        if (bot->GetShapeshiftForm() != FORM_NONE && bot->GetShapeshiftForm() != FORM_MOONKIN && bot->GetShapeshiftForm() != FORM_TREE)
            return false;
        bot->StopMoving();
        uint32 hpBefore = bot->GetHealth();
        bot->CastSpell(bot, spell, false);
        if (bot->IsNonMeleeSpellCasted(false) || bot->GetHealth() > hpBefore)
        {
            Count(BLC_SELF_HEAL);
            return true;
        }
    }
    return false;
}

bool BotLifeMgr::RealPlayerNear(Player* bot, float dist) const
{
    Map::PlayerList const& players = bot->GetMap()->GetPlayers();
    for (Map::PlayerList::const_iterator itr = players.begin(); itr != players.end(); ++itr)
    {
        Player* p = itr->GetSource();
        if (!p || p == bot || !p->GetSession() || p->GetSession()->IsBot())
            continue;
        if (p->IsInWorld() && bot->GetExactDist(p) < dist)
            return true;
    }
    return false;
}

// the engine releases the spirit and runs back to the corpse; when that takes too long
// (ghost stuck at a graveyard or on the way) the bot is revived at its corpse, if nobody is watching
bool BotLifeMgr::HandleDeath(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (!t.deadSince)
    {
        t.deadSince = now;
        Count(BLC_DEATH);
        // every death in a dungeon under repair, whatever the cause - the log of OnKilledByCreature
        // stayed empty through four wipes in the Shado-Pan Monastery (a fall has no killer)
        if ((t.party == BOTLIFE_PARTY_DUNGEON || t.party == BOTLIFE_PARTY_RAID) && _dungeonFocusMaps.count(bot->GetMapId()))
            TC_LOG_INFO("playerbots", "BotLife: {} (lvl {}) is dead in map {} at {:.0f} {:.0f} {:.0f}, move flags 0x{:X}{}",
                bot->GetName(), uint32(bot->GetLevel()), bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(),
                bot->m_movementInfo.GetMovementFlags(), bot->HasPlayerFlag(PLAYER_FLAGS_GHOST) ? ", ghost" : "");
        return false;
    }
    if (now - t.deadSince < 4 * MINUTE * IN_MILLISECONDS || !bot->HasPlayerFlag(PLAYER_FLAGS_GHOST) || bot->IsBeingTeleported())
        return false;
    if (bot->GetMap()->Instanceable() || RealPlayerNear(bot, 150.0f))
        return false;
    WorldLocation corpse = bot->GetCorpseLocation();
    t.deadSince = 0;
    bot->ResurrectPlayer(0.5f);
    bot->SpawnCorpseBones();
    if (corpse.GetMapId() != MAPID_INVALID && !(corpse.GetPositionX() == 0.0f && corpse.GetPositionY() == 0.0f))
    {
        MapEntry const* me = sMapStore.LookupEntry(corpse.GetMapId());
        if (me && !me->Instanceable())
            bot->TeleportTo(corpse.GetMapId(), corpse.GetPositionX(), corpse.GetPositionY(), corpse.GetPositionZ() + 0.5f, bot->GetOrientation());
    }
    Count(BLC_GHOST_REVIVE);
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {}: ghost for too long, revived at corpse", bot->GetName());
    return true;
}

bool BotLifeMgr::HasGrindTarget(PlayerbotAI* botAI)
{
    Unit* target = botAI->GetAiObjectContext()->GetValue<Unit*>("grind target")->Get();
    return target && target->IsAlive();
}

// grind on the way, but do not get stuck on a target the engine never attacks
bool BotLifeMgr::TravelBlockedByTarget(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    if (now < t.ignoreTargetsUntil)
        return false;
    if (!HasGrindTarget(botAI))
    {
        t.targetWaitSince = 0;
        return false;
    }
    if (!t.targetWaitSince)
        t.targetWaitSince = now;
    if (now - t.targetWaitSince < 15000 || now - t.lastCombat < 15000)
        return true;
    t.targetWaitSince = 0;
    t.ignoreTargetsUntil = now + 30000;
    return false;
}

// ---------------------------------------------------------------------------------------------
// travel

void BotLifeMgr::BuildPath(Player* bot, BotLifeInfo& t)
{
    t.path.clear();
    t.pathIdx = 0;
    PathGenerator path(bot);
    path.CalculatePath(t.destX, t.destY, t.destZ, false);
    if (!(path.GetPathType() & (PATHFIND_NORMAL | PATHFIND_INCOMPLETE)))
        return;
    Movement::PointsArray const& points = path.GetPath();
    t.path.reserve(points.size());
    for (G3D::Vector3 const& p : points)
        t.path.push_back({ p.x, p.y, p.z });
}

// path diagnostics, read by ".botlife pathstats" (cs_playerbots.cpp)
// 0 samples, 1 no navmesh / tile (straight line), 2 no path, 3 incomplete, 4 shortcut, 5 normal, 6 other, 7 start far
// from the mesh
std::atomic<uint32> tt_pathStats[8];

bool BotLifeMgr::Travel(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (!t.hasDest || bot->GetMapId() != t.destMap)
    {
        t.hasDest = false;
        return false;
    }

    float d = bot->GetExactDist(t.destX, t.destY, t.destZ);
    if (Arrived(bot, t))
        return false;

    // Acherus floats above the Scarlet Enclave; its floors are joined by teleport pads and the ground by
    // gryphons and a portal - no walkable way, and the navmesh knows none. A bot takes the pad straight to where it goes.
    if (bot->GetMapId() == 609 && d > 30.0f && std::fabs(bot->GetPositionZ() - t.destZ) > 25.0f
        && (bot->GetPositionZ() > 300.0f || t.destZ > 300.0f) && !bot->IsInCombat())
    {
        Count(BLC_DK_PORTAL);
        t.path.clear();
        t.pathIdx = 0;
        t.lastProgressCheck = 0;
        bot->TeleportTo(609, t.destX, t.destY, t.destZ + 0.5f, bot->GetOrientation());
        return true;
    }

    if (d > MAX_TRAVEL_DIST * 1.5f)
    {
        t.hasDest = false;
        return false;
    }

    if (bot->IsSitState())
        bot->SetStandState(UNIT_STAND_STATE_STAND);

    // longer trips on a mount
    if (d > 40.0f)
    {
        t.wantMount = true;
        if (d > 100.0f && !bot->IsMounted() && MountUp(bot))
            t.lastMoveOrder = 0;   // speed changed: new move order right away
    }

    // progress / stuck detection
    if (!t.lastProgressCheck)
    {
        t.lastProgressCheck = now;
        t.lastDist = d;
        t.lastPosX = bot->GetPositionX();
        t.lastPosY = bot->GetPositionY();
        t.detour = 0;
        t.bestDist = d;
        t.bestDistAt = now;
    }
    else if (now - t.lastProgressCheck >= 8000)
    {
        // with a real navmesh path the way round a mountain or a lake leads away from the destination
        // for a while. Not closer but still covering ground is a detour (two minutes of it at most); stuck is standing.
        float const moved = bot->GetExactDist2d(t.lastPosX, t.lastPosY);
        if (t.lastDist - d >= 3.0f)
        {
            t.stuck = 0;
            t.detour = 0;
        }
        else if (moved >= 15.0f && t.detour < 15)
            ++t.detour;
        else
            ++t.stuck;
        // pacing to and fro looks like progress every other step: only a new record counts
        if (d < t.bestDist - 3.0f)
        {
            t.bestDist = d;
            t.bestDistAt = now;
        }
        else if (now - t.bestDistAt >= 240000 && t.stuck < 6)
            t.stuck = 6;
        t.lastPosX = bot->GetPositionX();
        t.lastPosY = bot->GetPositionY();
        t.lastDist = d;
        t.lastProgressCheck = now;
        if (t.stuck >= 2)
        {
            t.path.clear();
            t.pathIdx = 0;
        }
        if (t.stuck >= 6)
        {
            // ~50 seconds without progress: give up this destination
            // almost at a quest area whose centre cannot be reached (cliff, water): work from here
            if (t.state == BotLifeState::DO_QUEST && d < 80.0f)
            {
                t.destX = bot->GetPositionX();
                t.destY = bot->GetPositionY();
                t.destZ = bot->GetPositionZ();
                t.stuck = 0;
                t.path.clear();
                t.pathIdx = 0;
                t.lastProgressCheck = 0;
                return false;
            }
            Count(BLC_STUCK);
            if (_debug)
                TC_LOG_INFO("playerbots", "BotLife {}: stuck traveling (state {}) at {} {} {} map {}, dest {} {} {} dist {}", bot->GetName(),
                    uint32(t.state), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), bot->GetMapId(), t.destX, t.destY, t.destZ, d);
            // nobody watching: a bot does not stay stuck on terrain the navmesh does not know
            if (t.state != BotLifeState::AT_GRIND && !bot->GetMap()->Instanceable() && !RealPlayerNear(bot, 150.0f))
            {
                Count(BLC_UNSTUCK);
                t.stuck = 0;
                t.path.clear();
                t.pathIdx = 0;
                t.lastProgressCheck = 0;
                bot->TeleportTo(t.destMap, t.destX, t.destY, t.destZ + 0.5f, bot->GetOrientation());
                return true;
            }
            if (t.state == BotLifeState::GO_QUESTGIVER && t.npcEntry)
                t.avoidNpc[t.npcEntry] = now + 30 * MINUTE * IN_MILLISECONDS;
            else if ((t.state == BotLifeState::GO_TURNIN || t.state == BotLifeState::DO_QUEST) && t.questId)
                t.questRetarget += 2;
            t.hasDest = false;
            t.stateUntil = now;   // Think() handles the timeout
            return false;
        }
    }

    // (1-10: the next stretch is ordered 15 yd before the waypoint - a bot that waits for its next think at
    // every waypoint moves in fits and starts)
    if (bot->isMoving() && now - t.lastMoveOrder < 5000 && bot->GetExactDist2d(t.wpX, t.wpY) > 15.0f)
        return true;
    if (now - t.lastMoveOrder < 1000)
        return true;

    float wx = t.destX, wy = t.destY, wz = t.destZ;
    if (d > 60.0f)
    {
        if (t.pathIdx >= t.path.size())
            BuildPath(bot, t);

        if (t.path.size() > 1)
        {
            // walk the cached path in chunks of ~40 yards
            uint32 idx = std::max<uint32>(t.pathIdx, 1);
            while (idx + 1 < t.path.size() && bot->GetExactDist(t.path[idx].x, t.path[idx].y, t.path[idx].z) < 40.0f)
                ++idx;
            wx = t.path[idx].x;
            wy = t.path[idx].y;
            wz = t.path[idx].z;
            t.pathIdx = idx + 1;
        }
        else
        {
            // no navmesh path: step straight towards the destination
            float angle = bot->GetAngle(t.destX, t.destY);
            wx = bot->GetPositionX() + std::cos(angle) * 35.0f;
            wy = bot->GetPositionY() + std::sin(angle) * 35.0f;
            wz = bot->GetPositionZ() + 2.0f;
            bot->UpdateAllowedPositionZ(wx, wy, wz);
        }
    }

    // what kind of path does every tenth travel order get? (measuring only)
    {
        static thread_local uint32 t_sample = 0;
        static thread_local uint32 t_lastPathLog = 0;
        if (++t_sample % 10 == 0)
        {
            PathGenerator probe(bot);
            probe.CalculatePath(wx, wy, wz, false);
            uint32 const type = probe.GetPathType();
            uint32 const kind = (type & PATHFIND_NOT_USING_PATH) ? 1 : (type & PATHFIND_NOPATH) ? 2 : (type & PATHFIND_INCOMPLETE) ? 3
                : (type & PATHFIND_SHORTCUT) ? 4 : (type & PATHFIND_NORMAL) ? 5 : 6;
            tt_pathStats[0].fetch_add(1, std::memory_order_relaxed);
            tt_pathStats[kind].fetch_add(1, std::memory_order_relaxed);
            if (type & PATHFIND_FARFROMPOLY_START)
                tt_pathStats[7].fetch_add(1, std::memory_order_relaxed);
            if (kind != 5 && now - t_lastPathLog > 30000)
            {
                t_lastPathLog = now;
                TC_LOG_INFO("playerbots", "BotLife path: {} map {} type 0x{:X} from {:.0f} {:.0f} {:.0f} to {:.0f} {:.0f} {:.0f} ({:.0f} yd, {} points), flags 0x{:X}{}",
                    bot->GetName(), bot->GetMapId(), type, bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), wx, wy, wz,
                    bot->GetExactDist(wx, wy, wz), uint32(probe.GetPath().size()), bot->m_movementInfo.GetMovementFlags(),
                    bot->IsMounted() ? ", mounted" : "");
            }
        }
    }
    bot->GetMotionMaster()->MovePoint(0, wx, wy, wz, true);
    t.lastMoveOrder = now;
    t.wpX = wx;
    t.wpY = wy;
    return true;
}

// ---------------------------------------------------------------------------------------------
// grinding / level fit

bool BotLifeMgr::FindGrindSpot(Player* bot, BotLifeGrindSpot& out, bool anyZone)
{
    auto mapIt = _grind.find(bot->GetMapId());
    if (mapIt == _grind.end() || mapIt->second.empty())
        return false;

    FactionTemplateEntry const* botFaction = bot->GetFactionTemplateEntry();
    uint32 level = bot->GetLevel();
    uint32 minL = level > 2 ? level - 2 : 1;
    uint32 maxL = std::min<uint32>(level + 1, MAX_BOTLIFE_LEVEL);
    uint32 zone = bot->GetZoneId();
    float bx = bot->GetPositionX(), by = bot->GetPositionY();
    float maxDist = anyZone ? 1200.0f : 1500.0f;

    uint32 seen = 0;
    for (uint32 l = minL; l <= maxL; ++l)
    {
        for (BotLifeGrindSpot const& spot : mapIt->second[l])
        {
            if (!anyZone && spot.zone && spot.zone != zone)
                continue;
            float d = Dist2d(bx, by, spot.x, spot.y);
            if (d < 50.0f || d > maxDist)
                continue;
            if (spot.teamDisabled && spot.teamDisabled == bot->GetTeam())
                continue;
            if (IsEnemyTerritory(bot, spot.zone))
                continue;
            if (spot.faction && botFaction)
                if (FactionTemplateEntry const* ft = sFactionTemplateStore.LookupEntry(spot.faction))
                    if (ft->IsFriendlyTo(*botFaction))
                        continue;
            // reservoir sampling
            if (urand(0, seen++) == 0)
                out = spot;
        }
    }
    return seen > 0;
}

bool BotLifeMgr::ZoneFitsLevel(Player* bot) const
{
    // scripted/phased starting-zone maps (Ebon Hold, Wandering Isle, Gilneas, Lost Isles): bots cannot progress there
    switch (bot->GetMapId())
    {
        case 860:
            // the Wandering Isle is mostly plain phase 1: a pandaren without a faction quests there first
            if (_pandarenIsle && bot->GetRace() == RACE_PANDAREN_NEUTRAL && bot->GetLevel() < 10)
                break;
            return false;
        case 609:
            // a new death knight plays its starting chain in Acherus and the Scarlet Enclave first
            return DeathKnightChainOpen(bot);
        case 654: case 648:
            return false;
        default:
            break;
    }
    if (IsEnemyTerritory(bot, bot->GetZoneId()))
        return false;
    // a bot alone in a dungeon or raid (its party is not restored after a restart) stayed there for good: 400+
    // stranded bots, each in an instance map of its own (558 maps loaded, 1400 creatures per Ulduar copy) - the server tick
    // grew with every restart
    if (bot->GetMap()->Instanceable() && !bot->InBattleground() && !bot->GetGroup())
        return false;
    auto it = _zoneLevels.find(bot->GetZoneId());
    if (it == _zoneLevels.end())
        return true;
    int32 level = bot->GetLevel();
    // a starter area (band up to level 6) is left two levels above its band, not six: with the bot
    // rotation a hundred bots shared thirty boars there
    if (level > int32(it->second.high) + (it->second.high <= 6 ? 2 : 6))
        return false;
    if (level + 4 < int32(it->second.low))
        return false;
    return true;
}

// batch 11h: where a low-level bot belongs - the start area of its race. Goblins and worgen start on a
// map of their own that bots skip (Kezan, Gilneas): the start area of the orcs / the night elves instead, where retail
// sends them next. The neutral pandaren of the Wandering Isle are handled apart (BotLife.PandarenIsle).
bool BotLifeMgr::HomeStart(Player* bot, uint32& map, float& x, float& y) const
{
    uint8 race = bot->GetRace();
    if (race == RACE_GOBLIN)
        race = RACE_ORC;
    else if (race == RACE_WORGEN)
        race = RACE_NIGHTELF;
    PlayerInfo const* info = sObjectMgr->GetPlayerInfo(race, bot->GetClass());
    if (!info || info->mapId == 609)
        info = sObjectMgr->GetPlayerInfo(race, CLASS_WARRIOR);   // a class the stand-in race does not have, or a death knight
    if (!info || info->mapId == 648 || info->mapId == 654 || info->mapId == 860 || info->mapId == 609)
        return false;
    map = info->mapId;
    x = info->positionX;
    y = info->positionY;
    return true;
}

bool BotLifeMgr::RelocateForLevel(Player* bot)
{
    if (IsWalker(bot))
        return false;   // a walker stays in its starting area (Kezan and Gilneas too)
    uint32 now = getMSTime();
    if (now - relocateRefill > 500)
    {
        relocateTokens = std::min<uint32>(relocateTokens + (now - relocateRefill) / 500, 40);
        relocateRefill = now;
    }
    if (!relocateTokens)
        return false;

    uint32 level = bot->GetLevel();
    FactionTemplateEntry const* homeFaction = bot->GetFactionTemplateEntry();
    // batch 11h: below level 10 first a spot near the start area of the bot's race
    uint32 homeMap = 0;
    float hx = 0.0f, hy = 0.0f;
    if (level < _homeStartLevel && !(bot->GetMapId() == 860 && bot->GetRace() == RACE_PANDAREN_NEUTRAL)
        && HomeStart(bot, homeMap, hx, hy))
    {
        auto mapIt = _grind.find(homeMap);
        if (mapIt != _grind.end() && mapIt->second.size() > level && !mapIt->second[level].empty())
        {
            std::vector<BotLifeGrindSpot> const& spots = mapIt->second[level];
            for (uint32 attempt = 0; attempt < 40; ++attempt)
            {
                BotLifeGrindSpot const& spot = spots[urand(0, spots.size() - 1)];
                if (Dist2d(hx, hy, spot.x, spot.y) > 2500.0f)
                    continue;
                if ((spot.teamDisabled && spot.teamDisabled == bot->GetTeam()) || IsEnemyTerritory(bot, spot.zone))
                    continue;
                if (spot.faction && homeFaction)
                    if (FactionTemplateEntry const* ft = sFactionTemplateStore.LookupEntry(spot.faction))
                        if (ft->IsFriendlyTo(*homeFaction))
                            continue;
                auto zl = _zoneLevels.find(spot.zone);
                if (zl != _zoneLevels.end() && (int32(level) > int32(zl->second.high) + 6 || int32(level) + 4 < int32(zl->second.low)))
                    continue;
                --relocateTokens;
                Count(BLC_RELOCATE);
                AdjustMapPopulation(bot->GetMapId(), -1);
                AdjustMapPopulation(homeMap, +1);
                bot->TeleportTo(homeMap, spot.x, spot.y, spot.z + 0.5f, frand(0.0f, 2 * float(M_PI)));
                return true;
            }
        }
    }
    std::vector<uint32> maps;
    // a pandaren without a faction stays on the Wandering Isle until level 10
    if (_pandarenIsle && bot->GetMapId() == 860 && bot->GetRace() == RACE_PANDAREN_NEUTRAL && level < 10)
        maps = { 860 };
    else if (level < 58)
        maps = { 0, 1 };
    else if (level < 68)
        maps = { 530 };
    else if (level < 80)
        maps = { 571 };
    else if (level < 85)
        maps = { 0, 1 };
    else if (level < 90 || MapPopulation(1064) >= 150)
        maps = { 870 };
    else
        maps = { 870, 1064 };   // Isle of Thunder takes some level-90 bots off Pandaria (capped at 150)
    // stay on the current map when it has a fitting area
    if (std::find(maps.begin(), maps.end(), bot->GetMapId()) != maps.end())
        maps.insert(maps.begin(), bot->GetMapId());
    // with two fitting continents take the less crowded one first (Eastern Kingdoms carried 863 of 3000 bots)
    if (maps.size() > 1)
        std::stable_sort(maps.begin(), maps.end(), [this](uint32 a, uint32 b) { return MapPopulation(a) < MapPopulation(b); });

    FactionTemplateEntry const* botFaction = bot->GetFactionTemplateEntry();
    for (uint32 map : maps)
    {
        auto mapIt = _grind.find(map);
        if (mapIt == _grind.end() || mapIt->second.size() <= level)
            continue;
        std::vector<BotLifeGrindSpot> const& spots = mapIt->second[level];
        if (spots.empty())
            continue;
        for (uint32 attempt = 0; attempt < 25; ++attempt)
        {
            BotLifeGrindSpot const& spot = spots[urand(0, spots.size() - 1)];
            if (spot.teamDisabled && spot.teamDisabled == bot->GetTeam())
                continue;
            if (IsEnemyTerritory(bot, spot.zone))
                continue;
            if (spot.faction && botFaction)
                if (FactionTemplateEntry const* ft = sFactionTemplateStore.LookupEntry(spot.faction))
                    if (ft->IsFriendlyTo(*botFaction))
                        continue;
            auto zl = _zoneLevels.find(spot.zone);
            if (zl != _zoneLevels.end() && (int32(level) > int32(zl->second.high) + 6 || int32(level) + 4 < int32(zl->second.low)))
                continue;
            --relocateTokens;
            Count(BLC_RELOCATE);
            if (_debug)
                TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): zone {} does not fit, relocating to map {} zone {}",
                    bot->GetName(), level, bot->GetZoneId(), map, spot.zone);
            // keep the population snapshot current between counts (all 595 stranded bots went to one continent)
            AdjustMapPopulation(bot->GetMapId(), -1);
            AdjustMapPopulation(map, +1);
            bot->TeleportTo(map, spot.x, spot.y, spot.z + 0.5f, frand(0.0f, 2 * float(M_PI)));
            return true;
        }
    }
    return false;
}

// ---------------------------------------------------------------------------------------------
// quests

// every lookup of the plan cache goes through here. Two of them (IsQuestTarget and the death handler)
// did not take the lock and raced with an insert from another map thread - a rehash under a running find, SIGSEGV two
// minutes after a restart, while the cache was still filling. Plans are never erased, so a pointer stays valid; the
// last hit is kept per thread (IsQuestTarget asks for the same quest for every unit around a bot).
BotLifeQuestPlan const* BotLifeMgr::FindPlan(uint32 questId)
{
    static thread_local uint32 t_lastQuest = 0;
    static thread_local BotLifeQuestPlan const* t_lastPlan = nullptr;
    if (t_lastPlan && t_lastQuest == questId)
        return t_lastPlan;
    std::shared_lock<std::shared_mutex> guard(_planLock);
    auto it = _plans.find(questId);
    if (it == _plans.end())
        return nullptr;
    t_lastQuest = questId;
    t_lastPlan = &it->second;
    return t_lastPlan;
}

BotLifeQuestPlan const& BotLifeMgr::GetPlan(Quest const* quest)
{
    // called from all map threads - the cache insert (rehash) raced with lookups elsewhere
    if (BotLifeQuestPlan const* known = FindPlan(quest->GetQuestId()))
        return *known;

    BotLifeQuestPlan plan;
    plan.supported = IsQuestSupported(quest);
    if (plan.supported)
    {
        for (QuestObjective const& obj : quest->GetObjectives())
        {
            if (obj.Type == QUEST_OBJECTIVE_MONSTER)
            {
                plan.targetCreatures.insert(obj.ObjectID);
                auto kc = _killCreditSources.find(obj.ObjectID);
                if (kc != _killCreditSources.end())
                    plan.targetCreatures.insert(kc->second.begin(), kc->second.end());
                auto cs = _creditSources.find(obj.ObjectID);
                if (cs != _creditSources.end())
                    for (BotLifeCreditSource const& src : cs->second)
                        if (src.spell || src.fight)
                            plan.targetCreatures.insert(src.creature);   // attackable ones only get attacked (valid target check)
            }
            else if (obj.Type == QUEST_OBJECTIVE_ITEM)
            {
                auto src = _itemCreatureSources.find(obj.ObjectID);
                if (src != _itemCreatureSources.end())
                    plan.targetCreatures.insert(src->second.begin(), src->second.end());
            }
        }
    }
    std::unique_lock<std::shared_mutex> guard(_planLock);
    return _plans.emplace(quest->GetQuestId(), std::move(plan)).first->second;   // another thread may have won: keep that one
}

bool BotLifeMgr::IsQuestSupported(Quest const* quest, char const** why)
{
    auto no = [why](char const* reason) { if (why) *why = reason; return false; };
    // Death Comes From On High is done through the Eye of Acherus (DeathKnightEye)
    if (quest && quest->GetQuestId() == 12641)
        return true;
    // daily quests are never picked up: a daily is a quest like any other, and the only quests a
    // bot of the level cap still has. Weekly, seasonal and the other repeatable ones (turn-ins) stay out.
    bool const daily = quest && quest->IsDaily();
    if (!quest || quest->IsWeekly() || quest->IsSeasonal() || (quest->IsRepeatable() && !daily) || (daily && !_dailyQuests))
        return no("weekly, seasonal or repeatable");
    // QuestType 2 = normal (0 = auto complete, 1 = disabled); QuestInfoID 0 = plain quest (no group/dungeon/raid/pvp)
    // (quest info 21 = class quest: the training quests of the monk)
    // 
    // 
    bool const groupQuest = quest->GetQuestInfoID() == 1 && quest->GetSuggestedPlayers() <= 3;
    if ((quest->GetQuestType() != 2 && quest->GetQuestType() != 0)
        || (quest->GetQuestInfoID() != 0 && quest->GetQuestInfoID() != 21 && !groupQuest) || (quest->GetSuggestedPlayers() > 1 && !groupQuest))
        return no("group, dungeon, raid or other special quest");
    if (quest->HasSpecialFlag(QUEST_SPECIAL_FLAGS_TIMED) || quest->HasFlag(QUEST_FLAGS_FLAGS_PVP))
        return no("timed or pvp");
    if (quest->GetObjectives().empty())
    {
        // an event, an escort or a place has to complete it: only the place is something a bot can do
        // 
        // 
        std::vector<uint32> eventCreatures, eventObjects;
        QuestEventSpots(quest->GetQuestId(), eventCreatures, eventObjects);
        // 8-10 eventwait: the server completes these itself after a timer, the bot only waits and fights
        static std::set<uint32> const timerEventQuests = { 14154 };
        if (timerEventQuests.count(quest->GetQuestId()))
            return true;
        if (quest->HasSpecialFlag(QUEST_SPECIAL_FLAGS_EXPLORATION_OR_EVENT) && !_questTriggers.count(quest->GetQuestId())
            && !_questUse.count(quest->GetQuestId()) && eventCreatures.empty() && eventObjects.empty())
            return no("an event or escort completes it");
        // delivery / "talk to" quest: complete on accept, only the walk to the ender (an open world NPC) is needed
        for (auto const& rel : sObjectMgr->GetCreatureQuestInvolvedRelationReverseBounds(quest->GetQuestId()))
            if (_creatureSpawns.count(rel.second))
                return true;
        for (auto const& rel : sObjectMgr->GetGOQuestInvolvedRelationReverseBounds(quest->GetQuestId()))
            if (_goSpawns.count(rel.second))
                return true;   // (batch 11i: a quest object)
        return no("ender not spawned in the open world (phase 1)");
    }

    // a creature a bot can fight: spawned in the open world, hostile or neutral, attackable
    auto fightable = [this, quest](uint32 entry) -> bool
    {
        if (!_creatureSpawns.count(entry))
            return false;
        CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(entry);
        if (!ct || (ct->unit_flags & (UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE)))
            return false;
        // a scripted creature that is immune until its event starts (a captive that is set free) is fine
        if ((ct->unit_flags & UNIT_FLAG_IMMUNE_TO_PC) && !ct->ScriptID && ct->AIName.empty())
            return false;
        FactionTemplateEntry const* ft = sFactionTemplateStore.LookupEntry(ct->faction);
        if (!ft)
            return false;
        if (ft->IsHostileToPlayers() || ft->IsNeutralToAll())
            return true;
        // an NPC of the other faction (faction group masks: 2 = Alliance, 4 = Horde) - hostile to the
        // side that can take this quest. QuestDoable checks it per bot.
        uint32 const races = quest->GetAllowableRaces();
        bool const forAlliance = !races || (races & RACEMASK_ALLIANCE), forHorde = !races || (races & RACEMASK_HORDE);
        uint32 const sides = (forAlliance ? 2 : 0) | (forHorde ? 4 : 0);
        if (ft->hostileMask & sides)
            return true;
        // neutral to the players who can take the quest, with enemies of its own (yellow, attackable:
        // Corrupted Bloodtalon) - as long as it has no role as an NPC
        return !((ft->friendlyMask | ft->ourMask) & (sides | FACTION_MASK_PLAYER)) && !ct->npcflag;
    };
    // a credit that comes from a talk, a quest item or a spell instead of a kill
    auto interactable = [this](uint32 credit) -> bool
    {
        if (_creditSources.count(credit))
            return true;
        auto co = _creditObjects.find(credit);   // (batch 11l: an object to open)
        if (co != _creditObjects.end())
            for (uint32 go : co->second)
                if (_goSpawns.count(go))
                    return true;
        auto ec = _equipCredits.find(credit);    // (batch 11m: an item to put on, from a chest)
        if (ec != _equipCredits.end())
            for (uint32 item : ec->second)
            {
                auto ch = _equipItemChests.find(item);
                if (ch != _equipItemChests.end())
                    for (uint32 go : ch->second)
                        if (_goSpawns.count(go))
                            return true;
            }
        if (!_creatureSpawns.count(credit))
            return false;
        CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(credit);
        return ct && (ct->npcflag & (UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_SPELLCLICK));
    };

    for (QuestObjective const& obj : quest->GetObjectives())
    {
        if (obj.Type == QUEST_OBJECTIVE_MONSTER)
        {
            // "talk to" / "use on" objectives credit friendly NPCs: bots cannot do those
            bool ok = fightable(obj.ObjectID);
            if (!ok)
            {
                auto kc = _killCreditSources.find(obj.ObjectID);
                if (kc != _killCreditSources.end())
                    for (uint32 entry : kc->second)
                        if (fightable(entry))
                        {
                            ok = true;
                            break;
                        }
            }
            // or an area trigger listed for this quest gives it
            if (!ok && !interactable(obj.ObjectID) && !HasQuestHelper(quest, obj.ObjectID)   // (batch 11j: a helper)
                && !_questTriggers.count(quest->GetQuestId())
                && quest->GetQuestId() != 14293 /* 8-10 vehiclewait: the horse ride completes it */)
                return no("credit creature that is not fought, talked to or hit by a known spell");
        }
        else if (obj.Type == QUEST_OBJECTIVE_LEARNSPELL)
            continue;   // a class spell that comes with a level: checked per bot (QuestDoable)
        else if (obj.Type == QUEST_OBJECTIVE_ITEM)
        {
            // a delivery - the quest hands the item out itself
            if (obj.ObjectID == quest->GetSrcItemId())
                continue;
            bool ok = _itemGoSources.count(obj.ObjectID) > 0;
            // a vendor in the open world sells it
            if (!ok)
            {
                auto vs = _itemVendorSources.find(obj.ObjectID);
                if (vs != _itemVendorSources.end())
                    for (uint32 entry : vs->second)
                        if (_creatureSpawns.count(entry))
                        {
                            ok = true;
                            break;
                        }
            }
            // batch 11d: the item of the quest makes it
            if (!ok)
            {
                auto qu = _questUse.find(quest->GetQuestId());
                if (qu != _questUse.end())
                    for (BotLifeQuestUse const& use : qu->second)
                        if (use.makes == uint32(obj.ObjectID))
                        {
                            ok = true;
                            break;
                        }
            }
            if (!ok)
            {
                auto cs = _itemCreatureSources.find(obj.ObjectID);
                if (cs != _itemCreatureSources.end())
                    for (uint32 entry : cs->second)
                        if (fightable(entry))
                        {
                            ok = true;
                            break;
                        }
            }
            if (!ok)
                ok = _itemClickSources.count(obj.ObjectID) != 0;   // batch 11o: a creature to click
            if (!ok)
                ok = _itemTalkSources.count(obj.ObjectID) != 0;    // batch 11y: an NPC that hands it out
            if (!ok)
                return no("item without a creature or chest to loot it from");
        }
        else if (obj.Type == QUEST_OBJECTIVE_GAMEOBJECT)
        {
            // an object to use, spawned in the open world
            if (!_goSpawns.count(obj.ObjectID))
                return no("object to use is not spawned in the open world");
        }
        else if (obj.Type == QUEST_OBJECTIVE_AREATRIGGER)
        {
            // a place to visit
            if (!_questTriggers.count(quest->GetQuestId()))
                return no("place to visit without an area trigger");
        }
        else if (obj.Type == QUEST_OBJECTIVE_TALKTO)
        {
            // batch 11v: somebody to talk to (or to click), spawned in the open world
            if (!_creatureSpawns.count(obj.ObjectID))
                return no("creature to talk to is not spawned in the open world");
        }
        else
            return no("currency, reputation, money, pet battle or player kill objective");
    }
    // the ender has to be there as well
    bool ender = false;
    for (auto const& rel : sObjectMgr->GetCreatureQuestInvolvedRelationReverseBounds(quest->GetQuestId()))
        if (_creatureSpawns.count(rel.second))
            ender = true;
    for (auto const& rel : sObjectMgr->GetGOQuestInvolvedRelationReverseBounds(quest->GetQuestId()))
        if (_goSpawns.count(rel.second))
            ender = true;   // (batch 11i: a quest object)
    if (!ender && why)
        return no("ender not spawned in the open world (phase 1)");   // (only for the report: QuestDoable checks it per bot)
    return true;
}

bool BotLifeMgr::OwnSideCreature(Player* bot, uint32 entry) const
{
    CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(entry);
    FactionTemplateEntry const* ft = ct ? sFactionTemplateStore.LookupEntry(ct->faction) : nullptr;
    if (!ft || ft->IsHostileToPlayers() || ft->IsNeutralToAll() || (ct->npcflag & UNIT_NPC_FLAG_GOSSIP))
        return false;
    uint32 const own = bot->GetTeam() == HORDE ? 4 : 2, other = bot->GetTeam() == HORDE ? 2 : 4;
    return (ft->hostileMask & other) && !(ft->hostileMask & own);
}

bool BotLifeMgr::NearestQuestTrigger(Player* bot, uint32 questId, BotLifeSpawn& out) const
{
    auto it = _questTriggers.find(questId);
    if (it == _questTriggers.end())
        return false;
    float best = MAX_TRAVEL_DIST;
    bool found = false;
    for (BotLifeSpawn const& s : it->second)
    {
        if (s.map != bot->GetMapId())
            continue;
        float const d = Dist2d(bot->GetPositionX(), bot->GetPositionY(), s.x, s.y);
        if (d < best)
        {
            best = d;
            out = s;
            found = true;
        }
    }
    return found;
}

// everything the quest needs (objective sources and the ender) is on this map within travel range
// set while QuestDoable looks at a quest a walker does not have yet: see SpawnInPhase
namespace
{
    thread_local bool tl_walkerAnyPhase = false;
    struct WalkerAnyPhaseGuard
    {
        bool const old;
        explicit WalkerAnyPhaseGuard(bool value) : old(tl_walkerAnyPhase) { tl_walkerAnyPhase = value; }
        ~WalkerAnyPhaseGuard() { tl_walkerAnyPhase = old; }
    };
}

bool BotLifeMgr::QuestDoable(Player* bot, Quest const* quest)
{
    if (quest->GetQuestId() == 14293)   // 8-10 vehiclewait
        return true;
    WalkerAnyPhaseGuard const anyPhase(IsWalker(bot) && bot->GetQuestStatus(quest->GetQuestId()) == QUEST_STATUS_NONE);
    // batch 11z3: a group quest only for a bot in a group of at least the suggested size
    if (quest->GetQuestInfoID() == 1 || quest->GetSuggestedPlayers() > 1)
    {
        Group const* group = bot->GetGroup();
        if (!group || group->GetMembersCount() < std::max<uint32>(2, quest->GetSuggestedPlayers()))
            return false;
    }
    BotLifeSpawn tmp;
    for (QuestObjective const& obj : quest->GetObjectives())
    {
        std::vector<uint32> creatures, objects;
        bool anywhere = false;   // batch 11d: made with the item of the quest, wherever the bot is
        if (obj.Type == QUEST_OBJECTIVE_MONSTER)
        {
            creatures.push_back(obj.ObjectID);
            auto kc = _killCreditSources.find(obj.ObjectID);
            if (kc != _killCreditSources.end())
                creatures.insert(creatures.end(), kc->second.begin(), kc->second.end());
            // NPCs of this bot's own faction are targets for the other side only
            creatures.erase(std::remove_if(creatures.begin(), creatures.end(), [&](uint32 entry) { return OwnSideCreature(bot, entry); }), creatures.end());
            auto credit = _creditSources.find(obj.ObjectID);
            if (credit != _creditSources.end())
                for (BotLifeCreditSource const& src : credit->second)
                    creatures.push_back(src.creature);
            if (AddQuestHelperSpots(quest, obj.ObjectID, creatures, objects))   // (batch 11j)
                anywhere = true;
            auto co = _creditObjects.find(obj.ObjectID);   // (batch 11l: an object to open)
            if (co != _creditObjects.end())
                objects.insert(objects.end(), co->second.begin(), co->second.end());
            AddEquipChests(bot, obj.ObjectID, objects);   // (batch 11m)
            AddToolDropSpots(bot, obj.ObjectID, creatures);   // (batch 11t)
        }
        else if (obj.Type == QUEST_OBJECTIVE_ITEM)
        {
            if (obj.ObjectID == quest->GetSrcItemId())
                continue;   // handed out on accept
            auto cs = _itemCreatureSources.find(obj.ObjectID);
            if (cs != _itemCreatureSources.end())
                creatures = cs->second;
            AddItemVendors(bot, obj.ObjectID, creatures);
            auto ic = _itemClickSources.find(obj.ObjectID);   // (batch 11o: a creature to click)
            if (ic != _itemClickSources.end())
                creatures.insert(creatures.end(), ic->second.begin(), ic->second.end());
            auto itk = _itemTalkSources.find(obj.ObjectID);   // (batch 11y: an NPC that hands it out)
            if (itk != _itemTalkSources.end())
                for (BotLifeCreditSource const& src : itk->second)
                    creatures.push_back(src.creature);
            anywhere = AddQuestUseSpots(quest, obj.ObjectID, creatures, objects, bot);   // (batch 11o: bot - a tool to fetch)
            auto gs = _itemGoSources.find(obj.ObjectID);
            if (gs != _itemGoSources.end())
                objects = gs->second;
        }
        else if (obj.Type == QUEST_OBJECTIVE_TALKTO)
            creatures.push_back(obj.ObjectID);   // batch 11v: somebody to talk to
        else if (obj.Type == QUEST_OBJECTIVE_GAMEOBJECT)
            objects.push_back(obj.ObjectID);
        else if (obj.Type == QUEST_OBJECTIVE_LEARNSPELL)
        {
            if (!bot->HasSpell(obj.ObjectID))
                return false;
            continue;
        }
        else if (obj.Type == QUEST_OBJECTIVE_AREATRIGGER)
        {
            if (!NearestQuestTrigger(bot, quest->GetQuestId(), tmp))
                return false;
            continue;
        }
        bool found = (!creatures.empty() && NearestSpawn(bot, creatures, false, tmp, MAX_TRAVEL_DIST))
            || (!objects.empty() && NearestSpawn(bot, objects, true, tmp, MAX_TRAVEL_DIST));
        // a creature credit that a listed area trigger gives
        if (!found && !anywhere && obj.Type == QUEST_OBJECTIVE_MONSTER && NearestQuestTrigger(bot, quest->GetQuestId(), tmp))
            continue;
        if (!found && !anywhere)
            return false;
    }
    if (quest->GetObjectives().empty() && quest->HasSpecialFlag(QUEST_SPECIAL_FLAGS_EXPLORATION_OR_EVENT)
        && quest->GetQuestId() != 14154 /* 8-10 eventwait2 */)
    {
        if (_questUse.count(quest->GetQuestId()))
        {
            // batch 11d: the item of the quest completes it, at a place or wherever the bot is
            std::vector<uint32> creatures, objects;
            if (!AddQuestUseSpots(quest, 0, creatures, objects)
                && !(!creatures.empty() && NearestSpawn(bot, creatures, false, tmp, MAX_TRAVEL_DIST))
                && !(!objects.empty() && NearestSpawn(bot, objects, true, tmp, MAX_TRAVEL_DIST)))
                return false;
        }
        else if (!NearestQuestTrigger(bot, quest->GetQuestId(), tmp))
        {
            // batch 11q: an event completes it - the NPC or the object behind it, within reach
            std::vector<uint32> creatures, objects;
            QuestEventSpots(quest->GetQuestId(), creatures, objects);
            if (!(!creatures.empty() && NearestSpawn(bot, creatures, false, tmp, MAX_TRAVEL_DIST))
                && !(!objects.empty() && NearestSpawn(bot, objects, true, tmp, MAX_TRAVEL_DIST)))
                return false;
        }
    }
    std::vector<uint32> enders, goEnders;
    for (auto const& rel : sObjectMgr->GetCreatureQuestInvolvedRelationReverseBounds(quest->GetQuestId()))
        enders.push_back(rel.second);
    for (auto const& rel : sObjectMgr->GetGOQuestInvolvedRelationReverseBounds(quest->GetQuestId()))
        goEnders.push_back(rel.second);   // (batch 11i: a quest object)
    return (!enders.empty() && NearestSpawn(bot, enders, false, tmp, MAX_TRAVEL_DIST))
        || (!goEnders.empty() && NearestSpawn(bot, goEnders, true, tmp, MAX_TRAVEL_DIST));
}

bool BotLifeMgr::QuestLevelOk(Player* bot, Quest const* quest) const
{
    int32 level = bot->GetLevel();
    if (level < quest->GetMinLevel())
        return false;
    int32 questLevel = quest->GetQuestLevel() > 0 ? quest->GetQuestLevel() : level;
    if (questLevel > level + 2)
        return false;
    // a walker tests every quest of its zones, the grey ones as well: a player can do them
    if (IsWalker(bot))
        return true;
    if (questLevel >= level - 5)
        return true;
    // the next step of a chain the bot is on, up to 10 levels lower - players finish a chain too
    // (Echo Isles: Young and Vicious, level 3, was too low at level 9 and the chain to Sen'jin Village stopped)
    if (questLevel < level - 10)
        return false;
    if (quest->GetPrevQuestId() > 0 && bot->GetQuestRewardStatus(quest->GetPrevQuestId()))
        return true;
    auto in = _questLeadsIn.find(quest->GetQuestId());
    if (in != _questLeadsIn.end())
        for (uint32 prev : in->second)
            if (bot->GetQuestRewardStatus(prev))
                return true;
    return false;
}

uint32 BotLifeMgr::ActiveQuestCount(Player* bot) const
{
    uint32 count = 0;
    for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
        if (bot->GetQuestSlotQuestId(slot))
            ++count;
    return count;
}

// quests the bots keep failing
void BotLifeMgr::LoadBadQuests()
{
    auto bad = std::make_shared<std::unordered_set<uint32>>();
    if (_questLearning)
        if (QueryResult result = PlayerbotsDatabase.Query("SELECT quest FROM tt_botlife_quest_record "
            "WHERE (fails >= 6 AND wins = 0) OR (fails >= 30 AND wins * 15 < fails)"))
            do
            {
                bad->insert(result->Fetch()[0].GetUInt32());
            } while (result->NextRow());
    size_t const count = bad->size();
    std::atomic_store(&_badQuests, std::shared_ptr<std::unordered_set<uint32> const>(std::move(bad)));
    TC_LOG_INFO("playerbots", "BotLife: {} quests the bots keep failing are out", count);
}

bool BotLifeMgr::IsBadQuest(uint32 questId) const
{
    std::shared_ptr<std::unordered_set<uint32> const> bad = std::atomic_load(&_badQuests);
    return bad && bad->count(questId) > 0;
}

void BotLifeMgr::RecordQuest(uint32 questId, bool success)
{
    if (!_questLearning || !questId)
        return;
    PlayerbotsDatabase.PExecute("INSERT INTO tt_botlife_quest_record (quest, fails, wins, ts) VALUES ({}, {}, {}, UNIX_TIMESTAMP()) "
        "ON DUPLICATE KEY UPDATE fails = fails + {}, wins = wins + {}, ts = UNIX_TIMESTAMP()",
        questId, success ? 0 : 1, success ? 1 : 0, success ? 0 : 1, success ? 1 : 0);
}

bool BotLifeMgr::HasAvailableQuest(Player* bot, BotLifeInfo& t, uint32 entry, bool go)
{
    for (uint32 questId : go ? sObjectMgr->GetGOQuestRelations(entry) : sObjectMgr->GetCreatureQuestRelations(entry))
    {
        if (t.skipQuests.count(questId))
            continue;
        Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
        if (!quest || !QuestLevelOk(bot, quest) || !WalkAllows(bot, quest))
            continue;
        if (!GetPlan(quest).supported || (IsBadQuest(questId) && !IsWalker(bot)))
        {
            // a quest to skip is a reason for the visit as well: it opens the rest of its chain
            if (CanSkipQuest(bot, quest))
                return true;
            continue;
        }
        if (bot->CanTakeQuest(quest, false) && bot->CanAddQuest(quest, false) && QuestDoable(bot, quest))
            return true;
        // a quest of the death knight chain the bot cannot get done is skipped at the giver
        if (quest->GetZoneOrSort() == -372 && DeathKnightChainOpen(bot) && CanSkipQuest(bot, quest))
            return true;
    }
    return false;
}

bool BotLifeMgr::FindQuestGiver(Player* bot, BotLifeInfo& t, BotLifeSpawn& out)
{
    auto it = _questGivers.find(bot->GetMapId());
    if (it == _questGivers.end())
        return false;

    uint32 now = getMSTime();
    uint32 zone = bot->GetZoneId();
    float bx = bot->GetPositionX(), by = bot->GetPositionY();
    std::vector<std::pair<float, BotLifeSpawn const*>> candidates;
    for (BotLifeSpawn const& s : it->second)
    {
        float d = Dist2d(bx, by, s.x, s.y);
        // a walker follows its chain across a zone border
        if (d > 1500.0f || (s.zone != zone && d > 500.0f && !IsWalker(bot)))
            continue;
        if (!SpawnInPhase(bot, s))
            continue;
        auto avoid = t.avoidNpc.find(s.entry | (s.go ? 0x80000000 : 0));
        if (avoid != t.avoidNpc.end() && now < avoid->second)
            continue;
        candidates.emplace_back(d, &s);
    }
    std::sort(candidates.begin(), candidates.end(), [](auto const& a, auto const& b) { return a.first < b.first; });

    std::set<uint32> checked;
    for (auto const& c : candidates)
    {
        if (checked.size() >= 25)
            break;
        uint32 const key = c.second->entry | (c.second->go ? 0x80000000 : 0);
        if (!checked.insert(key).second)
            continue;
        if (HasAvailableQuest(bot, t, c.second->entry, c.second->go))
        {
            out = *c.second;
            return true;
        }
        t.avoidNpc[key] = now + 15 * MINUTE * IN_MILLISECONDS;
    }
    return false;
}

uint32 BotLifeMgr::AcceptQuests(Player* bot, Creature* npc, BotLifeInfo& t, uint32 now)
{
    // some quest givers are EscortAI NPCs whose OnQuestAccept starts the escort right away; EscortAI::Start()
    // refuses (logs "attempts to Start while in combat") if the NPC is already fighting something else (e.g. npc_kayra_longmane,
    // Zangarmarsh), silently leaving the quest accepted but never progressing. Skip the whole visit and try again later.
    if (npc->IsInCombat())
        return 0;
    uint32 accepted = 0, skipped = 0;
    // (a second round after a skipped quest: what it kept closed may be offered by the same NPC)
    for (uint8 round = 0; round < 2 && (round == 0 || skipped); ++round)
    for (uint32 questId : sObjectMgr->GetCreatureQuestRelations(npc->GetEntry()))
    {
        if (ActiveQuestCount(bot) >= _maxQuests)
            break;
        if (t.skipQuests.count(questId))
            continue;
        Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
        if (!quest || !QuestLevelOk(bot, quest) || !WalkAllows(bot, quest))
            continue;
        // a quest a bot cannot do, or one the bots keep failing, is skipped: its chain goes on
        if (!GetPlan(quest).supported || (IsBadQuest(questId) && !IsWalker(bot)))
        {
            if (IsBadQuest(questId))
                Count(BLC_QUEST_BAD_SKIP);
            if (SkipQuest(bot, quest))
                ++skipped;
            continue;
        }
        if (!bot->CanTakeQuest(quest, false) || !bot->CanAddQuest(quest, false) || !QuestDoable(bot, quest))
        {
            // the death knight chain goes on past a quest the bot cannot get done
            if (quest->GetZoneOrSort() == -372 && DeathKnightChainOpen(bot) && SkipQuest(bot, quest))
                ++skipped;
            continue;
        }
        // an auto complete quest (a talk) has no accept: the NPC offers the reward right away
        if (quest->GetQuestType() == 0)
        {
            if (TurnIn(bot, npc, questId))
                ++accepted;
            continue;
        }
        bot->AddQuestAndCheckCompletion(quest, npc);
        if (bot->FindQuestSlot(questId) >= MAX_QUEST_LOG_SIZE)
            continue;
        t.questStarted[questId] = now;
        if (IsWalker(bot))
            TC_LOG_INFO("playerbots", "WALK {} lvl {}: accepted {} \"{}\" at {}", bot->GetName(), uint32(bot->GetLevel()), questId, quest->GetLogTitle(), npc->GetName());
        ++accepted;
        Count(BLC_QUEST_ACCEPT);
        if (t.party && bot->GetGroup() && bot->GetGroup()->GetLeaderGUID() == bot->GetGUID())
            PartyShareQuest(bot, quest, npc);
        if (_chat && urand(0, 99) < 4 && CanBroadcast(now, 60000))
        {
            std::string text = PickText("broadcast_quest_accepted_generic", bot);
            if (!text.empty())
            {
                std::ostringstream link;
                link << "|cffffff00|Hquest:" << questId << ":" << quest->GetQuestLevel() << "|h[" << quest->GetLogTitle() << "]|h|r";
                size_t pos = text.find("%quest_link");
                if (pos != std::string::npos)
                    text.replace(pos, 11, link.str());
                if (text.find('%') == std::string::npos)
                    Queue(urand(2000, 8000), bot, BOTLIFE_CHAT_GUILD, text);
            }
        }
    }
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {}: accepted {} quests from {}", bot->GetName(), accepted, npc->GetEntry());
    return accepted + skipped;
}

// batch 11i: the quests of a quest object (a crate, a body, a wanted poster)
uint32 BotLifeMgr::AcceptQuestsGo(Player* bot, GameObject* go, BotLifeInfo& t, uint32 now)
{
    uint32 accepted = 0;
    for (uint32 questId : sObjectMgr->GetGOQuestRelations(go->GetEntry()))
    {
        if (ActiveQuestCount(bot) >= _maxQuests)
            break;
        if (t.skipQuests.count(questId))
            continue;
        Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
        if (!quest || !QuestLevelOk(bot, quest) || !GetPlan(quest).supported || IsBadQuest(questId))
            continue;
        if (!bot->CanTakeQuest(quest, false) || !bot->CanAddQuest(quest, false) || !QuestDoable(bot, quest))
            continue;
        if (quest->GetQuestType() == 0)
        {
            if (TurnIn(bot, go, questId))
                ++accepted;
            continue;
        }
        bot->AddQuestAndCheckCompletion(quest, go);
        if (bot->FindQuestSlot(questId) >= MAX_QUEST_LOG_SIZE)
            continue;
        t.questStarted[questId] = now;
        ++accepted;
        Count(BLC_QUEST_ACCEPT);
    }
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {}: accepted {} quests from object {}", bot->GetName(), accepted, go->GetEntry());
    return accepted;
}

bool BotLifeMgr::FindQuestEnder(Player* bot, uint32 questId, BotLifeSpawn& out)
{
    // batch 11i: the nearest quest object that takes the quest, next to the NPCs below
    BotLifeSpawn goEnder;
    bool hasGoEnder = false;
    {
        std::vector<uint32> objects;
        uint32 const nowGo = getMSTime();
        PlayerbotAI* ai = GET_PLAYERBOT_AI(bot);
        for (auto const& rel : sObjectMgr->GetGOQuestInvolvedRelationReverseBounds(questId))
        {
            if (ai)
            {
                auto avoid = ai->life.avoidEnder.find(rel.second | 0x80000000);
                if (avoid != ai->life.avoidEnder.end() && nowGo < avoid->second)
                    continue;
            }
            objects.push_back(rel.second);
        }
        hasGoEnder = !objects.empty() && NearestSpawn(bot, objects, true, goEnder, MAX_TRAVEL_DIST);
    }
    BotLifeSpawn npcEnder;
    if (!FindQuestEnderNpc(bot, questId, npcEnder))
    {
        if (hasGoEnder)
            out = goEnder;
        return hasGoEnder;
    }
    out = npcEnder;
    if (hasGoEnder && Dist2d(bot->GetPositionX(), bot->GetPositionY(), goEnder.x, goEnder.y)
        < Dist2d(bot->GetPositionX(), bot->GetPositionY(), npcEnder.x, npcEnder.y))
        out = goEnder;
    return true;
}

bool BotLifeMgr::FindQuestEnderNpc(Player* bot, uint32 questId, BotLifeSpawn& out)
{
    std::vector<uint32> entries;
    for (auto const& rel : sObjectMgr->GetCreatureQuestInvolvedRelationReverseBounds(questId))
        entries.push_back(rel.second);
    if (entries.empty())
        return false;

    PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
    uint32 now = getMSTime();
    if (botAI)
    {
        std::vector<uint32> allowed;
        // its own list. avoidNpc also holds every NPC that had no quest to GIVE this bot (15 minutes,
        // FindQuestGiver) - such an NPC then could not take a quest in either ("no ender in reach").
        for (uint32 e : entries)
        {
            auto avoid = botAI->life.avoidEnder.find(e);
            if (avoid == botAI->life.avoidEnder.end() || now >= avoid->second)
                allowed.push_back(e);
        }
        entries.swap(allowed);
    }
    return NearestSpawn(bot, entries, false, out, MAX_TRAVEL_DIST);
}

bool BotLifeMgr::NearestSpawn(Player* bot, std::vector<uint32> const& entries, bool gameObjects, BotLifeSpawn& out, float maxDist)
{
    auto const& store = gameObjects ? _goSpawns : _creatureSpawns;
    float best = maxDist;
    bool found = false;
    float bx = bot->GetPositionX(), by = bot->GetPositionY();
    for (uint32 entry : entries)
    {
        auto it = store.find(entry);
        if (it == store.end())
            continue;
        for (BotLifeSpawn const& s : it->second)
        {
            if (s.map != bot->GetMapId())
                continue;
            if (!SpawnInPhase(bot, s))
                continue;
            float d = Dist2d(bx, by, s.x, s.y);
            if (d < best)
            {
                best = d;
                out = s;
                found = true;
            }
        }
    }
    return found;
}

// can the bot see this creature spawn? In the zone the bot is in the phases have to overlap.
// Elsewhere on the map the bot gets its phase when it arrives: only the phase 1 spawns count there, as before.
bool BotLifeMgr::SpawnInPhase(Player* bot, BotLifeSpawn const& spawn) const
{
    if (spawn.phaseMask & bot->GetPhaseMask())
        return true;
    // a MoP phase id: visible when the bot has that phase
    if (spawn.phaseId && bot->HasPhaseList(spawn.phaseId))
        return true;
    // a walker judging a quest it does not have yet: the quest brings the phase
    if (tl_walkerAnyPhase && (spawn.phaseMask || spawn.phaseId) && spawn.zone == bot->GetZoneId())
        return true;
    return spawn.zone != bot->GetZoneId() && (spawn.phaseMask & 1);
}

// encounters that begin with a conversation: (quest, gossip starter, creature that must become attackable).
// 24814 An Ancient Enemy: Vol'jin ("I am ready") starts the fight, Zar'jira is not attackable before; the event resets after 3 minutes.
bool BotLifeMgr::StartEventCreature(Player* bot, BotLifeInfo& t, uint32 now)
{
    static constexpr uint32 kStarts[][3] = { { 24814, 38225, 38306 } };
    for (auto const& st : kStarts)
    {
        if (bot->GetQuestStatus(st[0]) != QUEST_STATUS_INCOMPLETE)
            continue;
        Creature* target = bot->FindNearestCreature(st[2], 120.0f, true);
        if (!target || !target->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE))
            continue;   // already attackable (or not here): the fight is on
        Creature* starter = bot->FindNearestCreature(st[1], 120.0f, true);
        if (!starter || !starter->HasFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_GOSSIP))
            continue;   // the event is running (the gossip is off) or the starter is not here
        auto it = t.interacted.find(starter->GetGUID());
        if (it != t.interacted.end() && it->second > now)
            continue;
        if (bot->GetExactDist(starter) > 6.0f)
        {
            SetDest(t, bot->GetMapId(), starter->GetPositionX(), starter->GetPositionY(), starter->GetPositionZ(), 3.0f);
            return Travel(bot, t, now);
        }
        bot->StopMoving();
        bot->SetFacingToObject(starter);
        if (t.interacted.size() > 32)
            t.interacted.clear();
        t.interacted[starter->GetGUID()] = now + 60000;
        TC_LOG_INFO("playerbots", "BotLife {}: starts the event of quest {} by talking to {} ({})", bot->GetName(), st[0], starter->GetName(), starter->GetEntry());
        TalkTo(bot, starter);
        t.interactUntil = now + 3000;
        return true;
    }
    return false;
}

// encounters whose course depends on a click the player has to make: (quest, spell-click creature).
// 24814 An Ancient Enemy: the Fires of the Seas (38542) feed Zar'jira; stamping them out (spell click 73296) frees Vol'jin's friends.
bool BotLifeMgr::ClickEventCreature(Player* bot, BotLifeInfo& t, uint32 now)
{
    static constexpr std::pair<uint32, uint32> kEvents[] = { { 24814, 38542 } };
    for (auto const& ev : kEvents)
    {
        if (bot->GetQuestStatus(ev.first) != QUEST_STATUS_INCOMPLETE)
            continue;
        std::list<Creature*> found;
        bot->GetCreatureListWithEntryInGrid(found, ev.second, 80.0f);
        Creature* best = nullptr;
        for (Creature* c : found)
        {
            if (!c->IsAlive() || !c->HasFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK) || c->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE))
                continue;
            auto it = t.interacted.find(c->GetGUID());
            if (it != t.interacted.end() && it->second > now)
                continue;   // clicked a moment ago
            if (!best || bot->GetExactDist(c) < bot->GetExactDist(best))
                best = c;
        }
        if (!best)
            continue;
        if (bot->GetExactDist(best) > 7.0f)
        {
            SetDest(t, bot->GetMapId(), best->GetPositionX(), best->GetPositionY(), best->GetPositionZ(), 4.0f);
            return Travel(bot, t, now);
        }
        bot->StopMoving();
        bot->SetFacingToObject(best);
        if (t.interacted.size() > 32)
            t.interacted.clear();
        t.interacted[best->GetGUID()] = now + 15000;
        TC_LOG_INFO("playerbots", "BotLife {}: clicks {} ({}) for quest {} (event creature)", bot->GetName(), best->GetName(), best->GetEntry(), ev.first);
        best->HandleSpellClick(bot);
        t.interactUntil = now + 2500;
        return true;
    }
    return false;
}

bool BotLifeMgr::PickObjectiveDest(Player* bot, BotLifeInfo& t, Quest const* quest)
{
    t.useGo.Clear();
    t.questPoint = false;
    // a place to visit - walk into the area trigger, the trigger check does the rest
    auto toTrigger = [&]() -> bool
    {
        BotLifeSpawn trigger;
        if (!NearestQuestTrigger(bot, quest->GetQuestId(), trigger))
            return false;
        SetDest(t, trigger.map, trigger.x, trigger.y, trigger.z, 2.0f);
        t.questPoint = true;
        return true;
    };
    if ((quest->GetObjectives().empty() && quest->GetQuestId() == 14154) || quest->GetQuestId() == 14293)   // 8-10 eventwait2 + vehiclewait: the server completes it, wait here
    {
        // 8-10 eventwait3
        if (!bot->HasAura(68218) && !bot->HasAura(66894) && bot->GetQuestStatus(14154) == QUEST_STATUS_INCOMPLETE)
        {
            bot->CastSpell(bot, 66894, true);
            TC_LOG_INFO("playerbots", "WALK {} quest 14154: prison timer missing, cast 66894, aura 68218 now {}", bot->GetName(), bot->HasAura(68218));
        }
        SetDest(t, bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), 2.0f);
        return true;
    }
    if (quest->GetObjectives().empty())
    {
        // batch 11d: the item of the quest completes it - at a spell focus, on a creature, or right here
        if (_questUse.count(quest->GetQuestId()))
        {
            std::vector<uint32> creatures, objects;
            bool const here = AddQuestUseSpots(quest, 0, creatures, objects);
            BotLifeSpawn spot;
            if ((!objects.empty() && NearestSpawn(bot, objects, true, spot, MAX_TRAVEL_DIST))
                || (!creatures.empty() && NearestSpawn(bot, creatures, false, spot, MAX_TRAVEL_DIST)))
            {
                SetDest(t, spot.map, spot.x, spot.y, spot.z, 10.0f);
                return true;
            }
            if (!here)
                return false;
            SetDest(t, bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), 2.0f);
            return true;
        }
        if (toTrigger())
            return true;
        // batch 11q: an event completes it - to the NPC or the object behind it
        std::vector<uint32> creatures, objects;
        QuestEventSpots(quest->GetQuestId(), creatures, objects);
        BotLifeSpawn spot;
        if ((!objects.empty() && NearestSpawn(bot, objects, true, spot, MAX_TRAVEL_DIST))
            || (!creatures.empty() && NearestSpawn(bot, creatures, false, spot, MAX_TRAVEL_DIST)))
        {
            SetDest(t, spot.map, spot.x, spot.y, spot.z, 10.0f);
            return true;
        }
        return false;
    }
    for (QuestObjective const& obj : quest->GetObjectives())
    {
        if (bot->IsQuestObjectiveComplete(quest, obj))
            continue;
        if (obj.Type == QUEST_OBJECTIVE_AREATRIGGER)
            return toTrigger();
        if (obj.Type == QUEST_OBJECTIVE_LEARNSPELL)
            return false;   // the spell comes with a level this bot does not have yet

        std::vector<uint32> creatures;
        std::vector<uint32> objects;
        bool anywhere = false;   // batch 11d: 
        if (obj.Type == QUEST_OBJECTIVE_MONSTER)
        {
            creatures.push_back(obj.ObjectID);
            auto kc = _killCreditSources.find(obj.ObjectID);
            if (kc != _killCreditSources.end())
                creatures.insert(creatures.end(), kc->second.begin(), kc->second.end());
            auto credit = _creditSources.find(obj.ObjectID);
            if (credit != _creditSources.end())
                for (BotLifeCreditSource const& src : credit->second)
                    creatures.push_back(src.creature);
            if (AddQuestHelperSpots(quest, obj.ObjectID, creatures, objects))   // (batch 11j)
                anywhere = true;
            auto co = _creditObjects.find(obj.ObjectID);   // (batch 11l: an object to open)
            if (co != _creditObjects.end())
                objects.insert(objects.end(), co->second.begin(), co->second.end());
            AddEquipChests(bot, obj.ObjectID, objects);   // (batch 11m)
            AddToolDropSpots(bot, obj.ObjectID, creatures);   // (batch 11t)
        }
        else if (obj.Type == QUEST_OBJECTIVE_ITEM)
        {
            auto cs = _itemCreatureSources.find(obj.ObjectID);
            if (cs != _itemCreatureSources.end())
                creatures = cs->second;
            AddItemVendors(bot, obj.ObjectID, creatures);
            auto ic = _itemClickSources.find(obj.ObjectID);   // (batch 11o: a creature to click)
            if (ic != _itemClickSources.end())
                creatures.insert(creatures.end(), ic->second.begin(), ic->second.end());
            auto itk = _itemTalkSources.find(obj.ObjectID);   // (batch 11y: an NPC that hands it out)
            if (itk != _itemTalkSources.end())
                for (BotLifeCreditSource const& src : itk->second)
                    creatures.push_back(src.creature);
            anywhere = AddQuestUseSpots(quest, obj.ObjectID, creatures, objects, bot);   // (batch 11o: bot - a tool to fetch)
            auto gs = _itemGoSources.find(obj.ObjectID);
            if (gs != _itemGoSources.end())
                objects = gs->second;
        }
        else if (obj.Type == QUEST_OBJECTIVE_TALKTO)
            creatures.push_back(obj.ObjectID);   // batch 11v: somebody to talk to
        else if (obj.Type == QUEST_OBJECTIVE_GAMEOBJECT)
            objects.push_back(obj.ObjectID);

        BotLifeSpawn creatureSpawn, goSpawn;
        bool hasCreature = !creatures.empty() && NearestSpawn(bot, creatures, false, creatureSpawn, MAX_TRAVEL_DIST);
        bool hasGo = !objects.empty() && NearestSpawn(bot, objects, true, goSpawn, MAX_TRAVEL_DIST);
        if (!hasCreature && !hasGo)
        {
            if (!anywhere)
                return toTrigger();   // no creature or object for this objective: its trigger
            // batch 11d: made with the item of the quest, right here
            SetDest(t, bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), 2.0f);
            return true;
        }

        BotLifeSpawn dest;
        if (hasGo && (!hasCreature || bot->GetExactDist2d(goSpawn.x, goSpawn.y) < bot->GetExactDist2d(creatureSpawn.x, creatureSpawn.y)))
            dest = goSpawn;
        else
            dest = creatureSpawn;

        // after a retarget pick one of the other spawns instead of the nearest
        if (t.questRetarget && !creatures.empty() && dest.entry == creatureSpawn.entry)
        {
            auto it = _creatureSpawns.find(creatureSpawn.entry);
            if (it != _creatureSpawns.end() && it->second.size() > 1)
            {
                std::vector<BotLifeSpawn const*> near;
                for (BotLifeSpawn const& s : it->second)
                    if (s.map == bot->GetMapId() && bot->GetExactDist2d(s.x, s.y) < 800.0f)
                        near.push_back(&s);
                if (!near.empty())
                    dest = *near[urand(0, near.size() - 1)];
            }
        }

        SetDest(t, dest.map, dest.x, dest.y, dest.z, 20.0f);
        return true;
    }
    return toTrigger();   // nothing to fight or use: the quest's area trigger, if it has one
}

// another spawn of something an open objective needs - a creature to kill or to loot, an object to
// open - 60 to 700 yd from here; one of the six nearest, so that the bots of one quest spread over its area.
bool BotLifeMgr::PickRoamDest(Player* bot, BotLifeInfo& t, Quest const* quest)
{
    std::vector<std::pair<float, BotLifeSpawn const*>> near;
    float const bx = bot->GetPositionX(), by = bot->GetPositionY();
    auto collect = [&](std::unordered_map<uint32, std::vector<BotLifeSpawn>> const& store, uint32 entry)
    {
        auto it = store.find(entry);
        if (it == store.end())
            return;
        for (BotLifeSpawn const& s : it->second)
        {
            if (s.map != bot->GetMapId())
                continue;
            float const d = Dist2d(bx, by, s.x, s.y);
            if (d >= 60.0f && d <= 700.0f)
                near.emplace_back(d, &s);
        }
    };
    for (QuestObjective const& obj : quest->GetObjectives())
    {
        if (bot->IsQuestObjectiveComplete(quest, obj))
            continue;
        if (obj.Type == QUEST_OBJECTIVE_MONSTER)
        {
            collect(_creatureSpawns, obj.ObjectID);
            auto kc = _killCreditSources.find(obj.ObjectID);
            if (kc != _killCreditSources.end())
                for (uint32 entry : kc->second)
                    collect(_creatureSpawns, entry);
            auto credit = _creditSources.find(obj.ObjectID);
            if (credit != _creditSources.end())
                for (BotLifeCreditSource const& src : credit->second)
                    collect(_creatureSpawns, src.creature);
        }
        else if (obj.Type == QUEST_OBJECTIVE_ITEM)
        {
            auto cs = _itemCreatureSources.find(obj.ObjectID);
            if (cs != _itemCreatureSources.end())
                for (uint32 entry : cs->second)
                    collect(_creatureSpawns, entry);
            auto ic = _itemClickSources.find(obj.ObjectID);   // (batch 11o)
            if (ic != _itemClickSources.end())
                for (uint32 entry : ic->second)
                    collect(_creatureSpawns, entry);
            auto itk = _itemTalkSources.find(obj.ObjectID);   // (batch 11y)
            if (itk != _itemTalkSources.end())
                for (BotLifeCreditSource const& src : itk->second)
                    collect(_creatureSpawns, src.creature);
            auto gs = _itemGoSources.find(obj.ObjectID);
            if (gs != _itemGoSources.end())
                for (uint32 entry : gs->second)
                    collect(_goSpawns, entry);
        }
        else if (obj.Type == QUEST_OBJECTIVE_GAMEOBJECT)
            collect(_goSpawns, obj.ObjectID);
    }
    if (near.empty())
        return false;
    t.questPoint = false;
    size_t const pool = std::min<size_t>(near.size(), 6);
    std::partial_sort(near.begin(), near.begin() + pool, near.end(), [](auto const& a, auto const& b) { return a.first < b.first; });
    BotLifeSpawn const* pick = near[urand(0, uint32(pool) - 1)].second;
    SetDest(t, pick->map, pick->x, pick->y, pick->z, 20.0f);
    return true;
}

bool BotLifeMgr::EngageQuestCreature(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    Quest const* quest = sObjectMgr->GetQuestTemplate(t.questId);
    if (!quest)
        return false;

    Creature* target = t.questTarget.IsEmpty() ? nullptr : ObjectAccessor::GetCreature(*bot, t.questTarget);
    if (target && (!target->IsAlive() || target->IsInEvadeMode() || (target->HasLootRecipient() && !target->IsTappedBy(bot))))
        target = nullptr;
    if (target && now - t.questTargetSince > 25000)
    {
        // could not get into a fight with it (unreachable, immune, ...)
        t.badQuestTargets[target->GetGUID()] = now + 5 * MINUTE * IN_MILLISECONDS;
        Count(BLC_QUEST_ENGAGE_FAIL);
        target = nullptr;
    }

    if (!target)
    {
        t.questTarget.Clear();
        if (now < t.nextQuestTargetSearch)
            return false;
        t.nextQuestTargetSearch = now + 3000;
        if (t.badQuestTargets.size() > 32)
            t.badQuestTargets.clear();

        // "learn the spell, then use it": the spell of a learn objective this bot has
        bool learned = false;
        for (QuestObjective const& obj : quest->GetObjectives())
            if (obj.Type == QUEST_OBJECTIVE_LEARNSPELL && bot->HasSpell(obj.ObjectID))
                learned = true;
        // creatures for the objectives that are still open
        std::vector<uint32> entries;
        for (QuestObjective const& obj : quest->GetObjectives())
        {
            if (bot->IsQuestObjectiveComplete(quest, obj))
                continue;
            if (obj.Type == QUEST_OBJECTIVE_MONSTER)
            {
                entries.push_back(obj.ObjectID);
                auto kc = _killCreditSources.find(obj.ObjectID);
                if (kc != _killCreditSources.end())
                    entries.insert(entries.end(), kc->second.begin(), kc->second.end());
                // practice targets - the credit comes when a spell of ours hits them
                auto credit = _creditSources.find(obj.ObjectID);
                if (credit != _creditSources.end())
                    for (BotLifeCreditSource const& src : credit->second)
                        if (src.fight || (src.spell && (learned || bot->HasSpell(src.spell))))
                            entries.push_back(src.creature);
                // batch 11j: the creatures that feed a helper standing here
                auto qu = _questUse.find(quest->GetQuestId());
                if (qu != _questUse.end())
                    for (BotLifeQuestUse const& use : qu->second)
                        if (use.credit == uint32(obj.ObjectID) && bot->FindNearestCreature(use.credit, 30.0f, true))
                            entries.insert(entries.end(), use.creatures.begin(), use.creatures.end());
                AddToolDropSpots(bot, obj.ObjectID, entries);   // batch 11t: the creatures that drop the tool
            }
            else if (obj.Type == QUEST_OBJECTIVE_ITEM)
            {
                auto cs = _itemCreatureSources.find(obj.ObjectID);
                if (cs != _itemCreatureSources.end())
                    entries.insert(entries.end(), cs->second.begin(), cs->second.end());
                auto qu = _questUse.find(quest->GetQuestId());   // batch 11o: a creature that drops a tool
                if (qu != _questUse.end())
                    for (BotLifeQuestUse const& use : qu->second)
                        if (use.tool && use.makes == uint32(obj.ObjectID) && !bot->HasItemCount(use.item, 1))
                        {
                            auto ts = _itemCreatureSources.find(use.item);
                            if (ts != _itemCreatureSources.end())
                                entries.insert(entries.end(), ts->second.begin(), ts->second.end());
                        }
            }
        }
        // batch 11f: a creature whose corpse the item of the quest is used on
        {
            auto qu = _questUse.find(quest->GetQuestId());
            if (qu != _questUse.end())
                for (BotLifeQuestUse const& use : qu->second)
                    if (use.corpse)
                        entries.insert(entries.end(), use.creatures.begin(), use.creatures.end());
        }
        // batch 11z: an escort - what attacks the one the bot walks with
        if (quest->GetObjectives().empty())
        {
            auto qe = _questEventSources.find(quest->GetQuestId());
            if (qe != _questEventSources.end())
                for (BotLifeCreditSource const& src : qe->second)
                {
                    if (!src.follow || target)
                        continue;
                    Creature* escort = bot->FindNearestCreature(src.creature, 40.0f, true);
                    if (!escort || !escort->IsInCombat())
                        continue;
                    for (Unit* attacker : escort->getAttackers())
                        if (Creature* c = attacker ? attacker->ToCreature() : nullptr)
                            if (c->IsAlive() && bot->IsValidAttackTarget(c))
                            {
                                target = c;
                                break;
                            }
                }
        }
        // batch 11q: a quest without objectives that a kill completes
        if (quest->GetObjectives().empty())
        {
            auto qe = _questEventSources.find(quest->GetQuestId());
            if (qe != _questEventSources.end())
                for (BotLifeCreditSource const& src : qe->second)
                    if (src.fight)
                        entries.push_back(src.creature);
        }
        float best = 0.0f;
        for (uint32 entry : entries)
        {
            std::list<Creature*> list;
            bot->GetCreatureListWithEntryInGrid(list, entry, 70.0f);
            for (Creature* c : list)
            {
                // why is Zar'jira not chosen?
                if (entry == 38306)
                {
                    static std::unordered_map<ObjectGuid::LowType, uint32> s_zjDiag;
                    uint32& nextLog = s_zjDiag[bot->GetGUID().GetCounter()];
                    if (now >= nextLog)
                    {
                        nextLog = now + 15000;
                        TC_LOG_INFO("playerbots", "BotLife {}: engage diag Zar'jira: alive {} evade {} validAttack {} lootRecipient {} tappedByBot {} levelGap {} avoided {} flags {:#x} dist {:.0f}",
                            bot->GetName(), c->IsAlive() ? 1 : 0, c->IsInEvadeMode() ? 1 : 0, bot->IsValidAttackTarget(c) ? 1 : 0, c->HasLootRecipient() ? 1 : 0,
                            c->IsTappedBy(bot) ? 1 : 0, int32(c->GetLevel()) - int32(bot->GetLevel()), IsAvoidedTarget(bot, c) ? 1 : 0, c->GetUInt32Value(UNIT_FIELD_FLAGS), bot->GetExactDist(c));
                    }
                }
                if (!c->IsAlive() || c->IsInEvadeMode() || !bot->IsValidAttackTarget(c))
                    continue;
                if (c->HasLootRecipient() && !c->IsTappedBy(bot))
                    continue;
                if (int32(c->GetLevel()) - int32(bot->GetLevel()) > 4 || IsAvoidedTarget(bot, c))
                    continue;
                auto bad = t.badQuestTargets.find(c->GetGUID());
                if (bad != t.badQuestTargets.end() && now < bad->second)
                    continue;
                float d = bot->GetExactDist(c);
                if (!target || d < best)
                {
                    target = c;
                    best = d;
                }
            }
        }
        if (!target)
            return false;
        t.questTarget = target->GetGUID();
        t.questTargetSince = now;
        Count(BLC_QUEST_ENGAGE);
    }

    botAI->GetAiObjectContext()->GetValue<Unit*>("current target")->Set(target);
    bot->SetSelection(target->GetGUID());
    // casters and hunters open from range; chasing into melee kept them moving so they never cast
    bool ranged = PlayerBotSpec::IsRanged(bot);
    // a target that does not fight back (practice target, neutral creature outside its
    // aggro range) never puts a caster in combat, and out of combat the bot casts nothing. After 6 seconds without a
    // hit: walk in and open with a melee swing, the fight that follows brings the spells.
    if (ranged && now - t.questTargetSince > 6000 && !target->IsInCombat() && target->IsFullHealth())
        ranged = false;
    if (bot->GetVictim() != target || (!ranged && !bot->HasUnitState(UNIT_STATE_MELEE_ATTACKING)))
        bot->Attack(target, !ranged);
    // a practice target gives its credit for one spell: use that one
    if (now >= t.nextQuestSpell)
    {
        t.nextQuestSpell = now + 2500;
        uint32 questSpell = 0;
        for (QuestObjective const& obj : quest->GetObjectives())
        {
            if (questSpell || obj.Type != QUEST_OBJECTIVE_MONSTER || bot->IsQuestObjectiveComplete(quest, obj))
                continue;
            auto credit = _creditSources.find(obj.ObjectID);
            if (credit == _creditSources.end())
                continue;
            for (BotLifeCreditSource const& src : credit->second)
                if (src.creature == target->GetEntry() && src.spell && bot->HasSpell(src.spell))
                {
                    questSpell = src.spell;
                    break;
                }
            // the credit comes from something the learned spell triggers (Seal of Command -> its hit): use the learned one
            if (!questSpell)
                for (QuestObjective const& learn : quest->GetObjectives())
                    if (learn.Type == QUEST_OBJECTIVE_LEARNSPELL && bot->HasSpell(learn.ObjectID))
                        questSpell = learn.ObjectID;
        }
        if (SpellInfo const* spellInfo = questSpell ? sSpellMgr->GetSpellInfo(questSpell) : nullptr)
        {
            if (!spellInfo->IsPositive())
                botAI->CastSpell(questSpell, target);
            else if (!bot->HasAura(questSpell))
                bot->CastSpell(bot, questSpell, false);   // a seal: on ourselves, the hits do the rest
        }
    }
    // a quest spell that works around the bot itself (Arcane Torrent on the Mana Wyrms) needs the bot
    // next to its target, a caster as well
    if (ranged)
        for (QuestObjective const& obj : quest->GetObjectives())
        {
            auto credit = obj.Type == QUEST_OBJECTIVE_MONSTER ? _creditSources.find(obj.ObjectID) : _creditSources.end();
            if (credit == _creditSources.end())
                continue;
            for (BotLifeCreditSource const& src : credit->second)
                if (src.creature == target->GetEntry() && src.spell && bot->HasSpell(src.spell))
                    if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(src.spell))
                        if (spellInfo->GetMaxRange(false) < 10.0f)
                            ranged = false;
        }
    if (!bot->isMoving() || now - t.lastMoveOrder > 2000)
    {
        bot->GetMotionMaster()->MoveChase(target, ranged ? 25.0f : 0.0f);
        t.lastMoveOrder = now;
    }
    return true;
}

uint32 BotLifeMgr::QuestProgressValue(Player* bot, Quest const* quest) const
{
    uint32 value = 0;
    for (QuestObjective const& obj : quest->GetObjectives())
    {
        if (obj.Type == QUEST_OBJECTIVE_ITEM)
            value += bot->GetItemCount(obj.ObjectID, false);
        else
            value += bot->GetQuestObjectiveCounter(obj.ID);
    }
    return value;
}

void BotLifeMgr::FindQuestObject(Player* bot, BotLifeInfo& t)
{
    Quest const* quest = sObjectMgr->GetQuestTemplate(t.questId);
    if (!quest)
        return;
    // batch 11q: an object whose use completes a quest without objectives
    auto qo = quest->GetObjectives().empty() ? _questEventObjects.find(quest->GetQuestId()) : _questEventObjects.end();
    if (qo != _questEventObjects.end())
        for (uint32 entry : qo->second)
        {
            GameObject* go = bot->FindNearestGameObject(entry, 50.0f);
            if (!go || !go->isSpawned() || go->getLootState() != GO_READY)
                continue;
            auto used = t.usedGos.find(go->GetGUID());
            if (used != t.usedGos.end() && getMSTime() < used->second)
                continue;
            t.useGo = go->GetGUID();
            return;
        }
    for (QuestObjective const& obj : quest->GetObjectives())
    {
        if (bot->IsQuestObjectiveComplete(quest, obj))
            continue;
        std::vector<uint32> entries;
        if (obj.Type == QUEST_OBJECTIVE_ITEM)
        {
            auto sources = _itemGoSources.find(obj.ObjectID);
            if (sources != _itemGoSources.end())
                entries = sources->second;
            auto qu = _questUse.find(quest->GetQuestId());   // batch 11o: the chest of a tool to fetch
            if (qu != _questUse.end())
                for (BotLifeQuestUse const& use : qu->second)
                    if (use.tool && use.makes == uint32(obj.ObjectID) && !bot->HasItemCount(use.item, 1))
                    {
                        auto ts = _itemGoSources.find(use.item);
                        if (ts != _itemGoSources.end())
                            entries.insert(entries.end(), ts->second.begin(), ts->second.end());
                    }
        }
        else if (obj.Type == QUEST_OBJECTIVE_GAMEOBJECT)
            entries.push_back(obj.ObjectID);   // an object to use
        else if (obj.Type == QUEST_OBJECTIVE_MONSTER)
        {
            auto co = _creditObjects.find(obj.ObjectID);   // batch 11l: an object that gives the credit
            if (co != _creditObjects.end())
                entries = co->second;
            AddEquipChests(bot, obj.ObjectID, entries);    // batch 11m: a chest with an item to put on
        }
        if (entries.empty())
            continue;
        GameObject* best = nullptr;
        float bestDist = 50.0f;
        for (uint32 entry : entries)
        {
            GameObject* go = bot->FindNearestGameObject(entry, 50.0f);
            if (!go || !go->isSpawned() || go->getLootState() != GO_READY)
                continue;
            auto used = t.usedGos.find(go->GetGUID());
            if (used != t.usedGos.end() && getMSTime() < used->second)
                continue;
            float d = bot->GetExactDist(go);
            if (d < bestDist)
            {
                best = go;
                bestDist = d;
            }
        }
        if (best)
        {
            t.useGo = best->GetGUID();
            return;
        }
    }
}

bool BotLifeMgr::UseQuestObject(Player* bot, BotLifeInfo& t, uint32 now)
{
    GameObject* go = ObjectAccessor::GetGameObject(*bot, t.useGo);
    if (!go || !go->isSpawned() || go->getLootState() != GO_READY)
    {
        t.useGo.Clear();
        return false;
    }
    if (bot->GetExactDist(go) > INTERACTION_DISTANCE - 1.0f)
    {
        if (!bot->isMoving() || now - t.lastMoveOrder > 3000)
        {
            bot->GetMotionMaster()->MovePoint(0, go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(), true);
            t.lastMoveOrder = now;
        }
        return true;
    }

    bot->StopMoving();
    ObjectGuid guid = go->GetGUID();
    // the same object is not opened again for a while (it may hold nothing for us and stay ready)
    if (t.usedGos.size() > 32)
        t.usedGos.clear();
    t.usedGos[guid] = now + 5 * MINUTE * IN_MILLISECONDS;
    // at a Runeforge of Acherus a death knight engraves its weapon - the engraving gives the credit
    if (go->GetEntry() == GO_ACHERUS_RUNEFORGE && t.questId == QUEST_DK_RUNEFORGING)
    {
        DeathKnightWeapon(bot);
        bot->CastSpell(bot, SPELL_RUNEFORGING_CREDIT, true);
        Count(BLC_LOOT_GO);
        t.useGo.Clear();
        return true;
    }
    if (go->GetGoType() != GAMEOBJECT_TYPE_CHEST)
    {
        // not a chest - using it is the objective (a goober gives the credit in GameObject::Use)
        go->Use(bot);
        // batch 11z2: an object whose gossip hands the item out - pick its first option, as a player does
        if (_gossipItemObjects.count(go->GetEntry()) && go->AI())
            go->AI()->OnGossipSelect(bot, go->GetGOInfo()->GetGossipMenuId(), 0);
        Count(BLC_LOOT_GO);
        t.useGo.Clear();
        return true;
    }
    bot->SendLoot(guid, LOOT_CORPSE);
    if (bot->GetLootGUID() == guid)
    {
        Loot* loot = &go->loot;
        uint32 maxSlot = std::min<uint32>(uint32(loot->items.size() + loot->quest_items.size()), 16);
        for (uint32 slot = 0; slot < maxSlot; ++slot)
        {
            LootItem* item = loot->LootItemInSlot(slot, bot);
            if (!item || item->is_looted)
                continue;
            bot->StoreLootItem(uint8(slot), loot);
            Count(BLC_LOOT_ITEM);
        }
        Count(BLC_LOOT_GO);
        bot->GetSession()->DoLootRelease(guid);
    }
    t.useGo.Clear();
    return true;
}

// what a client does with a gossip window - open it and pick the conversation option(s). Gossip
// scripts (C++ and SmartAI) give their quest credit from there.
void BotLifeMgr::TalkTo(Player* bot, Creature* npc)
{
    bot->TalkedToCreature(npc->GetEntry(), npc->GetGUID());   // batch 11v: "talk to" objectives, as a gossip hello does
    bot->PlayerTalkClass->ClearMenus();
    if (!sScriptMgr->OnGossipHello(bot, npc) && !npc->AI()->OnGossipHello(bot))
    {
        bot->PrepareGossipMenu(npc, npc->GetGossipMenuId(), true);
        bot->SendPreparedGossip(npc);
    }
    for (uint8 step = 0; step < 4; ++step)
    {
        GossipMenu const& menu = bot->PlayerTalkClass->GetGossipMenu();
        uint32 const menuId = menu.GetMenuId();
        int32 pick = -1;
        // the chat bubble options: a database menu marks them GOSSIP_OPTION_GOSSIP, a script gives them an action id
        // (2-10, batch 11f: one of them at random, also one with a small fee - the clues of a quest can be
        // spread over the options)
        std::vector<int32> options;
        for (auto const& item : menu.GetMenuItems())
            if (item.second.MenuItemIcon == 0 && !item.second.IsCoded
                && (!item.second.BoxMoney || (item.second.BoxMoney <= 100 && bot->HasEnoughMoney(uint64(item.second.BoxMoney))))
                && (item.second.OptionType == GOSSIP_OPTION_GOSSIP || item.second.OptionType >= 1000))
                options.push_back(int32(item.first));
        if (!options.empty())
            pick = options[urand(0, uint32(options.size()) - 1)];
        if (pick < 0)
            break;
        uint32 const sender = bot->PlayerTalkClass->GetGossipOptionSender(pick);
        uint32 const action = bot->PlayerTalkClass->GetGossipOptionAction(pick);
        if (!sScriptMgr->OnGossipSelect(bot, npc, sender, action) && !npc->AI()->OnGossipSelect(bot, menuId, pick))
            bot->OnGossipSelect(npc, pick, menuId);
        if (!bot->IsInWorld() || bot->IsBeingTeleported() || !npc->IsInWorld())
            return;
    }
    bot->PlayerTalkClass->ClearMenus();
}

// batch 11d: where the item of the quest is used for this result (an objective item, or 0 = the quest
// itself); true when one of the ways needs no place at all
bool BotLifeMgr::AddQuestUseSpots(Quest const* quest, uint32 makes, std::vector<uint32>& creatures, std::vector<uint32>& objects, Player* bot) const
{
    auto qu = _questUse.find(quest->GetQuestId());
    if (qu == _questUse.end())
        return false;
    bool anywhere = false;
    for (BotLifeQuestUse const& use : qu->second)
    {
        if (use.makes != makes || use.credit)
            continue;
        // batch 11o: a tool the bot does not carry yet: where it lies, drops or is sold
        if (use.tool && bot && !bot->HasItemCount(use.item, 1))
        {
            auto gs = _itemGoSources.find(use.item);
            if (gs != _itemGoSources.end())
                objects.insert(objects.end(), gs->second.begin(), gs->second.end());
            auto cs = _itemCreatureSources.find(use.item);
            if (cs != _itemCreatureSources.end())
                creatures.insert(creatures.end(), cs->second.begin(), cs->second.end());
            AddItemVendors(bot, use.item, creatures);
            continue;
        }
        creatures.insert(creatures.end(), use.creatures.begin(), use.creatures.end());
        objects.insert(objects.end(), use.objects.begin(), use.objects.end());
        if (use.creatures.empty() && use.objects.empty())
            anywhere = true;
    }
    return anywhere;
}

// batch 11q: the NPCs and objects whose event completes a quest without objectives (spawned ones)
void BotLifeMgr::QuestEventSpots(uint32 questId, std::vector<uint32>& creatures, std::vector<uint32>& objects) const
{
    auto qe = _questEventSources.find(questId);
    if (qe != _questEventSources.end())
        for (BotLifeCreditSource const& src : qe->second)
            if (_creatureSpawns.count(src.creature))
                creatures.push_back(src.creature);
    auto qo = _questEventObjects.find(questId);
    if (qo != _questEventObjects.end())
        for (uint32 go : qo->second)
            if (_goSpawns.count(go))
                objects.push_back(go);
}

// batch 11t: the creatures that drop the tool for a credit - none while the bot has the spell itself or
// a tool for it in its bags
void BotLifeMgr::AddToolDropSpots(Player* bot, uint32 credit, std::vector<uint32>& creatures) const
{
    auto cs = _creditSources.find(credit);
    if (cs == _creditSources.end())
        return;
    std::vector<uint32> drops;
    for (BotLifeCreditSource const& src : cs->second)
    {
        if (!src.spell || src.fight)
            continue;
        if (bot->HasSpell(src.spell))
            return;
        auto tools = _spellTools.find(src.spell);
        if (tools == _spellTools.end())
            continue;
        for (uint32 tool : tools->second)
        {
            if (bot->HasItemCount(tool, 1))
                return;
            auto it = _itemCreatureSources.find(tool);
            if (it != _itemCreatureSources.end())
                drops.insert(drops.end(), it->second.begin(), it->second.end());
        }
    }
    creatures.insert(creatures.end(), drops.begin(), drops.end());
}

// batch 11m: the chests of the items this bot can use whose equip spell gives the credit - none while it
// carries such an item already
void BotLifeMgr::AddEquipChests(Player* bot, uint32 credit, std::vector<uint32>& objects) const
{
    auto ec = _equipCredits.find(credit);
    if (ec == _equipCredits.end())
        return;
    for (uint32 item : ec->second)
        if (bot->GetItemCount(item, true))
            return;
    for (uint32 item : ec->second)
    {
        ItemTemplate const* proto = sObjectMgr->GetItemTemplate(item);
        if (!proto || bot->CanUseItem(proto) != EQUIP_ERR_OK)
            continue;
        auto ch = _equipItemChests.find(item);
        if (ch != _equipItemChests.end())
            objects.insert(objects.end(), ch->second.begin(), ch->second.end());
    }
}

// batch 11m: an item in the bags whose equip spell gives an open credit of the quest: put it on
bool BotLifeMgr::EquipQuestItem(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (_equipCredits.empty() || bot->IsInCombat())
        return false;
    Quest const* quest = sObjectMgr->GetQuestTemplate(t.questId);
    if (!quest)
        return false;
    for (QuestObjective const& obj : quest->GetObjectives())
    {
        if (obj.Type != QUEST_OBJECTIVE_MONSTER || bot->IsQuestObjectiveComplete(quest, obj))
            continue;
        auto ec = _equipCredits.find(obj.ObjectID);
        if (ec == _equipCredits.end())
            continue;
        for (uint32 entry : ec->second)
        {
            Item* item = nullptr;
            for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END && !item; ++slot)
                if (Item* i = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
                    if (i->GetEntry() == entry)
                        item = i;
            for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END && !item; ++bag)
                if (Bag* container = bot->GetBagByPos(bag))
                    for (uint32 slot = 0; slot < container->GetBagSize() && !item; ++slot)
                        if (Item* i = container->GetItemByPos(uint8(slot)))
                            if (i->GetEntry() == entry)
                                item = i;
            if (!item)
                continue;
            uint16 dest;
            if (bot->CanEquipItem(NULL_SLOT, dest, item, true) != EQUIP_ERR_OK)
                continue;
            bot->SwapItem(item->GetPos(), dest);
            Count(BLC_QUEST_ENGAGE);
            if (_debug)
                TC_LOG_INFO("playerbots", "BotLife {}: equips {} for quest {}", bot->GetName(), entry, quest->GetQuestId());
            t.interactUntil = now + 1500;
            return true;
        }
    }
    return false;
}

// batch 11j: where the item that summons the helper of a credit is used; true when anywhere will do
bool BotLifeMgr::AddQuestHelperSpots(Quest const* quest, uint32 credit, std::vector<uint32>& creatures, std::vector<uint32>& objects) const
{
    auto qu = _questUse.find(quest->GetQuestId());
    if (qu == _questUse.end())
        return false;
    bool anywhere = false;
    for (BotLifeQuestUse const& use : qu->second)
    {
        if (!use.credit || use.credit != credit)
            continue;
        creatures.insert(creatures.end(), use.creatures.begin(), use.creatures.end());
        objects.insert(objects.end(), use.objects.begin(), use.objects.end());
        if (use.creatures.empty() && use.objects.empty())
            anywhere = true;
    }
    return anywhere;
}

bool BotLifeMgr::HasQuestHelper(Quest const* quest, uint32 credit) const
{
    auto qu = _questUse.find(quest->GetQuestId());
    if (qu != _questUse.end())
        for (BotLifeQuestUse const& use : qu->second)
            if ((use.credit && use.credit == credit) || (use.hitCredit && use.hitCredit == credit))
                return true;
    return false;
}

// batch 11d: the item of the quest has to be used - at a spell focus object (a phial at the moonwell),
// on a creature, or simply here - to make an objective item or to complete the quest
// the start item that calls up a companion (the Gilnean Mastiff): used wherever the bot stands,
// as soon as the quest is worked on and no living companion of the bot is near
bool BotLifeMgr::UseCompanionItem(Player* bot, BotLifeInfo& t, uint32 now)
{
    auto qu = _questUse.find(t.questId);
    if (qu == _questUse.end() || now < t.interactUntil || now < t.nextUseSearch)
        return false;
    if (bot->GetQuestStatus(t.questId) != QUEST_STATUS_INCOMPLETE)
        return false;
    for (BotLifeQuestUse const& use : qu->second)
    {
        if (!use.companion)
            continue;
        std::list<Creature*> list;
        bot->GetCreatureListWithEntryInGrid(list, use.companion, 60.0f);
        bool here = false;
        for (Creature* c : list)
            if (c->IsAlive() && c->GetOwnerGUID() == bot->GetGUID())
                here = true;
        if (here)
            continue;
        Item* item = bot->GetItemByEntry(use.item);
        SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(use.spell);
        if (!item || !spellInfo)
            continue;
        bot->UnsummonPetTemporaryIfAny();
        bot->StopMoving();
        SpellCastTargets targets;
        bot->CastItemUseSpell(item, targets, 0, 0);
        uint32 const busy = spellInfo->CalcCastTime() + 1500;
        t.interactUntil = now + busy;
        t.nextUseSearch = now + busy + 3000;
        TC_LOG_INFO("playerbots", "BotLife: {} calls up its companion {} with item {} for quest {}", bot->GetName(), use.companion, use.item, t.questId);
        Count(BLC_QUEST_ENGAGE);
        return true;
    }
    return false;
}

bool BotLifeMgr::UseQuestItem(Player* bot, BotLifeInfo& t, uint32 now)
{
    auto qu = _questUse.find(t.questId);
    if (qu == _questUse.end())
        return false;
    if (now < t.interactUntil)
        return true;   // casting
    if (bot->IsInCombat() || now < t.nextUseSearch)
        return false;
    Quest const* quest = sObjectMgr->GetQuestTemplate(t.questId);
    if (!quest || bot->GetQuestStatus(t.questId) != QUEST_STATUS_INCOMPLETE)
        return false;

    for (BotLifeQuestUse const& use : qu->second)
    {
        if (use.makes)
        {
            bool open = false;
            for (QuestObjective const& obj : quest->GetObjectives())
                if (obj.Type == QUEST_OBJECTIVE_ITEM && uint32(obj.ObjectID) == use.makes && !bot->IsQuestObjectiveComplete(quest, obj))
                    open = true;
            if (!open)
                continue;
        }
        // batch 11j: a helper - only while its objective is open and none stands here yet
        if (use.credit)
        {
            bool open = false;
            for (QuestObjective const& obj : quest->GetObjectives())
                if (obj.Type == QUEST_OBJECTIVE_MONSTER && uint32(obj.ObjectID) == use.credit && !bot->IsQuestObjectiveComplete(quest, obj))
                    open = true;
            if (!open || bot->FindNearestCreature(use.credit, 25.0f, true))
                continue;
        }
        // only while the objective the hit creature credits is open
        if (use.hitCredit)
        {
            bool open = false;
            for (QuestObjective const& obj : quest->GetObjectives())
                if (obj.Type == QUEST_OBJECTIVE_MONSTER && uint32(obj.ObjectID) == use.hitCredit && !bot->IsQuestObjectiveComplete(quest, obj))
                    open = true;
            if (!open)
                continue;
        }
        // batch 11s: the creature it calls up is still here: fight that one first
        if (use.summoned && bot->FindNearestCreature(use.summoned, 40.0f, true))
            continue;
        // our companion still stands here: nothing to do
        if (use.companion)
        {
            bool here = false;
            std::list<Creature*> list;
            bot->GetCreatureListWithEntryInGrid(list, use.companion, 60.0f);
            for (Creature* c : list)
                if (c->IsAlive() && c->GetOwnerGUID() == bot->GetGUID())
                    here = true;
            if (here)
                continue;
            bot->UnsummonPetTemporaryIfAny();   // a pet in the way blocked the mastiff (4-10)
        }
        Item* item = bot->GetItemByEntry(use.item);
        SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(use.spell);
        if (!item || !spellInfo)
            continue;

        WorldObject* spot = nullptr;
        Creature* target = nullptr;
        float best = 0.0f;
        for (uint32 entry : use.objects)
        {
            std::list<GameObject*> list;
            bot->GetGameObjectListWithEntryInGrid(list, entry, 60.0f);
            for (GameObject* go : list)
            {
                if (!go->isSpawned())
                    continue;
                float const d = bot->GetExactDist(go);
                if (!spot || d < best)
                {
                    spot = go;
                    best = d;
                }
            }
        }
        if (use.objects.empty())
            for (uint32 entry : use.creatures)
            {
                std::list<Creature*> list;
                bot->GetCreatureListWithEntryInGrid(list, entry, 60.0f);
                for (Creature* c : list)
                {
                    if (c->IsAlive() == use.corpse)
                        continue;   // (batch 11f: a corpse when the spell asks for one, a living creature otherwise)
                    auto done = t.interacted.find(c->GetGUID());
                    if (done != t.interacted.end() && now < done->second)
                        continue;
                    float const d = bot->GetExactDist(c);
                    if (!spot || d < best)
                    {
                        spot = c;
                        target = c;
                        best = d;
                    }
                }
            }
        if (!spot && (!use.objects.empty() || !use.creatures.empty()))
            continue;   // none of it here

        if (use.credit)
            target = nullptr;   // (batch 11j: the helper is placed next to its feeders, not on them)
        float const range = use.credit ? 12.0f : target ? std::min(std::max(spellInfo->GetMaxRange(!bot->IsHostileTo(target)) - 2.0f, 3.0f), 20.0f) : 3.0f;
        if (spot && best > range)
        {
            if (!bot->isMoving() || now - t.lastMoveOrder > 3000)
            {
                bot->GetMotionMaster()->MovePoint(0, spot->GetPositionX(), spot->GetPositionY(), spot->GetPositionZ(), true);
                t.lastMoveOrder = now;
            }
            return true;
        }

        bot->StopMoving();
        if (spot)
            bot->SetFacingToObject(spot);
        SpellCastTargets targets;
        if (target)
        {
            targets.SetUnitTarget(target);
            bot->SetSelection(target->GetGUID());
            if (t.interacted.size() > 32)
                t.interacted.clear();
            t.interacted[target->GetGUID()] = now + 60000;
        }
        bot->CastItemUseSpell(item, targets, 0, 0);
        // a channelled item spell works per tick: stay for the channel
        uint32 const channel = spellInfo->IsChanneled() && spellInfo->GetDuration() > 0 ? std::min<uint32>(uint32(spellInfo->GetDuration()), 13000) : 0;
        uint32 const busy = spellInfo->CalcCastTime() + channel + 1500;
        t.interactUntil = now + busy;
        t.nextUseSearch = now + busy + 3000;
        Count(BLC_QUEST_ENGAGE);
        return true;
    }
    return false;
}

// the vendors that sell an item for money, as far as they are not hostile to this bot
void BotLifeMgr::AddItemVendors(Player* bot, uint32 item, std::vector<uint32>& creatures) const
{
    auto vs = _itemVendorSources.find(item);
    if (vs == _itemVendorSources.end())
        return;
    uint32 const own = bot->GetTeam() == HORDE ? 4 : 2;
    for (uint32 entry : vs->second)
    {
        CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(entry);
        FactionTemplateEntry const* ft = ct ? sFactionTemplateStore.LookupEntry(ct->faction) : nullptr;
        if (ft && !(ft->hostileMask & (own | FACTION_MASK_PLAYER)))
            creatures.push_back(entry);
    }
}

// objective items a vendor sells for money: walk up to the vendor and buy what is missing
bool BotLifeMgr::BuyQuestItem(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (bot->IsInCombat() || now < t.nextVendorSearch)
        return false;
    Quest const* quest = sObjectMgr->GetQuestTemplate(t.questId);
    if (!quest)
        return false;
    for (QuestObjective const& obj : quest->GetObjectives())
    {
        if (obj.Type != QUEST_OBJECTIVE_ITEM || bot->IsQuestObjectiveComplete(quest, obj))
            continue;
        std::vector<uint32> vendors;
        AddItemVendors(bot, obj.ObjectID, vendors);
        ItemTemplate const* proto = vendors.empty() ? nullptr : sObjectMgr->GetItemTemplate(obj.ObjectID);
        if (!proto)
            continue;
        uint32 const have = bot->GetItemCount(obj.ObjectID, false);
        if (have >= uint32(obj.Amount))
            continue;

        Creature* vendor = nullptr;
        float best = 0.0f;
        for (uint32 entry : vendors)
        {
            std::list<Creature*> list;
            bot->GetCreatureListWithEntryInGrid(list, entry, 60.0f);
            for (Creature* c : list)
            {
                if (!c->IsAlive() || !c->IsVendor() || bot->IsHostileTo(c))
                    continue;
                float const d = bot->GetExactDist(c);
                if (!vendor || d < best)
                {
                    vendor = c;
                    best = d;
                }
            }
        }
        if (!vendor)
            continue;
        if (best > 4.0f)
        {
            if (!bot->isMoving() || now - t.lastMoveOrder > 3000)
            {
                bot->GetMotionMaster()->MovePoint(0, vendor->GetPositionX(), vendor->GetPositionY(), vendor->GetPositionZ(), true);
                t.lastMoveOrder = now;
            }
            return true;
        }

        VendorItemData const* items = vendor->GetVendorItems();
        int32 slot = -1;
        for (uint32 i = 0; items && i < items->GetItemCount(); ++i)
            if (VendorItem const* vi = items->GetItem(i))
                if (vi->item == uint32(obj.ObjectID) && vi->Type == ITEM_VENDOR_TYPE_ITEM && !vi->ExtendedCost)
                {
                    slot = int32(i);
                    break;
                }
        // a purchase is a stack of BuyCount: as many as the objective is short of
        uint32 const perBuy = std::max<uint32>(proto->BuyCount, 1);
        uint32 const stacks = std::min<uint32>((uint32(obj.Amount) - have + perBuy - 1) / perBuy, 20);
        if (slot < 0 || !bot->HasEnoughMoney(uint64(proto->BuyPrice) * stacks))
        {
            t.nextVendorSearch = now + 60000;   // not on sale here, or no money for it yet
            continue;
        }
        bot->StopMoving();
        bot->SetFacingToObject(vendor);
        bool const bought = bot->BuyItemFromVendorSlot(vendor->GetGUID(), uint32(slot), obj.ObjectID, uint8(stacks), NULL_BAG, NULL_SLOT);
        t.nextVendorSearch = now + (bought ? 2000 : 30000);
        if (bought)
            Count(BLC_QUEST_ENGAGE);
        return bought;
    }
    return false;
}

// objectives whose credit does not come from a kill: an NPC to talk to, or a creature that gives
// the credit when the quest item (or a spell of the bot) is used on it.
bool BotLifeMgr::InteractQuestCreature(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    if (now < t.interactUntil)
        return true;   // talking, casting
    if (bot->IsInCombat() || now < t.nextInteractSearch)
        return false;
    Quest const* quest = sObjectMgr->GetQuestTemplate(t.questId);
    if (!quest)
        return false;

    // an item in the bags that casts this spell when used
    auto itemWithSpell = [bot](uint32 spell) -> Item*
    {
        auto fits = [spell](Item* item) -> bool
        {
            if (!item)
                return false;
            ItemTemplate const* proto = item->GetTemplate();
            for (uint8 i = 0; i < MAX_ITEM_PROTO_SPELLS; ++i)
                if (proto->Spells[i].SpellId == int32(spell) && proto->Spells[i].SpellTrigger == ITEM_SPELLTRIGGER_ON_USE)
                    return true;
            return false;
        };
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
            if (Item* item = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
                if (fits(item))
                    return item;
        for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
            if (Bag* b = bot->GetBagByPos(bag))
                for (uint32 slot = 0; slot < b->GetBagSize(); ++slot)
                    if (Item* item = b->GetItemByPos(uint8(slot)))
                        if (fits(item))
                            return item;
        return nullptr;
    };

    // batch 11q: a quest without objectives that an event completes: its NPCs as one more objective
    static QuestObjective const eventObjective{};
    std::vector<QuestObjective const*> objectives;
    for (QuestObjective const& obj : quest->GetObjectives())
        objectives.push_back(&obj);
    auto qe = quest->GetObjectives().empty() ? _questEventSources.find(quest->GetQuestId()) : _questEventSources.end();
    if (qe != _questEventSources.end())
        objectives.push_back(&eventObjective);
    for (QuestObjective const* objective : objectives)
    {
        QuestObjective const& obj = *objective;
        bool const event = objective == &eventObjective;
        // batch 11o: an item a click on a creature hands out
        auto ic = obj.Type == QUEST_OBJECTIVE_ITEM ? _itemClickSources.find(obj.ObjectID) : _itemClickSources.end();
        auto italk = obj.Type == QUEST_OBJECTIVE_ITEM ? _itemTalkSources.find(obj.ObjectID) : _itemTalkSources.end();   // (batch 11y)
        if (!event && ((obj.Type != QUEST_OBJECTIVE_MONSTER && obj.Type != QUEST_OBJECTIVE_TALKTO && ic == _itemClickSources.end()
            && italk == _itemTalkSources.end()) || bot->IsQuestObjectiveComplete(quest, obj)))   // (batch 11v: "talk to" as well)
            continue;
        std::vector<BotLifeCreditSource> sources;
        if (event)
            sources = qe->second;
        else if (ic != _itemClickSources.end())
            for (uint32 npc : ic->second)
            {
                BotLifeCreditSource src;
                src.creature = npc;
                src.click = true;
                sources.push_back(src);
            }
        else if (obj.Type != QUEST_OBJECTIVE_ITEM)   // (batch 11y: an item id is no creature entry)
        {
            auto credit = _creditSources.find(obj.ObjectID);
            if (credit != _creditSources.end())
                sources = credit->second;
            if (CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(obj.ObjectID))
                if (obj.Type == QUEST_OBJECTIVE_TALKTO || (ct->npcflag & UNIT_NPC_FLAG_SPELLCLICK)
                    || ((ct->npcflag & UNIT_NPC_FLAG_GOSSIP) && _gossipTalk.count(obj.ObjectID)))   // (4-10: flavour gossip is fought)
                    sources.push_back(BotLifeCreditSource{ obj.ObjectID, 0 });   // (batch 11v: "talk to" always)
        }
        if (italk != _itemTalkSources.end())   // batch 11y: an NPC that hands the item out
            sources.insert(sources.end(), italk->second.begin(), italk->second.end());

        for (BotLifeCreditSource const& src : sources)
        {
            if (src.fight)
                continue;   // EngageQuestCreature
            Item* item = nullptr;
            SpellInfo const* spellInfo = src.spell ? sSpellMgr->GetSpellInfo(src.spell) : nullptr;
            if (src.spell)
            {
                if (!spellInfo)
                    continue;
                if (!bot->HasSpell(src.spell))
                {
                    item = itemWithSpell(src.spell);
                    if (!item)
                        continue;
                }
            }

            std::list<Creature*> list;
            bot->GetCreatureListWithEntryInGrid(list, src.creature, 60.0f);
            Creature* target = nullptr;
            float best = 0.0f;
            for (Creature* c : list)
            {
                // 
                bool const visit = src.visit > 0.0f;   // (batch 11k: any NPC, a bunny too - the bot only stands near it)
                if (!c->IsAlive() || (!visit && !src.spell && c->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE)))
                    continue;
                if (!visit && src.spell && !item && bot->IsValidAttackTarget(c))
                    continue;   // something to fight with that spell: EngageQuestCreature
                // 
                if (!visit && !src.spell && !src.click && bot->IsValidAttackTarget(c) && (c->IsHostileTo(bot) || !c->HasFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_GOSSIP)))
                    continue;
                if (src.click && !c->HasFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK))
                    continue;   // (batch 11o: clicked already, by somebody)
                auto done = t.interacted.find(c->GetGUID());
                if (done != t.interacted.end() && now < done->second)
                    continue;
                float const d = bot->GetExactDist(c);
                if (!target || d < best)
                {
                    target = c;
                    best = d;
                }
            }
            if (!target)
                continue;

            bool const bunny = target->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);
            float range = 3.0f;
            if (spellInfo && !bunny)
                range = std::min(std::max(spellInfo->GetMaxRange(!bot->IsHostileTo(target)) - 2.0f, 3.0f), 20.0f);
            if (src.visit > 0.0f)
                range = std::max(2.0f, std::min(src.visit - 3.0f, 15.0f));   // (batch 11k)
            if (best > range)
            {
                if (!bot->isMoving() || now - t.lastMoveOrder > 3000)
                {
                    bot->GetMotionMaster()->MovePoint(0, target->GetPositionX(), target->GetPositionY(), target->GetPositionZ(), true);
                    t.lastMoveOrder = now;
                }
                return true;
            }

            bot->StopMoving();
            bot->SetFacingToObject(target);
            // batch 11z: an escort - stay with it; when it is attacked the fight goes first
            if (src.visit > 0.0f && src.follow)
            {
                if (target->IsInCombat())
                    return false;   // EngageQuestCreature: what attacks it
                t.interactUntil = now + 1500;
                Count(BLC_QUEST_ENGAGE);
                return true;
            }
            // batch 11k: near enough - the NPC's timer gives the credit; wait a moment, nothing else
            if (src.visit > 0.0f)
            {
                if (t.interacted.size() > 32)
                    t.interacted.clear();
                t.interacted[target->GetGUID()] = now + 20000;
                t.interactUntil = now + 4000;
                Count(BLC_QUEST_ENGAGE);
                return true;
            }
            if (!bunny)
                bot->SetSelection(target->GetGUID());
            if (t.interacted.size() > 32)
                t.interacted.clear();
            t.interacted[target->GetGUID()] = now + 60000;
            uint32 busy = 2500;
            if (!src.spell)
            {
                // a spell click NPC (a corpse to pick up, something to mount) is clicked, the rest is talked to
                if (target->HasFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK))
                {
                    bot->TalkedToCreature(target->GetEntry(), target->GetGUID());
                    target->HandleSpellClick(bot);
                }
                else
                    TalkTo(bot, target);
            }
            else
            {
                if (item)
                {
                    // a bunny cannot be the target: the spell of the item picks it up itself (nearby entry, area)
                    SpellCastTargets targets;
                    if (!bunny)
                        targets.SetUnitTarget(target);
                    bot->CastItemUseSpell(item, targets, 0, 0);
                }
                else
                    bot->CastSpell(bunny ? static_cast<Unit*>(bot) : static_cast<Unit*>(target), src.spell, false);
                busy = spellInfo->CalcCastTime() + std::min<uint32>(uint32(std::max(spellInfo->GetDuration(), 0)), 10000) * (spellInfo->IsChanneled() ? 1 : 0) + 1500;
            }
            Count(BLC_QUEST_ENGAGE);
            t.interactUntil = now + busy;
            return true;
        }
    }
    t.nextInteractSearch = now + 3000;
    return false;
}

bool BotLifeMgr::TurnIn(Player* bot, WorldObject* giver, uint32 questId)
{
    Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
    if (!quest || (bot->GetQuestStatus(questId) != QUEST_STATUS_COMPLETE && quest->GetQuestType() != 0))
        return false;
    // 
    Creature* npc = giver->ToCreature();
    if (npc ? !sObjectMgr->GetCreatureQuestInvolvedRelations(npc->GetEntry()).HasQuest(questId)
            : !(giver->ToGameObject() && sObjectMgr->GetGOQuestInvolvedRelations(giver->GetEntry()).HasQuest(questId)))
        return false;

    uint32 reward = 0;
    if (quest->GetRewChoiceItemsCount())
    {
        uint32 bestValue = 0;
        for (uint32 i = 0; i < QUEST_REWARD_CHOICES_COUNT; ++i)
        {
            uint32 itemId = quest->RewardChoiceItemId[i];
            if (!itemId)
                continue;
            ItemTemplate const* proto = sObjectMgr->GetItemTemplate(itemId);
            if (!proto)
                continue;
            uint32 value = proto->SellPrice + 1;
            if (bot->CanUseItem(proto) == EQUIP_ERR_OK)
            {
                value += 1000000;
                if (sRandomItemMgr->FitsBot(bot, proto))   // right armor type and primary stat first
                    value += 2000000 + proto->ItemLevel * 1000;
            }
            if (!reward || value > bestValue)
            {
                reward = itemId;
                bestValue = value;
            }
        }
    }

    if (!bot->CanRewardQuest(quest, reward, false))
    {
        // usually full bags: make room for the rewards and try again
        ManageBags(bot, 8);
        if (!bot->CanRewardQuest(quest, reward, false))
        {
            if (_debug)
                TC_LOG_INFO("playerbots", "BotLife {}: cannot reward quest {} (reward {})", bot->GetName(), questId, reward);
            return false;
        }
        Count(BLC_TURNIN_BAGS);
    }

    bot->RewardQuest(quest, reward, giver, false);
    Count(BLC_QUEST_TURNIN);
    RecordQuest(questId, true);
    if (IsWalker(bot))
        TC_LOG_INFO("playerbots", "WALK {} lvl {}: turned in {} \"{}\"", bot->GetName(), uint32(bot->GetLevel()), questId, quest->GetLogTitle());
    if (quest->IsDaily())
        Count(BLC_DAILY_TURNIN);
    if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot))
    {
        botAI->life.questStarted.erase(questId);
        if (npc && botAI->life.party && bot->GetGroup() && bot->GetGroup()->GetLeaderGUID() == bot->GetGUID())
            PartyTurnIn(bot, npc, questId);
    }
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {}: turned in quest {}", bot->GetName(), questId);
    return true;
}

// a quest a bot cannot do (a scripted event, a vehicle, a credit that only a script gives) keeps the
// rest of its chain closed for that bot. It then counts as done - nothing is given for it - so that the quests behind
// it get played. Plain quests only: no dungeon or raid quests, nothing repeatable.
bool BotLifeMgr::CanSkipQuest(Player* bot, Quest const* quest) const
{
    if (IsWalker(bot))
        return false;   // a walker meets the quest as a player does - the chain stops here
    if (!_skipQuests || quest->GetQuestType() != 2 || quest->IsRepeatable() || quest->IsDaily() || quest->IsWeekly() || quest->IsSeasonal())
        return false;
    if (quest->GetQuestInfoID() != 0 && quest->GetQuestInfoID() != 1 && quest->GetQuestInfoID() != 21)   // plain, group, class
        return false;
    if (bot->IsQuestRewarded(quest->GetQuestId()))
        return false;
    return bot->GetQuestStatus(quest->GetQuestId()) != QUEST_STATUS_NONE || bot->CanTakeQuest(quest, false);
}

bool BotLifeMgr::SkipQuest(Player* bot, Quest const* quest)
{
    if (!CanSkipQuest(bot, quest))
        return false;
    char const* why = nullptr;
    IsQuestSupported(quest, &why);
    bot->MarkQuestRewarded(quest->GetQuestId());
    Count(BLC_QUEST_SKIP);
    if (_questLearning)
        PlayerbotsDatabase.PExecute("INSERT INTO tt_botlife_quest_fail (quest, reason, n, sample, ts) VALUES ({}, 'skipped', 1, '{}', UNIX_TIMESTAMP()) "
            "ON DUPLICATE KEY UPDATE n = n + 1, sample = VALUES(sample), ts = VALUES(ts)", quest->GetQuestId(), why ? why : "");
    return true;
}

// the quest belongs to another continent (the bot was moved, or logged in on a trip): its enders are all elsewhere
bool BotLifeMgr::QuestElsewhere(Player* bot, uint32 questId) const
{
    bool elsewhere = false;
    for (auto const& rel : sObjectMgr->GetGOQuestInvolvedRelationReverseBounds(questId))   // (batch 11i)
    {
        auto it = _goSpawns.find(rel.second);
        if (it == _goSpawns.end())
            continue;
        for (BotLifeSpawn const& s : it->second)
        {
            if (s.map == bot->GetMapId())
                return false;
            elsewhere = true;
        }
    }
    for (auto const& rel : sObjectMgr->GetCreatureQuestInvolvedRelationReverseBounds(questId))
    {
        auto it = _creatureSpawns.find(rel.second);
        if (it == _creatureSpawns.end())
            continue;
        for (BotLifeSpawn const& s : it->second)
        {
            if (s.map == bot->GetMapId())
                return false;
            elsewhere = true;
        }
    }
    return elsewhere;
}

void BotLifeMgr::AbandonQuest(Player* bot, BotLifeInfo& t, uint32 questId, char const* reason, bool record)
{
    if (IsWalker(bot))
    {
        TC_LOG_INFO("playerbots", "WALK {} lvl {}: FAILED {} - {} (at map {} {} {} {}) - kept in the log", bot->GetName(), uint32(bot->GetLevel()), questId,
            reason, bot->GetMapId(), int32(bot->GetPositionX()), int32(bot->GetPositionY()), int32(bot->GetPositionZ()));
        t.skipQuests.insert(questId);   // (walker: the quest stays, as for a player - an event may still complete it)
        t.questStarted.erase(questId);
        return;
    }
    // why, per quest - to tell a bot limitation from a quest that is broken on the server
    if (_questLearning && questId)
        PlayerbotsDatabase.PExecute("INSERT INTO tt_botlife_quest_fail (quest, reason, n, sample, ts) VALUES ({}, '{}', 1, '{} lvl {} map {} {} {} {} phase {}', UNIX_TIMESTAMP()) "
            "ON DUPLICATE KEY UPDATE n = n + 1, sample = VALUES(sample), ts = VALUES(ts)", questId, reason, bot->GetName(), uint32(bot->GetLevel()),
            bot->GetMapId(), int32(bot->GetPositionX()), int32(bot->GetPositionY()), int32(bot->GetPositionZ()), bot->GetPhaseMask());
    t.questStarted.erase(questId);
    uint16 slot = bot->FindQuestSlot(questId);
    if (slot >= MAX_QUEST_LOG_SIZE)
        return;
    WorldPacket packet(CMSG_QUESTLOG_REMOVE_QUEST, 1);
    packet << uint8(slot);
    bot->GetSession()->HandleQuestLogRemoveQuest(packet);
    // in the death knight starting chain (quest sort -372) a quest the bot gives up on counts as done
    // (no reward): the chain goes on
    if (Quest const* quest = sObjectMgr->GetQuestTemplate(questId))
        if (quest->GetZoneOrSort() == -372 && DeathKnightChainOpen(bot))
            SkipQuest(bot, quest);
    if (record && !IsBadQuest(questId))
        RecordQuest(questId, false);
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {}: abandoned quest {}", bot->GetName(), questId);
}

bool BotLifeMgr::IsAvoidedTarget(Player* bot, Unit* unit)
{
    if (!_enabled || !_loaded || !unit || unit->GetTypeId() != TYPEID_UNIT)
        return false;
    PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
    if (!botAI || botAI->life.avoidCreature.empty())
        return false;
    auto it = botAI->life.avoidCreature.find(unit->GetEntry());
    if (it == botAI->life.avoidCreature.end())
        return false;
    if (getMSTime() >= it->second)
    {
        botAI->life.avoidCreature.erase(it);
        return false;
    }
    return true;
}

bool BotLifeMgr::IsQuestTarget(Player* bot, Unit* unit)
{
    if (!_enabled || !_loaded || !unit)
        return false;
    Creature* creature = unit->ToCreature();
    if (!creature)
        return false;
    PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
    if (!botAI || botAI->life.state != BotLifeState::DO_QUEST || !botAI->life.questId)
        return false;
    BotLifeQuestPlan const* plan = FindPlan(botAI->life.questId);   // was an unlocked _plans.find
    return plan && plan->targetCreatures.count(creature->GetEntry()) > 0;
}

// ---------------------------------------------------------------------------------------------
// loot, bags, rest

// the armory shows who killed which boss. The statistics the client shows are never saved by the core,
// so every player on the map of a boss that dies gets a row (characters.tt_armory_boss_kills). Map thread of the kill.
void BotLifeMgr::RecordBossKill(Creature* killed)
{
    Map* map = killed->GetMap();
    std::ostringstream values;
    uint32 const when = uint32(GameTime::GetGameTime());
    uint32 rows = 0;
    Map::PlayerList const& players = map->GetPlayers();
    for (Map::PlayerList::const_iterator itr = players.begin(); itr != players.end() && rows < 45; ++itr)
        if (Player* player = itr->GetSource())
        {
            values << (rows ? "," : "") << '(' << player->GetGUID().GetCounter() << ',' << killed->GetEntry() << ',' << map->GetId()
                << ',' << uint32(map->GetDifficulty()) << ",1," << when << ')';
            ++rows;
        }
    if (rows)
        CharacterDatabase.PExecute("INSERT INTO tt_armory_boss_kills (guid, creature, map, difficulty, kills, last_kill) VALUES {} "
            "ON DUPLICATE KEY UPDATE kills = kills + 1, last_kill = VALUES(last_kill)", values.str());
}

void BotLifeNoteFinalBossKill(Creature* killed);   // , BotLifeDungeon.cpp

void BotLifeMgr::OnCreatureKill(Player* killer, Creature* killed)
{
    if (!_enabled || !_loaded || !killer || !killed)
        return;

    if (killed->GetMap()->IsDungeon())
        BotLifeNoteFinalBossKill(killed);

    if (killed->GetMap()->IsDungeon() && IsBossEntry(killed->GetEntry()))
        RecordBossKill(killed);

    // a dungeon finder group with a real player - the bot that leads the run counts kills / bosses
    // whoever made the kill (also the player), and the bots of the group get the corpse for looting (the core's loot
    // permissions decide: round robin / rolls of the player are respected by SendLoot)
    if (Group* group = killer->GetGroup())
        if (killer->GetMap()->IsDungeon() && !killer->GetMap()->IsRaid())
            for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
            {
                Player* member = ref->GetSource();
                PlayerbotAI* memberAI = member ? GET_PLAYERBOT_AI(member) : nullptr;
                if (!memberAI || member->GetMap() != killer->GetMap())
                    continue;
                BotLifeInfo& mt = memberAI->life;
                if (mt.lfgLeadInstance == killer->GetInstanceId())
                {
                    ++mt.dungeonKills;
                    CreatureTemplate const* ct = killed->GetCreatureTemplate();
                    if (ct && IsBossEntry(ct->Entry))
                        ++mt.dungeonBosses;
                }
                if (_loot && (mt.lfgMaster || mt.lfgLeadInstance == killer->GetInstanceId()) && member->IsWithinDistInMap(killed, 40.0f))
                {
                    if (mt.lootQueue.size() >= 6)
                        mt.lootQueue.pop_front();
                    mt.lootQueue.push_back(killed->GetGUID());
                }
            }

    PlayerbotAI* botAI = GET_PLAYERBOT_AI(killer);
    if (!botAI || botAI->IsRealPlayer() || botAI->HasRealPlayerMaster() || !sRandomPlayerbotMgr->IsRandomBot(killer))
        return;

    Count(BLC_KILL);
    if (botAI->life.party == BOTLIFE_PARTY_DUNGEON || botAI->life.party == BOTLIFE_PARTY_RAID)
    {
        CreatureTemplate const* ct = killed->GetCreatureTemplate();
        bool boss = ct && IsBossEntry(ct->Entry);
        Count(BLC_DUNGEON_KILL);
        if (boss)
            Count(BLC_DUNGEON_BOSS);
        if (Group* group = killer->GetGroup())
            if (Player* leader = ObjectAccessor::GetPlayer(*killer, group->GetLeaderGUID()))
                if (PlayerbotAI* leaderAI = GET_PLAYERBOT_AI(leader))
                {
                    ++leaderAI->life.dungeonKills;
                    if (boss)
                        ++leaderAI->life.dungeonBosses;
                }
    }
    if (_loot)
    {
        BotLifeInfo& t = botAI->life;
        if (t.lootQueue.size() >= 6)
            t.lootQueue.pop_front();
        t.lootQueue.push_back(killed->GetGUID());
        if (t.party && killer->GetGroup())
            PartyShareKill(killer, killed);
    }

    // rare kills are worth mentioning
    if (_chat && killer->GetGuildId())
    {
        uint32 rank = killed->GetCreatureTemplate()->rank;
        char const* category = nullptr;
        if (rank == CREATURE_ELITE_RARE)
            category = "broadcast_killed_rare";
        else if (rank == CREATURE_ELITE_RAREELITE)
            category = "broadcast_killed_rareelite";
        else if (rank == CREATURE_ELITE_WORLDBOSS)
            category = "broadcast_killed_worldboss";
        if (category && urand(0, 99) < 50 && CanBroadcast(getMSTime(), 45000))
        {
            std::string text = PickText(category, killer);
            size_t pos = text.find("%victim_name");
            if (pos != std::string::npos)
                text.replace(pos, 12, killed->GetName());
            if (!text.empty() && text.find('%') == std::string::npos)
                Queue(urand(3000, 9000), killer, BOTLIFE_CHAT_GUILD, text);
        }
    }
}

void BotLifeMgr::OnKilledByCreature(Creature* killer, Player* killed)
{
    if (!_enabled || !_loaded || !killer || !killed || !killed->GetSession() || !killed->GetSession()->IsBot())
        return;
    Count(BLC_DEATH_BY_CREATURE);
    CreatureTemplate const* ct = killer->GetCreatureTemplate();
    if (killer->GetLevel() >= killed->GetLevel() + 3)
        Count(BLC_DEATH_BY_HIGHER);
    if (ct && ct->rank != CREATURE_ELITE_NORMAL)
        Count(BLC_DEATH_BY_ELITE);
    if (killer->IsGuard() || (ct && (ct->flags_extra & CREATURE_FLAG_EXTRA_CIVILIAN)))
        Count(BLC_DEATH_BY_GUARD);
    // learning: the same kind of creature twice in a short time is too much for this bot, for now
    if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(killed))
    {
        BotLifeInfo& t = botAI->life;
        uint32 now = getMSTime();
        // who kills the party in the dungeons under repair (BotLife.DungeonFocus)
        if ((t.party == BOTLIFE_PARTY_DUNGEON || t.party == BOTLIFE_PARTY_RAID) && _dungeonFocusMaps.count(killed->GetMapId()))
            TC_LOG_INFO("playerbots", "BotLife: {} (lvl {}, {}) died in map {} to {} ({}, lvl {}, {} max hp) at {:.0f} {:.0f} {:.0f}",
                killed->GetName(), uint32(killed->GetLevel()),
                PlayerBotSpec::IsTank(killed, true) ? "tank" : PlayerBotSpec::IsHeal(killed, true) ? "healer" : "dps", killed->GetMapId(),
                killer->GetName(), killer->GetEntry(), uint32(killer->GetLevel()), killer->GetMaxHealth(),
                killed->GetPositionX(), killed->GetPositionY(), killed->GetPositionZ());
        // death streak (a paladin died 65 times to Blackrock Invaders in 30 min: aggressive mobs at the
        // graveyard/corpse, avoiding the entry does not help): 4 deaths in 10 minutes and the bot moves on
        t.recentDeaths.push_back(now);
        while (!t.recentDeaths.empty() && now - t.recentDeaths.front() > 10 * MINUTE * IN_MILLISECONDS)
            t.recentDeaths.pop_front();
        if (t.recentDeaths.size() >= 4 && !killed->GetMap()->Instanceable())
        {
            t.relocateAfterDeaths = true;
            t.recentDeaths.clear();
        }
        // ASan: clear BEFORE taking the reference - clearing after it left d dangling and the
        // d.first = 0 below wrote into freed memory (heap corruption, jemalloc crashes 27/28-9)
        if (t.deathsBy.size() >= 16 && !t.deathsBy.count(killer->GetEntry()))
            t.deathsBy.clear();
        auto& d = t.deathsBy[killer->GetEntry()];
        d.first = (d.second && now - d.second < 20 * MINUTE * IN_MILLISECONDS) ? d.first + 1 : 1;
        d.second = now;
        // the corpse lies next to the killer: a solo bot does not come back there again
        if (!killed->GetMap()->Instanceable() && !killed->GetGroup() && (d.first >= 2 || t.recentDeaths.size() >= 3))
            t.graveyardRevive = now + 4000;
        if (d.first >= 2 && !killed->GetMap()->Instanceable())
        {
            t.avoidCreature[killer->GetEntry()] = now + 30 * MINUTE * IN_MILLISECONDS;
            d.first = 0;
            Count(BLC_AVOID_CREATURE);
            if (t.questId && t.state == BotLifeState::DO_QUEST)
            {
                BotLifeQuestPlan const* plan = FindPlan(t.questId);   // was an unlocked _plans.find
                if (plan && plan->targetCreatures.count(killer->GetEntry()))
                {
                    t.skipQuests.insert(t.questId);
                    AbandonQuest(killed, t, t.questId, "killed twice by the target");
                    SetState(killed, t, BotLifeState::IDLE, now, 0);
                }
            }
        }
    }
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {} (lvl {}, map {} zone {}) killed by {} ({}, lvl {}, rank {})", killed->GetName(),
            uint32(killed->GetLevel()), killed->GetMapId(), killed->GetZoneId(), killer->GetName(), killer->GetEntry(),
            uint32(killer->GetLevel()), ct ? ct->rank : 0);
}

void BotLifeMgr::OnKilledByPlayer(Player* killer, Player* killed)
{
    if (!_enabled || !_loaded || !killer || !killed || !killed->GetSession() || !killed->GetSession()->IsBot())
        return;
    Count(BLC_DEATH_BY_PLAYER);
}

bool BotLifeMgr::DoLoot(Player* bot, BotLifeInfo& t, uint32 now, float maxDist, uint32 maxTime)
{
    while (t.lootTarget.IsEmpty() && !t.lootQueue.empty())
    {
        ObjectGuid guid = t.lootQueue.front();
        t.lootQueue.pop_front();
        Creature* c = ObjectAccessor::GetCreature(*bot, guid);
        if (c && c->isDead() && c->HasFlag(OBJECT_FIELD_DYNAMIC_FLAGS, UNIT_DYNFLAG_LOOTABLE) && c->IsTappedBy(bot)
            && bot->GetExactDist(c) < maxDist)
        {
            t.lootTarget = guid;
            t.lootSince = now;
        }
    }
    if (t.lootTarget.IsEmpty())
        return false;

    Creature* c = ObjectAccessor::GetCreature(*bot, t.lootTarget);
    if (!c || !c->isDead() || !c->HasFlag(OBJECT_FIELD_DYNAMIC_FLAGS, UNIT_DYNFLAG_LOOTABLE) || now - t.lootSince > maxTime)
    {
        t.lootTarget.Clear();
        return false;
    }

    if (bot->GetExactDist(c) > INTERACTION_DISTANCE - 1.5f)
    {
        if (!bot->isMoving() || now - t.lastMoveOrder > 2500)
        {
            if (bot->IsSitState())
                bot->SetStandState(UNIT_STAND_STATE_STAND);
            bot->GetMotionMaster()->MovePoint(0, c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), true);
            t.lastMoveOrder = now;
        }
        return true;
    }

    bot->StopMoving();
    LootCorpse(bot, c);
    t.lootTarget.Clear();
    return true;
}

namespace
{
    // batch 11g: the corpses the area loot of a player takes along (LootHandler: AELootCreatureCheck)
    struct BotAreaLootCheck
    {
        BotAreaLootCheck(Player* looter, ObjectGuid main) : _looter(looter), _main(main) { }
        bool operator()(Creature* c) const
        {
            return !c->IsAlive() && c->GetGUID() != _main && c->HasFlag(OBJECT_FIELD_DYNAMIC_FLAGS, UNIT_DYNFLAG_LOOTABLE)
                && _looter->IsWithinDist(c, 30.0f) && _looter->IsAllowedToLoot(c);
        }
        Player* _looter;
        ObjectGuid _main;
    };
}

void BotLifeMgr::LootCorpse(Player* bot, Creature* creature, bool area)
{
    ObjectGuid guid = creature->GetGUID();
    bot->SendLoot(guid, LOOT_CORPSE);
    if (bot->GetLootGUID() != guid)
        return;

    Count(BLC_LOOT_CORPSE);
    Loot* loot = &creature->loot;
    if (loot->gold)
    {
        WorldPacket packet(CMSG_LOOT_MONEY, 0);
        bot->GetSession()->HandleLootMoneyOpcode(packet);
    }

    uint32 maxSlot = std::min<uint32>(uint32(loot->items.size() + loot->quest_items.size()), 16);
    for (uint32 slot = 0; slot < maxSlot; ++slot)
    {
        LootItem* item = loot->LootItemInSlot(slot, bot);
        if (!item || item->is_looted)
            continue;
        uint32 itemId = item->itemid;
        uint32 before = bot->GetItemCount(itemId, false);
        bot->StoreLootItem(uint8(slot), loot);
        if (bot->GetItemCount(itemId, false) > before)
        {
            Count(BLC_LOOT_ITEM);
            BroadcastLoot(bot, itemId);
        }
    }
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {}: looted {}", bot->GetName(), creature->GetEntry());
    bot->GetSession()->DoLootRelease(guid);

    // batch 11g: area loot, as a player has it in MoP - the other corpses within 30 yd come along
    if (!area)
        return;
    std::list<Creature*> corpses;
    BotAreaLootCheck check(bot, guid);
    Trinity::CreatureListSearcher<BotAreaLootCheck> searcher(bot, corpses, check);
    bot->VisitNearbyGridObject(30.0f, searcher);
    uint32 n = 0;
    for (Creature* other : corpses)
    {
        if (++n > 15)
            break;
        LootCorpse(bot, other, false);
    }
}

void BotLifeMgr::ManageBags(Player* bot, uint32 minFree, bool sellMaterials)
{
    // count free slots
    uint32 freeSlots = 0;
    for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        if (!bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
            ++freeSlots;
    for (uint8 bagSlot = INVENTORY_SLOT_BAG_START; bagSlot < INVENTORY_SLOT_BAG_END; ++bagSlot)
        if (Bag* bag = bot->GetBagByPos(bagSlot))
            freeSlots += bag->GetFreeSlots();
    if (freeSlots >= minFree)
        return;

    // "sell" junk (and, when still full, plain white items that are not quest items or containers)
    uint64 money = 0;
    // pass 2 only - gathered materials (trade goods) go to the guild bank or the auction house on the next town
    // visit; they are vendored only when the bags are still full after junk and plain white items
    for (uint32 pass = 0; pass < (sellMaterials ? 3u : 2u) && freeSlots < minFree; ++pass)
    {
        uint32 maxQuality = pass == 0 ? ITEM_QUALITY_POOR : ITEM_QUALITY_NORMAL;
        auto consider = [&](uint8 bagSlot, uint8 slot, Item* item)
        {
            if (!item)
                return;
            ItemTemplate const* proto = item->GetTemplate();
            if (!proto || proto->Quality > maxQuality || proto->Class == ITEM_CLASS_QUEST || proto->Class == ITEM_CLASS_CONTAINER)
                return;
            if (pass >= 1 && (proto->Class == ITEM_CLASS_CONSUMABLE || !proto->SellPrice))
                return;
            if ((pass == 2) != (proto->Class == ITEM_CLASS_TRADE_GOODS) && pass > 0)
                return;
            money += uint64(proto->SellPrice) * item->GetCount();
            bot->DestroyItem(bagSlot, slot, true);
            ++freeSlots;
        };
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
            consider(INVENTORY_SLOT_BAG_0, slot, bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot));
        for (uint8 bagSlot = INVENTORY_SLOT_BAG_START; bagSlot < INVENTORY_SLOT_BAG_END; ++bagSlot)
            if (Bag* bag = bot->GetBagByPos(bagSlot))
                for (uint32 slot = 0; slot < bag->GetBagSize(); ++slot)
                    consider(bagSlot, uint8(slot), bag->GetItemByPos(uint8(slot)));
    }

    // still too full. Spare bags are never sold above, and a walker has no town visit to
    // empty its bags: with 40 of 40 slots taken every quest reward was refused ("turn-in refused").
    if (freeSlots < minFree)
    {
        bool walker = IsWalker(bot);
        std::set<uint32> provided;
        for (uint8 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
            if (Quest const* quest = sObjectMgr->GetQuestTemplate(bot->GetQuestSlotQuestId(slot)))
                if (quest->GetSrcItemId())
                    provided.insert(quest->GetSrcItemId());
        auto lastResort = [&](uint8 bagSlot, uint8 slot, Item* item)
        {
            if (!item || freeSlots >= minFree)
                return;
            ItemTemplate const* proto = item->GetTemplate();
            if (!proto || proto->Class == ITEM_CLASS_QUEST || proto->Class == ITEM_CLASS_KEY || proto->StartQuest
                || proto->ItemId == 6948 || provided.count(proto->ItemId) || bot->HasQuestForItem(proto->ItemId))
                return;
            if (Bag* spare = item->ToBag())
            {
                if (!spare->IsEmpty())
                    return;
            }
            else if (!walker || proto->Quality > ITEM_QUALITY_UNCOMMON)
                return;
            money += uint64(proto->SellPrice) * item->GetCount();
            bot->DestroyItem(bagSlot, slot, true);
            ++freeSlots;
        };
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
            lastResort(INVENTORY_SLOT_BAG_0, slot, bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot));
        for (uint8 bagSlot = INVENTORY_SLOT_BAG_START; bagSlot < INVENTORY_SLOT_BAG_END; ++bagSlot)
            if (Bag* bag = bot->GetBagByPos(bagSlot))
                for (uint32 slot = 0; slot < bag->GetBagSize(); ++slot)
                    lastResort(bagSlot, uint8(slot), bag->GetItemByPos(uint8(slot)));
    }
    if (money)
    {
        Count(BLC_BAG_SELL);
        bot->ModifyMoney(int64(money));
    }
}

bool BotLifeMgr::DoRest(Player* bot, BotLifeInfo& t, uint32 now)
{
    bool usesMana = bot->GetPowerType() == POWER_MANA && bot->GetMaxPower(POWER_MANA) > 0;
    if (!t.resting)
    {
        if (bot->GetHealthPct() >= 50.0f && (!usesMana || bot->GetPowerPct(POWER_MANA) >= 30.0f))
            return false;
        t.resting = true;
        t.lastRegen = now;
        bot->StopMoving();
        bot->SetStandState(UNIT_STAND_STATE_SIT);
        return true;
    }

    if (now - t.lastRegen >= 1000)
    {
        t.lastRegen = now;
        bot->ModifyHealth(int32(bot->GetMaxHealth() * 0.07f));
        if (usesMana)
            bot->ModifyPower(POWER_MANA, int32(bot->GetMaxPower(POWER_MANA) * 0.07f));
    }

    if (bot->GetHealthPct() >= 95.0f && (!usesMana || bot->GetPowerPct(POWER_MANA) >= 90.0f))
    {
        t.resting = false;
        bot->SetStandState(UNIT_STAND_STATE_STAND);
        return false;
    }
    if (!bot->IsSitState())
        bot->SetStandState(UNIT_STAND_STATE_SIT);
    return true;
}

// ---------------------------------------------------------------------------------------------
// statistics

// a bot working on one quest for at least minAgeMs (for ".botlife bot")
std::string BotLifeMgr::SampleQuestBot(uint32 minAgeMs)
{
    uint32 now = getMSTime();
    std::vector<std::string> names;
    for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
    {
        Player* bot = pair.second;
        PlayerbotAI* botAI = bot ? GET_PLAYERBOT_AI(bot) : nullptr;
        if (!botAI || botAI->life.state != BotLifeState::DO_QUEST || !botAI->life.questId)
            continue;
        auto it = botAI->life.questStarted.find(botAI->life.questId);
        if (it != botAI->life.questStarted.end() && now - it->second >= minAgeMs)
            names.push_back(bot->GetName());
    }
    return names.empty() ? std::string() : names[urand(0, names.size() - 1)];
}

void BotLifeMgr::PrintBot(ChatHandler* handler, std::string const& nameArg)
{
    std::string name = nameArg == "sample" ? SampleQuestBot(10 * MINUTE * IN_MILLISECONDS) : nameArg;
    Player* bot = name.empty() ? nullptr : ObjectAccessor::FindPlayerByName(name);
    PlayerbotAI* botAI = bot ? GET_PLAYERBOT_AI(bot) : nullptr;
    if (!botAI)
    {
        handler->SendSysMessage("BotLife: bot not found");
        return;
    }
    BotLifeInfo const& t = botAI->life;
    uint32 now = getMSTime();
    std::ostringstream out;
    out << "BotLife " << bot->GetName() << " lvl " << uint32(bot->GetLevel()) << " map " << bot->GetMapId() << " zone " << bot->GetZoneId()
        << " pos " << int32(bot->GetPositionX()) << " " << int32(bot->GetPositionY()) << " " << int32(bot->GetPositionZ())
        << " | state " << uint32(t.state) << " for " << (now - t.stateSince) / IN_MILLISECONDS << "s, party " << uint32(t.party)
        << ", combat " << bot->IsInCombat() << ", alive " << bot->IsAlive() << ", mounted " << bot->IsMounted() << ", hp " << int32(bot->GetHealthPct());
    handler->SendSysMessage(out.str().c_str());
    out.str("");
    if (t.hasDest)
        out << "dest map " << t.destMap << " " << int32(t.destX) << " " << int32(t.destY) << " " << int32(t.destZ) << " dist "
            << int32(bot->GetMapId() == t.destMap ? bot->GetExactDist(t.destX, t.destY, t.destZ) : -1) << " stuck " << uint32(t.stuck);
    else
        out << "no dest";
    Unit* grind = botAI->GetAiObjectContext()->GetValue<Unit*>("grind target")->Get();
    Unit* victim = bot->GetVictim();
    out << " | grind target " << (grind ? grind->GetName() : "-") << " (" << (grind ? grind->GetEntry() : 0) << ", quest target "
        << (grind && IsQuestTarget(bot, grind)) << "), victim " << (victim ? victim->GetName() : "-");
    handler->SendSysMessage(out.str().c_str());
    for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
    {
        uint32 questId = bot->GetQuestSlotQuestId(slot);
        Quest const* quest = questId ? sObjectMgr->GetQuestTemplate(questId) : nullptr;
        if (!quest)
            continue;
        out.str("");
        auto started = t.questStarted.find(questId);
        out << (questId == t.questId ? "* " : "  ") << questId << " " << quest->GetLogTitle() << " (lvl " << quest->GetQuestLevel() << ") status "
            << uint32(bot->GetQuestStatus(questId)) << ", age " << (started != t.questStarted.end() ? (now - started->second) / IN_MILLISECONDS : 0) << "s:";
        for (QuestObjective const& obj : quest->GetObjectives())
        {
            out << " [type " << uint32(obj.Type) << " id " << obj.ObjectID << " " << (obj.Type == QUEST_OBJECTIVE_ITEM ? bot->GetItemCount(obj.ObjectID, false)
                : bot->GetQuestObjectiveCounter(obj.ID)) << "/" << obj.Amount << "]";
            if (obj.Type == QUEST_OBJECTIVE_MONSTER || obj.Type == QUEST_OBJECTIVE_ITEM)
            {
                std::vector<uint32> entries;
                if (obj.Type == QUEST_OBJECTIVE_MONSTER)
                    entries.push_back(obj.ObjectID);
                auto src = obj.Type == QUEST_OBJECTIVE_ITEM ? _itemCreatureSources.find(obj.ObjectID) : _killCreditSources.find(obj.ObjectID);
                if (src != (obj.Type == QUEST_OBJECTIVE_ITEM ? _itemCreatureSources.end() : _killCreditSources.end()))
                    entries.insert(entries.end(), src->second.begin(), src->second.end());
                uint32 alive = 0;
                for (uint32 e : entries)
                {
                    std::list<Creature*> list;
                    bot->GetCreatureListWithEntryInGrid(list, e, 80.0f);
                    for (Creature* c : list)
                        if (c->IsAlive())
                            ++alive;
                }
                out << "{" << entries.size() << " src, " << alive << " alive <80yd}";
            }
        }
        handler->SendSysMessage(out.str().c_str());
    }
}

void BotLifeMgr::ResetStats()
{
    for (auto& c : _counters)
        c.store(0, std::memory_order_relaxed);
    _statsSince = getMSTime();
}

void BotLifeMgr::PrintStats(ChatHandler* handler)
{
    static char const* const counterNames[BLC_MAX] = { "quest_accept", "quest_turnin", "ab_unsupported", "ab_noender",
        "ab_nodest", "ab_noprogress", "ab_timeout", "turnin_fail", "turnin_timeout", "turnin_bags", "giver_noaccept", "giver_timeout", "loot_corpse",
        "loot_item", "loot_go", "bag_sell", "relocate", "stuck", "rest", "kill", "levelup", "party_formed", "party_disbanded", "party_summon",
        "party_quest_shared", "party_quest_turnin", "dungeon_start", "dungeon_cleared", "dungeon_timeout",
        "dungeon_wipeout", "dungeon_abort", "dungeon_boss", "dungeon_kill", "dungeon_rez", "dungeon_wipe", "raid_start", "unstuck", "ghost_revive", "orphan_group", "mount", "death", "death_by_creature", "death_by_higher", "death_by_elite", "death_by_guard",
        "death_by_player", "potion", "dungeon_stalled", "avoid_creature", "town_visit", "door_open", "quest_engage", "quest_engage_fail", "bg_queued", "bg_joined", "bg_capture", "bg_left", "bg_flag", "bg_flag_capture", "areatrigger", "self_heal", "repair", "guild_created", "guild_join", "pandaren_faction", "gbank_gold", "gbank_item", "ah_post", "ah_buy", "gear_fix", "gear_upgrade", "death_relocate", "profession_set", "gather_node", "gather_skin", "ah_post_mat", "tank_shield", "bags_given", "stranded_out", "rebalance", "cast_call", "cast_strict_fail", "cast_moving", "cast_prepared", "cast_timed", "gbank_supply", "gbank_equip", "gbank_treasure", "gbank_tab_bought", "banker_picked", "banker_home", "banker_withdraw", "banker_vendor", "banker_gold", "mail_gold", "lfg_bot_queued", "lfg_short", "lfg_master", "phantom_combat_cleared", "craft", "craft_fail", "recipe_learned", "profession_swap", "banker_sort", "lfg_lead", "talents", "event_gossip", "kill_gate", "craft_supply", "guild_repair", "gbank_resort", "refine", "enchant_scroll", "fish_cast", "fish_catch", "heroic_start", "daily_turnin", "dig_survey", "dig_find", "dig_solve", "quest_bad_skip", "quest_roam", "quest_skip", "vendor_gear", "dk_chain_giveup", "dk_portal", "dk_eye", "dk_eye_siphon" };
    static char const* const stateNames[] = { "idle", "go_grind", "at_grind", "go_questgiver", "do_quest", "go_turnin", "rest", "town", "dig" };

    uint32 states[9] = {};
    uint32 questAge[4] = {};
    uint32 tanks = 0, heals = 0, ghosts = 0, total = 0, inParty = 0, grouped = 0, dead = 0, combat = 0, instance = 0, withMaster = 0, questsInLog = 0;
    for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
    {
        Player* bot = pair.second;
        if (!bot || !bot->IsInWorld())
            continue;
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI)
            continue;
        ++total;
        uint8 st = uint8(botAI->life.state);
        if (st < 9)
            ++states[st];
        if (bot->GetGroup())
            ++grouped;
        if (botAI->life.party)
            ++inParty;
        if (!bot->IsAlive())
        {
            ++dead;
            if (bot->HasPlayerFlag(PLAYER_FLAGS_GHOST))
                ++ghosts;
        }
        if (bot->IsInCombat())
            ++combat;
        if (bot->GetMap() && bot->GetMap()->Instanceable())
            ++instance;
        if (botAI->HasRealPlayerMaster())
            ++withMaster;
        questsInLog += ActiveQuestCount(bot);
        for (auto const& qs : botAI->life.questStarted)
        {
            uint32 age = getMSTime() - qs.second;
            ++questAge[age < 5 * MINUTE * IN_MILLISECONDS ? 0 : age < 15 * MINUTE * IN_MILLISECONDS ? 1 : age < 25 * MINUTE * IN_MILLISECONDS ? 2 : 3];
        }
        if (PlayerBotSpec::IsTank(bot, true))
            ++tanks;
        else if (PlayerBotSpec::IsHeal(bot, true))
            ++heals;
    }

    uint32 minutes = GetMSTimeDiffToNow(_statsSince) / MINUTE / IN_MILLISECONDS;
    std::ostringstream out;
    out << "BotLife: " << total << " bots, grouped " << grouped << " (bot life parties " << _parties.size() << ", members " << inParty << ")" << ", dead " << dead << " (ghost " << ghosts << "), combat " << combat
        << ", instance " << instance << ", real master " << withMaster << ", quests in log " << questsInLog << ", tanks " << tanks << ", healers " << heals;
    handler->SendSysMessage(out.str().c_str());
    out.str("");
    out << "quest ages: <5m " << questAge[0] << ", 5-15m " << questAge[1] << ", 15-25m " << questAge[2] << ", >25m " << questAge[3];
    handler->SendSysMessage(out.str().c_str());
    out.str("");
    out << "states:";
    for (uint32 i = 0; i < 9; ++i)
        out << ' ' << stateNames[i] << '=' << states[i];
    handler->SendSysMessage(out.str().c_str());
    out.str("");
    out << "counters (" << minutes << " min):";
    for (uint32 i = 0; i < BLC_MAX; ++i)
        out << ' ' << counterNames[i] << '=' << _counters[i].load(std::memory_order_relaxed);
    handler->SendSysMessage(out.str().c_str());
    TC_LOG_INFO("playerbots", "BotLife stats: {} bots grouped {} dead {} combat {} instance {} | {}", total, grouped, dead, combat,
        instance, out.str());

    uint32 shown = 0;
    for (auto const& p : _parties)
    {
        BotLifeParty const& party = p.second;
        if (party.type == BOTLIFE_PARTY_WORLD || party.dungeon < 0 || uint32(party.dungeon) >= _dungeons.size() || ++shown > 12)
            continue;
        Player* leader = ObjectAccessor::FindConnectedPlayer(party.leader);
        PlayerbotAI* leaderAI = leader ? GET_PLAYERBOT_AI(leader) : nullptr;
        uint32 alive = 0, inside = 0;
        for (ObjectGuid const& guid : party.members)
            if (Player* m = ObjectAccessor::FindConnectedPlayer(guid))
            {
                if (m->IsAlive())
                    ++alive;
                if (m->GetMapId() == _dungeons[party.dungeon].map)
                    ++inside;
            }
        std::ostringstream line;
        line << (party.type == BOTLIFE_PARTY_RAID ? "raid " : "dungeon ") << _dungeons[party.dungeon].name << ": leader "
            << (leader ? leader->GetName() : "?") << " lvl " << (leader ? uint32(leader->GetLevel()) : 0) << ", " << party.members.size()
            << " members (" << inside << " inside, " << alive << " alive), kills " << (leaderAI ? leaderAI->life.dungeonKills : 0)
            << ", bosses " << (leaderAI ? leaderAI->life.dungeonBosses : 0) << "/" << _dungeons[party.dungeon].bosses << ", wipes "
            << party.wipes << ", " << GetMSTimeDiffToNow(party.formedAt) / MINUTE / IN_MILLISECONDS << " min";
        handler->SendSysMessage(line.str().c_str());
    }
}


// ---------------------------------------------------------------------------------------------
// weapons. The random bot factory leaves many bots without a main hand weapon (all death knights,
// most level 50-89 bots): they fight with their fists and every "requires a melee weapon" ability fails.

namespace
{
    struct WeaponCandidate { uint32 entry; uint32 reqLevel; uint32 itemLevel; };

    std::vector<WeaponCandidate> const& WeaponCandidates()
    {
        static std::vector<WeaponCandidate> list;
        static std::once_flag once;
        std::call_once(once, []()
        {
            for (auto const& pair : *sObjectMgr->GetItemTemplateStore())
            {
                ItemTemplate const& proto = pair.second;
                // shields too (tanks get one next to their one-hander)
                bool shield = proto.Class == ITEM_CLASS_ARMOR && proto.SubClass == ITEM_SUBCLASS_ARMOR_SHIELD && proto.InventoryType == INVTYPE_SHIELD;
                if ((proto.Class != ITEM_CLASS_WEAPON && !shield) || proto.Quality < ITEM_QUALITY_NORMAL || proto.Quality > ITEM_QUALITY_RARE)
                    continue;
                if (!shield && proto.InventoryType != INVTYPE_WEAPON && proto.InventoryType != INVTYPE_2HWEAPON
                    && proto.InventoryType != INVTYPE_WEAPONMAINHAND && proto.InventoryType != INVTYPE_RANGED
                    && proto.InventoryType != INVTYPE_RANGEDRIGHT)
                    continue;
                if (!shield && (proto.SubClass == ITEM_SUBCLASS_WEAPON_FISHING_POLE || proto.SubClass == ITEM_SUBCLASS_WEAPON_MISCELLANEOUS
                    || proto.SubClass == ITEM_SUBCLASS_WEAPON_EXOTIC || proto.SubClass == ITEM_SUBCLASS_WEAPON_EXOTIC2
                    || proto.SubClass == ITEM_SUBCLASS_WEAPON_SPEAR || proto.SubClass == ITEM_SUBCLASS_WEAPON_THROWN))
                    continue;
                if (proto.Duration || proto.Bonding == BIND_QUEST || proto.StartQuest || !proto.ItemLevel || proto.RequiredLevel > 90)
                    continue;
                std::string const& name = proto.Name1;
                if (name.find("Monster") != std::string::npos || name.find("Test") != std::string::npos || name.find("OLD") != std::string::npos
                    || name.find("[") != std::string::npos || name.find("Deprecated") != std::string::npos || name.find("NPC") != std::string::npos)
                    continue;
                list.push_back({ proto.ItemId, proto.RequiredLevel, proto.ItemLevel });
            }
            std::sort(list.begin(), list.end(), [](WeaponCandidate const& a, WeaponCandidate const& b) { return a.itemLevel > b.itemLevel; });
            TC_LOG_INFO("server.loading", ">> BotLife: {} weapon and shield candidates for bots", list.size());
        });
        return list;
    }
}

// bots randomized before the BotFactory::Randomize fix (and bots that lost their gear) log in naked or
// without a spec; fill them up once per login with factory gear (incremental: nothing worn is downgraded)
bool BotLifeMgr::EnsureGear(PlayerbotAI* botAI)
{
    Player* bot = botAI->GetBot();
    if (bot->GetLevel() < 5)
        return false;
    static uint8 const armorSlots[] = { EQUIPMENT_SLOT_HEAD, EQUIPMENT_SLOT_SHOULDERS, EQUIPMENT_SLOT_CHEST, EQUIPMENT_SLOT_WAIST,
        EQUIPMENT_SLOT_LEGS, EQUIPMENT_SLOT_FEET, EQUIPMENT_SLOT_WRISTS, EQUIPMENT_SLOT_HANDS, EQUIPMENT_SLOT_BACK };
    uint32 worn = 0;
    for (uint8 slot : armorSlots)
        if (bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
            ++worn;
    bool noSpec = bot->GetLevel() >= 10 && bot->GetSpecialization() == Specializations::SPEC_NONE;
    // 
    if ((worn >= 5 || _naturalProgression) && !noSpec)
        return false;

    BotFactory factory(bot, bot->GetLevel());
    if (noSpec)
        factory.InitTalentsTree(false);
    if (worn < 5 && !_naturalProgression)
        factory.InitEquipment(true);
    botAI->ResetStrategies();
    Count(BLC_GEAR_FIX);
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): gear fix ({} armor pieces worn, spec {})", bot->GetName(), uint32(bot->GetLevel()),
            worn, uint32(bot->GetSpecialization()));
    return true;
}

// bots never put on the gear they got from quests and loot (7797 wearable items sat in the bags of the
// online bots). Armor, jewelry and cloaks go on when they fit the class/spec and beat the worn item level; weapons
// only replace a weapon of the same kind (hunters: EnsureWeapon).
// what a piece of gear is worth to a bot - its item level, with the quality on top (a grey or white
// piece has no stats: a green one beats a grey one up to 10 item levels higher and a white one up to 5)
static int32 GearValue(ItemTemplate const* proto)
{
    static int32 const qualityBonus[] = { -40, -20, 0, 24, 48, 60, 60, 0 };
    if (proto->Quality == ITEM_QUALITY_HEIRLOOM)
        return 1000000;   // scales with the level
    return int32(proto->ItemLevel) * 4 + qualityBonus[std::min<uint32>(proto->Quality, 7)];
}

// what a piece is worth to this bot - its stats weighted for the role (the own primary stat
// 1, the rest by role) and the weapon damage for physical classes (an off hand at half: it hits for half)
static float GearScore(Player* bot, ItemTemplate const* proto, bool offhand = false)
{
    if (!proto)
        return 0.0f;
    if (proto->Quality == ITEM_QUALITY_HEIRLOOM)
        return 1000000.0f;   // scales with the level
    bool const tank = PlayerBotSpec::IsTank(bot, true);
    bool const heal = PlayerBotSpec::IsHeal(bot, true);
    uint32 const primary = RandomItemManager::PrimaryStat(bot);
    bool const caster = primary == ITEM_MOD_INTELLECT;
    float score = 0.0f;
    for (uint8 j = 0; j < MAX_ITEM_PROTO_STATS; ++j)
    {
        int32 const value = proto->ItemStat[j].ItemStatValue;
        if (value <= 0)
            continue;
        float weight = 0.0f;
        switch (proto->ItemStat[j].ItemStatType)
        {
            case ITEM_MOD_STRENGTH:
            case ITEM_MOD_AGILITY:
            case ITEM_MOD_INTELLECT:          weight = proto->ItemStat[j].ItemStatType == primary ? 1.0f : 0.0f; break;
            case ITEM_MOD_STAMINA:            weight = tank ? 0.7f : 0.1f; break;
            case ITEM_MOD_SPIRIT:             weight = heal ? 0.55f : 0.0f; break;
            case ITEM_MOD_HIT_RATING:         weight = heal ? 0.0f : tank ? 0.3f : 0.5f; break;
            case ITEM_MOD_EXPERTISE_RATING:   weight = heal || caster ? 0.0f : 0.45f; break;
            case ITEM_MOD_DODGE_RATING:
            case ITEM_MOD_PARRY_RATING:       weight = tank ? 0.45f : 0.0f; break;
            case ITEM_MOD_CRIT_RATING:
            case ITEM_MOD_HASTE_RATING:
            case ITEM_MOD_MASTERY_RATING:     weight = 0.4f; break;
            case ITEM_MOD_SPELL_POWER:        weight = caster ? 0.85f : 0.0f; break;
            case ITEM_MOD_ATTACK_POWER:
            case ITEM_MOD_RANGED_ATTACK_POWER: weight = caster ? 0.0f : 0.4f; break;
            case ITEM_MOD_PVP_POWER:
            case ITEM_MOD_RESILIENCE_RATING:  weight = 0.05f; break;
            default: break;
        }
        score += weight * float(value);
    }
    if (proto->Class == ITEM_CLASS_WEAPON && !caster && proto->Delay)
        score += (proto->DamageMin + proto->DamageMax) / 2.0f / (float(proto->Delay) / 1000.0f) * (offhand ? 1.5f : 3.0f);
    return score;
}

// better for this bot - the weighted stats, and within 2% the item level and quality
static bool BetterGear(Player* bot, ItemTemplate const* candidate, ItemTemplate const* current, bool offhand = false)
{
    if (!current)
        return true;
    float const a = GearScore(bot, candidate, offhand), b = GearScore(bot, current, offhand);
    if (a > b * 1.02f + 0.5f)
        return true;
    if (a < b * 0.98f - 0.5f)
        return false;
    return GearValue(candidate) > GearValue(current);
}

// to-do #20/#36/#44: the stats of a random suffix or random property ("of the Bear") sit on the
// item, not in its template - without them every Outland/Northrend green weighed as bare (death knights kept the
// starting sword with better greens in the bags)
static float ItemGearScore(Player* bot, Item* item, bool offhand = false)
{
    ItemTemplate const* proto = item->GetTemplate();
    int32 const randomId = item->GetItemRandomPropertyId();
    if (!randomId)
        return GearScore(bot, proto, offhand);
    std::vector<std::pair<uint32, int32>> stats;
    auto addEnchant = [&](uint32 enchantId, int32 amount)
    {
        SpellItemEnchantmentEntry const* ench = sSpellItemEnchantmentStore.LookupEntry(enchantId);
        if (!ench)
            return;
        for (uint8 s = 0; s < MAX_ITEM_ENCHANTMENT_EFFECTS; ++s)
            if (ench->Type[s] == ITEM_ENCHANTMENT_TYPE_STAT)
                stats.emplace_back(ench->SpellID[s], amount >= 0 ? amount : int32(ench->Amount[s]));
    };
    if (randomId < 0)
    {
        if (ItemRandomSuffixEntry const* suffix = sItemRandomSuffixStore.LookupEntry(uint32(-randomId)))
            for (uint8 k = 0; k < 5; ++k)
                if (suffix->enchant_id[k])
                    addEnchant(suffix->enchant_id[k], int32(item->GetItemSuffixFactor() * suffix->prefix[k] / 10000));
    }
    else if (ItemRandomPropertiesEntry const* prop = sItemRandomPropertiesStore.LookupEntry(uint32(randomId)))
    {
        for (uint8 k = 0; k < MAX_ITEM_ENCHANTMENT_EFFECTS; ++k)
            if (prop->enchant_id[k])
                addEnchant(prop->enchant_id[k], -1);
    }
    if (stats.empty())
        return GearScore(bot, proto, offhand);
    ItemTemplate copy = *proto;
    uint8 slot = 0;
    for (auto const& stat : stats)
    {
        while (slot < MAX_ITEM_PROTO_STATS && copy.ItemStat[slot].ItemStatValue)
            ++slot;
        if (slot >= MAX_ITEM_PROTO_STATS)
            break;
        copy.ItemStat[slot].ItemStatType = stat.first;
        copy.ItemStat[slot].ItemStatValue = stat.second;
    }
    return GearScore(bot, &copy, offhand);
}

// BetterGear for two real items (their random stats included)
static bool BetterItem(Player* bot, Item* candidate, Item* current, bool offhand = false)
{
    if (!current)
        return true;
    float const a = ItemGearScore(bot, candidate, offhand), b = ItemGearScore(bot, current, offhand);
    if (a > b * 1.02f + 0.5f)
        return true;
    if (a < b * 0.98f - 0.5f)
        return false;
    return GearValue(candidate->GetTemplate()) > GearValue(current->GetTemplate());
}

// the best off hand in the bags (shield, held item, or a one-hander for a dual wielder)
static Item* BestOffhandInBags(Player* bot, Item* skip)
{
    Item* best = nullptr;
    float bestScore = 0.0f;
    auto consider = [&](Item* item)
    {
        if (!item || item == skip)
            return;
        ItemTemplate const* proto = item->GetTemplate();
        uint32 const inv = proto->InventoryType;
        bool const fits = inv == INVTYPE_SHIELD || inv == INVTYPE_HOLDABLE
            || ((inv == INVTYPE_WEAPON || inv == INVTYPE_WEAPONOFFHAND) && bot->CanDualWield());
        if (!fits || bot->CanUseItem(proto) != EQUIP_ERR_OK || !sRandomItemMgr->FitsBot(bot, proto))
            return;
        float const score = ItemGearScore(bot, item, true);   // (4-10: random stats)
        if (score > bestScore)
        {
            best = item;
            bestScore = score;
        }
    };
    for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        consider(bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot));
    for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
        if (Bag* container = bot->GetBagByPos(bag))
            for (uint32 slot = 0; slot < container->GetBagSize(); ++slot)
                consider(container->GetItemByPos(uint8(slot)));
    return best;
}

// a weapon from the bags - the same kind as the worn one, or a two-hander for main hand +
// off hand, or a one-hander with the best off hand from the bags for a two-hander; hunters swap ranged weapons only
bool BotLifeMgr::EquipWeaponUpgrade(Player* bot, Item* item, uint16 dest, Item* current)
{
    if (!current)
        return false;   // an empty weapon slot: EnsureWeapon
    ItemTemplate const* proto = item->GetTemplate();
    auto weaponKind = [](uint32 inv) { return inv == INVTYPE_WEAPONMAINHAND ? uint32(INVTYPE_WEAPON) : inv; };
    auto ranged = [](uint32 inv) { return inv == INVTYPE_RANGED || inv == INVTYPE_RANGEDRIGHT; };
    uint32 const newKind = weaponKind(proto->InventoryType), oldKind = weaponKind(current->GetTemplate()->InventoryType);
    if (bot->GetClass() == CLASS_HUNTER && (!ranged(newKind) || !ranged(oldKind)))
        return false;
    uint8 const slot = uint8(dest & 255);
    auto log = [&](char const* how)
    {
        if (_debug)
            TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): equips {} (ilvl {}) over {} ({})", bot->GetName(),
                uint32(bot->GetLevel()), proto->Name1, proto->ItemLevel, current->GetTemplate()->Name1, how);
    };
    if (newKind == oldKind)
    {
        if (!BetterItem(bot, item, current, slot == EQUIPMENT_SLOT_OFFHAND))   // (4-10: random stats)
            return false;
        log("same kind");
        bot->SwapItem(item->GetPos(), dest);
        return true;
    }
    if (slot != EQUIPMENT_SLOT_MAINHAND || bot->CanTitanGrip())
        return false;
    if (newKind == INVTYPE_2HWEAPON && oldKind == INVTYPE_WEAPON)
    {
        Item* off = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_OFFHAND);
        float const worn = ItemGearScore(bot, current) + (off ? ItemGearScore(bot, off, true) : 0.0f);
        if (ItemGearScore(bot, item) <= worn * 1.05f)
            return false;
        log("two-hander for main hand + off hand");
        bot->SwapItem(item->GetPos(), dest);   // the off hand goes to the bags (AutoUnequipOffhandIfNeed)
        return true;
    }
    if (newKind == INVTYPE_WEAPON && oldKind == INVTYPE_2HWEAPON)
    {
        Item* off = BestOffhandInBags(bot, item);
        if (!off || ItemGearScore(bot, item) + ItemGearScore(bot, off, true) <= ItemGearScore(bot, current) * 1.05f)
            return false;
        log("one-hander + off hand for a two-hander");
        bot->SwapItem(item->GetPos(), dest);
        uint16 offDest;
        if (bot->CanEquipItem(EQUIPMENT_SLOT_OFFHAND, offDest, off, true) == EQUIP_ERR_OK)
            bot->SwapItem(off->GetPos(), offDest);
        return true;
    }
    return false;
}

// the armor type of the class in MoP (as RandomItemManager::ShouldEquipArmorForSpec)
static uint32 ClassArmorType(Player* bot)
{
    bool const high = bot->GetLevel() >= 40;
    switch (bot->GetClass())
    {
        case CLASS_WARRIOR:
        case CLASS_PALADIN:      return high ? ITEM_SUBCLASS_ARMOR_PLATE : ITEM_SUBCLASS_ARMOR_MAIL;
        case CLASS_DEATH_KNIGHT: return ITEM_SUBCLASS_ARMOR_PLATE;
        case CLASS_HUNTER:
        case CLASS_SHAMAN:       return high ? ITEM_SUBCLASS_ARMOR_MAIL : ITEM_SUBCLASS_ARMOR_LEATHER;
        case CLASS_ROGUE:
        case CLASS_DRUID:
        case CLASS_MONK:         return ITEM_SUBCLASS_ARMOR_LEATHER;
        default:                 return ITEM_SUBCLASS_ARMOR_CLOTH;
    }
}

void BotLifeMgr::EquipBagUpgrades(Player* bot)
{
    std::vector<Item*> items;
    for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        if (Item* item = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
            items.push_back(item);
    for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
        if (Bag* container = bot->GetBagByPos(bag))
            for (uint32 slot = 0; slot < container->GetBagSize(); ++slot)
                if (Item* item = container->GetItemByPos(uint8(slot)))
                    items.push_back(item);

    for (Item* item : items)
    {
        ItemTemplate const* proto = item->GetTemplate();
        if (!proto || (proto->Class != ITEM_CLASS_ARMOR && proto->Class != ITEM_CLASS_WEAPON) || proto->InventoryType == INVTYPE_NON_EQUIP
            || proto->InventoryType == INVTYPE_BODY || proto->InventoryType == INVTYPE_TABARD || proto->InventoryType == INVTYPE_BAG)
            continue;
        if (bot->CanUseItem(proto) != EQUIP_ERR_OK)
            continue;
        // a green piece with the wrong primary stat still beats a grey or white one (stamina, armor)
        bool statOnly = false;
        if (!sRandomItemMgr->FitsBot(bot, proto))
        {
            bool const typed = proto->SubClass >= ITEM_SUBCLASS_ARMOR_CLOTH && proto->SubClass <= ITEM_SUBCLASS_ARMOR_PLATE
                && proto->InventoryType != INVTYPE_CLOAK && proto->InventoryType != INVTYPE_HOLDABLE && proto->InventoryType != INVTYPE_SHIELD;
            statOnly = proto->Class == ITEM_CLASS_ARMOR && proto->Quality >= ITEM_QUALITY_UNCOMMON
                && RandomItemManager::ItemLevelFits(bot->GetLevel(), proto) && RandomItemManager::HasWrongPrimaryStat(bot, proto)
                && proto->InventoryType != INVTYPE_SHIELD && proto->InventoryType != INVTYPE_HOLDABLE
                && (!typed || proto->SubClass == ClassArmorType(bot));
            if (!statOnly)
                continue;
        }
        if (item->IsEquipped())
            continue;   // put on earlier in this round
        uint16 dest;
        // a ring or trinket is weighed against the weaker of the two worn ones
        if (proto->InventoryType == INVTYPE_FINGER || proto->InventoryType == INVTYPE_TRINKET)
        {
            uint8 const first = proto->InventoryType == INVTYPE_FINGER ? EQUIPMENT_SLOT_FINGER1 : EQUIPMENT_SLOT_TRINKET1;
            Item* one = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, first);
            Item* two = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, first + 1);
            uint8 const slot = !one ? first : !two ? uint8(first + 1)
                : BetterItem(bot, one, two) ? uint8(first + 1) : first;
            if (bot->CanEquipItem(slot, dest, item, true) != EQUIP_ERR_OK)
                continue;
        }
        // 
        else if (bot->CanEquipItem(NULL_SLOT, dest, item, true) != EQUIP_ERR_OK
            && (proto->Class != ITEM_CLASS_WEAPON || bot->CanEquipItem(EQUIPMENT_SLOT_MAINHAND, dest, item, true) != EQUIP_ERR_OK))
            continue;
        Item* current = bot->GetItemByPos(dest);
        if (statOnly && current && current->GetTemplate()->Quality >= ITEM_QUALITY_UNCOMMON)
            continue;   // only over an empty slot or a grey / white piece
        if (proto->Class == ITEM_CLASS_WEAPON)
        {
            if (EquipWeaponUpgrade(bot, item, dest, current))   // weapon kinds, hunters
                Count(BLC_GEAR_UPGRADE);
            continue;
        }
        if (current && !BetterItem(bot, item, current))   // weighted stats (4-10: + random stats)
            continue;
        if (_debug)
            TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): equips {} (ilvl {}) over {}", bot->GetName(), uint32(bot->GetLevel()),
                proto->Name1, proto->ItemLevel, current ? current->GetTemplate()->Name1 : "nothing");
        bot->SwapItem(item->GetPos(), dest);
        Count(BLC_GEAR_UPGRADE);
    }
}

// bots fill empty, grey and white armor slots with what vendors sell for gold
namespace
{
    struct ArmorSlotTypes { uint8 slot; uint32 types[2]; };
    ArmorSlotTypes const s_armorSlotTypes[] =
    {
        { EQUIPMENT_SLOT_HEAD, { INVTYPE_HEAD, 0 } }, { EQUIPMENT_SLOT_SHOULDERS, { INVTYPE_SHOULDERS, 0 } },
        { EQUIPMENT_SLOT_CHEST, { INVTYPE_CHEST, INVTYPE_ROBE } }, { EQUIPMENT_SLOT_WAIST, { INVTYPE_WAIST, 0 } },
        { EQUIPMENT_SLOT_LEGS, { INVTYPE_LEGS, 0 } }, { EQUIPMENT_SLOT_FEET, { INVTYPE_FEET, 0 } },
        { EQUIPMENT_SLOT_WRISTS, { INVTYPE_WRISTS, 0 } }, { EQUIPMENT_SLOT_HANDS, { INVTYPE_HANDS, 0 } },
        { EQUIPMENT_SLOT_BACK, { INVTYPE_CLOAK, 0 } },
    };
    // armor any vendor sells for plain gold (no tokens, reputation, skill or limited stock), by inventory type
    std::once_flag s_vendorArmorOnce;
    std::unordered_map<uint32, std::vector<ItemTemplate const*>> s_vendorArmor;
    void LoadVendorArmor()
    {
        uint32 count = 0;
        if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT v.item FROM npc_vendor v JOIN item_template t ON t.entry = v.item "
            "WHERE v.item > 0 AND v.ExtendedCost = 0 AND v.maxcount = 0 AND v.type <= 1 AND t.class = 4 AND t.Quality <= 2 AND t.BuyPrice > 0 "
            "AND t.RequiredReputationFaction = 0 AND t.RequiredSkill = 0"))
        {
            do
            {
                if (ItemTemplate const* proto = sObjectMgr->GetItemTemplate(result->Fetch()[0].GetUInt32()))
                {
                    s_vendorArmor[proto->InventoryType].push_back(proto);
                    ++count;
                }
            } while (result->NextRow());
        }
        TC_LOG_INFO("playerbots", "BotLife: {} vendor armor pieces for bots", count);
    }
}

bool BotLifeMgr::HasWeakArmorSlot(Player* bot) const
{
    if (bot->GetLevel() < 5)
        return false;
    for (ArmorSlotTypes const& st : s_armorSlotTypes)
    {
        Item* item = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, st.slot);
        if (!item || item->GetTemplate()->Quality <= ITEM_QUALITY_NORMAL)
            return true;
    }
    return false;
}

void BotLifeMgr::VendorGear(Player* bot)
{
    if (bot->GetLevel() < 5)
        return;
    std::call_once(s_vendorArmorOnce, LoadVendorArmor);
    uint64 budget = bot->GetMoney() / 3;
    uint32 const level = bot->GetLevel();
    uint32 bought = 0;
    for (ArmorSlotTypes const& st : s_armorSlotTypes)
    {
        Item* current = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, st.slot);
        if (current && current->GetTemplate()->Quality >= ITEM_QUALITY_UNCOMMON)
            continue;   // only over an empty slot or a grey / white piece
        int32 const currentValue = current ? GearValue(current->GetTemplate()) : -1000;
        ItemTemplate const* best = nullptr;
        for (uint32 type : st.types)
        {
            if (!type)
                continue;
            auto itr = s_vendorArmor.find(type);
            if (itr == s_vendorArmor.end())
                continue;
            for (ItemTemplate const* proto : itr->second)
            {
                if (proto->RequiredLevel > level || proto->ItemLevel + 15 < level || proto->BuyPrice > budget)
                    continue;
                if (bot->CanUseItem(proto) != EQUIP_ERR_OK || !sRandomItemMgr->FitsBot(bot, proto))
                    continue;
                if (GearValue(proto) <= currentValue + 4 || (best && GearValue(proto) <= GearValue(best)))
                    continue;
                best = proto;
            }
        }
        if (!best)
            continue;
        ItemPosCountVec dest;
        if (bot->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, best->ItemId, 1) != EQUIP_ERR_OK)
            break;   // bags full
        if (!bot->StoreNewItem(dest, best->ItemId, true))
            continue;
        bot->ModifyMoney(-int64(best->BuyPrice));
        budget -= std::min<uint64>(budget, best->BuyPrice);
        ++bought;
        Count(BLC_VENDOR_GEAR);
        if (_debug)
            TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): bought {} (ilvl {}) at a vendor for {}", bot->GetName(), level, best->Name1,
                best->ItemLevel, current ? current->GetTemplate()->Name1 : "an empty slot");
    }
    if (bought)
        EquipBagUpgrades(bot);
}

// the giver / ender was not at its spawn - it may walk a path: find it within 150 yd and walk after it
// (at most four times per visit). True while the bot is on its way.
bool BotLifeMgr::ChaseWalkingNpc(Player* bot, BotLifeInfo& t)
{
    if (t.npcIsGo || t.npcChase >= 4)
        return false;
    Creature* npc = bot->FindNearestCreature(t.npcEntry, 150.0f, true);
    if (!npc || npc->IsInCombat())
        return false;
    ++t.npcChase;
    SetDest(t, npc->GetMapId(), npc->GetPositionX(), npc->GetPositionY(), npc->GetPositionZ(), 4.0f);
    t.lastMoveOrder = 0;
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {}: {} ({}) is not at its spawn, walking after it ({} yd)", bot->GetName(), npc->GetName(),
            npc->GetEntry(), uint32(bot->GetExactDist(npc)));
    return true;
}

// a new death knight follows its starting chain (Acherus, the Scarlet Enclave, the Light of
// Dawn, the Battle for the Ebon Hold) like a player does; a quest a bot cannot do is skipped and the chain goes on. Open
// while the bot is in the Scarlet Enclave below level 60 and has not finished The Battle For The Ebon Hold.
bool BotLifeMgr::DeathKnightChainOpen(Player* bot) const
{
    if (!_dkChain || bot->GetClass() != CLASS_DEATH_KNIGHT || bot->GetMapId() != 609 || bot->GetLevel() >= 60
        || bot->IsQuestRewarded(13166))
        return false;
    PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
    return botAI && !botAI->life.dkChainGivenUp;
}

// twelve minutes without a quest done: the chain quests in the log count as done (no reward); the fourth time, or with
// nothing in the log to skip, the rest of the chain is given up and the bot moves on to a zone of its level
void BotLifeMgr::DeathKnightChainWatch(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (!DeathKnightChainOpen(bot))
        return;
    uint32 const done = bot->getRewardedQuests().size();
    if (!t.dkChainSince || done != t.dkChainDone)
    {
        t.dkChainSince = now;
        t.dkChainDone = done;
        return;
    }
    if (now - t.dkChainSince < 12 * MINUTE * IN_MILLISECONDS)
        return;
    t.dkChainSince = now;
    // diagnostics: the chain quests the bot could take next and why it does not
    {
        std::ostringstream why;
        uint32 listed = 0;
        for (auto const& qp : sObjectMgr->GetQuestTemplates())
        {
            Quest const* quest = qp.second;
            if (quest->GetZoneOrSort() != -372 || bot->IsQuestRewarded(quest->GetQuestId()) || listed >= 6)
                continue;
            if (!bot->CanTakeQuest(quest, false) && bot->GetQuestStatus(quest->GetQuestId()) == QUEST_STATUS_NONE)
                continue;
            ++listed;
            why << ' ' << quest->GetQuestId() << "[st " << uint32(bot->GetQuestStatus(quest->GetQuestId())) << " sup "
                << GetPlan(quest).supported << " lvl " << QuestLevelOk(bot, quest) << " doable " << QuestDoable(bot, quest)
                << " skip " << CanSkipQuest(bot, quest) << " bad " << IsBadQuest(quest->GetQuestId())
                << " ts " << t.skipQuests.count(quest->GetQuestId()) << ']';
        }
        TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): death knight chain stalled at {} {} {} state {}:{}", bot->GetName(),
            uint32(bot->GetLevel()), int32(bot->GetPositionX()), int32(bot->GetPositionY()), int32(bot->GetPositionZ()),
            uint32(t.state), why.str());
    }
    // a new try for the chain quests given up on and the givers avoided since
    for (auto itr = t.skipQuests.begin(); itr != t.skipQuests.end();)
    {
        Quest const* quest = sObjectMgr->GetQuestTemplate(*itr);
        if (quest && quest->GetZoneOrSort() == -372)
            itr = t.skipQuests.erase(itr);
        else
            ++itr;
    }
    t.avoidNpc.clear();
    std::vector<uint32> stalled;
    for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
        if (uint32 questId = bot->GetQuestSlotQuestId(slot))
            if (Quest const* quest = sObjectMgr->GetQuestTemplate(questId))
                if (quest->GetZoneOrSort() == -372)
                    stalled.push_back(questId);
    if (!stalled.empty() && ++t.dkChainStalls < 4)
    {
        for (uint32 questId : stalled)
        {
            t.skipQuests.insert(questId);
            AbandonQuest(bot, t, questId, "death knight chain stalled", false);   // skipped there
        }
        return;
    }
    t.dkChainGivenUp = true;   // closed for this session (never mark a quest done that was not done)
    Count(BLC_DK_CHAIN_GIVEUP);
    TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): death knight chain given up ({} quests done, {} in the log)", bot->GetName(),
        uint32(bot->GetLevel()), done, uint32(stalled.size()));
}

// Death Comes From On High (12641). The bot takes the Eye of Acherus at the control mechanism, waits
// until the eye has flown to New Avalon and has control (its flight aura), flies it over the four buildings and casts
// Siphon of Acherus on each one; the credit comes from the spell script, as for a player. Then it lets the eye go and
// turns the quest in as usual. Three tries per session; a try ends after six minutes.
bool BotLifeMgr::DeathKnightEye(Player* bot, BotLifeInfo& t, uint32 now)
{
    enum
    {
        QUEST_DEATH_COMES_FROM_ON_HIGH  = 12641,
        GO_EYE_CONTROL_MECHANISM        = 191609,
        NPC_EYE_OF_ACHERUS              = 28511,
        SPELL_THE_EYE_OF_ACHERUS        = 51852,
        SPELL_SIPHON_OF_ACHERUS         = 51859,
        SPELL_EYE_OF_ACHERUS_FLIGHT     = 51890,
    };
    Unit* charm = bot->GetCharm();
    Creature* eye = charm && charm->GetEntry() == NPC_EYE_OF_ACHERUS ? charm->ToCreature() : nullptr;
    if (!eye)
    {
        if (!bot->IsAlive() || bot->IsInCombat() || bot->GetQuestStatus(QUEST_DEATH_COMES_FROM_ON_HIGH) != QUEST_STATUS_INCOMPLETE
            || t.dkEyeTries >= 3)
            return false;
        GameObject* go = bot->FindNearestGameObject(GO_EYE_CONTROL_MECHANISM, 120.0f);
        if (!go)
            return false;
        if (t.dkEyeSince && now - t.dkEyeSince < 10000)
            return true;   // just used: the eye is on its way
        if (bot->GetExactDist(go) > INTERACTION_DISTANCE - 1.0f)
        {
            if (!bot->isMoving() || now - t.lastMoveOrder > 3000)
            {
                bot->GetMotionMaster()->MovePoint(0, go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(), true);
                t.lastMoveOrder = now;
            }
            return true;
        }
        bot->StopMoving();
        go->Use(bot);
        t.dkEyeSince = now;
        ++t.dkEyeTries;
        Count(BLC_DK_EYE);
        if (_debug)
            TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): takes the Eye of Acherus (try {})", bot->GetName(),
                uint32(bot->GetLevel()), t.dkEyeTries);
        return true;
    }

    // the bot looks through the eye: nothing else runs for it meanwhile
    if (!t.dkEyeSince)
        t.dkEyeSince = now;
    Quest const* quest = sObjectMgr->GetQuestTemplate(QUEST_DEATH_COMES_FROM_ON_HIGH);
    bool const done = !quest || bot->GetQuestStatus(QUEST_DEATH_COMES_FROM_ON_HIGH) != QUEST_STATUS_INCOMPLETE;
    if (done || now - t.dkEyeSince > 6 * MINUTE * IN_MILLISECONDS)
    {
        TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): lets the Eye of Acherus go ({})", bot->GetName(),
            uint32(bot->GetLevel()), done ? "quest complete" : "timeout");
        bot->RemoveAurasDueToSpell(SPELL_THE_EYE_OF_ACHERUS);
        t.dkEyeSince = 0;
        return true;
    }
    if (!eye->HasAura(SPELL_EYE_OF_ACHERUS_FLIGHT))
        return true;   // still on its way to New Avalon

    // the next building not siphoned yet
    Creature* target = nullptr;
    for (QuestObjective const& obj : quest->GetObjectives())
        if (obj.Type == QUEST_OBJECTIVE_MONSTER && !bot->IsQuestObjectiveComplete(quest, obj))
            if ((target = eye->FindNearestCreature(obj.ObjectID, 600.0f)))
                break;
    if (!target)
        return true;   // the timeout lets the eye go
    float const x = target->GetPositionX(), y = target->GetPositionY(), z = target->GetPositionZ() + 15.0f;
    if (eye->GetExactDist2d(x, y) > 15.0f || std::fabs(eye->GetPositionZ() - z) > 25.0f)
    {
        if (!eye->isMoving() || now - t.lastMoveOrder > 4000)
        {
            eye->GetMotionMaster()->MovePoint(0, x, y, z, false);
            t.lastMoveOrder = now;
        }
        return true;
    }
    // a real channel, as a player casts it; the next one only when the channel has ended
    if (eye->GetCurrentSpell(CURRENT_CHANNELED_SPELL))
        return true;
    if (now - t.dkEyeCast > 3000)
    {
        // what the previous cast left behind: the channel aura on the building
        if (t.dkEyeCast)
            TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): eye diag - target {} ({}) dist2d {:.1f} dz {:.1f}, aura on target {}, quest status {}",
                bot->GetName(), uint32(bot->GetLevel()), target->GetName(), target->GetEntry(), eye->GetExactDist2d(target),
                eye->GetPositionZ() - target->GetPositionZ(), target->HasAura(SPELL_SIPHON_OF_ACHERUS),
                uint32(bot->GetQuestStatus(QUEST_DEATH_COMES_FROM_ON_HIGH)));
        eye->StopMoving();
        eye->SetFacingToObject(target);
        eye->CastSpell(target, SPELL_SIPHON_OF_ACHERUS, false);
        t.dkEyeCast = now;
        Count(BLC_DK_EYE_SIPHON);
        TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): siphons {} through the eye - channel {}", bot->GetName(),
            uint32(bot->GetLevel()), target->GetName(), eye->GetCurrentSpell(CURRENT_CHANNELED_SPELL) ? "up" : "not up");
    }
    return true;
}

// death knights wield the sword every death knight gets in Acherus and keep a rune on the weapon
void BotLifeMgr::DeathKnightWeapon(Player* bot)
{
    enum
    {
        ITEM_RUNED_SOULBLADE        = 38707,   // The Emblazoned Runeblade
        ITEM_EBON_BLADE_GREATSWORD  = 38632,   // The Light of Dawn (end of the starting chain)
        ITEM_FIST_OF_OMOKK          = 13167,   // what the bot factory hands a new death knight
        RUNE_FALLEN_CRUSADER        = 3368,
        RUNE_RAZORICE               = 3370,
        RUNE_STONESKIN_GARGOYLE     = 3847,
    };
    if (bot->GetClass() != CLASS_DEATH_KNIGHT || bot->GetLevel() < 55)
        return;
    // the sword of the Ebon Blade (end of the starting chain the bots skip or give up on),
    // put on directly - EquipBagUpgrades leaves weapons above the bot's level alone (ilvl 70 at level 55), so the
    // factory Fist of Omokk stayed in hand. Kept when the bot wields something better than the sword.
    if (ItemTemplate const* sword = sObjectMgr->GetItemTemplate(ITEM_EBON_BLADE_GREATSWORD))
    {
        Item* main = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND);
        bool const factory = main && (main->GetEntry() == ITEM_FIST_OF_OMOKK || main->GetEntry() == ITEM_RUNED_SOULBLADE);
        if (!main || factory || (main->GetEntry() != ITEM_EBON_BLADE_GREATSWORD && GearValue(main->GetTemplate()) < GearValue(sword)))
        {
            Item* blade = bot->GetItemByEntry(ITEM_EBON_BLADE_GREATSWORD);
            if (!blade)
            {
                ItemPosCountVec dest;
                if (bot->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, ITEM_EBON_BLADE_GREATSWORD, 1) == EQUIP_ERR_OK)
                    blade = bot->StoreNewItem(dest, ITEM_EBON_BLADE_GREATSWORD, true);
            }
            uint16 equipDest;
            if (blade && !blade->IsEquipped()
                && bot->CanEquipItem(EQUIPMENT_SLOT_MAINHAND, equipDest, blade, true) == EQUIP_ERR_OK)
            {
                bot->SwapItem(blade->GetPos(), equipDest);
                if (_debug)
                    TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): wields the Greatsword of the Ebon Blade", bot->GetName(),
                        uint32(bot->GetLevel()));
            }
        }
        // the factory weapon and the spare first sword out of the bags once the greatsword is in hand
        Item* wielded = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND);
        if (wielded && wielded->GetEntry() == ITEM_EBON_BLADE_GREATSWORD)
        {
            if (bot->HasItemCount(ITEM_FIST_OF_OMOKK, 1, false))
                bot->DestroyItemCount(ITEM_FIST_OF_OMOKK, 99, true);
            if (bot->HasItemCount(ITEM_RUNED_SOULBLADE, 1, false))
                bot->DestroyItemCount(ITEM_RUNED_SOULBLADE, 99, true);
        }
    }
    // runeforging
    auto isRune = [](uint32 id)
    {
        return (id >= 3365 && id <= 3370) || id == 3594 || id == 3595 || id == 3847 || id == 3883;
    };
    auto runeforge = [&](uint8 slot, uint32 rune)
    {
        Item* item = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
        if (!item || item->GetTemplate()->Class != ITEM_CLASS_WEAPON || isRune(item->GetEnchantmentId(PERM_ENCHANTMENT_SLOT)))
            return;
        bot->ApplyEnchantment(item, PERM_ENCHANTMENT_SLOT, false);
        item->SetEnchantment(PERM_ENCHANTMENT_SLOT, rune, 0, 0, bot->GetGUID());
        bot->ApplyEnchantment(item, PERM_ENCHANTMENT_SLOT, true);
        if (_debug)
            TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): runeforges {} with {}", bot->GetName(), uint32(bot->GetLevel()),
                item->GetTemplate()->Name1, rune);
    };
    Item* main = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND);
    bool const twoHander = main && main->GetTemplate()->InventoryType == INVTYPE_2HWEAPON;
    uint32 const spec = bot->GetSpecialization();
    runeforge(EQUIPMENT_SLOT_MAINHAND, spec == SPEC_DEATH_KNIGHT_BLOOD && twoHander ? RUNE_STONESKIN_GARGOYLE : RUNE_FALLEN_CRUSADER);
    if (spec == SPEC_DEATH_KNIGHT_FROST && !twoHander)
        runeforge(EQUIPMENT_SLOT_OFFHAND, RUNE_RAZORICE);
}

// the port's factory has no InitBags: 2728 of 3000 bots carried only the 16-slot backpack, so gathered
// materials and loot overflowed at once. Empty bag slots get a bag that fits the level.
void BotLifeMgr::EnsureBags(Player* bot)
{
    uint32 level = bot->GetLevel();
    uint32 bag = level < 15 ? 4238 : level < 30 ? 4245 : level < 45 ? 10050 : level < 60 ? 14046 : level < 70 ? 21841
        : level < 80 ? 41599 : 54443;
    for (uint8 slot = INVENTORY_SLOT_BAG_START; slot < INVENTORY_SLOT_BAG_END; ++slot)
    {
        if (bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
            continue;
        uint16 dest;
        if (bot->CanEquipNewItem(slot, dest, bag, false) != EQUIP_ERR_OK)
            continue;
        if (bot->EquipNewItem(dest, bag, true))
            Count(BLC_BAGS_GIVEN);
    }
}

bool BotLifeMgr::EnsureWeapon(Player* bot)
{
    auto isRanged = [](ItemTemplate const* proto)
    {
        return proto->Class == ITEM_CLASS_WEAPON && (proto->SubClass == ITEM_SUBCLASS_WEAPON_BOW
            || proto->SubClass == ITEM_SUBCLASS_WEAPON_GUN || proto->SubClass == ITEM_SUBCLASS_WEAPON_CROSSBOW);
    };
    bool hunter = bot->GetClass() == CLASS_HUNTER;
    // tanks fight with a one-hander and a shield (a two-hander leaves Shield Slam / Shield of the Righteous and
    // the block unusable; castdiag 26-9 found prot warriors with polearms)
    uint32 spec = bot->GetSpecialization();
    bool tank = spec == Specializations::SPEC_WARRIOR_PROTECTION || spec == Specializations::SPEC_PALADIN_PROTECTION;
    // assassination / subtlety: Mutilate, Backstab and Dispatch need a dagger
    bool daggerSpec = spec == Specializations::SPEC_ROGUE_ASSASSINATION || spec == Specializations::SPEC_ROGUE_SUBTLETY;
    bool changed = false;
    uint32 level = bot->GetLevel();
    uint32 minReq = level > 10 ? level - 10 : 0;

    Item* current = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND);
    bool replace = false;
    if (current)
    {
        ItemTemplate const* cur = current->GetTemplate();
        // hunters shoot: a melee weapon in their (MoP: only) weapon slot leaves every shot unusable
        if ((hunter && !isRanged(cur)) || (tank && cur->InventoryType == INVTYPE_2HWEAPON)
            || (daggerSpec && cur->SubClass != ITEM_SUBCLASS_WEAPON_DAGGER))
        {
            // swap instead of destroying the equipped weapon (mass DestroyItem at login preceded the crash in
            // Map::Update's update list on 26-9 23:21); the old weapon goes to the bags and is sold later
            replace = true;
            current = nullptr;
        }
    }

    if (!current)
    {
        // first pass: a weapon that fits the spec (primary stat, weapon type); second pass: anything usable
        for (uint32 pass = 0; pass < 2 && !current; ++pass)
            for (WeaponCandidate const& c : WeaponCandidates())
            {
                if (c.reqLevel > level || c.reqLevel < minReq)
                    continue;
                ItemTemplate const* proto = sObjectMgr->GetItemTemplate(c.entry);
                if (!proto || proto->Class != ITEM_CLASS_WEAPON || bot->CanUseItem(proto) != EQUIP_ERR_OK || isRanged(proto) != hunter)
                    continue;
                if (!RandomItemManager::ItemLevelFits(level, proto))   // no item level 813 on a level 1 bot
                    continue;
                if (tank && proto->InventoryType == INVTYPE_2HWEAPON)
                    continue;
                if (pass == 0 && (!sRandomItemMgr->FitsBot(bot, proto) || (daggerSpec && proto->SubClass != ITEM_SUBCLASS_WEAPON_DAGGER)))
                    continue;
                uint16 dest;
                if (bot->CanEquipNewItem(EQUIPMENT_SLOT_MAINHAND, dest, c.entry, replace) != EQUIP_ERR_OK)
                    continue;
                Item* item = nullptr;
                if (!replace)
                    item = bot->EquipNewItem(dest, c.entry, true);
                else
                {
                    ItemPosCountVec bagDest;
                    if (bot->CanStoreNewItem(NULL_BAG, NULL_SLOT, bagDest, c.entry, 1) != EQUIP_ERR_OK)
                        break;   // bags full: keep the old weapon for now
                    Item* stored = bot->StoreNewItem(bagDest, c.entry, true);
                    uint16 eqDest;
                    if (stored && bot->CanEquipItem(EQUIPMENT_SLOT_MAINHAND, eqDest, stored, true) == EQUIP_ERR_OK)
                    {
                        bot->SwapItem(stored->GetPos(), eqDest);
                        item = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND);
                    }
                }
                if (item)
                {
                    bot->AutoUnequipOffhandIfNeed();
                    current = item;
                    changed = true;
                    if (_debug)
                        TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): weapon {} ({})", bot->GetName(), level, proto->Name1, c.entry);
                }
                break;
            }
    }

    if (tank && !bot->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_OFFHAND))
    {
        for (WeaponCandidate const& c : WeaponCandidates())
        {
            if (c.reqLevel > level || c.reqLevel < minReq)
                continue;
            ItemTemplate const* proto = sObjectMgr->GetItemTemplate(c.entry);
            if (!proto || proto->InventoryType != INVTYPE_SHIELD || bot->CanUseItem(proto) != EQUIP_ERR_OK)
                continue;
            uint16 dest;
            if (bot->CanEquipNewItem(EQUIPMENT_SLOT_OFFHAND, dest, c.entry, false) != EQUIP_ERR_OK)
                continue;
            if (bot->EquipNewItem(dest, c.entry, true))
            {
                changed = true;
                Count(BLC_TANK_SHIELD);
            }
            break;
        }
    }
    return changed;
}


// ---------------------------------------------------------------------------------------------
// questing together. The port has no quest actions for bots that follow a real player: they take the
// quests the player takes and hand them in when the player does (the player walks, talks and loots; the group
// shares kill credit anyway).

void BotLifeMgr::MasterQuestSync(Player* bot, Player* master, BotLifeInfo& t, uint32 now)
{
    if (now < t.nextMasterQuestSync)
        return;
    t.nextMasterQuestSync = now + 3000;
    if (!master->IsInWorld() || master->FindMap() != bot->FindMap() || bot->GetDistance(master) > 100.0f || bot->IsInCombat())
        return;

    for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
    {
        uint32 questId = master->GetQuestSlotQuestId(slot);
        if (!questId || bot->GetQuestStatus(questId) != QUEST_STATUS_NONE || bot->GetQuestRewardStatus(questId))
            continue;
        Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
        if (!quest || !bot->CanTakeQuest(quest, false) || !bot->CanAddQuest(quest, false))
            continue;
        bot->AddQuestAndCheckCompletion(quest, master);
        Count(BLC_PARTY_QUEST_SHARED);
    }

    for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
    {
        uint32 questId = bot->GetQuestSlotQuestId(slot);
        if (!questId || !master->GetQuestRewardStatus(questId))
            continue;
        Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
        if (!quest)
            continue;
        if (bot->GetQuestStatus(questId) != QUEST_STATUS_COMPLETE)
            bot->CompleteQuest(questId);
        if (bot->GetQuestStatus(questId) == QUEST_STATUS_COMPLETE && bot->CanRewardQuest(quest, 0, false))
        {
            bot->RewardQuest(quest, 0, bot, false);
            Count(BLC_PARTY_QUEST_TURNIN);
        }
    }
}

uint32 BotLifeMgr::MapPopulation(uint32 mapId) const
{
    switch (mapId)
    {
        case 0:   return _mapPop[0].load(std::memory_order_relaxed);
        case 1:   return _mapPop[1].load(std::memory_order_relaxed);
        case 530: return _mapPop[2].load(std::memory_order_relaxed);
        case 571: return _mapPop[3].load(std::memory_order_relaxed);
        case 870: return _mapPop[4].load(std::memory_order_relaxed);
        case 1064: return _mapPop[5].load(std::memory_order_relaxed);
        default:  return 0;
    }
}

// gathering fills the bags with materials; then a town trip (guild bank, auction house) comes first
bool BotLifeMgr::BagsFullOfMaterials(Player* bot) const
{
    uint32 freeSlots = 0, materialStacks = 0;
    auto consider = [&](Item* item)
    {
        if (!item)
            ++freeSlots;
        else if (ItemTemplate const* proto = item->GetTemplate())
            if (proto->Class == ITEM_CLASS_TRADE_GOODS)
                ++materialStacks;
    };
    for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        consider(bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot));
    for (uint8 bagSlot = INVENTORY_SLOT_BAG_START; bagSlot < INVENTORY_SLOT_BAG_END; ++bagSlot)
        if (Bag* bag = bot->GetBagByPos(bagSlot))
            for (uint32 slot = 0; slot < bag->GetBagSize(); ++slot)
                consider(bag->GetItemByPos(uint8(slot)));
    return freeSlots < 6 && materialStacks >= 4;
}

void BotLifeMgr::AdjustMapPopulation(uint32 mapId, int32 delta)
{
    int idx = mapId == 0 ? 0 : mapId == 1 ? 1 : mapId == 530 ? 2 : mapId == 571 ? 3 : mapId == 870 ? 4 : mapId == 1064 ? 5 : -1;
    if (idx < 0)
        return;
    if (delta < 0)
    {
        uint32 cur = _mapPop[idx].load(std::memory_order_relaxed);
        while (cur && !_mapPop[idx].compare_exchange_weak(cur, cur - 1, std::memory_order_relaxed)) { }
    }
    else
        _mapPop[idx].fetch_add(uint32(delta), std::memory_order_relaxed);
}
