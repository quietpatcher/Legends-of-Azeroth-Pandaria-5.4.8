/*
* This file is part of the Pandaria 5.4.8 Project. See THANKS file for Copyright information
*
* This program is free software; you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the
* Free Software Foundation; either version 2 of the License, or (at your
* option) any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include "ScriptMgr.h"
#include "GameEventMgr.h"
#include "Transport.h"
#include "Random.h"
#include "Containers.h"
#include "Timer.h"
#include "Vehicle.h"

// Darkmoon Deathmatch
enum DarkmoonDeathmatchData
{
    GAME_EVENT_DARKMOON_DEATHMATCH_ANNOUNCE           = 82,
    GAME_EVENT_DARKMOON_DEATHMATCH_RUN                = 83,

    NPC_DARKMOON_DEATHMATCH_ANNOUNCER                 = 55402,

    GO_DARKMOON_DEATHMATCH_CHEST                      = 209620,

    SPELL_ENTER_DEATHMATCH                            = 108919,
    SPELL_EXIT_DEATHMATCH                             = 108923
};

enum Yells
{
    SAY_ANNOUNCE                                      = 0,
    SAY_RUN                                           = 1,
    SAY_END                                           = 2
};

class npc_darkmoon_deathmatch_announcer : public CreatureScript
{
    public:
        npc_darkmoon_deathmatch_announcer() : CreatureScript("npc_darkmoon_deathmatch_announcer") { }

        struct npc_darkmoon_deathmatch_announcerAI : public ScriptedAI
        {
            npc_darkmoon_deathmatch_announcerAI(Creature* creature) : ScriptedAI(creature)
            {
                chestGuid = ObjectGuid::Empty;
                winnerGuid = ObjectGuid::Empty;
                chestNeedsRespawn = false;
            }

            void UpdateAI(uint32 diff) override
            {
                if (chestNeedsRespawn && !chestGuid)
                {
                    if (GameObject* chest = GetClosestGameObjectWithEntry(me, GO_DARKMOON_DEATHMATCH_CHEST, 100))
                    {
                        chestGuid = chest->GetGUID();
                        chest->Respawn();
                    }
                }
            }

            void sOnGameEvent(bool start, uint16 eventId) override
            {
                if (!start)
                    return;

                if (eventId == GAME_EVENT_DARKMOON_DEATHMATCH_ANNOUNCE)
                    Talk(SAY_ANNOUNCE);
                else if (eventId == GAME_EVENT_DARKMOON_DEATHMATCH_RUN)
                {
                    Talk(SAY_RUN);
                    if (GameObject* chest = ObjectAccessor::GetGameObject(*me, chestGuid))
                        chest->Respawn();
                    else
                    {
                        chestGuid = ObjectGuid::Empty;
                        chestNeedsRespawn = true;
                    }
                }
            }

            void SetWinner(ObjectGuid winnerGuid)
            {
                if (Player* player = ObjectAccessor::GetPlayer(*me, winnerGuid))
                    Talk(SAY_END, player);
                sGameEventMgr->StopEvent(GAME_EVENT_DARKMOON_DEATHMATCH_RUN);
            }

        private:
            ObjectGuid chestGuid;
            ObjectGuid winnerGuid;
            bool chestNeedsRespawn;
        };
        
        CreatureAI* GetAI(Creature* creature) const override
        {
            return new npc_darkmoon_deathmatch_announcerAI(creature);
        }
};

enum MoonfangSpells
{
    SPELL_FREE_YOUR_MIND        = 145111,
    SPELL_FREE_YOUR_MIND_EFF    = 145112,
    SPELL_MOONFANG_CURSE        = 144590,
    SPELL_MOONFANG_TEARS        = 144702,
    SPELL_MOONFANG_TEARS_EFF    = 144579,
    SPELL_FANGS_OF_THE_MOON     = 144700,
    SPELL_CALL_THE_PACK         = 144602,
    SPELL_CALL_THE_PACK_EFF     = 144604,
    SPELL_LEAP_FOR_THE_KILL     = 144546,
    SPELL_LEAP_FOR_THE_KILL_EFF = 144535,
};

enum MoonfangEvents
{
    EVENT_MOONFANG_CURSE = 1,
    EVENT_FANGS_OF_THE_MOON,
    EVENT_CALL_THE_PACK,
    EVENT_LEAP_FOR_THE_KILL,
    EVENT_MOONFANG_TEARS,
};

// Moonfang 71992
struct npc_darkmoon_moonfang : public customCreatureAI
{
    npc_darkmoon_moonfang(Creature* creature) : customCreatureAI(creature) { }

    void Reset() override
    {
        events.Reset();
    }

    void JustEngagedWith(Unit* who) override
    {
        events.ScheduleEvent(EVENT_MOONFANG_CURSE, 19s + 500ms);
        events.ScheduleEvent(EVENT_FANGS_OF_THE_MOON, 8s + 500ms);
        events.ScheduleEvent(EVENT_MOONFANG_TEARS, 11s);
        events.ScheduleEvent(EVENT_CALL_THE_PACK, 25s);
        events.ScheduleEvent(EVENT_LEAP_FOR_THE_KILL, 15s);
    }

    void EnterEvadeMode(EvadeReason why = EVADE_REASON_OTHER) override
    {
        ScriptedAI::EnterEvadeMode();
    }

    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim())
            return;

        events.Update(diff);

        if (me->HasUnitState(UNIT_STATE_CASTING))
            return;

        while (uint32 eventId = events.ExecuteEvent())
        {
            ExecuteTargetEvent(SPELL_MOONFANG_CURSE, 21 * IN_MILLISECONDS, EVENT_MOONFANG_CURSE, eventId, PRIORITY_SELF);
            ExecuteTargetEvent(SPELL_CALL_THE_PACK, 32 * IN_MILLISECONDS, EVENT_CALL_THE_PACK, eventId, PRIORITY_SELF);
            ExecuteTargetEvent(SPELL_FANGS_OF_THE_MOON, 12.5 * IN_MILLISECONDS, EVENT_FANGS_OF_THE_MOON, eventId);
            ExecuteTargetEvent(SPELL_LEAP_FOR_THE_KILL, 16 * IN_MILLISECONDS, EVENT_LEAP_FOR_THE_KILL, eventId, PRIORITY_NOT_VICTIM);
            ExecuteTargetEvent(SPELL_MOONFANG_TEARS, 20 * IN_MILLISECONDS, EVENT_MOONFANG_TEARS, eventId, PRIORITY_SELF);
            break;
        }

        DoMeleeAttackIfReady();
    }
};

class go_darkmoon_treasure_chest : public GameObjectScript
{
    public:
        go_darkmoon_treasure_chest() : GameObjectScript("go_darkmoon_treasure_chest")
        {
            lastLooter = ObjectGuid::Empty;
        }

        void OnLootStateChanged(GameObject* go, uint32 state, Unit* unit) override
        {
            if (state == GO_ACTIVATED && unit)
                lastLooter = unit->GetGUID();

            if (state == GO_JUST_DEACTIVATED)
                if (Creature* announcer = GetClosestCreatureWithEntry(go, NPC_DARKMOON_DEATHMATCH_ANNOUNCER, 100, true))
                    if (npc_darkmoon_deathmatch_announcer::npc_darkmoon_deathmatch_announcerAI* ai = CAST_AI(npc_darkmoon_deathmatch_announcer::npc_darkmoon_deathmatch_announcerAI, announcer->GetAI()))
                        ai->SetWinner(lastLooter);
        }

    private:
        ObjectGuid lastLooter;
};

class spell_darkmoon_deathmatch : public SpellScriptLoader
{
    public:
        spell_darkmoon_deathmatch() : SpellScriptLoader("spell_darkmoon_deathmatch") { }

        class spell_darkmoon_deathmatch_SpellScript : public SpellScript
        {
            PrepareSpellScript(spell_darkmoon_deathmatch_SpellScript);

            void HandleScriptEffect(SpellEffIndex /*effIndex*/)
            {
                Unit* caster = GetCaster();
                if (!caster)
                    return;

                if (caster->GetPositionY() < 6402.79f)
                    caster->CastSpell(caster, SPELL_ENTER_DEATHMATCH);
                else
                    caster->CastSpell(caster, SPELL_EXIT_DEATHMATCH);
            }

            void Register() override
            {
                OnEffectHit += SpellEffectFn(spell_darkmoon_deathmatch_SpellScript::HandleScriptEffect, EFFECT_0, SPELL_EFFECT_SCRIPT_EFFECT);
            }
        };

        SpellScript* GetSpellScript() const override
        {
            return new spell_darkmoon_deathmatch_SpellScript();
        }
};

