-- To-do 419 (Araj the Summoner, Andorhal): reporter sees Illusory Wraith + Deathguard War-Captain but no skeletons.
-- Cause: SmartAI 1852 id 2 still casts the classic Summon Illusory Wraith (17231); the Cataclysm version casts Summon Berserkers (83701, which has only a dummy effect in the 5.4.8 data and no script behind it).
-- Change: id 2 casts 82861 (Summon Stickbone Berserker, SUMMON effect on creature 44329; found in Spell.dbc, 83701 only dummy) with the Cata timers from ref_cpp (first 18-23s, repeat 50-65s, target self).
-- Source: Cata Preservation DB (ref_cpp smart_scripts 1852 id 2); spell choice from Spell.dbc 5.4.8 (83701 = dummy only, 82861 = summon); client test on dev 31-10 showed 83701 does nothing.
-- Rollback: UPDATE smart_scripts SET event_param2 = 24000, action_param1 = 17231, action_param2 = 1, comment = "Araj the Summoner - In Combat - Cast Summon Illusory Wraith" WHERE entryorguid = 1852 AND source_type = 0 AND id = 2;
UPDATE smart_scripts SET event_param2 = 23000, action_param1 = 82861, action_param2 = 0, comment = "Araj the Summoner - In Combat - Cast Summon Stickbone Berserker" WHERE entryorguid = 1852 AND source_type = 0 AND id = 2;
