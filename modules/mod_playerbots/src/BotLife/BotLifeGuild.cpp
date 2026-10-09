/*
 * BotLife guild life. Everything here runs on the world thread (BotLifeMgr::WorldUpdate):
 * guilds, the guild bank and the faction choice touch shared objects that map threads must not race on.
 *  - unaligned pandaren bots (level 10+) join the faction that has fewer bots
 *  - bot guilds per faction, each led by a bot; unguilded random bots join the smallest guild of their faction
 *  - guild bank business on town visits: crafting materials and a share of the bot's gold go to the guild bank
 */

#include "BotLife.h"

#include "AuctionHousePackets.h"
#include "AuctionHouseMgr.h"
#include "Chat.h"
#include "DatabaseEnv.h"
#include "GameTime.h"
#include "Config.h"
#include "Guild.h"
#include "GuildMgr.h"
#include "CharacterCache.h"
#include "Item.h"
#include "Log.h"
#include "Mail.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "Playerbots.h"
#include "RandomPlayerbotMgr.h"
#include "WorldPacket.h"
#include "WorldSession.h"

#include <algorithm>
#include <cmath>
#include <unordered_map>
#include <unordered_set>
#include <sstream>

namespace
{
    char const* const DefaultAllianceGuilds = "Lions of Northshire,Deepforge Brotherhood,Moonwell Sentinels,Tidewatch Company,"
        "Gilneas Nightwatch,Exodar Lightbearers,Gnomeregan Sprocketeers,Westfall Irregulars";
    char const* const DefaultHordeGuilds = "Bloodhoof Striders,Darkspear Tidecallers,Sunstrider Embers,Warsong Outriders,"
        "Forsaken Deathwatch,Bilgewater Brokers,Thunderhorn Clan,Ashenvale Reavers";

    uint8 const GuildTabMaterials = 0;
    uint8 const GuildTabSupplies = 1;
    uint32 const GuildRankRightsMember = 67;     // guild chat listen/speak, as the default ranks have
    uint8 const GuildTabEquipment = 2;
    uint8 const GuildTabTreasures = 3;
    // tabs 5 and 6 are not used: gems and enchanting materials, recipes and glyphs
    uint8 const GuildTabGems = 4;
    uint8 const GuildTabRecipes = 5;
    // a seventh tab the bankers may use: herbs and cooking ingredients, out of the materials tab.
    // The bankers buy up to BotBuyTabs tabs with gold; a seventh is used when the guild has one.
    uint8 const GuildTabHerbs = 6;
    uint8 const BotGuildTabs = 7;
    uint8 const BotBuyTabs = 6;
    uint32 const GuildRankBanker = 1;
    uint32 const GuildRankInitiate = 4;

    // what goes where in a bot guild's bank
    enum class BankCategory { None, Material, Supply, Equipment, Treasure, Gem, Recipe, Herb };

    BankCategory Categorize(Item* item)
    {
        ItemTemplate const* proto = item->GetTemplate();
        if (!proto || item->IsSoulBound() || item->IsBoundByEnchant() || !item->CanBeTraded() || proto->StartQuest
            || proto->Bonding == BIND_QUEST || (proto->Flags & ITEM_PROTO_FLAG_CONJURED) || item->GetUInt32Value(ITEM_FIELD_EXPIRATION)
            || proto->Quality > ITEM_QUALITY_EPIC)
            return BankCategory::None;
        switch (proto->Class)
        {
            case ITEM_CLASS_GEM:
                return BankCategory::Gem;
            case ITEM_CLASS_TRADE_GOODS:
                // what jewelcrafters and enchanters work with has its own tab, and so have herbs and cooking ingredients
                if (proto->SubClass == ITEM_SUBCLASS_HERB || proto->SubClass == ITEM_SUBCLASS_MEAT)
                    return BankCategory::Herb;
                return proto->SubClass == ITEM_SUBCLASS_JEWELCRAFTING || proto->SubClass == ITEM_SUBCLASS_ENCHANTING
                    ? BankCategory::Gem : BankCategory::Material;
            case ITEM_CLASS_RECIPE:
            case ITEM_CLASS_GLYPH:
                return BankCategory::Recipe;
            case ITEM_CLASS_CONSUMABLE:
                // elixirs, flasks, scrolls, enchantments; potions, food and bandages the bot uses itself
                switch (proto->SubClass)
                {
                    case ITEM_SUBCLASS_ELIXIR:
                    case ITEM_SUBCLASS_FLASK:
                    case ITEM_SUBCLASS_SCROLL:
                    case ITEM_SUBCLASS_ITEM_ENHANCEMENT:
                        return BankCategory::Supply;
                    default:
                        return BankCategory::None;
                }
            case ITEM_CLASS_CONTAINER:   // spare bags (the equipped ones are not in the inventory slots)
                // only bags worth having - the supplies tabs were full of six slot pouches, and the
                // banker's own bags full of the ones it took out again
                return item->IsNotEmptyBag() || proto->ContainerSlots < 16 ? BankCategory::None : BankCategory::Supply;
            case ITEM_CLASS_WEAPON:
            case ITEM_CLASS_ARMOR:
                // uncommon (green) items are no longer put in the guild bank, only
                // blue and higher; green goes out through the existing auction posting logic (BotLifeAuction.cpp).
                if (proto->Quality < ITEM_QUALITY_RARE)
                    return BankCategory::None;
                // 
                return proto->Quality == ITEM_QUALITY_RARE ? BankCategory::Equipment : BankCategory::Treasure;
            default:
                return BankCategory::None;
        }
    }

    // the tab of a category; a guild that has not bought the later tabs yet keeps those things in an earlier one
    uint8 TabFor(BankCategory category, uint8 tabs)
    {
        switch (category)
        {
            case BankCategory::Supply: return GuildTabSupplies;
            case BankCategory::Equipment: return GuildTabEquipment;
            case BankCategory::Treasure: return GuildTabTreasures;
            case BankCategory::Gem: return tabs > GuildTabGems ? GuildTabGems : GuildTabMaterials;
            case BankCategory::Recipe: return tabs > GuildTabRecipes ? GuildTabRecipes : GuildTabSupplies;
            case BankCategory::Herb: return tabs > GuildTabHerbs ? GuildTabHerbs : GuildTabMaterials;
            default: return GuildTabMaterials;
        }
    }

    struct TabStats
    {
        uint32 free = 0;
        std::unordered_map<uint32, uint32> stacks;   // entry -> stacks in the tab
    };

    TabStats GetTabStats(Guild* guild, uint8 tab)
    {
        TabStats s;
        for (uint8 slot = 0; slot < GUILD_BANK_MAX_SLOTS; ++slot)
            if (Item* item = guild->GetBankItem(tab, slot))
                ++s.stacks[item->GetEntry()];
            else
                ++s.free;
        return s;
    }

