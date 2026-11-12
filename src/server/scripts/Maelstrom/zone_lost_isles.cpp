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

#include "ScriptPCH.h"
#include "TemporarySummon.h"
#include "SpellScript.h"

/*######
## Quest 14239: Don't Go Into the Light!
##
## The goblin washes up near death on the flotsam off Shipwreck Shore. Doc Zapnozzle (36608) tells Geargrinder Gizmo
## who is lying there, tries his wet jumper cables and leaves the rest to the goblin; only then the quest is taken
## and handed in. The Near Death! aura (69010) is not applied: its invisibility (type 7) hides Doc and Gizmo from the
## goblin himself (WorldObject::CanDetectInvisibilityOf) and nothing in the 5.4.8 data gives them the detection.
######*/

namespace DontGoIntoTheLight
{
    enum
    {
        QUEST_LIFE_SAVINGS              = 14126,
        QUEST_DONT_GO_INTO_THE_LIGHT    = 14239,
        NPC_GEARGRINDER_GIZMO           = 36600,
        SPELL_JUMPER_CABLES             = 69022,

        SAY_DOC_GIZMO                   = 0,
        SAY_DOC_THATS_HIM               = 1,
        SAY_DOC_STAY_BACK               = 2,
        SAY_DOC_CLEAR                   = 3,
        SAY_DOC_UP_TO_HIM               = 4,
        SAY_DOC_RIGHT_CHOICE            = 5,
        SAY_DOC_SEE_YOU                 = 6,
        SAY_GIZMO_THOUGHT_DEAD          = 1,

        EVENT_DOC_THATS_HIM             = 1,
        EVENT_GIZMO_THOUGHT_DEAD        = 2,
        EVENT_DOC_STAY_BACK             = 3,
        EVENT_DOC_CLEAR                 = 4,
        EVENT_DOC_UP_TO_HIM             = 5,
        EVENT_DOC_SEE_YOU               = 6
    };
}

struct npc_lost_isles_doc_zapnozzle : public ScriptedAI
{
    npc_lost_isles_doc_zapnozzle(Creature* creature) : ScriptedAI(creature), _scanTimer(2000) { }

    void OnQuestAccept(Player* player, Quest const* quest) override
    {
        if (quest->GetQuestId() != DontGoIntoTheLight::QUEST_DONT_GO_INTO_THE_LIGHT)
            return;

        // whatever was left of the resuscitation is over
        if (player->GetGUID() == _playerGUID)
        {
            _events.Reset();
            _playerGUID.Clear();
        }

        Talk(DontGoIntoTheLight::SAY_DOC_RIGHT_CHOICE, player);
        _events.ScheduleEvent(DontGoIntoTheLight::EVENT_DOC_SEE_YOU, 5000);
    }

