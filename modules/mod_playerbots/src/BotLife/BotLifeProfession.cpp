/*
 * BotLife gathering professions.
 *  - every bot from level 5 has two gathering professions (mining + herbalism, herbalism + skinning or mining + skinning,
 *    picked by GUID), skill kept at the level of its zones (the rank spells from ServiceMgr, 75 skill per rank)
 *  - out of combat in the open world a bot walks to a herb/ore node in reach of its skill, or a skinnable corpse, casts
 *    the real gathering spell (skill-ups and loot like a player) and loots everything
 *  - crafting (29-9): part of the bots pair a gathering profession with its crafting one (mining + blacksmithing /
 *    engineering, herbalism + alchemy, skinning + leatherworking / tailoring). They know the trainer recipes up to their
 *    skill and craft during a town visit, before the guild bank / auction house business, with the materials in their
 *    bags (real casts: reagents are used up, skill-ups like a player). Recipes that need a forge/anvil only near one.
 */

#include "BotLife.h"

#include <cmath>

#include "CellImpl.h"
#include "Config.h"
#include "Creature.h"
#include "DBCStores.h"
#include "GameObject.h"
#include "Group.h"
#include "Guild.h"
#include "GuildMgr.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "Log.h"
#include "LootMgr.h"
#include "Map.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "DatabaseEnv.h"
#include "Player.h"
#include "Spell.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "PlayerbotAI.h"
#include "Playerbots.h"
#include "WorldSession.h"

namespace
{
    struct GatherProfession
    {
        uint16 skill;
        uint32 ranks[8];     // Apprentice .. Zen Master, 75 skill each
        uint32 tool;         // item the gathering spell may ask for (totem category)
    };

    GatherProfession const Herbalism = { SKILL_HERBALISM, { 2366, 2368, 3570, 11993, 28695, 50300, 74519, 110413 }, 0 };
    GatherProfession const Mining    = { SKILL_MINING,    { 2575, 2576, 3564, 10248, 29354, 50310, 74517, 102161 }, 2901 };
    GatherProfession const Skinning  = { SKILL_SKINNING,  { 8613, 8617, 8618, 10768, 32678, 50305, 74522, 102216 }, 7005 };
    // crafting professions (rank spells as in ServiceMgr::_profs); tool = second item the recipes may ask for
    GatherProfession const Blacksmithing  = { SKILL_BLACKSMITHING,  { 2018, 3100, 3538, 9785, 29844, 51300, 76666, 110396 }, 5956 };
    GatherProfession const Alchemy        = { SKILL_ALCHEMY,        { 2259, 3101, 3464, 11611, 28596, 51304, 80731, 105206 }, 0 };
    GatherProfession const Leatherworking = { SKILL_LEATHERWORKING, { 2108, 3104, 3811, 10662, 32549, 51302, 81199, 110423 }, 0 };
    GatherProfession const Engineering    = { SKILL_ENGINEERING,    { 4036, 4037, 4038, 12656, 30350, 51306, 82774, 110403 }, 6219 };
    GatherProfession const Tailoring      = { SKILL_TAILORING,      { 3908, 3909, 3910, 12180, 26790, 51309, 75156, 110426 }, 0 };

    // no glyphs, cut gems, enchantments, food or fish from the bots: . tool: Virtuoso Inking
    // Set, Jeweler's Kit, Runed Elementium Rod
    GatherProfession const Inscription    = { SKILL_INSCRIPTION,    { 45357, 45358, 45359, 45360, 45361, 45363, 86008, 110417 }, 39505 };
    GatherProfession const Jewelcrafting  = { SKILL_JEWELCRAFTING,  { 25229, 25230, 28894, 28895, 28897, 51311, 73318, 110420 }, 20815 };
    GatherProfession const Enchanting     = { SKILL_ENCHANTING,     { 7411, 7412, 7413, 13920, 28029, 51313, 74258, 110400 }, 52723 };
    // secondary professions: every bot has them, they take no profession slot
    GatherProfession const Cooking        = { SKILL_COOKING,        { 2550, 3102, 3413, 18260, 33359, 51296, 88053, 104381 }, 0 };
    GatherProfession const Fishing        = { SKILL_FISHING,        { 7620, 7731, 7732, 18248, 33095, 51294, 88868, 110410 }, 0 };
    // First Aid (Apprentice .. Zen Master)
    GatherProfession const FirstAid       = { SKILL_FIRST_AID,      { 3273, 3274, 7924, 10846, 27028, 45542, 74559, 110406 }, 0 };
    GatherProfession const* const SecondaryProfessions[] = { &Cooking, &Fishing, &FirstAid };
    GatherProfession const Archaeology    = { SKILL_ARCHAEOLOGY,    { 78670, 88961, 89718, 89719, 89720, 89721, 89722, 110393 }, 0 };
    // the six Ways of Pandaren cooking (skills of their own, no rank spells)
    GatherProfession const WayOfTheGrill   = { SKILL_WAY_OF_THE_GRILL,   {}, 0 };
    GatherProfession const WayOfTheWok     = { SKILL_WAY_OF_THE_WOK,     {}, 0 };
    GatherProfession const WayOfThePot     = { SKILL_WAY_OF_THE_POT,     {}, 0 };
    GatherProfession const WayOfTheSteamer = { SKILL_WAY_OF_THE_STEAMER, {}, 0 };
    GatherProfession const WayOfTheOven    = { SKILL_WAY_OF_THE_OVEN,    {}, 0 };
    GatherProfession const WayOfTheBrew    = { SKILL_WAY_OF_THE_BREW,    {}, 0 };
    GatherProfession const* const Ways[6] = { &WayOfTheGrill, &WayOfTheWok, &WayOfThePot, &WayOfTheSteamer, &WayOfTheOven, &WayOfTheBrew };
    uint32 const SurveySpell = 80451;

    // per bot (GUID % 16). The first eight rows are the picks of before (GUID % 8). In the second eight, three rows
    // changed, and each of those keeps one profession, so a bot swaps one: herbalism + inscription (was mining +
    // herbalism), mining + jewelcrafting (was mining + skinning), tailoring + enchanting (was skinning + tailoring).
    GatherProfession const* const ProfessionPicks[16][2] = {
        { &Mining, &Herbalism }, { &Herbalism, &Skinning }, { &Mining, &Skinning },
        { &Mining, &Blacksmithing }, { &Herbalism, &Alchemy }, { &Skinning, &Leatherworking },
        { &Mining, &Engineering }, { &Skinning, &Tailoring },
        { &Herbalism, &Inscription }, { &Herbalism, &Skinning }, { &Mining, &Jewelcrafting },
        { &Mining, &Blacksmithing }, { &Herbalism, &Alchemy }, { &Skinning, &Leatherworking },
        { &Mining, &Engineering }, { &Tailoring, &Enchanting } };
    // the primary professions (one that is not in the pick of a bot is dropped)
    GatherProfession const* const AllProfessions[] = { &Herbalism, &Mining, &Skinning, &Blacksmithing, &Alchemy,
        &Leatherworking, &Engineering, &Tailoring, &Inscription, &Jewelcrafting, &Enchanting };
    // everything a bot crafts with
    GatherProfession const* const CraftProfessions[] = { &Herbalism, &Mining, &Skinning, &Blacksmithing, &Alchemy,
        &Leatherworking, &Engineering, &Tailoring, &Inscription, &Jewelcrafting, &Enchanting, &Cooking,
        &WayOfTheGrill, &WayOfTheWok, &WayOfThePot, &WayOfTheSteamer, &WayOfTheOven, &WayOfTheBrew };
    uint32 const EngineeringExtraTool = 10498;   // Gyromatic Micro-Adjustor
    uint32 const EnchantingVellum = 38682;
    uint32 const BasicCampfire = 818;
    uint32 const FishingSpell = 131474;          // the script casts 131476 (no pole) or 131490 (with a pole)
    uint32 const FishingCasts[2] = { 131476, 131490 };

