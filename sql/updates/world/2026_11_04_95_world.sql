-- 425 (Tirisfal block, fix): phase 2400 does not exist in Phase.dbc ("Phase 2400 defined in phase_area does not exist, skipped"), so the 9 Worgen Infiltrators (38967)
--   were never visible. Move the same mechanism (phase_area + conditions type 26 + creature.phaseId) to PhaseId 399.
-- Source: Phase.dbc on dev (~/server/data/dbc/Phase.dbc, 1991 rows) contains ID 399 and not 2400; 399 is not used in phase_area, creature, gameobject or
--   conditions (type 26) anywhere in our world DB (checked 04-11). The id itself is only a free valid slot: no sniff/source gives the retail phase id for quest 24993
--   (ref_cpp has these spawns in default phase 169). Mechanism and quest conditions: HavenWoW BFA-HavenCore issue 670, Wowhead quest 24993; same as Forsaken Front 277/278/284.
-- Rollback: DELETE FROM phase_area WHERE AreaId=159 AND PhaseId=399; DELETE FROM conditions WHERE SourceTypeOrReferenceId=26 AND SourceGroup=399;
--   UPDATE creature SET phaseId=2400 WHERE guid IN (192663,192920,193800,193803,193806,194346,194348,194349,194618);  (or phaseId=0 / 169 for always visible)
DELETE FROM phase_area WHERE AreaId=159 AND PhaseId IN (2400,399);
INSERT INTO phase_area (AreaId,PhaseId,Comment) VALUES (159,399,'Brill - Worgen Infiltrators while quest 24993 taken/complete');
DELETE FROM conditions WHERE SourceTypeOrReferenceId=26 AND SourceGroup IN (2400,399);
INSERT INTO conditions (SourceTypeOrReferenceId,SourceGroup,SourceEntry,SourceId,ElseGroup,ConditionTypeOrReference,ConditionTarget,ConditionValue1,ConditionValue2,ConditionValue3,NegativeCondition,ErrorType,ErrorTextId,ScriptName,Comment) VALUES
(26,399,159,0,0,9,0,24993,0,0,0,0,0,'','Brill 399: Annihilate the Worgen taken'),
(26,399,159,0,1,28,0,24993,0,0,0,0,0,'','Brill 399: Annihilate the Worgen complete');
UPDATE creature SET phaseId=399 WHERE guid IN (192663,192920,193800,193803,193806,194346,194348,194349,194618) AND id=38967;
