-- To-do 405 (SmartAI check on mobs, batch 7: EasternPlaguelands, WesternPlaguelands, BlastedLands, BurningSteppes, Badlands, SearingGorge, SwampofSorrows, TheHinterlands, Felwood, Hyjal, Uldum): 53 creatures cast spells on retail but have no script, or only the old 3.3.5 script, in our world DB.
-- Cause: our smart_scripts for these entries come from the alexkulya import (identical to ref_alex) or are missing; the Cataclysm sniff data (ref_cpp) has SmartAI with the retail casts for them.
-- Change: port the ref_cpp SmartAI (smart_scripts source_type 0) for 53 creatures (12 new, 41 replacing an unchanged alexkulya script); AIName set to SmartAI for 12 entries that had none.
-- Schema/enum mapping: target_param4 = 0; event_flags 512 (WHILE_CHARMED in TC master; RAID40 difficulty in our core, would disable the event) dropped, 256 -> 0x10000 (DONT_RESET); action 27 COMBAT_STOP -> 203, 85 SELF_CAST -> 11 CAST with flag 0x10, 134 INVOKER_CAST -> 85; cast triggerFlags/targetsLimit (param3/4) = 0.
-- Source: ref_cpp (Cataclysm Preservation Project TDB434.22011, sniff-based) smart_scripts/creature_text/waypoints/conditions, rows copied 1:1 apart from the mapping above. Every spell id checked against the 5.4.8 client Spell.dbc + SpellEffect.dbc on dev (exists, has effects, name matches the ref_cpp comment). Not yet seen in game.
-- Rollback: rollback/405_batch7_rollback.sql (re-inserts the 41 replaced old scripts, deletes the ported rows, resets AIName for the 12 entries that had none).
-- Rollback (short, loses the replaced old scripts of 2729,2743,5996,5997,5990,6010,5977,5978,5975,6006,6007,8298,8300,8296,8297,8301,8302,8303,7026,7034,9604,8566,5839,8598,9447,9449,8548,8556,8563,31096,8538,10826,10821,10825,11897,8956,48154,7158,38926,41031,45859): DELETE FROM smart_scripts WHERE source_type=0 AND entryorguid IN (2729,2743,5996,5997,5990,6010,5977,5978,5975,6006,6007,8298,8300,8296,8297,8301,8302,8303,12425,7026,7034,9604,8566,5839,8598,9447,9449,8548,8556,8563,31096,8538,10826,10821,10825,11897,46095,8956,48154,7158,7106,47679,38915,38913,38926,40573,40713,38951,43427,41031,45859,48041,48040); DELETE FROM smart_scripts WHERE source_type=9 AND entryorguid IN (0); UPDATE creature_template SET AIName='' WHERE entry IN (12425,46095,7106,47679,38915,38913,40573,40713,38951,43427,48041,48040);

