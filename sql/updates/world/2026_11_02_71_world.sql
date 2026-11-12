-- To-do 132 (quests flagged QUEST_FLAGS_UNAVAILABLE 0x4000 still offered), group B: Outland/Northrend dungeon quests that patch 4.3.0 re-issued
-- under new quest ids (29566-29863, givers moved inside the dungeons). The old ids were removed from the game, but our data still has the old
-- entrance NPCs offering them, so players and bots get two copies of the same quest and the old copy has no retail counterpart in 5.4.8.
-- Cause: alexkulya import kept the pre-4.3.0 queststarter/questender rows; the core does not evaluate the 0x4000 flag.
-- Change: remove starter/ender rows of 27 old quests (list below), log them in tt_removed_queststarter, and let Lakka's gossip option
--         (menu 7868, "I'll have you out of there in just a moment.") also work for the 4.3.0 version 29605 Brother Against Brother; until now the
--         condition only accepted the old 10097, which made 29605 impossible to finish once 10097 is gone.
-- Old id -> 4.3.0 replacement (same title) with starter present in ref_sf AND ref_cpp:
--   9496 Pride of the Fel Horde -> 29688 Advancing the Campaign (Ty'jin 16575 keeps 29688); 9524 Imprisoned in the Citadel (Randy 17288, no spawn) -> removed;
--   9572/9575 Weaken the Ramparts (A: Lt. Chadwick 17557, H: Stok'ton 17493) -> removed, Ramparts now has 54931 Stok'ton etc.; 9717 Oh, It's On! (T'shu 17857) -> removed;
--   9765 Preparing for War / 9766 Coilfang Armaments (Ysiel 17841) -> removed (9766 is not even in the 5.4.8 QuestV2.dbc);
--   10094 The Codex of Blood -> 29643; 10095 Into the Heart of the Labyrinth -> 29644; 10177 Trouble at Auchindoun -> 29642 (Mahfuun 54890);
--   10097 Brother Against Brother -> 29605; 10098 Terokk's Legacy -> 29606 (Isfar 54840 inside Sethekk Halls);
--   10164 Everything Will Be Alright -> 29595 (Aldrimus 19698 keeps 29595); 10165 Undercutting the Competition -> 29575; 10216 Safety Is Job One -> 29573 (Morphalius 54692);
--   10218 Someone Else's Hard Work Pays Off (Sha'heen 19671, no spawn) -> removed; 10284 Escape from Durnholde -> 29599 (Thrall 17876 keeps 29599);
--   10298 Hero of the Brood (Sa'at 20201) -> removed; 10882 Harbinger of Doom (A'dal 18481) -> removed;
--   13096 Gal'darah Must Pay -> 29834/29835; 13098 For Posterity -> 29840/29844; 13099 Just Checkin' -> 29836 (To'kini 28527 keeps 29836);
--   13108 Whatever it Takes! -> 29861; 13109 Diametrically Opposed -> 29860 (Stormherald Eljrrin 56027); 13167 Death to the Traitor King -> 29807;
--   13182 Don't Forget the Eggs! -> 29808 (Reclaimer A'zak 55564); 13190 All Things in Good Time (Kilix 26653, heroic daily) -> removed.
-- Source: warcraft.wiki.gg patch notes "Patch 4.3.0 (2011-11-29): Removed" / "Added, replacing previous version" per quest (e.g. Weaken the Ramparts (Horde),
--         Imprisoned in the Citadel (Alliance), Oh, It's On!, Preparing for War, Coilfang Armaments (quest), Someone Else's Hard Work Pays Off,
--         Hero of the Brood, Harbinger of Doom (quest), Gal'darah Must Pay, For Posterity, All Things in Good Time, Escape from Durnholde (BC Classic) id 10284,
--         Death to the Traitor King (Wrath Classic) id 13167, Don't Forget the Eggs! (Wrath Classic) id 13182); Wowhead MoP Classic marks 10094 and 13099
--         "obsolete by Blizzard" (its other old-id pages are carried over from TBC/Wrath Classic data and show the old givers, so they are not used as
--         evidence); ref_sf (SkyFire 5.4.8) and ref_cpp (Cata 4.3.4 sniff) have no queststarter/questender rows for any of the 27 old ids
--         while both have starters for the 29xxx replacements; 5.4.8 QuestV2.dbc lacks 9766. Lakka: world.quest_objective 29605 "Free Lakka" (npc 18956),
--         Lakka SmartAI event 62 menu 7868 option 0 runs timed script 1895600; ref_sf/ref_cpp carry the same 10097-only condition.
-- Rollback:
--   INSERT INTO creature_queststarter (id,quest) VALUES (16575,9496),(17288,9524),(17493,9572),(17557,9575),(17857,9717),(17841,9765),(17841,9766),(19542,10094),
--     (18933,10097),(18933,10098),(19698,10164),(19674,10165),(18893,10177),(19670,10216),(19671,10218),(17876,10284),(20201,10298),(18481,10882),(30671,13096),
--     (30676,13098),(28527,13099),(30105,13108),(30105,13109),(26653,13167),(26653,13182),(26653,13190);
--   INSERT INTO gameobject_queststarter (id,quest) VALUES (182947,10095);
--   INSERT INTO creature_questender (id,quest) VALUES (16575,9496),(17290,9524),(17558,9572),(17479,9575),(17857,9717),(17841,9765),(17841,9766),(18893,10095),
--     (18933,10097),(18933,10098),(19698,10164),(19674,10165),(19542,10177),(19674,10218),(18723,10284),(20130,10298),(18481,10882),(30671,13096),(30676,13098),
--     (30676,13099),(30105,13108),(30105,13109),(26653,13167),(26653,13182),(26653,13190);
--   INSERT INTO gameobject_questender (id,quest) VALUES (182947,10094),(183877,10216);
--   DELETE FROM tt_removed_queststarter WHERE removed='2026-11-02' AND quest IN (9496,9524,9572,9575,9717,9765,9766,10094,10095,10097,10098,10164,10165,10177,10216,10218,10284,10298,10882,13096,13098,13099,13108,13109,13167,13182,13190);
--   DELETE FROM conditions WHERE SourceTypeOrReferenceId=15 AND SourceGroup=7868 AND SourceEntry=0 AND ConditionTypeOrReference=9 AND ConditionValue1=29605;

DELETE FROM `creature_queststarter` WHERE (`id`,`quest`) IN (
(16575,9496),(17288,9524),(17493,9572),(17557,9575),(17857,9717),(17841,9765),(17841,9766),(19542,10094),
(18933,10097),(18933,10098),(19698,10164),(19674,10165),(18893,10177),(19670,10216),(19671,10218),(17876,10284),
(20201,10298),(18481,10882),(30671,13096),(30676,13098),(28527,13099),(30105,13108),(30105,13109),(26653,13167),
(26653,13182),(26653,13190));
DELETE FROM `gameobject_queststarter` WHERE (`id`,`quest`) IN ((182947,10095));

DELETE FROM `creature_questender` WHERE (`id`,`quest`) IN (
(16575,9496),(17290,9524),(17558,9572),(17479,9575),(17857,9717),(17841,9765),(17841,9766),(18893,10095),
(18933,10097),(18933,10098),(19698,10164),(19674,10165),(19542,10177),(19674,10218),(18723,10284),(20130,10298),
(18481,10882),(30671,13096),(30676,13098),(30676,13099),(30105,13108),(30105,13109),(26653,13167),(26653,13182),
(26653,13190));
DELETE FROM `gameobject_questender` WHERE (`id`,`quest`) IN ((182947,10094),(183877,10216));

DELETE FROM `tt_removed_queststarter` WHERE `kind`='c' AND (`id`,`quest`) IN (
(16575,9496),(17288,9524),(17493,9572),(17557,9575),(17857,9717),(17841,9765),(17841,9766),(19542,10094),
(18933,10097),(18933,10098),(19698,10164),(19674,10165),(18893,10177),(19670,10216),(19671,10218),(17876,10284),
(20201,10298),(18481,10882),(30671,13096),(30676,13098),(28527,13099),(30105,13108),(30105,13109),(26653,13167),
(26653,13182),(26653,13190));
DELETE FROM `tt_removed_queststarter` WHERE `kind`='g' AND (`id`,`quest`) IN ((182947,10095));
INSERT INTO `tt_removed_queststarter` (`kind`,`id`,`quest`,`removed`) VALUES
('c',16575,9496,'2026-11-02'),('c',17288,9524,'2026-11-02'),('c',17493,9572,'2026-11-02'),('c',17557,9575,'2026-11-02'),
('c',17857,9717,'2026-11-02'),('c',17841,9765,'2026-11-02'),('c',17841,9766,'2026-11-02'),('c',19542,10094,'2026-11-02'),
('c',18933,10097,'2026-11-02'),('c',18933,10098,'2026-11-02'),('c',19698,10164,'2026-11-02'),('c',19674,10165,'2026-11-02'),
('c',18893,10177,'2026-11-02'),('c',19670,10216,'2026-11-02'),('c',19671,10218,'2026-11-02'),('c',17876,10284,'2026-11-02'),
('c',20201,10298,'2026-11-02'),('c',18481,10882,'2026-11-02'),('c',30671,13096,'2026-11-02'),('c',30676,13098,'2026-11-02'),
('c',28527,13099,'2026-11-02'),('c',30105,13108,'2026-11-02'),('c',30105,13109,'2026-11-02'),('c',26653,13167,'2026-11-02'),
('c',26653,13182,'2026-11-02'),('c',26653,13190,'2026-11-02'),('g',182947,10095,'2026-11-02');

-- Lakka (18956) gossip option 0: also usable with the 4.3.0 quest 29605 taken (ElseGroup 1 = OR with the existing 10097 row).
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=15 AND `SourceGroup`=7868 AND `SourceEntry`=0 AND `ConditionTypeOrReference`=9 AND `ConditionValue1`=29605;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(15,7868,0,0,1,9,0,29605,0,0,0,0,0,'','Lakka - gossip option 0 - requires quest 29605 Brother Against Brother (4.3.0 version) taken');
