-- To-do 456 (Guthrum Thunderfist keeps offering the gryphon flight to Western Plaguelands; proposal Gemini item456_20261030_2209 reviewed against the DB):
-- gossip menu 11885 option 1 (taxi 2459 via SmartAI) had no condition. Quest 28505 "The Battle for Andorhal" (started by Falstad Wildhammer 5636,
-- ended by Thassarian 44453) is the only Guthrum-flight quest in our DB; the option is now only shown while that quest is incomplete/complete (not yet rewarded).
-- Source: quest_template.LogDescription 28505 (5.4.8 data in our DB: "Speak with Guthrum Thunderfist to fly to Andorhal"); no sniff of the gossip condition.
-- Rollback: DELETE FROM conditions WHERE SourceTypeOrReferenceId=15 AND SourceGroup=11885 AND SourceEntry=1;
DELETE FROM conditions WHERE SourceTypeOrReferenceId=15 AND SourceGroup=11885 AND SourceEntry=1;
INSERT INTO conditions (SourceTypeOrReferenceId,SourceGroup,SourceEntry,SourceId,ElseGroup,ConditionTypeOrReference,ConditionTarget,ConditionValue1,ConditionValue2,ConditionValue3,NegativeCondition,ErrorType,ErrorTextId,ScriptName,Comment) VALUES
(15,11885,1,0,0,47,0,28505,10,0,0,0,0,"","Guthrum Thunderfist - flight to Andorhal only while quest 28505 is in progress/complete");
