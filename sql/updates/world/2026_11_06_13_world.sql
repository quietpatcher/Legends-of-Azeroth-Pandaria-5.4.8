-- Rollback: restore the tables listed in the Rollback section of state/l1_silverpine_hillsbrad_diff.md from the pre-apply dump.
-- Source: DeltaTho PR 15 via 1LineAtaTime/LoA-Pandaria-Playerbots b179e298 (GPLv2); concatenated in original order:
--   2026_10_29_986_31_sp_dimensional_barrier.sql
--   2026_10_29_986_32_sp_dalaran_crater_portals.sql
--   2026_10_29_986_33_sp_battlefront_phases.sql
--   2026_10_29_986_34_sp_wolf_in_bears_clothing.sql
--   2026_10_29_986_35_sp_of_no_consequence.sql
--   2026_10_29_986_36_sp_pyrewood_fallen_vanguards.sql
--   2026_10_29_986_37_sp_great_escape.sql
--   2026_10_29_986_40_sp_cities_in_dust.sql

-- ===== 2026_10_29_986_31_sp_dimensional_barrier.sql
-- ported from PR 15 2026_10_27_45_world.sql (#986)
-- Ambermill: the Dimensional Barrier (QUEST INVIS 20) only shows during Transdimensional Warfare: Chapter III. Retail gives
-- its detection, Detect: Quest Invis Zone 20 (Ambermill Shield, invisibility type 28), in Silverpine while the quest is in
-- progress; mop had neither the spell_area row nor the barrier's invisibility, so everyone always saw it.
DELETE FROM `spell_area` WHERE `spell`=85406 AND `area`=130;
INSERT INTO `spell_area` (`spell`,`area`,`quest_start`,`quest_end`,`aura_spell`,`racemask`,`gender`,`autocast`,`quest_start_status`,`quest_end_status`) VALUES
(85406,130,0,27518,0,0,2,1,0,8);

DELETE FROM `gameobject_addon` WHERE `guid`=160563;
INSERT INTO `gameobject_addon` (`guid`,`invisibilityType`,`invisibilityValue`) VALUES
(160563,28,1);

-- ===== 2026_10_29_986_32_sp_dalaran_crater_portals.sql
-- ported from PR 15 2026_10_27_46_world.sql (#986)
-- Dalaran Crater: the portals between the Sepulcher and the crater (Relios the Relic Keeper, Ley Energies, Practical
-- Vengeance) teleport to a database destination that was missing, so both put the player back where they stood.
-- No sniff has the destinations; send each portal to the other one's spawn point.
DELETE FROM `spell_target_position` WHERE `id` IN (85317,85318);
INSERT INTO `spell_target_position` (`id`,`effIndex`,`target_map`,`target_position_x`,`target_position_y`,`target_position_z`,`target_orientation`) VALUES
(85317,0,0,294.061,377.439,-63.9923,0),       -- Portal to Dalaran Crater: at the Portal to the Sepulcher (45732, guid 312106)
(85318,0,0,452.427,1465.43,125.141,1.06465);  -- Portal to the Sepulcher: at the Portal to Dalaran Crater (45731, guid 312118), by Dalar Dawnweaver

-- ===== 2026_10_29_986_33_sp_battlefront_phases.sql
-- ported from PR 15 2026_10_27_47_world.sql (#986)
-- The Battlefront (area 5456): show who only arrives there later in the story
-- Sylvanas 46124 and High Warlord Cromush 46125 stand at the Battlefront after Cities in Dust (Sylvanas ends it and gives
-- Empire of Dirt), and Archmage Ataeric 46049 with his Forsaken Mages 46048 are the Ambermill magi raised after
-- Transdimensional Warfare: Chapter III. All were in the default phase and stood there from the start.
-- Phase.dbc has no phase named for the Battlefront; use two unused generic ones ("Quest Zone-Specific 22" and "23").
-- The phases are zone-wide (130), so they are seen from outside the Battlefront; these entries only stand there.
-- The Forsaken Mages no longer see the worgen in the default phase next to them, so they stand rather than fight.
--   197  Ataeric and the Forsaken Mages   Transdimensional Warfare: Chapter III rewarded
--   198  Sylvanas and Cromush             Cities in Dust completed or rewarded
UPDATE `creature` SET `phaseId`=197, `phaseGroup`=0 WHERE `map`=0 AND `areaId`=5456 AND `id` IN (46048,46049);
UPDATE `creature` SET `phaseId`=198, `phaseGroup`=0 WHERE `map`=0 AND `areaId`=5456 AND `id` IN (46124,46125);

DELETE FROM `phase_area` WHERE `AreaId`=130 AND `PhaseId` IN (197,198);
INSERT INTO `phase_area` (`AreaId`,`PhaseId`,`Comment`) VALUES
(130,197,'The Battlefront - Archmage Ataeric and the Forsaken Mages after Transdimensional Warfare: Chapter III'),
(130,198,'The Battlefront - Sylvanas and Cromush after Cities in Dust');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=26 AND `SourceEntry`=130 AND `SourceGroup` IN (197,198);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(26,197,130,0,0,47,0,27518,64,0,0,0,0,'','The Battlefront - phase 197 once Transdimensional Warfare: Chapter III is rewarded'),
(26,198,130,0,0,47,0,27601,66,0,0,0,0,'','The Battlefront - phase 198 once Cities in Dust is completed');

-- ===== 2026_10_29_986_34_sp_wolf_in_bears_clothing.sql
-- ported from PR 15 2026_10_27_48_world.sql (#986)
-- A Wolf in Bear's Clothing (27510): the Inconspicuous Bears are worgen druids that only show themselves when beaten
-- (their script turns them into Worgen Druids 45751 at 1% health). The template addon put Worgen Druid Form, the
-- transform into 45751, on them from the start, so they never looked like bears. TCPP has no such aura.
UPDATE `creature_template_addon` SET `auras`='' WHERE `entry`=45750 AND `auras`='85359';
-- The bears were spawned 69 times, in two sniffed batches whose spawns stand 1-4 yards apart: within the 3 yards each one
-- wanders, so they are the same bears twice (retail has 29). Remove the later spawn of each such pair (48 are left).
DELETE FROM `creature_addon` WHERE `guid` IN (188256,188259,188260,188271,188272,188276,188278,188280,188288,188365,188368,188369,188379,188383,188384,188385,188387,188388,188391,188440,188441);
DELETE FROM `creature` WHERE `id`=45750 AND `guid` IN (188256,188259,188260,188271,188272,188276,188278,188280,188288,188365,188368,188369,188379,188383,188384,188385,188387,188388,188391,188440,188441);

-- ===== 2026_10_29_986_35_sp_of_no_consequence.sql
-- ported from PR 15 2026_10_27_49_world.sql (#986)
-- Of No Consequence (27547): the Cowering Troopers' spellclick cast Squirrel Scrubber Vehicle Aura (90102), which sets a
-- vehicle id on the player who clicks; their script gave the credit instead. Use the quest's own spell, Quest Credit:
-- Of No Consequence (85580, kill credit 45910 on the clicker), and keep the script for the line and the despawn.
DELETE FROM `npc_spellclick_spells` WHERE `npc_entry`=45910;
INSERT INTO `npc_spellclick_spells` (`npc_entry`,`spell_id`,`cast_flags`,`user_type`) VALUES
(45910,85580,2,0);
DELETE FROM `smart_scripts` WHERE `entryorguid`=45910 AND `source_type`=0;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(45910,0,0,0,11,0,100,0,0,0,0,0,0,18,768,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Cowering Trooper - On Respawn - Set Immune Flags'),
(45910,0,1,2,73,0,100,0,0,0,0,0,0,83,16777216,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Cowering Trooper - On Spellclick - Remove Spellclick Flag'),
(45910,0,2,3,61,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Cowering Trooper - On Spellclick - Say Line 0'),
(45910,0,3,0,61,0,100,0,0,0,0,0,0,41,2000,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Cowering Trooper - On Spellclick - Despawn');

-- ===== 2026_10_29_986_36_sp_pyrewood_fallen_vanguards.sql
-- ported from PR 15 2026_10_27_50_world.sql (#986)
-- Pyrewood Village: the fallen Forsaken Vanguards (45882, Permanent Feign Death) were set to wander, so the corpses slid
-- around the village
UPDATE `creature` SET `MovementType`=0, `wander_distance`=0 WHERE `id`=45882;

-- ===== 2026_10_29_986_37_sp_great_escape.sql
-- ported from PR 15 2026_10_27_51_world.sql (#986)
-- The Great Escape (27438): nothing cast Quest Credit: The Great Escape (85091), the quest's only way to be completed.
-- Accepting it from Deathstalker Commander Belmont now casts The Great Escape Initialize (89225) -> Flight of the Val'kyr (85073):
-- Arthura (45555, Vehicle 1119) takes the player and Lord Godfrey's corpse (45556), Belmont sees them off and she flies them over
-- the Greymane Wall to the Forsaken Front, where the player is credited and set down beside Sylvanas.
-- Talking to Belmont again restarts an escape that was cut short; reaching Sylvanas 45525 with the quest still open completes it.
INSERT IGNORE INTO `quest_template_addon` (`ID`) VALUES (27438);
UPDATE `quest_template_addon` SET `SourceSpellID` = 89225 WHERE `ID` = 27438;

DELETE FROM `spell_script_names` WHERE `spell_id` IN (89225, 85073, 85079);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(89225, 'spell_silverpine_the_great_escape_initialize'),
(85073, 'spell_silverpine_flight_of_the_valkyr'),
(85079, 'spell_silverpine_summon_belmont_great_escape');

UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_belmont_great_escape' WHERE `entry` IN (45312, 45474);
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_arthura_great_escape' WHERE `entry` = 45555;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_sylvanas_forsaken_front' WHERE `entry` = 45525;

-- Arthura hovers; Lord Godfrey's corpse is dead, as his body at the Forsaken Front (45576)
DELETE FROM `creature_template_addon` WHERE `entry` IN (45555, 45556);
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `MountCreatureID`, `StandState`, `AnimTier`, `VisFlags`, `SheathState`, `PvPFlags`, `emote`, `aiAnimKit`, `movementAnimKit`, `meleeAnimKit`, `visibilityDistanceType`, `auras`) VALUES
(45555, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(45556, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '29266');

-- The farewell (broadcast_text 45701-45707; 45705 belongs to someone else)
DELETE FROM `creature_text` WHERE `CreatureID` IN (45555, 45557, 45312, 45474);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(45555, 0, 0, 'What about you, Belmont? How will you get back?', 12, 0, 100, 0, 0, 0, 0, 45701, 5, 'Arthura - The Great Escape'),
(45555, 1, 0, 'So be it. Farewell, Belmont.', 12, 0, 100, 0, 0, 0, 0, 45706, 5, 'Arthura - The Great Escape'),
(45555, 2, 0, 'Oh my... hang on tight!', 12, 0, 100, 0, 0, 0, 0, 45707, 5, 'Arthura - The Great Escape'),
(45557, 0, 0, 'I''ll be fine, Arthura. The worgen lost our scent. It''s doubtful that they even know we''re here.', 12, 0, 100, 0, 0, 0, 0, 45702, 5, 'Deathstalker Commander Belmont - The Great Escape'),
(45557, 1, 0, 'I''ll probably make it back to the Forsaken Front before you two, er, three.', 12, 0, 100, 0, 0, 0, 0, 45703, 5, 'Deathstalker Commander Belmont - The Great Escape'),
(45557, 2, 0, 'Now move out! You must not keep the Banshee Queen waiting.', 12, 0, 100, 0, 0, 0, 0, 45704, 5, 'Deathstalker Commander Belmont - The Great Escape'),
(45312, 0, 0, 'I''ll be fine, Arthura. The worgen lost our scent. It''s doubtful that they even know we''re here.', 12, 0, 100, 0, 0, 0, 0, 45702, 5, 'Deathstalker Commander Belmont - The Great Escape'),
(45312, 1, 0, 'I''ll probably make it back to the Forsaken Front before you two, er, three.', 12, 0, 100, 0, 0, 0, 0, 45703, 5, 'Deathstalker Commander Belmont - The Great Escape'),
(45312, 2, 0, 'Now move out! You must not keep the Banshee Queen waiting.', 12, 0, 100, 0, 0, 0, 0, 45704, 5, 'Deathstalker Commander Belmont - The Great Escape'),
(45474, 0, 0, 'I''ll be fine, Arthura. The worgen lost our scent. It''s doubtful that they even know we''re here.', 12, 0, 100, 0, 0, 0, 0, 45702, 5, 'Deathstalker Commander Belmont - The Great Escape'),
(45474, 1, 0, 'I''ll probably make it back to the Forsaken Front before you two, er, three.', 12, 0, 100, 0, 0, 0, 0, 45703, 5, 'Deathstalker Commander Belmont - The Great Escape'),
(45474, 2, 0, 'Now move out! You must not keep the Banshee Queen waiting.', 12, 0, 100, 0, 0, 0, 0, 45704, 5, 'Deathstalker Commander Belmont - The Great Escape');

-- ===== 2026_10_29_986_40_sp_cities_in_dust.sql
-- ported from PR 15 2026_10_27_54_world.sql (#986)
-- Cities in Dust (27601): its objective, Cities in Dust Quest Credit (46019), is given only by the spell Cities in Dust (85952),
-- which nothing cast, and Sylvanas at the Forsaken Front (45617) had no gossip option to start the march.
-- Her option (the text of broadcast_text 46257, given without its id because the text has only a female form; shown while
-- the quest is in progress) casts Summon Sylvanas (85864): her actor 46026 brings Cromush
-- and the three val'kyr, sings Song of Sylvanas and marches with the player across the Battlefront to the Greymane Wall, where
-- the finale of broadcast_text 46139-46227 plays (Crowley and Bloodfang, Godfrey with Lorna, Walden and Ashbury, all the
-- player's personal summons) and the player is credited. Speakers as on warcraft.wiki.gg.
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 11823 AND `OptionID` = 0;
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`, `OptionBroadcastTextID`, `OptionType`, `OptionNpcflag`, `ActionMenuID`, `ActionPoiID`, `BoxCoded`, `BoxMoney`, `BoxText`, `BoxBroadcastTextID`, `VerifiedBuild`) VALUES
(11823, 0, 0, 'Accompany Lady Sylvanas Windrunner across the Battlefront.', 0, 1, 1, 0, 0, 0, 0, NULL, 0, 0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 11823 AND `SourceEntry` = 0;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(15, 11823, 0, 0, 0, 47, 0, 27601, 8, 0, 0, 0, 0, '', 'Lady Sylvanas Windrunner - show the march gossip option while Cities in Dust is in progress');

UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_sylvanas_forsaken_front_finale' WHERE `entry` = 45617;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_sylvanas_cities_in_dust' WHERE `entry` = 46026;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_cities_in_dust_actor' WHERE `entry` IN (46027, 46028, 46029, 46030, 46031, 46032, 46033, 46034, 46035, 46036);
-- Walden's combat SmartAI: he is only an actor of the finale
DELETE FROM `smart_scripts` WHERE `entryorguid` = 46029 AND `source_type` = 0 AND `id` IN (0, 1, 2);

DELETE FROM `spell_script_names` WHERE `spell_id` IN (85877, 85878, 85925, 85926, 85927, 85944, 85950);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(85877, 'spell_silverpine_cities_in_dust_summon'),
(85878, 'spell_silverpine_cities_in_dust_summon'),
(85925, 'spell_silverpine_cities_in_dust_summon'),
(85926, 'spell_silverpine_cities_in_dust_summon'),
(85927, 'spell_silverpine_cities_in_dust_summon'),
(85944, 'spell_silverpine_execution'),
(85950, 'spell_silverpine_raise_forsaken_actors');

-- Where Crowley and Bloodfang come out of Gilneas and Godfrey's men come over the wall. No sniff has these spells' positions:
-- Godfrey and Walden use the sniffed spots of Lorna and Walden (static spawns 373753 and 373754, deleted below), the others are ours.
DELETE FROM `spell_target_position` WHERE `ID` IN (85877, 85878, 85925, 85926, 85927);
INSERT INTO `spell_target_position` (`ID`, `effIndex`, `target_map`, `target_position_x`, `target_position_y`, `target_position_z`, `target_orientation`) VALUES
(85877, 0, 0, -760, 1550, 28.5, 0),
(85878, 0, 0, -762, 1541, 28.5, 0),
(85925, 0, 0, -809.41, 1544.53, 28.0109, 6.19401),
(85926, 0, 0, -775.669, 1529.1, 28.8968, 1.77121),
(85927, 0, 0, -805, 1537, 28.2, 0);

-- The val'kyr hover
DELETE FROM `creature_template_addon` WHERE `entry` IN (46032, 46033, 46034);
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `MountCreatureID`, `StandState`, `AnimTier`, `VisFlags`, `SheathState`, `PvPFlags`, `emote`, `aiAnimKit`, `movementAnimKit`, `meleeAnimKit`, `visibilityDistanceType`, `auras`) VALUES
(46032, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(46033, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(46034, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, NULL);

-- Static spawns of the finale's summons: Ashbury 46030, Lorna 46027, Walden 46029, Crowley 46036
DELETE FROM `creature_addon` WHERE `guid` IN (373751, 373753, 373754, 373755);
DELETE FROM `creature` WHERE `guid` IN (373751, 373753, 373754, 373755) AND `id` IN (46027, 46029, 46030, 46036);

DELETE FROM `creature_text` WHERE `CreatureID` IN (46026, 46028, 46031, 46032, 46033, 46034, 46035, 46036);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(46026, 0, 0, 'Onward, $n! We will beat back the Alliance dogs and secure Lordaeron for the Forsaken! For the Horde!', 12, 0, 100, 0, 0, 0, 0, 46139, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 1, 0, 'I will leave your cities in dust and your lives in ruin!', 14, 0, 100, 0, 0, 0, 0, 46141, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 2, 0, 'Lay down your arms and surrender!', 14, 0, 100, 0, 0, 0, 0, 46142, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 3, 0, 'Look at them, $p. They scurry like rats, veering headlong to their doom. Surely Crowley and Bloodfang can see the futility in this!', 12, 0, 100, 0, 0, 0, 0, 46143, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 4, 0, 'To the Greymane Wall! We will force their hand.', 12, 0, 100, 0, 0, 0, 0, 46144, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 5, 0, 'Crowley, your forces have fallen before my mighty army. You have lost!', 14, 0, 100, 0, 0, 0, 0, 46188, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 6, 0, 'You frivolously throw away the lives of your people while your own king sits atop his throne of lies, nary lifting a finger to help.', 12, 0, 100, 0, 0, 0, 0, 46190, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 7, 0, 'Is Gilneas worth the lives that have been lost? The lives that will be lost? You cannot win.', 12, 0, 100, 0, 0, 0, 0, 46191, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 8, 0, 'And your daughter? You could have saved her... You could have offered her your blood, yet you did not. Why?', 12, 0, 100, 0, 0, 0, 0, 46194, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 9, 0, 'Nothing, yet...', 12, 0, 100, 0, 0, 0, 0, 46196, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 10, 0, 'I now present you with a choice - a choice that I was never given.', 12, 0, 100, 0, 0, 0, 0, 46197, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 11, 0, 'I offer you the life of Lorna for your unconditional surrender.', 12, 0, 100, 0, 0, 0, 0, 46198, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 12, 0, 'Choose your next words wisely, Crowley. Deny me and she will serve me in undeath - forever.', 12, 0, 100, 0, 0, 0, 0, 46199, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 13, 0, 'Bring her, Godfrey!', 14, 0, 100, 0, 0, 0, 0, 46200, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 14, 0, 'Release her, Godfrey.', 12, 0, 100, 0, 0, 0, 0, 46206, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 15, 0, 'Now leave here, Crowley, and never return.', 12, 0, 100, 0, 0, 0, 0, 46208, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 16, 0, 'Lordaeron belongs to the Forsaken.', 12, 0, 100, 0, 0, 0, 0, 46209, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 17, 0, 'SOLDIERS OF THE HORDE! WE ARE VICTORIOUS! LORDAERON IS W...', 14, 0, 100, 0, 0, 0, 0, 46211, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 18, 0, '%s dies.', 16, 0, 100, 0, 0, 0, 0, 46212, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 19, 0, 'I saw... only darkness.', 12, 0, 100, 0, 0, 0, 0, 46224, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 20, 0, 'And as I drifted towards nothingness, a brilliant light appeared, then another, and another... My dear val''kyr.', 12, 0, 100, 0, 0, 0, 0, 46225, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 21, 0, 'I know now - beyond a shadow of a doubt - that the val''kyr are our future.', 12, 0, 100, 0, 0, 0, 0, 46226, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46026, 22, 0, 'We will never stop fighting for Lordaeron. Never...', 12, 0, 100, 0, 0, 0, 0, 46227, 5, 'Lady Sylvanas Windrunner - Cities in Dust'),
(46036, 0, 0, 'It''s not over, Sylvanas. Not yet.', 12, 0, 100, 0, 0, 0, 0, 46189, 5, 'Lord Darius Crowley - Cities in Dust'),
(46036, 1, 0, 'We will die trying!', 12, 0, 100, 0, 0, 0, 0, 46193, 5, 'Lord Darius Crowley - Cities in Dust'),
(46036, 2, 0, 'LORNA? What... Where is she!? What have you done to her!?', 12, 0, 100, 0, 0, 0, 0, 46195, 5, 'Lord Darius Crowley - Cities in Dust'),
(46036, 3, 0, 'GODFREY! You deceitful maggot!', 12, 0, 100, 0, 0, 0, 0, 46203, 5, 'Lord Darius Crowley - Cities in Dust'),
(46036, 4, 0, 'Lorna... I... Release her. I will sound the retreat.', 12, 0, 100, 0, 0, 0, 0, 46204, 5, 'Lord Darius Crowley - Cities in Dust'),
(46036, 5, 0, 'Forgive me, daughter...', 12, 0, 100, 0, 0, 0, 0, 46210, 5, 'Lord Darius Crowley - Cities in Dust'),
(46035, 0, 0, 'You can''t be serious, Crowley. You miserable bastard!', 12, 0, 100, 0, 0, 0, 0, 46205, 5, 'Packleader Ivar Bloodfang - Cities in Dust'),
(46028, 0, 0, 'Hello, old friend!', 12, 0, 100, 0, 0, 0, 0, 46202, 5, 'Lord Godfrey - Cities in Dust'),
(46028, 1, 0, 'Of course, mistress.', 12, 0, 100, 0, 0, 0, 0, 46207, 5, 'Lord Godfrey - Cities in Dust'),
(46028, 2, 0, 'Something that should have been done a long time ago, you filthy animal.', 12, 0, 100, 0, 0, 0, 0, 46214, 5, 'Lord Godfrey - Cities in Dust'),
(46028, 3, 0, 'Gilneas belongs to me, and so soon will the rest of Lordaeron!', 12, 0, 100, 0, 0, 0, 0, 46215, 5, 'Lord Godfrey - Cities in Dust'),
(46028, 4, 0, 'NOW JOIN YOUR MISTRESS IN DEATH!', 12, 0, 100, 0, 0, 0, 0, 46216, 5, 'Lord Godfrey - Cities in Dust'),
(46028, 5, 0, 'FALL BACK, BROTHERS! TO SHADOWFANG!', 14, 0, 100, 0, 0, 0, 0, 46217, 5, 'Lord Godfrey - Cities in Dust'),
(46028, 6, 0, 'This land will quiver and shake in the wake of our destruction!', 14, 0, 100, 0, 0, 0, 0, 46218, 5, 'Lord Godfrey - Cities in Dust'),
(46031, 0, 0, 'WHAT HAVE YOU DONE, GODFREY!', 12, 0, 100, 0, 0, 0, 0, 46213, 5, 'High Warlord Cromush - Cities in Dust'),
(46031, 1, 0, 'Fix her... FIX HER!', 12, 0, 100, 0, 0, 0, 0, 46219, 5, 'High Warlord Cromush - Cities in Dust'),
(46034, 0, 0, 'We are bound to her, sisters...', 12, 0, 100, 0, 0, 0, 0, 46220, 5, 'Agatha - Cities in Dust'),
(46032, 0, 0, 'It will destroy us, sister...', 12, 0, 100, 0, 0, 0, 0, 46221, 5, 'Arthura - Cities in Dust'),
(46032, 1, 0, 'Then let it be done.', 12, 0, 100, 0, 0, 0, 0, 46223, 5, 'Arthura - Cities in Dust'),
(46033, 0, 0, 'It is our sacred duty. The pact was sealed, the bargain made...', 12, 0, 100, 0, 0, 0, 0, 46222, 5, 'Daschla - Cities in Dust');