    void UpdateAI(uint32 diff) override
    {
        if (_playerGUID.IsEmpty())
        {
            if (_scanTimer <= diff)
            {
                _scanTimer = 1000;
                LookForTheNextOne();
            }
            else
                _scanTimer -= diff;
        }

        _events.Update(diff);
        while (uint32 eventId = _events.ExecuteEvent())
        {
            if (eventId == DontGoIntoTheLight::EVENT_DOC_SEE_YOU)
            {
                Talk(DontGoIntoTheLight::SAY_DOC_SEE_YOU);
                continue;
            }

            Player* player = ObjectAccessor::GetPlayer(*me, _playerGUID);
            if (!player || player->GetQuestStatus(DontGoIntoTheLight::QUEST_DONT_GO_INTO_THE_LIGHT) != QUEST_STATUS_NONE || !me->IsWithinDist(player, 30.0f))
            {
                _events.CancelEvent(DontGoIntoTheLight::EVENT_DOC_THATS_HIM);
                _events.CancelEvent(DontGoIntoTheLight::EVENT_GIZMO_THOUGHT_DEAD);
                _events.CancelEvent(DontGoIntoTheLight::EVENT_DOC_STAY_BACK);
                _events.CancelEvent(DontGoIntoTheLight::EVENT_DOC_CLEAR);
                _events.CancelEvent(DontGoIntoTheLight::EVENT_DOC_UP_TO_HIM);
                _playerGUID.Clear();
                continue;
            }

            switch (eventId)
            {
                case DontGoIntoTheLight::EVENT_DOC_THATS_HIM:
                    Talk(DontGoIntoTheLight::SAY_DOC_THATS_HIM, player);
                    _events.ScheduleEvent(DontGoIntoTheLight::EVENT_GIZMO_THOUGHT_DEAD, 6000);
                    break;
                case DontGoIntoTheLight::EVENT_GIZMO_THOUGHT_DEAD:
                    if (Creature* gizmo = me->FindNearestCreature(DontGoIntoTheLight::NPC_GEARGRINDER_GIZMO, 30.0f))
                        gizmo->AI()->Talk(DontGoIntoTheLight::SAY_GIZMO_THOUGHT_DEAD, player);
                    _events.ScheduleEvent(DontGoIntoTheLight::EVENT_DOC_STAY_BACK, 5000);
                    break;
                case DontGoIntoTheLight::EVENT_DOC_STAY_BACK:
                    Talk(DontGoIntoTheLight::SAY_DOC_STAY_BACK, player);
                    _events.ScheduleEvent(DontGoIntoTheLight::EVENT_DOC_CLEAR, 5000);
                    break;
                case DontGoIntoTheLight::EVENT_DOC_CLEAR:
                    Talk(DontGoIntoTheLight::SAY_DOC_CLEAR, player);
                    me->CastSpell(player, DontGoIntoTheLight::SPELL_JUMPER_CABLES, true);
                    _events.ScheduleEvent(DontGoIntoTheLight::EVENT_DOC_UP_TO_HIM, 5000);
                    break;
                case DontGoIntoTheLight::EVENT_DOC_UP_TO_HIM:
                    Talk(DontGoIntoTheLight::SAY_DOC_UP_TO_HIM, player);
                    _playerGUID.Clear();
                    break;
                default:
                    break;
            }
        }
    }

private:
    void LookForTheNextOne()
    {
        std::list<Player*> players;
        me->GetPlayerListInGrid(players, 15.0f);
        for (Player* player : players)
        {
            if (!player->IsAlive() || _seen.count(player->GetGUID()))
                continue;
            if (player->GetQuestStatus(DontGoIntoTheLight::QUEST_LIFE_SAVINGS) != QUEST_STATUS_REWARDED ||
                player->GetQuestStatus(DontGoIntoTheLight::QUEST_DONT_GO_INTO_THE_LIGHT) != QUEST_STATUS_NONE)
                continue;

            if (_seen.size() > 200)
                _seen.clear();
            _seen.insert(player->GetGUID());
            _playerGUID = player->GetGUID();
            Talk(DontGoIntoTheLight::SAY_DOC_GIZMO, player);
            _events.ScheduleEvent(DontGoIntoTheLight::EVENT_DOC_THATS_HIM, 6000);
            return;
        }
    }

    EventMap _events;
    ObjectGuid _playerGUID;
    std::set<ObjectGuid> _seen;
    uint32 _scanTimer;
};

/*######
## Quest 14021: Miner Troubles
##
## Foreman Dampwick sends his last Frightened Miner (35813) into the Kaja'mite Cavern with an ore cart; the goblin
## keeps the Smart Mining Monkeys off him while he works the Kaja'mite Ore deposits. The credit comes when he is done
## with the last one. A miner that dies is replaced by Dampwick on request (gossip, 68069).
######*/

namespace MinerTroubles
{
    enum
    {
        QUEST_MINER_TROUBLES            = 14021,
        NPC_FRIGHTENED_MINER            = 35813,
        NPC_ORE_CART                    = 35814,
        NPC_KILL_CREDIT                 = 35816,
        SPELL_ORE_CART_CHAIN            = 68122,

        SAY_START                       = 0,
        SAY_CAVE_PAINTINGS              = 1,
        SAY_FINAL_DEPOSIT               = 4,
        SAY_REACH_DEPOSIT               = 5,
        SAY_LEAVE_DEPOSIT               = 6,

        POINT_DEPOSIT                   = 1,
        POINT_LEAVE                     = 2,

        STATE_START                     = 0,
        STATE_MOVE                      = 1,
        STATE_MINE                      = 2,
        STATE_LEAVE                     = 3,

        START_TIME                      = 3000,
        MINE_TIME                       = 10000,
        LEG_TIME_MAX                    = 90000,
        LEAVE_TIME                      = 8000
    };

