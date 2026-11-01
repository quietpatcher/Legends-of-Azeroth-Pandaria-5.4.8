-- To-do 464 (quest 13798 Rain of Destruction: cannot talk to Durak to reapply the Imp Disguise):
-- Cause: Durak (33760) gossip menu 10396 only has option 0 (quest 13842), nothing to get the Imp Disguise (63704) back after it is lost.
-- Change: gossip option 1 "I lost my Imp Disguise", shown while quest 13798 is taken/complete and the player has no aura 63704; SmartAI closes the gossip and casts 63704 on the player. The double Splintertree Demolisher (PhaseMgr aura/zone phase merge) from the same report is NOT part of this change (core, no source yet).
-- Source: Wowhead quest 13798 ("Speak with Durak to reapply Imp Disguise"), WoWDB / Wowhead Cata+MoP Classic quest text. Option wording is ours (retail text not available).
-- Rollback: DELETE FROM gossip_menu_option WHERE MenuID = 10396 AND OptionID = 1; DELETE FROM conditions WHERE SourceTypeOrReferenceId = 15 AND SourceGroup = 10396 AND SourceEntry = 1; DELETE FROM smart_scripts WHERE entryorguid = 33760 AND source_type = 0 AND id IN (4, 5);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 10396 AND `OptionID` = 1;
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`, `OptionBroadcastTextID`, `OptionType`, `OptionNpcflag`, `ActionMenuID`, `ActionPoiID`, `BoxCoded`, `BoxMoney`, `BoxText`, `BoxBroadcastTextID`, `VerifiedBuild`) VALUES
(10396, 1, 0, "Durak, I lost my Imp Disguise. Can you give it back?", 0, 1, 1, 0, 0, 0, 0, NULL, 0, 0);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 10396 AND `SourceEntry` = 1;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(15, 10396, 1, 0, 0, 47, 0, 13798, 10, 0, 0, 0, 0, "", "Durak option 1: quest Rain of Destruction taken or complete"),
(15, 10396, 1, 0, 0, 1, 0, 63704, 0, 0, 1, 0, 0, "", "Durak option 1: player has no Imp Disguise");
DELETE FROM `smart_scripts` WHERE `entryorguid` = 33760 AND `source_type` = 0 AND `id` IN (4, 5);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(33760, 0, 4, 5, 62, 0, 100, 0, 10396, 1, 0, 0, 0, 72, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, "Durak - On Gossip Select option 1 - Close Gossip"),
(33760, 0, 5, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 11, 63704, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, "Durak - Linked To Id 4 - Cast Imp Disguise on player");
