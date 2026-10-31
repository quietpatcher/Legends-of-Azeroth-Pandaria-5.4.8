/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
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

// Silverpine Forest, Forsaken High Command: "The Warchief Cometh" (26965) and "Waiting to Exsanguinate" (27045).
// Ported from the TrinityCore Cataclysm Classic zone_silverpine_forest.cpp and adapted to this core's API.

#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "GameObjectAI.h"
#include "CombatAI.h"
#include "GridNotifiers.h"
#include "Player.h"
#include "ObjectAccessor.h"
#include "MotionMaster.h"
#include "SpellScript.h"
#include "SpellAuras.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "TemporarySummon.h"
#include "Vehicle.h"

using namespace std::chrono_literals;

// The core has no separate "uninteractible" unit flag; the NPC is simply made unselectable.
static void SetUninteractible(Unit* unit, bool apply)
{
    if (apply)
        unit->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);
    else
        unit->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);
}

Position const OrgrimmarPortalPos[3] =
{
    { 1358.62f, 1054.72f, 53.1200f, 0.0f },
    { 1393.27f, 1021.20f, 53.2225f, 0.0f },
    { 1404.71f, 1063.73f, 60.5617f, 0.0f }
};

Position const HellscreamElitePos[16] =
{
    { 1387.90f, 1029.71f, 53.21853f, 2.827433f },
    { 1389.79f, 1024.51f, 53.20833f, 2.827433f },
    { 1388.05f, 1026.91f, 53.20833f, 2.827433f },
    { 1388.16f, 1020.88f, 53.25523f, 2.827433f },
    { 1385.79f, 1025.99f, 53.22593f, 2.827433f },
    { 1386.69f, 1023.26f, 53.24393f, 2.827433f },
    { 1384.33f, 1022.04f, 53.28123f, 2.827433f },
    { 1391.10f, 1027.73f, 53.20483f, 2.827433f },

    { 1359.10f, 1046.55f, 52.97053f, 5.253441f },
    { 1360.89f, 1051.81f, 53.19793f, 5.253441f },
    { 1360.75f, 1048.84f, 53.12893f, 5.253441f },
    { 1364.43f, 1053.62f, 53.29343f, 5.253441f },
    { 1363.08f, 1048.15f, 53.22223f, 5.253441f },
    { 1364.08f, 1050.84f, 53.29163f, 5.253441f },
    { 1366.69f, 1050.31f, 53.34203f, 5.253441f },
    { 1357.85f, 1050.12f, 52.99823f, 5.253441f }
};

Position const GarroshPos = { 1402.45f, 1061.62f, 60.56173f, 3.926991f };

Position const GarroshJumpPos = { 1378.65f, 1044.23f, 53.8389f, 5.51524f };

Position const CromushPos = { 1404.71f, 1063.73f, 60.5617f, 2.827433f };

Position const AgathaPreRisePos = { 1364.02f, 1028.54f, 66.99143f };

Position const AgathaRisePos = { 1368.65f, 1032.19f, 63.3033f };

Position const AgathaPreResetPos = { 1364.02f, 1028.54f, 55.9914f };

Position const AgathaResetPos = { 1364.02f, 1028.54f, 58.1319f };

enum QuestTheWarchiefCometh
{
    QUEST_THE_WARCHIEF_COMETH               = 26965,

    NPC_LADY_SYLVANAS_WINDRUNNER_COMETH     = 44365,
    NPC_AGATHA_COMETH                       = 44608,
    NPC_GRAND_EXECUTOR_MORTUUS              = 44615,
    NPC_MALE_FALLEN_HUMAN                   = 44592,
    NPC_FEMALE_FALLEN_HUMAN                 = 44593,
    NPC_PORTAL_FROM_ORGRIMMAR               = 44630,
    NPC_GARROSH_HELLSCREAM                  = 44629,
    NPC_HIGH_WARLORD_CROMUSH_COMETH         = 44640,
    NPC_HELLSCREAM_ELITE_COMETH             = 44636,
    NPC_QUEST_MONSTER_CREDIT                = 44629,
    NPC_FORSAKEN_WARHORSE_UNPHASED          = 73595,

    SPELL_RAISE_FORSAKEN_COMETH             = 83173,
    SPELL_AIR_REVENANT_ENTRANCE             = 55761,
    SPELL_SIMPLE_TELEPORT                   = 12980,
    SPELL_WELCOME_TO_SILVERPINE_CREDIT      = 83384,

    EVENT_START_SCENE_COMETH                = 1,
    EVENT_SUMMON_PORTAL_COMETH              = 2,
    EVENT_SUMMON_GARROSH_COMETH             = 3,
    EVENT_AGATHA_RAISE_FORSAKEN             = 4, // Note: 4-8 are used.
    EVENT_SCENE_TALK_COMETH                 = 9, // Note: 9-36 are used.

    ACTION_START_SCENE_COMETH               = 1,

    TALK_SYLVANAS_COMETH_0                  = 0,
    TALK_SYLVANAS_COMETH_1                  = 1,
    TALK_SYLVANAS_COMETH_2                  = 2,
    TALK_SYLVANAS_COMETH_3                  = 3,
    TALK_SYLVANAS_COMETH_4                  = 4,
    TALK_SYLVANAS_COMETH_5                  = 5,
    TALK_SYLVANAS_COMETH_6                  = 6,
    TALK_SYLVANAS_COMETH_7                  = 7,
    TALK_SYLVANAS_COMETH_8                  = 8,
    TALK_SYLVANAS_COMETH_9                  = 9,
    TALK_SYLVANAS_COMETH_10                 = 10,
    TALK_GARROSH_COMETH_0                   = 0,
    TALK_GARROSH_COMETH_1                   = 1,
    TALK_GARROSH_COMETH_2                   = 2,
    TALK_GARROSH_COMETH_3                   = 3,
    TALK_GARROSH_COMETH_4                   = 4,
    TALK_GARROSH_COMETH_5                   = 5,
    TALK_GARROSH_COMETH_6                   = 6,
    TALK_GARROSH_COMETH_7                   = 7,
    TALK_GARROSH_COMETH_8                   = 8,
    TALK_GARROSH_COMETH_9                   = 9,
    TALK_GARROSH_COMETH_10                  = 10,
    TALK_CROMUSH_COMETH_0                   = 0,
    TALK_CROMUSH_COMETH_1                   = 1,

    PATH_CROMUSH                            = 3571216,
    PATH_GARROSH                            = 3570320,

    POINT_AGATHA_PRE_RISE                   = 1,
    POINT_AGATHA_RISE                       = 2,
    POINT_AGATHA_PRE_RESET                  = 3,
    POINT_AGATHA_RESET                      = 4,

    ANIMKIT_GENERAL_1                       = 609,
    ANIMKIT_SYLV_1                          = 595,
    ANIMKIT_SYLV_2                          = 606,
    ANIMKIT_GARROSH_1                       = 662,
    ANIMKIT_GARROSH_2                       = 595
};

// 44615 - Grand Executor Mortuus
struct npc_silverpine_grand_executor_mortuus : public ScriptedAI
{
    npc_silverpine_grand_executor_mortuus(Creature* creature) : ScriptedAI(creature), _summons(me), _eventInProgress(false) {}

