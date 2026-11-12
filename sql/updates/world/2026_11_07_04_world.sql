-- To-do 490 follow-up (needs the core change of the same commit: SET_COUNTER value 0 with reset 1 is accepted at load).
-- Own-client retest 07-11 (Horde char): after a failed or repeated try Mirveda's counter was already above 0 at the next accept,
-- went past 3 and never fired "on counter 3" (complete + reset script 1540202), so she stayed on faction 232 without gossip.
-- * Event 6 (reset counter after the completion, as in ref_cpp) is restored and event 5 links to it again (5 -> 6 -> 7).
-- * Accepting the quest (action list 1540201) now also sets counter 1 back to 0, so every try counts from zero.
-- Source: ref_cpp smart_scripts 15402 id 6; own-client retest state/devtest_dev97j_20261105.md 'To-do 490 retest Horde (07-11)'.
-- Rollback: DELETE FROM smart_scripts WHERE (entryorguid = 15402 AND source_type = 0 AND id = 6) OR (entryorguid = 1540201 AND source_type = 9 AND id = 5);
-- UPDATE smart_scripts SET link = 7 WHERE entryorguid = 15402 AND source_type = 0 AND id = 5;
DELETE FROM `smart_scripts` WHERE (`entryorguid` = 15402 AND `source_type` = 0 AND `id` = 6) OR (`entryorguid` = 1540201 AND `source_type` = 9 AND `id` = 5);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(15402, 0, 6, 7, 61, 0, 100, 0, 0, 0, 0, 0, 0, 63, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Apprentice Mirveda - On counter - Reset counter'),
(1540201, 9, 5, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 63, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Apprentice Mirveda - Script 2 - Reset counter');
UPDATE `smart_scripts` SET `link` = 6 WHERE `entryorguid` = 15402 AND `source_type` = 0 AND `id` = 5;
