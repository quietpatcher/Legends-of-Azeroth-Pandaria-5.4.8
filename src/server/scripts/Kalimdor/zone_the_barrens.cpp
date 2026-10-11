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

/* ScriptData
SDName: The_Barrens
SD%Complete: 90
SDComment: Quest support: 863
SDCategory: Barrens
EndScriptData */

/* ContentData
npc_wizzlecrank_shredder
EndContentData */

#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "ScriptedEscortAI.h"
#include "Player.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "Vehicle.h"
#include "TemporarySummon.h"
#include "ObjectAccessor.h"
#include "WaypointManager.h"
#include "MoveSpline.h"
#include "MoveSplineInit.h"

/*######
## npc_beaten_corpse
######*/

#define GOSSIP_CORPSE "Examine corpse in detail..."

enum eQuests
{
    QUEST_LOST_IN_BATTLE      = 4921,
    QUEST_DRAG_IT_OUT_OF_THEM = 13961,
};

enum eSpells
{
    SPELL_SNARED_IN_NET        = 65581,
    SPELL_SNARED_NET_CONNECTOR = 65596,
    SPELL_SUMMON_RAZORMANE     = 65595,
    SPELL_DRAGING_A_RAZORMANE  = 65601,
};

enum eCreatures
{
    NPC_RAZORMANE_PILLAGER_SUMMONED = 34514,
};

class npc_beaten_corpse : public CreatureScript
{
public:
    npc_beaten_corpse() : CreatureScript("npc_beaten_corpse") { }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
    {
        player->PlayerTalkClass->ClearMenus();
        if (action == GOSSIP_ACTION_INFO_DEF +1)
        {
            player->SEND_GOSSIP_MENU(3558, creature->GetGUID());
            player->TalkedToCreature(creature->GetEntry(), creature->GetGUID());
        }
        return true;
    }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        if (player->GetQuestStatus(QUEST_LOST_IN_BATTLE) == QUEST_STATUS_INCOMPLETE || player->GetQuestStatus(QUEST_LOST_IN_BATTLE) == QUEST_STATUS_COMPLETE)
            player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, GOSSIP_CORPSE, GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF+1);

        player->SEND_GOSSIP_MENU(3557, creature->GetGUID());
        return true;
    }

};

/*######
# npc_gilthares
######*/

enum Gilthares
{
    SAY_GIL_START               = 0,
    SAY_GIL_AT_LAST             = 1,
    SAY_GIL_PROCEED             = 2,
    SAY_GIL_FREEBOOTERS         = 3,
    SAY_GIL_AGGRO               = 4,
    SAY_GIL_ALMOST              = 5,
    SAY_GIL_SWEET               = 6,
    SAY_GIL_FREED               = 7,

    QUEST_FREE_FROM_HOLD        = 898,
    AREA_MERCHANT_COAST         = 391,
    FACTION_ESCORTEE            = 232                       //guessed, possible not needed for this quest
};

class npc_gilthares : public CreatureScript
{
public:
    npc_gilthares() : CreatureScript("npc_gilthares") { }

    bool OnQuestAccept(Player* player, Creature* creature, const Quest* quest) override
    {
        if (quest->GetQuestId() == QUEST_FREE_FROM_HOLD)
        {
            creature->SetFaction(FACTION_ESCORTEE);
            creature->SetStandState(UNIT_STAND_STATE_STAND);

            creature->AI()->Talk(SAY_GIL_START, player);

            if (npc_giltharesAI* pEscortAI = CAST_AI(npc_gilthares::npc_giltharesAI, creature->AI()))
                pEscortAI->Start(false, player->GetGUID(), quest);
        }
        return true;
    }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_giltharesAI(creature);
    }

    struct npc_giltharesAI : public EscortAI
    {
        npc_giltharesAI(Creature* creature) : EscortAI(creature) { }

        void Reset() override { }

        void WaypointReached(uint32 waypointId, uint32 pathId) override
        {
            Player* player = GetPlayerForEscort();
            if (!player)
                return;

            switch (waypointId)
            {
                case 16:
                    Talk(SAY_GIL_AT_LAST, player);
                    break;
                case 17:
                    Talk(SAY_GIL_PROCEED, player);
                    break;
                case 18:
                    Talk(SAY_GIL_FREEBOOTERS, player);
                    break;
                case 37:
                    Talk(SAY_GIL_ALMOST, player);
                    break;
                case 47:
                    Talk(SAY_GIL_SWEET, player);
                    break;
                case 53:
                    Talk(SAY_GIL_FREED, player);
                    player->GroupEventHappens(QUEST_FREE_FROM_HOLD, me);
                    break;
            }
        }

        void JustEngagedWith(Unit* who) override
        {
            //not always use
            if (rand()%4)
                return;

            //only aggro text if not player and only in this area
            if (who->GetTypeId() != TYPEID_PLAYER && me->GetAreaId() == AREA_MERCHANT_COAST)
            {
                //appears to be pretty much random (possible only if escorter not in combat with who yet?)
                Talk(SAY_GIL_AGGRO, who);
            }
        }
    };

};

/*######
## npc_taskmaster_fizzule
######*/

enum TaskmasterFizzule
{
    FACTION_FRIENDLY_F  = 35,
    SPELL_FLARE         = 10113,
    SPELL_FOLLY         = 10137,
};

class npc_taskmaster_fizzule : public CreatureScript
{
public:
    npc_taskmaster_fizzule() : CreatureScript("npc_taskmaster_fizzule") { }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_taskmaster_fizzuleAI(creature);
    }

    struct npc_taskmaster_fizzuleAI : public ScriptedAI
    {
        npc_taskmaster_fizzuleAI(Creature* creature) : ScriptedAI(creature)
        {
            factionNorm = creature->GetFaction();
        }

        uint32 factionNorm;
        bool IsFriend;
        uint32 ResetTimer;
        uint8 FlareCount;

        void Reset() override
        {
            IsFriend = false;
            ResetTimer = 120000;
            FlareCount = 0;
            me->SetFaction(factionNorm);
        }

        void DoFriend()
        {
            me->RemoveAllAuras();
            me->GetThreatManager().RemoveMeFromThreatLists();
            me->GetThreatManager().ClearAllThreat();
            me->CombatStop(true);

            me->StopMoving();
            me->GetMotionMaster()->MoveIdle();

            me->SetFaction(FACTION_FRIENDLY_F);
            me->HandleEmoteCommand(EMOTE_ONESHOT_SALUTE);
        }

        void SpellHit(Unit* /*caster*/, const SpellInfo* spell) override
        {
            if (spell->Id == SPELL_FLARE || spell->Id == SPELL_FOLLY)
            {
                ++FlareCount;

                if (FlareCount >= 2)
                    IsFriend = true;
            }
        }

        void JustEngagedWith(Unit* /*who*/) override { }

        void UpdateAI(uint32 diff) override
        {
            if (IsFriend)
            {
                if (ResetTimer <= diff)
                {
                    EnterEvadeMode();
                    return;
                } else ResetTimer -= diff;
            }

            if (!UpdateVictim())
                return;

            DoMeleeAttackIfReady();
        }

        void ReceiveEmote(Player* /*player*/, uint32 emote) override
        {
            if (emote == TEXT_EMOTE_SALUTE)
            {
                if (FlareCount >= 2)
                {
                    if (me->GetFaction() == FACTION_FRIENDLY_F)
                        return;

                    DoFriend();
                }
            }
        }
    };

};

/*#####
## npc_twiggy_flathead
#####*/

enum TwiggyFlathead
{
    NPC_BIG_WILL                = 6238,
    NPC_AFFRAY_CHALLENGER       = 6240,

    SAY_BIG_WILL_READY          = 0,
    SAY_TWIGGY_FLATHEAD_BEGIN   = 0,
    SAY_TWIGGY_FLATHEAD_FRAY    = 1,
    SAY_TWIGGY_FLATHEAD_DOWN    = 2,
    SAY_TWIGGY_FLATHEAD_OVER    = 3
};

Position const AffrayChallengerLoc[6] =
{
    {-1683.0f, -4326.0f, 2.79f, 0.0f},
    {-1682.0f, -4329.0f, 2.79f, 0.0f},
    {-1683.0f, -4330.0f, 2.79f, 0.0f},
    {-1680.0f, -4334.0f, 2.79f, 1.49f},
    {-1674.0f, -4326.0f, 2.79f, 3.49f},
    {-1677.0f, -4334.0f, 2.79f, 1.66f}
};

