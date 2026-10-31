-- Silverpine Forest: Horde Hauler (44731) and Horde Coffin Hauler (44764) drove their waypoint path without the ettin that pulls them.
-- The Subdued Forest Ettins (44737 / 46560) stood next to the carts as separate wandering spawns. Install them as vehicle accessory on
-- seat 0 and remove the 18 loose spawns (guids below, dumped to backups/442 on dev).
-- Rollback: DELETE FROM `vehicle_template_accessory` WHERE `entry` IN (44731, 44764); re-import the dumped creature rows.
DELETE FROM `vehicle_template_accessory` WHERE `entry` IN (44731, 44764);
INSERT INTO `vehicle_template_accessory` (`entry`, `accessory_entry`, `seat_id`, `minion`, `description`, `summontype`, `summontimer`) VALUES
(44731, 44737, 0, 1, 'Horde Hauler - Subdued Forest Ettin', 8, 0),
(44764, 46560, 0, 1, 'Horde Coffin Hauler - Subdued Forest Ettin', 8, 0);

DELETE FROM `creature` WHERE `guid` IN (187562,187573,187582,187591,187600,187630,187637,187644,188358,188036,188058,188087,188104,188124,188179,188195,188200,188222) AND `id` IN (44737, 46560);
