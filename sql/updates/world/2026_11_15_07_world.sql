-- Spirit healers (6491) in Eastern Kingdoms and Kalimdor: two healers stand 21 to 25 yards from their graveyard while the
--   sniffs have them 12 to 13 yards from it, and at five graveyards there is no spirit healer at all within 250 yards:
--   Eastern Plaguelands (graveyard 1405), the Ruins of Gilneas in Silverpine (1810), Searing Gorge (1847), Ashenvale (851)
--   and Dustwallow Marsh (1265). A player who releases at those graveyards has no healer to resurrect at.
-- Cause: the spawns come from an older database; the healers at these graveyards were never added.
-- Change: move 371256 (graveyard 636, Searing Gorge) and 371405 (graveyard 511, Winterspring) to the position and
--   orientation of the sniffed healer at their graveyard (other columns stay), and add the five missing healers as guids
--   5300055 to 5300059 (position, orientation, zone, area and spawn time from the sniffed row; spawn mask 1, phase mask
--   65535, no phase id or group, as for all our other healers: the phase ids 169 and 274 of the sniffs are not used by any
--   of our creatures). The ghost-only aura 10848 comes from the template addon of 6491, so no creature_addon rows.
--   No creature_addon, formation, linked respawn, pool, game event, waypoint or smart script row refers to the two moved
--   guids. The guids 5300055 to 5300059 follow the last used guid 5300054 and are free in the world table and in all
--   pending updates; no 6491 spawn stands within 250 yards of any of the new positions.
-- Not changed on purpose: seven further healers of the review (371283, 371291, 371231, 371316, 371368, 371319 and the
--   borderline 371312) stand far from their graveyard but our world already has a second healer within 3 to 9 yards of that
--   graveyard at the sniffed position (375075, 375074, 375073, 375089, 371216, 375093); moving them would stack two healers
--   on one spot. 371312 stands 15.3 yards from graveyard 1277 against 19 yards from the sniffed healer, which is no proof.
-- Source: the Cataclysm Preservation world database (built from sniffs): healers at -6439.12 -1114.68 312.147 (12.3 yards
--   from graveyard 636) and 6889.73 -4661.07 701.771 (12.8 yards from graveyard 511), plus the healers of the five
--   missing graveyards at 3.1 to 9.3 yards from the graveyard; graveyard positions from the 5.4.8 client data
--   (WorldSafeLocs.dbc) with their zones from game_graveyard_zone. Checked 15-11-2026.
-- Rollback:
--   UPDATE `creature` SET `position_x`=-6432.8,`position_y`=-1129.57,`position_z`=316.414,`orientation`=2.08438 WHERE `guid`=371256 AND `id`=6491;
--   UPDATE `creature` SET `position_x`=6855.81,`position_y`=-4664.11,`position_z`=701.468,`orientation`=0.146364 WHERE `guid`=371405 AND `id`=6491;
--   DELETE FROM `creature` WHERE `guid` IN (5300055,5300056,5300057,5300058,5300059) AND `id`=6491;
UPDATE `creature` SET `position_x`=-6439.12,`position_y`=-1114.68,`position_z`=312.147,`orientation`=3.01942 WHERE `guid`=371256 AND `id`=6491;
UPDATE `creature` SET `position_x`=6889.73,`position_y`=-4661.07,`position_z`=701.771,`orientation`=3.22886 WHERE `guid`=371405 AND `id`=6491;
DELETE FROM `creature` WHERE `guid` IN (5300055,5300056,5300057,5300058,5300059) AND `id`=6491;
INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5300055,6491,0,139,4281,1,65535,0,0,0,0,2356.65,-5663.06,382.257,0.586577,60,0,0,0,4120,0,0,0,0,0,0,0,'',0,0),
(5300056,6491,0,4706,5434,1,65535,0,0,0,0,-905.74,1623.03,68.3634,2.3911,120,0,0,0,4120,0,0,0,0,0,0,0,'',0,0),
(5300057,6491,0,51,1959,1,65535,0,0,0,0,-6558.31,-1959.74,247.225,1.0472,300,0,0,0,4120,0,0,0,0,0,0,0,'',0,0),
(5300058,6491,1,1638,5345,1,65535,0,0,0,0,-972.736,-74.5938,17.9305,3.15905,300,0,0,0,4120,0,0,0,0,0,0,0,'',0,0),
(5300059,6491,1,15,4010,1,65535,0,0,0,0,-4632.74,-3136.45,35.0033,1.53589,300,0,0,0,4120,0,0,0,0,0,0,0,'',0,0);