class npc_twiggy_flathead : public CreatureScript
{
public:
    npc_twiggy_flathead() : CreatureScript("npc_twiggy_flathead") { }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_twiggy_flatheadAI(creature);
    }

    struct npc_twiggy_flatheadAI : public ScriptedAI
    {
        npc_twiggy_flatheadAI(Creature* creature) : ScriptedAI(creature) { }

        bool EventInProgress;
        bool EventGrate;
        bool EventBigWill;
        bool ChallengerDown[6];
        uint8 Wave;
        uint32 WaveTimer;
        uint32 ChallengerChecker;
        ObjectGuid PlayerGUID;
        ObjectGuid AffrayChallenger[6];
        ObjectGuid BigWill;

        void Reset() override
        {
            EventInProgress = false;
            EventGrate = false;
            EventBigWill = false;
            WaveTimer = 600000;
            ChallengerChecker = 0;
            Wave = 0;
            PlayerGUID = ObjectGuid::Empty;

            for (uint8 i = 0; i < 6; ++i)
            {
                AffrayChallenger[i] = ObjectGuid::Empty;
                ChallengerDown[i] = false;
            }
            BigWill = ObjectGuid::Empty;
        }

        void JustEngagedWith(Unit* /*who*/) override { }

        void MoveInLineOfSight(Unit* who) override

        {
            if (!who || !who->IsAlive() || EventInProgress)
                return;

            if (who->GetTypeId() == TYPEID_PLAYER && me->IsWithinDistInMap(who, 10.0f))
                if (Player* player = who->ToPlayer())
                    if (player->GetQuestStatus(1719) == QUEST_STATUS_INCOMPLETE)
                    {
                        PlayerGUID = who->GetGUID();
                        EventInProgress = true;
                    }
        }

        void KilledUnit(Unit* /*victim*/) override { }

        void UpdateAI(uint32 diff) override
        {
            if (EventInProgress)
            {
                Player* warrior = NULL;

                if (PlayerGUID)
                    warrior = ObjectAccessor::GetPlayer(*me, PlayerGUID);

                if (!warrior)
                    return;

                if (!warrior->IsAlive() && warrior->GetQuestStatus(1719) == QUEST_STATUS_INCOMPLETE)
                {
                    Talk(SAY_TWIGGY_FLATHEAD_DOWN);
                    warrior->FailQuest(1719);

                    for (uint8 i = 0; i < 6; ++i) // unsummon challengers
                    {
                        if (AffrayChallenger[i])
                        {
                            Creature* creature = Unit::GetCreature((*me), AffrayChallenger[i]);
                            if (creature && creature->IsAlive())
                                creature->DisappearAndDie();
                        }
                    }

                    if (BigWill) // unsummon bigWill
                    {
                        Creature* creature = Unit::GetCreature((*me), BigWill);
                        if (creature && creature->IsAlive())
                            creature->DisappearAndDie();
                    }
                    Reset();
                }

                if (!EventGrate && EventInProgress)
                {
                    float x, y, z;
                    warrior->GetPosition(x, y, z);

                    if (x >= -1684 && x <= -1674 && y >= -4334 && y <= -4324)
                    {
                        warrior->AreaExploredOrEventHappens(1719);
                        Talk(SAY_TWIGGY_FLATHEAD_BEGIN, warrior);

                        for (uint8 i = 0; i < 6; ++i)
                        {
                            Creature* creature = me->SummonCreature(NPC_AFFRAY_CHALLENGER, AffrayChallengerLoc[i], TEMPSUMMON_TIMED_OR_DEAD_DESPAWN, 600000ms);
                            if (!creature)
                                continue;
                            creature->SetFaction(35);
                            creature->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);
                            creature->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE);
                            creature->HandleEmoteCommand(EMOTE_ONESHOT_ROAR);
                            AffrayChallenger[i] = creature->GetGUID();
                        }
                        WaveTimer = 5000;
                        ChallengerChecker = 1000;
                        EventGrate = true;
                    }
                }
                else if (EventInProgress)
                {
                    if (ChallengerChecker <= diff)
                    {
                        for (uint8 i = 0; i < 6; ++i)
                        {
                            if (AffrayChallenger[i])
                            {
                                Creature* creature = Unit::GetCreature((*me), AffrayChallenger[i]);
                                if ((!creature || (!creature->IsAlive())) && !ChallengerDown[i])
                                {
                                    Talk(SAY_TWIGGY_FLATHEAD_DOWN);
                                    ChallengerDown[i] = true;
                                }
                            }
                        }
                        ChallengerChecker = 1000;
                    } else ChallengerChecker -= diff;

                    if (WaveTimer <= diff)
                    {
                        if (Wave < 6 && AffrayChallenger[Wave] && !EventBigWill)
                        {
                            Talk(SAY_TWIGGY_FLATHEAD_FRAY);
                            Creature* creature = ObjectAccessor::GetCreature(*me, AffrayChallenger[Wave]);
                            if (creature && (creature->IsAlive()))
                            {
                                creature->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);
                                creature->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE);
                                creature->HandleEmoteCommand(EMOTE_ONESHOT_ROAR);
                                creature->SetFaction(14);
                                creature->AI()->AttackStart(warrior);
                                ++Wave;
                                WaveTimer = 20000;
                            }
                        }
                        else if (Wave >= 6 && !EventBigWill)
                        {
                            if (Creature* creature = me->SummonCreature(NPC_BIG_WILL, -1722, -4341, 6.12f, 6.26f, TEMPSUMMON_TIMED_OR_DEAD_DESPAWN, 480000ms))
                            {
                                BigWill = creature->GetGUID();
                                //creature->GetMotionMaster()->MovePoint(0, -1693, -4343, 4.32f);
                                //creature->GetMotionMaster()->MovePoint(1, -1684, -4333, 2.78f);
                                creature->GetMotionMaster()->MovePoint(2, -1682, -4329, 2.79f);
                                creature->HandleEmoteCommand(EMOTE_STATE_READY_UNARMED);
                                EventBigWill = true;
                                WaveTimer = 1000;
                            }
                        }
                        else if (Wave >= 6 && EventBigWill && BigWill)
                        {
                            Creature* creature = ObjectAccessor::GetCreature(*me, BigWill);
                            if (!creature || !creature->IsAlive())
                            {
                                Talk(SAY_TWIGGY_FLATHEAD_OVER);
                                Reset();
                            }
                        }
                    } else WaveTimer -= diff;
                }
            }
        }
    };

};

/*#####
## npc_wizzlecrank_shredder
#####*/

enum Wizzlecrank
{
    SAY_MERCENARY       = 0,
    SAY_START           = 0,
    SAY_STARTUP1        = 1,
    SAY_STARTUP2        = 2,
    SAY_PROGRESS_1      = 3,
    SAY_PROGRESS_2      = 4,
    SAY_PROGRESS_3      = 5,
    SAY_END             = 6,

    QUEST_ESCAPE        = 863,
    FACTION_RATCHET     = 637,
    NPC_PILOT_WIZZ      = 3451,
    NPC_MERCENARY       = 3282,
};

class npc_wizzlecrank_shredder : public CreatureScript
{
public:
    npc_wizzlecrank_shredder() : CreatureScript("npc_wizzlecrank_shredder") { }

    struct npc_wizzlecrank_shredderAI : public EscortAI
    {
        npc_wizzlecrank_shredderAI(Creature* creature) : EscortAI(creature)
        {
            IsPostEvent = false;
            PostEventTimer = 1000;
            PostEventCount = 0;
        }

        bool IsPostEvent;
        uint32 PostEventTimer;
        uint32 PostEventCount;

        void Reset() override
        {
            if (!HasEscortState(STATE_ESCORT_ESCORTING))
            {
                if (me->GetStandState() == UNIT_STAND_STATE_DEAD)
                     me->SetStandState(UNIT_STAND_STATE_STAND);

                IsPostEvent = false;
                PostEventTimer = 1000;
                PostEventCount = 0;
            }
        }

        void WaypointReached(uint32 waypointId, uint32 pathId) override
        {
            switch (waypointId)
            {
                case 0:
                    Talk(SAY_STARTUP1);
                    break;
                case 9:
                    SetRun(false);
                    break;
                case 17:
                    if (Creature* temp = me->SummonCreature(NPC_MERCENARY, 1128.489f, -3037.611f, 92.701f, 1.472f, TEMPSUMMON_TIMED_DESPAWN_OUT_OF_COMBAT, 120000ms))
                    {
                        temp->AI()->Talk(SAY_MERCENARY);
                        me->SummonCreature(NPC_MERCENARY, 1160.172f, -2980.168f, 97.313f, 3.690f, TEMPSUMMON_TIMED_DESPAWN_OUT_OF_COMBAT, 120000ms);
                    }
                    break;
                case 24:
                    IsPostEvent = true;
                    break;
            }
        }

        void WaypointStart(uint32 PointId) override
        {
            Player* player = GetPlayerForEscort();

            if (!player)
                return;

            switch (PointId)
            {
                case 9:
                    Talk(SAY_STARTUP2, player);
                    break;
                case 18:
                    Talk(SAY_PROGRESS_1, player);
                    SetRun();
                    break;
            }
        }

        void JustSummoned(Creature* summoned) override
        {
            if (summoned->GetEntry() == NPC_PILOT_WIZZ)
                me->SetStandState(UNIT_STAND_STATE_DEAD);

            if (summoned->GetEntry() == NPC_MERCENARY)
                summoned->AI()->AttackStart(me);
        }

        void UpdateEscortAI(const uint32 Diff) override
        {
            if (!UpdateVictim())
            {
                if (IsPostEvent)
                {
                    if (PostEventTimer <= Diff)
                    {
                        switch (PostEventCount)
                        {
                            case 0:
                                Talk(SAY_PROGRESS_2);
                                break;
                            case 1:
                                Talk(SAY_PROGRESS_3);
                                break;
                            case 2:
                                Talk(SAY_END);
                                break;
                            case 3:
                                if (Player* player = GetPlayerForEscort())
                                {
                                    player->GroupEventHappens(QUEST_ESCAPE, me);
                                    me->SummonCreature(NPC_PILOT_WIZZ, 0.0f, 0.0f, 0.0f, 0.0f, TEMPSUMMON_TIMED_DESPAWN, 180000ms);
                                }
                                break;
                        }

                        ++PostEventCount;
                        PostEventTimer = 5000;
                    }
                    else
                        PostEventTimer -= Diff;
                }

                return;
            }

            DoMeleeAttackIfReady();
        }
    };

