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

#include "QuestDef.h"
#include "QuestPools.h"
#include "Player.h"
#include "World.h"
#include "ObjectMgr.h"

Quest::Quest(Field* questRecord)
{
    _id = questRecord[0].GetUInt32();
    _type = questRecord[1].GetUInt8();
    _questLevel = questRecord[2].GetInt16();
    _minLevel = questRecord[3].GetInt16();
    _packageID = questRecord[4].GetUInt32();
    _questSortID = questRecord[5].GetInt16();
    _questInfoID = questRecord[6].GetUInt16();
    _suggestedPlayers = questRecord[7].GetUInt8();
    _nextQuestInChain = questRecord[8].GetUInt32();
    _rewardXPDifficulty = questRecord[9].GetUInt8();
    _rewardMoney = questRecord[10].GetInt32();
    _rewardBonusMoney = questRecord[11].GetUInt32();
    _rewardDisplaySpell = questRecord[12].GetUInt32();
    _rewardSpell = questRecord[13].GetInt32();
    _rewardHonor = questRecord[14].GetUInt32();
    _rewardKillHonor = questRecord[15].GetUInt32();
    _sourceItemId = questRecord[16].GetUInt32();
    _flags = questRecord[17].GetUInt32();
    _flagsEx = questRecord[18].GetUInt32();

    _rewItemsCount = 0;
    _rewChoiceItemsCount = 0;
    _rewCurrencyCount = 0;

    for (uint32 i = 0; i < QUEST_ITEM_DROP_COUNT; ++i)
    {
        RewardItemId[i] = questRecord[19 + i * 4].GetUInt32();
        RewardItemCount[i] = questRecord[20 + i * 4].GetUInt32();
        ItemDrop[i] = questRecord[21 + i * 4].GetUInt32();
        ItemDropQuantity[i] = questRecord[22 + i * 4].GetUInt32();

        if (RewardItemId[i])
            ++_rewItemsCount;
    }

    for (uint32 i = 0; i < QUEST_REWARD_CHOICES_COUNT; ++i)
    {
        RewardChoiceItemId[i] = questRecord[35 + i * 2].GetUInt32();
        RewardChoiceItemCount[i] = questRecord[36 + i * 2].GetUInt32();

        if (RewardChoiceItemId[i])
            ++_rewChoiceItemsCount;
    }

    _poiContinent = questRecord[47].GetUInt16();
    _poix = questRecord[48].GetFloat();
    _poiy = questRecord[49].GetFloat();
    _poiPriority = questRecord[50].GetUInt32();

    _rewardTitleId = questRecord[51].GetUInt16();
    _rewardArenaPoints = questRecord[52].GetUInt16();
    _rewardSkillId = questRecord[53].GetUInt16();
    _rewardSkillPoints = questRecord[54].GetUInt8();

    _questGiverPortrait = questRecord[55].GetUInt32();
    _questTurnInPortrait = questRecord[56].GetUInt32();

    for (uint32 i = 0; i < QUEST_REWARD_REPUTATIONS_COUNT; ++i)
    {
        RewardFactionId[i] = questRecord[57 + i * 3].GetUInt32();
        RewardFactionValue[i] = questRecord[58 + i * 3].GetInt32();
        RewardFactionOverride[i] = questRecord[59 + i * 3].GetInt32();
    }

    _rewardReputationMask = questRecord[72].GetUInt32();

    for (uint32 i = 0; i < QUEST_REWARD_CURRENCY_COUNT; ++i)
    {
        RewardCurrencyId[i] = questRecord[73 + i * 2].GetUInt32();
        RewardCurrencyCount[i] = questRecord[74 + i * 2].GetUInt32();

        if (RewardCurrencyId[i])
            ++_rewCurrencyCount;
    }

    _soundAccept = questRecord[81].GetUInt16();
    _soundTurnIn = questRecord[82].GetUInt16();
    _areaGroupID = questRecord[83].GetUInt8();
    _limitTime = questRecord[84].GetUInt32();
    _allowableRaces = questRecord[85].GetUInt32();

    _logTitle = questRecord[86].GetString();
    _logDescription = questRecord[87].GetString();
    _questDescription = questRecord[88].GetString();
    _areaDescription = questRecord[89].GetString();
    _portraitGiverText = questRecord[90].GetString();
    _portraitGiverName = questRecord[91].GetString();
    _portraitTurnInText = questRecord[92].GetString();
    _portraitTurnInName = questRecord[93].GetString();
    _questCompletionLog = questRecord[94].GetString();
}

