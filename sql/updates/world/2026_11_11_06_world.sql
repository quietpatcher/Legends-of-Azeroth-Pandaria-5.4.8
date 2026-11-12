-- Northwatch Supply Crate (39251, quest 25167 Breaking the Chain, to-do 228): a player can now target and attack the crate a Northwatch Lug
-- carries (destroying it kills the carrier, as on retail), and the crate of a killed carrier disappears at once.
-- Cause: seat 9108 (seat 0 of vehicle 1328, the lug) in VehicleSeat.dbc has flags 0x128009 = VEHICLE_SEAT_FLAG_PASSENGER_NOT_SELECTABLE (0x100000);
--        Vehicle::AddPassenger sets UNIT_FLAG_NOT_SELECTABLE on every passenger of such a seat, so the crate could not be targeted.
--        The accessory had summontype 6 (despawn 30 s after death): when the carrier dies the crate is made to die without a death script
--        (Unit::_ExitVehicle), its SmartAI despawn never ran and the corpse stayed 30 s.
-- Source: 5.4.8 data (Vehicle.dbc 1328 -> VehicleSeat.dbc 9108 flags 0x128009); Warcraft Wiki and Wowpedia "Northwatch Lug":
--         destroying the carried crate makes it fall on the lug and kill it.
-- Rollback:
--   DELETE FROM smart_scripts WHERE entryorguid=39249 AND source_type=0 AND id=2;
--   UPDATE vehicle_template_accessory SET summontype=6 WHERE entry=39249 AND accessory_entry=39251 AND seat_id=0;
DELETE FROM smart_scripts WHERE entryorguid=39249 AND source_type=0 AND id=2;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, target_type, target_param1, target_param2, target_param3, target_param4, target_x, target_y, target_z, target_o, comment) VALUES
(39249, 0, 2, 0, 27, 0, 100, 0, 0, 0, 0, 0, 0, 19, 33554432, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Lug - On Passenger Boarded - Remove NOT_SELECTABLE from the crate (seat flag), to-do 228');
UPDATE vehicle_template_accessory SET summontype=5 WHERE entry=39249 AND accessory_entry=39251 AND seat_id=0;
