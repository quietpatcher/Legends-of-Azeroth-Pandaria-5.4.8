-- #486: Prospector Anvilward (15420, quest 8483 "The Dwarven Spy") turned hostile at the top of the North Sanctum
-- but never attacked; he only fought back once the player hit him.
-- Cause: waypoint 7 only ran Set Faction 24; nothing started combat (faction change alone does not aggro a player
-- who is already in range), and nothing restored faction/gossip after an evade.
-- Fix: link Start Attacking on the action invoker (the player who chose the gossip) after the faction change, and
-- reset faction + gossip flag on reset.
-- Source: Wowhead quest 8483 / NPC 15420 (he reveals himself and attacks the player); quest text "lure him ... and
-- kill him". Exact retail timing unknown without a sniff.
DELETE FROM `smart_scripts` WHERE `entryorguid` = 15420 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(15420, 0, 0, 1, 62, 0, 100, 0, 6954, 0, 0, 0, 0, 53, 0, 15420, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Gossip Option 0 Selected - Start Waypoint'),
(15420, 0, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 72, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Gossip Option 0 Selected - Close Gossip'),
(15420, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 83, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Gossip Option 0 Selected - Remove Npc Flag Gossip'),
(15420, 0, 3, 0, 40, 0, 100, 0, 1, 15420, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 1 Reached - Say Line 0'),
(15420, 0, 4, 5, 40, 0, 100, 0, 6, 15420, 0, 0, 0, 54, 2500, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 6 Reached - Pause Waypoint'),
(15420, 0, 5, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 6 Reached - Say Line 1'),
(15420, 0, 6, 7, 40, 0, 100, 0, 7, 15420, 0, 0, 0, 54, 15000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 7 Reached - Pause Waypoint'),
(15420, 0, 7, 8, 61, 0, 100, 0, 0, 0, 0, 0, 0, 2, 24, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 7 Reached - Set Faction 24'),
(15420, 0, 8, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 49, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 7 Reached - Start Attacking'),
(15420, 0, 9, 0, 1, 0, 100, 1, 10000, 10000, 24000, 29000, 0, 1, 2, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - Out of Combat - Say Line 2'),
(15420, 0, 10, 11, 25, 0, 100, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Reset - Set Faction Default'),
(15420, 0, 11, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 82, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Reset - Add Npc Flag Gossip');
-- Rollback (original 9 rows): DELETE FROM smart_scripts WHERE entryorguid=15420 AND source_type=0; then re-insert:
-- INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
-- (15420, 0, 0, 1, 62, 0, 100, 0, 6954, 0, 0, 0, 0, 53, 0, 15420, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Gossip Option 0 Selected - Start Waypoint'),
-- (15420, 0, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 72, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Gossip Option 0 Selected - Close Gossip'),
-- (15420, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 83, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Gossip Option 0 Selected - Remove Npc Flag Gossip'),
-- (15420, 0, 3, 0, 40, 0, 100, 0, 1, 15420, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 1 Reached - Say Line 0'),
-- (15420, 0, 4, 5, 40, 0, 100, 0, 6, 15420, 0, 0, 0, 54, 2500, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 6 Reached - Pause Waypoint'),
-- (15420, 0, 5, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 6 Reached - Say Line 1'),
-- (15420, 0, 6, 7, 40, 0, 100, 0, 7, 15420, 0, 0, 0, 54, 15000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 7 Reached - Pause Waypoint'),
-- (15420, 0, 7, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 2, 24, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - On Waypoint 7 Reached - Set Faction 24'),
-- (15420, 0, 8, 0, 1, 0, 100, 1, 10000, 10000, 24000, 29000, 0, 1, 2, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prospector Anvilward - Out of Combat - Say Line 2');
