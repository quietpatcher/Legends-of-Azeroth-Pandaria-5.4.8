-- Spirit healers in Northrend: three graveyards in the Storm Peaks have no spirit healer within 250 yards, so a player who
--   releases at graveyard 1388, 1400 or 1403 has no healer to resurrect at. The wider review counts 17 healers of entry 6491 in our world against 89 in the sniffs;
--   that gap is almost entirely a different entry: our world stands 60 more healers in Northrend as entry 29259, a second
--   template of the same Spirit Healer (same npcflag 16385, faction 35, unit_flags 768, ghost-only aura 10848), and only
--   these three graveyards, a fourth with a displaced healer and the Wintergrasp ones lack one.
-- Cause: the spawns come from an older database; the healers at these graveyards were never added.
-- Change: add three healers of entry 6491 as guids 5300100 to 5300102 (position, orientation, zone, area, health and spawn
--   time from the sniffed row; spawn mask 1, phase mask 65535, no phase id or group, as for all our other healers). The
--   sniffs carry phase id 169 on every healer; in our world phase 169 only exists as a Twilight Highlands zone phase (areas
--   5140 and 5424), not in Northrend, so it is left out. The ghost-only aura 10848 comes from the template addon of 6491,
--   so no creature_addon rows. The guids follow the last used guid 5300059 with a gap, are free in the world table and in all pending updates, and no healer of ours stands within 250 yards of the new spots.
-- Not changed on purpose: graveyard 1383 (Storm Peaks, 7080.4 -141.2): our healer 89882 (entry 29259) stands 20.7 yards from
--   it and 13 yards higher against 5 yards for the sniffed one, so adding a second healer would stack two; a move of 89882 is
--   a separate change. Graveyard 1397 (Icecrown): our healer 89891 stands 10 yards from the sniffed one. The seven
--   Wintergrasp graveyards (zone 4197, healers driven by the battle) and all graveyards of instances and battlegrounds
--   without a game_graveyard_zone row are skipped; graveyards 1477 and 1720 have a sniffed healer but no zone link, so no
--   player is ever sent there.
-- Source: the Cataclysm Preservation world database (built from sniffs): healers 99199, 99776 and 99785 at 6.3, 8.7 and 9.5
--   yards from their graveyard; graveyard positions from the 5.4.8 client data (WorldSafeLocs.dbc) with their zones from
--   game_graveyard_zone; our healers of entry 29259 compared at 15 yards. Checked 15-11-2026.
-- Rollback:
--   DELETE FROM `creature` WHERE `guid` IN (5300100,5300101,5300102) AND `id`=6491;
DELETE FROM `creature` WHERE `guid` IN (5300100,5300101,5300102) AND `id`=6491;
INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5300100,6491,571,67,67,1,65535,0,0,0,0,7463.12,-3326.36,899.719,1.72146,60,0,0,0,4120,0,0,0,0,0,0,0,'',0,0),
(5300101,6491,571,67,4446,1,65535,0,0,0,0,7832.92,-2019.02,1226.67,3.63783,60,0,0,0,4120,0,0,0,0,0,0,0,'',0,0),
(5300102,6491,571,67,4419,1,65535,0,0,0,0,6431.54,-1186.62,448.172,2.38906,60,0,0,0,4120,0,0,0,0,0,0,0,'',0,0);
