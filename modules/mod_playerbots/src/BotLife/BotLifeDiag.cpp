/*
 * BotLife diagnostics that must run on the bot's own map thread.
 * ".botlife castdiag [n]": the next n caster bots in combat log why (not) they can cast their main spells.
 */

#include "BotLife.h"
#include "CharacterCache.h"
#include "ObjectMgr.h"
#include "Playerbots.h"
#include "RandomPlayerbotMgr.h"
#include <sstream>
#include "ThreadOwnerCheck.h"
#include "Chat.h"

#include "CellImpl.h"
#include "DatabaseEnv.h"
#include "CreatureAI.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "ObjectAccessor.h"
#include "Log.h"
#include "MotionMaster.h"
#include "MoveSpline.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "Playerbots.h"
#include "Spell.h"
#include "SpellHistory.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "MapManager.h"
#include "Pet.h"
#include "PathGenerator.h"
#include "BotFactory.h"
#include "TemporarySummon.h"
#include "DynamicObject.h"

#include <algorithm>
#include <sstream>

namespace
{
    std::vector<std::string> const* CastDiagSpells(uint8 cls)
    {
        static std::vector<std::string> const mage = { "frostbolt", "fireball", "arcane blast", "frostfire bolt", "ice lance", "fire blast" };
        static std::vector<std::string> const warlock = { "shadow bolt", "incinerate", "malefic grasp", "corruption", "conflagrate" };
        static std::vector<std::string> const priest = { "smite", "mind flay", "mind blast", "flash heal", "shadow word: pain" };
        static std::vector<std::string> const shaman = { "lightning bolt", "lava burst", "healing wave", "flame shock", "earth shock" };
        static std::vector<std::string> const druid = { "wrath", "starfire", "moonfire", "mangle", "shred", "rake", "rip", "maul" };
        static std::vector<std::string> const warrior = { "mortal strike", "bloodthirst", "colossus smash", "heroic strike", "execute", "shield slam", "devastate" };
        static std::vector<std::string> const paladin = { "crusader strike", "judgment", "templar's verdict", "hammer of the righteous", "exorcism", "holy shock" };
        static std::vector<std::string> const rogue = { "sinister strike", "eviscerate", "mutilate", "slice and dice", "revealing strike" };
        static std::vector<std::string> const dk = { "icy touch", "plague strike", "obliterate", "frost strike", "death strike", "heart strike", "scourge strike", "death coil" };
        static std::vector<std::string> const hunter = { "explosive shot", "steady shot", "cobra shot", "auto shot", "arcane shot" };
        static std::vector<std::string> const monk = { "keg smash", "jab", "tiger palm", "blackout kick", "surging mist", "stance of the sturdy ox" };
        switch (cls)
        {
            case CLASS_MAGE: return &mage;
            case CLASS_WARLOCK: return &warlock;
            case CLASS_PRIEST: return &priest;
            case CLASS_SHAMAN: return &shaman;
            case CLASS_DRUID: return &druid;
            case CLASS_HUNTER: return &hunter;
            case CLASS_MONK: return &monk;
            case CLASS_WARRIOR: return &warrior;
            case CLASS_PALADIN: return &paladin;
            case CLASS_ROGUE: return &rogue;
            case CLASS_DEATH_KNIGHT: return &dk;
            default: return nullptr;
        }
    }
}

void BotLifeMgr::CastDiag(PlayerbotAI* botAI)
{
    Player* bot = botAI->GetBot();
    std::vector<std::string> const* spells = CastDiagSpells(bot->GetClass());
    if (!spells)
        return;
    if (_castDiagLeft.fetch_sub(1, std::memory_order_relaxed) <= 0)
        return;

    Unit* target = botAI->GetAiObjectContext()->GetValue<Unit*>("current target")->Get();
    std::ostringstream out;
    out << "CASTDIAG " << bot->GetName() << " cls " << uint32(bot->GetClass()) << " spec " << uint32(bot->GetSpecialization())
        << " lvl " << uint32(bot->GetLevel()) << " state " << uint32(botAI->GetState())
        << " moving " << bot->isMoving() << " mflags 0x" << std::hex << bot->GetUnitMovementFlags() << std::dec
        << " motion " << uint32(bot->GetMotionMaster()->GetCurrentMovementGeneratorType())
        << " casting " << bot->HasUnitState(UNIT_STATE_CASTING)
        << " cur " << (bot->GetCurrentSpell(CURRENT_GENERIC_SPELL) ? bot->GetCurrentSpell(CURRENT_GENERIC_SPELL)->m_spellInfo->Id : 0)
        << "/" << (bot->GetCurrentSpell(CURRENT_CHANNELED_SPELL) ? bot->GetCurrentSpell(CURRENT_CHANNELED_SPELL)->m_spellInfo->Id : 0) << " mana " << bot->GetPower(POWER_MANA)
        << " rage " << bot->GetPower(POWER_RAGE) << " energy " << bot->GetPower(POWER_ENERGY) << " rp " << bot->GetPower(POWER_RUNIC_POWER)
        << " holy " << bot->GetPower(POWER_HOLY_POWER) << " chi " << bot->GetPower(POWER_CHI) << " cp " << uint32(bot->GetComboPoints());
    if (target)
        out << " target " << target->GetName() << " dist " << bot->GetDistance(target) << " los " << bot->IsWithinLOSInMap(target);
    else
        out << " target none";
    out << " victim " << (bot->GetVictim() ? bot->GetVictim()->GetName() : "none") << " |";
    for (std::string const& name : *spells)
    {
        uint32 id = botAI->GetAiObjectContext()->GetValue<uint32>("spell id", name)->Get();
        if (!id)
        {
            out << " " << name << ":-";
            continue;
        }
        SpellInfo const* info = sSpellMgr->GetSpellInfo(id);
        out << " " << name << ":" << id << (botAI->CanCastSpell(id, target, true) ? ":OK" : ":no")
            << (info && bot->GetSpellHistory()->IsReady(info, 0, false) ? ":rdy" : ":cd")
            << ":" << (info ? info->CalcCastTime(bot->GetLevel()) : 0) << "ms";
        // why: CheckCast result as CanCastSpell sees it (c) and as the strict pre-cast check in CastSpell sees it (s),
        // plus a pending retry block (b = ms left)
        if (info && target)
        {
            Unit* oldSel = bot->GetSelectedUnit();
            Spell* test = new Spell(bot, info, TRIGGERED_IGNORE_POWER_AND_REAGENT_COST);
            test->m_targets.SetUnitTarget(target);
            out << ":c" << uint32(test->CheckCast(true));
            delete test;
            if (oldSel)
                bot->SetSelection(oldSel->GetGUID());
        }
        auto blocked = botAI->_spellRetryBlock.find(id);
        if (blocked != botAI->_spellRetryBlock.end() && getMSTimeDiff(getMSTime(), blocked->second) < 60000)
            out << ":b" << getMSTimeDiff(getMSTime(), blocked->second);
    }
    out << " | strat";
    for (std::string const& s : botAI->GetStrategies(BOT_STATE_COMBAT))
        out << " " << s;
    TC_LOG_INFO("playerbots", "{}", out.str());
}

