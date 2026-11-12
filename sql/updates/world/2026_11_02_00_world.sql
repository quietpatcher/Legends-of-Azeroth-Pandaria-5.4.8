-- Quest 13947 'Blastranaar!' (Horde, Ashenvale, to-do 468), part 1/3: the vehicle creature 34433 'Furious Wind Rider', its summon position and the flight paths.
-- derived, no sniff: VehicleId 417 (Vehicle.dbc: id numbering runs with the entry series, 34430->415, 34438->418, 34432->419; 416 does not exist, 417 has one seat 4326 with CAN_CONTROL|CAN_CAST|CAN_ATTACK, matching an action-bar-only ride),
--   summon position of 65478 (3 yd next to Thraka, same z as Thraka; the video shows the wyvern appearing next to her ~1 s after the gossip), all waypoints (own flight: approach from Thraka, 4 laps of ~570 yd at z 135 over the 34494/34492 spawns, return path to Thraka),
--   flight speed (aura 54950 'Swift Wings', aura 208 +100 percent = ~14 yd/s so that the approach takes ~24 s and the return ~22 s, video: ~20 s), the 4-lap timeout (~185 s total, own choice; retail behaviour without pressing key 3 is unknown), creature_template_movement flight type.
-- Source: DBC 5.4.8 (Spell 65478 summon 34433 prop 1162 target DEST_DB; 65489 / 65481 / 65469; VehicleSeat 4326), wiki warcraft.wiki.gg/wiki/Blastranaar! (key 1 = Throw Explosive, key 3 = Return to Base!), Honorbuddy MoP 5.4.8 quest behavior 13947 (CastPetAction 1 / 3), YouTube d9ZUrwW-Opk and 6wBmQ8-Qi9g frame by frame; flight pattern copied from 30159 Sigrid Iceborn's Proto-Drake (CAN_CONTROL vehicle + SmartAI waypoints); state/blastranaar_468_bronnen.md.
-- Rollback: UPDATE `creature_template` SET `VehicleId` = 0, `spell1` = 0, `spell3` = 0, `AIName` = '' WHERE `entry` = 34433; DELETE FROM `creature_template_movement` WHERE `CreatureId` = 34433; DELETE FROM `creature_template_addon` WHERE `entry` = 34433; DELETE FROM `spell_target_position` WHERE `id` = 65478 AND `effIndex` = 0; DELETE FROM `waypoints` WHERE `entry` IN (3443301,3443302,3443303);

UPDATE `creature_template` SET `VehicleId` = 417, `spell1` = 65489, `spell3` = 65481, `AIName` = 'SmartAI' WHERE `entry` = 34433 AND `VehicleId` = 0;

DELETE FROM `creature_template_movement` WHERE `CreatureId` = 34433;
INSERT INTO `creature_template_movement` (`CreatureId`,`Ground`,`Swim`,`Flight`,`Rooted`,`Chase`,`Random`,`InteractionPauseTimer`) VALUES
(34433,1,0,2,0,NULL,NULL,NULL);

DELETE FROM `creature_template_addon` WHERE `entry` = 34433;
INSERT INTO `creature_template_addon` (`entry`,`path_id`,`mount`,`MountCreatureID`,`StandState`,`AnimTier`,`VisFlags`,`SheathState`,`PvPFlags`,`emote`,`aiAnimKit`,`movementAnimKit`,`meleeAnimKit`,`visibilityDistanceType`,`auras`) VALUES
(34433,0,0,0,0,2,0,0,0,0,0,0,0,0,'54950');

DELETE FROM `spell_target_position` WHERE `id` = 65478 AND `effIndex` = 0;
INSERT INTO `spell_target_position` (`id`,`effIndex`,`target_map`,`target_position_x`,`target_position_y`,`target_position_z`,`target_orientation`) VALUES
(65478,0,1,3052.7,-494.5,206.0,4.11898);

