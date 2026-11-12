-- SI7-BLIZZ 29733 SI:7 Report: Lost in the Woods: the two Rell-vehicle rows of 2026_11_04_05 run again.
-- (1) 55335 id 1 (Data 4/1 from Amber = four ambushers dead -> outro list 5533501) and id 2 (Data 9 -> despawn) carried event_flags 512, meant as "while charmed". On this core 0x200 is SMART_EVENT_FLAG_DIFFICULTY_RAID40 (SmartScriptMgr.h:1428, no charm flag exists; SmartScript::ProcessEvent has no charm check) and FillScript drops difficulty-flagged rows outside dungeons, so both rows never ran on map 870: the outro only came from the 60 s failsafe (5533500 id 21 -> 5533502) and the vehicle never despawned on Data 9. Proven on 29725 (5-11-2026 02:25, probe rows) and on 29726/29727 (same rows with flags 0 fire while the player drives).
-- (2) No double outro: CALL_TIMED_ACTIONLIST replaces the running list (SmartScript::SetScript9 clears mTimedActionList), so once Data 4/1 starts 5533501 the failsafe row of 5533500 is gone; if the failsafe comes first it despawns the ambushers (Data 9, no death event) before running the same outro.
-- Source: SmartScriptMgr.h / SmartScript.cpp of this core, dev tests 5-11-2026 (si7_rest_20261104.md).
-- DERIVED (no sniff): nothing new (2026_11_04_05/11 unchanged otherwise).
-- Rollback: UPDATE `smart_scripts` SET `event_flags` = 512 WHERE `source_type` = 0 AND `entryorguid` = 55335 AND `id` IN (1, 2);

UPDATE `smart_scripts` SET `event_flags` = 0 WHERE `source_type` = 0 AND `entryorguid` = 55335 AND `id` IN (1, 2);
