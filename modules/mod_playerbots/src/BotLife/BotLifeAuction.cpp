/*
 * BotLife auction house business, on the world thread during town visits (the auction houses are shared).
 *  - bots post bind-on-equip green and better items from their bags (whole stacks, priced from the vendor price)
 *  - bots buy an equipment upgrade now and then; the item goes straight into the bot's bags, the seller is paid
 *    by mail exactly like a buyout (so real players' auctions sell to bots too)
 * Mirrors WorldSession::HandleAuctionSellItem / HandleAuctionPlaceBid (buyout branch).
 */

#include "BotLife.h"

#include "AuctionHouseBot.h"
#include "AuctionHousePackets.h"
#include "AuctionHouseMgr.h"
#include "BattlePetMgr.h"
#include "DB2Enums.h"
#include "DB2Stores.h"
#include "Config.h"
#include "DatabaseEnv.h"
#include "GameTime.h"
#include "Group.h"
#include "Item.h"
#include "Log.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "Playerbots.h"
#include "RandomItemManager.h"
#include "World.h"

#include <algorithm>
#include <unordered_set>

namespace
{
    uint32 const BotAuctionMinutes = 24 * 60;

    // best armor type the class wears at this level (cloth 1, leather 2, mail 3, plate 4)
    uint32 PreferredArmor(Player* bot)
    {
        switch (bot->GetClass())
        {
            case CLASS_WARRIOR:
            case CLASS_PALADIN:
                return bot->GetLevel() >= 40 ? ITEM_SUBCLASS_ARMOR_PLATE : ITEM_SUBCLASS_ARMOR_MAIL;
            case CLASS_DEATH_KNIGHT:
                return ITEM_SUBCLASS_ARMOR_PLATE;
            case CLASS_HUNTER:
            case CLASS_SHAMAN:
                return bot->GetLevel() >= 40 ? ITEM_SUBCLASS_ARMOR_MAIL : ITEM_SUBCLASS_ARMOR_LEATHER;
            case CLASS_ROGUE:
            case CLASS_DRUID:
            case CLASS_MONK:
                return ITEM_SUBCLASS_ARMOR_LEATHER;
            default:
                return ITEM_SUBCLASS_ARMOR_CLOTH;
        }
    }

    // gathered materials (herbs, ore, bars, leather, cloth ...): whole stacks of common quality and better
    bool IsMaterial(Item* item)
    {
        ItemTemplate const* proto = item->GetTemplate();
        return proto && proto->Class == ITEM_CLASS_TRADE_GOODS && proto->Quality >= ITEM_QUALITY_NORMAL
            && proto->Quality <= ITEM_QUALITY_EPIC && proto->SellPrice && !item->IsSoulBound() && item->CanBeTraded()
            && !proto->StartQuest && proto->Bonding != BIND_QUEST && !item->GetUInt32Value(ITEM_FIELD_EXPIRATION);
    }

    bool IsPostable(Item* item)
    {
        if (IsMaterial(item))
            return true;
        ItemTemplate const* proto = item->GetTemplate();
        if (!proto || item->IsSoulBound() || item->IsBoundByEnchant() || !item->CanBeTraded() || item->IsNotEmptyBag())
            return false;
        if ((proto->Flags & ITEM_PROTO_FLAG_CONJURED) || item->GetUInt32Value(ITEM_FIELD_EXPIRATION) || proto->StartQuest
            || proto->Bonding == BIND_QUEST)
            return false;
        // caged battle pets never showed up on the AH - they are Quality 1 (common) with
        // SellPrice 0 (not vendor-sellable, only tradeable), so the two checks below always filtered them out.
        // Post them regardless of quality/sell price; every other quality-based item still needs both.
        if (proto->Class == ITEM_CLASS_MISCELLANEOUS && proto->SubClass == ITEM_SUBCLASS_JUNK_PET)
            return true;
        // crafting: what the bots craft - potions, elixirs, flasks, bandages, armor kits - is mostly
        // common quality, so it would only ever go to the vendor
        if (proto->Class == ITEM_CLASS_CONSUMABLE && proto->SellPrice && proto->Quality >= ITEM_QUALITY_NORMAL
            && (proto->SubClass == ITEM_SUBCLASS_POTION || proto->SubClass == ITEM_SUBCLASS_ELIXIR || proto->SubClass == ITEM_SUBCLASS_FLASK
                || proto->SubClass == ITEM_SUBCLASS_ITEM_ENHANCEMENT || proto->SubClass == ITEM_SUBCLASS_BANDAGE))
            return true;
        if (!proto->SellPrice || proto->Quality < ITEM_QUALITY_UNCOMMON || proto->Quality > ITEM_QUALITY_EPIC)
            return false;
        return proto->Class == ITEM_CLASS_WEAPON || proto->Class == ITEM_CLASS_ARMOR || proto->Class == ITEM_CLASS_GEM
            || proto->Class == ITEM_CLASS_RECIPE;
    }
}

