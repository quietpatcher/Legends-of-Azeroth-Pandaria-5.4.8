/*
 * Bot life: social side of "bot life" - chat, emotes, guild chat reactions, zone channel chatter
 * and guild calendar events (sign-ups, joining the organizer's raid when the event starts).
 *
 * Everything that sends chat is queued and delivered from the world thread (WorldUpdate).
 */

#include "BotLife.h"
#include "World.h"
#include "MapManager.h"

#include "CalendarMgr.h"
#include "Channel.h"
#include "ChannelMgr.h"
#include "Chat.h"
#include "ChatPackets.h"
#include "DatabaseEnv.h"
#include "DBCStores.h"
#include "Group.h"
#include "GroupMgr.h"
#include "Guild.h"
#include "GuildMgr.h"
#include "Log.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "PlayerbotSpec.h"
#include "Playerbots.h"
#include "QuestDef.h"
#include "Random.h"
#include "RandomPlayerbotMgr.h"
#include "Timer.h"
#include "WorldPacket.h"
#include "WorldSession.h"

#include <algorithm>
#include <cctype>
#include <sstream>

namespace
{
    // hand written lines, casual lowercase like players type
    std::vector<std::string> const GuildGreet = {
        "hi %s", "hey %s", "o/", "yo %s", "hiya", "welcome back %s", "hey hey", "sup %s", "\\o", "heya %s", "hi", "evening %s" };
    std::vector<std::string> const GuildGz = {
        "gz", "gz %s", "grats!", "gratz %s", "nice ding", "gz!!", "grats on the level", "woo gz", "ding! gz", "congrats %s" };
    std::vector<std::string> const GuildReplyQuestion = {
        "not sure tbh", "idk", "no idea lol", "maybe ask in trade", "yes", "no", "probably", "hmm good question",
        "check wowhead lol", "i think so", "no clue", "depends", "ask me later im pulling" };
    std::vector<std::string> const GuildReplyGeneric = {
        "lol", "haha", "true", "nice", "same", "yep", "ya", "agreed", "fair", "lmao", "ok", "sounds good", ":)", "hehe" };
    std::vector<std::string> const GuildReplyThanks = { "np", "np!", "anytime", "yw", "no problem" };
    std::vector<std::string> const GuildIdle = {
        "anyone up for a dungeon later?", "brb food", "back", "this zone is packed", "anyone know a good farm spot?",
        "leveling is slow today", "almost %next_level", "grinding in %zone_name", "who else is still up", "lag or is it me?",
        "need a tank for %instance_name later", "questing in %zone_name, anyone near?", "just got a nice drop",
        "coffee time", "ok who pulled that", "hi all", "anyone doing %instance_name?", "%zone_name is kinda pretty tbh",
        "lf %instance_name, need 2 more", "level %my_level %my_class looking for group", "back from dinner", "brb",
        "these mobs hit hard", "finally out of %zone_name lol", "gonna do some quests in %zone_name", "who needs mats?" };
    std::vector<std::string> const SayIdle = {
        "hey", "hi there", "nice gear", "hello :)", "good luck out there", "this area is crowded",
        "watch out for the mobs over there", "lol", "o/", "busy place", "evening", "cool mount", "on my way to %zone_name" };
    std::vector<std::string> const ZoneChat = {
        "LFG %instance_name", "anyone want to group for quests in %zone_name?", "WTB bags", "LF healer for %instance_name",
        "LF tank %instance_name", "anyone else doing quests here?", "where is the flight master in %zone_name?",
        "any guild recruiting?", "LFM %instance_name need dps", "selling cloth, pst", "wts herbs, cheap", "LFG quests %zone_name",
        "anyone seen the rare here?", "how do i get to %instance_name?", "%my_level %my_class LFG" };
    std::vector<std::string> const EventStart = { "omw!", "coming", "here", "ready", "lets go", "on my way", "inc", "ready when you are" };
    std::vector<std::string> const AnnouncementReact = { "sounds good", "nice!", "count me in", "ill be there", "cool", "sweet", "noted", "yay" };
    std::vector<std::string> const LevelUpSelf = { "ding %my_level", "ding!", "%my_level finally", "ding %my_level :)", "woo level %my_level" };

    std::vector<std::string> const BlockedWords = {
        "fuck", "shit", "gag", "hoe", "whore", "bitch", "retard", "gay", "nazi", "kys", "cock", "dick", "penis", "porn", "sex",
        "rape", "cunt", "slut", "nigg", "fag", "kill yourself", "suicide", "drug", "weed", "cancer", "stfu", "wtf", "idiot", "stupid",
        "noob", "thunderfury", "chuck norris", "anal", "boob", "tits", "naked", "horny", "sexy", "virgin", "pussy", "damn", "hell" };

