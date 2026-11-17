-- To-do 304 (Deadmines bot groups stall): two patrols in the Deadmines (map 36) have waypoints far outside the instance.
-- Oaf Lackey 319251 (path 319251): all 4 points at x 1813-1823, y 213-219 = coordinates of another map; it walks out of the
-- dungeon and the bot leader that picks the nearest mob chases it east until it is stuck where no spawn is reachable
-- (BotLife "stalled", ~20 kills, 0 bosses). The other Oaf Lackeys in the reference stand still.
-- Mining Monkey 319249 (path 319249): points 1-4 are a 3-yard shuffle at its spawn, points 5-6 jump to 1773,256 (same artefact in
-- the reference sniff data, ref_cpp path 3760540 points 5-6). Keep the shuffle, drop the two bad points.
-- Source: world.waypoint_data 319249/319251; ref_cpp creature 375867/375934/375998 (Oaf Lackey, MovementType 0) and path 3760540;
--   BotLife.log 08-11 05:30 (leader stuck at 196,-459 after chasing the Lackey), state/fix304_deadmines_stalls_20261110.md.
-- Rollback: UPDATE `creature` SET `MovementType`=2 WHERE `guid`=319251; INSERT the creature_addon row (319251, path_id 319251) and the
--   waypoint_data rows 319251 (4) and 319249 points 5-6 back from the backup dump ~/backups/pre_2026_11_10_05.sql.
UPDATE `creature` SET `MovementType`=0, `wander_distance`=0 WHERE `guid`=319251;
UPDATE `creature_addon` SET `path_id`=0 WHERE `guid`=319251;
DELETE FROM `waypoint_data` WHERE `id`=319251;
DELETE FROM `waypoint_data` WHERE `id`=319249 AND `point` IN (5,6);
