-- 425 (Tirisfal block): the 9 Worgen Infiltrators (38967) in Brill stay visible after quest 24993 'Annihilate the Worgen'.
-- Source: HavenWoW BFA-HavenCore issue 670 ('after picking up the quest the Worgen Infiltrators should show up in Brill'), Wowhead quest 24993 (kill 5 'within Brill');
--   ref_cpp has no usable phase for them (PhaseId 169 there is the sniff default). Same mechanism as our Forsaken Front phases 277/278/284 (phase_area + conditions type 26 + creature.phaseId).
-- Visible only while quest 24993 is in the log or complete-not-rewarded; gone when rewarded or never taken.
-- Rollback: DELETE FROM phase_area WHERE AreaId=159 AND PhaseId=2400; DELETE FROM conditions WHERE SourceTypeOrReferenceId=26 AND SourceGroup=2400;
--   UPDATE creature SET phaseId=0 WHERE guid IN (192663,192920,193800,193803,193806,194346,194348,194349,194618);  (then .reload conditions / grid reload)
DELETE FROM phase_area WHERE AreaId=159 AND PhaseId=2400;
INSERT INTO phase_area (AreaId,PhaseId,Comment) VALUES (159,2400,'Brill - Worgen Infiltrators while quest 24993 taken/complete');
DELETE FROM conditions WHERE SourceTypeOrReferenceId=26 AND SourceGroup=2400;
INSERT INTO conditions (SourceTypeOrReferenceId,SourceGroup,SourceEntry,SourceId,ElseGroup,ConditionTypeOrReference,ConditionTarget,ConditionValue1,ConditionValue2,ConditionValue3,NegativeCondition,ErrorType,ErrorTextId,ScriptName,Comment) VALUES
(26,2400,159,0,0,9,0,24993,0,0,0,0,0,'','Brill 2400: Annihilate the Worgen taken'),
(26,2400,159,0,1,28,0,24993,0,0,0,0,0,'','Brill 2400: Annihilate the Worgen complete');
UPDATE creature SET phaseId=2400 WHERE guid IN (192663,192920,193800,193803,193806,194346,194348,194349,194618) AND id=38967;
