-- To-do 405 (SmartAI check on mobs, batch 2: DunMorogh, ElwynnForest, Teldrassil, AzuremystIsle, BloodmystIsle, Gilneas, GilneasCity, RuinsofGilneas, TheWanderingIsle): 15 creatures cast spells on retail but have no script, or only the old 3.3.5 script, in our world DB.
-- Cause: our smart_scripts for these entries come from the alexkulya import (identical to ref_alex) or are missing; the Cataclysm sniff data (ref_cpp) has SmartAI with the retail casts for them.
-- Change: port the ref_cpp SmartAI (smart_scripts source_type 0 + 5 timed action lists) for 15 creatures (6 new, 9 replacing an unchanged alexkulya script); AIName set to SmartAI for 4 entries that had none.
-- Schema/enum mapping: target_param4 = 0; event_flags 512 (WHILE_CHARMED in TC master; RAID40 difficulty in our core, would disable the event) dropped, 256 -> 0x10000 (DONT_RESET); action 27 COMBAT_STOP -> 203, 85 SELF_CAST -> 11 CAST with flag 0x10, 134 INVOKER_CAST -> 85; cast triggerFlags/targetsLimit (param3/4) = 0.
-- Source: ref_cpp (Cataclysm Preservation Project TDB434.22011, sniff-based) smart_scripts/creature_text/waypoints/conditions, rows copied 1:1 apart from the mapping above. Every spell id checked against the 5.4.8 client Spell.dbc + SpellEffect.dbc on dev (exists, has effects, name matches the ref_cpp comment). Not yet seen in game.
-- Rollback: rollback/405_batch2_rollback.sql (re-inserts the 9 replaced old scripts, deletes the ported rows, resets AIName for the 4 entries that had none).
-- Rollback (short, loses the replaced old scripts of 1115,6123,1119,1961,2000,2015,2030,7234,20556): DELETE FROM smart_scripts WHERE source_type=0 AND entryorguid IN (41478,1115,6123,1119,10611,1961,1679,2009,2000,2015,2030,7234,20556,36207,35504); DELETE FROM smart_scripts WHERE source_type=9 AND entryorguid IN (6800,6801,6802,6803,6804); UPDATE creature_template SET AIName='' WHERE entry IN (41478,10611,36207,35504);

