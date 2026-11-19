-- Dire Maul (map 429): three bosses stand away from the position both reference databases give.
-- What a player sees today: Illyanna Ravenoak (West, 11488) stands about 90 yards from where she belongs, Magister Kalendris
--   (West, 11487) about 16 yards and Lethtendris (East, 14327) about 12 yards, so players meet them in the wrong place or
--   miss them on their usual route.
-- Cause: the positions come from an older database; the Cataclysm Preservation sniff database (ref_cpp) and the second
--   reference (ref_sf) hold the same spawn for all three.
-- Checked: each boss has one spawn in world and in both references; ref_cpp and ref_sf agree to the last digit. The three
--   spawns have no waypoint, formation, linked respawn, pool, game event or smart script by guid (creature_addon only holds
--   stand state 8 for Kalendris, which stays); the smart scripts per entry summon nothing and use no fixed coordinates; the
--   scripts in Kalimdor/DireMaul reference none of the three. Left out on purpose: Hydrospawn (13280, 22 yd) and Alzzin the
--   Wildshaper (11492, 40 yd) both walk a waypoint path (guid 323165 / 323216) that starts at the old spot.
-- Change: the three spawns are moved to the reference position and orientation; spawn mask and respawn time stay.
-- Source: Cataclysm Preservation sniff database (ref_cpp guids 84381, 56802, 56805) and ref_sf (same guids), 18-11-2026.
-- Rollback (the values before this update; only SQL lines below):
--   UPDATE `creature` SET `position_x`=-100.348,`position_y`=526.156,`position_z`=28.6149,`orientation`=3.9802 WHERE `guid`=323250 AND `id`=11488;
--   UPDATE `creature` SET `position_x`=27.1106,`position_y`=571.258,`position_z`=-4.30945,`orientation`=4.53786 WHERE `guid`=323252 AND `id`=11487;
--   UPDATE `creature` SET `position_x`=1.83788,`position_y`=-445.35,`position_z`=16.4108,`orientation`=5.75797 WHERE `guid`=323447 AND `id`=14327;

UPDATE `creature` SET `position_x`=-11.46,`position_y`=542.11,`position_z`=28.78,`orientation`=3.11 WHERE `guid`=323250 AND `id`=11488;  -- Illyanna Ravenoak (11488), 90.3 yd
UPDATE `creature` SET `position_x`=13.4018,`position_y`=578.911,`position_z`=-3.56219,`orientation`=4.71533 WHERE `guid`=323252 AND `id`=11487;  -- Magister Kalendris (11487), 15.7 yd
UPDATE `creature` SET `position_x`=4.58,`position_y`=-456.84,`position_z`=16.58,`orientation`=3.17 WHERE `guid`=323447 AND `id`=14327;  -- Lethtendris (14327), 11.8 yd