    bool OnQuestAccept(Player* player, Creature* creature, Quest const* quest) override
    {
        if (quest->GetQuestId() == QUEST_ESCAPE)
        {
            creature->SetFaction(FACTION_RATCHET);
            if (EscortAI* pEscortAI = CAST_AI(npc_wizzlecrank_shredder::npc_wizzlecrank_shredderAI, creature->AI()))
                pEscortAI->Start(true, player->GetGUID());
        }
        return true;
    }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_wizzlecrank_shredderAI(creature);
    }

};

// Razormane Pillager 34503, 34514
class npc_razormane_pillager : public CreatureScript
{
    public:
        npc_razormane_pillager() : CreatureScript("npc_razormane_pillager") { }

        bool OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
        {
            player->PlayerTalkClass->ClearMenus();

            if (action == GOSSIP_ACTION_INFO_DEF + 1)
            {
                creature->DespawnOrUnsummon();
                player->CastSpell(player, SPELL_SUMMON_RAZORMANE, true);
            }

            player->CLOSE_GOSSIP_MENU();

            return true;
        }

        bool OnGossipHello(Player* player, Creature* creature) override
        {
            if (creature->IsQuestGiver())
                player->PrepareQuestMenu(creature->GetGUID());

            if (player->GetQuestStatus(QUEST_DRAG_IT_OUT_OF_THEM) != QUEST_STATUS_INCOMPLETE)
                return false;

            player->ADD_GOSSIP_ITEM_DB(player->GetDefaultGossipMenuForSource(creature), 0, GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 1);

            player->SEND_GOSSIP_MENU(player->GetGossipTextId(creature), creature->GetGUID());
            return true;
        }

        struct npc_razormane_pillagerAI : public ScriptedAI
        {
            npc_razormane_pillagerAI(Creature* creature) : ScriptedAI(creature) { }

            ObjectGuid summonerGUID;

            void IsSummonedBy(Unit* summoner) override
            {
                summonerGUID = summoner->GetGUID();
                me->CastSpell(summoner, SPELL_DRAGING_A_RAZORMANE, true);
                me->CastSpell(summoner, SPELL_SNARED_NET_CONNECTOR, true);
                me->SetFaction(35);
                me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_PACIFIED | UNIT_FLAG_IMMUNE_TO_NPC);
                me->DespawnOrUnsummon(300 * IN_MILLISECONDS);
                me->SetStandState(UNIT_STAND_STATE_DEAD);
            }

            void Reset() override
            {
                me->SetFaction(109);
            }

            void UpdateAI(uint32 diff) override
            {
                if (me->GetEntry() == NPC_RAZORMANE_PILLAGER_SUMMONED)
                {
                    if (Unit* owner = ObjectAccessor::GetUnit(*me, summonerGUID))
                        me->GetMotionMaster()->MoveFollow(owner, 2.5f, me->GetAngle(owner));

                    return;
                }

                if (!UpdateVictim())
                    return;

                DoMeleeAttackIfReady();
            }
        };

        CreatureAI* GetAI(Creature* creature) const override
        {
            return new npc_razormane_pillagerAI(creature);
        }
};

// Grol`dom Net 65580
class spell_groldom_net : public SpellScript
{
    PrepareSpellScript(spell_groldom_net);

    void HandleDummy(SpellEffIndex /*effIndex*/)
    {
        if (Unit* target = GetHitUnit())
            target->CastSpell(target, SPELL_SNARED_IN_NET, true);
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_groldom_net::HandleDummy, EFFECT_0, SPELL_EFFECT_DUMMY);
    }
};

// Snared in Net 65581
class spell_snared_in_net : public AuraScript
{
    PrepareAuraScript(spell_snared_in_net);

    void Apply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        if (Unit* owner = GetOwner()->ToCreature())
        {
            owner->SetFaction(35);

            uint32 delay = 0;
            owner->m_Events.Schedule(delay += 300 * IN_MILLISECONDS, 1, [owner]()
            {
                owner->SetFaction(109);
                owner->RemoveAurasDueToSpell(SPELL_SNARED_IN_NET);
            });
        }
    }

    void Register() override
    {
        OnEffectApply += AuraEffectApplyFn(spell_snared_in_net::Apply, EFFECT_0, SPELL_AURA_MOD_STUN, AURA_EFFECT_HANDLE_REAL);
    }
};

// AreaTrigger 5465
class AreaTrigger_at_groldom_farm : public AreaTriggerScript
{
    public:
        AreaTrigger_at_groldom_farm() : AreaTriggerScript("AreaTrigger_at_groldom_farm") { }

        bool OnTrigger(Player* player, AreaTriggerEntry const* trigger) override
        {
            if (player->HasAura(SPELL_DRAGING_A_RAZORMANE) && player->GetQuestStatus(QUEST_DRAG_IT_OUT_OF_THEM) == QUEST_STATUS_INCOMPLETE)
            {
                if (Aura* dragAura = player->GetAura(SPELL_DRAGING_A_RAZORMANE))
                    if (Unit* caster = dragAura->GetCaster())
                        if (caster->ToCreature())
                            caster->ToCreature()->DespawnOrUnsummon(1000);

                player->RemoveAurasDueToSpell(SPELL_DRAGING_A_RAZORMANE);
                player->RemoveAurasDueToSpell(SPELL_SNARED_NET_CONNECTOR);
                player->CompleteQuest(QUEST_DRAG_IT_OUT_OF_THEM);
            }

            return false;
        }
};

enum BackInTheFightType
{
    NPC_WOUNDED_DEFENDER = 38805,

    ACTION_HEALED_BY_BANDAGE = 0,

    TALK_HEALED = 0,
};

// Wounded Defender 38805
struct npc_barrent_wounded_defender : public ScriptedAI
{
    npc_barrent_wounded_defender(Creature* creature) : ScriptedAI(creature) { }

    TaskScheduler scheduler;
    ObjectGuid questReceiverGUID;
    bool hasCredit;

    void Reset() override
    {
        hasCredit = false;
        questReceiverGUID = ObjectGuid::Empty;
        me->SetStandState(UNIT_STAND_STATE_SLEEP);
    }

    void SetGUID(ObjectGuid guid, int32 /*type*/) override
    {
        questReceiverGUID = guid;
    }