// ".botlife aggrodiag [n]": the next n bots fighting a creature that is neutral to all log whether it fights back
void BotLifeMgr::AggroDiag(PlayerbotAI* botAI)
{
    Player* bot = botAI->GetBot();
    Unit* victim = bot->GetVictim();
    Creature* creature = victim ? victim->ToCreature() : nullptr;
    if (!creature || !creature->IsNeutralToAll() || creature->IsCivilian())
        return;
    if (_aggroDiagLeft.fetch_sub(1, std::memory_order_relaxed) <= 0)
        return;
    Unit* cv = creature->GetVictim();
    TC_LOG_INFO("playerbots", "AGGRODIAG bot {} lvl {} vs {} ({}) lvl {} hp {:.0f}% dist {:.1f} | c.combat {} engaged {} victim {} threat {} react {} evade {} attackers {} ai {}",
        bot->GetName(), uint32(bot->GetLevel()), creature->GetName(), creature->GetEntry(), uint32(creature->GetLevel()),
        creature->GetHealthPct(), bot->GetDistance(creature), creature->IsInCombat(), creature->IsAIEnabled && creature->AI()->IsEngaged(),
        cv ? cv->GetName() : "none", uint32(creature->GetThreatManager().GetThreatListSize()), uint32(creature->GetReactState()),
        creature->IsInEvadeMode(), uint32(creature->getAttackers().size()), creature->GetAIName());
}

// ".botlife rangetest [n]": n caster bots shoot one (triggered) nuke at a neutral creature 15-30 yd away and report
// 4 s later whether it fights back (repro: Adult Plainstrider ignores a druid's Wrath, reacts to melee)
namespace
{
    struct NeutralCreatureInRange
    {
        WorldObject const* me;
        bool operator()(Creature* c) const
        {
            return c->IsAlive() && c->IsNeutralToAll() && !c->IsCivilian() && !c->IsInCombat() && !c->IsTrigger()
                && me->GetDistance(c) > 15.0f && me->IsWithinDistInMap(c, 30.0f);
        }
    };

    uint32 RangeTestSpell(Player* bot)
    {
        static std::vector<uint32> const spells = { 5176 /*wrath*/, 116 /*frostbolt*/, 133 /*fireball*/, 686 /*shadow bolt*/,
            585 /*smite*/, 403 /*lightning bolt*/ };
        for (uint32 id : spells)
            if (bot->HasSpell(id))
                return id;
        return 0;
    }
}

// test lab - raise solo bots to a level (their own map thread)
void BotLifeMgr::StartTestLevel(uint32 level, int32 count, uint8 role)
{
    _testLevelRole.store(role, std::memory_order_relaxed);   // optional tank/heal class filter
    _testLevel.store(level, std::memory_order_relaxed);
    _testLevelLeft.store(count, std::memory_order_release);
}

bool BotLifeMgr::TestLevelBot(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    uint32 const level = _testLevel.load(std::memory_order_relaxed);
    if (IsWalker(bot))   // the walkers keep their own level
        return false;
    if (!level || bot->GetLevel() >= level || bot->GetGroup() || t.banker || !bot->IsAlive() || bot->IsInCombat()
        || bot->GetMap()->Instanceable() || bot->IsBeingTeleported() || bot->IsInFlight())
        return false;
    // role filter - a class that does not fit is skipped and does not count (check before the fetch_sub)
    if (uint8 const role = _testLevelRole.load(std::memory_order_relaxed))
    {
        uint8 const cls = bot->GetClass();
        bool const fits = role == 1 ? (cls == CLASS_WARRIOR || cls == CLASS_PALADIN || cls == CLASS_DEATH_KNIGHT || cls == CLASS_MONK || cls == CLASS_DRUID)
                                    : (cls == CLASS_PALADIN || cls == CLASS_PRIEST || cls == CLASS_SHAMAN || cls == CLASS_MONK || cls == CLASS_DRUID);
        if (!fits)
            return false;
    }
    if (_testLevelLeft.fetch_sub(1, std::memory_order_acq_rel) <= 0)
        return false;
    uint32 const from = bot->GetLevel();
    bot->GiveLevel(level);
    bot->SetUInt32Value(PLAYER_FIELD_XP, 0);
    BotFactory factory(bot, level);
    factory.Randomize(false);
    botAI->ResetStrategies();
    SetState(bot, t, BotLifeState::IDLE, now, 0);
    RelocateForLevel(bot);
    TC_LOG_INFO("playerbots", "TESTLEVEL {} ({} {}) {} -> {}", bot->GetName(), uint32(bot->GetRace()), uint32(bot->GetClass()), from, level);
    return true;
}