    uint32 FreeBagSlots(Player* bot)
    {
        uint32 free = 0;
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
            if (!bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
                ++free;
        for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
            if (Bag* container = bot->GetBagByPos(bag))
                free += container->GetFreeSlots();
        return free;
    }

    std::vector<std::string> SplitNames(std::string const& list)
    {
        std::vector<std::string> names;
        std::stringstream ss(list);
        std::string name;
        while (std::getline(ss, name, ','))
        {
            name.erase(0, name.find_first_not_of(' '));
            name.erase(name.find_last_not_of(' ') + 1);
            if (!name.empty())
                names.push_back(name);
        }
        return names;
    }

    // crafting materials a bot has no use for: trade goods and gems that are not bound
    bool IsGuildBankMaterial(Item* item)
    {
        ItemTemplate const* proto = item->GetTemplate();
        if (!proto || item->IsSoulBound() || item->IsBoundByEnchant() || proto->StartQuest || proto->Bonding == BIND_QUEST)
            return false;
        if (proto->Quality > ITEM_QUALITY_EPIC)
            return false;
        return proto->Class == ITEM_CLASS_TRADE_GOODS || proto->Class == ITEM_CLASS_GEM;
    }
}

void BotLifeMgr::LoadGuildConfig()
{
    _botGuilds = sConfigMgr->GetBoolDefault("BotLife.Guilds", true);
    _pandarenFaction = sConfigMgr->GetBoolDefault("BotLife.PandarenFaction", true);
    _pandarenIsle = sConfigMgr->GetBoolDefault("BotLife.PandarenIsle", true);
    _guildBank = sConfigMgr->GetBoolDefault("BotLife.GuildBank", true);
    _guildBankers = sConfigMgr->GetBoolDefault("BotLife.GuildBankers", true);
    _lfgFill = sConfigMgr->GetBoolDefault("BotLife.LfgFill", true);
    _lfgDelaySeconds = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.LfgFillDelay", 20)));
    _guildSize = uint32(std::max(20, sConfigMgr->GetIntDefault("BotLife.GuildSize", 160)));
    _guildShare = uint32(std::min(100, std::max(0, sConfigMgr->GetIntDefault("BotLife.GuildShare", 80))));
    _guildJoinLevel = uint32(std::max(1, sConfigMgr->GetIntDefault("BotLife.GuildJoinLevel", 10)));
    _guildFoundLevel = uint32(std::max(1, sConfigMgr->GetIntDefault("BotLife.GuildFoundLevel", 30)));
    _extraGuildSize = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.ExtraBotGuildSize", 175)));
    _guildBankGoldPct = uint32(std::min(100, std::max(0, sConfigMgr->GetIntDefault("BotLife.GuildBankGoldPct", 5))));
    _guildBankGoldCap = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.GuildBankGoldCap", 20)));
    _guildBankFreeSlots = uint32(std::min(90, std::max(4, sConfigMgr->GetIntDefault("BotLife.GuildBankFreeSlots", 30))));
    _guildRepair = sConfigMgr->GetBoolDefault("BotLife.GuildRepair", true);
    _guildRepairGold = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.GuildRepairGold", 25)));
    _guildRepairMinBank = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.GuildRepairMinBank", 2000)));
    _guildNames[0] = SplitNames(sConfigMgr->GetStringDefault("BotLife.GuildNamesAlliance", DefaultAllianceGuilds));
    _guildNames[1] = SplitNames(sConfigMgr->GetStringDefault("BotLife.GuildNamesHorde", DefaultHordeGuilds));
    _extraBotGuilds = SplitNames(sConfigMgr->GetStringDefault("BotLife.ExtraBotGuilds", "Lanterns of the Lost"));
}

void BotLifeMgr::GuildUpdate(uint32 now)
{
    std::vector<Player*> bots;
    uint32 teamCount[2] = { 0, 0 };   // alliance, horde
    for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
    {
        Player* bot = pair.second;
        if (!bot || !bot->IsInWorld() || !bot->GetSession())
            continue;
        bots.push_back(bot);
        if (bot->GetRace() != RACE_PANDAREN_NEUTRAL)
            ++teamCount[bot->GetTeam() == HORDE ? 1 : 0];
    }
    std::shuffle(bots.begin(), bots.end(), RandomEngine::Instance());

    if (_pandarenFaction)
        PandarenFactionChoice(bots, teamCount);
    if (_botGuilds)
        ManageBotGuilds(bots, now);
}

void BotLifeMgr::PandarenFactionChoice(std::vector<Player*> const& bots, uint32 (&teamCount)[2])
{
    uint32 done = 0;
    for (Player* bot : bots)
    {
        if (done >= 5)
            break;
        // 
        if (bot->GetRace() != RACE_PANDAREN_NEUTRAL || !bot->IsAlive() || bot->IsInCombat()
            || bot->IsBeingTeleported() || bot->IsInFlight() || bot->InBattleground() || bot->GetGroup() || bot->GetMap()->Instanceable())
            continue;
        // first the quests of the Wandering Isle, the choice comes at level 10
        if (_pandarenIsle && bot->GetMapId() == 860 && bot->GetLevel() < 10)
            continue;

        // the same handler the client's faction choice dialog uses (race, faction, capital, hearth, languages)
        bool horde = teamCount[1] < teamCount[0];
        WorldPacket packet(CMSG_SELECT_FACTION, 4);
        packet << uint32(horde ? 0 /*JOIN_THE_HORDE*/ : 1 /*JOIN_THE_ALLIANCE*/);
        bot->GetSession()->HandleSelectFactionOpcode(packet);
        if (bot->GetRace() == RACE_PANDAREN_NEUTRAL)
            continue;
        ++teamCount[horde ? 1 : 0];
        ++done;
        Count(BLC_PANDAREN_FACTION);
        TC_LOG_INFO("playerbots", "BotLife: pandaren {} (lvl {}) joined the {}", bot->GetName(), uint32(bot->GetLevel()), horde ? "Horde" : "Alliance");
    }
}

bool BotLifeMgr::IsBotGuild(Guild const* guild) const
{
    for (uint8 team = 0; team < 2; ++team)
        for (std::string const& name : _guildNames[team])
            if (guild->GetName() == name)
                return true;
    for (std::string const& name : _extraBotGuilds)   // e.g. "Lanterns of the Lost" gets full tab/banker treatment too
        if (guild->GetName() == name)
            return true;
    return false;
}

void BotLifeMgr::ManageBotGuilds(std::vector<Player*> const& bots, uint32 /*now*/)
{
    struct BotGuild { Guild* guild; uint32 members; uint32 cap; };
    std::vector<BotGuild> guilds[2];
    std::vector<std::string> missing[2];
    for (uint8 team = 0; team < 2; ++team)
        for (std::string const& name : _guildNames[team])
        {
            if (Guild* guild = sGuildMgr->GetGuildByName(name))
                guilds[team].push_back({ guild, uint32(guild->GetMembersCount()), _guildSize });
            else
                missing[team].push_back(name);
        }
    // a player's guild from BotLife.ExtraBotGuilds takes bots of its faction too, up to its own cap
    if (_extraGuildSize)
        for (std::string const& name : _extraBotGuilds)
            if (Guild* guild = sGuildMgr->GetGuildByName(name))
                if (CharacterCacheEntry const* leader = sCharacterCache->GetCharacterCacheByGuid(guild->GetLeaderGUID()))
                    guilds[Player::TeamForRace(leader->Race) == HORDE ? 1 : 0].push_back(
                        { guild, uint32(guild->GetMembersCount()), _extraGuildSize });

    auto usable = [](Player* bot)
    {
        return bot->IsAlive() && !bot->IsInCombat() && !bot->IsBeingTeleported() && !bot->InBattleground()
            && !bot->GetMap()->Instanceable() && bot->GetRace() != RACE_PANDAREN_NEUTRAL;
    };

    // found one missing guild per update, led by a bot of that faction
    for (uint8 team = 0; team < 2; ++team)
    {
        if (missing[team].empty())
            continue;
        Player* leader = nullptr;
        for (Player* bot : bots)
            if (!bot->GetGuildId() && bot->GetLevel() >= _guildFoundLevel && (bot->GetTeam() == HORDE) == (team == 1) && usable(bot)
                && bot->GetGUID().GetCounter() % 100 < _guildShare)
            {
                leader = bot;
                break;
            }
        if (!leader)
            continue;

        Guild* guild = new Guild();
        if (!guild->Create(leader, missing[team].front()))
        {
            TC_LOG_ERROR("playerbots", "BotLife: could not create guild '{}' for {}", missing[team].front(), leader->GetName());
            delete guild;
            continue;
        }
        sGuildMgr->AddGuild(guild);
        SetupBotGuild(guild, leader);
        guilds[team].push_back({ guild, uint32(guild->GetMembersCount()), _guildSize });
        Count(BLC_GUILD_CREATED);
        TC_LOG_INFO("playerbots", "BotLife: guild '{}' founded by {} (lvl {}, {})", guild->GetName(), leader->GetName(),
            uint32(leader->GetLevel()), team ? "Horde" : "Alliance");
        break;
    }

    // unguilded bots join the smallest guild of their faction (a few per update, each join writes to the DB)
    uint32 added = 0;
    for (Player* bot : bots)
    {
        if (added >= 15)
            break;
        if (bot->GetGuildId() || bot->GetLevel() < _guildJoinLevel || !usable(bot) || bot->GetGUID().GetCounter() % 100 >= _guildShare)
            continue;
        uint8 team = bot->GetTeam() == HORDE ? 1 : 0;
        BotGuild* best = nullptr;
        for (BotGuild& g : guilds[team])
            if (g.members < g.cap && (!best || g.members < best->members))
                best = &g;
        if (!best)
            continue;
        if (best->guild->AddMember(bot->GetGUID()))
        {
            ++best->members;
            ++added;
            Count(BLC_GUILD_JOIN);
        }
    }

    if (_guildBankers && _guildBank)
        ManageGuildBankers(bots);
}

void BotLifeMgr::SetupBotGuild(Guild* guild, Player* leader)
{
    WorldSession* session = leader->GetSession();

    // two bank tabs, paid by the guild master like a player would
    static uint32 const tabPrice[2] = { 100, 250 };
    for (uint8 tab = guild->GetPurchasedTabsSize(); tab < 2; ++tab)
    {
        leader->ModifyMoney(int64(tabPrice[tab]) * GOLD);
        guild->HandleBuyBankTab(session, tab);
    }
    guild->HandleSetBankTabInfo(session, GuildTabMaterials, "Materials", "INV_Fabric_Silk_02");
    guild->HandleSetBankTabInfo(session, GuildTabSupplies, "Supplies", "INV_Misc_Bag_10");

    // members and initiates may put items in both tabs and take 5 stacks a day from the supplies
    GuildBankRightsAndSlotsVec rights;
    rights.push_back(GuildBankRightsAndSlots(GuildTabMaterials, GUILD_BANK_RIGHT_DEPOSIT_ITEM, 0));
    rights.push_back(GuildBankRightsAndSlots(GuildTabSupplies, GUILD_BANK_RIGHT_DEPOSIT_ITEM, 5));
    guild->HandleSetRankInfo(session, 3, "Member", GuildRankRightsMember, 0, rights);
    guild->HandleSetRankInfo(session, 4, "Initiate", GuildRankRightsMember, 0, rights);
    guild->HandleSetMOTD(session, "Welcome! Spare materials go to the guild bank.");
}

// a guild member repairs on the guild's account, as a player with the repair right does at the
// vendor - the Guild Repairs achievements never moved because the bots paid everything themselves. World thread (the
// bank is shared by all maps). The bot pays the vendor and the guild pays it back in one withdrawal: one transaction
// instead of one for every item. What the day's allowance does not cover stays the bot's own cost.
void BotLifeMgr::RepairInTown(Player* bot)
{
    uint64 const before = bot->GetMoney();
    bot->DurabilityRepairAll(true, 1.0f, false);
    uint64 const paid = before > bot->GetMoney() ? before - bot->GetMoney() : 0;
    if (!paid)
        return;
    Count(BLC_REPAIR);
    if (!_guildRepair || !bot->GetGuildId())
        return;
    Guild* guild = sGuildMgr->GetGuildById(bot->GetGuildId());
    if (!guild || !IsBotGuild(guild) || guild->GetBankMoney() < uint64(_guildRepairMinBank) * GOLD + paid)
        return;
    if (guild->HandleMemberWithdrawMoney(bot->GetSession(), paid, true))
    {
        bot->ModifyMoney(int64(paid));
        Count(BLC_GUILD_REPAIR);
    }
}

void BotLifeMgr::QueueTownBusiness(ObjectGuid guid)
{
    std::lock_guard<std::mutex> guard(_businessLock);
    if (_townBusiness.size() < 1000)
        _townBusiness.push_back(guid);
}

void BotLifeMgr::QueueCraftSupply(ObjectGuid guid)
{
    std::lock_guard<std::mutex> guard(_businessLock);
    if (_craftSupply.size() < 1000)
        _craftSupply.push_back(guid);
}

void BotLifeMgr::ProcessTownBusiness()
{
    // crafters fetch reagents from the materials tab before they craft
    {
        std::vector<ObjectGuid> supply;
        {
            std::lock_guard<std::mutex> guard(_businessLock);
            supply.swap(_craftSupply);
        }
        for (ObjectGuid const& guid : supply)
            if (Player* bot = ObjectAccessor::FindPlayer(guid))
                if (bot->IsInWorld() && bot->IsAlive() && !bot->IsInCombat() && bot->GetSession())
                    CraftSupply(bot);
    }

    std::vector<ObjectGuid> queue;
    {
        std::lock_guard<std::mutex> guard(_businessLock);
        uint32 n = std::min<uint32>(20, uint32(_townBusiness.size()));
        queue.assign(_townBusiness.begin(), _townBusiness.begin() + n);
        _townBusiness.erase(_townBusiness.begin(), _townBusiness.begin() + n);
    }
    for (ObjectGuid const& guid : queue)
    {
        Player* bot = ObjectAccessor::FindPlayer(guid);
        if (!bot || !bot->IsInWorld() || !bot->IsAlive() || bot->IsInCombat() || !bot->GetSession())
            continue;
        CollectMailMoney(bot);   // auction gold waits in the mailbox
        if (_guildBank && bot->GetGuildId())
        {
            RepairInTown(bot);
            GuildBankBusiness(bot);
        }
        if (_auctions)
            AuctionBusiness(bot);
        VendorGear(bot);   // empty, grey and white armor slots from a vendor
        DeathKnightWeapon(bot);   // Runed Soulblade + runeforging
    }

    // guild bankers at the vault / auctioneer / mailbox
    std::vector<std::pair<ObjectGuid, uint8>> bankers;
    {
        std::lock_guard<std::mutex> guard(_businessLock);
        bankers.swap(_bankerBusiness);
    }
    for (auto const& job : bankers)
    {
        Player* bot = ObjectAccessor::FindPlayer(job.first);
        if (!bot || !bot->IsInWorld() || !bot->IsAlive() || bot->IsInCombat() || !bot->GetSession())
            continue;
        BankerBusiness(bot, job.second);
    }
}

void BotLifeMgr::GuildBankBusiness(Player* bot)
{
    Guild* guild = sGuildMgr->GetGuildById(bot->GetGuildId());
    if (!guild || !guild->GetPurchasedTabsSize())
        return;

    // gold: the bot keeps what it needs for repairs and training, a small share of the rest goes to the guild
    uint64 keep = uint64(bot->GetLevel()) * bot->GetLevel() * 600;
    uint64 money = bot->GetMoney();
    if (money > keep && _guildBankGoldPct)
    {
        uint64 amount = std::min<uint64>((money - keep) * _guildBankGoldPct / 100, uint64(bot->GetLevel()) * _guildBankGoldCap * SILVER);
        if (amount >= 10 * SILVER && bot->HasEnoughMoney(amount))
        {
            guild->HandleMemberDepositMoney(bot->GetSession(), amount);
            Count(BLC_GBANK_GOLD);
        }
    }

    // items by tab. Bot guilds: materials, supplies, green equipment, rare/epic treasures; the bot weighs
    // bank against auction house (three stacks of one item are enough for the bank, greens sell unless the bot's
    // auctions are at the cap, epics are kept). Other guilds (a real player's): only materials in the first tab.
    bool botGuild = IsBotGuild(guild);
    uint8 tabs = std::min<uint8>(guild->GetPurchasedTabsSize(), BotGuildTabs);
    TabStats stats[BotGuildTabs];
    for (uint8 tab = 0; tab < tabs; ++tab)
        stats[tab] = GetTabStats(guild, tab);

    int32 ownAuctions = -1;   // counted on first need
    auto auctionsFull = [&]()
    {
        if (ownAuctions < 0)
        {
            ownAuctions = 0;
            if (AuctionHouseObject* house = sAuctionMgr->GetAuctionsMap(bot->GetFaction()))
                for (auto itr = house->GetAuctionsBegin(); itr != house->GetAuctionsEnd(); ++itr)
                    if (itr->second->owner == bot->GetGUID())
                        ++ownAuctions;
        }
        return !_auctions || uint32(ownAuctions) + 2 >= _auctionMaxPerBot;
    };

    // the banker could not keep up: at most 3 stacks per visit and 24 deposits per guild per
    // 10 minutes (world thread only, no lock needed); the rest goes to the auction house
    uint32 now = getMSTime();
    auto& rate = _guildDepositRate[guild->GetId()];
    if (getMSTimeDiff(rate.first, now) > 10 * MINUTE * IN_MILLISECONDS)
        rate = { now, 0 };
    uint32 stacks = 0;
    auto deposit = [&](uint8 bag, uint8 slot, Item* item)
    {
        if (stacks >= 3 || rate.second >= 24 || !item)
            return;
        BankCategory category = botGuild ? Categorize(item) : (IsGuildBankMaterial(item) ? BankCategory::Material : BankCategory::None);
        if (category == BankCategory::None)
            return;
        uint8 tab = TabFor(category, tabs);
        if (tab >= tabs)
            return;
        TabStats& s = stats[tab];
        uint32 entry = item->GetEntry();
        uint32 quality = item->GetTemplate()->Quality;
        uint32 have = s.stacks.count(entry) ? s.stacks[entry] : 0;
        if (!s.free && (!have || item->GetMaxStackCount() <= 1))
            return;
        if (botGuild)
            switch (category)
            {
                case BankCategory::Material:
                case BankCategory::Supply:
                case BankCategory::Gem:
                case BankCategory::Herb:
                    // plenty in the bank / the tab is at its fill target (1-10: BotLife.GuildBankFreeSlots,
                    // was a fixed 10 - the tabs sat at 86-98 of 98 for good): auction house
                    if (have >= 3 || s.free <= (have ? _guildBankFreeSlots / 2 : _guildBankFreeSlots))
                        return;
                    break;
                case BankCategory::Recipe:
                    // one of each is enough for the guild, the rest goes to the auction house
                    if (have >= 1 || s.free <= _guildBankFreeSlots)
                        return;
                    break;
                case BankCategory::Equipment:
                    if (s.free <= 10 || (!auctionsFull() && urand(0, 99) >= 25))
                        return;
                    break;
                case BankCategory::Treasure:
                    if (quality < ITEM_QUALITY_EPIC && (s.free <= 10 || urand(0, 99) >= 60))
                        return;
                    break;
                default:
                    return;
            }
        guild->SwapItemsWithInventory(bot, false, tab, NULL_SLOT, bag, slot, 0);
        if (bot->GetItemByPos(bag, slot) == item)   // bank full or no rights: stays in the bag
            return;
        ++stacks;
        ++rate.second;
        if (!have && s.free)
            --s.free;
        ++s.stacks[entry];
        switch (category)
        {
            case BankCategory::Supply: Count(BLC_GBANK_SUPPLY); break;
            case BankCategory::Equipment: Count(BLC_GBANK_EQUIP); break;
            case BankCategory::Treasure: Count(BLC_GBANK_TREASURE); break;
            default: Count(BLC_GBANK_ITEM); break;
        }
    };
    for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        deposit(INVENTORY_SLOT_BAG_0, slot, bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot));
    for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
        if (Bag* container = bot->GetBagByPos(bag))
            for (uint32 slot = 0; slot < container->GetBagSize(); ++slot)
                deposit(bag, uint8(slot), container->GetItemByPos(uint8(slot)));
}