    void OnQuestAccept(Player* /*player*/, Quest const* quest) override
    {
        if (quest->GetQuestId() == QUEST_THE_WARCHIEF_COMETH)
        {
            if (_eventInProgress)
                return;

            DoAction(ACTION_START_SCENE_COMETH);
        }
    }

    void Reset() override
    {
        _events.Reset();
        _garroshGUID.Clear();
        _cromushGUID.Clear();
        _sylvanasGUID.Clear();
        _agathaGUID.Clear();
        _summons.clear();
        _eventInProgress = false;
    }

    void JustSummoned(Creature* summon) override
    {
        _summons.Summon(summon);

        switch (summon->GetEntry())
        {
            case NPC_GARROSH_HELLSCREAM:
                summon->CastSpell(summon, SPELL_SIMPLE_TELEPORT);
                _garroshGUID = summon->GetGUID();
                break;

            case NPC_HELLSCREAM_ELITE_COMETH:
                summon->CastSpell(summon, SPELL_SIMPLE_TELEPORT);
                break;

            default:
                break;
        }
    }

    void DoAction(int32 param) override
    {
        switch (param)
        {
            case ACTION_START_SCENE_COMETH:
            {
                _eventInProgress = true;

                if (Creature* sylvanas = me->FindNearestCreature(NPC_LADY_SYLVANAS_WINDRUNNER_COMETH, 100.0f))
                {
                    _sylvanasGUID = sylvanas->GetGUID();

                    if (Creature* agatha = me->FindNearestCreature(NPC_AGATHA_COMETH, 100.0f))
                    {
                        _agathaGUID = agatha->GetGUID();

                        _events.ScheduleEvent(EVENT_START_SCENE_COMETH, 250ms);
                    }
                }

                break;
            }

            default:
                break;
        }
    }

    void UpdateAI(uint32 diff) override
    {
        _events.Update(diff);

        while (uint32 eventId = _events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_START_SCENE_COMETH:
                    _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH, 1s);
                    _events.ScheduleEvent(EVENT_SUMMON_PORTAL_COMETH, 4s);
                    _events.ScheduleEvent(EVENT_SUMMON_GARROSH_COMETH, 7s + 500ms);
                    break;

                case EVENT_SUMMON_PORTAL_COMETH:
                    SummonPortalsFromOrgrimmar();
                    break;

                case EVENT_SUMMON_GARROSH_COMETH:
                    SummonGarroshAndHisEliteGuards();
                    break;

                case EVENT_SCENE_TALK_COMETH:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_0);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 1, 4s + 500ms);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 1:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        sylvanas->SetFacingTo(0.808979f);

                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_1);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 2, 3s + 500ms);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 2:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        garrosh->GetMotionMaster()->MoveJump(GarroshJumpPos, 16.0f, 8.0f);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 3, 2s + 500ms);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 3:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        sylvanas->SetFacingTo(3.924652f);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 4, 1s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 4:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                            garrosh->SetFacingToObject(sylvanas);

                        garrosh->PlayOneShotAnimKitId(ANIMKIT_GARROSH_1);

                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_0);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 5, 12s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 5:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        garrosh->SetFacingTo(3.9444442f);

                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_1);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 6, 7s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 6:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        sylvanas->SetFacingTo(2.4260077f);

                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_2);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 7, 5s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 7:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        sylvanas->SetFacingTo(3.7350047f);
                        sylvanas->PlayOneShotAnimKitId(ANIMKIT_SYLV_1);

                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_3);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 8, 16s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 8:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_4);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 9, 4s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 9:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_2);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 10, 3s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 10:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_5);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 11, 6s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 11:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_6);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 12, 6s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 12:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        sylvanas->PlayOneShotAnimKitId(ANIMKIT_SYLV_2);

                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_7);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 13, 9s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 13:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_8);

                        _events.ScheduleEvent(EVENT_AGATHA_RAISE_FORSAKEN, 3s);
                    }
                    break;
                }

                case EVENT_AGATHA_RAISE_FORSAKEN:
                {
                    if (Creature* agatha = ObjectAccessor::GetCreature(*me, _agathaGUID))
                    {
                        agatha->GetMotionMaster()->MovePoint(POINT_AGATHA_PRE_RISE, AgathaPreRisePos, false);

                        _events.ScheduleEvent(EVENT_AGATHA_RAISE_FORSAKEN + 1, 2s + 500ms);
                    }
                    break;
                }

                case EVENT_AGATHA_RAISE_FORSAKEN + 1:
                {
                    if (Creature* agatha = ObjectAccessor::GetCreature(*me, _agathaGUID))
                    {
                        agatha->SetWalk(true);
                        agatha->GetMotionMaster()->MovePoint(POINT_AGATHA_RISE, AgathaRisePos, false);

                        _events.ScheduleEvent(EVENT_AGATHA_RAISE_FORSAKEN + 2, 6s);
                    }
                    break;
                }

                case EVENT_AGATHA_RAISE_FORSAKEN + 2:
                {
                    if (Creature* agatha = ObjectAccessor::GetCreature(*me, _agathaGUID))
                    {
                        agatha->CastSpell(agatha, SPELL_RAISE_FORSAKEN_COMETH);

                        _events.ScheduleEvent(EVENT_AGATHA_RAISE_FORSAKEN + 3, 10s);
                    }
                    break;
                }

                case EVENT_AGATHA_RAISE_FORSAKEN + 3:
                {
                    if (Creature* agatha = ObjectAccessor::GetCreature(*me, _agathaGUID))
                    {
                        agatha->GetMotionMaster()->MovePoint(POINT_AGATHA_PRE_RESET, AgathaPreResetPos, false);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 14, 750ms);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 14:
                {
                    if (Creature* cromush = ObjectAccessor::GetCreature(*me, _cromushGUID))
                    {
                        if (cromush->IsAIEnabled)
                            cromush->AI()->Talk(TALK_CROMUSH_COMETH_0);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 15, 3s + 500ms);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 15:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        garrosh->PlayOneShotAnimKitId(ANIMKIT_GENERAL_1);

                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_3);

                        if (Creature* agatha = ObjectAccessor::GetCreature(*me, _agathaGUID))
                            agatha->SetWalk(false);

                        _events.ScheduleEvent(EVENT_AGATHA_RAISE_FORSAKEN + 4, 12s);
                    }
                    break;
                }

                case EVENT_AGATHA_RAISE_FORSAKEN + 4:
                {
                    if (Creature* agatha = ObjectAccessor::GetCreature(*me, _agathaGUID))
                    {
                        agatha->GetMotionMaster()->MovePoint(POINT_AGATHA_RESET, AgathaResetPos, false);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 16, 1s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 16:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        sylvanas->PlayOneShotAnimKitId(ANIMKIT_GENERAL_1);

                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_9);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 17, 10s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 17:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_4);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 18, 6s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 18:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_5);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 19, 6s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 19:
                {
                    if (Creature* sylvanas = ObjectAccessor::GetCreature(*me, _sylvanasGUID))
                    {
                        if (sylvanas->IsAIEnabled)
                            sylvanas->AI()->Talk(TALK_SYLVANAS_COMETH_10);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 20, 5s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 20:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        garrosh->SetFacingTo(5.51524f);

                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_6);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 21, 4s + 500ms);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 21:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        if (Creature* cromush = ObjectAccessor::GetCreature(*me, _cromushGUID))
                        {
                            garrosh->SetFacingToObject(cromush);

                            _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 22, 500ms);
                        }
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 22:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        garrosh->PlayOneShotAnimKitId(ANIMKIT_GARROSH_2);

                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_7);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 23, 14s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 23:
                {
                    if (Creature* cromush = ObjectAccessor::GetCreature(*me, _cromushGUID))
                    {
                        if (cromush->IsAIEnabled)
                            cromush->AI()->Talk(TALK_CROMUSH_COMETH_1);

                        if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                        {
                            cromush->SetFacingToObject(garrosh);

                            _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 24, 2s + 500ms);
                        }
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 24:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        garrosh->SetFacingTo(5.6199603f);
                        garrosh->PlayOneShotAnimKitId(ANIMKIT_GARROSH_2);

                        if (garrosh->IsAIEnabled)
                            garrosh->AI()->Talk(TALK_GARROSH_COMETH_8);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 25, 8s + 500ms);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 25:
                {
                    if (Creature* garrosh = ObjectAccessor::GetCreature(*me, _garroshGUID))
                    {
                        garrosh->CastSpell(garrosh, SPELL_WELCOME_TO_SILVERPINE_CREDIT, true);

                        garrosh->GetMotionMaster()->MovePath(PATH_GARROSH, false);

                        _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 26, 9s);
                    }
                    break;
                }

                case EVENT_SCENE_TALK_COMETH + 26:
                    DespawnGarroshAndHisEliteGuards();
                    _events.ScheduleEvent(EVENT_SCENE_TALK_COMETH + 27, 500ms);
                    break;

                case EVENT_SCENE_TALK_COMETH + 27:
                    _summons.DespawnAll();
                    Reset();
                    break;

                default:
                    break;
            }
        }

        if (!UpdateVictim())
            return;
    }

    void SummonPortalsFromOrgrimmar()
    {
        for (Position const& pos : OrgrimmarPortalPos)
            me->SummonCreature(NPC_PORTAL_FROM_ORGRIMMAR, pos, TEMPSUMMON_TIMED_DESPAWN, 300s);

        std::list<Creature*> orgrimmarPortals;
        GetCreatureListWithEntryInGrid(orgrimmarPortals, me, NPC_PORTAL_FROM_ORGRIMMAR, 100.0f);

        for (Creature* portal : orgrimmarPortals)
            portal->CastSpell(portal, SPELL_AIR_REVENANT_ENTRANCE);
    }

    void SummonGarroshAndHisEliteGuards()
    {
        for (Position const& pos : HellscreamElitePos)
            me->SummonCreature(NPC_HELLSCREAM_ELITE_COMETH, pos, TEMPSUMMON_TIMED_DESPAWN, 300s);

        me->SummonCreature(NPC_GARROSH_HELLSCREAM, GarroshPos, TEMPSUMMON_TIMED_DESPAWN, 300s);

        if (Creature* cromush = me->SummonCreature(NPC_HIGH_WARLORD_CROMUSH_COMETH, CromushPos, TEMPSUMMON_TIMED_DESPAWN, 300s))
        {
            _cromushGUID = cromush->GetGUID();

            cromush->RemoveNpcFlag(UNIT_NPC_FLAG_QUESTGIVER);
            cromush->GetMotionMaster()->MovePath(PATH_CROMUSH, false);
        }
    }

    void DespawnGarroshAndHisEliteGuards()
    {
        for (ObjectGuid const& summonedCreature : _summons)
        {
            if (Creature* summon = ObjectAccessor::GetCreature(*me, summonedCreature))
                summon->CastSpell(summon, SPELL_SIMPLE_TELEPORT);
        }
    }