// the Charge path check from a spot to the creatures around it (upstream #424)
void BotLifeMgr::StartPathProbe(uint32 map, float x, float y, float z)
{
    _pathProbeMap = map;
    _pathProbeX = x;
    _pathProbeY = y;
    _pathProbeZ = z;
    _pathProbePending.store(true, std::memory_order_release);
}

void BotLifeMgr::PathProbe(Player* bot)
{
    Map* map = bot->GetMap();
    // a ground creature (an Orgrimmar Grunt) as the source of the path, invisible and passive, gone after 10 s
    TempSummon* probe = map->SummonCreature(3296, Position(_pathProbeX, _pathProbeY, _pathProbeZ, 0.0f), nullptr, 10000ms);
    if (!probe)
    {
        TC_LOG_INFO("playerbots", "PATHPROBE map {} {} {} {}: no probe creature", _pathProbeMap, _pathProbeX, _pathProbeY, _pathProbeZ);
        return;
    }
    probe->SetVisible(false);
    probe->SetReactState(REACT_PASSIVE);
    probe->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_IMMUNE_TO_NPC);
    std::list<Creature*> around;
    Trinity::AllWorldObjectsInRange check(probe, 25.0f);
    Trinity::CreatureListSearcher<Trinity::AllWorldObjectsInRange> searcher(probe, around, check);
    Cell::VisitAllObjects(probe, searcher, 25.0f);
    TC_LOG_INFO("playerbots", "PATHPROBE map {} from {:.1f} {:.1f} {:.1f} (probe z {:.1f}): {} creatures within 25 yd", _pathProbeMap,
        _pathProbeX, _pathProbeY, _pathProbeZ, probe->GetPositionZ(), uint32(around.size()));
    for (Creature* c : around)
    {
        if (c == probe || !c->IsAlive())
            continue;
        float const objSize = c->GetCombatReach();
        float const range = 25.0f * 1.5f + objSize;
        PathGenerator path(probe);
        path.SetPathLengthLimit(range);
        bool const ok = path.CalculatePath(c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), false);
        uint32 const type = path.GetPathType();
        bool const los = c->IsWithinLOSInMap(probe);
        bool const badZ = path.IsInvalidDestinationZ(c);
        char const* verdict = !los ? "NO LOS" : (type & PATHFIND_SHORT) ? "NOPATH (short)" : (!ok || (type & (PATHFIND_NOPATH | PATHFIND_INCOMPLETE)))
            ? "NOPATH (no/incomplete path)" : badZ ? "NOPATH (end z)" : "ok";
        G3D::Vector3 const& end = path.GetActualEndPosition();
        // the same path without the Charge limit: its real length and point count
        PathGenerator free(probe);
        free.CalculatePath(c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), false);
        float freeLength = 0.0f;
        for (size_t i = 1; i < free.GetPath().size(); ++i)
            freeLength += (free.GetPath()[i] - free.GetPath()[i - 1]).length();
        TC_LOG_INFO("playerbots", "PATHPROBE {} ({}) at {:.1f} {:.1f} {:.1f} dist {:.1f}: {} - type 0x{:X}, {} points, end {:.1f} {:.1f} {:.1f} | no limit: type 0x{:X}, {} points, length {:.1f} (limit {:.1f})",
            c->GetName(), c->GetEntry(), c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), probe->GetExactDist(c), verdict, type,
            uint32(path.GetPath().size()), end.x, end.y, end.z, free.GetPathType(), uint32(free.GetPath().size()), freeLength, range);
    }
}

void BotLifeMgr::StartRangeTest(int32 count, uint32 entry, uint32 maxLevel)
{
    _rangeTestMaxLevel = maxLevel ? maxLevel : 255;
    _rangeTestSpawns.clear();
    _rangeTestEntry = entry;
    if (entry)
        if (QueryResult result = WorldDatabase.PQuery("SELECT map, position_x, position_y, position_z FROM creature WHERE id = {} LIMIT 50", entry))
            do
            {
                Field* f = result->Fetch();
                _rangeTestSpawns.push_back({ float(f[0].GetUInt16()), f[1].GetFloat(), f[2].GetFloat(), f[3].GetFloat() });
            } while (result->NextRow());
    _rangeTestLeft.store(count, std::memory_order_relaxed);
}

