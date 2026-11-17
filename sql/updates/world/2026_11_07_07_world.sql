-- To-do 476 (Grimscale Seer 15950, Tranquil Shore, Eversong Woods): players report the seers rarely use ranged abilities.
-- Our script (same as ref_cpp, ref_sf and ref_alex) only casts Lightning Bolt 20802 after 6.8-8.5 s and then every 14-26 s.
-- Warcraft Wiki (Grimscale Seer, abilities) also lists Fear 26661 ("Strikes fear in an enemy ... 10 sec. Only 1 target can be
-- feared at a time"), which none of our data has. Fear is added in combat; NO SOURCE for its timer: chosen conservatively
-- (first after 10-14 s, then every 25-35 s, current target). The Lightning Bolt timers stay as in all three reference databases.
-- Source: https://warcraft.wiki.gg/wiki/Grimscale_Seer (abilities Fear + Lightning Bolt); ref_cpp smart_scripts 15950.
-- Rollback: DELETE FROM smart_scripts WHERE entryorguid = 15950 AND source_type = 0 AND id = 1;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 15950 AND `source_type` = 0 AND `id` = 1;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(15950, 0, 1, 0, 0, 0, 100, 0, 10000, 14000, 25000, 35000, 0, 11, 26661, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Grimscale Seer - In Combat - Cast Fear');
