-- To-do 405 (SmartAI check on mobs, batch 3: TheBarrens, SilverpineForest, StonetalonMountains, SouthernBarrens, HillsbradFoothills, Azshara): 31 creatures cast spells on retail but have no script, or only the old 3.3.5 script, in our world DB.
-- Cause: our smart_scripts for these entries come from the alexkulya import (identical to ref_alex) or are missing; the Cataclysm sniff data (ref_cpp) has SmartAI with the retail casts for them.
-- Change: port the ref_cpp SmartAI (smart_scripts source_type 0) for 31 creatures (9 new, 22 replacing an unchanged alexkulya script); AIName set to SmartAI for 8 entries that had none.
-- Schema/enum mapping: target_param4 = 0; event_flags 512 (WHILE_CHARMED in TC master; RAID40 difficulty in our core, would disable the event) dropped, 256 -> 0x10000 (DONT_RESET); action 27 COMBAT_STOP -> 203, 85 SELF_CAST -> 11 CAST with flag 0x10, 134 INVOKER_CAST -> 85; cast triggerFlags/targetsLimit (param3/4) = 0.
-- Source: ref_cpp (Cataclysm Preservation Project TDB434.22011, sniff-based) smart_scripts/creature_text/waypoints/conditions, rows copied 1:1 apart from the mapping above. Every spell id checked against the 5.4.8 client Spell.dbc + SpellEffect.dbc on dev (exists, has effects, name matches the ref_cpp comment). Not yet seen in game.
-- Rollback: rollback/405_batch3_rollback.sql (re-inserts the 22 replaced old scripts, deletes the ported rows, resets AIName for the 8 entries that had none).
-- Rollback (short, loses the replaced old scripts of 8761,36873,3461,3265,3268,3271,9458,3270,3672,5835,3452,1913,1888,2628,2242,14221,2386,2416,3261,3375,5859,5829): DELETE FROM smart_scripts WHERE source_type=0 AND entryorguid IN (8761,36972,36873,3461,3265,3268,3271,9458,3270,3672,5835,3452,45883,1913,46040,1888,44367,2628,2242,14221,2386,2416,34917,40904,34961,3261,3375,37924,5859,5829,5863); DELETE FROM smart_scripts WHERE source_type=9 AND entryorguid IN (0); UPDATE creature_template SET AIName='' WHERE entry IN (36972,45883,46040,44367,34917,40904,34961,37924);