    struct Dungeon { uint8 minLevel; uint8 maxLevel; char const* name; };
    std::vector<Dungeon> const Dungeons = {
        { 15, 21, "Ragefire Chasm" }, { 15, 21, "the Deadmines" }, { 15, 25, "Wailing Caverns" }, { 18, 25, "Shadowfang Keep" },
        { 20, 30, "Blackfathom Deeps" }, { 20, 30, "the Stockade" }, { 25, 35, "Gnomeregan" }, { 26, 36, "Scarlet Halls" },
        { 28, 38, "Scarlet Monastery" }, { 30, 40, "Razorfen Kraul" }, { 38, 48, "Scholomance" }, { 40, 50, "Razorfen Downs" },
        { 40, 50, "Uldaman" }, { 44, 54, "Zul'Farrak" }, { 45, 55, "Maraudon" }, { 50, 60, "the Sunken Temple" },
        { 52, 60, "Blackrock Depths" }, { 55, 60, "Lower Blackrock Spire" }, { 57, 63, "Hellfire Ramparts" },
        { 58, 64, "the Blood Furnace" }, { 61, 67, "the Slave Pens" }, { 62, 68, "the Underbog" }, { 63, 69, "Mana-Tombs" },
        { 64, 70, "Auchenai Crypts" }, { 66, 72, "Sethekk Halls" }, { 67, 73, "Shadow Labyrinth" }, { 68, 74, "Utgarde Keep" },
        { 69, 75, "the Nexus" }, { 71, 77, "Azjol-Nerub" }, { 72, 78, "Drak'Tharon Keep" }, { 74, 80, "Utgarde Pinnacle" },
        { 78, 80, "the Halls of Lightning" }, { 80, 83, "Blackrock Caverns" }, { 80, 83, "Throne of the Tides" },
        { 81, 84, "the Vortex Pinnacle" }, { 83, 85, "Grim Batol" }, { 85, 87, "the Temple of the Jade Serpent" },
        { 85, 87, "Stormstout Brewery" }, { 87, 89, "Shado-Pan Monastery" }, { 87, 89, "Mogu'shan Palace" },
        { 90, 90, "Gate of the Setting Sun" }, { 90, 90, "Siege of Niuzao Temple" } };

    char const* ClassName(uint8 cls)
    {
        static char const* names[] = { "", "warrior", "paladin", "hunter", "rogue", "priest", "death knight", "shaman", "mage",
            "warlock", "monk", "druid" };
        return cls < 12 ? names[cls] : "";
    }

    char const* RaceName(uint8 race)
    {
        switch (race)
        {
            case 1: return "human";
            case 2: return "orc";
            case 3: return "dwarf";
            case 4: return "night elf";
            case 5: return "undead";
            case 6: return "tauren";
            case 7: return "gnome";
            case 8: return "troll";
            case 9: return "goblin";
            case 10: return "blood elf";
            case 11: return "draenei";
            case 22: return "worgen";
            case 24: case 25: case 26: return "pandaren";
            default: return "";
        }
    }

    std::string Lower(std::string s)
    {
        std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) { return char(std::tolower(c)); });
        return s;
    }

    bool ContainsWord(std::string const& text, std::vector<std::string> const& words)
    {
        std::string l = " " + Lower(text) + " ";
        for (std::string const& w : words)
        {
            size_t pos = l.find(w);
            while (pos != std::string::npos)
            {
                bool startOk = !std::isalpha((unsigned char)l[pos - 1]);
                bool endOk = !std::isalpha((unsigned char)l[pos + w.size()]);
                if (startOk && endOk)
                    return true;
                pos = l.find(w, pos + 1);
            }
        }
        return false;
    }

    void ReplaceAll(std::string& text, std::string const& what, std::string const& with)
    {
        size_t pos = 0;
        while ((pos = text.find(what, pos)) != std::string::npos)
        {
            text.replace(pos, what.size(), with);
            pos += with.size();
        }
    }

    bool OnlyKnownPlaceholders(std::string const& text, std::vector<std::string> const& extra)
    {
        static std::vector<std::string> const known = { "%s", "%zone_name", "%my_level", "%next_level", "%my_class", "%my_race",
            "%my_role", "%instance_name" };
        size_t pos = text.find('%');
        while (pos != std::string::npos)
        {
            bool ok = false;
            for (auto const* list : { &known, &extra })
                for (std::string const& p : *list)
                    if (text.compare(pos, p.size(), p) == 0 && (pos + p.size() >= text.size() || !std::isalpha((unsigned char)text[pos + p.size()]) || p == "%s"))
                    {
                        ok = true;
                        break;
                    }
            if (!ok)
                return false;
            pos = text.find('%', pos + 1);
        }
        return true;
    }
}

