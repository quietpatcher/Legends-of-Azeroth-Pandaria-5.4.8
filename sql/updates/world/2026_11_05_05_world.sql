-- SI7-BLIZZ 29727 SI:7 Report: Take No Prisoners: the Amber vehicle never fights by itself, scene targets limited to the scene player (follow-up of the 29725 findings of 5-11-2026).
-- (1) AIName 55405 SmartAI -> SmartVehicleAI: with plain SmartAI a player-driven vehicle runs UpdateVictim/AttackStart/MoveChase and EnterEvadeMode/MoveTargetedHome as soon as a hozen engages it (proven on 29725, dev 5-11 01:45: rider movement no longer accepted). SmartVehicleAI (SmartAI.cpp:982) keeps the SmartAI events and lists.
-- (2) Targets: the credit, the teleport home and the failsafe used "all players within 250/400 yd" (bystanders in Grookin Hill would be credited and teleported). The failsafe runs on the vehicle: its target is the vehicle's summoner (the player cast 103609). The final list runs on Sully 55408: closest player within 60 yd (the rider on the perch is the only player in the personal scene).
-- Source: SmartAI.cpp (SmartVehicleAI, VehicleAIBase), SmartScript.cpp (SMART_TARGET_OWNER_OR_SUMMONER, SMART_TARGET_CLOSEST_PLAYER), dev test of 29725 on 5-11-2026.
-- DERIVED (no sniff): nothing new; the perch, guard and barrel positions stay as in 2026_11_03_03 / 2026_11_05_02.
-- Rollback: UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 55405; UPDATE `smart_scripts` SET `target_type` = 17, `target_param1` = 0, `target_param2` = 400 WHERE `source_type` = 9 AND ((`entryorguid` = 5540501 AND `id` = 0) OR (`entryorguid` = 5540802 AND `id` = 7)); UPDATE `smart_scripts` SET `target_type` = 17, `target_param1` = 0, `target_param2` = 250 WHERE `source_type` = 9 AND `entryorguid` = 5540802 AND `id` = 6;

-- (1) the vehicle never fights or evades on its own
UPDATE `creature_template` SET `AIName` = 'SmartVehicleAI' WHERE `entry` = 55405;

-- (2) credit and the way home to the scene player only
UPDATE `smart_scripts` SET `target_type` = 23, `target_param1` = 0, `target_param2` = 0 WHERE `source_type` = 9 AND `entryorguid` = 5540501 AND `id` = 0;
UPDATE `smart_scripts` SET `target_type` = 21, `target_param1` = 60, `target_param2` = 0 WHERE `source_type` = 9 AND `entryorguid` = 5540802 AND `id` IN (6, 7);