std::vector<std::pair<uint32, Position>> passengers
{
    { 68233, { 6.57632f, -3.6821f,  1.201352f, 4.0477900f } },
    { 68238, { -0.1620f, 7.45662f,  1.201352f, 0.0058666f } },
    { 68231, { -6.6299f, 3.93165f,  1.201352f, 1.1105790f } },
    { 68239, { 6.56192f, 4.00892f,  1.201351f, 5.2554440f } },
    { 68232, { -6.3160f, -3.8700f,  1.201352f, 2.0703380f } },
    { 68238, { 0.27098f, -7.2955f,  1.201352f, 3.1815390f } },
};

class transport_merry_go_round : public TransportScript
{
    public:
        transport_merry_go_round() : TransportScript("transport_merry_go_round") { }

        void OnCreate(Transport* transport) override
        {
            for (auto&& passenger : passengers)
            {
                Map* map = transport->GetMap();
                Creature* creature = new Creature();
                if (!creature->Create(map->GenerateLowGuid<HighGuid::Unit>(), map, PHASEMASK_NORMAL, passenger.first, 0, 0, passenger.second.GetPositionX(), passenger.second.GetPositionY(), passenger.second.GetPositionZ(), passenger.second.GetOrientation()))
                {
                    delete creature;
                    return;
                }

                creature->SetRespawnTime(0);

                float x, y, z, o;
                creature->GetPosition(x, y, z, o);

                creature->SetTransport(transport);
                creature->m_movementInfo.transport.guid = transport->GetGUID();
                creature->m_movementInfo.transport.pos.Relocate(x, y, z, o);
                transport->CalculatePassengerPosition(x, y, z, &o);
                creature->Relocate(x, y, z, o);

                bool spawned = false;
                if (creature->IsInWorld())
                {
                    creature->UpdateObjectVisibility(true);
                    spawned = true;
                }
                else if (creature->GetMap()->AddToMap(creature))
                    spawned = true;
                else
                    spawned = false;

                if (creature->IsPositionValid() && spawned)
                    transport->AddPassenger(creature);
                else if (!creature->GetMap()->AddToMap(creature))
                    delete creature;
            }
        }
};