void BotLifeMgr::LoadTexts()
{
    _texts.clear();
    _texts["guild_greet"] = GuildGreet;
    _texts["guild_gz"] = GuildGz;
    _texts["guild_reply_question"] = GuildReplyQuestion;
    _texts["guild_reply_generic"] = GuildReplyGeneric;
    _texts["guild_reply_thanks"] = GuildReplyThanks;
    _texts["guild_idle"] = GuildIdle;
    _texts["say_idle"] = SayIdle;
    _texts["zone_chat"] = ZoneChat;
    _texts["event_start"] = EventStart;
    _texts["announcement_react"] = AnnouncementReact;
    _texts["levelup_self"] = LevelUpSelf;

    std::unordered_map<std::string, std::vector<std::string>> extraPlaceholders = {
        { "broadcast_looting_item_rare", { "%item_link" } },
        { "broadcast_looting_item_epic", { "%item_link" } },
        { "broadcast_quest_turned_in", { "%quest_link" } },
        { "broadcast_quest_accepted_generic", { "%quest_link" } },
        { "broadcast_killed_rare", { "%victim_name" } },
        { "broadcast_killed_rareelite", { "%victim_name" } },
        { "broadcast_killed_worldboss", { "%victim_name" } },
        { "broadcast_levelup_generic", {} },
        { "suggest_something", {} },
        { "suggest_instance", {} },
        { "reply", {} } };

    uint32 count = 0;
    if (QueryResult result = PlayerbotsDatabase.Query("SELECT name, text FROM ai_playerbot_texts"))
    {
        do
        {
            Field* f = result->Fetch();
            std::string name = f[0].GetString();
            std::string text = f[1].GetString();
            auto extra = extraPlaceholders.find(name);
            if (extra == extraPlaceholders.end())
                continue;
            if (text.empty() || text.size() > 140 || ContainsWord(text, BlockedWords))
                continue;
            if (std::any_of(text.begin(), text.end(), [](unsigned char c) { return c >= 128 || c == '|'; }))
                continue;
            if (!OnlyKnownPlaceholders(text, extra->second))
                continue;
            _texts[name].push_back(text);
            ++count;
        } while (result->NextRow());
    }
    TC_LOG_INFO("server.loading", ">> BotLife: {} chat texts loaded from ai_playerbot_texts", count);
}

std::string BotLifeMgr::Fill(std::string text, Player* bot, Player* other)
{
    if (other)
        ReplaceAll(text, "%s", other->GetName());
    if (text.find("%zone_name") != std::string::npos)
    {
        AreaTableEntry const* zone = sAreaTableStore.LookupEntry(bot->GetZoneId());
        ReplaceAll(text, "%zone_name", zone && zone->area_name ? zone->area_name : "here");
    }
    ReplaceAll(text, "%next_level", std::to_string(bot->GetLevel() + 1));
    ReplaceAll(text, "%my_level", std::to_string(bot->GetLevel()));
    ReplaceAll(text, "%my_class", ClassName(bot->GetClass()));
    ReplaceAll(text, "%my_race", RaceName(bot->GetRace()));
    if (text.find("%my_role") != std::string::npos)
        ReplaceAll(text, "%my_role", PlayerBotSpec::IsTank(bot) ? "tank" : (PlayerBotSpec::IsHeal(bot) ? "healer" : "dps"));
    if (text.find("%instance_name") != std::string::npos)
    {
        std::vector<char const*> fitting;
        for (Dungeon const& d : Dungeons)
            if (bot->GetLevel() >= d.minLevel && bot->GetLevel() <= d.maxLevel + 2)
                fitting.push_back(d.name);
        if (fitting.empty())
            return "";
        ReplaceAll(text, "%instance_name", fitting[urand(0, fitting.size() - 1)]);
    }
    return text;
}

std::string BotLifeMgr::PickText(std::string const& category, Player* bot, Player* other)
{
    auto it = _texts.find(category);
    if (it == _texts.end() || it->second.empty())
        return "";
    for (uint32 attempt = 0; attempt < 4; ++attempt)
    {
        std::string text = it->second[urand(0, it->second.size() - 1)];
        if (!other && text.find("%s") != std::string::npos)
            continue;
        text = Fill(text, bot, other);
        if (!text.empty())
            return text;
    }
    return "";
}

void BotLifeMgr::Queue(uint32 delayMs, Player* bot, uint8 type, std::string const& text, ObjectGuid target, uint32 emote)
{
    if (!bot || (text.empty() && type != BOTLIFE_CHAT_EMOTE))
        return;
    BotLifePendingChat chat;
    chat.at = getMSTime() + delayMs;
    chat.bot = bot->GetGUID();
    chat.type = type;
    chat.text = text;
    chat.target = target;
    chat.emote = emote;
    std::lock_guard<std::mutex> guard(_lock);
    if (_pending.size() < 500)
        _pending.push_back(std::move(chat));
}

bool BotLifeMgr::CanBroadcast(uint32 now, uint32 minGapMs)
{
    std::lock_guard<std::mutex> guard(_lock);
    if (now < _nextBroadcast)
        return false;
    _nextBroadcast = now + minGapMs;
    return true;
}

