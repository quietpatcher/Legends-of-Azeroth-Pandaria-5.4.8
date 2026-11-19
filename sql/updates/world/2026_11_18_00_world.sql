-- Hellfire Ramparts and The Blood Furnace: two creature spawns that do not match the references.
-- What a player sees today: Hellfire Ramparts has four Hellfire Sentries (17517); two of them (guids 75050 and 75051) stand on
--   the lower path near -1226 1472, far from the platform of Vazruden the Herald where the encounter needs them. In The Blood
--   Furnace the chained Magtheridon (21174, guid 92038) behind the glass wanders around randomly (MovementType 1, 5 yards).
-- Cause: both come from an older database. The two references have only the two platform sentries (53822/53823 here) and a
--   stationary Magtheridon on the same spot.
-- Checked: guids 75050 and 75051 have no creature_addon, formation, linked respawn, pool, smart script by guid or game event, and
--   no script refers to these guids (the sentry script finds the herald within 150 yards; these two stand about 350 yards away).
-- Change: the two extra sentries are deleted; Magtheridon 92038 becomes stationary (MovementType 0, wander distance 0).
-- Source: Cataclysm Preservation and SkyFire 5.4.8 world databases (two Hellfire Sentries on map 543; Magtheridon 21174 on map
--   542 with MovementType 0), 18-11-2026.
-- Rollback (the rows and values before this update):
--   INSERT INTO `creature` VALUES (75050,17517,543,3562,3562,6,1,0,0,0,0,-1229.42,1475.46,68.5581,3.67248,7200,0,0,0,9744,0,0,0,0,0,0,0,'',0,0);
--   INSERT INTO `creature` VALUES (75051,17517,543,3562,3562,6,1,0,0,0,0,-1223.65,1469.98,68.5635,4.02984,7200,0,0,0,9744,0,0,0,0,0,0,0,'',0,0);
--   UPDATE `creature` SET `MovementType`=1,`wander_distance`=5 WHERE `guid`=92038 AND `id`=21174;

DELETE FROM `creature` WHERE `guid` IN (75050,75051) AND `id`=17517;  -- Hellfire Sentry, lower path

UPDATE `creature` SET `MovementType`=0,`wander_distance`=0 WHERE `guid`=92038 AND `id`=21174;  -- Magtheridon, chained
