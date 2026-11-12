-- To-do 132 (quests flagged QUEST_FLAGS_UNAVAILABLE 0x4000 still offered), group A: pre-Cataclysm quests that Blizzard removed in 4.0.1 / 4.0.3a.
-- Cause: alexkulya import kept creature_queststarter/questender rows for quests that no longer exist for players in 5.4.8;
--        the core ignores the 0x4000 flag, so the NPCs still offer them (826 starter at Master Gadrin was already dropped earlier, only the ender row was left).
-- Change: remove the starter/ender rows of 826 Zalazane (Master Gadrin 3188, Durotar), 4141 Muigin and Larion (Muigin 9119, Un'Goro),
--         6521 An Unholy Alliance (Bragor Bloodfist 36273, Undercity; Scholomance chain) and log them in tt_removed_queststarter.
-- Source: warcraft.wiki.gg Zalazane (quest) "Patch 4.0.1: Removed. Replaced with Cleanup on Isle E."; Muigin and Larion "Patch 4.0.3a: Removed";
--         An Unholy Alliance "Patch 4.0.3a: Removed"; ref_sf (SkyFire 5.4.8) and ref_cpp (Cata 4.3.4 sniff) have quest_template rows for all three but no
--         queststarter/questender rows (ref_sf keeps a starter for only 1 of the 3913 quests with flag 0x4000, ref_cpp for 9). Wowhead MoP Classic
--         still shows pages for these ids (carried over from Classic-era data, no obsolete marker) and is therefore not used as evidence. Chain: 4142 A Visit to Gregan
--         (PrevQuestID 4141) and 6522 (RewardNextQuest 6521) have no starter any more, so nothing else depends on these.
-- Rollback:
--   INSERT INTO creature_queststarter (id,quest) VALUES (9119,4141),(36273,6521);
--   INSERT INTO creature_questender (id,quest) VALUES (3188,826),(9119,4141);
--   DELETE FROM tt_removed_queststarter WHERE removed='2026-11-02' AND quest IN (826,4141,6521);

DELETE FROM `creature_queststarter` WHERE (`id`,`quest`) IN ((9119,4141),(36273,6521));
DELETE FROM `creature_questender` WHERE (`id`,`quest`) IN ((3188,826),(9119,4141));

DELETE FROM `tt_removed_queststarter` WHERE `kind`='c' AND (`id`,`quest`) IN ((9119,4141),(36273,6521));
INSERT INTO `tt_removed_queststarter` (`kind`,`id`,`quest`,`removed`) VALUES
('c',9119,4141,'2026-11-02'),
('c',36273,6521,'2026-11-02');