// 134815 - WHEE!
class spell_whee_trigger : public SpellScript
{
    PrepareSpellScript(spell_whee_trigger);

    enum
    {
        SPELL_WHEE                  = 46668,
        ITEM_DARKMOON_RIDE_TICKET   = 81055,
        MAX_DURATION                = HOUR * IN_MILLISECONDS,
    };

    void HandleHit()
    {
        if (Player* player = GetHitUnit()->ToPlayer())
        {
            if (Aura* aura = player->GetAura(SPELL_WHEE))
            {
                int32 duration = aura->GetDuration();
                duration += MINUTE * IN_MILLISECONDS;
                duration = std::min(duration, int32(MAX_DURATION));
                aura->SetMaxDuration(duration);
                aura->SetDuration(duration);
            }
            else if (player->HasItemCount(ITEM_DARKMOON_RIDE_TICKET))
            {
                player->CastSpell(player, SPELL_WHEE, true);
                player->DestroyItemCount(ITEM_DARKMOON_RIDE_TICKET, 1, true);
            }
        }
    }

    void Register() override
    {
        OnHit += SpellHitFn(spell_whee_trigger::HandleHit);
    }
};

// Free your Mind 145111
class spell_darkmoon_free_your_mind : public SpellScript
{
    PrepareSpellScript(spell_darkmoon_free_your_mind);

    void HandleAfterCast()
    {
        if (roll_chance_i(50))
            GetCaster()->CastSpell(GetCaster(), SPELL_FREE_YOUR_MIND_EFF, true);
    }

    void Register() override
    {
        AfterCast += SpellCastFn(spell_darkmoon_free_your_mind::HandleAfterCast);
    }
};

// Moonfang Tears 144702
class spell_darkmoon_moonfang_tears : public SpellScript
{
    PrepareSpellScript(spell_darkmoon_moonfang_tears);

    std::list<WorldObject*> m_targets;

    void HandleOnEffectHit(SpellEffIndex effIdx)
    {
        if (Unit* caster = GetCaster())
            if (Unit* target = GetHitUnit())
                caster->CastSpell(target, GetSpellInfo()->Effects[effIdx].BasePoints, true);
    }

    void CountTargets(std::list<WorldObject*>& targets)
    {
        m_targets = targets;

        targets.remove_if([=](WorldObject* target) { return target && target->ToPlayer() && GetCaster() && target->ToPlayer()->GetExactDist2d(GetCaster()) < 12.5f; });

        if (targets.size() >= 3)
            return;

        targets.clear();

        for (auto&& itr : m_targets)
            targets.push_back(itr);

        if (targets.size() > 3)
            Trinity::Containers::RandomResizeList(targets, 3);
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_darkmoon_moonfang_tears::HandleOnEffectHit, EFFECT_0, SPELL_EFFECT_DUMMY);
        OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(spell_darkmoon_moonfang_tears::CountTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENEMY);
    }
};