DELETE FROM `waypoints` WHERE `entry` IN (3443301,3443302,3443303);
INSERT INTO `waypoints` (`entry`,`pointid`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`point_comment`) VALUES
(3443301,1,3046.0,-493.0,222.0,NULL,0,'Blastranaar wyvern approach 1 (derived, no sniff)'),
(3443301,2,2985.0,-470.0,205.0,NULL,0,'Blastranaar wyvern approach 2 (derived, no sniff)'),
(3443301,3,2910.0,-440.0,175.0,NULL,0,'Blastranaar wyvern approach 3 (derived, no sniff)'),
(3443301,4,2845.0,-405.0,148.0,NULL,0,'Blastranaar wyvern approach 4 (derived, no sniff)'),
(3443301,5,2813.0,-379.0,135.0,NULL,0,'Blastranaar wyvern approach 5 (derived, no sniff)'),
(3443302,1,2802.3,-329.0,135.0,NULL,0,'Blastranaar wyvern lap 1 (derived, no sniff)'),
(3443302,2,2773.0,-292.4,135.0,NULL,0,'Blastranaar wyvern lap 2 (derived, no sniff)'),
(3443302,3,2733.0,-279.0,135.0,NULL,0,'Blastranaar wyvern lap 3 (derived, no sniff)'),
(3443302,4,2693.0,-292.4,135.0,NULL,0,'Blastranaar wyvern lap 4 (derived, no sniff)'),
(3443302,5,2663.7,-329.0,135.0,NULL,0,'Blastranaar wyvern lap 5 (derived, no sniff)'),
(3443302,6,2653.0,-379.0,135.0,NULL,0,'Blastranaar wyvern lap 6 (derived, no sniff)'),
(3443302,7,2663.7,-429.0,135.0,NULL,0,'Blastranaar wyvern lap 7 (derived, no sniff)'),
(3443302,8,2693.0,-465.6,135.0,NULL,0,'Blastranaar wyvern lap 8 (derived, no sniff)'),
(3443302,9,2733.0,-479.0,135.0,NULL,0,'Blastranaar wyvern lap 9 (derived, no sniff)'),
(3443302,10,2773.0,-465.6,135.0,NULL,0,'Blastranaar wyvern lap 10 (derived, no sniff)'),
(3443302,11,2802.3,-429.0,135.0,NULL,0,'Blastranaar wyvern lap 11 (derived, no sniff)'),
(3443302,12,2813.0,-379.0,135.0,NULL,0,'Blastranaar wyvern lap 12 (derived, no sniff)'),
(3443302,13,2802.3,-329.0,135.0,NULL,0,'Blastranaar wyvern lap 13 (derived, no sniff)'),
(3443302,14,2773.0,-292.4,135.0,NULL,0,'Blastranaar wyvern lap 14 (derived, no sniff)'),
(3443302,15,2733.0,-279.0,135.0,NULL,0,'Blastranaar wyvern lap 15 (derived, no sniff)'),
(3443302,16,2693.0,-292.4,135.0,NULL,0,'Blastranaar wyvern lap 16 (derived, no sniff)'),
(3443302,17,2663.7,-329.0,135.0,NULL,0,'Blastranaar wyvern lap 17 (derived, no sniff)'),
(3443302,18,2653.0,-379.0,135.0,NULL,0,'Blastranaar wyvern lap 18 (derived, no sniff)'),
(3443302,19,2663.7,-429.0,135.0,NULL,0,'Blastranaar wyvern lap 19 (derived, no sniff)'),
(3443302,20,2693.0,-465.6,135.0,NULL,0,'Blastranaar wyvern lap 20 (derived, no sniff)'),
(3443302,21,2733.0,-479.0,135.0,NULL,0,'Blastranaar wyvern lap 21 (derived, no sniff)'),
(3443302,22,2773.0,-465.6,135.0,NULL,0,'Blastranaar wyvern lap 22 (derived, no sniff)'),
(3443302,23,2802.3,-429.0,135.0,NULL,0,'Blastranaar wyvern lap 23 (derived, no sniff)'),
(3443302,24,2813.0,-379.0,135.0,NULL,0,'Blastranaar wyvern lap 24 (derived, no sniff)'),
(3443302,25,2802.3,-329.0,135.0,NULL,0,'Blastranaar wyvern lap 25 (derived, no sniff)'),
(3443302,26,2773.0,-292.4,135.0,NULL,0,'Blastranaar wyvern lap 26 (derived, no sniff)'),
(3443302,27,2733.0,-279.0,135.0,NULL,0,'Blastranaar wyvern lap 27 (derived, no sniff)'),
(3443302,28,2693.0,-292.4,135.0,NULL,0,'Blastranaar wyvern lap 28 (derived, no sniff)'),
(3443302,29,2663.7,-329.0,135.0,NULL,0,'Blastranaar wyvern lap 29 (derived, no sniff)'),
(3443302,30,2653.0,-379.0,135.0,NULL,0,'Blastranaar wyvern lap 30 (derived, no sniff)'),
(3443302,31,2663.7,-429.0,135.0,NULL,0,'Blastranaar wyvern lap 31 (derived, no sniff)'),
(3443302,32,2693.0,-465.6,135.0,NULL,0,'Blastranaar wyvern lap 32 (derived, no sniff)'),
(3443302,33,2733.0,-479.0,135.0,NULL,0,'Blastranaar wyvern lap 33 (derived, no sniff)'),
(3443302,34,2773.0,-465.6,135.0,NULL,0,'Blastranaar wyvern lap 34 (derived, no sniff)'),
(3443302,35,2802.3,-429.0,135.0,NULL,0,'Blastranaar wyvern lap 35 (derived, no sniff)'),
(3443302,36,2813.0,-379.0,135.0,NULL,0,'Blastranaar wyvern lap 36 (derived, no sniff)'),
(3443302,37,2802.3,-329.0,135.0,NULL,0,'Blastranaar wyvern lap 37 (derived, no sniff)'),
(3443302,38,2773.0,-292.4,135.0,NULL,0,'Blastranaar wyvern lap 38 (derived, no sniff)'),
(3443302,39,2733.0,-279.0,135.0,NULL,0,'Blastranaar wyvern lap 39 (derived, no sniff)'),
(3443302,40,2693.0,-292.4,135.0,NULL,0,'Blastranaar wyvern lap 40 (derived, no sniff)'),
(3443302,41,2663.7,-329.0,135.0,NULL,0,'Blastranaar wyvern lap 41 (derived, no sniff)'),
(3443302,42,2653.0,-379.0,135.0,NULL,0,'Blastranaar wyvern lap 42 (derived, no sniff)'),
(3443302,43,2663.7,-429.0,135.0,NULL,0,'Blastranaar wyvern lap 43 (derived, no sniff)'),
(3443302,44,2693.0,-465.6,135.0,NULL,0,'Blastranaar wyvern lap 44 (derived, no sniff)'),
(3443302,45,2733.0,-479.0,135.0,NULL,0,'Blastranaar wyvern lap 45 (derived, no sniff)'),
(3443302,46,2773.0,-465.6,135.0,NULL,0,'Blastranaar wyvern lap 46 (derived, no sniff)'),
(3443302,47,2802.3,-429.0,135.0,NULL,0,'Blastranaar wyvern lap 47 (derived, no sniff)'),
(3443302,48,2813.0,-379.0,135.0,NULL,0,'Blastranaar wyvern lap 48 (derived, no sniff)'),
(3443303,1,2930.0,-445.0,170.0,NULL,0,'Blastranaar wyvern return 1 (derived, no sniff)'),
(3443303,2,3000.0,-475.0,200.0,NULL,0,'Blastranaar wyvern return 2 (derived, no sniff)'),
(3443303,3,3040.0,-490.0,212.0,NULL,0,'Blastranaar wyvern return 3 (derived, no sniff)'),
(3443303,4,3052.7,-494.5,206.5,NULL,0,'Blastranaar wyvern return 4 (derived, no sniff)');
