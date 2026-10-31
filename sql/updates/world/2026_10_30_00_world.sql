-- Silverpine Forest, quest 27099 "No Escape" (to-do 446): simplified: retail scene missing without sniff.
-- Retail: a scene in the upper hall of Fenris Keep (Crowley / Ivar Bloodfang / Maleb talk, the refugee leaders drink worgen blood and
-- transform), then Agatha grabs the player and flies them out of the keep. We have no sniff of that scene (no scene spawns/script), so this is
-- the reduced version: Agatha (44951, spawn 375615, upper hall z 76) gives the kill credit "Human Leaders found" to a player who has the quest and
-- comes within 12 yd, says "Run...!", takes the player on board (Ride Vehicle Hardcoded 46598), says "RUN!", flies them out of the keep and
-- drops them on the isle east of the keep (next to the Hillsbrad Refugee at 1052.18 692.916 53.4623), then despawns (respawn 30 s).
-- Missing without sniff: Crowley/Ivar/Maleb actors and dialogue, the worgen transformation, the worgen attacking Agatha, the exact flight path.
-- Texts: Wowpedia / WoWWiki "No Escape" (Agatha: "Run...!", "RUN!"); broadcast_text 45185 = "RUN!" (female).
--
-- Rollback:
--   DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 44951;
--   DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 22 AND `SourceEntry` = 44951 AND `SourceId` = 0;
--   DELETE FROM `waypoints` WHERE `entry` = 4495100;
--   DELETE FROM `creature_text` WHERE `CreatureID` = 44951;
--   UPDATE `creature_template` SET `AIName` = '' WHERE `entry` = 44951;
--   UPDATE `creature` SET `spawntimesecs` = 120 WHERE `guid` = 375615 AND `id` = 44951;
-- (a table dump from before the change: ~/backups/446/)

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 44951;
UPDATE `creature` SET `spawntimesecs` = 30 WHERE `guid` = 375615 AND `id` = 44951;

DELETE FROM `creature_text` WHERE `CreatureID` = 44951;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(44951, 0, 0, 'Run...!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Agatha - No Escape (27099), simplified: retail scene missing without sniff'),
(44951, 1, 0, 'RUN!',    12, 0, 100, 0, 0, 0, 0, 45185, 0, 'Agatha - No Escape (27099), simplified: retail scene missing without sniff');

DELETE FROM `waypoints` WHERE `entry` = 4495100;
INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES
(4495100, 1, 1020.0,  691.5,  90.0, NULL, 0, 'Agatha - No Escape, simplified: up out of the upper hall (invented path, no sniff)'),
(4495100, 2, 1046.0,  693.0,  72.0, NULL, 0, 'Agatha - No Escape, simplified: out over the courtyard'),
(4495100, 3, 1052.18, 692.916, 55.4623, NULL, 0, 'Agatha - No Escape, simplified: 2 yd above the ground at the Hillsbrad Refugee spawn, passenger is dropped here');

DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 44951;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
-- idle (phase 1): player with quest 27099 comes within 12 yd (condition below), only one at a time
(44951, 0, 0, 1, 10, 1, 100, 0, 1, 12, 5000, 5000, 1, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - Out of Combat LOS (player with quest 27099) - Set Event Phase 2 (simplified: retail scene missing without sniff)'),
(44951, 0, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 33, 44951, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - Linked - Quest Credit "Human Leaders found" (44951)'),
(44951, 0, 2, 3, 61, 0, 100, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - Linked - Say Line 0 ("Run...!")'),
(44951, 0, 3, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 85, 46598, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - Linked - Invoker Cast Ride Vehicle Hardcoded on self (player boards)'),
-- phase 2: passenger on board -> shout and fly
(44951, 0, 4, 5, 27, 2, 100, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - On Passenger Boarded - Say Line 1 ("RUN!")'),
(44951, 0, 5, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 4495100, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - Linked - Start Waypoint 4495100 (run)'),
-- end of path: drop the passenger, leave
(44951, 0, 6, 7, 58, 2, 100, 0, 0, 0, 0, 0, 0, 28, 46598, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - On Waypoint Path Ended - Remove Aura Ride Vehicle Hardcoded (drops the passenger)'),
(44951, 0, 7, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 41, 3000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - Linked - Despawn in 3 s (respawn 30 s)'),
-- failsafe: nobody boarded / path stuck -> reset after 60 s in phase 2
(44951, 0, 8, 9, 1, 2, 100, 1, 60000, 60000, 0, 0, 0, 28, 46598, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - Out of Combat 60 s in phase 2 (failsafe) - Remove Aura Ride Vehicle Hardcoded'),
(44951, 0, 9, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 41, 1000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Agatha - Linked - Despawn in 1 s (failsafe)');

-- the LOS trigger (event 0 = SourceGroup 1) only fires for a player who has the quest in the log and not yet completed
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 22 AND `SourceEntry` = 44951 AND `SourceId` = 0;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(22, 1, 44951, 0, 0, 9, 0, 27099, 0, 0, 0, 0, 0, '', 'Agatha No Escape trigger only for players on quest 27099 (simplified: retail scene missing without sniff)');
