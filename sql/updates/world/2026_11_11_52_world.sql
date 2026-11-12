-- Kezan, quest 14126 Life Savings (goblin start): the ride to the yacht instead of a teleport.
--
-- Cause: the gossip of Sassy Hardwrench (menu 12493, "Okay, Sassy, I'm ready to go.") teleported the goblin onto the
--   deck of the yacht. On retail Sassy drives: "Hand over the keys, boss. I'm driving." The Hot Rod (37676, Sassy
--   37680 at the wheel) sprints down the highway, goes around the Kaja'Cola balloon that came down ("We'll have to go
--   around." / "OUT OF THE WAY!"), runs over whoever is in the way, jumps onto the deck and spins to a stop ("Here we
--   are, safe and... OH NO! We've been double-crossed!"). At Gallywix the ex has something to say ("We're through,
--   $n! I'm with Candy now." / "... with Chip now.").
--   The Rope Ladder (201791) and the Last Chance Yacht Boarding Mortar (207355) at the dock cast a script effect
--   (70389 / 92629) that nothing handled, so they did nothing.
-- Fix: the gossip makes the player cast 70318 Hand Over the Keys (spell_kezan_hand_over_the_keys summons the Hot Rod,
--   npc_kezan_life_savings_hot_rod drives it); texts for Sassy 37680; the knockback of this Hot Rod (70330, cone on
--   entry, no conditions = everything in the cone) hits Kezan Citizens only; spell_kezan_yacht_boarding makes ladder
--   and mortar throw the player onto the deck (70390 / 92633, their spell_target_position rows exist); the two
--   leftover spawns of the temporary Hot Rod and its driver (phase 1) are removed; Chip and Candy on the yacht speak.
-- Source: wowwiki-archive.fandom.com/wiki/Quest:Life_Savings (Dialogue, "On the trip"), wowhead.com/quest=14126,
--   5.4.8 client Spell.dbc (70318 dummy on the caster, 70321 summon 37676 with ride spell 66724 Sassy's Driving,
--   70329 periodic trigger of 70330 knockback cone entry, 70325 skid, 70389/92629 script effect, 70390/92633 jump to
--   a DB destination), broadcast_text 37257/37258/37259/49306/49307. The route itself has no source (no sniff): it is
--   laid over sniffed ground positions (the pile-up of Goblin Hot Rods 49131 on the highway, Kezan Citizens of the
--   last phase, the Villa Mooks at the dock, the mortar); start and end are the sniffed spots of 371541 and 371544.
-- Needs the worldserver binary with these script names.
-- Rollback: the statements at the bottom of this file (commented out).

-- Sassy Hardwrench: the gossip hands over the keys (invoker casts 70318 on himself, triggered)
UPDATE `smart_scripts` SET `action_type`=85, `action_param1`=70318, `action_param2`=2, `target_x`=0, `target_y`=0, `target_z`=0,
  `comment`='Sassy Hardwrench - On Gossip Option 0 Selected - Invoker Cast Life Savings: Hand Over the Keys'
  WHERE `entryorguid`=34668 AND `source_type`=0 AND `id`=0 AND `event_type`=62;
UPDATE `smart_scripts` SET `comment`='Sassy Hardwrench - On Gossip Option 0 Selected - Close Gossip'
  WHERE `entryorguid`=34668 AND `source_type`=0 AND `id`=1 AND `event_type`=61;

UPDATE `creature_template` SET `ScriptName`='npc_kezan_life_savings_hot_rod' WHERE `entry`=37676;

DELETE FROM `spell_script_names` WHERE `spell_id` IN (70318,70389,92629);
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(70318,'spell_kezan_hand_over_the_keys'),
(70389,'spell_kezan_yacht_boarding'),
(92629,'spell_kezan_yacht_boarding');

-- the driver
DELETE FROM `creature_text` WHERE `CreatureID`=37680;
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(37680,0,0,'We''ll have to go around.',12,0,100,0,0,0,0,37257,0,'Sassy Hardwrench - Life Savings, the balloon on the highway'),
(37680,1,0,'OUT OF THE WAY!',14,0,100,0,0,0,0,37258,0,'Sassy Hardwrench - Life Savings, the pile-up'),
(37680,2,0,'Here we are, safe and... OH NO! We''ve been double-crossed!',12,0,100,0,0,0,0,37259,0,'Sassy Hardwrench - Life Savings, on the deck');