void Quest::LoadRewardDisplaySpell(Field* fields)
{
    uint32 spellId = fields[1].GetUInt32();
    uint32 playerConditionId = fields[2].GetUInt32();
    uint32 type = fields[3].GetUInt32();

    if (!sSpellMgr->GetSpellInfo(spellId))
    {
        TC_LOG_ERROR("sql.sql", "Table `quest_reward_display_spell` has non-existing Spell ({}) set for quest {}. Skipped.", spellId, fields[0].GetUInt32());
        return;
    }

    if (type >= AsUnderlyingType(QuestCompleteSpellType::Max))
    {
        TC_LOG_ERROR("sql.sql", "Table `quest_reward_display_spell` invalid type value ({}) set for quest {} and spell {}. Set to 0.", type, fields[0].GetUInt32(), spellId);
        type = AsUnderlyingType(QuestCompleteSpellType::LegacyBehavior);
    }

    RewardDisplaySpell.emplace_back(spellId, playerConditionId, QuestCompleteSpellType(type));
}

void Quest::LoadQuestDetails(Field* fields)
{
    for (uint32 i = 0; i < QUEST_EMOTE_COUNT; ++i)
    {
        if (!sEmotesStore.LookupEntry(fields[1 + i].GetUInt16()))
        {
            TC_LOG_ERROR("sql.sql", "Table `quest_details` has non-existing Emote{} ({}) set for quest {}. Skipped.", 1+i, fields[1+i].GetUInt16(), fields[0].GetUInt32());
            continue;
        }

        DetailsEmote[i] = fields[1 + i].GetUInt16();
    }

    for (uint32 i = 0; i < QUEST_EMOTE_COUNT; ++i)
        DetailsEmoteDelay[i] = fields[5 + i].GetUInt32();
}

void Quest::LoadQuestRequestItems(Field* fields)
{
    _emoteOnComplete = fields[1].GetUInt16();
    _emoteOnIncomplete = fields[2].GetUInt16();

    if (!sEmotesStore.LookupEntry(_emoteOnComplete))
        TC_LOG_ERROR("sql.sql", "Table `quest_request_items` has non-existing EmoteOnComplete ({}) set for quest {}.", _emoteOnComplete, fields[0].GetUInt32());

    if (!sEmotesStore.LookupEntry(_emoteOnIncomplete))
        TC_LOG_ERROR("sql.sql", "Table `quest_request_items` has non-existing EmoteOnIncomplete ({}) set for quest {}.", _emoteOnIncomplete, fields[0].GetUInt32());

    _requestItemsText = fields[3].GetString();
}

void Quest::LoadQuestOfferReward(Field* fields)
{
    for (uint32 i = 0; i < QUEST_EMOTE_COUNT; ++i)
    {
        if (!sEmotesStore.LookupEntry(fields[1 + i].GetUInt16()))
        {
            TC_LOG_ERROR("sql.sql", "Table `quest_offer_reward` has non-existing Emote{} ({}) set for quest {}. Skipped.", 1+i, fields[1+i].GetUInt16(), fields[0].GetUInt32());
            continue;
        }

        OfferRewardEmote[i] = fields[1 + i].GetInt16();
    }

    for (uint32 i = 0; i < QUEST_EMOTE_COUNT; ++i)
        OfferRewardEmoteDelay[i] = fields[5 + i].GetUInt32();

    _offerRewardText = fields[9].GetString();
}

void Quest::LoadQuestTemplateAddon(Field* fields)
{
    _maxLevel = fields[1].GetUInt8();
    _allowableClasses = fields[2].GetUInt32();
    _sourceSpellID = fields[3].GetUInt32();
    _prevQuestID = fields[4].GetInt32();
    _nextQuestID = fields[5].GetUInt32();
    _exclusiveGroup = fields[6].GetInt32();
    _rewardMailTemplateId = fields[7].GetUInt32();
    _rewardMailDelay = fields[8].GetUInt32();
    _requiredSkillId = fields[9].GetUInt16();
    _requiredSkillPoints = fields[10].GetUInt16();
    _requiredMinRepFaction = fields[11].GetUInt16();
    _requiredMaxRepFaction = fields[12].GetUInt16();
    _requiredMinRepValue = fields[13].GetInt32();
    _requiredMaxRepValue = fields[14].GetInt32();
    _sourceItemIdCount = fields[15].GetUInt8();
    _specialFlags = fields[16].GetUInt8();
    _scriptId = sObjectMgr->GetScriptId(fields[17].GetString());

    if (_specialFlags & QUEST_SPECIAL_FLAGS_AUTO_ACCEPT)
        _flags |= QUEST_FLAGS_AUTO_ACCEPT;
}

