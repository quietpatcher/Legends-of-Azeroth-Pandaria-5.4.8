-- Quest givers and spirit healers of the review of 15-11-2026, remaining part: 13 quest giver spawns that lie 6 to 148
--   yards from the position the sniff-based references have for the same creature, one spirit healer that stands 35 yards
--   from its graveyard and three graveyards in Outland without any spirit healer within 250 yards.
-- What a player sees today: the quest givers stand at a position from an older database instead of at the spot where quests
--   are given and handed in according to the sniffs (Arazmodu 148 yards, High Priest Thel'danis 27 yards, Argus Highbeacon
--   20 yards, Kinnel 19 yards and so on); the spirit healer at its graveyard in Zangarmarsh stands 35 yards from it, and a
--   player who releases at the three graveyards in Nagrand and Terokkar Forest has no healer to
--   resurrect at.
-- Cause: positions come from an older database; the sniff-based reference has the observed position, and the healers at
--   these graveyards were never added.
-- Checked per row: the reference has a spawn of the same id on the same map at exactly the new coordinates (MovementType 0 in
--   both, same zone; the area is also the same except for Argent Apothecary Judkins, whose area is left unchanged); no other
--   spawn of that id lies within 3 yards of a new quest giver position and each id has a single spawn in our world; no
--   creature_formations, creature_addon waypoint path, waypoint_data, game_event_creature, pool_creature or linked_respawn row
--   refers to the changed spawns; none of the spawns has a ScriptName; the smart_scripts of High Priest Thel'danis and Argus
--   Highbeacon hold no waypoint, move-to-position, summon or teleport action; Anachronos (15192) has a core script, but it only
--   handles gossip and does not use any position. The healer 92772 stands 35.0 yards from graveyard 969 and the sniffed
--   position is the graveyard itself (0.0 yards, WorldSafeLocs.dbc of the 5.4.8 client); the added healers stand 1.4 to 7.0 yards
--   from graveyards 1037, 1291 and 1298 and no healer 6491 of ours stands within 250 yards of any of the four positions. The
--   guids 5300060 to 5300062 follow the last used guid 5300059 and are free in the world table and in all pending updates.
-- Left out on purpose: Lady Jaina Proudmoore (path and MovementType) and the six duplicate candidates are handled separately;
--   the healers 81524 and 81525 (15.3 and 16.6 yards, no proof); the sniffed healer 17634 at graveyard 1262 (Shadowmoon
--   Valley), because our healer 92037 already stands 95 yards from it; the 71 sniffed healers in Northrend, which need a
--   separate review; Totem of Tikti was already left out earlier because of its absolute summon coordinates.
-- Change: position_x, position_y, position_z and orientation of the 13 quest givers and of healer 92772 are set to the
--   reference values; three healers (id 6491) are added with position, orientation, zone, area and spawn time of the sniffed row;
--   spawn mask 1, phase mask 65535, no phase id or group, as for all our other healers. The ghost-only aura comes from the
--   template addon of 6491, so no creature_addon rows.
-- Source: Cataclysm Preservation sniff database + 5.4.8 WorldSafeLocs.dbc, 15-11-2026.
-- Rollback (the values before this update):
--   UPDATE `creature` SET `position_x`=2451.29,`position_y`=-1665.18,`position_z`=102.739,`orientation`=0.995205 WHERE `guid`=212134 AND `id`=44472;
--   UPDATE `creature` SET `position_x`=990.127,`position_y`=-1820.29,`position_z`=80.4872,`orientation`=3.79717 WHERE `guid`=212351 AND `id`=1854;
--   UPDATE `creature` SET `position_x`=1861.29,`position_y`=-3729.53,`position_z`=195.679,`orientation`=6.17538 WHERE `guid`=172780 AND `id`=45451;
--   UPDATE `creature` SET `position_x`=2954.69,`position_y`=-2994.99,`position_z`=126.972,`orientation`=1.97949 WHERE `guid`=173979 AND `id`=45828;
--   UPDATE `creature` SET `position_x`=-12114,`position_y`=-845.66,`position_z`=46.3196,`orientation`=3.49945 WHERE `guid`=183167 AND `id`=42814;
--   UPDATE `creature` SET `position_x`=-12845.3,`position_y`=-431.559,`position_z`=12.9928,`orientation`=2.17538 WHERE `guid`=183232 AND `id`=44043;
--   UPDATE `creature` SET `position_x`=-8467.88,`position_y`=-4243.7,`position_z`=-208.358,`orientation`=1.25664 WHERE `guid`=274363 AND `id`=15192;
--   UPDATE `creature` SET `position_x`=-8518.55,`position_y`=-4221.15,`position_z`=-214.183,`orientation`=3.28877 WHERE `guid`=274376 AND `id`=19936;
--   UPDATE `creature` SET `position_x`=-1440.66,`position_y`=-1938.09,`position_z`=94.1271,`orientation`=5.34509 WHERE `guid`=268972 AND `id`=37515;
--   UPDATE `creature` SET `position_x`=-4138.3,`position_y`=-1954.25,`position_z`=93.4163,`orientation`=1.19838 WHERE `guid`=268980 AND `id`=37847;
--   UPDATE `creature` SET `position_x`=-2100.58,`position_y`=-1736.95,`position_z`=97.4215,`orientation`=1.96322 WHERE `guid`=269039 AND `id`=3433;
--   UPDATE `creature` SET `position_x`=-2231.75,`position_y`=-3735.59,`position_z`=91.7402,`orientation`=3.87386 WHERE `guid`=269211 AND `id`=39322;
--   UPDATE `creature` SET `position_x`=-3864.44,`position_y`=-2292.84,`position_z`=91.7917,`orientation`=2.94767 WHERE `guid`=269246 AND `id`=39697;
--   UPDATE `creature` SET `position_x`=253.195,`position_y`=7050.25,`position_z`=35.1273,`orientation`=3.75296 WHERE `guid`=92772 AND `id`=6491;
--   DELETE FROM `creature` WHERE `guid` IN (5300060,5300061,5300062) AND `id`=6491;

