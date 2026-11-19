-- Five service and quest NPCs of the review of 15-11-2026: Seth, Caylee Dak and Vindicator Kaan (Shattrath City), the flight
--   master Krexcil (Netherstorm) and the innkeeper Janene (map 1, area 513).
-- What a player sees today: these NPCs stand between 7 and 82 yards from the place where they were seen in the sniffs, so
--   quests are offered or handed in away from the expected spot.
-- Cause: the positions come from an older database; the sniff-based reference has the NPC somewhere else.
-- Checked: each NPC has exactly one spawn (MovementType 0, phase mask 1, no script name, formation, pool, game event, linked
--   respawn, waypoint, smart script on the spawn or condition); Seth and Krexcil have a plain creature_addon row (no path,
--   no aura) that stays. The Cataclysm Preservation reference has one spawn of each (phase id 169 = default phase), the
--   SkyFire 5.4.8 reference has it at the same coordinates, same area, height difference at most 1.7 yards. Nothing of
--   ours stands within 2 yards of the new positions except the event creatures Winter Reveler (15760, phase mask 65535)
--   next to Janene and Caylee's pet Dusky (24728), which the reference also places there.
-- Not done: Lord Torvos (guid 99717) would stand on exactly the same point as High Exarch Commodus (72496) and the
--   reference has no Commodus spawn, so that conflict is left; Timothy Holland (95516): the reference spot is 10.4 yards below
--   the inn floor where every other innkeeper-house NPC of both references and of ours stands, ground height not confirmed.
-- Change: the five spawns move to the reference position and orientation.
-- Source: Cataclysm Preservation sniff database and SkyFire 5.4.8 database (comparison), 15-11-2026.
-- Rollback (the values before this update):
--   UPDATE `creature` SET `position_x`=-1610.08,`position_y`=5298.37,`position_z`=-38.9131,`orientation`=2.90344 WHERE `guid`=66060 AND `id`=18653;
--   UPDATE `creature` SET `position_x`=-1658.85,`position_y`=5725.71,`position_z`=130.598,`orientation`=3.25265 WHERE `guid`=126499 AND `id`=24727;
--   UPDATE `creature` SET `position_x`=-1804.42,`position_y`=5608.02,`position_z`=130.812,`orientation`=1.26175 WHERE `guid`=126634 AND `id`=23271;
--   UPDATE `creature` SET `position_x`=3078.15,`position_y`=3601.7,`position_z`=144.067,`orientation`=4.80138 WHERE `guid`=57285 AND `id`=18938;
--   UPDATE `creature` SET `position_x`=-3616.13,`position_y`=-4470.81,`position_z`=14.3278,`orientation`=2.21657 WHERE `guid`=255182 AND `id`=6272;

UPDATE `creature` SET `position_x`=-1612.66,`position_y`=5315.41,`position_z`=-40.2089,`orientation`=6.04818 WHERE `guid`=66060 AND `id`=18653;  -- Seth (18653), 17.3 yd
UPDATE `creature` SET `position_x`=-1715.53,`position_y`=5727.81,`position_z`=130.735,`orientation`=4.0682 WHERE `guid`=126499 AND `id`=24727;  -- Caylee Dak (24727), 56.7 yd
UPDATE `creature` SET `position_x`=-1752.74,`position_y`=5671.48,`position_z`=129.142,`orientation`=2.7181 WHERE `guid`=126634 AND `id`=23271;  -- Vindicator Kaan (23271), 81.9 yd
UPDATE `creature` SET `position_x`=3085.3,`position_y`=3600.82,`position_z`=144.009,`orientation`=3.89776 WHERE `guid`=57285 AND `id`=18938;  -- Krexcil (18938), 7.2 yd
UPDATE `creature` SET `position_x`=-3619.51,`position_y`=-4462.25,`position_z`=13.7046,`orientation`=1.8326 WHERE `guid`=255182 AND `id`=6272;  -- Innkeeper Janene (6272), 9.2 yd