// ---------------------------------------------------------------------------------------------
// guild bankers. One low level member per bot guild gets the "Banker" rank and lives in the faction capital:
// guild vault (layout, next tab, gold in, surplus out) - auctioneer (sells the surplus) - mailbox (auction gold).
// The world thread picks the bankers and does the business; the map thread only walks the banker around.

void BotLifeMgr::LoadBankerSpots()
{
    struct Capital { uint32 map; uint32 zone; };
    static Capital const capitals[2] = { { 0, 1519 }, { 1, 1637 } };   // Stormwind, Orgrimmar
    for (uint8 team = 0; team < 2; ++team)
    {
        std::vector<BankerSpot> vaults, mailboxes, auctioneers;
        if (QueryResult result = WorldDatabase.PQuery("SELECT g.position_x, g.position_y, g.position_z, t.type FROM gameobject g "
            "JOIN gameobject_template t ON t.entry = g.id WHERE g.map = {} AND g.zoneId = {} AND t.type IN ({}, {})",
            capitals[team].map, capitals[team].zone, uint32(GAMEOBJECT_TYPE_GUILD_BANK), uint32(GAMEOBJECT_TYPE_MAILBOX)))
        {
            do
            {
                Field* fields = result->Fetch();
                BankerSpot spot;
                spot.map = capitals[team].map;
                spot.x = fields[0].GetFloat();
                spot.y = fields[1].GetFloat();
                spot.z = fields[2].GetFloat();
                (fields[3].GetUInt8() == GAMEOBJECT_TYPE_GUILD_BANK ? vaults : mailboxes).push_back(spot);
            } while (result->NextRow());
        }
        for (auto const& cs : _creatureSpawns)
        {
            CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(cs.first);
            if (!ct || !(ct->npcflag & UNIT_NPC_FLAG_AUCTIONEER))
                continue;
            for (BotLifeSpawn const& s : cs.second)
                if (s.map == capitals[team].map && s.zone == capitals[team].zone)
                {
                    BankerSpot spot;
                    spot.map = s.map;
                    spot.x = s.x;
                    spot.y = s.y;
                    spot.z = s.z;
                    auctioneers.push_back(spot);
                }
        }
        auto dist = [](BankerSpot const& a, BankerSpot const& b) { return std::hypot(a.x - b.x, a.y - b.y); };
        auto nearest = [&](std::vector<BankerSpot> const& list, BankerSpot const& from) -> BankerSpot const*
        {
            BankerSpot const* best = nullptr;
            for (BankerSpot const& s : list)
                if (!best || dist(s, from) < dist(*best, from))
                    best = &s;
            return best;
        };
        // the vault with the shortest walk to an auctioneer
        BankerSpot const* vault = nullptr;
        BankerSpot const* auctioneer = nullptr;
        for (BankerSpot const& v : vaults)
            if (BankerSpot const* a = nearest(auctioneers, v))
                if (!vault || dist(v, *a) < dist(*vault, *auctioneer))
                {
                    vault = &v;
                    auctioneer = a;
                }
        BankerSpot const* mailbox = vault ? nearest(mailboxes, *vault) : nullptr;
        if (!vault || !auctioneer || !mailbox)
        {
            TC_LOG_ERROR("server.loading", "BotLife: no guild vault / auctioneer / mailbox for the {} banker", team ? "Horde" : "Alliance");
            continue;
        }
        _bankerSpots[team][0] = *vault;
        _bankerSpots[team][1] = *auctioneer;
        _bankerSpots[team][2] = *mailbox;
        _bankerSpotsOk[team] = true;
        TC_LOG_INFO("server.loading", ">> BotLife: {} banker route vault ({:.0f} {:.0f}) auctioneer ({:.0f} {:.0f}) mailbox ({:.0f} {:.0f})",
            team ? "Horde" : "Alliance", vault->x, vault->y, auctioneer->x, auctioneer->y, mailbox->x, mailbox->y);
    }
}

