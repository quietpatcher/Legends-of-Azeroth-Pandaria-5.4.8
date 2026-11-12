-- Quest-chain blockers ported from 1LineAtaTime/LoA-Pandaria-Playerbots 9648ddfb (GPLv2): 2026_10_28_982 items 6 and 7, 2026_10_29_1005.
-- Items 1-5 of 982 (negative PrevQuestID rows) are not needed here: the core change that treats a negative PrevQuestID as
-- "taken" (SatisfyQuestPreviousQuest) makes them takeable without data changes.
-- Sources: 6) AC, TC 4.3.4 and SFDB 5.4.8 all have PrevQuestID/NextQuestID/ExclusiveGroup 0 for these cloth donations (Wowpedia: no
-- prerequisite); ours form a dependency cycle through the exclusive group. 7) SkyFire 5.4.8 (ref_sf) has the starter and ender rows
-- (58114, 30127); without them the Horde Krasarang chain stops after Blind Them! (30124). 1005) see the notes below.
-- Rollback: the commented statements at the end of this file.

-- 6) A Donation of Silk / Mageweave / Runecloth (Exodar and Silvermoon): remove the prerequisite cycle.
UPDATE `quest_template_addon` SET `PrevQuestID` = 0, `NextQuestID` = 0, `ExclusiveGroup` = 0
 WHERE `ID` IN (7792, 7798, 10356, 10359, 10360, 10361) AND `ExclusiveGroup` IN (-7792, -10359);

-- 7) 30127 Threat from Dojan (Horde): Kor Bloodtusk 58114 starts and ends it.
DELETE FROM `creature_queststarter` WHERE `id` = 58114 AND `quest` = 30127;
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES (58114, 30127);
DELETE FROM `creature_questender` WHERE `id` = 58114 AND `quest` = 30127;
INSERT INTO `creature_questender` (`id`, `quest`) VALUES (58114, 30127);

-- 1005) 14125 "447": Kezan phase_definitions entry 5 (phasemask 96) requires 14125 QUEST_NONE or complete, so while 14125 is
-- INCOMPLETE the player fell back to phasemask 1 and the Gasbot Control Panel 201736 (phase 176) was invisible. A second OR group
-- (ElseGroup 1) accepts 14120 rewarded AND 14125 taken (condition 9, incomplete only). The existing ElseGroup 0 rows are untouched.
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 25 AND `SourceGroup` = 4737 AND `SourceEntry` = 5 AND `ElseGroup` = 1;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(25, 4737, 5, 0, 1, 8, 0, 14120, 0, 0, 0, 0, 0, '', 'Kezan phase 96: 14120 rewarded (447 in progress)'),
(25, 4737, 5, 0, 1, 9, 0, 14125, 0, 0, 0, 0, 0, '', 'Kezan phase 96: 14125 taken (Gasbot Control Panel visible)');

-- Rollback:
--   UPDATE `quest_template_addon` SET `NextQuestID` = 10357, `ExclusiveGroup` = -7792 WHERE `ID` IN (7792, 7798, 10356);
--   UPDATE `quest_template_addon` SET `PrevQuestID` = 7798 WHERE `ID` = 10356;
--   UPDATE `quest_template_addon` SET `NextQuestID` = 10362, `ExclusiveGroup` = -10359 WHERE `ID` IN (10359, 10360, 10361);
--   UPDATE `quest_template_addon` SET `PrevQuestID` = 10359 WHERE `ID` = 10360;
--   UPDATE `quest_template_addon` SET `PrevQuestID` = 10360 WHERE `ID` = 10361;
--   DELETE FROM `creature_queststarter` WHERE `id` = 58114 AND `quest` = 30127;
--   DELETE FROM `creature_questender` WHERE `id` = 58114 AND `quest` = 30127;
--   DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 25 AND `SourceGroup` = 4737 AND `SourceEntry` = 5 AND `ElseGroup` = 1;