    // the spot of the last miner next to Foreman Dampwick, the first cave painting, the mouth of the cavern
    Position const MinerStart   = { 499.92f, 2970.43f, 7.87f, 4.80f };
    Position const CavePainting = { 567.0f,  2947.0f,  3.0f,  0.0f };
    Position const CavernMouth  = { 522.0f,  2967.0f,  8.0f,  0.0f };

    // the Kaja'mite Ore deposits (gameobject 195622) from the mouth of the cavern to its far end
    Position const Deposits[] =
    {
        { 577.785f, 2904.27f, -6.97f, 0.0f },
        { 601.269f, 2889.74f, -6.28f, 0.0f },
        { 607.663f, 2855.47f, -7.24f, 0.0f },
        { 668.467f, 2949.86f, -0.03f, 0.0f }
    };
    uint32 const DepositCount = sizeof(Deposits) / sizeof(Deposits[0]);

    void SummonMiner(Player* player)
    {
        if (player->GetQuestStatus(QUEST_MINER_TROUBLES) != QUEST_STATUS_INCOMPLETE)
            return;

        // one miner at a time
        std::list<Creature*> miners;
        player->GetCreatureListWithEntryInGrid(miners, NPC_FRIGHTENED_MINER, 300.0f);
        for (Creature* miner : miners)
            if (miner->IsAlive() && miner->IsSummon() && miner->ToTempSummon()->GetSummonerGUID() == player->GetGUID())
                return;

        player->SummonCreature(NPC_FRIGHTENED_MINER, MinerStart, TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900s);
    }
}

struct npc_lost_isles_frightened_miner : public ScriptedAI
{
    npc_lost_isles_frightened_miner(Creature* creature) : ScriptedAI(creature),
        _state(MinerTroubles::STATE_START), _deposit(0), _timer(MinerTroubles::START_TIME), _checkTimer(500), _saidPaintings(false) { }

    void IsSummonedBy(Unit* summoner) override
    {
        Player* player = summoner->ToPlayer();
        if (!player)
            return;

        _playerGUID = player->GetGUID();
        // one of the goblins: the monkeys go for him
        me->SetFaction(player->GetFaction());
        me->SetReactState(REACT_PASSIVE);
        me->SetWalk(false);

        if (Creature* cart = me->SummonCreature(MinerTroubles::NPC_ORE_CART, me->GetPositionX() - 1.5f, me->GetPositionY(), me->GetPositionZ(), me->GetOrientation(), TEMPSUMMON_MANUAL_DESPAWN))
        {
            _cartGUID = cart->GetGUID();
            cart->SetReactState(REACT_PASSIVE);
            cart->GetMotionMaster()->MoveFollow(me, 1.5f, float(M_PI));
            me->CastSpell(cart, MinerTroubles::SPELL_ORE_CART_CHAIN, true);
        }
    }

    void JustDied(Unit* /*killer*/) override
    {
        DespawnCart();
    }

    // no running back to Foreman Dampwick after a monkey: he goes on with his work
    void EnterEvadeMode(EvadeReason why) override
    {
        _EnterEvadeMode(why);
    }

    void UpdateAI(uint32 diff) override
    {
        if (_playerGUID.IsEmpty() || !me->IsAlive())
            return;

        if (_checkTimer <= diff)
        {
            _checkTimer = 500;

            Player* player = ObjectAccessor::GetPlayer(*me, _playerGUID);
            if (_state != MinerTroubles::STATE_LEAVE && (!player || player->GetQuestStatus(MinerTroubles::QUEST_MINER_TROUBLES) != QUEST_STATUS_INCOMPLETE))
            {
                // the quest was dropped or the goblin is gone
                DespawnCart();
                me->DespawnOrUnsummon();
                return;
            }

            if (_state == MinerTroubles::STATE_MOVE)
                Walk(player);
        }
        else
            _checkTimer -= diff;

        if (_timer > diff)
        {
            _timer -= diff;
            return;
        }

        Player* player = ObjectAccessor::GetPlayer(*me, _playerGUID);
        switch (_state)
        {
            case MinerTroubles::STATE_START:
                Talk(MinerTroubles::SAY_START, player);
                StartLeg();
                break;
            case MinerTroubles::STATE_MOVE:
                // did not get there: work where he stands
                StartMining(player);
                break;
            case MinerTroubles::STATE_MINE:
                me->SetEmoteState(EMOTE_ONESHOT_NONE);
                if (++_deposit >= MinerTroubles::DepositCount)
                {
                    // done: out on his own
                    _state = MinerTroubles::STATE_LEAVE;
                    _timer = MinerTroubles::LEAVE_TIME;
                    me->GetMotionMaster()->MovePoint(MinerTroubles::POINT_LEAVE, MinerTroubles::CavernMouth);
                }
                else
                {
                    Talk(MinerTroubles::SAY_LEAVE_DEPOSIT, player);
                    StartLeg();
                }
                break;
            case MinerTroubles::STATE_LEAVE:
                DespawnCart();
                me->DespawnOrUnsummon();
                _timer = 60000;
                break;
            default:
                break;
        }
    }

private:
    void StartLeg()
    {
        _state = MinerTroubles::STATE_MOVE;
        _timer = MinerTroubles::LEG_TIME_MAX;
        me->GetMotionMaster()->MovePoint(MinerTroubles::POINT_DEPOSIT, MinerTroubles::Deposits[_deposit]);
    }

