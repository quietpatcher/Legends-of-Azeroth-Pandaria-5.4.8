-- Small data fixes ported from 1LineAtaTime/LoA-Pandaria-Playerbots (GPLv2): 88313276, 5501949d, d0072196, 0a691795, a899beee,
-- 0725b152 (PR 15 #978), 48da5f71. Every value was re-checked against our own data or a reference database (see per block).
-- Rollback: the commented statements at the end of this file.

-- 24925 (Lost Isles): the 26 Oomlot Shamans (38644) have spawnMask 0 ("not spawned") and phase 1, while their camp mates
-- (38643 / 38574 / 38575, 47 spawns) all use spawnMask 1 and phase 12288 (the phase of the player after the Town-In-A-Box
-- defence), so the 5-kill objective cannot be finished. Source: our own spawn data of the camp mates.
UPDATE `creature` SET `spawnMask` = 1 WHERE `id` = 38644 AND `spawnMask` = 0;
UPDATE `creature` SET `phaseMask` = 12288 WHERE `id` = 38644 AND `phaseMask` = 1;

-- 24958 Volcanoth!: the Bootzooka (spell 73066) has two creature conditions for 38855: ConditionTarget 1 (the target, right)
-- and ConditionTarget 0 (the caster must be Volcanoth), which no player meets. The SkyFire 5.4.8 data (ref_sf) has only the target row.
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 17 AND `SourceEntry` = 73066 AND `ConditionTarget` = 0;

-- Kaja'Cola Zero-One chests (GO 202554, quest item 52483): all 15 spawns lie in the late Lost Isles scene whose creatures use
-- phase 16384, but the chests were phase 1 and so invisible to a player in that phase.
UPDATE `gameobject` SET `phaseMask` = 16384 WHERE `id` = 202554 AND `phaseMask` = 1;

-- Brewmaster Blanche (59569) had no spawn, so "Blanche's Boomer Brew" (30567) could not be started. Position from the SkyFire
-- 5.4.8 database (ref_sf creature 8163388), identical to the position in the 1LineAtaTime fix.
DELETE FROM `creature` WHERE `guid` = 4049101 AND `id` = 59569;
INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(4049101,59569,870,5785,0,1,1,0,0,2215.19,-1166.03,448.864,4.83031,120,0,0,0,0,0,0,0,0,0,0,0,'',0,0);

-- Apothecary Karlov (29346) was a patch 3.0.2 pre-event NPC removed later; the holiday Commoners still start "Desperate Research"
-- (12783 troll, 12811 orc) which leads to "Orgrimmar" (12785, 12812) that only Karlov ends. Disable the unfinishable chain.
DELETE FROM `disables` WHERE `sourceType` = 1 AND `entry` IN (12783, 12785, 12811, 12812);
INSERT INTO `disables` (`sourceType`,`entry`,`flags`,`params_0`,`params_1`,`comment`) VALUES
(1,12783,0,'','','Deprecated quest: Desperate Research (troll), ends at removed Apothecary Karlov'),
(1,12785,0,'','','Deprecated quest: Orgrimmar (troll), ender Apothecary Karlov removed'),
(1,12811,0,'','','Deprecated quest: Desperate Research (orc), ends at removed Apothecary Karlov'),
(1,12812,0,'','','Deprecated quest: Orgrimmar (orc), ender Apothecary Karlov removed');

-- Level 28 needs 21,120 XP, a typo for 27,120: patch 5.0.4 cut levels 10-39 to 80% of the Cataclysm values (ref_sf: 33,900 at 28,
-- 33,900 x 0.8 = 27,120; level 27: 32,200 x 0.8 = 25,760 matches our row).
UPDATE `player_xp_for_level` SET `xp_for_next_level` = 27120 WHERE `lvl` = 28 AND `xp_for_next_level` = 21120;

-- Northern Barrens: one Boahn (3672), the rare Druid of the Fang. There were three, none pooled: 35328 at (-586, -2326) in every
-- phase, and a pair 2.8 yd apart at (-707, -2295). Keep 35328 in the normal phase (PR 15 #978).
UPDATE `creature` SET `phaseMask` = 1 WHERE `guid` = 35328 AND `id` = 3672;
DELETE FROM `creature` WHERE `guid` IN (263366, 264200) AND `id` = 3672;
DELETE `ca` FROM `creature_addon` `ca` LEFT JOIN `creature` `c` ON `c`.`guid` = `ca`.`guid` WHERE `ca`.`guid` IN (263366, 264200) AND `c`.`guid` IS NULL;

-- Kun-Lai Summit, Farmhand Freedom: the freed Farmstead Slaves (59577) had no creature_text rows ("Could not find Text").
-- Lines and broadcast text ids checked against our broadcast_text table (ids 58802, 58874-58879).
DELETE FROM `creature_text` WHERE `CreatureID` = 59577;
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(59577,0,0,'Death to the yaungol!',12,0,50,0,0,0,58875,0,'Farmstead Slave - Farmhand Freedom'),
(59577,0,1,'Good riddance.',12,0,50,0,0,0,58879,0,'Farmstead Slave - Farmhand Freedom'),
(59577,0,2,'Let''s go to Binan Village.',12,0,50,0,0,0,58878,0,'Farmstead Slave - Farmhand Freedom'),
(59577,0,3,'Our hero!',12,0,50,0,0,0,58876,0,'Farmstead Slave - Farmhand Freedom'),
(59577,0,4,'Quick, let''s get out of here.',12,0,50,0,0,0,58874,0,'Farmstead Slave - Farmhand Freedom'),
(59577,0,5,'We''re free!',12,0,50,0,0,0,58802,0,'Farmstead Slave - Farmhand Freedom'),
(59577,0,6,'We''re saved!',12,0,50,0,0,0,58877,0,'Farmstead Slave - Farmhand Freedom');

-- Rollback:
--   UPDATE `creature` SET `spawnMask` = 0, `phaseMask` = 1 WHERE `id` = 38644 AND `spawnMask` = 1 AND `phaseMask` = 12288;
--   INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES (17,0,73066,0,0,31,0,3,38855,0,0,0,0,'',NULL);
--   UPDATE `gameobject` SET `phaseMask` = 1 WHERE `id` = 202554 AND `phaseMask` = 16384;
--   DELETE FROM `creature` WHERE `guid` = 4049101 AND `id` = 59569;
--   DELETE FROM `disables` WHERE `sourceType` = 1 AND `entry` IN (12783, 12785, 12811, 12812);
--   UPDATE `player_xp_for_level` SET `xp_for_next_level` = 21120 WHERE `lvl` = 28;
--   UPDATE `creature` SET `phaseMask` = 65535 WHERE `guid` = 35328 AND `id` = 3672;   (the two deleted Boahn rows are not restored)
--   DELETE FROM `creature_text` WHERE `CreatureID` = 59577;
