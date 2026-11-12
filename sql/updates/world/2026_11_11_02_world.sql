-- Northwatch Foothold (Durotar, to-do 228): the Northwatch Lug supply carriers walk one way from the landing ships to the supply
-- tent and vanish there with their crate, as the reporter saw on retail; the 15 sniff duplicates that wandered around with a
-- crate (MovementType 1) are removed, two carrier pairs spawn at the ships with staggered respawn (120/180 s) on the one-way path
-- 2527450 (the reverse points 11-18 and the duplicate paths 2527740/2528320 are gone), point 10 runs waypoint_scripts 2527450
-- (despawn self), and destroying the carried Northwatch Supply Crate (39251) kills its carrier (Breaking the Chain, 25167).
-- The crate keeps riding on vehicle 1328 seat 0 (vehicle_template_accessory, unchanged).
-- Source: reporter's retail observation (to-do 228), Wowpedia Northwatch Lug / Breaking the Chain (crate crushes the lug);
--   spawn layout = sniffed pairs along the ship-tent line (creature 39249, 19 rows). Proposal: the internal notes.
-- Rollback: the internal notes (restores all 19 spawns, addons, the three paths and the
--   crate SmartAI); dev pre-image ~/backups/pre_2026_11_11_02_northwatch.sql.
-- Item 228: Northwatch Foothold supply carriers (Northwatch Lug & Supply Crate)
-- Fix supply line pathing, despawn inside tent, crate death trigger, and cleanup

-- 1. Northwatch Supply Crate (39251) SmartAI:
-- When destroyed, kill the carrier (vehicle/summoner) and despawn after 2 seconds
DELETE FROM `smart_scripts` WHERE `entryorguid` = 39251 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(39251, 0, 0, 1, 6, 0, 100, 0, 0, 0, 0, 0, 0, 51, 0, 0, 0, 0, 0, 0, 23, 0, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Supply Crate - On Just Died - Kill Carrier (Summoner)'),
(39251, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 41, 2000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Supply Crate - Link - Despawn after 2s');

-- 2. Waypoint script to despawn carrier inside the supply tent
DELETE FROM `waypoint_scripts` WHERE `id` = 2527450;
INSERT INTO `waypoint_scripts` (`id`, `delay`, `command`, `datalong`, `datalong2`, `dataint`, `x`, `y`, `z`, `o`, `guid`, `Comment`) VALUES
(2527450, 0, 18, 0, 0, 0, 0, 0, 0, 0, 3001, 'Northwatch Lug - Despawn inside tent (SCRIPT_COMMAND_DESPAWN_SELF)');

-- 3. One-way supply path 2527450 from landing ship to tent:
-- Remove reverse loop points 11-18, and remove redundant loop paths 2527740 and 2528320
DELETE FROM `waypoint_data` WHERE `id` IN (2527450, 2527740, 2528320);
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `move_flag`, `action`, `action_chance`, `wpguid`, `entry`) VALUES
(2527450, 1, -1014, -4423, 27, 0, 5000, 0, 0, 100, 0, '39249'),
(2527450, 2, -1011.3, -4512.4, 25.55, 0, 0, 0, 0, 100, 0, '39249'),
(2527450, 3, -996, -4557, 26, 0, 0, 0, 0, 100, 0, '39249'),
(2527450, 4, -996.3, -4612.1, 25.78, 0, 0, 0, 0, 100, 0, '39249'),
(2527450, 5, -984.5, -4652.2, 30.25, 0, 0, 0, 0, 100, 0, '39249'),
(2527450, 6, -992.6, -4669.3, 28.09, 0, 0, 0, 0, 100, 0, '39249'),
(2527450, 7, -997.4, -4694.9, 21.57, 0, 0, 0, 0, 100, 0, '39249'),
(2527450, 8, -1021.4, -4722.2, 15.27, 0, 0, 0, 0, 100, 0, '39249'),
(2527450, 9, -1031.5, -4725.4, 14.74, 0, 0, 0, 0, 100, 0, '39249'),
(2527450, 10, -1066.5, -4734.7, 16.65, 0, 1000, 0, 2527450, 100, 0, '39249');

-- 4. Creature addons: set active carrier pairs on path 2527450
DELETE FROM `creature_addon` WHERE `guid` IN (252745, 252747, 252774, 252776, 252832);
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `MountCreatureID`, `StandState`, `AnimTier`, `VisFlags`, `SheathState`, `PvPFlags`, `emote`, `aiAnimKit`, `movementAnimKit`, `meleeAnimKit`, `visibilityDistanceType`, `auras`) VALUES
(252745, 2527450, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(252747, 2527450, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(252774, 2527450, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, NULL),
(252776, 2527450, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, NULL);

-- 5. Creature spawns:
-- Set carrier pairs to spawn at landing ships with MovementType=2 and staggered respawn
UPDATE `creature` SET
    `position_x` = -1014.0,
    `position_y` = -4423.0,
    `position_z` = 27.0,
    `orientation` = 0.738687,
    `MovementType` = 2,
    `wander_distance` = 0,
    `spawntimesecs` = 120
WHERE `guid` = 252745;

UPDATE `creature` SET
    `position_x` = -1012.52,
    `position_y` = -4421.52,
    `position_z` = 26.581,
    `orientation` = 0.738687,
    `MovementType` = 2,
    `wander_distance` = 0,
    `spawntimesecs` = 120
WHERE `guid` = 252747;

UPDATE `creature` SET
    `position_x` = -1014.0,
    `position_y` = -4423.0,
    `position_z` = 27.0,
    `orientation` = 0.738687,
    `MovementType` = 2,
    `wander_distance` = 0,
    `spawntimesecs` = 180
WHERE `guid` = 252774;

UPDATE `creature` SET
    `position_x` = -1012.52,
    `position_y` = -4421.52,
    `position_z` = 26.581,
    `orientation` = 0.738687,
    `MovementType` = 2,
    `wander_distance` = 0,
    `spawntimesecs` = 180
WHERE `guid` = 252776;

-- Delete the 15 redundant sniff-duplicate Lug spawns
DELETE FROM `creature` WHERE `guid` IN (
    252749, 252760, 252762, 252765, 252778,
    252793, 252795, 252797, 252810, 252820,
    252822, 252824, 252832, 252834, 252836
);
