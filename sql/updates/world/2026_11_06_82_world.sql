-- Rollback: restore the tables listed in the Rollback section of state/l1_silverpine_hillsbrad_diff.md from the pre-apply dump.
-- Source: DeltaTho via 1LineAtaTime/LoA-Pandaria-Playerbots (GPLv2), file 2026_11_04_70_world.sql.
-- Ruins of Southshore: remove the second of two Used Blight Canisters (207090) spawned 1.5 yd apart
DELETE FROM `gameobject` WHERE `guid` = 158279 AND `id` = 207090;
