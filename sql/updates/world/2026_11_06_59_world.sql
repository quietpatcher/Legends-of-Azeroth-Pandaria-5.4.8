-- Rollback: restore the tables listed in the Rollback section of state/l1_silverpine_hillsbrad_diff.md from the pre-apply dump.
-- Source: DeltaTho via 1LineAtaTime/LoA-Pandaria-Playerbots (GPLv2), file 2026_10_29_986_84_hb_machine_steed_phase.sql.
-- ported from PR 15 2026_10_28_63_world.sql (#986)
-- Welcome to the Machine: Ride Skeletal Steed seats the player without its phase 317, which hid the scene's own actors
-- (spell_hillsbrad_machine_ride_skeletal_steed).
DELETE FROM `spell_script_names` WHERE `spell_id`=88543 AND `ScriptName`='spell_hillsbrad_machine_ride_skeletal_steed';
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(88543,'spell_hillsbrad_machine_ride_skeletal_steed');
