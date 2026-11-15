-- Spirit healers (6491) in Tirisfal Glades: a dead player who releases in Deathknell or in Brill has to run far from the
--   graveyard to find the spirit healer (138 and 41 yards away), and at the Undercity graveyard there is no healer at all.
-- Cause: spawns 371227 (graveyard 94, Deathknell) and 371403 (graveyard 289, Brill) were copied from a database with
--   wrong positions, and the healer of graveyard 96 (Undercity) is missing.
-- Change: move 371227 and 371403 to the position and orientation of the healer that stands next to their graveyard
--   in the reference (other columns stay), and add the Undercity healer with guid 5131000 (position, orientation, spawn
--   time and movement from the reference; phase, spawn mask, model and flags as the other healers in this zone). The
--   ghost-only aura 10848 comes from the template addon of 6491, as for all our other healers, so no creature_addon row.
--   No formation, linked respawn, pool or game event refers to the two moved guids. Guid 5131000 is in our own block
--   (5129001-5130151 are used by earlier updates), is free, and no 6491 spawn exists within 5 yards of the new position.
-- Source: the Cataclysm Preservation world database (built from sniffs): healers at 1882.78 1622.24 94.28 (6.9 yards
--   from graveyard 94), 2349.71 484.75 33.45 (7.3 yards from graveyard 289) and 1819.41 219.233 60.07 (5.5 yards from
--   graveyard 96); graveyard positions from the client data (WorldSafeLocs). Checked 14-11-2026.
-- Rollback:
--   UPDATE `creature` SET `position_x`=1753.08,`position_y`=1585.8,`position_z`=112.28,`orientation`=1.52353 WHERE `guid`=371227 AND `id`=6491;
--   UPDATE `creature` SET `position_x`=2383.21,`position_y`=469.47,`position_z`=35.52,`orientation`=3.84555 WHERE `guid`=371403 AND `id`=6491;
--   DELETE FROM `creature` WHERE `guid`=5131000 AND `id`=6491;
--   DELETE FROM `creature_addon` WHERE `guid`=5131000;
UPDATE `creature` SET `position_x`=1882.78,`position_y`=1622.24,`position_z`=94.28,`orientation`=1.5528 WHERE `guid`=371227 AND `id`=6491;
UPDATE `creature` SET `position_x`=2349.71,`position_y`=484.75,`position_z`=33.45,`orientation`=1.80702 WHERE `guid`=371403 AND `id`=6491;
DELETE FROM `creature` WHERE `guid`=5131000 AND `id`=6491;
DELETE FROM `creature_addon` WHERE `guid`=5131000;
INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5131000,6491,0,85,85,1,65535,0,0,0,0,1819.41,219.233,60.0732,0.337883,60,0,0,0,4120,0,0,0,0,0,0,0,'',0,0);
