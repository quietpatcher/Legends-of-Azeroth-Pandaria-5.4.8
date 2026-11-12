-- 431/432 (Tirisfal block): Horde Coffin Hauler guid 188122 drives the northern leg of its Silverpine road, 4 Dreadguards escort it.
-- Source: Wowhead MoP Classic npc=44764 (28 pins along the road 1527,611 .. 1392,796 + comment 'Horde Hauler goes North to South, the Coffin Hauler South to North'),
--   wowpedia/mmo-champion ('wagon travels the whole way, makes periodic stops'); Wowhead npc=44911 pins on that same road line (1437,695 / 1437,703);
--   ref_cpp: haulers 326733/326091 sniffed at fixed points of the same road (no path in ref, creature_addon waypointPathId 0), 4 Dreadguards 186850-53 stand
--   on the road line with identical orientation and an exact 3.9 yd step = a sniffed escort column, not camp spawns. Z from terrain (terrain_z.py).
-- Rollback: ~/backup/tirisfal_pre_20261104.sql (DELETE FROM waypoint_data WHERE id=188122; DELETE FROM creature_formations WHERE leaderGUID=188122;
--   UPDATE creature_addon SET path_id=0 WHERE guid=188122; UPDATE creature SET MovementType=0, position_x=1459.9, position_y=647.9, position_z=47.4 WHERE guid=188122; restore the 4 Dreadguard rows from the dump)
DELETE FROM waypoint_data WHERE id=188122;
INSERT INTO waypoint_data (id,point,position_x,position_y,position_z,orientation,delay,move_flag,action,action_chance,wpguid,entry) VALUES
(188122,1,1527.0,611.0,47.10,0,20000,0,0,100,0,NULL),
(188122,2,1513.0,621.5,47.16,0,0,0,0,100,0,NULL),
(188122,3,1499.0,632.0,46.69,0,0,0,0,100,0,NULL),
(188122,4,1485.0,642.5,46.52,0,0,0,0,100,0,NULL),
(188122,5,1471.0,653.0,46.58,0,0,0,0,100,0,NULL),
(188122,6,1454.0,661.0,46.86,0,0,0,0,100,0,NULL),
(188122,7,1444.4,677.9,47.13,0,0,0,0,100,0,NULL),
(188122,8,1434.9,694.7,47.13,0,0,0,0,100,0,NULL),
(188122,9,1425.3,711.6,47.13,0,0,0,0,100,0,NULL),
(188122,10,1415.7,728.4,47.13,0,0,0,0,100,0,NULL),
(188122,11,1406.1,745.3,47.13,0,0,0,0,100,0,NULL),
(188122,12,1396.6,762.1,47.13,0,0,0,0,100,0,NULL),
(188122,13,1387.0,779.0,47.13,0,0,0,0,100,0,NULL),
(188122,14,1392.0,796.0,47.13,0,20000,0,0,100,0,NULL),
(188122,15,1387.0,779.0,47.13,0,0,0,0,100,0,NULL),
(188122,16,1396.6,762.1,47.13,0,0,0,0,100,0,NULL),
(188122,17,1406.1,745.3,47.13,0,0,0,0,100,0,NULL),
(188122,18,1415.7,728.4,47.13,0,0,0,0,100,0,NULL),
(188122,19,1425.3,711.6,47.13,0,0,0,0,100,0,NULL),
(188122,20,1434.9,694.7,47.13,0,0,0,0,100,0,NULL),
(188122,21,1444.4,677.9,47.13,0,0,0,0,100,0,NULL),
(188122,22,1454.0,661.0,46.86,0,0,0,0,100,0,NULL),
(188122,23,1471.0,653.0,46.58,0,0,0,0,100,0,NULL),
(188122,24,1485.0,642.5,46.52,0,0,0,0,100,0,NULL),
(188122,25,1499.0,632.0,46.69,0,0,0,0,100,0,NULL),
(188122,26,1513.0,621.5,47.16,0,0,0,0,100,0,NULL);
UPDATE creature_addon SET path_id=188122 WHERE guid=188122;
UPDATE creature SET MovementType=2, position_x=1471.0, position_y=653.0, position_z=46.58 WHERE guid=188122;
DELETE FROM creature_formations WHERE leaderGUID=188122;
INSERT INTO creature_formations (leaderGUID,memberGUID,dist,angle,groupAI,point_1,point_2) VALUES
(188122,188122,0,0,515,0,0),(188122,186850,5,180,515,0,0),(188122,186851,9,180,515,0,0),(188122,186852,13,180,515,0,0),(188122,186853,17,180,515,0,0);
