-- To-do 132 (quests flagged QUEST_FLAGS_UNAVAILABLE 0x4000 still offered), group C: two quests that never had a live giver in 5.4.8.
-- Cause: alexkulya import gave both a queststarter row although retail never offered them:
--   9344 A Hasty Departure (Far Seer Regulkut 16574, Thrallmar) is a Burning Crusade BETA quest that never went live; bots on prod completed it 679 times
--   because it is a plain talk-to quest, and its RewardNextQuest 9345 Preparing the Salve has no PrevQuestID so the real chain is not affected.
--   29853 Champion of the King (Black Knight 35557, Trial of the Champion) is the unused "King Varian Wrynn" twin of 29851 Champion of the Tournament
--   (both auto-accept/auto-complete on the Black Knight); retail only uses 29851.
-- Change: remove the two starter rows and the 9344 ender row, log them in tt_removed_queststarter. 29851 keeps its starter.
-- Source: warcraft.wiki.gg A Hasty Departure "Patch 2.0.1: Added, beta only", category "Removed from The Burning Crusade beta"; Wowhead MoP Classic has no
--         page for quest 9344 nor 29853 (HTTP 404, i.e. not in the MoP Classic quest data) while 29851 has one with Start: The Black Knight;
--         ref_sf (SkyFire 5.4.8) and ref_cpp (Cata 4.3.4 sniff) have no starter/ender for 9344 and 29853 but both have starter 35557 for 29851.
-- Rollback:
--   INSERT INTO creature_queststarter (id,quest) VALUES (16574,9344),(35557,29853);
--   INSERT INTO creature_questender (id,quest) VALUES (16574,9344);
--   DELETE FROM tt_removed_queststarter WHERE removed='2026-11-02' AND quest IN (9344,29853);

DELETE FROM `creature_queststarter` WHERE (`id`,`quest`) IN ((16574,9344),(35557,29853));
DELETE FROM `creature_questender` WHERE (`id`,`quest`) IN ((16574,9344));

DELETE FROM `tt_removed_queststarter` WHERE `kind`='c' AND (`id`,`quest`) IN ((16574,9344),(35557,29853));
INSERT INTO `tt_removed_queststarter` (`kind`,`id`,`quest`,`removed`) VALUES
('c',16574,9344,'2026-11-02'),
('c',35557,29853,'2026-11-02');
