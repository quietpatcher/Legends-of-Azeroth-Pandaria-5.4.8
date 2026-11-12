-- Quest 13947 'Blastranaar!' (to-do 468), part 2/3: gossip option on Thraka (34429), the SmartAI that summons and flies the wyvern, the bomb targets and the kill credit.
-- derived, no sniff: option id 1 / chat icon / quest condition (QUESTTAKEN = quest incomplete) of the gossip option; the chain gossip -> 65478 (spawn) -> 65469 (ride, SAI cross cast instead of 65470 script effect) -> own SAI flight; return-to-base handling on spellhit 65481; the landing (remove 65469 from rider and wyvern, despawn);
--   kill credit via SMART_ACTION_CALL_KILLEDMONSTER on the spellhit of 28888 (blizzlike would be the spells 65530/65537, whose caster/target chain is not sniffed); sentinels/throwers set passive; phase mask 3 -> 2 handling of the wyvern.
-- Source: wiki warcraft.wiki.gg/wiki/Blastranaar! (gossip text), broadcast_text 34604, DBC 5.4.8 (Spell 65478, 65469, 65470, 65489, 65481, 28888, 65530, 65537), quest_objective 264982/264983 (34494 x20, 34492 x10), SmartAI precedents 30159 / 28665 (CAN_CONTROL vehicle + waypoints) and 28639 (actionlist after waypoint); state/blastranaar_468_bronnen.md.
-- Rollback: DELETE FROM `gossip_menu_option` WHERE `MenuID` = 10510 AND `OptionID` = 1; DELETE FROM `conditions` WHERE (`SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 10510 AND `SourceEntry` = 1) OR (`SourceTypeOrReferenceId` = 13 AND `SourceGroup` = 3 AND `SourceEntry` = 28888); UPDATE `creature_template` SET `AIName` = '' WHERE `entry` IN (34429,34494,34492); DELETE FROM `smart_scripts` WHERE (`entryorguid` IN (34429,34433,34494,34492) AND `source_type` = 0) OR (`entryorguid` BETWEEN 3443400 AND 3443403 AND `source_type` = 9);

DELETE FROM `gossip_menu_option` WHERE `MenuID` = 10510 AND `OptionID` = 1;
INSERT INTO `gossip_menu_option` (`MenuID`,`OptionID`,`OptionIcon`,`OptionText`,`OptionBroadcastTextID`,`OptionType`,`OptionNpcflag`,`ActionMenuID`,`ActionPoiID`,`BoxCoded`,`BoxMoney`,`BoxText`,`BoxBroadcastTextID`,`VerifiedBuild`) VALUES
(10510,1,0,'I am to bomb Astranaar! Captain Goggath''s orders.',34604,1,1,0,0,0,0,NULL,0,0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 10510 AND `SourceEntry` = 1;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceGroup` = 3 AND `SourceEntry` = 28888;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(15,10510,1,0,0,9,0,13947,0,0,0,0,0,'','Thraka gossip 1 (bomb Astranaar): only with quest 13947 taken and incomplete (derived, no sniff)'),
(13,3,28888,0,0,31,0,3,34494,0,0,0,0,'','Blastranaar Explosive Impact hits Astranaar Sentinel'),
(13,3,28888,0,1,31,0,3,34492,0,0,0,0,'','Blastranaar Explosive Impact hits Astranaar Thrower');

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` IN (34429,34494,34492) AND `AIName` = '';

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (34429,34433,34494,34492) AND `source_type` = 0;
DELETE FROM `smart_scripts` WHERE `entryorguid` BETWEEN 3443400 AND 3443403 AND `source_type` = 9;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(34429,0,0,1,62,0,100,0,10510,1,0,0,0,72,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Thraka - On Gossip Option 1 Selected (''I am to bomb Astranaar!'') - Close Gossip'),
(34429,0,1,0,61,0,100,0,0,0,0,0,0,85,65478,2,0,0,0,0,7,0,0,0,0,0,0,0,0,'Thraka - On Gossip Option 1 Selected - Invoker casts ''Summon Wind Rider'' (65478) on itself, wyvern spawns at spell_target_position'),
(34433,0,0,1,54,0,100,0,0,0,0,0,0,22,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Just Summoned - Set Event Phase 1 (flying)'),
(34433,0,1,2,61,0,100,0,0,0,0,0,0,44,3,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Just Summoned - Set Phase Mask 3 (visible for both mask 1 and the rider''s mask 2, so the ride aura is not removed by the phase switch; derived, no sniff)'),
(34433,0,2,3,61,0,100,0,0,0,0,0,0,67,1,10000,10000,0,0,100,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Just Summoned - Create Timed Event 1 (10 s: despawn when nobody boarded)'),
(34433,0,3,0,61,0,100,0,0,0,0,0,0,86,65469,2,23,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Just Summoned - Summoner casts ''Ride Wind Rider'' (65469) on the wyvern (control vehicle + phase aura 2/170)'),
(34433,0,4,5,27,1,100,0,0,0,0,0,0,74,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Passenger Boarded - Remove Timed Event 1'),
(34433,0,5,6,61,0,100,0,0,0,0,0,0,44,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Passenger Boarded - Set Phase Mask 2 (only the rider sees the wyvern; passenger follows, derived, no sniff)'),
(34433,0,6,0,61,0,100,0,0,0,0,0,0,80,3443400,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Passenger Boarded - Run Script ''Take off'''),
(34433,0,7,0,59,0,100,0,1,0,0,0,0,41,100,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Timed Event 1 - Despawn (no passenger boarded)'),
(34433,0,8,0,28,0,100,0,0,0,0,0,0,41,1500,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Passenger Removed - Despawn In 1500 ms'),
(34433,0,9,0,58,1,100,0,0,3443301,0,0,0,80,3443401,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Path 3443301 (approach) Ended - Run Script ''Start laps'' (after EndPath, never WP_START inside the ENDED handler)'),
(34433,0,10,11,58,1,100,0,0,3443302,0,0,0,22,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Path 3443302 (laps, 4x = own 180 s timeout, derived, no sniff) Ended - Set Event Phase 2 (returning)'),
(34433,0,11,0,61,0,100,0,0,0,0,0,0,80,3443402,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Path 3443302 Ended - Run Script ''Return to base'''),
(34433,0,12,13,8,1,100,0,65481,0,0,0,0,22,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Spellhit ''Return to Base!'' (65481) - Set Event Phase 2 (returning)'),
(34433,0,13,0,61,0,100,0,0,0,0,0,0,80,3443402,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Spellhit ''Return to Base!'' - Run Script ''Return to base'''),
(34433,0,14,0,58,2,100,0,0,3443303,0,0,0,80,3443403,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Path 3443303 (return) Ended - Run Script ''Land'''),
(3443400,9,0,0,0,0,100,0,1500,1500,0,0,0,53,1,3443301,0,0,0,0,1,0,0,0,0,0,0,0,0,'Take off - after 1.5 s start approach path 3443301 (run, no repeat, passive)'),
(3443401,9,0,0,0,0,100,0,100,100,0,0,0,53,1,3443302,0,0,0,0,1,0,0,0,0,0,0,0,0,'Start laps - start path 3443302 (4 laps over Astranaar, no repeat, passive)'),
(3443402,9,0,0,0,0,100,0,100,100,0,0,0,53,1,3443303,0,0,0,0,1,0,0,0,0,0,0,0,0,'Return to base - start path 3443303 (back to Thraka, no repeat, passive)'),
(3443403,9,0,0,0,0,100,0,800,800,0,0,0,28,65469,0,0,0,0,0,29,0,0,0,0,0,0,0,0,'Land - remove ''Ride Wind Rider'' (phase 2/170 part) from the rider in seat 0'),
(3443403,9,1,0,0,0,100,0,200,200,0,0,0,28,65469,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Land - remove ''Ride Wind Rider'' (control vehicle part) from the wyvern: rider steps off at Thraka'),
(3443403,9,2,0,0,0,100,0,1000,1000,0,0,0,41,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Land - despawn the wyvern'),
(34494,0,0,0,25,0,100,0,0,0,0,0,0,8,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Astranaar Sentinel - On Reset - Set React State Passive (do not attack the rider)'),
(34494,0,1,0,8,0,100,0,28888,0,0,0,0,33,34494,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Astranaar Sentinel - On Spellhit ''Blastranaar Explosive Impact'' (28888) - Kill Credit 34494 to the wyvern''s passenger (vehicle handling in CALL_KILLEDMONSTER; own route instead of 65530/65537, derived, no sniff)'),
(34492,0,0,0,25,0,100,0,0,0,0,0,0,8,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Astranaar Thrower - On Reset - Set React State Passive (do not attack the rider)'),
(34492,0,1,0,8,0,100,0,28888,0,0,0,0,33,34492,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Astranaar Thrower - On Spellhit ''Blastranaar Explosive Impact'' (28888) - Kill Credit 34492 to the wyvern''s passenger (vehicle handling in CALL_KILLEDMONSTER; own route instead of 65530/65537, derived, no sniff)');
