-- Starting-zone quest givers whose spawn differs from the sniff-based references (review of 15-11-2026, verified one by one).
-- What a player sees today:
--   Elwynn Forest, Brother Paxton (quests 28806-28813, 29082) paces a 66-point loop in front of the abbey, 13.8 yards from
--     where the sniffs have him standing still.
--   Durotar, Grandmatron Tekla (quest 25189 Spirits Be Praised, which asks you to lead her out of her flooded hut to
--     Raggaran at 49 -4220): both spawns stand at 47 -4215, five yards from Raggaran, so the escort is done on accepting it.
--   Durotar, Halga Bloodeye (844, 5041, 13949), Kijara (24623, 24626) and Vek'nag (25256) pace short back-and-forth paths.
--   Dun Morogh, Ultham Ironhorn (turn-in 14083) stands 13.6 yards and Felix Whindlebolt (3361) 6.6 yards off.
--   Teldrassil, Mist (quest 938) stands 64 yards from her sniffed spawn and Priestess A'moora (2518) 7.1 yards.
-- Cause: positions and paths come from an older database; the sniff-based references have none of them.
-- Checked per NPC: no smart_scripts row uses a waypoint or a position (Halga and Kijara only have gossip/quest-accept
--   actions), no creature_formations, game_event_creature or phase_area/phase_definitions row covers these spawns, the
--   waypoint ids are used by no other spawn or template. Script npc_brother_paxton only reacts to players within 15 yards,
--   npc_watershed_patrol only gives kill credit on turn-in, npc_mist is a FollowerAI (follows the player, finishes within
--   10 yards of Arynia at 10678 1914, independent of her start position). The two Tekla spawns have no phase difference.
-- Change: move each spawn to the reference position and orientation. For Paxton, Halga, Kijara and Vek'nag also set
--   MovementType 0, clear path_id in creature_addon (other columns stay) and remove waypoint_data of that id.
-- Source: Cataclysm Preservation world database (sniffs) and SkyFire 5.4.8 world database (same coordinates, so one
--   source), checked 15-11-2026: no path and MovementType 0 for all four path NPCs and for Paxton; Tekla at 392.446
--   -4081.49 20.5023 and 562.012 -4103.38 16.8399 (area 4981), Raggaran at 49.1719 -4220.28 in both.
-- Rollback:
--   UPDATE `creature` SET `position_x`=-8823.75,`position_y`=-147.313,`position_z`=80.7947,`orientation`=2.61581,`MovementType`=2,`wander_distance`=0 WHERE `guid`=177921 AND `id`=951;
--   UPDATE `creature_addon` SET `path_id`=177921 WHERE `guid`=177921;
--   UPDATE `creature` SET `position_x`=47.2917,`position_y`=-4215.24,`position_z`=35.0482,`orientation`=5.06901 WHERE `guid`=253489 AND `id`=39325;
--   UPDATE `creature` SET `position_x`=47.2917,`position_y`=-4215.24,`position_z`=35.0482,`orientation`=5.06901 WHERE `guid`=253749 AND `id`=39325;
--   UPDATE `creature` SET `position_x`=1093.12,`position_y`=-4939.15,`position_z`=14.0696,`orientation`=4.684,`MovementType`=2,`wander_distance`=0 WHERE `guid`=250677 AND `id`=39604;
--   UPDATE `creature_addon` SET `path_id`=250677 WHERE `guid`=250677;
--   UPDATE `creature` SET `position_x`=326.227,`position_y`=-3674.45,`position_z`=27.2174,`orientation`=1.49923,`MovementType`=2,`wander_distance`=0 WHERE `guid`=262339 AND `id`=34258;
--   UPDATE `creature_addon` SET `path_id`=262339 WHERE `guid`=262339;
--   UPDATE `creature` SET `position_x`=-1549.89,`position_y`=-5314.9,`position_z`=8.03791,`orientation`=2.70617,`MovementType`=2,`wander_distance`=0 WHERE `guid`=251657 AND `id`=37969;
--   UPDATE `creature_addon` SET `path_id`=251657 WHERE `guid`=251657;
--   UPDATE `creature` SET `position_x`=-5521.92,`position_y`=-1347.17,`position_z`=398.694,`orientation`=4.03171 WHERE `guid`=169381 AND `id`=4772;
--   UPDATE `creature` SET `position_x`=-6370.85,`position_y`=570.393,`position_z`=385.806,`orientation`=4.20469 WHERE `guid`=166987 AND `id`=8416;
--   UPDATE `creature` SET `position_x`=10725.5,`position_y`=2154.09,`position_z`=1330.02,`orientation`=2.41744 WHERE `guid`=278140 AND `id`=3568;
--   UPDATE `creature` SET `position_x`=10677.6,`position_y`=1933.33,`position_z`=1336.18,`orientation`=3.28122 WHERE `guid`=276669 AND `id`=7313;
--   DELETE FROM `waypoint_data` WHERE `id`=177921;
--   INSERT INTO `waypoint_data` (`id`,`point`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`move_flag`,`action`,`action_chance`,`wpguid`,`entry`) VALUES
--   (177921,1,-8833.07,-152.085,80.349,0,0,0,0,100,0,'951'),
--   (177921,2,-8830.21,-146.632,80.5787,0,0,0,0,100,0,'951'),
--   (177921,3,-8826.04,-146.105,80.6188,0,0,0,0,100,0,'951'),
--   (177921,4,-8822.08,-146.456,80.877,0,0,0,0,100,0,'951'),
--   (177921,5,-8817.2,-150.924,81.5878,0,0,0,0,100,0,'951'),
--   (177921,6,-8813.55,-153.822,82.0283,0,8000,0,0,100,0,'951'),
--   (177921,7,-8811.99,-159.78,81.614,0,0,0,0,100,0,'951'),
--   (177921,8,-8810.78,-164.51,81.306,0,0,0,0,100,0,'951'),
--   (177921,9,-8813.96,-163.8,81.108,0,0,0,0,100,0,'951'),
--   (177921,10,-8816.21,-156.19,81.452,0,0,0,0,100,0,'951'),
--   (177921,11,-8823.21,-151.63,80.539,0,0,0,0,100,0,'951'),
--   (177921,12,-8833.07,-152.085,80.349,0,0,0,0,100,0,'951'),
--   (177921,13,-8830.21,-146.632,80.5787,0,0,0,0,100,0,'951'),
--   (177921,14,-8826.04,-146.105,80.6188,0,0,0,0,100,0,'951'),
--   (177921,15,-8822.08,-146.456,80.877,0,8000,0,0,100,0,'951'),
--   (177921,16,-8817.2,-150.924,81.5878,0,0,0,0,100,0,'951'),
--   (177921,17,-8813.55,-153.822,82.0283,0,0,0,0,100,0,'951'),
--   (177921,18,-8811.99,-159.78,81.614,0,0,0,0,100,0,'951'),
--   (177921,19,-8810.78,-164.51,81.306,0,0,0,0,100,0,'951'),
--   (177921,20,-8813.96,-163.8,81.108,0,0,0,0,100,0,'951'),
--   (177921,21,-8816.21,-156.19,81.452,0,0,0,0,100,0,'951'),
--   (177921,22,-8823.21,-151.63,80.539,0,0,0,0,100,0,'951'),
--   (177921,23,-8833.07,-152.085,80.349,0,8000,0,0,100,0,'951'),
--   (177921,24,-8830.21,-146.632,80.5787,0,0,0,0,100,0,'951'),
--   (177921,25,-8826.04,-146.105,80.6188,0,0,0,0,100,0,'951'),
--   (177921,26,-8822.08,-146.456,80.877,0,0,0,0,100,0,'951'),
--   (177921,27,-8817.2,-150.924,81.5878,0,0,0,0,100,0,'951'),
--   (177921,28,-8813.55,-153.822,82.0283,0,0,0,0,100,0,'951'),
--   (177921,29,-8811.99,-159.78,81.614,0,0,0,0,100,0,'951'),
--   (177921,30,-8810.78,-164.51,81.306,0,0,0,0,100,0,'951'),
--   (177921,31,-8813.96,-163.8,81.108,0,0,0,0,100,0,'951'),
--   (177921,32,-8816.21,-156.19,81.452,0,0,0,0,100,0,'951'),
--   (177921,33,-8823.21,-151.63,80.539,0,0,0,0,100,0,'951'),
--   (177921,34,-8833.07,-152.085,80.349,0,8000,0,0,100,0,'951'),
--   (177921,35,-8830.21,-146.632,80.5787,0,0,0,0,100,0,'951'),
--   (177921,36,-8826.04,-146.105,80.6188,0,0,0,0,100,0,'951'),
--   (177921,37,-8822.08,-146.456,80.877,0,0,0,0,100,0,'951'),
--   (177921,38,-8817.2,-150.924,81.5878,0,0,0,0,100,0,'951'),
--   (177921,39,-8813.55,-153.822,82.0283,0,0,0,0,100,0,'951'),
--   (177921,40,-8811.99,-159.78,81.614,0,0,0,0,100,0,'951'),
--   (177921,41,-8810.78,-164.51,81.306,0,8000,0,0,100,0,'951'),
--   (177921,42,-8813.96,-163.8,81.108,0,0,0,0,100,0,'951'),
--   (177921,43,-8816.21,-156.19,81.452,0,0,0,0,100,0,'951'),
--   (177921,44,-8823.21,-151.63,80.539,0,0,0,0,100,0,'951'),
--   (177921,45,-8833.07,-152.085,80.349,0,0,0,0,100,0,'951'),
--   (177921,46,-8830.21,-146.632,80.5787,0,0,0,0,100,0,'951'),
--   (177921,47,-8826.04,-146.105,80.6188,0,0,0,0,100,0,'951'),
--   (177921,48,-8822.08,-146.456,80.877,0,0,0,0,100,0,'951'),
--   (177921,49,-8817.2,-150.924,81.5878,0,0,0,0,100,0,'951'),
--   (177921,50,-8813.55,-153.822,82.0283,0,0,0,0,100,0,'951'),
--   (177921,51,-8811.99,-159.78,81.614,0,0,0,0,100,0,'951'),
--   (177921,52,-8810.78,-164.51,81.306,0,8000,0,0,100,0,'951'),
--   (177921,53,-8813.96,-163.8,81.108,0,0,0,0,100,0,'951'),
--   (177921,54,-8816.21,-156.19,81.452,0,0,0,0,100,0,'951'),
--   (177921,55,-8823.21,-151.63,80.539,0,0,0,0,100,0,'951'),
--   (177921,56,-8833.07,-152.085,80.349,0,0,0,0,100,0,'951'),
--   (177921,57,-8830.21,-146.632,80.5787,0,0,0,0,100,0,'951'),
--   (177921,58,-8826.04,-146.105,80.6188,0,0,0,0,100,0,'951'),
--   (177921,59,-8822.08,-146.456,80.877,0,0,0,0,100,0,'951'),
--   (177921,60,-8817.2,-150.924,81.5878,0,0,0,0,100,0,'951'),
--   (177921,61,-8813.55,-153.822,82.0283,0,8000,0,0,100,0,'951'),
--   (177921,62,-8811.99,-159.78,81.614,0,0,0,0,100,0,'951'),
--   (177921,63,-8810.78,-164.51,81.306,0,8000,0,0,100,0,'951'),
--   (177921,64,-8813.96,-163.8,81.108,0,0,0,0,100,0,'951'),
--   (177921,65,-8816.21,-156.19,81.452,0,0,0,0,100,0,'951'),
--   (177921,66,-8823.21,-151.63,80.539,0,0,0,0,100,0,'951');
--   DELETE FROM `waypoint_data` WHERE `id`=250677;
--   INSERT INTO `waypoint_data` (`id`,`point`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`move_flag`,`action`,`action_chance`,`wpguid`,`entry`) VALUES
--   (250677,1,1093.31,-4935.21,13.4578,0,0,0,0,100,0,NULL),
--   (250677,2,1093.2,-4936.21,13.4578,0,0,0,0,100,0,NULL),
--   (250677,3,1093.12,-4939.21,14.0828,0,0,0,0,100,0,NULL),
--   (250677,4,1093.06,-4941.21,14.8328,0,0,0,0,100,0,NULL),
--   (250677,5,1092.99,-4943.89,14.9578,0,0,0,0,100,0,NULL),
--   (250677,6,1092.99,-4943.89,14.9578,0,0,0,0,100,0,NULL);
--   DELETE FROM `waypoint_data` WHERE `id`=251657;
--   INSERT INTO `waypoint_data` (`id`,`point`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`move_flag`,`action`,`action_chance`,`wpguid`,`entry`) VALUES
--   (251657,1,-1550.59,-5314.18,8.03791,0,0,0,0,100,0,NULL),
--   (251657,2,-1549.89,-5314.9,8.03791,0,0,0,0,100,0,NULL),
--   (251657,3,-1554.43,-5312.78,8.28791,0,0,0,0,100,0,NULL),
--   (251657,4,-1554.43,-5312.78,8.28791,0,0,0,0,100,0,NULL);
--   DELETE FROM `waypoint_data` WHERE `id`=262339;
--   INSERT INTO `waypoint_data` (`id`,`point`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`move_flag`,`action`,`action_chance`,`wpguid`,`entry`) VALUES
--   (262339,1,326.601,-3677.97,27.2174,0,0,0,0,100,0,NULL),
--   (262339,2,326.792,-3678.96,27.2174,0,0,0,0,100,0,NULL),
--   (262339,3,325.915,-3678.81,27.2174,0,0,0,0,100,0,NULL),
--   (262339,4,326.358,-3672.63,27.2174,0,0,0,0,100,0,NULL),
--   (262339,5,326.358,-3672.63,27.2174,0,0,0,0,100,0,NULL);
UPDATE `creature` SET `position_x`=-8814.29,`position_y`=-157.297,`position_z`=81.6672,`orientation`=2.71012,`MovementType`=0,`wander_distance`=0 WHERE `guid`=177921 AND `id`=951;
UPDATE `creature_addon` SET `path_id`=0 WHERE `guid`=177921;
DELETE FROM `waypoint_data` WHERE `id`=177921;
UPDATE `creature` SET `position_x`=392.446,`position_y`=-4081.49,`position_z`=20.5023,`orientation`=3.3804 WHERE `guid`=253489 AND `id`=39325;
UPDATE `creature` SET `position_x`=562.012,`position_y`=-4103.38,`position_z`=16.8399,`orientation`=2.74017 WHERE `guid`=253749 AND `id`=39325;
UPDATE `creature` SET `position_x`=1096.05,`position_y`=-4935.3,`position_z`=14.6712,`orientation`=1.49577,`MovementType`=0,`wander_distance`=0 WHERE `guid`=250677 AND `id`=39604;
UPDATE `creature_addon` SET `path_id`=0 WHERE `guid`=250677;
DELETE FROM `waypoint_data` WHERE `id`=250677;
UPDATE `creature` SET `position_x`=326.792,`position_y`=-3678.96,`position_z`=27.2174,`orientation`=4.90458,`MovementType`=0,`wander_distance`=0 WHERE `guid`=262339 AND `id`=34258;
UPDATE `creature_addon` SET `path_id`=0 WHERE `guid`=262339;
DELETE FROM `waypoint_data` WHERE `id`=262339;
UPDATE `creature` SET `position_x`=-1549.89,`position_y`=-5314.9,`position_z`=8.06281,`orientation`=5.4877,`MovementType`=0,`wander_distance`=0 WHERE `guid`=251657 AND `id`=37969;
UPDATE `creature_addon` SET `path_id`=0 WHERE `guid`=251657;
DELETE FROM `waypoint_data` WHERE `id`=251657;
UPDATE `creature` SET `position_x`=-5523.24,`position_y`=-1333.6,`position_z`=398.555,`orientation`=2.68781 WHERE `guid`=169381 AND `id`=4772;
UPDATE `creature` SET `position_x`=-6372.79,`position_y`=576.672,`position_z`=385.806,`orientation`=1.96919 WHERE `guid`=166987 AND `id`=8416;
UPDATE `creature` SET `position_x`=10758.4,`position_y`=2208.9,`position_z`=1331.64,`orientation`=4.2237 WHERE `guid`=278140 AND `id`=3568;
UPDATE `creature` SET `position_x`=10683.6,`position_y`=1929.56,`position_z`=1336.4,`orientation`=5.81298 WHERE `guid`=276669 AND `id`=7313;