void Quest::LoadQuestObjective(Field* fields)
{
    QuestObjective& obj = Objectives.emplace_back();
    obj.QuestID = fields[0].GetUInt32();
    obj.ID = fields[1].GetUInt32();
    obj.Type = fields[2].GetUInt8();
    obj.StorageIndex = fields[3].GetInt8();
    obj.ObjectID = fields[4].GetInt32();
    obj.Amount = fields[5].GetInt32();
    obj.Flags = fields[6].GetUInt32();
    obj.Description = fields[7].GetString();

    _usedQuestObjectiveTypes[obj.Type] = true;
}

void Quest::LoadQuestObjectiveVisualEffect(Field* fields)
{
    uint32 objID = fields[1].GetUInt32();

    for (QuestObjective& obj : Objectives)
    {
        if (obj.ID == objID)
        {
            uint8 effectIndex = fields[3].GetUInt8();
            if (effectIndex >= obj.VisualEffects.size())
                obj.VisualEffects.resize(effectIndex + 1, 0);

            obj.VisualEffects[effectIndex] = fields[4].GetInt32();
            break;
        }
    }
}

uint32 Quest::XPValue(Player const* player) const
{
    if (player)
    {
        int32 quest_level = (_questLevel == -1 ? player->GetLevel() : _questLevel);
        const QuestXPEntry* xpentry = sQuestXPStore.LookupEntry(quest_level);
        if (!xpentry)
            return 0;

        int32 diffFactor = 2 * (quest_level - player->GetLevel()) + 20;
        if (diffFactor < 1)
            diffFactor = 1;
        else if (diffFactor > 10)
            diffFactor = 10;

        uint32 xp = diffFactor * xpentry->Difficulty[_rewardXPDifficulty] / 10;
        if (xp <= 100)
            xp = 5 * ((xp + 2) / 5);
        else if (xp <= 500)
            xp = 10 * ((xp + 5) / 10);
        else if (xp <= 1000)
            xp = 25 * ((xp + 12) / 25);
        else
            xp = 50 * ((xp + 25) / 50);

        return xp;
    }

    return 0;
}

