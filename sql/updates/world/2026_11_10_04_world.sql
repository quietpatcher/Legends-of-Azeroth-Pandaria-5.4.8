-- To-do 449 (rest): Darnassus Attacked? (32414) is handed in to Lady Jaina Proudmoore, who also gives Tracking the Thieves (32460).
-- quest_template_addon already chains them (NextQuestID 32460, PrevQuestID 32414); RewardNextQuest makes Jaina offer the follow-up
-- directly in the turn-in window. Note: the whole chain (32394, 32414, 32460) needs Operation: Shieldwall Revered (1376, 21000);
-- the earlier test that saw no follow-up used a character without that reputation.
-- Source: ref_alex quest_template 32414 NextQuestId 32460; Wowhead quest 32414/32460 (start and end Lady Jaina Proudmoore).
-- Rollback: UPDATE `quest_template` SET `RewardNextQuest`=0 WHERE `ID`=32414;
UPDATE `quest_template` SET `RewardNextQuest`=32460 WHERE `ID`=32414;
