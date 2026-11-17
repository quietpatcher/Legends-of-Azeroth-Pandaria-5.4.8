-- Zixil (3537, Hillsbrad Foothills, merchant and repairer): move to the position the sniff-based references have and
--   stop the walking movement type.
-- What a player sees today: the vendor stands 201 yards away from where he is found in the sniffs; his movement type
--   says "random-path walking" but he has no path at all, so the spawn has no defined behaviour.
-- Cause: the position comes from an older database; the spawn carries MovementType 2 without any waypoint data.
-- Checked: two independent sniff-based references (Cataclysm Preservation and the SkyFire sniff database) have exactly
--   the same single spawn at the new coordinates with MovementType 0, and neither has a creature_addon path,
--   waypoint_data, waypoints or smart_scripts for him, so he stands still there. Our spawn has no creature_addon row,
--   waypoint_data, smart_scripts, game_event_creature, pool_creature, or linked_respawn row; he is the only spawn
--   of this entry; template has no ScriptName or AIName and the same vendor and repair flags (4224) in both references.
-- Change: position_x, position_y, position_z, orientation and MovementType of the spawn.
-- Source: Cataclysm Preservation sniff database, checked 15-11-2026.
-- Rollback (the values before this update):
--   UPDATE `creature` SET `position_x`=-229.734,`position_y`=-726.782,`position_z`=60.6245,`orientation`=3.28665,`MovementType`=2 WHERE `guid`=175883 AND `id`=3537;

UPDATE `creature` SET `position_x`=-416.987,`position_y`=-653.933,`position_z`=54.5461,`orientation`=5.03489,`MovementType`=0 WHERE `guid`=175883 AND `id`=3537;
