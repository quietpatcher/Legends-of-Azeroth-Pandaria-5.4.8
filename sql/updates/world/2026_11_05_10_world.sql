-- To-do 485, Silverpine Forest: the Abandoned Outhouse (GO 205143, gossip menu 11897) offered "Yorick, you in there? I'm ready to do this!"
-- to everyone, also before quest 27045 Waiting to Exsanguinate was accepted and after its objective was done, and each click summoned
-- Deathstalker Rane Yorick again (go_silverpine_abandoned_outhouse::OnGossipSelect casts the summon without a quest check).
-- Show the option only while 27045 is taken and not complete (CONDITION_QUESTTAKEN = status INCOMPLETE, ConditionMgr.cpp).
-- Source: Wowhead quest 27045 (https://www.wowhead.com/quest=27045/waiting-to-exsanguinate): the outhouse option is the quest's start of the
-- scene; DERIVED (no sniff): no ref core (ref_cpp/ref_sf/ref_alex) has a condition for menu 11897, the option text only makes sense on the quest.
-- Rollback: DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 11897 AND `SourceEntry` = 0;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 11897 AND `SourceEntry` = 0;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(15, 11897, 0, 0, 0, 9, 0, 27045, 0, 0, 0, 0, 0, '', 'Abandoned Outhouse - show option only while Waiting to Exsanguinate (27045) is taken and incomplete (to-do 485)');
