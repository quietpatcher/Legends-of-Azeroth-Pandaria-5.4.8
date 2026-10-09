#ifndef _PLAYERBOT_RANDOMITEMMGR_H
#define _PLAYERBOT_RANDOMITEMMGR_H

#include <map>
#include <set>
#include <unordered_set>
#include <vector>

#include "AiFactory.h"
#include "Common.h"
#include "Item.h"
#include "Player.h"

enum item_sub_class : uint32
{
    PLATE = 0,
    MAIL,
    LEATHER,
    CLOTH
};

class RandomItemManager
{
public:
    RandomItemManager();
    void Init();
    virtual ~RandomItemManager();
    static RandomItemManager* instance()
    {
        static RandomItemManager instance;
        return &instance;
    }

    uint32 FindBestItemForLevelAndEquip(Player* bot, InventoryType invType);
    bool IsTestItem(uint32 itemId) { return _itemForTest.find(itemId) != _itemForTest.end(); }

    std::vector<uint32> GetCachedEquipments(uint32 requiredLevel, uint32 inventoryType);

    bool CanEquipArmor(Player* bot, ItemTemplate const* proto);
    bool CanEquipWeapon(Player* bot, ItemTemplate const* proto);
    bool CanEquipSubArmor(Player* bot, ItemTemplate const* proto);
    // MoP rules shared with BotLife (bag upgrades, quest rewards, auction buys)
    static uint32 PrimaryStat(Player* bot);                              // ITEM_MOD_STRENGTH / AGILITY / INTELLECT
    static bool HasWrongPrimaryStat(Player* bot, ItemTemplate const* proto);
    bool FitsBot(Player* bot, ItemTemplate const* proto);               // armor type + primary stat (+ weapon type)
    // the highest item level a character of this level can sensibly wear. Thousands of items have no
    // required level in the database although their item level belongs to level 85-90 (or is plain nonsense: 813).
    static uint32 MaxItemLevelForLevel(uint32 level)
    {
        if (level >= 90)
            return 100000;
        if (level > 85)
            return 372 + (level - 85) * 16;      // Pandaria questing: 384 ... 437
        if (level > 80)
            return 285 + (level - 80) * 15;      // Cataclysm: 300 ... 360
        if (level > 70)
            return 130 + (level - 70) * 9;       // Northrend: 139 ... 220
        if (level > 60)
            return 85 + (level - 60) * 4;        // Outland: 89 ... 125
        return level + 15;                       // classic: item level is about the level plus five
    }
    static bool ItemLevelFits(uint32 level, ItemTemplate const* proto);
private:
    void AddItemStats(uint32 mod, uint8& sp, uint8& ap, uint8& tank);
    bool CanEquipItem(EquipmentSlots slot, ItemTemplate const* proto);
    
    bool CheckItemStats(Classes clazz, uint8 sp, uint8 ap, uint8 tank);
    bool ShouldEquipArmorForSpec(uint32 level, Classes playerclass, Specializations spec, ItemTemplate const* proto);
    bool ShouldEquipWeaponForSpec(Classes playerclass, Specializations spec, ItemTemplate const* proto);
private:
    std::map<uint32, std::map<uint32, std::vector<uint32>>> _equipCacheNew;
    std::map<EquipmentSlots, std::set<InventoryType>> _viable_slots;
    std::unordered_set<uint32> _itemForTest;
};

#define sRandomItemMgr RandomItemManager::instance()

#endif
