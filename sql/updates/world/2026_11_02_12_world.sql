-- 480 Whirling Vortex (34322): circle 4 laps. Flying creatures ignore SAI Set Run 0 (MoveSplineInit.cpp:36-42, flight rate 1.0 x speed_run 3 = 21 yd/s), so after _11 the 3-lap-less circle took ~16 s and the spell window (Sky Lightning 65231 / Vortex Vengeance 65216, range 100 yd, ~34 s) only dealt ~3300 of Lord Magmathar's 6510 HP. 4 laps give ~95 s window / ~8400 dmg. Source: client 5.4.8 DBC (Spell/SpellRange/SpellCooldowns), Creature.cpp:432, Unit.cpp:12439, state/client_test_408_468_20261102.md Poging 5
-- Rollback: DELETE FROM `waypoints` WHERE `entry` = 34322 AND `pointid` BETWEEN 16 AND 42; INSERT INTO `waypoints` (`entry`,`pointid`,`position_x`,`position_y`,`position_z`,`point_comment`) VALUES (34322,16,3099.62,-1034.36,544.151,'Whirling Vortex'),(34322,17,3011.31,-1046.85,435.522,'Whirling Vortex'),(34322,18,2837.34,-1102.63,313.604,'Whirling Vortex'),(34322,19,2672.86,-1172.51,219.757,'Whirling Vortex'),(34322,20,2563,-1267.04,164.266,'Whirling Vortex'),(34322,21,2502.28,-1304.61,140.949,'Whirling Vortex'); UPDATE `smart_scripts` SET `event_param1` = 15 WHERE `entryorguid` = 34322 AND `source_type` = 0 AND `id` = 3; UPDATE `smart_scripts` SET `event_param1` = 21 WHERE `entryorguid` = 34322 AND `source_type` = 0 AND `id` = 4;
DELETE FROM `world`.`waypoints` WHERE `entry` = 34322 AND `pointid` >= 16;
INSERT INTO `world`.`waypoints` (`entry`,`pointid`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`point_comment`)
SELECT 34322, w.`pointid` + 7 * n.`k`, w.`position_x`, w.`position_y`, w.`position_z`, w.`orientation`, w.`delay`, w.`point_comment`
FROM `world`.`waypoints` w, (SELECT 1 AS `k` UNION SELECT 2 UNION SELECT 3) n
WHERE w.`entry` = 34322 AND w.`pointid` BETWEEN 9 AND 15;
INSERT INTO `world`.`waypoints` (`entry`,`pointid`,`position_x`,`position_y`,`position_z`,`point_comment`) VALUES
(34322,37,3099.62,-1034.36,544.151,'Whirling Vortex'),
(34322,38,3011.31,-1046.85,435.522,'Whirling Vortex'),
(34322,39,2837.34,-1102.63,313.604,'Whirling Vortex'),
(34322,40,2672.86,-1172.51,219.757,'Whirling Vortex'),
(34322,41,2563,-1267.04,164.266,'Whirling Vortex'),
(34322,42,2502.28,-1304.61,140.949,'Whirling Vortex');
UPDATE `world`.`smart_scripts` SET `event_param1` = 36 WHERE `entryorguid` = 34322 AND `source_type` = 0 AND `id` = 3;
UPDATE `world`.`smart_scripts` SET `event_param1` = 42 WHERE `entryorguid` = 34322 AND `source_type` = 0 AND `id` = 4;
