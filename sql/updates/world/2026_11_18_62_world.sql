-- Temple of the Jade Serpent (map 960): Sha of Doubt stands about 23 yards from the reference position.
-- What a player sees today: after Liu Flameheart the Sha of Doubt (56439) waits in the south of the room, 23 yards away from
--   the spot where the sniff-based second reference (ref_sf) has it, next to the other spawns of that room.
-- Cause: the position comes from an older database. ref_cpp has no Pandaria content, so ref_sf is the only reference.
-- Checked: one spawn in world and in ref_sf (guid 4366); orientation is identical. The spawn has no creature_addon, waypoint,
--   formation, linked respawn, pool, game event or smart script by guid; the boss script (boss_sha_of_doubt) and the instance
--   script use fixed positions only for the minion summons (z 185.1, around x 900-918 / y -2620 to -2626) and for Liu, none
--   for the boss itself. Spawn mask (262) and respawn time (86400) stay, they are our own settings.
-- Change: the spawn is moved to the ref_sf position (z 184.542).
-- Source: ref_sf guid 4366 (second reference, Pandaria), 18-11-2026.
-- Rollback (the values before this update; only SQL lines below):
--   UPDATE `creature` SET `position_x`=893.977,`position_y`=-2670.66,`position_z`=185.185 WHERE `guid`=539875 AND `id`=56439;

UPDATE `creature` SET `position_x`=900.535,`position_y`=-2648.63,`position_z`=184.542 WHERE `guid`=539875 AND `id`=56439;  -- Sha of Doubt (56439), 23.0 yd
