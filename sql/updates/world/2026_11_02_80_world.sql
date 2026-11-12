-- To-do 130 (Jade Forest, Alliance: quests without a spawned turn-in NPC): An Unexpected Advantage (30565, prev 30000 The Jade Serpent, next 31362 Last Piece of the Puzzle)
-- has its starter and ender in creature_queststarter/creature_questender (Sully "The Pickle" McLeary, 59550), but 59550 had no spawn, so the quest could not be taken
-- or turned in and the chain to Lorewalker Cho (59620, Pearlfin Village) stopped. Quest items 80176/80177 drop from 59554 (18 spawns), so the quest is completable.
-- Change: spawn 59550 at Pearlfin Village (area 5935), guid 5130130, phaseMask 1 like the other SI:7 agents there (Sully 55282, Rell 66949).
-- Source: Wowhead MoP Classic npc=59550 (g_mapperData, zone 5785, pins 58.4/82.2 and 58.6/82.2; quest=30565 start and end Sully "The Pickle" McLeary);
-- pin 58.6/82.2 converted with WorldMapArea.dbc (5.4.8 client) to -173.6 -2640.2, z = ground height 0.38. Calibration: Wowhead pins of 55282/66949/59620/60970
-- land 4-12 yd from our spawns. ref_sf and ref_alex have the same quest relations and no spawn either. Orientation copied from Sully 55282 (no source for it).
-- Rollback: DELETE FROM `creature` WHERE `guid` = 5130130;

DELETE FROM `creature` WHERE `guid` = 5130130;
INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5130130,59550,870,5785,5935,1,1,0,0,0,0,-173.6,-2640.2,0.38,4.75848,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0);
