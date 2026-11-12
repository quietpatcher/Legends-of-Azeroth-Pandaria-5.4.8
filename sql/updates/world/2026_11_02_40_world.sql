-- To-do 405 (SmartAI check on mobs, batch 1: Durotar, Mulgore, TirisfalGlades, EversongWoods, Ghostlands, Kezan, TheLostIsles): 23 creatures cast spells on retail but have no script, or only the old 3.3.5 script, in our world DB.
-- Cause: our smart_scripts for these entries come from the alexkulya import (identical to ref_alex) or are missing; the Cataclysm sniff data (ref_cpp) has SmartAI with the retail casts for them.
-- Change: port the ref_cpp SmartAI (smart_scripts source_type 0) for 23 creatures (4 new, 19 replacing an unchanged alexkulya script); AIName set to SmartAI for 4 entries that had none.
-- Schema/enum mapping: target_param4 = 0; event_flags 512 (WHILE_CHARMED in TC master; RAID40 difficulty in our core, would disable the event) dropped, 256 -> 0x10000 (DONT_RESET); action 27 COMBAT_STOP -> 203, 85 SELF_CAST -> 11 CAST with flag 0x10, 134 INVOKER_CAST -> 85; cast triggerFlags/targetsLimit (param3/4) = 0.
-- Source: ref_cpp (Cataclysm Preservation Project TDB434.22011, sniff-based) smart_scripts/creature_text/waypoints/conditions, rows copied 1:1 apart from the mapping above. Every spell id checked against the 5.4.8 client Spell.dbc + SpellEffect.dbc on dev (exists, has effects, name matches the ref_cpp comment). Not yet seen in game.
-- Rollback: rollback/405_batch1_rollback.sql (re-inserts the 19 replaced old scripts, deletes the ported rows, resets AIName for the 4 entries that had none).
-- Rollback (short, loses the replaced old scripts of 3106,3107,3115,3123,3114,3116,3118,3197,3112,3117,3198,3199,3196,5823,5824,5822,3232,15669,16345): DELETE FROM smart_scripts WHERE source_type=0 AND entryorguid IN (3106,3107,3115,3123,3114,3116,39249,3118,3197,3112,3117,3198,3199,3196,5823,5824,5822,2958,2960,3232,15668,15669,16345); DELETE FROM smart_scripts WHERE source_type=9 AND entryorguid IN (0); UPDATE creature_template SET AIName='' WHERE entry IN (39249,2958,2960,15668);

