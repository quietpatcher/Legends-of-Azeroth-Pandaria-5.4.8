/*
* This file is part of the Legends of Azeroth Pandaria Project. See THANKS file for Copyright information
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
#include "ScriptedCreature.h"
#include "ScriptedEscortAI.h"
#include "SpellScript.h"
#pragma execution_character_set("UTF-8")

enum groundTroopsTypes
{
    NPC_AWOL_GRUNT_DESCIPLINED = 42893,
    NPC_AWOL_GRUNT             = 42646,

    TALK_ENRAGE = 0,
    TALK_DEFEAT,
    TALK_APOLOGY,

    ACTION_CHOISE = 0,
};

// AWOL Grunt 42646
struct npc_azshara_awol_grunt : public ScriptedAI
{
    npc_azshara_awol_grunt(Creature* creature) : ScriptedAI(creature) { }

    TaskScheduler scheduler;
    ObjectGuid targetGUID;
    bool hasDefeat;

    void Reset() override
    {
        targetGUID = ObjectGuid::Empty;
        hasDefeat = false;
        me->SetFaction(125);
    }

    void SetGUID(ObjectGuid guid, int32 /*type*/) override
    {
        targetGUID = guid;
    }

    void DoAction(int32 actionId) override
    {
        if (actionId == ACTION_CHOISE)
        {
            uint32 ourChoise = urand(0, 1);

            if (ourChoise)
            {
                if (Player* target = ObjectAccessor::GetPlayer(*me, targetGUID))
                {
                    Talk(TALK_APOLOGY, target);
                    target->KilledMonsterCredit(NPC_AWOL_GRUNT_DESCIPLINED);
                }

                scheduler
                    .Schedule(Seconds(2), [this](TaskContext context)
                {
                    MoveAway();
                });
            }
            else
            {
                me->SetFaction(16);

                if (Player* target = ObjectAccessor::GetPlayer(*me, targetGUID))
                {
                    Talk(TALK_ENRAGE, target);
                    AttackStart(target);
                }
            }
        }
    }

    void DamageTaken(Unit* attacker, uint32& damage) override
    {
        if (hasDefeat)
            damage = 0;

        if (damage >= me->GetHealth() && !hasDefeat)
        {
            damage = 0;
            hasDefeat = true;
            me->SetFaction(125);
            me->PrepareChanneledCast(me->GetOrientation());
            Talk(TALK_DEFEAT);

            if (Player* target = ObjectAccessor::GetPlayer(*me, targetGUID))
                target->KilledMonsterCredit(NPC_AWOL_GRUNT_DESCIPLINED);

            scheduler
                .Schedule(Seconds(2), [this](TaskContext context)
            {
                MoveAway();
            });
        }
    }

    void UpdateAI(uint32 diff) override
    {
        scheduler.Update(diff);

        if (!UpdateVictim())
            return;

        DoMeleeAttackIfReady();
    }

    private:
        void MoveAway()
        {
            Position pos = me->GetNearPosition(15.0f, frand(0.0f, 2 * M_PI));
            me->GetMotionMaster()->MovePoint(0, pos);
            me->DespawnOrUnsummon(me->GetSplineDuration());
        }
};

// Chewing Out 80017
class spell_azshara_chewing_out : public SpellScript
{
    PrepareSpellScript(spell_azshara_chewing_out);

    void HandleEffectHit(SpellEffIndex /*effIndex*/)
    {
        if (Player* caster = GetCaster()->ToPlayer())
        {
            if (Creature* grunt = GetHitCreature())
            {
                grunt->AI()->SetGUID(caster->GetGUID());
                grunt->AI()->DoAction(ACTION_CHOISE);
            }
        }
    }

    void FilterTargets(std::list<WorldObject*>& targets)
    {
        targets.remove_if([=](WorldObject* target) { return target->GetEntry() != NPC_AWOL_GRUNT; });
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_azshara_chewing_out::HandleEffectHit, EFFECT_0, SPELL_EFFECT_DUMMY);
        OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(spell_azshara_chewing_out::FilterTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENTRY);
    }
};