// loot rolls for bots (Group::BotRollChoice): need only for a real upgrade the bot can use (right armor type,
// right primary stat, better item level than what it wears in that slot), greed for anything worth money, else pass
namespace
{
    // an equippable piece that beats what this player wears in that slot (right armor type for the class)
    bool IsGearUpgrade(Player* p, ItemTemplate const* proto)
    {
        if ((proto->Class != ITEM_CLASS_WEAPON && proto->Class != ITEM_CLASS_ARMOR) || p->CanUseItem(proto) != EQUIP_ERR_OK
            || proto->RequiredLevel > p->GetLevel())
            return false;
        if (proto->Class == ITEM_CLASS_ARMOR && proto->InventoryType != INVTYPE_CLOAK && proto->SubClass >= ITEM_SUBCLASS_ARMOR_CLOTH
            && proto->SubClass <= ITEM_SUBCLASS_ARMOR_PLATE && proto->SubClass != PreferredArmor(p))
            return false;
        uint8 slot = p->FindEquipSlot(proto, NULL_SLOT, true);
        if (slot >= EQUIPMENT_SLOT_END)
            return false;
        Item* current = p->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
        return proto->ItemLevel > (current ? current->GetTemplate()->ItemLevel : 0);
    }

    uint8 BotRollChoiceImpl(Player* bot, ItemTemplate const* proto, uint8 /*rollVoteMask*/)
    {
        // a real player in the group goes first - no bot needs what is an upgrade for him
        if (Group* group = bot->GetGroup())
            for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                if (Player* member = ref->GetSource())
                    if (member->GetSession() && !member->GetSession()->IsBot() && member->IsInMap(bot) && IsGearUpgrade(member, proto))
                        return proto->SellPrice ? GREED : PASS;
        if ((proto->Class == ITEM_CLASS_WEAPON || proto->Class == ITEM_CLASS_ARMOR) && bot->CanUseItem(proto) == EQUIP_ERR_OK
            && proto->RequiredLevel <= bot->GetLevel())
        {
            bool armorOk = proto->Class != ITEM_CLASS_ARMOR || proto->InventoryType == INVTYPE_CLOAK
                || proto->SubClass < ITEM_SUBCLASS_ARMOR_CLOTH || proto->SubClass > ITEM_SUBCLASS_ARMOR_PLATE
                || proto->SubClass == PreferredArmor(bot);
            if (armorOk && sRandomItemMgr->FitsBot(bot, proto))
            {
                uint8 slot = bot->FindEquipSlot(proto, NULL_SLOT, true);
                if (slot < EQUIPMENT_SLOT_END)
                {
                    Item* current = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
                    uint32 currentLevel = current ? current->GetTemplate()->ItemLevel : 0;
                    if (proto->ItemLevel > currentLevel)
                        return NEED;
                }
            }
        }
        return proto->SellPrice ? GREED : PASS;
    }
}

void BotLifeMgr::LoadAuctionConfig()
{
    Group::BotRollChoice = &BotRollChoiceImpl;
    _auctions = sConfigMgr->GetBoolDefault("BotLife.AuctionHouse", true);
    _auctionPostPerVisit = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.AuctionPostPerVisit", 2)));
    _auctionMaxPerBot = uint32(std::max(1, sConfigMgr->GetIntDefault("BotLife.AuctionMaxPerBot", 8)));
    _auctionBuyChance = uint32(std::min(100, std::max(0, sConfigMgr->GetIntDefault("BotLife.AuctionBuyChance", 30))));
    _auctionBattlePets = uint32(std::max(0, sConfigMgr->GetIntDefault("BotLife.AuctionBattlePets", 150)));
}

