-- To-do 446, Fenris Keep, quest 27099 No Escape (simplified scene, owner decision 30-10): on the live server Agatha (44951) did not react to a
-- player on the quest standing next to her; on dev the first approach to the Agatha loaded at server start also gave nothing, after a kill and
-- respawn it worked every time. Cause NOT proven (state/fix433_446_20261105.md): either the start state misses event phase 1, or she stands in
-- combat (OOC_LOS returns while IsInCombat). Make the trigger independent of both:
-- (1) event 0 (OOC_LOS) fires in every event phase (mask 0 instead of 1); the quest condition (27099 taken = INCOMPLETE) still stops a second
--     trigger for the same player, because the credit completes the objective;
-- (2) the same trigger as IC_LOS (id 11, event 26) with the same condition, so a stuck combat state does not block it.
-- Source: own script (2026_10_30_01, commit 948ede1a); SmartScript.cpp:3056 (mask 0 = every phase), SmartScript.cpp:3291 (OOC_LOS needs !IsInCombat).
-- Rollback: UPDATE `smart_scripts` SET `event_phase_mask` = 1 WHERE `entryorguid` = 44951 AND `source_type` = 0 AND `id` = 0;
--           DELETE FROM `smart_scripts` WHERE `entryorguid` = 44951 AND `source_type` = 0 AND `id` = 11;
--           DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 22 AND `SourceGroup` = 12 AND `SourceEntry` = 44951;
UPDATE `smart_scripts` SET `event_phase_mask` = 0 WHERE `entryorguid` = 44951 AND `source_type` = 0 AND `id` = 0;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 44951 AND `source_type` = 0 AND `id` = 11;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`)
SELECT `entryorguid`, `source_type`, 11, 1, 26, 0, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, 'Agatha - In Combat LOS (player with quest 27099) - Set Event Phase 2 (same trigger as id 0 when she is stuck in combat, to-do 446)'
FROM `smart_scripts` WHERE `entryorguid` = 44951 AND `source_type` = 0 AND `id` = 0;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 22 AND `SourceGroup` = 12 AND `SourceEntry` = 44951;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(22, 12, 44951, 0, 0, 9, 0, 27099, 0, 0, 0, 0, 0, '', 'Agatha IC_LOS No Escape trigger only for players on quest 27099 (to-do 446)');