bool BotLifeMgr::IsBanker(ObjectGuid guid)
{
    std::lock_guard<std::mutex> guard(_bankerLock);
    return _bankerGuids.count(guid) != 0;
}

void BotLifeMgr::ManageGuildBankers(std::vector<Player*> const& bots)
{
    std::unordered_set<uint32> botGuilds;
    for (uint8 team = 0; team < 2; ++team)
        if (_bankerSpotsOk[team])
            for (std::string const& name : _guildNames[team])
                if (Guild* guild = sGuildMgr->GetGuildByName(name))
                    botGuilds.insert(guild->GetId());
    if (_bankerSpotsOk[0] || _bankerSpotsOk[1])   // extra named guilds get a banker too
        for (std::string const& name : _extraBotGuilds)
            if (Guild* guild = sGuildMgr->GetGuildByName(name))
                botGuilds.insert(guild->GetId());

    // candidates: the lowest level free members per guild; stale bankers (from before a restart) back to initiate
    std::unordered_map<uint32, std::vector<Player*>> best;
    for (Player* bot : bots)
    {
        uint32 guildId = bot->GetGuildId();
        if (!guildId || !botGuilds.count(guildId))
            continue;
        auto current = _guildBanker.find(guildId);
        bool isCurrent = current != _guildBanker.end()
            && std::find(current->second.begin(), current->second.end(), bot->GetGUID()) != current->second.end();
        if (!isCurrent && bot->GetRank() == GuildRankBanker)
            if (Guild* guild = sGuildMgr->GetGuildById(guildId))
                guild->ChangeMemberRank(bot->GetGUID(), GuildRankInitiate);
        if (isCurrent || bot->GetLevel() > 20 || !bot->IsAlive() || bot->GetGroup() || bot->InBattleground() || bot->InBattlegroundQueue()
            || bot->IsBeingTeleported() || bot->GetMap()->Instanceable())
            continue;
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI || botAI->HasRealPlayerMaster())
            continue;
        best[guildId].push_back(bot);
    }

    for (uint32 guildId : botGuilds)
    {
        Guild* guild = sGuildMgr->GetGuildById(guildId);
        if (!guild)
            continue;
        // the bankers scale with the guild - one per 150 members, three at most (a guild of 500
        // filled its bank faster than one banker could sort and sell)
        uint32 const wanted = std::min<uint32>(3, 1 + guild->GetMembersCount() / 150);
        std::vector<ObjectGuid>& bankers = _guildBanker[guildId];
        auto retire = [&](ObjectGuid const& guid)
        {
            guild->ChangeMemberRank(guid, GuildRankInitiate);
            std::lock_guard<std::mutex> guard(_bankerLock);
            _bankerGuids.erase(guid);
        };
        for (auto it = bankers.begin(); it != bankers.end();)
        {
            Player* banker = ObjectAccessor::FindConnectedPlayer(*it);
            if (banker && banker->GetGuildId() == guildId && !banker->GetGroup() && !banker->InBattleground())
            {
                ++it;
                continue;
            }
            retire(*it);   // logged out, left or grouped: an ordinary member again
            it = bankers.erase(it);
        }
        while (bankers.size() > wanted)
        {
            retire(bankers.back());
            bankers.pop_back();
        }
        auto pick = best.find(guildId);
        if (pick == best.end() || bankers.size() >= wanted)
            continue;
        std::sort(pick->second.begin(), pick->second.end(), [](Player* a, Player* b) { return a->GetLevel() < b->GetLevel(); });
        for (Player* banker : pick->second)
        {
            if (bankers.size() >= wanted)
                break;
            if (!guild->ChangeMemberRank(banker->GetGUID(), GuildRankBanker))
                continue;
            bankers.push_back(banker->GetGUID());
            {
                std::lock_guard<std::mutex> guard(_bankerLock);
                _bankerGuids.insert(banker->GetGUID());
            }
            if (banker->GetMoney() < 20 * GOLD)   // purse for auction deposits
                banker->ModifyMoney(int64(20 * GOLD - banker->GetMoney()));
            Count(BLC_BANKER_PICKED);
            TC_LOG_INFO("playerbots", "BotLife: {} (lvl {}) is now banker {} of {} of '{}'", banker->GetName(), uint32(banker->GetLevel()),
                bankers.size(), wanted, guild->GetName());
        }
    }
}

