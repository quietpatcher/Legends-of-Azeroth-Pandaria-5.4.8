-- Northwatch Foothold (Durotar, to-do 228): the four crate carriers (Northwatch Lug 39249) keep walking, vanishing at the tent and
-- respawning at the ships when no player is near their part of the 360 yd path.
-- Cause: a creature is only updated while a player is within range of its cell. A player at the ships saw the carriers walk
--        off and freeze out of range; a player at the tent never saw one arrive; a frozen or despawned carrier did not respawn
--        until somebody came close to where it stood. Measured on the test server 11-11: the carriers that spawned at 20:01 and
--        20:03 both vanished at the tent in the same second at 20:15, when the tester arrived there (path walk time is 3-4 min).
-- Fix: the carrier sets itself active on (re)spawn, the same way as the 8 existing "On Respawn - Set Active" rows (e.g. the
--      Argent Peacekeepers), so the supply line runs on once a player has been in the area.
-- Source: reporter's retail observation (to-do 228: carriers walk from the ships to the tent as a steady line); own client run
--         state/test_228_20261111.md; Server.log lines "exit vehicle entry 39249" of both carriers at 20:15.
-- Rollback:
--   DELETE FROM smart_scripts WHERE entryorguid=39249 AND source_type=0 AND id=1;
DELETE FROM `smart_scripts` WHERE `entryorguid`=39249 AND `source_type`=0 AND `id`=1;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(39249, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 48, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Lug - On Respawn - Set Active (supply line keeps running, to-do 228)');