// Moonfang Curse 144590
class spell_darkmoon_moonfang_curse : public SpellScript
{
    PrepareSpellScript(spell_darkmoon_moonfang_curse);

    std::list<WorldObject*> copyTargets;

    void CountTargets(std::list<WorldObject*>& targets)
    {
        uint32 targetsCount = targets.size() % 2 == 0 ? targets.size() / 2 : (targets.size() - 1) / 2;

        if (targets.size() > targetsCount)
            Trinity::Containers::RandomResizeList(targets, targetsCount);

        copyTargets = targets;
    }

    void CopyTargets(std::list<WorldObject*>& targets)
    {
        targets = copyTargets;
    }

    void Register() override
    {
        OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(spell_darkmoon_moonfang_curse::CountTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENEMY);
        OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(spell_darkmoon_moonfang_curse::CopyTargets, EFFECT_1, TARGET_UNIT_SRC_AREA_ENEMY);
        OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(spell_darkmoon_moonfang_curse::CopyTargets, EFFECT_2, TARGET_UNIT_SRC_AREA_ENEMY);
        OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(spell_darkmoon_moonfang_curse::CopyTargets, EFFECT_3, TARGET_UNIT_SRC_AREA_ENEMY);
    }
};

// (whack-a-gnoll) 101994 - Whack! Summon Aura: periodic dummy (1.2 s) on the player while Whack-a-Gnoll! 101612 is up.
// The summons are personal (SummonProperties 2841: only visible to the summoner) and the baby/Hogger summons need
// Whack-a-Gnoll! on the caster, so the player summons the gnoll at a barrel.
class spell_darkmoon_whack_summon_aura : public AuraScript
{
    PrepareAuraScript(spell_darkmoon_whack_summon_aura);

    enum
    {
        NPC_WHACK_A_GNOLL_BARREL    = 54546,
        SPELL_WHACK_SUMMON_GNOLL    = 102036,
        SPELL_WHACK_SUMMON_BABY     = 102043,
        SPELL_WHACK_SUMMON_HOGGER   = 102044,
        BARREL_BUSY_MS              = 5000,     // a gnoll stays up five seconds
    };

    std::map<ObjectGuid, uint32> _barrelUsed;

    void HandlePeriodic(AuraEffect const* /*aurEff*/)
    {
        Player* player = GetTarget()->ToPlayer();
        if (!player)
            return;

        std::list<Creature*> barrels;
        player->GetCreatureListWithEntryInGrid(barrels, NPC_WHACK_A_GNOLL_BARREL, 30.0f);
        uint32 now = getMSTime();
        std::vector<Creature*> freeBarrels;
        for (Creature* barrel : barrels)
        {
            auto itr = _barrelUsed.find(barrel->GetGUID());
            if (itr == _barrelUsed.end() || getMSTimeDiff(itr->second, now) >= BARREL_BUSY_MS)
                freeBarrels.push_back(barrel);
        }
        if (freeBarrels.empty())
            return;

        Creature* barrel = Trinity::Containers::SelectRandomContainerElement(freeBarrels);
        uint32 roll = urand(0, 99);
        uint32 spellId = roll < 15 ? SPELL_WHACK_SUMMON_BABY : (roll < 25 ? SPELL_WHACK_SUMMON_HOGGER : SPELL_WHACK_SUMMON_GNOLL);
        player->CastSpell(barrel, spellId, true);
        _barrelUsed[barrel->GetGUID()] = now;
    }

    void Register() override
    {
        OnEffectPeriodic += AuraEffectPeriodicFn(spell_darkmoon_whack_summon_aura::HandlePeriodic, EFFECT_0, SPELL_AURA_PERIODIC_DUMMY);
    }
};

// (shooting gallery) 101872 - Shoot: a cone cast on the Target Bunnies of the gallery. The shot of a player never reached them
// through the normal target selection, so the hit is resolved here: the Target Bunny that carries the Target Indicator [DND]
// (101010) in the cone in front of the player takes the shot, loses the indicator and pays the Quick Shot Bonus! (101012).
class spell_darkmoon_shooting_gallery_shoot : public SpellScript
{
    PrepareSpellScript(spell_darkmoon_shooting_gallery_shoot);