void BotLifeMgr::EnsureGuildBankLayout(Guild* guild, Player* banker)
{
    if (!_guildLayoutDone.count(guild->GetId()))
    {
        _guildLayoutDone.insert(guild->GetId());
        static char const* const names[BotGuildTabs] = { "Materials", "Supplies", "Equipment", "Treasures", "Gems & Enchants", "Recipes & Glyphs",
            "Herbs & Cooking" };   // at most 16 characters (guild_bank_tab.TabName)
        static char const* const icons[BotGuildTabs] = { "INV_Fabric_Silk_02", "INV_Misc_Bag_10", "INV_Sword_04", "INV_Misc_Gem_Diamond_02",
            "INV_Misc_Gem_Variety_01", "INV_Scroll_03", "INV_Misc_Flower_02" };
        uint8 tabs = std::min<uint8>(guild->GetPurchasedTabsSize(), BotGuildTabs);
        GuildBankRightsAndSlotsVec bankerRights, memberRights;
        for (uint8 tab = 0; tab < tabs; ++tab)
        {
            guild->SetBankTabInfoSystem(tab, names[tab], icons[tab]);
            bankerRights.push_back(GuildBankRightsAndSlots(tab, GUILD_BANK_RIGHT_FULL, 1000));
            // everybody may deposit everywhere; supplies may be taken (5 a day), and materials by the crafters
            // 
            memberRights.push_back(GuildBankRightsAndSlots(tab, GUILD_BANK_RIGHT_DEPOSIT_ITEM,
                tab == GuildTabSupplies ? 5 : (tab == GuildTabMaterials || tab == GuildTabGems || tab == GuildTabHerbs) ? 12 : 0));
        }
        guild->SetRankInfoSystem(GuildRankBanker, "Banker", GuildRankRightsMember | GR_RIGHT_WITHDRAW_GOLD | GR_RIGHT_MODIFY_BANK_TAB,
            100000, bankerRights);
        // members repair on the guild's account (BotLife.GuildRepairGold a day, RepairInTown)
        uint32 const memberRankRights = GuildRankRightsMember | (_guildRepair ? uint32(GR_RIGHT_WITHDRAW_REPAIR) : 0u);
        uint32 const repairGold = _guildRepair ? _guildRepairGold : 0;
        guild->SetRankInfoSystem(3, "Member", memberRankRights, repairGold, memberRights);
        guild->SetRankInfoSystem(GuildRankInitiate, "Initiate", memberRankRights, repairGold, memberRights);
    }

    // the next tab when the guild can pay for it: the banker withdraws the price and buys it like a player
    static uint32 const tabPrice[BotBuyTabs] = { 100, 250, 500, 1000, 2500, 5000 };
    uint8 tabs = guild->GetPurchasedTabsSize();
    if (!banker || tabs >= BotBuyTabs)
        return;
    uint64 price = uint64(tabPrice[tabs]) * GOLD;
    if (guild->GetBankMoney() < price + 200 * GOLD || !guild->HandleMemberWithdrawMoney(banker->GetSession(), price))
        return;
    guild->HandleBuyBankTab(banker->GetSession(), tabs);
    if (guild->GetPurchasedTabsSize() > tabs)
    {
        _guildLayoutDone.erase(guild->GetId());   // name and rights for the new tab next visit
        Count(BLC_GBANK_TAB_BOUGHT);
        TC_LOG_INFO("playerbots", "BotLife: guild '{}' bought bank tab {} ({} g)", guild->GetName(), uint32(tabs) + 1, tabPrice[tabs]);
    }
    else if (banker->GetMoney() >= price)   // not bought: the price goes back
        guild->HandleMemberDepositMoney(banker->GetSession(), price);
}

