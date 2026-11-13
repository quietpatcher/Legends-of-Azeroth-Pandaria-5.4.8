-- To-do 468 (quest 13947 Blastranaar!), reporter note 11-11 20:47 (sync99b): (a) the wind rider does not slow down over Astranaar,
-- (b) bombed Throwers jump again and do not despawn, (c) the elves do not die.
-- Cause (a): path 3443302 (the four passes over Astranaar, 1486 yd) and the approach path are flown at the same speed. Wyvern 34433 has
--   speed_run 4.0 (2026_11_09_04) and the addon aura 54950 (+100 percent, vehicle flight speed), so the flight speed is 4.0 * 2.0 * 7 = about 56 yd/s
--   (Unit::UpdateSpeed MOVE_FLIGHT, controlled by a player). The four passes therefore take about 26 s, shorter than the 30 bombs need (cooldown 2 s),
--   and the wyvern returns on its own. Flying creatures ignore the walk flag (SelectSpeedType), so SMART_ACTION_SET_RUN cannot slow them.
--   New core action SMART_ACTION_SET_SPEED_RATE (209): script 3443401 (start of the passes) sets the flight rate to 3.14 (about 22 yd/s, the passes
--   take about 67 s, videos 65-70 s); script 3443402 (return to base) sets 2.62 (about 18 yd/s, 366 yd in about 20 s, videos about 20 s back).
-- Cause (b)/(c): the bomb makes the Sentinel/Thrower a combat participant of the wind rider (spell on a hostile creature) which it cannot reach
--   (passive, the rider flies). CreatureAI::UpdateVictim -> SmartAI::EnterEvadeMode sets UNIT_STATE_EVADE, and Creature::Update skips
--   AI()->UpdateAI while IsInEvadeMode(), so the SmartAI timed event 'Die after 1.5 s' (2026_11_09_04) never ran until the creature had walked home,
--   and a second bomb knocked it back again. The old 'Die at once' worked only because it ran inside the spellhit. Fix: SMART_ACTION_DISABLE_EVADE (117)
--   on reset, so the creature stays in the AI loop and dies 1.5 s after the hit. The spellhit gets a 3 s cooldown (params 3/4) so a second bomb
--   within the 1.5 s does not give double kill credit or a second timer. This file is self-contained (it also contains the rows of 2026_11_09_04).
-- Source: code (Creature.cpp Creature::Update ALIVE case, SmartAI.cpp EnterEvadeMode/UpdateAI, Unit.cpp UpdateSpeed/SetSpeed, MoveSplineInit.cpp SelectSpeedType);
--   DBC 5.4.8 spell 28888 (effect 144 knockback 150, radius 10), 65489; quest videos (retail: about 65-70 s over Astranaar, about 20 s back).
--   Pass and return speeds follow the video timings (d9ZUrwW-Opk 1:22-1:42, 6wBmQ8-Qi9g 1:30-1:45 for the return); the 1.5 s / 3 s delays are our choice, derived, no sniff.
-- Rollback: DELETE FROM `smart_scripts` WHERE `entryorguid` IN (34494,34492) AND `source_type` = 0 AND `id` = 4;
--   UPDATE `smart_scripts` SET `event_param3` = 0, `event_param4` = 0 WHERE `entryorguid` IN (34494,34492) AND `source_type` = 0 AND `id` = 1;
--   DELETE FROM `smart_scripts` WHERE `entryorguid` IN (3443401,3443402) AND `source_type` = 9;
--   INSERT INTO `smart_scripts` VALUES (3443401,9,0,0,0,0,100,0,100,100,0,0,0,53,1,3443302,0,0,0,0,1,0,0,0,0,0,0,0,0,'Start laps - start path 3443302'),
--   (3443402,9,0,0,0,0,100,0,100,100,0,0,0,53,1,3443303,0,0,0,0,1,0,0,0,0,0,0,0,0,'Return to base - start path 3443303');

UPDATE `creature_template` SET `speed_run` = 4.0 WHERE `entry` = 34433;

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (34494,34492) AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(34494,0,0,0,25,0,100,0,0,0,0,0,0,8,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Astranaar Sentinel - On Reset - Set React State Passive (do not attack the rider)'),
(34494,0,1,2,8,0,100,0,28888,0,3000,3000,0,33,34494,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Astranaar Sentinel - On Spellhit ''Blastranaar Explosive Impact'' (28888, 3 s cooldown) - Kill Credit 34494 to the wyvern''s passenger (derived, no sniff)'),
(34494,0,2,0,61,0,100,0,0,0,0,0,0,67,1,1500,1500,0,0,100,1,0,0,0,0,0,0,0,0,'Astranaar Sentinel - On bomb impact - Create Timed Event 1 (1.5 s: knockback visible first)'),
(34494,0,3,0,59,0,100,0,1,0,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Astranaar Sentinel - On Timed Event 1 - Die'),
(34494,0,4,0,25,0,100,0,0,0,0,0,0,117,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Astranaar Sentinel - On Reset - Disable Evade (UNIT_STATE_EVADE stops UpdateAI, the timed Die never ran)'),
(34492,0,0,0,25,0,100,0,0,0,0,0,0,8,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Astranaar Thrower - On Reset - Set React State Passive (do not attack the rider)'),
(34492,0,1,2,8,0,100,0,28888,0,3000,3000,0,33,34492,0,0,0,0,0,7,0,0,0,0,0,0,0,0,'Astranaar Thrower - On Spellhit ''Blastranaar Explosive Impact'' (28888, 3 s cooldown) - Kill Credit 34492 to the wyvern''s passenger (derived, no sniff)'),
(34492,0,2,0,61,0,100,0,0,0,0,0,0,67,1,1500,1500,0,0,100,1,0,0,0,0,0,0,0,0,'Astranaar Thrower - On bomb impact - Create Timed Event 1 (1.5 s: knockback visible first)'),
(34492,0,3,0,59,0,100,0,1,0,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Astranaar Thrower - On Timed Event 1 - Die'),
(34492,0,4,0,25,0,100,0,0,0,0,0,0,117,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Astranaar Thrower - On Reset - Disable Evade (UNIT_STATE_EVADE stops UpdateAI, the timed Die never ran)');

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (3443401,3443402) AND `source_type` = 9;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(3443401,9,0,0,0,0,100,0,100,100,0,0,0,209,6,314,0,0,0,0,1,0,0,0,0,0,0,0,0,'Start laps - flight speed rate 3.14 (about 22 yd/s: 1486 yd in about 67 s, videos 65-70 s) over Astranaar'),
(3443401,9,1,0,0,0,100,0,100,100,0,0,0,53,1,3443302,0,0,0,0,1,0,0,0,0,0,0,0,0,'Start laps - start path 3443302 (4 passes over the main road, no repeat, passive)'),
(3443402,9,0,0,0,0,100,0,100,100,0,0,0,209,6,262,0,0,0,0,1,0,0,0,0,0,0,0,0,'Return to base - flight speed rate 2.62 (about 18 yd/s: 366 yd from the end of the passes in about 20 s, videos ~20 s)'),
(3443402,9,1,0,0,0,100,0,100,100,0,0,0,53,1,3443303,0,0,0,0,1,0,0,0,0,0,0,0,0,'Return to base - start path 3443303 (back to Thraka, no repeat, passive)');