    void DoAction(int32 actionId) override
    {
        if (actionId == ACTION_HEALED_BY_BANDAGE && !hasCredit)
        {
            hasCredit = true;
            me->SetStandState(UNIT_STAND_STATE_STAND);

            if (Player* questReceiver = ObjectAccessor::GetPlayer(*me, questReceiverGUID))
                questReceiver->KilledMonsterCredit(me->GetEntry());

            scheduler
                .Schedule(Seconds(2), [this](TaskContext context)
            {
                Talk(TALK_HEALED);
            });

            scheduler
                .Schedule(Seconds(4), [this](TaskContext context)
            {
                // Move away!
                Position pos = me->GetNearPosition(15.0f, frand(0.0f, 2 * M_PI));
                me->GetMotionMaster()->MovePoint(0, pos);
                me->DespawnOrUnsummon(me->GetSplineDuration());
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
};

// Bandage 72925
class spell_barrens_bandage : public SpellScript
{
    PrepareSpellScript(spell_barrens_bandage);

    void HandleEffectHit(SpellEffIndex /*effIndex*/)
    {
        if (Player* caster = GetCaster()->ToPlayer())
        {
            if (Creature* target = GetHitCreature())
            {
                if (target->GetEntry() == NPC_WOUNDED_DEFENDER)
                {
                    target->AI()->SetGUID(caster->GetGUID());
                    target->AI()->DoAction(ACTION_HEALED_BY_BANDAGE);
                }
            }
        }
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_barrens_bandage::HandleEffectHit, EFFECT_0, SPELL_EFFECT_DUMMY);
    }
};

/*######
## Crossroads Caravan Pickup (13949) and Crossroads Caravan Delivery (13975)
######*/

// Both quests are a ride as the guard of a caravan. The caravan master calls the caravan (Summon Kodo
// Part 1 / 2, cast by the player). The kodo carries its driver on seat 0 and the seat of the guard on seat 1: Riding Shotgun or
// The Hotseat, a vehicle of its own whose action bar holds Shoot. The player climbs on with a click on the kodo, the caravan runs
// its route and the credit comes on arrival. On the way to Grol'dom Farm Razormane Raiders come at the kodo in threes; on the way
// to the Crossroads Burning Blade Raiders ride alongside on their mounts and jump on in front of the guard.
// Sources: Spell.dbc, SpellEffect.dbc and Vehicle.dbc of the client, the quest texts and the comments on both quests. The route,
// the timing of the ambushes and the jump are reconstructions: there is no script or sniff of the ride itself.
enum CrossroadsCaravan
{
    NPC_HALGA_BLOODEYE                  = 34258,
    NPC_LEAD_CARAVAN_KODO               = 34430,
    NPC_FAR_WATCH_CARAVAN_KODO          = 34432,
    NPC_RAZORMANE_RAIDER                = 34487,
    NPC_CROSSROADS_CARAVAN_KODO         = 34576,
    NPC_HEAD_CARAVAN_KODO               = 34577,
    NPC_ROCCO_WHIPSHANK                 = 34578,
    NPC_THE_HOTSEAT                     = 34582,
    NPC_BURNING_BLADE_MOUNT             = 34593,
    NPC_BURNING_BLADE_RAIDER            = 34594,
    NPC_CARAVAN_PICKUP_CREDIT           = 53613,
    // the Mor'shan caravan
    NPC_NAGALA_WHIPSHANK                = 52207,
    NPC_CHIEF_CARAVAN_KODO              = 52209,
    NPC_MORSHAN_RIDING_SHOTGUN          = 52210,
    NPC_CROSSROADS_CARAVAN_CART         = 52211,
    NPC_BURNING_BLADE_AMBUSHER_CART     = 52274,   // takes the supply cart
    NPC_BURNING_BLADE_AMBUSHER_GRAB     = 52275,   // carries the driver off (a vehicle)
    NPC_BURNING_BLADE_AMBUSHER_ASK      = 52276,
    NPC_MORSHAN_PICKUP_CREDIT           = 52303,
    NPC_MASTER_CARAVAN_KODO             = 52314,
    NPC_MORSHAN_CARAVAN_CART            = 52316,
    NPC_MORSHAN_DELIVERY_CREDIT         = 52326,
    NPC_MORSHAN_ATTACK_CONTROLLER       = 52334,
    NPC_MORSHAN_BURNING_BLADE_MOUNT     = 52337,
    NPC_BURNING_BLADE_ATTACKER          = 52338,
    NPC_CARAVAN_DELIVERY_CREDIT         = 65892,

    SPELL_RIDE_CARAVAN_KODO             = 65466,
    SPELL_CALL_A_PACK_KODO              = 65494,
    SPELL_CARAVAN_PICKUP_COMPLETE       = 65561,
    SPELL_SUMMON_RAZORMANE_RAIDER       = 65496,
    SPELL_CALL_A_PACK_KODO_2            = 65663,
    SPELL_CARAVAN_QUEST_COMPLETE        = 65670,
    SPELL_SUMMON_BURNING_BLADE          = 65692,
    SPELL_FACE_SMASH                    = 65704,
    SPELL_HIT_RAIDER_IN_THE_FACE        = 65713,
    SPELL_BURNING_BLADE_NET             = 96661,
    SPELL_MORSHAN_SUMMON_BURNING_BLADE  = 96786,
    SPELL_MORSHAN_DELIVERY_CREDIT       = 96788,

    QUEST_CROSSROADS_CARAVAN_PICKUP     = 13949,
    QUEST_CROSSROADS_CARAVAN_DELIVERY   = 13975,
    QUEST_MORSHAN_CARAVAN_PICKUP        = 29109,
    QUEST_MORSHAN_CARAVAN_DELIVERY      = 29111,

    PATH_CARAVAN_PICKUP                 = 3443000,
    PATH_CARAVAN_DELIVERY               = 3457700,
    PATH_MORSHAN_PICKUP                 = 5220900,
    PATH_MORSHAN_DELIVERY               = 5231400,

    SEAT_CARAVAN_DRIVER                 = 0,
    SEAT_CARAVAN_GUARD                  = 1,
    SEAT_HOTSEAT_GUARD                  = 0,
    SEAT_HOTSEAT_RAIDER                 = 1,
    SEAT_MASTER_KODO_CONTROLLER         = 2,

    SAY_HALGA_MOVE_OUT                  = 2,
    SAY_ROCCO_RIDE_HARD                 = 1,
    SAY_BALGOR_PICKUP_DONE              = 0,
    SAY_BALGOR_TURNING_BACK             = 1,
    SAY_BALGOR_BURNING_BLADE            = 2,
    SAY_BALGOR_DELIVERY_DONE            = 3,

    DATA_CARAVAN_STAGE                  = 1,
    DATA_CARAVAN_JUMP                   = 2,
    ACTION_CARAVAN_JUMP                 = 1,

    CARAVAN_WAITING                     = 0,
    CARAVAN_MOUNTING                    = 1,
    CARAVAN_RIDING                      = 2,
    CARAVAN_DONE                        = 3,
    CARAVAN_SCENE                       = 4,

    // Balgor Whipshank on the way to Dreadmist camp (52227)
    SAY_MORSHAN_DRIVER_CAMP             = 6,
    SAY_MORSHAN_DRIVER_LUNCH            = 7,
    SAY_MORSHAN_DRIVER_HELP             = 8,
    SAY_MORSHAN_DRIVER_TURNING_BACK     = 9,
    // Balgor Whipshank on the way to the Mor'shan Rampart (52333)
    SAY_MORSHAN_HOP_ON                  = 0,
    SAY_MORSHAN_SPOTTED                 = 1,
    SAY_MORSHAN_CLOSING_IN              = 2,
    SAY_MORSHAN_ALL_SIDES               = 3,
    SAY_MORSHAN_MADE_IT                 = 4,
    SAY_MORSHAN_TURNING_BACK            = 5,
};

// the seat of the guard on a caravan kodo (Riding Shotgun / The Hotseat), or null
static Unit* CaravanGuardSeat(Creature const* kodo)
{
    Vehicle* kit = kodo->GetVehicleKit();
    Unit* seat = kit ? kit->GetPassenger(SEAT_CARAVAN_GUARD) : nullptr;
    return seat && seat->GetVehicleKit() ? seat : nullptr;
}

// the guard of a caravan: on the seat of the guard, or on the Master Caravan Kodo itself
static Player* CaravanGuard(Creature const* kodo)
{
    Vehicle* kit = kodo->GetVehicleKit();
    Unit* onSeat = kit ? kit->GetPassenger(SEAT_CARAVAN_GUARD) : nullptr;
    if (!onSeat)
        return nullptr;
    if (Player* player = onSeat->ToPlayer())
        return player;
    if (!onSeat->GetVehicleKit() || !onSeat->IsWithinDist2d(kodo, 10.0f))
        return nullptr;
    Unit* guard = onSeat->GetVehicleKit()->GetPassenger(SEAT_HOTSEAT_GUARD);
    return guard ? guard->ToPlayer() : nullptr;
}

// where a raider lands in front of the guard: the second seat of the seat of the guard (The Hotseat,
// Riding Shotgun), or the attack controller the Master Caravan Kodo carries
static Unit* CaravanPerch(Creature const* kodo, int8& seatId)
{
    if (kodo->GetEntry() != NPC_MASTER_CARAVAN_KODO)
    {
        seatId = SEAT_HOTSEAT_RAIDER;
        return CaravanGuardSeat(kodo);
    }
    seatId = 0;
    Vehicle* kit = kodo->GetVehicleKit();
    Unit* controller = kit ? kit->GetPassenger(SEAT_MASTER_KODO_CONTROLLER) : nullptr;
    return controller && controller->GetVehicleKit() ? controller : nullptr;
}

// Lead Caravan Kodo 34430, Head Caravan Kodo 34577
struct npc_crossroads_caravan_kodo : public ScriptedAI
{
    npc_crossroads_caravan_kodo(Creature* creature) : ScriptedAI(creature), summons(creature),
        delivery(creature->GetEntry() == NPC_HEAD_CARAVAN_KODO) { }

    SummonList summons;
    bool const delivery;
    ObjectGuid playerGUID;
    ObjectGuid packGUID;
    Movement::PointsArray route;
    uint32 stage = CARAVAN_WAITING;
    uint32 timer = 35 * IN_MILLISECONDS;   // waiting: as long as Calling the Caravan lasts on the player
    uint32 rideTime = 0;
    uint32 ambushTimer = 0;
    uint32 launchTimer = 0;
    uint32 jumpLock = 0;
    uint32 mounts = 0;
    bool movedOut = false;
    bool ambushed = false;

    void InitializeAI() override
    {
        me->SetReactState(REACT_PASSIVE);
    }

    void Reset() override { }
    void AttackStart(Unit* /*who*/) override { }
    void MoveInLineOfSight(Unit* /*who*/) override { }
    void EnterEvadeMode(EvadeReason /*why*/) override { }

    void DamageTaken(Unit* /*attacker*/, uint32& damage) override
    {
        damage = 0;   // the kodo takes no damage on the way
    }

    uint32 GetData(uint32 type) const override
    {
        if (type == DATA_CARAVAN_STAGE)
            return stage;
        if (type == DATA_CARAVAN_JUMP)
            return jumpLock;
        return 0;
    }

    void SetData(uint32 type, uint32 value) override
    {
        if (type == DATA_CARAVAN_JUMP)
            jumpLock = value;
    }

    void IsSummonedBy(Unit* summoner) override
    {
        if (summoner->GetTypeId() != TYPEID_PLAYER)
            return;
        playerGUID = summoner->GetGUID();
        me->SetFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK);
        DoCast(me, delivery ? SPELL_CALL_A_PACK_KODO_2 : SPELL_CALL_A_PACK_KODO, true);
    }

    void JustSummoned(Creature* summon) override
    {
        summons.Summon(summon);
        switch (summon->GetEntry())
        {
            case NPC_FAR_WATCH_CARAVAN_KODO:
            case NPC_CROSSROADS_CARAVAN_KODO:
                packGUID = summon->GetGUID();
                summon->SetReactState(REACT_PASSIVE);
                summon->SetSpeed(MOVE_RUN, 1.4f);   // keeps up behind the lead kodo
                break;
            case NPC_RAZORMANE_RAIDER:
                // no leash: they stay on the caravan until the minute of their summon spell is up
                summon->SetCombatDistance(500.0f);
                summon->GetThreatManager().AddThreat(me, 1000000.0f);
                summon->AI()->AttackStart(me);
                break;
            case NPC_BURNING_BLADE_MOUNT:
                summon->SetSpeed(MOVE_RUN, 1.6f);
                summon->GetMotionMaster()->MoveFollow(me, 9.0f, (++mounts & 1) ? float(M_PI) / 2.0f : -float(M_PI) / 2.0f);
                break;
            default:
                break;
        }
    }

    void SummonedCreatureDespawn(Creature* summon) override
    {
        summons.Despawn(summon);
    }

    Creature* Driver() const
    {
        Vehicle* kit = me->GetVehicleKit();
        Unit* driver = kit ? kit->GetPassenger(SEAT_CARAVAN_DRIVER) : nullptr;
        return driver ? driver->ToCreature() : nullptr;
    }

    Player* Guard() const
    {
        Unit* seat = CaravanGuardSeat(me);
        if (seat && !seat->IsWithinDist2d(me, 10.0f))   // the seat is no longer on the back of the kodo
            seat = nullptr;
        Unit* guard = seat ? seat->GetVehicleKit()->GetPassenger(SEAT_HOTSEAT_GUARD) : nullptr;
        return guard ? guard->ToPlayer() : nullptr;
    }

    void OnSpellClick(Unit* clicker, bool& result) override
    {
        Player* player = clicker->ToPlayer();
        if (!player || stage != CARAVAN_WAITING || player->GetGUID() != playerGUID || !me->IsWithinDistInMap(player, 10.0f))
            return;
        if (player->GetQuestStatus(delivery ? QUEST_CROSSROADS_CARAVAN_DELIVERY : QUEST_CROSSROADS_CARAVAN_PICKUP) != QUEST_STATUS_INCOMPLETE)
            return;
        Unit* seat = CaravanGuardSeat(me);
        if (!seat)
            return;
        player->CastSpell(seat, SPELL_RIDE_CARAVAN_KODO, true);
        result = true;
        stage = CARAVAN_MOUNTING;
        timer = 2 * IN_MILLISECONDS;
        me->RemoveFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK);
    }

    // The route from the waypoint path, with a point on the ground every six yards or so: one straight line between two nodes
    // would cut through the slopes.
    void BuildRoute()
    {
        route.clear();
        WaypointPath const* path = sWaypointMgr->GetPath(delivery ? PATH_CARAVAN_DELIVERY : PATH_CARAVAN_PICKUP);
        if (!path || path->empty())
            return;
        G3D::Vector3 last(me->GetPositionX(), me->GetPositionY(), me->GetPositionZ());
        route.push_back(last);
        for (WaypointData const* node : *path)
        {
            G3D::Vector3 const next(node->x, node->y, node->z);
            uint32 const steps = std::max<uint32>(1, uint32(std::ceil((next - last).length() / 6.0f)));
            for (uint32 i = 1; i <= steps; ++i)
            {
                G3D::Vector3 point = last + (next - last) * (float(i) / float(steps));
                float const ground = me->GetMap()->GetHeight(me->GetPhaseMask(), point.x, point.y, point.z + 4.0f);
                if (ground > INVALID_HEIGHT && std::fabs(ground - point.z) < 6.0f)
                    point.z = ground;
                route.push_back(point);
            }
            last = next;
        }
    }

    // One spline over what is left of the route, from the point nearest to the kodo onwards.
    void Launch()
    {
        G3D::Vector3 const here(me->GetPositionX(), me->GetPositionY(), me->GetPositionZ());
        size_t nearest = 0;
        for (size_t i = 1; i < route.size(); ++i)
            if ((route[i] - here).squaredLength() < (route[nearest] - here).squaredLength())
                nearest = i;
        Movement::PointsArray points;
        points.push_back(here);
        for (size_t i = nearest + 1; i < route.size(); ++i)
            points.push_back(route[i]);
        if (points.size() < 2)
            return;
        Movement::MoveSplineInit init(me);
        init.MovebyPath(points);
        init.SetUncompressed();   // the route is longer than a packed path can hold
        init.SetWalk(false);
        init.Launch();
    }

    void StartRide()
    {
        BuildRoute();
        if (route.size() < 2)
        {
            TC_LOG_ERROR("scripts", "npc_crossroads_caravan_kodo: no waypoint path for the caravan of {}", me->GetEntry());
            End(0);
            return;
        }
        stage = CARAVAN_RIDING;
        // the Lead Caravan Kodo was recorded as not selectable, but in this core that also makes it no
        // valid attack target: the Razormane Raiders then go for the guard. It stays selectable and takes no damage.
        if (delivery)
            me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE);
        ambushTimer = (delivery ? 21 : 15) * IN_MILLISECONDS;
        if (Creature* pack = ObjectAccessor::GetCreature(*me, packGUID))
            pack->GetMotionMaster()->MoveFollow(me, 6.0f, float(M_PI));
        Launch();
    }