// (quest-money-table) QuestMoneyReward.dbc of the 5.4.8 client: money per level (1-100) and difficulty column (0-9)
static int32 const sQuestMoneyReward[100][10] =
{
    { 0, 2, 4, 8, 12, 15, 30, 50, 75, 0 },
    { 0, 3, 8, 17, 25, 35, 65, 100, 125, 0 },
    { 0, 5, 13, 25, 40, 50, 100, 150, 200, 0 },
    { 0, 7, 20, 35, 55, 75, 150, 225, 300, 0 },
    { 0, 10, 25, 50, 75, 100, 200, 300, 400, 0 },
    { 0, 13, 35, 65, 100, 125, 250, 400, 500, 0 },
    { 0, 17, 45, 85, 125, 175, 350, 500, 700, 0 },
    { 0, 22, 55, 110, 175, 225, 450, 700, 900, 0 },
    { 0, 30, 70, 150, 200, 300, 600, 900, 1200, 0 },
    { 0, 35, 85, 175, 250, 350, 700, 1000, 1300, 0 },
    { 0, 40, 100, 200, 300, 400, 800, 1300, 1700, 0 },
    { 0, 50, 125, 250, 350, 500, 1000, 1500, 2000, 0 },
    { 0, 55, 150, 300, 400, 600, 1100, 1700, 2300, 0 },
    { 0, 65, 150, 300, 500, 600, 1300, 2000, 2700, 0 },
    { 0, 70, 175, 350, 500, 700, 1400, 2000, 2700, 0 },
    { 0, 80, 200, 400, 600, 800, 1600, 2500, 3300, 0 },
    { 0, 90, 225, 450, 700, 900, 1800, 2500, 3300, 0 },
    { 0, 100, 250, 500, 700, 1000, 2000, 3000, 4000, 0 },
    { 0, 100, 250, 500, 800, 1100, 2000, 3000, 4000, 0 },
    { 0, 125, 300, 600, 900, 1200, 2500, 3500, 4700, 0 },
    { 0, 125, 350, 700, 1000, 1300, 2500, 4000, 5300, 0 },
    { 0, 150, 350, 700, 1100, 1400, 3000, 4500, 6000, 0 },
    { 0, 150, 400, 800, 1200, 1500, 3000, 4500, 6000, 0 },
    { 0, 175, 400, 800, 1300, 1700, 3500, 5000, 6700, 0 },
    { 0, 175, 500, 900, 1400, 1800, 3500, 5500, 7300, 0 },
    { 0, 200, 500, 1000, 1500, 2000, 4000, 6000, 8000, 0 },
    { 0, 225, 600, 1100, 1700, 2200, 4500, 6500, 8700, 0 },
    { 0, 250, 600, 1200, 1800, 2500, 5000, 7000, 9300, 0 },
    { 0, 250, 600, 1300, 1900, 2500, 5000, 7500, 10000, 0 },
    { 0, 250, 700, 1400, 2100, 2500, 5500, 8000, 10700, 0 },
    { 0, 300, 700, 1500, 2200, 3000, 6000, 9000, 12000, 0 },
    { 0, 300, 800, 1600, 2500, 3000, 6500, 9500, 12700, 0 },
    { 0, 350, 800, 1700, 2500, 3500, 6500, 10000, 13300, 0 },
    { 0, 350, 900, 1700, 2500, 3500, 7000, 10500, 14000, 0 },
    { 0, 350, 900, 1800, 2500, 3500, 7500, 11000, 14700, 0 },
    { 0, 400, 1000, 2000, 3000, 4000, 7500, 11500, 15300, 0 },
    { 0, 400, 1000, 2000, 3000, 4000, 8000, 12000, 16000, 0 },
    { 0, 400, 1100, 2000, 3000, 4500, 8500, 13000, 17300, 0 },
    { 0, 500, 1100, 2500, 3500, 4500, 9000, 14000, 18700, 0 },
    { 0, 500, 1200, 2500, 3500, 5000, 10000, 15000, 20000, 0 },
    { 0, 500, 1300, 2500, 4000, 5500, 11000, 16000, 21300, 0 },
    { 0, 600, 1400, 3000, 4500, 5500, 11500, 17000, 22700, 0 },
    { 0, 600, 1500, 3000, 4500, 6000, 12000, 18000, 24000, 0 },
    { 0, 600, 1600, 3000, 4500, 6500, 12500, 19000, 25300, 0 },
    { 0, 600, 1600, 3000, 5000, 6500, 13000, 19500, 26000, 0 },
    { 0, 700, 1700, 3500, 5000, 6500, 13000, 20000, 26700, 0 },
    { 0, 700, 1700, 3500, 5000, 7000, 13500, 20500, 27300, 0 },
    { 0, 700, 1700, 3500, 5000, 7000, 14000, 21000, 28000, 0 },
    { 0, 700, 1800, 3500, 5500, 7000, 14000, 21000, 28000, 0 },
    { 0, 700, 1800, 3500, 5500, 7500, 14500, 22000, 29300, 0 },
    { 0, 800, 1900, 4000, 5500, 7500, 15000, 22500, 30000, 0 },
    { 0, 800, 1900, 4000, 6000, 7500, 15500, 23000, 30700, 0 },
    { 0, 800, 2000, 4000, 6000, 8000, 16000, 24000, 32000, 0 },
    { 0, 800, 2000, 4000, 6000, 8000, 16500, 24500, 32700, 0 },
    { 0, 800, 2100, 4000, 6000, 8500, 16500, 25000, 33300, 0 },
    { 0, 800, 2100, 4000, 6500, 8500, 17000, 25500, 34000, 0 },
    { 0, 900, 2200, 4500, 6500, 8500, 17000, 26000, 34700, 0 },
    { 0, 900, 2200, 4500, 6500, 9000, 17500, 26500, 35300, 0 },
    { 0, 900, 2200, 4500, 6500, 9000, 18000, 26500, 35300, 0 },
    { 0, 900, 2300, 4500, 7000, 9000, 18000, 27000, 36000, 0 },
    { 0, 2000, 5200, 10000, 16000, 20000, 40000, 60000, 80000, 0 },
    { 0, 2800, 7000, 14000, 21000, 27000, 54000, 81000, 108000, 0 },
    { 0, 3000, 7400, 15000, 23000, 29000, 58000, 87000, 116000, 0 },
    { 0, 3200, 8000, 16000, 24000, 31000, 62000, 93000, 124000, 0 },
    { 0, 3400, 8400, 17000, 26000, 33000, 66000, 99000, 132000, 0 },
    { 0, 3600, 9000, 18000, 27000, 35000, 70000, 105000, 140000, 0 },
    { 0, 3800, 9400, 19000, 29000, 37000, 74000, 111000, 148000, 0 },
    { 0, 4000, 10000, 20000, 30000, 39000, 78000, 117000, 156000, 0 },
    { 0, 4200, 10400, 21000, 32000, 41000, 82000, 123000, 164000, 0 },
    { 0, 4400, 11200, 22000, 34000, 44000, 88000, 132000, 176000, 0 },
    { 0, 4800, 12000, 24000, 37000, 47000, 94000, 141000, 188000, 0 },
    { 0, 5000, 12800, 25000, 39000, 50000, 100000, 150000, 200000, 0 },
    { 0, 5400, 13600, 27000, 41000, 53000, 106000, 159000, 212000, 0 },
    { 0, 5600, 14400, 28000, 44000, 56000, 112000, 168000, 224000, 0 },
    { 0, 6000, 15000, 30000, 46000, 59000, 118000, 177000, 236000, 0 },
    { 0, 6200, 15800, 31000, 48000, 62000, 124000, 186000, 248000, 0 },
    { 0, 6600, 16600, 33000, 51000, 65000, 130000, 195000, 260000, 0 },
    { 0, 6800, 17400, 34000, 53000, 68000, 136000, 204000, 272000, 0 },
    { 0, 7200, 18200, 36000, 55000, 71000, 142000, 213000, 284000, 0 },
    { 0, 7400, 19000, 37000, 58000, 74000, 148000, 222000, 296000, 0 },
    { 0, 7800, 19500, 39000, 59000, 78000, 156000, 234000, 312000, 0 },
    { 0, 8200, 20500, 41000, 62000, 82000, 164000, 246000, 328000, 0 },
    { 0, 8600, 21500, 43000, 65000, 86000, 172000, 258000, 344000, 0 },
    { 0, 9000, 22500, 45000, 68000, 90000, 180000, 270000, 360000, 0 },
    { 0, 9400, 23500, 47000, 71000, 94000, 188000, 282000, 376000, 0 },
    { 0, 9800, 24500, 49000, 74000, 98000, 196000, 294000, 392000, 0 },
    { 0, 10200, 25500, 51000, 77000, 102000, 204000, 306000, 408000, 0 },
    { 0, 10600, 26500, 53000, 80000, 106000, 212000, 318000, 424000, 0 },
    { 0, 11000, 27500, 55000, 83000, 110000, 220000, 330000, 440000, 0 },
    { 0, 11400, 28500, 57000, 86000, 114000, 228000, 342000, 456000, 0 },
    { 0, 11800, 29500, 59000, 89000, 118000, 236000, 354000, 472000, 0 },
    { 0, 12200, 30500, 61000, 92000, 122000, 244000, 366000, 488000, 0 },
    { 0, 12600, 31500, 63000, 95000, 126000, 252000, 378000, 504000, 0 },
    { 0, 13000, 32500, 65000, 98000, 130000, 260000, 390000, 520000, 0 },
    { 0, 13400, 33500, 67000, 101000, 134000, 268000, 402000, 536000, 0 },
    { 0, 13800, 34500, 69000, 104000, 138000, 276000, 414000, 552000, 0 },
    { 0, 14200, 35500, 71000, 107000, 142000, 284000, 426000, 568000, 0 },
    { 0, 14600, 36500, 73000, 110000, 146000, 292000, 438000, 584000, 0 },
    { 0, 15000, 37500, 75000, 113000, 150000, 300000, 450000, 600000, 0 },
    { 0, 15400, 38500, 77000, 116000, 154000, 308000, 462000, 616000, 0 }
};