    void Walk(Player* player)
    {
        if (!_saidPaintings && me->GetExactDist2d(&MinerTroubles::CavePainting) < 20.0f)
        {
            _saidPaintings = true;
            Talk(MinerTroubles::SAY_CAVE_PAINTINGS, player);
        }

        if (me->GetExactDist2d(&MinerTroubles::Deposits[_deposit]) < 4.0f)
            StartMining(player);
        else if (!me->isMoving())
            me->GetMotionMaster()->MovePoint(MinerTroubles::POINT_DEPOSIT, MinerTroubles::Deposits[_deposit]);
    }

    void StartMining(Player* player)
    {
        _state = MinerTroubles::STATE_MINE;
        _timer = MinerTroubles::MINE_TIME;
        me->GetMotionMaster()->Clear();
        me->StopMoving();
        me->SetFacingTo(me->GetAngle(&MinerTroubles::Deposits[_deposit]));
        me->SetEmoteState(EMOTE_STATE_WORK_MINING);

        if (_deposit + 1 < MinerTroubles::DepositCount)
        {
            Talk(MinerTroubles::SAY_REACH_DEPOSIT, player);
            return;
        }

        Talk(MinerTroubles::SAY_FINAL_DEPOSIT, player);
        if (player)
            player->RewardPlayerAndGroupAtEvent(MinerTroubles::NPC_KILL_CREDIT, player);
    }

    void DespawnCart()
    {
        if (Creature* cart = ObjectAccessor::GetCreature(*me, _cartGUID))
            cart->DespawnOrUnsummon();
        _cartGUID.Clear();
    }

    ObjectGuid _playerGUID;
    ObjectGuid _cartGUID;
    uint8 _state;
    uint32 _deposit;
    uint32 _timer;
    uint32 _checkTimer;
    bool _saidPaintings;
};

class quest_lost_isles_miner_troubles : public QuestScript
{
public:
    quest_lost_isles_miner_troubles() : QuestScript("quest_lost_isles_miner_troubles") { }

    void OnQuestStatusChange(Player* player, Quest const* /*quest*/, QuestStatus oldStatus, QuestStatus newStatus) override
    {
        if (newStatus == QUEST_STATUS_INCOMPLETE && oldStatus != QUEST_STATUS_INCOMPLETE)
            MinerTroubles::SummonMiner(player);
    }
};

// 68069 Miner Troubles: New Miner from Gossip ("Er, Dampwick, I need another miner....")
class spell_lost_isles_new_miner : public SpellScript
{
    PrepareSpellScript(spell_lost_isles_new_miner);

    void HandleAfterHit()
    {
        if (Player* player = GetHitPlayer())
            MinerTroubles::SummonMiner(player);
    }

    void Register() override
    {
        AfterHit += SpellHitFn(spell_lost_isles_new_miner::HandleAfterHit);
    }
};

/*######
## Quest 14243: Warchief's Revenge
##
## Thrall turns the goblin into a Cyclone of the Elements (68408 summons the vehicle 36178, ride spell 68436) that he
## steers over the Alliance ships himself; its Lightning Strike (68445) slays the Alliance Sailors. With fifty of them
## dead the cyclone takes him to the Wild Overlook (quest script below).
######*/

