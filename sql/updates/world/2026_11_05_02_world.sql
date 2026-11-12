-- SI7-BLIZZ 29727 SI:7 Report: Take No Prisoners (Pearlfin Village): the Amber scene (The Debriefing 04) made playable along the retail mechanics.
-- (1) Amber vehicle 55405 VehicleId 1794 -> 1777: 1794 (seat 10307, 0x200c063) has CAN_ATTACK but no CAN_CONTROL, so the core never charms the player and no Sniper Shot bar is sent (the same failure as Rell with 1771, proven on dev 4-11); by creature entry order 55405 lies between 55403 (= 1776) and 55415 (= 1780), and 1777 (seats 10248 0xe2100a06 CAN_CONTROL + 10252) is the first controllable one in 1777-1779; the two seats match the retail "Force Switch to Seat 1/2" spells 103820/103825 of this scene.
-- (2) Pearlfin Amber 55283 keeps herself grid-active while the Debriefing list waits, teleport -> summon delay 2500 -> 10000 ms (same fix as 29733).
-- (3) The stage counters never advanced: SMART_ACTION_SET_COUNTER ignores its target (SmartScript.cpp StoreCounter on the own script), so the guards counted on themselves. Now every guard/barrel/orc sends SET_DATA to Sully 55408 on death and Sully adds to his own counters (the pattern proven for 29733 in 2026_11_04_11).
-- (4) The wandering guards of stage B are the retail entry 55484 "Grookin Whomper" (103854 The Debriefing 04: Summon Hozen Guard, Wander) instead of 55473 (103839 = charge stage 5); 55484 gets the same combat data as 55411 (faction 14, Health_mod 0.05) and the same SmartAI.
-- (5) Vehicle events need SMART_EVENT_FLAG_WHILE_CHARMED (512); failsafe after 15 minutes in the vehicle: teleport back and despawn, no credit.
-- Source: 5.4.8 Spell.dbc/SpellEffect.dbc (103608/103609/103616/103620/103621 Sniper Shot 269999 dmg, 103629/103854/103839/103867/103906 summons, 103820/103825), Vehicle.dbc/VehicleSeat.dbc 18414 (1776-1780, 1794), video https://www.youtube.com/watch?v=HLplKibsp_A + whisper transcript, SmartScript.cpp (SET_COUNTER), dev tests 4-11 (29733 counter fix).
-- DERIVED (no sniff): VehicleId 1777, stage composition and positions (unchanged from 2026_11_03_03), failsafe 900 s. NOT built: Shooting Sully 103841/103842 + Sully's unit frame 103843 (Sully 55408 stays immune, unit_flags 768), the 30/35 s timers 103849/103871, the Hozen Guard Check 103794, the sniper rifle 103619 as a second vehicle.
-- (correction 5-11-2026 02:28, dev test 29725) event_flags 512 is NOT "while charmed" on this core: SmartScriptMgr.h has no such flag, 0x200 = SMART_EVENT_FLAG_DIFFICULTY_RAID40, so flagged rows never ran on map 870. The vehicle rows below now use flags 0/1; SmartScript::ProcessEvent has no charm check, vehicle events fire while the player drives.
-- Rollback: UPDATE `creature_template` SET `VehicleId` = 1794 WHERE `entry` = 55405; UPDATE `creature_template` SET `faction` = 35, `Health_mod` = 1, `AIName` = '' WHERE `entry` = 55484; DELETE FROM `smart_scripts` WHERE (`source_type` = 0 AND `entryorguid` = 55484) OR (`source_type` = 0 AND `entryorguid` = 55405 AND `id` >= 2) OR (`source_type` = 0 AND `entryorguid` = 55408 AND `id` >= 4) OR (`source_type` = 9 AND `entryorguid` = 5540501); UPDATE `smart_scripts` SET `event_flags` = 0 WHERE `source_type` = 0 AND `entryorguid` = 55405 AND `id` = 1; UPDATE `smart_scripts` SET `action_type` = 63, `action_param2` = 1 WHERE `source_type` = 0 AND `id` = 0 AND `entryorguid` IN (55410, 55411, 55473, 55498); UPDATE `smart_scripts` SET `action_param1` = 55473 WHERE `source_type` = 9 AND `entryorguid` = 5540800 AND `id` IN (7, 8); then restore list 5528300 from 2026_11_03_03_world.sql (or ~/backup/si7blizz_pre_2026_11_05_02.sql on dev).

-- (1) controllable vehicle
UPDATE `creature_template` SET `VehicleId` = 1777 WHERE `entry` = 55405;

-- (2) Pearlfin Amber: set active, teleport, 10 s later the vehicle, set inactive again
DELETE FROM `smart_scripts` WHERE `source_type` = 9 AND `entryorguid` = 5528300;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(5528300, 9, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 48, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, "Amber (Pearlfin) timed - Set active (grid keeps updating while the invoker is away)"),
(5528300, 9, 1, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 85, 103608, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, "Amber (Pearlfin) timed - Invoker casts The Debriefing 04: Teleport In"),
(5528300, 9, 2, 0, 0, 0, 100, 0, 10000, 10000, 0, 0, 0, 85, 103609, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, "Amber (Pearlfin) timed - Invoker casts The Debriefing 04: Summon Amber Vehicle (boards via 103616 Amber's Report)"),
(5528300, 9, 3, 0, 0, 0, 100, 0, 2000, 2000, 0, 0, 0, 48, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, "Amber (Pearlfin) timed - Set inactive again");

