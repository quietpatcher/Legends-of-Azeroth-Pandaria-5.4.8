-- Creature abilities (wave 1) for creatures that have no SmartAI rows today: 473 creatures, 866 smart_scripts rows.
-- Zones: 002_silverpine_forest, 004_dun_morogh_coldridge_valley_and_new_tinkertown, 005_teldrassil_and_shadowglen, 007_durotar_valley_of_trials_and_echo_isles, 008_mulgore_and_camp_narache, 009_eversong_woods_and_sunstrider_isle, 011_the_lost_isles, 012_the_wandering_isle, 013_westfall, 014_loch_modan, 015_darkshore, 016_bloodmyst_isle, 017_ruins_of_gilneas, 018_northern_barrens, 019_azshara, 020_ghostlands, 021_redridge_mountains, 022_shadowfang_keep, 023_blackfathom_deeps, 024_duskwood, 025_wetlands, 026_ashenvale, 027_hillsbrad_foothills, 028_arathi_highlands, 029_northern_stranglethorn, 030_stonetalon_mountains, 031_gnomeregan, 032_scarlet_monastery, 033_the_cape_of_stranglethorn, 034_southern_barrens, 035_desolace, 036_the_hinterlands, 037_dustwallow_marsh, 038_western_plaguelands, 039_feralas, 040_eastern_plaguelands, 041_thousand_needles, 042_badlands, 043_tanaris, 044_felwood, 045_searing_gorge, 046_burning_steppes, 047_un_goro_crater, 048_winterspring, 049_swamp_of_sorrows, 050_blasted_lands, 051_silithus, 052_deadwind_pass, 053_plaguelands, 054_moonglade, 055_razorfen_kraul
-- Source: DeltaTho PR 15 creature abilities as ported in 1LineAtaTime/LoA-Pandaria-Playerbots 6d8f6c15 / d9db430a (GPLv2). Re-filtered for
-- our data: creatures that already have source_type 0 rows or a ScriptName, and creatures touched by open work branches, are left out.
-- Plausibility check done on the kept rows: spell names are class and creature fitting; 30% of the cast rows are also confirmed by the
-- SkyFire / Cataclysm Preservation / Alex reference databases (the references have few Cataclysm and MoP scripts).
-- Idempotent: DELETE of the listed entries, then INSERT; AIName is set to SmartAI only where AIName and ScriptName are empty.
-- Rollback: the commented statements at the end of this file.