void BotLifeMgr::Deliver(BotLifePendingChat const& chat)
{
    Player* bot = ObjectAccessor::FindConnectedPlayer(chat.bot);
    if (!bot || !bot->IsInWorld() || !bot->GetSession() || bot->IsBeingTeleported())
        return;

    switch (chat.type)
    {
        case BOTLIFE_CHAT_GUILD:
            if (Guild* guild = sGuildMgr->GetGuildById(bot->GetGuildId()))
                guild->BroadcastToGuild(bot->GetSession(), false, chat.text, LANG_UNIVERSAL);
            break;
        case BOTLIFE_CHAT_SAY:
            if (bot->IsAlive())
                bot->Say(chat.text, LANG_UNIVERSAL);
            break;
        case BOTLIFE_CHAT_EMOTE:
            if (bot->IsAlive() && !bot->IsInCombat())
                DoTextEmote(bot, chat.emote, chat.target.IsEmpty() ? nullptr : ObjectAccessor::GetUnit(*bot, chat.target));
            break;
        case BOTLIFE_CHAT_ZONE:
            SayInZoneChannel(bot, chat.text);
            break;
        default:
            break;
    }
}

void BotLifeMgr::DoTextEmote(Player* bot, uint32 textEmote, Unit* target)
{
    if (target && target->IsInMap(bot) && bot->GetExactDist(target) < 40.0f)
        bot->SetFacingToObject(target);
    else
        target = nullptr;

    WorldPacket data(CMSG_TEXT_EMOTE);
    WorldPackets::Chat::CTextEmote packet(std::move(data));
    packet.EmoteID = textEmote;
    packet.SoundIndex = 0;
    packet.Target = target ? target->GetGUID() : ObjectGuid::Empty;
    bot->GetSession()->HandleTextEmoteOpcode(packet);
}

bool BotLifeMgr::SayInZoneChannel(Player* bot, std::string const& text)
{
    AreaTableEntry const* zone = sAreaTableStore.LookupEntry(bot->GetZoneId());
    ChatChannelsEntry const* channelEntry = sChatChannelsStore.LookupEntry(1);   // General
    if (!zone || !zone->area_name || !channelEntry || !channelEntry->pattern)
        return false;

    char name[200];
    snprintf(name, sizeof(name), channelEntry->pattern, zone->area_name);
    ChannelMgr* channelMgr = ChannelMgr::forTeam(bot->GetTeam());
    if (!channelMgr)
        return false;
    Channel* channel = channelMgr->GetJoinChannel(name, channelEntry->ChannelID);
    if (!channel)
        return false;
    channel->JoinChannel(bot, "");   // no-op (no message for built-in channels) when already a member
    channel->Say(bot->GetGUID(), text, LANG_UNIVERSAL);
    return true;
}

Player* BotLifeMgr::RandomGuildBot(uint32 guildId, Player* exclude, uint32 nearLevel)
{
    std::vector<Player*> candidates;
    for (auto it = sRandomPlayerbotMgr->GetPlayerBotsBegin(); it != sRandomPlayerbotMgr->GetPlayerBotsEnd(); ++it)
    {
        Player* bot = it->second;
        if (!bot || bot == exclude || !bot->IsInWorld() || bot->GetGuildId() != guildId || bot->IsBeingTeleported())
            continue;
        if (nearLevel && std::abs(int32(bot->GetLevel()) - int32(nearLevel)) > 10)
            continue;
        candidates.push_back(bot);
    }
    if (candidates.empty())
        return nearLevel ? RandomGuildBot(guildId, exclude, 0) : nullptr;
    return candidates[urand(0, candidates.size() - 1)];
}

bool BotLifeMgr::GuildHasRealPlayerOnline(uint32 guildId) const
{
    if (!guildId)
        return false;
    for (Player* player : sRandomPlayerbotMgr->GetPlayers())
        if (player && player->IsInWorld() && player->GetGuildId() == guildId)
            return true;
    return false;
}

// ---------------------------------------------------------------------------------------------
// per bot (map thread): only queues, never sends directly

