-- Rollback: restore ~/backups/sql/rise_godfrey_pre_20261108.sql (REPLACE rows of the touched tables), then DELETE FROM spell_script_names WHERE spell_id IN (85149,85197); DELETE FROM spell_area WHERE spell=85149; UPDATE quest_template_addon SET SourceSpellID=0 WHERE ID=27472; UPDATE creature_template SET ScriptName='' WHERE entry BETWEEN 45605 AND 45612 (45605: AIName='SmartAI' again); DELETE FROM creature_template_addon/creature_text rows of 45607-45611 / 45612 that the dump does not contain. Restart needed to unbind the scripts.
-- Source: 1LineAtaTime/LoA-Pandaria-Playerbots (GPLv2) 2026_10_29_986_38_sp_rise_godfrey.sql (from PR 15 2026_10_27_52) and 986_28_sp_ashbury_actor.sql (PR 15 2026_10_27_42); only these two, checked against zone_silverpine_forest_1l.cpp (RiseGodfrey enum, spells 85149/85150-85157/85197, entries 45605-45612).
-- Why: Rise, Godfrey (27472) accepts but its scene never starts: the C++ (spell_silverpine_summon_forsaken_front_actors + _aura, spell_silverpine_raise_forsaken_actors, npc_silverpine_sylvanas_rise_godfrey, npc_silverpine_forsaken_front_actor) is registered, but the DB bindings were not ported (sync98 left out 1L's Silverpine SQL on purpose, to protect 26965/26998/27045).
-- Left out on purpose (touch other quests or our own phasing): 986_10-13 (quest gating), 27 (camp phases: dev has its own 5387 phases 277/278/284), 61-66 (invis detections / groups, incl. 26964/26965/27097-27099). Spell 85150-85157 spell_target_position rows already exist in dev.
-- 45605 is also the Tirisfal wickerman Sylvanas (TDB, static guid 4307400, SmartAI + creature_text 0-12): as in 1L the SmartAI and the old texts go, ScriptName takes the entry (that static one only stands then). 1L schema creature_template_addon (StandState/AnimTier/SheathState) is the same as dev's.

-- Accepting the quest casts Summon Forsaken Front Actors (85149); spell_area gives it again in the Forsaken Front while the quest is in progress
INSERT IGNORE INTO `quest_template_addon` (`ID`) VALUES (27472);
UPDATE `quest_template_addon` SET `SourceSpellID` = 85149 WHERE `ID` = 27472;

DELETE FROM `spell_script_names` WHERE `spell_id` IN (85149, 85197);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(85149, 'spell_silverpine_summon_forsaken_front_actors'),
(85149, 'spell_silverpine_summon_forsaken_front_actors_aura'),
(85197, 'spell_silverpine_raise_forsaken_actors');

DELETE FROM `spell_area` WHERE `spell` = 85149;
INSERT INTO `spell_area` (`spell`, `area`, `quest_start`, `quest_end`, `aura_spell`, `racemask`, `gender`, `autocast`, `quest_start_status`, `quest_end_status`) VALUES
(85149, 5387, 27472, 0, 0, 0, 2, 1, 8, 11);

DELETE FROM `smart_scripts` WHERE `entryorguid` = 45605 AND `source_type` = 0;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_sylvanas_rise_godfrey' WHERE `entry` = 45605;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_forsaken_front_actor' WHERE `entry` IN (45606, 45607, 45608, 45609, 45610, 45611, 45612);

-- As the camp around Godfrey's body: Sylvanas on her horse, the three dead, the val'kyr hovering
DELETE FROM `creature_template_addon` WHERE `entry` IN (45605, 45606, 45607, 45608, 45609, 45610, 45611);
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `MountCreatureID`, `StandState`, `AnimTier`, `VisFlags`, `SheathState`, `PvPFlags`, `emote`, `aiAnimKit`, `movementAnimKit`, `meleeAnimKit`, `visibilityDistanceType`, `auras`) VALUES
(45605, 0, 29257, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(45606, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '29266'),
(45607, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '29266'),
(45608, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '29266'),
(45609, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(45610, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(45611, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, NULL);

-- Speakers as on warcraft.wiki.gg (Rise, Godfrey)
DELETE FROM `creature_text` WHERE `CreatureID` IN (45605, 45606, 45612);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(45605, 0, 0, 'Rise, Lord Vincent Godfrey. Be reborn as an instrument of my vengeance!', 12, 0, 100, 0, 0, 0, 0, 45740, 5, 'Lady Sylvanas Windrunner - Rise, Godfrey'),
(45605, 1, 0, 'You live to serve me, Godfrey. Together we will crush the worgen uprising and retake Gilneas for the Forsaken.', 12, 0, 100, 0, 0, 0, 0, 45742, 5, 'Lady Sylvanas Windrunner - Rise, Godfrey'),
(45605, 2, 0, 'Yes, of course...', 12, 0, 100, 0, 0, 0, 0, 45744, 5, 'Lady Sylvanas Windrunner - Rise, Godfrey'),
(45605, 3, 0, 'Prepare your men. The Gilneas Liberation Front amasses at the Greymane Wall. Soon their reinforcements from Stormwind will arrive. We haven''t a minute to waste.', 12, 0, 100, 0, 0, 0, 0, 45748, 5, 'Lady Sylvanas Windrunner - Rise, Godfrey'),
(45605, 4, 0, 'Armor, weapons, whatever you may need, you will find at the supply depot behind me. Go now.', 12, 0, 100, 0, 0, 0, 0, 45750, 5, 'Lady Sylvanas Windrunner - Rise, Godfrey'),
(45605, 5, 0, 'Once again you have impressed me, $n. Without your aid, we would have not made it this far. Walk with me...', 12, 0, 100, 0, 0, 0, 0, 45751, 5, 'Lady Sylvanas Windrunner - Rise, Godfrey'),
(45606, 0, 0, 'I live again...', 12, 0, 100, 0, 0, 0, 0, 45741, 5, 'Lord Godfrey - Rise, Godfrey'),
(45606, 1, 0, 'The irony of what I have become is not lost upon me, Lady Sylvanas.', 12, 0, 100, 0, 0, 0, 0, 45745, 5, 'Lord Godfrey - Rise, Godfrey'),
(45606, 2, 0, 'Though as I have always said, better dead than worgen.', 12, 0, 100, 0, 0, 0, 0, 45746, 5, 'Lord Godfrey - Rise, Godfrey'),
(45606, 3, 0, 'Or in this case, better undead than worgen.', 12, 0, 100, 0, 0, 0, 0, 45747, 5, 'Lord Godfrey - Rise, Godfrey'),
(45606, 4, 0, 'As you wish, Banshee Queen.', 12, 0, 100, 0, 0, 0, 0, 45749, 5, 'Lord Godfrey - Rise, Godfrey'),
(45612, 0, 0, 'For the Horde...', 12, 0, 100, 0, 0, 0, 0, 45743, 5, 'High Warlord Cromush - Rise, Godfrey');

-- Baron Ashbury 45607 is a personal actor of the scene (spell 85156), not a static spawn: the static one would despawn at once (no summoner)
DELETE FROM `creature_addon` WHERE `guid` = 373752;
DELETE FROM `creature` WHERE `guid` = 373752 AND `id` = 45607;
