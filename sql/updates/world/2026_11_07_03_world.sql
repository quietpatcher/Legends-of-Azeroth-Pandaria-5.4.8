-- To-do 490 follow-up to 2026_11_07_02: SmartAIMgr skipped Mirveda event 6 ("reset counter", SET_COUNTER id 1 value 0 reset 1):
-- this core rejects value 0 at load, which also broke the link chain 5 -> 6 -> 7, so the reset script 1540202 after the quest
-- completion never ran. The counter does not need an explicit reset: SmartScript::OnReset clears all counters when Mirveda
-- leaves combat after the summons died. Event 5 now links straight to event 7 and event 6 is removed.
-- Source: SmartScriptMgr.cpp SET_COUNTER check (value == 0 rejected), SmartScript.cpp OnReset (mCounterList.clear()).
-- Rollback: UPDATE smart_scripts SET link = 6 WHERE entryorguid = 15402 AND source_type = 0 AND id = 5; and re-insert event 6 from
-- 2026_11_07_02 (or ref_cpp smart_scripts 15402 id 6).
DELETE FROM `smart_scripts` WHERE `entryorguid` = 15402 AND `source_type` = 0 AND `id` = 6;
UPDATE `smart_scripts` SET `link` = 7 WHERE `entryorguid` = 15402 AND `source_type` = 0 AND `id` = 5;
