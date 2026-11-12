-- Rollback: restore the tables listed in the Rollback section of state/l1_silverpine_hillsbrad_diff.md from the pre-apply dump.
-- Source: DeltaTho PR 15 via 1LineAtaTime/LoA-Pandaria-Playerbots b179e298 (GPLv2); concatenated in original order:
--   2026_10_29_986_07_sp_sanders_noose.sql
--   2026_10_29_986_14_sp_rear_guard_quests.sql
--   2026_10_29_986_15_sp_rise_forsaken_no_escape.sql
--   2026_10_29_986_16_sp_lordaeron.sql
--   2026_10_29_986_17_sp_nowhere_to_run.sql
--   2026_10_29_986_18_sp_wagons.sql
--   2026_10_29_986_19_sp_skitterweb_matriarch.sql
--   2026_10_29_986_20_sp_battered_chest_z.sql

-- ===== 2026_10_29_986_07_sp_sanders_noose.sql
-- ported from PR 15 2026_10_25_44_world.sql (#986)
-- Lieutenant Sanders hangs from his noose (vehicle 659) instead of standing beside it

-- The noose hangs still, as sniffed (the world dump gave it random movement)
UPDATE `creature` SET `wander_distance` = 0, `MovementType` = 0 WHERE `guid` = 192577;

DELETE FROM `npc_spellclick_spells` WHERE `npc_entry` = 38936;
INSERT INTO `npc_spellclick_spells` (`npc_entry`, `spell_id`, `cast_flags`, `user_type`) VALUES
(38936, 46598, 1, 0);

-- Sanders is a minion accessory: the accessories are installed again on the noose's first update, and a non-minion one is not
-- unsummoned when it is put off, so it was left standing beside the tree as a second Sanders
DELETE FROM `vehicle_template_accessory` WHERE `entry` = 38936;
INSERT INTO `vehicle_template_accessory` (`entry`, `accessory_entry`, `seat_id`, `minion`, `description`, `summontype`, `summontimer`) VALUES
(38936, 13158, 0, 1, 'Lieutenant Sanders'' Noose - Lieutenant Sanders', 8, 0);

-- The chain: the Noose Focus above the noose chains Sanders by the foot, to a second, also invisible Noose Focus at his foot (the
-- old standalone Sanders spawn's guid). The sniffed Sanders Foot Noose (73444) is a chain of fixed length that falls short of
-- him, so this uses a Base -> Base chain beam instead (Ongolongo - Chain Visual). Both foci hang still, as sniffed.
DELETE FROM `creature` WHERE `guid` = 192578 AND `id` IN (13158, 39093);
DELETE FROM `creature_addon` WHERE `guid` = 192578;
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `modelid`, `position_x`, `position_y`, `position_z`,
`orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`) VALUES
(192578, 39093, 0, 85, 4918, 1, 1, 11686, 2533.23, -920.179, 61.0012, 4.53786, 300, 0, 0, 42, 0, 0);
UPDATE `creature` SET `wander_distance` = 0, `MovementType` = 0 WHERE `guid` = 192579;
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 39093;
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (39093, -192579) AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `target_type`, `target_param1`, `target_param2`, `comment`) VALUES
(-192579, 0, 0, 0, 1, 0, 100, 0, 1000, 1000, 5000, 5000, 11, 79807, 34, 10, 192578, 39093, 'Lieutenant Sanders'' Noose Focus - Out of Combat - Cast ''Ongolongo - Chain Visual'' on the Noose Focus at his foot (Aura Not Present)');

-- A hanging prisoner holds no weapon
DELETE FROM `creature_equip_template` WHERE `CreatureID` = 13158;

