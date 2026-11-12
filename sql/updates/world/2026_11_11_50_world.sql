-- Kezan, quests 14121 Robbing Hoods and 14124 Liberate the Kaja'mite (goblin start).
--
-- 14121: a Hired Looter (35234) that is run over with the Hot Rod throws his Stolen Loot to the driver (spell 67041
--   Robbing Hoods: Create Stolen Loot) and stays down; nothing did that, so the quest could only be done on foot.
--   The looter gets the script npc_kezan_hired_looter (it also keeps the Torch Toss of the old SmartAI row).
--   The knockback of the Hot Rod (66301, TARGET_UNIT_CONE_ENTRY) had no entry conditions and threw everything in a
--   12 yard cone aside, quest givers and other players included; it now hits Hired Looters and Kezan Citizens only.
-- 14124: Kablooey Bombs (67682) blow a Kaja'mite Deposit (195488) into three Kaja'mite Chunks (195492) and stun a
--   Rebellious Troll for a moment (spell_kezan_kablooey_bombs). The 15 chunks that lay in the mine permanently are
--   removed: chunks only come out of a blown up deposit. The deposit itself is not clickable (goober without quest
--   and not consumable, as in the client cache).
-- Source: wowhead.com/quest=14121 (comment: "run them down... you get the stolen loot directly in your inventory"),
--   warcraft.wiki.gg/wiki/Robbing_Hoods, warcraft.wiki.gg/wiki/Liberate_the_Kaja%27mite ("blow them up in to three
--   Kaja'mite Chunks", "stun the rebellious trolls, if for a second or so"), 5.4.8 client Spell.dbc (67041 create item
--   on an enemy target, 66301 cone entry 12 yd, 67682 activate object in 5 yd of the landing + dummy on enemies, area
--   group 1723 = Kaja'mine 4766), ref_cpp/ref_sf gameobject_template 195488 (data all 0) and no 195492 spawns in ref_cpp.
-- Rollback: the statements at the bottom of this file (commented out).

UPDATE `creature_template` SET `AIName`='', `ScriptName`='npc_kezan_hired_looter' WHERE `entry`=35234;

DELETE FROM `spell_script_names` WHERE `spell_id` IN (67041,67682);
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(67041,'spell_kezan_create_stolen_loot'),
(67682,'spell_kezan_kablooey_bombs');

-- 66301 Hot Rod - Knockback, effect 0: Hired Looter 35234, Kezan Citizen 35063 / 35075
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=13 AND `SourceEntry`=66301;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(13,1,66301,0,0,31,0,3,35234,0,0,0,0,'','Hot Rod - Knockback hits Hired Looter'),
(13,1,66301,0,1,31,0,3,35063,0,0,0,0,'','Hot Rod - Knockback hits Kezan Citizen'),
(13,1,66301,0,2,31,0,3,35075,0,0,0,0,'','Hot Rod - Knockback hits Kezan Citizen');

-- Kaja'mite Deposit: not a button
UPDATE `gameobject_template` SET `data1`=0, `data5`=0 WHERE `entry`=195488;

-- the permanent Kaja'mite Chunks (guid 216093-216107)
DELETE FROM `gameobject` WHERE `id`=195492 AND `map`=648 AND `guid` BETWEEN 216093 AND 216107;

-- Rollback:
-- UPDATE `creature_template` SET `AIName`='SmartAI', `ScriptName`='' WHERE `entry`=35234;
-- DELETE FROM `spell_script_names` WHERE `spell_id` IN (67041,67682);
-- DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=13 AND `SourceEntry`=66301;
-- UPDATE `gameobject_template` SET `data1`=14124, `data5`=1 WHERE `entry`=195488;
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216093,195492,648,4737,4766,1,32,0,0,-8497.07,1190.89,42.9992,2.78495,0,0,0.984143,0.177376,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216094,195492,648,4737,4766,1,32,0,0,-8488.23,1184.14,41.9642,1.76001,0,0,0.770741,0.637148,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216095,195492,648,4737,4766,1,32,0,0,-8484.94,1166.96,41.7269,1.76001,0,0,0.770741,0.637148,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216096,195492,648,4737,4766,1,32,0,0,-8483.77,1153.34,39.7902,1.53853,0,0,0.695606,0.718424,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216097,195492,648,4737,4766,1,32,0,0,-8478.81,1140.49,40.3999,3.00879,0,0,0.997796,0.0663518,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216098,195492,648,4737,4766,1,32,0,0,-8461.94,1141,39.8191,4.51676,0,0,0.772783,-0.63467,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216099,195492,648,4737,4766,1,32,0,0,-8454.77,1160.56,39.8499,3.98897,0,0,0.911579,-0.411125,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216100,195492,648,4737,4766,1,32,0,0,-8439.06,1180.52,40.7984,4.34947,0,0,0.823106,-0.567887,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216101,195492,648,4737,4766,1,32,0,0,-8439.03,1192.86,40.5609,5.32022,0,0,0.463094,-0.886309,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216102,195492,648,4737,4766,1,32,0,0,-8446.62,1200.57,40.6294,5.9022,0,0,0.189343,-0.981911,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216103,195492,648,4737,4766,1,32,0,0,-8462.3,1203.76,42.1474,0.200994,0,0,0.100328,0.994954,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216104,195492,648,4737,4766,1,32,0,0,-8478.92,1202.34,41.9344,6.15196,0,0,0.0655673,-0.997848,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216105,195492,648,4737,4766,1,32,0,0,-8490.38,1204.33,42.3581,5.5315,0,0,0.367059,-0.930198,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216106,195492,648,4737,4766,1,32,0,0,-8498.2,1208.06,43.0213,4.31414,0,0,0.833007,-0.553263,60,100,1,'',0);
-- INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES (216107,195492,648,4737,4766,1,32,0,0,-8498.36,1208.49,43.076,2.16687,0,0,0.88357,0.468298,60,100,1,'',0);