// the Battle Pets category of the auction house was empty - nobody cages pets. The characters of
// the auction house bot keep a stock of caged pets there: a random tradable species, breed, quality and level, priced by
// quality and level. World thread (BotLifeMgr::WorldUpdate), a few per minute until the stock is back at the target.
void BotLifeMgr::SeedBattlePetAuctions()
{
    static std::vector<uint32> species;
    static std::unordered_set<uint32> allowed;
    if (species.empty())
    {
        // test pets on the auction house: the names in BattlePetSpeciesFlags do not fit the client
        // data. 0x2 is on the 237 ordinary pets that can be caged and traded (Mechanical Squirrel, Bombay Cat), 0x10 on
        // the ones that cannot (wild and store pets), 0x20 on hidden ones (trainer pets), 0x80 on companions that
        // cannot fight, 0x800 / 0x1000 on special cases. The old filter (not 0x2, not 0x10) left exactly the hidden
        // and test species: eleven of them, "Jacob the Test Seagull" included.
        for (uint32 i = 0; i < sBattlePetSpeciesStore.GetNumRows(); ++i)
            if (BattlePetSpeciesEntry const* entry = sBattlePetSpeciesStore.LookupEntry(i))
                if ((entry->Flags & 0x2) && !(entry->Flags & (0x10 | 0x20 | 0x80 | 0x800 | 0x1000)))
                    if (CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(entry->NpcId))
                        if (ct->Name.find("Test") == std::string::npos && ct->Name.find("test") == std::string::npos)
                        {
                            species.push_back(entry->SpeciesId);
                            allowed.insert(entry->SpeciesId);
                        }
        if (species.empty())
        {
            _auctionBattlePets = 0;
            return;
        }
    }

    static uint32 const allHouses[3] = { AUCTIONHOUSE_ALLIANCE, AUCTIONHOUSE_HORDE, AUCTIONHOUSE_NEUTRAL };
    bool const oneHouse = sWorld->getBoolConfig(CONFIG_ALLOW_TWO_SIDE_INTERACTION_AUCTION);
    for (uint32 houseId : allHouses)
    {
        if (oneHouse && houseId != AUCTIONHOUSE_NEUTRAL)
            continue;
        AuctionHouseObject* house = sAuctionMgr->GetAuctionsMapByHouseId(uint8(houseId));
        AuctionHouseEntry const* houseEntry = sAuctionHouseStore.LookupEntry(houseId);
        if (!house || !houseEntry)
            continue;
        uint32 stock = 0;
        for (auto itr = house->GetAuctionsBegin(); itr != house->GetAuctionsEnd(); ++itr)
        {
            // a mount the bot seller listed far below the price floor (AuctionBotSeller::SetPricesOfItem)
            // runs out now - the old 100 gold Mechano-Hogs kept every other mount off the auction house
            if (itr->second->itemEntry != BATTLE_PET_CAGE_ITEM_ID && !itr->second->bid && sAuctionBotConfig->IsBotChar(itr->second->owner))
                if (ItemTemplate const* proto = sObjectMgr->GetItemTemplate(itr->second->itemEntry))
                    if (proto->GetClass() == ITEM_CLASS_MISCELLANEOUS && proto->GetSubClass() == ITEM_SUBCLASS_JUNK_MOUNT)
                    {
                        uint64 const least = uint64(proto->GetQuality() >= ITEM_QUALITY_EPIC ? 7500 : proto->GetQuality() == ITEM_QUALITY_RARE ? 2000 : 400) * GOLD;
                        if (itr->second->buyout && itr->second->buyout < least && itr->second->expire_time > GameTime::GetGameTime())
                            itr->second->expire_time = GameTime::GetGameTime();
                    }
            if (itr->second->itemEntry == BATTLE_PET_CAGE_ITEM_ID)
            {
                // a cage of the bot seller with a species that is not for sale runs out now
                if (!itr->second->bid && sAuctionBotConfig->IsBotChar(itr->second->owner))
                    if (Item* cage = sAuctionMgr->GetAItem(itr->second->itemGUIDLow))
                        if (!allowed.count(cage->GetDynamicUInt32Value(ITEM_DYNAMIC_MODIFIERS, ITEM_MODIFIER_INDEX_BATTLE_PET_SPECIES)))
                        {
                            itr->second->expire_time = GameTime::GetGameTime();
                            continue;
                        }
                ++stock;
            }
        }
        uint32 const target = oneHouse ? _auctionBattlePets : _auctionBattlePets / 3;
        if (stock >= target)
            continue;

        CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
        for (uint32 n = std::min<uint32>(target - stock, 15); n; --n)
        {
            ObjectGuid owner = sAuctionBotConfig->GetRandChar();
            if (owner.IsEmpty())
                break;
            Item* item = Item::CreateItem(BATTLE_PET_CAGE_ITEM_ID, 1);
            if (!item)
                break;
            uint32 const pet = species[urand(0, uint32(species.size()) - 1)];
            uint32 roll = urand(0, 99);
            uint32 const quality = roll < 10 ? 0 : roll < 50 ? 1 : roll < 82 ? 2 : 3;   // poor, common, uncommon, rare
            roll = urand(0, 99);
            uint32 const level = roll < 55 ? 1 : roll < 80 ? urand(2, 10) : roll < 94 ? urand(11, 24) : 25;
            item->SetDynamicModifier(ITEM_MODIFIER_INDEX_BATTLE_PET_SPECIES, pet);
            item->SetDynamicModifier(ITEM_MODIFIER_INDEX_BATTLE_PET_BREED, uint32(sObjectMgr->BattlePetGetRandomBreed(pet)) | (quality << 24));
            item->SetDynamicModifier(ITEM_MODIFIER_INDEX_BATTLE_PET_LEVEL, level);

            static uint32 const baseGold[4] = { 15, 40, 120, 450 };
            uint64 const buyout = uint64(baseGold[quality]) * GOLD * (100 + level * 20) / 100 * urand(80, 130) / 100;
            uint32 const hours = urand(24, 72);

            AuctionEntry* auction = new AuctionEntry();
            auction->Id = sObjectMgr->GenerateAuctionID();
            auction->houseId = houseId;
            auction->itemGUIDLow = item->GetGUID().GetCounter();
            auction->itemEntry = item->GetEntry();
            auction->itemCount = 1;
            auction->owner = owner;
            auction->startbid = buyout * urand(60, 90) / 100;
            auction->bidder = ObjectGuid::Empty;
            auction->bid = 0;
            auction->buyout = buyout;
            auction->expire_time = GameTime::GetGameTime() + hours * HOUR;
            auction->deposit = 0;
            auction->etime = hours * HOUR;
            auction->auctionHouseEntry = houseEntry;

            item->SaveToDB(trans);
            sAuctionMgr->AddAItem(item);
            house->AddAuction(auction);
            auction->SaveToDB(trans);
            Count(BLC_AH_POST);
        }
        CharacterDatabase.CommitTransaction(trans);
    }
}

