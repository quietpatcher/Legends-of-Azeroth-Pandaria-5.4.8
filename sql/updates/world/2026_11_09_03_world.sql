-- To-do 468 follow-up to 2026_11_09_01: own-client test 09-11 on dev: the bombs now reach the sentinels and throwers from the road
-- (credit counts, no 'Out of range'), but the camera still went into tree crowns in about half of the frames at z 140. The passes
-- along the main road are raised to z 155 and the U-turns to z 160 (ground ~107, so the bomb, range 100 yd, still reaches them).
-- Source: own-client test state/devtest_dev97j_20261105.md 'Clienttest 09-11 dev97w (434/436/446/468)'; DBC SpellRange 135 (65489).
-- Rollback: UPDATE waypoints SET position_z = 140 WHERE entry = 3443302 AND position_z = 155;
-- UPDATE waypoints SET position_z = 150 WHERE entry = 3443302 AND position_z = 160;
UPDATE `waypoints` SET `position_z` = 160 WHERE `entry` = 3443302 AND `position_z` = 150;
UPDATE `waypoints` SET `position_z` = 155 WHERE `entry` = 3443302 AND `position_z` = 140;