namespace WarchiefsRevenge
{
    enum
    {
        QUEST_WARCHIEFS_REVENGE = 14243,
        NPC_CYCLONE             = 36178,
        MAP_LOST_ISLES          = 648
    };

    Position const WildOverlook = { 871.797f, 2768.51f, 119.17f, 0.0f };
}

// The cyclone is a vehicle whose passenger steers (VehicleSeat 5746): Vehicle::AddPassenger charms it (SetCharmedBy ->
// CreatureAI::OnCharmed disables the creature AI, Unit::UpdateCharmAI swaps in PossessedAI), so neither UpdateAI nor
// PassengerBoarded of a creature script runs while the goblin rides. The end of the ride is therefore driven from the
// quest: 50 sailors slain (COMPLETE) takes him to the Wild Overlook, dropping the quest (NONE) lets the storm go of him.
class CycloneExitEvent : public BasicEvent
{
public:
    CycloneExitEvent(Player* player, bool toOverlook) : _player(player), _toOverlook(toOverlook) { }

    bool Execute(uint64 /*time*/, uint32 /*diff*/) override
    {
        Unit* base = _player->GetVehicleBase();
        if (!base || base->GetEntry() != WarchiefsRevenge::NPC_CYCLONE)
            return true;

        Creature* cyclone = base->ToCreature();
        _player->ExitVehicle();
        if (cyclone)
            cyclone->DespawnOrUnsummon(1000);
        if (_toOverlook)
            _player->TeleportTo(WarchiefsRevenge::MAP_LOST_ISLES, WarchiefsRevenge::WildOverlook.GetPositionX(), WarchiefsRevenge::WildOverlook.GetPositionY(),
                WarchiefsRevenge::WildOverlook.GetPositionZ(), WarchiefsRevenge::WildOverlook.GetOrientation());
        return true;
    }

private:
    Player* _player;
    bool _toOverlook;
};

class quest_lost_isles_warchiefs_revenge : public QuestScript
{
public:
    quest_lost_isles_warchiefs_revenge() : QuestScript("quest_lost_isles_warchiefs_revenge") { }

    void OnQuestStatusChange(Player* player, Quest const* /*quest*/, QuestStatus /*oldStatus*/, QuestStatus newStatus) override
    {
        if (newStatus != QUEST_STATUS_COMPLETE && newStatus != QUEST_STATUS_NONE)
            return;

        Unit* base = player->GetVehicleBase();
        if (!base || base->GetEntry() != WarchiefsRevenge::NPC_CYCLONE)
            return;

        // not from inside the kill or quest handler that got us here
        player->m_Events.AddEvent(new CycloneExitEvent(player, newStatus == QUEST_STATUS_COMPLETE), player->m_Events.CalculateTime(500));
    }
};

// 68408 Warchief's Revenge: Quest Accept (from Thrall, on accept and when the goblin comes back without his cyclone)
class spell_lost_isles_warchiefs_revenge_accept : public SpellScript
{
    PrepareSpellScript(spell_lost_isles_warchiefs_revenge_accept);

    SpellCastResult CheckCast()
    {
        Player* player = GetCaster()->ToPlayer();
        if (!player || player->GetVehicle() || player->GetQuestStatus(WarchiefsRevenge::QUEST_WARCHIEFS_REVENGE) != QUEST_STATUS_INCOMPLETE)
            return SPELL_FAILED_DONT_REPORT;
        return SPELL_CAST_OK;
    }

    void Register() override
    {
        OnCheckCast += SpellCheckCastFn(spell_lost_isles_warchiefs_revenge_accept::CheckCast);
    }
};

void AddSC_lost_isles()
{
    new creature_script<npc_lost_isles_doc_zapnozzle>("npc_lost_isles_doc_zapnozzle");
    new creature_script<npc_lost_isles_frightened_miner>("npc_lost_isles_frightened_miner");
    new quest_lost_isles_miner_troubles();
    new spell_script<spell_lost_isles_new_miner>("spell_lost_isles_new_miner");
    new quest_lost_isles_warchiefs_revenge();
    new spell_script<spell_lost_isles_warchiefs_revenge_accept>("spell_lost_isles_warchiefs_revenge_accept");
}
