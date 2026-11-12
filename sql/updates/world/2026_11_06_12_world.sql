-- Rollback: restore the tables listed in the Rollback section of state/l1_silverpine_hillsbrad_diff.md from the pre-apply dump.
-- Source: DeltaTho PR 15 via 1LineAtaTime/LoA-Pandaria-Playerbots b179e298 (GPLv2); concatenated in original order:
--   2026_10_29_986_21_sp_no_player_damage_req.sql
--   2026_10_29_986_22_sp_excising_the_taint.sql
--   2026_10_29_986_23_sp_torok_hatchet_sepulcher.sql
--   2026_10_29_986_24_sp_horde_cannons.sql
--   2026_10_29_986_25_sp_hillsbrad_worgen_swim.sql
--   2026_10_29_986_26_sp_chain_after_sepulcher.sql
--   2026_10_29_986_29_sp_ambermill_phases.sql
--   2026_10_29_986_30_sp_ataeric_shield.sql

-- ===== 2026_10_29_986_21_sp_no_player_damage_req.sql
-- ported from PR 15 2026_10_26_12_world.sql (#986)
-- #986: ORs the flag in (the PR SET it) so existing flags_extra bits survive; needs CREATURE_FLAG_EXTRA_NO_PLAYER_DAMAGE_REQ = 0x00400000 in core (core lane, PR 29b4b167)
-- Silverpine Forest quest targets that others help kill: credit whoever tagged them, even with less than half of the damage
-- (CREATURE_FLAG_EXTRA_NO_PLAYER_DAMAGE_REQ)
-- 44367 Forest Ettin (It's Only Poisonous if You Ingest It): the player's Bush Chicken Explosion! takes most of its health
-- 44793 Worgen Renegade (The Gilneas Liberation Front): fights the Forsaken Troopers around Forsaken High Command
UPDATE `creature_template` SET `flags_extra` = `flags_extra` | 4194304 WHERE `entry` IN (44367, 44793);

-- ===== 2026_10_29_986_22_sp_excising_the_taint.sql
-- ported from PR 15 2026_10_26_30_world.sql (#986)
-- Silverpine Forest: Excising the Taint (27181) is turned in to Sylvanas' voice, like Seek and Destroy (27193) after it
-- The 4.3.4 sniff has Flags 0x190000; our row lost QUEST_FLAGS_AUTO_COMPLETE (0x10000), so the client offered no remote turn-in
UPDATE `quest_template` SET `Flags` = 0x190000 WHERE `ID` = 27181;

-- ===== 2026_10_29_986_23_sp_torok_hatchet_sepulcher.sql
-- ported from PR 15 2026_10_27_00_world.sql (#986)
-- #986 guid reservation: creature guids 4046100-4046101 are kept as in the PR (no collision: our max creature guid is 4044100, the RFC dungeon block
-- is 4045000-4045129). Reserved for Torok/Hatchet; the next @CGUID block for new updates must start above 4046101 (4047000+), and 3100000-3199999 is the Hillsbrad block.
-- Silverpine Forest: Warlord Torok and Admiral Hatchet move to the Sepulcher with Sylvanas after Lordaeron. Hair of the Dog, Reinforcements
-- from Fenris and The Waters Run Red... are handed in to them "at the Sepulcher", but they were only spawned at the Forsaken Rear Guard.
-- Nothing sniffed them there: Torok stands at 45.8, 42.0 on the Silverpine map (a screenshot), with Hatchet on his left as at the
-- Rear Guard; heights from the terrain.
DELETE FROM `creature` WHERE `guid` IN (4046100, 4046101) AND `id` IN (44916, 44917);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`,
`equipment_id`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`) VALUES
(4046100, 44917, 0, 130, 228, 1, 1, 490.67, 1526.40, 131.08, 1.31, 0, 300, 0, 0, 0, 0, 0, 0), -- Warlord Torok
(4046101, 44916, 0, 130, 228, 1, 1, 488.74, 1526.92, 131.38, 1.62, 0, 300, 0, 0, 0, 0, 0, 0); -- Admiral Hatchet

-- ===== 2026_10_29_986_24_sp_horde_cannons.sql
-- ported from PR 15 2026_10_27_01_world.sql (#986)
-- Silverpine Forest, The Waters Run Red...: let players board the Horde Cannons (45263) at the Decrepit Fields. The cannon is a
-- vehicle with one seat that the rider controls, and Rocket Blast on its bar, but it had no spellclick, so clicking it did nothing.
-- No spellclick was sniffed for it; it uses the generic Ride Vehicle Hardcoded.
UPDATE `creature_template` SET `npcflag` = 16777216 WHERE `entry` = 45263;

DELETE FROM `npc_spellclick_spells` WHERE `npc_entry` = 45263;
INSERT INTO `npc_spellclick_spells` (`npc_entry`, `spell_id`, `cast_flags`, `user_type`) VALUES
(45263, 46598, 1, 0);

-- Only for The Waters Run Red...: it can be boarded while the quest is in progress, and throws the player out once it is done.
-- Having a vehicle condition also keeps the cannon in place: a vehicle without one despawns when its rider leaves it.
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 18 AND `SourceGroup` = 45263 AND `SourceEntry` = 46598;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 16 AND `SourceEntry` = 45263;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(18, 45263, 46598, 0, 0, 9, 0, 27232, 0, 0, 0, 0, 0, '', 'Horde Cannon - Board it only while The Waters Run Red... is in progress'),
(16, 0, 45263, 0, 0, 9, 0, 27232, 0, 0, 0, 0, 0, '', 'Horde Cannon - Leave it once The Waters Run Red... is no longer in progress');

-- ===== 2026_10_29_986_25_sp_hillsbrad_worgen_swim.sql
-- ported from PR 15 2026_10_27_02_world.sql (#986)
-- Silverpine Forest, The Waters Run Red...: the Hillsbrad Worgen (45270) swim across Lordamere Lake in waves to the Horde Cannons
-- at the Decrepit Fields. Their 24 sniffed swim paths run from the far shore to ours, but each swimmer was spawned at the point
-- where the sniff saw it, part-way across, and looped its path back and forth. Each one now starts mid-lake, out of sight of the
-- cannons, swims across once and, on reaching our shore, disappears to start again about 15 seconds later; a killed one is back
-- as soon. Their corpse delay is 5 seconds: the respawn time is set at death (or a despawn) as respawn plus corpse delay, so the
-- 60-second default made every cycle 80 seconds long. They start where their
-- path crosses y = 815, not on the far shore, so they come into sight soon. Creatures only update near a player
-- (Map.UpdatableObjectList is off): the waves run while someone is at the cannons and pause when nobody is. The paths move from
-- waypoint_data to SmartAI waypoints, under the swimmer's guid. Retail summons these worgen; the sniffed spawns stand in.
-- They swim in straight lines: the navmesh puts water paths on the surface, where a creature counts as walking on the water, so
-- it lost its swim flag and dropped under the surface at every step.
UPDATE `creature_template` SET `AIName` = 'SmartAI', `flags_extra` = 536870912 WHERE `entry` = 45270; -- CREATURE_FLAG_EXTRA_IGNORE_PATHFINDING

UPDATE `creature` SET `position_x` = 673.0563, `position_y` = 815.0000, `position_z` = 32.1237, `orientation` = 1.7735, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307216 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 714.4180, `position_y` = 815.0000, `position_z` = 31.7415, `orientation` = 1.9167, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307217 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 781.4416, `position_y` = 815.0000, `position_z` = 32.5506, `orientation` = 1.6586, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307218 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 714.4180, `position_y` = 815.0000, `position_z` = 31.7415, `orientation` = 1.9167, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307220 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 781.4416, `position_y` = 815.0000, `position_z` = 32.5506, `orientation` = 1.6586, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307222 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 781.4701, `position_y` = 815.0000, `position_z` = 32.5508, `orientation` = 1.6588, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307223 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 781.3030, `position_y` = 815.0000, `position_z` = 32.5531, `orientation` = 1.6578, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307225 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 673.0563, `position_y` = 815.0000, `position_z` = 32.1237, `orientation` = 1.7735, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307226 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 699.7828, `position_y` = 815.0000, `position_z` = 30.2523, `orientation` = 1.7778, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307231 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 673.0563, `position_y` = 815.0000, `position_z` = 32.1237, `orientation` = 1.7735, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307232 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 714.4180, `position_y` = 815.0000, `position_z` = 31.7415, `orientation` = 1.9167, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307234 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 700.7681, `position_y` = 815.0000, `position_z` = 32.0569, `orientation` = 1.9769, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307235 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 781.4701, `position_y` = 815.0000, `position_z` = 32.5508, `orientation` = 1.6588, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307237 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 781.4416, `position_y` = 815.0000, `position_z` = 32.5506, `orientation` = 1.6586, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307239 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 781.4701, `position_y` = 815.0000, `position_z` = 32.5508, `orientation` = 1.6588, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307241 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 673.0563, `position_y` = 815.0000, `position_z` = 32.1237, `orientation` = 1.7735, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307243 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 673.0563, `position_y` = 815.0000, `position_z` = 32.1237, `orientation` = 1.7735, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307247 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 774.5820, `position_y` = 815.0000, `position_z` = 32.6233, `orientation` = 1.4344, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307249 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 781.4701, `position_y` = 815.0000, `position_z` = 32.5508, `orientation` = 1.6588, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307250 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 774.5820, `position_y` = 815.0000, `position_z` = 32.6233, `orientation` = 1.4344, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307253 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 774.5820, `position_y` = 815.0000, `position_z` = 32.6233, `orientation` = 1.4344, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307257 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 673.0563, `position_y` = 815.0000, `position_z` = 32.1237, `orientation` = 1.7735, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307260 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 673.0563, `position_y` = 815.0000, `position_z` = 32.1237, `orientation` = 1.7735, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307263 AND `id` = 45270;
UPDATE `creature` SET `position_x` = 673.0563, `position_y` = 815.0000, `position_z` = 32.1237, `orientation` = 1.7735, `MovementType` = 0, `spawntimesecs` = 10 WHERE `guid` = 307264 AND `id` = 45270;

UPDATE `creature_addon` SET `path_id` = 0 WHERE `guid` IN (307216, 307217, 307218, 307220, 307222, 307223, 307225, 307226, 307231, 307232, 307234, 307235, 307237, 307239, 307241, 307243, 307247, 307249, 307250, 307253, 307257, 307260, 307263, 307264);
DELETE FROM `waypoint_data` WHERE `id` IN (307216, 307217, 307218, 307220, 307222, 307223, 307225, 307226, 307231, 307232, 307234, 307235, 307237, 307239, 307241, 307243, 307247, 307249, 307250, 307253, 307257, 307260, 307263, 307264);

DELETE FROM `waypoints` WHERE `entry` IN (307216, 307217, 307218, 307220, 307222, 307223, 307225, 307226, 307231, 307232, 307234, 307235, 307237, 307239, 307241, 307243, 307247, 307249, 307250, 307253, 307257, 307260, 307263, 307264);
INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES
(307216, 1, 673.0563, 815.0000, 32.1237, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307216, 2, 645.1440, 950.8960, 30.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307216, 3, 644.7420, 952.8560, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307216, 4, 644.3400, 954.8150, 33.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307216, 5, 643.9380, 956.7730, 33.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307216, 6, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307216, 7, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307217, 1, 714.4180, 815.0000, 31.7415, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307217, 2, 683.4680, 900.8940, 32.7460, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307217, 3, 661.7210, 961.0810, 31.4841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307217, 4, 661.0410, 962.9620, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307217, 5, 660.3610, 964.8430, 32.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307217, 6, 659.5490, 967.2670, 33.5215, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307217, 7, 659.5490, 967.2670, 33.5215, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307218, 1, 781.4416, 815.0000, 32.5506, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307218, 2, 763.7060, 1016.0000, 31.9335, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307218, 3, 763.6180, 1017.0000, 30.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307218, 4, 763.5300, 1017.9900, 31.6117, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307218, 5, 763.4860, 1019.0200, 31.9013, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307218, 6, 763.4860, 1019.0200, 31.9013, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307220, 1, 714.4180, 815.0000, 31.7415, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307220, 2, 683.4680, 900.8940, 32.7460, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307220, 3, 661.7210, 961.0810, 31.4841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307220, 4, 661.0410, 962.9620, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307220, 5, 660.3610, 964.8430, 32.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307220, 6, 659.5490, 967.2670, 33.5215, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307220, 7, 659.5490, 967.2670, 33.5215, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307222, 1, 781.4416, 815.0000, 32.5506, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307222, 2, 763.7060, 1016.0000, 31.9335, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307222, 3, 763.6180, 1017.0000, 30.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307222, 4, 763.5300, 1017.9900, 31.6117, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307222, 5, 763.4860, 1019.0200, 31.9013, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307222, 6, 763.4860, 1019.0200, 31.9013, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307223, 1, 781.4701, 815.0000, 32.5508, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307223, 2, 763.7380, 1015.9600, 31.9349, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307223, 3, 763.6500, 1016.9600, 30.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307223, 4, 763.4750, 1018.9500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307223, 5, 763.4750, 1018.9500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307225, 1, 781.3030, 815.0000, 32.5531, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307225, 2, 763.7770, 1015.8600, 31.9363, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307225, 3, 763.6900, 1016.8600, 30.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307225, 4, 763.5170, 1018.8500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307225, 5, 763.5170, 1018.8500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307226, 1, 673.0563, 815.0000, 32.1237, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307226, 2, 645.1440, 950.8960, 30.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307226, 3, 644.7420, 952.8560, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307226, 4, 644.3400, 954.8150, 33.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307226, 5, 643.9380, 956.7730, 33.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307226, 6, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307226, 7, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307231, 1, 699.7828, 815.0000, 30.2523, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307231, 2, 668.5160, 963.7320, 31.9602, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307231, 3, 667.9000, 966.6680, 31.7227, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307231, 4, 667.6270, 968.0830, 32.0098, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307231, 5, 667.6270, 968.0830, 32.0098, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307232, 1, 673.0563, 815.0000, 32.1237, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307232, 2, 645.1440, 950.8960, 30.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307232, 3, 644.7420, 952.8560, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307232, 4, 644.3400, 954.8150, 33.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307232, 5, 643.9380, 956.7730, 33.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307232, 6, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307232, 7, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307234, 1, 714.4180, 815.0000, 31.7415, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307234, 2, 683.4680, 900.8940, 32.7460, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307234, 3, 661.7210, 961.0810, 31.4841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307234, 4, 661.0410, 962.9620, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307234, 5, 660.3610, 964.8430, 32.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307234, 6, 659.5490, 967.2670, 33.5215, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307234, 7, 659.5490, 967.2670, 33.5215, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 1, 700.7681, 815.0000, 32.0569, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 2, 688.4370, 843.6510, 32.7414, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 3, 643.4450, 948.4110, 31.3591, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 4, 642.6560, 950.2490, 32.6091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 5, 641.4730, 953.0060, 33.6091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 6, 640.6840, 954.8440, 34.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 7, 640.2890, 955.7630, 35.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 8, 639.9480, 956.4320, 35.4373, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307235, 9, 639.9480, 956.4320, 35.4373, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307237, 1, 781.4701, 815.0000, 32.5508, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307237, 2, 763.7380, 1015.9600, 31.9349, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307237, 3, 763.6500, 1016.9600, 30.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307237, 4, 763.4750, 1018.9500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307237, 5, 763.4750, 1018.9500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307239, 1, 781.4416, 815.0000, 32.5506, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307239, 2, 763.7060, 1016.0000, 31.9335, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307239, 3, 763.6180, 1017.0000, 30.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307239, 4, 763.5300, 1017.9900, 31.6117, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307239, 5, 763.4860, 1019.0200, 31.9013, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307239, 6, 763.4860, 1019.0200, 31.9013, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307241, 1, 781.4701, 815.0000, 32.5508, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307241, 2, 763.7380, 1015.9600, 31.9349, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307241, 3, 763.6500, 1016.9600, 30.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307241, 4, 763.4750, 1018.9500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307241, 5, 763.4750, 1018.9500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307243, 1, 673.0563, 815.0000, 32.1237, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307243, 2, 645.1440, 950.8960, 30.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307243, 3, 644.7420, 952.8560, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307243, 4, 644.3400, 954.8150, 33.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307243, 5, 643.9380, 956.7730, 33.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307243, 6, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307243, 7, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307247, 1, 673.0563, 815.0000, 32.1237, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307247, 2, 645.1440, 950.8960, 30.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307247, 3, 644.7420, 952.8560, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307247, 4, 644.3400, 954.8150, 33.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307247, 5, 643.9380, 956.7730, 33.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307247, 6, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307247, 7, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307249, 1, 774.5820, 815.0000, 32.6233, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307249, 2, 803.5780, 1026.5300, 32.2218, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307249, 3, 803.7140, 1027.5200, 31.0908, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307249, 4, 804.0210, 1029.5100, 32.2092, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307249, 5, 804.0210, 1029.5100, 32.2092, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307250, 1, 781.4701, 815.0000, 32.5508, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307250, 2, 763.7380, 1015.9600, 31.9349, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307250, 3, 763.6500, 1016.9600, 30.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307250, 4, 763.4750, 1018.9500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307250, 5, 763.4750, 1018.9500, 32.3617, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307253, 1, 774.5820, 815.0000, 32.6233, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307253, 2, 803.5780, 1026.5300, 32.2218, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307253, 3, 803.7140, 1027.5200, 31.0908, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307253, 4, 804.0210, 1029.5100, 32.2092, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307253, 5, 804.0210, 1029.5100, 32.2092, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307257, 1, 774.5820, 815.0000, 32.6233, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307257, 2, 803.5780, 1026.5300, 32.2218, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307257, 3, 803.7140, 1027.5200, 31.0908, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307257, 4, 804.0210, 1029.5100, 32.2092, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307257, 5, 804.0210, 1029.5100, 32.2092, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307260, 1, 673.0563, 815.0000, 32.1237, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307260, 2, 645.1440, 950.8960, 30.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307260, 3, 644.7420, 952.8560, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307260, 4, 644.3400, 954.8150, 33.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307260, 5, 643.9380, 956.7730, 33.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307260, 6, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307260, 7, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307263, 1, 673.0563, 815.0000, 32.1237, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307263, 2, 645.1440, 950.8960, 30.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307263, 3, 644.7420, 952.8560, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307263, 4, 644.3400, 954.8150, 33.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307263, 5, 643.9380, 956.7730, 33.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307263, 6, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307263, 7, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307264, 1, 673.0563, 815.0000, 32.1237, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307264, 2, 645.1440, 950.8960, 30.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307264, 3, 644.7420, 952.8560, 32.2341, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307264, 4, 644.3400, 954.8150, 33.1091, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307264, 5, 643.9380, 956.7730, 33.9841, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307264, 6, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake'),
(307264, 7, 643.8300, 957.1980, 34.2948, 0, 0, 'Hillsbrad Worgen - Swim across Lordamere Lake');

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (-307216, -307217, -307218, -307220, -307222, -307223, -307225, -307226, -307231, -307232, -307234, -307235, -307237, -307239, -307241, -307243, -307247, -307249, -307250, -307253, -307257, -307260, -307263, -307264) AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(-307216, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307216, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307216, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307217, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307217, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307217, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307218, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307218, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307218, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307220, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307220, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307220, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307222, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307222, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307222, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307223, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307223, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307223, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307225, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307225, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307225, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307226, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307226, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307226, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307231, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307231, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307231, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307232, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307232, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307232, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307234, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307234, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307234, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307235, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307235, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307235, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307237, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307237, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307237, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307239, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307239, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307239, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307241, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307241, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307241, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307243, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307243, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307243, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307247, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307247, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307247, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307249, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307249, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307249, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307250, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307250, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307250, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307253, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307253, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307253, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307257, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307257, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307257, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307260, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307260, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307260, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307263, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307263, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307263, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds'),
(-307264, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 53, 1, 307264, 0, 0, 1000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Swim across Lordamere Lake, then despawn'),
(-307264, 0, 1, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 116, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hillsbrad Worgen - On Respawn - Set Corpse Delay 5 seconds');

-- ===== 2026_10_29_986_26_sp_chain_after_sepulcher.sql
-- ported from PR 15 2026_10_27_40_world.sql (#986)
-- Silverpine Forest after the Sepulcher: restore the quest chain from To Forsaken Forward Command to Cities in Dust
-- Prerequisites as in the retail and Cataclysm Classic world databases (identical there) and warcraft.wiki.gg: a negative
-- ExclusiveGroup with a shared NextQuestID means every quest of the group is needed for the next one.
-- On Whose Orders? (needs Rutsak's Guard) and A Wolf in Bear's Clothing (needs Only One May Enter) only from the wiki.

INSERT IGNORE INTO `quest_template_addon` (`ID`) VALUES
(27423),(27472),(27475),(27483),(27510),(27542),(27547);

-- Ruins of Gilneas: In Time, All Will Be Revealed, Losing Ground and The F.C.D. all need To Forsaken Forward Command,
-- and all three are needed for Break in Communications: Dreadwatch Outpost
UPDATE `quest_template_addon` SET `PrevQuestID`=27290, `NextQuestID`=27349, `ExclusiveGroup`=-27333 WHERE `ID` IN (27333,27342,27345);
UPDATE `quest_template_addon` SET `PrevQuestID`=0 WHERE `ID`=27349;
UPDATE `quest_template_addon` SET `PrevQuestID`=27350 WHERE `ID`=27364;
-- A Man Named Godfrey and Resistance is Futile both need Fall Back! and are both needed for The Great Escape
UPDATE `quest_template_addon` SET `PrevQuestID`=27405, `NextQuestID`=27438, `ExclusiveGroup`=-27406 WHERE `ID` IN (27406,27423);
-- The Forsaken Front
UPDATE `quest_template_addon` SET `PrevQuestID`=0, `NextQuestID`=27472 WHERE `ID`=27438;
UPDATE `quest_template_addon` SET `PrevQuestID`=27438 WHERE `ID`=27472;
UPDATE `quest_template_addon` SET `PrevQuestID`=27472, `NextQuestID`=27476, `ExclusiveGroup`=-27474 WHERE `ID` IN (27474,27475);
-- Ambermill: Relios the Relic Keeper and Practical Vengeance are both needed for Only One May Enter
UPDATE `quest_template_addon` SET `PrevQuestID`=27476, `NextQuestID`=27484, `ExclusiveGroup`=-27478 WHERE `ID` IN (27478,27483);
UPDATE `quest_template_addon` SET `PrevQuestID`=0 WHERE `ID`=27484;
UPDATE `quest_template_addon` SET `PrevQuestID`=27484 WHERE `ID`=27510;
UPDATE `quest_template_addon` SET `NextQuestID`=27542 WHERE `ID`=27518;
UPDATE `quest_template_addon` SET `PrevQuestID`=27518 WHERE `ID`=27542;
-- Pyrewood: Of No Consequence, Lessons in Fear and Pyrewood's Fall all need Taking the Battlefront and are all needed for
-- Sowing Discord; 7th Legion Battle Plans and Sowing Discord are both needed for On Her Majesty's Secret Service
UPDATE `quest_template_addon` SET `PrevQuestID`=27542, `NextQuestID`=27580, `ExclusiveGroup`=-27550 WHERE `ID` IN (27547,27548,27550);
UPDATE `quest_template_addon` SET `PrevQuestID`=27550, `NextQuestID`=27594, `ExclusiveGroup`=-27580 WHERE `ID` IN (27577,27580);
UPDATE `quest_template_addon` SET `NextQuestID`=27601 WHERE `ID`=27594;
UPDATE `quest_template_addon` SET `PrevQuestID`=27594 WHERE `ID`=27601;

-- Quest givers that exist neither on retail nor in the Cataclysm data (Wowhead agrees):
-- Sylvanas at the Forsaken Front only ends The Great Escape; Only One May Enter comes from Dalar Dawnweaver, Chapter I from
-- Sylvanas, Chapter II from the Ambermill Dimensional Portal; Resistance is Futile from Forward Commander Onslaught;
-- Empire of Dirt from Sylvanas at the Battlefront.
DELETE FROM `creature_queststarter` WHERE (`id`,`quest`) IN ((45525,27438),(45617,27484),(45752,27512),(45617,27513),(45474,27423),(2215,27746));

-- ===== 2026_10_29_986_29_sp_ambermill_phases.sql
-- ported from PR 15 2026_10_27_43_world.sql (#986)
-- Ambermill (area 233): phase the other dimension of Transdimensional Warfare and its aftermath
-- Everything was spawned in the default phase, so everybody saw the Dalaran mage town of the other dimension, the
-- Forsaken army that storms it, its aftermath and three Archmage Ataerics at once, and spell_area put the Transdimensional
-- Shift screen effect on everyone in Ambermill who had not completed Chapter III.
-- Phase.dbc names 279, 280 and 281 "Amber Mill" and PhaseXPhaseGroup shows 280 and 281 together. No 5.4.8 spell grants
-- them and no sniff shows the layers, so the assignment is ours:
--   280  the mage town of the other dimension (Chapter II, Chapter III)   while the player has Transdimensional Shift
--   281  Archmage Ataeric's stand against the Forsaken (Chapter III)      Transdimensional Shift and Chapter III in progress
--   279  the aftermath: the Forsaken army, Daschla and the raised Ataeric  Chapter III completed or rewarded
-- Transdimensional Shift itself is given in Ambermill from taking Chapter II until Chapter III is completed (the
-- Ambermill Dimensional Portal takes the player there; walking in works too). The portal only opens for players on
-- Chapter II or Chapter III.

UPDATE `creature` SET `phaseId`=280, `phaseGroup`=0 WHERE `map`=0 AND `areaId`=233 AND `id` IN (1888,1889,1913,1914,1920,3577,3578);
UPDATE `creature` SET `phaseId`=281, `phaseGroup`=0 WHERE `map`=0 AND `areaId`=233 AND `id` IN (2120,45761,45762,45763,45764);
UPDATE `creature` SET `phaseId`=279, `phaseGroup`=0 WHERE `map`=0 AND `areaId`=233 AND `id` IN (45775,45777,45778,45781,45802,45803);

-- Doomskull is an Ambermill Witchalok's summon (spell 87225) sniffed as a spawn; Ataeric's corpse 45779 lay under the
-- raised Ataeric 45803. The Archmage Target 45764 in front of Ataeric is the target of his Dimensional Beam and stays.
DELETE FROM `creature_addon` WHERE `guid` IN (312540,312484);
DELETE FROM `creature` WHERE (`guid`,`id`) IN ((312540,46846),(312484,45779));

DELETE FROM `spell_area` WHERE `spell`=85361 AND `area`=233;
INSERT INTO `spell_area` (`spell`,`area`,`quest_start`,`quest_end`,`aura_spell`,`racemask`,`gender`,`autocast`,`quest_start_status`,`quest_end_status`) VALUES
(85361,233,27513,27518,0,0,2,1,74,41);

DELETE FROM `phase_area` WHERE `AreaId`=233 AND `PhaseId` IN (279,280,281);
INSERT INTO `phase_area` (`AreaId`,`PhaseId`,`Comment`) VALUES
(233,280,'Ambermill - the mage town of the other dimension'),
(233,281,'Ambermill - Archmage Ataeric''s stand'),
(233,279,'Ambermill - after Transdimensional Warfare: Chapter III');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=26 AND `SourceEntry`=233 AND `SourceGroup` IN (279,280,281);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=15 AND `SourceGroup`=12054 AND `SourceEntry`=0;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(26,280,233,0,0,1,0,85361,0,0,0,0,0,'','Ambermill - phase 280 with Transdimensional Shift'),
(26,281,233,0,0,1,0,85361,0,0,0,0,0,'','Ambermill - phase 281 with Transdimensional Shift'),
(26,281,233,0,0,47,0,27518,8,0,0,0,0,'','Ambermill - phase 281 while Transdimensional Warfare: Chapter III is in progress'),
(26,279,233,0,0,47,0,27518,66,0,0,0,0,'','Ambermill - phase 279 once Transdimensional Warfare: Chapter III is completed'),
(15,12054,0,0,0,47,0,27513,8,0,0,0,0,'','Ambermill Dimensional Portal - gossip option with Transdimensional Warfare: Chapter II in progress'),
(15,12054,0,0,1,47,0,27518,8,0,0,0,0,'','Ambermill Dimensional Portal - or with Transdimensional Warfare: Chapter III in progress');

-- ===== 2026_10_29_986_30_sp_ataeric_shield.sql
-- ported from PR 15 2026_10_27_44_world.sql (#986)
-- Transdimensional Warfare: Chapter III (27518): overload Archmage Ataeric's shield by killing Arcane Fiends near him
-- Ataeric's old script ran on a timer: 50 seconds after the pull it gave the credit, whatever the player did. His
-- mop_world template has the stunned flag (retail has none), so his untriggered Arcane Shield, Dimensional Beam and Summon
-- Arcane Fiend casts all failed and he could be killed before the timer ran out, with no credit.
-- The quest objective ("Overload Archmage Ataeric with arcane power to bring down the Transdimensional Shield"), his boss
-- whisper "Destroy Arcane Fiends near Archmage Ataeric to overload the shield!" and the retail Arcane Fiend script ("On
-- Just Died - Cast Arcane Expulsion") describe the fight; the steps below are ours: he stands shielded and beaming, summons
-- an Arcane Fiend every 10 seconds, and each fiend that dies within 15 yards of him strains the shield. His lines mark the
-- five steps; at the fifth the shield breaks and he dies, which credits every player within 100 yards. The casts are
-- triggered so the stunned flag does not stop them.

UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (2120,45766);
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (2120,45766) AND `source_type`=0;
DELETE FROM `smart_scripts` WHERE `entryorguid`=2120000 AND `source_type`=9;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(2120,0,0,1,25,0,100,0,0,0,0,0,0,11,87251,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Reset - Cast Arcane Shield'),
(2120,0,1,0,61,0,100,0,0,0,0,0,0,11,85373,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Reset - Cast Dimensional Beam'),
(2120,0,2,3,4,0,100,0,0,0,0,0,0,21,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Aggro - Disable Combat Movement'),
(2120,0,3,4,61,0,100,0,0,0,0,0,0,20,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Aggro - Disable Melee'),
(2120,0,4,5,61,0,100,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Aggro - Say Line 1'),
(2120,0,5,0,61,0,100,0,0,0,0,0,0,1,0,0,1,0,0,0,7,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Aggro - Say Line 0 (boss whisper to the player who pulled him)'),
(2120,0,6,0,0,0,100,0,1000,1000,10000,10000,0,11,87253,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - In Combat - Cast Summon Arcane Fiend'),
(2120,0,7,0,38,0,100,0,1,1,0,0,0,63,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Data Set 1 1 - Add 1 to Counter 1'),
(2120,0,8,0,77,0,100,0,1,1,0,0,0,1,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Counter 1 = 1 - Say Line 2'),
(2120,0,9,0,77,0,100,0,1,2,0,0,0,1,3,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Counter 1 = 2 - Say Line 3'),
(2120,0,10,0,77,0,100,0,1,3,0,0,0,1,4,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Counter 1 = 3 - Say Line 4'),
(2120,0,11,0,77,0,100,0,1,4,0,0,0,1,5,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Counter 1 = 4 - Say Line 5'),
(2120,0,12,0,77,0,100,0,1,5,0,0,0,80,2120000,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Counter 1 = 5 - Run Script'),
(2120,0,13,0,6,0,100,0,0,0,0,0,0,33,45769,0,0,0,0,0,17,0,100,0,0,0,0,0,0,'Archmage Ataeric - On Death - Quest Credit Transdimensional Warfare: Chapter III'),
(2120,0,14,0,7,0,100,0,0,0,0,0,0,41,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - On Evade - Despawn'),
(2120000,9,0,0,0,0,100,0,0,0,0,0,0,1,6,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - Script - Say Line 6'),
(2120000,9,1,0,0,0,100,0,3000,3000,0,0,0,28,87251,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - Script - Remove Arcane Shield'),
(2120000,9,2,0,0,0,100,0,0,0,0,0,0,28,85373,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - Script - Remove Dimensional Beam'),
(2120000,9,3,0,0,0,100,0,2000,2000,0,0,0,1,7,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - Script - Say Line 7'),
(2120000,9,4,0,0,0,100,0,2000,2000,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,'Archmage Ataeric - Script - Die'),
(45766,0,0,1,6,0,100,0,0,0,0,0,0,11,87249,2,0,0,0,0,1,0,0,0,0,0,0,0,0,'Arcane Fiend - On Death - Cast Arcane Expulsion'),
(45766,0,1,0,61,0,100,0,0,0,0,0,0,45,1,1,0,0,0,0,19,2120,15,0,0,0,0,0,0,'Arcane Fiend - On Death - Set Data 1 1 on Archmage Ataeric within 15 yards');

