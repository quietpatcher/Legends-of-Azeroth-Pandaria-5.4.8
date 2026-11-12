-- Prod crash 12-11 01:59 (to-do 497): Speaker Mar'grom (18693) SmartAI id 0 "On Spellhit Fire - Cast Fire Ward (37844)" had no cooldown.
-- Fire Ward is itself a Fire spell, so the cast hit the creature again, fired the same event, and so on until the stack overflowed (gdb on core 2393531).
-- Core guard is in commit ed5eee63; this gives the event the 10 s cooldown (params 3/4) as a second layer.
-- Source: gdb backtrace of the prod core (SmartScript::ProcessEvent SPELLHIT recursion); smart_scripts 18693 id 0 in our DB.
-- Rollback:
--   UPDATE smart_scripts SET event_param3=0, event_param4=0 WHERE entryorguid=18693 AND source_type=0 AND id=0;
UPDATE smart_scripts SET event_param3=10000, event_param4=10000 WHERE entryorguid=18693 AND source_type=0 AND id=0 AND event_type=8;
