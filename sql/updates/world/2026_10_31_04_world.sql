-- To-do 461 (Sabina Pilgrim attacks Horde players near Arctanus, Thunder Peak, Ashenvale):
-- Cause: Sabina Pilgrim (34283, Alliance, faction 2163) and her Horde counterpart Stikwad (34512) stand on the same spot, both phaseMask 1, so Horde players see and get aggroed by Sabina.
-- Change: phase them apart with the Ashenvale team phases that already exist (phase_definitions zone 331: Horde 4097 = 1|4096, Alliance 8193 = 1|8192; 4096/8192 unused by other creatures in zone 331): Sabina 8192 (Alliance only), Stikwad 4096 (Horde only).
-- Source: Wowpedia/Warcraft Wiki + WoWWiki Sabina_Pilgrim ("Sabina and her Horde counterpart, Stikwad, are phased apart from one another").
-- Rollback: UPDATE creature SET phaseMask = 1 WHERE guid IN (307992, 302664);
UPDATE `creature` SET `phaseMask` = 8192 WHERE `guid` = 307992 AND `id` = 34283;
UPDATE `creature` SET `phaseMask` = 4096 WHERE `guid` = 302664 AND `id` = 34512;

-- To-do 462 (Astranaar Sentinels, dead decoration in Silverwind Refuge, attack Horde players):
-- Cause: Astranaar Sentinel 52000 has the Permanent Feign Death aura (58951) like the other dead Night Elves of Silverwind Refuge (e.g. Shandrina 3955) but, unlike them, flags_extra 0 (not civilian) and hostile faction 79, so it gets AggressorAI.
-- Change: flags_extra 2 (CREATURE_FLAG_EXTRA_CIVILIAN), same as Shandrina 3955 / Harklan 3956 in the same camp. Core untouched.
-- Source: Wowpedia/WoWWiki Silverwind Refuge + Astranaar Sentinel (killed in the Horde assault after the Cataclysm, lie dead in the camp).
-- Rollback: UPDATE creature_template SET flags_extra = 0 WHERE entry = 52000;
UPDATE `creature_template` SET `flags_extra` = 2 WHERE `entry` = 52000;
