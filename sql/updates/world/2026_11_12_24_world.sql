-- To-do 468 (quest 13947 Blastranaar!), follow-up to 2026_11_12_23 after the last own-client test on dev: the passes repeat, but 'Return to Base!' (key 3)
-- does nothing and the 300 s failsafe never fired, so the rider could not leave the flight.
-- Return to Base! is spell 65481 (third button of the vehicle bar of 34433; DBC: dummy effect, target 1 = the caster, cooldown 45 s). It was handled by a
--   spellhit event of the wind rider, the failsafe by a timed event created in the 'Start laps' action list; neither is proven to run while a player
--   controls the vehicle and both were bound to event phase 1. The handlers that are proven are the waypoint-ended events (they returned the rider
--   after the 4th pass).
-- New: (a) a spell script (spell_ashenvale_blastranaar_return_to_base, in the core) on 65481 calls the rider's SmartAI DoAction(1), which fires
--   SMART_EVENT_ACTION_DONE 1 -> event phase 2 -> script 3443402 'Return to base' (the old spellhit handlers 12/13 stay as a second route);
--   (b) failsafe by laps: the 'path 3443302 ended' event counts finished rounds in counter 1 (reset to 0 when the passes start) and at 5 rounds
--   (about 6 minutes at 71 s per round) the rider returns by itself; the time-based failsafe is removed. Retail has no end other than the player
--   (comment on the quest: fly back and forth until enough is destroyed, key 3 returns), the 5 rounds are our guard, not from a source.
--   (c) the ended-handlers no longer require event phase 1/2 (path 3443302 only ends during the passes, 3443303 only during the return), so a lost
--   event phase cannot block them.
-- Source: DBC 5.4.8 spell 65481; SmartAI code paths (SmartAI::EndPath fires the waypoint-ended event, SmartAI::DoAction fires ACTION_DONE); quest 13947 comment on Wowhead.
-- Rollback: DELETE FROM `spell_script_names` WHERE `spell_id` = 65481 AND `ScriptName` = 'spell_ashenvale_blastranaar_return_to_base';
--   DELETE FROM `smart_scripts` WHERE `entryorguid` = 34433 AND `source_type` = 0 AND `id` IN (10,11,15,16,17,18);
--   UPDATE `smart_scripts` SET `event_phase_mask` = 2 WHERE `entryorguid` = 34433 AND `source_type` = 0 AND `id` = 14;
--   DELETE FROM `smart_scripts` WHERE `entryorguid` = 3443401 AND `source_type` = 9 AND `id` = 3; then re-insert the rows of 2026_11_12_23 for 34433 ids 15/16 and 3443401 id 3.

DELETE FROM `spell_script_names` WHERE `spell_id` = 65481;
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES (65481,'spell_ashenvale_blastranaar_return_to_base');

UPDATE `smart_scripts` SET `event_phase_mask` = 0 WHERE `entryorguid` = 34433 AND `source_type` = 0 AND `id` = 14;

DELETE FROM `smart_scripts` WHERE `entryorguid` = 3443401 AND `source_type` = 9 AND `id` = 3;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 34433 AND `source_type` = 0 AND `id` IN (10,11,15,16,17,18);
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(3443401,9,3,0,0,0,100,0,100,100,0,0,0,63,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,'Start laps - Set Counter 1 (finished rounds) to 0'),
(34433,0,10,0,58,0,100,0,0,3443302,0,0,0,63,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Path 3443302 (passes) Ended - Counter 1 + 1 (one round done)'),
(34433,0,11,15,77,0,100,0,1,5,0,0,0,22,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Counter 1 = 5 (5 rounds, about 6 minutes) - Set Event Phase 2 (returning)'),
(34433,0,15,0,61,0,100,0,0,0,0,0,0,80,3443402,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - After 5 rounds - Run Script ''Return to base'''),
(34433,0,17,18,72,0,100,0,1,0,0,0,0,22,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Action 1 (spell script of Return to Base!) - Set Event Phase 2 (returning)'),
(34433,0,18,0,61,0,100,0,0,0,0,0,0,80,3443402,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Furious Wind Rider - On Action 1 - Run Script ''Return to base''');