private:
    EventMap _events;
    ObjectGuid _garroshGUID;
    ObjectGuid _cromushGUID;
    ObjectGuid _sylvanasGUID;
    ObjectGuid _agathaGUID;
    SummonList _summons;
    bool _eventInProgress;
};

enum RaiseForsakenCometh
{
    ACTION_RISE_DURING_RAISE                = 1,
    ACTION_DESCEND_AFTER_RAISE              = 2,

    POINT_BEING_RISEN                       = 1,

    ANIMKIT_RESET                           = 0,
    ANIMKIT_FALLEN_HUMAN                    = 721
};

// 83173 - Raise Forsaken
class spell_silverpine_raise_forsaken_83173 : public AuraScript
{
    PrepareAuraScript(spell_silverpine_raise_forsaken_83173);

    void OnApply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        Unit* target = GetTarget();

        if (Creature* fallenHuman = target->ToCreature())
        {
            if (fallenHuman->IsAIEnabled)
                fallenHuman->AI()->DoAction(ACTION_RISE_DURING_RAISE);
        }
    }

    void OnRemove(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        Unit* target = GetTarget();

        if (Creature* fallenHuman = target->ToCreature())
        {
            if (fallenHuman->IsAIEnabled)
                fallenHuman->AI()->DoAction(ACTION_DESCEND_AFTER_RAISE);
        }
    }

    void Register() override
    {
        OnEffectApply += AuraEffectApplyFn(spell_silverpine_raise_forsaken_83173::OnApply, EFFECT_0, SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        OnEffectRemove += AuraEffectRemoveFn(spell_silverpine_raise_forsaken_83173::OnRemove, EFFECT_0, SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
    }
};

enum FallenHuman
{
    SPELL_FEIGNED                               = 80636,
    SPELL_FORSAKEN_TROOPER_MS_COMETH            = 83149,

    EVENT_ASCEND                                = 1,
    EVENT_TRANSFORM_INTO_FORSAKEN               = 2,
    EVENT_FACE_TOWARDS_SYLVANAS                 = 3,
    EVENT_EMOTE_TO_SYLVANAS                     = 4
};

// 44592, 44593 - Fallen Human
struct npc_silverpine_fallen_human : public ScriptedAI
{
    npc_silverpine_fallen_human(Creature* creature) : ScriptedAI(creature), _transformDone(false) {}

    void Reset() override
    {
        _transformDone = false;
        _events.Reset();
    }

    void DoAction(int32 action) override
    {
        switch (action)
        {
            case ACTION_RISE_DURING_RAISE:
                me->SetAIAnimKitId(ANIMKIT_FALLEN_HUMAN);
                _events.ScheduleEvent(EVENT_ASCEND, 1s);
                break;

            case ACTION_DESCEND_AFTER_RAISE:
                me->SetWalk(false);
                me->SetAIAnimKitId(ANIMKIT_RESET);
                me->GetMotionMaster()->MoveFall();
                _events.ScheduleEvent(EVENT_TRANSFORM_INTO_FORSAKEN, 1s);
                break;

            default:
                break;
        }
    }

    void UpdateAI(uint32 diff) override
    {
        _events.Update(diff);

        while (uint32 eventId = _events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_ASCEND:
                    me->SetWalk(true);
                    me->GetMotionMaster()->MovePoint(POINT_BEING_RISEN, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ() + 3.5f, false);
                    break;

                case EVENT_TRANSFORM_INTO_FORSAKEN:
                {
                    if (_transformDone)
                        return;

                    DoCastSelf(SPELL_FORSAKEN_TROOPER_MS_COMETH);

                    _transformDone = true;

                    _events.ScheduleEvent(EVENT_FACE_TOWARDS_SYLVANAS, 1s + 500ms);
                    break;
                }

                case EVENT_FACE_TOWARDS_SYLVANAS:
                    me->SetFacingTo(0.706837f);
                    _events.ScheduleEvent(EVENT_EMOTE_TO_SYLVANAS, 2s + 500ms);
                    break;

                case EVENT_EMOTE_TO_SYLVANAS:
                    me->HandleEmoteCommand(EMOTE_ONESHOT_SALUTE);
                    me->DespawnOrUnsummon(80000);
                    break;

                default:
                    break;
            }
        }
    }

private:
    EventMap _events;
    bool _transformDone;
};

