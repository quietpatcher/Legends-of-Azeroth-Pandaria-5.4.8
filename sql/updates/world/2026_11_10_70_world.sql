-- Western Plaguelands, Andorhal (to-do 423, follow-up of 413): remove surplus wandering Alliance soldiers, and the
-- duplicate Putridius that shared a spawn pool with a Soulless Ghoul in Andorhal (to-do 421).
-- Andorhal Defender (44448), Provincial Minuteman (44944) and Frightened Provincial Minuteman (45101) had far more spawns than
-- the retail map: 75/50/32 spawns against 42-55/12-13/18-22 map pins. Each map pin keeps the nearest spawn within 12 yards;
-- the wandering spawns that match no pin are removed. Spawns with a waypoint path are always kept.
-- Result: 44448 75 -> 45 (Supporting the Troops, 27085, needs 15), 44944 50 -> 22, 45101 32 -> 19.
-- Putridius (1850) has two retail map pins, both at Caer Darrow (spawn 301914 there stays); the Andorhal copy (15146) is removed
-- with pool 183. The Soulless Ghoul (1794, level 54-55) stays: Cataclysm data shows two of them in Andorhal at that level.
-- Source: Wowhead Cataclysm Classic and MoP Classic map pins of npc 44448, 44944, 45101, 1850 and 1794.
-- Rollback: re-import the rows from the backup dump ~/backup/andorhal423_pre_20261110.sql (creature + creature_addon for these
--   guids, creature 15146/15154, pool_template 183, pool_creature 15146/15154).

-- Andorhal Defender (30 spawns)
DELETE FROM `creature_addon` WHERE `guid` IN (311852,311854,311858,311862,311866,311868,311880,311889,311896,311904,311909,311911,311912,311915,311916,311917,311943,311944,311951,311989,311993,311996,311998,312000,312001,312002,312003,312006,312007,312039);
DELETE FROM `creature` WHERE `id`=44448 AND `guid` IN (311852,311854,311858,311862,311866,311868,311880,311889,311896,311904,311909,311911,311912,311915,311916,311917,311943,311944,311951,311989,311993,311996,311998,312000,312001,312002,312003,312006,312007,312039);

-- Provincial Minuteman (28 spawns)
DELETE FROM `creature_addon` WHERE `guid` IN (312043,312044,312045,312047,312048,312051,312052,312054,312055,312056,312057,312058,312059,312060,312061,312064,312065,312066,312067,312068,312069,312070,312072,312074,312085,312086,312089,312093);
DELETE FROM `creature` WHERE `id`=44944 AND `guid` IN (312043,312044,312045,312047,312048,312051,312052,312054,312055,312056,312057,312058,312059,312060,312061,312064,312065,312066,312067,312068,312069,312070,312072,312074,312085,312086,312089,312093);

-- Frightened Provincial Minuteman (13 spawns)
DELETE FROM `creature_addon` WHERE `guid` IN (311846,311878,311879,311891,311895,311902,311937,312013,312015,312017,312018,312021,312024);
DELETE FROM `creature` WHERE `id`=45101 AND `guid` IN (311846,311878,311879,311891,311895,311902,311937,312013,312015,312017,312018,312021,312024);

-- Putridius in Andorhal: remove the spawn and the pool; the Soulless Ghoul spawn stays outside a pool.
DELETE FROM `pool_creature` WHERE `pool_entry`=183 AND `guid` IN (15146,15154);
DELETE FROM `pool_template` WHERE `entry`=183;
DELETE FROM `creature` WHERE `guid`=15146 AND `id`=1850;
