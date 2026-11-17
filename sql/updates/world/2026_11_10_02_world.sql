-- To-do 432: the four Dreadguards (44911, guids 186850-186853) on the Tirisfal/Silverpine road stand still in an evenly spaced column.
-- 2026_11_04_92 made them a formation behind the Horde Coffin Hauler 188122 on its road path. The Silverpine wagon port
-- (2026_11_06_11) then removed every static wagon spawn on purpose (the wagons are now summoned per line by a bunny and drive
-- north into Tirisfal without stopping), which also removed 188122. Since then the formation has no leader and the guards are frozen.
-- Spawning 188122 again would put a second, looping Coffin Hauler next to the summoned line, so the column walks the road by itself:
-- the front guard (186850) leads on the same road route, the other three follow in its sniffed 3.9 yd steps.
-- Source: the column itself (identical orientation 2.22 = facing down the road, exact 3.9 yd step = a moving escort captured mid-walk);
--   road points = path 188122 from 2026_11_04_92 (Wowhead npc 44764 pins, terrain z); Wowhead npc 44911 pins on the same road line.
-- Rollback: DELETE FROM `creature_formations` WHERE `leaderGUID`=186850; DELETE FROM `creature_addon` WHERE `guid`=186850;
--   DELETE FROM `waypoint_data` WHERE `id`=1868500; UPDATE `creature` SET `MovementType`=0 WHERE `guid`=186850;
--   and re-run the formation/waypoint part of 2026_11_04_92 (leader 188122, path 188122).
DELETE FROM `creature_formations` WHERE `leaderGUID` IN (188122, 186850) OR `memberGUID` IN (186850, 186851, 186852, 186853, 188122);
INSERT INTO `creature_formations` (`leaderGUID`,`memberGUID`,`dist`,`angle`,`groupAI`,`point_1`,`point_2`) VALUES
(186850,186850,0,0,515,0,0),
(186850,186851,3.9,180,515,0,0),
(186850,186852,7.8,180,515,0,0),
(186850,186853,11.7,180,515,0,0);

-- the old path of the removed hauler is no longer used by anything
DELETE FROM `waypoint_data` WHERE `id` IN (188122, 1868500);
INSERT INTO `waypoint_data` (`id`,`point`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`move_flag`,`action`,`action_chance`,`wpguid`,`entry`) VALUES
(1868500,1,1425.3,711.6,47.13,0,0,0,0,100,0,0),
(1868500,2,1415.7,728.4,47.13,0,0,0,0,100,0,0),
(1868500,3,1406.1,745.3,47.13,0,0,0,0,100,0,0),
(1868500,4,1396.6,762.1,47.13,0,0,0,0,100,0,0),
(1868500,5,1387,779,47.13,0,0,0,0,100,0,0),
(1868500,6,1392,796,47.13,0,20000,0,0,100,0,0),
(1868500,7,1387,779,47.13,0,0,0,0,100,0,0),
(1868500,8,1396.6,762.1,47.13,0,0,0,0,100,0,0),
(1868500,9,1406.1,745.3,47.13,0,0,0,0,100,0,0),
(1868500,10,1415.7,728.4,47.13,0,0,0,0,100,0,0),
(1868500,11,1425.3,711.6,47.13,0,0,0,0,100,0,0),
(1868500,12,1434.9,694.7,47.13,0,0,0,0,100,0,0),
(1868500,13,1444.4,677.9,47.13,0,0,0,0,100,0,0),
(1868500,14,1454,661,46.86,0,0,0,0,100,0,0),
(1868500,15,1471,653,46.58,0,0,0,0,100,0,0),
(1868500,16,1485,642.5,46.52,0,0,0,0,100,0,0),
(1868500,17,1499,632,46.69,0,0,0,0,100,0,0),
(1868500,18,1513,621.5,47.16,0,0,0,0,100,0,0),
(1868500,19,1527,611,47.1,0,20000,0,0,100,0,0),
(1868500,20,1513,621.5,47.16,0,0,0,0,100,0,0),
(1868500,21,1499,632,46.69,0,0,0,0,100,0,0),
(1868500,22,1485,642.5,46.52,0,0,0,0,100,0,0),
(1868500,23,1471,653,46.58,0,0,0,0,100,0,0),
(1868500,24,1454,661,46.86,0,0,0,0,100,0,0),
(1868500,25,1444.4,677.9,47.13,0,0,0,0,100,0,0),
(1868500,26,1434.9,694.7,47.13,0,0,0,0,100,0,0);

DELETE FROM `creature_addon` WHERE `guid` = 186850;
INSERT INTO `creature_addon` (`guid`,`path_id`) VALUES (186850,1868500);
UPDATE `creature` SET `MovementType`=2 WHERE `guid`=186850;