/*
Quest: An Ancient Enemy -- needs some corrections
*/

static const Position ancientEnemyPos[3] =
{
    {-716.50f, -5597.82f, 25.56f, 1.23f}, // Vanira
    {-730.68f, -5592.52f, 25.5f, 0.52f}, // Zuni
    {-722.39f, -5597.65f, 25.5f, 0.89f}, // Vol'jin
};

enum ancientEnemy
{
        NPC_ZUNI                    = 38423,
        NPC_ZARJIRA                 = 38306,
        NPC_VANIRA                  = 38437,
        NPC_VOLJIN                  = 38225,
        EVENT_INTRO                 = 1,
        SPELL_FIRES                 = 72250,
        SPELL_FIRES_BEAM            = 73294,
        SPELL_ICE_ENCASE            = 45438,   // Ice Block: visual for Vanira/Zuni encased in ice (UNVERIFIED id vs 5.4.8 dbc)
        ACTION_VOLJIN_BATTLE_ON     = 10,      // Vol'jin starts/resumes casting at Zar'jira
        ACTION_VOLJIN_BATTLE_OFF    = 11,      // Vol'jin stops casting (ice/drain phase)
};

static const uint32 npcId[3] = { NPC_ZUNI, NPC_VANIRA, NPC_VOLJIN };

class npc_voljin_ancient_enemy : public CreatureScript
{
    enum
    {
        QUEST_ANCIENT_ENEMY         = 24814,
        GOSSIP_VOLJIN               = 15318,
        GOSSIP_MENU_VOLJIN_READY    = 11020,   // gossip_menu_option 11020/0 "I am ready, Vol'jin." (localized)

        SPELL_VOLJIN_CREDIT         = 73589,
        SPELL_SHADOW_SHOCK          = 73087,
        SPELL_SHOOT                 = 20463,

        EVENT_SHOOT                 = 2,
        EVENT_SHADOW_SHOCK          = 3,

        SAY_INTRO1                   = 0,
        SAY_INTRO2                   = 1,
        SAY_BRAZIERS                = 2,
        SAY_OUTRO_1                 = 3,
        SAY_OUTRO_2                 = 4,
        SAY_OUTRO_3                 = 5,
    };

    struct npc_voljin_ancient_enemyAI : public ScriptedAI
    {
        npc_voljin_ancient_enemyAI(Creature* c) : ScriptedAI(c) {}

        void Reset() override
        {
            EventInProgress = false;
            battle = false;
            eventTime = 0;
            events.Reset();
            me->SetFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_GOSSIP);
        }

        void AttackStart(Unit * who) override
        {
            ScriptedAI::AttackStartNoMove(who);
        }

        void DoAction(int32 action) override
        {
            if (action == ACTION_VOLJIN_BATTLE_ON)
            {
                // the casts run from here, not from JustEngagedWith (he is passive/AttackStartNoMove and has no victim of his own)
                battle = true;
                events.CancelEvent(EVENT_SHOOT);
                events.CancelEvent(EVENT_SHADOW_SHOCK);
                events.ScheduleEvent(EVENT_SHOOT, 1500);
                events.ScheduleEvent(EVENT_SHADOW_SHOCK, 4000);
                return;
            }
            if (action == ACTION_VOLJIN_BATTLE_OFF)
            {
                battle = false;
                events.CancelEvent(EVENT_SHOOT);
                events.CancelEvent(EVENT_SHADOW_SHOCK);
                me->InterruptNonMeleeSpells(false);
                return;
            }
            if(EventInProgress)
                return;
            EventInProgress = true;

            for (int i=0; i<=2; ++i)
            {
                if(Creature * creature = i == 2 ? me : me->FindNearestCreature(i ? NPC_ZUNI : NPC_VANIRA, 20.0f))
                {
                    creature->AddUnitMovementFlag(MOVEMENTFLAG_WALKING);
                    creature->SetReactState(REACT_PASSIVE);
                    creature->GetMotionMaster()->MovePoint(0, ancientEnemyPos[i]);
                }
            }

            events.ScheduleEvent(EVENT_INTRO, 10000);
        }