void BotLifeMgr::RangeTest(PlayerbotAI* botAI, BotLifeInfo& t, uint32 now)
{
    Player* bot = botAI->GetBot();
    if (t.rangeTestPhase == 2 || t.rangeTestPhase == 3)
    {
        if (now < t.rangeTestAt)
            return;
        bool early = t.rangeTestPhase == 2;
        Creature* c = ObjectAccessor::GetCreature(*bot, t.rangeTestCreature);
        if (early)
        {
            t.rangeTestPhase = 3;
            t.rangeTestAt = now + 3000;
        }
        else
        {
            t.rangeTestPhase = 0;
            t.rangeTestCreature = ObjectGuid::Empty;
        }
        if (!c)
            return;
        TC_LOG_INFO("playerbots", "RANGETEST {} bot {} combatWith {} botCombat {} creatureCombatRefs {} botRefsTo {}", early ? "+1s" : "+4s",
            bot->GetName(), c->GetCombatManager().IsInCombatWith(bot), bot->IsInCombat(), uint32(c->GetCombatManager().GetPvECombatRefs().size()),
            uint32(bot->GetCombatManager().GetPvECombatRefs().size()));
        Unit* cv = c->GetVictim();
        TC_LOG_INFO("playerbots", "RANGETEST bot {} lvl {} spell {} -> {} ({}) lvl {} | start {:.1f} now {:.1f} yd | c.combat {} engaged {} victim {} threat {} react {} evade {} hp {:.0f}% moving {}",
            bot->GetName(), uint32(bot->GetLevel()), t.rangeTestSpell, c->GetName(), c->GetEntry(), uint32(c->GetLevel()), t.rangeTestDist, bot->GetDistance(c), c->IsInCombat(),
            c->IsAIEnabled && c->AI()->IsEngaged(), cv ? cv->GetName() : "none", uint32(c->GetThreatManager().GetThreatListSize()),
            uint32(c->GetReactState()), c->IsInEvadeMode(), c->GetHealthPct(), c->isMoving());
        return;
    }
    if (bot->IsInCombat() || !bot->IsAlive() || bot->GetMap()->Instanceable() || bot->GetGroup() || botAI->HasRealPlayerMaster())
        return;
    uint32 spell = RangeTestSpell(bot);
    if (!spell)
        return;

    Creature* target = nullptr;
    if (_rangeTestEntry)
    {
        if (t.rangeTestPhase == 0)
        {
            if (bot->GetLevel() > _rangeTestMaxLevel)
                return;
            if (_rangeTestSpawns.empty() || _rangeTestLeft.fetch_sub(1, std::memory_order_relaxed) <= 0)
                return;
            auto const& s = _rangeTestSpawns[urand(0, _rangeTestSpawns.size() - 1)];
            t.rangeTestPhase = 1;
            t.rangeTestAt = now + 8000;
            bot->TeleportTo(uint32(s[0]), s[1] + 22.0f, s[2], s[3] + 2.0f, 0.0f);
            return;
        }
        if (now < t.rangeTestAt || bot->IsBeingTeleported())
            return;
        std::list<Creature*> list;
        bot->GetCreatureListWithEntryInGrid(list, _rangeTestEntry, 40.0f);
        for (Creature* c : list)
            if (c->IsAlive() && !c->IsInCombat() && bot->GetDistance(c) > 10.0f)
            {
                target = c;
                break;
            }
        if (!target)
        {
            t.rangeTestPhase = 0;
            return;
        }
    }
    else
    {
        std::list<Creature*> list;
        NeutralCreatureInRange check{ bot };
        Trinity::CreatureListSearcher<NeutralCreatureInRange> searcher(bot, list, check);
        CellCoord pair(Trinity::ComputeCellCoord(bot->GetPositionX(), bot->GetPositionY()));
        Cell cell(pair);
        cell.SetNoCreate();
        TypeContainerVisitor<Trinity::CreatureListSearcher<NeutralCreatureInRange>, GridTypeMapContainer> visitor(searcher);
        cell.Visit(pair, visitor, *bot->GetMap(), *bot, 30.0f);
        if (list.empty() || _rangeTestLeft.fetch_sub(1, std::memory_order_relaxed) <= 0)
            return;
        target = list.front();
    }
    bot->SetFacingToObject(target);
    bot->CastSpell(target, spell, true);
    t.rangeTestCreature = target->GetGUID();
    t.rangeTestAt = now + 1000;
    t.rangeTestSpell = spell;
    t.rangeTestDist = bot->GetDistance(target);
    t.rangeTestPhase = 2;
}

void BotLifeMgr::PrintCastStats(ChatHandler* handler)
{
    std::vector<std::pair<uint32, uint32>> list;
    {
        std::lock_guard<std::mutex> g(_castStatsLock);
        list.assign(_castStats.begin(), _castStats.end());
        _castStats.clear();
    }
    std::sort(list.begin(), list.end(), [](auto const& a, auto const& b) { return a.second > b.second; });
    std::ostringstream out;
    out << "casts since last read:";
    for (size_t i = 0; i < list.size() && i < 80; ++i)
    {
        SpellInfo const* info = sSpellMgr->GetSpellInfo(list[i].first);
        out << " | " << (info ? info->SpellName : "?") << "=" << list[i].second;
    }
    handler->SendSysMessage(out.str().c_str());

    std::vector<std::pair<uint64, uint32>> fails;
    {
        std::lock_guard<std::mutex> g(_castStatsLock);
        fails.assign(_strictStats.begin(), _strictStats.end());
        _strictStats.clear();
    }
    std::sort(fails.begin(), fails.end(), [](auto const& a, auto const& b) { return a.second > b.second; });
    std::ostringstream f;
    f << "strict fails (spell:code):";
    for (size_t i = 0; i < fails.size() && i < 60; ++i)
    {
        SpellInfo const* info = sSpellMgr->GetSpellInfo(uint32(fails[i].first % 1000000));
        f << " | " << (info ? info->SpellName : "?") << ":" << (fails[i].first / 1000000) << "=" << fails[i].second;
    }
    handler->SendSysMessage(f.str().c_str());
}

