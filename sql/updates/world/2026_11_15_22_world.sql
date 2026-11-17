-- Service NPCs and a quest object of the review of 15-11-2026: one trainer position, one duplicate trainer spawn and three
--   missing spawns of the Half-Buried Bottle.
-- What a player sees today: Kylanna Windwhisper (Feralas, 7948) stands 17 yards from the spot where she was seen in the
--   sniffs, the Orgrimmar trainer Muraga (46741) stands twice (two spawns 13 yards apart), and only 2 of the 5 Half-Buried
--   Bottles (quest "Message in a Bottle", Cape of Stranglethorn) exist, so the quest has too few places to start from.
-- Cause: Kylanna's position comes from an older database; Muraga has one spawn too many (the sniff-based reference has one,
--   and guid 266023 already stands exactly there); three bottle spawns of the reference were never added.
-- Checked: Kylanna is stationary (MovementType 0, no creature_addon, waypoint, smart script or script name) and the reference
--   has one spawn of her (phase id 169 = default phase). Muraga guid 194709 has no creature_addon, formation, linked respawn,
--   game event, pool, waypoint, smart script, movement override, condition, own quest relation or script name. The bottle
--   spawns have no game event, pool or script name; nothing else stands within 15 yards of them.
-- Change: Kylanna guid 257433 is moved to the reference position and orientation; Muraga duplicate guid 194709 is deleted
--   (266023 stays); three Half-Buried Bottle (204406) spawns are added with the reference values (reference guids 200768,
--   200822, 201060; the reference phase id 169 is the default phase and becomes phase mask 1, phase id 0).
-- Reserved guids: gameobject 4500001-4500009 (used 4500001-4500003).
-- Source: Cataclysm Preservation sniff database (comparison), 15-11-2026.
-- Rollback (the values and rows before this update):
--   UPDATE `creature` SET `position_x`=-4352.95,`position_y`=2200.51,`position_z`=13.5044,`orientation`=5.94668 WHERE `guid`=257433 AND `id`=7948;
--   INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES (194709,46741,1,1637,5167,1,1,0,0,35243,0,1907.07,-4462.99,53.3865,4.50574,300,0,0,0,1220,0,0,0,0,0,0,0,'',0,0);
--   DELETE FROM `gameobject` WHERE `guid` BETWEEN 4500001 AND 4500009;

UPDATE `creature` SET `position_x`=-4367.92,`position_y`=2208.53,`position_z`=13.5192,`orientation`=5.49779 WHERE `guid`=257433 AND `id`=7948;  -- Kylanna Windwhisper (7948), 17.0 yd

DELETE FROM `creature_addon` WHERE `guid`=194709;
DELETE FROM `creature` WHERE `guid`=194709 AND `id`=46741;  -- Muraga (46741), 266023 stays

DELETE FROM `gameobject` WHERE `guid` IN (4500001,4500002,4500003);
INSERT INTO `gameobject` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`position_x`,`position_y`,`position_z`,`orientation`,`rotation0`,`rotation1`,`rotation2`,`rotation3`,`spawntimesecs`,`animprogress`,`state`,`ScriptName`,`VerifiedBuild`) VALUES
(4500001,204406,0,5287,43,1,1,0,0,-14647.9,194.451,-1.00246,0,0,0,0,1,300,255,1,'',0),
(4500002,204406,0,5287,43,1,1,0,0,-14517,126.283,0.163271,0,0,0,0,1,300,255,1,'',0),
(4500003,204406,0,5287,311,1,1,0,0,-13747.6,-353.359,0.138918,0,0,0,0,1,300,255,1,'',0);