void BotLifeMgr::QueueBankerBusiness(ObjectGuid guid, uint8 step)
{
    std::lock_guard<std::mutex> guard(_businessLock);
    if (_bankerBusiness.size() < 200)
        _bankerBusiness.emplace_back(guid, step);
}

void BotLifeMgr::CollectMailMoney(Player* bot)
{
    // auction sales pay by mail; bots have no client to open the mailbox
    if (!bot->IsMailsLoaded())
        return;
    time_t now = GameTime::GetGameTime();
    uint64 total = 0;
    for (PlayerMails::iterator itr = bot->GetMailBegin(); itr != bot->GetMailEnd(); ++itr)
    {
        Mail* mail = *itr;
        if (mail->state == MAIL_STATE_DELETED || !mail->money || mail->COD || mail->deliver_time > now)
            continue;
        if (!bot->ModifyMoney(int64(mail->money)))
            break;
        total += mail->money;
        mail->money = 0;
        // money only (auction sold): the mail is done; with items it stays
        mail->state = mail->HasItems() ? MAIL_STATE_CHANGED : MAIL_STATE_DELETED;
        bot->m_mailsUpdated = true;
    }
    if (total)
        Count(BLC_MAIL_GOLD);
}

void BotLifeMgr::BankerBusiness(Player* bot, uint8 step)
{
    Guild* guild = sGuildMgr->GetGuildById(bot->GetGuildId());
    if (!guild || !IsBanker(bot->GetGUID()))
        return;

    switch (step)
    {
        case 0:   // guild vault
        {
            EnsureGuildBankLayout(guild, bot);

            // what the auction house did not take: the vendor pays for it (that gold ends in the guild bank too)
            // earlier (16 free, was 8), and nothing may stay behind for good: spare bags were never
            // sold and things without a vendor price never left - the banker of Lanterns of the Lost sat on 56 of 56
            // slots of pouches and could not take anything out of the bank any more. Bound things are the banker's own.
            if (FreeBagSlots(bot) < 16)
            {
                uint64 money = 0;
                auto sell = [&](uint8 bag, uint8 slot, Item* item)
                {
                    if (!item || sAuctionMgr->GetAItem(item->GetGUID().GetCounter()))
                        return;
                    ItemTemplate const* proto = item->GetTemplate();
                    if (!proto || item->IsSoulBound() || item->IsNotEmptyBag() || proto->StartQuest || proto->Bonding == BIND_QUEST
                        || (proto->Class == ITEM_CLASS_QUEST && !proto->SellPrice))
                        return;
                    if (!proto->SellPrice)
                        return;   // no vendor takes it - and never destroy what may be a player's (it is not taken out either)
                    money += uint64(proto->SellPrice) * item->GetCount();
                    bot->DestroyItem(bag, slot, true);
                };
                for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
                    sell(INVENTORY_SLOT_BAG_0, slot, bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot));
                for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
                    if (Bag* container = bot->GetBagByPos(bag))
                        for (uint32 slot = 0; slot < container->GetBagSize(); ++slot)
                            sell(bag, uint8(slot), container->GetItemByPos(uint8(slot)));
                if (money)
                {
                    bot->ModifyMoney(int64(money));
                    Count(BLC_BANKER_VENDOR);
                }
            }

            // gold above the working purse goes to the guild
            uint64 const purse = 50 * GOLD;
            if (bot->GetMoney() > purse + 10 * GOLD)
            {
                guild->HandleMemberDepositMoney(bot->GetSession(), bot->GetMoney() - purse);
                Count(BLC_BANKER_GOLD);
            }

            // surplus out: more than three stacks of one item, or a tab with less than 12 free slots
            // (the most stacked and cheapest first)
            uint32 freeSlots = FreeBagSlots(bot);
            uint32 budget = std::min<uint32>(20, freeSlots > 2 ? freeSlots - 2 : 0);   // was 10
            uint8 tabs = guild->GetPurchasedTabsSize();   // every tab, also ones bought later
            for (uint8 tab = 0; tab < tabs && budget; ++tab)
            {
                TabStats s = GetTabStats(guild, tab);
                // the tabs stay full: the bot tabs are kept at BotLife.GuildBankFreeSlots free
                // (was 12 of 98, which is what the banks sat at); tabs a player bought himself keep the old margin
                uint32 const keepFree = tab < BotGuildTabs ? _guildBankFreeSlots : 12;
                uint32 room = s.free < keepFree ? keepFree - s.free : 0;
                struct Slot { uint8 slot; uint32 entry; uint64 value; };
                std::vector<Slot> slots;
                for (uint8 slot = 0; slot < GUILD_BANK_MAX_SLOTS; ++slot)
                    if (Item* item = guild->GetBankItem(tab, slot))
                        if (item->GetTemplate()->SellPrice)   // what no vendor takes stays in the bank
                            slots.push_back({ slot, item->GetEntry(), uint64(item->GetTemplate()->SellPrice) * item->GetCount() });
                std::sort(slots.begin(), slots.end(), [&](Slot const& a, Slot const& b)
                {
                    uint32 na = s.stacks[a.entry], nb = s.stacks[b.entry];
                    return na != nb ? na > nb : a.value < b.value;
                });
                for (Slot const& entry : slots)
                {
                    if (!budget)
                        break;
                    uint32& count = s.stacks[entry.entry];
                    if (count <= 3 && !room)
                        continue;
                    Item* item = guild->GetBankItem(tab, entry.slot);
                    if (!item)
                        continue;
                    guild->SwapItemsWithInventory(bot, true, tab, entry.slot, NULL_BAG, NULL_SLOT, 0);
                    if (guild->GetBankItem(tab, entry.slot) == item)
                        break;   // bags full or no rights
                    --count;
                    --budget;
                    if (room)
                        --room;
                    Count(BLC_BANKER_WITHDRAW);
                }
            }

            // tabs 5 and 6 stay empty: what lies in the wrong tab moves to the tab of its kind
            // (gems and enchanting materials, recipes and glyphs, rare equipment) - at most 20 a visit
            {
                uint32 resort = 20;
                uint8 const ownTabs = std::min<uint8>(guild->GetPurchasedTabsSize(), BotGuildTabs);
                for (uint8 tab = 0; tab < ownTabs && resort; ++tab)
                    for (uint8 slot = 0; slot < GUILD_BANK_MAX_SLOTS && resort; ++slot)
                    {
                        Item* item = guild->GetBankItem(tab, slot);
                        if (!item)
                            continue;
                        BankCategory const category = Categorize(item);
                        if (category == BankCategory::None)
                            continue;
                        uint8 const wanted = TabFor(category, ownTabs);
                        if (wanted == tab)
                            continue;
                        uint8 freeSlot = GUILD_BANK_MAX_SLOTS;
                        for (uint8 dst = 0; dst < GUILD_BANK_MAX_SLOTS; ++dst)
                            if (!guild->GetBankItem(wanted, dst))
                            {
                                freeSlot = dst;
                                break;
                            }
                        if (freeSlot == GUILD_BANK_MAX_SLOTS)
                            continue;   // that tab is full
                        guild->SwapItems(bot, tab, slot, wanted, freeSlot, 0);
                        if (guild->GetBankItem(tab, slot) == item)
                        {
                            resort = 0;   // refused (rights)
                            break;
                        }
                        --resort;
                        Count(BLC_GBANK_RESORT);
                    }
            }

            // keep the tabs tidy - merge partial stacks, then order every tab by item class,
            // subclass, quality (best first), item level and entry. At most 40 moves per visit (DB writes, bank log).
            uint32 moves = 40;
            for (uint8 tab = 0; tab < guild->GetPurchasedTabsSize() && moves; ++tab)   // every tab, also ones bought later (names of 4+ stay)
            {
                // merge: a partial stack onto an earlier partial stack of the same item
                for (uint8 src = GUILD_BANK_MAX_SLOTS; src-- > 0 && moves;)
                {
                    Item* from = guild->GetBankItem(tab, src);
                    if (!from || from->GetCount() >= from->GetMaxStackCount())
                        continue;
                    for (uint8 dst = 0; dst < src; ++dst)
                    {
                        Item* to = guild->GetBankItem(tab, dst);
                        if (!to || to->GetEntry() != from->GetEntry() || to->GetCount() >= to->GetMaxStackCount())
                            continue;
                        uint32 amount = std::min(from->GetCount(), to->GetMaxStackCount() - to->GetCount());
                        guild->SwapItems(bot, tab, src, tab, dst, amount == from->GetCount() ? 0 : amount);
                        --moves;
                        break;
                    }
                }

                auto before = [](Item const* a, Item const* b)
                {
                    ItemTemplate const* pa = a->GetTemplate();
                    ItemTemplate const* pb = b->GetTemplate();
                    if (pa->Class != pb->Class) return pa->Class < pb->Class;
                    if (pa->SubClass != pb->SubClass) return pa->SubClass < pb->SubClass;
                    if (pa->Quality != pb->Quality) return pa->Quality > pb->Quality;
                    if (pa->ItemLevel != pb->ItemLevel) return pa->ItemLevel > pb->ItemLevel;
                    if (pa->ItemId != pb->ItemId) return pa->ItemId < pb->ItemId;
                    return a->GetCount() > b->GetCount();
                };
                // selection sort over the occupied slots, packed to the front of the tab
                for (uint8 target = 0; target < GUILD_BANK_MAX_SLOTS && moves; ++target)
                {
                    uint8 best = GUILD_BANK_MAX_SLOTS;
                    for (uint8 slot = target; slot < GUILD_BANK_MAX_SLOTS; ++slot)
                        if (Item* item = guild->GetBankItem(tab, slot))
                            if (best == GUILD_BANK_MAX_SLOTS || before(item, guild->GetBankItem(tab, best)))
                                best = slot;
                    if (best == GUILD_BANK_MAX_SLOTS)
                        break;   // the rest of the tab is empty
                    if (best == target)
                        continue;
                    Item* moving = guild->GetBankItem(tab, best);
                    guild->SwapItems(bot, tab, best, tab, target, 0);
                    if (guild->GetBankItem(tab, target) != moving)
                        break;   // refused (rights): leave this tab
                    --moves;
                    Count(BLC_BANKER_SORT);
                }
            }
            break;
        }
        case 1:   // auctioneer
            if (_auctions)
                AuctionBusiness(bot, true);
            break;
        case 2:   // mailbox
            CollectMailMoney(bot);
            break;
        default:
            break;
    }
}

