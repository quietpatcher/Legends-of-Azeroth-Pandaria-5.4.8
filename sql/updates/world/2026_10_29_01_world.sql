-- Quest 26998 (Iterating Upon Success): Blight Concoction (83573) hit every neutral and hostile unit in the target area;
-- limit effect 0 to the Vile Fin murlocs (1908/46573 Oracle, 1768/46574 Tidehunter). Quest objective kills entry 1908.
-- Rollback: DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceEntry` = 83573;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceEntry` = 83573;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(13, 1, 83573, 0, 0, 31, 0, 3, 1908, 0, 0, 0, 0, '', 'Blight Concoction targets Vile Fin Oracle'),
(13, 1, 83573, 0, 1, 31, 0, 3, 1768, 0, 0, 0, 0, '', 'Blight Concoction targets Vile Fin Tidehunter'),
(13, 1, 83573, 0, 2, 31, 0, 3, 46573, 0, 0, 0, 0, '', 'Blight Concoction targets Vile Fin Oracle'),
(13, 1, 83573, 0, 3, 31, 0, 3, 46574, 0, 0, 0, 0, '', 'Blight Concoction targets Vile Fin Tidehunter');