    // mining counts as crafting too - smelting (ore to bars, at a forge)
    bool IsCraftSkill(uint16 skill)
    {
        return skill == SKILL_BLACKSMITHING || skill == SKILL_ALCHEMY || skill == SKILL_LEATHERWORKING
            || skill == SKILL_ENGINEERING || skill == SKILL_TAILORING || skill == SKILL_MINING
            || skill == SKILL_INSCRIPTION || skill == SKILL_JEWELCRAFTING || skill == SKILL_ENCHANTING || skill == SKILL_COOKING
            || skill == SKILL_FIRST_AID   // bandages
            || (skill >= SKILL_WAY_OF_THE_GRILL && skill <= SKILL_WAY_OF_THE_BREW);
    }

    // what a recipe makes - the item of a create-item effect, or the scroll of an enchantment (the
    // enchantment is then cast on a vellum)
    uint32 CraftProduct(SpellInfo const* info, bool* scroll = nullptr)
    {
        for (uint32 e = 0; e < MAX_SPELL_EFFECTS; ++e)
            if ((info->Effects[e].Effect == SPELL_EFFECT_CREATE_ITEM || info->Effects[e].Effect == SPELL_EFFECT_CREATE_ITEM_2)
                && info->Effects[e].ItemType)
                return info->Effects[e].ItemType;
        for (uint32 e = 0; e < MAX_SPELL_EFFECTS; ++e)
            if (info->Effects[e].Effect == SPELL_EFFECT_ENCHANT_ITEM && info->Effects[e].ItemType)
            {
                if (scroll)
                    *scroll = true;
                return info->Effects[e].ItemType;
            }
        return 0;
    }

    uint32 const SpellFocusAnvil = 1;
    uint32 const SpellFocusForge = 3;
    uint32 const SpellFocusCookingFire = 4;

    // an anvil / forge (spell focus object) within range, wherever its own radius ends
    struct FocusObjectCheck
    {
        Player* bot;
        uint32 focusId;
        float range;

        bool operator()(GameObject* go) const
        {
            return go->GetGoType() == GAMEOBJECT_TYPE_SPELL_FOCUS && go->isSpawned() && go->GetGOInfo()->spellFocus.focusId == focusId
                && bot->IsWithinDistInMap(go, range);
        }
    };

    GameObject* FindFocusObject(Player* bot, uint32 focusId, float range)
    {
        GameObject* found = nullptr;
        FocusObjectCheck check{ bot, focusId, range };
        Trinity::GameObjectSearcher<FocusObjectCheck> searcher(bot, found, check);
        CellCoord pair(Trinity::ComputeCellCoord(bot->GetPositionX(), bot->GetPositionY()));
        Cell cell(pair);
        cell.SetNoCreate();
        TypeContainerVisitor<Trinity::GameObjectSearcher<FocusObjectCheck>, GridTypeMapContainer> visitor(searcher);
        cell.Visit(pair, visitor, *bot->GetMap(), *bot, range);
        return found;
    }

    // reagents a vendor sells (vials, thread, flux, dye ...), item -> price each in copper. The crafts
    // of the bots never started (0 per hour) because nobody had a crystal vial or a spool of thread in the bags.
    std::unordered_map<uint32, uint32> s_vendorReagents;

    // every reagent in the bags; what is missing must be something a vendor sells and the bot can pay (toBuy gets
    // item/count), and at least one reagent must be the bot's own - no crafting out of thin air.
    // Recipes without reagents (cooldown transmutes and the like) are not worth a cast.
    bool HasReagents(Player* bot, SpellInfo const* info, std::vector<std::pair<uint32, uint32>>* toBuy = nullptr)
    {
        bool own = false;
        uint64 cost = 0;
        for (uint32 i = 0; i < MAX_SPELL_REAGENTS; ++i)
        {
            if (info->Reagent[i] <= 0)
                continue;
            uint32 const item = uint32(info->Reagent[i]);
            uint32 const need = info->ReagentCount[i];
            uint32 const have = bot->GetItemCount(item, false);
            if (have >= need)
            {
                own = true;
                continue;
            }
            auto vendor = s_vendorReagents.find(item);
            if (vendor == s_vendorReagents.end())
                return false;
            cost += uint64(vendor->second) * (need - have);
            if (toBuy)
                toBuy->emplace_back(item, need - have);
        }
        return own && (!cost || bot->GetMoney() >= cost + 1 * GOLD);
    }

    bool FocusNear(Player* bot, uint32 focusId)
    {
        GameObject* focus = nullptr;
        Trinity::GameObjectFocusCheck check(bot, focusId);
        Trinity::GameObjectSearcher<Trinity::GameObjectFocusCheck> searcher(bot, focus, check);
        CellCoord pair(Trinity::ComputeCellCoord(bot->GetPositionX(), bot->GetPositionY()));
        Cell cell(pair);
        cell.SetNoCreate();
        TypeContainerVisitor<Trinity::GameObjectSearcher<Trinity::GameObjectFocusCheck>, GridTypeMapContainer> visitor(searcher);
        cell.Visit(pair, visitor, *bot->GetMap(), *bot, 20.0f);
        return focus != nullptr;
    }

    // skill that matches the zones of the level: 5 per level, then 425 -> 600 over the Pandaria levels
    uint16 SkillForLevel(uint32 level)
    {
        if (level >= 85)
            return uint16(std::min<uint32>(600, 425 + (level - 85) * 35));
        return uint16(std::max<uint32>(1, level * 5));
    }

    // a herb/ore node (chest with a herbalism/mining skill lock) the bot's skill opens
    struct GatherNodeCheck
    {
        Player* bot;
        float range;
        uint16 herb;
        uint16 mine;
        uint32 lockType = 0;