    void Ambush(uint32 diff)
    {
        // nothing any more on the last stretch
        if (me->GetExactDist2d(route.back().x, route.back().y) < (delivery ? 150.0f : 90.0f))
            return;
        if (ambushTimer > diff)
        {
            ambushTimer -= diff;
            return;
        }
        if (!delivery)
        {
            for (uint8 i = 0; i < 3; ++i)
                DoCast(me, SPELL_SUMMON_RAZORMANE_RAIDER, true);
            ambushTimer = urand(6, 14) * IN_MILLISECONDS;
            return;
        }
        if (!ambushed)
        {
            ambushed = true;
            if (Creature* driver = Driver())
                driver->AI()->Talk(SAY_BALGOR_BURNING_BLADE);
        }
        DoCast(me, SPELL_SUMMON_BURNING_BLADE, true);
        ambushTimer = urand(4, 7) * IN_MILLISECONDS;
    }

    void Arrive(Player* player)
    {
        if (Creature* driver = Driver())
            driver->AI()->Talk(delivery ? SAY_BALGOR_DELIVERY_DONE : SAY_BALGOR_PICKUP_DONE, player);
        if (delivery)
        {
            if (Unit* seat = CaravanGuardSeat(me))
                seat->CastSpell(player, SPELL_CARAVAN_QUEST_COMPLETE, true);
            player->KilledMonsterCredit(NPC_CARAVAN_DELIVERY_CREDIT);
        }
        else
        {
            if (Unit* seat = CaravanGuardSeat(me))
                seat->CastSpell(player, SPELL_CARAVAN_PICKUP_COMPLETE, true);
            player->KilledMonsterCredit(NPC_CARAVAN_PICKUP_CREDIT);
        }
        // both quests carry the 'event' flag: without this they stay incomplete with every objective done
        player->AreaExploredOrEventHappens(delivery ? QUEST_CROSSROADS_CARAVAN_DELIVERY : QUEST_CROSSROADS_CARAVAN_PICKUP);
        player->ExitVehicle();
        End(10 * IN_MILLISECONDS);
    }

    // The ride is over (arrived, or the guard got off): the attackers run, the caravan goes after the delay.
    void End(uint32 delay)
    {
        stage = CARAVAN_DONE;
        timer = delay;
        me->StopMoving();
        if (Creature* pack = ObjectAccessor::GetCreature(*me, packGUID))
            pack->GetMotionMaster()->MoveIdle();
        for (ObjectGuid const& guid : summons)
        {
            Creature* summon = ObjectAccessor::GetCreature(*me, guid);
            if (!summon || summon->GetEntry() != NPC_RAZORMANE_RAIDER || !summon->IsAlive())
                continue;
            summon->SetReactState(REACT_PASSIVE);
            summon->GetThreatManager().ClearAllThreat();
            summon->CombatStop(true);
            summon->GetMotionMaster()->MoveFleeing(me, 5 * IN_MILLISECONDS);
            summon->DespawnOrUnsummon(5 * IN_MILLISECONDS);
        }
    }

    void UpdateAI(uint32 diff) override
    {
        jumpLock -= std::min(jumpLock, diff);
        switch (stage)
        {
            case CARAVAN_WAITING:   // nobody climbed on: the caravan leaves
            case CARAVAN_DONE:
                if (timer > diff)
                {
                    timer -= diff;
                    break;
                }
                summons.DespawnAll();
                me->DespawnOrUnsummon();
                break;
            case CARAVAN_MOUNTING:
                if (timer > diff)
                {
                    timer -= diff;
                    break;
                }
                if (Guard())
                    StartRide();
                else
                {
                    // the climb did not take: the kodo waits for another click
                    stage = CARAVAN_WAITING;
                    timer = 20 * IN_MILLISECONDS;
                    me->SetFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK);
                }
                break;
            case CARAVAN_RIDING:
            {
                Player* player = Guard();
                if (!player)
                {
                    // the guard got off: the driver turns back, there is no credit
                    if (Creature* driver = Driver())
                        driver->AI()->Talk(SAY_BALGOR_TURNING_BACK);
                    End(4 * IN_MILLISECONDS);
                    break;
                }
                rideTime += diff;
                if (!movedOut && rideTime > uint32(delivery ? 1500 : 6000))
                {
                    movedOut = true;
                    if (Creature* master = me->FindNearestCreature(delivery ? NPC_ROCCO_WHIPSHANK : NPC_HALGA_BLOODEYE, 150.0f))
                        master->AI()->Talk(delivery ? SAY_ROCCO_RIDE_HARD : SAY_HALGA_MOVE_OUT);
                }
                Ambush(diff);
                launchTimer -= std::min(launchTimer, diff);
                if (me->movespline->Finalized())
                {
                    if (me->GetExactDist2d(route.back().x, route.back().y) < 8.0f)
                        Arrive(player);
                    else if (!launchTimer)
                    {
                        launchTimer = 2 * IN_MILLISECONDS;   // something stopped the kodo: on it goes
                        Launch();
                    }
                }
                break;
            }
            default:
                break;
        }
    }
};

