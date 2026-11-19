-- Azuremyst Isle wild battle pet pool (zone 3524): Squirrel and Skunk caps raised to the number of critter spawns, Rat added.
-- What a player sees today: the pool allows only 8 Rabbits, 8 Squirrels and 6 Skunks on the whole island, although 24 Squirrel
--   and 18 Skunk spawns exist there, so most of those critters can never be fought as a battle pet; the Rat is missing.
-- Cause: the Azuremyst rows of `battle_pet_wild_pool` were set too low (8/8/6) and the Rat row was never added.
-- Checked: the spawn manager only converts existing critter spawns of the pool entry in that zone, capped by `max`; zone 3524 has
--   2 Rabbit (721), 24 Squirrel (1412), 18 Skunk (17467), 5 Rat (4075) and 3 Chicken (620) spawns. Rabbit (8 >= 2) stays.
--   The Rat (species 417, level 1-2) is listed for Ammen Vale / Azuremyst; the Chicken is NOT an Azuremyst pet (Bloodmyst,
--   Elwynn, Tirisfal etc. only), so it is not added. Grey Moth (species 464, wild NPC 62050) is an Azuremyst pet, but it has
--   0 creature spawns in world and in both reference databases and no source for positions exists, so no row is added (it would
--   do nothing); positions are still needed.
-- Change: Squirrel max 8 -> 24, Skunk max 6 -> 18, Rat row (zone 3524, species 417, entry 4075, max 5, level 1-2) added.
-- Source: warcraftpets.com zone list (Azuremyst Isle, pet level 1-2) and wow-petguide.com (Rat zones), via search 18-11-2026;
--   spawn counts from the world database (dev).
-- Rollback (the values and rows before this update):
--   UPDATE `battle_pet_wild_pool` SET `max`=8 WHERE `zone`=3524 AND `species`=379;
--   UPDATE `battle_pet_wild_pool` SET `max`=6 WHERE `zone`=3524 AND `species`=397;
--   DELETE FROM `battle_pet_wild_pool` WHERE `zone`=3524 AND `species`=417;

UPDATE `battle_pet_wild_pool` SET `max`=24 WHERE `zone`=3524 AND `species`=379 AND `entry`=1412;  -- Squirrel
UPDATE `battle_pet_wild_pool` SET `max`=18 WHERE `zone`=3524 AND `species`=397 AND `entry`=17467;  -- Skunk

DELETE FROM `battle_pet_wild_pool` WHERE `zone`=3524 AND `species`=417;
INSERT INTO `battle_pet_wild_pool` (`zone`,`species`,`entry`,`max`,`minLevel`,`maxLevel`,`comment`) VALUES
(3524,417,4075,5,1,2,'Rat - Azuremyst Isle');
