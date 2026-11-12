-- Source: dev97 validation 4-11-2026 (Pakket D FAIL, Duskhaven street fight); flags compared with ref_cpp creature_template 34913 (unit_flags 32768).
-- Prince Liam Greymane 34913 carries unit_flags 33284 = 0x8000 CAN_SWIM | 0x200 IMMUNE_TO_NPC | 0x4 DISABLE_MOVE (also on prod, not from l1-D).
-- npc_prince_liam_greymane_phase2 calls AttackStart(34884). With DISABLE_MOVE MotionMaster::MoveChase returns at once
-- (MotionMaster.cpp:613), with IMMUNE_TO_NPC ThreatReference::FlagsAllowFighting(worgen, Liam) is false (ThreatManager.cpp:122-136)
-- so the threat reference goes offline and Liam never enters combat. Reference value: 32768.
-- Rollback:
--   UPDATE `creature_template` SET `unit_flags` = 33284 WHERE `entry` = 34913;
-- Re-runnable: UPDATE with fixed value.
UPDATE `creature_template` SET `unit_flags` = 32768 WHERE `entry` = 34913;
