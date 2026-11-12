-- Rollback: restore the tables listed in the Rollback section of state/l1_silverpine_hillsbrad_diff.md from the pre-apply dump.
-- Source: DeltaTho PR 15 via 1LineAtaTime/LoA-Pandaria-Playerbots b179e298 (GPLv2); concatenated in original order:
--   2026_10_29_986_49_rg_what_tomorrow_brings.sql
--   2026_10_29_986_50_rg_resistance_is_futile.sql
--   2026_10_29_986_51_rg_great_escape_start.sql
--   2026_10_29_986_52_rg_duplicate_spawns.sql
--   2026_10_29_986_53_rg_vanguards_not_immune.sql
--   2026_10_29_986_54_rg_fallen_forsaken.sql
--   2026_10_29_986_55_rg_catapults.sql
--   2026_10_29_986_56_rg_vanguard_phase_edge.sql

-- ===== 2026_10_29_986_49_rg_what_tomorrow_brings.sql
-- ported from PR 15 2026_10_27_65_world.sql (#986)
-- What Tomorrow Brings (27401): the 7th Legion Telescope seats the player in Gilneas Camera 01 (45427, Summon Gilneas Camera), but
-- the camera had no script, so it never moved and nothing gave the credit (Quest Credit: What Tomorrow Brings, kill credit 45430,
-- the camera target over the harbour). The camera now flies out over the harbour, holds there, credits the player and brings them
-- back to the telescope (see npc_silverpine_gilneas_camera).
-- Both world databases auto-complete the quest (flags 589824): it is handed in over the F.C.D., which then gives Fall Back!
-- ("<The F.C.D. buzzes.> <Howls can be heard in the background.>") in the Cathedral Quarter, as Excising the Taint is handed in
-- to Sylvanas' voice. (This core also lets an auto-complete quest be handed in at its ender before its objectives are done.)
UPDATE `quest_template` SET `Flags` = 589824 WHERE `ID` = 27401;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_gilneas_camera' WHERE `entry` = 45427;

-- ===== 2026_10_29_986_50_rg_resistance_is_futile.sql
-- ported from PR 15 2026_10_27_66_world.sql (#986)
-- Resistance is Futile (27423) is given automatically on the way out of Emberstone Village (warcraft.wiki.gg). The Cataclysm
-- Classic world database lists area triggers 6256-6259 (around Emberstone's Belmont and the road south) as the quest's
-- objectives; starting the quest from them is ours. Here only Forward Commander Onslaught offered it, who stays behind at the
-- overrun Forward Command. Start it from those area triggers: it comes over the F.C.D. ("<The F.C.D. buzzes.> This is
-- Commander Lorna Crowley..."), shown in its window as the player leaves Emberstone with Fall Back! handed in. Belmont does
-- not offer it.
DELETE FROM `areatrigger_queststarter` WHERE `id` IN (6256, 6257, 6258, 6259);
INSERT INTO `areatrigger_queststarter` (`id`, `quest`) VALUES
(6256, 27423),
(6257, 27423),
(6258, 27423),
(6259, 27423);
DELETE FROM `creature_queststarter` WHERE `id` = 45312 AND `quest` = 27423;

-- ===== 2026_10_29_986_51_rg_great_escape_start.sql
-- ported from PR 15 2026_10_27_67_world.sql (#986)
-- The Great Escape (27438) starts at Tempest's Reach, where retail's Flight of the Val'kyr (85073) and Summon Belmont (85079) put
-- Arthura and Belmont and where our data has the quest's Belmont (45312) kneeling by Godfrey's corpse, now shown. The static
-- Belmont 45474 at Forward Command is a copy of the escort Summon Belmont (84944) summons, absent from both world databases; it
-- stood in the overrun camp. It was the only ender of A Man Named Godfrey and Resistance is Futile, so Belmont 45312 takes
-- them instead (ours): at Emberstone until A Man Named Godfrey is completed, then at Tempest's Reach.
DELETE FROM `creature_addon` WHERE `guid` = 373716;
DELETE FROM `creature` WHERE `guid` = 373716 AND `id` = 45474;
DELETE FROM `creature_questender` WHERE `id` = 45312 AND `quest` IN (27406, 27423);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(45312, 27406),
(45312, 27423);

-- ===== 2026_10_29_986_52_rg_duplicate_spawns.sql
-- ported from PR 15 2026_10_27_68_world.sql (#986)
-- Ruins of Gilneas: spawns standing twice on the same spot (same entry, within a yard; for those walking a path, the same path).
-- Where one of the pair has a waypoint path and the other none, the one with the path stays. The removed spawns' paths go too.
DELETE FROM `creature_addon` WHERE `guid` IN (307480, 307575, 307550, 307612, 307522, 307587, 307549, 307592, 307602, 307553, 307502, 307509, 307539);
DELETE FROM `creature` WHERE `guid` IN (307480, 307575, 307550, 307612, 307522, 307587, 307549, 307592, 307602, 307553, 307502, 307509, 307539)
    AND `id` IN (45280, 45292, 45375, 45376, 45481, 45483, 45499, 45535, 45536, 45537, 45538);
DELETE FROM `waypoint_data` WHERE `id` IN (307575, 307550, 307612, 307522, 307502, 307509);

-- ===== 2026_10_29_986_53_rg_vanguards_not_immune.sql
-- ported from PR 15 2026_10_27_69_world.sql (#986)
-- Ruins of Gilneas: the Forsaken Vanguards (45280) were immune to NPCs (template unit_flags 0x8210: IMMUNE_TO_NPC and RENAME
-- besides CAN_SWIM), so they and the Worgen Rebels and Rushers attacking them across the Northern Headlands and Forward Command
-- never fought: neither side can start combat with, or attack, a unit immune to NPCs. Retail has no unit flags on them.
UPDATE `creature_template` SET `unit_flags` = `unit_flags` & ~(0x200 | 0x10) WHERE `entry` = 45280;

-- ===== 2026_10_29_986_54_rg_fallen_forsaken.sql
-- ported from PR 15 2026_10_27_70_world.sql (#986)
-- Ruins of Gilneas: the fallen Forsaken at two lost outposts stood alive
-- The F.C.D.: "find our outpost on the coast. By now the soldiers there are likely all dead, but their F.C.D. might be
-- operational" - the five Forsaken Vanguards around the device (GO 205363).
-- Break in Communications: Dreadwatch Outpost: "Dreadwatch is lost?" - its abominations lie dead (Permanent Feign Death, as on
-- retail), but its nine Forsaken Vanguards stood alive.
-- Lay them all down with Permanent Feign Death, as the fallen Vanguards of the overrun Forward Command (45532) are.
DELETE FROM `creature_addon` WHERE `guid` IN (306612, 306613, 306614, 306615, 306616,
    306591, 306620, 306622, 306623, 306624, 306626, 306701, 306732, 306733);
INSERT INTO `creature_addon` (`guid`, `auras`) VALUES
(306612, '29266'), (306613, '29266'), (306614, '29266'), (306615, '29266'), (306616, '29266'),
(306591, '29266'), (306620, '29266'), (306622, '29266'), (306623, '29266'), (306624, '29266'),
(306626, '29266'), (306701, '29266'), (306732, '29266'), (306733, '29266');

-- ===== 2026_10_29_986_55_rg_catapults.sql
-- ported from PR 15 2026_10_27_71_world.sql (#986)
-- Ruins of Gilneas: the Forsaken Catapults (45282) at Forward Command and their Blightspreader crews (45374) stood idle: no script.
-- Wowhead (MoP Classic) has the catapult casting Plague Barrel (84804, a missile anywhere in sight whose impact, 84803, hits,
-- damages buildings and leaves the Plague Slime pool 84802) and Flame Breath (84806, a short channel with a frontal cone, 84807),
-- and the Blightspreader Demoralizing Shout (13730). Neither world database scripts them. The catapults hold their ground and
-- lob barrels at what they fight, breathing fire at anything that closes in; the timings are ours.
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` IN (45282, 45374);
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (45282, 45374) AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(45282, 0, 0, 1, 4, 0, 100, 0, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Forsaken Catapult - On Aggro - Disable Combat Movement'),
(45282, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Forsaken Catapult - On Aggro - Disable Melee'),
(45282, 0, 2, 0, 0, 0, 100, 0, 1000, 3000, 7000, 9000, 0, 11, 84804, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Forsaken Catapult - In Combat - Cast ''Plague Barrel'''),
(45282, 0, 3, 0, 9, 0, 100, 0, 0, 8, 10000, 14000, 0, 11, 84806, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Forsaken Catapult - Within 0-8 Range - Cast ''Flame Breath'''),
(45374, 0, 0, 0, 0, 0, 100, 0, 2000, 5000, 25000, 30000, 0, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Forsaken Blightspreader - In Combat - Cast ''Demoralizing Shout''');

-- ===== 2026_10_29_986_56_rg_vanguard_phase_edge.sql
-- ported from PR 15 2026_10_27_72_world.sql (#986)
-- Ruins of Gilneas: Forsaken Vanguard 307207 stands on the edge of the Forward Command phase box (2026_10_27_62) fighting two
-- Worgen Rebels of the Northern Headlands just outside it, who stay in the default phase; units in different phases do not see
-- each other, so it stood idle. It belongs to the Headlands fight, which goes on whatever the state of Forward Command (it has
-- no overrun twin); put it back in the default phase. It is the only holding-camp fighter whose nearest enemy is outside.
UPDATE `creature` SET `phaseId` = 0 WHERE `guid` = 307207 AND `id` = 45280;