        bool operator()(GameObject* go)
        {
            if (go->GetGoType() != GAMEOBJECT_TYPE_CHEST || !go->isSpawned() || go->getLootState() != GO_READY
                || !bot->IsWithinDistInMap(go, range))
                return false;
            LockEntry const* lock = sLockStore.LookupEntry(go->GetGOInfo()->GetLockId());
            if (!lock)
                return false;
            for (uint32 i = 0; i < MAX_LOCK_CASE; ++i)
            {
                if (lock->Type[i] != LOCK_KEY_SKILL)
                    continue;
                if ((lock->Index[i] == LOCKTYPE_HERBALISM && herb && herb >= lock->Skill[i])
                    || (lock->Index[i] == LOCKTYPE_MINING && mine && mine >= lock->Skill[i]))
                {
                    lockType = lock->Index[i];
                    return true;
                }
            }
            return false;
        }
    };

    struct SkinnableCorpseCheck
    {
        Player* bot;
        float range;

        bool operator()(Creature* c) const
        {
            // own kills, or kills of the own group 
            return !c->IsAlive() && c->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_SKINNABLE) && bot->IsWithinDistInMap(c, range)
                && (c->GetLootRecipient() == bot || (bot->GetGroup() && c->GetLootRecipientGroup() == bot->GetGroup()));
        }
    };

    void LootAll(Player* bot, Loot* loot, ObjectGuid guid)
    {
        uint32 maxSlot = std::min<uint32>(uint32(loot->items.size() + loot->quest_items.size()), 16);
        for (uint32 slot = 0; slot < maxSlot; ++slot)
        {
            LootItem* item = loot->LootItemInSlot(slot, bot);
            if (!item || item->is_looted)
                continue;
            bot->StoreLootItem(uint8(slot), loot);
        }
        bot->GetSession()->DoLootRelease(guid);
    }

    // scribes mill their herbs, jewelcrafters prospect their ore, enchanters disenchant the green and
    // blue gear in their bags. A bot cannot click a loot window, so it gets what the cast would give: the loot of the
    // milling / prospecting / disenchant template of the item, for five of a stack (or the one piece of gear).
    uint32 RefineMaterials(Player* bot, uint32 maxBatches)
    {
        uint16 const inscription = bot->HasSkill(SKILL_INSCRIPTION) ? bot->GetSkillValue(SKILL_INSCRIPTION) : 0;
        uint16 const jewelcrafting = bot->HasSkill(SKILL_JEWELCRAFTING) ? bot->GetSkillValue(SKILL_JEWELCRAFTING) : 0;
        uint16 const enchanting = bot->HasSkill(SKILL_ENCHANTING) ? bot->GetSkillValue(SKILL_ENCHANTING) : 0;
        if (!inscription && !jewelcrafting && !enchanting)
            return 0;

        struct Job
        {
            Item* item;
            LootStore const* store;
            uint32 lootId;
            uint32 take;
        };
        std::vector<Job> jobs;
        auto consider = [&](Item* item)
        {
            if (!item || jobs.size() >= maxBatches)
                return;
            ItemTemplate const* proto = item->GetTemplate();
            if (!proto)
                return;
            if (inscription && (proto->Flags & ITEM_PROTO_FLAG_MILLABLE) && item->GetCount() >= 5
                && proto->RequiredSkillRank <= inscription && LootTemplates_Milling.HaveLootFor(proto->ItemId))
                jobs.push_back({ item, &LootTemplates_Milling, proto->ItemId, 5 });
            else if (jewelcrafting && (proto->Flags & ITEM_PROTO_FLAG_PROSPECTABLE) && item->GetCount() >= 5
                && proto->RequiredSkillRank <= jewelcrafting && LootTemplates_Prospecting.HaveLootFor(proto->ItemId))
                jobs.push_back({ item, &LootTemplates_Prospecting, proto->ItemId, 5 });
            else if (enchanting && (proto->Class == ITEM_CLASS_WEAPON || proto->Class == ITEM_CLASS_ARMOR)
                && proto->Quality >= ITEM_QUALITY_UNCOMMON && proto->Quality <= ITEM_QUALITY_RARE && proto->DisenchantID
                && proto->RequiredDisenchantSkill <= enchanting && LootTemplates_Disenchant.HaveLootFor(proto->DisenchantID))
                jobs.push_back({ item, &LootTemplates_Disenchant, proto->DisenchantID, 1 });
        };
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
            consider(bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot));
        for (uint8 bagSlot = INVENTORY_SLOT_BAG_START; bagSlot < INVENTORY_SLOT_BAG_END; ++bagSlot)
            if (Bag* bag = bot->GetBagByPos(bagSlot))
                for (uint32 slot = 0; slot < bag->GetBagSize(); ++slot)
                    consider(bag->GetItemByPos(uint8(slot)));

        uint32 done = 0;
        for (Job const& job : jobs)   // (one job per item, so no job sees an item another one used up)
        {
            Loot loot;
            loot.FillLoot(job.item, job.lootId, *job.store, bot, true, true);
            std::vector<std::pair<uint32, uint32>> yield;
            for (LootItem const& li : loot.items)
                if (li.itemid && !li.currency && li.count)
                    yield.emplace_back(li.itemid, li.count);
            if (job.take == 1)
                bot->DestroyItem(job.item->GetBagSlot(), job.item->GetSlot(), true);
            else
            {
                uint32 count = job.take;
                bot->DestroyItemCount(job.item, count, true);
            }
            for (auto const& got : yield)
            {
                ItemPosCountVec dest;
                if (bot->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, got.first, got.second) == EQUIP_ERR_OK)
                    bot->StoreNewItem(dest, got.first, true);
            }
            ++done;
        }
        return done;
    }

    // solve a research project the bot has the fragments for (no keystones). The client names the
    // fragments it spends in the cast packet; a bot hands the same data to the spell.
    bool SolveResearchProject(Player* bot)
    {
        for (uint32 i = 0; i < 7; ++i)   // PLAYER_FIELD_RESEARCHING: two project ids per field, thirteen branches
        {
            uint32 const value = bot->GetUInt32Value(PLAYER_FIELD_RESEARCHING + i);
            for (uint32 projectId : { value >> 16, value & 0xFFFF })
            {
                ResearchProjectEntry const* project = projectId ? sResearchProjectStore.LookupEntry(projectId) : nullptr;
                ResearchBranchEntry const* branch = project ? sResearchBranchStore.LookupEntry(project->ResearchBranchId) : nullptr;
                SpellInfo const* info = project ? sSpellMgr->GetSpellInfo(project->SpellId) : nullptr;
                if (!branch || !info || !project->RequiredFragmentCount
                    || !bot->HasCurrency(branch->FragmentCurrencyId, project->RequiredFragmentCount))
                    continue;
                SpellResearchData* data = new SpellResearchData();
                data->KeystoneItemId = 0;
                data->KeystoneCount = 0;
                data->FragmentCurrencyId = branch->FragmentCurrencyId;
                data->FragmentCount = project->RequiredFragmentCount;
                Spell* spell = new Spell(bot, info, TRIGGERED_NONE);
                spell->m_researchData = data;
                SpellCastTargets targets;
                targets.SetUnitTarget(bot);
                spell->prepare(&targets);
                return true;
            }
        }
        return false;
    }

    // the bobber of the bot's fishing cast
    GameObject* FishingBobber(Player* bot)
    {
        for (uint32 spell : FishingCasts)
            if (GameObject* go = bot->GetGameObject(spell))
                if (go->GetGoType() == GAMEOBJECT_TYPE_FISHINGNODE)
                    return go;
        return nullptr;
    }
}