enum SpellForsakenTrooperMasterScriptCometh
{
    SPELL_FORSAKEN_TROOPER_MALE_01_HC       = 83150,
    SPELL_FORSAKEN_TROOPER_MALE_02_HC       = 83163,
    SPELL_FORSAKEN_TROOPER_MALE_03_HC       = 83164,
    SPELL_FORSAKEN_TROOPER_MALE_04_HC       = 83165,
    SPELL_FORSAKEN_TROOPER_FEMALE_01_HC     = 83152,
    SPELL_FORSAKEN_TROOPER_FEMALE_02_HC     = 83166,
    SPELL_FORSAKEN_TROOPER_FEMALE_03_HC     = 83167,
    SPELL_FORSAKEN_TROOPER_FEMALE_04_HC     = 83168,

    DISPLAY_MALE_01_HC                      = 33978,
    DISPLAY_MALE_02_HC                      = 33980,
    DISPLAY_MALE_03_HC                      = 33979,
    DISPLAY_MALE_04_HC                      = 33981,
    DISPLAY_FEMALE_01_HC                    = 33982,
    DISPLAY_FEMALE_02_HC                    = 33983,
    DISPLAY_FEMALE_03_HC                    = 33984,
    DISPLAY_FEMALE_04_HC                    = 33985
};

// 83149 - Forsaken Trooper Master Script (Forsaken High Command)
class spell_silverpine_forsaken_trooper_masterscript_high_command : public SpellScript
{
    PrepareSpellScript(spell_silverpine_forsaken_trooper_masterscript_high_command);

    void HandleScriptEffect(SpellEffIndex /*effIndex*/)
    {
        if (Unit* caster = GetCaster())
        {
            caster->RemoveAura(SPELL_FEIGNED);

            uint32 spellId = SPELL_FORSAKEN_TROOPER_MALE_01_HC;

            switch (caster->GetDisplayId())
            {
                case DISPLAY_MALE_01_HC:
                    spellId = SPELL_FORSAKEN_TROOPER_MALE_01_HC;
                    break;
                case DISPLAY_MALE_02_HC:
                    spellId = SPELL_FORSAKEN_TROOPER_MALE_02_HC;
                    break;
                case DISPLAY_MALE_03_HC:
                    spellId = SPELL_FORSAKEN_TROOPER_MALE_03_HC;
                    break;
                case DISPLAY_MALE_04_HC:
                    spellId = SPELL_FORSAKEN_TROOPER_MALE_04_HC;
                    break;
                case DISPLAY_FEMALE_01_HC:
                    spellId = SPELL_FORSAKEN_TROOPER_FEMALE_01_HC;
                    break;
                case DISPLAY_FEMALE_02_HC:
                    spellId = SPELL_FORSAKEN_TROOPER_FEMALE_02_HC;
                    break;
                case DISPLAY_FEMALE_03_HC:
                    spellId = SPELL_FORSAKEN_TROOPER_FEMALE_03_HC;
                    break;
                case DISPLAY_FEMALE_04_HC:
                    spellId = SPELL_FORSAKEN_TROOPER_FEMALE_04_HC;
                    break;
                default:
                    break;
            }

            caster->CastSpell(caster, spellId, true);
        }
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_silverpine_forsaken_trooper_masterscript_high_command::HandleScriptEffect, EFFECT_0, SPELL_EFFECT_SCRIPT_EFFECT);
    }
};

enum AbandonedOuthouse
{
    QUEST_WAITING_TO_EXSANGUINATE           = 27045,

    SPELL_SUMMON_DEATHSTALKER_YORICK        = 83751
};

// 205143 - Abandoned Outhouse
struct go_silverpine_abandoned_outhouse : public GameObjectAI
{
    go_silverpine_abandoned_outhouse(GameObject* go) : GameObjectAI(go) { }

    bool OnQuestAccept(Player* player, Quest const* quest) override
    {
        if (quest->GetQuestId() == QUEST_WAITING_TO_EXSANGUINATE)
            player->CastSpell(player, SPELL_SUMMON_DEATHSTALKER_YORICK, true);

        return false;
    }

    bool OnGossipSelect(Player* player, uint32 /*sender*/, uint32 /*action*/) override
    {
        player->CastSpell(player, SPELL_SUMMON_DEATHSTALKER_YORICK, true);
        player->PlayerTalkClass->SendCloseGossip();
        return true;
    }
};

Position const YorickReadyPosition = { 1313.7f, 1211.99f, 58.5f, 4.564474f };

enum DeathstalkerRaneYorick
{
    PHASE_WAITING_TO_EXSANGUINATE           = 265,

    NPC_ARMOIRE_SUMMONED                    = 44893,
    NPC_PACKLEADER_IVAR_BLOODFANG           = 44884,

    SPELL_STEALTH                           = 34189,
    SPELL_PERMANENT_FEIGN_DEATH             = 29266,
    SPELL_HIDDEN_IN_ARMOIRE                 = 83788,
    SPELL_SUMMON_YORICK                     = 83751,
    SPELL_CANCEL_SUMMON_YORICK              = 83755,

    EVENT_START_QUEST_EXSANGUINATE          = 1,
    EVENT_WAIT_FOR_PLAYER_EXSANGUINATE      = 3,
    EVENT_RANE_HIDE                         = 4,
    EVENT_SET_GUID_FOR_ARMOIRE              = 5,
    EVENT_RANE_TALK_TO_PLAYER               = 6,
    EVENT_RANE_LAST_MOVE                    = 7,
    EVENT_RANE_SKIPS_PATH                   = 9,

    ACTION_RANE_JUMP_DEATH                  = 1,
    ACTION_RANE_SKIP_PATH                   = 2,

    TALK_YORICK_EXSANGUINATE_SUMMON         = 0,
    TALK_YORICK_EXSANGUINATE_HIDE           = 1,

    PATH_YORICK_UP                          = 3590560,
    PATH_YORICK_HIDE                        = 3590568,

    WAYPOINT_CLOSE_TO_ARMOIRE               = 14, // last node of the 15-node path
    WAYPOINT_HIDDEN_NEXT_TO_ARMOIRE         = 1  // last node of the 2-node path
};

