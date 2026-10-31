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

/* ScriptData
SDName: Western_Plaguelands
SD%Complete:
SDComment:
SDCategory: Western Plaguelands
EndScriptData */

/* ContentData
EndContentData */

enum eQuests
{
    QUEST_SCHOLOMANCER_A = 27162,
    QUEST_SCHOLOMANCER_H = 26924,
};

enum eCreatures
{
    NPC_THASSARIAN           = 44453,
    NPC_KOLTIRA_DEATHVIEWER  = 44452,
    NPC_DARK_MASTER_GANDLING = 44323,

    FACTION_ANDORHAL_HELPER  = 1727, // friendly to Alliance and Horde players, hostile to monsters (Gandling = faction 21)
};

enum eSpells
{
    SPELL_SHADOWBOLT      = 79932,
    SPELL_SHADOW_ERUPTION = 79932, // real id is 86845 (shadow pools), untested, left as it was
    SPELL_SHADOW_PRISON   = 86780, // 15 s stun, nothing else (SpellEffect: Apply Aura Stun)
};

enum eEvents
{
    EVENT_SHADOW_BOLT = 1,
    EVENT_SHADOW_ERUPTION,
};

enum eTalks
{
    // Darkmaster Gandling, creature_text 44323
    SAY_INTRO,      // Prepare to die, $r!
    SAY_SPECIAL_1,  // Your life is forfeit.
    SAY_SPECIAL_2,  // Enough of this. The Cult of the Damned doesn't need Andorhal...

    // Thassarian 44453 and Koltira Deathweaver 44452 share the first groups
    SAY_HELPER_QUEST_ACCEPT = 0, // 45516
    SAY_HELPER_BATTLE_CRY   = 1, // 45042 / 45043
    SAY_HELPER_WHISPER      = 10, // Thassarian 45056
    SAY_KOLTIRA_WHISPER     = 5,  // Koltira 45056

    // dialogue after Gandling left, see broadcast_text 45045-45055
    SAY_THASSARIAN_1       = 2, // 45045
    SAY_KOLTIRA_1          = 2, // 45046
    SAY_THASSARIAN_LAUGH   = 3, // 45047
    SAY_THASSARIAN_2       = 4, // 45048
    SAY_KOLTIRA_2          = 3, // 45049
    SAY_THASSARIAN_3       = 5, // 45050
    SAY_THASSARIAN_4       = 6, // 45051
    SAY_THASSARIAN_5       = 7, // 45052
    SAY_KOLTIRA_3          = 4, // 45053
    SAY_THASSARIAN_LAUGH_2 = 8, // 45054
    SAY_THASSARIAN_6       = 9, // 45055
};

enum eActions
{
    ACTION_HELP_AGAINST_GANDLING = 1, // battle cry, attack Gandling
    ACTION_GANDLING_LEFT         = 2, // both helpers: stop fighting and go home; Thassarian also runs the dialogue with Koltira and whispers the players
};

// Dark Master Gandling 44323
struct npc_dark_master_gandling_quest : public ScriptedAI
{
    npc_dark_master_gandling_quest(Creature* creature) : ScriptedAI(creature), eventDone(false) { }

    EventMap events;
    bool eventDone;