int32 Quest::GetRewOrReqMoney(Player const* player) const
{
    // RequiredMoney: the amount is the negative copper sum.
    if (_rewardMoney < 0)
        return _rewardMoney;

    // the Angler's dailies pay with the level - level^2 x 20 copper (20 silver at 10, 16 gold at 90)
    if (_id >= 99101 && _id <= 99103 && player)
        return int32(player->GetLevel() * player->GetLevel() * 20 * sWorld->getRate(RATE_DROP_MONEY));

    // quests that take the player's level carry the money sniffed at one level (mostly 90: 11g40s).
    // Scale it like retail, ~level^2: base 114000 (or the stored amount if larger) x level^2 / 8100.
    if (_questLevel == -1 && _rewardMoney > 0 && player)
    {
        uint32 level = std::min<uint32>(player->GetLevel(), 90);
        // (quest-money-table) the column of the client table whose level-90 amount is the stored amount
        for (uint32 col = 0; col < 10; ++col)
            if (sQuestMoneyReward[89][col] == _rewardMoney)
                return std::max<int32>(1, int32(sQuestMoneyReward[std::max<uint32>(level, 1) - 1][col] * sWorld->getRate(RATE_DROP_MONEY)));
        double base = std::max<int32>(_rewardMoney, 114000);
        return std::max<int32>(1, int32(base * level * level / 8100.0 * sWorld->getRate(RATE_DROP_MONEY)));
    }

    // RewardMoney: the positive amount
    if (!player || !player->IsMaxLevel())
        return int32(_rewardMoney * sWorld->getRate(RATE_DROP_MONEY));
    else // At level cap, the money reward is the maximum amount between normal and bonus money reward
        return std::max(int32(GetRewMoneyMaxLevel()), int32(_rewardMoney * sWorld->getRate(RATE_DROP_MONEY)));
}