// 44882 - Deathstalker Rane Yorick
struct npc_silverpine_deathstalker_rane_yorick : public ScriptedAI
{
    npc_silverpine_deathstalker_rane_yorick(Creature* creature) : ScriptedAI(creature), _playerArrived(false), _playerSkipped(false) { }

    void JustAppeared() override
    {
        me->SetPowerType(POWER_ENERGY);
        me->SetMaxPower(POWER_ENERGY, 100);
        me->SetPower(POWER_ENERGY, 100);
    }

    void IsSummonedBy(Unit* summoner) override
    {
        me->SetFacingToObject(summoner);

        _events.ScheduleEvent(EVENT_START_QUEST_EXSANGUINATE, 1s);
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type != WAYPOINT_MOTION_TYPE)
            return;

        uint32 pathId = me->GetWaypointPath();

        if (pathId == PATH_YORICK_UP && id == WAYPOINT_CLOSE_TO_ARMOIRE)
            _events.ScheduleEvent(EVENT_WAIT_FOR_PLAYER_EXSANGUINATE, 1s);

        if (pathId == PATH_YORICK_HIDE && id == WAYPOINT_HIDDEN_NEXT_TO_ARMOIRE)
        {
            me->SetFacingTo(4.6425757f);

            DoCastSelf(SPELL_STEALTH);

            SetUninteractible(me, true);

            _playerSkipped = true;
        }
    }

    void DoAction(int32 param) override
    {
        switch (param)
        {
            case ACTION_RANE_JUMP_DEATH:
                me->SetDisableGravity(true);
                _events.ScheduleEvent(EVENT_RANE_LAST_MOVE, 10ms);
                break;

            case ACTION_RANE_SKIP_PATH:
                me->PauseMovement();
                me->GetMotionMaster()->Clear();
                _events.Reset();
                _events.ScheduleEvent(EVENT_RANE_SKIPS_PATH, 250ms);
                break;

            default:
                break;
        }
    }

    void UpdateAI(uint32 diff) override
    {
        TempSummon* tempSummon = me->ToTempSummon();
        if (!tempSummon)
            return;

        _events.Update(diff);

        if (Unit* summoner = tempSummon->GetSummoner())
        {
            // Note: SummonPropertiesFlags::DespawnWhenExpired is NYI.
            if (!summoner->HasAura(SPELL_SUMMON_YORICK))
                me->DespawnOrUnsummon();
        }

        if (!_playerSkipped)
        {
            if (Unit* summoner = tempSummon->GetSummoner())
            {
                if (summoner->HasAura(SPELL_HIDDEN_IN_ARMOIRE))
                {
                    _playerSkipped = true;

                    DoAction(ACTION_RANE_SKIP_PATH);
                }
            }
        }

        while (uint32 eventId = _events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_START_QUEST_EXSANGUINATE:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        Talk(TALK_YORICK_EXSANGUINATE_SUMMON, summoner);

                        _events.ScheduleEvent(EVENT_START_QUEST_EXSANGUINATE + 1, 1s + 500ms);
                    }
                    break;
                }

                case EVENT_START_QUEST_EXSANGUINATE + 1:
                    me->GetMotionMaster()->MovePath(PATH_YORICK_UP, false);
                    break;

                case EVENT_WAIT_FOR_PLAYER_EXSANGUINATE:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (summoner->GetDistance2d(me) <= 5.0f && !_playerArrived)
                        {
                            _events.ScheduleEvent(EVENT_RANE_TALK_TO_PLAYER, 1s);
                            _playerArrived = true;
                        }
                        else
                            _events.ScheduleEvent(EVENT_WAIT_FOR_PLAYER_EXSANGUINATE, 1s);
                    }
                    break;
                }

                case EVENT_RANE_TALK_TO_PLAYER:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        Talk(TALK_YORICK_EXSANGUINATE_HIDE, summoner);

                        _events.ScheduleEvent(EVENT_RANE_HIDE, 3s);
                        _events.ScheduleEvent(EVENT_SET_GUID_FOR_ARMOIRE, 1s);
                    }
                    break;
                }

                case EVENT_RANE_HIDE:
                    me->GetMotionMaster()->MovePath(PATH_YORICK_HIDE, false);
                    break;

                case EVENT_SET_GUID_FOR_ARMOIRE:
                {
                    TC_LOG_INFO("scripts", "Yorick: EVENT_SET_GUID_FOR_ARMOIRE bloodfang={} armoire={}", _bloodfangGUID ? 1 : 0, _armoireGUID ? 1 : 0);

                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (!_bloodfangGUID)
                        {
                            if (Creature* bloodfang = me->FindNearestCreature(NPC_PACKLEADER_IVAR_BLOODFANG, 30.0f))
                            {
                                // Note: this core sets no owner GUID on plain temp summons, so compare the summoner GUID instead.
                                if (bloodfang->ToTempSummon() && bloodfang->ToTempSummon()->GetSummonerGUID() == summoner->GetGUID())
                                    _bloodfangGUID = bloodfang->GetGUID();
                            }
                        }

                        if (!_armoireGUID)
                        {
                            if (Creature* armoire = me->FindNearestCreature(NPC_ARMOIRE_SUMMONED, 30.0f))
                            {
                                // Note: this core sets no owner GUID on plain temp summons, so compare the summoner GUID instead.
                                if (armoire->ToTempSummon() && armoire->ToTempSummon()->GetSummonerGUID() == summoner->GetGUID())
                                {
                                    _armoireGUID = armoire->GetGUID();

                                    if (armoire->IsAIEnabled)
                                        armoire->AI()->SetGUID(me->GetGUID(), me->GetEntry());
                                }
                            }
                        }
                    }

                    if (!_bloodfangGUID || !_armoireGUID)
                        _events.ScheduleEvent(EVENT_SET_GUID_FOR_ARMOIRE, 1s);
                    break;
                }

                case EVENT_RANE_LAST_MOVE:
                    DoCastSelf(SPELL_PERMANENT_FEIGN_DEATH);
                    _events.ScheduleEvent(EVENT_RANE_LAST_MOVE + 1, 2s);
                    break;

                case EVENT_RANE_LAST_MOVE + 1:
                    me->SetDisableGravity(false);
                    break;

                case EVENT_RANE_SKIPS_PATH:
                    me->NearTeleportTo(YorickReadyPosition.GetPositionX(), YorickReadyPosition.GetPositionY(), YorickReadyPosition.GetPositionZ(), YorickReadyPosition.GetOrientation());
                    _events.ScheduleEvent(EVENT_RANE_SKIPS_PATH + 1, 250ms);
                    break;

                case EVENT_RANE_SKIPS_PATH + 1:
                    DoCastSelf(SPELL_STEALTH);
                    SetUninteractible(me, true);
                    _events.ScheduleEvent(EVENT_SET_GUID_FOR_ARMOIRE, 500ms);
                    break;

                default:
                    break;
            }
        }
    }

private:
    EventMap _events;
    ObjectGuid _armoireGUID;
    ObjectGuid _bloodfangGUID;
    bool _playerArrived;
    bool _playerSkipped;
};

enum WaitingToExsanguinate
{
    NPC_DEATHSTALKER_RANE_YORICK            = 44882,
    NPC_LORD_DARIUS_CROWLEY                 = 44883,