-- 3106 Surf Crawler (Durotar, 50 spawns): replace, 1 rows, 1 casts: 78744 Bubblebeam [e6/a23]
-- 3107 Mature Surf Crawler (Durotar, 30 spawns): replace, 1 rows, 1 casts: 78744 Bubblebeam [e6/a23]
-- 3115 Dustwind Harpy (Durotar, 23 spawns): replace, 3 rows, 2 casts: 77522 Swoop [e31/a0,e98/a0]; 80215 Dustwind [e6/a9]
-- 3123 Bloodtalon Scythemaw (Durotar, 23 spawns): replace, 2 rows, 2 casts: 6268 Rushing Charge [e96/a0,e6/a79]; 13443 Rend [e6/a3]
-- 3114 Razormane Battleguard (Durotar, 20 spawns): replace, 5 rows, 4 casts: 32064 Battle Shout [e6/a99]; 5280 Razor Mane [e6/a15]; 77558 Bloody Strike [e31/a0,e6/a79,e6/a54]; 8599 Enrage [e6/a79,e6/a138]
-- 3116 Dustwind Pillager (Durotar, 20 spawns): replace, 3 rows, 2 casts: 3147 Rend Flesh [e6/a3]; 80215 Dustwind [e6/a9]
-- 39249 Northwatch Lug (Durotar, 19 spawns): insert, 1 rows, 1 casts: 75356 Fisticuffs [e31/a0]
-- 3118 Dustwind Storm Witch (Durotar, 16 spawns): replace, 4 rows, 3 casts: 77160 Nimbus Bolt [e2/a0]; 80215 Dustwind [e6/a9]; 12058 Chain Lightning [e2/a0]
-- 3197 Burning Blade Fanatic (Durotar, 13 spawns): replace, 2 rows, 2 casts: 5262 Fanatic Blade [e6/a42]; 80174 Felblood [e6/a14,e2/a0,e6/a226]
-- 3112 Razormane Scout (Durotar, 12 spawns): replace, 2 rows, 2 casts: 80149 Throw Axe [e31/a0]; 5280 Razor Mane [e6/a15]
-- 3117 Dustwind Savage (Durotar, 11 spawns): replace, 3 rows, 2 casts: 75930 Mangle [e2/a0,e6/a3]; 80215 Dustwind [e6/a9]
-- 3198 Burning Blade Apprentice (Durotar, 11 spawns): replace, 4 rows, 3 casts: 77721 Shadow Weave [e2/a0]; 12746 Summon Voidwalker [e56/a0]; 80174 Felblood [e6/a14,e2/a0,e6/a226]
-- 3199 Burning Blade Cultist (Durotar, 5 spawns): replace, 4 rows, 3 casts: 79938 Incinerate [e2/a0]; 11939 Summon Imp [e28/a0]; 80174 Felblood [e6/a14,e2/a0,e6/a226]
-- 3196 Burning Blade Neophyte (Durotar, 5 spawns): replace, 4 rows, 3 casts: 79932 Shadow Bolt [e2/a0]; 79954 Fel Armor [e6/a79,e6/a20]; 80174 Felblood [e6/a14,e2/a0,e6/a226]
-- 5823 Death Flayer (Durotar, 4 spawns): replace, 2 rows, 2 casts: 79840 Harden [e6/a87]; 79607 Venom Splash [e27/a3]
-- 5824 Captain Flat Tusk (Durotar, 4 spawns): replace, 4 rows, 3 casts: 5280 Razor Mane [e6/a15]; 77558 Bloody Strike [e31/a0,e6/a79,e6/a54]; 79733 Commanding Shout [e6/a230]
-- 5822 Felweaver Scornn (Durotar, 2 spawns): replace, 3 rows, 3 casts: 30842 Summon Felhunter [e56/a0]; 79934 Demon Armor [e6/a22,e6/a118]; 79933 Drain Life [e6/a53]
-- 2958 Prairie Wolf (Mulgore, 135 spawns): insert, 3 rows, 1 casts: 5781 Threatening Growl [e6/a80,e6/a80]
-- 2960 Prairie Wolf Alpha (Mulgore, 67 spawns): insert, 3 rows, 1 casts: 5781 Threatening Growl [e6/a80,e6/a80]
-- 3232 Bristleback Interloper (Mulgore, 25 spawns): replace, 2 rows, 2 casts: 81653 Bristleback [e6/a15]; 79584 Fan of Knives [e2/a0]
-- 15668 Grimscale Murloc (EversongWoods, 28 spawns): insert, 2 rows, 1 casts: 26661 Fear [e6/a7]
-- 15669 Grimscale Oracle (EversongWoods, 10 spawns): replace, 3 rows, 2 casts: 17137 Flash Heal [e10/a0]; 26661 Fear [e6/a7]
-- 16345 Shadowpine Catlord (Ghostlands, 15 spawns): replace, 2 rows, 2 casts: 28902 Bloodlust [e6/a193]; 28904 Summon Ghostclaw Lynx [e56/a0]