void BotLifeMgr::SocialTick(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    if (now < t.nextSocial)
        return;
    t.nextSocial = now + urand(20000, 45000);

    Player* bot = botAI->GetBot();
    Player* real = nullptr;
    float best = 25.0f;
    for (Player* player : sRandomPlayerbotMgr->GetPlayers())
    {
        if (!player || !player->IsInWorld() || player->FindMap() != bot->FindMap() || player->IsGameMaster())
            continue;
        if (player->GetTeam() != bot->GetTeam())   // no staring and waving at a player of the other faction
            continue;
        float d = bot->GetExactDist(player);
        if (d < best)
        {
            best = d;
            real = player;
        }
    }
    if (!real)
        return;

    {
        std::lock_guard<std::mutex> guard(_lock);
        uint32& cooldown = _realSocialCooldown[uint64(real->GetGUID())];
        if (now < cooldown)
            return;
        cooldown = now + urand(20000, 40000);
    }

    uint32 roll = urand(0, 99);
    if (_emotes && roll < 30)
    {
        static uint32 const atPlayer[] = { TEXT_EMOTE_WAVE, TEXT_EMOTE_HELLO, TEXT_EMOTE_BOW, TEXT_EMOTE_SALUTE, TEXT_EMOTE_GREET, TEXT_EMOTE_CHEER };
        Queue(urand(0, 1500), bot, BOTLIFE_CHAT_EMOTE, "", real->GetGUID(), atPlayer[urand(0, 5)]);
    }
    else if (_emotes && roll < 45)
    {
        static uint32 const idle[] = { TEXT_EMOTE_DANCE, TEXT_EMOTE_LAUGH, TEXT_EMOTE_FLEX, TEXT_EMOTE_YAWN, TEXT_EMOTE_ROAR };
        Queue(urand(0, 1500), bot, BOTLIFE_CHAT_EMOTE, "", ObjectGuid::Empty, idle[urand(0, 4)]);
    }
    else if (_chat && roll < 60)
    {
        std::string text = PickText(urand(0, 3) ? "say_idle" : "suggest_something", bot, real);
        if (!text.empty())
            Queue(urand(500, 2500), bot, BOTLIFE_CHAT_SAY, text);
    }
}

// ---------------------------------------------------------------------------------------------
// hooks

void BotLifeMgr::OnLevelChanged(Player* player, uint8 oldLevel)
{
    if (player && player->GetSession() && player->GetSession()->IsBot() && player->GetLevel() > oldLevel)
        Count(BLC_LEVELUP);
    if (!_enabled || !_loaded || !_chat || !player || player->GetLevel() <= oldLevel)
        return;
    uint32 guildId = player->GetGuildId();
    PlayerbotAI* botAI = GET_PLAYERBOT_AI(player);
    bool isBot = botAI && !botAI->IsRealPlayer();

    if (!isBot)
    {
        // a real player leveled: the guild says gz
        if (!guildId)
            return;
        uint32 count = urand(1, 4);
        Player* last = nullptr;
        for (uint32 i = 0; i < count; ++i)
            if (Player* bot = RandomGuildBot(guildId, last))
            {
                Queue(urand(2500, 14000), bot, BOTLIFE_CHAT_GUILD, PickText("guild_gz", bot, player));
                last = bot;
            }
        return;
    }

    if (guildId && GuildHasRealPlayerOnline(guildId) && urand(0, 99) < 12 && CanBroadcast(getMSTime(), 45000))
    {
        std::string text = PickText(urand(0, 1) ? "levelup_self" : "broadcast_levelup_generic", player);
        Queue(urand(1000, 5000), player, BOTLIFE_CHAT_GUILD, text);
    }
}

void BotLifeMgr::OnQuestRewarded(Player* player, Quest const* quest)
{
    if (!_enabled || !_loaded || !_chat || !player || !quest || !player->GetGuildId())
        return;
    PlayerbotAI* botAI = GET_PLAYERBOT_AI(player);
    if (!botAI || botAI->IsRealPlayer() || !GuildHasRealPlayerOnline(player->GetGuildId()))
        return;
    if (urand(0, 99) >= 4 || !CanBroadcast(getMSTime(), 60000))
        return;
    std::string text = PickText("broadcast_quest_turned_in", player);
    std::ostringstream link;
    link << "|cffffff00|Hquest:" << quest->GetQuestId() << ":" << quest->GetQuestLevel() << "|h[" << quest->GetLogTitle() << "]|h|r";
    ReplaceAll(text, "%quest_link", link.str());
    if (!text.empty() && text.find('%') == std::string::npos)
        Queue(urand(2000, 6000), player, BOTLIFE_CHAT_GUILD, text);
}

void BotLifeMgr::BroadcastLoot(Player* bot, uint32 itemId)
{
    if (!_chat || !bot->GetGuildId())
        return;
    ItemTemplate const* proto = sObjectMgr->GetItemTemplate(itemId);
    if (!proto || proto->Quality < ITEM_QUALITY_RARE)
        return;
    uint32 chance = proto->Quality >= ITEM_QUALITY_EPIC ? 90 : 20;
    if (urand(0, 99) >= chance || !GuildHasRealPlayerOnline(bot->GetGuildId()) || !CanBroadcast(getMSTime(), 45000))
        return;
    std::string text = PickText(proto->Quality >= ITEM_QUALITY_EPIC ? "broadcast_looting_item_epic" : "broadcast_looting_item_rare", bot);
    std::ostringstream link;
    link << "|c" << std::hex << ItemQualityColors[proto->Quality] << std::dec << "|Hitem:" << itemId << ":0:0:0:0:0:0:0:0:0|h["
         << proto->Name1 << "]|h|r";
    ReplaceAll(text, "%item_link", link.str());
    if (!text.empty() && text.find('%') == std::string::npos)
        Queue(urand(1500, 5000), bot, BOTLIFE_CHAT_GUILD, text);
}

