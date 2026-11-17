-- To-do 434 (The Warchief Cometh, Forsaken High Command, Silverpine Forest): the corpse field has the wrong mix of Fallen
--   Humans. A player sees 12 corpses where the original has 11, one of them standing on a spot with no corpse in the
--   original, and the male/female split differs (ours 7 male + 5 female, original 5 male + 6 female).
-- Cause: after the exact-position twins were removed (2026_11_12_02) 12 rows were left. 11 of them stand on the 11 original
--   spots, but 5 of those have the wrong entry (44592 vs 44593), one original spot (1372.08 1034.98) has no row at all, and
--   two rows (187007 at 1376 1029.61, 187011 at 1377.3 1035.93) stand on spots that do not exist in the original.
-- Change: set entry 44592 on 186829 and 187529, entry 44593 on 187049, 187532 and 186950 (modelid moved to the same
--   position in the other gender display list of the entry, 33978-33981 male / 33982-33985 female, so the Forsaken
--   trooper chosen by display id in the scene fits the entry); move 187011 (44593) to the missing spot 1372.08 1034.98
--   with the original z and orientation; delete 187007 (no original spot). Result: 11 rows, 5 x 44592 and 6 x 44593, each
--   on an original position. No creature_addon, pool, event, formation, linked respawn, smart_scripts or condition row
--   refers to these guids; the scripts act on the entries (44592/44593) through spell targets, not on guids or counts.
-- Source: the Cataclysm Preservation world database (built from sniffs) and the SkyFire 5.4.8 world database list the same
--   11 spawns (identical positions and entries row by row): 44592 at 1367.33 1035.38, 1369.65 1033.67, 1369.71 1040.19,
--   1372.58 1038.07, 1372.98 1041.06; 44593 at 1369.57 1036.9, 1370.66 1030.82, 1372.08 1034.98, 1373.35 1031.58,
--   1374.14 1036.35, 1375.2 1038.58. Checked 15-11-2026.
-- Rollback:
--   UPDATE `creature` SET `id`=44593,`modelid`=33983 WHERE `guid` IN (186829,187529);
--   UPDATE `creature` SET `id`=44592,`modelid`=33980 WHERE `guid` IN (187049,186950);
--   UPDATE `creature` SET `id`=44592,`modelid`=33978 WHERE `guid`=187532;
--   UPDATE `creature` SET `position_x`=1377.3,`position_y`=1035.93,`position_z`=51.0961,`orientation`=3.14159 WHERE `guid`=187011 AND `id`=44593;
--   INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
--   (187007,44592,0,130,5369,1,1,0,0,33979,0,1376,1029.61,50.9374,0.890118,300,0,0,0,273,0,0,0,0,0,0,0,"",0,0);
UPDATE `creature` SET `id`=44592,`modelid`=33979 WHERE `guid` IN (186829,187529);
UPDATE `creature` SET `id`=44593,`modelid`=33984 WHERE `guid` IN (187049,186950);
UPDATE `creature` SET `id`=44593,`modelid`=33982 WHERE `guid`=187532;
UPDATE `creature` SET `position_x`=1372.08,`position_y`=1034.98,`position_z`=50.8489,`orientation`=0.890118 WHERE `guid`=187011 AND `id`=44593;
DELETE FROM `creature` WHERE `guid`=187007 AND `id`=44592;