    SPELL_SUMMON_CROWLEY_BLOODFANG_MASTER   = 83762,
    SPELL_ARMOIRE_CAMERA_ON_CROWLEY         = 83763,
    SPELL_ARMOIRE_CAMERA_ON_BLOODFANG       = 83764,
    SPELL_RIDE_REVERSE_CAST_EXSANGUINATE    = 83781,
    SPELL_EJECT_PASSENGER_01                = 80743,
    SPELL_KILL_CREDIT_YORICK                = 83786,
    SPELL_HIDE_IN_ARMOIRE                   = 83788,

    EVENT_START_SCENE_EXSANGUINATE          = 1,
    EVENT_TALK_SCENE_EXSANGUINATE           = 4,
    EVENT_ACTION_SCENE_EXSANGUINATE         = 27,
    EVENT_SWITCH_SCENE_CAMERA               = 33,
    EVENT_FINISH_SCENE_EXSANGUINATE         = 40,

    TALK_YORICK_EXSANGUINATE_DEATH           = 2,
    TALK_CROWLEY_EXSANGUINATE_0              = 0,
    TALK_CROWLEY_EXSANGUINATE_1              = 1,
    TALK_CROWLEY_EXSANGUINATE_2              = 2,
    TALK_CROWLEY_EXSANGUINATE_3              = 3,
    TALK_CROWLEY_EXSANGUINATE_4              = 4,
    TALK_CROWLEY_EXSANGUINATE_5              = 5,
    TALK_CROWLEY_EXSANGUINATE_6              = 6,
    TALK_BLOODFANG_EXSANGUINATE_0            = 0,
    TALK_BLOODFANG_EXSANGUINATE_1            = 1,
    TALK_BLOODFANG_EXSANGUINATE_2            = 2,
    TALK_BLOODFANG_EXSANGUINATE_3            = 3,
    TALK_BLOODFANG_EXSANGUINATE_4            = 4,
    TALK_BLOODFANG_EXSANGUINATE_5            = 5,
    TALK_BLOODFANG_EXSANGUINATE_6            = 6,
    TALK_BLOODFANG_EXSANGUINATE_7            = 7,
    TALK_BLOODFANG_EXSANGUINATE_8            = 8,
    TALK_BLOODFANG_EXSANGUINATE_9            = 9,
    TALK_BLOODFANG_EXSANGUINATE_10           = 10,

    PATH_CROWLEY_ENTER                       = 3590640,
    PATH_BLOODFANG_ENTER                     = 3590720,
    PATH_BLOODFANG_NEAR_YORICK               = 3590728,
    PATH_BLOODFANG_WITH_YORICK               = 3590736,
    PATH_BLOODFANG_EXIT                      = 3590744,
    PATH_CROWLEY_EXIT                        = 3590648
};

// 44893 - Armoire
struct npc_silverpine_armoire : public VehicleAI
{
    npc_silverpine_armoire(Creature* creature) : VehicleAI(creature) { }

    void PassengerBoarded(Unit* passenger, int8 /*seatId*/, bool apply) override
    {
        TC_LOG_INFO("scripts", "Armoire scene: PassengerBoarded {} apply={} questStatus={}", passenger->GetGUID().ToString(), apply ? 1 : 0,
            passenger->ToPlayer() ? uint32(passenger->ToPlayer()->GetQuestStatus(QUEST_WAITING_TO_EXSANGUINATE)) : 0);

        if (apply)
        {
            if (Player* player = passenger->ToPlayer())
            {
                if (player->GetQuestStatus(QUEST_WAITING_TO_EXSANGUINATE) == QUEST_STATUS_INCOMPLETE)
                    _events.ScheduleEvent(EVENT_START_SCENE_EXSANGUINATE, 400ms);
            }
        }
        else
        {
            if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                crowley->DespawnOrUnsummon();

            if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                bloodfang->DespawnOrUnsummon();

            if (Creature* yorick = ObjectAccessor::GetCreature(*me, _yorickGUID))
                yorick->CastSpell(yorick, SPELL_CANCEL_SUMMON_YORICK, true);

            me->DespawnOrUnsummon(1000);
        }
    }

    void SetGUID(ObjectGuid guid, int32 id) override
    {
        TC_LOG_INFO("scripts", "Armoire scene: SetGUID entry {} guid {}", id, guid.ToString());

        switch (id)
        {
            case NPC_DEATHSTALKER_RANE_YORICK:
                _yorickGUID = guid;
                break;

            case NPC_LORD_DARIUS_CROWLEY:
                _crowleyGUID = guid;
                break;

            case NPC_PACKLEADER_IVAR_BLOODFANG:
                _bloodfangGUID = guid;
                break;

            default:
                break;
        }
    }

    void UpdateAI(uint32 diff) override
    {
        TempSummon* tempSummon = me->ToTempSummon();
        if (!tempSummon)
            return;

        _events.Update(diff);

        while (uint32 eventId = _events.ExecuteEvent())
        {
            // Debug: one line per executed scene step, shows which actors are still resolvable (Logger.scripts is 3 = info, so INFO is used).
            TC_LOG_INFO("scripts", "Armoire scene (Waiting to Exsanguinate): event {} summoner={} crowley={} bloodfang={} yorick={}", eventId,
                tempSummon->GetSummoner() ? 1 : 0, ObjectAccessor::GetCreature(*me, _crowleyGUID) ? 1 : 0,
                ObjectAccessor::GetCreature(*me, _bloodfangGUID) ? 1 : 0, ObjectAccessor::GetCreature(*me, _yorickGUID) ? 1 : 0);

            switch (eventId)
            {
                case EVENT_START_SCENE_EXSANGUINATE:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        summoner->CastSpell(summoner, SPELL_SUMMON_CROWLEY_BLOODFANG_MASTER, true);

                        _events.ScheduleEvent(EVENT_START_SCENE_EXSANGUINATE + 1, 100ms);
                    }
                    break;
                }

                case EVENT_START_SCENE_EXSANGUINATE + 1:
                {
                    if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                    {
                        crowley->GetMotionMaster()->MovePath(PATH_CROWLEY_ENTER, false);

                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            bloodfang->GetMotionMaster()->MovePath(PATH_BLOODFANG_ENTER, false);

                            _events.ScheduleEvent(EVENT_START_SCENE_EXSANGUINATE + 2, 7s);
                        }
                    }
                    break;
                }

