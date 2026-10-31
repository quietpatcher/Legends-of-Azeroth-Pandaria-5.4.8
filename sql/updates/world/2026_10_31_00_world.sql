-- To-do 459 (Andorhal Defenders vs Opengut Behemoth / Desiccated Spearman / Desiccated Magus do not fight; client test dev118 31-10: FAIL):
-- Cause (FactionTemplate.dbc 5.4.8): Defender faction 2202 (Alliance, hostileMask 4 = Horde) and the undead faction 974 (monster, hostileMask 1 = players) are
-- not hostile to each other, so the OOC "attack closest enemy" scripts of 2026_10_30_07/_08 find no enemy.
-- Change: 44315, 44316, 44562 get faction 2212 (same faction group 20 as 974, ourMask 8, hostileMask 7 = players, Alliance and Horde) so the Alliance defenders become enemies.
-- Source: functional change, NOT a retail copy. ref_cpp (Cataclysm sniffs) and ref_sf have the same factions (974/2202) for these entries and no sniffed mechanism that makes them fight.
-- Rollback: UPDATE creature_template SET faction = 974 WHERE entry IN (44315, 44316, 44562);
UPDATE `creature_template` SET `faction` = 2212 WHERE `entry` IN (44315, 44316, 44562);
