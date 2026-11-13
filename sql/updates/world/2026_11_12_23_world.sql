-- To-do 468 (quest 13947 Blastranaar!), follow-up to 2026_11_12_22 after the third own-client test on dev: (1) on the first pass the wind rider
-- flies through a red/orange roof (map 34.2/48.4) and at map 35.9/46.4 a dark crown plane sits right behind it, (2) 10 Astranaar Throwers cannot be
-- destroyed in one flight.
-- (1) Map to world (WorldMapArea 331: left 1700, right -4066.67, top 4672.92, bottom 829.17; x = top - 0.484 * 3843.75 and y = left - 0.342 * 5766.67):
--   34.2/48.4 is world 2812 -272, which is on the first pass segment (2828.6 -254.1) -> (2814.1 -270.0) -> (2799.7 -285.8) at z 130. There stand
--   the Watch Wind Rider (34160) at z 140, two Astranaar's Burning fire bunnies at z 130-133 and an Astranaar Smoke object at z 134 (2800-2814, -264..-277):
--   a building with a roof at about z 130-140 on the line. Further elevated spawns: z 136 at 2775 -285, z 153-154 at 2830-2840 -285..-289. The two points are moved
--   to the open strip north-west of the building (nothing is spawned there; at least 11 yd from the building spawns and from the z 136 object):
--   2814.1 -270.0 -> 2808.0 -250.0, 2799.7 -285.8 -> 2788.0 -258.0 (z unchanged, all repeats of these points in path 3443302).
--   35.9/46.4 is world 2889 -370, 17 yd from the approach path between 3443301/3 (2920 -400, z 185) and 3443301/4 (2875 -300, z 150), where the
--   path was at about z 175, in the crown layer; the ground there is z 107 and no elevated spawn stands within 40 yd. Those two points go to z 172 and z 135 so
--   the descent starts earlier (the cliff edge of Hellscream's Watch, plateau z 199-216, lies before the first of them). Crown heights are not in the
--   world data, so this part is an estimate.
-- (2) There are 8 Throwers (34492, respawn 60 s) and the quest wants 10. With 4 passes in 71 s a Thrower can only be destroyed twice if he is hit at the
--   very start and again after at least 61.5 s (1.5 s delayed death plus 60 s respawn), which works for at most 3 of the 8 and needs exact timing. On
--   retail the flight has no fixed end: a player comment says 'You will fly back and forth across Astranaar until you have managed to destroy enough
--   vehicles and people', key 3 (Return to Base) ends the flight. So the passes now repeat until key 3 is pressed (path repeat flag of the 'Start laps'
--   script), the wind rider no longer returns by itself after the 4th pass (the 'path ended' handlers 10/11 are removed) and, so a forgotten ride does
--   not last forever, it returns by itself after 300 s (our choice, no source).
-- Source: map/DBC conversion and spawn positions in the world data, quest 13947 comments on Wowhead (flight back and forth until done, key 3 returns), own-client
--   tests on dev. Positions, z values and the 300 s are derived, no sniff.
-- Rollback: UPDATE `waypoints` SET `position_x` = 2814.1, `position_y` = -270.0 WHERE `entry` = 3443302 AND ABS(`position_x` - 2808.0) < 0.1 AND ABS(`position_y` + 250.0) < 0.1;
--   UPDATE `waypoints` SET `position_x` = 2799.7, `position_y` = -285.8 WHERE `entry` = 3443302 AND ABS(`position_x` - 2788.0) < 0.1 AND ABS(`position_y` + 258.0) < 0.1;
--   UPDATE `waypoints` SET `position_z` = 185 WHERE `entry` = 3443301 AND `pointid` = 3 AND `position_z` = 172; UPDATE `waypoints` SET `position_z` = 150 WHERE `entry` = 3443301 AND `pointid` = 4 AND `position_z` = 135;
--   UPDATE `smart_scripts` SET `action_param3` = 0 WHERE `entryorguid` = 3443401 AND `source_type` = 9 AND `id` = 2; DELETE FROM `smart_scripts` WHERE `entryorguid` = 3443401 AND `source_type` = 9 AND `id` = 3;
--   DELETE FROM `smart_scripts` WHERE `entryorguid` = 34433 AND `source_type` = 0 AND `id` IN (15,16); then re-insert ids 10 and 11 of 34433:
--   (34433,0,10,11,58,1,100,0,0,3443302,0,0,0,22,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Path 3443302 Ended - Set Event Phase 2 (returning)') and
--   (34433,0,11,0,61,0,100,0,0,0,0,0,0,80,3443402,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Path 3443302 Ended - Run Script Return to base').

UPDATE `waypoints` SET `position_x` = 2808.0, `position_y` = -250.0 WHERE `entry` = 3443302 AND ABS(`position_x` - 2814.1) < 0.1 AND ABS(`position_y` + 270.0) < 0.1;
UPDATE `waypoints` SET `position_x` = 2788.0, `position_y` = -258.0 WHERE `entry` = 3443302 AND ABS(`position_x` - 2799.7) < 0.1 AND ABS(`position_y` + 285.8) < 0.1;
UPDATE `waypoints` SET `position_z` = 172 WHERE `entry` = 3443301 AND `pointid` = 3 AND `position_z` = 185;
UPDATE `waypoints` SET `position_z` = 135 WHERE `entry` = 3443301 AND `pointid` = 4 AND `position_z` = 150;

UPDATE `smart_scripts` SET `action_param3` = 1 WHERE `entryorguid` = 3443401 AND `source_type` = 9 AND `id` = 2 AND `action_type` = 53;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 3443401 AND `source_type` = 9 AND `id` = 3;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 34433 AND `source_type` = 0 AND `id` IN (10,11,15,16);
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(3443401,9,3,0,0,0,100,0,100,100,0,0,0,67,2,300000,300000,0,0,100,1,0,0,0,0,0,0,0,0,'Start laps - Create Timed Event 2 (300 s: the passes repeat until Return to Base, this returns a forgotten ride)'),
(34433,0,15,16,59,1,100,0,2,0,0,0,0,22,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Timed Event 2 (300 s of passes) - Set Event Phase 2 (returning)'),
(34433,0,16,0,61,0,100,0,0,0,0,0,0,80,3443402,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Timed Event 2 - Run Script ''Return to base''');