                case EVENT_START_SCENE_EXSANGUINATE + 2:
                {
                    if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            crowley->SetFacingToObject(bloodfang);

                            bloodfang->SetFacingToObject(crowley);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE, 2s);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                        {
                            if (crowley->IsAIEnabled)
                                crowley->AI()->Talk(TALK_CROWLEY_EXSANGUINATE_0, summoner);

                            _events.ScheduleEvent(EVENT_SWITCH_SCENE_CAMERA, 3s + 900ms);
                        }
                    }
                    break;
                }

                case EVENT_SWITCH_SCENE_CAMERA:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        TC_LOG_INFO("scripts", "Armoire scene: camera on Bloodfang (event {})", eventId);
                        summoner->CastSpell(summoner, SPELL_ARMOIRE_CAMERA_ON_BLOODFANG, true);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 1, 2s + 500ms);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 1:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_0, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 2, 3s + 100ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 2:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->HandleEmoteCommand(EMOTE_ONESHOT_POINT);

                        _events.ScheduleEvent(EVENT_SWITCH_SCENE_CAMERA + 1, 4s + 800ms);
                    }
                    break;
                }

                case EVENT_SWITCH_SCENE_CAMERA + 1:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        TC_LOG_INFO("scripts", "Armoire scene: camera on Crowley (event {})", eventId);
                        summoner->CastSpell(summoner, SPELL_ARMOIRE_CAMERA_ON_CROWLEY, true);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 3, 2s + 500ms);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 3:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                        {
                            if (crowley->IsAIEnabled)
                                crowley->AI()->Talk(TALK_CROWLEY_EXSANGUINATE_1, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 4, 3s + 500ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 4:
                {
                    if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                    {
                        crowley->HandleEmoteCommand(EMOTE_ONESHOT_EXCLAMATION);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 5, 5s + 400ms);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 5:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                        {
                            if (crowley->IsAIEnabled)
                                crowley->AI()->Talk(TALK_CROWLEY_EXSANGUINATE_2, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 6, 3s + 100ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 6:
                {
                    if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                    {
                        crowley->HandleEmoteCommand(EMOTE_ONESHOT_TALK);

                        _events.ScheduleEvent(EVENT_SWITCH_SCENE_CAMERA + 2, 3s + 550ms);
                    }
                    break;
                }

                case EVENT_SWITCH_SCENE_CAMERA + 2:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        TC_LOG_INFO("scripts", "Armoire scene: camera on Bloodfang (event {})", eventId);
                        summoner->CastSpell(summoner, SPELL_ARMOIRE_CAMERA_ON_BLOODFANG, true);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 7, 2s + 500ms);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 7:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_1, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 8, 3s + 800ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 8:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_2, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 9, 2s + 400ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 9:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_3, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 10, 3s + 900ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 10:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->HandleEmoteCommand(EMOTE_ONESHOT_TALK);

                        _events.ScheduleEvent(EVENT_SWITCH_SCENE_CAMERA + 3, 4s + 450ms);
                    }
                    break;
                }

                case EVENT_SWITCH_SCENE_CAMERA + 3:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        TC_LOG_INFO("scripts", "Armoire scene: camera on Crowley (event {})", eventId);
                        summoner->CastSpell(summoner, SPELL_ARMOIRE_CAMERA_ON_CROWLEY, true);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 11, 3s);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 11:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                        {
                            if (crowley->IsAIEnabled)
                                crowley->AI()->Talk(TALK_CROWLEY_EXSANGUINATE_3, summoner);

                            _events.ScheduleEvent(EVENT_SWITCH_SCENE_CAMERA + 4, 1s + 900ms);
                        }
                    }
                    break;
                }

                case EVENT_SWITCH_SCENE_CAMERA + 4:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        TC_LOG_INFO("scripts", "Armoire scene: camera on Bloodfang (event {})", eventId);
                        summoner->CastSpell(summoner, SPELL_ARMOIRE_CAMERA_ON_BLOODFANG, true);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 12, 2s + 500ms);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 12:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_4, summoner);

                            _events.ScheduleEvent(EVENT_ACTION_SCENE_EXSANGUINATE, 2s + 300ms);
                        }
                    }
                    break;
                }

                case EVENT_ACTION_SCENE_EXSANGUINATE:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->SetFacingTo(0.6457718f);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 13, 1s + 300ms);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 13:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_5, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 14, 4s);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 14:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_6, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 15, 3s + 500ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 15:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->HandleEmoteCommand(EMOTE_ONESHOT_YES);

                        _events.ScheduleEvent(EVENT_ACTION_SCENE_EXSANGUINATE + 1, 2s + 800ms);
                    }
                    break;
                }

                case EVENT_ACTION_SCENE_EXSANGUINATE + 1:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->GetMotionMaster()->MovePath(PATH_BLOODFANG_NEAR_YORICK, false);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 16, 3s);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 16:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->HandleEmoteCommand(EMOTE_ONESHOT_ROAR);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 17, 200ms);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 17:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_7, summoner);

                            _events.ScheduleEvent(EVENT_ACTION_SCENE_EXSANGUINATE + 2, 2s + 300ms);
                        }
                    }
                    break;
                }

                case EVENT_ACTION_SCENE_EXSANGUINATE + 2:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        if (Creature* yorick = ObjectAccessor::GetCreature(*me, _yorickGUID))
                        {
                            yorick->RemoveAura(SPELL_STEALTH);

                            SetUninteractible(yorick, false);

                            bloodfang->CastSpell(yorick, SPELL_RIDE_REVERSE_CAST_EXSANGUINATE, true);

                            _events.ScheduleEvent(EVENT_ACTION_SCENE_EXSANGUINATE + 3, 1s + 100ms);
                        }
                    }
                    break;
                }

                case EVENT_ACTION_SCENE_EXSANGUINATE + 3:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->GetMotionMaster()->MovePath(PATH_BLOODFANG_WITH_YORICK, false);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 18, 3s);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 18:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            bloodfang->SetFacingTo(3.054326f);

                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_8, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 19, 3s + 600ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 19:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* yorick = ObjectAccessor::GetCreature(*me, _yorickGUID))
                        {
                            if (yorick->IsAIEnabled)
                                yorick->AI()->Talk(TALK_YORICK_EXSANGUINATE_DEATH, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 20, 4s + 850ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 20:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (Creature* yorick = ObjectAccessor::GetCreature(*me, _yorickGUID))
                            {
                                bloodfang->CastSpell(yorick, SPELL_EJECT_PASSENGER_01, false);

                                if (yorick->IsAIEnabled)
                                    yorick->AI()->DoAction(ACTION_RANE_JUMP_DEATH);

                                if (bloodfang->IsAIEnabled)
                                    bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_9, summoner);

                                _events.ScheduleEvent(EVENT_ACTION_SCENE_EXSANGUINATE + 4, 3s + 600ms);
                            }
                        }
                    }
                    break;
                }

                case EVENT_ACTION_SCENE_EXSANGUINATE + 4:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->SetFacingTo(0.0f);

                        _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 21, 1s + 100ms);
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 21:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            if (bloodfang->IsAIEnabled)
                                bloodfang->AI()->Talk(TALK_BLOODFANG_EXSANGUINATE_10, summoner);

                            _events.ScheduleEvent(EVENT_TALK_SCENE_EXSANGUINATE + 22, 4s + 100ms);
                        }
                    }
                    break;
                }

                case EVENT_TALK_SCENE_EXSANGUINATE + 22:
                {
                    if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                    {
                        bloodfang->HandleEmoteCommand(EMOTE_ONESHOT_TALK);

                        _events.ScheduleEvent(EVENT_SWITCH_SCENE_CAMERA + 5, 3s + 250ms);
                    }
                    break;
                }

                case EVENT_SWITCH_SCENE_CAMERA + 5:
                {
                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        TC_LOG_INFO("scripts", "Armoire scene: camera on Crowley (event {})", eventId);
                        summoner->CastSpell(summoner, SPELL_ARMOIRE_CAMERA_ON_CROWLEY, true);

                        if (Creature* bloodfang = ObjectAccessor::GetCreature(*me, _bloodfangGUID))
                        {
                            bloodfang->SetWalk(false);
                            bloodfang->GetMotionMaster()->MovePath(PATH_BLOODFANG_EXIT, false);

                            _events.ScheduleEvent(EVENT_ACTION_SCENE_EXSANGUINATE + 5, 3s);
                        }
                    }
                    break;
                }

                case EVENT_ACTION_SCENE_EXSANGUINATE + 5:
                {
                    if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                    {
                        crowley->GetMotionMaster()->MovePath(PATH_CROWLEY_EXIT, false);

                        _events.ScheduleEvent(EVENT_FINISH_SCENE_EXSANGUINATE, 4s);
                    }
                    break;
                }

                case EVENT_FINISH_SCENE_EXSANGUINATE:
                {
                    TC_LOG_INFO("scripts", "Armoire scene: finish (kill credit, exit vehicle)");

                    if (Unit* summoner = tempSummon->GetSummoner())
                    {
                        if (Creature* crowley = ObjectAccessor::GetCreature(*me, _crowleyGUID))
                            crowley->CastSpell(summoner, SPELL_KILL_CREDIT_YORICK, false);

                        if (Creature* yorick = ObjectAccessor::GetCreature(*me, _yorickGUID))
                            yorick->CastSpell(summoner, SPELL_CANCEL_SUMMON_YORICK, true);

                        summoner->GetMotionMaster()->Clear();

                        summoner->RemoveAura(SPELL_HIDE_IN_ARMOIRE);

                        summoner->ExitVehicle();
                    }
                    break;
                }

                default:
                    break;
            }
        }
    }

