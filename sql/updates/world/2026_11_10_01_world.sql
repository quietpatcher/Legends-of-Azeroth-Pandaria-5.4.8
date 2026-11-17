-- To-do 449 (rest): Beastmaster's Hunt turn-ins that could not be handed in.
-- 1) Beastmaster's Hunt: The Tiger (32162/32165) and The Crab (32163/32166) end at a Mound of Dirt (216162/216163) that had no
--    spawn in Krasarang Wilds. Spawn both at the turn-in point of their quest POI (QuestPOI index -1, client data). The Crane
--    mound (216161, guid 4310220) sits exactly on its POI turn-in point (-2045,1110), so the same rule is used here.
--    z = ground height read with .gps on the test server: Tiger 13.21, Crab 2.88.
-- Source: quest_poi / quest_poi_points (turn-in points 32162: -1402,2297; 32163: -1425,309).
-- Rollback: DELETE FROM `gameobject` WHERE `guid` IN (4310221,4310222); (part 2: see below)
DELETE FROM `gameobject` WHERE `guid` IN (4310221,4310222);
INSERT INTO `gameobject` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`position_x`,`position_y`,`position_z`,`orientation`,`rotation0`,`rotation1`,`rotation2`,`rotation3`,`spawntimesecs`,`animprogress`,`state`,`ScriptName`,`VerifiedBuild`) VALUES
(4310221,216162,870,0,0,1,1,0,0,-1402,2297,13.21,0,0,0,0,1,120,255,1,'',0),
(4310222,216163,870,0,0,1,1,0,0,-1425,309,2.88,0,0,0,0,1,120,255,1,'',0);

-- 2) All three Mound of Dirt objects (also the Crane one that was already spawned) could not be clicked: their template addon
--    carries GO_FLAG_INTERACT_COND (4), so the client only lets a player use them when the server marks them with
--    GO_DYNFLAG_LO_ACTIVATE, and this core only sets that flag for chests and goobers, never for quest giver objects (type 2).
--    Tested on the test server: quest complete, yellow ? on the mound, right-click does nothing. Without the flag the client
--    sends the use, and the server shows the turn-in window only to players who have the quest.
-- Rollback (part 2): UPDATE `gameobject_template_addon` SET `flags`=`flags`|4 WHERE `entry` IN (216161,216162,216163);
UPDATE `gameobject_template_addon` SET `flags`=`flags`&~4 WHERE `entry` IN (216161,216162,216163);
