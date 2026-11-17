-- #487: Eversong Ranger (15938) shot once on aggro and then stood still with the bow drawn against the Dead Scar undead.
-- Cause: the aggro link raised the event phase 0 -> 1 (action 23), but every combat row (shoot, sheath swap, combat
-- movement, start attacking) carried event_phase_mask 2, so IsInPhase() never matched and none of them fired.
-- Fix: standard ranged-NPC pattern (shoot 5-30 yd, close in when out of range, swords + melee within 10 yd, flee at 15%),
-- all rows in phase 1, phase reset on evade.
-- Source: Wowhead NPC 15938 (Eversong Ranger: ranged Shoot, bow + swords); SmartAI pattern as used by TrinityCore for
-- ranged NPCs such as 5251/7939 (comparison material). Retail combat timers unknown without a sniff (2.3-3.9 s used).

DELETE FROM `smart_scripts` WHERE `entryorguid` = 15938 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(15938, 0, 0, 1, 4, 0, 100, 1, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Aggro - Disable Combat Movement (No Repeat)'),
(15938, 0, 1, 2, 61, 0, 100, 1, 0, 0, 0, 0, 0, 11, 6660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Aggro - Cast \'Shoot\' (No Repeat)'),
(15938, 0, 2, 3, 61, 0, 100, 1, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Aggro - Stop Attacking (No Repeat)'),
(15938, 0, 3, 0, 61, 0, 100, 1, 0, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Aggro - Set Event Phase 1 (No Repeat)'),
(15938, 0, 4, 5, 9, 1, 100, 0, 5, 30, 2300, 3900, 0, 11, 6660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 5-30 Range - Cast \'Shoot\' (Phase 1)'),
(15938, 0, 5, 0, 61, 1, 100, 0, 5, 30, 2300, 3900, 0, 40, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 5-30 Range - Set Sheath Ranged (Phase 1)'),
(15938, 0, 6, 7, 9, 1, 100, 0, 30, 80, 2000, 2000, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 30-80 Range - Enable Combat Movement (Phase 1)'),
(15938, 0, 7, 0, 61, 1, 100, 0, 30, 80, 0, 0, 0, 20, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 30-80 Range - Start Attacking (Phase 1)'),
(15938, 0, 8, 9, 9, 1, 100, 0, 0, 10, 2000, 2000, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 0-10 Range - Enable Combat Movement (Phase 1)'),
(15938, 0, 9, 10, 61, 1, 100, 0, 0, 10, 0, 0, 0, 40, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 0-10 Range - Set Sheath Melee (Phase 1)'),
(15938, 0, 10, 0, 61, 1, 100, 0, 0, 10, 0, 0, 0, 20, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 0-10 Range - Start Attacking (Phase 1)'),
(15938, 0, 11, 12, 9, 1, 100, 0, 11, 25, 2000, 2000, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 11-25 Range - Disable Combat Movement (Phase 1)'),
(15938, 0, 12, 13, 61, 1, 100, 0, 11, 25, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 11-25 Range - Stop Attacking (Phase 1)'),
(15938, 0, 13, 0, 61, 1, 100, 0, 11, 25, 0, 0, 0, 40, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 11-25 Range - Set Sheath Ranged (Phase 1)'),
(15938, 0, 14, 15, 7, 1, 100, 1, 0, 0, 0, 0, 0, 40, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Evade - Set Sheath Melee (Phase 1) (No Repeat)'),
(15938, 0, 15, 0, 61, 1, 100, 1, 0, 0, 0, 0, 0, 22, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Evade - Set Event Phase 0 (Phase 1) (No Repeat)'),
(15938, 0, 16, 0, 2, 1, 100, 1, 0, 15, 0, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Between 0-15% Health - Set Event Phase 2 (Phase 1) (No Repeat)'),
(15938, 0, 17, 18, 2, 2, 100, 1, 0, 15, 0, 0, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Between 0-15% Health - Enable Combat Movement (Phase 2) (No Repeat)'),
(15938, 0, 18, 0, 61, 2, 100, 1, 0, 0, 0, 0, 0, 25, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Between 0-15% Health - Flee For Assist (Phase 2) (No Repeat)'),
(15938, 0, 19, 20, 7, 2, 100, 1, 0, 0, 0, 0, 0, 40, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Evade - Set Sheath Melee (Phase 2) (No Repeat)'),
(15938, 0, 20, 0, 61, 2, 100, 1, 0, 0, 0, 0, 0, 22, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Evade - Set Event Phase 0 (Phase 2) (No Repeat)');
-- Rollback (original 15 rows): DELETE FROM smart_scripts WHERE entryorguid=15938 AND source_type=0; then re-insert:
-- INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
-- (15938, 0, 0, 1, 1, 0, 100, 0, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Out of Combat - Disable Combat Movement'),
-- (15938, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Out of Combat - Stop Attacking'),
-- (15938, 0, 2, 3, 4, 0, 100, 0, 0, 0, 0, 0, 0, 11, 6660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Aggro - Cast \'Shoot\''),
-- (15938, 0, 3, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 23, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Aggro - Increment Phase By 1'),
-- (15938, 0, 4, 5, 9, 2, 100, 0, 5, 30, 3400, 3700, 0, 11, 6660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 5-30 Range - Cast \'Shoot\' (Phase 2)'),
-- (15938, 0, 5, 0, 61, 2, 100, 0, 0, 0, 0, 0, 0, 40, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 5-30 Range - Set Sheath Ranged (Phase 2)'),
-- (15938, 0, 6, 0, 9, 2, 100, 0, 25, 80, 0, 0, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 25-80 Range - Enable Combat Movement (Phase 2)'),
-- (15938, 0, 7, 0, 9, 2, 100, 0, 0, 5, 0, 0, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 0-5 Range - Enable Combat Movement (Phase 2)'),
-- (15938, 0, 8, 9, 9, 2, 100, 0, 0, 0, 0, 0, 0, 40, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 0-0 Range - Set Sheath Melee (Phase 2)'),
-- (15938, 0, 9, 0, 61, 2, 100, 0, 0, 0, 0, 0, 0, 20, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 0-0 Range - Start Attacking (Phase 2)'),
-- (15938, 0, 10, 0, 9, 2, 100, 0, 5, 15, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Within 5-15 Range - Disable Combat Movement (Phase 2)'),
-- (15938, 0, 11, 0, 2, 0, 100, 1, 0, 15, 0, 0, 0, 23, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Between 0-15% Health - Increment Phase By 1 (Phase 2)'),
-- (15938, 0, 12, 13, 2, 0, 100, 1, 0, 15, 0, 0, 0, 21, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Between 0-15% Health - Enable Combat Movement (No Repeat)'),
-- (15938, 0, 13, 0, 61, 0, 100, 1, 0, 0, 0, 0, 0, 25, 1, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - Between 0-15% Health - Flee For Assist (No Repeat)'),
-- (15938, 0, 14, 0, 7, 0, 100, 0, 0, 0, 0, 0, 0, 40, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eversong Ranger - On Evade - Set Sheath Melee (No Repeat)');
