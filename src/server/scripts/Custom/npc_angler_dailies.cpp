/*
 * the Angler (the server, 2-10-2026)
 *
 * A pandaren angler by the fishing trainers of the ten capitals, one NPC for each faction (990001 Alliance, 990002
 * Horde). He gives three dailies: Weekend Catch (99101, ten fish), The One That Didn't Get Away (99102, a rare
 * catch) and Net Gains (99103, five finds from fishing pools). Player::StoreLootItem gives their credits. The quests
 * themselves give +1 fishing (RewardSkillLineID); on the turn-in he adds gold that grows with the level, now and
 * then an angler's item, and after ten of his dailies a Tiny Goldfish. About every quarter of an hour he yells
 * something across the city, and now and then he farts so the whole city hears it.
 */

#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "Player.h"
#include "QuestDef.h"
#include "DatabaseEnv.h"

enum AnglerDailies
{
    SAY_IDLE                = 0,      // zone yell
    EMOTE_FART              = 1,      // zone emote with a sound
    SAY_GOLDFISH            = 2,

    QUEST_WEEKEND_CATCH     = 99101,
    QUEST_NET_GAINS         = 99103,

    ITEM_TINY_GOLDFISH      = 85447,
    DAILIES_FOR_GOLDFISH    = 10,
    ITEM_CHANCE_PERCENT     = 5,

    EVENT_YELL              = 1,
    EVENT_FART              = 2,
};

// a small chance at one of these on a turn-in
static uint32 const AnglerItems[] =
{
    33820,  // Weather-Beaten Fishing Hat
    45991,  // Bone Fishing Pole
    45992,  // Jeweled Fishing Pole
    19971,  // High Test Eternium Fishing Line
    85973,  // Ancient Pandaren Fishing Charm
};

struct npc_angler_dailies : public ScriptedAI
{
    npc_angler_dailies(Creature* creature) : ScriptedAI(creature) { }

    void Reset() override
    {
        _events.Reset();
        _events.ScheduleEvent(EVENT_YELL, urand(2, 15) * MINUTE * IN_MILLISECONDS);
        _events.ScheduleEvent(EVENT_FART, urand(10, 40) * MINUTE * IN_MILLISECONDS);
    }

    void UpdateAI(uint32 diff) override
    {
        _events.Update(diff);
        while (uint32 eventId = _events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_YELL:
                    Talk(SAY_IDLE);
                    _events.ScheduleEvent(EVENT_YELL, urand(13, 17) * MINUTE * IN_MILLISECONDS);
                    break;
                case EVENT_FART:
                    Talk(EMOTE_FART);
                    _events.ScheduleEvent(EVENT_FART, urand(25, 45) * MINUTE * IN_MILLISECONDS);
                    break;
                default:
                    break;
            }
        }
    }

    void OnQuestReward(Player* player, Quest const* quest, uint32 /*opt*/) override
    {
        uint32 const questId = quest->GetQuestId();
        if (questId < QUEST_WEEKEND_CATCH || questId > QUEST_NET_GAINS)
            return;

        // (the gold that grows with the level is the quest money itself: Quest::GetRewOrReqMoney, shown in the window)

        if (urand(0, 99) < ITEM_CHANCE_PERCENT)
            player->AddItem(AnglerItems[urand(0, sizeof(AnglerItems) / sizeof(AnglerItems[0]) - 1)], 1);

        // the dailies he has had from this player; the tenth brings the goldfish
        uint32 const guid = player->GetGUID().GetCounter();
        CharacterDatabase.DirectPExecute("INSERT INTO tt_angler_dailies (guid, dailies) VALUES ({}, 1) "
            "ON DUPLICATE KEY UPDATE dailies = dailies + 1", guid);
        if (QueryResult result = CharacterDatabase.PQuery("SELECT dailies FROM tt_angler_dailies WHERE guid = {}", guid))
            if (result->Fetch()[0].GetUInt32() == DAILIES_FOR_GOLDFISH && player->AddItem(ITEM_TINY_GOLDFISH, 1))
                Talk(SAY_GOLDFISH, player);
    }

private:
    EventMap _events;
};

void AddSC_npc_angler_dailies()
{
    RegisterCreatureAI(npc_angler_dailies);
}