// Burning Blade Mount 34593: runs alongside the caravan and sends its rider across
struct npc_caravan_burning_blade_mount : public ScriptedAI
{
    npc_caravan_burning_blade_mount(Creature* creature) : ScriptedAI(creature) { }

    uint32 cueTimer = urand(5, 8) * IN_MILLISECONDS;
    bool leaving = false;

    void InitializeAI() override
    {
        me->SetReactState(REACT_PASSIVE);
    }

    void Reset() override { }
    void AttackStart(Unit* /*who*/) override { }
    void MoveInLineOfSight(Unit* /*who*/) override { }
    void EnterEvadeMode(EvadeReason /*why*/) override { }

    void UpdateAI(uint32 diff) override
    {
        if (leaving)
            return;
        if (cueTimer > diff)
        {
            cueTimer -= diff;
            return;
        }
        cueTimer = 1500;
        TempSummon* summon = me->ToTempSummon();
        Unit* summoner = summon ? summon->GetSummoner() : nullptr;
        Creature* kodo = summoner ? summoner->ToCreature() : nullptr;
        Vehicle* kit = me->GetVehicleKit();
        Unit* rider = kit ? kit->GetPassenger(0) : nullptr;
        if (!kodo || kodo->AI()->GetData(DATA_CARAVAN_STAGE) != CARAVAN_RIDING || !rider || !rider->IsAlive())
        {
            // the caravan is gone or the rider is off: the mount runs
            leaving = true;
            me->GetMotionMaster()->MovePoint(0, me->GetNearPosition(30.0f, float(M_PI) / 2.0f));
            me->DespawnOrUnsummon(3 * IN_MILLISECONDS);
            return;
        }
        if (me->GetExactDist2d(kodo) > 16.0f || kodo->AI()->GetData(DATA_CARAVAN_JUMP))
            return;   // not alongside yet, or another raider is in the air
        int8 perchSeat = 0;
        Unit* perch = CaravanPerch(kodo, perchSeat);
        if (!perch || perch->GetVehicleKit()->GetPassenger(perchSeat))
            return;   // somebody stands in front of the guard already
        if (Creature* raider = rider->ToCreature())
            raider->AI()->DoAction(ACTION_CARAVAN_JUMP);
    }
};

// Burning Blade Raider 34594: rides the mount, jumps on in front of the guard and swings at him
struct npc_caravan_burning_blade_raider : public ScriptedAI
{
    npc_caravan_burning_blade_raider(Creature* creature) : ScriptedAI(creature) { }

    ObjectGuid kodoGUID;
    uint32 checkTimer = 1000;
    uint32 swingTimer = 1500;
    bool jumped = false;
    bool landed = false;
    bool leaving = false;

    void Reset() override { }

    void IsSummonedBy(Unit* summoner) override
    {
        // the mount carries the raider, the caravan called the mount
        TempSummon* mount = summoner->ToTempSummon();
        if (!mount || (mount->GetEntry() != NPC_BURNING_BLADE_MOUNT && mount->GetEntry() != NPC_MORSHAN_BURNING_BLADE_MOUNT))
            return;
        kodoGUID = mount->GetSummonerGUID();
        me->SetReactState(REACT_PASSIVE);
    }

    Creature* Kodo() const
    {
        return kodoGUID.IsEmpty() ? nullptr : ObjectAccessor::GetCreature(*me, kodoGUID);
    }

    void DoAction(int32 action) override
    {
        if (action != ACTION_CARAVAN_JUMP || jumped)
            return;
        Creature* kodo = Kodo();
        int8 perchSeat = 0;
        if (!kodo || !CaravanPerch(kodo, perchSeat))
            return;
        jumped = true;
        kodo->AI()->SetData(DATA_CARAVAN_JUMP, 2500);
        me->ExitVehicle();
        // to where the kodo will be when the raider comes down
        float const lead = kodo->GetSpeed(MOVE_RUN) * me->GetExactDist2d(kodo) / 20.0f;
        me->GetMotionMaster()->MoveJump(kodo->GetPositionX() + lead * std::cos(kodo->GetOrientation()),
            kodo->GetPositionY() + lead * std::sin(kodo->GetOrientation()), kodo->GetPositionZ() + 2.0f, 20.0f, 8.0f);
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type != EFFECT_MOTION_TYPE || id != EVENT_JUMP || !jumped || landed)
            return;
        landed = true;
        Creature* kodo = Kodo();
        int8 perchSeat = 0;
        Unit* seat = kodo ? CaravanPerch(kodo, perchSeat) : nullptr;
        if (!seat || !CaravanGuard(kodo))
            return;   // nobody to fight: the next check sends the raider off
        if (!seat->GetVehicleKit()->GetPassenger(perchSeat) && me->GetExactDist2d(kodo) < 12.0f)
        {
            me->EnterVehicle(seat, perchSeat);
            checkTimer = 2 * IN_MILLISECONDS;   // time to take the seat before the next check
            return;
        }
        // came down beside the kodo: the next check sends him off (he has no mount any more)
    }

    void UpdateAI(uint32 diff) override
    {
        if (kodoGUID.IsEmpty())   // not with a caravan: an ordinary raider
        {
            if (UpdateVictim())
                DoMeleeAttackIfReady();
            return;
        }
        if (leaving)
            return;
        if (checkTimer > diff)
            checkTimer -= diff;
        else
        {
            checkTimer = 1000;
            Creature* kodo = Kodo();
            if (!kodo || kodo->AI()->GetData(DATA_CARAVAN_STAGE) != CARAVAN_RIDING || (!jumped && !me->GetVehicle())
                || (landed && !me->GetVehicle()))
            {
                // the caravan got through or turned back, or the mount is gone: off he goes
                leaving = true;
                me->ExitVehicle();
                me->SetReactState(REACT_PASSIVE);
                me->GetThreatManager().ClearAllThreat();
                me->CombatStop(true);
                if (kodo)
                    me->GetMotionMaster()->MoveFleeing(kodo, 4 * IN_MILLISECONDS);
                me->DespawnOrUnsummon(4 * IN_MILLISECONDS);
                return;
            }
        }
        Unit* seat = me->GetVehicleBase();
        if (seat && (seat->GetEntry() == NPC_THE_HOTSEAT || seat->GetEntry() == NPC_MORSHAN_RIDING_SHOTGUN || seat->GetEntry() == NPC_MORSHAN_ATTACK_CONTROLLER))
        {
            // in front of the guard: a swing every two seconds
            if (swingTimer > diff)
                swingTimer -= diff;
            else
            {
                swingTimer = 2 * IN_MILLISECONDS;
                Creature* kodo = Kodo();
                if (Player* guard = kodo ? CaravanGuard(kodo) : nullptr)
                    me->AttackerStateUpdate(guard, true);
            }
            return;
        }
    }
};

/*######
## Mor'shan Caravan Pick-Up (29109) and Mor'shan Caravan Delivery (29111)
######*/

// The caravan goes on from the Crossroads to the Mor'shan Rampart, in two rides.
// Pick-Up: Rocco Whipshank calls the Chief Caravan Kodo (driver Balgor Whipshank, Riding Shotgun as the seat of the guard, the
// supply cart behind). Nobody attacks on the way; Balgor talks. At Dreadmist camp the Burning Blade is waiting: the guard is
// netted, Balgor is carried off and the cart is stolen. The ride itself is the credit.
// Delivery: Nagala Whipshank calls the Master Caravan Kodo. The guard sits on the kodo itself (its second seat has the action
// bar), Burning Blade Attackers ride alongside and jump on the attack controller the kodo carries. Credit at the rampart.
// Sources: the client data (96566, 96749, 96661, 96786, 96788, 96792, Vehicle.dbc 1580-1591), the lines in broadcast_text, the
// sightings and quotes on Wowhead and the spawns that were recorded during a ride. The pace of the scene at the camp and of the
// attackers is a reconstruction.
// Chief Caravan Kodo 52209, Master Caravan Kodo 52314
struct npc_morshan_caravan_kodo : public ScriptedAI
{
    npc_morshan_caravan_kodo(Creature* creature) : ScriptedAI(creature), summons(creature),
        delivery(creature->GetEntry() == NPC_MASTER_CARAVAN_KODO) { }