-- 8761 Mosshoof Courser (Azshara, 89 spawns): replace, 4 rows, 3 casts: 8599 Enrage [e6/a79,e6/a138]; 22120 Charge [e96/a0,e58/a0]; 31274 Knockdown [e6/a12,e2/a0]
-- 36972 Grit (Azshara, 3 spawns): insert, 2 rows, 2 casts: 69375 Lob Fire [e165/a0,e27/a89]; 69359 Flamethrower [e6/a89]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows
-- 36873 High Priestess Silthera (Azshara, 1 spawns): replace, 3 rows, 2 casts: 9734 Holy Smite [e2/a0]; 11639 Shadow Word: Pain [e6/a3]
-- 3461 Oasis Snapjaw (TheBarrens, 38 spawns): replace, 2 rows, 2 casts: 80604 Crushing Bite [e31/a0,e6/a101]; 6530 Sling Dirt [e6/a54]
-- 3265 Razormane Hunter (TheBarrens, 26 spawns): replace, 3 rows, 2 casts: 6660 Shoot [e2/a0]; 6479 Razormane Wolf [e56/a0]
-- 3268 Razormane Thornweaver (TheBarrens, 8 spawns): replace, 2 rows, 2 casts: 21335 Thorns [e6/a15]; 6950 Faerie Fire [e6/a101]
-- 3271 Razormane Mystic (TheBarrens, 5 spawns): replace, 4 rows, 3 casts: 9613 Shadow Bolt [e2/a0]; 26364 Lightning Shield [e2/a0]
-- 9458 Horde Axe Thrower (TheBarrens, 3 spawns): replace, 1 rows, 1 casts: 10277 Throw [e2/a0]
-- 3270 Elder Mystic Razorsnout (TheBarrens, 2 spawns): replace, 2 rows, 2 casts: 75068 Lava Burst [e2/a0]; 39591 Searing Totem [e28/a0]
-- 3672 Boahn (TheBarrens, 2 spawns): replace, 3 rows, 2 casts: 9532 Lightning Bolt [e2/a0]; 20790 Healing Touch [e10/a0]
-- 5835 Foreman Grills (TheBarrens, 1 spawns): replace, 3 rows, 3 casts: 7165 Battle Stance [e6/a36]; 9080 Hamstring [e31/a0,e6/a33]; 6531 Overseer's Poison [e6/a3]
-- 3452 Serena Bloodfeather (TheBarrens, 1 spawns): replace, 2 rows, 2 casts: 3264 Blood Howl [e6/a14]; 39068 Feather Burst [e2/a0,e98/a0]
-- 45883 7th Legion Scout (SilverpineForest, 73 spawns): insert, 5 rows, 5 casts: 84442 Stealth [e6/a16]; 79862 Backstab [e31/a0]; 79584 Fan of Knives [e2/a0]; 80576 Shadowstep [e5/a0]
-- 1913 Ambermill Warder (SilverpineForest, 22 spawns): replace, 3 rows, 2 casts: 3248 Improved Blocking [e6/a51]; 86817 Spell Ward [e6/a69]
-- 46040 7th Legion Scout (SilverpineForest, 12 spawns): insert, 5 rows, 5 casts: 84442 Stealth [e6/a16]; 79862 Backstab [e31/a0]; 79584 Fan of Knives [e2/a0]; 80576 Shadowstep [e5/a0]
-- 1888 Ambermill Watcher (SilverpineForest, 11 spawns): replace, 5 rows, 4 casts: 17140 Holy Fire [e2/a0,e6/a3]; 11640 Renew [e6/a8]; 48168 Inner Fire [e6/a101,e6/a136,e6/a79]
-- 44367 Forest Ettin (SilverpineForest, 4 spawns): insert, 2 rows, 2 casts: 80146 Bonk [e31/a0,e6/a49,e6/a47]; 88421 Log Smash [e31/a0,e144/a0]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows
-- 2628 Dalaran Worker (HillsbradFoothills, 41 spawns): replace, 1 rows, 1 casts: 33661 Crush Armor [e6/a101]
-- 2242 Syndicate Spy (HillsbradFoothills, 35 spawns): replace, 3 rows, 3 casts: 22766 Sneak [e6/a16,e6/a33]; 7159 Backstab [e58/a0]
-- 14221 Gravis Slipknot (HillsbradFoothills, 2 spawns): replace, 1 rows, 1 casts: 18501 Enrage [e6/a13,e6/a138]
-- 2386 Alliance Guard (HillsbradFoothills, 2 spawns): replace, 2 rows, 2 casts: 12170 Revenge [e2/a0]; 12169 Shield Block [e6/a51]
-- 2416 Crushridge Plunderer (HillsbradFoothills, 2 spawns): replace, 2 rows, 2 casts: 9143 Bomb [e58/a0]; 15496 Cleave [e31/a0]
-- 34917 Invading Tendril (StonetalonMountains, 34 spawns): insert, 4 rows, 2 casts: 62975 Shadow Bolt [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 4 rows
-- 40904 Krom'gar Peon (StonetalonMountains, 23 spawns): insert, 2 rows, 2 casts: 76565 Throw Iron Ore [e32/a0,e3/a0,e86/a0]; 76576 Clear Summoned Ore [e86/a0]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows
-- 34961 Invading Crusher (StonetalonMountains, 9 spawns): insert, 4 rows, 2 casts: 62975 Shadow Bolt [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 4 rows
-- 3261 Bristleback Thornweaver (SouthernBarrens, 15 spawns): replace, 3 rows, 2 casts: 9739 Wrath [e2/a0]; 12747 Entangling Roots [e6/a26,e6/a3]
-- 3375 Bael'dun Foreman (SouthernBarrens, 10 spawns): replace, 3 rows, 2 casts: 32064 Battle Shout [e6/a99]; 6257 Torch Toss [e2/a0,e6/a3]
-- 37924 Barrens Operative (SouthernBarrens, 8 spawns): insert, 5 rows, 5 casts: 22766 Sneak [e6/a16,e6/a33]; 37685 Backstab [e31/a0]; 80576 Shadowstep [e5/a0]; 14902 Cheap Shot [e6/a12]
-- 5859 Hagg Taurenbane (SouthernBarrens, 2 spawns): replace, 4 rows, 4 casts: 7165 Battle Stance [e6/a36]; 40505 Cleave [e31/a0]; 13730 Demoralizing Shout [e6/a99]; 9080 Hamstring [e31/a0,e6/a33]
-- 5829 Snort the Heckler (SouthernBarrens, 2 spawns): replace, 2 rows, 2 casts: 3604 Tendon Rip [e6/a33]; 7951 Toxic Spit [e2/a0]
-- 5863 Geopriest Gukk'rok (SouthernBarrens, 2 spawns): insert, 4 rows, 4 casts: 75068 Lava Burst [e2/a0]; 80117 Earth Spike [e32/a0]; 79927 Earth Shield [e6/a42]

DELETE FROM `smart_scripts` WHERE `source_type`=0 AND `entryorguid` IN (8761,36972,36873,3461,3265,3268,3271,9458,3270,3672,5835,3452,45883,1913,46040,1888,44367,2628,2242,14221,2386,2416,34917,40904,34961,3261,3375,37924,5859,5829,5863);
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (36972,45883,46040,44367,34917,40904,34961,37924);
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(8761,0,0,1,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Mosshoof Courser - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(8761,0,1,0,61,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Mosshoof Courser - Between 0-30% Health - Say Line 0 (No Repeat)'),
(8761,0,2,0,4,0,100,1,0,0,0,0,0,11,22120,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Mosshoof Courser - On Aggro - Cast \'Charge\' (No Repeat)'),
(8761,0,3,0,0,0,100,0,4000,7000,15000,18000,0,11,31274,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Mosshoof Courser - In Combat - Cast \'Knockdown\''),
(36972,0,0,0,9,0,100,0,8,40,4000,6000,0,11,69375,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Grit - Within 8-40 Range - Cast \'Lob Fire\''),
(36972,0,1,0,0,0,100,0,5000,7000,15000,22000,0,11,69359,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Grit - In Combat - Cast \'Flamethrower\''),
(36873,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9734,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'High Priestess Silthera - In Combat - Cast \'Holy Smite\''),
(36873,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'High Priestess Silthera - Between 0-15% Health - Flee For Assist (No Repeat)'),
(36873,0,2,0,0,0,100,0,5000,7000,25000,28000,0,11,11639,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'High Priestess Silthera - In Combat - Cast \'Shadow Word: Pain\''),
(3461,0,0,0,0,0,100,0,2000,7000,18000,26000,0,11,80604,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Oasis Snapjaw - In Combat - Cast \'Crushing Bite\''),
(3461,0,1,0,0,0,100,0,4000,9000,15000,22000,0,11,6530,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Oasis Snapjaw - In Combat - Cast \'Sling Dirt\''),
(3265,0,0,0,0,0,100,0,0,0,2300,3900,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Hunter - In Combat - Cast Shoot'),
(3265,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Hunter - HP@15 - Flee For Assist (No Repeat)'),
(3265,0,2,0,25,0,100,0,0,0,0,0,0,11,6479,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Hunter- On Reset - Cast to summon Razormane Wolf'),
(3268,0,0,0,1,0,100,0,500,1000,600000,600000,0,11,21335,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Thornweaver - Out of Combat - Cast \'Thorns\''),
(3268,0,1,0,0,0,100,0,3000,4500,20000,25000,0,11,6950,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Thornweaver - In Combat - Cast \'Faerie Fire\''),
(3271,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9613,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Mystic - In Combat - Cast \'Shadow Bolt\''),
(3271,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Mystic - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3271,0,2,0,1,0,100,0,500,1000,600000,600000,0,11,26364,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Mystic - Out of Combat - Cast \'Lightning Shield\''),
(3271,0,3,0,16,0,100,0,26364,1,15000,30000,0,11,26364,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Mystic - On Friendly Unit Missing Buff \'Lightning Shield\' - Cast \'Lightning Shield\''),
(9458,0,0,0,0,0,100,0,0,0,2300,3900,0,11,10277,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Horde Axe Thrower - In Combat - Cast \'Throw\''),
(3270,0,0,0,0,0,100,0,4000,5000,18000,22000,0,11,75068,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Elder Mystic Razorsnout - In Combat - Cast \'Lava Burst\''),
(3270,0,1,0,0,0,100,0,3000,6000,15000,27000,0,11,39591,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Elder Mystic Razorsnout - In Combat - Cast \'Searing Totem\''),
(3672,0,0,0,0,0,100,0,0,0,2400,3800,0,11,9532,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Boahn - In Combat CMC - Cast \'Lightning Bolt\'0'),
(3672,0,1,0,2,0,100,0,0,40,30000,40000,0,11,20790,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Boahn - Between 0-40% Health - Cast \'Healing Touch\''),
(3672,0,2,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Boahn - Between 0-15% Health - Flee For Assist (No Repeat)'),
(5835,0,0,0,11,0,100,1,0,0,0,0,0,11,7165,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Foreman Grills - On Respawn - Cast \'Battle Stance\' (No Repeat)'),
(5835,0,1,0,9,0,100,0,0,5,15000,18000,0,11,9080,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Foreman Grills - Within 0-5 Range - Cast \'Hamstring\''),
(5835,0,2,0,0,0,100,0,3000,5000,17000,25000,0,11,6531,32,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Foreman Grills - In Combat - Cast \'Overseer\'s Poison\''),
(3452,0,0,0,0,0,100,0,6000,8000,17000,18000,0,11,3264,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Serena Bloodfeather - In Combat - Cast \'Blood Howl\''),
(3452,0,1,0,0,0,100,0,2000,4000,11000,22000,0,11,39068,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Serena Bloodfeather - In Combat - Cast \'Feather Burst\''),
(45883,0,0,0,11,0,100,1,0,0,0,0,0,11,84442,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - On Respawn - Cast \'Stealth\' (No Repeat)'),
(45883,0,1,0,7,0,100,1,0,0,0,0,0,11,84442,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - On Evade - Cast \'Stealth\' (No Repeat)'),
(45883,0,2,0,67,0,100,0,9000,12000,0,0,0,11,79862,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - On Behind Target - Cast \'Backstab\''),
(45883,0,3,0,9,0,100,0,0,12,13600,14500,0,11,79584,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - Within 0-12 Range - Cast \'Fan of Knives\''),
(45883,0,4,0,2,0,100,1,0,30,0,0,0,11,80576,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - Between 0-30% Health - Cast \'Shadowstep\' (No Repeat)'),
(1913,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Ambermill Warder - Between 0-15% Health - Flee For Assist (No Repeat)'),
(1913,0,1,0,0,0,100,0,6000,6000,18000,22000,0,11,3248,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ambermill Warder - In Combat - Cast \'Improved Blocking\''),
(1913,0,2,0,0,0,100,0,12000,15000,30000,32000,0,11,86817,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ambermill Warder - In Combat - Cast \'Spell Ward\''),
(46040,0,0,0,11,0,100,1,0,0,0,0,0,11,84442,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - On Respawn - Cast \'Stealth\' (No Repeat)'),
(46040,0,1,0,7,0,100,1,0,0,0,0,0,11,84442,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - On Evade - Cast \'Stealth\' (No Repeat)'),
(46040,0,2,0,67,0,100,0,9000,12000,0,0,0,11,79862,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - On Behind Target - Cast \'Backstab\''),
(46040,0,3,0,9,0,100,0,0,12,13600,14500,0,11,79584,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - Within 0-12 Range - Cast \'Fan of Knives\''),
(46040,0,4,0,2,0,100,1,0,30,0,0,0,11,80576,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'7th Legion Scout - Between 0-30% Health - Cast \'Shadowstep\' (No Repeat)'),
(1888,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Ambermill Watcher - Between 0-15% Health - Flee For Assist (No Repeat)'),
(1888,0,1,0,0,0,100,0,4000,5000,15000,17000,0,11,17140,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ambermill Watcher - In Combat - Cast \'Holy Fire\''),
(1888,0,2,0,2,0,100,0,0,40,15000,21000,0,11,11640,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ambermill Watcher - Between 0-40% Health - Cast \'Renew\''),
(1888,0,3,0,14,0,100,0,150,40,15000,18000,0,11,11640,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Ambermill Watcher - Friendly At 150 Health - Cast \'Renew\''),
(1888,0,4,0,1,0,100,0,500,1000,1800000,1800000,0,11,48168,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ambermill Watcher - Out of Combat - Cast \'Inner Fire\''),
(44367,0,0,0,0,0,100,0,5000,7000,17000,22000,0,11,80146,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Forest Ettin - In Combat - Cast \'Bonk\''),
(44367,0,1,0,0,0,100,0,12000,15000,28000,35000,0,11,88421,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Forest Ettin - In Combat - Cast \'Log Smash\''),
(2628,0,0,0,0,0,100,0,5000,6000,15000,19000,0,11,33661,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Crush Armor'),
(2242,0,0,0,11,0,100,1,0,0,0,0,0,11,22766,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sneak on Spawn'),
(2242,0,1,0,7,0,100,1,0,0,0,0,0,11,22766,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sneak on Evade'),
(2242,0,2,0,67,0,100,0,3900,6900,0,0,0,11,7159,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Casts Backstab'),
(14221,0,0,0,2,0,100,1,0,30,0,0,0,11,18501,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Enrage at 30% HP'),
(2386,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,12170,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Revenge'),
(2386,0,1,0,2,0,100,0,0,70,15000,15000,0,11,12169,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shield Block at 70% HP'),
(2416,0,0,0,0,0,100,0,0,0,3500,4100,0,11,9143,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Bomb'),
(2416,0,1,0,9,0,100,0,0,10,15000,25000,0,11,15496,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Cleave on Close'),
(34917,0,0,0,4,0,100,1,0,0,0,0,0,22,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Invading Tendril - On Aggro - Set Event Phase 1 (No Repeat)'),
(34917,0,1,0,4,1,100,1,0,0,0,0,0,21,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Invading Tendril - On Aggro - Disable Combat Movement (Phase 1) (No Repeat)'),
(34917,0,2,0,4,1,100,1,0,0,0,0,0,11,62975,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Invading Tendril - On Aggro - Cast \'Shadow Bolt\' (Phase 1) (No Repeat)'),
(34917,0,3,0,9,1,100,0,5,30,3500,4100,0,11,62975,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Invading Tendril - Within 5-30 Range - Cast \'Shadow Bolt\' (Phase 1)'),
(40904,0,0,1,4,0,100,1,0,0,0,0,0,11,76565,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Krom\'gar Peon - On Aggro - Cast \'Throw Iron Ore\' (No Repeat)'),
(40904,0,1,0,61,0,100,1,0,0,0,0,0,11,76576,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Krom\'gar Peon - On Aggro - Cast \'Clear Summoned Ore\' (No Repeat)'),
(34961,0,0,0,4,0,100,1,0,0,0,0,0,22,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Invading Crusher - On Aggro - Set Event Phase 1 (No Repeat)'),
(34961,0,1,0,4,1,100,1,0,0,0,0,0,21,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Invading Crusher - On Aggro - Disable Combat Movement (Phase 1) (No Repeat)'),
(34961,0,2,0,4,1,100,1,0,0,0,0,0,11,62975,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Invading Crusher - On Aggro - Cast \'Shadow Bolt\' (Phase 1) (No Repeat)'),
(34961,0,3,0,9,1,100,0,5,30,3500,4100,0,11,62975,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Invading Crusher - Within 5-30 Range - Cast \'Shadow Bolt\' (Phase 1)'),
(3261,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9739,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Bristleback Thornweaver - In Combat - Cast \'Wrath\''),
(3261,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Bristleback Thornweaver - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3261,0,2,0,9,0,100,0,0,20,9000,12000,0,11,12747,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Bristleback Thornweaver - Within 0-20 Range - Cast \'Entangling Roots\''),
(3375,0,0,0,4,0,100,1,0,0,0,0,0,11,32064,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bael\'dun Foreman - On Aggro - Cast \'Battle Shout\' (No Repeat)'),
(3375,0,1,0,0,0,100,0,2000,4000,21000,24000,0,11,6257,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Bael\'dun Foreman - In Combat - Cast \'Torch Toss\''),
(3375,0,2,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Bael\'dun Foreman - Between 0-15% Health - Flee For Assist (No Repeat)'),
(37924,0,0,0,11,0,100,1,0,0,0,0,0,11,22766,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Barrens Operative - On Respawn - Cast \'Sneak\' (No Repeat)'),
(37924,0,1,0,7,0,100,1,0,0,0,0,0,11,22766,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Barrens Operative - On Evade - Cast \'Sneak\' (No Repeat)'),
(37924,0,2,0,67,0,100,0,9000,12000,0,0,0,11,37685,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Barrens Operative - On Behind Target - Cast \'Backstab\''),
(37924,0,3,0,2,0,100,0,0,40,18000,22000,0,11,80576,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Barrens Operative - Between 0-40% Health - Cast \'Shadowstep\''),
(37924,0,4,0,9,0,100,0,0,5,24000,26000,0,11,14902,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Barrens Operative - Within 0-5 Range - Cast \'Cheap Shot\''),
(5859,0,0,0,4,0,100,1,0,0,0,0,0,11,7165,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hagg Taurenbane - On Aggro - Cast \'Battle Stance\' (No Repeat)'),
(5859,0,1,0,9,0,100,0,0,5,9000,12000,0,11,40505,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Hagg Taurenbane - Within 0-5 Range - Cast \'Cleave\''),
(5859,0,2,0,9,0,100,0,0,8,25000,30000,0,11,13730,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hagg Taurenbane - Within 0-8 Range - Cast \'Demoralizing Shout\''),
(5859,0,3,0,0,0,100,0,2000,4500,12000,20000,0,11,9080,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Hagg Taurenbane - In Combat - Cast \'Hamstring\''),
(5829,0,0,0,0,0,100,0,2000,3000,12000,15000,0,11,3604,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Snort the Heckler - In Combat - Cast \'Tendon Rip\''),
(5829,0,1,0,0,0,100,0,6000,9000,22000,26000,0,11,7951,32,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Snort the Heckler - In Combat - Cast \'Toxic Spit\''),
(5863,0,0,0,0,0,100,0,5000,8000,18000,25000,0,11,75068,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Geopriest Gukk\'rok - In Combat - Cast \'Lava Burst\''),
(5863,0,1,0,0,0,100,0,2000,3000,15000,15500,0,11,80117,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Geopriest Gukk\'rok - In Combat - Cast \'Earth Spike\''),
(5863,0,2,0,1,0,100,0,500,1000,600000,600000,0,11,79927,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Geopriest Gukk\'rok - Out of Combat - Cast \'Earth Shield\''),
(5863,0,3,0,16,0,100,0,79927,1,15000,30000,0,11,79927,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Geopriest Gukk\'rok - On Friendly Unit Missing Buff \'Earth Shield\' - Cast \'Earth Shield\'');