void BotLifeMgr::LoadProfessionConfig()
{
    _professions = sConfigMgr->GetBoolDefault("BotLife.Professions", true);
    _fishing = sConfigMgr->GetBoolDefault("BotLife.Fishing", true);
    _fishingMinutes = uint32(std::max(5, sConfigMgr->GetIntDefault("BotLife.FishingMinutes", 45)));
    _archaeology = sConfigMgr->GetBoolDefault("BotLife.Archaeology", true);
    _digMinutes = uint32(std::max(10, sConfigMgr->GetIntDefault("BotLife.DigMinutes", 60)));
    _craftsPerVisit = sConfigMgr->GetIntDefault("BotLife.CraftsPerVisit", 4);
    _craftRecipes.clear();
    // trainer recipes that create an item, lowest required skill per spell
    // (1-10: cooking, enchanting, jewelcrafting and inscription too; a recipe is anything that makes an item -
    // create item, the create item of the newer recipes, or an enchantment that has a scroll)
    if (QueryResult result = WorldDatabase.Query("SELECT spell, reqskill, MIN(reqskillvalue) FROM npc_trainer "
        "WHERE reqskill IN (129, 164, 165, 171, 185, 186, 197, 202, 333, 755, 773, 975, 976, 977, 978, 979, 980) GROUP BY spell, reqskill"))   // (4-10: 129 First Aid)
    {
        do
        {
            Field* fields = result->Fetch();
            uint32 spell = fields[0].GetUInt32();
            SpellInfo const* info = sSpellMgr->GetSpellInfo(spell);
            if (!info || !CraftProduct(info))
                continue;
            _craftRecipes[uint16(fields[1].GetUInt32())].emplace_back(spell, uint16(fields[2].GetUInt32()));
        } while (result->NextRow());
    }
    size_t total = 0;
    for (auto& pair : _craftRecipes)
    {
        std::sort(pair.second.begin(), pair.second.end(), [](auto const& a, auto const& b) { return a.second > b.second; });
        total += pair.second.size();
    }
    // cheap trade goods any vendor sells for gold
    s_vendorReagents.clear();
    if (QueryResult result = WorldDatabase.Query("SELECT DISTINCT v.item FROM npc_vendor v JOIN item_template t ON t.entry = v.item "
        "WHERE v.item > 0 AND v.ExtendedCost = 0 AND t.class = 7 AND t.BuyPrice > 0 AND t.BuyPrice <= 50000"))
    {
        do
        {
            if (ItemTemplate const* proto = sObjectMgr->GetItemTemplate(result->Fetch()[0].GetUInt32()))
                if (proto->BuyPrice > 0)
                    s_vendorReagents[proto->ItemId] = std::max<uint32>(1, uint32(proto->BuyPrice) / std::max<uint32>(1, proto->BuyCount));
        } while (result->NextRow());
    }
    TC_LOG_INFO("playerbots", "BotLife: {} crafting recipes for bots, {} vendor reagents", total, s_vendorReagents.size());
}

void BotLifeMgr::EnsureProfessions(Player* bot)
{
    if (!_professions || bot->GetLevel() < 5)
        return;
    GatherProfession const* const* profs = ProfessionPicks[bot->GetGUID().GetCounter() % 16];
    uint16 target = SkillForLevel(bot->GetLevel());
    uint32 tier = std::min<uint32>(7, (target - 1) / 75);
    // bots from before the crafting split: drop one profession that is not in the pick, so the pick fits
    bool missing = !bot->HasSkill(profs[0]->skill) || !bot->HasSkill(profs[1]->skill);
    if (missing && !bot->GetFreePrimaryProfessionPoints())
    {
        for (GatherProfession const* other : AllProfessions)
        {
            if (other == profs[0] || other == profs[1] || !bot->HasSkill(other->skill))
                continue;
            for (uint32 r = 0; r < 8; ++r)
                if (bot->HasSpell(other->ranks[r]))
                    bot->RemoveSpell(other->ranks[r], false, false);
            bot->SetSkill(other->skill, 0, 0, 0);
            Count(BLC_PROFESSION_SWAP);
            break;
        }
    }
    for (uint32 p = 0; p < 2; ++p)
    {
        GatherProfession const& prof = *profs[p];
        if (!bot->HasSkill(prof.skill) && !bot->GetFreePrimaryProfessionPoints())
            continue;   // two other professions already
        bool learned = false;
        for (uint32 r = 0; r <= tier; ++r)
            if (!bot->HasSpell(prof.ranks[r]))
            {
                bot->LearnSpell(prof.ranks[r], false);
                learned = true;
            }
        if (bot->GetSkillValue(prof.skill) < target)
        {
            bot->SetSkill(prof.skill, uint16(tier + 1), target, uint16((tier + 1) * 75));
            learned = true;
        }
        if (prof.tool && !bot->HasItemCount(prof.tool, 1, false))
            bot->StoreNewItemInBestSlots(prof.tool, 1);
        if (prof.skill == SKILL_ENGINEERING && !bot->HasItemCount(EngineeringExtraTool, 1, false))
            bot->StoreNewItemInBestSlots(EngineeringExtraTool, 1);
        if (learned)
            Count(BLC_PROFESSION_SET);
        // crafting: the trainer recipes up to the skill
        if (IsCraftSkill(prof.skill) && bot->HasSkill(prof.skill))
        {
            auto recipes = _craftRecipes.find(prof.skill);
            if (recipes == _craftRecipes.end())
                continue;
            uint16 skill = bot->GetSkillValue(prof.skill);
            uint32 newRecipes = 0;
            for (auto const& recipe : recipes->second)   // highest first; 40 per check spreads the first wave
                if (recipe.second <= skill && !bot->HasSpell(recipe.first) && newRecipes < 40)
                {
                    bot->LearnSpell(recipe.first, false);
                    ++newRecipes;
                }
            if (newRecipes)
                Count(BLC_RECIPE_LEARNED, newRecipes);
        }
    }

    // cooking and fishing for everybody
    for (GatherProfession const* prof : SecondaryProfessions)
    {
        bool learned = false;
        for (uint32 r = 0; r <= tier; ++r)
            if (!bot->HasSpell(prof->ranks[r]))
            {
                bot->LearnSpell(prof->ranks[r], false);
                learned = true;
            }
        if (bot->GetSkillValue(prof->skill) < target)
        {
            bot->SetSkill(prof->skill, uint16(tier + 1), target, uint16((tier + 1) * 75));
            learned = true;
        }
        if (learned)
            Count(BLC_PROFESSION_SET);
        auto recipes = _craftRecipes.find(prof->skill);
        if (recipes == _craftRecipes.end() || !bot->HasSkill(prof->skill))
            continue;
        uint16 const skill = bot->GetSkillValue(prof->skill);
        uint32 newRecipes = 0;
        for (auto const& recipe : recipes->second)
            if (recipe.second <= skill && !bot->HasSpell(recipe.first) && newRecipes < 40)
            {
                bot->LearnSpell(recipe.first, false);
                ++newRecipes;
            }
        if (newRecipes)
            Count(BLC_RECIPE_LEARNED, newRecipes);
    }

    // one of the six Ways of Pandaren cooking for a cook of the level cap
    if (bot->GetLevel() >= 90 && bot->GetSkillValue(SKILL_COOKING) >= 525)
    {
        GatherProfession const* way = Ways[bot->GetGUID().GetCounter() % 6];
        if (!bot->HasSkill(way->skill))
        {
            bot->SetSkill(way->skill, 1, 600, 600);
            Count(BLC_PROFESSION_SET);
        }
        auto recipes = _craftRecipes.find(way->skill);
        if (recipes != _craftRecipes.end())
            for (auto const& recipe : recipes->second)
                if (!bot->HasSpell(recipe.first))
                {
                    bot->LearnSpell(recipe.first, false);
                    Count(BLC_RECIPE_LEARNED);
                }
    }

    // archaeology for one bot in four, from level 20 (SetSkill hands out the dig sites and projects)
    if (_archaeology && bot->GetLevel() >= 20 && bot->GetGUID().GetCounter() % 4 == 0)
    {
        bool learned = false;
        for (uint32 r = 0; r <= tier; ++r)
            if (!bot->HasSpell(Archaeology.ranks[r]))
            {
                bot->LearnSpell(Archaeology.ranks[r], false);
                learned = true;
            }
        if (bot->GetSkillValue(SKILL_ARCHAEOLOGY) < target)
        {
            bot->SetSkill(SKILL_ARCHAEOLOGY, uint16(tier + 1), target, uint16((tier + 1) * 75));
            learned = true;
        }
        if (learned)
            Count(BLC_PROFESSION_SET);
    }
}