    SummonList summons;
    bool const delivery;
    ObjectGuid playerGUID;
    ObjectGuid cartGUID;
    ObjectGuid ambusherGUID[3];
    Movement::PointsArray route;
    uint32 stage = CARAVAN_WAITING;
    uint32 timer = 35 * IN_MILLISECONDS;
    uint32 rideTime = 0;
    uint32 ambushTimer = 0;
    uint32 launchTimer = 0;
    uint32 jumpLock = 0;
    uint32 mounts = 0;
    uint8 said = 0;        // the lines of the driver so far
    uint8 scene = 0;       // the step of the ambush at the camp
    bool greeted = false;
    bool campSaid = false;

    void InitializeAI() override
    {
        me->SetReactState(REACT_PASSIVE);
    }

    void Reset() override { }
    void AttackStart(Unit* /*who*/) override { }
    void MoveInLineOfSight(Unit* /*who*/) override { }
    void EnterEvadeMode(EvadeReason /*why*/) override { }
    void OnCharmed(bool /*apply*/) override { }   // the guard of the Master Caravan Kodo sits on its control seat: this AI stays

    void DamageTaken(Unit* /*attacker*/, uint32& damage) override
    {
        damage = 0;
    }

    uint32 GetData(uint32 type) const override
    {
        if (type == DATA_CARAVAN_STAGE)
            return stage;
        if (type == DATA_CARAVAN_JUMP)
            return jumpLock;
        return 0;
    }

    void SetData(uint32 type, uint32 value) override
    {
        if (type == DATA_CARAVAN_JUMP)
            jumpLock = value;
    }

    void IsSummonedBy(Unit* summoner) override
    {
        if (summoner->GetTypeId() != TYPEID_PLAYER)
            return;
        playerGUID = summoner->GetGUID();
        me->SetFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK);
        me->SummonCreature(delivery ? NPC_MORSHAN_CARAVAN_CART : NPC_CROSSROADS_CARAVAN_CART, me->GetNearPosition(9.0f, float(M_PI)), TEMPSUMMON_MANUAL_DESPAWN);
    }

    void JustSummoned(Creature* summon) override
    {
        summons.Summon(summon);
        switch (summon->GetEntry())
        {
            case NPC_CROSSROADS_CARAVAN_CART:
            case NPC_MORSHAN_CARAVAN_CART:
                cartGUID = summon->GetGUID();
                summon->SetReactState(REACT_PASSIVE);
                summon->SetSpeed(MOVE_RUN, 1.4f);
                break;
            case NPC_MORSHAN_BURNING_BLADE_MOUNT:
                summon->SetSpeed(MOVE_RUN, 1.6f);
                summon->GetMotionMaster()->MoveFollow(me, 9.0f, (++mounts & 1) ? float(M_PI) / 2.0f : -float(M_PI) / 2.0f);
                break;
            case NPC_BURNING_BLADE_AMBUSHER_CART:
            case NPC_BURNING_BLADE_AMBUSHER_GRAB:
            case NPC_BURNING_BLADE_AMBUSHER_ASK:
                summon->SetReactState(REACT_PASSIVE);
                summon->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE);
                break;
            default:
                break;
        }
    }

    void SummonedCreatureDespawn(Creature* summon) override
    {
        summons.Despawn(summon);
    }

    void PassengerBoarded(Unit* who, int8 seatId, bool apply) override
    {
        // the guard of the Master Caravan Kodo gets its action bar, not its reins
        if (Player* player = who->ToPlayer())
            if (apply && seatId == SEAT_CARAVAN_GUARD)
                player->SetClientControl(me, false);
    }

    Creature* Driver() const
    {
        Vehicle* kit = me->GetVehicleKit();
        Unit* driver = kit ? kit->GetPassenger(SEAT_CARAVAN_DRIVER) : nullptr;
        return driver ? driver->ToCreature() : nullptr;
    }

    void DriverSays(uint8 line, Player* player = nullptr)
    {
        if (Creature* driver = Driver())
            driver->AI()->Talk(line, player);
    }

    void OnSpellClick(Unit* clicker, bool& result) override
    {
        Player* player = clicker->ToPlayer();
        if (!player || stage != CARAVAN_WAITING || player->GetGUID() != playerGUID || !me->IsWithinDistInMap(player, 10.0f))
            return;
        if (player->GetQuestStatus(delivery ? QUEST_MORSHAN_CARAVAN_DELIVERY : QUEST_MORSHAN_CARAVAN_PICKUP) != QUEST_STATUS_INCOMPLETE)
            return;
        // the client data have Mount Caravan Kodo (Part 03 / 04) for this, aimed at 'a nearby entry'; with two caravans side by
        // side that could seat a player on the wrong one, so the player is seated directly
        if (delivery)
            player->EnterVehicle(me, SEAT_CARAVAN_GUARD);
        else if (Unit* seat = CaravanGuardSeat(me))
            player->CastSpell(seat, SPELL_RIDE_CARAVAN_KODO, true);
        else
            return;
        result = true;
        stage = CARAVAN_MOUNTING;
        timer = 2 * IN_MILLISECONDS;
        me->RemoveFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK);
    }

    void BuildRoute()
    {
        route.clear();
        WaypointPath const* path = sWaypointMgr->GetPath(delivery ? PATH_MORSHAN_DELIVERY : PATH_MORSHAN_PICKUP);
        if (!path || path->empty())
            return;
        G3D::Vector3 last(me->GetPositionX(), me->GetPositionY(), me->GetPositionZ());
        route.push_back(last);
        for (WaypointData const* node : *path)
        {
            G3D::Vector3 const next(node->x, node->y, node->z);
            uint32 const steps = std::max<uint32>(1, uint32(std::ceil((next - last).length() / 6.0f)));
            for (uint32 i = 1; i <= steps; ++i)
            {
                G3D::Vector3 point = last + (next - last) * (float(i) / float(steps));
                float const ground = me->GetMap()->GetHeight(me->GetPhaseMask(), point.x, point.y, point.z + 4.0f);
                if (ground > INVALID_HEIGHT && std::fabs(ground - point.z) < 6.0f)
                    point.z = ground;
                route.push_back(point);
            }
            last = next;
        }
    }

    void Launch()
    {
        G3D::Vector3 const here(me->GetPositionX(), me->GetPositionY(), me->GetPositionZ());
        size_t nearest = 0;
        for (size_t i = 1; i < route.size(); ++i)
            if ((route[i] - here).squaredLength() < (route[nearest] - here).squaredLength())
                nearest = i;
        Movement::PointsArray points;
        points.push_back(here);
        for (size_t i = nearest + 1; i < route.size(); ++i)
            points.push_back(route[i]);
        if (points.size() < 2)
            return;
        Movement::MoveSplineInit init(me);
        init.MovebyPath(points);
        init.SetUncompressed();
        init.SetWalk(false);
        init.Launch();
    }

    void StartRide()
    {
        BuildRoute();
        if (route.size() < 2)
        {
            TC_LOG_ERROR("scripts", "npc_morshan_caravan_kodo: no waypoint path for the caravan of {}", me->GetEntry());
            End(0);
            return;
        }
        stage = CARAVAN_RIDING;
        me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE);
        ambushTimer = 20 * IN_MILLISECONDS;
        if (Creature* cart = ObjectAccessor::GetCreature(*me, cartGUID))
            cart->GetMotionMaster()->MoveFollow(me, 7.0f, float(M_PI));
        Launch();
    }

    float ToTheEnd() const
    {
        return me->GetExactDist2d(route.back().x, route.back().y);
    }

    // Pick-Up: nobody attacks; the driver talks
    void Chatter()
    {
        static uint32 const when[6] = { 3000, 14000, 28000, 42000, 56000, 70000 };
        if (said < 6 && rideTime >= when[said])
            DriverSays(said++);
        if (!campSaid && ToTheEnd() < 110.0f)
        {
            campSaid = true;
            DriverSays(SAY_MORSHAN_DRIVER_CAMP);   // "we'll stop at Dreadmist Camp"
        }
    }

    // Delivery: Burning Blade Attackers on their mounts, and the driver calls them out
    void Attackers(uint32 diff)
    {
        float const left = ToTheEnd();
        if (said == 1 && left < 600.0f)
        {
            said = 2;
            DriverSays(SAY_MORSHAN_CLOSING_IN);
        }
        else if (said == 2 && left < 250.0f)
        {
            said = 3;
            DriverSays(SAY_MORSHAN_ALL_SIDES);
        }
        if (left < 150.0f)
            return;
        if (ambushTimer > diff)
        {
            ambushTimer -= diff;
            return;
        }
        if (said == 0)
        {
            said = 1;
            DriverSays(SAY_MORSHAN_SPOTTED);
        }
        DoCast(me, SPELL_MORSHAN_SUMMON_BURNING_BLADE, true);
        ambushTimer = urand(4, 7) * IN_MILLISECONDS;
    }

    // The ambush at Dreadmist camp, step by step. Returns the time to the next step, 0 when the scene is over.
    uint32 SceneStep(Player* player)
    {
        Creature* nagala = me->FindNearestCreature(NPC_NAGALA_WHIPSHANK, 100.0f);
        Creature* withCart = ObjectAccessor::GetCreature(*me, ambusherGUID[0]);
        Creature* grabber = ObjectAccessor::GetCreature(*me, ambusherGUID[1]);
        Creature* asker = ObjectAccessor::GetCreature(*me, ambusherGUID[2]);
        switch (scene++)
        {
            case 0:
                DriverSays(SAY_MORSHAN_DRIVER_LUNCH);
                return 4000;
            case 1:
                if (nagala)
                    nagala->AI()->Talk(0);
                return 4000;
            case 2:
            {
                // where the three were recorded, around the place the caravan stops
                static Position const spots[3] = { { 314.3f, -2560.4f, 92.6f, 5.73f }, { 320.9f, -2573.4f, 92.1f, 1.29f }, { 310.8f, -2568.6f, 93.9f, 0.49f } };
                static uint32 const entries[3] = { NPC_BURNING_BLADE_AMBUSHER_CART, NPC_BURNING_BLADE_AMBUSHER_GRAB, NPC_BURNING_BLADE_AMBUSHER_ASK };
                for (uint8 i = 0; i < 3; ++i)
                    if (Creature* ambusher = me->SummonCreature(entries[i], spots[i], TEMPSUMMON_MANUAL_DESPAWN))
                        ambusherGUID[i] = ambusher->GetGUID();
                withCart = ObjectAccessor::GetCreature(*me, ambusherGUID[0]);
                if (withCart)
                {
                    withCart->AI()->Talk(0);
                    // the net holds the guard; it gets a limited life so that it can never outlast the scene
                    if (Aura* net = withCart->AddAura(SPELL_BURNING_BLADE_NET, player))
                    {
                        net->SetMaxDuration(20 * IN_MILLISECONDS);
                        net->SetDuration(20 * IN_MILLISECONDS);
                    }
                }
                return 3500;
            }
            case 3:
                if (withCart)
                    withCart->AI()->Talk(1);
                return 3500;
            case 4:
                if (asker)
                    asker->AI()->Talk(0);
                return 3000;
            case 5:
                if (grabber)
                    grabber->AI()->Talk(0);
                return 3000;
            case 6:
            {
                Creature* driver = Driver();
                if (driver)
                {
                    driver->AI()->Talk(SAY_MORSHAN_DRIVER_HELP);
                    if (grabber)
                    {
                        driver->ExitVehicle();
                        driver->EnterVehicle(grabber, 0);
                    }
                }
                Creature* cart = ObjectAccessor::GetCreature(*me, cartGUID);
                if (cart)
                {
                    if (withCart)
                        withCart->EnterVehicle(cart, 0);
                    cart->GetMotionMaster()->Clear();
                    cart->GetMotionMaster()->MovePoint(0, 360.0f, -2486.0f, 92.0f);
                }
                // up the path to Dreadmist Peak
                if (grabber)
                    grabber->GetMotionMaster()->MovePoint(0, 353.0f, -2498.0f, 92.0f);
                if (asker)
                    asker->GetMotionMaster()->MovePoint(0, 345.0f, -2505.0f, 92.0f);
                return 3000;
            }
            case 7:
                if (nagala)
                    nagala->AI()->Talk(1);
                return 3000;
            default:
                return 0;
        }
    }

    void Arrive(Player* player)
    {
        if (delivery)
        {
            DriverSays(SAY_MORSHAN_MADE_IT, player);
            me->CastSpell(player, SPELL_MORSHAN_DELIVERY_CREDIT, true);
            player->KilledMonsterCredit(NPC_MORSHAN_DELIVERY_CREDIT);
        }
        else
            player->KilledMonsterCredit(NPC_MORSHAN_PICKUP_CREDIT);
        player->RemoveAurasDueToSpell(SPELL_BURNING_BLADE_NET);
        player->ExitVehicle();
        End(8 * IN_MILLISECONDS);
    }

    void End(uint32 delay)
    {
        stage = CARAVAN_DONE;
        timer = delay;
        me->StopMoving();
        if (Player* player = ObjectAccessor::GetPlayer(*me, playerGUID))
            player->RemoveAurasDueToSpell(SPELL_BURNING_BLADE_NET);
    }

    void UpdateAI(uint32 diff) override
    {
        jumpLock -= std::min(jumpLock, diff);
        switch (stage)
        {
            case CARAVAN_WAITING:
                if (delivery && !greeted && timer < 33 * IN_MILLISECONDS)
                {
                    greeted = true;
                    DriverSays(SAY_MORSHAN_HOP_ON, ObjectAccessor::GetPlayer(*me, playerGUID));
                }
                [[fallthrough]];   // nobody climbed on: the caravan leaves
            case CARAVAN_DONE:
                if (timer > diff)
                {
                    timer -= diff;
                    break;
                }
                summons.DespawnAll();
                me->DespawnOrUnsummon();
                break;
            case CARAVAN_MOUNTING:
                if (timer > diff)
                {
                    timer -= diff;
                    break;
                }
                if (CaravanGuard(me))
                    StartRide();
                else
                {
                    stage = CARAVAN_WAITING;
                    timer = 20 * IN_MILLISECONDS;
                    me->SetFlag(UNIT_FIELD_NPC_FLAGS, UNIT_NPC_FLAG_SPELLCLICK);
                }
                break;
            case CARAVAN_RIDING:
            {
                Player* player = CaravanGuard(me);
                if (!player)
                {
                    DriverSays(delivery ? uint8(SAY_MORSHAN_TURNING_BACK) : uint8(SAY_MORSHAN_DRIVER_TURNING_BACK));
                    End(4 * IN_MILLISECONDS);
                    break;
                }
                rideTime += diff;
                if (delivery)
                    Attackers(diff);
                else
                    Chatter();
                launchTimer -= std::min(launchTimer, diff);
                if (me->movespline->Finalized())
                {
                    if (ToTheEnd() < 8.0f)
                    {
                        if (delivery)
                            Arrive(player);
                        else
                        {
                            stage = CARAVAN_SCENE;
                            timer = 1 * IN_MILLISECONDS;
                        }
                    }
                    else if (!launchTimer)
                    {
                        launchTimer = 2 * IN_MILLISECONDS;
                        Launch();
                    }
                }
                break;
            }
            case CARAVAN_SCENE:
            {
                Player* player = CaravanGuard(me);
                if (!player)
                {
                    End(4 * IN_MILLISECONDS);   // the guard is gone before the scene is over: no credit
                    break;
                }
                if (timer > diff)
                {
                    timer -= diff;
                    break;
                }
                timer = SceneStep(player);
                if (!timer)
                    Arrive(player);
                break;
            }
            default:
                break;
        }
    }
};