    void Reset() override
    {
        SetCombatMovement(false);
        events.Reset();
        eventDone = false;
        me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_NPC | UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_PACIFIED);
    }

    // The outro ends combat on its own; an evade in the middle would Reset() him and open him up for another "kill"
    void EnterEvadeMode(EvadeReason why) override
    {
        if (eventDone)
            return;

        ScriptedAI::EnterEvadeMode(why);
    }

    void JustEngagedWith(Unit* who) override
    {
        Talk(SAY_INTRO);
        events.ScheduleEvent(EVENT_SHADOW_BOLT, urand(1.5 * IN_MILLISECONDS, 3 * IN_MILLISECONDS));
        events.ScheduleEvent(EVENT_SHADOW_ERUPTION, 12 * IN_MILLISECONDS);
    }

    void DamageTaken(Unit* attacker, uint32& damage) override
    {
        if (eventDone)
        {
            // Thassarian and Koltira hit him for real, but nobody finishes him: he leaves on his own
            if (damage >= me->GetHealth())
                damage = me->GetHealth() - 1;
            return;
        }

        // "At low health, Gandling traps the hero within a shadow prison" (threshold itself is not documented)
        if (!me->HealthBelowPctDamaged(15, damage))
            return;

        damage = 0;
        eventDone = true;
        events.Reset();
        me->InterruptNonMeleeSpells(true);
        me->SetReactState(REACT_PASSIVE);
        me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_PACIFIED);
        Talk(SAY_SPECIAL_1);

        Unit* victim = attacker ? attacker->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
        if (!victim)
            victim = attacker;
        if (victim)
            DoCast(victim, SPELL_SHADOW_PRISON);

        // Thassarian and Koltira stand in the square (sniff: 1291,-1531 and 1289,-1536) and now join in
        me->m_Events.Schedule(2500, [this]() { CallHelper(NPC_THASSARIAN); });
        me->m_Events.Schedule(3500, [this]() { CallHelper(NPC_KOLTIRA_DEATHVIEWER); });

        // "Koltira Deathweaver and Thassarian arrive and break the hero out of the prison"
        me->m_Events.Schedule(6000, [this]()
        {
            me->InterruptNonMeleeSpells(true);
            std::list<Player*> players;
            GetPlayerListInGrid(players, me, 100.0f);
            for (Player* player : players)
                player->RemoveAurasDueToSpell(SPELL_SHADOW_PRISON);
        });

        me->m_Events.Schedule(10000, [this]()
        {
            Talk(SAY_SPECIAL_2);
            HandleCompleteQuest();
        });

        // "Darkmaster Gandling teleports away from the battlefield" (no teleport visual known, he just leaves)
        me->m_Events.Schedule(14000, [this]()
        {
            if (Creature* thassarian = me->FindNearestCreature(NPC_THASSARIAN, 40.0f))
                thassarian->AI()->DoAction(ACTION_GANDLING_LEFT);
            if (Creature* koltira = me->FindNearestCreature(NPC_KOLTIRA_DEATHVIEWER, 40.0f))
                koltira->AI()->DoAction(ACTION_GANDLING_LEFT);
            me->CombatStop(true);
            me->DespawnOrUnsummon();
        });
    }

    void UpdateAI(uint32 diff) override
    {
        if (eventDone)
            return;

        if (!UpdateVictim())
            return;

        if (me->HasUnitState(UNIT_STATE_CASTING))
            return;

        events.Update(diff);

        while (uint32 eventId = events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_SHADOW_BOLT:
                    if (Unit* target = me->GetVictim())
                        DoCast(target, SPELL_SHADOWBOLT);

                    events.ScheduleEvent(EVENT_SHADOW_BOLT, urand(3.1 * IN_MILLISECONDS, 3.5 * IN_MILLISECONDS));
                    break;
                case EVENT_SHADOW_ERUPTION:
                    if (Unit* target = me->GetVictim())
                        DoCast(target, SPELL_SHADOW_ERUPTION);

                    events.ScheduleEvent(EVENT_SHADOW_ERUPTION, 14 * IN_MILLISECONDS);
                    break;
            }
        }
    }

    private:
        void CallHelper(uint32 entry)
        {
            if (Creature* helper = me->FindNearestCreature(entry, 40.0f))
                helper->AI()->DoAction(ACTION_HELP_AGAINST_GANDLING);
        }

        // Both factions share the objective (quest_objective: 44323 for 27162 and 26924)
        void HandleCompleteQuest()
        {
            std::list<Player*> players;
            GetPlayerListInGrid(players, me, 100.0f);
            for (Player* player : players)
                if (player->GetQuestStatus(QUEST_SCHOLOMANCER_A) == QUEST_STATUS_INCOMPLETE || player->GetQuestStatus(QUEST_SCHOLOMANCER_H) == QUEST_STATUS_INCOMPLETE)
                    player->KilledMonsterCredit(me->GetEntry());
        }
};

// Thassarian 44453 and Koltira Deathweaver 44452: quest givers in the camps, helpers in the square next to Gandling
class npc_scholomancer_helper : public CreatureScript
{
    public:
        npc_scholomancer_helper(char const* name) : CreatureScript(name) { }

        bool OnQuestAccept(Player* /*player*/, Creature* creature, Quest const* quest) override
        {
            if (quest->GetQuestId() == QUEST_SCHOLOMANCER_A || quest->GetQuestId() == QUEST_SCHOLOMANCER_H)
                creature->AI()->Talk(SAY_HELPER_QUEST_ACCEPT);

            return true;
        }

        struct npc_scholomancer_helperAI : public ScriptedAI
        {
            npc_scholomancer_helperAI(Creature* creature) : ScriptedAI(creature) { }