-- 70330 Life Savings: Hot Rod - Knockback, effect 0: Kezan Citizen 35063 / 35075
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=13 AND `SourceEntry`=70330;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(13,1,70330,0,0,31,0,3,35063,0,0,0,0,'','Life Savings: Hot Rod - Knockback hits Kezan Citizen'),
(13,1,70330,0,1,31,0,3,35075,0,0,0,0,'','Life Savings: Hot Rod - Knockback hits Kezan Citizen');

-- leftover spawns of the temporary Hot Rod (on the deck) and its driver (in the yard), both in phase 1
DELETE FROM `creature` WHERE `guid`=371541 AND `id`=37680;
DELETE FROM `creature` WHERE `guid`=371544 AND `id`=37676;

-- Chip Endale (guid 230649) and Candy Cane (guid 230611) on the yacht: the ex speaks when the goblin walks up
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (35053,35054) AND `ScriptName`='';
DELETE FROM `creature_text` WHERE (`CreatureID`=35054 AND `GroupID`=2) OR (`CreatureID`=35053 AND `GroupID`=3);
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(35054,2,0,'We''re through, $n! I''m with Candy now.',12,0,100,0,0,0,0,49307,0,'Chip Endale - Life Savings, on the yacht'),
(35053,3,0,'We''re through, $n! I''m with Chip now.',12,0,100,0,0,0,0,49306,0,'Candy Cane - Life Savings, on the yacht');
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (-230649,-230611) AND `source_type`=0;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(-230649,0,0,0,10,0,100,0,1,10,120000,120000,1,1,2,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Chip Endale (yacht) - OOC LOS, female player on Life Savings - Say Line 2'),
(-230611,0,0,0,10,0,100,0,1,10,120000,120000,1,1,3,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Candy Cane (yacht) - OOC LOS, male player on Life Savings - Say Line 3');
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=22 AND `SourceEntry` IN (-230649,-230611);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(22,1,-230649,0,0,20,0,1,0,0,0,0,0,'','Chip Endale (yacht) speaks to a female player'),
(22,1,-230649,0,0,47,0,14126,10,0,0,0,0,'','Chip Endale (yacht) speaks while Life Savings is in the log'),
(22,1,-230611,0,0,20,0,0,0,0,0,0,0,'','Candy Cane (yacht) speaks to a male player'),
(22,1,-230611,0,0,47,0,14126,10,0,0,0,0,'','Candy Cane (yacht) speaks while Life Savings is in the log');

-- Rollback:
-- UPDATE `smart_scripts` SET `action_type`=62, `action_param1`=648, `action_param2`=0, `target_x`=-7850.39, `target_y`=1840.03, `target_z`=7.60943, `comment`='Sassy Hardwrench' WHERE `entryorguid`=34668 AND `source_type`=0 AND `id`=0 AND `event_type`=62;
-- UPDATE `smart_scripts` SET `comment`='Sassy Hardwrench' WHERE `entryorguid`=34668 AND `source_type`=0 AND `id`=1 AND `event_type`=61;
-- UPDATE `creature_template` SET `ScriptName`='' WHERE `entry`=37676;
-- DELETE FROM `spell_script_names` WHERE `spell_id` IN (70318,70389,92629);
-- DELETE FROM `creature_text` WHERE `CreatureID`=37680;
-- DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=13 AND `SourceEntry`=70330;
-- DELETE FROM `smart_scripts` WHERE `entryorguid` IN (-230649,-230611) AND `source_type`=0;
-- DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=22 AND `SourceEntry` IN (-230649,-230611);
-- DELETE FROM `creature_text` WHERE (`CreatureID`=35054 AND `GroupID`=2) OR (`CreatureID`=35053 AND `GroupID`=3);
-- UPDATE `creature_template` SET `AIName`='' WHERE `entry` IN (35053,35054);
-- INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawntimesecs_max`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `npcflag2`, `unit_flags`, `unit_flags2`, `dynamicflags`, `ScriptName`, `walk_mode`, `VerifiedBuild`) VALUES (371541,37680,648,4737,4765,0,1,0,0,0,0,-8408.95,1320.89,103.067,0.565413,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0);
-- INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawntimesecs_max`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `npcflag2`, `unit_flags`, `unit_flags2`, `dynamicflags`, `ScriptName`, `walk_mode`, `VerifiedBuild`) VALUES (371544,37676,648,4737,4838,0,1,0,0,0,0,-7849.34,1841.15,7.60784,0.146732,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0);