-- (3) counters: deaths report to Sully, Sully counts on himself
UPDATE `smart_scripts` SET `action_type` = 45, `action_param1` = 1, `action_param2` = 1, `comment` = "Grookin Whomper (idle) - On Death - Data 1/1 to Sully (he counts stage A)" WHERE `source_type` = 0 AND `entryorguid` = 55411 AND `id` = 0;
UPDATE `smart_scripts` SET `action_type` = 45, `action_param1` = 2, `action_param2` = 1, `comment` = "Sully's Bomb Barrel - On Death - Data 2/1 to Sully (he counts stage B)" WHERE `source_type` = 0 AND `entryorguid` = 55410 AND `id` = 0;
UPDATE `smart_scripts` SET `action_type` = 45, `action_param1` = 2, `action_param2` = 1, `comment` = "Grookin Whomper (charge) - On Death - Data 2/1 to Sully (he counts stage B)" WHERE `source_type` = 0 AND `entryorguid` = 55473 AND `id` = 0;
UPDATE `smart_scripts` SET `action_type` = 45, `action_param1` = 3, `action_param2` = 1, `comment` = "Hellscream's Vanguard - On Death - Data 3/1 to Sully (he counts stage C)" WHERE `source_type` = 0 AND `entryorguid` = 55498 AND `id` = 0;
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 55408 AND `id` >= 4;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(55408, 0, 4, 0, 38, 0, 100, 0, 1, 1, 0, 0, 0, 63, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, "Sully - On Data 1/1 (a stage A guard died) - Add 1 to counter 1"),
(55408, 0, 5, 0, 38, 0, 100, 0, 2, 1, 0, 0, 0, 63, 2, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, "Sully - On Data 2/1 (a barrel or stage B guard died) - Add 1 to counter 2"),
(55408, 0, 6, 0, 38, 0, 100, 0, 3, 1, 0, 0, 0, 63, 3, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, "Sully - On Data 3/1 (a Vanguard orc died) - Add 1 to counter 3");

-- (4) retail wander guard 55484
UPDATE `creature_template` SET `faction` = 14, `Health_mod` = 0.05, `AIName` = 'SmartAI' WHERE `entry` = 55484;
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 55484;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(55484, 0, 0, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 45, 2, 1, 0, 0, 0, 0, 19, 55408, 400, 0, 0, 0, 0, 0, 0, "Grookin Whomper (wander) - On Death - Data 2/1 to Sully (he counts stage B)"),
(55484, 0, 1, 0, 38, 0, 100, 0, 9, 1, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, "Grookin Whomper (wander) - On Data 9 - Despawn");
UPDATE `smart_scripts` SET `action_param1` = 55484, `comment` = "Sully stage B - Summon wandering guard (103854 Summon Hozen Guard, Wander = 55484)" WHERE `source_type` = 9 AND `entryorguid` = 5540800 AND `id` IN (7, 8);

-- (5) vehicle: charm flag, failsafe
UPDATE `smart_scripts` SET `event_flags` = 0 WHERE `source_type` = 0 AND `entryorguid` = 55405 AND `id` = 1;
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 55405 AND `id` >= 2;
DELETE FROM `smart_scripts` WHERE `source_type` = 9 AND `entryorguid` = 5540501;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(55405, 0, 2, 0, 60, 0, 100, 1, 900000, 900000, 0, 0, 0, 80, 5540501, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, "Amber (vehicle) - 15 min after summon (failsafe, no credit) - Teleport back and clean up"),
(5540501, 9, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 62, 870, 0, 0, 0, 0, 0, 17, 0, 400, 0, 0, -163.0, -2662.0, 1.03, 4.0, "Amber (vehicle) failsafe - Teleport the player back to Pearlfin Village"),
(5540501, 9, 1, 0, 0, 0, 100, 0, 1000, 1000, 0, 0, 0, 45, 9, 1, 0, 0, 0, 0, 9, 55411, 0, 400, 0, 0, 0, 0, 0, "Amber (vehicle) failsafe - Despawn idle guards"),
(5540501, 9, 2, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 45, 9, 1, 0, 0, 0, 0, 9, 55484, 0, 400, 0, 0, 0, 0, 0, "Amber (vehicle) failsafe - Despawn wander guards"),
(5540501, 9, 3, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 45, 9, 1, 0, 0, 0, 0, 9, 55473, 0, 400, 0, 0, 0, 0, 0, "Amber (vehicle) failsafe - Despawn charge guards"),
(5540501, 9, 4, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 45, 9, 1, 0, 0, 0, 0, 9, 55410, 0, 400, 0, 0, 0, 0, 0, "Amber (vehicle) failsafe - Despawn barrels"),
(5540501, 9, 5, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 45, 9, 1, 0, 0, 0, 0, 9, 55498, 0, 400, 0, 0, 0, 0, 0, "Amber (vehicle) failsafe - Despawn Vanguard"),
(5540501, 9, 6, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 45, 9, 1, 0, 0, 0, 0, 9, 55408, 0, 400, 0, 0, 0, 0, 0, "Amber (vehicle) failsafe - Despawn Sully"),
(5540501, 9, 7, 0, 0, 0, 100, 0, 1000, 1000, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, "Amber (vehicle) failsafe - Despawn vehicle");