        void UpdateAI(uint32 diff) override
        {
            if(!EventInProgress)
                return;

            // an event that never got to its fight (Zar'jira dead or gone, the player left) gave the
            // gossip back only after a restart - nobody could start it again
            eventTime += diff;
            if (eventTime > 3 * MINUTE * IN_MILLISECONDS && !me->IsInCombat() && !battle)
            {
                for (uint32 entry : { uint32(NPC_ZUNI), uint32(NPC_VANIRA) })
                    if (Creature* helper = me->FindNearestCreature(entry, 60.0f))
                        if (helper->IsAIEnabled)
                            helper->AI()->EnterEvadeMode();
                EnterEvadeMode();
                return;
            }

            events.Update(diff);
            {
                if(uint32 eventId = events.ExecuteEvent())
                {
                    switch(eventId)
                    {
                    case EVENT_INTRO:
                        Talk(SAY_INTRO1);
                        if (Creature * zarjira = me->FindNearestCreature(NPC_ZARJIRA, 30.0f))
                            zarjira->AI()->DoAction(1);
                        break;
                    case EVENT_SHOOT:
                        if (battle)
                            if (Creature* zar = me->FindNearestCreature(NPC_ZARJIRA, 60.0f, true))
                            {
                                me->SetFacingToObject(zar);
                                DoCast(zar, SPELL_SHOOT);
                            }
                        events.ScheduleEvent(EVENT_SHOOT, urand(2000, 2500));
                        break;
                    case EVENT_SHADOW_SHOCK:
                        if (battle)
                            if (Creature* zar = me->FindNearestCreature(NPC_ZARJIRA, 60.0f, true))
                                DoCast(zar, SPELL_SHADOW_SHOCK);
                        events.ScheduleEvent(EVENT_SHADOW_SHOCK, urand(8000, 10000));
                        break;
                    default:
                        break;
                    }
                }
            }
        }
    private:
        bool EventInProgress;
        bool battle = false;
        uint32 eventTime = 0;
        EventMap events;
    };

public:

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        if(player->GetQuestStatus(QUEST_ANCIENT_ENEMY) == QUEST_STATUS_INCOMPLETE)
        {
            player->ADD_GOSSIP_ITEM_DB(GOSSIP_MENU_VOLJIN_READY, 0, GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF+1);
            player->SEND_GOSSIP_MENU(GOSSIP_VOLJIN, creature->GetGUID());            
        }
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
    {
        player->PlayerTalkClass->ClearMenus();
        player->CLOSE_GOSSIP_MENU();
        // Zar'jira back first when an earlier group killed her (she stayed dead for an hour)
        if (Creature* zarjira = creature->FindNearestCreature(NPC_ZARJIRA, 60.0f, false))
            if (!zarjira->IsAlive())
                zarjira->Respawn(true);
        if (Creature* zuni = creature->FindNearestCreature(NPC_ZUNI, 60.0f, false))
            if (!zuni->IsAlive())
                zuni->Respawn(true);
        if (action == GOSSIP_ACTION_INFO_DEF+1)
            creature->AI()->DoAction(1);
        player->KilledMonsterCredit(NPC_VOLJIN);
        creature->RemoveFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_GOSSIP);
        return true;
    }

    npc_voljin_ancient_enemy() : CreatureScript("npc_voljin_ancient_enemy") { }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_voljin_ancient_enemyAI (creature);
    }
};

class npc_zarjira : public CreatureScript
{
    enum
    {
        NPC_FIRE_OF_THE_SEAS        = 38542,
        NPC_MANIFESTATION           = 38302,
        SPELL_FROSTBOLT             = 46987,
        SPELL_SUMMON_MANIFESTATION  = 73295,
        SPELL_DELUGE_OF_SHADOW      = 72044,

        EVENT_COMBAT                = 2,
        EVENT_FROSTBOLT             = 3,
        EVENT_MANIFESTATION         = 4,
        EVENT_FIRES                 = 5,

