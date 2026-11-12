-- Heroic dungeons (player path): heroic loot of the Nexus commander and heroic stats of the Hour of Twilight bosses.
-- Cause 1: Commander Stoutbeard (26796) and Commander Kolurg (26798) exist only in heroic Nexus, but every loot row
--          had lootmode DUNGEON_NORMAL, so the boss dropped nothing.
-- Cause 2: Hour of Twilight (map 940) is heroic only, but Arcurion (54590), Archbishop Benedictus (54938) and
--          Asira Dawnslayer (54968) only had a DUNGEON_NORMAL row. Without a heroic row the core falls back to
--          DamageModifier 1.0, so these bosses hit for a fraction of their intended damage.
-- Source: 5.4.8 client JournalEncounterItem.dbc (items 37728-37731 listed for the heroic commander encounter);
--         5.4.8 MapDifficulty.dbc (map 940 has heroic only); values copied from the existing rows of the same
--         creatures, as done for the other heroic-only maps in 2026_11_03_12.
-- Rollback:
--   UPDATE creature_loot_template SET lootmode='DUNGEON_NORMAL' WHERE entry IN (26796,26798) AND lootmode='DUNGEON_HEROIC';
--   DELETE FROM creature_template_difficulty WHERE id IN (54590,54938,54968) AND difficulty='DUNGEON_HEROIC';
UPDATE creature_loot_template SET lootmode='DUNGEON_HEROIC' WHERE entry IN (26796,26798) AND lootmode='DUNGEON_NORMAL';

DELETE FROM creature_template_difficulty WHERE id IN (54590,54938,54968) AND difficulty='DUNGEON_HEROIC';
INSERT INTO creature_template_difficulty (id, difficulty, health_mod, DamageModifier, level_min, level_max)
SELECT id, 'DUNGEON_HEROIC', health_mod, DamageModifier, level_min, level_max
  FROM creature_template_difficulty WHERE id IN (54590,54938,54968) AND difficulty='DUNGEON_NORMAL';
