-- To-do 405 (SmartAI check on mobs, remainder 12-11): 23 creature types that fight with retail abilities but have no AI at all in our world DB (AIName and ScriptName empty, npcflag 0).
-- Cause: the first 405 run (batches 1-8, 2-11) only looked at ref_cpp casts inside the zone lists given per batch; these entries sit in zones never run (Stormwind City, BRD, Black Temple, Icecrown Citadel, Firelands, Dragon Soul, Vashj'ir, Borean Tundra), or have scripts only in ref_sf/ref_alex (Elder Springpaw, Gilneas, Camp Narache, Tinkertown, Black Temple).
-- Change: 70 smart_scripts rows for 23 entries (ref_cpp 16 entries, ref_sf 2, ref_alex 5), creature_template.AIName = 'SmartAI' for all of them, creature_text for Bonechewer Taskmaster 23028 (groups 0-1 from ref_alex), 1 smart_event condition for 1756 (type 22). No existing row of any entry is touched: none of the entries had smart_scripts rows.
-- Mapping as in batches 1-4: target_param4 = 0; ref_cpp event_flags 512 (WHILE_CHARMED in TC master, RAID40 in our core) dropped; event_flags 30 (= difficulty 0-3, i.e. every difficulty) cleared because our difficulty bits do not match the MoP difficulty ids; cast triggerFlags/targetsLimit (param3/4) = 0. ref_sf/ref_alex rows copied as they are (same enums as our core).
-- Checks: every spell id exists in the 5.4.8 client Spell.dbc + SpellEffect.dbc with real effects and its name matches the source comment; no cast with target NONE; no row with a creature/quest/text/equipment reference missing in our DB; mob filter (npcflag 0, hostile faction, attackable); no C++ conflict (grep of src for each entry).
-- Spellhit guard (prod crash 12-11): rows with SMART_EVENT_SPELLHIT (8) that could re-trigger themselves: none in this set (the only such row, Alliance Deserter 25761 id 1, was left out as a quest mechanic).
-- Omitted on purpose: 56 of the 79 candidates (friendly/immune/non-attackable flags, dummy-only or renamed spells, missing refs, quest mechanics, C++ double-up).
-- Source: ref_cpp (Cataclysm Preservation Project TDB434.22011, sniff-based) for 1756,16059,37016,37021,37023,37027,37031,37034,40912,41227,41641,41729,41923,53188,53639,57749; ref_sf (SkyFire 5.4.8) for 15651,15652; ref_alex (alexkulya 3.3.5/4.x import) for 23028,35509,36293,36712,43092. Not yet seen in game.
-- Rollback:
--   DELETE FROM `smart_scripts` WHERE `source_type`=0 AND `entryorguid` IN (1756,15651,15652,16059,23028,35509,36293,36712,37016,37021,37023,37027,37031,37034,40912,41227,41641,41729,41923,43092,53188,53639,57749);
--   UPDATE `creature_template` SET `AIName`='' WHERE `entry` IN (1756,15651,15652,16059,23028,35509,36293,36712,37016,37021,37023,37027,37031,37034,40912,41227,41641,41729,41923,43092,53188,53639,57749);
--   DELETE FROM `creature_text` WHERE (`CreatureID`=23028 AND `GroupID`=0) OR (`CreatureID`=23028 AND `GroupID`=1);
--   DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=22 AND `SourceEntry` IN (1756);

-- 23028 Bonechewer Taskmaster (BlackTemple, map 564, 3 spawns): ref_alex, 5 rows, 2 casts: 40851 Disgruntled [e6/a79,e6/a61,e6/a133]; 40845 Fury [e6/a79,e6/a61,e6/a92]
-- 35509 Gilneas City Guard (GilneasCity, map 654, 10 spawns): ref_alex, 2 rows, 1 casts: 6660 Shoot [e2/a0]
-- 36293 Ogre Minion (Gilneas, map 654, 14 spawns): ref_alex, 1 rows, 1 casts: 75436 Clubbed [e31/a0,e6/a4]
-- 36712 Chief Squealer Thornmantle (CampNaracheStart, map 1, 1 spawns): ref_alex, 3 rows, 2 casts: 81691 Quillhorn [e31/a0,e98/a0]; 81695 Torch Toss [e2/a0,e6/a3]
-- 43092 Gnomeregan Recruit (NewTinkertownStart, map 0, 12 spawns): ref_alex, 1 rows, 1 casts: 85756 Shoot [e2/a0,e63/a0]
-- 1756 Stormwind Royal Guard (StormwindCity, map 0, 24 spawns): ref_cpp, 11 rows, 3 casts: 6660 Shoot [e2/a0]; 12169 Shield Block [e6/a51]; 12170 Revenge [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 16059 Theldren (BlackrockDepths, map 230, 1 spawns): ref_cpp, 11 rows, 8 casts: 27578 Battle Shout [e6/a99]; 27579 Demoralizing Shout [e6/a99]; 27581 Disarm [e6/a67]; 15503 Drink Healing Potion [e10/a0]; 19134 Frightening Shout [e64/a0,e6/a7,e6/a31]; 27584 Hamstring [e2/a0,e6/a33]; 27577 Intercept [e96/a0,e64/a0]; 27580 Mortal Strike [e6/a118,e121/a0]; event_flags 512 (WHILE_CHARMED) dropped on 5 rows
-- 37016 Skybreaker Luminary (Icecrown Citadel, map 631, 1 spawns): ref_cpp, 4 rows, 4 casts: 69926 Earth Shield [e6/a42]; 69958 Healing Wave [e10/a0,e10/a0,e10/a0]; 69923 Chain Heal [e10/a0,e10/a0,e10/a0]; 69970 Lightning Bolt [e2/a0,e2/a0,e2/a0]
-- 37021 Skybreaker Vicar (Icecrown Citadel, map 631, 1 spawns): ref_cpp, 3 rows, 3 casts: 69963 Greater Heal [e10/a0,e10/a0,e10/a0]; 69967 Smite [e2/a0,e2/a0,e2/a0]; 69910 Pain Suppression [e6/a87]
-- 37023 Plague Scientist (Icecrown Citadel, map 631, 8 spawns): ref_cpp, 4 rows, 4 casts: 71103 Combobulating Spray [e6/a60,e6/a56,e6/a33]; 73079 Plague Blast [e2/a0]; 69871 Plague Stream [e6/a79]
-- 37027 Skybreaker Hierophant (Icecrown Citadel, map 631, 2 spawns): ref_cpp, 4 rows, 4 casts: 69898 Rejuvenation [e6/a8,e6/a8,e6/a8]; 69882 Regrowth [e10/a0,e10/a0,e10/a0,e6/a8,e6/a8,e6/a8]; 69899 Healing Touch [e10/a0,e10/a0,e10/a0]; 69968 Wrath [e2/a0,e2/a0,e2/a0]
-- 37031 Kor'kron Oracle (Icecrown Citadel, map 631, 3 spawns): ref_cpp, 4 rows, 4 casts: 69926 Earth Shield [e6/a42]; 69958 Healing Wave [e10/a0,e10/a0,e10/a0]; 69923 Chain Heal [e10/a0,e10/a0,e10/a0]; 69970 Lightning Bolt [e2/a0,e2/a0,e2/a0]
-- 37034 Kor'kron Templar (Icecrown Citadel, map 631, 4 spawns): ref_cpp, 3 rows, 3 casts: 69963 Greater Heal [e10/a0,e10/a0,e10/a0]; 69967 Smite [e2/a0,e2/a0,e2/a0]; 69910 Pain Suppression [e6/a87]
-- 40912 Snapjaw Grouper (Vashjir, map 0, 72 spawns): ref_cpp, 1 rows, 1 casts: 79442 Snapjaw [e31/a0]
-- 41227 Azsh'ir Infantry (VashjirDepths, map 0, 27 spawns): ref_cpp, 2 rows, 2 casts: 61168 Throw [e31/a0]; 79449 Body Slam [e96/a0,e98/a0,e165/a0]
-- 41641 Tentacle Horror (VashjirDepths, map 0, 3 spawns): ref_cpp, 2 rows, 1 casts: 78331 Shadow Bolt [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows
-- 41729 Taken Gilblin (VashjirDepths, map 0, 18 spawns): ref_cpp, 1 rows, 1 casts: 79544 Psionic Overload [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 41923 Luxscale Grouper (VashjirDepths, map 0, 29 spawns): ref_cpp, 1 rows, 1 casts: 79559 Luxscale Light [e6/a22,e6/a49,e6/a80]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 53188 Flamewaker Subjugator (Firelands, map 720, 3 spawns): ref_cpp, 1 rows, 1 casts: 100527 Furious [e6/a79,e6/a61]; dropped row(s): id 0 (SET_DATA on Flamewaker Animator 53187, which has no script (Animate Magma 99045 is dummy-only, no SpellScript))
-- 53639 Flamewaker Cauterizer (Firelands, map 720, 1 spawns): ref_cpp, 1 rows, 1 casts: 100060 Flame Shield [e6/a23,e128/a28]
-- 57749 Faceless Corruptor (DragonSoul, map 967, 13 spawns): ref_cpp, 1 rows, 1 casts: 96516 Shadow Bolt [e2/a0,e2/a0,e2/a0]
-- 15651 Springpaw Stalker (EversongWoods, map 530, 102 spawns): ref_sf, 2 rows, 2 casts: 24450 Prowl [e6/a16,e6/a33,e6/a79]
-- 15652 Elder Springpaw (EversongWoods, map 530, 32 spawns): ref_sf, 2 rows, 2 casts: 24450 Prowl [e6/a16,e6/a33,e6/a79]

DELETE FROM `smart_scripts` WHERE `source_type`=0 AND `entryorguid` IN (1756,15651,15652,16059,23028,35509,36293,36712,37016,37021,37023,37027,37031,37034,40912,41227,41641,41729,41923,43092,53188,53639,57749);
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (1756,15651,15652,16059,23028,35509,36293,36712,37016,37021,37023,37027,37031,37034,40912,41227,41641,41729,41923,43092,53188,53639,57749) AND `AIName`='';
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(23028,0,0,1,0,0,100,0,5000,15000,14000,14000,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bonechewer Taskmaster - In Combat - Say Text Line 0'),
(23028,0,1,0,61,0,100,0,0,0,0,0,0,67,1,3000,3000,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bonechewer Taskmaster - In Combat - Create Timed Event'),
(23028,0,2,0,59,0,100,0,1,0,0,0,0,11,40851,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bonechewer Taskmaster - On Timed Event - Cast \'Disgruntled\''),
(23028,0,3,0,38,0,100,0,1,1,0,0,0,11,40845,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bonechewer Taskmaster - On Data Set 1 1 - Cast \'Fury\''),
(23028,0,4,0,38,0,100,1,1,1,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bonechewer Taskmaster - On Data Set 1 1 - Say Text Line 1 (No Repeat)'),
(35509,0,0,0,0,0,100,0,0,0,3400,3700,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gilneas City Guard - In Combat CMC - Cast \'Shoot\''),
(35509,0,1,0,1,0,100,0,1000,1000,1000,1000,0,49,0,0,0,0,0,0,19,35505,5,0,0,0.0,0.0,0.0,0.0,'Gilneas City Guard - OOC - Attack Creature ID: 35505, 5 Yards'),
(36293,0,0,0,0,0,100,0,1000,1000,22000,22000,0,11,75436,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ogre Minion - In Combat - Cast Spell \'Clubbed\''),
(36712,0,0,0,4,0,100,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Chief Squealer Thornmantle - On Aggro - Say Text Line 0 (No Repeat)'),
(36712,0,1,0,0,0,100,0,5000,5000,12000,15000,0,11,81691,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Chief Squealer Thornmantle - In Combat - Cast Spell \'Quillhorn\''),
(36712,0,2,0,0,0,100,0,4000,9000,18000,24000,0,11,81695,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Chief Squealer Thornmantle - In Combat - Cast Spell \'Torch Toss\''),
(43092,0,0,0,0,0,100,0,1000,4000,5000,8000,0,11,85756,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gnomeregan Recruit - In Combat - Cast Spell \'Shoot\''),
(1756,0,0,0,10,0,100,0,1,10,10000,10000,1,87,6800,6801,6802,6803,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - Within 1-10 Range Out of Combat LoS - Run Random Script'),
(1756,0,1,0,0,0,100,0,0,0,2000,4000,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - In Combat - Cast \'Shoot\''),
(1756,0,2,0,9,0,100,0,0,5,11000,14000,0,11,12169,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - Within 0-5 Range - Cast \'Shield Block\''),
(1756,0,3,0,0,0,100,0,5000,9000,8000,13000,0,11,12170,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - In Combat - Cast \'Revenge\''),
(1756,0,4,0,22,0,100,0,101,5000,5000,0,0,80,6800,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - On Received Emote \'Wave\' - Run Script'),
(1756,0,5,0,22,0,100,0,78,5000,5000,0,0,80,6801,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - On Received Emote \'Salute\' - Run Script'),
(1756,0,6,0,22,0,100,0,58,5000,5000,0,0,80,6802,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - On Received Emote \'Kiss\' - Run Script'),
(1756,0,7,0,22,0,100,0,84,5000,5000,0,0,80,6803,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - On Received Emote \'Shy\' - Run Script'),
(1756,0,8,0,22,0,100,0,77,5000,5000,0,0,80,6804,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - On Received Emote \'Rude\' - Run Script'),
(1756,0,9,0,22,0,100,0,22,5000,5000,0,0,80,6804,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - On Received Emote \'Chicken\' - Run Script'),
(1756,0,10,0,22,0,100,0,17,5000,5000,0,0,80,6802,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind Royal Guard - On Received Emote \'Bow\' - Run Script'),
(16059,0,0,0,1,0,100,1,100,100,0,0,0,11,27578,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - IC - Battle Shout'),
(16059,0,1,0,0,0,100,0,1000,1000,35000,35000,0,11,27579,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - IC - Demoralizing Shout'),
(16059,0,2,0,0,0,100,0,5000,5000,15000,15000,0,11,27581,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - IC - Disarm '),
(16059,0,3,0,2,0,100,1,20,35,0,0,0,11,15503,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - IC - Heal '),
(16059,0,4,0,0,0,100,0,7000,7000,9000,9000,0,11,19134,0,0,0,0,0,5,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - IC - Fear random target '),
(16059,0,5,0,0,0,100,0,8000,8000,9000,9000,0,11,27584,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - IC - Hamstring '),
(16059,0,6,0,0,0,100,0,0,0,14000,14000,0,11,27577,2,0,0,0,0,5,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - IC - Charge random target '),
(16059,0,7,0,0,0,100,0,3000,3000,12000,12000,0,11,27580,2,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - IC - Mortal Strike '),
(16059,0,8,0,4,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Theldren - aggro -  text'),
(16059,0,9,0,6,0,100,0,0,0,0,0,0,33,16166,0,0,0,0,0,18,90,0,0,0,0.0,0.0,0.0,0.0,'Theldren - On Death - kill credit to players within 90 yd (quest 9015 asks to slay him; the reference gave it on summon)'),
(16059,0,10,0,63,0,100,0,0,0,0,0,0,49,0,0,0,0,0,0,21,60,0,0,0,0.0,0.0,0.0,0.0,'Theldren - Just summoned - Attack'),
(37016,0,0,0,0,0,100,0,1000,1500,20000,25000,0,11,69926,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Luminary - In Combat - Cast \'Earth Shield\''),
(37016,0,1,0,0,0,100,0,3000,3000,6000,7000,0,11,69958,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Luminary - In Combat - Cast \'Healing Wave\''),
(37016,0,2,0,0,0,100,0,4000,6000,6000,7000,0,11,69923,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Luminary - In Combat - Cast \'Chain Heal\''),
(37016,0,3,0,0,0,100,0,7000,8000,7000,8000,0,11,69970,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Luminary - In Combat - Cast \'Lightning Bolt\''),
(37021,0,0,0,0,0,100,0,7000,7000,5000,10000,0,11,69963,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Vicar - In Combat - Cast \'Greater Heal\''),
(37021,0,1,0,0,0,100,0,0,0,7000,8000,0,11,69967,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Vicar - In Combat - Cast \'Smite\''),
(37021,0,2,0,0,0,100,0,25000,30000,25000,30000,0,11,69910,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Vicar - In Combat - Cast \'Pain Suppression\''),
(37023,0,0,0,0,0,100,0,2000,3000,23000,24000,0,11,71103,0,0,0,0,0,6,0,0,0,0,0.0,0.0,0.0,0.0,'Plague Scientist - In Combat - Cast \'Combobulating Spray\''),
(37023,0,1,0,0,0,100,0,5000,6000,5000,6000,0,11,73079,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Plague Scientist - In Combat - Cast \'Plague Blast\''),
(37023,0,2,0,0,0,100,0,9000,10000,25000,26000,0,11,69871,0,0,0,0,0,9,0,0,30,0,0.0,0.0,0.0,0.0,'Plague Scientist - In Combat - Cast \'Plague Stream\''),
(37023,0,3,0,1,0,100,0,2000,3000,10000,10000,0,11,69871,0,0,0,0,0,9,10404,0,10,0,0.0,0.0,0.0,0.0,'Plague Scientist - Out of Combat - Cast \'Plague Stream\''),
(37027,0,0,0,0,0,100,0,0,0,3000,5000,0,11,69898,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Hierophant - In Combat - Cast \'Rejuvenation\''),
(37027,0,1,0,0,0,100,0,7000,7000,18000,24000,0,11,69882,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Hierophant - In Combat - Cast \'Regrowth\''),
(37027,0,2,0,0,0,100,0,25000,25000,10000,15000,0,11,69899,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Hierophant - In Combat - Cast \'Healing Touch\''),
(37027,0,3,0,0,0,100,0,0,500,3000,5000,0,11,69968,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Skybreaker Hierophant - In Combat - Cast \'Wrath\''),
(37031,0,0,0,0,0,100,0,1000,1500,20000,25000,0,11,69926,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Kor\'kron Oracle - In Combat - Cast \'Earth Shield\''),
(37031,0,1,0,0,0,100,0,3000,3000,6000,7000,0,11,69958,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Kor\'kron Oracle - In Combat - Cast \'Healing Wave\''),
(37031,0,2,0,0,0,100,0,4000,6000,6000,7000,0,11,69923,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Kor\'kron Oracle - In Combat - Cast \'Chain Heal\''),
(37031,0,3,0,0,0,100,0,7000,8000,7000,8000,0,11,69970,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Kor\'kron Oracle - In Combat - Cast \'Lightning Bolt\''),
(37034,0,0,0,0,0,100,0,7000,7000,5000,10000,0,11,69963,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Kor\'kron Templar - In Combat - Cast \'Greater Heal\''),
(37034,0,1,0,0,0,100,0,0,0,7000,8000,0,11,69967,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Kor\'kron Templar - In Combat - Cast \'Smite\''),
(37034,0,2,0,0,0,100,0,25000,30000,25000,30000,0,11,69910,0,0,0,0,0,26,40,0,0,0,0.0,0.0,0.0,0.0,'Kor\'kron Templar - In Combat - Cast \'Pain Suppression\''),
(40912,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,79442,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Snapjaw'),
(41227,0,0,0,0,0,100,0,0,0,3500,4100,0,11,61168,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Throw'),
(41227,0,1,0,9,0,100,0,0,30,15000,20000,0,11,79449,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Body Slam on Close'),
(41641,0,0,0,4,0,100,1,0,0,0,0,0,21,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stop Moving on Aggro'),
(41641,0,1,0,0,0,100,0,2000,3000,12000,19000,0,11,78331,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shadow Bolt'),
(41729,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,79544,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Psionic Overload'),
(41923,0,0,0,0,0,100,0,3000,4500,20000,22000,0,11,79559,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Luxscale Light'),
(53188,0,1,0,2,0,100,1,0,25,0,0,0,11,100527,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Flamewaker Subjugator - HP 25% - Cast: \'Furious\''),
(53639,0,0,0,1,0,100,0,10000,10000,25000,25000,0,11,100060,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Flamewaker Cauterizer - OOC - Cast: \'Flame Shield\''),
(57749,0,0,0,0,0,100,0,0,0,3400,4700,0,11,96516,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Faceless Corruptor - In Combat - Cast \'Shadow Bolt\' (Dungeon & Raid)'),
(15651,0,0,0,11,0,100,1,0,0,0,0,0,11,24450,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Springpaw Stalker - On Respawn - Cast Prowl'),
(15651,0,1,0,7,0,100,1,0,0,0,0,0,11,24450,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Springpaw Stalker - On Evade - Cast Prowl'),
(15652,0,0,0,11,0,100,1,0,0,0,0,0,11,24450,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Elder Springpaw - On Respawn - Cast Prowl'),
(15652,0,1,0,7,0,100,1,0,0,0,0,0,11,24450,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Elder Springpaw - On Evade - Cast Prowl');
DELETE FROM `creature_text` WHERE (`CreatureID`=23028 AND `GroupID`=0) OR (`CreatureID`=23028 AND `GroupID`=1);
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(23028,0,0,'I\'ve seen female Gnomes hit harder than you!',14,0,100.0,0,0,0,0,0,0,'Bonechewer Taskmaster'),
(23028,0,1,'If you don\'t start throwing some real punches, you\'ll be cleaning the drake stalls for a year!',14,0,100.0,0,0,0,0,0,0,'Bonechewer Taskmaster'),
(23028,0,2,'Stop your slacking and fight like a true fel orc!',14,0,100.0,0,0,0,0,0,0,'Bonechewer Taskmaster'),
(23028,0,3,'You call that an offense? I\'ve seen more offensive tallstriders!',14,0,100.0,0,0,0,0,0,0,'Bonechewer Taskmaster'),
(23028,1,0,'%s becomes increasingly enraged as he sees his allies fall in battle!',16,0,100.0,0,0,0,0,0,0,'Bonechewer Taskmaster');
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=22 AND `SourceEntry` IN (1756);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(22,1,1756,0,0,28,0,13188,0,0,0,0,0,'','Only Run script if quest is completed');
