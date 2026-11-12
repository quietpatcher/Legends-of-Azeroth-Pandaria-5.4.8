-- Arathi Highlands: the Forsaken Courier (2714) patrols alone south of Go'Shek Farm
-- The Cataclysm Classic TDB 4.4.2 and the retail TDB 1210 have one Forsaken Courier (their 285848, mop's 161449) on a
-- 10-node walking path (22867840) on the trail south of Go'Shek Farm, and no Forsaken Bodyguards (2721) anywhere.
-- Wowhead comments on Just Like Old Times (26110) agree: "Pats back and forth on the trail south of the farm",
-- "no adds anymore" (the bodyguards went in patch 2.3), spawn at 53.51 64.85 = mop's 161449.
-- mop also had the pre-Cataclysm courier 11304 standing with four Bodyguards at the farmhouse; nothing references them.
-- Remove those five, give 161449 the TDB path and its 120 s respawn. Ours: the path id 1612980.
-- Reconcile 2026-11-11 (l1/R1111-reconcile): upstream kept guid 161449 and removed 161298 (in 2026_11_10_12); our closed fix 253 (to-do 343,
-- repeat check 343: one courier near the spot) had done the opposite, so applied as written no courier was left. The courier that stays
-- is ours, 161298 (10 yd from 161449's spot), and it gets the sniffed path: guid 161449 -> 161298, path id -> 1612980, start on node 1.
-- This changes fix 253's "stands mostly still" to the patrol: the path is sniffed (TDB 4.4.2 and 1210, path 22867840) and the players'
-- comments name it, while ours was SkyFire data without a path; fix 253's goal (one courier, at this spot) holds, all ten nodes lie in the
-- check's box. The respawn stays at our 300 s (upstream 120). The farmhouse courier 11304 and its four Bodyguards go as upstream says.
-- Rollback: UPDATE creature SET position_x=-1643.65, position_y=-2961.22, position_z=27.6476, orientation=4.44416, MovementType=1,
--   wander_distance=3 WHERE guid=161298; DELETE FROM creature_addon WHERE guid=161298; DELETE FROM waypoint_data WHERE id=1612980;
--   11304 and the Bodyguards 11431, 12959, 12967, 60905 from the pre-L1 dump of creature.
DELETE FROM `creature` WHERE `guid`=11304 AND `id`=2714;
DELETE FROM `creature` WHERE `guid` IN (11431,12959,12967,60905) AND `id`=2721;
DELETE FROM `creature_addon` WHERE `guid` IN (11304,11431,12959,12967,60905);
DELETE FROM `game_event_creature` WHERE `guid` IN (11304,11431,12959,12967,60905);
DELETE FROM `waypoint_data` WHERE `id`=1612980;
INSERT INTO `waypoint_data` (`id`,`point`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`move_flag`,`action`,`action_chance`,`wpguid`) VALUES
(1612980,1,-1644.77,-2970.93,26.889,0,0,0,0,100,0),
(1612980,2,-1643.69,-2961.7,27.8141,0,0,0,0,100,0),
(1612980,3,-1640.91,-2951.57,28.433,0,0,0,0,100,0),
(1612980,4,-1639.89,-2948.18,28.7621,0,0,0,0,100,0),
(1612980,5,-1640.86,-2917.59,27.2608,0,0,0,0,100,0),
(1612980,6,-1641.81,-2914.43,26.8585,0,0,0,0,100,0),
(1612980,7,-1641.82,-2914.76,26.7874,0,0,0,0,100,0),
(1612980,8,-1639.27,-2923.27,27.669,0,0,0,0,100,0),
(1612980,9,-1637.15,-2931.19,28.2743,0,0,0,0,100,0),
(1612980,10,-1642.04,-2956,28.0418,0,0,0,0,100,0);
DELETE FROM `creature_addon` WHERE `guid`=161298;
INSERT INTO `creature_addon` (`guid`,`path_id`) VALUES (161298,1612980);
UPDATE `creature` SET `position_x`=-1644.77, `position_y`=-2970.93, `position_z`=26.889, `orientation`=4.98914, `MovementType`=2, `wander_distance`=0, `currentwaypoint`=0 WHERE `guid`=161298 AND `id`=2714;
