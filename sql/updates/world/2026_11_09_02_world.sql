-- Rollback: UPDATE `quest_template_addon` SET `ScriptName` = '' WHERE `ID` = 27099;
-- Source: core QuestScript hook (ScriptMgr::OnQuestStatusChange runs on abandon, QuestHandler.cpp:634); quest_silverpine_no_escape removes the Agatha bond on abandon
-- To-do 446, No Escape: abandoning the quest left Agatha standing; the quest script removes Bond of the Val'kyr so she leaves.
UPDATE `quest_template_addon` SET `ScriptName` = 'quest_silverpine_no_escape' WHERE `ID` = 27099;
