/*
 * Bot life: script hooks for "bot life" (see BotLife.h).
 */

#include "Creature.h"
#include "Guild.h"
#include "Player.h"
#include "QuestDef.h"
#include "ScriptMgr.h"
#include "BotLife.h"
#include "WorldSession.h"
#include "Map.h"
#include "Playerbots.h"
#include "PlayerbotAI.h"
#include "PlayerbotSpec.h"
#include "Group.h"
#include "Spell.h"
#include <sstream>

extern thread_local uint32 tl_damageSpellId;   // set in Unit::DealDamage

class BotLifePlayerScript : public PlayerScript
{
public:
    BotLifePlayerScript() : PlayerScript("BotLifePlayerScript") { }

    void OnCreatureKill(Player* killer, Creature* killed) override
    {
        sBotLife->OnCreatureKill(killer, killed);
    }

    void OnPlayerKilledByCreature(Creature* killer, Player* killed) override
    {
        sBotLife->OnKilledByCreature(killer, killed);
    }

    void OnPVPKill(Player* killer, Player* killed) override
    {
        sBotLife->OnKilledByPlayer(killer, killed);
    }

    void OnLevelChanged(Player* player, uint8 oldLevel) override
    {
        sBotLife->OnLevelChanged(player, oldLevel);
    }

    void OnQuestRewarded(Player* player, Quest const* quest) override
    {
        sBotLife->OnQuestRewarded(player, quest);
    }

    void OnLogin(Player* player) override
    {
        if (player && player->GetSession() && !player->GetSession()->IsBot())
            sBotLife->OnRealPlayerLogin(player);
    }

    void OnLogout(Player* player) override
    {
        if (player && player->GetSession() && !player->GetSession()->IsBot())
            sBotLife->OnRealPlayerLogout(player);
    }

    void OnChat(Player* player, uint32 /*type*/, uint32 /*lang*/, std::string& msg, Guild* guild) override
    {
        if (player && guild && player->GetSession() && !player->GetSession()->IsBot())
            sBotLife->OnGuildChat(player, msg, guild);
    }
};

class BotLifeWorldScript : public WorldScript
{
public:
    BotLifeWorldScript() : WorldScript("BotLifeWorldScript") { }

    void OnStartup() override
    {
        sBotLife->LoadCaches();
    }

    void OnUpdate(uint32 diff) override
    {
        sBotLife->WorldUpdate(diff);
    }
};

// diagnostics: the killing blow on a bot of a dungeon party - who or what (self = environment)
class BotLifeUnitScript : public UnitScript
{
public:
    BotLifeUnitScript() : UnitScript("BotLifeUnitScript") { }

    void OnDamage(Unit* attacker, Unit* victim, uint32& damage) override
    {
        Player* bot = victim ? victim->ToPlayer() : nullptr;
        if (!bot || !damage || damage < bot->GetHealth() || !bot->GetSession() || !bot->GetSession()->IsBot() || !bot->GetMap()->IsDungeon())
            return;
        PlayerbotAI* botAI = GET_PLAYERBOT_AI(bot);
        if (!botAI || (botAI->life.party != BOTLIFE_PARTY_DUNGEON && botAI->life.party != BOTLIFE_PARTY_RAID
            && !sBotLife->IsLfgTestBot(bot->GetGUID())))
            return;
        LiquidData liquid;
        ZLiquidStatus const status = bot->GetMap()->GetLiquidStatus(bot->GetPhaseMask(), bot->GetPositionX(), bot->GetPositionY(),
            bot->GetPositionZ(), MAP_ALL_LIQUIDS, &liquid);
        TC_LOG_INFO("playerbots", "BotLife: killing blow on {} in map {}: {} ({}) for {} (health {}), at {:.1f} {:.1f} {:.1f}, liquid status {} type {}, spell {}",
            bot->GetName(), bot->GetMapId(), !attacker ? std::string("nobody") : attacker == bot ? std::string("self/environment") : attacker->GetName(),
            attacker && attacker->ToCreature() ? attacker->GetEntry() : 0, damage, bot->GetHealth(), bot->GetPositionX(), bot->GetPositionY(),
            bot->GetPositionZ(), uint32(status), status != LIQUID_MAP_NO_WATER ? uint32(liquid.type_flags) : 0u, tl_damageSpellId);

        // night: what the party looked like at a creature's killing blow
        if (!attacker || attacker == bot || !attacker->ToCreature())
            return;
        // the attacker's own numbers
        TC_LOG_INFO("playerbots", "BotLife blowstats {} ({}) lvl {}: weapon {:.0f}-{:.0f}, attack power {:.0f}, attack time {}, auras {}, victim {} armor {} damage taken pct {:.2f}",
            attacker->GetName(), attacker->GetEntry(), uint32(attacker->GetLevel()), attacker->GetFloatValue(UNIT_FIELD_MIN_DAMAGE),
            attacker->GetFloatValue(UNIT_FIELD_MAX_DAMAGE), attacker->GetTotalAttackPowerValue(BASE_ATTACK), attacker->GetAttackTime(BASE_ATTACK),
            uint32(attacker->GetAppliedAuras().size()), bot->GetName(), bot->GetArmor(),
            bot->GetTotalAuraMultiplierByMiscMask(SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN, SPELL_SCHOOL_MASK_NORMAL));
        std::ostringstream party;
        if (Group* group = bot->GetGroup())
            for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
            {
                Player* m = ref->GetSource();
                if (!m || m == bot || m->GetMap() != bot->GetMap())
                    continue;
                bool const heal = PlayerBotSpec::IsHeal(m, true), tank = PlayerBotSpec::IsTank(m, true);
                if (!heal && !tank)
                    continue;
                PlayerbotAI* mAI = GET_PLAYERBOT_AI(m);
                Spell const* cast = m->GetCurrentSpell(CURRENT_GENERIC_SPELL);
                party << " | " << (heal ? "healer " : "tank ") << m->GetName() << (m->IsAlive() ? "" : " DEAD")
                      << " hp " << uint32(m->GetHealthPct()) << "% mana " << uint32(m->GetPowerPct(POWER_MANA)) << "% dist "
                      << uint32(m->GetExactDist(bot)) << " los " << (m->IsWithinLOSInMap(bot) ? 1 : 0) << " casting "
                      << (cast ? cast->GetSpellInfo()->Id : 0) << " engine " << (mAI ? uint32(mAI->GetState()) : 9u)
                      << " incombat " << (m->IsInCombat() ? 1 : 0) << " attackers " << uint32(m->getAttackers().size());
            }
        Unit* killerTarget = attacker->GetVictim();
        TC_LOG_INFO("playerbots", "BotLife deathdiag {} ({}, lvl {}, maxhp {}, armor {}) by {} ({}, lvl {}) for {}: attackers {}, killer targets {}{}",
            bot->GetName(), PlayerBotSpec::IsTank(bot, true) ? "tank" : PlayerBotSpec::IsHeal(bot, true) ? "healer" : "dps",
            uint32(bot->GetLevel()), bot->GetMaxHealth(), bot->GetArmor(), attacker->GetName(), attacker->GetEntry(), uint32(attacker->GetLevel()),
            damage, uint32(bot->getAttackers().size()), killerTarget ? killerTarget->GetName() : std::string("-"), party.str());
    }
};

void AddSC_bot_life()
{
    new BotLifePlayerScript();
    new BotLifeWorldScript();
    new BotLifeUnitScript();
}