// blacksmithing and engineering recipes ask for an anvil, smelting for a forge. A smith / engineer goes
// to the nearest anvil of the town, a miner without those to the forge; they stand next to each other in most towns.
// True when the bot is on its way (the town visit carries on there).
bool BotLifeMgr::GoToForge(Player* bot, BotLifeInfo& t)
{
    bool const anvil = bot->HasSkill(SKILL_BLACKSMITHING) || bot->HasSkill(SKILL_ENGINEERING);
    if (!anvil && !bot->HasSkill(SKILL_MINING))
        return false;
    uint32 const focusId = anvil ? SpellFocusAnvil : SpellFocusForge;
    if (FocusNear(bot, focusId))
        return false;   // already there
    GameObject* focus = FindFocusObject(bot, focusId, 150.0f);
    if (!focus)
        return false;
    float const angle = frand(0.0f, 2 * float(M_PI));
    SetDest(t, bot->GetMapId(), focus->GetPositionX() + std::cos(angle) * 3.0f, focus->GetPositionY() + std::sin(angle) * 3.0f,
        focus->GetPositionZ(), 3.0f);
    return true;
}

// the guild bank is the crafters' store room. Gatherers fill the materials tab, a crafter on a town
// visit takes what its highest recipe is short of (enough for the crafts of this visit; vendor reagents are bought at
// the cast). World thread (ProcessTownBusiness): the bank is shared by all maps. One recipe per visit, and nothing when
// the bags already hold a full recipe. The withdrawals count against the member rank's daily slots of the tab.
void BotLifeMgr::CraftSupply(Player* bot)
{
    Guild* guild = sGuildMgr->GetGuildById(bot->GetGuildId());
    if (!_professions || !guild || !IsBotGuild(guild) || !guild->GetPurchasedTabsSize())
        return;
    bool crafter = false;
    for (GatherProfession const* prof : CraftProfessions)
        if (IsCraftSkill(prof->skill) && bot->HasSkill(prof->skill))
            crafter = true;
    if (!crafter)
        return;

    // 
    static uint8 const supplyTabs[3] = { 0, 4, 6 };
    uint8 const supplyTabCount = guild->GetPurchasedTabsSize() > 6 ? 3 : guild->GetPurchasedTabsSize() > 4 ? 2 : 1;
    std::unordered_map<uint32, uint32> bank;   // entry -> count
    for (uint8 k = 0; k < supplyTabCount; ++k)
        for (uint8 slot = 0; slot < GUILD_BANK_MAX_SLOTS; ++slot)
            if (Item* item = guild->GetBankItem(supplyTabs[k], slot))
                bank[item->GetEntry()] += item->GetCount();
    if (bank.empty())
        return;

    for (GatherProfession const* prof : CraftProfessions)
    {
        if (!IsCraftSkill(prof->skill) || !bot->HasSkill(prof->skill))
            continue;
        auto recipes = _craftRecipes.find(prof->skill);
        if (recipes == _craftRecipes.end())
            continue;
        uint16 skill = bot->GetSkillValue(prof->skill);
        uint32 looked = 0;
        for (auto const& recipe : recipes->second)   // highest required skill first
        {
            if (recipe.second > skill || !bot->HasSpell(recipe.first))
                continue;
            if (++looked > 400)
                break;
            SpellInfo const* info = sSpellMgr->GetSpellInfo(recipe.first);
            if (!info || (info->RequiresSpellFocus && !FocusNear(bot, info->RequiresSpellFocus)))
                continue;

            // every reagent in the bags or the bank (or sold by a vendor), and at least one that is not vendor stuff
            uint32 casts = std::max<uint32>(1, _craftsPerVisit);
            bool feasible = true, real = false, needBank = false;
            for (uint32 i = 0; i < MAX_SPELL_REAGENTS && feasible; ++i)
            {
                if (info->Reagent[i] <= 0)
                    continue;
                uint32 const item = uint32(info->Reagent[i]);
                uint32 const need = std::max<uint32>(1, info->ReagentCount[i]);
                uint32 const have = bot->GetItemCount(item, false);
                auto stock = bank.find(item);
                uint32 const avail = have + (stock != bank.end() ? stock->second : 0);
                if (avail >= need)
                {
                    real = true;
                    casts = std::min(casts, avail / need);
                    if (have < need)
                        needBank = true;
                }
                else if (!s_vendorReagents.count(item))
                    feasible = false;
            }
            if (!feasible || !real)
                continue;
            if (!needBank)
                return;   // the bags already hold this recipe

            for (uint32 i = 0; i < MAX_SPELL_REAGENTS; ++i)
            {
                if (info->Reagent[i] <= 0)
                    continue;
                uint32 const item = uint32(info->Reagent[i]);
                uint32 const want = std::max<uint32>(1, info->ReagentCount[i]) * casts;
                uint32 const have = bot->GetItemCount(item, false);
                if (have >= want || !bank.count(item))
                    continue;
                uint32 shortBy = want - have;
                for (uint32 pos = 0; pos < uint32(supplyTabCount) * GUILD_BANK_MAX_SLOTS && shortBy; ++pos)
                {
                    uint8 const tab = supplyTabs[pos / GUILD_BANK_MAX_SLOTS];
                    uint8 const slot = uint8(pos % GUILD_BANK_MAX_SLOTS);
                    Item* stack = guild->GetBankItem(tab, slot);
                    if (!stack || stack->GetEntry() != item)
                        continue;
                    uint32 const take = std::min<uint32>(shortBy, stack->GetCount());
                    bool const whole = take == stack->GetCount();
                    guild->SwapItemsWithInventory(bot, true, tab, slot, NULL_BAG, NULL_SLOT, whole ? 0 : take);
                    uint32 const now = bot->GetItemCount(item, false);
                    if (now + shortBy <= want)
                        return;   // nothing came: no slots left today, or the bags are full
                    shortBy = now >= want ? 0 : want - now;
                    Count(BLC_CRAFT_SUPPLY);
                }
            }
            return;   // one recipe per visit
        }
    }
}

