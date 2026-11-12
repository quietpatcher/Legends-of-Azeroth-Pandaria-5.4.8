-- Rollback: restore the tables listed in the Rollback section of state/l1_silverpine_hillsbrad_diff.md from the pre-apply dump.
-- Source: DeltaTho PR 15 via 1LineAtaTime/LoA-Pandaria-Playerbots b179e298 (GPLv2); concatenated in original order:
--   2026_10_29_986_57_rg_abominations_feign_death.sql
--   2026_10_29_986_58_rg_on_whose_orders_fcd.sql
--   2026_10_29_986_59_rg_area_trigger_quests.sql
--   2026_10_29_986_60_rg_keg_delivery.sql
--   2026_10_29_986_64_sp_dalaran_crater_portal_invis.sql
--   2026_10_29_986_77_sp_ambermill_daschla.sql
--   2026_10_29_986_78_sp_trio_step_aside.sql
--   2026_10_29_986_79_sp_cities_in_dust_song.sql

-- ===== 2026_10_29_986_57_rg_abominations_feign_death.sql
-- ported from PR 15 2026_10_27_73_world.sql (#986)
-- Ruins of Gilneas: the abominations (45345) at Dreadwatch Outpost and nearby lie in Permanent Feign Death (template aura, as on
-- retail) but were set to wander (random movement, 3 yards), so they got up and walked about. Keep them still.
UPDATE `creature` SET `MovementType` = 0, `wander_distance` = 0 WHERE `id` = 45345;

-- ===== 2026_10_29_986_58_rg_on_whose_orders_fcd.sql
-- ported from PR 15 2026_10_27_74_world.sql (#986)
-- On Whose Orders? (27364) comes over the F.C.D. ("<The F.C.D. buzzes.> ... Find him at the Cathedral Quarter in Gilneas City and
-- take him out") once Captain Rutsak has told the player of the 7th Legion and Master Sergeant Zaren and sent them to avenge his
-- men (Vengeance for Our Soldiers, 27360); Wowhead and warcraft.wiki.gg have it start automatically. Nothing gave it, so the
-- player who turned in to Rutsak got no word of Zaren. Have the player cast Start Quest: Master Sergeant Zaren (84870) when they
-- take Vengeance for Our Soldiers from Rutsak, and again when they hand it in to him in case it was missed; its script shows the
-- quest in its window as it is accepted (spell_silverpine_start_quest_master_sergeant_zaren). The quest's prerequisites still
-- apply and the spell does nothing once the quest is taken or done. Pulling Zaren (2026_10_27_64) and Forward Commander
-- Onslaught still give it too.
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 45389;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 45389 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(45389, 0, 0, 0, 19, 0, 100, 0, 27360, 0, 0, 0, 0, 85, 84870, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Captain Rutsak - On Quest ''Vengeance for Our Soldiers'' Taken - Invoker Cast Start Quest: Master Sergeant Zaren'),
(45389, 0, 1, 0, 20, 0, 100, 0, 27360, 0, 0, 0, 0, 85, 84870, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Captain Rutsak - On Quest ''Vengeance for Our Soldiers'' Rewarded - Invoker Cast Start Quest: Master Sergeant Zaren');

DELETE FROM `spell_script_names` WHERE `spell_id` = 84870 AND `ScriptName` = 'spell_silverpine_start_quest_master_sergeant_zaren';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(84870, 'spell_silverpine_start_quest_master_sergeant_zaren');

-- ===== 2026_10_29_986_59_rg_area_trigger_quests.sql
-- ported from PR 15 2026_10_27_75_world.sql (#986)
-- Four quests completed by reaching a place had no area trigger linked to their area-trigger objective. They are handed in
-- from the log (auto-complete), and the core let such quests be handed in unfinished, which hid this; now they need the
-- objective done. The Cataclysm Classic world database gives each objective's area trigger. This core keys area-trigger
-- objectives by the objective's own id, so the link goes through areatrigger_involvedrelation.
--   14389 Wasn't It Obvious?   AreaTrigger 5610
--   25930 Ascending the Vale   AreaTrigger 5940
--   26258 Deathwing's Fall     AreaTrigger 6126
--   28228 Rejoining the Forest AreaTrigger 6505
DELETE FROM `areatrigger_involvedrelation` WHERE `id` IN (5610, 5940, 6126, 6505);
INSERT INTO `areatrigger_involvedrelation` (`id`, `quest`) VALUES
(5610, 14389),
(5940, 25930),
(6126, 26258),
(6505, 28228);
UPDATE `quest_objective` SET `objectId` = 5610 WHERE `questId` = 14389 AND `type` = 10;
UPDATE `quest_objective` SET `objectId` = 5940 WHERE `questId` = 25930 AND `type` = 10;
UPDATE `quest_objective` SET `objectId` = 6126 WHERE `questId` = 26258 AND `type` = 10;
UPDATE `quest_objective` SET `objectId` = 6505 WHERE `questId` = 28228 AND `type` = 10;
UPDATE `quest_template_addon` SET `SpecialFlags` = `SpecialFlags` | 2 WHERE `ID` IN (14389, 25930, 26258, 28228);

-- ===== 2026_10_29_986_60_rg_keg_delivery.sql
-- ported from PR 15 2026_10_27_76_world.sql (#986)
-- It Does You No Good In The Keg (30624 Alliance, 30653 Horde): beer is delivered to Zhu's Wardens (Koro Mistwalker 59846 gives
-- credit 59878), the Shado-Pan (Fo Sho Knucklebump 59829, credit 59880), the Crane Wing priests (credit 59879) and the faction's
-- settlers: the night elves (Lyalia 59849, credit 59881 "Beer Credit: Alliance") for the Alliance, the tauren (Sunwalker Dezco
-- 59851, credit 59882 "Beer Credit: Horde") for the Horde, as both world databases have the objectives. Lyalia gave the Horde
-- credit and Dezco the Crane Wing priests', so the Alliance copy could never be finished (it was handed in unfinished through the
-- core's old auto-complete loophole). Lyalia now gives 59881 and Dezco 59882. Until the Crane Wing priests' place is known (none
-- stand near the camps), each settler leader also gives the priests' credit, so each faction gets it from its own, friendly
-- camp; the credit only counts for players on the quest.
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (59849, 59851) AND `source_type` = 0 AND `action_type` = 33;
DELETE FROM `smart_scripts` WHERE (`entryorguid` = 59851 AND `source_type` = 0 AND `id` = 5) OR (`entryorguid` = 59849 AND `source_type` = 0 AND `id` = 4);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(59849, 0, 3, 0, 60, 0, 100, 0, 1000, 1000, 1000, 1000, 0, 33, 59881, 0, 0, 0, 0, 0, 18, 10, 0, 0, 0, 0, 0, 0, 0, 'Lyalia - On Update - Quest Credit ''Beer Credit: Alliance'' to players within 10 yards'),
(59849, 0, 4, 0, 60, 0, 100, 0, 1000, 1000, 1000, 1000, 0, 33, 59879, 0, 0, 0, 0, 0, 18, 10, 0, 0, 0, 0, 0, 0, 0, 'Lyalia - On Update - Quest Credit ''Beer Credit: Redwing Priests'' to players within 10 yards (stand-in)'),
(59851, 0, 4, 0, 60, 0, 100, 0, 1000, 1000, 1000, 1000, 0, 33, 59882, 0, 0, 0, 0, 0, 18, 10, 0, 0, 0, 0, 0, 0, 0, 'Sunwalker Dezco - On Update - Quest Credit ''Beer Credit: Horde'' to players within 10 yards'),
(59851, 0, 5, 0, 60, 0, 100, 0, 1000, 1000, 1000, 1000, 0, 33, 59879, 0, 0, 0, 0, 0, 18, 10, 0, 0, 0, 0, 0, 0, 0, 'Sunwalker Dezco - On Update - Quest Credit ''Beer Credit: Redwing Priests'' to players within 10 yards (stand-in)');

-- ===== 2026_10_29_986_64_sp_dalaran_crater_portal_invis.sql
-- ported from PR 15 2026_10_27_83_world.sql (#986)
-- Dalaran Crater: the Portal to Dalaran Crater by Dalar Dawnweaver at the Sepulcher and the Portal to the Sepulcher in the crater
-- carry Apply Quest Invis Zone 13 (85319) and nothing gave Detect: Quest Invis Zone 13 (85320, next to the portals' spells
-- 85317/85318), so neither could be seen or used for Relios the Relic Keeper, Ley Energies and Practical Vengeance. Give it at
-- Silverpine and in the crater once Dalar Dawnweaver is completed, or while Practical Vengeance is in the log.
-- Those bounds are ours.
DELETE FROM `spell_area` WHERE `spell` = 85320 AND `area` IN (130, 279);
INSERT INTO `spell_area` (`spell`, `area`, `quest_start`, `quest_end`, `aura_spell`, `racemask`, `gender`, `autocast`, `quest_start_status`, `quest_end_status`) VALUES
(85320, 130, 27476, 0, 0, 0, 2, 1, 66, 0),
(85320, 279, 27476, 0, 0, 0, 2, 1, 66, 0),
(85320, 130, 27483, 0, 0, 0, 2, 1, 10, 0),
(85320, 279, 27483, 0, 0, 0, 2, 1, 10, 0);

-- ===== 2026_10_29_986_77_sp_ambermill_daschla.sql
-- ported from PR 15 2026_10_28_55_world.sql (#986)
-- Ambermill (area 233): show Daschla raising Archmage Ataeric inside the other dimension, and the aftermath outside it only.
-- The aftermath phase 279 (2026_10_27_43) showed two Daschlas once Transdimensional Warfare: Chapter III was completed: the
-- one hovering over the raised Ataeric 45803 (45802) and the one with the Forsaken army (45775). The first is the end of the
-- fight inside the other dimension; the second is what the Forsaken Front sees outside it. Now:
--   190 "Quest Zone-Specific 15" (unused generic phase, ours): Daschla 45802 and the raised Ataeric 45803, while the player
--       still has Transdimensional Shift 85361 and Chapter III is completed;
--   279 the aftermath (army, catapults, Daschla 45775) only without Transdimensional Shift.
-- Transdimensional Shift now lasts until Chapter III is handed in (it ended on completion, so the raising was never seen).
-- The assignment is ours; no sniff shows these layers.
UPDATE `creature` SET `phaseId`=190, `phaseGroup`=0 WHERE `guid` IN (312242,312243) AND `id` IN (45802,45803);

DELETE FROM `spell_area` WHERE `spell`=85361 AND `area`=233;
INSERT INTO `spell_area` (`spell`,`area`,`quest_start`,`quest_end`,`aura_spell`,`racemask`,`gender`,`autocast`,`quest_start_status`,`quest_end_status`) VALUES
(85361,233,27513,27518,0,0,2,1,74,43);

DELETE FROM `phase_area` WHERE `AreaId`=233 AND `PhaseId`=190;
INSERT INTO `phase_area` (`AreaId`,`PhaseId`,`Comment`) VALUES
(233,190,'Ambermill - Daschla raises Archmage Ataeric (inside the other dimension, Chapter III completed)');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=26 AND `SourceEntry`=233 AND `SourceGroup`=190;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=26 AND `SourceEntry`=233 AND `SourceGroup`=279 AND `ConditionTypeOrReference`=1;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(26,190,233,0,0,1,0,85361,0,0,0,0,0,'','Ambermill - phase 190 with Transdimensional Shift'),
(26,190,233,0,0,47,0,27518,2,0,0,0,0,'','Ambermill - phase 190 once Transdimensional Warfare: Chapter III is completed'),
(26,279,233,0,0,1,0,85361,0,0,1,0,0,'','Ambermill - phase 279 only outside the other dimension (no Transdimensional Shift)');

-- The Forsaken Front val'kyr (Agatha, Daschla, Arthura) hover in the sniff, a few yards above the ground, but had no
-- movement row, so the core moved them to the ground and they stood clipped into it. Disable gravity, as for the
-- Sepulcher Daschla 44609.
DELETE FROM `creature_template_movement` WHERE `CreatureId` IN (45583,45584,45585,45625,45626,45627,45761,45775,45802);
INSERT INTO `creature_template_movement` (`CreatureId`,`Ground`,`Swim`,`Flight`,`Rooted`,`Chase`,`Random`,`InteractionPauseTimer`) VALUES
(45583,0,0,1,0,NULL,NULL,NULL), -- Agatha
(45584,0,0,1,0,NULL,NULL,NULL), -- Daschla
(45585,0,0,1,0,NULL,NULL,NULL), -- Arthura
(45625,0,0,1,0,NULL,NULL,NULL), -- Agatha
(45626,0,0,1,0,NULL,NULL,NULL), -- Daschla
(45627,0,0,1,0,NULL,NULL,NULL), -- Arthura
(45761,0,0,1,0,NULL,NULL,NULL), -- Daschla (Ataeric's stand)
(45775,0,0,1,0,NULL,NULL,NULL), -- Daschla (Ambermill aftermath)
(45802,0,0,1,0,NULL,NULL,NULL); -- Daschla (raising Ataeric)

-- ===== 2026_10_29_986_78_sp_trio_step_aside.sql
-- ported from PR 15 2026_10_28_56_world.sql (#986)
-- The Forsaken Front: the raised Godfrey, Walden and Ashbury step aside when they go with the player.
-- Lord Godfrey 45622, Lord Walden 45623 and Baron Ashbury 45624 stand at the Forsaken Front from Rise, Godfrey on (phase
-- 278, 2026_10_27_41). Taking the Battlefront hands them to the player as companions (45878-45880, Battlefront Summon
-- Master Aura), so from then on the player saw each of them twice. They do not come back: after On Her Majesty's Secret
-- Service the trio has its Cities in Dust actors, and Godfrey turns on the Forsaken there. Phase 191 "Quest Zone-Specific
-- 16" (unused generic phase; the assignment is ours): from Rise, Godfrey completed until Taking the Battlefront is rewarded.
UPDATE `creature` SET `phaseId`=191, `phaseGroup`=0 WHERE `guid` IN (306537,306532,306539) AND `id` IN (45622,45623,45624);

DELETE FROM `phase_area` WHERE `AreaId`=130 AND `PhaseId`=191;
INSERT INTO `phase_area` (`AreaId`,`PhaseId`,`Comment`) VALUES
(130,191,'The Forsaken Front - raised Godfrey, Walden and Ashbury before they go with the player');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=26 AND `SourceEntry`=130 AND `SourceGroup`=191;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(26,191,130,0,0,47,0,27472,66,0,0,0,0,'','The Forsaken Front - phase 191 once Rise, Godfrey is completed'),
(26,191,130,0,0,47,0,27542,43,0,0,0,0,'','The Forsaken Front - phase 191 until Taking the Battlefront is rewarded');

-- ===== 2026_10_29_986_79_sp_cities_in_dust_song.sql
-- ported from PR 15 2026_10_28_57_world.sql (#986)
-- Cities in Dust: Song of Sylvanas keeps the Battlefront off the player who marches with her (spell_silverpine_song_of_sylvanas).
DELETE FROM `spell_script_names` WHERE `spell_id`=85874 AND `ScriptName`='spell_silverpine_song_of_sylvanas';
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(85874,'spell_silverpine_song_of_sylvanas');

