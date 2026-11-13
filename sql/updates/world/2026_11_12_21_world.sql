-- To-do 468 (quest 13947 Blastranaar!), follow-up to 2026_11_12_20 after the own-client test on dev: (1) the approach to the bridge is flown at
-- about 25 yd/s and the wind rider flies about 25 yd/s on the passes and on the return, so the rates set by 2026_11_12_20 had no effect,
-- (2) the return takes about 12 s instead of about 20 s, (3) over the middle of Astranaar the camera sits inside the tree crowns.
-- Cause (1)/(2): the rate was set for MOVE_FLIGHT only. The wind rider moves on its waypoints with the run speed of the template (speed_run 4.0 *
--   7 = 28 yd/s; the measured 24-26 yd/s on approach, passes and return are this speed within the measuring error), so Unit::SetSpeed(MOVE_FLIGHT)
--   did not change the spline velocity. The two scripts now set the run rate AND the flight rate, so whichever speed type the spline takes is
--   slowed. The approach (before the bridge) is not touched and keeps its speed: the reporter found it right. The passes start only when script
--   3443401 runs, after the approach path has ended at the bridge (waypoint 3443301/5, 2828.6 -254.1), so no extra waypoint event is needed.
--   Passes: rate 3.14 (22 yd/s): 1486 yd in about 67 s. Return: rate 2.62 (18.3 yd/s): the 366 yd from the end of the passes in about 20 s.
-- Cause (3): the passes were flown at z 155 (U-turns 160) over ground at about 107, spawns and objects in the town reach z 142-167, and the camera
--   hangs behind and above the rider. No tree-height data is available on the server; the passes are raised by 20 yd (z 175, U-turns 180) and the
--   last approach point (same x/y as the first pass point) to 175. Reach check of the bomb (Throw Explosive, range 100 yd, 3D): of the 67
--   Sentinel/Thrower spawns (z 107-121) every one except one Thrower, which was already out of reach before (102 yd), stays within 100 yd
--   of the raised path; that Thrower is then 113 yd away. The target (a ground circle) is chosen by the player, so reach is the limit.
-- Source: own-client measurements on dev (approach about 14 s including the 1.5 s take-off, passes about 58 s, return about 12 s for 302 yd);
--   quest videos for the pass and return durations (about 65-70 s over the village, about 20 s back); creature and gameobject positions in the town.
--   The rates and the 20 yd are derived, no sniff.
-- Rollback: UPDATE `waypoints` SET `position_z` = 155 WHERE `entry` = 3443302 AND `position_z` = 175;
--   UPDATE `waypoints` SET `position_z` = 160 WHERE `entry` = 3443302 AND `position_z` = 180;
--   UPDATE `waypoints` SET `position_z` = 150 WHERE `entry` = 3443301 AND `pointid` = 5 AND `position_z` = 175;
--   DELETE FROM `smart_scripts` WHERE `entryorguid` IN (3443401,3443402) AND `source_type` = 9;
--   then re-insert the rows of 2026_11_12_20 for these two scripts (action 209 with param1 6 only, then the path start).

UPDATE `waypoints` SET `position_z` = 180 WHERE `entry` = 3443302 AND `position_z` = 160;
UPDATE `waypoints` SET `position_z` = 175 WHERE `entry` = 3443302 AND `position_z` = 155;
UPDATE `waypoints` SET `position_z` = 175 WHERE `entry` = 3443301 AND `pointid` = 5 AND `position_z` = 150;

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (3443401,3443402) AND `source_type` = 9;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(3443401,9,0,0,0,0,100,0,100,100,0,0,0,209,1,314,0,0,0,0,1,0,0,0,0,0,0,0,0,'Start laps - run speed rate 3.14 (about 22 yd/s) over Astranaar'),
(3443401,9,1,0,0,0,100,0,100,100,0,0,0,209,6,314,0,0,0,0,1,0,0,0,0,0,0,0,0,'Start laps - flight speed rate 3.14 (about 22 yd/s) over Astranaar'),
(3443401,9,2,0,0,0,100,0,100,100,0,0,0,53,1,3443302,0,0,0,0,1,0,0,0,0,0,0,0,0,'Start laps - start path 3443302 (4 passes over the main road, no repeat, passive)'),
(3443402,9,0,0,0,0,100,0,100,100,0,0,0,209,1,262,0,0,0,0,1,0,0,0,0,0,0,0,0,'Return to base - run speed rate 2.62 (about 18 yd/s, about 20 s for 366 yd)'),
(3443402,9,1,0,0,0,100,0,100,100,0,0,0,209,6,262,0,0,0,0,1,0,0,0,0,0,0,0,0,'Return to base - flight speed rate 2.62 (about 18 yd/s, about 20 s for 366 yd)'),
(3443402,9,2,0,0,0,100,0,100,100,0,0,0,53,1,3443303,0,0,0,0,1,0,0,0,0,0,0,0,0,'Return to base - start path 3443303 (back to Thraka, no repeat, passive)');