        SAY_INTRO                   = 1,
        SAY_FIRES                   = 2,
    };

    struct npc_zarjiraAI : public ScriptedAI
    {
        npc_zarjiraAI(Creature* c) : ScriptedAI(c) {}

        void Reset() override
        {
            events.Reset();
            icePhase = false;
            finale = false;
            me->SetReactState(REACT_PASSIVE);
            me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE);
            me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC);
        }

        void DamageTaken(Unit* attacker, uint32& damage) override
        {
            // the event is Vol'jin's fight: players never hurt her; Vol'jin's hits are capped (3% per hit) and she
            // stays above 35% until the fires have been stamped out (finale)
            if (!attacker || attacker->GetTypeId() == TYPEID_PLAYER || attacker->GetOwnerGUID().IsPlayer())
            {
                damage = 0;
                return;
            }
            uint32 const maxHp = me->GetMaxHealth();
            damage = std::min(damage, maxHp * 3 / 100);
            if (!finale)
            {
                uint32 const floorHp = maxHp * 35 / 100;
                uint32 const hp = me->GetHealth();
                damage = hp > floorHp ? std::min(damage, hp - floorHp) : 0;
            }
        }

        void AttackStart(Unit * who) override
        {
            // a player never becomes her target: only Vol'jin and his companions
            if (who && who->GetTypeId() == TYPEID_PLAYER)
                return;
            ScriptedAI::AttackStartNoMove(who);
        }

        void DoAction(int32 action) override
        {
            if(action == 1)
                events.ScheduleEvent(EVENT_INTRO, 12000);
            if(action == 2)
            {
                if (!icePhase)
                    return;
                icePhase = false;
                finale = true;
                Talk(SAY_FIRES);
                if(Creature * voljin = me->FindNearestCreature(NPC_VOLJIN, 30.0f))
                {
                    voljin->RemoveAllAuras();
                    voljin->AI()->DoAction(ACTION_VOLJIN_BATTLE_ON);
                }
                // the ice breaks: Zuni falls, Vanira kneels beside him
                if (Creature* zuni = me->FindNearestCreature(NPC_ZUNI, 30.0f))
                {
                    zuni->RemoveAurasDueToSpell(SPELL_ICE_ENCASE);
                    me->Kill(zuni, false);
                }
                if (Creature* vanira = me->FindNearestCreature(NPC_VANIRA, 30.0f))
                {
                    vanira->RemoveAurasDueToSpell(SPELL_ICE_ENCASE);
                    vanira->SetStandState(UNIT_STAND_STATE_KNEEL);
                }
            }
        }

        void JustDied(Unit* killer) override
        {
            for(int i=0;i<=2;++i)
                if(Creature * creature = me->FindNearestCreature(npcId[i], 30.0f))
                    creature->AI()->EnterEvadeMode();

            std::list<Player*> playerList;
            GetPlayerListInGrid(playerList, me, 50.0f);
            for (auto&& player : playerList)
                player->KilledMonsterCredit(NPC_ZARJIRA, ObjectGuid::Empty);
        }

        void JustEngagedWith(Unit *) override { }   // the timers start in EVENT_COMBAT (JustEngagedWith is not reliable here)

        void UpdateAI(uint32 diff) override
        {
            // a state line every 15 s while she is in combat or attackable
            if (diagTimer <= diff)
            {
                diagTimer = 15000;
                if (me->IsInCombat() || !me->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE))
                {
                    Creature* vj = me->FindNearestCreature(NPC_VOLJIN, 100.0f, true);
                    uint32 threats = 0;
                    for (ThreatReference const* ref : me->GetThreatManager().GetUnsortedThreatList()) { (void)ref; ++threats; }
                    TC_LOG_INFO("playerbots", "ZARJIRA hp {}/{} flags {:#x} react {} victim {} threats {} voljin hp {} alive {} phase {} events {}",
                        me->GetHealth(), me->GetMaxHealth(), me->GetUInt32Value(UNIT_FIELD_FLAGS), uint32(me->GetReactState()),
                        me->GetVictim() ? me->GetVictim()->GetName() : "-", threats, vj ? vj->GetHealth() : 0, vj ? 1 : 0,
                        me->IsInCombat() ? 1 : 0, events.Empty() ? 0 : 1);
                }
            }
            else
                diagTimer -= diff;
            // players hit her, but she keeps her eyes on Vol'jin: clear their threat, turn back to him
            if (me->IsInCombat())
            {
                for (ThreatReference const* ref : me->GetThreatManager().GetUnsortedThreatList())
                    if (ref->GetVictim() && ref->GetVictim()->GetTypeId() == TYPEID_PLAYER)
                    {
                        me->GetThreatManager().ClearThreat(ref->GetVictim());
                        break;   // the list changed: the next tick goes on
                    }
                if (Unit* victim = me->GetVictim())
                    if (victim->GetTypeId() == TYPEID_PLAYER)
                        if (Creature* voljin = me->FindNearestCreature(NPC_VOLJIN, 100.0f, true))
                            me->Attack(voljin, false);
            }
            events.Update(diff);
            if(uint32 eventId = events.ExecuteEvent())
            {
                switch(eventId)
                {
                case EVENT_INTRO:
                    Talk(1);
                    events.ScheduleEvent(EVENT_COMBAT, 10000);
                    break;
                case EVENT_COMBAT:
                    {
                        me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE);
                        me->SetReactState(REACT_AGGRESSIVE);
                        if(Creature * creature = me->FindNearestCreature(NPC_VOLJIN, 30.0f))
                            creature->CastSpell(me, SPELL_DELUGE_OF_SHADOW, true);

                        for(int i=0;i<=2;++i)
                        {
                            if(Creature * creature = me->FindNearestCreature(npcId[i], 30.0f))
                            {
                                me->SetInCombatWith(creature);
                                if(i == 2)
                                {
                                    me->Attack(creature, false);
                                    creature->Attack(me, false);
                                }
                                else
                                {
                                    creature->Attack(me, true);
                                    creature->GetMotionMaster()->MoveChase(me);
                                }

                            }
                        }
                        me->SetReactState(REACT_PASSIVE);
                        me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC);   // attackable-looking, but players cannot damage her
                        if(Creature * voljin = me->FindNearestCreature(NPC_VOLJIN, 30.0f))
                            voljin->AI()->DoAction(ACTION_VOLJIN_BATTLE_ON);
                        events.CancelEvent(EVENT_FROSTBOLT);
                        events.CancelEvent(EVENT_MANIFESTATION);
                        events.CancelEvent(EVENT_FIRES);
                        events.ScheduleEvent(EVENT_FROSTBOLT, 3000);
                        events.ScheduleEvent(EVENT_MANIFESTATION, 10000);
                        events.ScheduleEvent(EVENT_FIRES, 30000);
                    }
                    break;
                case EVENT_FROSTBOLT:
                    if(me->GetPower(POWER_MANA) <= me->GetMaxPower(POWER_MANA) / 4)
                        me->SetPower(POWER_MANA, me->GetMaxPower(POWER_MANA));
                    // at Vol'jin, never at a player
                    if (Creature* voljinTarget = me->FindNearestCreature(NPC_VOLJIN, 100.0f, true))
                        DoCast(voljinTarget, SPELL_FROSTBOLT);
                    events.ScheduleEvent(EVENT_FROSTBOLT, urand(2500, 3000));
                    break;
                case EVENT_MANIFESTATION:
                {
                    // at most two Manifestations at a time - they piled up
                    std::list<Creature*> manifestations;
                    me->GetCreatureListWithEntryInGrid(manifestations, NPC_MANIFESTATION, 60.0f);
                    manifestations.remove_if([](Creature* c) { return !c->IsAlive(); });
                    if (manifestations.size() >= 2)
                    {
                        events.ScheduleEvent(EVENT_MANIFESTATION, 5000);
                        break;
                    }
                    // players are not on her threat list: the wisp comes up at a random player in range
                    {
                        std::list<Player*> wispPlayers;
                        GetPlayerListInGrid(wispPlayers, me, 60.0f);
                        wispPlayers.remove_if([](Player* pl) { return !pl->IsAlive(); });
                        if (!wispPlayers.empty())
                        {
                            auto it = wispPlayers.begin();
                            std::advance(it, urand(0, uint32(wispPlayers.size()) - 1));
                            (*it)->CastSpell(*it, SPELL_SUMMON_MANIFESTATION, true);
                        }
                    }
                    events.ScheduleEvent(EVENT_MANIFESTATION, urand(15000, 20000));
                    break;
                }
                case EVENT_FIRES:
                    {
                        if (finale || icePhase)
                            break;
                        if (Creature* ancientenemy = me->FindNearestCreature(38225, 100.0f, true))
                            ancientenemy->AI()->Talk(SAY_INTRO, me);
                        std::list<Creature*> cList;
                        me->GetCreatureListWithEntryInGrid(cList, NPC_FIRE_OF_THE_SEAS, 30.0f);
                        // the fires light again only when all are out (a lit fire is
                        // selectable), and 90-120 s later instead of 60-80 s
                        bool anyLit = false;
                        for (Creature* fire : cList)
                            if (!fire->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE))
                                anyLit = true;
                        if (anyLit)
                        {
                            events.ScheduleEvent(EVENT_FIRES, 15000);
                            break;
                        }
                        for(std::list<Creature*>::const_iterator i = cList.begin(); i != cList.end(); ++i)
                        {
                            (*i)->CastSpell((*i), SPELL_FIRES, true);
                            (*i)->CastSpell(me, SPELL_FIRES_BEAM, true);
                            (*i)->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);                            
                        }
                        // ice/drain phase: Vol'jin stops, Vanira and Zuni are encased until all fires are out
                        icePhase = true;
                        if (Creature* voljin = me->FindNearestCreature(NPC_VOLJIN, 30.0f))
                            voljin->AI()->DoAction(ACTION_VOLJIN_BATTLE_OFF);
                        for (uint32 entry : { uint32(NPC_ZUNI), uint32(NPC_VANIRA) })
                            if (Creature* helper = me->FindNearestCreature(entry, 30.0f))
                                helper->CastSpell(helper, SPELL_ICE_ENCASE, true);
                    }
                    break;
                default:
                    break;
                }
            }
        }
    private:
        EventMap events;
        uint32 diagTimer = 0;
        bool icePhase = false;
        bool finale = false;
    };

