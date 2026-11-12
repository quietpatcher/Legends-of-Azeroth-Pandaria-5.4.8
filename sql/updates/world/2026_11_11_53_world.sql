-- Lost Isles (goblin start): 14239 Don't Go Into the Light! and 14021 Miner Troubles.
--
-- 14239, cause: the goblin arrived on the flotsam standing up and Doc Zapnozzle (36608) was a silent quest giver.
--   On retail he wakes up near death (aura 69010 Near Death!) next to Doc Zapnozzle and Geargrinder Gizmo; the Doc
--   tells Gizmo who is lying there, tries his jumper cables (69022) and leaves it to the goblin; the quest is taken
--   and handed in lying down, and the Doc speaks again on accept.
--   Fix: script npc_lost_isles_doc_zapnozzle (the scene and the lines on accept) and the texts.
--   The Near Death! aura (69010) is NOT applied: its second effect is MOD_INVISIBILITY type 7 (value 100000) and
--   WorldObject::CanDetectInvisibilityOf (Object.cpp) lets an invisible seer see only units that have the matching
--   invisibility detection, so the goblin could not see or target Doc Zapnozzle or Gizmo (dev play-test 11-11). Neither
--   creature has such detection in the 5.4.8 data (36608 has no aura, 36600 only 68327 heat signature), so the
--   near-death state is not reproduced.
-- 14021, cause: Foreman Dampwick gave the credit "Miner Troubles Kill Credit" (35816) the moment the quest was
--   accepted. On retail it is an escort: the Frightened Miner (35813) goes into the Kaja'mite Cavern with his ore
--   cart and works the deposits while the Smart Mining Monkeys go for him; the credit comes at the last deposit. A
--   dead miner is replaced through the gossip "Er, Dampwick, I need another miner....".
--   Fix: Dampwick only speaks on accept; quest script quest_lost_isles_miner_troubles summons the miner, script
--   npc_lost_isles_frightened_miner walks him along the Kaja'mite Ore deposits (gameobject 195622); the gossip
--   option (menu 10677 -> 10712) casts 68069 Miner Troubles: New Miner from Gossip (spell_lost_isles_new_miner);
--   the missing deposit lines of the miner; Dampwick claims the mine on hand-in.
-- Source: wowpedia.fandom.com/wiki/Don't_Go_Into_the_Light! (Notes), wowpedia.fandom.com/wiki/Miner_Troubles (Notes),
--   broadcast_text 36543-36549, 36577, 36010-36017, 36020, 49833/49834, npc_text 14869 (gossip_menu 10712), 5.4.8
--   client Spell.dbc/SpellEffect.dbc (69010: effect 0 aura 12 stun, effect 1 aura 18 invisibility type 7; 69022, 68059-68122). The order of the deposits has no source.
-- Needs the worldserver binary with these script names.
-- Rollback: the statements at the bottom of this file (commented out).

-- 14239 -----------------------------------------------------------------------------------------------------------
UPDATE `creature_template` SET `ScriptName`='npc_lost_isles_doc_zapnozzle' WHERE `entry`=36608;

DELETE FROM `creature_text` WHERE `CreatureID`=36608;
DELETE FROM `creature_text` WHERE `CreatureID`=36600 AND `GroupID`=1;
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`)
SELECT 36608, CASE `ID` WHEN 36543 THEN 0 WHEN 36544 THEN 1 WHEN 36545 THEN 2 WHEN 36546 THEN 3 WHEN 36547 THEN 4 WHEN 36548 THEN 5 ELSE 6 END,
  0, `Text`, 12, 0, 100, 0, 0, 0, 0, `ID`, 0, 'Doc Zapnozzle - Don''t Go Into the Light!'
  FROM `broadcast_text` WHERE `ID` IN (36543,36544,36545,36546,36547,36548,36549);
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`)
SELECT 36600, 1, 0, `Text`, 12, 0, 100, 0, 0, 0, 0, `ID`, 0, 'Geargrinder Gizmo - Don''t Go Into the Light!'
  FROM `broadcast_text` WHERE `ID`=36577;