    enum
    {
        NPC_TARGET_BUNNY        = 24171,
        SPELL_TARGET_INDICATOR  = 101010,
        SPELL_QUICK_SHOT_BONUS  = 101012,
    };

    void HandleAfterCast()
    {
        Player* player = GetCaster()->ToPlayer();
        if (!player)
            return;

        std::list<Creature*> bunnies;
        player->GetCreatureListWithEntryInGrid(bunnies, NPC_TARGET_BUNNY, 20.0f);

        Creature* best = nullptr;
        float bestDist = 0.0f;
        for (Creature* bunny : bunnies)
        {
            if (!bunny->IsAlive() || !bunny->HasAura(SPELL_TARGET_INDICATOR) || !player->isInFront(bunny, float(M_PI) * 2.0f / 3.0f))
                continue;
            float dist = player->GetExactDist2d(bunny);
            if (!best || dist < bestDist)
            {
                best = bunny;
                bestDist = dist;
            }
        }

        if (!best)
            return;

        best->RemoveAurasDueToSpell(SPELL_TARGET_INDICATOR);
        best->CastSpell(player, SPELL_QUICK_SHOT_BONUS, true);
    }

    void Register() override
    {
        AfterCast += SpellCastFn(spell_darkmoon_shooting_gallery_shoot::HandleAfterCast);
    }
};

// (ring toss) 102058 - Ring Toss: the game aura (override bar 101695, alt power bar 88 with a maximum of 10). The bar counts the rings that are left.
class spell_darkmoon_ring_toss_game : public AuraScript
{
    PrepareAuraScript(spell_darkmoon_ring_toss_game);

    enum
    {
        RING_TOSS_RINGS     = 10,
    };

    void HandleApply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        GetTarget()->SetMaxPower(POWER_ALTERNATE_POWER, RING_TOSS_RINGS);
        GetTarget()->SetPower(POWER_ALTERNATE_POWER, RING_TOSS_RINGS);
    }

    void Register() override
    {
        AfterEffectApply += AuraEffectApplyFn(spell_darkmoon_ring_toss_game::HandleApply, EFFECT_1, SPELL_AURA_ENABLE_ALT_POWER, AURA_EFFECT_HANDLE_REAL);
    }
};

// (ring toss) 101695 - Ring Toss: the throw from the override bar, cast on the ground (dummy effect on a 4 yd area). The ring lands at the destination of the
// cast: the Dubenko (54490) within 2.75 yd of it is hit and pays the Ring Toss kill credit (54495) of Target: Turtle (29455, 3 rings). Every throw costs one ring
// of the bar; the game ends (aura 102058 off) with the last ring or when the quest is complete.
class spell_darkmoon_ring_toss_throw : public SpellScript
{
    PrepareSpellScript(spell_darkmoon_ring_toss_throw);

    enum
    {
        NPC_DUBENKO             = 54490,
        NPC_RING_TOSS_CREDIT    = 54495,
        QUEST_TARGET_TURTLE     = 29455,
        SPELL_RING_TOSS_GAME    = 102058,
        SPELL_RING_TOSS_LANDING = 101697,       // missile to the destination, summons the ring object 209269 (9 s)
    };

    void HandleAfterCast()
    {
        Player* player = GetCaster()->ToPlayer();
        WorldLocation const* dest = GetExplTargetDest();
        if (!player || !dest || !player->HasAura(SPELL_RING_TOSS_GAME))
            return;

        // the spell itself takes one ring from the bar (power cost): the bar already shows the rings that are left
        int32 rings = player->GetPower(POWER_ALTERNATE_POWER);

        std::list<Creature*> turtles;
        player->GetCreatureListWithEntryInGrid(turtles, NPC_DUBENKO, 60.0f);

        Creature* hit = nullptr;
        float hitDist = 2.75f;
        for (Creature* turtle : turtles)
        {
            float dist = turtle->GetExactDist2d(dest->GetPositionX(), dest->GetPositionY());
            if (turtle->IsAlive() && dist <= hitDist)
            {
                hit = turtle;
                hitDist = dist;
            }
        }

        TC_LOG_DEBUG("scripts", "RingToss: {} threw at {:.1f} {:.1f}, {} turtles in range, nearest {:.1f} yd, hit {}, rings left {}", player->GetName(), dest->GetPositionX(), dest->GetPositionY(),
            turtles.size(), turtles.empty() ? -1.0f : turtles.front()->GetExactDist2d(dest->GetPositionX(), dest->GetPositionY()), hit ? 1 : 0, rings);

        if (hit)
            player->CastSpell(hit->GetPositionX(), hit->GetPositionY(), hit->GetPositionZ(), SPELL_RING_TOSS_LANDING, true);
        else
            player->CastSpell(dest->GetPositionX(), dest->GetPositionY(), dest->GetPositionZ(), SPELL_RING_TOSS_LANDING, true);

        if (hit)
            player->KilledMonsterCredit(NPC_RING_TOSS_CREDIT);

        if (rings <= 0 || player->GetQuestStatus(QUEST_TARGET_TURTLE) != QUEST_STATUS_INCOMPLETE)
            player->RemoveAurasDueToSpell(SPELL_RING_TOSS_GAME);
    }

