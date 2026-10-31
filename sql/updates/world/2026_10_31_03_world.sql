-- To-do 449 part c (quest NPCs/objects without any spawn, state/missing_spawns/INDEX.md): spawns copied from reference DBs, only for candidates that
-- were checked as active in 5.4.8 (quest in world.quest_template, no event/phase/scene/vehicle dependency, template present). Proposal only, NOT applied.
-- cause: quest enders without any spawn in world.creature / world.gameobject, so the quests could not be handed in.
-- change: 2 creature spawns + 1 gameobject spawn (all map 870, Pandaria), values copied 1:1 from ref_sf (SkyFire 5.4.x), phaseMask 1, spawnMask 1, as in
--         2026_10_30_02/_03 (zoneId/areaId left at default 0, curhealth 1, npcflag/unit_flags 0 = take from template).
-- source (ref_sf table + guid, position cross-checked against Wowhead MoP Classic mapperData of the npc=/object= page, 31-10-2026, consistent in both):
--   66730 Hyuna of the Shrines (Jade Forest, Grand Master Pet Tamer, quest 31953 "Grand Master Hyuna", daily pet battle)  ref_sf.creature  guid 8168148  (Wowhead 48,54)
--   67558 Huntsman Blake (Krasarang Wilds, ender 32170 32171 32172 32184 (+32185/32186 not in quest_template))            ref_sf.creature  guid 8179762  (Wowhead 84.2,18.8)
--   216161 Mound of Dirt (Krasarang Wilds, ender of 32161 + 32164 Beastmaster's Hunt: The Crane, quest item 91819/91854)   ref_sf.gameobject guid 261859 (Wowhead 39.2,62)
-- Reserved guids: creature 5127720-5127729 (used 5127720-5127721), gameobject 4310220-4310229 (used 4310220). Current max: creature 5127656, gameobject 4310102.
-- Not included (see proposal_449c.md): 14504 17288 20604 20612 29346 47006 59569 65723, gameobject 148512.
-- Not covered here: Mound of Dirt 216162 (Tiger) / 216163 (Crab): no reference spawn (only Wowhead 13.8,41.3 and 56.3,42.2) -> open on the to-do.
-- Repeatable: DELETE own guids first, then INSERT.
--
-- Rollback: DELETE FROM `creature` WHERE `guid` BETWEEN 5127720 AND 5127729; DELETE FROM `gameobject` WHERE `guid` BETWEEN 4310220 AND 4310229;

-- 1) creature: Hyuna of the Shrines, Huntsman Blake
DELETE FROM `creature` WHERE `guid` BETWEEN 5127720 AND 5127729;
INSERT INTO `creature` (`guid`,`id`,`map`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5127720,66730,870,1,1,0,0,0,0,1130.8,-1897.38,136.385,6.10732,120,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127721,67558,870,1,1,0,0,0,0,-699.385,-1005.14,33.9245,2.05474,120,0,0,0,1,0,0,0,0,0,0,0,'',0,0);

-- 2) gameobject: Mound of Dirt (Crane)
DELETE FROM `gameobject` WHERE `guid` BETWEEN 4310220 AND 4310229;
INSERT INTO `gameobject` (`guid`,`id`,`map`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`position_x`,`position_y`,`position_z`,`orientation`,`rotation0`,`rotation1`,`rotation2`,`rotation3`,`spawntimesecs`,`animprogress`,`state`,`ScriptName`,`VerifiedBuild`) VALUES
(4310220,216161,870,1,1,0,0,-2045.13,1110.06,5.25088,6.2599,0,0,0,1,120,255,1,'',0);