void BotLifeMgr::OnRealPlayerLogin(Player* player)
{
    if (!_enabled || !_loaded || !_chat || !player || !player->GetGuildId())
        return;
    uint32 count = urand(1, 3);
    Player* last = nullptr;
    for (uint32 i = 0; i < count; ++i)
        if (Player* bot = RandomGuildBot(player->GetGuildId(), last))
        {
            Queue(urand(6000, 30000), bot, BOTLIFE_CHAT_GUILD, PickText("guild_greet", bot, player));
            last = bot;
        }
}

void BotLifeMgr::OnRealPlayerLogout(Player* player)
{
    if (!player)
        return;
    std::lock_guard<std::mutex> guard(_lock);
    _realSocialCooldown.erase(uint64(player->GetGUID()));
}

void BotLifeMgr::OnGuildChat(Player* player, std::string const& msg, Guild* guild)
{
    if (!_enabled || !_loaded || !_chat || !player || !guild)
        return;
    PlayerbotAI* botAI = GET_PLAYERBOT_AI(player);
    if (botAI && !botAI->IsRealPlayer())
        return;   // only react to real players

    std::string l = " " + Lower(msg) + " ";
    auto has = [&](std::initializer_list<char const*> words)
    {
        for (char const* w : words)
        {
            std::string pattern = std::string(w);
            size_t pos = l.find(pattern);
            if (pos != std::string::npos && !std::isalpha((unsigned char)l[pos - 1]) && !std::isalpha((unsigned char)l[pos + pattern.size()]))
                return true;
        }
        return false;
    };

    std::string category;
    uint32 replies = 0;
    if (has({ "hi", "hello", "hey", "yo", "sup", "hallo", "hoi", "morning", "evening", "o/", "hiya", "heya", "goedemorgen", "goedenavond" }))
    {
        category = "guild_greet";
        replies = urand(1, 3);
    }
    else if (has({ "thanks", "thx", "ty", "bedankt", "dank" }))
    {
        category = "guild_reply_thanks";
        replies = urand(0, 99) < 70 ? 1 : 0;
    }
    else if (msg.find('?') != std::string::npos)
    {
        category = "guild_reply_question";
        replies = urand(0, 99) < 60 ? 1 : 0;
    }
    else
    {
        category = urand(0, 99) < 70 ? "guild_reply_generic" : "reply";
        replies = urand(0, 99) < 30 ? 1 : 0;
    }

    Player* last = nullptr;
    for (uint32 i = 0; i < replies; ++i)
        if (Player* bot = RandomGuildBot(guild->GetId(), last))
        {
            std::string text = PickText(category, bot, player);
            if (text.empty() && category == "reply")
                text = PickText("guild_reply_generic", bot, player);
            Queue(urand(3000, 12000) + i * urand(2000, 6000), bot, BOTLIFE_CHAT_GUILD, text);
            last = bot;
        }
}

// ---------------------------------------------------------------------------------------------
// world thread

void BotLifeMgr::GuildChatter(uint32 now)
{
    if (now < _nextGuildChat)
        return;
    _nextGuildChat = now + urand(_guildChatInterval * 500, _guildChatInterval * 1500);

    std::set<uint32> guilds;
    for (Player* player : sRandomPlayerbotMgr->GetPlayers())
        if (player && player->IsInWorld() && player->GetGuildId())
            guilds.insert(player->GetGuildId());

    for (uint32 guildId : guilds)
    {
        Player* bot = RandomGuildBot(guildId);
        if (!bot)
            continue;
        uint32 roll = urand(0, 99);
        std::string text = PickText(roll < 55 ? "guild_idle" : (roll < 85 ? "suggest_something" : "suggest_instance"), bot);
        if (!text.empty())
            Queue(0, bot, BOTLIFE_CHAT_GUILD, text);
    }
}

void BotLifeMgr::ZoneChatter(uint32 now)
{
    if (now < _nextZoneChat)
        return;
    _nextZoneChat = now + urand(_zoneChatInterval * 500, _zoneChatInterval * 1500);

    std::set<std::pair<uint32, uint32>> zones;   // map, zone of real players
    for (Player* player : sRandomPlayerbotMgr->GetPlayers())
        if (player && player->IsInWorld())
            zones.insert({ player->GetMapId(), player->GetZoneId() });

    for (auto const& z : zones)
    {
        std::vector<Player*> candidates;
        for (auto it = sRandomPlayerbotMgr->GetPlayerBotsBegin(); it != sRandomPlayerbotMgr->GetPlayerBotsEnd(); ++it)
        {
            Player* bot = it->second;
            if (bot && bot->IsInWorld() && bot->GetMapId() == z.first && bot->GetZoneId() == z.second && !bot->IsBeingTeleported())
                candidates.push_back(bot);
        }
        if (candidates.empty())
            continue;
        Player* bot = candidates[urand(0, candidates.size() - 1)];
        std::string text = PickText(urand(0, 99) < 70 ? "zone_chat" : "suggest_something", bot);
        if (!text.empty())
            Queue(0, bot, BOTLIFE_CHAT_ZONE, text);
    }
}

