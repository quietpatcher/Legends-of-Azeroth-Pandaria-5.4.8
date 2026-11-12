-- Lost Isles (goblin start): 14243 Warchief's Revenge.
--
-- Cause: Thrall (36161) gave the credit for the Alliance Sailor and teleported the goblin to the Wild Overlook the
--   moment the quest was accepted, and the objective had been cut down from 50 sailors to 1. On retail "accepting
--   the quest will buff players with Cyclone of the Elements and turn them into a tornado. Use the Lightning Strike
--   ability to kill Alliance sailors"; with 50 slain "the cyclone will automatically head to the Wild Overlook".
-- Fix: on accept the player casts 68408 Warchief's Revenge: Quest Accept (summons the vehicle Cyclone of the Elements
--   36178 and puts him on it, the core does that for a vehicle summon); the same on talking to Thrall again while
--   the quest is in progress (after a death or a relog; spell_lost_isles_warchiefs_revenge_accept refuses a second
--   cyclone); Thrall yells on accept; the objective is 50 again; npc_lost_isles_cyclone_of_the_elements lets the
--   quest script quest_lost_isles_warchiefs_revenge ends the ride: it takes the goblin
--   off the cyclone and to the Wild Overlook when the 50 are dead (and lets go of him when the quest is dropped). It is a
--   quest script because the cyclone is charmed by its rider (Vehicle::AddPassenger -> SetCharmedBy -> PossessedAI), so a
--   creature script on 36178 never gets UpdateAI or PassengerBoarded.
-- Source: wowpedia.fandom.com/wiki/Warchief's_Revenge (Objectives "Alliance Sailor slain x 50", Notes), quest log
--   text of 14243 ("slay 50 Alliance Sailors"), ref_sf quest_objective 14243 amount 50 and ref_cpp
--   RequiredNpcOrGoCount1 50, 5.4.8 client: Spell.dbc 68408 (summon 36178, summon properties 827 = vehicle category,
--   ride spell 68436), VehicleSeat 5746 of vehicle 508 (the passenger steers), creature_template 36178 spell1 68445.
--   The arrival at the Wild Overlook is still the teleport that was there (the flight has no source).
-- Needs the worldserver binary with these script names.
-- Rollback: the statements at the bottom of this file (commented out).

UPDATE `quest_objective` SET `amount`=50 WHERE `questId`=14243 AND `objectId`=36176 AND `type`=0;

UPDATE `quest_template_addon` SET `ScriptName`='quest_lost_isles_warchiefs_revenge' WHERE `ID`=14243;

DELETE FROM `spell_script_names` WHERE `spell_id`=68408;
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(68408,'spell_lost_isles_warchiefs_revenge_accept');

DELETE FROM `smart_scripts` WHERE `entryorguid`=36161 AND `source_type`=0;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(36161,0,0,1,19,0,100,0,14243,0,0,0,0,85,68408,2,0,0,0,0,7,0,0,0,0,0,0,0,0,'Thrall - On Quest ''Warchief''s Revenge'' Taken - Invoker Cast Warchief''s Revenge: Quest Accept'),
(36161,0,1,0,61,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Thrall - On Quest ''Warchief''s Revenge'' Taken - Say Line 0'),
(36161,0,2,0,64,0,100,0,0,0,0,0,0,85,68408,2,0,0,0,0,7,0,0,0,0,0,0,0,0,'Thrall - On Gossip Hello, Warchief''s Revenge in progress - Invoker Cast Warchief''s Revenge: Quest Accept');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=22 AND `SourceEntry`=36161;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(22,3,36161,0,0,47,0,14243,8,0,0,0,0,'','Thrall - a new cyclone only while Warchief''s Revenge is in progress');

-- Rollback:
-- UPDATE `quest_objective` SET `amount`=1 WHERE `questId`=14243 AND `objectId`=36176 AND `type`=0;
-- UPDATE `quest_template_addon` SET `ScriptName`='' WHERE `ID`=14243;
-- DELETE FROM `spell_script_names` WHERE `spell_id`=68408;
-- DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=22 AND `SourceEntry`=36161;
-- DELETE FROM `smart_scripts` WHERE `entryorguid`=36161 AND `source_type`=0;
-- INSERT INTO `smart_scripts` VALUES (36161,0,0,1,19,0,100,0,14243,0,0,0,0,33,36176,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Thrall');
-- INSERT INTO `smart_scripts` VALUES (36161,0,1,0,61,0,100,0,0,0,0,0,0,62,648,0,0,0,0,0,7,0,0,0,0,871.797,2768.51,119.17,0,'Thrall');
