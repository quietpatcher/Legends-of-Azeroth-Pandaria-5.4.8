-- Heroic dungeons (player path): open heroic Scarlet Halls (map 1001, LFG 473) and heroic Scholomance (map 1007, LFG 472).
-- APPLY ONLY AFTER a client run of both heroics on the test server (see the internal notes, test steps).
-- Cause: both heroics were switched off in the base data (disables type 2, flag 2 = heroic; Scholomance heroic also
--        had level_min 99), so a level 90 player could not queue for them or enter them.
-- Source: 5.4.8 client LfgDungeons.dbc (472 Scholomance and 473 Scarlet Halls: heroic, level 90, part of
--         Random Mists of Pandaria Heroic 462) and MapDifficulty.dbc (both maps have a heroic difficulty).
-- Rollback:
--   DELETE FROM disables WHERE sourceType=2 AND entry IN (1001,1007);
--   INSERT INTO disables (sourceType, entry, flags, params_0, params_1, comment) VALUES
--     (2, 1001, 2, '', '', 'Scarlet Halls heroic disabled (TT: normal re-enabled 26-9)'),
--     (2, 1007, 2, '', '', 'disabled scholomance');
--   UPDATE access_requirement SET level_min=99 WHERE mapId=1007 AND difficulty='DUNGEON_HEROIC';
DELETE FROM disables WHERE sourceType=2 AND entry IN (1001,1007) AND flags=2;
UPDATE access_requirement SET level_min=90 WHERE mapId=1007 AND difficulty='DUNGEON_HEROIC' AND level_min=99;
