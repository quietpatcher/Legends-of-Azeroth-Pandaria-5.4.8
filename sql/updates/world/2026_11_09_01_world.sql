-- To-do 468 (quest 13947 Blastranaar!): the reporter's note (05-11, 08-11) and the quest videos: the wind rider flies in at the north-east
-- entrance of Astranaar and follows the main road through the town to the south-west side, instead of circling over the roofs and tree
-- crowns. The 48-point circle (path 3443302, our own, derived, no sniff) is replaced by four passes along the main road (north-east to
-- south-west and back, U-turns outside the town), z 140 over the road (ground ~107, the Astranaar Sentinels stand along this axis, so
-- the bomb (Throw Explosive 65489, range 100 yd) reaches them from the road); the approach (3443301 points 3-5) now ends at the
-- north-east entrance. Return path 3443303 and the landing are unchanged.
-- Source: reporter note on to-do 468 (YouTube video: clear path from the north-east entrance along the main road to the south-west side);
-- axis from the Astranaar Sentinel spawns (34494, x 2639-2817, y -489..-263); DBC SpellRange 135 (100 yd) for 65489.
-- Rollback: restore the rows below (old approach points and the old circle):
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443301,1,3046,-493,222,NULL,0,'Blastranaar wyvern approach 1 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443301,2,2985,-470,205,NULL,0,'Blastranaar wyvern approach 2 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443301,3,2910,-440,175,NULL,0,'Blastranaar wyvern approach 3 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443301,4,2845,-405,165,NULL,0,'Blastranaar wyvern approach 4 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443301,5,2813,-379,160,NULL,0,'Blastranaar wyvern approach 5 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,1,2802.3,-329,160,NULL,0,'Blastranaar wyvern lap 1 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,2,2773,-292.4,160,NULL,0,'Blastranaar wyvern lap 2 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,3,2733,-279,160,NULL,0,'Blastranaar wyvern lap 3 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,4,2693,-292.4,160,NULL,0,'Blastranaar wyvern lap 4 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,5,2663.7,-329,160,NULL,0,'Blastranaar wyvern lap 5 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,6,2653,-379,160,NULL,0,'Blastranaar wyvern lap 6 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,7,2663.7,-429,160,NULL,0,'Blastranaar wyvern lap 7 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,8,2693,-465.6,160,NULL,0,'Blastranaar wyvern lap 8 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,9,2733,-479,160,NULL,0,'Blastranaar wyvern lap 9 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,10,2773,-465.6,160,NULL,0,'Blastranaar wyvern lap 10 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,11,2802.3,-429,160,NULL,0,'Blastranaar wyvern lap 11 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,12,2813,-379,160,NULL,0,'Blastranaar wyvern lap 12 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,13,2802.3,-329,160,NULL,0,'Blastranaar wyvern lap 13 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,14,2773,-292.4,160,NULL,0,'Blastranaar wyvern lap 14 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,15,2733,-279,160,NULL,0,'Blastranaar wyvern lap 15 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,16,2693,-292.4,160,NULL,0,'Blastranaar wyvern lap 16 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,17,2663.7,-329,160,NULL,0,'Blastranaar wyvern lap 17 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,18,2653,-379,160,NULL,0,'Blastranaar wyvern lap 18 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,19,2663.7,-429,160,NULL,0,'Blastranaar wyvern lap 19 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,20,2693,-465.6,160,NULL,0,'Blastranaar wyvern lap 20 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,21,2733,-479,160,NULL,0,'Blastranaar wyvern lap 21 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,22,2773,-465.6,160,NULL,0,'Blastranaar wyvern lap 22 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,23,2802.3,-429,160,NULL,0,'Blastranaar wyvern lap 23 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,24,2813,-379,160,NULL,0,'Blastranaar wyvern lap 24 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,25,2802.3,-329,160,NULL,0,'Blastranaar wyvern lap 25 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,26,2773,-292.4,160,NULL,0,'Blastranaar wyvern lap 26 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,27,2733,-279,160,NULL,0,'Blastranaar wyvern lap 27 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,28,2693,-292.4,160,NULL,0,'Blastranaar wyvern lap 28 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,29,2663.7,-329,160,NULL,0,'Blastranaar wyvern lap 29 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,30,2653,-379,160,NULL,0,'Blastranaar wyvern lap 30 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,31,2663.7,-429,160,NULL,0,'Blastranaar wyvern lap 31 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,32,2693,-465.6,160,NULL,0,'Blastranaar wyvern lap 32 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,33,2733,-479,160,NULL,0,'Blastranaar wyvern lap 33 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,34,2773,-465.6,160,NULL,0,'Blastranaar wyvern lap 34 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,35,2802.3,-429,160,NULL,0,'Blastranaar wyvern lap 35 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,36,2813,-379,160,NULL,0,'Blastranaar wyvern lap 36 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,37,2802.3,-329,160,NULL,0,'Blastranaar wyvern lap 37 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,38,2773,-292.4,160,NULL,0,'Blastranaar wyvern lap 38 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,39,2733,-279,160,NULL,0,'Blastranaar wyvern lap 39 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,40,2693,-292.4,160,NULL,0,'Blastranaar wyvern lap 40 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,41,2663.7,-329,160,NULL,0,'Blastranaar wyvern lap 41 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,42,2653,-379,160,NULL,0,'Blastranaar wyvern lap 42 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,43,2663.7,-429,160,NULL,0,'Blastranaar wyvern lap 43 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,44,2693,-465.6,160,NULL,0,'Blastranaar wyvern lap 44 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,45,2733,-479,160,NULL,0,'Blastranaar wyvern lap 45 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,46,2773,-465.6,160,NULL,0,'Blastranaar wyvern lap 46 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,47,2802.3,-429,160,NULL,0,'Blastranaar wyvern lap 47 (derived, no sniff)');
-- INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES (3443302,48,2813,-379,160,NULL,0,'Blastranaar wyvern lap 48 (derived, no sniff)');
DELETE FROM `waypoints` WHERE `entry` = 3443302;
INSERT INTO `waypoints` (`entry`, `pointid`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `point_comment`) VALUES
(3443302, 1, 2828.6, -254.1, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 2, 2814.1, -270.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 3, 2799.7, -285.8, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 4, 2785.3, -301.6, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 5, 2770.8, -317.5, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 6, 2756.4, -333.3, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 7, 2741.9, -349.2, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 8, 2727.5, -365.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 9, 2713.1, -380.8, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 10, 2698.6, -396.7, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 11, 2684.2, -412.5, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 12, 2669.7, -428.4, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 13, 2655.3, -444.2, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 14, 2640.9, -460.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 15, 2626.4, -475.9, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 16, 2598.5, -484.2, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 17, 2602.8, -501.7, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 18, 2620.7, -504.4, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 19, 2626.4, -475.9, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 20, 2640.9, -460.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 21, 2655.3, -444.2, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 22, 2669.7, -428.4, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 23, 2684.2, -412.5, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 24, 2698.6, -396.7, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 25, 2713.1, -380.8, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 26, 2727.5, -365.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 27, 2741.9, -349.2, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 28, 2756.4, -333.3, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 29, 2770.8, -317.5, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 30, 2785.3, -301.6, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 31, 2799.7, -285.8, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 32, 2814.1, -270.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 33, 2828.6, -254.1, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 34, 2856.5, -245.8, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 35, 2852.2, -228.3, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 36, 2834.3, -225.6, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 37, 2828.6, -254.1, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 38, 2814.1, -270.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 39, 2799.7, -285.8, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 40, 2785.3, -301.6, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 41, 2770.8, -317.5, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 42, 2756.4, -333.3, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 43, 2741.9, -349.2, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 44, 2727.5, -365.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 45, 2713.1, -380.8, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 46, 2698.6, -396.7, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 47, 2684.2, -412.5, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 48, 2669.7, -428.4, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 49, 2655.3, -444.2, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 50, 2640.9, -460.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 51, 2626.4, -475.9, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 52, 2598.5, -484.2, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 53, 2602.8, -501.7, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 54, 2620.7, -504.4, 150.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 55, 2626.4, -475.9, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 56, 2640.9, -460.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 57, 2655.3, -444.2, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 58, 2669.7, -428.4, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 59, 2684.2, -412.5, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 60, 2698.6, -396.7, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 61, 2713.1, -380.8, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 62, 2727.5, -365.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 63, 2741.9, -349.2, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 64, 2756.4, -333.3, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 65, 2770.8, -317.5, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 66, 2785.3, -301.6, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 67, 2799.7, -285.8, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 68, 2814.1, -270.0, 140.0, 0, 0, 'Blastranaar pass over the main road'),
(3443302, 69, 2828.6, -254.1, 140.0, 0, 0, 'Blastranaar pass over the main road');
UPDATE `waypoints` SET `position_x` = 2920, `position_y` = -400, `position_z` = 185 WHERE `entry` = 3443301 AND `pointid` = 3;
UPDATE `waypoints` SET `position_x` = 2875, `position_y` = -300, `position_z` = 165 WHERE `entry` = 3443301 AND `pointid` = 4;
UPDATE `waypoints` SET `position_x` = 2828.6, `position_y` = -254.1, `position_z` = 150 WHERE `entry` = 3443301 AND `pointid` = 5;
