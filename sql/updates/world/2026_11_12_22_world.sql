-- To-do 468 (quest 13947 Blastranaar!), follow-up to 2026_11_12_21 after the second own-client test on dev: the speeds are right now (approach about
-- 14 s, passes about 70 s, return about 22 s), but the wind rider flew INSIDE the foliage of the giant trees of Astranaar (the camera sat in the crown model
-- and the screen turned into one purple/blue plane), and from z 175 the default horizontal camera gave 'Out of range' on nearly every throw. The route
-- goes down: below the canopy, along the main road, as in the quest videos (a clear path along the main road through Astranaar).
-- Ground along the road: the Astranaar Sentinels and Throwers that stand on the road at the passes (waypoints 3443302/2-14 and the repeats) are at
--   z 107.2-108.5 (lowest per waypoint within 25 yd), the road patrol points of the town at z 107; near the south-west end (waypoints 15 and 19,
--   x 2626.4 y -475.9) the lowest spawn is at z 99.0 (lake shore). The passes are set to ground + about 22 yd: z 130 over the road, z 121 at the
--   south-west end (ground 99), z 135 for the three U-turn points outside the town (x 2598-2621, y -484..-504, no spawns there). Their x/y are unchanged
--   (the axis of the Sentinel spawns, the main road north-east to south-west).
-- Descent: the approach path ends at the bridge (3443301/5, 2828.6 -254.1) and now has z 130 there (was 175); the point before it (3443301/4, 2875 -300)
--   goes from 165 to 150, the one before that (z 185) is unchanged, so the descent is 185 -> 150 -> 130 over 110 and 64 yd. The return path 3443303
--   is not changed: it climbs from the end of the passes (z 130) to 185 at 2930 -445 over 216 yd, with ground at about 103-108 under that leg,
--   and keeps the earlier ridge clearance at Hellscream's Watch (z 220-225).
-- Bomb reach: Throw Explosive has range 100 yd (3D, from the wind rider to the target circle). With the passes at z 121-135 every one of the 67
--   Sentinel/Thrower spawns (z 107-121) is within 94 yd 3D of the path (largest horizontal distance 91 yd, 90 percent within 55 yd; before this
--   change z 155-175: largest 3D distance 102-113 yd, so one Thrower was out of reach). The vertical distance is now 9-28 yd, so a horizontal camera
--   reaches ground targets up to about 97 yd away.
-- Not verifiable here: building and tree positions are not in the world data. NPCs standing on platforms at z 132-143 lie within 12 yd of the
--   path at waypoints 2, 5, 6 and 14/20 (z 127-143); a platform there could still touch the path.
-- Source: z of the creature and gameobject spawns along the road (world data), spell range of 65489 (100 yd), own-client test on dev, quest videos
--   (route along the main road). Heights are derived, no sniff.
-- Rollback: UPDATE `waypoints` SET `position_z` = 175 WHERE `entry` = 3443302 AND `position_z` IN (121,130);
--   UPDATE `waypoints` SET `position_z` = 180 WHERE `entry` = 3443302 AND `position_z` = 135;
--   UPDATE `waypoints` SET `position_z` = 175 WHERE `entry` = 3443301 AND `pointid` = 5 AND `position_z` = 130;
--   UPDATE `waypoints` SET `position_z` = 165 WHERE `entry` = 3443301 AND `pointid` = 4 AND `position_z` = 150;

UPDATE `waypoints` SET `position_z` = 121 WHERE `entry` = 3443302 AND `position_z` = 175 AND ABS(`position_x` - 2626.4) < 0.1 AND ABS(`position_y` + 475.9) < 0.1;
UPDATE `waypoints` SET `position_z` = 135 WHERE `entry` = 3443302 AND `position_z` = 180;
UPDATE `waypoints` SET `position_z` = 130 WHERE `entry` = 3443302 AND `position_z` = 175;
UPDATE `waypoints` SET `position_z` = 130 WHERE `entry` = 3443301 AND `pointid` = 5 AND `position_z` = 175;
UPDATE `waypoints` SET `position_z` = 150 WHERE `entry` = 3443301 AND `pointid` = 4 AND `position_z` = 165;
