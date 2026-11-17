-- Mount Hyjal (map 1, zone 616): remove the surplus Tomo (53781) that stands on top of his identical twin 43381.
-- Problem: at Nordrassil (area 4989, 5184 -1717.68 1340.04) a player meets two Tomo, the leatherworking supplies
--   vendor, at the same spot, both with spawn mask 1, phase mask 1 and no phase id.
-- Cause: the sniffs put 43381 in phase 194 (the normal Hyjal phase) and 53781 in phase 426, the Molten Front
--   (Firelands Invasion) daily stage. Our core only grants phase 194 in Hyjal (phase_area, no condition) and has no
--   rule that grants phase 426, so with phase id 0 both copies show for everyone.
-- Change: delete the phase 426 copy (guid 375462) and its creature_addon row (sheath state only), as was done for
--   six other pairs in the previous update. Both templates have the same npcflag 3200, faction and unit flags and no
--   gossip menu, script or AI; both have the same 10 vendor items; neither has a quest starter, quest ender or
--   trainer row. No formation, linked respawn, game event, pool, waypoint or smart script row refers to the guid,
--   and each entry has exactly one spawn. The kept spawn 285135 (entry 43381) has the same position, model and health.
-- Source: the Cataclysm Preservation world database (built from sniffs): creature PhaseId per spawn (43381 = 194,
--   53781 = 426) and phase_area, Wowpedia "Firelands Invasion". Checked 15-11-2026.
-- Rollback:
--   INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
--   (375462,53781,1,616,4989,1,1,0,0,33338,0,5184,-1717.68,1340.04,2.6529,300,0,0,0,44679,8338,0,0,0,0,0,0,'',0,0);
--   INSERT INTO `creature_addon` (`guid`,`path_id`,`mount`,`MountCreatureID`,`StandState`,`AnimTier`,`VisFlags`,`SheathState`,`PvPFlags`,`emote`,`aiAnimKit`,`movementAnimKit`,`meleeAnimKit`,`visibilityDistanceType`,`auras`) VALUES
--   (375462,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL);
DELETE FROM `creature_addon` WHERE `guid` = 375462;
DELETE FROM `creature` WHERE `guid` = 375462 AND `id` = 53781;
