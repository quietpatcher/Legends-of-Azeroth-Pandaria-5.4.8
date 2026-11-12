-- To-do 490 follow-up: after the three summons died Mirveda left combat at once (EVADEDIAG left-combat entry=15402) and the
-- timed reset script 1540202 started by the completion was dropped by the evade, so she stayed on faction 232 without gossip.
-- The reset now also runs directly on evade (as for Prospector Anvilward 15420): gossip/quest flag back, faction 1604,
-- immune to NPCs again, phase 0. This also covers a try that ends without completion.
-- Source: own-client retest 07-11 (state/devtest_dev97j_20261105.md 'To-do 490 retest dev97t'), Server.log EVADEDIAG line;
-- the actions are those of ref_cpp action list 1540202.
-- Rollback: DELETE FROM smart_scripts WHERE entryorguid = 15402 AND source_type = 0 AND id BETWEEN 9 AND 12;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 15402 AND `source_type` = 0 AND `id` BETWEEN 9 AND 12;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(15402, 0,  9, 10, 7, 0, 100, 0, 0, 0, 0, 0, 0, 81,    2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Apprentice Mirveda - On Evade - Set NPC Flags gossip/questgiver'),
(15402, 0, 10, 11, 61, 0, 100, 0, 0, 0, 0, 0, 0, 2, 1604, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Apprentice Mirveda - On Evade - Set Faction 1604'),
(15402, 0, 11, 12, 61, 0, 100, 0, 0, 0, 0, 0, 0, 18,  512, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Apprentice Mirveda - On Evade - Add Unit Flags Immune to NPC'),
(15402, 0, 12,  0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 22,    0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Apprentice Mirveda - On Evade - Set Phase 0');