DELETE FROM `smart_scripts` WHERE `source_type`=0 AND `entryorguid` IN (3106,3107,3115,3123,3114,3116,39249,3118,3197,3112,3117,3198,3199,3196,5823,5824,5822,2958,2960,3232,15668,15669,16345);
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (39249,2958,2960,15668);
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(3106,0,0,0,0,0,100,0,4000,5000,17000,22000,0,11,78744,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Surf Crawler - In Combat - Cast \'Bubblebeam\''),
(3107,0,0,0,0,0,100,0,4000,5000,17000,22000,0,11,78744,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Mature Surf Crawler - In Combat - Cast \'Bubblebeam\''),
(3115,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Harpy - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3115,0,1,0,0,0,100,0,4000,5000,12000,19000,0,11,77522,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Harpy - In Combat - Cast \'Swoop\''),
(3115,0,2,0,2,0,100,0,0,50,13000,24000,0,11,80215,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Harpy - Between 0-50% Health - Cast \'Dustwind\''),
(3123,0,0,0,4,0,100,1,0,0,0,0,0,11,6268,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bloodtalon Scythemaw - On Aggro - Cast \'Rushing Charge\' (No Repeat)'),
(3123,0,1,0,0,0,100,0,3000,4500,24000,25000,0,11,13443,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Bloodtalon Scythemaw - In Combat - Cast \'Rend\''),
(3114,0,0,0,4,0,100,1,0,0,0,0,0,11,32064,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Battleguard - On Aggro - Cast \'Battle Shout\' (No Repeat)'),
(3114,0,1,0,1,0,100,0,500,1000,300000,300000,0,11,5280,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Battleguard - Out of Combat - Cast \'Razor Mane\''),
(3114,0,2,0,0,0,100,0,4000,6000,25000,31000,0,11,77558,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Battleguard - In Combat - Cast \'Bloody Strike\''),
(3114,0,3,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Battleguard - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3114,0,4,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Battleguard - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3116,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Pillager - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3116,0,1,0,0,0,100,0,5000,11000,18000,24000,0,11,3147,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Pillager - In Combat - Cast \'Rend Flesh\''),
(3116,0,2,0,2,0,100,0,0,50,13000,24000,0,11,80215,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Pillager - Between 0-50% Health - Cast \'Dustwind\''),
(39249,0,0,0,0,0,100,0,5000,5000,14000,17000,0,11,75356,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Northwatch Lug - In Combat - Cast \'Fisticuffs\''),
(3118,0,0,0,0,0,100,0,0,0,3400,4700,0,11,77160,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Storm Witch - In Combat - Cast \'Nimbus Bolt\''),
(3118,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Storm Witch - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3118,0,2,0,2,0,100,0,0,50,13000,24000,0,11,80215,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Storm Witch - Between 0-50% Health - Cast \'Dustwind\''),
(3118,0,3,0,0,0,100,0,7000,9000,24000,26000,0,11,12058,0,0,0,0,0,4,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Storm Witch - In Combat - Cast \'Chain Lightning\''),
(3197,0,0,0,0,0,100,0,1000,11000,16000,22000,0,11,5262,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Fanatic - In Combat - Cast \'Fanatic Blade\''),
(3197,0,1,0,0,0,100,0,6000,8000,60000,65000,0,11,80174,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Fanatic - In Combat - Cast \'Felblood\''),
(3112,0,0,0,4,0,100,1,0,0,0,0,0,11,80149,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Scout - On Aggro - Cast \'Throw Axe\' (No Repeat)'),
(3112,0,1,0,1,0,100,0,500,1000,300000,300000,0,11,5280,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Razormane Scout - Out of Combat - Cast \'Razor Mane\''),
(3117,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Savage - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3117,0,1,0,0,0,100,0,5000,5000,18000,22000,0,11,75930,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Savage - In Combat - Cast \'Mangle\''),
(3117,0,2,0,2,0,100,0,0,50,13000,24000,0,11,80215,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dustwind Savage - Between 0-50% Health - Cast \'Dustwind\''),
(3198,0,0,0,0,0,100,0,0,0,3400,4700,0,11,77721,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Apprentice - In Combat - Cast \'Shadow Weave\''),
(3198,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Apprentice - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3198,0,2,0,1,0,100,1,3000,5000,0,0,0,11,12746,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Apprentice - Out of Combat - Cast \'Summon Voidwalker\' (No Repeat)'),
(3198,0,3,0,0,0,100,0,6000,8000,60000,65000,0,11,80174,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Apprentice - In Combat - Cast \'Felblood\''),
(3199,0,0,0,0,0,100,0,0,0,3400,4700,0,11,79938,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Cultist - In Combat - Cast \'Incinerate\''),
(3199,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Cultist - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3199,0,2,0,1,0,100,1,3000,5000,0,0,0,11,11939,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Cultist - Out of Combat - Cast \'Summon Imp\' (No Repeat)'),
(3199,0,3,0,0,0,100,0,6000,8000,60000,65000,0,11,80174,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Cultist - In Combat - Cast \'Felblood\''),
(3196,0,0,0,0,0,100,0,0,0,3400,4700,0,11,79932,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Neophyte - In Combat - Cast \'Shadow Bolt\''),
(3196,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Neophyte - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3196,0,2,0,1,0,100,0,500,1000,600000,600000,0,11,79954,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Neophyte - Out of Combat - Cast \'Fel Armor\''),
(3196,0,3,0,0,0,100,0,6000,8000,60000,65000,0,11,80174,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Burning Blade Neophyte - In Combat - Cast \'Felblood\''),
(5823,0,0,0,2,0,100,0,0,50,24000,26000,0,11,79840,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Death Flayer - Between 0-50% Health - Cast \'Harden\''),
(5823,0,1,0,0,0,100,0,3500,4500,15000,24000,0,11,79607,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Death Flayer - In Combat - Cast \'Venom Splash\''),
(5824,0,0,0,11,0,100,1,0,0,0,0,0,11,5280,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Captain Flat Tusk - On Respawn - Cast \'Razor Mane\' (No Repeat)'),
(5824,0,1,0,9,0,100,0,0,5,7000,12000,0,11,77558,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Captain Flat Tusk - Within 0-5 Range - Cast \'Bloody Strike\''),
(5824,0,2,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Captain Flat Tusk - Between 0-15% Health - Flee For Assist (No Repeat)'),
(5824,0,3,0,4,0,100,1,0,0,0,0,0,11,79733,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Captain Flat Tusk - On Aggro - Cast \'Commanding Shout\' (No Repeat)'),
(5822,0,0,0,1,0,100,1,3000,5000,0,0,0,11,30842,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Felweaver Scornn - Out of Combat - Cast \'Summon Felhunter\' (No Repeat)'),
(5822,0,1,0,1,0,100,0,500,1000,600000,600000,0,11,79934,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Felweaver Scornn - Out of Combat - Cast \'Demon Armor\''),
(5822,0,2,0,2,0,100,0,0,40,16000,23000,0,11,79933,0,0,0,0,0,2,1,0,0,0,0.0,0.0,0.0,0.0,'Felweaver Scornn - Between 0-40% Health - Cast \'Drain Life\''),
(2958,0,0,1,1,0,5,0,60000,60000,120000,600000,0,4,1018,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Prairie Wolf - Out of Combat - Play Sound 1018'),
(2958,0,1,0,61,0,5,0,60000,60000,120000,600000,0,5,393,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Prairie Wolf - Out of Combat - Play Emote 393'),
(2958,0,2,0,9,0,100,0,0,5,45000,45000,0,11,5781,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Prairie Wolf - Within 0-5 Range - Cast \'Threatening Growl\''),
(2960,0,0,1,1,0,5,0,60000,60000,120000,600000,0,4,1018,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Prairie Wolf Alpha - Out of Combat - Play Sound 1018'),
(2960,0,1,0,61,0,5,0,60000,60000,120000,600000,0,5,393,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Prairie Wolf Alpha - Out of Combat - Play Emote 393'),
(2960,0,2,0,9,0,100,0,0,5,45000,45000,0,11,5781,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Prairie Wolf Alpha - Within 0-5 Range - Cast \'Threatening Growl\''),
(3232,0,0,0,11,0,100,1,0,0,0,0,0,11,81653,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bristleback Interloper - On Respawn - Cast \'Bristleback\' (No Repeat)'),
(3232,0,1,0,0,0,100,0,5000,8000,22000,24000,0,11,79584,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bristleback Interloper - In Combat - Cast \'Fan of Knives\''),
(15668,0,0,0,38,0,100,0,0,1,0,0,0,11,26661,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Grimscale Murloc - On Data Set 0 1 - Cast \'Fear\' (No Repeat)'),
(15668,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Grimscale Murloc - Between 0-15% Health - Flee For Assist (No Repeat)'),
(15669,0,0,0,14,0,100,0,400,40,12000,16000,0,11,17137,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Grimscale Oracle - Friendly At 70 Health - Cast \'Flash Heal\''),
(15669,0,1,0,38,0,100,0,0,1,0,0,0,11,26661,3,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Grimscale Oracle - On Data Set 0 1 - Cast \'Fear\' (No Repeat)'),
(15669,0,2,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Grimscale Oracle - Between 0-15% Health - Flee For Assist (No Repeat)'),
(16345,0,0,0,16,0,100,0,28902,30,20000,40000,0,11,28902,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowpine Catlord - On Friendly Unit Missing Buff \'Bloodlust\' - Cast \'Bloodlust\''),
(16345,0,1,0,1,0,100,1,1000,1000,0,0,0,11,28904,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowpine Catlord - Out of Combat - Cast \'Summon Ghostclaw Lynx\' (No Repeat)');