bool BotLifeMgr::CraftBusiness(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    if (!_professions || (!t.craftsLeft && !t.craftSpell))
        return false;
    if (bot->IsNonMeleeSpellCasted(false))
        return true;   // the craft cast is running
    t.craftSpell = 0;
    if (!t.craftsLeft || bot->IsInCombat())
        return false;
    if (now < t.nextCraft)
        return true;

    // first turn herbs into pigments, ore into gems, spare gear into dust (once a visit)
    if (!t.refined)
    {
        t.refined = true;
        if (uint32 const batches = RefineMaterials(bot, 6))
        {
            Count(BLC_REFINE, batches);
            bot->StopMoving();
            t.nextCraft = now + 2000;
            return true;
        }
    }

    // the highest recipe we have the materials for (best skill-ups, most valuable result); a little randomness
    uint32 choices[3] = {};
    uint32 found = 0;
    bool wantFire = false;
    for (GatherProfession const* prof : CraftProfessions)
    {
        if (!IsCraftSkill(prof->skill) || !bot->HasSkill(prof->skill))
            continue;
        auto recipes = _craftRecipes.find(prof->skill);
        if (recipes == _craftRecipes.end())
            continue;
        uint16 skill = bot->GetSkillValue(prof->skill);
        for (auto const& recipe : recipes->second)
        {
            if (found >= 3)
                break;
            if (recipe.second > skill || !bot->HasSpell(recipe.first) || t.craftFailed.count(recipe.first))
                continue;
            SpellInfo const* info = sSpellMgr->GetSpellInfo(recipe.first);
            if (!info || !HasReagents(bot, info))
                continue;
            if (info->RequiresSpellFocus && !FocusNear(bot, info->RequiresSpellFocus))
            {
                if (info->RequiresSpellFocus == SpellFocusCookingFire)
                    wantFire = true;   // a cook lights a fire of its own (below)
                continue;
            }
            bool fits = true;
            if (uint32 const made = CraftProduct(info))
            {
                ItemPosCountVec dest;
                if (bot->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, made, 1) != EQUIP_ERR_OK)
                    fits = false;
            }
            if (fits)
                choices[found++] = recipe.first;
        }
    }
    if (!found && wantFire && !t.fireMade)
    {
        t.fireMade = true;
        bot->StopMoving();
        bot->CastSpell(bot, BasicCampfire, true);
        t.nextCraft = now + 1500;
        return true;
    }
    if (!found)
    {
        t.craftsLeft = 0;
        return false;
    }
    uint32 spell = choices[urand(0, found - 1)];
    uint32 product = 0;
    bool scroll = false;
    if (SpellInfo const* info = sSpellMgr->GetSpellInfo(spell))
        product = CraftProduct(info, &scroll);
    uint32 before = product ? bot->GetItemCount(product) : 0;
    bot->StopMoving();
    // buy what the recipe is short of from "the vendor around the corner"
    if (SpellInfo const* info = sSpellMgr->GetSpellInfo(spell))
    {
        std::vector<std::pair<uint32, uint32>> toBuy;
        if (HasReagents(bot, info, &toBuy))
            for (auto const& entry : toBuy)
            {
                ItemPosCountVec dest;
                if (bot->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, entry.first, entry.second) != EQUIP_ERR_OK)
                    break;   // no room: the cast fails on the reagent and the recipe is skipped this visit
                bot->StoreNewItem(dest, entry.first, true);
                bot->ModifyMoney(-int64(uint64(s_vendorReagents[entry.first]) * entry.second));
            }
    }
    if (scroll)
    {
        // an enchantment goes on a vellum (a vendor sells those) and comes out as a scroll
        Item* vellum = bot->GetItemByEntry(EnchantingVellum);
        if (!vellum)
        {
            auto price = s_vendorReagents.find(EnchantingVellum);
            uint64 const cost = uint64(price != s_vendorReagents.end() ? price->second : 1000) * 5;
            ItemPosCountVec dest;
            if (bot->GetMoney() >= cost + 1 * GOLD && bot->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, EnchantingVellum, 5) == EQUIP_ERR_OK)
            {
                vellum = bot->StoreNewItem(dest, EnchantingVellum, true);
                bot->ModifyMoney(-int64(cost));
            }
        }
        if (vellum)
            if (SpellInfo const* info = sSpellMgr->GetSpellInfo(spell))
            {
                SpellCastTargets targets;
                targets.SetItemTarget(vellum);
                Spell* cast = new Spell(bot, info, TRIGGERED_NONE);
                cast->prepare(&targets);
                Count(BLC_ENCHANT_SCROLL);
            }
    }
    else
        bot->CastSpell(bot, spell, false);
    --t.craftsLeft;
    t.nextCraft = now + 1500;
    if (bot->IsNonMeleeSpellCasted(false) || (product && bot->GetItemCount(product) > before))
    {
        t.craftSpell = spell;
        Count(BLC_CRAFT);
    }
    else
    {
        t.craftFailed.insert(spell);   // focus, tool or another cast check: not again this visit
        Count(BLC_CRAFT_FAIL);
    }
    return true;
}

