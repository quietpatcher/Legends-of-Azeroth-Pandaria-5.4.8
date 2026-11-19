-- Heroic Deadmines, Vanessa VanCleef nightmare (to-do 314), build step 1: tree and database made equal.
-- What a player sees today: on a database built from the tree alone the narrator (creature 49671) has no lines 12-18 ("The
--   nightmare shifts!", "Save Emme/Erik/Calissa Harrington!", "The Nightmare Elixir wears off!", "A shadowy figure appears in
--   the ship's cabin!", "The Nightmare Elixir takes hold!"), so those screen messages never appear, and the nightmare
--   bosses 49670, 49674, 49681, 49682, the Enraged Worgen 49532 and the Harringtons 49534-49536, 49539 have no script name,
--   so the C++ classes that drive them are never attached. On the development database three script names point at
--   classes that do not exist (49454, 49457, 49550), and the start-up log reports each of them.
-- Cause: the data of the nightmare build (patch 314b) was only ever put in the development database, never in a tree file; the
--   data of the reverted builds (314c, 314d) stayed behind there. Glubtok 49670 and Foe Reaper 5000 49681 also carry the AI
--   name SmartAI next to a script name; the script name wins, so their Spirit Strike rows never run.
-- Checked: the C++ classes npc_deadmines_nightmare_boss, _worgen and _harrington exist and are registered; the classes
--   npc_deadmines_vanessas_trap_bunny, npc_deadmines_steam_valve and npc_vanessa_vancleef_rope exist nowhere in the source.
--   Narrator groups 0-11 are identical in the sniff-based reference (ids and broadcast texts); groups 12-18 are not in the
--   reference as creature text, the broadcast texts 49707, 49711-49714, 48276 and 49705 exist in the world database and carry
--   exactly these English texts. Narrator 49671 keeps no script name and no AI name (the instance script makes it talk).
--   Spell click rows, spawns and the Spirit Strike smart script rows are left alone (later steps decide on them).
-- Change: creature text 49671 groups 12-18 added; script names set on 49670, 49674, 49681, 49682 (boss), 49532 (worgen),
--   49534, 49535, 49536, 49539 (Harrington); script names emptied on 49454, 49457, 49550; AI name emptied on 49670 and 49681.
-- Source: world database broadcast_text (client text, ids as listed above); script names from the registered C++ classes;
--   Cataclysm Preservation sniff database (creature_text groups 0-11 and creature_template, comparison); SkyFire 5.4.8
--   database has no creature text for 49671. Design of 14-11-2026.
-- Note: the live server and the source tree have none of these script names and only text groups 0-11 of 49671; the
--   development database still held leftovers of a reverted change. The rollback restores the live/tree state.
-- Rollback (the values before this update on the live server):
--   DELETE FROM `creature_text` WHERE `CreatureID`=49671 AND `GroupID` BETWEEN 12 AND 18;
--   UPDATE `creature_template` SET `ScriptName`='' WHERE `entry` IN (49454,49457,49550,49674,49682,49532,49534,49535,49536,49539);
--   UPDATE `creature_template` SET `AIName`='SmartAI',`ScriptName`='' WHERE `entry` IN (49670,49681);

DELETE FROM `creature_text` WHERE `CreatureID`=49671 AND `GroupID` BETWEEN 12 AND 18;
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(49671,12,0,'The nightmare shifts!',41,0,100,0,0,0,0,49707,0,'Vanessa VanCleef (nightmare) - nightmare shifts'),
(49671,13,0,'Save Emme Harrington!',41,0,100,0,0,0,0,49711,0,'Vanessa VanCleef (nightmare) - Ripsnarl nightmare, Emme'),
(49671,14,0,'Save Erik Harrington!',41,0,100,0,0,0,0,49712,0,'Vanessa VanCleef (nightmare) - Ripsnarl nightmare, Erik'),
(49671,15,0,'Save Calissa Harrington!',41,0,100,0,0,0,0,49713,0,'Vanessa VanCleef (nightmare) - Ripsnarl nightmare, Calissa'),
(49671,16,0,'The Nightmare Elixir wears off!',41,0,100,0,0,0,0,49714,0,'Vanessa VanCleef (nightmare) - elixir wears off'),
(49671,17,0,'A shadowy figure appears in the ship\'s cabin!',41,0,100,0,0,0,0,48276,0,'Vanessa VanCleef (nightmare) - after Ripsnarl death'),
(49671,18,0,'The Nightmare Elixir takes hold!',41,0,100,0,0,0,0,49705,0,'Vanessa VanCleef (nightmare) - elixir takes hold');

UPDATE `creature_template` SET `ScriptName`='npc_deadmines_nightmare_boss' WHERE `entry` IN (49674,49682);  -- Helix, Ripsnarl
UPDATE `creature_template` SET `AIName`='',`ScriptName`='npc_deadmines_nightmare_boss' WHERE `entry` IN (49670,49681);  -- Glubtok, Foe Reaper 5000
UPDATE `creature_template` SET `ScriptName`='npc_deadmines_nightmare_worgen' WHERE `entry`=49532;
UPDATE `creature_template` SET `ScriptName`='npc_deadmines_nightmare_harrington' WHERE `entry` IN (49534,49535,49536,49539);
UPDATE `creature_template` SET `ScriptName`='' WHERE `entry` IN (49454,49457,49550) AND `ScriptName` IN ('npc_deadmines_vanessas_trap_bunny','npc_deadmines_steam_valve','npc_vanessa_vancleef_rope');