void BotLifeMgr::WorldUpdate(uint32 diff)
{
    if (!_enabled || !_loaded)
        return;
    _worldTimer += diff;
    if (_worldTimer < 1000)
        return;
    _worldTimer = 0;
    uint32 now = getMSTime();

    // the list of quests the bots keep failing, every twenty minutes
    if (!_nextBadQuestLoad)
        _nextBadQuestLoad = now + 20 * MINUTE * IN_MILLISECONDS;
    else if (now >= _nextBadQuestLoad)
    {
        _nextBadQuestLoad = now + 20 * MINUTE * IN_MILLISECONDS;
        LoadBadQuests();
    }

    if (++_mapPopTimer >= 30)
    {
        _mapPopTimer = 0;
        // bot sessions are not in the world session map: count the players of the continent maps themselves (the maps
        // are idle while the world script update runs)
        static uint32 const continents[6] = { 0, 1, 530, 571, 870, 1064 };
        for (size_t i = 0; i < 6; ++i)
        {
            Map* map = sMapMgr->FindMap(continents[i], 0);
            _mapPop[i].store(map ? map->GetPlayersCountExceptGMs() : 0, std::memory_order_relaxed);
        }
    }

    // to-do 265: role snapshot of the bot characters, every ten minutes
    if (now >= _nextRoleSnap)
    {
        _nextRoleSnap = now + 10 * MINUTE * IN_MILLISECONDS;
        LoadRoleSnapshot();
    }

    // (level-balance) every ten minutes, the first round ten minutes after the start (the bots are logged in by then)
    if (_levelBalance && _levelBalanceMoves)
    {
        if (!_nextLevelBalance)
            _nextLevelBalance = now + 10 * MINUTE * IN_MILLISECONDS;
        else if (now >= _nextLevelBalance)
        {
            _nextLevelBalance = now + 10 * MINUTE * IN_MILLISECONDS;
            BalanceLevels(now);
        }
    }

    std::vector<BotLifePendingChat> due;
    {
        std::lock_guard<std::mutex> guard(_lock);
        for (auto it = _pending.begin(); it != _pending.end();)
        {
            if (now >= it->at)
            {
                due.push_back(std::move(*it));
                it = _pending.erase(it);
            }
            else
                ++it;
        }
        if (_realSocialCooldown.size() > 200)
            _realSocialCooldown.clear();
    }
    for (BotLifePendingChat const& chat : due)
        Deliver(chat);

    if (_chat)
        GuildChatter(now);
    if (_zoneChat)
        ZoneChatter(now);

    if (_auctions && _auctionBattlePets && now >= _nextPetSeed)
    {
        _nextPetSeed = now + 60000;
        SeedBattlePetAuctions();
    }

    if (now >= _nextPartyUpdate)
    {
        _nextPartyUpdate = now + 5000;
        PartyUpdate(now);
        if (_battlegrounds)
            BattlegroundUpdate(now);
    }

    if (now >= _nextGuildUpdate)
    {
        _nextGuildUpdate = now + 15000;
        GuildUpdate(now);
    }
    if (_lfgFill && now >= _nextLfgUpdate)
    {
        _nextLfgUpdate = now + 10000;
        LfgUpdate(now);
    }
    ProcessTownBusiness();

    if (_guildEvents && now >= _nextCalendar)
    {
        _nextCalendar = now + 60000;
        UpdateCalendar();
    }
}

// ---------------------------------------------------------------------------------------------
// guild calendar events