bool BotLifeMgr::GatherBusiness(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();

    // our gathering cast opened the loot: take everything
    if (!t.gatherTarget.IsEmpty() && bot->GetLootGUID() == t.gatherTarget)
    {
        Loot* loot = nullptr;
        if (t.gatherTarget.IsGameObject())
        {
            if (GameObject* go = ObjectAccessor::GetGameObject(*bot, t.gatherTarget))
                loot = &go->loot;
        }
        else if (Creature* c = ObjectAccessor::GetCreature(*bot, t.gatherTarget))
            loot = &c->loot;
        if (loot)
            LootAll(bot, loot, t.gatherTarget);
        else
            bot->GetSession()->DoLootRelease(t.gatherTarget);
        Count(t.gatherTarget.IsGameObject() ? BLC_GATHER_NODE : BLC_GATHER_SKIN);
        t.gatherTarget.Clear();
        return true;
    }

    if (!t.gatherTarget.IsEmpty())
    {
        if (bot->HasUnitState(UNIT_STATE_CASTING))
            return true;   // gathering
        WorldObject* target = t.gatherTarget.IsGameObject() ? static_cast<WorldObject*>(ObjectAccessor::GetGameObject(*bot, t.gatherTarget))
                                                            : static_cast<WorldObject*>(ObjectAccessor::GetCreature(*bot, t.gatherTarget));
        bool valid = target && (t.gatherTarget.IsGameObject() ? static_cast<GameObject*>(target)->getLootState() == GO_READY
                                                              : static_cast<Creature*>(target)->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_SKINNABLE));
        if (!valid || t.gatherCasts >= 3 || now - t.gatherSince > 30000)
        {
            if (t.usedGos.size() > 32)
                t.usedGos.clear();
            t.usedGos[t.gatherTarget] = now + 5 * MINUTE * IN_MILLISECONDS;
            t.gatherTarget.Clear();
            return false;
        }
        if (bot->GetExactDist(target) > INTERACTION_DISTANCE - 1.0f)
        {
            if (!bot->isMoving() || now - t.lastMoveOrder > 3000)
            {
                bot->GetMotionMaster()->MovePoint(0, target->GetPositionX(), target->GetPositionY(), target->GetPositionZ(), true);
                t.lastMoveOrder = now;
            }
            return true;
        }
        bot->StopMoving();
        bot->GetMotionMaster()->Clear();
        ++t.gatherCasts;
        if (t.gatherTarget.IsGameObject())
            bot->CastSpell(static_cast<GameObject*>(target), t.gatherSpell, false);
        else
            bot->CastSpell(static_cast<Creature*>(target), t.gatherSpell, false);
        return true;
    }

    if (now < t.nextGatherSearch)
        return false;
    t.nextGatherSearch = now + 5000;

    uint16 herb = bot->HasSkill(SKILL_HERBALISM) ? bot->GetSkillValue(SKILL_HERBALISM) : 0;
    uint16 mine = bot->HasSkill(SKILL_MINING) ? bot->GetSkillValue(SKILL_MINING) : 0;
    bool skin = bot->HasSkill(SKILL_SKINNING);
    if (!herb && !mine && !skin)
        return false;

    CellCoord pair(Trinity::ComputeCellCoord(bot->GetPositionX(), bot->GetPositionY()));
    Cell cell(pair);
    cell.SetNoCreate();

    if (herb || mine)
    {
        GatherNodeCheck check{ bot, 30.0f, herb, mine };
        std::list<GameObject*> nodes;
        Trinity::GameObjectListSearcher<GatherNodeCheck> searcher(bot, nodes, check);
        TypeContainerVisitor<Trinity::GameObjectListSearcher<GatherNodeCheck>, GridTypeMapContainer> visitor(searcher);
        cell.Visit(pair, visitor, *bot->GetMap(), *bot, 30.0f);
        GameObject* best = nullptr;
        for (GameObject* go : nodes)
        {
            auto used = t.usedGos.find(go->GetGUID());
            if (used != t.usedGos.end() && now < used->second)
                continue;
            if (!best || bot->GetExactDist(go) < bot->GetExactDist(best))
                best = go;
        }
        if (best)
        {
            // which lock the node has decides the spell
            LockEntry const* lock = sLockStore.LookupEntry(best->GetGOInfo()->GetLockId());
            bool isHerb = false;
            for (uint32 i = 0; lock && i < MAX_LOCK_CASE; ++i)
                if (lock->Type[i] == LOCK_KEY_SKILL && lock->Index[i] == LOCKTYPE_HERBALISM)
                    isHerb = true;
            t.gatherTarget = best->GetGUID();
            t.gatherSpell = isHerb ? Herbalism.ranks[0] : Mining.ranks[0];
            t.gatherSince = now;
            t.gatherCasts = 0;
            return true;
        }
    }

    if (skin)
    {
        SkinnableCorpseCheck check{ bot, 20.0f };
        std::list<Creature*> corpses;
        Trinity::CreatureListSearcher<SkinnableCorpseCheck> searcher(bot, corpses, check);
        TypeContainerVisitor<Trinity::CreatureListSearcher<SkinnableCorpseCheck>, GridTypeMapContainer> visitor(searcher);
        cell.Visit(pair, visitor, *bot->GetMap(), *bot, 20.0f);
        for (Creature* c : corpses)
        {
            auto used = t.usedGos.find(c->GetGUID());
            if (used != t.usedGos.end() && now < used->second)
                continue;
            if (!botAI->CanCastSpell(Skinning.ranks[0], c, true))
                continue;   // skill too low for this creature
            t.gatherTarget = c->GetGUID();
            t.gatherSpell = Skinning.ranks[0];
            t.gatherSince = now;
            t.gatherCasts = 0;
            return true;
        }
    }
    return false;
}