-- 41478 Snow Tracker Wolf (DunMorogh, 77 spawns): insert, 3 rows, 1 casts: 32918 Chilling Howl [e6/a166]
-- 1115 Rockjaw Skullthumper (DunMorogh, 40 spawns): replace, 2 rows, 2 casts: 69851 Club [e2/a0,e98/a0]; 3148 Head Crack [e6/a80]
-- 6123 Dark Iron Spy (DunMorogh, 22 spawns): replace, 3 rows, 2 casts: 14873 Sinister Strike [e31/a0]; 3583 Deadly Poison [e6/a3]
-- 1119 Hammerspine (DunMorogh, 2 spawns): replace, 2 rows, 1 casts: 18501 Enrage [e6/a13,e6/a138]
-- 10611 Shorty (DunMorogh, 1 spawns): insert, 13 rows, 2 casts: 18655 Mortar Animate [e86/a0]; 16786 Mortar Shot [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 9 rows
-- 1961 Mangeclaw (DunMorogh, 1 spawns): replace, 2 rows, 2 casts: 75002 Leaping Rush [e41/a0,e31/a0]; 3242 Ravage [e31/a0,e6/a12]
-- 1679 Avarus Kharag (DunMorogh, 1 spawns): insert, 1 rows, 1 casts: 13005 Hammer of Justice [e6/a12]
-- 2009 Gnarlpine Shaman (Teldrassil, 31 spawns): insert, 3 rows, 2 casts: 15039 Flame Shock [e2/a0,e6/a3]; 11986 Healing Wave [e10/a0]
-- 2000 Webwood Silkspinner (Teldrassil, 17 spawns): replace, 2 rows, 2 casts: 12023 Web [e6/a26,e64/a0]; 11918 Poison [e6/a3]
-- 2015 Bloodfeather Harpy (Teldrassil, 13 spawns): replace, 2 rows, 1 casts: 6958 Blood Leech [e9/a0]
-- 2030 Elder Timberling (Teldrassil, 9 spawns): replace, 3 rows, 3 casts: 324 Lightning Shield [e6/a4,e6/a87]; 26364 Lightning Shield [e2/a0]; 84036 Healing Wave [e10/a0]
-- 7234 Ferocitas the Dream Eater (Teldrassil, 1 spawns): replace, 2 rows, 2 casts: 12787 Thrash [e6/a42]; 78921 Dream Lash [e2/a0]
-- 20556 Stormwind Marine (AzuremystIsle, 2 spawns): replace, 35 rows, 3 casts: 12170 Revenge [e2/a0]; 12169 Shield Block [e6/a51]; 6660 Shoot [e2/a0]
-- 36207 Forsaken Assassin (Gilneas, 1 spawns): insert, 3 rows, 1 casts: 75360 Backstab [e31/a0,e6/a89]
-- 35504 Gilneas City Guard (GilneasCity, 11 spawns): insert, 2 rows, 1 casts: 67595 Shoot [e1/a0]

DELETE FROM `smart_scripts` WHERE `source_type`=0 AND `entryorguid` IN (41478,1115,6123,1119,10611,1961,1679,2009,2000,2015,2030,7234,20556,36207,35504);
DELETE FROM `smart_scripts` WHERE `source_type`=9 AND `entryorguid` IN (6800,6801,6802,6803,6804);
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (41478,10611,36207,35504);
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(41478,0,0,1,1,0,10,0,30000,600000,120000,600000,0,4,1018,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Snow Tracker Wolf - Out of Combat - Play Sound 1018'),
(41478,0,1,0,61,0,100,0,30000,600000,120000,600000,0,5,393,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Snow Tracker Wolf - Out of Combat - Play Emote 393'),
(41478,0,2,0,0,0,100,0,9000,10000,20000,25000,0,11,32918,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Snow Tracker Wolf - In Combat - Cast \'Chilling Howl\''),
(1115,0,0,0,0,0,100,0,3500,4500,12000,13000,0,11,69851,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Rockjaw Skullthumper - In Combat - Cast \'Club\''),
(1115,0,1,0,0,0,100,0,8000,10000,22000,25000,0,11,3148,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Rockjaw Skullthumper - In Combat - Cast \'Head Crack\''),
(6123,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Spy - Between 0-15% Health - Flee For Assist (No Repeat)'),
(6123,0,1,0,0,0,100,0,3000,4500,11500,17500,0,11,14873,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Spy - In Combat - Cast \'Sinister Strike\''),
(6123,0,2,0,0,0,100,0,8000,11000,27000,32000,0,11,3583,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Spy - In Combat - Cast \'Deadly Poison\''),
(1119,0,0,1,2,0,100,1,0,30,0,0,0,11,18501,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hammerspine - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(1119,0,1,0,61,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hammerspine - Between 0-30% Health - Say Line 0 (No Repeat)'),
(10611,0,0,1,38,0,100,0,1,0,0,0,0,69,0,0,0,0,0,0,8,0,0,0,0,-6031.59,-228.182,414.404,2.0,'Shorty - On Data Set 1 0 - Move To Position'),
(10611,0,1,0,61,0,100,0,1,0,0,0,0,48,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Shorty - On Data Set 1 0 - Set Active On'),
(10611,0,2,0,38,0,100,0,2,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,2.18492,'Shorty - On Data Set 2 0 - Set Orientation 2,18492'),
(10611,0,3,0,38,0,100,0,3,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,2.84489,'Shorty - On Data Set 3 0 - Set Orientation 2.844887'),
(10611,0,4,0,38,0,100,0,4,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,4.54215,'Shorty - On Data Set 4 0 - Set Orientation 4.54215'),
(10611,0,5,0,38,0,100,0,5,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,2.84489,'Shorty - On Data Set 4 0 - Set Orientation 2.844887'),
(10611,0,6,0,38,0,100,0,6,0,0,0,0,11,18655,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Shorty - On Data Set 6 0 - Cast \'Mortar Animate\''),
(10611,0,7,0,38,0,100,0,7,0,0,0,0,11,16786,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Shorty - On Data Set 7 0 - Cast \'Mortar Shot\''),
(10611,0,8,0,38,0,100,0,8,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,4.54215,'Shorty - On Data Set 8 0 - Set Orientation 4.54215'),
(10611,0,9,0,38,0,100,0,9,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,4.54215,'Shorty - On Data Set 9 0 - Set Orientation 4.54215'),
(10611,0,10,0,38,0,100,0,10,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,2.84489,'Shorty - On Data Set 10 0 - Set Orientation 2.844887'),
(10611,0,11,0,38,0,100,0,11,0,0,0,0,69,0,0,0,0,0,0,8,0,0,0,0,-6007.46,-202.158,407.448,2.0,'Shorty - On Data Set 11 0 - Move To Position'),
(10611,0,12,0,38,0,100,0,12,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,2.47837,'Shorty - On Data Set 12 0 - Set Orientation 2.478368'),
(1961,0,0,0,4,0,100,1,0,0,0,0,0,11,75002,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Mangeclaw - On Aggro - Cast \'Leaping Rush\' (No Repeat)'),
(1961,0,1,0,0,0,100,0,3000,4500,12000,14500,0,11,3242,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Mangeclaw - In Combat - Cast \'Ravage\''),
(1679,0,0,0,0,0,100,0,6000,8000,11000,15000,0,11,13005,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Avarus Kharag - In Combat - Cast \'Hammer of Justice\' (No Repeat)'),
(2009,0,0,0,2,0,100,1,0,30000,0,30000,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Gnarlpine Shaman - Between 0-15% Health - Flee For Assist (No Repeat)'),
(2009,0,1,0,0,0,100,0,2000,4000,12000,13000,0,11,15039,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gnarlpine Shaman - IC - Cast Flame Shock'),
(2009,0,2,0,0,0,100,0,6000,8000,13000,16000,0,11,11986,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Gnarlpine Shaman - IC - Cast Healing Wave'),
(2000,0,0,0,9,0,100,0,0,30,17000,20000,0,11,12023,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Webwood Silkspinner - Within 0-30 Range - Cast \'Web\''),
(2000,0,1,0,0,0,100,0,2000,4000,15000,17000,0,11,11918,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Webwood Silkspinner - IC - Cast Poison'),
(2015,0,0,0,4,0,100,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bloodfeather Harpy - On Aggro - Say Line 0 (No Repeat)'),
(2015,0,1,0,9,0,100,0,0,5,6000,9000,0,11,6958,0,0,0,0,0,2,1,0,0,0,0.0,0.0,0.0,0.0,'Bloodfeather Harpy - Within 0-5 Range - Cast \'Blood Leech\''),
(2030,0,0,0,1,0,40,1,1000,1000,0,0,0,11,324,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Elder Timberling - Out of Combat - Cast \'Lightning Shield\' (No Repeat)'),
(2030,0,1,0,1,0,70,1,1000,1000,0,0,0,11,26364,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Elder Timberling - Out of Combat - Cast \'Lightning Shield\' (No Repeat)'),
(2030,0,2,0,2,0,80,0,0,30000,5000,30000,0,11,84036,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Elder Timberling - Between 0-30% Health - Cast \'Healing Wave\' (No Repeat)'),
(7234,0,0,0,0,0,70,0,2000,2000,5000,5000,0,11,12787,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ferocitas the Dream Eater - In Combat - Cast \'Thrash\''),
(7234,0,1,0,0,0,100,0,2000,4000,5000,7000,0,11,78921,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ferocitas the Dream Eater - IC - Cast Dream Lash'),
(20556,0,0,0,9,0,100,0,0,5,8000,12000,0,11,12170,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - Within 0-5 Range - Cast \'Revenge\''),
(20556,0,1,0,0,0,100,0,3000,5000,9000,14000,0,11,12169,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - In Combat - Cast \'Shield Block\''),
(20556,0,2,0,0,0,100,0,0,0,2000,4000,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - In Combat - Cast \'Shoot\''),
(20556,0,3,0,22,0,100,0,101,5000,5000,0,0,80,6800,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - On Received Emote \'Wave\' - Run Script'),
(20556,0,4,0,22,0,100,0,78,5000,5000,0,0,80,6801,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - On Received Emote \'Salute\' - Run Script'),
(20556,0,5,0,22,0,100,0,58,5000,5000,0,0,80,6802,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - On Received Emote \'Kiss\' - Run Script'),
(20556,0,6,0,22,0,100,0,84,5000,5000,0,0,80,6803,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - On Received Emote \'Shy\' - Run Script'),
(20556,0,7,0,22,0,100,0,77,5000,5000,0,0,80,6804,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - On Received Emote \'Rude\' - Run Script'),
(20556,0,8,0,22,0,100,0,22,5000,5000,0,0,80,6804,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - On Received Emote \'Chicken\' - Run Script'),
(20556,0,9,0,22,0,100,0,17,5000,5000,0,0,80,6802,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Marine - On Received Emote \'Bow\' - Run Script'),
(6802,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6802,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6802,9,2,0,0,0,100,0,2000,2000,0,0,0,5,2,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Bow\''),
(6802,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6802,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(6804,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6804,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6804,9,2,0,0,0,100,0,2000,2000,0,0,0,5,25,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Point\''),
(6804,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6804,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(6803,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6803,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6803,9,2,0,0,0,100,0,2000,2000,0,0,0,5,23,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Flex\''),
(6803,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6803,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(6801,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6801,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6801,9,2,0,0,0,100,0,2000,2000,0,0,0,5,66,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Salute\''),
(6801,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6801,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(6800,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6800,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6800,9,2,0,0,0,100,0,2000,2000,0,0,0,5,3,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Wave\''),
(6800,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6800,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(36207,0,0,1,54,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On just summoned - Self: Talk 0 // '),
(36207,0,1,0,61,0,100,0,0,0,0,0,0,49,0,0,0,0,0,0,23,0,0,0,0,0.0,0.0,0.0,0.0,' Linked - Self: Attack Owner/Summoner // '),
(36207,0,2,0,67,0,100,0,9000,12000,0,0,0,11,75360,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When victim is behind me (wait 9000 - 12000 ms before next event trigger) - Self: Cast spell 75360 on Victim // Forsaken Assassin - On Behind Target - Cast \'Backstab\''),
(35504,0,0,0,0,0,100,0,0,0,2000,2000,0,11,67595,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 0 and 0 ms (and later repeats every 2000 and 2000 ms) - Self: Cast spell 67595 on Victim // '),
(35504,0,1,0,1,0,100,0,2000,2000,2000,2000,0,49,0,0,0,0,0,0,11,35505,20,0,0,0.0,0.0,0.0,0.0,'When out of combat and timer at the begining between 2000 and 2000 ms (and later repeats every 2000 and 2000 ms) - Self: Attack Creature Bloodfang Ripper (35505) in 20 yd // ');