void BotLifeMgr::UpdateCalendar()
{
    time_t nowT = time(nullptr);
    std::vector<CalendarEvent*> events(sCalendarMgr->GetEvents().begin(), sCalendarMgr->GetEvents().end());
    for (CalendarEvent* ev : events)
    {
        if (!ev || !ev->IsGuildEvent() || !ev->GetGuildId())
            continue;
        time_t eventTime = ev->GetEventTime();
        if (eventTime + HOUR < nowT)
            continue;
        uint32 guildId = uint32(ev->GetGuildId());
        uint64 eventId = ev->GetEventId();

        if (ev->IsGuildAnnouncement())
        {
            if (_seenAnnouncements.insert(eventId).second && _chat)
            {
                uint32 count = urand(2, 4);
                Player* last = nullptr;
                for (uint32 i = 0; i < count; ++i)
                    if (Player* bot = RandomGuildBot(guildId, last))
                    {
                        Queue(urand(10000, 60000), bot, BOTLIFE_CHAT_GUILD, PickText("announcement_react", bot));
                        last = bot;
                    }
            }
            continue;
        }

        // who is signed up already
        std::unordered_set<uint64> invited;
        std::vector<ObjectGuid> signedBots;
        uint32 botInvites = 0;
        for (CalendarInvite const* invite : sCalendarMgr->GetEventInvites(eventId))
        {
            ObjectGuid guid = ObjectGuid(uint64(invite->GetInviteeGUID()));
            invited.insert(uint64(guid));
            if (!sRandomPlayerbotMgr->IsRandomBot(guid.GetCounter()))
                continue;
            ++botInvites;
            CalendarInviteStatus status = invite->GetStatus();
            if (status == CALENDAR_STATUS_SIGNED_UP || status == CALENDAR_STATUS_ACCEPTED || status == CALENDAR_STATUS_CONFIRMED
                || status == CALENDAR_STATUS_TENTATIVE)
                signedBots.push_back(guid);
        }

        // sign up a few bots per minute until the target is reached
        if (eventTime > nowT && botInvites < _calendarSignups)
        {
            Player* creator = ObjectAccessor::FindConnectedPlayer(ev->GetCreatorGUID());
            uint32 nearLevel = creator ? creator->GetLevel() : 0;
            uint32 toAdd = std::min<uint32>(urand(1, 3), _calendarSignups - botInvites);
            for (uint32 i = 0; i < toAdd; ++i)
            {
                Player* bot = RandomGuildBot(guildId, nullptr, nearLevel);
                if (!bot || invited.count(uint64(bot->GetGUID())))
                    continue;
                CalendarInviteStatus status = urand(0, 99) < 85 ? CALENDAR_STATUS_SIGNED_UP : CALENDAR_STATUS_TENTATIVE;
                CalendarInvite* invite = new CalendarInvite(sCalendarMgr->GetFreeInviteId(), eventId, uint64(bot->GetGUID()),
                    uint64(bot->GetGUID()), nowT, status, CALENDAR_RANK_PLAYER, "");
                sCalendarMgr->AddInvite(ev, invite);
                invited.insert(uint64(bot->GetGUID()));
                if (_debug)
                    TC_LOG_INFO("playerbots", "BotLife: {} signed up for guild event {}", bot->GetName(), eventId);
            }
        }

        // event starts: signed up bots join the organizer
        if (nowT >= eventTime && nowT < eventTime + 30 * MINUTE && !_startedEvents.count(eventId))
        {
            Player* creator = ObjectAccessor::FindConnectedPlayer(ev->GetCreatorGUID());
            if (!creator || !creator->IsInWorld())
                continue;
            PlayerbotAI* creatorAI = GET_PLAYERBOT_AI(creator);
            if (creatorAI && !creatorAI->IsRealPlayer())
                continue;
            _startedEvents.insert(eventId);
            StartGuildEvent(creator, eventId, signedBots);
        }
    }
}

void BotLifeMgr::StartGuildEvent(Player* creator, uint64 eventId, std::vector<ObjectGuid> const& signedUp)
{
    Group* group = creator->GetGroup();
    if (!group)
    {
        group = new Group();
        if (!group->Create(creator))
        {
            delete group;
            return;
        }
        sGroupMgr->AddGroup(group);
    }

    uint32 added = 0;
    for (ObjectGuid const& guid : signedUp)
    {
        if (added >= _eventRaidSize)
            break;
        Player* bot = ObjectAccessor::FindConnectedPlayer(guid);
        if (!bot || !bot->IsInWorld() || bot->GetGroup() || !bot->IsAlive() || bot->InBattleground() || bot->IsBeingTeleported())
            continue;
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI)
            continue;
        if (!group->isRaidGroup() && group->GetMembersCount() >= 5)
            group->ConvertToRaid();
        if (group->IsFull() || !group->AddMember(bot))
            continue;

        botAI->SetMaster(creator);
        botAI->ResetStrategies();
        botAI->ChangeStrategy("+follow", BOT_STATE_NON_COMBAT);
        QueueReset(bot);
        QueueTeleport(bot, creator->GetMapId(), creator->GetPositionX() + frand(-3.0f, 3.0f), creator->GetPositionY() + frand(-3.0f, 3.0f),
            creator->GetPositionZ() + 0.5f, creator->GetOrientation());
        ++added;
        if (_chat && added <= 2)
            Queue(urand(2000, 7000), bot, BOTLIFE_CHAT_GUILD, PickText("event_start", bot, creator));
    }

    ChatHandler(creator->GetSession()).PSendSysMessage("Guild event: %u bots joined your group.", added);
    TC_LOG_INFO("playerbots", "BotLife: guild event {} started by {}, {} bots joined", eventId, creator->GetName(), added);
}