            void Reset() override
            {
                // They only fight when Gandling's script calls them, not whatever walks past the square
                me->SetReactState(REACT_PASSIVE);

                // The helpers in the square (spawns next to Gandling) must be friendly to Alliance and Horde players and
                // unattackable for them; the questgivers in the camps (190+ yards away) keep their own faction.
                // Faction 1727 (friendly to players of both factions, hostile to monsters) instead of 35: with 35 Gandling
                // (faction 21) is neutral to them and Unit::IsValidAttackTarget refuses the creature-vs-creature attack,
                // so the helpers could not fight him. IMMUNE_TO_NPC (template flags) is removed for the same reason
                // (ThreatReference::FlagsAllowFighting checks it in both directions).
                if (me->GetHomePosition().GetExactDist2d(1288.65f, -1536.47f) < 40.0f)
                {
                    me->SetFaction(FACTION_ANDORHAL_HELPER);
                    me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_NPC);
                    me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_NON_ATTACKABLE);
                }
            }

            void DoAction(int32 action) override
            {
                switch (action)
                {
                    case ACTION_HELP_AGAINST_GANDLING:
                        if (Creature* gandling = me->FindNearestCreature(NPC_DARK_MASTER_GANDLING, 40.0f))
                        {
                            Talk(SAY_HELPER_BATTLE_CRY);
                            me->GetThreatManager().AddThreat(gandling, 1.0f, nullptr, true, true);
                            AttackStart(gandling);
                        }
                        break;
                    case ACTION_GANDLING_LEFT:
                        // Gandling is gone: end the fight (nobody else may stay on the threat list) and walk back to the spawn
                        me->CombatStop(true);
                        me->GetThreatManager().ClearAllThreat();
                        me->AttackStop();
                        me->GetMotionMaster()->MoveTargetedHome();
                        // Unit::Attack removed IMMUNE_TO_PC when the helper engaged Gandling; put it back so players cannot
                        // attack the helpers in the square afterwards (440)
                        if (me->GetHomePosition().GetExactDist2d(1288.65f, -1536.47f) < 40.0f)
                            me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_NON_ATTACKABLE);
                        if (me->GetEntry() == NPC_THASSARIAN)
                            StartDialogue();
                        break;
                }
            }

            void UpdateAI(uint32 /*diff*/) override
            {
                if (!UpdateVictim())
                    return;

                DoMeleeAttackIfReady();
            }

            private:
                // Order and lines: Wowpedia "Scholomancer (Alliance)" / WoWWiki "Scholomancer (Horde)"; the pauses are a guess
                void StartDialogue()
                {
                    uint32 delay = 3000;
                    ScheduleTalk(delay, NPC_THASSARIAN, SAY_THASSARIAN_1);            delay += 6000;
                    ScheduleTalk(delay, NPC_KOLTIRA_DEATHVIEWER, SAY_KOLTIRA_1);      delay += 6000;
                    ScheduleTalk(delay, NPC_THASSARIAN, SAY_THASSARIAN_LAUGH);        delay += 3000;
                    ScheduleTalk(delay, NPC_THASSARIAN, SAY_THASSARIAN_2);            delay += 5000;
                    ScheduleTalk(delay, NPC_KOLTIRA_DEATHVIEWER, SAY_KOLTIRA_2);      delay += 7000;
                    ScheduleTalk(delay, NPC_THASSARIAN, SAY_THASSARIAN_3);            delay += 5000;
                    ScheduleTalk(delay, NPC_THASSARIAN, SAY_THASSARIAN_4);            delay += 7000;
                    ScheduleTalk(delay, NPC_THASSARIAN, SAY_THASSARIAN_5);            delay += 7000;
                    ScheduleTalk(delay, NPC_KOLTIRA_DEATHVIEWER, SAY_KOLTIRA_3);      delay += 5000;
                    ScheduleTalk(delay, NPC_THASSARIAN, SAY_THASSARIAN_LAUGH_2);      delay += 3000;
                    ScheduleTalk(delay, NPC_THASSARIAN, SAY_THASSARIAN_6);            delay += 5000;

                    // Thassarian whispers the Alliance players, Koltira the Horde players
                    me->m_Events.Schedule(delay, [this]()
                    {
                        Creature* koltira = me->FindNearestCreature(NPC_KOLTIRA_DEATHVIEWER, 40.0f);
                        std::list<Player*> players;
                        GetPlayerListInGrid(players, me, 100.0f);
                        for (Player* player : players)
                        {
                            if (player->GetQuestStatus(QUEST_SCHOLOMANCER_A) == QUEST_STATUS_COMPLETE)
                                Talk(SAY_HELPER_WHISPER, player);
                            else if (koltira && player->GetQuestStatus(QUEST_SCHOLOMANCER_H) == QUEST_STATUS_COMPLETE)
                                koltira->AI()->Talk(SAY_KOLTIRA_WHISPER, player);
                        }
                    });
                }

                void ScheduleTalk(uint32 delay, uint32 entry, uint8 group)
                {
                    me->m_Events.Schedule(delay, [this, entry, group]()
                    {
                        if (entry == NPC_THASSARIAN)
                            Talk(group);
                        else if (Creature* other = me->FindNearestCreature(entry, 40.0f))
                            other->AI()->Talk(group);
                    });
                }
        };

        CreatureAI* GetAI(Creature* creature) const override
        {
            return new npc_scholomancer_helperAI(creature);
        }
};

void AddSC_western_plaguelands()
{
    new creature_script<npc_dark_master_gandling_quest>("npc_dark_master_gandling_quest");
    new npc_scholomancer_helper("npc_thassarian_quest");
    new npc_scholomancer_helper("npc_koltira_quest");
}