public:
    npc_zarjira() : CreatureScript("npc_zarjira") { }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_zarjiraAI (creature);
    }
};

class npc_fire_of_the_seas : public CreatureScript
{
    enum
    {
        SPELL_STAMP_OUT_FIRES       = 73296,
    };

    struct npc_fire_of_the_seasAI : public ScriptedAI
    {
        npc_fire_of_the_seasAI(Creature* c) : ScriptedAI(c) {}

        void Reset() override
        {
            me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);
        }

        void SpellHit(Unit * /*caster*/, const SpellInfo * spell) override
        {
            if(spell->Id == SPELL_STAMP_OUT_FIRES)
            {
                me->RemoveAllAuras();
                me->InterruptNonMeleeSpells(true);
                if(Creature * zarjira = me->FindNearestCreature(NPC_ZARJIRA, 30.0f))
                    if(!zarjira->HasAura(SPELL_FIRES_BEAM))
                        zarjira->AI()->DoAction(2);
                me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);
            }
        }
    private:
    };

public:
    npc_fire_of_the_seas() : CreatureScript("npc_fire_of_the_seas") { }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_fire_of_the_seasAI (creature);
    }
};

void AddSC_azshara()
{
    new creature_script<npc_azshara_awol_grunt>("npc_azshara_awol_grunt");
    new spell_script<spell_azshara_chewing_out>("spell_azshara_chewing_out");
    new npc_voljin_ancient_enemy();
    new npc_zarjira();
    new npc_fire_of_the_seas();
}