private:
    EventMap _events;
    ObjectGuid _yorickGUID;
    ObjectGuid _crowleyGUID;
    ObjectGuid _bloodfangGUID;
};

enum DariusCrowleyExsanguinate
{
    WAYPOINT_ON_CROWLEY_DESPAWN              = 1
};

// 44883 - Lord Darius Crowley
struct npc_silverpine_lord_darius_crowley_exsanguinate : public ScriptedAI
{
    npc_silverpine_lord_darius_crowley_exsanguinate(Creature* creature) : ScriptedAI(creature) { }

    void JustAppeared() override
    {
        me->SetReactState(REACT_PASSIVE);
    }

    void IsSummonedBy(Unit* /*summoner*/) override
    {
        if (Creature* armoire = me->FindNearestCreature(NPC_ARMOIRE_SUMMONED, 100.0f))
        {
            if (armoire->IsAIEnabled)
                armoire->AI()->SetGUID(me->GetGUID(), me->GetEntry());
        }
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type == WAYPOINT_MOTION_TYPE && me->GetWaypointPath() == PATH_CROWLEY_EXIT && id == WAYPOINT_ON_CROWLEY_DESPAWN)
            me->DespawnOrUnsummon();
    }
};

enum IvarBloodfangExsanguinate
{
    WAYPOINT_ON_BLOODFANG_DESPAWN            = 2
};

// 44884 - Packleader Ivar Bloodfang
struct npc_silverpine_packleader_ivar_bloodfang_exsanguinate : public ScriptedAI
{
    npc_silverpine_packleader_ivar_bloodfang_exsanguinate(Creature* creature) : ScriptedAI(creature) { }

    void JustAppeared() override
    {
        me->SetReactState(REACT_PASSIVE);
    }

    void IsSummonedBy(Unit* /*summoner*/) override
    {
        if (Creature* armoire = me->FindNearestCreature(NPC_ARMOIRE_SUMMONED, 30.0f))
        {
            if (armoire->IsAIEnabled)
                armoire->AI()->SetGUID(me->GetGUID(), me->GetEntry());
        }
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type == WAYPOINT_MOTION_TYPE && me->GetWaypointPath() == PATH_BLOODFANG_EXIT && id == WAYPOINT_ON_BLOODFANG_DESPAWN)
            me->DespawnOrUnsummon();
    }
};

// 80743 - Eject Passenger 1 (ejects the passenger of seat 0 of the caster's vehicle)
class spell_gen_eject_passenger_1 : public SpellScript
{
    PrepareSpellScript(spell_gen_eject_passenger_1);

    void HandleScriptEffect(SpellEffIndex /*effIndex*/)
    {
        if (Unit* target = GetHitUnit())
            if (Vehicle* vehicle = target->GetVehicleKit())
                if (Unit* passenger = vehicle->GetPassenger(0))
                    passenger->ExitVehicle();
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_gen_eject_passenger_1::HandleScriptEffect, EFFECT_0, SPELL_EFFECT_SCRIPT_EFFECT);
    }
};

// 83781 - Ride Vehicle (reverse cast): the target casts the spell given in the effect's base points on the caster
class spell_gen_reverse_cast_target_to_caster_triggered : public SpellScript
{
    PrepareSpellScript(spell_gen_reverse_cast_target_to_caster_triggered);

    // The effect uses TARGET_SRC_CASTER / TARGET_UNIT_SRC_AREA_ENTRY (radius 10) and there are no conditions rows for it, so without
    // a filter every unit near the caster is hit - including the player in the Armoire, who then casts the ride aura on the caster
    // and is thrown out of the Armoire. Only the explicit target of the cast may reverse-cast.
    void FilterTargets(std::list<WorldObject*>& targets)
    {
        Unit* explicitTarget = GetExplTargetUnit();
        targets.remove_if([explicitTarget](WorldObject* target) { return target != explicitTarget; });
    }

    void HandleScriptEffect(SpellEffIndex effIndex)
    {
        if (Unit* target = GetHitUnit())
            target->CastSpell(GetCaster(), GetSpellInfo()->Effects[effIndex].BasePoints, true);
    }

    void Register() override
    {
        OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(spell_gen_reverse_cast_target_to_caster_triggered::FilterTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENTRY);
        OnEffectHitTarget += SpellEffectFn(spell_gen_reverse_cast_target_to_caster_triggered::HandleScriptEffect, EFFECT_0, SPELL_EFFECT_SCRIPT_EFFECT);
    }
};

void AddSC_silverpine_forest_high_command()
{
    RegisterCreatureAI(npc_silverpine_grand_executor_mortuus);
    RegisterSpellScript(spell_silverpine_raise_forsaken_83173);
    RegisterCreatureAI(npc_silverpine_fallen_human);
    RegisterSpellScript(spell_silverpine_forsaken_trooper_masterscript_high_command);
    RegisterGameObjectAI(go_silverpine_abandoned_outhouse);
    RegisterCreatureAI(npc_silverpine_deathstalker_rane_yorick);
    RegisterCreatureAI(npc_silverpine_armoire);
    RegisterCreatureAI(npc_silverpine_lord_darius_crowley_exsanguinate);
    RegisterCreatureAI(npc_silverpine_packleader_ivar_bloodfang_exsanguinate);
    RegisterSpellScript(spell_gen_eject_passenger_1);
    RegisterSpellScript(spell_gen_reverse_cast_target_to_caster_triggered);
}