    void Register() override
    {
        AfterCast += SpellCastFn(spell_darkmoon_ring_toss_throw::HandleAfterCast);
    }
};

// (human cannonball) shared ids. 15218 Faire Cannon Trigger (in the cannon), 33068 Cannon Target Bunny (in the water), 54224 = quest credit
namespace DarkmoonCannon
{
    uint32 const NPC_CANNON_TRIGGER     = 15218;
    uint32 const NPC_TARGET_BUNNY       = 33068;
    uint32 const NPC_POINT_CREDIT       = 54224;
    uint32 const SPELL_CANNON_ROOT      = 97936;
    uint32 const SPELL_CANNON_BLAST     = 102121;
    uint32 const SPELL_MAGIC_WINGS      = 102116;
    uint32 const SPELL_TARGET_CENTER    = 62173;    // area aura A (3 yd): bullseye, BE_SPELL_TARGET criterion of achievement 6021
    uint32 const SPELL_TARGET_CLOSE     = 62175;    // area aura B (7 yd)
    uint32 const SPELL_TARGET_NEAR      = 62179;    // area aura C (15 yd)
}

// (human cannonball) 102112 - Cannon Prep: 5 s in the cannon (invisible, disarmed, rooted by 97936 from the gossip). Effect 2 is a periodic
// trigger without a trigger spell; at the tick (or at expiry, whichever comes first) the player is fired: root off, Cannon Blast 102121 on,
// and the Faire Cannon Trigger casts Magic Wings 102116 (feather fall + knock back 55 / 47.9 away from the trigger) on the player.
class spell_darkmoon_cannon_prep : public AuraScript
{
    PrepareAuraScript(spell_darkmoon_cannon_prep);

    void HandleApply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        GetTarget()->RemoveAurasByType(SPELL_AURA_MOUNTED);
    }

    void Launch()
    {
        Player* player = GetTarget()->ToPlayer();
        if (!player || !player->HasAura(DarkmoonCannon::SPELL_CANNON_ROOT))     // the root is the "not fired yet" marker
            return;

        player->RemoveAurasDueToSpell(DarkmoonCannon::SPELL_CANNON_ROOT);       // a root blocks the knock back
        player->CastSpell(player, DarkmoonCannon::SPELL_CANNON_BLAST, true);
        if (Creature* cannon = player->FindNearestCreature(DarkmoonCannon::NPC_CANNON_TRIGGER, 30.0f))
            cannon->CastSpell(player, DarkmoonCannon::SPELL_MAGIC_WINGS, true);
        else
        {
            player->AddAura(DarkmoonCannon::SPELL_MAGIC_WINGS, player);
            player->KnockbackFrom(player->GetPositionX() - std::cos(player->GetOrientation()), player->GetPositionY() - std::sin(player->GetOrientation()), 55.0f, 47.9f);
        }
    }

    void HandlePeriodic(AuraEffect const* /*aurEff*/)
    {
        PreventDefaultAction();
        Launch();
    }

    void HandleRemove(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        if (GetTargetApplication()->GetRemoveMode() == AURA_REMOVE_BY_EXPIRE)
            Launch();
        else
            GetTarget()->RemoveAurasDueToSpell(DarkmoonCannon::SPELL_CANNON_ROOT);   // cancelled or died in the cannon: nothing was fired
    }

    void Register() override
    {
        AfterEffectApply += AuraEffectApplyFn(spell_darkmoon_cannon_prep::HandleApply, EFFECT_0, SPELL_AURA_TRANSFORM, AURA_EFFECT_HANDLE_REAL);
        OnEffectPeriodic += AuraEffectPeriodicFn(spell_darkmoon_cannon_prep::HandlePeriodic, EFFECT_2, SPELL_AURA_PERIODIC_TRIGGER_SPELL);
        AfterEffectRemove += AuraEffectRemoveFn(spell_darkmoon_cannon_prep::HandleRemove, EFFECT_0, SPELL_AURA_TRANSFORM, AURA_EFFECT_HANDLE_REAL);
    }
};

