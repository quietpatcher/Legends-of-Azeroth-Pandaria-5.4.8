-- Azuremyst Isle: the mage quest "Control" (9595) is still offered by Semid (17481) at Azure Watch.
-- What a player sees today: a draenei mage can take "Control" from Semid; the quest needs a Magewraith (17612) that nothing
--   summons any more, so it cannot be finished.
-- Cause: the class quests of Azure Watch were removed in patch 4.0.3a; our database kept the quest giver and turn-in relations
--   of this one. The priest quest "Help Tavara" (9586) of the same set has no quest giver here any more (only a turn-in row).
-- Checked: neither reference database has a quest giver for 9595 or 9586; no other relation, condition or script uses 9595.
-- Change: the quest giver row of Semid and the turn-in row of Bati (17514) for 9595 are deleted, and the orphan turn-in row of
--   Guvan (17482) for 9586.
-- Source: Wowpedia, Semid: "removed from World of Warcraft in patch 4.0.3a"; Cataclysm Preservation and SkyFire 5.4.8 world
--   databases (no creature_queststarter rows for 9595 and 9586), 18-11-2026.
-- Rollback (the rows before this update):
--   INSERT INTO `creature_queststarter` (`id`,`quest`) VALUES (17481,9595);
--   INSERT INTO `creature_questender` (`id`,`quest`) VALUES (17514,9595);
--   INSERT INTO `creature_questender` (`id`,`quest`) VALUES (17482,9586);

DELETE FROM `creature_queststarter` WHERE `id`=17481 AND `quest`=9595;  -- Semid, Control
DELETE FROM `creature_questender` WHERE `id`=17514 AND `quest`=9595;    -- Bati, Control
DELETE FROM `creature_questender` WHERE `id`=17482 AND `quest`=9586;    -- Guvan, Help Tavara