// ".botlife mapstats": objects per loaded map (world thread, maps idle) - to find what grows with uptime
namespace
{
    struct MapObjectCounter
    {
        size_t creatures = 0, gameObjects = 0, dynamicObjects = 0, pets = 0, corpses = 0;
        void Visit(std::unordered_map<ObjectGuid, Creature*>& m) { creatures += m.size(); }
        void Visit(std::unordered_map<ObjectGuid, GameObject*>& m) { gameObjects += m.size(); }
        void Visit(std::unordered_map<ObjectGuid, DynamicObject*>& m) { dynamicObjects += m.size(); }
        void Visit(std::unordered_map<ObjectGuid, Pet*>& m) { pets += m.size(); }
        void Visit(std::unordered_map<ObjectGuid, Corpse*>& m) { corpses += m.size(); }
        template<class T> void Visit(std::unordered_map<ObjectGuid, T*>&) { }
    };
    struct DynSpellCounter
    {
        std::unordered_map<uint64, uint32>& out;
        void Visit(std::unordered_map<ObjectGuid, DynamicObject*>& m)
        {
            for (auto const& e : m)
            {
                Unit* caster = e.second->GetCaster();
                uint32 entry = caster && caster->GetTypeId() == TYPEID_UNIT ? caster->GetEntry() : 0;
                ++out[(uint64(e.second->GetSpellId()) << 32) | entry];
            }
        }
        template<class T> void Visit(std::unordered_map<ObjectGuid, T*>&) { }
    };
}

// the wind riders hang still above the big cities: ".botlife creature <entry>" - what the
// spawned creatures of one entry are doing. World thread, maps idle.
namespace
{
    struct CreatureEntryProbe
    {
        uint32 entry;
        std::vector<Creature*>& out;
        void Visit(std::unordered_map<ObjectGuid, Creature*>& m)
        {
            for (auto const& e : m)
                if (e.second->GetEntry() == entry)
                    out.push_back(e.second);
        }
        template<class T> void Visit(std::unordered_map<ObjectGuid, T*>&) { }
    };
}

// ".botlife questcoverage" - of the quests that open world NPCs offer, which can a bot do, and why not
void BotLifeMgr::PrintQuestCoverage(ChatHandler* handler)
{
    std::map<std::string, std::pair<uint32, std::vector<uint32>>> reasons;
    std::unordered_set<uint32> seen;
    uint32 offered = 0, supported = 0;
    // synchronous: the async workers do not keep the order, and a statement on a table that does not exist yet aborts
    // the server (MySQLConnection::_HandleMySQLErrno) - that was the crash of 1-10 23:51
    PlayerbotsDatabase.DirectExecute("CREATE TABLE IF NOT EXISTS tt_botlife_quest_support (quest INT UNSIGNED NOT NULL PRIMARY KEY, "
        "level SMALLINT NOT NULL, reason VARCHAR(90) NOT NULL)");
    PlayerbotsDatabase.DirectExecute("DELETE FROM tt_botlife_quest_support");
    for (auto const& giver : _questGivers)
        for (BotLifeSpawn const& s : giver.second)
            for (uint32 questId : sObjectMgr->GetCreatureQuestRelations(s.entry))
            {
                if (!seen.insert(questId).second)
                    continue;
                Quest const* quest = sObjectMgr->GetQuestTemplate(questId);
                if (!quest)
                    continue;
                ++offered;
                char const* why = nullptr;
                bool const ok = IsQuestSupported(quest, &why);
                if (ok)
                    ++supported;
                std::string const reason = ok ? "supported" : (why ? why : "?");
                auto& r = reasons[reason];
                ++r.first;
                if (r.second.size() < 5)
                    r.second.push_back(questId);
                PlayerbotsDatabase.PExecute("INSERT INTO tt_botlife_quest_support (quest, level, reason) VALUES ({}, {}, '{}')",
                    questId, int32(quest->GetQuestLevel()), reason);
            }
    std::ostringstream head;
    head << "quests offered by open world NPCs: " << offered << ", a bot can do " << supported << " ("
        << (offered ? supported * 100 / offered : 0) << "%) - per quest in mop_playerbots.tt_botlife_quest_support";
    handler->SendSysMessage(head.str().c_str());
    for (auto const& r : reasons)
    {
        std::ostringstream out;
        out << "  " << r.second.first << "  " << r.first << "  (e.g.";
        for (uint32 q : r.second.second)
            out << ' ' << q;
        out << ')';
        handler->SendSysMessage(out.str().c_str());
    }
}

