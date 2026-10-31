-- To-do 449 (quest NPCs without any spawn, TURN-IN BLOCKED list, state/missing_spawns/INDEX.md): spawn the quest enders that have no spawn in our world DB,
-- so players can hand in the quest. One spawn per NPC unless a second position is known. Coordinates: ref DB position (comparison material), zone and
-- spawn count checked against Wowhead (g_mapperData of npc= pages, 30-10-2026):
--   43818 Maruut Stonebinder, Deepholm (map 646): ref_cpp + ref_alex agree (995.613 521.274 -49.2591 and 980.276 519.708 -49.3348); Wowhead 2 spawns (49.4,52.8) (49.6,53). Quests 26833, 26875.
--   13158 Lieutenant Sanders, Tirisfal Glades (map 0): ref_alex + ref_sf agree (2533.34 -920.672 60.9892); Wowhead: cluster at 86-88,43-44 (6 points, we add 1). Quests 25010, 25046.
--   20482 Image of Commander Ameer, Netherstorm (map 530): ref_sf (4017.97 2315.8 114.946); Wowhead 2 points at (56.8,38.4). Quests 10339, 10384, 10385.
--   63277 Dog, Dread Wastes (map 870): ref_sf (-1126.02 3221.82 -2.2539); Wowhead (54.4,71.2). Quest 31186.
--   67537 Daxil "The Gem" Oregrind, Krasarang Wilds (map 870): ref_sf (-2059.21 1889.71 1.34689); Wowhead (22.4,62.2). Quests 32140, 32141.
-- Not verified: exact retail position within the Wowhead cluster, orientation, wander/movement (placed standing still).
-- Rollback: DELETE FROM `creature` WHERE `guid` BETWEEN 5127641 AND 5127646;
DELETE FROM `creature` WHERE `guid` BETWEEN 5127641 AND 5127646;
INSERT INTO `creature` (`guid`,`id`,`map`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5127641,43818,646,1,1,0,0,0,0,995.613,521.274,-49.2591,0.20944,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127642,43818,646,1,1,0,0,0,0,980.276,519.708,-49.3348,5.4839,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127643,13158,0,1,1,0,0,0,0,2533.34,-920.672,60.9892,4.53786,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127644,20482,530,1,1,0,0,0,0,4017.97,2315.8,114.946,0.436332,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127645,63277,870,1,1,0,0,0,0,-1126.02,3221.82,-2.2539,3.42548,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127646,67537,870,1,1,0,0,0,0,-2059.21,1889.71,1.34689,6.24666,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0);