// nobody fishes: a solo bot that stands near fishable water now and then stops for a few casts.
// The real spell, the bobber of the core, and a click on it when it splashes; the catch is the fishing loot of the zone.
bool BotLifeMgr::FishBusiness(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();

    // the catch: our click on the bobber opened its loot (or that of the school of fish it landed in)
    if (!t.fishBobber.IsEmpty() && bot->GetLootGUID() == t.fishBobber)
    {
        if (GameObject* source = ObjectAccessor::GetGameObject(*bot, t.fishBobber))
            LootAll(bot, &source->loot, t.fishBobber);
        else
            bot->GetSession()->DoLootRelease(t.fishBobber);
        Count(BLC_FISH_CATCH);
        t.fishBobber.Clear();
        t.fishNextCast = now + urand(1500, 4000);
        return true;
    }

    // the line is out: wait for the splash, then click the bobber
    if (GameObject* bobber = FishingBobber(bot))
    {
        if (bobber->getLootState() == GO_READY)
        {
            bobber->Use(bot);
            t.fishBobber = bot->GetLootGUID();   // empty: it got away
            t.fishNextCast = now + urand(1500, 3000);
        }
        return true;
    }
    t.fishBobber.Clear();

    if (!t.fishCastsLeft)
    {
        if (now < t.nextFishCheck)
            return false;
        t.nextFishCheck = now + urand(45, 120) * IN_MILLISECONDS;
        if (!t.nextFishSession)
        {
            t.nextFishSession = now + urand(0, _fishingMinutes) * MINUTE * IN_MILLISECONDS;
            return false;
        }
        if (now < t.nextFishSession || !bot->HasSkill(SKILL_FISHING) || bot->GetGroup() || bot->GetMap()->Instanceable()
            || bot->IsInWater() || t.state == BotLifeState::TOWN || t.state == BotLifeState::DIG || bot->IsNonMeleeSpellCasted(false))
            return false;
        // water the bobber can land in: the cast puts it 10 to 20 yd ahead, so all of that stretch has to be water
        Map* map = bot->GetMap();
        float const bz = bot->GetPositionZ();
        float const start = frand(0.0f, 2 * float(M_PI));
        for (uint32 i = 0; i < 16 && !t.fishCastsLeft; ++i)
        {
            float const angle = start + i * float(M_PI) / 8.0f;
            bool water = true;
            float level = bz;
            for (float dist : { 11.0f, 15.0f, 19.0f })
            {
                float const x = bot->GetPositionX() + std::cos(angle) * dist, y = bot->GetPositionY() + std::sin(angle) * dist;
                LiquidData liquid;
                ZLiquidStatus const status = map->GetLiquidStatus(bot->GetPhaseMask(), x, y, bz + 2.0f,
                    MAP_LIQUID_TYPE_WATER | MAP_LIQUID_TYPE_OCEAN, &liquid);
                if (status == LIQUID_MAP_NO_WATER || liquid.level > bz + 1.0f || liquid.level < bz - 12.0f
                    || liquid.level - liquid.depth_level < 1.0f)
                {
                    water = false;
                    break;
                }
                level = liquid.level;
            }
            if (!water || !bot->IsWithinLOS(bot->GetPositionX() + std::cos(angle) * 15.0f, bot->GetPositionY() + std::sin(angle) * 15.0f, level + 0.5f))
                continue;
            t.fishAngle = Position::NormalizeOrientation(angle);
            t.fishX = bot->GetPositionX();
            t.fishY = bot->GetPositionY();
            t.fishCastsLeft = urand(3, 6);
            t.fishNextCast = now;
            t.nextFishSession = now + urand(_fishingMinutes * 2 / 3, _fishingMinutes * 4 / 3) * MINUTE * IN_MILLISECONDS;
        }
        if (!t.fishCastsLeft)
            return false;
    }

    if (now < t.fishNextCast || bot->IsNonMeleeSpellCasted(false))
        return true;
    // walked or was pulled away: the session is over
    if (bot->GetExactDist2d(t.fishX, t.fishY) > 4.0f || bot->IsInWater())
    {
        t.fishCastsLeft = 0;
        return false;
    }
    bot->StopMoving();
    bot->GetMotionMaster()->Clear();
    if (bot->IsSitState())
        bot->SetStandState(UNIT_STAND_STATE_STAND);
    bot->SetFacingTo(t.fishAngle);
    --t.fishCastsLeft;
    bot->CastSpell(bot, FishingSpell, false);
    t.fishNextCast = now + 2500;
    if (!bot->IsNonMeleeSpellCasted(false))
    {
        t.fishCastsLeft = 0;   // the cast failed: no fishable water after all
        return false;
    }
    Count(BLC_FISH_CAST);
    return true;
}

// no archaeology: one bot in four digs. Now and then it rides to one of its own dig sites on the
// continent (in a zone of its level), surveys at the find (a bot knows where the find is - a player needs a few casts to
// home in on it), takes the fragments out of it and solves the project it has the fragments for.
bool BotLifeMgr::StartDig(Player* bot, BotLifeInfo& t, uint32 now)
{
    t.nextDig = now + urand(_digMinutes * 2 / 3, _digMinutes * 4 / 3) * MINUTE * IN_MILLISECONDS;
    int32 continent = -1;
    for (uint32 i = 0; i < RESEARCH_CONTINENT_COUNT; ++i)
        if (ResearchContinents[i] == bot->GetMapId())
            continent = int32(i);
    if (continent < 0 || bot->GetMap()->Instanceable())
        return false;

    ArchaeologyFindInfo const* best = nullptr;
    float bestDist = 2500.0f;
    for (uint32 j = 0; j < MAX_DIGSITES_PER_CONTINENT; ++j)
    {
        uint32 const site = bot->GetDynamicUInt32Value(PLAYER_DYNAMIC_FIELD_RESERACH_SITE, uint16(continent * MAX_DIGSITES_PER_CONTINENT + j));
        ArchaeologyFindList const* finds = site ? sObjectMgr->GetArcheologyFindListForDigsite(site) : nullptr;
        if (!finds || finds->empty())
            continue;
        ArchaeologyFindInfo const& find = finds->front();
        float const dist = bot->GetExactDist2d(find.x, find.y);
        if (dist >= bestDist)
            continue;
        // not into a zone the bot is too small for
        auto zone = _zoneLevels.find(bot->GetMap()->GetZoneId(bot->GetPhaseMask(), find.x, find.y, find.z));
        if (zone != _zoneLevels.end() && int32(bot->GetLevel()) + 3 < int32(zone->second.low))
            continue;
        best = &find;
        bestDist = dist;
    }
    if (!best)
        return false;
    SetState(bot, t, BotLifeState::DIG, now, 15 * MINUTE * IN_MILLISECONDS);
    SetDest(t, bot->GetMapId(), best->x, best->y, best->z, 6.0f);
    t.digCastAt = 0;
    t.digFinds = 0;
    t.digMisses = 0;
    return true;
}

bool BotLifeMgr::DigBusiness(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    if (bot->IsNonMeleeSpellCasted(false))
        return true;   // surveying, or solving a project

    // the survey dug something up: the find is there for half a minute
    if (t.digCastAt)
    {
        t.digCastAt = 0;
        GameObject* find = bot->GetMap()->GetGameObject(bot->m_ObjectSlot[1]);
        if (find && find->GetGoType() == GAMEOBJECT_TYPE_CHEST && bot->GetExactDist(find) < 15.0f)
        {
            ObjectGuid const guid = find->GetGUID();
            bot->SendLoot(guid, LOOT_CORPSE);
            if (bot->GetLootGUID() == guid)
                LootAll(bot, &find->loot, guid);
            Count(BLC_DIG_FIND);
            ++t.digFinds;
            t.digMisses = 0;
            if (SolveResearchProject(bot))
            {
                Count(BLC_DIG_SOLVE);
                return true;
            }
        }
        else if (++t.digMisses >= 3)
        {
            SetState(bot, t, BotLifeState::IDLE, now, 0);   // the find is out of reach (under the ground, on a ledge)
            return false;
        }
    }

    ResearchDigsite* site = bot->GetCurrentResearchDigsite();
    ArchaeologyFindInfo const* find = site ? site->GetArchaeologyFind() : nullptr;
    if (!find)
    {
        // still on the way to the site - or the site is used up, or cannot be reached
        if (!site && t.hasDest && !Arrived(bot, t))
        {
            Travel(bot, t, now);
            if (t.hasDest)
                return true;
        }
        SetState(bot, t, BotLifeState::IDLE, now, 0);
        return false;
    }
    if (bot->GetExactDist2d(find->x, find->y) > 4.0f)
    {
        if (!t.hasDest || std::fabs(t.destX - find->x) > 0.5f || std::fabs(t.destY - find->y) > 0.5f)
            SetDest(t, bot->GetMapId(), find->x, find->y, find->z, 3.0f);
        Travel(bot, t, now);
        if (!t.hasDest)
        {
            SetState(bot, t, BotLifeState::IDLE, now, 0);
            return false;
        }
        return true;
    }
    bot->StopMoving();
    if (bot->IsMounted())
        Dismount(bot);
    bot->CastSpell(bot, SurveySpell, false);
    t.digCastAt = now;
    Count(BLC_DIG_SURVEY);
    return true;
}
