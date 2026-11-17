-- #486 (follow-up to 2026_11_06_02): Prospector Anvilward still did not attack first in the own-client test of 06-11.
-- Cause: waypoint events have no action invoker in this core (SmartScript::GetTargets, SMART_TARGET_ACTION_INVOKER only
-- uses the event's own trigger, no last-invoker fallback), so Start Attacking with target 7 at waypoint 7 had no victim.
-- Fix: store the player who picks the gossip (Store Target List, var 1) and attack the stored target at waypoint 7;
-- also restore faction and gossip flag on evade, because he stayed hostile after the player ran off.
-- Source: Wowhead quest 8483 / NPC 15420 (he attacks the player who lured him into the sanctum).
UPDATE `smart_scripts` SET `link` = 12 WHERE `entryorguid` = 15420 AND `source_type` = 0 AND `id` = 2;
UPDATE `smart_scripts` SET `target_type` = 12, `target_param1` = 1, `comment` = 'Prospector Anvilward - On Waypoint 7 Reached - Start Attacking Stored Target' WHERE `entryorguid` = 15420 AND `source_type` = 0 AND `id` = 8;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 15420 AND `source_type` = 0 AND `id` IN (12, 13, 14);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(15420, 0, 12, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 64, 1, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Gossip Option 0 Selected - Store Target List (invoker)'),
(15420, 0, 13, 14, 7, 0, 100, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Evade - Set Faction Default'),
(15420, 0, 14, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 82, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Evade - Add Npc Flag Gossip');
-- Rollback: DELETE FROM smart_scripts WHERE entryorguid=15420 AND source_type=0 AND id IN (12,13,14);
--   UPDATE smart_scripts SET link=0 WHERE entryorguid=15420 AND source_type=0 AND id=2;
--   UPDATE smart_scripts SET target_type=7, target_param1=0, comment='Prospector Anvilward - On Waypoint 7 Reached - Start Attacking' WHERE entryorguid=15420 AND source_type=0 AND id=8;
