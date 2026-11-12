-- 480 Whirling Vortex (34322): remove PLAYER_CONTROLLED flag (Creature::UpdateMovementFlags returns early), Ground=0, link On Summoned to Set Fly. Source: Creature.cpp:2927 + an internal proposal (client test pending)
-- Rollback: UPDATE `creature_template` SET `unit_flags` = 16810240 WHERE `entry` = 34322; UPDATE `creature_template_movement` SET `Ground` = 1, `Flight` = 2 WHERE `CreatureId` = 34322; DELETE FROM `smart_scripts` WHERE `entryorguid` = 34322 AND `source_type` = 0 AND `id` = 14; UPDATE `smart_scripts` SET `link` = 0 WHERE `entryorguid` = 34322 AND `source_type` = 0 AND `id` = 0;
-- 1. Remove UNIT_FLAG_PLAYER_CONTROLLED (0x01000000 = 16777216) from unit_flags:
--    16810240 -> 33024 (UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_CAN_SWIM)
UPDATE `world`.`creature_template` SET `unit_flags` = 33024 WHERE `entry` = 34322;

-- 2. Set Ground = 0 in creature_template_movement so creature defaults to Flight mode on spawn
UPDATE `world`.`creature_template_movement` SET `Ground` = 0, `Flight` = 2 WHERE `CreatureId` = 34322;

-- 3. In smart_scripts: link On Summoned (event 54, id 0) to Action 60 (Set Fly On)
UPDATE `world`.`smart_scripts` SET `link` = 14 WHERE `entryorguid` = 34322 AND `source_type` = 0 AND `id` = 0;

DELETE FROM `world`.`smart_scripts` WHERE `entryorguid` = 34322 AND `source_type` = 0 AND `id` = 14;
INSERT INTO `world`.`smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(34322, 0, 14, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 60, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Whirling Vortex - Linked To Id 0 - Set Fly On');