void BotLifeMgr::AuctionBusiness(Player* bot, bool banker)
{
    // a guild banker sells the guild bank surplus: more per visit, a bigger shop, no shopping
    uint32 const postPerVisit = banker ? 12 : _auctionPostPerVisit;
    uint32 const maxPerBot = banker ? 80 : _auctionMaxPerBot;
    AuctionHouseObject* house = sAuctionMgr->GetAuctionsMap(bot->GetFaction());
    AuctionHouseEntry const* houseEntry = AuctionHouseMgr::GetAuctionHouseEntry(bot->GetFaction());
    if (!house || !houseEntry)
        return;

    uint32 own = 0;
    for (auto itr = house->GetAuctionsBegin(); itr != house->GetAuctionsEnd(); ++itr)
        if (itr->second->owner == bot->GetGUID())
            ++own;

    // -- post
    uint32 posted = 0;
    auto post = [&](Item* item)
    {
        if (!item || posted >= postPerVisit || own >= maxPerBot || !IsPostable(item) || sAuctionMgr->GetAItem(item->GetGUID().GetCounter()))
            return;
        ItemTemplate const* proto = item->GetTemplate();
        // materials sell on demand, not at gear prices: a bit over vendor value with a floor by item level;
        // a single small stack stays in the bags (the guild bank already got its share this visit)
        bool material = IsMaterial(item);
        if (material && item->GetCount() < std::min<uint32>(proto->GetMaxStackSize(), 5))
            return;
        // caged battle pets have SellPrice 0 (not vendor-sellable), so the normal
        // sellprice-based pricing below would price them at 0 and skip the post entirely; give them a flat
        // floor price instead.
        bool battlePet = proto->Class == ITEM_CLASS_MISCELLANEOUS && proto->SubClass == ITEM_SUBCLASS_JUNK_PET;
        // prices far too low: by quality, a little under what the auction house bot asks
        // (worldserver.conf: white x4, green x8, blue x20, epic x80 of the vendor price)
        static uint32 const gearPct[2][5] = { { 350, 350, 650, 1600, 6000 }, { 500, 500, 900, 2200, 9000 } };
        static uint32 const matPct[2][5]  = { { 350, 350, 550, 1200, 4000 }, { 550, 550, 800, 1800, 6500 } };
        uint32 const q = std::min<uint32>(proto->Quality, ITEM_QUALITY_EPIC);
        uint64 each = battlePet ? uint64(urand(20, 60)) * GOLD
                    : material  ? std::max<uint64>(uint64(proto->SellPrice) * urand(matPct[0][q], matPct[1][q]) / 100, uint64(proto->ItemLevel) * 15)
                                : uint64(proto->SellPrice) * urand(gearPct[0][q], gearPct[1][q]) / 100;
        uint64 buyout = each * item->GetCount();
        uint64 bid = buyout * urand(70, 90) / 100;
        if (!bid)
            return;
        uint32 auctionTime = uint32(BotAuctionMinutes * MINUTE * sWorld->getRate(RATE_AUCTION_TIME));
        uint64 deposit = AuctionHouseMgr::GetAuctionDeposit(houseEntry, BotAuctionMinutes * MINUTE, item, item->GetCount());
        if (!bot->HasEnoughMoney(deposit))
            return;

        AuctionEntry* auction = new AuctionEntry();
        auction->houseId = sWorld->getBoolConfig(CONFIG_ALLOW_TWO_SIDE_INTERACTION_AUCTION) ? AUCTIONHOUSE_NEUTRAL : houseEntry->houseId;
        auction->Id = sObjectMgr->GenerateAuctionID();
        auction->itemGUIDLow = item->GetGUID().GetCounter();
        auction->itemEntry = item->GetEntry();
        auction->itemCount = item->GetCount();
        auction->owner = bot->GetGUID();
        auction->startbid = bid;
        auction->bidder = ObjectGuid::Empty;
        auction->bid = 0;
        auction->buyout = buyout;
        auction->expire_time = GameTime::GetGameTime() + auctionTime;
        auction->deposit = deposit;
        auction->etime = BotAuctionMinutes * MINUTE;
        auction->auctionHouseEntry = houseEntry;
        // ASan: no pending-auction list for bots - the entry is live (and buyable by the next bot) right
        // away, and a bought entry left a dangling pointer there. The deposit is paid at once.
        bot->ModifyMoney(-int64(deposit));
        sAuctionMgr->AddAItem(item);
        house->AddAuction(auction);
        bot->MoveItemFromInventory(item->GetBagSlot(), item->GetSlot(), true);

        CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
        item->DeleteFromInventoryDB(trans);
        item->SaveToDB(trans);
        auction->SaveToDB(trans);
        bot->SaveInventoryAndGoldToDB(trans);
        CharacterDatabase.CommitTransaction(trans);
        ++posted;
        ++own;
        Count(material ? BLC_AH_POST_MAT : BLC_AH_POST);
    };
    std::vector<Item*> items;
    for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        if (Item* item = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
            items.push_back(item);
    for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
        if (Bag* container = bot->GetBagByPos(bag))
            for (uint32 slot = 0; slot < container->GetBagSize(); ++slot)
                if (Item* item = container->GetItemByPos(uint8(slot)))
                    items.push_back(item);
    // materials first (they come in bulk from gathering), then gear
    std::stable_partition(items.begin(), items.end(), [](Item* item) { return IsMaterial(item); });
    for (Item* item : items)
        post(item);

    // -- buy an upgrade now and then
    // a bot with an empty, grey or white armor slot always shops, up to 3 pieces
    bool const weak = !banker && HasWeakArmorSlot(bot);
    if (banker || (!weak && urand(0, 99) >= _auctionBuyChance))
        return;
    for (uint32 round = 0; round < (weak ? 3u : 1u); ++round)
    {
    uint64 budget = bot->GetMoney() / 5;
    AuctionEntry* best = nullptr;
    uint8 bestSlot = NULL_SLOT;
    uint32 bestGain = 0;
    for (auto itr = house->GetAuctionsBegin(); itr != house->GetAuctionsEnd(); ++itr)
    {
        AuctionEntry* auction = itr->second;
        if (auction->owner == bot->GetGUID() || !auction->buyout || auction->buyout > budget || auction->bidder)
            continue;
        ItemTemplate const* proto = sObjectMgr->GetItemTemplate(auction->itemEntry);
        if (!proto || (proto->Class != ITEM_CLASS_WEAPON && proto->Class != ITEM_CLASS_ARMOR) || proto->RequiredLevel > bot->GetLevel())
            continue;
        if (proto->Class == ITEM_CLASS_ARMOR && proto->SubClass >= ITEM_SUBCLASS_ARMOR_CLOTH && proto->SubClass <= ITEM_SUBCLASS_ARMOR_PLATE
            && proto->InventoryType != INVTYPE_CLOAK && proto->SubClass != PreferredArmor(bot))
            continue;
        if (bot->CanUseItem(proto) != EQUIP_ERR_OK || !sRandomItemMgr->FitsBot(bot, proto))
            continue;
        uint8 slot = bot->FindEquipSlot(proto, NULL_SLOT, true);
        if (slot >= EQUIPMENT_SLOT_END)
            continue;
        Item* current = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
        // item level x4 plus the quality, as EquipBagUpgrades (a grey piece no longer blocks a green one)
        auto value = [](ItemTemplate const* t) -> int32
        {
            static int32 const qualityBonus[] = { -40, -20, 0, 24, 48, 60, 60, 0 };
            return t->Quality == ITEM_QUALITY_HEIRLOOM ? 1000000 : int32(t->ItemLevel) * 4 + qualityBonus[std::min<uint32>(t->Quality, 7)];
        };
        int32 const currentValue = current ? value(current->GetTemplate()) : -100;
        if (value(proto) <= currentValue + 12)
            continue;
        uint32 gain = uint32(value(proto) - currentValue);
        if (gain > bestGain)
        {
            best = auction;
            bestSlot = slot;
            bestGain = gain;
        }
    }
    if (!best)
        return;
    Item* item = sAuctionMgr->GetAItem(best->itemGUIDLow);
    if (!item)
        return;
    ItemPosCountVec dest;
    if (bot->CanStoreItem(NULL_BAG, NULL_SLOT, dest, item, false) != EQUIP_ERR_OK)
        return;

    CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
    bot->ModifyMoney(-int64(best->buyout));
    best->bidder = bot->GetGUID();
    best->bid = best->buyout;
    sAuctionMgr->SendAuctionSalePendingMail(best, trans);
    sAuctionMgr->SendAuctionSuccessfulMail(best, trans);   // the seller gets the money by mail
    best->DeleteFromDB(trans);
    sAuctionMgr->RemoveAItem(best->itemGUIDLow);           // keeps the item object, it moves to the bot
    house->RemoveAuction(best);
    item->SetOwnerGUID(bot->GetGUID());
    item->SetState(ITEM_CHANGED, bot);
    bot->MoveItemToInventory(dest, item, true);
    bot->SaveInventoryAndGoldToDB(trans);
    CharacterDatabase.CommitTransaction(trans);
    Count(BLC_AH_BUY);
    (void)bestSlot;
    if (_debug)
        TC_LOG_INFO("playerbots", "BotLife {} (lvl {}): bought {} from the auction house", bot->GetName(), uint32(bot->GetLevel()), item->GetTemplate()->Name1);
    EquipBagUpgrades(bot);   // wear it before the next round looks at the slot
    }
}