// (human cannonball) 102121 - Cannon Blast: the 60 s flight aura (override bar 306 = Cancel Magic Wings). The landing is resolved here: after 2.5 s
// of flight the player is polled every 250 ms; in water or no longer falling = landed. Distance (2D) to the Cannon Target Bunny: <= 3 yd 5 points,
// <= 7 yd 3 points, <= 15 yd 1 point (quest text), the bunny casts the ring spell on the player (62173 also gives achievement 6021).
class spell_darkmoon_cannon_flight : public AuraScript
{
    PrepareAuraScript(spell_darkmoon_cannon_flight);

    uint32 _flightTime = 0;
    uint32 _pollTime = 0;
    bool _landed = false;

    void HandleUpdate(uint32 diff, AuraEffect* /*aurEff*/)
    {
        _flightTime += diff;
        if (_landed || _flightTime < 2500)
            return;

        _pollTime += diff;
        if (_pollTime < 250)
            return;
        _pollTime = 0;

        Player* player = GetUnitOwner()->ToPlayer();     // no aura application in an update hook: GetTarget() is not valid here
        if (!player || (!player->IsInWater() && player->IsFalling()))
            return;

        _landed = true;
        player->RemoveAurasDueToSpell(DarkmoonCannon::SPELL_MAGIC_WINGS);

        if (Creature* bunny = player->FindNearestCreature(DarkmoonCannon::NPC_TARGET_BUNNY, 200.0f))
        {
            float dist = player->GetExactDist2d(bunny);
            TC_LOG_DEBUG("scripts", "Cannonball: {} landed at {:.1f} {:.1f} {:.1f}, {:.1f} yd from the target bunny", player->GetName(), player->GetPositionX(), player->GetPositionY(), player->GetPositionZ(), dist);
            uint32 points = 0;
            uint32 ringSpell = 0;
            if (dist <= 3.0f)
            {
                points = 5;
                ringSpell = DarkmoonCannon::SPELL_TARGET_CENTER;
            }
            else if (dist <= 7.0f)
            {
                points = 3;
                ringSpell = DarkmoonCannon::SPELL_TARGET_CLOSE;
            }
            else if (dist <= 15.0f)
            {
                points = 1;
                ringSpell = DarkmoonCannon::SPELL_TARGET_NEAR;
            }

            if (ringSpell)
            {
                bunny->CastSpell(player, ringSpell, true);
                player->KilledMonsterCredit(DarkmoonCannon::NPC_POINT_CREDIT, ObjectGuid::Empty, points);
            }
        }

        GetAura()->SetDuration(0);      // ends the flight aura on the next update (the override bar goes away)
    }

    void Register() override
    {
        OnEffectUpdate += AuraEffectUpdateFn(spell_darkmoon_cannon_flight::HandleUpdate, EFFECT_0, SPELL_AURA_OVERRIDE_SPELLS);
    }
};

// (tonk challenge) ids. 54588 Darkmoon Steam Tonk = the vehicle of the player (seat 0, summoned by 100752), 33081 Tonk Cannon Target = quest objective of 29434
// (30x, summoned by the wave list of Finlay, the SmartAI of the target gives the credit and despawns it on a hit of 102292), 54642 / 54643 Enemy Tonk / MiniZep.
namespace DarkmoonTonk
{
    uint32 const NPC_STEAM_TONK         = 54588;
    uint32 const NPC_CANNON_TARGET      = 33081;
    uint32 const NPC_ENEMY_TONK         = 54642;
    uint32 const NPC_ENEMY_MINIZEP      = 54643;
    uint32 const SPELL_CONTROLLER       = 100752;   // aura 60 s on the player (summons the tonk), links 102178
    uint32 const SPELL_TONK_ACTION      = 102178;   // bars: vehicle ability bar + alt power bar 129 (0..30)
    int32 const SCORE_MAX               = 30;
    float const SHOT_RANGE              = 30.0f;
}

// (tonk challenge) 102292 - Cannon: the button of the tonk. The 5.4.8 data has a cone of 7 degrees and a range of 7 yd, which our core takes literally: nothing
// was ever hit. The target is chosen here (nearest Tonk Cannon Target 30 yd / 60 degrees in front of the tonk, otherwise an Enemy Tonk / MiniZep) and the
// spell hits it as normal; the SmartAI of 33081 pays the kill credit and despawns it. A hit on a Tonk Cannon Target is a point on the score bar.
class spell_darkmoon_tonk_cannon : public SpellScript
{
    PrepareSpellScript(spell_darkmoon_tonk_cannon);

