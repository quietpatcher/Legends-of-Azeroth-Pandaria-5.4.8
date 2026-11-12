-- Silverpine Forest (to-do 433): the Subdued Forest Ettins (44737 / 46560) installed by 2026_10_29_02 sat on seat 0 of the Horde Hauler (44731) / Horde Coffin Hauler (44764),
-- i.e. on top of the cart at the driver position (Vehicle 1048/1049 seat 0 = attachment 1, offset 0.55/0/3.0), while the yoke stayed empty ("carts moving without ettins").
-- Seat 1 (attachment 15, offset 2.0/0/0) is the front/yoke position: the ettin pulls the cart from there.
-- Source: warcraft.wiki.gg / wowpedia Horde Hauler + Horde Coffin Hauler ("pulled by a Subdued Forest Ettin, driven by a Horde Engineer").
-- Derived: the seat number 1 comes from the Vehicle/VehicleSeat DBC geometry and was verified on dev with the real 5.4.8 client (seat 0: ettin on the cart roof, seat 1: ettin in front, pulling).
-- Rollback: UPDATE `vehicle_template_accessory` SET `seat_id` = 0 WHERE `entry` IN (44731, 44764) AND `accessory_entry` IN (44737, 46560);
UPDATE `vehicle_template_accessory` SET `seat_id` = 1 WHERE `entry` IN (44731, 44764) AND `accessory_entry` IN (44737, 46560);
