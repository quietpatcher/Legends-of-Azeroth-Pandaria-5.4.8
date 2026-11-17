-- To-do 468 (quest 13947 Blastranaar!), reporter note 05-11: "the elves should after launching away should die" and "the speed of the
-- mount flying towards Astranaar seems rather slow".
-- * Blastranaar Explosive Impact (28888) has an Area Knockback (effect 144, value 150, radius 10 yd) on retail; our Sentinels (34494) and
--   Throwers (34492) died in the same tick as the hit, so the knockback was never seen. They now die 1.5 s after the hit (the delay is our
--   choice: long enough to see the launch). Kill credit stays on the hit.
-- * Furious Wind Rider 34433 speed_run 1.14286 -> 4.0: in the quest videos the flight to Astranaar takes about 5-8 s, ours took about 43 s
--   over 343 yd; 4.0 (about 28 yd/s) gives about 12 s. No reference DB has another value (all 1.14286); to be tuned after testing.
-- Source: Wowhead spell 28888 (Wayback copy) Area Knockback; quest videos d9ZUrwW-Opk / LGu0x5A4yQo; state/fix468_rest_20261109.md.
-- Rollback: UPDATE creature_template SET speed_run = 1.14286 WHERE entry = 34433;
-- DELETE FROM smart_scripts WHERE entryorguid IN (34494, 34492) AND source_type = 0 AND id IN (2, 3); then re-insert id 2 as
-- (link 0, event 61, action 37 Die, target self) for both entries (as in 2026_11_08_01).
UPDATE `creature_template` SET `speed_run` = 4.0 WHERE `entry` = 34433;
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (34494, 34492) AND `source_type` = 0 AND `id` IN (2, 3);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(34494, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 67, 1, 1500, 1500, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 'Astranaar Sentinel - On bomb impact - Create Timed Event 1 (1.5 s: knockback visible first)'),
(34494, 0, 3, 0, 59, 0, 100, 0, 1, 0, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Astranaar Sentinel - On Timed Event 1 - Die'),
(34492, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 67, 1, 1500, 1500, 0, 0, 100, 1, 0, 0, 0, 0, 0, 0, 0, 'Astranaar Thrower - On bomb impact - Create Timed Event 1 (1.5 s: knockback visible first)'),
(34492, 0, 3, 0, 59, 0, 100, 0, 1, 0, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Astranaar Thrower - On Timed Event 1 - Die');
