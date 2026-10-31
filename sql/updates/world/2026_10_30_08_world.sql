-- To-do 459 (Andorhal Defender 44332 and Opengut Behemoth 44562 do not attack each other; proposal Gemini item459_20261030_2303 reviewed):
-- Both lacked the out-of-combat SMART_ACTION_ATTACK_START on the closest enemy within 15y that 44328/44315/44316 got in 2026_10_30_07. unit_flags of 44562 deliberately NOT changed (our value is probably from a sniff, ref_cpp differs, no proof it matters).
-- Source: functional fix reviewed against our world DB (smart_scripts); no sniff of the original AI, so not a verified retail copy.
-- Rollback: DELETE FROM smart_scripts WHERE source_type=0 AND ((entryorguid=44332 AND id=1) OR (entryorguid=44562 AND id=2));

DELETE FROM `smart_scripts` WHERE `entryorguid` = 44332 AND `id` = 1;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(44332, 0, 1, 0, 1, 0, 100, 0, 1000, 1000, 3000, 3000, 0, 49, 0, 0, 0, 0, 0, 0, 25, 15, 0, 0, 0, 0, 0, 0, 0, 'Andorhal Defender - OOC - Attack Closest Enemy');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 44562 AND `id` = 2;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(44562, 0, 2, 0, 1, 0, 100, 0, 1000, 1000, 3000, 3000, 0, 49, 0, 0, 0, 0, 0, 0, 25, 15, 0, 0, 0, 0, 0, 0, 0, 'Opengut Behemoth - OOC - Attack Closest Enemy');