UPDATE `creature` SET `position_x`=2454.11,`position_y`=-1659,`position_z`=102.924,`orientation`=4.28398 WHERE `guid`=212134 AND `id`=44472;
UPDATE `creature` SET `position_x`=963.394,`position_y`=-1817.01,`position_z`=80.4872,`orientation`=3.49406 WHERE `guid`=212351 AND `id`=1854;
UPDATE `creature` SET `position_x`=1841.74,`position_y`=-3726.59,`position_z`=195.68,`orientation`=3.0161 WHERE `guid`=172780 AND `id`=45451;
UPDATE `creature` SET `position_x`=2954.96,`position_y`=-3002.88,`position_z`=127.037,`orientation`=5.72468 WHERE `guid`=173979 AND `id`=45828;
UPDATE `creature` SET `position_x`=-12126.9,`position_y`=-843.761,`position_z`=45.3609,`orientation`=0.718409 WHERE `guid`=183167 AND `id`=42814;
UPDATE `creature` SET `position_x`=-12826.3,`position_y`=-432.688,`position_z`=13.0788,`orientation`=4.54086 WHERE `guid`=183232 AND `id`=44043;
UPDATE `creature` SET `position_x`=-8470.96,`position_y`=-4252.98,`position_z`=-208.358,`orientation`=1.25664 WHERE `guid`=274363 AND `id`=15192;
UPDATE `creature` SET `position_x`=-8582.8,`position_y`=-4354.45,`position_z`=-214.01,`orientation`=5.08131 WHERE `guid`=274376 AND `id`=19936;
UPDATE `creature` SET `position_x`=-1440.73,`position_y`=-1929.52,`position_z`=94.2273,`orientation`=2.67035 WHERE `guid`=268972 AND `id`=37515;
UPDATE `creature` SET `position_x`=-4148.83,`position_y`=-1942.8,`position_z`=93.0321,`orientation`=5.47871 WHERE `guid`=268980 AND `id`=37847;
UPDATE `creature` SET `position_x`=-2106.14,`position_y`=-1745.13,`position_z`=96.1111,`orientation`=4.70342 WHERE `guid`=269039 AND `id`=3433;
UPDATE `creature` SET `position_x`=-2215.91,`position_y`=-3731.34,`position_z`=91.6572,`orientation`=5.79852 WHERE `guid`=269211 AND `id`=39322;
UPDATE `creature` SET `position_x`=-3855.28,`position_y`=-2294.24,`position_z`=91.7917,`orientation`=1.72788 WHERE `guid`=269246 AND `id`=39697;
UPDATE `creature` SET `position_x`=248.339,`position_y`=7084.93,`position_z`=36.4931,`orientation`=3.04797 WHERE `guid`=92772 AND `id`=6491;
DELETE FROM `creature` WHERE `guid` IN (5300060,5300061,5300062) AND `id`=6491;
INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5300060,6491,530,3518,3764,1,65535,0,0,0,0,-1295.76,9170.33,217.797,0.295307,60,0,0,0,4120,0,0,0,0,0,0,0,'',0,0),
(5300061,6491,530,3519,4078,1,65535,0,0,0,0,-1423.5,4358.49,241.566,5.18548,72000,0,0,0,4120,0,0,0,0,0,0,0,'',0,0),
(5300062,6491,530,3519,3692,1,65535,0,0,0,0,-2438.87,4665.47,161.979,4.64829,72000,0,0,0,4120,0,0,0,0,0,0,0,'',0,0);
