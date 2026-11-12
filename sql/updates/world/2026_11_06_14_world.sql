-- Rollback: restore the tables listed in the Rollback section of state/l1_silverpine_hillsbrad_diff.md from the pre-apply dump.
-- Source: DeltaTho PR 15 via 1LineAtaTime/LoA-Pandaria-Playerbots b179e298 (GPLv2); concatenated in original order:
--   2026_10_29_986_41_sp_pyrewoods_fall.sql
--   2026_10_29_986_42_sp_sylvanas_gossip_11823.sql
--   2026_10_29_986_43_sp_to_forward_command.sql
--   2026_10_29_986_44_rg_korok_the_colossus.sql
--   2026_10_29_986_45_rg_dreadwatch_area_trigger.sql
--   2026_10_29_986_46_rg_forward_command_phases.sql
--   2026_10_29_986_47_rg_quest_invisible_forsaken.sql
--   2026_10_29_986_48_rg_on_whose_orders.sql

-- ===== 2026_10_29_986_41_sp_pyrewoods_fall.sql
-- ported from PR 15 2026_10_27_55_world.sql (#986)
-- Pyrewood's Fall (27550): Pyrewood Village only burns once the player has burned it
-- The quest's reward spell, Detect: Quest Invis Zone 16 (85598), lets the player see invisibility type 24 at strength 1, which
-- is what Apply Quest Invis Zone 16 (85599) puts on things, but nothing in the village had it: the sniffed fires (Fire 205577
-- across the village, 205578 in the chapel, inn and town hall) burned for everyone from the start, though the quest has the
-- player set the freshly taken village alight. No sniff has the fires' invisibility; give them type 24 at strength 1 so they
-- show once Pyrewood's Fall is turned in.
DELETE FROM `gameobject_addon` WHERE `guid` IN (SELECT `guid` FROM `gameobject` WHERE `id` IN (205577,205578));
INSERT INTO `gameobject_addon` (`guid`,`invisibilityType`,`invisibilityValue`)
SELECT `guid`,24,1 FROM `gameobject` WHERE `id` IN (205577,205578);

-- ===== 2026_10_29_986_42_sp_sylvanas_gossip_11823.sql
-- ported from PR 15 2026_10_27_56_world.sql (#986)
-- Gossip menu 11823 is shared by Sylvanas at Forsaken High Command and the Sepulcher (44365) and both Sylvanas of the Forsaken
-- Front (45525, 45617). The Cities in Dust option (start the march) only checked the quest, so every one of them offered it to a
-- player on Cities in Dust, though only 45617's script starts the march. Show it only on 45617.
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 11823 AND `SourceEntry` = 0 AND `ConditionTypeOrReference` = 31;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(15, 11823, 0, 0, 0, 31, 1, 3, 45617, 0, 0, 0, 0, '', 'Lady Sylvanas Windrunner - Cities in Dust option only on the Sylvanas after Rise, Godfrey');

-- ===== 2026_10_29_986_43_sp_to_forward_command.sql
-- ported from PR 15 2026_10_27_57_world.sql (#986)
-- To Forsaken Forward Command (27290): Sylvanas at the Sepulcher says "Arthura will escort you to Forward Command. Tell me when
-- you are ready and I will send you on your way." but had nothing to tell her, so the player had to find their own way into
-- Gilneas. 5.4.8 has the flight: Flight of the Val'kyr (84695) summons Arthura (45318, vehicle 1100) beside her and seats the
-- player through its ride aura (84691, which also gives the Gilneas Act I phase). No sniff has the gossip option, its text or the
-- flight path; the option's text is ours. It shows only on the Sepulcher's Sylvanas (the same entry stands at Forsaken High
-- Command) while the quest is in the log: it has no objectives, so it is complete as soon as it is accepted.
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_silverpine_arthura_forward_command' WHERE `entry` = 45318;

DELETE FROM `spell_script_names` WHERE `spell_id` = 84695 AND `ScriptName` = 'spell_silverpine_flight_of_the_valkyr_forward_command';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(84695, 'spell_silverpine_flight_of_the_valkyr_forward_command');

DELETE FROM `gossip_menu_option` WHERE `MenuID` = 11823 AND `OptionID` = 1;
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`, `OptionBroadcastTextID`, `OptionType`, `OptionNpcflag`, `ActionMenuID`, `ActionPoiID`, `BoxCoded`, `BoxMoney`, `BoxText`, `BoxBroadcastTextID`, `VerifiedBuild`) VALUES
(11823, 1, 0, 'I am ready to go to Forsaken Forward Command.', 0, 1, 1, 0, 0, 0, 0, NULL, 0, 0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 11823 AND `SourceEntry` = 1;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(15, 11823, 1, 0, 0, 47, 0, 27290, 10, 0, 0, 0, 0, '', 'Lady Sylvanas Windrunner - show the Forward Command option while To Forsaken Forward Command is in the log'),
(15, 11823, 1, 0, 0, 31, 1, 3, 44365, 306012, 0, 0, 0, '', 'Lady Sylvanas Windrunner - Forward Command option only on the Sylvanas at the Sepulcher');

-- ===== 2026_10_29_986_44_rg_korok_the_colossus.sql
-- ported from PR 15 2026_10_27_60_world.sql (#986)
-- Korok the Colossus (27322, started by an item Korok drops): retail also lets High Warlord Cromush take it at the Forsaken Front
-- (45593, around Godfrey's body) and at the Battlefront (46125), as well as Forward Commander Onslaught and Cromush 45631. 45593
-- has the quest-ender flag on retail (npcflag 2) but none here.
DELETE FROM `creature_questender` WHERE `quest` = 27322 AND `id` IN (45593, 46125);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(45593, 27322),
(46125, 27322);
UPDATE `creature_template` SET `npcflag` = `npcflag` | 2 WHERE `entry` = 45593;

-- ===== 2026_10_29_986_45_rg_dreadwatch_area_trigger.sql
-- ported from PR 15 2026_10_27_61_world.sql (#986)
-- Break in Communications: Dreadwatch Outpost (27349): "Investigate Dreadwatch Outpost" is an area-trigger objective, but no
-- area trigger was linked to it, so the objective was never met (the quest could only be handed in early through its
-- auto-complete flag). The Cataclysm Classic world database gives it as AreaTrigger 6246 (Dreadwatch Outpost, Northern
-- Headlands). This core keys area-trigger objectives by the objective's own id, so the link goes through
-- areatrigger_involvedrelation, which also wants the quest's exploration flag.
DELETE FROM `areatrigger_involvedrelation` WHERE `id` = 6246;
INSERT INTO `areatrigger_involvedrelation` (`id`, `quest`) VALUES
(6246, 27349);
UPDATE `quest_objective` SET `objectId` = 6246 WHERE `questId` = 27349 AND `id` = 266335;
UPDATE `quest_template_addon` SET `SpecialFlags` = `SpecialFlags` | 2 WHERE `ID` = 27349;

-- ===== 2026_10_29_986_46_rg_forward_command_phases.sql
-- ported from PR 15 2026_10_27_62_world.sql (#986)
-- Ruins of Gilneas (zone 4706), Horde: phase the story around Forsaken Forward Command
-- Retail has every spawn of the zone in phase 274 "Gilneas Act I" (both world databases) and its area triggers (Dreadwatch
-- Outpost, the edge of Emberstone Village) also carry phase 274, but here only the ride aura of the flight in gave it. Give it
-- zone-wide to everyone on the Horde storyline (To Forsaken Forward Command taken or done), so those area triggers work.
-- Forward Command was spawned twice on the same spots: holding (Onslaught, Belmont, defenders, catapults, Blightspreaders,
-- Sharpshooters and the attacking worgen) and overrun after Fall Back! (feign-death Vanguards and catapults with their
-- Blightspreaders, Onslaught dead, worgen, the 7th Legion marching through in columns). Retail sniffed only the first.
--   199  Forward Command holding     Fall Back! not taken (an unused generic phase, "Quest Zone-Specific 24")
--   275  Forward Command overrun     Fall Back! taken, completed or rewarded ("Gilneas Act II", also given by the escape flight)
--   276  Godfrey's corpse and Arthura at Tempest's Reach   The Great Escape not taken ("Gilneas Act III"; Arthura then carries
--        the corpse away)
-- The ids and the quest that switches them are ours; no sniff has them.
UPDATE `creature` SET `phaseId` = 199, `phaseGroup` = 0 WHERE `map` = 0 AND `id` IN (45280, 45282, 45292, 45312, 45313, 45314, 45315, 45374, 45375, 45376)
    AND `position_x` BETWEEN -1110 AND -800 AND `position_y` BETWEEN 1440 AND 1700;
UPDATE `creature` SET `phaseId` = 275, `phaseGroup` = 0 WHERE `map` = 0 AND `id` IN (45532, 45533, 45534, 45535, 45539, 45541, 51192);
UPDATE `creature` SET `phaseId` = 276, `phaseGroup` = 0 WHERE (`guid`, `id`) IN ((306589, 44369), (306590, 45314));

DELETE FROM `phase_area` WHERE `AreaId` = 4706 AND `PhaseId` IN (199, 274, 275, 276);
INSERT INTO `phase_area` (`AreaId`, `PhaseId`, `Comment`) VALUES
(4706, 274, 'Ruins of Gilneas - Gilneas Act I for the Horde storyline (area triggers)'),
(4706, 199, 'Ruins of Gilneas - Forsaken Forward Command holding'),
(4706, 275, 'Ruins of Gilneas - Forsaken Forward Command overrun after Fall Back!'),
(4706, 276, 'Ruins of Gilneas - Godfrey''s corpse at Tempest''s Reach before The Great Escape');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 26 AND `SourceEntry` = 4706 AND `SourceGroup` IN (199, 274, 275, 276);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(26, 274, 4706, 0, 0, 47, 0, 27290, 74, 0, 0, 0, 0, '', 'Ruins of Gilneas - phase 274 once To Forsaken Forward Command is taken'),
(26, 199, 4706, 0, 0, 47, 0, 27405, 33, 0, 0, 0, 0, '', 'Ruins of Gilneas - phase 199 while Fall Back! is not taken'),
(26, 275, 4706, 0, 0, 47, 0, 27405, 74, 0, 0, 0, 0, '', 'Ruins of Gilneas - phase 275 once Fall Back! is taken'),
(26, 276, 4706, 0, 0, 47, 0, 27438, 33, 0, 0, 0, 0, '', 'Ruins of Gilneas - phase 276 while The Great Escape is not taken');

-- ===== 2026_10_29_986_47_rg_quest_invisible_forsaken.sql
-- ported from PR 15 2026_10_27_63_world.sql (#986)
-- Ruins of Gilneas: show the quest-invisible Forsaken where the story puts them
-- Belmont, Arthura and the Deathstalkers carry "Apply Quest Invis Zone 7/9/10/11" (template or spawn auras, as on retail) and
-- nothing gave the matching "Detect: Quest Invis Zone N", so they were invisible: the Deathstalkers and Arthura at Forward
-- Command, Belmont and Arthura at Emberstone Village (where Fall Back! sends the player) and at Tempest's Reach. Retail does
-- not record what gave the detections; give them in the zone at the stage each group belongs to (ours):
--   Zone 7  (84685)  Deathstalkers at Forward Command      until Fall Back! is taken
--   Zone 9  (84711)  Arthura at Forward Command             from To Forsaken Forward Command taken until Fall Back! is taken
--   Zone 10 (84937)  Belmont and Arthura at Emberstone      from Fall Back! taken until A Man Named Godfrey is completed
--   Zone 11 (85039)  Belmont and Arthura at Tempest's Reach from A Man Named Godfrey completed until The Great Escape is done
-- (Belmont at Forward Command has his invisibility overridden by his spawn, as in the sniff.)
DELETE FROM `spell_area` WHERE `spell` IN (84685, 84711, 84937, 85039) AND `area` = 4706;
INSERT INTO `spell_area` (`spell`, `area`, `quest_start`, `quest_end`, `aura_spell`, `racemask`, `gender`, `autocast`, `quest_start_status`, `quest_end_status`) VALUES
(84685, 4706, 0, 27405, 0, 0, 2, 1, 0, 33),
(84711, 4706, 27290, 27405, 0, 0, 2, 1, 74, 33),
(84937, 4706, 27405, 27406, 0, 0, 2, 1, 74, 41),
(85039, 4706, 27406, 27438, 0, 0, 2, 1, 66, 41);

-- ===== 2026_10_29_986_48_rg_on_whose_orders.sql
-- ported from PR 15 2026_10_27_64_world.sql (#986)
-- On Whose Orders? (27364) starts by itself (Wowhead, warcraft.wiki.gg) when the player takes on Master Sergeant Pietro Zaren,
-- who carries the orders: 5.4.8 has Start Quest: Master Sergeant Zaren (84870), which nothing cast, and both world databases have
-- the quest auto-accepted and auto-completed (flags 589824), here 0. Have the player cast it when Zaren is pulled (the trigger is
-- ours); the quest's prerequisites still apply. Forward Commander Onslaught still offers it, as on retail.
UPDATE `quest_template` SET `Flags` = 589824 WHERE `ID` = 27364;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 45405 AND `source_type` = 0 AND `id` = 3;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(45405, 0, 3, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 85, 84870, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Master Sergeant Pietro Zaren - On Aggro - Invoker Cast Start Quest: Master Sergeant Zaren');