// Face Smash 65704 : the butt-end of the gun of the guard, for the raider who stands in front of him
// (seat 1 of The Hotseat). The spell itself lands on its caster; the thump is Hit Raider in the Face.
class spell_caravan_face_smash : public SpellScript
{
    PrepareSpellScript(spell_caravan_face_smash);

    void HandleAfterCast()
    {
        // the spell is cast 'by the charmer': its caster is the guard, the seat is what he sits on
        Unit* seat = GetCaster();
        if (!seat->GetVehicleKit())
            seat = seat->GetVehicleBase();
        Vehicle* kit = seat ? seat->GetVehicleKit() : nullptr;
        Unit* raider = kit ? kit->GetPassenger(SEAT_HOTSEAT_RAIDER) : nullptr;
        // the Master Caravan Kodo carries the guard himself and the raider on its attack controller
        if (kit && seat->GetEntry() == NPC_MASTER_CARAVAN_KODO)
        {
            Unit* controller = kit->GetPassenger(SEAT_MASTER_KODO_CONTROLLER);
            raider = controller && controller->GetVehicleKit() ? controller->GetVehicleKit()->GetPassenger(0) : nullptr;
        }
        if (!raider || !raider->IsAlive() || (raider->GetEntry() != NPC_BURNING_BLADE_RAIDER && raider->GetEntry() != NPC_BURNING_BLADE_ATTACKER))
            return;
        // Hit Raider in the Face aims at the second passenger of its caster: on the Master Caravan Kodo that is the guard himself
        if (seat->GetEntry() != NPC_MASTER_CARAVAN_KODO)
            seat->CastSpell(raider, SPELL_HIT_RAIDER_IN_THE_FACE, true);
        if (raider->IsAlive())
            if (Unit* guard = seat->GetCharmerOrOwnerOrSelf())
                guard->DealDamage(raider, raider->GetHealth(), nullptr, DIRECT_DAMAGE, SPELL_SCHOOL_MASK_NORMAL, nullptr, false);
    }

    void Register() override
    {
        AfterCast += SpellCastFn(spell_caravan_face_smash::HandleAfterCast);
    }
};

void AddSC_the_barrens()
{
    new npc_wizzlecrank_shredder();
    new npc_razormane_pillager();
    new spell_script<spell_groldom_net>("spell_groldom_net");
    new aura_script<spell_snared_in_net>("spell_snared_in_net");
    new AreaTrigger_at_groldom_farm();
    new creature_script<npc_barrent_wounded_defender>("npc_barrent_wounded_defender");
    new spell_script<spell_barrens_bandage>("spell_barrens_bandage");
    new creature_script<npc_crossroads_caravan_kodo>("npc_crossroads_caravan_kodo");
    new creature_script<npc_caravan_burning_blade_mount>("npc_caravan_burning_blade_mount");
    new creature_script<npc_caravan_burning_blade_raider>("npc_caravan_burning_blade_raider");
    new spell_script<spell_caravan_face_smash>("spell_caravan_face_smash");
    new creature_script<npc_morshan_caravan_kodo>("npc_morshan_caravan_kodo");
}
