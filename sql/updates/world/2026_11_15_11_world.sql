-- Totem of Tikti (creature guid 55140, entry 17362, Azuremyst Isle): move the spawn 11.8 yards to the position the
-- sniff-based reference has, and move the summon of its quest script along with it.
-- What a player sees today: the totem that starts quest "Totem of Yor" stands 11.8 yards from where it stands in the
--   sniffs; Stillpine Ancestor Tikti, which the totem summons on quest accept, appears next to the current totem spot.
-- Cause: the totem position comes from an older database. The smart_script of the totem summons the ancestor at fixed
--   coordinates (-3863.3 -13125 7.90906), which sit 1.53 yards west and 2 yards north of the current totem.
-- Checked: the reference has one spawn of entry 17362 on map 530 (zone and area 3524, MovementType 0 in both) at the
--   new coordinates; no other creature lies within 3 yards of it; creature_addon of the spawn holds no path or aura;
--   no creature_formations, game_event_creature, pool_creature or linked_respawn row refers to the spawn; template and
--   spawn have no ScriptName. The ancestor (entry 17392) has no spawn in the references and its walk-away script
--   (1739200) moves to absolute positions that do not depend on the totem, so only the summon point is touched.
-- No reference has a position for the summoned ancestor (the reference script casts a spell instead of summoning at
--   coordinates), so the summon point keeps its current offset to the totem (x -1.53, y +2, z +0, same orientation):
--   it moves from (-3863.3, -13125, 7.90906) to (-3874.84, -13122.5, 7.06856).
-- Change: position_x, position_y, position_z and orientation of the spawn; target_x, target_y and target_z of
--   smart_scripts row (17362, source_type 0, id 0).
-- Source: Cataclysm Preservation sniff database, checked 15-11-2026; quest flow (totem gives the quest, ancestor is
--   summoned on accept) checked against Wowhead.
-- Rollback (the values before this update):
--   UPDATE `creature` SET `position_x`=-3861.77,`position_y`=-13127,`position_z`=7.90906,`orientation`=6.0758 WHERE `guid`=55140 AND `id`=17362;
--   UPDATE `smart_scripts` SET `target_x`=-3863.3,`target_y`=-13125,`target_z`=7.90906 WHERE `entryorguid`=17362 AND `source_type`=0 AND `id`=0;

UPDATE `creature` SET `position_x`=-3873.31,`position_y`=-13124.5,`position_z`=7.06856,`orientation`=1.72788 WHERE `guid`=55140 AND `id`=17362;
UPDATE `smart_scripts` SET `target_x`=-3874.84,`target_y`=-13122.5,`target_z`=7.06856 WHERE `entryorguid`=17362 AND `source_type`=0 AND `id`=0;
