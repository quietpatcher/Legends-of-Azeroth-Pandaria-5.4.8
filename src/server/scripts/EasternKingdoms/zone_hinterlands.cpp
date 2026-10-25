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
SDName: Hinterlands
SD%Complete: 100
SDComment: Quest support: 836
SDCategory: The Hinterlands
EndScriptData */

/* ContentData
npc_00x09hl
EndContentData */

#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "ScriptedEscortAI.h"
#include "Player.h"

/*######
## npc_00x09hl
######*/

// Since patch 3.2 the escort is short: one ambush of three Marauding Owlbeasts on the road south of the start; when they are
// dead the robot says its flight line, the quest completes and it flies off to Booty Bay (the Vilebranch troll ambush and
// the long route to the coast are pre-3.2). Text groups: 0 start, 1 aggro, 2 danger, 4 flight; group 3 is a Tanaris line.
enum eOOX
{
    SAY_OOX_START           = 0,
    SAY_OOX_AGGRO           = 1,
    SAY_OOX_AMBUSH          = 2,
    SAY_OOX_END             = 4,

    QUEST_RESQUE_OOX_09     = 836,

    NPC_MARAUDING_OWL       = 7808,

    FACTION_ESCORTEE_A      = 774,
    FACTION_ESCORTEE_H      = 775
};

class npc_00x09hl : public CreatureScript
{
public:
    npc_00x09hl() : CreatureScript("npc_00x09hl") { }

    bool OnQuestAccept(Player* player, Creature* creature, const Quest* quest) override
    {
        if (quest->GetQuestId() == QUEST_RESQUE_OOX_09)
        {
            creature->SetStandState(UNIT_STAND_STATE_STAND);

            if (player->GetTeam() == ALLIANCE)
                creature->SetFaction(FACTION_ESCORTEE_A);
            else if (player->GetTeam() == HORDE)
                creature->SetFaction(FACTION_ESCORTEE_H);

            creature->AI()->Talk(SAY_OOX_START, player);

            if (npc_00x09hlAI* pEscortAI = CAST_AI(npc_00x09hl::npc_00x09hlAI, creature->AI()))
            {
                // the AI object survives the despawn after a finished run: start every run with a fresh ambush
                if (!pEscortAI->HasEscortState(STATE_ESCORT_ESCORTING))
                    pEscortAI->ClearRun();
                pEscortAI->Start(false, player->GetGUID(), quest);
            }
        }
        return true;
    }

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_00x09hlAI(creature);
    }

    struct npc_00x09hlAI : public EscortAI
    {
        npc_00x09hlAI(Creature* creature) : EscortAI(creature), _owlsAlive(0), _done(false), _flightTimer(0) { }

        void Reset() override { }

        void ClearRun()
        {
            _owlsAlive = 0;
            _done = false;
            _flightTimer = 0;
        }

        void UpdateAI(uint32 diff) override
        {
            // rockets: the robot rises for a few seconds, then it is taken away on the ground rules. Despawning it while it
            // still flies made the corpse fall (MoveFall) and that fall overrode the relocation to the spawn point, so the
            // robot came back at the ambush instead of at the start of the quest
            if (_flightTimer)
            {
                if (_flightTimer <= diff)
                {
                    _flightTimer = 0;
                    me->GetMotionMaster()->Clear();
                    me->StopMoving();
                    me->SetDisableGravity(false);
                    me->SetCanFly(false);
                    me->DespawnOrUnsummon();
                }
                else
                    _flightTimer -= diff;
                return;
            }

            EscortAI::UpdateAI(diff);
        }

        void WaypointReached(uint32 waypointId, uint32 /*pathId*/) override
        {
            switch (waypointId)
            {
                case 26:
                    Talk(SAY_OOX_AMBUSH);
                    break;
                case 28:
                    // wait on the road until the ambush is dead
                    if (_owlsAlive && !_done)
                        SetEscortPaused(true);
                    break;
            }
        }

        void WaypointStart(uint32 uiPointId) override
        {
            if (uiPointId != 27 || _done)
                return;

            _owlsAlive = 0;
            for (uint8 i = 0; i < 3; ++i)
            {
                const Position src = {147.927444f, -3851.513428f, 130.893f, 0};
                Position dst = me->GetRandomPoint(src, 7.0f);
                if (DoSummon(NPC_MARAUDING_OWL, dst, 25000ms, TEMPSUMMON_CORPSE_TIMED_DESPAWN))
                    ++_owlsAlive;
            }
        }

        void SummonedCreatureDies(Creature* summon, Unit* /*killer*/) override
        {
            if (summon->GetEntry() != NPC_MARAUDING_OWL || _done || !_owlsAlive)
                return;

            if (--_owlsAlive)
                return;

            _done = true;
            Player* player = GetPlayerForEscort();
            Talk(SAY_OOX_END, player);
            if (player)
                player->GroupEventHappens(QUEST_RESQUE_OOX_09, me);

            // rockets on: up and away, the robot comes back at its spawn after the respawn time
            if (!HasEscortState(STATE_ESCORT_PAUSED))
                SetEscortPaused(true);
            me->SetCanFly(true);
            me->SetDisableGravity(true);
            me->GetMotionMaster()->Clear();
            me->GetMotionMaster()->MovePoint(1, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ() + 40.0f, false);
            _flightTimer = 5000;
        }

        void JustEngagedWith(Unit* who) override
        {
            if (who->GetEntry() == NPC_MARAUDING_OWL)
                return;

            Talk(SAY_OOX_AGGRO);
        }

        void JustSummoned(Creature* summoned) override
        {
            // the ambush goes for the robot: a walk to its position at summon time left the owlbeasts standing on the
            // road behind it while the robot waited for them at the next point
            if (summoned->GetEntry() == NPC_MARAUDING_OWL && summoned->AI())
            {
                summoned->AI()->AttackStart(me);
                return;
            }
            summoned->GetMotionMaster()->MovePoint(0, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ());
        }

    private:
        uint8 _owlsAlive;
        bool _done;
        uint32 _flightTimer;
    };
};

void AddSC_hinterlands()
{
    new npc_00x09hl();
}
