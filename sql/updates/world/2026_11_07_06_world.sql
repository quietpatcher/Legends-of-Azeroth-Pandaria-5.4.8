-- To-do 490 follow-up: quest 8488 has SpecialFlags EXPLORATION_OR_EVENT, so it completes only after the "event happened" call.
-- That call came from Mirveda's counter (3 summons dead). In the own-client retest the quest could not be turned in: when the
-- last summon dies Mirveda leaves combat first, her evade/reset clears the counters (SmartScript::OnReset), and only then the
-- summon's death row adds 1, so the counter never reached 3. Gharsul now reports the event to the player who killed him
-- (action invoker on death), which is the quest goal ("Gharsul the Remorseless slain" + Mirveda protected; if she dies first
-- the quest has already failed).
-- Source: own-client retest 07-11 (state/devtest_dev97j_20261105.md 'To-do 490 retest evade-reset'), SmartScript.cpp OnReset,
-- quest_template 8488 SpecialFlags 2.
-- Rollback: DELETE FROM smart_scripts WHERE entryorguid = 15958 AND source_type = 0 AND id = 6;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 15958 AND `source_type` = 0 AND `id` = 6;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(15958, 0, 6, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 15, 8488, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'Gharsul the Remorseless - On Death - Quest Unexpected Results event happens for the killer');