-- (no spell_area row for 69010 Near Death!, see the header)

-- 14021 -----------------------------------------------------------------------------------------------------------
UPDATE `quest_template_addon` SET `ScriptName`='quest_lost_isles_miner_troubles' WHERE `ID`=14021;
UPDATE `creature_template` SET `ScriptName`='npc_lost_isles_frightened_miner' WHERE `entry`=35813;

DELETE FROM `spell_script_names` WHERE `spell_id`=68069;
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(68069,'spell_lost_isles_new_miner');

-- Foreman Dampwick: speaks on accept (was: the credit), hands out a new miner, claims the mine on hand-in
DELETE FROM `smart_scripts` WHERE `entryorguid`=35769 AND `source_type`=0;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(35769,0,0,0,19,0,100,0,14021,0,0,0,0,1,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Foreman Dampwick - On Quest ''Miner Troubles'' Taken - Say Line 0'),
(35769,0,1,0,62,0,100,0,10677,0,0,0,0,85,68069,2,0,0,0,0,7,0,0,0,0,0,0,0,0,'Foreman Dampwick - On Gossip Option 0 Selected - Invoker Cast Miner Troubles: New Miner from Gossip'),
(35769,0,2,0,20,0,100,0,14021,0,0,0,0,1,1,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Foreman Dampwick - On Quest ''Miner Troubles'' Finished - Say Line 1');

DELETE FROM `gossip_menu_option` WHERE `MenuID`=10677 AND `OptionID`=0;
INSERT INTO `gossip_menu_option` (`MenuID`,`OptionID`,`OptionIcon`,`OptionText`,`OptionBroadcastTextID`,`OptionType`,`OptionNpcflag`,`ActionMenuID`,`ActionPoiID`,`BoxCoded`,`BoxMoney`,`BoxText`,`BoxBroadcastTextID`,`VerifiedBuild`) VALUES
(10677,0,0,'Er, Dampwick, I need another miner....',36020,1,1,10712,0,0,0,'',0,0);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=15 AND `SourceGroup`=10677 AND `SourceEntry`=0;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(15,10677,0,0,0,47,0,14021,8,0,0,0,0,'','Foreman Dampwick - another miner only while Miner Troubles is in progress');

-- Frightened Miner: reaching a deposit (group 5), leaving a deposit (group 6)
DELETE FROM `creature_text` WHERE `CreatureID`=35813 AND `GroupID` IN (5,6);
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`)
SELECT 35813, 5, `ID`-36014, `Text`, 12, 0, 100, 0, 0, 0, 0, `ID`, 0, 'Frightened Miner - Miner Troubles, reaching a deposit'
  FROM `broadcast_text` WHERE `ID` IN (36014,36015,36016,36017);
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`)
SELECT 35813, 6, `ID`-36010, `Text`, 12, 0, 100, 0, 0, 0, 0, `ID`, 0, 'Frightened Miner - Miner Troubles, leaving a deposit'
  FROM `broadcast_text` WHERE `ID` IN (36010,36011,36012);

-- Rollback:
-- UPDATE `creature_template` SET `ScriptName`='' WHERE `entry` IN (36608,35813);
-- DELETE FROM `creature_text` WHERE `CreatureID`=36608;
-- DELETE FROM `creature_text` WHERE `CreatureID`=36600 AND `GroupID`=1;
-- UPDATE `quest_template_addon` SET `ScriptName`='' WHERE `ID`=14021;
-- DELETE FROM `spell_script_names` WHERE `spell_id`=68069;
-- DELETE FROM `smart_scripts` WHERE `entryorguid`=35769 AND `source_type`=0;
-- INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES (35769,0,0,0,19,0,100,0,14021,0,0,0,0,33,35816,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Foreman Dampwick');
-- DELETE FROM `gossip_menu_option` WHERE `MenuID`=10677 AND `OptionID`=0;
-- DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=15 AND `SourceGroup`=10677 AND `SourceEntry`=0;
-- DELETE FROM `creature_text` WHERE `CreatureID`=35813 AND `GroupID` IN (5,6);
