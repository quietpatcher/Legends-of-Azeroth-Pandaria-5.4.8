-- Instance patrols whose whole waypoint path lies more than 1000 yards from their spawn (to-do 304 follow-up, bot stalls):
-- 39 creatures in Black Morass (269), Temple of Ahn'Qiraj (531), Karazhan (532), Hyjal Summit (534),
-- Old Hillsbrad Foothills (560) and Zul'Gurub (859). Each path id equals the creature guid but every point belongs to another
-- place (left over from an old guid), so these mobs try to walk out of the instance and bot groups chase them (same cause as the
-- Deadmines Oaf Lackey, 2026_11_10_05). They now stand at their spawn; the waypoint rows are kept, only the link is removed.
-- List: state/far_waypoints_20261110.tsv (all points > 1000 yd, instance maps only; long continent patrols and the scripted
-- Flamewaker Priest 51397 in Molten Core left alone).
-- Source: world.creature / creature_addon / waypoint_data distance check 10-11-2026.
-- Rollback: UPDATE `creature` SET `MovementType`=2 WHERE `guid` IN (91333,91434,91441,91447,91442,91436,91462,91461,91457,91412,91456,91460,91459,91458,91314,91316,29341,34234,86560,86561,86562,81956,25295,25424,26429,26223,26442,26436,121079,96966,91567,91564,93299,93472,93494,93107,93265,93282,337983); UPDATE `creature_addon` SET `path_id`=`guid` WHERE `guid` IN (91333,91434,91441,91447,91442,91436,91462,91461,91457,91412,91456,91460,91459,91458,91314,91316,29341,34234,86560,86561,86562,81956,25295,25424,26429,26223,26442,26436,121079,96966,91567,91564,93299,93472,93494,93107,93265,93282,337983);
UPDATE `creature` SET `MovementType`=0 WHERE `guid` IN (91333,91434,91441,91447,91442,91436,91462,91461,91457,91412,91456,91460,91459,91458,91314,91316,29341,34234,86560,86561,86562,81956,25295,25424,26429,26223,26442,26436,121079,96966,91567,91564,93299,93472,93494,93107,93265,93282,337983) AND `MovementType`=2;
UPDATE `creature_addon` SET `path_id`=0 WHERE `guid` IN (91333,91434,91441,91447,91442,91436,91462,91461,91457,91412,91456,91460,91459,91458,91314,91316,29341,34234,86560,86561,86562,81956,25295,25424,26429,26223,26442,26436,121079,96966,91567,91564,93299,93472,93494,93107,93265,93282,337983) AND `path_id`=`guid`;
