-- Rollback: DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceEntry` = 83173;
-- Source: cause found in core, Spell::SelectImplicitAreaTargets (Spell.cpp:1141): TARGET_UNIT_SRC_AREA_ENTRY without conditions selects every unit; same condition pattern as the other spell 13 rows.
-- To-do 434, The Warchief Cometh: Agatha's Raise Forsaken (83173, effect 0: aura Dummy, targets SRC_CASTER + UNIT_SRC_AREA_ENTRY) had no
-- implicit target conditions, so Spell::SelectImplicitAreaTargets (TARGET_CHECK_ENTRY without conditions) took every unit in the radius
-- (guards, Garrosh, Mortuus, ...) and all of them got the raise visual. Only the Fallen Humans (44592 male, 44593 female) are to be raised;
-- the aura script (spell_silverpine_raise_forsaken_83173) already only reacts to those two entries.
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 13 AND `SourceEntry` = 83173;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(13, 1, 83173, 0, 0, 31, 0, 3, 44592, 0, 0, 0, 0, '', 'Raise Forsaken - target male Fallen Human (to-do 434)'),
(13, 1, 83173, 0, 1, 31, 0, 3, 44593, 0, 0, 0, 0, '', 'Raise Forsaken - or target female Fallen Human (to-do 434)');
