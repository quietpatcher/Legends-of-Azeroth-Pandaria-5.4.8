-- The Lost Isles (goblin start): Goblin Escape Pods (14001 / 14474).
-- What a player sees: Geargrinder Gizmo (36600) says nothing when the quest is taken, and every Goblin Escape Pod
--   (195188) the goblin opens lets a silent Trade Prince Gallywix (35649) out, six times in a row. No Goblin
--   Survivor ever comes out of a pod and none of their lines is heard.
-- Cause: Gizmo has no script for the accept line (creature_text group 0 exists but nothing uses it). The pod script
--   gives the credit and then always summons Gallywix for 30 seconds; nothing makes him or a survivor speak.
-- Change:
--   * Gizmo gets SmartAI: on accept of 14001 or 14474 he says his line (group 0) to the goblin.
--   * The pod keeps giving the credit "Goblin Survivors Rescued" on every pod (unchanged). The first pod of a goblin
--     lets Trade Prince Gallywix out, who says his line; that goblin then gets the hidden aura 67433 (Goblin Escape
--     Pods: Trade Prince Controller Aura). Every later pod lets a Goblin Survivor (34748) out, who says one of the
--     eight survivor lines (new creature_text group 7; the old groups 0-6 stay as they are).
--   * Both stay 60 seconds instead of 30 (duration of the summon spells 67845 and 66137 in the client data).
--   * spell_area rows (no autocast) tie aura 67433 to the quest: it goes when the quest is handed in or dropped, as
--     the Thermohydratic Flippers (68258) do, so a goblin who takes the quest again meets Gallywix first again.
-- Not changed: which goblin gets 14001 and which 14474 (see Source), the pods themselves, the credit per pod.
-- Source: warcraft.wiki.gg/wiki/Goblin_Escape_Pods and wowwiki-archive.fandom.com/wiki/Quest:Goblin_Escape_Pods
--   (Notes: Gizmo's line on accept; "The first goblin the player rescues will always be Gallywix" with his line;
--   Goblin Survivors follow with one of eight lines), wowhead.com/quest=14001 (comment of 13-12-2010, patch 4.0.3:
--   the first escape pod is Gallywix's; comment of 19-05-2014, patch 5.4.7: the two quests are gender specific),
--   broadcast_text 49824, 35947 and 35002-35009, 5.4.8 client data (Spell.dbc, SpellEffect.dbc, SpellMisc.dbc,
--   SpellDuration.dbc): 67845 summons 35649 and 66137 summons 34748, both duration index 3 = 60 s; 67433 is a
--   hidden dummy aura without duration. That 67433 is the marker for "Gallywix already freed" is read from its
--   name only; the summons are done by the pod itself instead of through 67845 / 66137 (same creature, same place).
--   Unknown and left as it was: whether the pod of Gallywix counts for the six, what a survivor does after his
--   line, and when a dead survivor (66138, creature 34736) comes out.
-- Rollback:
--   UPDATE `creature_template` SET `AIName`='' WHERE `entry`=36600;
--   DELETE FROM `smart_scripts` WHERE `entryorguid`=36600 AND `source_type`=0;
--   DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=22 AND `SourceEntry`=195188 AND `SourceId`=1;
--   DELETE FROM `creature_text` WHERE `CreatureID`=34748 AND `GroupID`=7;
--   DELETE FROM `spell_area` WHERE `spell`=67433 AND `area`=4720;
--   DELETE FROM `smart_scripts` WHERE `entryorguid`=195188 AND `source_type`=1;
--   INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
--   (195188,1,0,1,70,0,100,0,2,0,0,0,0,33,34748,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Goblin Escape Pod'),
--   (195188,1,1,0,61,0,100,0,0,0,0,0,0,12,35649,1,30000,0,0,0,1,0,0,0,0,0,0,0,0,'Goblin Escape Pod');

-- Geargrinder Gizmo: line on accept
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry`=36600;

DELETE FROM `smart_scripts` WHERE `entryorguid`=36600 AND `source_type`=0;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(36600,0,0,0,19,0,100,0,14001,0,0,0,0,1,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Geargrinder Gizmo - On Quest ''Goblin Escape Pods'' (14001) Taken - Say Line 0'),
(36600,0,1,0,19,0,100,0,14474,0,0,0,0,1,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Geargrinder Gizmo - On Quest ''Goblin Escape Pods'' (14474) Taken - Say Line 0');

-- Goblin Survivor: the eight lines in one group, so that one is picked at random
DELETE FROM `creature_text` WHERE `CreatureID`=34748 AND `GroupID`=7;
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`)
SELECT 34748, 7, `ID`-35002, `Text`, 12, 0, 100, 5, 0, 0, 0, `ID`, 0, 'Goblin Survivor to Player - freed from an escape pod'
  FROM `broadcast_text` WHERE `ID` BETWEEN 35002 AND 35009;

-- Goblin Escape Pod: credit on every pod; Gallywix out of the first, a Goblin Survivor out of the others
DELETE FROM `smart_scripts` WHERE `entryorguid`=195188 AND `source_type`=1;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(195188,1,0,0,70,0,100,0,2,0,0,0,0,33,34748,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Goblin Escape Pod - On Activated - Quest Credit ''Goblin Survivors Rescued'''),
(195188,1,1,2,70,0,100,0,2,0,0,0,0,12,34748,1,60000,0,0,0,1,0,0,0,0,0,0,0,0,'Goblin Escape Pod - On Activated (invoker has aura 67433) - Summon Goblin Survivor'),
(195188,1,2,0,61,0,100,0,0,0,0,0,0,1,7,0,0,0,0,0,19,34748,5,0,0,0,0,0,0,'Goblin Escape Pod - Linked - Goblin Survivor Says Random Line To Invoker'),
(195188,1,3,4,70,0,100,0,2,0,0,0,0,12,35649,1,60000,0,0,0,1,0,0,0,0,0,0,0,0,'Goblin Escape Pod - On Activated (invoker has no aura 67433) - Summon Trade Prince Gallywix'),
(195188,1,4,5,61,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,19,35649,5,0,0,0,0,0,0,'Goblin Escape Pod - Linked - Trade Prince Gallywix Says Line 0 To Invoker'),
(195188,1,5,0,61,0,100,0,0,0,0,0,0,75,67433,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Goblin Escape Pod - Linked - Add Aura ''Trade Prince Controller Aura'' To Invoker');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=22 AND `SourceEntry`=195188 AND `SourceId`=1;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(22,2,195188,1,0,1,0,67433,0,0,0,0,0,'','Goblin Escape Pod - a Goblin Survivor only for a goblin who has freed the Trade Prince (aura 67433)'),
(22,4,195188,1,0,1,0,67433,0,0,1,0,0,'','Goblin Escape Pod - Trade Prince Gallywix only for a goblin who has not freed him yet (no aura 67433)');

-- The marker aura lasts as long as the quest is in the log
DELETE FROM `spell_area` WHERE `spell`=67433 AND `area`=4720;
INSERT INTO `spell_area` (`spell`,`area`,`quest_start`,`quest_end`,`aura_spell`,`racemask`,`gender`,`autocast`,`quest_start_status`,`quest_end_status`) VALUES
(67433,4720,14001,14001,0,0,2,0,74,11),
(67433,4720,14474,14474,0,0,2,0,74,11);
