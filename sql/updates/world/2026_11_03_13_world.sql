-- Heroic dungeon rows with level 1 where the creature template is higher: fix 8 DUNGEON_HEROIC rows (level_min/level_max = 1) so the heroic version no longer spawns as level 1.
-- Cause: legacy SkyFire placeholder rows (level 1) for creatures whose template level is 84-86 (summons/triggers of Stonecore, Halls of Origination, Lost City of the Tol'vir,
--   Throne of the Tides, Zul'Gurub). Creature::SelectLevel (Creature.cpp:1247) takes level and health_mod from the heroic row, so these were level-1 creatures; 43159 and 52137
--   also carried DamageModifier 2859.73 / 2972.86 (compensation for the level-1 base) which at the real level would be ~6 million per swing.
--   The other 97 level-1 heroic rows have template level 1 (triggers, dummies, unused, friendly NPCs such as Lieutenant Sinclari and the Elevator Construction Chief) and are left alone.
-- Fix: level_min/level_max = creature_template minlevel/maxlevel (ref_cpp has the same level); DamageModifier of 43159 and 52137 = their DUNGEON_NORMAL value (2.414 / 2, fix-29 calibrated).
-- Source: creature_template minlevel/maxlevel on dev, live DUNGEON_NORMAL rows of 43159 / 52137, ref_cpp creature_template.
-- Rollback: every UPDATE carries the old values in its trailing comment; full script state/hdm/heroic_dm_rollback_13.sql

UPDATE `creature_template_difficulty` SET `level_min` = 86, `level_max` = 86, `DamageModifier` = 1.0 WHERE `id` = 41201 AND `difficulty` = 'DUNGEON_HEROIC'; -- Noxious Mire rk 0, old L1-1 DM 1.0, spawn NULL
UPDATE `creature_template_difficulty` SET `level_min` = 85, `level_max` = 85, `DamageModifier` = 1.0 WHERE `id` = 41479 AND `difficulty` = 'DUNGEON_HEROIC'; -- Add Stalker rk 0, old L1-1 DM 1.0, spawn 644:6
UPDATE `creature_template_difficulty` SET `level_min` = 84, `level_max` = 84, `DamageModifier` = 2.414 WHERE `id` = 43159 AND `difficulty` = 'DUNGEON_HEROIC'; -- Stalactite Trigger - Boss rk 1, old L1-1 DM 2859.73, spawn NULL
UPDATE `creature_template_difficulty` SET `level_min` = 85, `level_max` = 85, `DamageModifier` = 1.0 WHERE `id` = 44796 AND `difficulty` = 'DUNGEON_HEROIC'; -- Tolvir Land Mine rk 0, old L1-1 DM 1.0, spawn NULL
UPDATE `creature_template_difficulty` SET `level_min` = 86, `level_max` = 86, `DamageModifier` = 1.0 WHERE `id` = 44834 AND `difficulty` = 'DUNGEON_HEROIC'; -- Blight of Ozumat rk 0, old L1-1 DM 1.0, spawn NULL
UPDATE `creature_template_difficulty` SET `level_min` = 85, `level_max` = 85, `DamageModifier` = 1.0 WHERE `id` = 47922 AND `difficulty` = 'DUNGEON_HEROIC'; -- Solar Winds rk 0, old L1-1 DM 1.0, spawn NULL
UPDATE `creature_template_difficulty` SET `level_min` = 85, `level_max` = 85, `DamageModifier` = 1.0 WHERE `id` = 49481 AND `difficulty` = 'DUNGEON_HEROIC'; -- Collapsing Icicle rk 0, old L1-1 DM 1.0, spawn NULL
UPDATE `creature_template_difficulty` SET `level_min` = 85, `level_max` = 85, `DamageModifier` = 2.0 WHERE `id` = 52137 AND `difficulty` = 'DUNGEON_HEROIC'; -- Voodoo Spirit rk 1, old L1-1 DM 2972.86, spawn NULL
