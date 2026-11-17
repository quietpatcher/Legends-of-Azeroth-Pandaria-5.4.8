-- To-do 468 (quest 13947 Blastranaar!, Ashenvale): own-client flight test 08-11 on dev: over Astranaar the Furious Wind Rider flew its
-- circle at a flat z 135, 27-37 yd above the ground (GroundZ 98-109), so the camera went through tree crowns and roofs on every lap;
-- on the way back it passed (2997,-474) at z 198.75 with the ground at 198.63 and the rider died there instead of landing at Thraka.
-- The route is our own (derived, no sniff), so it is raised with margin: circle 135 -> 160, approach points 4/5 148/135 -> 165/160,
-- return points 1-3 170/200/212 -> 185/225/220 (landing point 4 at Thraka unchanged). Bombed Sentinels (34494) and Throwers (34492)
-- now die after the kill credit, as the objectives say ("slain", "destroyed").
-- Source: own-client test state/devtest_dev97j_20261105.md 'Quest 13947 Blastranaar flight test (08-11)' (.gps GroundZ values),
-- an internal proposal (heights raised further than proposed); quest objectives 13947.
-- Rollback: UPDATE waypoints SET position_z = 135 WHERE entry = 3443302;
-- UPDATE waypoints SET position_z = 148 WHERE entry = 3443301 AND pointid = 4; UPDATE waypoints SET position_z = 135 WHERE entry = 3443301 AND pointid = 5;
-- UPDATE waypoints SET position_z = 170 WHERE entry = 3443303 AND pointid = 1; UPDATE waypoints SET position_z = 200 WHERE entry = 3443303 AND pointid = 2;
-- UPDATE waypoints SET position_z = 212 WHERE entry = 3443303 AND pointid = 3;
-- DELETE FROM smart_scripts WHERE entryorguid IN (34494, 34492) AND source_type = 0 AND id = 2;
-- UPDATE smart_scripts SET link = 0 WHERE entryorguid IN (34494, 34492) AND source_type = 0 AND id = 1;
UPDATE `waypoints` SET `position_z` = 160 WHERE `entry` = 3443302;
UPDATE `waypoints` SET `position_z` = 165 WHERE `entry` = 3443301 AND `pointid` = 4;
UPDATE `waypoints` SET `position_z` = 160 WHERE `entry` = 3443301 AND `pointid` = 5;
UPDATE `waypoints` SET `position_z` = 185 WHERE `entry` = 3443303 AND `pointid` = 1;
UPDATE `waypoints` SET `position_z` = 225 WHERE `entry` = 3443303 AND `pointid` = 2;
UPDATE `waypoints` SET `position_z` = 220 WHERE `entry` = 3443303 AND `pointid` = 3;
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (34494, 34492) AND `source_type` = 0 AND `id` = 2;
UPDATE `smart_scripts` SET `link` = 2 WHERE `entryorguid` IN (34494, 34492) AND `source_type` = 0 AND `id` = 1;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(34494, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Astranaar Sentinel - On bomb impact - Die'),
(34492, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Astranaar Thrower - On bomb impact - Die');
