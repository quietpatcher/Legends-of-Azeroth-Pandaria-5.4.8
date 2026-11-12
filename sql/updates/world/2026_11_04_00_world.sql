-- To-do 405 (SmartAI port, follow-up of the in-game sample 04-11-2026): two ported health events fired at full health.
-- Cause: ref_cpp carries event_type 2 (SMART_EVENT_HEALTH_PCT: HPMin%, HPMax%, RepeatMin, RepeatMax) with HPMax 30000 for these rows,
-- so in our core the condition "health between 0 and 30000%" is always true. Seen with our own GM client on dev: Gnarlpine Shaman 2009
-- flees ("attempts to run away in fear!") at full health and never fights (the internal notes).
-- Change: 2009 id 0 HPMax 15 (repeat 0/0, No Repeat), 2030 id 2 HPMax 30 (repeat 5-30 s kept), matching the comment of each row.
-- Source: ref_alex smart_scripts 2009 id 0 = (0,15,0,0) and the row comments ("Between 0-15% / 0-30% Health") in 2026_11_02_41_world.sql.
-- Rollback: UPDATE smart_scripts SET event_param2=30000, event_param4=30000 WHERE entryorguid=2009 AND source_type=0 AND id=0;
--           UPDATE smart_scripts SET event_param2=30000 WHERE entryorguid=2030 AND source_type=0 AND id=2;
UPDATE `smart_scripts` SET `event_param1`=0, `event_param2`=15, `event_param3`=0, `event_param4`=0 WHERE `entryorguid`=2009 AND `source_type`=0 AND `id`=0 AND `event_type`=2;
UPDATE `smart_scripts` SET `event_param1`=0, `event_param2`=30 WHERE `entryorguid`=2030 AND `source_type`=0 AND `id`=2 AND `event_type`=2;