uint32 Quest::GetRewMoneyMaxLevel() const
{
    if (HasFlag(QUEST_FLAGS_NO_MONEY_FOR_XP))
        return 0;

    return _rewardBonusMoney;
}

/*static*/ bool Quest::IsTakingQuestEnabled(uint32 questId)
{
    if (!sQuestPoolMgr->IsQuestActive(questId))
        return false;

    return true;
}

bool Quest::IsAutoAccept() const
{
    return !sWorld->getBoolConfig(CONFIG_QUEST_IGNORE_AUTO_ACCEPT) && HasFlag(QUEST_FLAGS_AUTO_ACCEPT);
}

bool Quest::IsTurnIn() const
{
    return !sWorld->getBoolConfig(CONFIG_QUEST_IGNORE_AUTO_COMPLETE) && (_type == QUEST_TYPE_TURNIN || HasFlag(QUEST_FLAGS_AUTO_COMPLETE));
}

bool Quest::IsRaidQuest(Difficulty difficulty) const
{
    switch (_questInfoID)
    {
        case QUEST_INFO_RAID:
            return true;
        case QUEST_INFO_LEGENDARY:
            if (_id == 30107 || _id == 30118 || // Cluster Clutch
                _id == 32431 || _id == 32389)   // The Lion Roars
                return true;
            break;
        case QUEST_INFO_RAID_10:
            return (difficulty == RAID_DIFFICULTY_10MAN_NORMAL || difficulty == RAID_DIFFICULTY_10MAN_HEROIC);
        case QUEST_INFO_RAID_25:
            return (difficulty == RAID_DIFFICULTY_25MAN_NORMAL || difficulty == RAID_DIFFICULTY_25MAN_HEROIC || difficulty == RAID_DIFFICULTY_25MAN_LFR);
        default:
            break;
    }

    if (HasFlag(QUEST_FLAGS_RAID_GROUP_OK))
        return true;

    return false;
}

bool Quest::IsAllowedInRaid(Difficulty difficulty) const
{
    if (IsRaidQuest(difficulty))
        return true;

    return sWorld->getBoolConfig(CONFIG_QUEST_IGNORE_RAID);
}

uint32 Quest::CalculateHonorGain(uint8 level) const
{
    if (level > GT_MAX_LEVEL)
        level = GT_MAX_LEVEL;

    uint32 honor = 0;

    /*if (GetRewHonorAddition() > 0 || GetRewHonorMultiplier() > 0.0f)
    {
        // values stored from 0.. for 1...
        TeamContributionPointsEntry const* tc = sTeamContributionPointsStore.LookupEntry(level);
        if (!tc)
            return 0;

        honor = uint32(tc->value * GetRewHonorMultiplier() * 0.1f);
        honor += GetRewHonorAddition();
    }*/

    return honor;
}