void BotLifeMgr::PrintCreatureStats(ChatHandler* handler, uint32 entry)
{
    std::vector<Creature*> found;
    sMapMgr->DoForAllMaps([&](Map* map)
    {
        CreatureEntryProbe probe{ entry, found };
        TypeContainerVisitor<CreatureEntryProbe, MapStoredObjectTypesContainer> visitor(probe);
        visitor.Visit(map->GetObjectsStore());
    });
    uint32 alive = 0, onSpline = 0, canFly = 0, flying = 0, roaming = 0, awayFromHome = 0;
    std::map<uint32, uint32> motion;
    for (Creature* c : found)
    {
        if (c->IsAlive())
            ++alive;
        if (!c->movespline->Finalized())
            ++onSpline;
        if (c->CanFly())
            ++canFly;
        if (c->IsFlying())
            ++flying;
        if (c->HasUnitState(UNIT_STATE_ROAMING_MOVE))
            ++roaming;
        if (c->GetExactDist(&c->GetHomePosition()) > 3.0f)
            ++awayFromHome;
        ++motion[uint32(c->GetMotionMaster()->GetCurrentMovementGeneratorType())];
    }
    std::ostringstream out;
    out << "creature " << entry << ": in world " << found.size() << ", alive " << alive << ", on a spline " << onSpline
        << ", roaming " << roaming << ", away from spawn " << awayFromHome << ", can fly " << canFly << ", flying " << flying
        << " | motion type:";
    for (auto const& m : motion)
        out << ' ' << m.first << '=' << m.second;
    handler->SendSysMessage(out.str().c_str());
    for (size_t i = 0; i < found.size() && i < 8; ++i)
    {
        Creature* c = found[i];
        float nearest = -1.0f;
        for (auto const& ref : c->GetMap()->GetPlayers())
            if (Player* player = ref.GetSource())
            {
                float d = player->GetExactDist(c);
                if (nearest < 0.0f || d < nearest)
                    nearest = d;
            }
        std::ostringstream s;
        s << "  spawn " << c->GetSpawnId() << " map " << c->GetMapId() << " at " << int32(c->GetPositionX()) << ' ' << int32(c->GetPositionY())
          << ' ' << int32(c->GetPositionZ()) << ", from spawn " << int32(c->GetExactDist(&c->GetHomePosition())) << " yd, motion "
          << uint32(c->GetMotionMaster()->GetCurrentMovementGeneratorType()) << ", spline " << (c->movespline->Finalized() ? "idle" : "moving")
          << (c->HasUnitState(UNIT_STATE_ROAMING_MOVE) ? ", roaming" : "") << (c->HasUnitState(UNIT_STATE_NOT_MOVE) ? ", cannot move" : "")
          << (c->IsInCombat() ? ", in combat" : "") << ", move flags 0x" << std::hex << c->GetUnitMovementFlags() << std::dec
          << ", waypoint path " << c->GetWaypointPath() << " node " << c->GetCurrentWaypointID() << ", nearest player " << int32(nearest) << " yd";
        handler->SendSysMessage(s.str().c_str());
    }
}

void BotLifeMgr::PrintMapStats(ChatHandler* handler)
{
    struct Row { uint32 map, instance, players; MapObjectCounter c; size_t active; uint32 idle = 0; };   // perf1-D1: 
    std::vector<Row> rows;
    Row total{ 0, 0, 0, {}, 0 };
    uint32 maps = 0;
    sMapMgr->DoForAllMaps([&](Map* map)
    {
        Row r{ map->GetId(), map->GetInstanceId(), map->GetPlayersCountExceptGMs(), {}, map->GetActiveNonPlayersCount() };
        r.idle = map->GetBotIdleCount();   // perf1-D2: 
        TypeContainerVisitor<MapObjectCounter, MapStoredObjectTypesContainer> visitor(r.c);
        visitor.Visit(map->GetObjectsStore());
        total.players += r.players;
        total.c.creatures += r.c.creatures;
        total.c.gameObjects += r.c.gameObjects;
        total.c.dynamicObjects += r.c.dynamicObjects;
        total.c.pets += r.c.pets;
        total.c.corpses += r.c.corpses;
        total.active += r.active;
        ++maps;
        rows.push_back(r);
    });
    std::sort(rows.begin(), rows.end(), [](Row const& a, Row const& b) { return a.c.creatures > b.c.creatures; });
    // which spells the dynamic objects of the busiest map belong to (26-9: 14k on Eastern Kingdoms, 2-7 elsewhere)
    std::unordered_map<uint64, uint32> dynBySpell;   // spell << 32 | caster entry (0 = player)
    uint32 dynMap = 0, dynCount = 0;
    sMapMgr->DoForAllMaps([&](Map* map)
    {
        auto& store = map->GetObjectsStore().GetElements();
        size_t n = 0;
        MapObjectCounter c;
        TypeContainerVisitor<MapObjectCounter, MapStoredObjectTypesContainer> v(c);
        v.Visit(map->GetObjectsStore());
        if (c.dynamicObjects <= dynCount)
            return;
        dynCount = uint32(c.dynamicObjects);
        dynMap = map->GetId();
        dynBySpell.clear();
        DynSpellCounter spells{ dynBySpell };
        TypeContainerVisitor<DynSpellCounter, MapStoredObjectTypesContainer> dv(spells);
        dv.Visit(map->GetObjectsStore());
        (void)store; (void)n;
    });
    std::ostringstream out;
    out << "maps " << maps << " | total players " << total.players << " creatures " << total.c.creatures << " gos " << total.c.gameObjects
        << " dyn " << total.c.dynamicObjects << " pets " << total.c.pets << " corpses " << total.c.corpses << " active " << total.active
        << " | snapshot 0=" << MapPopulation(0) << " 1=" << MapPopulation(1) << " 530=" << MapPopulation(530) << " 571=" << MapPopulation(571)
        << " 870=" << MapPopulation(870) << " 1064=" << MapPopulation(1064)
        << " botpkt=" << Map::BotPacketsSkipped();   // perf2-F: bot update packets not built since start
    // update time per map in ms, average/peak since the last call (the tick is the slowest map)
    {
        static uint32 const continents[] = { 0, 1, 530, 571, 870, 1064 };
        out << " | update ms avg/peak";
        for (uint32 id : continents)
            out << ' ' << id << '=' << TTMapUpdateTime(id, false) << '/' << TTMapUpdateTime(id, true);
        uint32 slowId = 0, slowMs = 0;
        for (uint32 id = 0; id < 2048; ++id)
        {
            if (std::find(std::begin(continents), std::end(continents), id) != std::end(continents))
                continue;
            uint32 const peak = TTMapUpdateTime(id, true);
            if (peak > slowMs)
            {
                slowMs = peak;
                slowId = id;
            }
        }
        out << " slowest other " << slowId << '=' << TTMapUpdateTime(slowId, false) << '/' << slowMs;
    }
    for (size_t i = 0; i < rows.size() && i < 12; ++i)
        out << " || " << rows[i].map << "/" << rows[i].instance << " p" << rows[i].players << " c" << rows[i].c.creatures << " g"
            << rows[i].c.gameObjects << " d" << rows[i].c.dynamicObjects << " pet" << rows[i].c.pets << " a" << rows[i].active
            << " i" << rows[i].idle;   // perf1-D3: bots skipped on the last tick
    {
        std::vector<std::pair<uint64, uint32>> top(dynBySpell.begin(), dynBySpell.end());
        std::sort(top.begin(), top.end(), [](auto const& a, auto const& b) { return a.second > b.second; });
        out << " ## dynobjects map " << dynMap << " (" << dynCount << "):";
        for (size_t k = 0; k < top.size() && k < 8; ++k)
            out << " spell " << (top[k].first >> 32) << " caster " << (top[k].first & 0xFFFFFFFF) << " x" << top[k].second << ";";
    }
    handler->SendSysMessage(out.str().c_str());
}

