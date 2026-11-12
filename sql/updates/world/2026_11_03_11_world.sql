-- Heroic dungeon DamageModifier, step 2: outliers among Cataclysm (exp 3) and Pandaria (exp 4) heroic rows in creature_template_difficulty
-- DUNGEON_HEROIC (23 rows). The big Cata/MoP heroic cohort is NOT touched (Cata heroic elites 2.0 / bosses 5.5, MoP heroic bosses 3 are
-- consistent with ref_cpp ratios and with retail swing sizes), only rows far outside it.
-- Cause: legacy multipliers of 35-60 (Defias Reaper/Watcher 42.2, Helix Gearbreaker 60, Naz'jar Honor Guard 35, Lupine Spectre 35, Yu'lon 13.7,
-- Ahune 16.9 ...) on a Cata/MoP base give 100k-250k per swing for trash and 3x boss level for Helix (105,780 per swing at 0.5 s attack time).
-- Method: ref_cpp does not give an absolute Cata scale (its damage_exp3 is flat 197-217 for level 80-87), so the ref_cpp heroic DM x base ratio is
--   only used RELATIVELY: new DM = K3 (0.59, median of the ratio live/ref-derived over 233 consistent exp 3 rank-1 rows) x ref_cpp-derived DM, clamped to
--   p10..p90 of the live cohort with the same health_mod band (hm <3: 1.98-2.15, 3-10: 1.98-2.15, 10-25: 1.98-3.4, >=25: 2.0-6.7). No ref_cpp heroic: cohort median.
--   R4 (exp 4, no reference for heroics in ref_sf/ref_cpp): rank 1-3 with DM > 8 capped at the p90 of the live exp 4 heroic cohort (5.0).
-- Source: ref_cpp creature_template (heroic template via difficulty_entry_1), live cohort statistics of creature_template_difficulty DUNGEON_HEROIC;
--         deadmines report the internal notes (Helix 60 vs 5.5, Oaf 2 < normal, Reaper/Watcher 42.2).
-- Rollback: every UPDATE carries the old value in its trailing comment; the complete script is
--           state/hdm/heroic_dm_rollback_11.sql (UPDATE ... SET DamageModifier = <old> WHERE id = <id> AND difficulty = 'DUNGEON_HEROIC').
-- Repeatable: plain UPDATEs keyed on (id, difficulty); no INSERTs.


UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.0 WHERE `id` = 23115 AND `difficulty` = 'DUNGEON_HEROIC'; -- Ogrila Peacekeeper lvl 85-85 exp 3 rank 0 Outland, old 7.0, min swing 37866 -> 5410 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 5.0 WHERE `id` = 25740 AND `difficulty` = 'DUNGEON_HEROIC'; -- Ahune lvl 87-87 exp 4 rank 1 Coilfang: The Slave Pens, old 16.9, min swing 119179 -> 35260 (R4)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 2.153 WHERE `id` = 40633 AND `difficulty` = 'DUNGEON_HEROIC'; -- Nazjar Honor Guard lvl 85-85 exp 3 rank 1 no spawn, old 35.0, min swing 189332 -> 11647 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 2.0 WHERE `id` = 40655 AND `difficulty` = 'DUNGEON_HEROIC'; -- Ozumat lvl 87-87 exp 3 rank 1 no spawn, old 0.77, min swing 5430 -> 14104 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.0 WHERE `id` = 40923 AND `difficulty` = 'DUNGEON_HEROIC'; -- Unstable Corruption lvl 85-85 exp 3 rank 0 no spawn, old 7.0, min swing 37866 -> 5410 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.977 WHERE `id` = 44404 AND `difficulty` = 'DUNGEON_HEROIC'; -- Nazjar Tempest Witch lvl 85-85 exp 3 rank 1 no spawn, old 37.7, min swing 188643 -> 9893 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.977 WHERE `id` = 47296 AND `difficulty` = 'DUNGEON_HEROIC'; -- Helix Gearbreaker lvl 87-87 exp 3 rank 1 Deadmines, old 60.0, min swing 105780 -> 3485 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 3.418 WHERE `id` = 47403 AND `difficulty` = 'DUNGEON_HEROIC'; -- Defias Reaper lvl 86-86 exp 0 rank 1 no spawn, old 42.2, min swing 233155 -> 18884 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.977 WHERE `id` = 47404 AND `difficulty` = 'DUNGEON_HEROIC'; -- Defias Watcher lvl 86-86 exp 3 rank 1 Deadmines, old 42.2, min swing 233155 -> 10923 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.0 WHERE `id` = 47714 AND `difficulty` = 'DUNGEON_HEROIC'; -- Vapor lvl 86-87 exp 0 rank 0 no spawn, old 7.0, min swing 44020 -> 6288 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.0 WHERE `id` = 48266 AND `difficulty` = 'DUNGEON_HEROIC'; -- Defias Cannon lvl 85-85 exp 3 rank 0 Deadmines, old 7.0, min swing 37866 -> 5410 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 2.0 WHERE `id` = 48571 AND `difficulty` = 'DUNGEON_HEROIC'; -- Waterspout lvl 85-85 exp 3 rank 1 no spawn, old 1.407, min swing 7611 -> 10819 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.1 WHERE `id` = 48983 AND `difficulty` = 'DUNGEON_HEROIC'; -- Geyser lvl 87-87 exp 3 rank 0 no spawn, old 7.0, min swing 49364 -> 7757 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.0 WHERE `id` = 50561 AND `difficulty` = 'DUNGEON_HEROIC'; -- Bloodthirsty Ghoul lvl 87-87 exp 0 rank 0 no spawn, old 7.0, min swing 24682 -> 3526 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 2.153 WHERE `id` = 50834 AND `difficulty` = 'DUNGEON_HEROIC'; -- Rethilgore lvl 87-87 exp 0 rank 1 no spawn, old 35.0, min swing 246820 -> 15183 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 2.153 WHERE `id` = 50851 AND `difficulty` = 'DUNGEON_HEROIC'; -- Wolf Master Nandos lvl 87-87 exp 0 rank 1 no spawn, old 35.0, min swing 246820 -> 15183 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 2.153 WHERE `id` = 50857 AND `difficulty` = 'DUNGEON_HEROIC'; -- Odo the Blindwatcher lvl 85-85 exp 0 rank 1 no spawn, old 35.0, min swing 4437 -> 273 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 2.153 WHERE `id` = 50869 AND `difficulty` = 'DUNGEON_HEROIC'; -- Razorclaw the Butcher lvl 87-87 exp 0 rank 1 no spawn, old 35.0, min swing 394912 -> 24293 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 1.977 WHERE `id` = 50923 AND `difficulty` = 'DUNGEON_HEROIC'; -- Lupine Spectre lvl 87-87 exp 3 rank 1 no spawn, old 35.0, min swing 246820 -> 13942 (R3)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 5.0 WHERE `id` = 56762 AND `difficulty` = 'DUNGEON_HEROIC'; -- Yulon lvl 92-92 exp 4 rank 1 no spawn, old 13.7, min swing 327362 -> 119475 (R4)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 5.0 WHERE `id` = 58856 AND `difficulty` = 'DUNGEON_HEROIC'; -- Haunting Sha lvl 91-91 exp 4 rank 1 no spawn, old 15.0, min swing 280800 -> 93600 (R4)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 5.0 WHERE `id` = 58875 AND `difficulty` = 'DUNGEON_HEROIC'; -- Darkmaster Gandling lvl 92-92 exp 4 rank 1 Scholomance, old 12.8, min swing 305856 -> 119475 (R4)
UPDATE `creature_template_difficulty` SET `DamageModifier` = 5.0 WHERE `id` = 59080 AND `difficulty` = 'DUNGEON_HEROIC'; -- Darkmaster Gandling lvl 92-92 exp 4 rank 1 Scholomance, old 12.8, min swing 305856 -> 119475 (R4)