-- 2729 Elder Crag Coyote (Badlands, 30 spawns): replace, 1 rows, 1 casts: 32919 Snarl [e58/a0]
-- 2743 Shadowforge Warrior (Badlands, 19 spawns): replace, 2 rows, 2 casts: 32064 Battle Shout [e6/a99]; 17207 Whirlwind [e6/a23]
-- 5996 Nethergarde Miner (BlastedLands, 111 spawns): replace, 4 rows, 3 casts: 38557 Throw [e31/a0]; 80382 Dirt Toss [e6/a33,e6/a5]; 6016 Pierce Armor [e6/a101]
-- 5997 Nethergarde Engineer (BlastedLands, 40 spawns): replace, 4 rows, 3 casts: 6660 Shoot [e2/a0]; 79721 Explosive Shot [e58/a0]; 79726 Ticking Time Bomb [e28/a0]
-- 5990 Redstone Basilisk (BlastedLands, 33 spawns): replace, 2 rows, 2 casts: 83657 Hellgaze [e6/a3,e6/a33]; 77576 Stone Breath [e3/a0,e6/a12,e2/a0]
-- 6010 Felhound (BlastedLands, 31 spawns): replace, 2 rows, 2 casts: 81082 Noxious Breath [e6/a3,e2/a0]; 79616 Drain Life [e6/a53]
-- 5977 Dreadmaul Mauler (BlastedLands, 19 spawns): replace, 7 rows, 5 casts: 81140 Thunderclap [e2/a0,e6/a33,e6/a319]; 11960 Curse of the Dreadmaul [e6/a166]; 84333 Summon Dreadmaul [e2/a0]; 8599 Enrage [e6/a79,e6/a138]; 80182 Uppercut [e31/a0,e98/a0]
-- 5978 Dreadmaul Warlock (BlastedLands, 16 spawns): replace, 5 rows, 4 casts: 79938 Incinerate [e2/a0]; 44977 Fel Armor [e6/a118,e6/a79]; 79937 Immolate [e6/a3,e2/a0]; 84333 Summon Dreadmaul [e2/a0]
-- 5975 Dreadmaul Ogre Mage (BlastedLands, 8 spawns): replace, 5 rows, 4 casts: 79858 Frostbolt [e2/a0,e6/a33]; 79850 Frost Nova [e2/a0,e6/a26]; 79859 Ice Lance [e2/a0]; 84333 Summon Dreadmaul [e2/a0]
-- 6006 Shadowsworn Adept (BlastedLands, 7 spawns): replace, 3 rows, 3 casts: 77721 Shadow Weave [e2/a0]; 75073 Shadow Nova [e2/a0,e98/a0]; 77471 Shadow Shield [e6/a69]
-- 6007 Shadowsworn Enforcer (BlastedLands, 7 spawns): replace, 2 rows, 2 casts: 35373 Shadowfury [e2/a0,e98/a0]; 32916 Shadow Cleave [e31/a0]
-- 8298 Akubar the Seer (BlastedLands, 4 spawns): replace, 6 rows, 6 casts: 79884 Lightning Bolt [e2/a0]; 79892 Water Shield [e6/a4,e6/a42]; 79890 Flame Shock [e2/a0,e6/a3]; 39591 Searing Totem [e28/a0]; 79886 Lava Burst [e2/a0]
-- 8300 Ravage (BlastedLands, 3 spawns): replace, 4 rows, 4 casts: 82797 Leaping Bite [e31/a0,e98/a0,e41/a0]; 7367 Infected Bite [e6/a3,e6/a87]; 13445 Rend [e6/a3]; 3149 Furious Howl [e6/a80]
-- 8296 Mojo the Twisted (BlastedLands, 2 spawns): replace, 3 rows, 3 casts: 20298 Shadow Bolt [e2/a0]; 79954 Fel Armor [e6/a79,e6/a20]; 31976 Shadow Shield [e6/a69]
-- 8297 Magronos the Unyielding (BlastedLands, 2 spawns): replace, 5 rows, 4 casts: 8599 Enrage [e6/a79,e6/a138]; 10966 Uppercut [e31/a0,e98/a0]; 22859 Mortal Cleave [e31/a0,e6/a118]; 78827 Bladestorm [e31/a0]
-- 8301 Clack the Reaver (BlastedLands, 2 spawns): replace, 3 rows, 3 casts: 21067 Poison Bolt [e2/a0,e6/a3]; 79607 Venom Splash [e27/a3]; 79840 Harden [e6/a87]
-- 8302 Deatheye (BlastedLands, 2 spawns): replace, 3 rows, 3 casts: 83657 Hellgaze [e6/a3,e6/a33]; 77576 Stone Breath [e3/a0,e6/a12,e2/a0]; 54663 Fatal Bite [e9/a0]
-- 8303 Grunter (BlastedLands, 2 spawns): replace, 5 rows, 4 casts: 8599 Enrage [e6/a79,e6/a138]; 3604 Tendon Rip [e6/a33]; 79581 Angry Snort [e2/a0,e98/a0]; 6268 Rushing Charge [e96/a0,e6/a79]
-- 12425 Flint Shadowmore (WesternPlaguelands, 1 spawns): insert, 3 rows, 3 casts: 15582 Backstab [e58/a0]; 6434 Slice and Dice [e6/a138]; 12540 Gouge [e2/a0,e6/a12]
-- 7026 Blackrock Sorcerer (BurningSteppes, 26 spawns): replace, 3 rows, 3 casts: 20826 Immolate [e6/a3,e2/a0]; 20825 Shadow Bolt [e2/a0]; 13338 Curse of Tongues [e6/a65,e6/a75]
-- 7034 Firegut Ogre Mage (BurningSteppes, 15 spawns): replace, 4 rows, 3 casts: 35916 Molten Armor [e2/a0]; 6742 Bloodlust [e6/a138]; 9053 Fireball [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 9604 Gorgon'och (BurningSteppes, 2 spawns): replace, 4 rows, 3 casts: 35916 Molten Armor [e2/a0]; 6742 Bloodlust [e6/a138]; 9053 Fireball [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 8566 Dark Iron Lookout (SearingGorge, 24 spawns): replace, 4 rows, 3 casts: 88445 Shoot [e2/a0,e140/a0]; 32915 Raptor Strike [e58/a0]; 14443 Multi-Shot [e31/a0]
-- 5839 Dark Iron Geologist (SearingGorge, 15 spawns): replace, 2 rows, 2 casts: 9053 Fireball [e2/a0]; 8858 Bomb [e58/a0]
-- 8598 Frenzied Plaguehound (EasternPlaguelands, 58 spawns): replace, 2 rows, 2 casts: 8599 Enrage [e6/a79,e6/a138]; 90789 Plague Bite [e6/a3,e6/a87]
-- 9447 Scarlet Warder (EasternPlaguelands, 33 spawns): replace, 3 rows, 3 casts: 14518 Crusader Strike [e31/a0,e6/a14]; 15493 Holy Light [e10/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 9449 Scarlet Cleric (EasternPlaguelands, 20 spawns): replace, 3 rows, 3 casts: 15587 Mind Blast [e2/a0]; 15586 Heal [e10/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 8548 Vile Tutor (EasternPlaguelands, 14 spawns): replace, 4 rows, 3 casts: 12040 Shadow Shield [e6/a69,e6/a15]; 16587 Dark Whispers [e6/a13]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 8556 Crypt Walker (EasternPlaguelands, 8 spawns): replace, 2 rows, 2 casts: 744 Poison [e6/a3]; 745 Web [e6/a26,e64/a0]
-- 8563 Wretched Woodsman (EasternPlaguelands, 8 spawns): replace, 2 rows, 2 casts: 43410 Chop [e31/a0,e6/a118]; 11971 Sunder Armor [e6/a22]
-- 31096 Scourge Necromancer (EasternPlaguelands, 6 spawns): replace, 4 rows, 3 casts: 20298 Shadow Bolt [e2/a0]; 51337 Shadowflame [e2/a0,e64/a0]; 51338 Shadowflame [e6/a3]
-- 8538 Unseen Servant (EasternPlaguelands, 5 spawns): replace, 2 rows, 2 casts: 38240 Chilling Touch [e6/a79]; 18267 Curse of Weakness [e6/a13]
-- 10826 Lord Darkscythe (EasternPlaguelands, 5 spawns): replace, 5 rows, 5 casts: 79901 Blood Plague [e6/a3]; 15284 Cleave [e31/a0]; 79934 Demon Armor [e6/a22,e6/a118]; 79902 Plague Strike [e31/a0,e64/a0]; 11971 Sunder Armor [e6/a22]
-- 10821 Hed'mush the Rotting (EasternPlaguelands, 4 spawns): replace, 3 rows, 3 casts: 14099 Mighty Blow [e58/a0,e98/a0]; 16577 Disease Cloud [e6/a23]; 8599 Enrage [e6/a79,e6/a138]
-- 10825 Gish the Unmoving (EasternPlaguelands, 2 spawns): replace, 3 rows, 3 casts: 16564 Gargoyle Strike [e2/a0]; 13445 Rend [e6/a3]; 7020 Stoneform [e6/a101,e6/a61]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 11897 Duskwing (EasternPlaguelands, 1 spawns): replace, 2 rows, 2 casts: 77522 Swoop [e31/a0,e98/a0]; 8281 Sonic Burst [e58/a0,e6/a27]
-- 46095 Rohan the Assassin (EasternPlaguelands, 1 spawns): insert, 5 rows, 5 casts: 34189 Stealth [e6/a16]; 37685 Backstab [e31/a0]; 90783 Deadly Throw [e2/a0,e68/a0]; 30478 Hemorrhage [e31/a0,e6/a87]
-- 8956 Angerclaw Bear (Felwood, 36 spawns): replace, 3 rows, 2 casts: 8599 Enrage [e6/a79,e6/a138]; 84867 Sundering Swipe [e31/a0,e6/a101]
-- 48154 Jadefire Shifter (Felwood, 27 spawns): replace, 1 rows, 1 casts: 86073 Flamethrower [e6/a23]
-- 7158 Deadwood Shaman (Felwood, 20 spawns): replace, 5 rows, 5 casts: 9532 Lightning Bolt [e2/a0]; 13583 Curse of the Deadwood [e6/a118]; 12058 Chain Lightning [e2/a0]; 13585 Lightning Shield [e6/a43]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows
-- 7106 Jadefire Rogue (Felwood, 9 spawns): insert, 3 rows, 3 casts: 13578 Jadefire [e6/a15,e6/a101]; 7159 Backstab [e58/a0]; 13579 Gouge [e2/a0,e6/a12]
-- 47679 Winna Hazzard (Felwood, 1 spawns): insert, 3 rows, 2 casts: 81109 Poison Bolt [e2/a0]; 40818 Toxic Slime [e27/a3,e27/a33,e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 3 rows
-- 38915 Hyjal Warden (Hyjal, 72 spawns): insert, 2 rows, 1 casts: 19643 Mortal Strike [e31/a0,e6/a118]
-- 38913 Twilight Vanquisher (Hyjal, 61 spawns): insert, 2 rows, 1 casts: 79881 Slam [e31/a0]
-- 38926 Twilight Flamecaller (Hyjal, 29 spawns): replace, 5 rows, 3 casts: 15536 Fireball [e2/a0]; 20794 Flamestrike [e2/a0,e27/a3]; 11990 Rain of Fire [e27/a3]
-- 40573 Twilight Stormwaker (Hyjal, 21 spawns): insert, 1 rows, 1 casts: 65060 Twilight Bolt [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 40713 Twilight Augur (Hyjal, 16 spawns): insert, 1 rows, 1 casts: 80607 Flamestep [e5/a0,e2/a0,e27/a3]
-- 38951 Twilight Assassin (Hyjal, 14 spawns): insert, 3 rows, 3 casts: 30991 Stealth [e6/a16,e6/a36]; 37685 Backstab [e31/a0]; 80576 Shadowstep [e5/a0]
-- 43427 Furious Hyjal Warden (Hyjal, 13 spawns): insert, 4 rows, 3 casts: 18328 Incapacitating Shout [e6/a33]; 19643 Mortal Strike [e31/a0,e6/a118]; 15618 Snap Kick [e6/a12,e2/a0]
-- 41031 Twilight Juggernaut (Hyjal, 8 spawns): replace, 1 rows, 1 casts: 77224 Armor Plating [e6/a87]
-- 45859 Venomblood Scorpid (Uldum, 33 spawns): replace, 1 rows, 1 casts: 63900 Thunderstomp [e2/a0]
-- 48041 Pygmy Scout (Uldum, 15 spawns): insert, 3 rows, 2 casts: 79444 Impale [e31/a0,e6/a3]; 73864 Sand Trap [e50/a0]; event_flags 512 (WHILE_CHARMED) dropped on 3 rows
-- 48040 Pygmy Oaf (Uldum, 14 spawns): insert, 2 rows, 2 casts: 86695 Whirlwind [e6/a23,e6/a33,e6/a138]; 86699 Shockwave [e6/a12,e2/a0,e3/a0]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows

DELETE FROM `smart_scripts` WHERE `source_type`=0 AND `entryorguid` IN (2729,2743,5996,5997,5990,6010,5977,5978,5975,6006,6007,8298,8300,8296,8297,8301,8302,8303,12425,7026,7034,9604,8566,5839,8598,9447,9449,8548,8556,8563,31096,8538,10826,10821,10825,11897,46095,8956,48154,7158,7106,47679,38915,38913,38926,40573,40713,38951,43427,41031,45859,48041,48040);
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (12425,46095,7106,47679,38915,38913,40573,40713,38951,43427,48041,48040);
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(2729,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,32919,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Snarl'),
(2743,0,0,0,4,0,100,1,0,0,0,0,0,11,32064,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Battle Shout on Aggro'),
(2743,0,1,0,0,0,100,0,10000,10000,22000,24000,0,11,17207,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Whirlwind'),
(5996,0,0,0,0,0,100,0,0,0,2300,3900,0,11,38557,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Nethergarde Miner - In Combat - Cast \'Throw\''),
(5996,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Nethergarde Miner - Between 0-15% Health - Flee For Assist (No Repeat)'),
(5996,0,2,0,0,0,100,0,6000,9000,21000,26000,0,11,80382,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Nethergarde Miner - In Combat - Cast \'Dirt Toss\''),
(5996,0,3,0,9,0,100,0,0,5,12000,13000,0,11,6016,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Nethergarde Miner - Within 0-5 Range - Cast \'Pierce Armor\''),
(5997,0,0,0,0,0,100,0,0,0,2300,3900,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Nethergarde Engineer - In Combat - Cast \'Shoot\''),
(5997,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Nethergarde Engineer - Between 0-15% Health - Flee For Assist (No Repeat)'),
(5997,0,2,0,0,0,100,0,5000,7000,12000,15000,0,11,79721,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Nethergarde Engineer - In Combat - Cast \'Explosive Shot\''),
(5997,0,3,0,0,0,100,0,8000,12000,22000,26000,0,11,79726,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Nethergarde Engineer - In Combat - Cast \'Ticking Time Bomb\''),
(5990,0,0,0,0,0,100,0,3000,4500,14000,16000,0,11,83657,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Redstone Basilisk - In Combat - Cast \'Hellgaze\''),
(5990,0,1,0,0,0,100,0,6000,8000,22000,24000,0,11,77576,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Redstone Basilisk - In Combat - Cast \'Stone Breath\''),
(6010,0,0,0,0,0,100,0,4000,6000,15000,17000,0,11,81082,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Felhound - In Combat - Cast \'Noxious Breath\''),
(6010,0,1,0,2,0,100,0,0,55,14000,21000,0,11,79616,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Felhound - Between 0-55% Health - Cast \'Drain Life\''),
(5977,0,0,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Mauler - On Aggro - Say Line 0 (No Repeat)'),
(5977,0,1,0,0,0,100,0,6000,9000,20000,22000,0,11,81140,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Mauler - In Combat - Cast \'Thunderclap\''),
(5977,0,2,0,0,0,100,0,2000,5000,35000,41000,0,11,11960,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Mauler - In Combat - Cast \'Curse of the Dreadmaul\''),
(5977,0,3,0,0,0,100,0,9000,14000,25000,28000,0,11,84333,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Mauler - In Combat - Cast \'Summon Dreadmaul\''),
(5977,0,4,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Mauler - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(5977,0,5,0,2,0,100,1,0,30,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Mauler - Between 0-30% Health - Say Line 1 (No Repeat)'),
(5977,0,6,0,9,0,100,0,0,5,17000,18000,0,11,80182,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Mauler - Within 0-5 Range - Cast \'Uppercut\''),
(5978,0,0,0,0,0,100,0,0,0,3400,4700,0,11,79938,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Warlock - In Combat - Cast \'Incinerate\''),
(5978,0,1,0,1,0,100,0,500,1000,600000,600000,0,11,44977,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Warlock - Out of Combat - Cast \'Fel Armor\''),
(5978,0,2,0,0,0,100,0,8000,9000,17000,17500,0,11,79937,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Warlock - In Combat - Cast \'Immolate\''),
(5978,0,3,0,0,0,100,0,9000,14000,25000,28000,0,11,84333,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Warlock - In Combat - Cast \'Summon Dreadmaul\''),
(5978,0,4,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Warlock - On Aggro - Say Line 0 (No Repeat)'),
(5975,0,0,0,0,0,100,0,0,0,3400,4700,0,11,79858,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Ogre Mage - In Combat - Cast \'Frostbolt\''),
(5975,0,1,0,9,0,100,0,0,8,13600,14500,0,11,79850,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Ogre Mage - Within 0-8 Range - Cast \'Frost Nova\''),
(5975,0,2,0,0,0,100,0,8000,9000,15000,16000,0,11,79859,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Ogre Mage - In Combat - Cast \'Ice Lance\''),
(5975,0,3,0,0,0,100,0,9000,14000,25000,28000,0,11,84333,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Ogre Mage - In Combat - Cast \'Summon Dreadmaul\''),
(5975,0,4,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Dreadmaul Ogre Mage - On Aggro - Say Line 0 (No Repeat)'),
(6006,0,0,0,0,0,100,0,0,0,3400,4700,0,11,77721,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowsworn Adept - In Combat - Cast \'Shadow Weave\''),
(6006,0,1,0,9,0,100,0,0,8,13600,14500,0,11,75073,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowsworn Adept - Within 0-8 Range - Cast \'Shadow Nova\''),
(6006,0,2,0,2,0,100,1,0,30,0,0,0,11,77471,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowsworn Adept - Between 0-30% Health - Cast \'Shadow Shield\' (No Repeat)'),
(6007,0,0,0,9,0,100,0,0,8,14000,16000,0,11,35373,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowsworn Enforcer - Within 0-8 Range - Cast \'Shadowfury\''),
(6007,0,1,0,0,0,100,0,2000,4500,12000,13000,0,11,32916,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowsworn Enforcer - In Combat - Cast \'Shadow Cleave\''),
(8298,0,0,0,0,0,100,0,0,0,3400,4700,0,11,79884,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Akubar the Seer - In Combat - Cast \'Lightning Bolt\''),
(8298,0,1,0,1,0,100,0,500,1000,600000,600000,0,11,79892,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Akubar the Seer - Out of Combat - Cast \'Water Shield\''),
(8298,0,2,0,16,0,100,0,79892,1,15000,30000,0,11,79892,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Akubar the Seer - On Friendly Unit Missing Buff \'Water Shield\' - Cast \'Water Shield\''),
(8298,0,3,0,9,0,100,0,0,8,14000,14500,0,11,79890,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Akubar the Seer - Within 0-8 Range - Cast \'Flame Shock\''),
(8298,0,4,0,0,0,100,0,5000,7000,19000,22000,0,11,39591,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Akubar the Seer - In Combat - Cast \'Searing Totem\''),
(8298,0,5,0,0,0,100,0,12000,15000,25000,31000,0,11,79886,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Akubar the Seer - In Combat - Cast \'Lava Burst\''),
(8300,0,0,0,9,0,100,1,0,20,0,0,0,11,82797,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ravage - Within 0-20 Range - Cast \'Leaping Bite\' (No Repeat)'),
(8300,0,1,0,0,0,100,0,4500,4500,18500,19200,0,11,7367,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ravage - In Combat - Cast \'Infected Bite\''),
(8300,0,2,0,0,0,50,0,7000,8000,10000,25000,0,11,13445,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ravage - In Combat - Cast \'Rend\''),
(8300,0,3,0,0,0,80,0,5000,9000,18000,21000,0,11,3149,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ravage - In Combat - Cast \'Furious Howl\''),
(8296,0,0,0,0,0,100,0,0,0,3400,4700,0,11,20298,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Mojo the Twisted - In Combat - Cast \'Shadow Bolt\''),
(8296,0,1,0,1,0,100,0,500,1000,600000,600000,0,11,79954,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Mojo the Twisted - Out of Combat - Cast \'Fel Armor\''),
(8296,0,2,0,2,0,100,1,0,30,0,0,0,11,31976,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Mojo the Twisted - Between 0-30% Health - Cast \'Shadow Shield\' (No Repeat)'),
(8297,0,0,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Magronos the Unyielding - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(8297,0,1,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Magronos the Unyielding - Between 0-30% Health - Say Line 0 (No Repeat)'),
(8297,0,2,0,9,0,100,0,0,5,17000,18000,0,11,10966,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Magronos the Unyielding - Within 0-5 Range - Cast \'Uppercut\''),
(8297,0,3,0,0,0,100,0,6000,14000,19000,22500,0,11,22859,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Magronos the Unyielding - In Combat - Cast \'Mortal Cleave\''),
(8297,0,4,0,0,0,100,0,14000,18000,35000,36000,0,11,78827,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Magronos the Unyielding - In Combat - Cast \'Bladestorm\''),
(8301,0,0,0,0,0,100,0,2000,3000,11000,12000,0,11,21067,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Clack the Reaver - In Combat - Cast \'Poison Bolt\''),
(8301,0,1,0,0,0,100,0,6000,9000,18000,22000,0,11,79607,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Clack the Reaver - In Combat - Cast \'Venom Splash\''),
(8301,0,2,0,2,0,100,0,0,40,15000,16000,0,11,79840,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Clack the Reaver - Between 0-40% Health - Cast \'Harden\''),
(8302,0,0,0,0,0,100,0,2000,4500,12000,15000,0,11,83657,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Deatheye - In Combat - Cast \'Hellgaze\''),
(8302,0,1,0,0,0,100,0,6000,9000,24000,27000,0,11,77576,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Deatheye - In Combat - Cast \'Stone Breath\''),
(8302,0,2,0,2,0,100,0,0,40,9000,9000,0,11,54663,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Deatheye - Between 0-40% Health - Cast \'Fatal Bite\''),
(8303,0,0,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Grunter - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(8303,0,1,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Grunter - Between 0-30% Health - Say Line 0 (No Repeat)'),
(8303,0,2,0,0,0,100,0,3000,4000,12000,13000,0,11,3604,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Grunter - In Combat - Cast \'Tendon Rip\''),
(8303,0,3,0,0,0,100,0,2000,9000,9000,25000,0,11,79581,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Grunter - In Combat - Cast \'Angry Snort\''),
(8303,0,4,0,4,0,100,1,0,0,0,0,0,11,6268,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Grunter - On Aggro - Cast \'Rushing Charge\' (No Repeat)'),
(12425,0,0,0,67,0,100,0,3900,6900,0,0,0,11,15582,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Casts Backstab'),
(12425,0,1,0,2,0,100,0,0,40,22000,25000,0,11,6434,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Slice and Dice at 40% HP'),
(12425,0,2,0,0,0,100,0,10000,12000,16000,18000,0,11,12540,0,0,0,0,0,4,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Gouge'),
(7026,0,0,0,0,0,100,0,5000,6000,15000,18000,0,11,20826,0,0,0,0,0,4,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Immolate'),
(7026,0,1,0,0,0,100,0,0,0,3400,4700,0,11,20825,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shadow Bolt'),
(7026,0,2,0,0,0,100,0,7000,9000,18000,24000,0,11,13338,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Curse of Tongues'),
(7034,0,0,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Say Text on Aggro'),
(7034,0,1,0,11,0,100,1,0,0,0,0,0,11,35916,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Molten Armor on Spawn'),
(7034,0,2,0,2,0,100,1,0,40,0,0,0,11,6742,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Bloodlust at 40% HP'),
(7034,0,3,0,0,0,100,0,0,0,3400,4700,0,11,9053,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Fireball'),
(9604,0,0,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Say Text on Aggro'),
(9604,0,1,0,11,0,100,1,0,0,0,0,0,11,35916,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Molten Armor on Spawn'),
(9604,0,2,0,2,0,100,1,0,40,0,0,0,11,6742,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Bloodlust at 40% HP'),
(9604,0,3,0,0,0,100,0,0,0,3400,4700,0,11,9053,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Fireball'),
(8566,0,0,0,0,0,100,0,0,0,2300,3900,0,11,88445,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Lookout - In Combat - Cast \'Shoot\''),
(8566,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Lookout - Between 0-15% Health - Flee For Assist (No Repeat)'),
(8566,0,2,0,9,0,100,0,0,5,15000,17000,0,11,32915,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Lookout - Within 0-5 Range - Cast \'Raptor Strike\''),
(8566,0,3,0,0,0,100,0,8000,11000,17000,25000,0,11,14443,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Lookout - In Combat - Cast \'Multi-Shot\''),
(5839,0,0,0,0,0,100,0,2000,4500,9000,12000,0,11,9053,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Geologist - In Combat - Cast \'Fireball\''),
(5839,0,1,0,9,0,100,0,5,30,13000,14500,0,11,8858,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Iron Geologist - Within 5-30 Range - Cast \'Bomb\''),
(8598,0,0,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Enrage at 30% HP'),
(8598,0,1,0,0,0,100,0,5000,6000,17000,19000,0,11,90789,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Plague Bite'),
(9447,0,0,0,9,0,100,0,0,5,14000,16000,0,11,14518,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Crusader Strike on Close'),
(9447,0,1,0,2,0,100,1,0,40,0,0,0,11,15493,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Holy Light at 40% HP'),
(9447,0,2,0,14,0,100,0,800,40,15000,18000,0,11,15493,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Holy Light on Friendlies'),
(9449,0,0,0,0,0,100,0,0,0,3400,4700,0,11,15587,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Mind Blast'),
(9449,0,1,0,14,0,100,0,500,40,15000,18000,0,11,15586,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Heal on Friendlies'),
(9449,0,2,0,2,0,100,0,0,40,22000,25000,0,11,15586,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Heal at 40% HP'),
(8548,0,0,0,0,0,100,0,5000,8000,30000,35000,0,11,12040,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shadow Shield'),
(8548,0,1,0,4,0,100,1,0,0,0,0,0,11,16587,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Dark Whispers on Aggro'),
(8548,0,2,0,16,0,100,0,16587,40,22000,25000,0,11,16587,2,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Dark Whispers on Friendlies Missing Buff'),
(8548,0,3,0,2,0,100,1,0,15,0,0,0,25,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Flee at 15% HP'),
(8556,0,0,0,0,0,100,0,5000,5000,18000,19000,0,11,744,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Poison'),
(8556,0,1,0,9,0,100,0,0,30,15000,25000,0,11,745,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Web on Close'),
(8563,0,0,0,0,0,100,0,6000,8000,17000,18000,0,11,43410,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Chop'),
(8563,0,1,0,0,0,100,0,4000,4000,10000,12000,0,11,11971,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sunder Armor'),
(31096,0,0,0,0,0,100,0,0,0,3400,4700,0,11,20298,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shadow Bolt'),
(31096,0,1,0,2,0,100,1,0,15,0,0,0,25,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Flee at 15% HP'),
(31096,0,2,0,0,0,100,0,7000,8000,20000,25000,0,11,51337,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shadowflame'),
(31096,0,3,0,0,0,100,0,4000,4000,12000,16000,0,11,51338,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shadowflame'),
(8538,0,0,0,0,0,100,0,8000,8000,12000,14000,0,11,38240,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Chilling Touch'),
(8538,0,1,0,0,0,100,0,3000,5000,20000,27000,0,11,18267,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Curse of Weakness'),
(10826,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,79901,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Blood Plague'),
(10826,0,1,0,0,0,100,0,4000,4000,17000,18000,0,11,15284,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Cleave'),
(10826,0,2,0,1,0,100,0,500,1000,600000,600000,0,11,79934,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Demon Armor on Spawn'),
(10826,0,3,0,0,0,100,0,10000,11000,14000,16500,0,11,79902,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Plague Strike'),
(10826,0,4,0,0,0,100,0,15000,16000,10000,22000,0,11,11971,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sunder Armor'),
(10821,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,14099,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Mighty Blow'),
(10821,0,1,0,11,0,100,1,0,0,0,0,0,11,16577,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Disease Cloud on Spawn'),
(10821,0,2,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Enrage at 30% HP'),
(10825,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,16564,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Gargoyle Strike'),
(10825,0,1,0,0,0,100,0,5000,8000,18000,22000,0,11,13445,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Rend'),
(10825,0,2,0,2,0,100,1,0,40,0,0,0,11,7020,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Stoneform at 40% HP'),
(11897,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,77522,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Swoop'),
(11897,0,1,0,9,0,100,0,0,8,15000,25000,0,11,8281,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sonic Burst on Close'),
(46095,0,0,0,11,0,100,1,0,0,0,0,0,11,34189,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Stealth on Spawn'),
(46095,0,1,0,7,0,100,1,0,0,0,0,0,11,34189,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Stealth on Evade'),
(46095,0,2,0,67,0,100,0,3900,6900,0,0,0,11,37685,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Casts Backstab'),
(46095,0,3,0,0,0,100,0,0,0,3500,4100,0,11,90783,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Deadly Throw'),
(46095,0,4,0,0,0,100,0,5000,8000,17000,19000,0,11,30478,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Hemorrhage'),
(8956,0,0,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Angerclaw Bear - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(8956,0,1,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Angerclaw Bear - Between 0-30% Health - Say Line 0 (No Repeat)'),
(8956,0,2,0,9,0,100,0,0,5,22000,25000,0,11,84867,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Angerclaw Bear - Within 0-5 Range - Cast \'Sundering Swipe\''),
(48154,0,0,0,4,0,100,1,0,0,0,0,0,11,86073,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Jadefire Shifter - On Aggro - Cast \'Flamethrower\' (No Repeat)'),
(7158,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9532,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Deadwood Shaman - In Combat - Cast \'Lightning Bolt\''),
(7158,0,1,0,0,0,100,0,4000,11000,12000,15000,0,11,13583,2,0,0,0,0,4,0,0,0,0,0.0,0.0,0.0,0.0,'Deadwood Shaman - In Combat - Cast \'Curse of the Deadwood\''),
(7158,0,2,0,0,0,100,0,5500,9500,6500,9500,0,11,12058,2,0,0,0,0,4,0,0,0,0,0.0,0.0,0.0,0.0,'Deadwood Shaman - In Combat - Cast \'Chain Lightning\''),
(7158,0,3,0,1,0,100,0,500,1000,600000,600000,0,11,13585,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deadwood Shaman - Out of Combat - Cast \'Lightning Shield\''),
(7158,0,4,0,16,0,100,0,13585,1,15000,30000,0,11,13585,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deadwood Shaman - On Friendly Unit Missing Buff \'Lightning Shield\' - Cast \'Lightning Shield\''),
(7106,0,0,0,0,0,100,0,6000,9000,16000,19000,0,11,13578,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Jadefire Rogue - In Combat - Cast \'Jadefire\''),
(7106,0,1,0,67,0,100,0,6000,11000,0,0,0,11,7159,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Jadefire Rogue - On Behind Target - Cast \'Backstab\''),
(7106,0,2,0,0,0,100,0,4000,7000,9000,12000,0,11,13579,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Jadefire Rogue - In Combat - Cast \'Gouge\''),
(47679,0,0,0,0,0,100,0,0,0,3400,4700,0,11,81109,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Winna Hazzard - In Combat - Cast \'Poison Bolt\''),
(47679,0,1,0,9,0,100,0,0,8,15000,19000,0,11,40818,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Winna Hazzard - Within 0-8 Range - Cast \'Toxic Slime\''),
(47679,0,2,0,4,0,100,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Winna Hazzard - On Aggro - Say Line 0 (No Repeat)'),
(38915,0,0,0,0,0,100,0,5000,5000,11000,14000,0,11,19643,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 5000 and 5000 ms (and later repeats every 11000 and 14000 ms) - Self: Cast spell 19643 on Victim // '),
(38915,0,1,0,1,0,100,0,1000,1000,3000,3000,0,49,0,0,0,0,0,0,11,40229,10,0,0,0.0,0.0,0.0,0.0,'When out of combat and timer at the begining between 1000 and 1000 ms (and later repeats every 3000 and 3000 ms) - Self: Attack Creature Scalding Rock Elemental (40229) in 10 yd // '),
(38913,0,0,0,0,0,100,0,6000,8000,14000,18000,0,11,79881,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 6000 and 8000 ms (and later repeats every 14000 and 18000 ms) - Self: Cast spell 79881 on Victim // Twilight Vanquisher - In Combat - Cast \'Slam\''),
(38913,0,1,0,1,0,100,0,1000,1000,5000,5000,0,49,0,0,0,0,0,0,11,38915,6,0,0,0.0,0.0,0.0,0.0,'When out of combat and timer at the begining between 1000 and 1000 ms (and later repeats every 5000 and 5000 ms) - Self: Attack Creature Hyjal Warden (38915) in 6 yd // '),
(38926,0,0,0,0,0,100,0,0,0,3400,4700,0,11,15536,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 0 and 0 ms (and later repeats every 3400 and 4700 ms) - Self: Cast spell 15536 on Victim // Twilight Flamecaller - In Combat - Cast \'Fireball\''),
(38926,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'When health between 0% and 15% (check every 0 - 0 ms) - Self: Flee for assist // Twilight Flamecaller - Between 0-15% Health - Flee For Assist (No Repeat)'),
(38926,0,2,0,0,0,100,0,3000,6000,11000,12000,0,11,20794,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 3000 and 6000 ms (and later repeats every 11000 and 12000 ms) - Self: Cast spell 20794 on Victim // Twilight Flamecaller - In Combat - Cast \'Flamestrike\''),
(38926,0,3,0,0,0,100,0,9000,9000,21000,22000,0,11,11990,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 9000 and 9000 ms (and later repeats every 21000 and 22000 ms) - Self: Cast spell 11990 on Victim // Twilight Flamecaller - In Combat - Cast \'Rain of Fire\''),
(38926,0,4,0,1,0,100,0,1000,1000,5000,5000,0,49,0,0,0,0,0,0,11,38915,10,0,0,0.0,0.0,0.0,0.0,'When out of combat and timer at the begining between 1000 and 1000 ms (and later repeats every 5000 and 5000 ms) - Self: Attack Creature Hyjal Warden (38915) in 10 yd // '),
(40573,0,0,0,0,0,100,0,0,0,3400,4700,0,11,65060,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Stormwaker - In Combat - Cast \'Twilight Bolt\''),
(40713,0,0,0,67,0,100,0,9000,11000,0,0,0,11,80607,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Augur - On Behind Target - Cast \'Flamestep\''),
(38951,0,0,0,1,0,100,1,3000,5000,0,0,0,11,30991,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Assassin - Out of Combat - Cast \'Stealth\' (No Repeat)'),
(38951,0,1,0,67,0,100,0,3900,6900,0,0,0,11,37685,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Assassin - On Behind Target - Cast \'Backstab\''),
(38951,0,2,0,67,0,100,0,8000,9000,0,0,0,11,80576,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Assassin - On Behind Target - Cast \'Shadowstep\''),
(43427,0,0,0,0,0,100,0,5000,6000,22000,30000,0,11,18328,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 5000 and 6000 ms (and later repeats every 22000 and 30000 ms) - Self: Cast spell 18328 on Self // Furious Hyjal Warden - In Combat - Cast \'Incapacitating Shout\''),
(43427,0,1,0,0,0,100,0,1000,3000,7000,14000,0,11,19643,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 1000 and 3000 ms (and later repeats every 7000 and 14000 ms) - Self: Cast spell 19643 on Victim // Furious Hyjal Warden - In Combat - Cast \'Mortal Strike\''),
(43427,0,2,0,0,0,100,0,1000,3000,11000,13000,0,11,15618,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 1000 and 3000 ms (and later repeats every 11000 and 13000 ms) - Self: Cast spell 15618 on Victim // '),
(43427,0,3,0,1,0,100,0,1000,1000,3000,3000,0,49,0,0,0,0,0,0,11,40229,10,0,0,0.0,0.0,0.0,0.0,'When out of combat and timer at the begining between 1000 and 1000 ms (and later repeats every 3000 and 3000 ms) - Self: Attack Creature Scalding Rock Elemental (40229) in 10 yd // '),
(41031,0,0,0,1,0,100,0,500,1000,600000,600000,0,11,77224,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Juggernaut - Out of Combat - Cast \'Armor Plating\''),
(45859,0,0,0,9,0,100,0,0,5,12000,15000,0,11,63900,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Venomblood Scorpid - Within 0-5 Range - Cast \'Thunderstomp\''),
(48041,0,0,0,0,0,100,0,0,0,2300,3900,0,11,79444,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Pygmy Scout - In Combat - Cast \'Impale\''),
(48041,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Pygmy Scout - Between 0-15% Health - Flee For Assist (No Repeat)'),
(48041,0,2,0,9,0,100,0,0,8,15000,15000,0,11,73864,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Pygmy Scout - Within 0-8 Range - Cast \'Sand Trap\''),
(48040,0,0,0,9,0,100,0,0,8,15000,18000,0,11,86695,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Pygmy Oaf - Within 0-8 Range - Cast \'Whirlwind\''),
(48040,0,1,0,0,0,100,0,5000,5000,12500,13600,0,11,86699,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Pygmy Oaf - In Combat - Cast \'Shockwave\'');