-- ===== 2026_10_29_986_14_sp_rear_guard_quests.sql
-- ported from PR 15 2026_10_25_51_world.sql (#986)
-- Forsaken Rear Guard: Steel Thunder (27069), Lost in the Darkness (27093) and It's Only Poisonous if You Ingest It (27088) had
-- nothing behind them. Ported from TrinityCore: Admiral Hatchet lends an Orc Sea Pup on accepting Steel Thunder (or through his
-- gossip option) and takes its crates on turn-in (npc_silverpine_admiral_hatchet); a Sea Dog Crate puts an Orc Crate on the
-- player's pup and counts it (spell_silverpine_pick_up_orc_crate, npc_silverpine_orc_sea_pup, npc_silverpine_orc_crate); cutting a
-- Webbed Victim free may free an Orc Sea Dog that follows the player, or let out a foe (npc_silverpine_webbed_victim,
-- spell_silverpine_free_webbed_victim_random, npc_silverpine_orc_sea_dog); and a Mutant Bush Chicken released at a Forest Ettin is
-- eaten and explodes, weakening it (spell_silverpine_release_diseased_mutant_bush_chicken, npc_silverpine_mutant_bush_chicken,
-- npc_silverpine_forest_ettin, which also takes over Bonk and Log Smash from its SmartAI). The camp's talks come along: Hatchet
-- and Warlord Torok, Apothecary Wormcrud and the drunken sea dogs (at_silverpine_forsaken_rear_guard), and "Salty" Rocka and
-- "Salty" Gorgar.
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_admiral_hatchet' WHERE `entry` = 44916;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_apothecary_wormcrud' WHERE `entry` = 44912;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_salty_rocka' WHERE `entry` = 45498;
UPDATE `creature_template` SET `AIName` = '', `unit_flags` = 33288, `VehicleId` = 1060, `ScriptName` = 'npc_silverpine_orc_sea_pup' WHERE `entry` = 44914;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_orc_crate' WHERE `entry` = 44915;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_forest_ettin' WHERE `entry` = 44367;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_mutant_bush_chicken' WHERE `entry` = 44935;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_webbed_victim' WHERE `entry` = 44941;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_orc_sea_dog' WHERE `entry` = 44942;

DELETE FROM `smart_scripts` WHERE `entryorguid` = 44367 AND `source_type` = 0;

DELETE FROM `areatrigger_scripts` WHERE `entry` = 6222;
INSERT INTO `areatrigger_scripts` (`entry`, `ScriptName`) VALUES
(6222, 'at_silverpine_forsaken_rear_guard');

-- Hatchet's option for a new pup, while Steel Thunder is in progress
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 11901;
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`, `OptionBroadcastTextID`, `OptionType`, `OptionNpcflag`, `ActionMenuID`, `ActionPoiID`, `BoxCoded`, `BoxMoney`, `BoxText`, `BoxBroadcastTextID`, `VerifiedBuild`) VALUES
(11901, 0, 0, 'I seem to have misplaced my sea pup, admiral. Do you have another that you could lend to me?', 45023, 1, 1, 0, 0, 0, 0, NULL, 0, 0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 11901;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(15, 11901, 0, 0, 0, 9, 0, 27069, 0, 0, 0, 0, 0, '', 'Admiral Hatchet - Show sea pup option while Steel Thunder is in progress');

-- Pick Up Orc Crate on the pup; Bush Chicken Explosion! on the ettin only
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceEntry` IN (83838, 83903);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(13, 1, 83838, 0, 0, 31, 0, 3, 44914, 0, 0, 0, 0, '', 'Pick Up Orc Crate - Target Orc Sea Pup'),
(13, 5, 83903, 0, 0, 31, 0, 3, 44367, 0, 0, 0, 0, '', 'Bush Chicken Explosion! - Target Forest Ettin');

DELETE FROM `spell_script_names` WHERE `spell_id` IN (83838, 83902, 83919);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(83838, 'spell_silverpine_pick_up_orc_crate'),
(83902, 'spell_silverpine_release_diseased_mutant_bush_chicken'),
(83919, 'spell_silverpine_free_webbed_victim_random');

DELETE FROM `creature_text` WHERE `CreatureID` IN (45498, 45497, 44916, 44917, 44912, 44913, 44914, 44942);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(45498, 0, 0, 'Hey over there!  Hey!  Hey!  Over there!  How''sh everything going Gororgararar?', 14, 1, 100, 5, 0, 0, 0, 45623, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 1, 0, 'HA! Shows how much you know.  I left the critter back on the third ship!', 14, 1, 100, 5, 0, 0, 0, 45634, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 2, 0, 'Yoo hoo!  "Shmaltzy!"  Hey, why come your shupplies... Whe... Oh... Um... You got lots of boxes to keep track of...', 14, 1, 100, 5, 0, 0, 0, 45624, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 3, 0, 'I didn''t like that pet anyways.  Beshides... People stop by all the time and give me their pets.  If I lost one, it doesn''t matter, I''ve got dozens more to lose!', 14, 1, 100, 5, 0, 0, 0, 45637, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 4, 0, 'Hey over there!  Hey!  Hey!  Over there!  How''sh everything going Gororgararar?', 14, 1, 100, 5, 0, 0, 0, 45623, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 5, 0, 'My pet! Oh no!  Uh... I am shure that pet is around here somewhere...', 14, 1, 100, 5, 0, 0, 0, 45633, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 6, 0, 'Hey, "Salty" when are you going to get a new name? Thish town ain''t big ''nough for two of ussh...', 14, 1, 100, 5, 0, 0, 0, 45621, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 7, 0, 'Wait... Where is my pet?  It''s gone! No need to panic... Just need a quick drink and I can figure out where he went to.', 14, 1, 100, 5, 0, 0, 0, 45636, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 8, 0, '"Malty!"  Hey, "Malty!"  I thought you were going to get us shome more booze!  What''sh the hold up?', 14, 1, 100, 5, 0, 0, 0, 45626, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45498, 9, 0, 'I didn''t like that pet anyways.  Beshides... People stop by all the time and give me their pets.  If I lost one, it doesn''t matter, I''ve got dozens more to lose!', 14, 1, 100, 5, 0, 0, 0, 45637, 0, '"Salty" Rocka - Forsaken Rear Guard'),
(45497, 0, 0, 'Hey, shtop bothering me.  You''re a dishgrace to us all.  You can''t even hold onto your own petsh!', 14, 1, 100, 5, 0, 0, 0, 45631, 0, '"Salty" Gorgar - Forsaken Rear Guard'),
(45497, 1, 0, 'Maybe you should worry about your pet and not me!  I''m taking care of my bushinesh jusht fine!', 14, 1, 100, 5, 0, 0, 0, 45628, 0, '"Salty" Gorgar - Forsaken Rear Guard'),
(45497, 2, 0, 'Hey, shtop bothering me.  You''re a dishgrace to us all.  You can''t even hold onto your own petsh!', 14, 1, 100, 5, 0, 0, 0, 45631, 0, '"Salty" Gorgar - Forsaken Rear Guard'),
(45497, 3, 0, 'It''s "Salty!"  I got here firsht!  I got off the boat and onto land firsht!  I called the name "Salty."  Hey... Where''s your pet at?', 14, 1, 100, 5, 0, 0, 0, 45627, 0, '"Salty" Gorgar - Forsaken Rear Guard'),
(45497, 4, 0, '"Shalty."  That''s my name!  Your name should be "I can''t hold onto petsh."  I can''t believe anyone would trusht you with a beasht.', 14, 1, 100, 5, 0, 0, 0, 45629, 0, '"Salty" Gorgar - Forsaken Rear Guard'),
(44916, 0, 0, 'Who''s not drunk, Torok?', 12, 1, 100, 0, 0, 0, 0, 45018, 0, 'Admiral Hatchet - Forsaken Rear Guard'),
(44916, 1, 0, 'Yes.', 12, 1, 100, 0, 0, 0, 0, 45020, 0, 'Admiral Hatchet - Forsaken Rear Guard'),
(44917, 0, 0, 'Including me?', 12, 1, 100, 0, 0, 0, 0, 45019, 0, 'Warlord Torok - Forsaken Rear Guard'),
(44917, 1, 0, '<hic!> Well... Let''s see... By my count, nobody. The whole crew''s drunk out of their gourds, admiral... ''cept the sea pups... <hic!>', 12, 1, 100, 0, 0, 0, 0, 45021, 0, 'Warlord Torok - Forsaken Rear Guard'),
(44912, 0, 0, 'Touch my chicken and I will kill you in your sleep. Am I understood?', 12, 1, 100, 1, 0, 0, 0, 45069, 0, 'Apothecary Wormcrud - Forsaken Rear Guard'),
(44913, 0, 0, 'What''sh with the huuuuge bush chick-a-doodle?', 12, 1, 100, 1, 0, 0, 0, 45061, 0, 'Orc Sea Dog - Forsaken Rear Guard'),
(44913, 1, 0, 'It''sh makin'' me hungry... why''s it shooo big? You shome kind of idiot or shomething? Makin'' a chicken sho big... Who doesh that?', 12, 1, 100, 1, 0, 0, 0, 45062, 0, 'Orc Sea Dog - Forsaken Rear Guard'),
(44913, 2, 0, 'Forshaken do... that''sh who...It''sh sho big... Look at it''sh big shtupid neck. I jusht want to choke it to death!', 12, 1, 100, 1, 0, 0, 0, 45063, 0, 'Orc Sea Dog - Forsaken Rear Guard'),
(44914, 0, 0, 'Where to going, captain?', 12, 0, 100, 66, 0, 0, 0, 44990, 5, 'Orc Sea Pup - Steel Thunder'),
(44914, 1, 0, 'OOF! Maybe trow little softer, captain?', 12, 1, 100, 0, 0, 0, 0, 44992, 5, 'Orc Sea Pup - Steel Thunder'),
(44914, 2, 0, 'Heavy... no can see notin.', 12, 1, 100, 0, 0, 0, 0, 44993, 5, 'Orc Sea Pup - Steel Thunder'),
(44914, 3, 0, 'Captain, pup need help!', 12, 1, 100, 0, 0, 0, 0, 44996, 5, 'Orc Sea Pup - Steel Thunder'),
(44914, 4, 0, 'Please, captain, I can put box down?', 12, 1, 100, 0, 0, 0, 0, 44999, 5, 'Orc Sea Pup - Steel Thunder'),
(44914, 5, 0, 'NO MORE! DIS IS MAXI... MAXIMO... ME... DIS TOO MUCH!', 12, 1, 100, 0, 0, 0, 0, 45003, 5, 'Orc Sea Pup - Steel Thunder'),
(44914, 6, 0, 'Where to put? Dey falling! HELP!', 12, 1, 100, 0, 0, 0, 0, 45025, 5, 'Orc Sea Pup - Steel Thunder'),
(44914, 7, 0, 'OOF!', 12, 1, 100, 0, 0, 0, 0, 45024, 5, 'Orc Sea Pup - Steel Thunder'),
(44942, 0, 0, 'We gotta find the matriarch of this operation and end her!', 12, 1, 100, 5, 0, 0, 0, 45079, 5, 'Orc Sea Dog - Lost in the Darkness'),
(44942, 0, 1, 'Thank you, friend. Let''s kill us some overgrown... spiders. Sounded better in my head.', 12, 1, 100, 5, 0, 0, 0, 45078, 5, 'Orc Sea Dog - Lost in the Darkness'),
(44942, 0, 2, 'I need a drink!', 12, 1, 100, 5, 0, 0, 0, 45080, 5, 'Orc Sea Dog - Lost in the Darkness'),
(44942, 0, 3, 'Welcome to the party, $g pal:lady;!', 12, 1, 100, 5, 0, 0, 0, 45077, 5, 'Orc Sea Dog - Lost in the Darkness');

-- ===== 2026_10_29_986_15_sp_rise_forsaken_no_escape.sql
-- ported from PR 15 2026_10_25_52_world.sql (#986)
-- Rise, Forsaken (27097) and No Escape (27099): nothing summoned Agatha, raised the Hillsbrad Refugees for the Forsaken raised
-- credit or played the meeting in Fenris Keep that gives the Human Leaders found credit. Ported from TrinityCore: Sylvanas and
-- Bond of the Val'kyr give the player Agatha until No Escape is turned in, she raises the refugees the player kills and, on No
-- Escape, leads the player into the meeting (areatrigger 6230), played by the Fenris Keep Camera, then flies them back.

-- Lady Sylvanas Windrunner gives and dismisses Agatha
UPDATE `creature_template` SET `ScriptName` = 'npc_silverpine_sylvanas_windrunner_high_command' WHERE `entry` = 44365;

-- Bond of the Val'kyr, from Rise, Forsaken until No Escape is turned in
DELETE FROM `spell_script_names` WHERE `spell_id` = 83979;
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(83979, 'spell_silverpine_bond_of_the_valkyr');

DELETE FROM `spell_area` WHERE `spell` = 83979;
INSERT INTO `spell_area` (`spell`, `area`, `quest_start`, `quest_end`, `aura_spell`, `racemask`, `gender`, `autocast`, `quest_start_status`, `quest_end_status`) VALUES
(83979, 130, 27097, 27099, 0, 0, 2, 1, 74, 11);

-- Agatha Broadcast reaches only Agatha
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceEntry` = 83978;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(13, 1, 83978, 0, 0, 31, 0, 3, 44951, 0, 0, 0, 0, '', 'Agatha Broadcast - Target Agatha');

-- Agatha: the player's guardian; the sniffed copy goes, since Summon Agatha brings her
UPDATE `creature_template` SET `unit_class` = 2, `HoverHeight` = 2.2, `AIName` = '', `ScriptName` = 'npc_silverpine_agatha_fenris_isle' WHERE `entry` = 44951;

DELETE FROM `creature_template_addon` WHERE `entry` = 44951;
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `MountCreatureID`, `StandState`, `AnimTier`, `VisFlags`, `SheathState`, `PvPFlags`, `emote`, `aiAnimKit`, `movementAnimKit`, `meleeAnimKit`, `visibilityDistanceType`, `auras`) VALUES
(44951, 0, 0, 0, 0, 3, 0, 1, 0, 0, 0, 0, 0, 3, '85451');

DELETE FROM `creature` WHERE `guid` = 375615;
DELETE FROM `creature_addon` WHERE `guid` = 375615;

DELETE FROM `creature_text` WHERE `CreatureID` = 44951;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(44951, 0, 0, 'Death is only the beginning.', 12, 0, 100, 0, 0, 0, 0, 45090, 5, 'Agatha - Broadcast'),
(44951, 0, 1, 'Different master, same insatiable thirst for power.', 12, 0, 100, 0, 0, 0, 0, 45093, 5, 'Agatha - Broadcast'),
(44951, 0, 2, 'Do you feel it, $n? The darkness surrounds us.', 12, 0, 100, 0, 0, 0, 0, 45097, 5, 'Agatha - Broadcast'),
(44951, 0, 3, 'I long for the frozen wastes of Northrend.', 12, 0, 100, 0, 0, 0, 0, 45096, 5, 'Agatha - Broadcast'),
(44951, 0, 4, 'I sense doom in your future, $n.', 12, 0, 100, 0, 0, 0, 0, 45094, 5, 'Agatha - Broadcast'),
(44951, 0, 5, 'Life is meaningless. It is in the afterlife that we are truly tested.', 12, 0, 100, 0, 0, 0, 0, 45098, 5, 'Agatha - Broadcast'),
(44951, 0, 6, 'The warmth of this place sickens me.', 12, 0, 100, 0, 0, 0, 0, 45095, 5, 'Agatha - Broadcast'),
(44951, 0, 7, 'Through me the Banshee Queen sees all...', 12, 0, 100, 0, 0, 0, 0, 45099, 5, 'Agatha - Broadcast'),
(44951, 0, 8, 'Waste no time, $n. We mustn''t keep the Banshee Queen waiting.', 12, 0, 100, 0, 0, 0, 0, 45092, 5, 'Agatha - Broadcast'),
(44951, 1, 0, 'Bow before your new master!', 14, 0, 100, 0, 0, 0, 0, 45114, 5, 'Agatha - Rise, Forsaken'),
(44951, 1, 1, 'Rise and destroy our enemies!', 14, 0, 100, 0, 0, 0, 0, 45115, 5, 'Agatha - Rise, Forsaken'),
(44951, 1, 2, 'Rise, $n! Become Forsaken!', 14, 0, 100, 0, 0, 0, 0, 45091, 5, 'Agatha - Rise, Forsaken'),
(44951, 2, 0, 'This way, $n. We will take them by surprise.', 12, 0, 100, 1, 0, 0, 0, 45193, 5, 'Agatha - No Escape'),
(44951, 3, 0, 'Run...', 12, 0, 100, 457, 0, 0, 0, 45184, 5, 'Agatha - No Escape'),
(44951, 4, 0, 'RUN!', 12, 0, 100, 457, 0, 0, 0, 45185, 5, 'Agatha - No Escape');

-- Agatha flies the player from Fenris Keep back to Forsaken High Command
DELETE FROM `waypoint_data` WHERE `id` = 449510;
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `move_flag`, `action`, `action_chance`, `wpguid`) VALUES
(449510, 0, 978.75, 682.571, 74.9817, 0, 0, 1, 0, 100, 0),
(449510, 1, 979.691, 672.536, 74.9817, 0, 0, 1, 0, 100, 0),
(449510, 2, 984.573, 670.793, 75.4262, 0, 0, 1, 0, 100, 0),
(449510, 3, 997.752, 671.819, 69.7039, 0, 0, 1, 0, 100, 0),
(449510, 4, 998.248, 683.655, 70.2039, 0, 0, 1, 0, 100, 0),
(449510, 5, 1012.42, 684.455, 65.1761, 0, 0, 1, 0, 100, 0),
(449510, 6, 1011.69, 695.212, 60.9817, 0, 0, 1, 0, 100, 0),
(449510, 7, 996.165, 694.927, 60.9817, 0, 0, 1, 0, 100, 0),
(449510, 8, 995.677, 709.804, 60.9817, 0, 0, 1, 0, 100, 0),
(449510, 9, 982.948, 711.526, 60.9817, 0, 0, 1, 0, 100, 0),
(449510, 10, 983.938, 689.569, 60.2873, 0, 0, 1, 0, 100, 0),
(449510, 11, 961.075, 688.958, 60.2873, 0, 0, 1, 0, 100, 0),
(449510, 12, 933.366, 687.901, 70.0651, 0, 0, 1, 0, 100, 0),
(449510, 13, 871.441, 700.913, 91.8428, 0, 1200, 1, 0, 100, 0),
(449510, 14, 843.257, 730.168, 99.0837, 0, 0, 1, 0, 100, 0),
(449510, 15, 891.191, 859.995, 99.0837, 0, 0, 1, 0, 100, 0),
(449510, 16, 1167.72, 992.175, 99.0837, 0, 0, 1, 0, 100, 0),
(449510, 17, 1343, 1029.57, 62.7226, 0, 0, 1, 0, 100, 0),
(449510, 18, 1367.74, 1034.35, 54.1671, 0, 0, 1, 0, 100, 0);

-- Hillsbrad Refugees are raised by Agatha when the player kills them
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_hillsbrad_refugee' WHERE `entry` IN (44954, 44966);
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (44954, 44966) AND `source_type` = 0;

DELETE FROM `spell_script_names` WHERE `spell_id` = 83997;
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(83997, 'spell_silverpine_forsaken_trooper_masterscript_fenris_isle');

-- Forsaken Troopers (raised refugees)
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_forsaken_trooper_fenris_isle' WHERE `entry` BETWEEN 44958 AND 44965;

-- The spawned troopers are raised refugees caught by the sniffer (they stand on refugee spawn points, and the template is immune to
-- all, as a raised one is): they only exist for a few seconds after Agatha raises a refugee
DELETE FROM `creature` WHERE `guid` IN (307389, 307390, 307391, 307392, 307393, 307394, 307395, 307398, 307399, 307400, 307402, 307404,
307405, 307406, 307407, 312154, 312155, 312156, 312157, 312158, 312159) AND `id` BETWEEN 44958 AND 44965;

DELETE FROM `creature_text` WHERE `CreatureID` BETWEEN 44958 AND 44965;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(44958, 0, 0, 'I am Forsaken.', 12, 0, 100, 16, 0, 0, 0, 45106, 0, 'Forsaken Trooper - Raised'),
(44958, 0, 1, 'For the glory of the Dark Lady!', 12, 0, 100, 16, 0, 0, 0, 45107, 0, 'Forsaken Trooper - Raised'),
(44958, 0, 2, 'Wha... What has happened?', 12, 0, 100, 16, 0, 0, 0, 45108, 0, 'Forsaken Trooper - Raised'),
(44958, 0, 3, 'I am eternal... I am death.', 12, 0, 100, 16, 0, 0, 0, 45109, 0, 'Forsaken Trooper - Raised'),
(44958, 0, 4, 'I LIVE!', 12, 0, 100, 16, 0, 0, 0, 45111, 0, 'Forsaken Trooper - Raised'),
(44959, 0, 0, 'I am Forsaken.', 12, 0, 100, 16, 0, 0, 0, 45106, 0, 'Forsaken Trooper - Raised'),
(44959, 0, 1, 'For the glory of the Dark Lady!', 12, 0, 100, 16, 0, 0, 0, 45107, 0, 'Forsaken Trooper - Raised'),
(44959, 0, 2, 'Wha... What has happened?', 12, 0, 100, 16, 0, 0, 0, 45108, 0, 'Forsaken Trooper - Raised'),
(44959, 0, 3, 'I am eternal... I am death.', 12, 0, 100, 16, 0, 0, 0, 45109, 0, 'Forsaken Trooper - Raised'),
(44959, 0, 4, 'I LIVE!', 12, 0, 100, 16, 0, 0, 0, 45111, 0, 'Forsaken Trooper - Raised'),
(44960, 0, 0, 'I am Forsaken.', 12, 0, 100, 16, 0, 0, 0, 45106, 0, 'Forsaken Trooper - Raised'),
(44960, 0, 1, 'For the glory of the Dark Lady!', 12, 0, 100, 16, 0, 0, 0, 45107, 0, 'Forsaken Trooper - Raised'),
(44960, 0, 2, 'Wha... What has happened?', 12, 0, 100, 16, 0, 0, 0, 45108, 0, 'Forsaken Trooper - Raised'),
(44960, 0, 3, 'I am eternal... I am death.', 12, 0, 100, 16, 0, 0, 0, 45109, 0, 'Forsaken Trooper - Raised'),
(44960, 0, 4, 'I LIVE!', 12, 0, 100, 16, 0, 0, 0, 45111, 0, 'Forsaken Trooper - Raised'),
(44961, 0, 0, 'I am Forsaken.', 12, 0, 100, 16, 0, 0, 0, 45106, 0, 'Forsaken Trooper - Raised'),
(44961, 0, 1, 'For the glory of the Dark Lady!', 12, 0, 100, 16, 0, 0, 0, 45107, 0, 'Forsaken Trooper - Raised'),
(44961, 0, 2, 'Wha... What has happened?', 12, 0, 100, 16, 0, 0, 0, 45108, 0, 'Forsaken Trooper - Raised'),
(44961, 0, 3, 'I am eternal... I am death.', 12, 0, 100, 16, 0, 0, 0, 45109, 0, 'Forsaken Trooper - Raised'),
(44961, 0, 4, 'I LIVE!', 12, 0, 100, 16, 0, 0, 0, 45111, 0, 'Forsaken Trooper - Raised'),
(44962, 0, 0, 'I am Forsaken.', 12, 0, 100, 16, 0, 0, 0, 45106, 0, 'Forsaken Trooper - Raised'),
(44962, 0, 1, 'For the glory of the Dark Lady!', 12, 0, 100, 16, 0, 0, 0, 45107, 0, 'Forsaken Trooper - Raised'),
(44962, 0, 2, 'Wha... What has happened?', 12, 0, 100, 16, 0, 0, 0, 45108, 0, 'Forsaken Trooper - Raised'),
(44962, 0, 3, 'I am eternal... I am death.', 12, 0, 100, 16, 0, 0, 0, 45109, 0, 'Forsaken Trooper - Raised'),
(44962, 0, 4, 'I LIVE!', 12, 0, 100, 16, 0, 0, 0, 45111, 0, 'Forsaken Trooper - Raised'),
(44963, 0, 0, 'I am Forsaken.', 12, 0, 100, 16, 0, 0, 0, 45106, 0, 'Forsaken Trooper - Raised'),
(44963, 0, 1, 'For the glory of the Dark Lady!', 12, 0, 100, 16, 0, 0, 0, 45107, 0, 'Forsaken Trooper - Raised'),
(44963, 0, 2, 'Wha... What has happened?', 12, 0, 100, 16, 0, 0, 0, 45108, 0, 'Forsaken Trooper - Raised'),
(44963, 0, 3, 'I am eternal... I am death.', 12, 0, 100, 16, 0, 0, 0, 45109, 0, 'Forsaken Trooper - Raised'),
(44963, 0, 4, 'I LIVE!', 12, 0, 100, 16, 0, 0, 0, 45111, 0, 'Forsaken Trooper - Raised'),
(44964, 0, 0, 'I am Forsaken.', 12, 0, 100, 16, 0, 0, 0, 45106, 0, 'Forsaken Trooper - Raised'),
(44964, 0, 1, 'For the glory of the Dark Lady!', 12, 0, 100, 16, 0, 0, 0, 45107, 0, 'Forsaken Trooper - Raised'),
(44964, 0, 2, 'Wha... What has happened?', 12, 0, 100, 16, 0, 0, 0, 45108, 0, 'Forsaken Trooper - Raised'),
(44964, 0, 3, 'I am eternal... I am death.', 12, 0, 100, 16, 0, 0, 0, 45109, 0, 'Forsaken Trooper - Raised'),
(44964, 0, 4, 'I LIVE!', 12, 0, 100, 16, 0, 0, 0, 45111, 0, 'Forsaken Trooper - Raised'),
(44965, 0, 0, 'I am Forsaken.', 12, 0, 100, 16, 0, 0, 0, 45106, 0, 'Forsaken Trooper - Raised'),
(44965, 0, 1, 'For the glory of the Dark Lady!', 12, 0, 100, 16, 0, 0, 0, 45107, 0, 'Forsaken Trooper - Raised'),
(44965, 0, 2, 'Wha... What has happened?', 12, 0, 100, 16, 0, 0, 0, 45108, 0, 'Forsaken Trooper - Raised'),
(44965, 0, 3, 'I am eternal... I am death.', 12, 0, 100, 16, 0, 0, 0, 45109, 0, 'Forsaken Trooper - Raised'),
(44965, 0, 4, 'I LIVE!', 12, 0, 100, 16, 0, 0, 0, 45111, 0, 'Forsaken Trooper - Raised');

-- Worgen Sentry
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_worgen_sentry' WHERE `entry` = 44987;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 44987 AND `source_type` = 0;

DELETE FROM `creature_text` WHERE `CreatureID` = 44987;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(44987, 0, 0, 'Hurry, my lord! The enemy is upon us!', 14, 0, 100, 0, 0, 0, 0, 45128, 0, 'Worgen Sentry - Death'),
(44987, 0, 1, 'They come!', 14, 0, 100, 0, 0, 0, 0, 45127, 0, 'Worgen Sentry - Death');

-- No Escape starts on entering Fenris Keep with Agatha
DELETE FROM `areatrigger_scripts` WHERE `entry` = 6230;
INSERT INTO `areatrigger_scripts` (`entry`, `ScriptName`) VALUES
(6230, 'at_silverpine_no_escape');

-- The Fenris Keep Camera plays the meeting; its actors
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_fenris_keep_camera' WHERE `entry` = 45003;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_fenris_keep_actor' WHERE `entry` IN (44989, 44990, 44993, 44994, 44995, 44996, 44997, 45002);

DELETE FROM `creature_text` WHERE `CreatureID` IN (44989, 44996);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(44989, 0, 0, 'The Forsaken have broken through your defenses, magistrate.', 12, 0, 100, 396, 0, 0, 0, 45161, 0, 'Lord Darius Crowley - No Escape'),
(44989, 1, 0, 'You are out of time.', 12, 0, 100, 274, 0, 0, 0, 45162, 0, 'Lord Darius Crowley - No Escape'),
(44989, 2, 0, 'A decision must be made!', 12, 0, 100, 5, 0, 0, 0, 45163, 0, 'Lord Darius Crowley - No Escape'),
(44989, 3, 0, 'Die in battle and be raised as a servant of the Forsaken or...', 12, 0, 100, 396, 0, 0, 0, 45164, 0, 'Lord Darius Crowley - No Escape'),
(44989, 4, 0, 'Drink in my blood and be reborn as worgen, immune to the depravity of the Forsaken.', 12, 0, 100, 5, 0, 0, 0, 45165, 0, 'Lord Darius Crowley - No Escape'),
(44989, 5, 0, 'Help us destroy the Forsaken and retake Lordaeron for the Alliance!', 12, 0, 100, 5, 0, 0, 0, 45166, 0, 'Lord Darius Crowley - No Escape'),
(44996, 0, 0, 'We would rather die than be turned into worgen, but seeing as how even death provides no relief from the atrocities of this war...', 12, 0, 100, 1, 0, 0, 0, 45167, 0, 'Magistrate Henry Maleb - No Escape'),
(44996, 1, 0, 'We choose vengeance!', 12, 0, 100, 5, 0, 0, 0, 45168, 0, 'Magistrate Henry Maleb - No Escape');

-- ===== 2026_10_29_986_16_sp_lordaeron.sql
-- ported from PR 15 2026_10_25_53_world.sql (#986)
-- Lordaeron (27098): accepting it summoned no one, so Lady Sylvanas Windrunner was never accompanied to the Sepulcher and the
-- quest could not be completed. Sylvanas at Forsaken High Command now casts Summon Sylvanas + Horse on accept (or when talked to
-- while the quest is in progress): the player rides the Forsaken Warhorse beside Sylvanas to the Sepulcher while she tells the
-- story of the Forsaken, and is credited on arrival.
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_sylvanas_windrunner_lordaeron' WHERE `entry` = 45051;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_forsaken_warhorse_lordaeron' WHERE `entry` = 45057;

-- Sylvanas rides her own horse, as at Forsaken High Command
DELETE FROM `creature_template_addon` WHERE `entry` = 45051;
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `MountCreatureID`, `StandState`, `AnimTier`, `VisFlags`, `SheathState`, `PvPFlags`, `emote`, `aiAnimKit`, `movementAnimKit`, `meleeAnimKit`, `visibilityDistanceType`, `auras`) VALUES
(45051, 0, 29257, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 3, NULL);

DELETE FROM `creature_text` WHERE `CreatureID` = 45051;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(45051, 0, 0, 'I have not always been the Banshee Queen, $n.', 12, 0, 100, 0, 0, 20470, 0, 45201, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 1, 0, 'And my people have not always been the Forsaken.', 12, 0, 100, 0, 0, 20471, 0, 45202, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 2, 0, 'Long ago this land comprised the northern kingdoms of Lordaeron, ruled by King Terenas Menethil.', 12, 0, 100, 0, 0, 20472, 0, 45203, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 3, 0, 'Terenas had a son named Arthas.', 12, 0, 100, 0, 0, 20473, 0, 45204, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 4, 0, 'Arthas... even saying his name makes my body quiver in rage.', 12, 0, 100, 0, 0, 20474, 0, 45205, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 5, 0, 'This man-child, Arthas, took for himself a cursed blade known as Frostmourne.', 12, 0, 100, 0, 0, 20475, 0, 45206, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 6, 0, 'Through Frostmourne, Arthas killed his own father and razed this land along with every living creature in it!', 12, 0, 100, 0, 0, 20476, 0, 45207, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 7, 0, 'My own death came at the hands of Arthas when he and his armies sacked my homeland, Quel''Thalas, and murdered my people.', 12, 0, 100, 0, 0, 20477, 0, 45208, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 8, 0, 'In his vast cruelty, Arthas severed my spirit from my body and raised me as a banshee to serve in his Scourge army.', 12, 0, 100, 0, 0, 20478, 0, 45209, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 9, 0, 'A similar fate befell all that would die to the Scourge war machine.', 12, 0, 100, 0, 0, 20479, 0, 45210, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 10, 0, 'In death, they were reborn as mindless undead.', 12, 0, 100, 0, 0, 20480, 0, 45217, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 11, 0, 'But Arthas was not invincible! With each passing day his power waned - his grip over the will of the damned loosening.', 12, 0, 100, 0, 0, 20481, 0, 45218, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 12, 0, 'It was when Arthas was at his weakest that I struck!', 12, 0, 100, 0, 0, 20482, 0, 45219, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 13, 0, 'And though the hour of his atonement had come, the worm managed to escape his fate, returning to the frozen wastes of Northrend.', 12, 0, 100, 0, 0, 20483, 0, 45220, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 14, 0, 'With Arthas gone, so too was the control he held over the undead masses of Lordaeron. After recovering my body, I freed the remaining Scourge that were left behind.', 12, 0, 100, 0, 0, 20484, 0, 45221, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 15, 0, 'From the cruelty and mercilessness of Arthas, the man who would be the Lich King, the Forsaken were born.', 12, 0, 100, 0, 0, 20485, 0, 45222, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 16, 0, 'Our goal... Our sole purpose was to destroy the Lich King. We threw our lot in with the Horde and began our journey towards redemption.', 12, 0, 100, 0, 0, 20486, 0, 45223, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 17, 0, 'Now the Lich King is dead and we have returned.', 12, 0, 100, 0, 0, 20487, 0, 45224, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 18, 0, 'The people who called this land their home in life, do so in death as well.', 12, 0, 100, 0, 0, 20488, 0, 45225, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 19, 0, 'But the Alliance does not recognize our rights. They claim this land is their own while attempting to invalidate the claims of the founders of this kingdom.', 12, 0, 100, 0, 0, 20489, 0, 45226, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 20, 0, 'I will never allow it... Never!', 12, 0, 100, 0, 0, 20490, 0, 45227, 5, 'Lady Sylvanas Windrunner - Lordaeron'),
(45051, 21, 0, 'Lordaeron belongs to the Forsaken - always and forever.', 12, 0, 100, 0, 0, 20491, 0, 45228, 5, 'Lady Sylvanas Windrunner - Lordaeron');

-- ===== 2026_10_29_986_17_sp_nowhere_to_run.sql
-- ported from PR 15 2026_10_25_54_world.sql (#986)
-- Nowhere to Run (27195): it has no objective here, so it was complete on accept and Master Forteski never went into the Deep Elem
-- Mine. It now needs its quest event: accepting it from Forteski (or talking to him while it is in progress) has him lead his
-- Veteran Forsaken Troopers into the mine, where Packleader Ivar Bloodfang springs the trap; Forteski's last words give the event
-- before the bomb kills him and his troopers, who return shortly. Bloodfang and the bomb are summoned for the scene, so their
-- sniffed spawns go.
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_master_forteski' WHERE `entry` = 45228;

INSERT IGNORE INTO `quest_template_addon` (`ID`) VALUES (27195);
UPDATE `quest_template_addon` SET `SpecialFlags` = 2 WHERE `ID` = 27195;

DELETE FROM `creature` WHERE `guid` IN (307413, 307414);
DELETE FROM `creature_addon` WHERE `guid` IN (307413, 307414);

DELETE FROM `creature_text` WHERE `CreatureID` IN (45228, 45236);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(45228, 0, 0, 'Ready then? Let''s get a move on! Try and keep up, $n.', 12, 0, 100, 0, 0, 0, 0, 45386, 0, 'Master Forteski - Nowhere to Run'),
(45228, 1, 0, 'Onward, brothers and sisters!', 12, 0, 100, 0, 0, 0, 0, 45387, 0, 'Master Forteski - Nowhere to Run'),
(45228, 2, 0, 'What''s this then?', 12, 0, 100, 0, 0, 0, 0, 45388, 0, 'Master Forteski - Nowhere to Run'),
(45228, 3, 0, 'BOMB! IT''S A TRAP! RUN!', 14, 0, 100, 0, 0, 0, 0, 45391, 0, 'Master Forteski - Nowhere to Run'),
(45228, 4, 0, 'Remember this day as the day that Forteski saved your hide. Now run! Get back to Sylvanas!', 12, 0, 100, 0, 0, 0, 0, 45394, 0, 'Master Forteski - Nowhere to Run'),
(45236, 0, 0, 'Your doom!', 12, 0, 100, 0, 0, 0, 0, 45389, 0, 'Packleader Ivar Bloodfang - Nowhere to Run');

-- Explosion throws Forteski, his troopers and the players with them (Forteski's warning saves them: the blast only throws them
-- back up the tunnel) and sets off the bomb wagons
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceEntry` = 84474;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(13, 1, 84474, 0, 0, 31, 0, 3, 45228, 0, 0, 0, 0, '', 'Explosion - Target Master Forteski'),
(13, 1, 84474, 0, 1, 31, 0, 3, 45225, 0, 0, 0, 0, '', 'Explosion - Target Veteran Forsaken Trooper'),
(13, 1, 84474, 0, 2, 31, 0, 4, 0, 0, 0, 0, 0, '', 'Explosion - Target Player'),
(13, 2, 84474, 0, 0, 31, 0, 5, 205271, 0, 0, 0, 0, '', 'Explosion - Target Bomb Wagon');

-- ===== 2026_10_29_986_18_sp_wagons.sql
-- ported from PR 15 2026_10_25_55_world.sql (#986)
-- Silverpine Forest wagons. The sniffed spawns are snapshots of two wagon lines on the main road, and every wagon stood still (or ran a
-- few sniffed yards back and forth) while its Ettin, driver and troopers stood or wandered beside it. Per the sniffs, the Ettin
-- (seat 1, 6.7 yards ahead of the wagon), the Horde Engineer driver (seat 0), the troopers and the coffins all ride the wagon with
-- Ride Vehicle Hardcoded, so they now ride it as accessories. As on retail (Wowpedia):
-- * The Horde Hauler (44731) waits for passengers at the Tirisfal border, carries Forsaken Troopers south, stops at Forsaken High
--   Command and at the crossroads in front of the Sepulcher, puts its riders off at the Forsaken Front and despawns a little further
--   down the road.
-- * The Horde Coffin Hauler (44764) carries coffins from the Forsaken Front north into Tirisfal without stopping and despawns there,
--   putting its riders off.
-- An invisible bunny at the start of each line sends a wagon off every minute. The route is pieced together from all snapshots,
-- and the wagons keep their sniffed run speed. Creatures board with Ride Vehicle Hardcoded and players with Ride Horde Hauler, so
-- removing the players' aura at the Forsaken Front leaves the Ettin, driver and troopers aboard.
-- The once-only "Out of Combat" events are flagged not repeatable: without the flag this core fires an event with no repeat timer on
-- every update, and the wagon restarted its path from the first point several times a second. They are also flagged not to reset:
-- the threat of a mob that attacks a rider goes to the wagon, and when that fight ended the wagon's evade reset the event, which
-- started the path again from the Tirisfal border. The wagons are passive and do not evade, so they drive on through a fight
-- instead of chasing the mob and then returning to their last stop.
-- A despawning SmartAI creature turns invisible and leaves 5 seconds later, and a vehicle's accessories stay behind for 2 more
-- seconds when it goes, so the Ettin, driver, troopers and coffins stood on the road without their wagon. At its last point each
-- wagon tells its accessories to despawn and despawns with them, so they all vanish together.
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` IN (44731, 44734, 44764);
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` IN (44732, 44733, 44737, 44766, 46559, 46560);
UPDATE `creature_template` SET `speed_run` = 2 WHERE `entry` = 44764;
-- Players click the Horde Hauler to ride it, so it must be selectable (its template had UNIT_FLAG_NOT_SELECTABLE)
UPDATE `creature_template` SET `unit_flags` = 768 WHERE `entry` = 44731;

-- The snapshots go: wagons, Ettins, drivers, troopers and coffin stacks
DELETE FROM `creature_addon` WHERE `guid` IN (SELECT `guid` FROM `creature` WHERE `id` IN (44731, 44732, 44733, 44734, 44737, 44764,
44766, 46559, 46560));
DELETE FROM `creature` WHERE `id` IN (44731, 44732, 44733, 44734, 44737, 44764, 44766, 46559, 46560);
DELETE FROM `waypoint_data` WHERE `id` IN (187571, 187581, 187590, 187599, 187636, 187643, 188102);
DELETE FROM `vehicle_accessory` WHERE `guid` IN (188034, 188199);

-- Wagon spawners (General Purpose Bunny JMF): the Horde Hauler's at the Tirisfal border, the Coffin Hauler's at the Forsaken Front
DELETE FROM `creature_addon` WHERE `guid` IN (188034, 188199);
DELETE FROM `creature` WHERE `guid` IN (188034, 188199);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `modelid`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `MovementType`) VALUES
(188034, 45979, 0, 85, 85, 1, 1, 11686, 1542.8, 583.1, 45.0, 2.42, 120, 0, 0),
(188199, 45979, 0, 130, 5387, 1, 1, 11686, -151.7, 1236.8, 52.4, 6.0, 120, 0, 0);

DELETE FROM `vehicle_template_accessory` WHERE `entry` IN (44731, 44764);
INSERT INTO `vehicle_template_accessory` (`entry`, `accessory_entry`, `seat_id`, `minion`, `description`, `summontype`, `summontimer`) VALUES
(44731, 44734, 0, 1, 'Horde Hauler - Horde Engineer', 8, 0),
(44731, 44737, 1, 1, 'Horde Hauler - Subdued Forest Ettin', 8, 0),
(44731, 44733, 3, 1, 'Horde Hauler - Forsaken Trooper', 8, 0),
(44731, 44733, 4, 1, 'Horde Hauler - Forsaken Trooper', 8, 0),
(44731, 44733, 5, 1, 'Horde Hauler - Forsaken Trooper', 8, 0),
(44731, 44732, 6, 1, 'Horde Hauler - Forsaken Trooper', 8, 0),
(44731, 44732, 7, 1, 'Horde Hauler - Forsaken Trooper', 8, 0),
(44764, 46559, 0, 1, 'Horde Coffin Hauler - Horde Engineer', 8, 0),
(44764, 46560, 1, 1, 'Horde Coffin Hauler - Subdued Forest Ettin', 8, 0),
(44764, 44766, 3, 1, 'Horde Coffin Hauler - Coffins', 8, 0),
(44764, 44766, 4, 1, 'Horde Coffin Hauler - Coffins', 8, 0),
(44764, 44766, 5, 1, 'Horde Coffin Hauler - Coffins', 8, 0);

-- Players ride with Ride Horde Hauler, the accessories with Ride Vehicle Hardcoded
DELETE FROM `npc_spellclick_spells` WHERE `npc_entry` IN (44731, 44764);
INSERT INTO `npc_spellclick_spells` (`npc_entry`, `spell_id`, `cast_flags`, `user_type`) VALUES
(44731, 86807, 1, 0),
(44731, 46598, 1, 0),
(44764, 86807, 1, 0),
(44764, 46598, 1, 0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 18 AND `SourceGroup` IN (44731, 44764);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 22 AND `SourceEntry` = 44731 AND `SourceId` = 0;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(18, 44731, 86807, 0, 0, 31, 0, 4, 0, 0, 0, 0, 0, '', 'Horde Hauler - Ride Horde Hauler only for players'),
(18, 44731, 46598, 0, 0, 31, 0, 3, 0, 0, 0, 0, 0, '', 'Horde Hauler - Ride Vehicle Hardcoded only for creatures'),
(18, 44764, 86807, 0, 0, 31, 0, 4, 0, 0, 0, 0, 0, '', 'Horde Coffin Hauler - Ride Horde Hauler only for players'),
(18, 44764, 46598, 0, 0, 31, 0, 3, 0, 0, 0, 0, 0, '', 'Horde Coffin Hauler - Ride Vehicle Hardcoded only for creatures'),
(22, 11, 44731, 0, 0, 31, 0, 4, 0, 0, 0, 0, 0, '', 'Horde Hauler - Passenger Boarded - Only for players');

DELETE FROM `creature_text` WHERE `CreatureID` = 44734;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(44734, 0, 0, 'ALL ABOARD! Next stop: The Sepulcher.', 14, 1, 100, 0, 0, 0, 0, 44796, 0, 'Horde Engineer - Forsaken High Command'),
(44734, 1, 0, 'ALL ABOARD! Last stop: The Forsaken Front!', 14, 1, 100, 0, 0, 0, 0, 44797, 0, 'Horde Engineer - The Sepulcher'),
(44734, 2, 0, 'Final stop, the Forsaken Front! EVERYBODY OUT!', 12, 1, 100, 0, 0, 0, 0, 44788, 0, 'Horde Engineer - The Forsaken Front'),
(44734, 3, 0, 'This is a one way trip, kid, and you definitely don''t want to be comin'' back on the other wagon.', 12, 1, 100, 0, 0, 0, 0, 44790, 0, 'Horde Engineer - Player boards');

DELETE FROM `waypoints` WHERE `entry` IN (4473100, 4476400, 4476401);
INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES
(4473100, 1, 1500.1, 620.6, 47.4, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 2, 1459.9, 647.9, 47.4, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 3, 1415.5, 710.0, 47.2, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 4, 1384.8, 784.0, 47.1, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 5, 1356.3, 860.5, 52.1, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 6, 1341.7, 936.3, 54.7, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 7, 1337.6, 959.3, 54.6, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 8, 1332.6, 998.1, 54.7, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 9, 1237.0, 1115.0, 52.3, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 10, 1215.2, 1141.0, 50.5, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 11, 1193.2, 1156.8, 49.3, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 12, 1179.0, 1166.9, 49.0, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 13, 1162.9, 1176.9, 48.5, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 14, 1143.1, 1189.0, 48.0, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 15, 1098.9, 1207.3, 47.9, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 16, 1066.3, 1241.4, 46.3, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 17, 1053.2, 1254.0, 46.2, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 18, 1042.0, 1274.3, 46.6, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 19, 1001.4, 1292.8, 47.5, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 20, 959.2, 1319.8, 47.7, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 21, 914.7, 1350.7, 48.2, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 22, 880.6, 1358.5, 52.1, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 23, 861.4, 1359.9, 55.1, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 24, 840.6, 1360.7, 55.7, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 25, 793.0, 1361.0, 62.9, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 26, 722.8, 1353.6, 75.1, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 27, 677.7, 1319.8, 80.4, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 28, 668.6, 1314.2, 81.5, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 29, 657.5, 1307.4, 83.3, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 30, 646.8, 1303.2, 84.9, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 31, 633.5, 1298.2, 86.2, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 32, 446.5, 1226.6, 87.9, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 33, 406.4, 1233.8, 83.7, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 34, 384.7, 1235.9, 82.4, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 35, 362.5, 1240.6, 81.7, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 36, 354.0, 1242.6, 81.5, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 37, 293.0, 1259.0, 79.6, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 38, 241.5, 1270.5, 77.2, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 39, 203.1, 1259.1, 73.3, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 40, 188.0, 1259.0, 72.8, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 41, 177.6, 1256.2, 71.8, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 42, 165.1, 1252.8, 71.0, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 43, 149.7, 1248.0, 70.9, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 44, 129.4, 1241.8, 70.8, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 45, 42.9, 1212.0, 65.8, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 46, 1.9, 1199.6, 64.7, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 47, -113.5, 1214.2, 58.5, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4473100, 48, -187.4, 1210.9, 56.1, NULL, 0, 'Horde Hauler - Tirisfal to the Forsaken Front'),
(4476400, 1, -101.4, 1217.5, 58.3, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 2, 1.9, 1199.6, 64.7, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 3, 42.9, 1212.0, 65.8, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 4, 129.4, 1241.8, 70.8, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 5, 149.7, 1248.0, 70.9, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 6, 165.1, 1252.8, 71.0, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 7, 177.6, 1256.2, 71.8, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 8, 188.0, 1259.0, 72.8, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 9, 203.1, 1259.1, 73.3, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 10, 241.5, 1270.5, 77.2, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 11, 293.0, 1259.0, 79.6, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 12, 354.0, 1242.6, 81.5, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 13, 362.5, 1240.6, 81.7, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 14, 384.7, 1235.9, 82.4, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 15, 406.4, 1233.8, 83.7, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 16, 446.5, 1226.6, 87.9, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 17, 633.5, 1298.2, 86.2, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 18, 646.8, 1303.2, 84.9, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 19, 657.5, 1307.4, 83.3, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 20, 668.6, 1314.2, 81.5, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 21, 677.7, 1319.8, 80.4, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 22, 722.8, 1353.6, 75.1, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 23, 793.0, 1361.0, 62.9, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 24, 840.6, 1360.7, 55.7, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 25, 861.4, 1359.9, 55.1, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 26, 880.6, 1358.5, 52.1, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 27, 914.7, 1350.7, 48.2, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 28, 959.2, 1319.8, 47.7, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 29, 1001.4, 1292.8, 47.5, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 30, 1042.0, 1274.3, 46.6, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 31, 1053.2, 1254.0, 46.2, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 32, 1066.3, 1241.4, 46.3, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 33, 1098.9, 1207.3, 47.9, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 34, 1143.1, 1189.0, 48.0, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 35, 1162.9, 1176.9, 48.5, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 36, 1179.0, 1166.9, 49.0, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 37, 1193.2, 1156.8, 49.3, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 38, 1215.2, 1141.0, 50.5, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 39, 1237.0, 1115.0, 52.3, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 40, 1332.6, 998.1, 54.7, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 41, 1337.6, 959.3, 54.6, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 42, 1341.7, 936.3, 54.7, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 43, 1356.3, 860.5, 52.1, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 44, 1384.8, 784.0, 47.1, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 45, 1415.5, 710.0, 47.2, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 46, 1459.9, 647.9, 47.4, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 47, 1500.1, 620.6, 47.4, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal'),
(4476400, 48, 1542.8, 583.1, 45.0, NULL, 0, 'Horde Coffin Hauler - Forsaken Front to Tirisfal');

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (44731, 44732, 44733, 44734, 44737, 44764, 44766, 46559, 46560, -188034, -187562, -188199, -188200) AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(-188034, 0, 0, 0, 1, 0, 100, 1, 1000, 1000, 0, 0, 0, 48, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'General Purpose Bunny JMF - Out of Combat - Set Active'),
(-188034, 0, 1, 0, 1, 0, 100, 0, 2000, 2000, 60000, 60000, 0, 12, 44731, 8, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'General Purpose Bunny JMF - Out of Combat - Summon Horde Hauler'),
(-188199, 0, 0, 0, 1, 0, 100, 1, 1000, 1000, 0, 0, 0, 48, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'General Purpose Bunny JMF - Out of Combat - Set Active'),
(-188199, 0, 1, 0, 1, 0, 100, 0, 2000, 2000, 60000, 60000, 0, 12, 44764, 8, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'General Purpose Bunny JMF - Out of Combat - Summon Horde Coffin Hauler'),
(44731, 0, 0, 1, 1, 0, 100, 65537, 1000, 1000, 0, 0, 0, 48, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Out of Combat - Set Active'),
(44731, 0, 1, 12, 61, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 4473100, 0, 0, 1000, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Start Waypoint'),
(44731, 0, 2, 3, 40, 0, 100, 0, 7, 4473100, 0, 0, 0, 45, 1, 0, 0, 0, 0, 0, 19, 44734, 5, 0, 0, 0, 0, 0, 0, 'Horde Hauler - On Waypoint 7 Reached - Set Data 1 0 (Horde Engineer) (Forsaken High Command)'),
(44731, 0, 3, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 54, 20000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Pause Waypoint'),
(44731, 0, 4, 5, 40, 0, 100, 0, 31, 4473100, 0, 0, 0, 45, 1, 1, 0, 0, 0, 0, 19, 44734, 5, 0, 0, 0, 0, 0, 0, 'Horde Hauler - On Waypoint 31 Reached - Set Data 1 1 (Horde Engineer) (The Sepulcher)'),
(44731, 0, 5, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 54, 20000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Pause Waypoint'),
(44731, 0, 6, 7, 40, 0, 100, 0, 47, 4473100, 0, 0, 0, 45, 1, 2, 0, 0, 0, 0, 19, 44734, 5, 0, 0, 0, 0, 0, 0, 'Horde Hauler - On Waypoint 47 Reached - Set Data 1 2 (Horde Engineer) (The Forsaken Front)'),
(44731, 0, 7, 8, 61, 0, 100, 0, 0, 0, 0, 0, 0, 28, 86807, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Remove Aura ''Ride Horde Hauler'''),
(44731, 0, 8, 9, 61, 0, 100, 0, 0, 0, 0, 0, 0, 83, 16777216, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Remove Npc Flag Spellclick'),
(44731, 0, 9, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 54, 5000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Pause Waypoint'),
(44731, 0, 10, 0, 27, 0, 100, 0, 0, 0, 0, 0, 0, 45, 1, 3, 0, 0, 0, 0, 19, 44734, 5, 0, 0, 0, 0, 0, 0, 'Horde Hauler - On Passenger Boarded - Set Data 1 3 (Horde Engineer)'),
(44731, 0, 11, 0, 40, 0, 100, 0, 1, 4473100, 0, 0, 0, 54, 20000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - On Waypoint 1 Reached - Pause Waypoint (Tirisfal border)'),
(44731, 0, 12, 13, 61, 0, 100, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Set Reactstate Passive'),
(44731, 0, 13, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 117, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Disable Evade'),
(44731, 0, 14, 15, 40, 0, 100, 0, 48, 4473100, 0, 0, 0, 45, 2, 1, 0, 0, 0, 0, 9, 44734, 0, 15, 0, 0, 0, 0, 0, 'Horde Hauler - On Waypoint 48 Reached - Set Data 2 1 (Horde Engineer)'),
(44731, 0, 15, 16, 61, 0, 100, 0, 0, 0, 0, 0, 0, 45, 2, 1, 0, 0, 0, 0, 9, 44737, 0, 15, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Set Data 2 1 (Subdued Forest Ettin)'),
(44731, 0, 16, 17, 61, 0, 100, 0, 0, 0, 0, 0, 0, 45, 2, 1, 0, 0, 0, 0, 9, 44733, 0, 15, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Set Data 2 1 (Forsaken Trooper)'),
(44731, 0, 17, 18, 61, 0, 100, 0, 0, 0, 0, 0, 0, 45, 2, 1, 0, 0, 0, 0, 9, 44732, 0, 15, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Set Data 2 1 (Forsaken Trooper)'),
(44731, 0, 18, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Hauler - Linked - Despawn'),
(44734, 0, 0, 0, 38, 0, 100, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Engineer - On Data Set 1 0 - Say Line 0'),
(44734, 0, 1, 0, 38, 0, 100, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Engineer - On Data Set 1 1 - Say Line 1'),
(44734, 0, 2, 0, 38, 0, 100, 0, 1, 2, 0, 0, 0, 1, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Engineer - On Data Set 1 2 - Say Line 2'),
(44734, 0, 3, 0, 38, 0, 100, 0, 1, 3, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Engineer - On Data Set 1 3 - Say Line 3'),
(44734, 0, 4, 0, 38, 0, 100, 0, 2, 1, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Engineer - On Data Set 2 1 - Despawn'),
(44732, 0, 0, 0, 38, 0, 100, 0, 2, 1, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Forsaken Trooper - On Data Set 2 1 - Despawn'),
(44733, 0, 0, 0, 38, 0, 100, 0, 2, 1, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Forsaken Trooper - On Data Set 2 1 - Despawn'),
(44737, 0, 0, 0, 38, 0, 100, 0, 2, 1, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Subdued Forest Ettin - On Data Set 2 1 - Despawn'),
(44766, 0, 0, 0, 38, 0, 100, 0, 2, 1, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Coffins - On Data Set 2 1 - Despawn'),
(46559, 0, 0, 0, 38, 0, 100, 0, 2, 1, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Engineer - On Data Set 2 1 - Despawn'),
(46560, 0, 0, 0, 38, 0, 100, 0, 2, 1, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Subdued Forest Ettin - On Data Set 2 1 - Despawn'),
(44764, 0, 0, 1, 1, 0, 100, 65537, 1000, 1000, 0, 0, 0, 48, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Coffin Hauler - Out of Combat - Set Active'),
(44764, 0, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 4476400, 0, 0, 1000, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Coffin Hauler - Linked - Start Waypoint'),
(44764, 0, 2, 3, 61, 0, 100, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Coffin Hauler - Linked - Set Reactstate Passive'),
(44764, 0, 3, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 117, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Coffin Hauler - Linked - Disable Evade'),
(44764, 0, 4, 5, 40, 0, 100, 0, 48, 4476400, 0, 0, 0, 45, 2, 1, 0, 0, 0, 0, 9, 46559, 0, 15, 0, 0, 0, 0, 0, 'Horde Coffin Hauler - On Waypoint 48 Reached - Set Data 2 1 (Horde Engineer)'),
(44764, 0, 5, 6, 61, 0, 100, 0, 0, 0, 0, 0, 0, 45, 2, 1, 0, 0, 0, 0, 9, 46560, 0, 15, 0, 0, 0, 0, 0, 'Horde Coffin Hauler - Linked - Set Data 2 1 (Subdued Forest Ettin)'),
(44764, 0, 6, 7, 61, 0, 100, 0, 0, 0, 0, 0, 0, 45, 2, 1, 0, 0, 0, 0, 9, 44766, 0, 15, 0, 0, 0, 0, 0, 'Horde Coffin Hauler - Linked - Set Data 2 1 (Coffins)'),
(44764, 0, 7, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Coffin Hauler - Linked - Despawn');

-- ===== 2026_10_29_986_19_sp_skitterweb_matriarch.sql
-- ported from PR 15 2026_10_26_10_world.sql (#986)
-- Skitterweb Matriarch: lurks on the ceiling of the Skittering Dark and drops on whoever engages her (npc_silverpine_skitterweb_matriarch).
-- Her SmartAI left her a ground creature in mid-air, out of line of sight from the cave floor.
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_skitterweb_matriarch', `flags_extra` = 512 WHERE `entry` = 44906;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 44906 AND `source_type` = 0;

-- Skitterweb Web: the strands run to the Skitterweb Invisible Stalkers above her
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceEntry` = 83827;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(13, 1, 83827, 0, 0, 31, 0, 3, 44908, 0, 0, 0, 0, '', 'Skitterweb Web - Target Skitterweb Invisible Stalker');

-- The stalkers hang in the air: no wandering
UPDATE `creature` SET `wander_distance` = 0, `MovementType` = 0 WHERE `id` = 44908;

-- ===== 2026_10_29_986_20_sp_battered_chest_z.sql
-- ported from PR 15 2026_10_26_11_world.sql (#986)
-- Battered Chest at the Forsaken Rear Guard: the old Ivar Patch spawn kept its pre-Cataclysm height and floated above the ground
UPDATE `gameobject` SET `position_z` = 27.943 WHERE `guid` = 1468;