// walkers - one test bot per starting area works through its quests like a player (WALK lines)
bool BotLifeMgr::IsWalker(Player* bot) const
{
    auto walkers = std::atomic_load(&_walkers);
    return walkers && !walkers->empty() && walkers->count(bot->GetGUID().GetCounter());
}

bool BotLifeMgr::WalkAllows(Player* bot, Quest const* quest) const
{
    auto walkers = std::atomic_load(&_walkers);
    if (!walkers || walkers->empty())
        return true;
    auto it = walkers->find(bot->GetGUID().GetCounter());
    if (it == walkers->end() || it->second.count(quest->GetZoneOrSort()))
        return true;
    // the class quests of a starting chain (negative sorts of the classes), when they are for this class
    switch (quest->GetZoneOrSort())
    {
        case -61: case -81: case -82: case -141: case -161: case -162: case -261: case -262: case -263: case -372: case -395:
            return !quest->GetAllowableClasses() || (quest->GetAllowableClasses() & bot->GetClassMask());
        default:
            return false;
    }
}

std::string BotLifeMgr::WalkAdd(std::string const& name, std::string const& sorts)
{
    ObjectGuid guid = sCharacterCache->GetCharacterGuidByName(name);
    if (!guid)
        return "walk: no character " + name;
    if (!sRandomPlayerbotMgr->IsPoolBot(guid.GetCounter()))
        return "walk: " + name + " is not a random bot";
    std::set<int32> zones;
    std::istringstream in(sorts);
    std::string token;
    while (std::getline(in, token, ','))
        if (!token.empty())
            zones.insert(atoi(token.c_str()));
    if (zones.empty())
        return "walk: no quest zones";
    auto old = std::atomic_load(&_walkers);
    auto next = std::make_shared<std::unordered_map<ObjectGuid::LowType, std::set<int32>>>();
    if (old)
        *next = *old;
    (*next)[guid.GetCounter()] = zones;
    std::atomic_store(&_walkers, std::shared_ptr<std::unordered_map<ObjectGuid::LowType, std::set<int32>> const>(std::move(next)));
    bool const online = ObjectAccessor::FindConnectedPlayer(guid) != nullptr;
    sRandomPlayerbotMgr->TTKeepBot(guid.GetCounter(), true);   // in the rotation: ProcessBot logs it in
    TC_LOG_INFO("playerbots", "WALK {} added: quest zones {}{}", name, sorts, online ? "" : " (logging in)");
    return "walk: " + name + " walks " + sorts + (online ? "" : " (logging in)");
}

std::string BotLifeMgr::WalkRemove(std::string const& name)
{
    ObjectGuid guid = sCharacterCache->GetCharacterGuidByName(name);
    auto old = std::atomic_load(&_walkers);
    if (!guid || !old || !old->count(guid.GetCounter()))
        return "walk: " + name + " is no walker";
    auto next = std::make_shared<std::unordered_map<ObjectGuid::LowType, std::set<int32>>>(*old);
    next->erase(guid.GetCounter());
    sRandomPlayerbotMgr->TTKeepBot(guid.GetCounter(), false);
    std::atomic_store(&_walkers, std::shared_ptr<std::unordered_map<ObjectGuid::LowType, std::set<int32>> const>(std::move(next)));
    TC_LOG_INFO("playerbots", "WALK {} removed", name);
    return "walk: " + name + " removed";
}