-- 002_silverpine_forest
SET @ENTRIES := '1765';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(1765, 0, 0, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 3149, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Worg - Between 20-80% Health - Cast ''Furious Howl'' (No Repeat)');

-- 004_dun_morogh_coldridge_valley_and_new_tinkertown
SET @ENTRIES := '1131,42290';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(1131, 0, 0, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 3149, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Winter Wolf - Between 20-80% Health - Cast ''3149'' (No Repeat)'),
(42290, 0, 0, 1, 1, 0, 10, 0, 30000, 600000, 120000, 600000, 4, 1018, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Winter Wolf - Out of Combat - Play Sound 1018'),
(42290, 0, 1, 0, 61, 0, 100, 0, 30000, 600000, 120000, 600000, 5, 393, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Winter Wolf - Out of Combat - Play Emote 393'),
(42290, 0, 2, 0, 0, 0, 100, 0, 6000, 7000, 18000, 20000, 11, 32919, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Winter Wolf - In Combat - Cast ''Snarl''');

-- 005_teldrassil_and_shadowglen
SET @ENTRIES := '1998,2001';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(1998, 0, 0, 0, 0, 0, 100, 0, 2300, 2300, 17600, 17600, 11, 744, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Webwood Lurker - In Combat - Cast ''Poison'''),
(2001, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 11, 6752, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Giant Webwood Spider - On Respawn - Cast ''Weak Poison Proc'''),
(2001, 0, 1, 0, 0, 0, 100, 0, 6000, 6000, 12800, 12800, 11, 744, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Giant Webwood Spider - In Combat - Cast ''Poison'''),
(2001, 0, 2, 0, 0, 0, 100, 0, 7500, 7500, 15000, 15000, 11, 745, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Giant Webwood Spider - In Combat - Cast ''Web''');

-- 007_durotar_valley_of_trials_and_echo_isles
SET @ENTRIES := '38046,38217,39215,39337';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(38046, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 75002, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'Wildmane Cat - On Aggro - Cast ''Leaping Rush'' (No Repeat)'),
(38046, 0, 1, 0, 0, 0, 100, 0, 4000, 4500, 18000, 22000, 11, 31279, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wildmane Cat - In Combat - Cast ''Swipe'''),
(38046, 0, 2, 0, 1, 0, 30, 0, 45000, 55000, 120000, 300000, 11, 71232, 0, 0, 0, 0, 0, 9, 38141, 8, 25, 0, 0, 0, 0, 'Wildmane Cat - Out of Combat - Cast ''Wild Pounce'''),
(38217, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Darkspear Watcher - In Combat - Cast ''Shoot'''),
(39215, 0, 0, 0, 0, 0, 100, 0, 2000, 4500, 12000, 20000, 11, 75356, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Captured Northwatch Scout - In Combat - Cast ''Fisticuffs'''),
(39337, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wayward Plainstrider - On Aggro - Cast ''Rushing Charge'' (No Repeat)'),
(39337, 0, 1, 0, 1, 0, 100, 1, 2000, 3000, 0, 0, 11, 73757, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Wayward Plainstrider - Out of Combat - Cast ''Water Walk'' (No Repeat)');

-- 008_mulgore_and_camp_narache
SET @ENTRIES := '3035,36696';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(3035, 0, 0, 0, 0, 0, 100, 1, 2800, 6400, 0, 0, 11, 3604, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Flatland Cougar - In Combat - Cast ''Tendon Rip'' (No Repeat)'),
(36696, 0, 0, 0, 0, 0, 100, 1, 2000, 2000, 0, 0, 11, 3385, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Time = 2 seconds - Self: Cast spell Boar Charge (3385) on Self');

-- 009_eversong_woods_and_sunstrider_isle
SET @ENTRIES := '15635,15649,15650,15949,15967,16855';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(15635, 0, 0, 0, 2, 0, 100, 1, 10, 30, 0, 0, 11, 12160, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Eversong Tender - Between 10-30% Health - Cast ''Rejuvenation'' (No Repeat)'),
(15649, 0, 0, 0, 2, 0, 100, 1, 5, 15, 0, 0, 11, 29117, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Feral Dragonhawk Hatchling - Between 5-15% Health - Cast ''Feather Burst'' (No Repeat)'),
(15650, 0, 0, 0, 0, 0, 100, 0, 3100, 3100, 22800, 22800, 11, 29117, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Crazed Dragonhawk - In Combat - Cast ''Feather Burst'''),
(15949, 0, 0, 0, 0, 0, 100, 0, 2500, 3000, 9500, 10000, 11, 6818, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Thaelis the Hungerer - In Combat - Cast ''Corrupted Intellect'''),
(15967, 0, 0, 0, 2, 0, 100, 1, 20, 40, 0, 0, 11, 7994, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ether Fiend - Between 20-40% Health - Cast ''Nullify Mana'' (No Repeat)'),
(16855, 0, 0, 0, 0, 0, 100, 0, 4500, 6000, 25000, 26000, 11, 6016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Tregla - In Combat - Cast ''Pierce Armor''');

-- 011_the_lost_isles
SET @ENTRIES := '34763,35812,35838,35891,35894,35896,35897,35904,36092,36149,36153,36346,36681,36719,36735,36740,38187,38359,38360,38575,38808,38809,38810,38811,38845,38851,39042,39069,39141,39142,39143,39193,39354,39376,39426,39449,39589,40064,40067,40068';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(34763, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 69203, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Daggertooth Shark - In Combat - Cast ''Vicious Bite'''),
(35812, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 38560, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Smart Mining Monkey - In Combat - Cast ''Throw'''),
(35838, 0, 0, 0, 2, 0, 100, 0, 0, 40, 15000, 20000, 11, 11986, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Pygmy Witchdoctor - Between 0-40% Health - Cast ''Healing Wave'''),
(35838, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 25000, 30000, 11, 18503, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Pygmy Witchdoctor - In Combat - Cast ''Hex'''),
(35838, 0, 2, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 9613, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Pygmy Witchdoctor - In Combat - Cast ''Shadow Bolt'''),
(35891, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 15691, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'SI:7 Infiltrator - In Combat - Cast ''Eviscerate'''),
(35894, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 15620, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Orc Scout - In Combat - Cast ''Shoot'''),
(35896, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 68207, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Poison Spitter - In Combat - Cast ''Poison Spit'''),
(35896, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 68208, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Poison Spitter - In Combat - Cast ''Shoot Thorns'''),
(35897, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 68209, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Freezya - In Combat - Cast ''Frostbolt'''),
(35904, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 31289, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Jungle Cat - In Combat - Cast ''Claw'''),
(36092, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 14873, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'SI:7 Assassin - In Combat - Cast ''Sinister Strike'''),
(36149, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Alliance Sailor - In Combat - Cast ''Strike'''),
(36153, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Alliance Captain - Within 0-8 Range - Cast ''Demoralizing Shout'''),
(36346, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 15691, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'SI:7 Operative - In Combat - Cast ''Eviscerate'''),
(36681, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 69203, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ravenous Lurker - In Combat - Cast ''Vicious Bite'''),
(36719, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 31273, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Pterrordax Scavenger - Within 0-8 Range - Cast ''Screech'''),
(36735, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 35321, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Teraptor Matriarch - In Combat - Cast ''Gushing Wound'''),
(36735, 0, 1, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 36629, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Teraptor Matriarch - Within 0-8 Range - Cast ''Terrifying Roar'''),
(36740, 0, 0, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 6268, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Teraptor Hatchling - Within 8-25 Range - Cast ''Rushing Charge'''),
(38187, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 16827, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Spiny Raptor - In Combat - Cast ''Claw'''),
(38187, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 42320, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Spiny Raptor - In Combat - Cast ''Head Butt'''),
(38359, 0, 0, 0, 2, 0, 100, 1, 0, 30, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vashj''elan Warrior - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(38359, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 57846, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vashj''elan Warrior - In Combat - Cast ''Heroic Strike'''),
(38360, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 11831, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vashj''elan Siren - Within 0-8 Range - Cast ''Frost Nova'''),
(38360, 0, 1, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 9672, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vashj''elan Siren - In Combat - Cast ''Frostbolt'''),
(38575, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 74613, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Oomlot Tribesman - In Combat - Cast ''Shoot'''),
(38808, 0, 0, 0, 0, 0, 100, 0, 3000, 5000, 9000, 12000, 11, 12548, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gaahl - In Combat - Cast ''Frost Shock'''),
(38809, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 75945, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Malmo - In Combat - Cast ''Fury of the Storm'''),
(38809, 0, 1, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 57780, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Malmo - In Combat - Cast ''Lightning Bolt'''),
(38810, 0, 0, 0, 0, 0, 100, 0, 1000, 3000, 14000, 16000, 11, 75946, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Teloch - In Combat - Cast ''Fire and the Flames'''),
(38810, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 39591, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Teloch - On Aggro - Cast ''Searing Totem'' (No Repeat)'),
(38811, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 84837, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Oostan Headhunter - In Combat - Cast ''Shoot'''),
(38845, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 8873, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Child of Volcanoth - Within 0-5 Range - Cast ''Flame Breath'''),
(38851, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 72991, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Volcanoth Priest - In Combat - Cast ''Fireball'''),
(39042, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Alliance Paratrooper - In Combat - Cast ''Shoot'''),
(39069, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Alliance Paratrooper - In Combat - Cast ''Shoot'''),
(39141, 0, 0, 0, 2, 0, 100, 0, 0, 40, 30000, 35000, 11, 79853, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Commander Arrington - Between 0-40% Health - Cast ''Evasion'''),
(39141, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 79852, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Commander Arrington - In Combat - Cast ''Eviscerate'''),
(39141, 0, 2, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 60842, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Commander Arrington - In Combat - Cast ''Expose Armor'''),
(39141, 0, 3, 0, 9, 0, 100, 0, 0, 10, 12000, 15000, 11, 79851, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Commander Arrington - Within 0-10 Range - Cast ''Fan of Knives'''),
(39142, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 60850, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Darkblade Cyn - In Combat - Cast ''Mutilate'''),
(39142, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 60195, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Darkblade Cyn - In Combat - Cast ''Sinister Strike'''),
(39143, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 79862, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Alexi Silenthowl - In Combat - Cast ''Backstab'''),
(39143, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 79866, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Alexi Silenthowl - In Combat - Cast ''Deadly Throw'''),
(39143, 0, 2, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 79863, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Alexi Silenthowl - In Combat - Cast ''Hemorrhage'''),
(39193, 0, 0, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 76136, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Brute Overseer - Out of Combat - Cast ''Acidic Sweat'''),
(39193, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 3551, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Brute Overseer - In Combat - Cast ''Skull Crack'''),
(39354, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 32735, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Steamwheedle Shark - In Combat - Cast ''Saw Blade'''),
(39354, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 75962, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Steamwheedle Shark - In Combat - Cast ''Shred Armor'''),
(39376, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 73867, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'KTC Oil Bot - In Combat - Cast ''Cutting Laser'''),
(39426, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 75924, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Candy Cane - In Combat - Cast ''Heartbreaker'''),
(39449, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 75361, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Southsea Mercenary - In Combat - Cast ''Swashbuckling Slice'''),
(39589, 0, 0, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 76136, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Brute Bodyguard - Out of Combat - Cast ''Acidic Sweat'''),
(39589, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 10000, 14000, 11, 10966, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Brute Bodyguard - In Combat - Cast ''Uppercut'''),
(40064, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 16827, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Jungle Panther - In Combat - Cast ''Claw'''),
(40064, 0, 1, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 75002, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Jungle Panther - Within 8-25 Range - Cast ''Leaping Rush'''),
(40067, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 74724, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Iceeya - In Combat - Cast ''Frostbolt'''),
(40068, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 74726, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venom Spitter - In Combat - Cast ''Shoot Thorns'''),
(40068, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 74725, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venom Spitter - In Combat - Cast ''Venom Spit''');

-- 012_the_wandering_isle
SET @ENTRIES := '60554,60851,60852,60853,60854';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(60554, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 128510, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Escaped Horde Crewman - Within 0-5 Range - Cast ''Double Thrust'''),
(60851, 0, 0, 0, 0, 0, 100, 0, 5000, 7000, 14000, 17000, 11, 128440, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Delora Lionheart - In Combat - Cast ''Piercing Strikes'''),
(60851, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 128513, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Delora Lionheart - In Combat - Cast ''Strike'''),
(60852, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 128515, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Korga Strongmane - In Combat - Cast ''Lightning Bolt'''),
(60853, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 128526, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Makael Bay - Within 0-5 Range - Cast ''Saw Blade'''),
(60853, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 107115, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Makael Bay - In Combat - Cast ''Throw Dynamite'''),
(60854, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 128510, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Escaped Horde Crewman - Within 0-5 Range - Cast ''Double Thrust''');

-- 013_westfall
SET @ENTRIES := '596,42407,51915';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(596, 0, 0, 0, 0, 0, 100, 0, 2300, 4100, 7400, 9800, 11, 20883, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Brainwashed Noble - In Combat - Cast ''Arcane Blast'''),
(596, 0, 1, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 6117, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Brainwashed Noble - Between 30-60% Health - Cast ''Mage Armor'' (No Repeat)'),
(42407, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sentinel Hill Guard - In Combat - Cast ''Revenge'''),
(42407, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sentinel Hill Guard - In Combat - Cast ''Shield Block'''),
(42407, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sentinel Hill Guard - In Combat - Cast ''Shoot'''),
(51915, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Westfall Brigade Guard - In Combat - Cast ''Revenge'''),
(51915, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Westfall Brigade Guard - In Combat - Cast ''Shield Block'''),
(51915, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Westfall Brigade Guard - In Combat - Cast ''Shoot''');

-- 014_loch_modan
SET @ENTRIES := '44724';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(44724, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 84883, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Landshaper - In Combat - Cast ''Twilight Bolt''');

-- 015_darkshore
SET @ENTRIES := '33127,33181,34056,34427,48763';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(33127, 0, 0, 0, 0, 0, 100, 0, 4000, 4500, 12000, 17000, 11, 75008, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Moonstalker - In Combat - Cast ''Pounce'''),
(33181, 0, 0, 0, 0, 0, 100, 0, 3000, 5000, 15000, 20000, 11, 5884, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Anaya Dawnrunner - In Combat - Cast ''Banshee Curse'''),
(34056, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 11876, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vigilant Protector - Within 0-8 Range - Cast ''War Stomp'''),
(34427, 0, 0, 0, 1, 0, 100, 1, 1000, 3000, 0, 0, 11, 12746, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Thalya the Voidcaller - Out of Combat - Cast ''Summon Voidwalker'' (No Repeat)'),
(48763, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 30000, 35000, 11, 75017, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Forlorn Highborne - In Combat - Cast ''Curse of Doom''');

-- 016_bloodmyst_isle
SET @ENTRIES := '17322,17327,17328,17330,17331,17333,17334,17336,17339,17340,17341,17342,17343,17346,17349,17350,17352,17353,17358,17494,17522,17523,17527,17604,17607,17608,17609,17661,17678,17683,17704,17715';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(17322, 0, 0, 0, 0, 0, 100, 0, 10000, 15000, 0, 0, 11, 31282, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Infected Wildkin - In Combat - Cast ''Infected Wound'''),
(17327, 0, 0, 0, 0, 0, 100, 0, 1000, 1000, 15000, 15000, 11, 12550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Blacksilt Tidecaller - In Combat - Cast ''Lightning Shield'''),
(17327, 0, 1, 0, 0, 0, 100, 0, 5300, 5300, 19600, 19600, 11, 12160, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Blacksilt Tidecaller - In Combat - Cast ''Rejuvenation'''),
(17328, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 18000, 24000, 11, 31290, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Blacksilt Shorestriker - In Combat - Cast ''Net'''),
(17330, 0, 0, 0, 0, 0, 100, 0, 500, 2000, 4000, 6000, 11, 9739, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Blacksilt Seer - In Combat - Cast ''Wrath'''),
(17330, 0, 1, 0, 2, 0, 100, 0, 0, 35, 20000, 24000, 11, 12160, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Blacksilt Seer - Between 0-35% Health - Cast ''Rejuvenation'''),
(17330, 0, 2, 0, 2, 0, 100, 0, 0, 35, 30000, 35000, 11, 12160, 32, 0, 0, 0, 0, 26, 20, 0, 0, 0, 0, 0, 0, 'Blacksilt Seer - Between 0-35% Health - Cast ''Rejuvenation'' (Friend)'),
(17331, 0, 0, 0, 0, 0, 100, 0, 2500, 2500, 7400, 7400, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wrathscale Shorestalker - In Combat - Cast ''Strike'''),
(17333, 0, 0, 0, 0, 0, 100, 0, 2000, 2000, 8000, 8000, 11, 31295, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wrathscale Screamer - In Combat - Cast ''Scream'''),
(17334, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12555, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wrathscale Marauder - In Combat - Cast ''Pummel'''),
(17336, 0, 0, 0, 0, 0, 100, 0, 3500, 12000, 3500, 12000, 11, 9672, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wrathscale Sorceress - In Combat - Cast ''Frostbolt'''),
(17339, 0, 0, 0, 0, 0, 100, 0, 3200, 3200, 6400, 14700, 11, 9613, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Nazzivus Felsworn - In Combat - Cast ''Shadow Bolt'''),
(17339, 0, 1, 0, 0, 0, 100, 0, 14500, 24300, 16100, 27540, 11, 11962, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Nazzivus Felsworn - In Combat - Cast ''Immolate'''),
(17340, 0, 0, 0, 0, 0, 100, 0, 1000, 3000, 15000, 18000, 11, 21068, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Axxarien Shadowstalker - In Combat - Cast ''Corruption'''),
(17341, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 15691, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Axxarien Trickster - In Combat - Cast ''Eviscerate'''),
(17342, 0, 0, 0, 0, 0, 100, 0, 0, 3000, 12000, 20000, 11, 11990, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Axxarien Hellcaller - In Combat - Cast ''Rain of Fire'''),
(17343, 0, 0, 0, 0, 0, 100, 0, 1800, 1800, 20600, 20600, 11, 31286, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Thistle Lasher - In Combat - Cast ''Lash'''),
(17346, 0, 0, 0, 0, 0, 100, 0, 2500, 2500, 11720, 11720, 11, 31287, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mutated Tangler - In Combat - Cast ''Entangling Roots'''),
(17349, 0, 0, 0, 0, 0, 100, 0, 1500, 1500, 10500, 10500, 11, 36332, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Blue Flutterer - In Combat - Cast ''Rake'''),
(17350, 0, 0, 0, 0, 0, 100, 0, 1500, 1500, 10500, 10500, 11, 36332, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Royal Blue Flutterer - In Combat - Cast ''Rake'''),
(17352, 0, 0, 0, 0, 0, 100, 0, 3250, 3250, 10270, 10270, 11, 5810, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Corrupted Treant - In Combat - Cast ''Stone Skin'''),
(17353, 0, 0, 0, 0, 0, 100, 0, 2500, 2500, 8900, 8900, 11, 31277, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Corrupted Stomper - In Combat - Cast ''Stomp'''),
(17358, 0, 0, 0, 0, 0, 100, 0, 1000, 1000, 121000, 121000, 11, 31280, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Fouled Water Spirit - In Combat - Cast ''Bloodmyst Chill'''),
(17358, 0, 1, 0, 0, 0, 100, 0, 3100, 3100, 9600, 9600, 11, 31281, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Fouled Water Spirit - In Combat - Cast ''Bloodbolt'''),
(17494, 0, 0, 0, 0, 0, 100, 0, 6470, 8620, 3240, 35910, 11, 20791, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Zevrax - In Combat - Cast ''Shadow Bolt'''),
(17494, 0, 1, 0, 0, 0, 100, 0, 11300, 11300, 12950, 37520, 11, 11962, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Zevrax - In Combat - Cast ''Immolate'''),
(17494, 0, 2, 0, 0, 0, 100, 0, 3230, 30750, 19410, 45930, 11, 21068, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Zevrax - In Combat - Cast ''Corruption'''),
(17494, 0, 3, 0, 0, 0, 100, 0, 4850, 30740, 12950, 75790, 11, 17227, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Zevrax - In Combat - Cast ''Curse of Weakness'''),
(17522, 0, 0, 0, 0, 0, 100, 0, 4500, 4500, 12800, 12800, 11, 745, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Myst Spinner - In Combat - Cast ''Web'''),
(17523, 0, 0, 0, 0, 0, 100, 0, 1500, 1500, 33000, 33000, 11, 31288, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Myst Leecher - In Combat - Cast ''Leech Poison'''),
(17527, 0, 0, 0, 0, 0, 100, 0, 5000, 5000, 25000, 25000, 11, 3242, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Enraged Ravager - In Combat - Cast ''Ravage'''),
(17527, 0, 1, 0, 2, 0, 100, 0, 0, 30, 0, 0, 11, 15716, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Enraged Ravager - Between 0-30% Health - Cast ''Enrage'''),
(17604, 0, 0, 0, 26, 0, 100, 1, 0, 10, 0, 1, 11, 31734, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Spy - In Combat LOS 10 yards - Cast ''Mark of the Sunhawk'' (No Repeat)'),
(17604, 0, 1, 0, 0, 0, 100, 0, 4800, 29700, 16140, 25110, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Spy - In Combat - Cast ''Demoralizing Shout'''),
(17604, 0, 2, 0, 0, 0, 100, 0, 6450, 9380, 9700, 21250, 11, 31827, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Spy - In Combat - Cast ''Heroic Strike'''),
(17607, 0, 0, 0, 26, 0, 100, 1, 0, 10, 0, 1, 11, 31734, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Pyromancer - In Combat LOS 10 yards - Cast ''Mark of the Sunhawk'' (No Repeat)'),
(17607, 0, 1, 0, 0, 0, 100, 0, 3200, 3200, 15400, 15400, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Defender - In Combat - Cast ''Cleave'''),
(17607, 0, 2, 0, 0, 0, 100, 0, 8600, 8600, 34200, 34200, 11, 31737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Defender - In Combat - Cast ''Whirlwind'''),
(17608, 0, 0, 0, 26, 0, 100, 1, 0, 10, 0, 1, 11, 31734, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Pyromancer - In Combat LOS 10 yards - Cast ''Mark of the Sunhawk'' (No Repeat)'),
(17608, 0, 1, 0, 0, 0, 100, 0, 1500, 1500, 25700, 25700, 11, 11962, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Pyromancer - In Combat - Cast ''Immolate'''),
(17608, 0, 2, 0, 0, 0, 100, 0, 5200, 5200, 9900, 9900, 11, 9053, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Pyromancer - In Combat - Cast ''Fireball'''),
(17609, 0, 0, 0, 26, 0, 100, 1, 0, 10, 0, 1, 11, 31734, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Pyromancer - In Combat LOS 10 yards - Cast ''Mark of the Sunhawk'' (No Repeat)'),
(17609, 0, 1, 0, 0, 0, 100, 0, 1000, 1000, 6200, 6200, 11, 6660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Saboteur - In Combat - Cast ''Shoot'''),
(17609, 0, 2, 0, 0, 0, 100, 0, 11750, 11750, 32400, 32400, 11, 14443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunhawk Saboteur - In Combat - Cast ''Multi-Shot'''),
(17661, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 31279, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Deathclaw - In Combat - Cast ''Swipe'''),
(17678, 0, 0, 0, 1, 0, 100, 0, 1000, 1000, 10000, 10000, 11, 31612, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sironas - Out of Combat - Cast ''Sironas Channeling'''),
(17678, 0, 1, 0, 21, 0, 100, 0, 0, 0, 0, 0, 11, 31612, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sironas - On Reached Home - Cast ''Sironas Channeling'''),
(17678, 0, 2, 0, 0, 0, 100, 0, 7000, 9000, 11000, 11000, 11, 12742, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sironas - In Combat - Cast ''Immolate'''),
(17678, 0, 3, 0, 0, 0, 100, 0, 6000, 7000, 25000, 25000, 11, 8282, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sironas - In Combat - Cast ''Curse of Blood'''),
(17678, 0, 4, 0, 0, 0, 100, 0, 4000, 4000, 15000, 15000, 11, 10966, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sironas - In Combat - Cast ''Uppercut'''),
(17683, 0, 0, 0, 0, 0, 100, 0, 22650, 46000, 24260, 65400, 11, 744, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Zarakh - In Combat - Cast ''Poison'''),
(17683, 0, 1, 0, 0, 0, 100, 0, 1600, 19790, 17720, 40430, 11, 745, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Zarakh - In Combat - Cast ''Web'''),
(17704, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 9128, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Hand of Argus Swordsman - On Aggro - Cast ''Battle Shout'' (No Repeat)'),
(17704, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hand of Argus Swordsman - In Combat - Cast ''Strike'''),
(17715, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Atoph the Bloodcursed - In Combat - Cast ''Strike'''),
(17715, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 11977, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Atoph the Bloodcursed - In Combat - Cast ''Rend''');

-- 017_ruins_of_gilneas
SET @ENTRIES := '44111,45335,45367,45403,45481,45483,45499,45536,45537,45538,57802';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(44111, 0, 0, 0, 2, 0, 100, 1, 0, 30, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Worgen Invader - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(45335, 0, 0, 0, 2, 0, 100, 0, 0, 40, 30000, 35000, 11, 79853, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Highlands Fox - Between 0-40% Health - Cast ''Evasion'''),
(45367, 0, 0, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 68687, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gilnean Hound - Within 8-25 Range - Cast ''Leap'''),
(45403, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 81087, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, '7th Legion Submariner - In Combat - Cast ''Puncture Wound'''),
(45403, 0, 1, 0, 9, 0, 100, 0, 8, 30, 6000, 9000, 11, 86249, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, '7th Legion Submariner - Within 8-30 Range - Cast ''Throw'''),
(45481, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 60195, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bloodfang Scout - In Combat - Cast ''Sinister Strike'''),
(45483, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 79857, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Worgen Battlemage - Within 0-8 Range - Cast ''Blast Wave'''),
(45483, 0, 1, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 79854, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Worgen Battlemage - In Combat - Cast ''Fireball'''),
(45483, 0, 2, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 79849, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Worgen Battlemage - Out of Combat - Cast ''Molten Armor'''),
(45499, 0, 0, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 86345, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gilnean Warhound - Within 8-25 Range - Cast ''Leap'''),
(45536, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 82669, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bloodfang Scout - In Combat - Cast ''Shoot'''),
(45536, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 60195, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bloodfang Scout - In Combat - Cast ''Sinister Strike'''),
(45537, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 79854, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Worgen Battlemage - In Combat - Cast ''Fireball'''),
(45537, 0, 1, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 79849, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Worgen Battlemage - Out of Combat - Cast ''Molten Armor'''),
(45538, 0, 0, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 86345, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gilnean Warhound - Within 8-25 Range - Cast ''Leap'''),
(57802, 0, 0, 0, 2, 0, 100, 1, 0, 30, 0, 0, 11, 110055, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Lord Hiram Creed - Between 0-30% Health - Cast ''Berserk'' (No Repeat)'),
(57802, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 109706, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Lord Hiram Creed - In Combat - Cast ''Blackhowl''s Rage'''),
(57802, 0, 2, 0, 0, 0, 100, 0, 8000, 12000, 20000, 25000, 11, 109664, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Lord Hiram Creed - In Combat - Cast ''Blackhowl''s Will'''),
(57802, 0, 3, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 109196, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Lord Hiram Creed - In Combat - Cast ''Consuming Darkness''');

-- 018_northern_barrens
SET @ENTRIES := '3241,3242,3244,3286,3475,3638,3652,4316,7288,7308,7310,20797,51815,51914';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(3241, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 17498, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Savannah Patriarch - On Aggro - Cast ''Speed'''),
(3242, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 17498, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Zhevra Runner - On Aggro - Cast ''Speed'''),
(3244, 0, 0, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 7272, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Greater Plainstrider - Between 30-60% Health - Cast ''Dust Cloud'' (No Repeat)'),
(3286, 0, 0, 0, 0, 0, 100, 0, 2100, 2300, 32100, 32300, 11, 744, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Overseer - In Combat - Cast ''Poison'''),
(3475, 0, 0, 0, 11, 0, 100, 1, 0, 0, 0, 0, 11, 24450, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Echeyakee - On Respawn - Cast ''Prowl'' (No Repeat)'),
(3475, 0, 1, 0, 7, 0, 100, 1, 0, 0, 0, 0, 11, 24450, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Echeyakee - On Evade - Cast ''Prowl'' (No Repeat)'),
(3638, 0, 0, 0, 2, 0, 100, 1, 0, 20, 0, 0, 11, 7952, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Devouring Ectoplasm - Between 0-20% Health - Cast ''Clone'' (No Repeat)'),
(3652, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 3391, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Trigore the Lasher - In Combat - Cast ''Thrash'''),
(4316, 0, 0, 0, 0, 0, 100, 0, 2100, 2400, 12100, 13100, 11, 3604, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Kolkar Packhound - In Combat - Cast ''Tendon Rip'''),
(7288, 0, 0, 0, 0, 0, 100, 0, 2400, 2800, 12400, 12800, 11, 12057, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Grand Foreman Puzik Gallywix - In Combat - Cast ''Strike'''),
(7308, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 745, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Patroller - On Aggro - Cast ''Web'''),
(7310, 0, 0, 0, 0, 0, 100, 0, 2500, 3000, 13000, 14000, 11, 12057, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mutated Venture Co. Drone - In Combat - Cast ''Strike'''),
(20797, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 24844, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Deviate Coiler Hatchling - In Combat - Cast ''Lightning Breath'''),
(51815, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mor''shan Defender - In Combat - Cast ''Cleave'''),
(51815, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mor''shan Defender - In Combat - Cast ''Shoot'''),
(51914, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Horde Guard - In Combat - Cast ''Shoot''');

-- 019_azshara
SET @ENTRIES := '6370,6646,6647,6652,13896,36639,51508,51509,52018';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(6370, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 12548, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Makrinni Scrabbler - On Aggro - Cast ''Frost Shock'''),
(6370, 0, 1, 0, 0, 0, 100, 0, 2100, 2300, 6100, 6300, 11, 20822, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Makrinni Scrabbler - In Combat - Cast ''Frostbolt'''),
(6370, 0, 2, 0, 2, 0, 100, 1, 0, 20, 0, 0, 11, 11642, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Makrinni Scrabbler - Between 0-20% Health - Cast ''Heal'' (No Repeat)'),
(6646, 0, 0, 0, 0, 0, 100, 0, 2300, 3100, 7900, 8400, 11, 10101, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Monnos the Elder - In Combat - Cast ''Knock Away'''),
(6646, 0, 1, 0, 2, 0, 100, 1, 40, 80, 0, 0, 11, 5568, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Monnos the Elder - Between 40-80% Health - Cast ''Trample'' (No Repeat)'),
(6646, 0, 2, 0, 2, 0, 100, 1, 5, 20, 0, 0, 11, 11876, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Monnos the Elder - Between 5-20% Health - Cast ''War Stomp'' (No Repeat)'),
(6647, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 18651, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Magister Hawkhelm - On Aggro - Cast ''Multi-Shot'''),
(6647, 0, 1, 0, 0, 0, 100, 0, 2100, 2300, 6900, 7300, 11, 6660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Magister Hawkhelm - In Combat - Cast ''Shoot'''),
(6652, 0, 0, 0, 0, 0, 100, 0, 2400, 2900, 7500, 8100, 11, 21073, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Master Feardred - In Combat - Cast ''Arcane Explosion'''),
(13896, 0, 0, 0, 0, 0, 100, 0, 4800, 8200, 12400, 16800, 11, 7938, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scalebeard - In Combat - Cast ''Fatal Bite'''),
(36639, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 14000, 18000, 11, 80986, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sable Drakonid - In Combat - Cast ''Barrage of Flame'''),
(51508, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Valormok Guard - In Combat - Cast ''Cleave'''),
(51508, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Valormok Guard - In Combat - Cast ''Shoot'''),
(51509, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bilgewater Bruiser - In Combat - Cast ''Cleave'''),
(51509, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bilgewater Bruiser - In Combat - Cast ''Shoot'''),
(52018, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Palace Mook - In Combat - Cast ''Cleave'''),
(52018, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Palace Mook - In Combat - Cast ''Shoot''');

-- 020_ghostlands
SET @ENTRIES := '16347,16353';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(16347, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 32918, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Starving Ghostclaw - On Aggro - Cast ''Chilling Howl'''),
(16353, 0, 0, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 8281, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mistbat - Between 20-80% Health - Cast ''Sonic Burst'' (No Repeat)');

-- 021_redridge_mountains
SET @ENTRIES := '14273,43041,43369';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(14273, 0, 0, 0, 0, 0, 100, 0, 3100, 4700, 9600, 12700, 11, 9483, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Boulderheart - In Combat - Cast ''Boulder'''),
(43041, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 3391, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Ol'' Gummers - In Combat - Cast ''Thrash'''),
(43369, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Overlord Barbarius - Within 0-8 Range - Cast ''Demoralizing Shout'''),
(43369, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 9080, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Overlord Barbarius - In Combat - Cast ''Hamstring'''),
(43369, 0, 2, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 57846, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Overlord Barbarius - In Combat - Cast ''Heroic Strike'''),
(43369, 0, 3, 0, 0, 0, 100, 0, 10000, 12000, 16000, 20000, 11, 32736, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Overlord Barbarius - In Combat - Cast ''Mortal Strike''');

-- 022_shadowfang_keep
SET @ENTRIES := '47134,47135,47136,47137,47138,47145,47231,47232';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(47134, 0, 0, 1, 0, 0, 100, 0, 7000, 7000, 6000, 7000, 11, 91088, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 7000 and 7000 ms (and later repeats every 6000 and 7000 ms) - Self: Cast spell Consume Flesh (91088) on Victim // '),
(47134, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 67, 0, 1000, 1000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ' Linked - Trigger timed event #0 in 1000 - 1000 ms // '),
(47134, 0, 2, 0, 59, 0, 100, 4, 0, 0, 0, 0, 11, 91099, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 'On timed event 0 triggered - Self: Cast spell Rotting Bile (91099) on Random hostile (not top) // '),
(47135, 0, 0, 0, 6, 0, 100, 4, 0, 0, 0, 0, 11, 91554, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On death - Self: Cast spell Fetid Cloud (91554) on Self // '),
(47136, 0, 0, 1, 0, 0, 100, 0, 8000, 9000, 12000, 13000, 11, 3242, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 8000 and 9000 ms (and later repeats every 12000 and 13000 ms) - Self: Cast spell 3242 on Victim // '),
(47136, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ' Linked - Self: Trigger timed event 0 // '),
(47136, 0, 2, 0, 59, 0, 100, 4, 0, 0, 0, 0, 11, 91668, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On timed event 0 triggered - Self: Cast spell 91668 on Self // '),
(47137, 0, 0, 0, 0, 0, 100, 0, 5000, 6000, 8000, 9000, 11, 91213, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 5000 and 6000 ms (and later repeats every 8000 and 9000 ms) - Self: Cast spell Smash (91213) on Self // '),
(47137, 0, 1, 0, 0, 0, 100, 4, 10000, 11000, 10000, 11000, 11, 91220, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 10000 and 11000 ms (and later repeats every 10000 and 11000 ms) - Self: Cast spell Cowering Roar (91220) on Self // '),
(47138, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 91677, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Pustulant Monstrosity - In Combat - Cast ''Pustulant Spit'''),
(47145, 0, 0, 0, 0, 0, 100, 0, 3000, 3000, 6000, 6000, 11, 87081, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 3000 and 3000 ms (and later repeats every 6000 and 6000 ms) - Self: Cast spell 87081 on Victim // '),
(47145, 0, 1, 0, 0, 0, 100, 0, 8000, 8000, 9500, 9500, 11, 11972, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 8000 and 8000 ms (and later repeats every 9500 and 9500 ms) - Self: Cast spell 11972 on Victim // '),
(47145, 0, 2, 0, 0, 0, 100, 4, 10000, 10000, 21000, 21000, 11, 91629, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 10000 and 10000 ms (and later repeats every 21000 and 21000 ms) - Self: Cast spell 91629 on Self // '),
(47231, 0, 0, 0, 1, 0, 100, 0, 29000, 30000, 29000, 30000, 5, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'When out of combat and timer at the begining between 29000 and 30000 ms (and later repeats every 29000 and 30000 ms) - None: Play emote ONESHOT_TALK(DNR) (1) // '),
(47231, 0, 1, 0, 0, 0, 100, 2, 1, 1, 3000, 3000, 11, 12739, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 1 and 1 ms (and later repeats every 3000 and 3000 ms) - Self: Cast spell Shadow Bolt (12739) on Victim // '),
(47231, 0, 2, 0, 0, 0, 100, 4, 11000, 14000, 9000, 10000, 11, 91324, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 11000 and 14000 ms (and later repeats every 9000 and 10000 ms) - Self: Cast spell Shadowy Touch (91324) on Random hostile // '),
(47231, 0, 3, 0, 0, 0, 100, 4, 8000, 10000, 14000, 16000, 11, 91325, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 8000 and 10000 ms (and later repeats every 14000 and 16000 ms) - Self: Cast spell Shadow Vortex (91325) on Random hostile // '),
(47232, 0, 0, 0, 0, 0, 100, 0, 7000, 8000, 1000, 3000, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 7000 and 8000 ms (and later repeats every 1000 and 3000 ms) - Invoker: Cast spell Cleave (15496) to Victim // '),
(47232, 0, 1, 0, 0, 0, 100, 4, 6000, 7000, 6000, 7000, 11, 91348, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 6000 and 7000 ms (and later repeats every 6000 and 7000 ms) - Invoker: Cast spell Tenderize (91348) to Victim // ');

-- 023_blackfathom_deeps
SET @ENTRIES := '4798,6047';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(4798, 0, 0, 0, 0, 0, 100, 2, 5000, 7000, 20000, 35000, 11, 11980, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Fallenroot Shadowstalker - In Combat - Cast ''Curse of Weakness'' (Phase 1) (No Repeat)'),
(6047, 0, 0, 0, 0, 0, 100, 2, 5000, 9000, 14000, 18000, 11, 11831, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Aqua Guardian - In Combat - Cast ''Frost Nova''');

-- 024_duskwood
SET @ENTRIES := '503';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(503, 0, 0, 0, 0, 0, 100, 0, 5000, 11000, 22000, 33000, 11, 3537, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Lord Malathrom - In Combat - Cast ''Minions of Malathrom'' (No Repeat)');

-- 025_wetlands
SET @ENTRIES := '5683,41072,41080,41132,41137,41145,41147,41151,41167,41272,41293,41342,41343,41388,41389,41390,41391,41394,41400,41401,41409,41416,41419,41420,41424,41425,41426,41427,41428,41429,41449,41453,41522,41524,41553,41556,41558,41613,42041,42042,42043,42107,42110,42111,42154,42577,44110,44116,44224,44225,44226,44227,46122,48535,51520,51844,51922';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(5683, 0, 0, 0, 2, 0, 100, 1, 5, 30, 0, 0, 11, 12540, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Comar Villard - Between 5-30% Health - Cast ''Gouge'' (No Repeat)'),
(41072, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 78521, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Grunt - Within 0-5 Range - Cast ''Dragon''s Breath'''),
(41072, 0, 1, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 6268, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Grunt - Within 8-25 Range - Cast ''Rushing Charge'''),
(41080, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 78508, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Scout - In Combat - Cast ''Mark of Flames'''),
(41080, 0, 1, 0, 0, 0, 100, 0, 10000, 13000, 15000, 19000, 11, 78509, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Scout - In Combat - Cast ''Torch Toss'''),
(41132, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82703, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Flood Elemental - In Combat - Cast ''Pull of the Tides'''),
(41132, 0, 1, 0, 0, 0, 100, 0, 10000, 13000, 15000, 19000, 11, 79831, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Flood Elemental - In Combat - Cast ''Wave Crash'''),
(41137, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82704, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Displaced Threshadon - In Combat - Cast ''Snap and Toss'''),
(41145, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82710, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Silty Oozeling - In Combat - Cast ''Ooze Cap'''),
(41147, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 79607, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Slavering Ooze - In Combat - Cast ''Venom Splash'''),
(41151, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 77670, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Drungeld Glowerglare - In Combat - Cast ''Fire Whirl'''),
(41151, 0, 1, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 82635, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Drungeld Glowerglare - Within 8-25 Range - Cast ''Flaming Leap'''),
(41167, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 10987, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Torrention - Within 0-8 Range - Cast ''Geyser'''),
(41272, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 9053, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Smouldermage - In Combat - Cast ''Fireball'''),
(41272, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82641, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Smouldermage - In Combat - Cast ''Lava Gout'''),
(41272, 0, 2, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 79849, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Smouldermage - Out of Combat - Cast ''Molten Armor'''),
(41293, 0, 0, 0, 2, 0, 100, 1, 0, 30, 0, 0, 11, 81173, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Harbor Shredfin - Between 0-30% Health - Cast ''Frenzy'' (No Repeat)'),
(41293, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 69203, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Harbor Shredfin - In Combat - Cast ''Vicious Bite'''),
(41342, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 82608, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Mottled Screecher - Within 0-8 Range - Cast ''Howling Screech'''),
(41343, 0, 0, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 75002, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mottled Raptor - Within 8-25 Range - Cast ''Leaping Rush'''),
(41388, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82625, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Living Fossil - In Combat - Cast ''Bone Toss'''),
(41389, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 81305, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Paleolithic Elemental - In Combat - Cast ''Rock Barrage'''),
(41390, 0, 0, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 8852, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Mosshide Gnoll - Out of Combat - Cast ''Moss Hide'''),
(41391, 0, 0, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 8852, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Mosshide Mystic - Out of Combat - Cast ''Moss Hide'''),
(41391, 0, 1, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 9739, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mosshide Mystic - In Combat - Cast ''Wrath'''),
(41394, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Holdout - In Combat - Cast ''Shield Block'''),
(41394, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 34783, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Holdout - In Combat - Cast ''Spell Reflection'''),
(41400, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 3427, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Highland Razormaw - In Combat - Cast ''Infected Wound'''),
(41401, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 3147, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Highland Scytheclaw - In Combat - Cast ''Rend Flesh'''),
(41409, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 79721, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Trapper - In Combat - Cast ''Explosive Shot'''),
(41409, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Trapper - In Combat - Cast ''Shoot'''),
(41409, 0, 2, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 80004, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Trapper - In Combat - Cast ''Snake Trap'''),
(41416, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 80596, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Yorla Darksnare - In Combat - Cast ''Explosive Trap'''),
(41416, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82708, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Yorla Darksnare - In Combat - Cast ''Flaming Arrow'''),
(41416, 0, 2, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Yorla Darksnare - In Combat - Cast ''Shoot'''),
(41419, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 50000, 55000, 11, 82604, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Wetlands Crocolisk - In Combat - Cast ''Bad Attitude'''),
(41419, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 48287, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wetlands Crocolisk - In Combat - Cast ''Powerful Bite'''),
(41420, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 50000, 55000, 11, 82604, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Horrorjaw - In Combat - Cast ''Bad Attitude'''),
(41420, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 18000, 24000, 11, 51467, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Horrorjaw - In Combat - Cast ''Intimidating Roar'''),
(41420, 0, 2, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 48287, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Horrorjaw - In Combat - Cast ''Powerful Bite'''),
(41424, 0, 0, 0, 1, 0, 100, 1, 1000, 3000, 0, 0, 11, 79825, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Mouldering Mirebeast - Out of Combat - Cast ''Summon Unstable Mushroom'' (No Repeat)'),
(41425, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bluegill Murloc - Within 0-8 Range - Cast ''Splash'''),
(41425, 0, 1, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 34827, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bluegill Murloc - Out of Combat - Cast ''Water Shield'''),
(41426, 0, 0, 0, 0, 0, 100, 0, 2000, 5000, 35000, 40000, 11, 6274, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bluegill Oracle - In Combat - Cast ''Healing Ward'''),
(41426, 0, 1, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bluegill Oracle - Within 0-8 Range - Cast ''Splash'''),
(41426, 0, 2, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 32011, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bluegill Oracle - In Combat - Cast ''Water Bolt'''),
(41427, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 3360, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cursed Marine - In Combat - Cast ''Curse of the Eye'''),
(41427, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 82595, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cursed Marine - In Combat - Cast ''Rusty Rapier'''),
(41428, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 10653, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cursed Sailor - In Combat - Cast ''Curse of the Eye'''),
(41428, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 75388, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cursed Sailor - In Combat - Cast ''Rusty Cut'''),
(41429, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 10653, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Captain Halyndor - In Combat - Cast ''Curse of the Eye'''),
(41429, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 82599, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Captain Halyndor - In Combat - Cast ''Planked'''),
(41449, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 82664, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rampant Fire Elemental - In Combat - Cast ''Burning Hatred'''),
(41453, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 82644, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Smouldering Ooze - In Combat - Cast ''Flaming Ooze'''),
(41522, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 82723, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Calamoth Ashbeard - Within 0-8 Range - Cast ''Twilight Blast'''),
(41522, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 78129, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Calamoth Ashbeard - In Combat - Cast ''Twilight Bolt'''),
(41524, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 80596, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Yorla Darksnare - In Combat - Cast ''Explosive Trap'''),
(41524, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82708, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Yorla Darksnare - In Combat - Cast ''Flaming Arrow'''),
(41524, 0, 2, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Yorla Darksnare - In Combat - Cast ''Shoot'''),
(41553, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 77666, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Drungeld Glowerglare - Within 0-8 Range - Cast ''Fire Whirl'''),
(41553, 0, 1, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 82635, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Drungeld Glowerglare - Within 8-25 Range - Cast ''Flaming Leap'''),
(41556, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 16568, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Balgaras the Foul - In Combat - Cast ''Mind Flay'''),
(41556, 0, 1, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 77721, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Balgaras the Foul - In Combat - Cast ''Shadow Weave'''),
(41558, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 80117, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Forba Slabchisel - In Combat - Cast ''Earth Spike'''),
(41558, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 82738, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Forba Slabchisel - In Combat - Cast ''Rock Shower'''),
(41613, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Greenwarden Sentinel - In Combat - Cast ''Shoot'''),
(42041, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 18000, 24000, 11, 78397, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Whelpstealer - In Combat - Cast ''Fireproof Net'''),
(42041, 0, 1, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 78491, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Whelpstealer - Within 0-8 Range - Cast ''Whelp Call'''),
(42042, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 78472, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ebon Whelp - Within 0-5 Range - Cast ''Flame Breath'''),
(42043, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 75068, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ebon Slavehunter - In Combat - Cast ''Lava Burst'''),
(42107, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 78521, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Grunt - Within 0-5 Range - Cast ''Dragon''s Breath'''),
(42107, 0, 1, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 6268, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Grunt - Within 8-25 Range - Cast ''Rushing Charge'''),
(42110, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bluegill Puddlejumper - Within 0-8 Range - Cast ''Splash'''),
(42111, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bluegill Forager - Within 0-8 Range - Cast ''Splash'''),
(42111, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 10277, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bluegill Forager - In Combat - Cast ''Throw'''),
(42154, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 78129, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Convert - In Combat - Cast ''Twilight Bolt'''),
(42577, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 78143, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Drake Swarmer - Within 0-5 Range - Cast ''Twilight Breath'''),
(44110, 0, 0, 0, 2, 0, 100, 1, 0, 30, 0, 0, 11, 81173, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Ocean Shredfin - Between 0-30% Health - Cast ''Frenzy'' (No Repeat)'),
(44110, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 69203, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ocean Shredfin - In Combat - Cast ''Vicious Bite'''),
(44116, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 79175, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Harbor Crawler - In Combat - Cast ''Slap & Chop'''),
(44224, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Two-Toes - Within 0-8 Range - Cast ''Splash'''),
(44224, 0, 1, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 34827, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Two-Toes - Out of Combat - Cast ''Water Shield'''),
(44225, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 79721, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rufus Darkshot - In Combat - Cast ''Explosive Shot'''),
(44225, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rufus Darkshot - In Combat - Cast ''Shoot'''),
(44225, 0, 2, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 80004, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rufus Darkshot - In Combat - Cast ''Snake Trap'''),
(44226, 0, 0, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 78646, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sarltooth - Out of Combat - Cast ''Bone Shield'''),
(44226, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82625, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sarltooth - In Combat - Cast ''Bone Toss'''),
(44227, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 82742, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gazz the Loch-Hunter - In Combat - Cast ''Impaling Pull'''),
(46122, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 83639, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gorfax Angerfang - In Combat - Cast ''Bloodbath'''),
(46122, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 77558, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gorfax Angerfang - In Combat - Cast ''Bloody Strike'''),
(48535, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 83014, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Krazzworks Sky Marshall - In Combat - Cast ''Rapid Shot'''),
(48535, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Krazzworks Sky Marshall - In Combat - Cast ''Shoot'''),
(51520, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wetlands Mountaineer - In Combat - Cast ''Revenge'''),
(51520, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Wetlands Mountaineer - In Combat - Cast ''Shoot'''),
(51844, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Greenwarden Sentinel - In Combat - Cast ''Shoot'''),
(51922, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Menethil Guard - In Combat - Cast ''Revenge'''),
(51922, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Menethil Guard - In Combat - Cast ''Shield Block'''),
(51922, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Menethil Guard - In Combat - Cast ''Shoot''');

-- 026_ashenvale
SET @ENTRIES := '3730,3736,3940,6072,26116,33195,51507,51770,51814,51816,51867';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(3730, 0, 0, 0, 0, 0, 100, 0, 1700, 1900, 8700, 9600, 11, 3602, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dark Strand Excavator - In Combat - Cast ''Torch Burst'''),
(3736, 0, 0, 0, 0, 0, 100, 0, 2100, 2400, 9800, 12600, 11, 3602, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Darkslayer Mordenthal - In Combat - Cast ''Torch Burst'''),
(3940, 0, 0, 0, 0, 0, 100, 0, 6800, 8300, 37900, 46300, 11, 13860, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Taneel Darkwood - In Combat - Cast ''Shadow Word: Pain'''),
(3940, 0, 1, 0, 2, 0, 100, 0, 0, 90, 15000, 18000, 11, 11640, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Taneel Darkwood - Between 0-90% Health - Cast ''Renew'''),
(6072, 0, 0, 0, 0, 0, 100, 0, 2700, 3400, 11600, 12400, 11, 17620, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Diathorus the Seeker - In Combat - Cast ''Drain Life'''),
(6072, 0, 1, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 37624, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Diathorus the Seeker - Between 30-60% Health - Cast ''Carrion Swarm'' (No Repeat)'),
(6072, 0, 2, 0, 2, 0, 100, 1, 5, 30, 0, 0, 11, 12542, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Diathorus the Seeker - Between 5-30% Health - Cast ''Fear'' (No Repeat)'),
(26116, 0, 0, 0, 0, 0, 100, 0, 12000, 20000, 28000, 40000, 11, 122, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostwave Lieutenant - In Combat - Cast ''Frost Nova'''),
(26116, 0, 1, 0, 0, 0, 100, 0, 4000, 12000, 8000, 24000, 11, 8056, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostwave Lieutenant - In Combat - Cast ''Frost Shock'''),
(33195, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 78841, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ashenvale Bowman - In Combat - Cast ''Aimed Shot'''),
(33195, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 78754, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ashenvale Bowman - In Combat - Cast ''Arcane Shot'''),
(33195, 0, 2, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ashenvale Bowman - In Combat - Cast ''Shoot'''),
(51507, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Forest Song Peacekeeper - In Combat - Cast ''Cleave'''),
(51507, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Forest Song Peacekeeper - In Combat - Cast ''Shoot'''),
(51770, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Astranaar Sentinel - In Combat - Cast ''Shoot'''),
(51814, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Splintertree Guard - In Combat - Cast ''Shoot'''),
(51816, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Stardust Sentinel - In Combat - Cast ''Shoot'''),
(51867, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 32064, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Silverwind Vanquisher - Within 0-8 Range - Cast ''Battle Shout''');

-- 027_hillsbrad_foothills
SET @ENTRIES := '2356,13219,14278,14280,51842,51843,51916';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(2356, 0, 0, 0, 0, 0, 100, 0, 2200, 2600, 7400, 8100, 11, 31279, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Elder Gray Bear - In Combat - Cast ''Swipe'''),
(13219, 0, 0, 0, 0, 0, 80, 0, 1000, 1000, 7000, 7000, 11, 45026, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Jekyll Flandring - In Combat - Cast ''Heroic Strike'' (Phase 1)'),
(14278, 0, 0, 0, 0, 0, 100, 0, 2400, 4100, 10800, 13700, 11, 48288, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ro''Bark - In Combat - Cast ''Mace Smash'''),
(14280, 0, 0, 0, 0, 0, 100, 0, 2700, 3400, 8600, 11400, 11, 31279, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Big Samras - In Combat - Cast ''Swipe'''),
(51842, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dreadguard - In Combat - Cast ''Revenge'''),
(51842, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Dreadguard - In Combat - Cast ''Shield Block'''),
(51842, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dreadguard - In Combat - Cast ''Shoot'''),
(51843, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Blightguard - In Combat - Cast ''Revenge'''),
(51843, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Blightguard - In Combat - Cast ''Shield Block'''),
(51843, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Blightguard - In Combat - Cast ''Shoot'''),
(51916, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Tarren Mill Deathguard - In Combat - Cast ''Revenge'''),
(51916, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tarren Mill Deathguard - In Combat - Cast ''Shield Block'''),
(51916, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Tarren Mill Deathguard - In Combat - Cast ''Shoot''');

-- 028_arathi_highlands
SET @ENTRIES := '2779,24477,41295,42090,51819,51899';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(2779, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 43107, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Prince Nazjak - On Aggro - Cast ''Spear Throw'' (No Repeat)'),
(2779, 0, 1, 0, 0, 0, 100, 0, 3800, 5400, 10900, 13100, 11, 17687, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Prince Nazjak - In Combat - Cast ''Flurry'''),
(24477, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 7159, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Syndicate Thief - In Combat - Cast ''Backstab'''),
(24477, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 6713, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Syndicate Thief - In Combat - Cast ''Disarm'''),
(24477, 0, 2, 0, 0, 0, 100, 0, 10000, 12000, 16000, 20000, 11, 744, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Syndicate Thief - In Combat - Cast ''Poison'''),
(41295, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 79175, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ocean Crawler - In Combat - Cast ''Slap & Chop'''),
(42090, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Arathi Deathstalker - In Combat - Cast ''Shoot'''),
(51819, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Arathi Deathstalker - In Combat - Cast ''Shoot'''),
(51899, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hammerfall Guardian - In Combat - Cast ''Revenge'''),
(51899, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Hammerfall Guardian - In Combat - Cast ''Shield Block'''),
(51899, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hammerfall Guardian - In Combat - Cast ''Shoot''');

-- 029_northern_stranglethorn
SET @ENTRIES := '679,691,723,781,784,873,875,877,879,976,978,979,4260,4723,42858,42872,43049,43910,43911,43912,43913,51521,51533,51658,51662,51917,52184,52404,53000,53166';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(679, 0, 0, 0, 0, 0, 100, 0, 6500, 10000, 9500, 12500, 11, 12058, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mosh''Ogg Shaman - In Combat - Cast ''Chain Lightning'''),
(679, 0, 1, 0, 2, 0, 100, 0, 0, 30, 34000, 38000, 11, 6742, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Mosh''Ogg Shaman - Between 0-30% Health - Cast ''Bloodlust'''),
(679, 0, 2, 0, 0, 0, 100, 0, 9500, 18000, 33000, 45000, 11, 11899, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Mosh''Ogg Shaman - In Combat - Cast ''Healing Ward'''),
(691, 0, 0, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 38033, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Lesser Water Elemental - Between 20-80% Health - Cast ''Frost Nova'' (No Repeat)'),
(723, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mosh''Ogg Butcher - In Combat - Cast ''Cleave'''),
(781, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 6533, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Skullsplitter Headhunter - On Aggro - Cast ''Net'' (No Repeat)'),
(781, 0, 1, 0, 0, 0, 100, 0, 1000, 1500, 6500, 7000, 11, 10277, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Skullsplitter Headhunter - In Combat - Cast ''Throw'''),
(781, 0, 2, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 3148, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Skullsplitter Headhunter - Between 20-80% Health - Cast ''Head Crack'' (No Repeat)'),
(784, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Skullsplitter Beastmaster - In Combat - Cast ''Shoot'''),
(873, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4800, 11, 9532, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Saltscale Oracle - In Combat CMC - Cast ''Lightning Bolt'''),
(875, 0, 0, 0, 0, 0, 100, 0, 1000, 1000, 1800000, 1800000, 11, 12544, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Saltscale Tide Lord - Out of Combat - Cast ''Frost Armor'''),
(875, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 11, 9672, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Saltscale Tide Lord - In Combat CMC - Cast ''Frostbolt'''),
(875, 0, 2, 0, 9, 0, 100, 0, 0, 10, 15000, 18500, 11, 11831, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Saltscale Tide Lord - In Combat - Cast ''Frost Nova'''),
(877, 0, 0, 0, 9, 0, 100, 0, 0, 5, 20000, 30000, 11, 13443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Saltscale Forager - Within 0-5 Range - Cast ''Rend'''),
(877, 0, 1, 0, 0, 0, 100, 0, 2000, 3000, 4000, 9000, 11, 744, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Saltscale Forager - In Combat - Cast ''Poison'''),
(879, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2600, 4800, 11, 10277, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Saltscale Hunter - In Combat CMC - Cast ''Throw'''),
(976, 0, 0, 0, 0, 0, 100, 0, 2300, 2700, 9700, 12700, 11, 51772, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Kurzen War Tiger - In Combat - Cast ''Claw'''),
(978, 0, 0, 0, 0, 0, 100, 0, 3000, 5000, 9000, 12000, 11, 8050, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Kurzen Subchief - In Combat - Cast ''Flame Shock'''),
(979, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Kurzen Shadow Hunter - In Combat CMC - Cast ''Shoot'''),
(979, 0, 1, 0, 0, 0, 100, 0, 9000, 14000, 9000, 14000, 11, 8806, 32, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Kurzen Shadow Hunter - In Combat - Cast ''Poisoned Shot'''),
(4260, 0, 0, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 36203, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Shredder - Between 20-80% Health - Cast ''Doomsaw'' (No Repeat)'),
(4723, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 184, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Foreman Cozzle - On Aggro - Cast ''Fire Shield'' (No Repeat)'),
(4723, 0, 1, 0, 0, 0, 100, 0, 2100, 3400, 9700, 11800, 11, 9532, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Foreman Cozzle - In Combat - Cast ''Lightning Bolt'''),
(4723, 0, 2, 0, 2, 0, 100, 1, 5, 30, 0, 0, 11, 4979, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Foreman Cozzle - Between 5-30% Health - Cast ''Quick Flame Ward'' (No Repeat)'),
(42858, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 79890, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Braddok - In Combat - Cast ''Flame Shock'''),
(42858, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 3148, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Braddok - In Combat - Cast ''Head Crack'''),
(42858, 0, 2, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 79884, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Braddok - In Combat - Cast ''Lightning Bolt'''),
(42858, 0, 3, 0, 0, 0, 100, 0, 2000, 5000, 65000, 70000, 11, 39591, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Braddok - In Combat - Cast ''Searing Totem'''),
(42872, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 80074, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gurubashi Crusher - In Combat - Cast ''Ironweave Net'''),
(43049, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 18000, 24000, 11, 12024, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Nesingwary Hired Gun - In Combat - Cast ''Net'''),
(43049, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Nesingwary Hired Gun - In Combat - Cast ''Shoot'''),
(43910, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 79862, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chief Anders - In Combat - Cast ''Backstab'''),
(43910, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 79866, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chief Anders - In Combat - Cast ''Deadly Throw'''),
(43910, 0, 2, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 79863, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chief Anders - In Combat - Cast ''Hemorrhage'''),
(43911, 0, 0, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 19514, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Chief Gaulus - Out of Combat - Cast ''Lightning Shield'''),
(43912, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Chief Esquivel - Within 0-8 Range - Cast ''Demoralizing Shout'''),
(43912, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 9080, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chief Esquivel - In Combat - Cast ''Hamstring'''),
(43912, 0, 2, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 57846, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chief Esquivel - In Combat - Cast ''Heroic Strike'''),
(43912, 0, 3, 0, 0, 0, 100, 0, 10000, 12000, 16000, 20000, 11, 32736, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chief Esquivel - In Combat - Cast ''Mortal Strike'''),
(43913, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 17140, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chief Miranda - In Combat - Cast ''Holy Fire'''),
(43913, 0, 1, 0, 2, 0, 100, 0, 0, 40, 15000, 20000, 11, 79822, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Chief Miranda - Between 0-40% Health - Cast ''Holy Nova'''),
(43913, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 9734, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chief Miranda - In Combat - Cast ''Holy Smite'''),
(51521, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bambala Headhunter - In Combat - Cast ''Shoot'''),
(51533, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Fort Livingston Guard - In Combat - Cast ''Cleave'''),
(51533, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Fort Livingston Guard - In Combat - Cast ''Shoot'''),
(51658, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 17173, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mogh the Dead - In Combat - Cast ''Drain Life'''),
(51658, 0, 1, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 12471, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mogh the Dead - In Combat - Cast ''Shadow Bolt'''),
(51662, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Mahamba - Within 0-8 Range - Cast ''Splash'''),
(51662, 0, 1, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 79831, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mahamba - In Combat - Cast ''Wave Crash'''),
(51917, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Grom''gol Grunt - In Combat - Cast ''Revenge'''),
(51917, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Grom''gol Grunt - In Combat - Cast ''Shield Block'''),
(51917, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Grom''gol Grunt - In Combat - Cast ''Shoot'''),
(52184, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Nesingwary Hired Gun - In Combat - Cast ''Shoot'''),
(52404, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rebel Watchman - In Combat - Cast ''Cleave'''),
(53000, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Grom''gol Grunt - In Combat - Cast ''Cleave'''),
(53166, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 98822, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gurubashi Soul-Seeker - In Combat - Cast ''Deadly Bow''');

-- 030_stonetalon_mountains
SET @ENTRIES := '3991,4014,4015,4030,4067,5916,5931,34923,41311,51820,51825,51827,51828,51829,51830,51837';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(3991, 0, 0, 0, 0, 0, 100, 0, 1700, 2100, 6900, 8600, 11, 20793, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Deforester - In Combat - Cast ''Fireball'''),
(3991, 0, 1, 0, 2, 0, 100, 1, 20, 40, 0, 0, 11, 39273, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Deforester - Between 20-40% Health - Cast ''Rain of Fire'' (No Repeat)'),
(4014, 0, 0, 0, 2, 0, 100, 1, 20, 40, 0, 0, 11, 6605, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Pridewing Consort - Between 20-40% Health - Cast ''Terrifying Screech'' (No Repeat)'),
(4015, 0, 0, 0, 0, 0, 100, 0, 2100, 2300, 32100, 32300, 11, 744, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Pridewing Patriarch - In Combat - Cast ''Poison'''),
(4030, 0, 0, 0, 9, 0, 100, 0, 0, 5, 17000, 25000, 11, 6909, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vengeful Ancient - Within 0-5 Range - Cast Curse of Thorns'),
(4067, 0, 0, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 24331, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Runner - Between 20-80% Health - Cast ''Rake'' (No Repeat)'),
(5916, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 5759, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sentinel Amarassan - On Aggro - Cast ''Cat Form'''),
(5916, 0, 1, 0, 0, 0, 100, 0, 2400, 3900, 12400, 13900, 11, 24332, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sentinel Amarassan - In Combat - Cast ''Rake'''),
(5931, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 6533, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Foreman Rigger - On Aggro - Cast ''Net'''),
(5931, 0, 1, 0, 0, 0, 100, 0, 2100, 2400, 22100, 22400, 11, 6016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Foreman Rigger - In Combat - Cast ''Pierce Armor'''),
(34923, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 43512, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Harbinger Aph''lass - In Combat - Cast ''Mind Flay'''),
(34923, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 75903, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Harbinger Aph''lass - In Combat - Cast ''Shadow Crash'''),
(41311, 0, 0, 0, 67, 0, 100, 0, 9000, 12000, 0, 0, 11, 79862, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Master Assassin Kel''istra - On Behind Target - Cast ''Backstab'''),
(41311, 0, 1, 0, 13, 0, 100, 0, 20000, 30000, 0, 0, 11, 79866, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Master Assassin Kel''istra - On Victim Casting ''Alexander''s Test Periodic Aura'' - Cast ''Deadly Throw'''),
(41311, 0, 2, 0, 9, 0, 100, 0, 0, 5, 11000, 17000, 11, 79863, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Master Assassin Kel''istra - Within 0-5 Range - Cast ''Hemorrhage'''),
(41311, 0, 3, 0, 2, 0, 100, 1, 0, 30, 0, 0, 11, 79864, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Master Assassin Kel''istra - Between 0-30% Health - Cast ''Shadowstep'' (No Repeat)'),
(51820, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Krom''gar Enforcer - In Combat - Cast ''Cleave'''),
(51820, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Krom''gar Enforcer - In Combat - Cast ''Shoot'''),
(51825, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Revenge'''),
(51825, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Shield Block'''),
(51825, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Shoot'''),
(51827, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Krom''gar Enforcer - In Combat - Cast ''Cleave'''),
(51827, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Krom''gar Enforcer - In Combat - Cast ''Shoot'''),
(51828, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Windshear Hold Guardian - In Combat - Cast ''Cleave'''),
(51828, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Windshear Hold Guardian - In Combat - Cast ''Shoot'''),
(51829, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Stonetalon Grunt - In Combat - Cast ''Shoot'''),
(51830, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mirkfallon Post Scout - In Combat - Cast ''Shoot'''),
(51837, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Farwatcher Guardian - In Combat - Cast ''Shoot''');

-- 031_gnomeregan
SET @ENTRIES := '6224,6232,6407,7738';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(6224, 0, 0, 0, 0, 0, 100, 0, 4000, 5000, 20000, 25000, 11, 10732, 0, 0, 0, 0, 0, 19, 6224, 50, 0, 0, 0, 0, 0, 'Leprous Machinesmith - In Combat - Cast ''Supercharge'''),
(6224, 0, 1, 0, 0, 0, 100, 0, 2000, 5000, 4000, 6000, 11, 13398, 64, 0, 0, 0, 0, 21, 30, 0, 0, 0, 0, 0, 0, 'Leprous Machinesmith - In Combat CMC - Cast ''Throw Wrench'''),
(6224, 0, 2, 0, 2, 0, 100, 1, 0, 90, 0, 0, 11, 10348, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Leprous Machinesmith - Between 0-90% Health - Cast ''Tune Up'' (No Repeat)'),
(6224, 0, 3, 0, 8, 0, 100, 0, 9798, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Leprous Machinesmith - On Spellhit ''Radiation'' - Say Line 0'),
(6224, 0, 4, 0, 4, 0, 20, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Leprous Machinesmith - On Aggro - Say Line 1'),
(6232, 0, 0, 0, 0, 0, 100, 0, 4000, 6000, 20000, 20000, 11, 10831, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Arcane Nullifier X-21 - In Combat - Cast Reflection Field'),
(6232, 0, 1, 0, 0, 0, 100, 0, 8000, 9000, 15000, 15000, 11, 10832, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Arcane Nullifier X-21 - In Combat - Cast Mass Nullify'),
(6407, 0, 0, 0, 0, 0, 100, 0, 500, 1000, 2000, 2500, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Holdout Technician - In Combat - Cast Shoot'),
(6407, 0, 1, 0, 0, 0, 100, 0, 5000, 12000, 9000, 18000, 11, 8858, 0, 0, 0, 0, 0, 5, 30, 0, 0, 0, 0, 0, 0, 'Holdout Technician - In Combat - Cast Bomb'),
(7738, 0, 0, 0, 0, 0, 100, 2, 2000, 2000, 20000, 30000, 11, 10869, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Every 20 - 30 seconds (2 - 2s initially) - Self: Cast spell Summon Embers (10869) on Self');

-- 032_scarlet_monastery
SET @ENTRIES := '4542';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(4542, 0, 0, 0, 0, 0, 100, 0, 7000, 11000, 30000, 40000, 11, 8282, 0, 0, 0, 0, 0, 5, 20, 0, 0, 0, 0, 0, 0, 'High Inquisitor Fairbanks - In Combat - Cast Curse of Blood'),
(4542, 0, 1, 0, 0, 0, 100, 0, 6000, 11000, 15000, 20000, 11, 15090, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'High Inquisitor Fairbanks - In Combat - Cast Dispel Magic'),
(4542, 0, 2, 0, 0, 0, 100, 0, 0, 3000, 20000, 20000, 11, 11647, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'High Inquisitor Fairbanks - In Combat - Cast Power Word: Shield'),
(4542, 0, 3, 0, 0, 0, 100, 0, 10000, 15000, 20000, 20000, 11, 12039, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'High Inquisitor Fairbanks - In Combat - Cast Heal');

-- 033_the_cape_of_stranglethorn
SET @ENTRIES := '595,669,676,677,681,682,684,685,687,772,905,1094,1516,1557,1713,2541,2635,14491,15088,43050,51534,51661,51663,51823,52224,52372,52982';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(595, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2100, 4800, 11, 10277, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bloodscalp Hunter - In Combat CMC - Cast ''Throw'''),
(595, 0, 1, 0, 0, 0, 100, 0, 9500, 24100, 18500, 39800, 11, 6533, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bloodscalp Hunter - In Combat - Cast ''Net'''),
(595, 0, 2, 0, 2, 0, 100, 1, 0, 30, 0, 0, 11, 8599, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bloodscalp Hunter - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(669, 0, 0, 0, 25, 0, 100, 1, 0, 0, 0, 0, 11, 3621, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Skullsplitter Hunter - On Reset - Cast ''Skullsplitter Pet'' (No Repeat)'),
(669, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 11, 12787, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Skullsplitter Hunter - In Combat - Cast ''Thrash'' (No Repeat)'),
(669, 0, 2, 0, 2, 0, 100, 1, 5, 25, 0, 0, 11, 3148, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Skullsplitter Hunter - Between 5-25% Health - Cast ''Head Crack'' (No Repeat)'),
(676, 0, 0, 0, 0, 0, 100, 0, 2700, 4800, 9600, 12100, 11, 11969, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Surveyor - In Combat - Cast ''Fire Nova'''),
(677, 0, 0, 0, 54, 0, 100, 0, 1000, 2000, 0, 0, 11, 12544, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Tinkerer - On Just Summoned - Cast ''Frost Armor'''),
(677, 0, 1, 0, 0, 0, 100, 0, 3000, 4000, 5000, 6000, 11, 20823, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Tinkerer - In Combat CMC - Cast ''Fireball'''),
(677, 0, 2, 0, 0, 0, 100, 1, 8000, 8000, 8000, 8000, 11, 7979, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Tinkerer - IC - Cast Compact Harvest Reaper (no repeat)'),
(681, 0, 0, 0, 0, 0, 100, 0, 2300, 2700, 9700, 12700, 11, 51772, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Young Stranglethorn Tiger - In Combat - Cast ''Claw'''),
(682, 0, 0, 0, 0, 0, 100, 0, 2300, 2700, 9700, 12700, 11, 51772, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Stranglethorn Tiger - In Combat - Cast ''Claw'''),
(684, 0, 0, 0, 1, 0, 100, 1, 1000, 1500, 0, 0, 11, 22766, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Shadowmaw Panther - Out of Combat - Cast ''Sneak'' (No Repeat)'),
(685, 0, 0, 0, 0, 0, 100, 0, 2400, 3200, 17400, 18200, 11, 11977, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Stranglethorn Raptor - In Combat - Cast ''Rend'''),
(687, 0, 0, 0, 0, 0, 100, 0, 2400, 3200, 17400, 18200, 11, 11977, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Jungle Stalker - In Combat - Cast ''Rend'''),
(772, 0, 0, 0, 0, 0, 100, 0, 2300, 2700, 9700, 12700, 11, 51772, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Stranglethorn Tigress - In Combat - Cast ''Claw'''),
(905, 0, 0, 0, 2, 0, 100, 1, 5, 10, 0, 0, 11, 3019, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sharptooth Frenzy - Between 5-10% Health - Cast ''Frenzy'' (No Repeat)'),
(1094, 0, 0, 0, 0, 0, 100, 0, 3400, 4800, 23400, 24800, 11, 6016, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Venture Co. Miner - In Combat - Cast ''Pierce Armor'''),
(1516, 0, 0, 0, 2, 0, 100, 1, 0, 30, 0, 0, 11, 8269, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Konda - Between 0-30% Health - Cast ''Frenzy'' (No Repeat)'),
(1557, 0, 0, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 15615, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Elder Mistvale Gorilla - Between 30-60% Health - Cast ''Pummel'' (No Repeat)'),
(1713, 0, 0, 0, 1, 0, 100, 1, 1000, 1500, 0, 0, 11, 22766, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Elder Shadowmaw Panther - Out of Combat - Cast ''Sneak'' (No Repeat)'),
(2541, 0, 0, 0, 0, 0, 100, 0, 3700, 4200, 9700, 12200, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Lord Sakrasis - In Combat - Cast ''Cleave'''),
(2541, 0, 1, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 3583, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Lord Sakrasis - Between 30-60% Health - Cast ''Deadly Poison'' (No Repeat)'),
(2635, 0, 0, 0, 0, 0, 100, 0, 3000, 8000, 13000, 24000, 11, 3604, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Elder Saltwater Crocolisk - In Combat - Cast ''Tendon Rip'' (No Repeat)'),
(14491, 0, 0, 0, 2, 0, 100, 1, 5, 30, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Kurmokk - Between 5-30% Health - Cast ''Enrage'' (No Repeat)'),
(15088, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 16856, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Booty Bay Elite - In Combat - Cast ''Mortal Strike'''),
(15088, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 9080, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Booty Bay Elite - In Combat - Cast ''Hamstring'''),
(43050, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 18000, 24000, 11, 90337, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vale Howler - In Combat - Cast ''Bad Manner'''),
(43050, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 21000, 26000, 11, 61684, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vale Howler - In Combat - Cast ''Dash'''),
(43050, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 83012, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vale Howler - In Combat - Cast ''Fling Filth'''),
(51534, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Digsite Defender - In Combat - Cast ''Cleave'''),
(51534, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Digsite Defender - In Combat - Cast ''Shoot'''),
(51661, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 81140, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tsul''Kalu - Within 0-8 Range - Cast ''Thunderclap'''),
(51663, 0, 0, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 75002, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Pogeyan - Within 8-25 Range - Cast ''Leaping Rush'''),
(51823, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hardwrench Guard - In Combat - Cast ''Shoot'''),
(52224, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12097, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Jungle Serpent - In Combat - Cast ''Pierce Armor'''),
(52224, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 24003, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Jungle Serpent - In Combat - Cast ''Tranquilizing Poison'''),
(52372, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 24332, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mauti - In Combat - Cast ''Rake'''),
(52982, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bambala Headhunter - In Combat - Cast ''Shoot''');

-- 034_southern_barrens
SET @ENTRIES := '3246,3248,3425,3426,3454,3455,4127,5848,51851,51852,51853,51859,51861';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(3246, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 17498, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Fleeting Plainstrider - On Aggro - Cast ''Speed'''),
(3248, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 17498, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Barrens Giraffe - On Aggro - Cast ''Speed'''),
(3425, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 17498, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Savannah Prowler - On Aggro - Cast ''Speed'''),
(3426, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 17498, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Zhevra Charger - On Aggro - Cast ''Speed'''),
(3454, 0, 0, 0, 0, 0, 100, 0, 2300, 2800, 9400, 9900, 11, 5679, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cannoneer Smythe - In Combat - Cast ''Torch Burn'''),
(3455, 0, 0, 0, 0, 0, 100, 0, 2300, 2800, 9400, 9900, 11, 5679, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cannoneer Whessan - In Combat - Cast ''Torch Burn'''),
(4127, 0, 0, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 3604, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hecklefang Hyena - Between 20-80% Health - Cast ''Tendon Rip'' (No Repeat)'),
(5848, 0, 0, 0, 0, 0, 100, 0, 3000, 4500, 12000, 22000, 11, 74759, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Malgin Barleybrew - In Combat - Cast ''Bottle of Grog'''),
(5848, 0, 1, 0, 2, 0, 100, 1, 0, 40, 0, 0, 11, 3631, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Malgin Barleybrew - Between 0-40% Health - Cast ''Battle Fury'' (No Repeat)'),
(51851, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Desolation Guard - In Combat - Cast ''Shoot'''),
(51852, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Triumph Sentry - In Combat - Cast ''Revenge'''),
(51852, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Triumph Sentry - In Combat - Cast ''Shield Block'''),
(51852, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Triumph Sentry - In Combat - Cast ''Shoot'''),
(51853, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Revenge'''),
(51853, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Shield Block'''),
(51853, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Shoot'''),
(51859, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Honor''s Stand Guard - In Combat - Cast ''Revenge'''),
(51859, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Honor''s Stand Guard - In Combat - Cast ''Shield Block'''),
(51859, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Honor''s Stand Guard - In Combat - Cast ''Shoot'''),
(51861, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Revenge'''),
(51861, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Shield Block'''),
(51861, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Guard - In Combat - Cast ''Shoot''');

-- 035_desolace
SET @ENTRIES := '4644,4676,4688,5601,11685,11687,11688,11787,11788,13718,35828,43889,51511,51840';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(4644, 0, 0, 0, 1, 0, 100, 0, 1000, 2000, 5000, 5000, 11, 7366, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Magram Marauder - Out of Combat - Cast ''Berserker Stance'''),
(4644, 0, 1, 0, 0, 0, 100, 0, 0, 1500, 5000, 5000, 11, 7366, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Magram Marauder - In Combat - Cast ''Berserker Stance'''),
(4644, 0, 2, 0, 0, 0, 100, 0, 2500, 4000, 3500, 4500, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Magram Marauder - In Combat - Cast ''Cleave'''),
(4676, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 2601, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Lesser Infernal - On Aggro - Cast ''Fire Shield'''),
(4688, 0, 0, 0, 0, 0, 100, 0, 2500, 3000, 12500, 13000, 11, 3604, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bonepaw Hyena - In Combat - Cast ''Tendon Rip'''),
(5601, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 7164, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Khan Jehn - On Aggro - Cast ''Defensive Stance'''),
(5601, 0, 1, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 11972, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Khan Jehn - Between 30-60% Health - Cast ''Shield Bash'' (No Repeat)'),
(11685, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 11639, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Maraudine Priest - On Aggro - Cast ''Shadow Word: Pain'''),
(11685, 0, 1, 0, 0, 0, 100, 0, 3400, 4100, 9200, 10100, 11, 16568, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Maraudine Priest - In Combat - Cast ''Mind Flay'''),
(11687, 0, 0, 0, 0, 0, 100, 0, 2700, 3100, 8500, 9200, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ghostly Marauder - In Combat - Cast ''Strike'''),
(11688, 0, 0, 0, 0, 0, 100, 0, 9000, 14000, 25000, 35000, 11, 21048, 32, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Every 25 - 35 seconds (9 - 14s initially)  - Self: Cast spell Curse of the Tribes (21048) on Random hostile (flags: aura not present)'),
(11787, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 14120, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rock Borer - In Combat - Cast ''Tunneler Acid'''),
(11788, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 44477, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rock Worm - In Combat - Cast ''Acid Spit'''),
(13718, 0, 0, 0, 0, 0, 100, 0, 5400, 6200, 25900, 34600, 11, 15848, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'The Nameless Prophet - In Combat - Cast ''Festering Rash'''),
(35828, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 68249, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Lord Hydronis - Within 0-5 Range - Cast ''Tidal Wave'''),
(43889, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 18000, 24000, 11, 12024, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Karnum''s Warden - In Combat - Cast ''Net'''),
(51511, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Thargad''s Bodyguard - In Combat - Cast ''Shoot'''),
(51840, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ghost Walker Brave - In Combat - Cast ''Cleave'''),
(51840, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ghost Walker Brave - In Combat - Cast ''Shoot''');

-- 036_the_hinterlands
SET @ENTRIES := '2658,2680,43016';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(2658, 0, 0, 0, 0, 0, 100, 0, 1000, 2000, 14000, 14000, 11, 3147, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Razorbeak Gryphon - In Combat - Cast ''Rend Flesh'' Every 14 seconds'),
(2658, 0, 1, 0, 0, 0, 100, 0, 5000, 6000, 10000, 10000, 11, 11019, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Razorbeak Gryphon - In Combat - Cast ''Wing Flap'' Every 10 seconds'),
(2680, 0, 0, 0, 2, 0, 100, 1, 20, 80, 0, 0, 11, 3149, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vilebranch Wolf Pup - Between 20-80% Health - Cast ''Furious Howl'' (No Repeat)'),
(43016, 0, 0, 0, 0, 0, 100, 0, 2000, 3000, 14000, 15000, 11, 60195, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Deathstalker Bodychopper - In Combat - Cast ''Sinister Strike'''),
(43016, 0, 1, 0, 0, 0, 100, 0, 5000, 7000, 18000, 20000, 11, 79852, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Deathstalker Bodychopper - In Combat - Cast ''Eviscerate'''),
(43016, 0, 2, 0, 0, 0, 100, 0, 12000, 15000, 33000, 35000, 11, 60842, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Deathstalker Bodychopper - In Combat - Cast ''Expose Armor'''),
(43016, 0, 3, 0, 9, 0, 100, 0, 0, 8, 22000, 24000, 11, 79851, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Deathstalker Bodychopper - Within 0-8 Range - Cast ''Fan of Knives''');

-- 037_dustwallow_marsh
SET @ENTRIES := '4397,4973,5184,15552,23841,23899,23900,23941,51924';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(4397, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 9464, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Mudrock Spikeshell - On Aggro - Cast ''Barbs'''),
(4973, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 42131, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Guard Lasiter - In Combat - Cast ''Shoot'''),
(5184, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 7165, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Theramore Sentry - On Aggro - Cast ''Battle Stance'''),
(15552, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 55000, 60000, 11, 25772, 32, 1, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 'Dr Weavil - In Combat - Cast Mental Domination'),
(15552, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 14000, 16500, 11, 25774, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Dr Weavil - In Combat - Cast Mind Shatter'),
(23841, 0, 0, 0, 0, 0, 100, 0, 2100, 2400, 17100, 17400, 11, 12054, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Razorspine - In Combat - Cast ''Rend'''),
(23899, 0, 0, 1, 40, 0, 100, 0, 1, 23899, 0, 0, 101, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tethyr - Waypoint reached - Set home position'),
(23899, 0, 1, 8, 61, 0, 100, 0, 0, 0, 0, 0, 19, 128, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tethyr - Just Summoned - Remove unit flag'),
(23899, 0, 2, 0, 0, 0, 100, 0, 3000, 3000, 7000, 7000, 11, 42584, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Tethyr - Occ - Cast'),
(23899, 0, 3, 0, 0, 0, 100, 0, 5000, 5000, 8000, 8000, 11, 42574, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Tethyr - Occ - Cast'),
(23899, 0, 4, 0, 8, 0, 100, 0, 42578, 0, 0, 0, 11, 36662, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tethyr - Spell Hist - Cast'),
(23899, 0, 5, 6, 6, 0, 100, 0, 0, 0, 0, 0, 45, 0, 1, 0, 0, 0, 0, 11, 23905, 87, 0, 0, 0, 0, 0, 'Tethyr - On Death - Set Data'),
(23899, 0, 6, 0, 61, 0, 100, 0, 0, 0, 0, 0, 45, 0, 1, 0, 0, 0, 0, 11, 23900, 80, 0, 0, 0, 0, 0, 'Tethyr - On Death - Set Data'),
(23899, 0, 7, 0, 54, 0, 100, 0, 0, 0, 0, 0, 48, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tethyr - On Just Summoned - Set Active ON'),
(23899, 0, 8, 0, 61, 0, 100, 0, 0, 0, 0, 0, 48, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tethyr - On wp reached - Set Active OFF'),
(23900, 0, 0, 0, 1, 0, 100, 0, 3000, 3000, 2000, 2000, 11, 42580, 0, 0, 0, 0, 0, 19, 23899, 80, 0, 0, 0, 0, 0, 'Tethyr - Occ - Cast'),
(23900, 0, 1, 0, 0, 0, 100, 0, 3000, 3000, 2000, 2000, 11, 42580, 0, 0, 0, 0, 0, 19, 23899, 80, 0, 0, 0, 0, 0, 'Tethyr - IC - Cast'),
(23900, 0, 2, 0, 6, 0, 100, 0, 0, 0, 0, 0, 75, 52500, 0, 0, 0, 0, 0, 19, 23899, 80, 0, 0, 0, 0, 0, 'Tethyr - On death - Set data1'),
(23941, 0, 0, 0, 2, 0, 100, 1, 0, 15, 0, 0, 11, 42660, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Gavis Greyshield - Between 0-15% Health - Cast ''Gavis Greyshield Credit'' (No Repeat)'),
(51924, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Theramore Guard - In Combat - Cast ''Revenge'''),
(51924, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Theramore Guard - In Combat - Cast ''Shield Block'''),
(51924, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Theramore Guard - In Combat - Cast ''Shoot''');

-- 038_western_plaguelands
SET @ENTRIES := '1838,1884,10605,16143,51535';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(1838, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 20294, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Interrogator - On Aggro - Cast ''Immolate'''),
(1884, 0, 0, 0, 0, 0, 100, 0, 2500, 3000, 17500, 18000, 11, 11977, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Lumberjack - In Combat - Cast ''Rend'''),
(1884, 0, 1, 0, 2, 0, 100, 1, 25, 40, 0, 0, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Lumberjack - Between 25-40% Health - Cast ''Cleave'' (No Repeat)'),
(10605, 0, 0, 0, 1, 0, 100, 0, 0, 0, 0, 0, 11, 17175, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Medic - Out of Combat - Cast ''Resist Arcane'''),
(10605, 0, 1, 0, 2, 0, 100, 1, 5, 95, 0, 0, 11, 11640, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Medic - Between 5-95% Health - Cast ''Renew'' (No Repeat)'),
(10605, 0, 2, 0, 2, 0, 100, 1, 5, 20, 0, 0, 11, 17137, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Medic - Between 5-20% Health - Cast ''Flash Heal'' (No Repeat)'),
(16143, 0, 0, 0, 6, 0, 100, 0, 0, 0, 0, 0, 11, 28056, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Shadow of Doom - On Just Died - Cast ''Zap Crystal Corpse'''),
(16143, 0, 1, 0, 0, 0, 100, 0, 2000, 2000, 6500, 13000, 11, 16568, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Shadow of Doom - In Combat - Cast ''Mind Flay'''),
(16143, 0, 2, 0, 0, 0, 100, 0, 2000, 2000, 14500, 14500, 11, 12542, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Shadow of Doom - In Combat - Cast ''Fear'''),
(51535, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chillwind Guard - In Combat - Cast ''Cleave'''),
(51535, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chillwind Guard - In Combat - Cast ''Shoot''');

-- 039_feralas
SET @ENTRIES := '5258,39339,39607,43838,51832,51920,53562';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(5258, 0, 0, 0, 2, 0, 100, 1, 5, 30, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Woodpaw Alpha - Between 5-30% Health - Cast ''Enrage'' (No Repeat)'),
(39339, 0, 0, 0, 0, 0, 100, 0, 2000, 4500, 12000, 14000, 11, 81147, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cliff Giant - In Combat - Cast ''Boulder'''),
(39339, 0, 1, 0, 0, 0, 100, 0, 5000, 9000, 17000, 24000, 11, 45, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Cliff Giant - In Combat - Cast ''War Stomp'''),
(39339, 0, 2, 0, 1, 0, 100, 0, 1000, 1000, 3000, 3000, 49, 0, 0, 0, 0, 0, 0, 19, 40972, 10, 0, 0, 0, 0, 0, 'Cliff Giant - Out of Combat - Start Attacking'),
(39607, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 82376, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Glak the Quenched - In Combat - Cast ''Frost Smash'''),
(43838, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 77666, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Moltar the Burning - Within 0-8 Range - Cast ''Fire Whirl'''),
(51832, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 18000, 24000, 11, 33844, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Druid of the Talon - In Combat - Cast ''Entangling Roots'''),
(51832, 0, 1, 0, 2, 0, 100, 0, 0, 40, 15000, 20000, 11, 16561, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Druid of the Talon - Between 0-40% Health - Cast ''Regrowth'''),
(51832, 0, 2, 0, 2, 0, 100, 0, 0, 40, 15000, 20000, 11, 12160, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Druid of the Talon - Between 0-40% Health - Cast ''Rejuvenation'''),
(51920, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Camp Mojache Brave - In Combat - Cast ''Shoot'''),
(53562, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Feathermoon Sentinel - In Combat - Cast ''Shoot''');

-- 040_eastern_plaguelands
SET @ENTRIES := '11620,31094,45692,46093,46094,51986';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(11620, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 5337, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Spectral Marauder - In Combat - Cast ''Wither Strike'''),
(31094, 0, 0, 0, 0, 0, 100, 0, 9250, 14750, 10250, 15750, 11, 52372, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Knight of the Ebon Blade - In Combat - Cast Icy Touch'),
(31094, 0, 1, 0, 0, 0, 100, 0, 4500, 6200, 5500, 7200, 11, 52374, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Knight of the Ebon Blade - In Combat - Cast Blood Strike'),
(31094, 0, 2, 0, 0, 0, 100, 0, 3500, 9100, 4500, 11000, 11, 52373, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Knight of the Ebon Blade - In Combat - Cast Plague Strike'),
(31094, 0, 3, 0, 0, 0, 100, 0, 5200, 15500, 6200, 17500, 11, 52375, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Knight of the Ebon Blade - In Combat - Cast Death Coil'),
(45692, 0, 0, 0, 67, 0, 100, 0, 3900, 6900, 0, 0, 11, 7159, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Casts Backstab'),
(45692, 0, 1, 0, 13, 0, 100, 0, 20000, 30000, 0, 0, 11, 34802, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cast Kick on Player Spell Cast'),
(45692, 0, 2, 0, 2, 0, 100, 1, 0, 15, 0, 0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Flee at 15% HP'),
(46093, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 18266, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mataus the Wrathcaster - In Combat - Cast ''Curse of Agony'''),
(46093, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 17173, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mataus the Wrathcaster - In Combat - Cast ''Drain Life'''),
(46093, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 9613, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mataus the Wrathcaster - In Combat - Cast ''Shadow Bolt'''),
(46093, 0, 3, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 85800, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Mataus the Wrathcaster - Within 0-5 Range - Cast ''Shadowflame'''),
(46094, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 80003, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Huntsman Leopold - In Combat - Cast ''Black Arrow'''),
(46094, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 79721, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Huntsman Leopold - In Combat - Cast ''Explosive Shot'''),
(46094, 0, 2, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Huntsman Leopold - In Combat - Cast ''Shoot'''),
(46094, 0, 3, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 80004, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Huntsman Leopold - In Combat - Cast ''Snake Trap'''),
(51986, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 18328, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Argent Sentry - Within 0-8 Range - Cast ''Incapacitating Shout'''),
(51986, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 19643, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Argent Sentry - In Combat - Cast ''Mortal Strike'''),
(51986, 0, 2, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 15618, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Argent Sentry - In Combat - Cast ''Snap Kick''');

-- 041_thousand_needles
SET @ENTRIES := '5934,5935,7895,41421,47763,47766,47777,48131';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(5934, 0, 0, 0, 0, 0, 100, 0, 2500, 5000, 50000, 60000, 11, 8256, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Heartrazor - In Combat - Cast ''Lethal Toxin'''),
(5935, 0, 0, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 11020, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ironeye the Invincible - Between 30-60% Health - Cast ''Petrify'' (No Repeat)'),
(7895, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 5137, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ambassador Bloodrage - In Combat - Cast ''Call of the Grave'''),
(7895, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 11443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ambassador Bloodrage - In Combat - Cast ''Cripple'''),
(7895, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 9613, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ambassador Bloodrage - In Combat - Cast ''Shadow Bolt'''),
(41421, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 81219, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Rau Cliffrunner - On Aggro - Cast ''Battle Shout'' (No Repeat)'),
(41421, 0, 1, 0, 0, 0, 100, 0, 4000, 4500, 12000, 13000, 11, 79872, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rau Cliffrunner - In Combat - Cast ''Shockwave'''),
(47763, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 11970, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bound Fury - Within 0-8 Range - Cast ''Fire Nova'''),
(47763, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 80549, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bound Fury - In Combat - Cast ''Gout of Flame'''),
(47763, 0, 2, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 35377, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bound Fury - In Combat - Cast ''Scorch'''),
(47766, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 57780, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bound Vortex - In Combat - Cast ''Lightning Bolt'''),
(47766, 0, 1, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 83004, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Bound Vortex - Out of Combat - Cast ''Storm Cloud'''),
(47777, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 32018, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Animus - In Combat - Cast ''Call Lightning'''),
(47777, 0, 1, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 79539, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Animus - Within 0-5 Range - Cast ''Crashing Wave'''),
(47777, 0, 2, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 83018, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Animus - Within 0-5 Range - Cast ''Magma Wave'''),
(47777, 0, 3, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 32712, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Animus - Within 0-8 Range - Cast ''Shadow Nova'''),
(48131, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 6917, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Needlespine Cobra - In Combat - Cast ''Venom Spit''');

-- 042_badlands
SET @ENTRIES := '2749,7057,51523,51536,51537';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(2749, 0, 0, 0, 2, 0, 100, 1, 5, 30, 0, 0, 11, 9576, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Siege Golem - Between 5-30% Health - Cast ''Lock Down'' (No Repeat)'),
(7057, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 7164, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Digmaster Shovelphlange - On Aggro - Cast ''Defensive Stance'' (No Repeat)'),
(51523, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'New Kargath Defender - In Combat - Cast ''Cleave'''),
(51523, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'New Kargath Defender - In Combat - Cast ''Shoot'''),
(51536, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Reliquary Overseer - In Combat - Cast ''Shoot'''),
(51537, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragon''s Mouth Sentry - In Combat - Cast ''Cleave'''),
(51537, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dragon''s Mouth Sentry - In Combat - Cast ''Shoot''');

-- 043_tanaris
SET @ENTRIES := '8197,8198,8208,44569,44573,44598,44694,48155,51517';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(8197, 0, 0, 0, 0, 0, 100, 0, 1700, 2600, 9600, 12800, 11, 13748, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chronalis - In Combat - Cast ''Arcane Bolt'''),
(8197, 0, 1, 0, 2, 0, 100, 1, 40, 80, 0, 0, 11, 20717, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chronalis - Between 40-80% Health - Cast ''Sand Breath'' (No Repeat)'),
(8197, 0, 2, 0, 2, 0, 100, 1, 10, 30, 0, 0, 11, 18144, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Chronalis - Between 10-30% Health - Cast ''Swoop'' (No Repeat)'),
(8198, 0, 0, 0, 0, 0, 100, 0, 2100, 3200, 9700, 11300, 11, 21073, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Tick - In Combat - Cast ''Arcane Explosion'''),
(8198, 0, 1, 0, 2, 0, 100, 1, 40, 80, 0, 0, 11, 20717, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Tick - Between 40-80% Health - Cast ''Sand Breath'' (No Repeat)'),
(8198, 0, 2, 0, 2, 0, 100, 1, 10, 30, 0, 0, 11, 18144, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Tick - Between 10-30% Health - Cast ''Swoop'' (No Repeat)'),
(8208, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 7938, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Murderous Blisterpaw - In Combat - Cast ''Fatal Bite'''),
(8208, 0, 1, 0, 0, 0, 100, 0, 6000, 8000, 12000, 16000, 11, 36991, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Murderous Blisterpaw - In Combat - Cast ''Rend'''),
(8208, 0, 2, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 3391, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Murderous Blisterpaw - In Combat - Cast ''Thrash'''),
(44569, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sand Lasher - On Aggro - Set Event Phase 1 (No Repeat)'),
(44569, 0, 1, 0, 4, 1, 100, 1, 0, 0, 0, 0, 11, 48195, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sand Lasher - On Aggro - Cast ''Emerald Lasher Emerge'' (Phase 1) (No Repeat)'),
(44569, 0, 2, 0, 4, 1, 100, 1, 0, 0, 0, 0, 91, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sand Lasher - On Aggro - Remove Flag Standstate Submerged (Phase 1) (No Repeat)'),
(44569, 0, 3, 0, 0, 1, 100, 0, 3000, 5000, 12000, 15000, 11, 43619, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sand Lasher - In Combat - Cast ''Wrath'' (Phase 1)'),
(44569, 0, 4, 0, 7, 1, 100, 1, 0, 0, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sand Lasher - On Evade - Set Event Phase 2 (Phase 1) (No Repeat)'),
(44569, 0, 5, 0, 7, 2, 100, 1, 0, 0, 0, 0, 91, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sand Lasher - On Evade - Remove Flag Standstate Submerged (Phase 2) (No Repeat)'),
(44569, 0, 6, 0, 21, 2, 100, 1, 0, 0, 0, 0, 90, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sand Lasher - On Reached Home - Set Flag Standstate Submerged (Phase 2) (No Repeat)'),
(44573, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 31747, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dune Worm - In Combat - Cast ''Poison'''),
(44598, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Desert Bloom - On Aggro - Set Event Phase 1 (No Repeat)'),
(44598, 0, 1, 0, 4, 1, 100, 1, 0, 0, 0, 0, 11, 48195, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Desert Bloom - On Aggro - Cast ''Emerald Lasher Emerge'' (Phase 1) (No Repeat)'),
(44598, 0, 2, 0, 4, 1, 100, 1, 0, 0, 0, 0, 91, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Desert Bloom - On Aggro - Remove Flag Standstate Submerged (Phase 1) (No Repeat)'),
(44598, 0, 3, 0, 2, 1, 100, 1, 0, 30, 0, 0, 11, 83504, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Desert Bloom - Between 0-30% Health - Cast ''Healing Rain'' (Phase 1) (No Repeat)'),
(44598, 0, 4, 0, 7, 1, 100, 1, 0, 0, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Desert Bloom - On Evade - Set Event Phase 2 (Phase 1) (No Repeat)'),
(44598, 0, 5, 0, 7, 2, 100, 1, 0, 0, 0, 0, 91, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Desert Bloom - On Evade - Remove Flag Standstate Submerged (Phase 2) (No Repeat)'),
(44598, 0, 6, 0, 21, 2, 100, 1, 0, 0, 0, 0, 90, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Desert Bloom - On Reached Home - Set Flag Standstate Submerged (Phase 2) (No Repeat)'),
(44694, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 31747, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Noxious Tunneler - In Combat - Cast ''Poison'''),
(48155, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 94022, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Saltspray Gull - In Combat - Cast ''Trick'''),
(51517, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bootlegger Bruiser - In Combat - Cast ''Cleave'''),
(51517, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Bootlegger Bruiser - In Combat - Cast ''Shoot''');

-- 044_felwood
SET @ENTRIES := '7135,7136,11552,14343,51610,51845';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(7135, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 10966, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Infernal Bodyguard - In Combat - Cast ''Uppercut'''),
(7136, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 2602, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Infernal Sentry - On Aggro - Cast ''Fire Shield'''),
(11552, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 585, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Timbermaw Mystic - In Combat - Cast ''Smite'''),
(11552, 0, 1, 0, 0, 0, 100, 0, 10000, 13000, 15000, 19000, 11, 8092, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Timbermaw Mystic - In Combat - Cast ''Mind Blast'''),
(14343, 0, 0, 0, 0, 0, 100, 0, 2100, 2300, 15900, 18600, 11, 3589, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Olm the Wise - In Combat - Cast ''Deafening Screech'''),
(14343, 0, 1, 0, 2, 0, 100, 1, 5, 30, 0, 0, 11, 6605, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Olm the Wise - Between 5-30% Health - Cast ''Terrifying Screech'' (No Repeat)'),
(51610, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 45900, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Emerald Druid - In Combat - Cast ''Moonfire'''),
(51610, 0, 1, 0, 1, 0, 100, 1, 1000, 3000, 0, 0, 11, 79824, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Emerald Druid - Out of Combat - Cast ''Summon Treant Ally'' (No Repeat)'),
(51845, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Talonbranch Guardian - In Combat - Cast ''Shoot''');

-- 045_searing_gorge
SET @ENTRIES := '5857,8279';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(5857, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 11, 4167, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Searing Lava Spider - On Aggro - Cast ''Web'' (No Repeat)'),
(8279, 0, 0, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 9576, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Faulty War Golem - Between 30-60% Health - Cast ''Lock Down'' (No Repeat)');

-- 046_burning_steppes
SET @ENTRIES := '8917,48153,51539,51540';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(8917, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 5000, 8000, 11, 14516, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Quarry Slave - In Combat - Cast Strike'),
(8917, 0, 1, 0, 0, 0, 100, 0, 7000, 9000, 13000, 16000, 11, 9080, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Quarry Slave - In Combat - Cast Hamstring'),
(48153, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 3248, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Goblin Flamethrower - In Combat - Cast ''Improved Blocking'''),
(51539, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Flame Crest Bruiser - In Combat - Cast ''Cleave'''),
(51539, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Flame Crest Bruiser - In Combat - Cast ''Shoot'''),
(51540, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vigil Guard - In Combat - Cast ''Cleave'''),
(51540, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vigil Guard - In Combat - Cast ''Shoot''');

-- 047_un_goro_crater
SET @ENTRIES := '6506,6514,6521,6560,38305,38307,38329,38708,51525';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(6506, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ravasaur Runner - On Aggro - Cast ''Rushing Charge'''),
(6514, 0, 0, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 12555, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Un''Goro Gorilla - Between 30-60% Health - Cast ''Pummel'' (No Repeat)'),
(6521, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 11350, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Living Blaze - On Aggro - Cast ''Fire Shield'''),
(6560, 0, 0, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 5810, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Stone Guardian - Between 30-60% Health - Cast ''Stone Skin'' (No Repeat)'),
(38305, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 71791, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Gorishi Fledgling Colossus - Within 0-8 Range - Cast ''Poison Explosion'''),
(38305, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 71792, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Gorishi Fledgling Colossus - In Combat - Cast ''Poison Spit'''),
(38307, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 5568, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Gormashh - Within 0-8 Range - Cast ''Trample'''),
(38329, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 83386, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Durrin Direshovel - In Combat - Cast ''Heave'''),
(38329, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 11971, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Durrin Direshovel - In Combat - Cast ''Sunder Armor'''),
(38708, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 44531, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Devilsaur Queen - In Combat - Cast ''Dash'''),
(51525, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Marshal Expeditions Mercenary - In Combat - Cast ''Cleave'''),
(51525, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Marshal Expeditions Mercenary - In Combat - Cast ''Shoot''');

-- 048_winterspring
SET @ENTRIES := '7430,7439,10661,10741,48670,48918,50258,50325';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(7430, 0, 0, 0, 0, 0, 100, 0, 1500, 2000, 10000, 11000, 11, 24331, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostsaber Cub - In Combat - Cast ''Rake'''),
(7439, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 9532, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Winterfall Shaman - In Combat - Cast ''Lightning Bolt'''),
(7439, 0, 1, 0, 1, 0, 100, 0, 1000, 1000, 1200000, 1200000, 11, 17205, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Winterfall Shaman - Out of Combat - Cast ''Winterfall Firewater'''),
(7439, 0, 2, 0, 1, 0, 100, 0, 500, 1000, 600000, 600000, 11, 13585, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Winterfall Shaman - Out of Combat - Cast ''Lightning Shield'''),
(7439, 0, 3, 0, 16, 0, 100, 0, 13585, 1, 15000, 30000, 11, 13585, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Winterfall Shaman - On Friendly Unit Missing Buff ''Lightning Shield'' - Cast ''Lightning Shield'''),
(7439, 0, 4, 0, 2, 0, 100, 0, 0, 40, 14000, 21000, 11, 11431, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Winterfall Shaman - Between 0-40% Health - Cast ''Healing Touch'''),
(10661, 0, 0, 0, 0, 0, 100, 0, 2400, 3500, 8600, 9700, 11, 16340, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Spell Eater - In Combat - Cast ''Frost Breath'''),
(10741, 0, 0, 0, 2, 0, 100, 0, 0, 35, 25000, 26000, 11, 14100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sian-Rotam - Between 0-35% Health - Cast ''Terrifying Roar'''),
(10741, 0, 1, 0, 0, 0, 100, 0, 4000, 5000, 17000, 19000, 11, 3604, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sian-Rotam - In Combat - Cast ''Tendon Rip'''),
(10741, 0, 2, 0, 0, 0, 100, 0, 6500, 8000, 25000, 27000, 11, 13443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sian-Rotam - In Combat - Cast ''Rend'''),
(10741, 0, 3, 0, 54, 0, 100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Sian-Rotam - Just Summoned - Say Line 0'),
(48670, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Betrayed Ranger - In Combat - Cast ''Cleave'''),
(48670, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 6660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Betrayed Ranger - In Combat - Cast ''Shoot'''),
(48918, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 81087, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Winterhorn Stag - In Combat - Cast ''Puncture Wound'''),
(48918, 0, 1, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 11, 6268, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Winterhorn Stag - Within 8-25 Range - Cast ''Rushing Charge'''),
(50258, 0, 0, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 18670, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostmaul Tumbler - In Combat - Cast ''Knock Away'''),
(50258, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 18368, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostmaul Tumbler - In Combat - Cast ''Strike'''),
(50325, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 79868, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Umbranse the Spiritspeaker - In Combat - Cast ''Arcane Blast'''),
(50325, 0, 1, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 93723, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Umbranse the Spiritspeaker - Within 0-8 Range - Cast ''Arcane Explosion'''),
(50325, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 34447, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Umbranse the Spiritspeaker - In Combat - Cast ''Arcane Missiles'''),
(50325, 0, 3, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 21655, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Umbranse the Spiritspeaker - In Combat - Cast ''Blink''');

-- 049_swamp_of_sorrows
SET @ENTRIES := '14445,46368,51789,51918';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(14445, 0, 0, 0, 9, 0, 100, 0, 0, 5, 10000, 14000, 11, 12533, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Captain Wyrmak - Within 0-5 Range - Cast ''Acid Breath'''),
(14445, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Captain Wyrmak - In Combat - Cast ''Cleave'''),
(46368, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 6951, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Enthralled Makrura - In Combat - Cast ''Decayed Strength'''),
(51789, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 12000, 16000, 11, 80012, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Marshtide Sentry - In Combat - Cast ''Chimera Shot'''),
(51789, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 15000, 20000, 11, 22910, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Marshtide Sentry - In Combat - Cast ''Immolation Trap'''),
(51789, 0, 2, 0, 0, 0, 100, 0, 10000, 13000, 15000, 19000, 11, 80009, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Marshtide Sentry - In Combat - Cast ''Serpent Sting'''),
(51789, 0, 3, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Marshtide Sentry - In Combat - Cast ''Shoot'''),
(51918, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Stonard Grunt - In Combat - Cast ''Revenge'''),
(51918, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 12169, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Stonard Grunt - In Combat - Cast ''Shield Block'''),
(51918, 0, 2, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Stonard Grunt - In Combat - Cast ''Shoot''');

-- 050_blasted_lands
SET @ENTRIES := '41279,41290,51541';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(41279, 0, 0, 0, 1, 0, 100, 0, 1000, 2000, 30000, 30000, 11, 77371, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Loramus Thalipedes - Out of Combat - Cast ''Demon Hunter''s Resolve'''),
(41279, 0, 1, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 9081, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Loramus Thalipedes - Within 0-8 Range - Cast ''Shadow Bolt Volley'''),
(41290, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 7741, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Defiled Felhound - In Combat - Cast ''Summoned Demon'''),
(51541, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Sunveil Scout - In Combat - Cast ''Shoot''');

-- 051_silithus
SET @ENTRIES := '11721,11726,11728,11731,11734,11740,11883,12199,14471,14474,14477,14479,15201,15202,15213,15441,15545,15617,15742,15743';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(11721, 0, 0, 0, 0, 0, 100, 0, 2700, 3200, 32700, 33200, 11, 744, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hive''Ashi Worker - In Combat - Cast ''Poison'''),
(11726, 0, 0, 0, 0, 0, 100, 0, 2700, 3600, 11700, 14300, 11, 14120, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hive''Zora Tunneler - In Combat - Cast ''Tunneler Acid'''),
(11728, 0, 0, 0, 0, 0, 100, 0, 6000, 9000, 20000, 22000, 11, 16790, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hive''Zora Reaver - In Combat - Cast Knockdown'),
(11728, 0, 1, 0, 9, 0, 100, 0, 0, 5, 16000, 19000, 11, 40504, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hive''Zora Reaver - Within 0-5 Range - Cast Cleave'),
(11731, 0, 0, 0, 2, 0, 100, 1, 30, 60, 0, 0, 11, 29506, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Hive''Regal Burrower - Between 30-60% Health - Cast ''The Burrower''s Shell'' (No Repeat)'),
(11734, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 19471, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hive''Regal Hive Lord - On Aggro - Cast Berserker Charge'),
(11740, 0, 0, 0, 9, 0, 100, 1, 8, 25, 0, 0, 11, 22911, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Dredge Striker - Within 8-25 Range - Cast Charge (No Repeat)'),
(11883, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - On Aggro - Set Event Phase 1 (No Repeat)'),
(11883, 0, 1, 0, 4, 1, 100, 1, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - On Aggro - Disable Combat Movement (Phase 1) (No Repeat)'),
(11883, 0, 2, 0, 4, 1, 100, 1, 0, 0, 0, 0, 11, 9672, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - On Aggro - Cast ''Frostbolt'' (Phase 1) (No Repeat)'),
(11883, 0, 3, 0, 9, 1, 100, 0, 0, 40, 3400, 4700, 11, 9672, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - Within 0-40 Range - Cast ''Frostbolt'' (Phase 1)'),
(11883, 0, 4, 0, 9, 1, 100, 0, 40, 100, 2000, 2000, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - Within 40-100 Range - Enable Combat Movement (Phase 1)'),
(11883, 0, 5, 0, 9, 1, 100, 0, 10, 15, 2000, 2000, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - Within 10-15 Range - Disable Combat Movement (Phase 1)'),
(11883, 0, 6, 0, 9, 1, 100, 0, 0, 40, 2000, 2000, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - Within 0-40 Range - Disable Combat Movement (Phase 1)'),
(11883, 0, 7, 0, 3, 1, 100, 1, 0, 15, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - Between 0-15% Mana - Set Event Phase 2 (Phase 1)'),
(11883, 0, 8, 0, 3, 2, 100, 1, 0, 15, 0, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - Between 0-15% Mana - Enable Combat Movement (Phase 2)'),
(11883, 0, 9, 0, 3, 2, 100, 0, 30, 100, 100, 100, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - Between 30-100% Mana - Set Event Phase 1 (Phase 2)'),
(11883, 0, 10, 0, 9, 1, 100, 0, 0, 8, 13600, 14500, 11, 11831, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Master - Within 0-8 Range - Cast ''Frost Nova'' (Phase 1)'),
(11883, 0, 11, 0, 0, 1, 100, 0, 8000, 9000, 24000, 25000, 11, 12058, 1, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 'Cast Chain Lightning'),
(11883, 0, 12, 0, 0, 1, 100, 0, 5000, 6000, 15000, 21000, 11, 13339, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Cast Fire Blast'),
(12199, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 24313, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Shade of Ambermoon - On Aggro - Cast ''Shade'''),
(14471, 0, 0, 0, 0, 0, 100, 0, 8000, 12000, 18000, 26000, 11, 16727, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Setis - In Combat - Cast War Stomp'),
(14471, 0, 1, 0, 0, 0, 100, 0, 14000, 20000, 15000, 23000, 11, 10887, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Setis - In Combat - Cast Crowd Pummel'),
(14474, 0, 0, 0, 9, 0, 100, 0, 0, 30, 12000, 18000, 11, 21067, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Zora - Within 0-30 Range - Cast Poison Bolt'),
(14477, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 5568, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Grubthor - Within 0-8 Range - Cast ''Trample'''),
(14479, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - On Aggro - Set Event Phase 1 (No Repeat)'),
(14479, 0, 1, 0, 4, 1, 100, 1, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - On Aggro - Disable Combat Movement (Phase 1) (No Repeat)'),
(14479, 0, 2, 0, 4, 1, 100, 1, 0, 0, 0, 0, 11, 19816, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - On Aggro - Cast ''Fireball'' (Phase 1) (No Repeat)'),
(14479, 0, 3, 0, 9, 1, 100, 0, 0, 40, 3400, 4700, 11, 19816, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - Within 0-40 Range - Cast ''Fireball'' (Phase 1)'),
(14479, 0, 4, 0, 9, 1, 100, 0, 40, 100, 2000, 2000, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - Within 40-100 Range - Enable Combat Movement (Phase 1)'),
(14479, 0, 5, 0, 9, 1, 100, 0, 10, 15, 2000, 2000, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - Within 10-15 Range - Disable Combat Movement (Phase 1)'),
(14479, 0, 6, 0, 9, 1, 100, 0, 0, 40, 2000, 2000, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - Within 0-40 Range - Disable Combat Movement (Phase 1)'),
(14479, 0, 7, 0, 3, 1, 100, 1, 0, 15, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - Between 0-15% Mana - Set Event Phase 2 (Phase 1)'),
(14479, 0, 8, 0, 3, 2, 100, 1, 0, 15, 0, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - Between 0-15% Mana - Enable Combat Movement (Phase 2)'),
(14479, 0, 9, 0, 3, 2, 100, 0, 30, 100, 100, 100, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - Between 30-100% Mana - Set Event Phase 1 (Phase 2)'),
(14479, 0, 10, 0, 9, 1, 100, 0, 0, 20, 12000, 15000, 11, 17439, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Lord Everun - Within 0-20 Range - Cast ''Shadow Shock'' (Phase 1)'),
(15201, 0, 0, 0, 0, 0, 100, 0, 2000, 5000, 18000, 22000, 11, 15732, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Flamereaver - In Combat - Cast Immolate'),
(15202, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - On Aggro - Set Event Phase 1 (No Repeat)'),
(15202, 0, 1, 0, 4, 1, 100, 1, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - On Aggro - Disable Combat Movement (Phase 1) (No Repeat)'),
(15202, 0, 2, 0, 4, 1, 100, 1, 0, 0, 0, 0, 11, 19816, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - On Aggro - Cast ''Fireball'' (Phase 1) (No Repeat)'),
(15202, 0, 3, 0, 9, 1, 100, 0, 0, 40, 3400, 4700, 11, 19816, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - Within 0-40 Range - Cast ''Fireball'' (Phase 1)'),
(15202, 0, 4, 0, 9, 1, 100, 0, 40, 100, 2000, 2000, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - Within 40-100 Range - Enable Combat Movement (Phase 1)'),
(15202, 0, 5, 0, 9, 1, 100, 0, 10, 15, 2000, 2000, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - Within 10-15 Range - Disable Combat Movement (Phase 1)'),
(15202, 0, 6, 0, 9, 1, 100, 0, 0, 40, 2000, 2000, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - Within 0-40 Range - Disable Combat Movement (Phase 1)'),
(15202, 0, 7, 0, 3, 1, 100, 1, 0, 15, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - Between 0-15% Mana - Set Event Phase 2 (Phase 1)'),
(15202, 0, 8, 0, 3, 2, 100, 1, 0, 15, 0, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - Between 0-15% Mana - Enable Combat Movement (Phase 2)'),
(15202, 0, 9, 0, 3, 2, 100, 0, 30, 100, 100, 100, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - Between 30-100% Mana - Set Event Phase 1 (Phase 2)'),
(15202, 0, 10, 0, 9, 1, 100, 0, 0, 20, 12000, 15000, 11, 17439, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Vyral the Vile - Within 0-20 Range - Cast ''Shadow Shock'' (Phase 1)'),
(15213, 0, 0, 0, 4, 0, 100, 1, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - On Aggro - Set Event Phase 1 (No Repeat)'),
(15213, 0, 1, 0, 4, 1, 100, 1, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - On Aggro - Disable Combat Movement (Phase 1) (No Repeat)'),
(15213, 0, 2, 0, 4, 1, 100, 1, 0, 0, 0, 0, 11, 9672, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - On Aggro - Cast ''Frostbolt'' (Phase 1) (No Repeat)'),
(15213, 0, 3, 0, 9, 1, 100, 0, 0, 40, 3400, 4700, 11, 9672, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - Within 0-40 Range - Cast ''Frostbolt'' (Phase 1)'),
(15213, 0, 4, 0, 9, 1, 100, 0, 40, 100, 2000, 2000, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - Within 40-100 Range - Enable Combat Movement (Phase 1)'),
(15213, 0, 5, 0, 9, 1, 100, 0, 10, 15, 2000, 2000, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - Within 10-15 Range - Disable Combat Movement (Phase 1)'),
(15213, 0, 6, 0, 9, 1, 100, 0, 0, 40, 2000, 2000, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - Within 0-40 Range - Disable Combat Movement (Phase 1)'),
(15213, 0, 7, 0, 3, 1, 100, 1, 0, 15, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - Between 0-15% Mana - Set Event Phase 2 (Phase 1)'),
(15213, 0, 8, 0, 3, 2, 100, 1, 0, 15, 0, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - Between 0-15% Mana - Enable Combat Movement (Phase 2)'),
(15213, 0, 9, 0, 3, 2, 100, 0, 30, 100, 100, 100, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - Between 30-100% Mana - Set Event Phase 1 (Phase 2)'),
(15213, 0, 10, 0, 9, 1, 100, 0, 0, 8, 13600, 14500, 11, 11831, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - Within 0-8 Range - Cast ''Frost Nova'' (Phase 1)'),
(15213, 0, 11, 0, 0, 1, 100, 0, 8000, 9000, 24000, 25000, 11, 12058, 1, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - In Combat - Cast ''Chain Lightning'' (Phase 1)'),
(15213, 0, 12, 0, 0, 1, 100, 0, 5000, 6000, 15000, 21000, 11, 13339, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Twilight Overlord - In Combat - Cast ''Fire Blast'' (Phase 1)'),
(15441, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Ironforge Brigade Rifleman - In Combat - Cast Shoot'),
(15545, 0, 0, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Cenarion Outrider - Within 0-8 Range - Cast ''Demoralizing Shout'''),
(15617, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 10277, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Orgrimmar Legion Axe Thrower - In Combat - Cast Throw'),
(15742, 0, 0, 0, 0, 0, 100, 0, 5000, 5000, 5000, 10000, 11, 26167, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Colossus of Ashi - In Combat - Cast ''Colossal Smash'''),
(15743, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 19632, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Colossal Anubisath Warbringer - In Combat - Cast ''Cleave'''),
(15743, 0, 1, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 18944, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Colossal Anubisath Warbringer - Within 0-8 Range - Cast ''Smash'''),
(15743, 0, 2, 0, 9, 0, 100, 0, 0, 8, 12000, 18000, 11, 16727, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Colossal Anubisath Warbringer - Within 0-8 Range - Cast ''War Stomp''');

-- 052_deadwind_pass
SET @ENTRIES := '51987,57910';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(51987, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 6751, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Deadwind Widow - In Combat - Cast ''Weak Poison'''),
(57910, 0, 0, 0, 0, 0, 100, 0, 3000, 6000, 15000, 20000, 11, 110038, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Nalice - In Combat - Cast ''Arcane Destruction''');

-- 053_plaguelands
SET @ENTRIES := '28530,28576,28577,28594,28642,28834,28850,28856,28934,28964,29030,29031,29080,29102,29103,29106,29115,29136';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(28530, 0, 0, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Commander - In Combat - Cast ''Shoot'''),
(28576, 0, 0, 0, 1, 0, 30, 0, 5000, 20000, 5000, 20000, 11, 52149, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Citizen of Havenshire - Out of Combat - Cast ''Rain of Darkness'''),
(28577, 0, 0, 0, 1, 0, 30, 0, 5000, 20000, 5000, 20000, 11, 52149, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Citizen of Havenshire - Out of Combat - Cast ''Rain of Darkness'''),
(28594, 0, 0, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 11, 15498, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Preacher - In Combat - Cast ''Holy Smite'''),
(28594, 0, 1, 0, 0, 0, 100, 0, 3000, 6000, 18000, 24000, 11, 19725, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Preacher - In Combat - Cast ''Turn Undead'''),
(28642, 0, 0, 0, 1, 0, 100, 0, 5000, 20000, 5000, 20000, 11, 52147, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Scourge Sky Darkener - Out of Combat - Cast ''Sky Darkener Assault'''),
(28834, 0, 0, 0, 0, 0, 100, 0, 1000, 5000, 5000, 8000, 11, 52566, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Fleet Defender - In Combat - Cast ''Shoot'''),
(28850, 0, 0, 0, 0, 0, 100, 0, 1000, 1000, 4000, 5000, 11, 52539, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Land Cannon - In Combat - Cast ''Cannonball'''),
(28856, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 25710, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Fleet Guardian - In Combat - Cast ''Heroic Strike'''),
(28856, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 52566, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Fleet Guardian - In Combat - Cast ''Shoot'''),
(28934, 0, 0, 0, 0, 0, 100, 0, 4000, 6000, 8000, 12000, 11, 52372, 32, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Icy Touch'''),
(28934, 0, 1, 0, 0, 0, 100, 0, 3000, 5000, 8000, 12000, 11, 52373, 32, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Plague Strike'''),
(28934, 0, 2, 0, 0, 0, 100, 0, 4000, 8000, 4000, 8000, 11, 52374, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Blood Strike'''),
(28934, 0, 3, 0, 0, 0, 100, 0, 0, 0, 0, 0, 11, 52375, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Death Coil'''),
(28964, 0, 0, 0, 0, 0, 100, 0, 4000, 8000, 8000, 12000, 11, 52835, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Lord Jesseriah McCree - In Combat - Cast ''Cleave'''),
(28964, 0, 1, 0, 0, 0, 100, 0, 12000, 18000, 30000, 35000, 11, 52836, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Lord Jesseriah McCree - In Combat - Cast ''Holy Wrath'''),
(29030, 0, 0, 0, 1, 0, 100, 0, 4000, 10000, 8000, 14000, 11, 52953, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - Out of Combat - Cast ''Torch'''),
(29030, 0, 1, 0, 0, 0, 100, 0, 4000, 6000, 8000, 12000, 11, 52372, 32, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Icy Touch'''),
(29030, 0, 2, 0, 0, 0, 100, 0, 3000, 5000, 8000, 12000, 11, 52373, 32, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Plague Strike'''),
(29030, 0, 3, 0, 0, 0, 100, 0, 4000, 8000, 4000, 8000, 11, 52374, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Blood Strike'''),
(29031, 0, 0, 0, 1, 0, 100, 0, 4000, 10000, 8000, 14000, 11, 52953, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - Out of Combat - Cast ''Torch'''),
(29031, 0, 1, 0, 0, 0, 100, 0, 4000, 6000, 8000, 12000, 11, 52372, 32, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Icy Touch'''),
(29031, 0, 2, 0, 0, 0, 100, 0, 3000, 5000, 8000, 12000, 11, 52373, 32, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Plague Strike'''),
(29031, 0, 3, 0, 0, 0, 100, 0, 4000, 8000, 4000, 8000, 11, 52374, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight - In Combat - Cast ''Blood Strike'''),
(29080, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 25710, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Champion - In Combat - Cast ''Heroic Strike'''),
(29080, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 52566, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Champion - In Combat - Cast ''Shoot'''),
(29102, 0, 0, 0, 25, 0, 100, 0, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Hearthglen Crusader - On Reset - Set Event Phase 1'),
(29102, 0, 1, 0, 24, 1, 100, 0, 52196, 1, 1000, 2000, 11, 53348, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Hearthglen Crusader - On Target Buffed With ''Frostbrood Vanquisher'' - Cast ''Arrow Assault'' (Phase 1)'),
(29102, 0, 2, 0, 9, 1, 100, 0, 40, 150, 4000, 6000, 11, 53345, 64, 0, 1, 0, 0, 9, 0, 40, 150, 0, 0, 0, 0, 'Hearthglen Crusader - Within 40-150 Range - Cast ''Arrow Assault'' (Phase 1)'),
(29102, 0, 3, 0, 8, 0, 100, 0, 53110, 1, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Hearthglen Crusader - On Spellhit ''Devour Humanoid'' - Set Event Phase 2'),
(29103, 0, 0, 0, 25, 0, 100, 0, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tirisfal Crusader - On Reset - Set Event Phase 1'),
(29103, 0, 1, 0, 24, 1, 100, 0, 52196, 1, 1000, 2000, 11, 53348, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Tirisfal Crusader - On Target Buffed With ''Frostbrood Vanquisher'' - Cast ''Arrow Assault'' (Phase 1)'),
(29103, 0, 2, 0, 9, 1, 100, 0, 40, 150, 4000, 6000, 11, 53345, 64, 0, 1, 0, 0, 9, 0, 40, 150, 0, 0, 0, 0, 'Tirisfal Crusader - Within 40-150 Range - Cast ''Arrow Assault'' (Phase 1)'),
(29103, 0, 3, 0, 8, 0, 100, 0, 53110, 0, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Tirisfal Crusader - On Spellhit ''Devour Humanoid'' - Set Event Phase 2'),
(29106, 0, 0, 0, 0, 0, 100, 0, 4000, 6000, 8000, 12000, 11, 52372, 32, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight Champion - In Combat - Cast ''Icy Touch'''),
(29106, 0, 1, 0, 0, 0, 100, 0, 3000, 5000, 8000, 12000, 11, 52373, 32, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight Champion - In Combat - Cast ''Plague Strike'''),
(29106, 0, 2, 0, 0, 0, 100, 0, 4000, 8000, 4000, 8000, 11, 52374, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight Champion - In Combat - Cast ''Blood Strike'''),
(29106, 0, 3, 0, 0, 0, 100, 0, 0, 0, 0, 0, 11, 52375, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Death Knight Champion - In Combat - Cast ''Death Coil'''),
(29115, 0, 0, 0, 0, 0, 100, 0, 8000, 12000, 8000, 12000, 11, 53633, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rampaging Abomination - In Combat - Cast ''Cleave'''),
(29115, 0, 1, 0, 9, 0, 100, 0, 8, 40, 8000, 12000, 11, 50335, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Rampaging Abomination - Within 8-40 Range - Cast ''Scourge Hook'''),
(29136, 0, 0, 0, 6, 0, 100, 0, 0, 0, 0, 0, 11, 53278, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Volatile Ghoul - On Just Died - Cast ''Ghoulplosion''');

-- 054_moonglade
SET @ENTRIES := '53563';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(53563, 0, 0, 0, 0, 0, 100, 0, 2000, 4000, 8000, 12000, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Moonglade Warden - In Combat - Cast ''Cleave'''),
(53563, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 12000, 16000, 11, 95826, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Moonglade Warden - In Combat - Cast ''Shoot''');

-- 055_razorfen_kraul
SET @ENTRIES := '4425,4435,4512,4514,6168';

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `AIName` = '' AND `ScriptName` = '' AND FIND_IN_SET(`entry`, @ENTRIES);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND FIND_IN_SET(`entryorguid`, @ENTRIES);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(4425, 0, 0, 0, 0, 0, 100, 0, 3000, 5000, 6000, 9000, 11, 12553, 0, 0, 0, 0, 0, 5, 30, 0, 0, 0, 0, 0, 0, 'Blind Hunter - In Combat - Cast Shock'),
(4435, 0, 0, 0, 0, 0, 100, 0, 2000, 12000, 30000, 70000, 11, 9128, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Razorfen Warrior - In Combat - Cast Battle Shout'),
(4512, 0, 0, 0, 0, 0, 100, 0, 3000, 10000, 30000, 35000, 11, 8267, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Rotting Agam''ar - In Combat - Cast Cursed Blood'),
(4514, 0, 0, 0, 2, 0, 100, 1, 0, 40, 0, 0, 11, 8269, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Raging Agam''ar - Between Health 0-40% - Cast Frenzy'),
(6168, 0, 0, 0, 0, 0, 100, 0, 0, 500, 3000, 3000, 11, 9532, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Roogug - In Combat - Cast Lightning Bolt');

-- Rollback:
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` IN (1765,1131,42290,1998,2001,38046,38217,39215,39337,3035,36696,15635,15649,15650,15949,15967,16855,34763,35812,35838,35891,35894,35896,35897,35904,36092,36149,36153,36346,36681,36719,36735,36740,38187,38359,38360,38575,38808,38809,38810,38811,38845,38851,39042,39069,39141,39142,39143,39193,39354,39376,39426,39449,39589,40064,40067,40068,60554,60851,60852,60853,60854,596,42407,51915,44724,33127,33181,34056,34427,48763,17322,17327,17328,17330,17331,17333,17334,17336,17339,17340,17341,17342,17343,17346,17349,17350,17352,17353,17358,17494,17522,17523,17527,17604,17607,17608,17609,17661,17678,17683,17704,17715,44111,45335,45367,45403,45481,45483,45499,45536,45537,45538,57802,3241,3242,3244,3286,3475,3638,3652,4316,7288,7308,7310,20797,51815,51914,6370,6646,6647,6652,13896,36639,51508,51509,52018,16347,16353,14273,43041,43369,47134,47135,47136,47137,47138,47145,47231,47232,4798,6047,503,5683,41072,41080,41132,41137,41145,41147,41151,41167,41272,41293,41342,41343,41388,41389,41390,41391,41394,41400,41401,41409,41416,41419,41420,41424,41425,41426,41427,41428,41429,41449,41453,41522,41524,41553,41556,41558,41613,42041,42042,42043,42107,42110,42111,42154,42577,44110,44116,44224,44225,44226,44227,46122,48535,51520,51844,51922,3730,3736,3940,6072,26116,33195,51507,51770,51814,51816,51867,2356,13219,14278,14280,51842,51843,51916,2779,24477,41295,42090,51819,51899,679,691,723,781,784,873,875,877,879,976,978,979,4260,4723,42858,42872,43049,43910,43911,43912,43913,51521,51533,51658,51662,51917,52184,52404,53000,53166,3991,4014,4015,4030,4067,5916,5931,34923,41311,51820,51825,51827,51828,51829,51830,51837,6224,6232,6407,7738,4542,595,669,676,677,681,682,684,685,687,772,905,1094,1516,1557,1713,2541,2635,14491,15088,43050,51534,51661,51663,51823,52224,52372,52982,3246,3248,3425,3426,3454,3455,4127,5848,51851,51852,51853,51859,51861,4644,4676,4688,5601,11685,11687,11688,11787,11788,13718,35828,43889,51511,51840,2658,2680,43016,4397,4973,5184,15552,23841,23899,23900,23941,51924,1838,1884,10605,16143,51535,5258,39339,39607,43838,51832,51920,53562,11620,31094,45692,46093,46094,51986,5934,5935,7895,41421,47763,47766,47777,48131,2749,7057,51523,51536,51537,8197,8198,8208,44569,44573,44598,44694,48155,51517,7135,7136,11552,14343,51610,51845,5857,8279,8917,48153,51539,51540,6506,6514,6521,6560,38305,38307,38329,38708,51525,7430,7439,10661,10741,48670,48918,50258,50325,14445,46368,51789,51918,41279,41290,51541,11721,11726,11728,11731,11734,11740,11883,12199,14471,14474,14477,14479,15201,15202,15213,15441,15545,15617,15742,15743,51987,57910,28530,28576,28577,28594,28642,28834,28850,28856,28934,28964,29030,29031,29080,29102,29103,29106,29115,29136,53563,4425,4435,4512,4514,6168);
-- UPDATE `creature_template` SET `AIName` = '' WHERE `AIName` = 'SmartAI' AND `ScriptName` = '' AND `entry` IN (1765,1131,42290,1998,2001,38046,38217,39215,39337,3035,36696,15635,15649,15650,15949,15967,16855,34763,35812,35838,35891,35894,35896,35897,35904,36092,36149,36153,36346,36681,36719,36735,36740,38187,38359,38360,38575,38808,38809,38810,38811,38845,38851,39042,39069,39141,39142,39143,39193,39354,39376,39426,39449,39589,40064,40067,40068,60554,60851,60852,60853,60854,596,42407,51915,44724,33127,33181,34056,34427,48763,17322,17327,17328,17330,17331,17333,17334,17336,17339,17340,17341,17342,17343,17346,17349,17350,17352,17353,17358,17494,17522,17523,17527,17604,17607,17608,17609,17661,17678,17683,17704,17715,44111,45335,45367,45403,45481,45483,45499,45536,45537,45538,57802,3241,3242,3244,3286,3475,3638,3652,4316,7288,7308,7310,20797,51815,51914,6370,6646,6647,6652,13896,36639,51508,51509,52018,16347,16353,14273,43041,43369,47134,47135,47136,47137,47138,47145,47231,47232,4798,6047,503,5683,41072,41080,41132,41137,41145,41147,41151,41167,41272,41293,41342,41343,41388,41389,41390,41391,41394,41400,41401,41409,41416,41419,41420,41424,41425,41426,41427,41428,41429,41449,41453,41522,41524,41553,41556,41558,41613,42041,42042,42043,42107,42110,42111,42154,42577,44110,44116,44224,44225,44226,44227,46122,48535,51520,51844,51922,3730,3736,3940,6072,26116,33195,51507,51770,51814,51816,51867,2356,13219,14278,14280,51842,51843,51916,2779,24477,41295,42090,51819,51899,679,691,723,781,784,873,875,877,879,976,978,979,4260,4723,42858,42872,43049,43910,43911,43912,43913,51521,51533,51658,51662,51917,52184,52404,53000,53166,3991,4014,4015,4030,4067,5916,5931,34923,41311,51820,51825,51827,51828,51829,51830,51837,6224,6232,6407,7738,4542,595,669,676,677,681,682,684,685,687,772,905,1094,1516,1557,1713,2541,2635,14491,15088,43050,51534,51661,51663,51823,52224,52372,52982,3246,3248,3425,3426,3454,3455,4127,5848,51851,51852,51853,51859,51861,4644,4676,4688,5601,11685,11687,11688,11787,11788,13718,35828,43889,51511,51840,2658,2680,43016,4397,4973,5184,15552,23841,23899,23900,23941,51924,1838,1884,10605,16143,51535,5258,39339,39607,43838,51832,51920,53562,11620,31094,45692,46093,46094,51986,5934,5935,7895,41421,47763,47766,47777,48131,2749,7057,51523,51536,51537,8197,8198,8208,44569,44573,44598,44694,48155,51517,7135,7136,11552,14343,51610,51845,5857,8279,8917,48153,51539,51540,6506,6514,6521,6560,38305,38307,38329,38708,51525,7430,7439,10661,10741,48670,48918,50258,50325,14445,46368,51789,51918,41279,41290,51541,11721,11726,11728,11731,11734,11740,11883,12199,14471,14474,14477,14479,15201,15202,15213,15441,15545,15617,15742,15743,51987,57910,28530,28576,28577,28594,28642,28834,28850,28856,28934,28964,29030,29031,29080,29102,29103,29106,29115,29136,53563,4425,4435,4512,4514,6168);
