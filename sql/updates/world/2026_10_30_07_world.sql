-- To-do 458 (Desiccated Spearman and Andorhal Defender do not fight each other; proposal Gemini item458_20261030_2243 reviewed against the DB):
-- 44316 had no AI at all, 44328 and 44315 only had combat casts and no out-of-combat reaction to hostile NPCs; added OOC SMART_ACTION_ATTACK_START on the closest enemy within 15y to 44316, 44315 and 44328.
-- Source: functional fix reviewed against our world DB (smart_scripts of 44315, 44328); no sniff of the original AI, so not a verified retail copy.
-- Rollback: UPDATE creature_template SET AIName='' WHERE entry=44316; DELETE FROM smart_scripts WHERE source_type=0 AND ((entryorguid=44316 AND id=0) OR (entryorguid=44315 AND id=2) OR (entryorguid=44328 AND id=1));

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 44316;

DELETE FROM `smart_scripts` WHERE `entryorguid` = 44316 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(44316, 0, 0, 0, 1, 0, 100, 0, 1000, 1000, 3000, 3000, 0, 49, 0, 0, 0, 0, 0, 0, 25, 15, 0, 0, 0, 0, 0, 0, 0, 'Desiccated Spearman - OOC - Attack Closest Enemy');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 44315 AND `source_type` = 0 AND `id` = 2;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(44315, 0, 2, 0, 1, 0, 100, 0, 1000, 1000, 3000, 3000, 0, 49, 0, 0, 0, 0, 0, 0, 25, 15, 0, 0, 0, 0, 0, 0, 0, 'Desiccated Magus - OOC - Attack Closest Enemy');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 44328 AND `source_type` = 0 AND `id` = 1;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(44328, 0, 1, 0, 1, 0, 100, 0, 1000, 1000, 3000, 3000, 0, 49, 0, 0, 0, 0, 0, 0, 25, 15, 0, 0, 0, 0, 0, 0, 0, 'Andorhal Defender - OOC - Attack Closest Enemy');
