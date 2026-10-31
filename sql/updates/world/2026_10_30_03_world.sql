-- To-do 449 (quest NPCs without any spawn, TURN-IN BLOCKED list, state/missing_spawns/INDEX.md), part 2: Wowhead-only positions (no ref DB has these NPCs).
-- Method: Wowhead g_mapperData (npc= page, 30-10-2026, MoP Classic 5.5 data, NOT identical to 5.4.8) percent coordinates converted to world x/y with the
-- 5.4.8 WorldMapArea.dbc bounds (formula checked against the ref_sf Daxil position in 2026_10_30_02: 8 yd off). z = z of the nearest existing creature spawn in the same map
-- (distance in brackets), because Wowhead gives no height. Orientation 0, standing still. Position inside a Wowhead cluster is approximate.
--   8125 Dirge Quikcleave, Gadgetzan Tanaris [3.6 yd]; quests 6610, 6611, 6612.
--   3154 Jen'shan, Sen'jin Village Durotar [4.9 yd]; quest 3087.
--   3309 Karus, Orgrimmar [6.2 yd]; quest 4511.
--   68084 Lor'themar Theron, Silvermoon City [3.7 yd]; quest 32330 (5.4 pre-event NPC).
--   68651 Lady Jaina Proudmoore, Teldrassil [1.6 yd] and Darnassus [12.2 yd], one each as on Wowhead; quests 32414, 32460.
--   19456 Whitebark's Spirit, Eversong Woods [11.3 yd]; quest 10166.
--   36689 Kalecgos, Azshara [8.8 yd]; quest 24467.
--   63359 Skeer the Bloodseeker, Dread Wastes [9.7 yd]; quest 31175.
--   28122 Moodle, Sholazar Basin [4.0 yd]; quests 12578, 12579, 12580.
-- Deliberately NOT spawned (phased/scene/event or no reliable position, left open on the to-do): Thrall 48051 (Maelstrom scene), Ishi 68337, Laird 4200,
-- Zhi 59905, Captain Taylor 44490, Wrathion 58038/73138, Jaina 69741 (Isle of Thunder progress phase), Dragonwrath 53422, and the 72 NPCs without Wowhead coordinates.
-- Rollback: DELETE FROM `creature` WHERE `guid` BETWEEN 5127647 AND 5127656;
DELETE FROM `creature` WHERE `guid` BETWEEN 5127647 AND 5127656;
INSERT INTO `creature` (`guid`,`id`,`map`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5127647,8125,1,1,1,0,0,0,0,-7117.2,-3856.3,9.3,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127648,3154,1,1,1,0,0,0,0,-631.0,-4225.5,38.4,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127649,3309,1,1,1,0,0,0,0,1684.2,-4365.6,21.1,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127650,68084,530,1,1,0,0,0,0,9852.0,-7505.6,19.8,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127651,68651,1,1,1,0,0,0,0,9873.9,1885.4,1325.0,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127652,68651,1,1,1,0,0,0,0,10125.6,2587.1,1325.6,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127653,19456,530,1,1,0,0,0,0,8198.3,-6319.6,64.5,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127654,36689,1,1,1,0,0,0,0,4778.2,-7332.4,127.8,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127655,63359,870,1,1,0,0,0,0,-374.8,4780.2,-29.4,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0),
(5127656,28122,571,1,1,0,0,0,0,5649.5,4559.4,-134.9,0,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0);
