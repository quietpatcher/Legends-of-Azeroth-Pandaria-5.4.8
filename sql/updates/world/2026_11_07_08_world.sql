-- To-do 464 part 2 (Splintertree Post, Ashenvale): players in the Imp Disguise saw the Splintertree Demolisher twice.
-- Next to the normal Demolisher 33726 (guid 237191, phase 1) there is a second spawn of entry 33960 (guid 311065) on the same spot in
-- phase 2 only, which a disguised player (phase 1+2) sees as well. Nothing uses 33960 (no SmartAI, no script, no summon, no
-- accessory) and the Cataclysm Preservation data (sniff-based) has no 33960 spawn at all, so the extra spawn is removed.
-- Source: ref_cpp creature (only 33726 at 2283 -2529), own DB check 07-11.
-- Rollback (row saved on dev in ~/backups/sql/creature_311065_pre_20261107.sql):
-- INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawntimesecs_max`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `npcflag2`, `unit_flags`, `unit_flags2`, `dynamicflags`, `ScriptName`, `walk_mode`, `VerifiedBuild`) VALUES (311065,33960,1,331,431,1,2,0,0,28823,0,2282.44,-2529.29,98.4121,3.15905,300,0,0,0,1124,0,0,0,0,0,0,0,'',0,0);
DELETE FROM `creature` WHERE `guid` = 311065 AND `id` = 33960;
DELETE FROM `creature_addon` WHERE `guid` = 311065;