// forget what a walker gave up on: skip list, avoided givers/enders/creatures, quest timers; back to IDLE
std::string BotLifeMgr::WalkClear(std::string const& name)
{
    ObjectGuid guid = sCharacterCache->GetCharacterGuidByName(name);
    Player* bot = guid ? ObjectAccessor::FindPlayer(guid) : nullptr;
    PlayerbotAI* botAI = bot ? GET_PLAYERBOT_AI(bot) : nullptr;
    if (!botAI)
        return "walk: " + name + " is not online";
    BotLifeInfo& t = botAI->life;
    size_t const skipped = t.skipQuests.size();
    t.skipQuests.clear();
    t.avoidEnder.clear();
    t.avoidNpc.clear();
    t.avoidCreature.clear();
    t.questStarted.clear();
    t.hasDest = false;
    SetState(bot, t, BotLifeState::IDLE, getMSTime(), 0);
    TC_LOG_INFO("playerbots", "WALK {} cleared ({} skipped quests forgotten)", name, skipped);
    return "walk: " + name + " cleared, " + std::to_string(skipped) + " skipped quests forgotten";
}

namespace
{
    // the quest log of a walker: "id title [state] obj a/b ..."
    std::string WalkQuestLog(Player* bot)
    {
        std::ostringstream out;
        for (uint16 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
        {
            uint32 questId = bot->GetQuestSlotQuestId(slot);
            Quest const* quest = questId ? sObjectMgr->GetQuestTemplate(questId) : nullptr;
            if (!quest)
                continue;
            QuestStatus status = bot->GetQuestStatus(questId);
            out << " | " << questId << " " << quest->GetLogTitle()
                << (status == QUEST_STATUS_COMPLETE ? " [done]" : status == QUEST_STATUS_FAILED ? " [failed]" : "");
            for (QuestObjective const& obj : quest->GetObjectives())
                if (obj.Amount > 0)
                    out << " " << bot->GetQuestObjectiveCounter(obj.ID) << "/" << obj.Amount;
        }
        return out.str();
    }
}

void BotLifeMgr::WalkTick(Player* bot, BotLifeInfo& t, uint32 now)
{
    if (t.walkNextLog && now < t.walkNextLog)
        return;
    t.walkNextLog = now + 60 * IN_MILLISECONDS;
    TC_LOG_INFO("playerbots", "WALK {} lvl {} xp {} state {} map {} zone {} at {} {} {}{}{}", bot->GetName(), uint32(bot->GetLevel()),
        bot->GetUInt32Value(PLAYER_FIELD_XP), uint32(t.state), bot->GetMapId(), bot->GetZoneId(), int32(bot->GetPositionX()),
        int32(bot->GetPositionY()), int32(bot->GetPositionZ()), bot->IsAlive() ? "" : " DEAD", WalkQuestLog(bot));
}

std::string BotLifeMgr::WalkStatus()
{
    auto walkers = std::atomic_load(&_walkers);
    if (!walkers || walkers->empty())
        return "walk: no walkers";
    std::ostringstream out;
    for (auto const& w : *walkers)
    {
        ObjectGuid guid = ObjectGuid::Create<HighGuid::Player>(w.first);
        Player* bot = ObjectAccessor::FindConnectedPlayer(guid);
        std::string zones;
        for (int32 z : w.second)
            zones += (zones.empty() ? "" : ",") + std::to_string(z);
        if (!bot)
        {
            out << "walker " << w.first << " (zones " << zones << "): offline\n";
            continue;
        }
        uint32 done = 0, total = 0;
        std::ostringstream open;
        uint32 listed = 0;
        for (auto const& qp : sObjectMgr->GetQuestTemplates())
        {
            Quest const* quest = qp.second;
            if (!w.second.count(quest->GetZoneOrSort()))
                continue;
            if (quest->GetAllowableRaces() && !(quest->GetAllowableRaces() & bot->GetRaceMask()))
                continue;
            if (quest->GetAllowableClasses() && !(quest->GetAllowableClasses() & bot->GetClassMask()))
                continue;
            // nobody to hand it in to: removed or unused content, not part of the zone
            if (!bot->IsQuestRewarded(qp.first))
            {
                bool ender = false;
                for (auto const& rel : sObjectMgr->GetCreatureQuestInvolvedRelationReverseBounds(qp.first))
                    if (_creatureSpawns.count(rel.second))
                        ender = true;
                for (auto const& rel : sObjectMgr->GetGOQuestInvolvedRelationReverseBounds(qp.first))
                    if (_goSpawns.count(rel.second))
                        ender = true;
                if (!ender)
                    continue;
            }
            ++total;
            if (bot->IsQuestRewarded(qp.first))
            {
                ++done;
                continue;
            }
            // what a player could take now and the bot does not: why
            if (bot->GetQuestStatus(qp.first) == QUEST_STATUS_NONE && bot->CanTakeQuest(quest, false) && listed < 12)
            {
                char const* why = nullptr;
                bool const supported = GetPlan(quest).supported;
                if (!supported)
                    IsQuestSupported(quest, &why);
                open << "\n   can take " << qp.first << " " << quest->GetLogTitle() << ": "
                     << (!supported ? (why ? why : "unsupported") : !QuestLevelOk(bot, quest) ? "level" : !QuestDoable(bot, quest) ? "not doable" : "ok");
                ++listed;
            }
        }
        out << bot->GetName() << " lvl " << uint32(bot->GetLevel()) << " zones " << zones << " state " << uint32(GET_PLAYERBOT_AI(bot) ? GET_PLAYERBOT_AI(bot)->life.state : BotLifeState::IDLE)
            << " map " << bot->GetMapId() << " zone " << bot->GetZoneId() << ": " << done << "/" << total << " rewarded"
            << WalkQuestLog(bot) << open.str() << "\n";
    }
    return out.str();
}