bool BotLifeMgr::BankerUpdate(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    uint8 team = bot->GetTeam() == HORDE ? 1 : 0;
    if (!_bankerSpotsOk[team])
        return false;

    // home: the faction capital's guild vault
    BankerSpot const& vault = _bankerSpots[team][0];
    bool const away = bot->GetMapId() != vault.map || bot->GetExactDist2d(vault.x, vault.y) > 250.0f;
    if (bot->IsBeingTeleported() || bot->IsInFlight() || bot->GetVehicle())
        return false;
    // a banker picked while out in the world (the same low level bot after every restart) waited to be
    // alive and out of combat before going home - and stayed out there for good: 5 of 17 were still in Ashenvale, the
    // Barrens and Darkshore half an hour after a restart, the one of Lanterns of the Lost among them. Away from the
    // vault nothing is worth finishing: up, out of combat and home.
    if (!bot->IsAlive())
    {
        if (!away)
        {
            HandleDeath(bot, t, now);
            return false;
        }
        bot->ResurrectPlayer(1.0f);
        bot->SpawnCorpseBones();
    }
    if (bot->IsInCombat())
    {
        if (!away)
            return false;
        bot->CombatStop(true);
    }
    if (bot->HasUnitState(UNIT_STATE_CASTING))
    {
        if (!away)
            return true;
        bot->CastStop();
    }

    if (away)
    {
        if (now >= t.bankerNextTeleport)
        {
            t.bankerNextTeleport = now + 60000;
            Dismount(bot);
            bot->TeleportTo(vault.map, vault.x, vault.y, vault.z + 0.5f, frand(0.0f, 2 * float(M_PI)));
            t.bankerStep = uint8(bot->GetGUID().GetCounter() % 3);
            t.bankerDestSet = false;
            t.bankerWaitUntil = 0;
            t.hasDest = false;
            Count(BLC_BANKER_HOME);
        }
        return true;
    }

    if (t.bankerWaitUntil)
    {
        if (now < t.bankerWaitUntil)
            return true;
        t.bankerWaitUntil = 0;
        t.bankerStep = uint8((t.bankerStep + 1) % 3);
        t.bankerDestSet = false;
    }

    BankerSpot const& spot = _bankerSpots[team][t.bankerStep];
    if (!t.bankerDestSet)
    {
        float angle = frand(0.0f, 2 * float(M_PI));
        SetDest(t, spot.map, spot.x + std::cos(angle) * 2.5f, spot.y + std::sin(angle) * 2.5f, spot.z, 3.0f);
        t.bankerDestSet = true;
    }
    if (t.hasDest && !Arrived(bot, t))
    {
        Travel(bot, t, now);
        if (!t.hasDest)   // stuck on the way: a short hop
            bot->NearTeleportTo(spot.x, spot.y, spot.z + 0.5f, bot->GetOrientation());
        return true;
    }

    // at the vault / auctioneer / mailbox: business on the world thread, stand there for a moment
    bot->StopMoving();
    Dismount(bot);
    QueueBankerBusiness(bot->GetGUID(), t.bankerStep);
    t.bankerWaitUntil = now + urand(20, 40) * IN_MILLISECONDS;
    if (_emotes && urand(0, 99) < 20)
        bot->HandleEmoteCommand(EMOTE_ONESHOT_TALK);
    return true;
}

void BotLifeMgr::PrintGuilds(ChatHandler* handler)
{
    std::vector<Guild*> list;
    for (uint8 team = 0; team < 2; ++team)
        for (std::string const& name : _guildNames[team])
            if (Guild* guild = sGuildMgr->GetGuildByName(name))
                list.push_back(guild);
    uint32 guilded = 0, bots = 0;
    for (auto const& pair : sRandomPlayerbotMgr->GetAllBots())
        if (Player* bot = pair.second)
        {
            ++bots;
            if (bot->GetGuildId())
                ++guilded;
        }
    std::ostringstream out;
    out << "bot guilds: " << list.size() << "/" << (_guildNames[0].size() + _guildNames[1].size())
        << ", bots in a guild: " << guilded << "/" << bots;
    handler->SendSysMessage(out.str().c_str());
    for (Guild* guild : list)
    {
        std::ostringstream line;
        line << guild->GetName() << ": " << guild->GetMembersCount() << " members, bank "
             << guild->GetBankMoney() / GOLD << "g, tabs " << uint32(guild->GetPurchasedTabsSize());
        handler->SendSysMessage(line.str().c_str());
    }
}