    void SelectTarget(std::list<WorldObject*>& targets)
    {
        targets.clear();
        Unit* caster = GetCaster();
        if (!caster || caster->GetEntry() != DarkmoonTonk::NPC_STEAM_TONK)
            return;

        uint32 const entries[] = { DarkmoonTonk::NPC_CANNON_TARGET, DarkmoonTonk::NPC_ENEMY_TONK, DarkmoonTonk::NPC_ENEMY_MINIZEP };
        Creature* best = nullptr;
        float bestDist = 0.0f;
        for (uint32 entry : entries)
        {
            std::list<Creature*> found;
            caster->GetCreatureListWithEntryInGrid(found, entry, DarkmoonTonk::SHOT_RANGE);
            for (Creature* creature : found)
            {
                if (!creature->IsAlive() || !caster->isInFront(creature, float(M_PI) / 3.0f))
                    continue;
                float dist = caster->GetExactDist2d(creature);
                if (!best || dist < bestDist)
                {
                    best = creature;
                    bestDist = dist;
                }
            }
            if (best)       // the quest targets first, enemies only without one
                break;
        }

        TC_LOG_DEBUG("scripts", "Tonk: cannon shot from {:.1f} {:.1f} o {:.2f}, target {}", caster->GetPositionX(), caster->GetPositionY(), caster->GetOrientation(),
            best ? best->GetEntry() : 0);

        if (best)
            targets.push_back(best);
    }

    void HandleAfterHit()
    {
        Creature* tonk = GetCaster() ? GetCaster()->ToCreature() : nullptr;
        Unit* hit = GetHitUnit();
        if (!tonk || !hit || hit->GetEntry() != DarkmoonTonk::NPC_CANNON_TARGET || !tonk->GetVehicleKit())
            return;

        Unit* passenger = tonk->GetVehicleKit()->GetPassenger(0);
        Player* player = passenger ? passenger->ToPlayer() : nullptr;
        if (!player)
            return;

        int32 score = std::min<int32>(player->GetPower(POWER_ALTERNATE_POWER) + 1, DarkmoonTonk::SCORE_MAX);
        player->SetPower(POWER_ALTERNATE_POWER, score);
        if (score < DarkmoonTonk::SCORE_MAX)
            return;

        player->RemoveAurasDueToSpell(DarkmoonTonk::SPELL_TONK_ACTION);
        player->RemoveAurasDueToSpell(DarkmoonTonk::SPELL_CONTROLLER);
        tonk->DespawnOrUnsummon(1000);
    }

    void Register() override
    {
        OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(spell_darkmoon_tonk_cannon::SelectTarget, EFFECT_0, TARGET_UNIT_CONE_ENTRY);
        AfterHit += SpellHitFn(spell_darkmoon_tonk_cannon::HandleAfterHit);
    }
};

void AddSC_darkmoon_island()
{
    new npc_darkmoon_deathmatch_announcer();
    new creature_script<npc_darkmoon_moonfang>("npc_darkmoon_moonfang");
    new go_darkmoon_treasure_chest();
    new spell_darkmoon_deathmatch();
    new transport_merry_go_round();
    new spell_script<spell_whee_trigger>("spell_whee_trigger");
    new spell_script<spell_darkmoon_free_your_mind>("spell_darkmoon_free_your_mind");
    new spell_script<spell_darkmoon_moonfang_tears>("spell_darkmoon_moonfang_tears");
    new spell_script<spell_darkmoon_moonfang_curse>("spell_darkmoon_moonfang_curse");
    new aura_script<spell_darkmoon_whack_summon_aura>("spell_darkmoon_whack_summon_aura");   // (whack-a-gnoll)
    new spell_script<spell_darkmoon_shooting_gallery_shoot>("spell_darkmoon_shooting_gallery_shoot");   // (shooting gallery)
    new aura_script<spell_darkmoon_ring_toss_game>("spell_darkmoon_ring_toss_game");   // (ring toss)
    new spell_script<spell_darkmoon_ring_toss_throw>("spell_darkmoon_ring_toss_throw");   // (ring toss)
    new aura_script<spell_darkmoon_cannon_prep>("spell_darkmoon_cannon_prep");   // (human cannonball)
    new aura_script<spell_darkmoon_cannon_flight>("spell_darkmoon_cannon_flight");   // (human cannonball)
    new spell_script<spell_darkmoon_tonk_cannon>("spell_darkmoon_tonk_cannon");   // (tonk challenge)
}
