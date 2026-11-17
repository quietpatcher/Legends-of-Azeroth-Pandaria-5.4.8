-- Quest givers of the review of 15-11-2026 (Terokkar Forest to Desolace, 15 zones): 66 quest giver spawns that lie 6 to 81 yards
--   from the position the sniff-based reference has for the same creature (Grizzly Hills 18, Terokkar Forest 10, Zul'Drak 10,
--   Blade's Edge Mountains 9, Sholazar Basin 6, Netherstorm 5, The Storm Peaks 4, Shadowmoon Valley 2, Icecrown 1, Vashj'ir -
--   Shimmering Expanse 1), plus four duplicate spawns (Skybreaker Squad Leader, Farseer Gadra, Fiasco Sizzlegrin).
-- What a player sees today: the quest givers stand at a position from an older database instead of at the spot where quests
--   are given and handed in according to the sniffs (up to 81 yards away, for example Agadai 81, Old Man Barlo 75, Rheanna 74,
--   Witch Doctor Khufu 59), and three quest givers exist twice.
-- Cause: positions come from an older database; the sniff-based reference has the observed position. The duplicates are
--   surplus spawns: the id has more spawns here than in the reference and each reference spawn is already covered by another one.
-- Checked per row: the reference has a spawn of the same id on the same map at exactly the new coordinates (MovementType 0 and
--   phase mask 1 in both, no phase id or group, same zone); no creature_formations, creature_addon waypoint path, waypoint_data,
--   game_event_creature, pool_creature or linked_respawn row refers to the changed spawns; none of the spawns has a ScriptName;
--   no smart_script of the ids holds a waypoint, move-to-position or teleport action. Rows that differ more than 3 yards in
--   height are included only when the reference spawn is in the same area and at most 60 yards away. Area and zone columns are
--   left unchanged.
-- Duplicates: Skybreaker Squad Leader (31737) guids 111310 and 111312 (3 spawns here, 1 in the reference; 111311 stands at the
--   reference position and stays), Farseer Gadra (39226) guid 206261 (0.2 yards from 206234, which stays) and Fiasco Sizzlegrin
--   (40918) guid 206341 (the reference spawn stands where 206342 already is). Only guid 206261 has a creature_addon row; no
--   formation, linked respawn, game event, pool, waypoint, smart script or condition row refers to the four guids.
-- Left out on purpose: seven rows closer than 6 yards (marginal: Sky Sergeant Doryn, Olrokk, Inactive Fel Reaver 76834, Captain
--   Grondel, Tracker Val'zij, Astrid Bjornrittar, Bleenik Fizzlefuse) and four rows with a height difference of more than 3 yards
--   and more than 60 yards (Scout Captain Carter, Moteha Windborn, Tore Rumblewrench, Xarantaur); Conqueror Krenna (a height
--   difference of 45 yards, uncertain); Sorata Firespinner guid 572204 (a second spot on purpose: she ends three quests and the
--   public database shows two places for her in Azshara); rows without a clear reference spot are not touched.
-- Change: position_x, position_y, position_z and orientation of the 66 spawns are set to the reference values; the four
--   duplicate spawns are deleted.
-- Source: Cataclysm Preservation sniff database (comparison), 15-11-2026.
-- Rollback (the values and rows before this update):
--   UPDATE `creature` SET `position_x`=-2933.51,`position_y`=4069.93,`position_z`=3.67233,`orientation`=4.87342 WHERE `guid`=50233 AND `id`=24885;
--   UPDATE `creature` SET `position_x`=-3015.84,`position_y`=3974.7,`position_z`=3.10551,`orientation`=0.561024 WHERE `guid`=74818 AND `id`=18390;
--   UPDATE `creature` SET `position_x`=-2570.4,`position_y`=4991.83,`position_z`=11.2913,`orientation`=2.086 WHERE `guid`=76154 AND `id`=18714;
--   UPDATE `creature` SET `position_x`=-2301.65,`position_y`=4918.8,`position_z`=1.61751,`orientation`=6.01299 WHERE `guid`=76159 AND `id`=18715;
--   UPDATE `creature` SET `position_x`=-2511.04,`position_y`=3665.67,`position_z`=1.60652,`orientation`=2.86271 WHERE `guid`=77973 AND `id`=18566;
--   UPDATE `creature` SET `position_x`=-3203.12,`position_y`=6024.57,`position_z`=0.000296989,`orientation`=3.43244 WHERE `guid`=78274 AND `id`=18273;
--   UPDATE `creature` SET `position_x`=-2607.48,`position_y`=3321.04,`position_z`=0.849507,`orientation`=0.0957125 WHERE `guid`=78276 AND `id`=21006;
--   UPDATE `creature` SET `position_x`=-2538.25,`position_y`=3661.06,`position_z`=1.84738,`orientation`=0.809787 WHERE `guid`=78403 AND `id`=21007;
--   UPDATE `creature` SET `position_x`=-3723.14,`position_y`=4404.91,`position_z`=-2.90589,`orientation`=0.602223 WHERE `guid`=81000 AND `id`=22462;
--   UPDATE `creature` SET `position_x`=-1461.28,`position_y`=4992.3,`position_z`=-9.04306,`orientation`=5.1365 WHERE `guid`=99581 AND `id`=25580;
--   UPDATE `creature` SET `position_x`=-4027.65,`position_y`=1600.63,`position_z`=92.676,`orientation`=0.049544 WHERE `guid`=73928 AND `id`=21293;
--   UPDATE `creature` SET `position_x`=-3080.71,`position_y`=788.472,`position_z`=-8.52668,`orientation`=6.25788 WHERE `guid`=126542 AND `id`=23452;
--   UPDATE `creature` SET `position_x`=3567.71,`position_y`=6864.4,`position_z`=140.526,`orientation`=4.27606 WHERE `guid`=60253 AND `id`=22215;
--   UPDATE `creature` SET `position_x`=3016.94,`position_y`=5458.91,`position_z`=146.286,`orientation`=0.919091 WHERE `guid`=60901 AND `id`=22127;
--   UPDATE `creature` SET `position_x`=1782.83,`position_y`=5856.9,`position_z`=160.627,`orientation`=0.881992 WHERE `guid`=76079 AND `id`=21690;
--   UPDATE `creature` SET `position_x`=2792.09,`position_y`=5829.41,`position_z`=36.015,`orientation`=1.64384 WHERE `guid`=124632 AND `id`=22941;
--   UPDATE `creature` SET `position_x`=2545.37,`position_y`=7329.5,`position_z`=373.425,`orientation`=5.57181 WHERE `guid`=124654 AND `id`=23335;
--   UPDATE `creature` SET `position_x`=2323.45,`position_y`=7305.9,`position_z`=365.617,`orientation`=4.4501 WHERE `guid`=124668 AND `id`=23316;
--   UPDATE `creature` SET `position_x`=2320.46,`position_y`=7279.32,`position_z`=365.617,`orientation`=1.16404 WHERE `guid`=124674 AND `id`=23253;
--   UPDATE `creature` SET `position_x`=2444.59,`position_y`=5946.75,`position_z`=153.587,`orientation`=0.102097 WHERE `guid`=125597 AND `id`=23280;
--   UPDATE `creature` SET `position_x`=2796.79,`position_y`=5864.32,`position_z`=3.2038,`orientation`=3.80132 WHERE `guid`=125600 AND `id`=22995;
--   UPDATE `creature` SET `position_x`=4267.03,`position_y`=2200.15,`position_z`=133.988,`orientation`=4.23848 WHERE `guid`=57485 AND `id`=20450;
--   UPDATE `creature` SET `position_x`=4514.06,`position_y`=3430.35,`position_z`=166.743,`orientation`=3.89916 WHERE `guid`=76831 AND `id`=22293;
--   UPDATE `creature` SET `position_x`=3915.36,`position_y`=4046.15,`position_z`=189.937,`orientation`=3.93409 WHERE `guid`=78026 AND `id`=20920;
--   UPDATE `creature` SET `position_x`=4048.48,`position_y`=3556.9,`position_z`=121.313,`orientation`=5.46704 WHERE `guid`=80896 AND `id`=20780;
--   UPDATE `creature` SET `position_x`=4095.4,`position_y`=2943.89,`position_z`=356.26,`orientation`=0.305515 WHERE `guid`=126533 AND `id`=22899;
--   UPDATE `creature` SET `position_x`=5206.24,`position_y`=-1313.54,`position_z`=242.453,`orientation`=0.294778 WHERE `guid`=62372 AND `id`=28518;
--   UPDATE `creature` SET `position_x`=5795.23,`position_y`=-3024.65,`position_z`=286.656,`orientation`=2.01626 WHERE `guid`=86278 AND `id`=30007;
--   UPDATE `creature` SET `position_x`=6964.28,`position_y`=-4090.1,`position_z`=479.318,`orientation`=4.69163 WHERE `guid`=86681 AND `id`=33025;
--   UPDATE `creature` SET `position_x`=5794.42,`position_y`=-3565.94,`position_z`=386.673,`orientation`=3.32221 WHERE `guid`=99344 AND `id`=28479;
--   UPDATE `creature` SET `position_x`=5268.39,`position_y`=-3501.81,`position_z`=291.687,`orientation`=2.63201 WHERE `guid`=99737 AND `id`=28284;
--   UPDATE `creature` SET `position_x`=5268.55,`position_y`=-3510.37,`position_z`=291.694,`orientation`=2.46903 WHERE `guid`=117170 AND `id`=28125;
--   UPDATE `creature` SET `position_x`=5188.25,`position_y`=-2214.13,`position_z`=239.398,`orientation`=2.48865 WHERE `guid`=117210 AND `id`=29137;
--   UPDATE `creature` SET `position_x`=5541.01,`position_y`=-1874.73,`position_z`=238.268,`orientation`=0.722438 WHERE `guid`=118539 AND `id`=29689;
--   UPDATE `creature` SET `position_x`=5736.81,`position_y`=-3571.86,`position_z`=386.789,`orientation`=6.24072 WHERE `guid`=118921 AND `id`=28527;
--   UPDATE `creature` SET `position_x`=5782.24,`position_y`=-3574.62,`position_z`=386.498,`orientation`=2.2721 WHERE `guid`=118943 AND `id`=28480;
--   UPDATE `creature` SET `position_x`=3825.42,`position_y`=-1992.41,`position_z`=208.764,`orientation`=4.89958 WHERE `guid`=96084 AND `id`=26604;
--   UPDATE `creature` SET `position_x`=4549.18,`position_y`=-4255.22,`position_z`=170.646,`orientation`=2.04105 WHERE `guid`=117116 AND `id`=26361;
--   UPDATE `creature` SET `position_x`=4538.63,`position_y`=-4252.1,`position_z`=170.492,`orientation`=1.05219 WHERE `guid`=117138 AND `id`=26226;
--   UPDATE `creature` SET `position_x`=4349.38,`position_y`=-5305.08,`position_z`=1.21529,`orientation`=2.24663 WHERE `guid`=117143 AND `id`=26420;
--   UPDATE `creature` SET `position_x`=4597.93,`position_y`=-4230.19,`position_z`=178.646,`orientation`=3.00312 WHERE `guid`=117144 AND `id`=26212;
--   UPDATE `creature` SET `position_x`=4685.39,`position_y`=-4012.17,`position_z`=213.272,`orientation`=0.747691 WHERE `guid`=117145 AND `id`=26932;
--   UPDATE `creature` SET `position_x`=3846.07,`position_y`=-1966.04,`position_z`=208.502,`orientation`=2.92376 WHERE `guid`=117211 AND `id`=26424;
--   UPDATE `creature` SET `position_x`=3209.39,`position_y`=-2488.1,`position_z`=53.7645,`orientation`=3.21706 WHERE `guid`=119612 AND `id`=27120;
--   UPDATE `creature` SET `position_x`=3888.61,`position_y`=-1927.39,`position_z`=209.622,`orientation`=4.26163 WHERE `guid`=119625 AND `id`=26519;
--   UPDATE `creature` SET `position_x`=4242.88,`position_y`=-2036.47,`position_z`=238.595,`orientation`=1.40751 WHERE `guid`=119644 AND `id`=26543;
--   UPDATE `creature` SET `position_x`=4322.23,`position_y`=-4991.12,`position_z`=20.3783,`orientation`=1.5261 WHERE `guid`=119645 AND `id`=26884;
--   UPDATE `creature` SET `position_x`=4479.85,`position_y`=-2258.59,`position_z`=180.147,`orientation`=3.3521 WHERE `guid`=119654 AND `id`=27497;
--   UPDATE `creature` SET `position_x`=4715.76,`position_y`=-4445.13,`position_z`=193.168,`orientation`=2.02316 WHERE `guid`=120129 AND `id`=26335;
--   UPDATE `creature` SET `position_x`=4885.58,`position_y`=-4547.83,`position_z`=348.476,`orientation`=2.8164 WHERE `guid`=120130 AND `id`=26260;
--   UPDATE `creature` SET `position_x`=4984.98,`position_y`=-4692.77,`position_z`=219.491,`orientation`=1.81893 WHERE `guid`=120217 AND `id`=26514;
--   UPDATE `creature` SET `position_x`=4320.26,`position_y`=-4984.36,`position_z`=20.3781,`orientation`=5.65561 WHERE `guid`=120461 AND `id`=26886;
--   UPDATE `creature` SET `position_x`=3984.07,`position_y`=-3163.71,`position_z`=276.35,`orientation`=1.47157 WHERE `guid`=120664 AND `id`=27468;
--   UPDATE `creature` SET `position_x`=3994.03,`position_y`=-3167.91,`position_z`=278.208,`orientation`=5.75591 WHERE `guid`=120665 AND `id`=27484;
--   UPDATE `creature` SET `position_x`=6963.97,`position_y`=44.2659,`position_z`=819.131,`orientation`=1.80541 WHERE `guid`=75234 AND `id`=29751;
--   UPDATE `creature` SET `position_x`=7858.14,`position_y`=-750.136,`position_z`=1179.76,`orientation`=6.18401 WHERE `guid`=88396 AND `id`=30247;
--   UPDATE `creature` SET `position_x`=6917.26,`position_y`=-1541.88,`position_z`=833.81,`orientation`=1.11376 WHERE `guid`=98434 AND `id`=29975;
--   UPDATE `creature` SET `position_x`=7871.84,`position_y`=-788.764,`position_z`=1188.87,`orientation`=6.2443 WHERE `guid`=98464 AND `id`=30472;
--   UPDATE `creature` SET `position_x`=8368.86,`position_y`=2728.89,`position_z`=655.314,`orientation`=1.19812 WHERE `guid`=87900 AND `id`=30074;
--   UPDATE `creature` SET `position_x`=5258.22,`position_y`=4538.57,`position_z`=-85.7862,`orientation`=5.12896 WHERE `guid`=96998 AND `id`=28138;
--   UPDATE `creature` SET `position_x`=5249.52,`position_y`=4513.93,`position_z`=-85.3357,`orientation`=0.129775 WHERE `guid`=97050 AND `id`=28082;
--   UPDATE `creature` SET `position_x`=5627.88,`position_y`=4602.55,`position_z`=-137.187,`orientation`=1.78206 WHERE `guid`=97122 AND `id`=29006;
--   UPDATE `creature` SET `position_x`=6162.66,`position_y`=5100.9,`position_z`=-97.3822,`orientation`=0.582422 WHERE `guid`=99738 AND `id`=28114;
--   UPDATE `creature` SET `position_x`=5506.19,`position_y`=4748.05,`position_z`=-194.433,`orientation`=2.32449 WHERE `guid`=119715 AND `id`=28746;
--   UPDATE `creature` SET `position_x`=5585.69,`position_y`=5204.71,`position_z`=-135.432,`orientation`=0.118323 WHERE `guid`=121090 AND `id`=27987;
--   UPDATE `creature` SET `position_x`=-5859.46,`position_y`=4678.92,`position_z`=-512.795,`orientation`=-1.18422 WHERE `guid`=206321 AND `id`=40227;
--   INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
--   (111310,31737,571,210,4537,1,1,0,0,0,0,7288.88,1524.03,319.444,4.38078,300,0,0,0,25200,0,0,0,0,0,0,0,'',0,0),
--   (111312,31737,571,210,4537,1,1,0,0,0,0,7297.74,1507.7,319.563,2.53073,300,0,0,0,25200,0,0,0,0,0,0,0,'',0,0),
--   (206261,39226,0,5144,5006,1,1,0,0,31592,0,-5199.06,3964.2,-13.8967,2.82743,300,0,0,0,44679,0,0,0,0,0,0,0,'',0,0),
--   (206341,40918,0,5144,4970,1,1,0,0,32195,0,-6777.13,4171.31,-479.752,4.99164,60,0,0,0,446790,0,0,0,0,0,0,0,'',0,0);
--   INSERT INTO `creature_addon` (`guid`,`path_id`,`mount`,`MountCreatureID`,`StandState`,`AnimTier`,`VisFlags`,`SheathState`,`PvPFlags`,`emote`,`aiAnimKit`,`movementAnimKit`,`meleeAnimKit`,`visibilityDistanceType`,`auras`) VALUES
--   (206261,0,0,0,8,0,0,1,0,0,0,0,0,0,NULL);

UPDATE `creature` SET `position_x`=-2906.68,`position_y`=4027.85,`position_z`=0.395868,`orientation`=3.62679 WHERE `guid`=50233 AND `id`=24885;  -- Exorcist Sullivan (24885), 50.0 yd
UPDATE `creature` SET `position_x`=-2995.95,`position_y`=3983.49,`position_z`=3.18814,`orientation`=6.23082 WHERE `guid`=74818 AND `id`=18390;  -- Ros'eleth (18390), 21.7 yd
UPDATE `creature` SET `position_x`=-2574.84,`position_y`=4975.56,`position_z`=11.0632,`orientation`=2.94961 WHERE `guid`=76154 AND `id`=18714;  -- Scout Neftis (18714), 16.9 yd
UPDATE `creature` SET `position_x`=-2301.67,`position_y`=4898.39,`position_z`=1.22768,`orientation`=0.314159 WHERE `guid`=76159 AND `id`=18715;  -- Private Weeks (18715), 20.4 yd
UPDATE `creature` SET `position_x`=-2538.08,`position_y`=3660.54,`position_z`=1.94131,`orientation`=1.46608 WHERE `guid`=77973 AND `id`=18566;  -- Shadowstalker Kaide (18566), 27.5 yd
UPDATE `creature` SET `position_x`=-3190.64,`position_y`=6015.76,`position_z`=0.07636,`orientation`=3.33358 WHERE `guid`=78274 AND `id`=18273;  -- Kilrath (18273), 15.3 yd
UPDATE `creature` SET `position_x`=-2588.25,`position_y`=3319.51,`position_z`=0.58673,`orientation`=5.49392 WHERE `guid`=78276 AND `id`=21006;  -- Lieutenant Meridian (21006), 19.3 yd
UPDATE `creature` SET `position_x`=-2525.9,`position_y`=3665.57,`position_z`=1.66699,`orientation`=2.63545 WHERE `guid`=78403 AND `id`=21007;  -- Sergeant Chawni (21007), 13.1 yd
UPDATE `creature` SET `position_x`=-3742.69,`position_y`=4398.95,`position_z`=-0.295119,`orientation`=4.43314 WHERE `guid`=81000 AND `id`=22462;  -- Vindicator Haylen (22462), 20.6 yd
UPDATE `creature` SET `position_x`=-1409.14,`position_y`=5046.16,`position_z`=-9.00264,`orientation`=5.22907 WHERE `guid`=99581 AND `id`=25580;  -- Old Man Barlo (25580), 75.0 yd
UPDATE `creature` SET `position_x`=-4044.39,`position_y`=1609.47,`position_z`=94.7241,`orientation`=4.01426 WHERE `guid`=73928 AND `id`=21293;  -- Borak, Son of Oronok (21293), 19.0 yd
UPDATE `creature` SET `position_x`=-3023.1,`position_y`=793.828,`position_z`=-8.82144,`orientation`=2.63891 WHERE `guid`=126542 AND `id`=23452;  -- Commander Arcus (23452), 57.9 yd
UPDATE `creature` SET `position_x`=3606.15,`position_y`=6834.94,`position_z`=137.818,`orientation`=2.14742 WHERE `guid`=60253 AND `id`=22215;  -- Treebole (22215), 48.5 yd
UPDATE `creature` SET `position_x`=2959.73,`position_y`=5465.37,`position_z`=144.332,`orientation`=5.12665 WHERE `guid`=60901 AND `id`=22127;  -- Wildlord Antelarion (22127), 57.6 yd
UPDATE `creature` SET `position_x`=1775.73,`position_y`=5856.32,`position_z`=160.563,`orientation`=2.49582 WHERE `guid`=76079 AND `id`=21690;  -- R-3D0 (21690), 7.1 yd
UPDATE `creature` SET `position_x`=2785.99,`position_y`=5835.66,`position_z`=36.052,`orientation`=1.84254 WHERE `guid`=124632 AND `id`=22941;  -- Mog'dorg the Wizened (22941), 8.7 yd
UPDATE `creature` SET `position_x`=2518.76,`position_y`=7353.99,`position_z`=380.734,`orientation`=2.91244 WHERE `guid`=124654 AND `id`=23335;  -- Skyguard Khatie (23335), 36.9 yd
UPDATE `creature` SET `position_x`=2315.89,`position_y`=7304.39,`position_z`=366.92,`orientation`=5.01167 WHERE `guid`=124668 AND `id`=23316;  -- Torkus (23316), 7.8 yd
UPDATE `creature` SET `position_x`=2313.07,`position_y`=7276.83,`position_z`=365.462,`orientation`=1.14747 WHERE `guid`=124674 AND `id`=23253;  -- Kronk (23253), 7.8 yd
UPDATE `creature` SET `position_x`=2441.4,`position_y`=6027.56,`position_z`=154.114,`orientation`=5.17346 WHERE `guid`=125597 AND `id`=23280;  -- Agadai (23280), 80.9 yd
UPDATE `creature` SET `position_x`=2772.7,`position_y`=5838.93,`position_z`=-1.20216,`orientation`=3.26979 WHERE `guid`=125600 AND `id`=22995;  -- Chort (22995), 35.3 yd
UPDATE `creature` SET `position_x`=4264.46,`position_y`=2180.23,`position_z`=136.235,`orientation`=5.24025 WHERE `guid`=57485 AND `id`=20450;  -- Flesh Handler Viridius (20450), 20.2 yd
UPDATE `creature` SET `position_x`=4521.53,`position_y`=3435.61,`position_z`=166.805,`orientation`=4.08407 WHERE `guid`=76831 AND `id`=22293;  -- Inactive Fel Reaver (22293), 9.1 yd
UPDATE `creature` SET `position_x`=3911.36,`position_y`=4023.48,`position_z`=189.869,`orientation`=2.46091 WHERE `guid`=78026 AND `id`=20920;  -- Magister Theledorn (20920), 23.0 yd
UPDATE `creature` SET `position_x`=4036.13,`position_y`=3547.31,`position_z`=121.384,`orientation`=5.81718 WHERE `guid`=80896 AND `id`=20780;  -- Kaylaan (20780), 15.6 yd
UPDATE `creature` SET `position_x`=4107.49,`position_y`=2930.08,`position_z`=354.534,`orientation`=6.23883 WHERE `guid`=126533 AND `id`=22899;  -- Protectorate Advisor Rahim (22899), 18.4 yd
UPDATE `creature` SET `position_x`=5211.84,`position_y`=-1302.07,`position_z`=242.486,`orientation`=5.35816 WHERE `guid`=62372 AND `id`=28518;  -- Stefan Vadu (28518), 12.8 yd
UPDATE `creature` SET `position_x`=5792.44,`position_y`=-3018.4,`position_z`=286.389,`orientation`=2.02458 WHERE `guid`=86278 AND `id`=30007;  -- Gurgthock (30007), 6.8 yd
UPDATE `creature` SET `position_x`=6970.98,`position_y`=-4094.88,`position_z`=479.446,`orientation`=3.75246 WHERE `guid`=86681 AND `id`=33025;  -- Ha'wana (33025), 8.2 yd
UPDATE `creature` SET `position_x`=5736.14,`position_y`=-3571.37,`position_z`=386.995,`orientation`=6.16101 WHERE `guid`=99344 AND `id`=28479;  -- Witch Doctor Khufu (28479), 58.5 yd
UPDATE `creature` SET `position_x`=5270.21,`position_y`=-3509.2,`position_z`=291.694,`orientation`=2.38219 WHERE `guid`=99737 AND `id`=28284;  -- Specialist Cogwheel (28284), 7.6 yd
UPDATE `creature` SET `position_x`=5255.31,`position_y`=-3530.25,`position_z`=291.693,`orientation`=0 WHERE `guid`=117170 AND `id`=28125;  -- Dr. Rogers (28125), 23.9 yd
UPDATE `creature` SET `position_x`=5191.09,`position_y`=-2199.45,`position_z`=239.482,`orientation`=4.4855 WHERE `guid`=117210 AND `id`=29137;  -- Sergeant Riannah (29137), 15.0 yd
UPDATE `creature` SET `position_x`=5539.37,`position_y`=-1862.18,`position_z`=238.352,`orientation`=4.01426 WHERE `guid`=118539 AND `id`=29689;  -- Crusader MacKellar (29689), 12.7 yd
UPDATE `creature` SET `position_x`=5740.27,`position_y`=-3595.09,`position_z`=387.024,`orientation`=0.820305 WHERE `guid`=118921 AND `id`=28527;  -- Chronicler To'kini (28527), 23.5 yd
UPDATE `creature` SET `position_x`=5790.66,`position_y`=-3566.08,`position_z`=386.605,`orientation`=3.14159 WHERE `guid`=118943 AND `id`=28480;  -- Element-Tamer Dagoda (28480), 12.0 yd
UPDATE `creature` SET `position_x`=3826.5,`position_y`=-1985.58,`position_z`=208.376,`orientation`=4.27606 WHERE `guid`=96084 AND `id`=26604;  -- Mack Fearsen (26604), 6.9 yd
UPDATE `creature` SET `position_x`=4556.24,`position_y`=-4247.67,`position_z`=170.603,`orientation`=3.38594 WHERE `guid`=117116 AND `id`=26361;  -- Torthen Deepdig (26361), 10.3 yd
UPDATE `creature` SET `position_x`=4551.79,`position_y`=-4250.05,`position_z`=170.576,`orientation`=2.3911 WHERE `guid`=117138 AND `id`=26226;  -- Brugar Stoneshear (26226), 13.3 yd
UPDATE `creature` SET `position_x`=4340.57,`position_y`=-5297.95,`position_z`=1.66265,`orientation`=2.63545 WHERE `guid`=117143 AND `id`=26420;  -- Gavrock (26420), 11.3 yd
UPDATE `creature` SET `position_x`=4606.54,`position_y`=-4229.83,`position_z`=178.65,`orientation`=1.5726 WHERE `guid`=117144 AND `id`=26212;  -- Captain Gryan Stoutmantle (26212), 8.6 yd
UPDATE `creature` SET `position_x`=4698.39,`position_y`=-4004.78,`position_z`=212.355,`orientation`=0.506145 WHERE `guid`=117145 AND `id`=26932;  -- Petrov (26932), 15.0 yd
UPDATE `creature` SET `position_x`=3850.49,`position_y`=-1960.48,`position_z`=208.511,`orientation`=2.14675 WHERE `guid`=117211 AND `id`=26424;  -- Samir (26424), 7.1 yd
UPDATE `creature` SET `position_x`=3215.31,`position_y`=-2498.81,`position_z`=52.8002,`orientation`=5.3058 WHERE `guid`=119612 AND `id`=27120;  -- Raider Captain Kronn (27120), 12.3 yd
UPDATE `creature` SET `position_x`=3882.44,`position_y`=-1936.45,`position_z`=209.169,`orientation`=2.09439 WHERE `guid`=119625 AND `id`=26519;  -- Prigmon (26519), 11.0 yd
UPDATE `creature` SET `position_x`=4243.96,`position_y`=-2024.81,`position_z`=238.249,`orientation`=1.41171 WHERE `guid`=119644 AND `id`=26543;  -- Image of Drakuru (26543), 11.7 yd
UPDATE `creature` SET `position_x`=4326.23,`position_y`=-4983.15,`position_z`=20.4613,`orientation`=4.01426 WHERE `guid`=119645 AND `id`=26884;  -- Harkor (26884), 8.9 yd
UPDATE `creature` SET `position_x`=4469.31,`position_y`=-2261.68,`position_z`=181.176,`orientation`=6.05629 WHERE `guid`=119654 AND `id`=27497;  -- Captured Trapper (27497), 11.0 yd
UPDATE `creature` SET `position_x`=4706.64,`position_y`=-4453.71,`position_z`=195.048,`orientation`=1.97222 WHERE `guid`=120129 AND `id`=26335;  -- Fallen Earthen Warrior (26335), 12.7 yd
UPDATE `creature` SET `position_x`=4894.46,`position_y`=-4563.21,`position_z`=347.919,`orientation`=2.89725 WHERE `guid`=120130 AND `id`=26260;  -- Kurun (26260), 17.8 yd
UPDATE `creature` SET `position_x`=4982.14,`position_y`=-4653.88,`position_z`=219.574,`orientation`=4.17134 WHERE `guid`=120217 AND `id`=26514;  -- Surveyor Orlond (26514), 39.0 yd
UPDATE `creature` SET `position_x`=4322.28,`position_y`=-4990.64,`position_z`=20.4613,`orientation`=1.36136 WHERE `guid`=120461 AND `id`=26886;  -- Kraz (26886), 6.6 yd
UPDATE `creature` SET `position_x`=3981.2,`position_y`=-3177.18,`position_z`=279.076,`orientation`=1.37881 WHERE `guid`=120664 AND `id`=27468;  -- Sergeant Hartsman (27468), 14.0 yd
UPDATE `creature` SET `position_x`=4023.82,`position_y`=-3235.14,`position_z`=280.683,`orientation`=5.55015 WHERE `guid`=120665 AND `id`=27484;  -- Rheanna (27484), 73.6 yd
UPDATE `creature` SET `position_x`=6951.33,`position_y`=46.3564,`position_z`=795.069,`orientation`=2.67035 WHERE `guid`=75234 AND `id`=29751;  -- Drom Frostgrip (29751), 27.3 yd
UPDATE `creature` SET `position_x`=7870.46,`position_y`=-749.844,`position_z`=1176.75,`orientation`=5.41052 WHERE `guid`=88396 AND `id`=30247;  -- Bloodguard Lorga (30247), 12.7 yd
UPDATE `creature` SET `position_x`=6922.17,`position_y`=-1534.57,`position_z`=836.157,`orientation`=4.27606 WHERE `guid`=98434 AND `id`=29975;  -- Lok'lira the Crone (29975), 9.1 yd
UPDATE `creature` SET `position_x`=7850.46,`position_y`=-787.967,`position_z`=1183.5,`orientation`=3.1765 WHERE `guid`=98464 AND `id`=30472;  -- Olut Alegut (30472), 22.1 yd
UPDATE `creature` SET `position_x`=8380.47,`position_y`=2717.56,`position_z`=655.178,`orientation`=1.19812 WHERE `guid`=87900 AND `id`=30074;  -- The Leaper (30074), 16.2 yd
UPDATE `creature` SET `position_x`=5263.77,`position_y`=4511.33,`position_z`=-84.7118,`orientation`=2.49582 WHERE `guid`=96998 AND `id`=28138;  -- Elder Harkek (28138), 27.8 yd
UPDATE `creature` SET `position_x`=5280.53,`position_y`=4533.72,`position_z`=-80.4395,`orientation`=3.80482 WHERE `guid`=97050 AND `id`=28082;  -- High-Shaman Rakjak (28082), 37.1 yd
UPDATE `creature` SET `position_x`=5648.67,`position_y`=4605.62,`position_z`=-132.056,`orientation`=3.00197 WHERE `guid`=97122 AND `id`=29006;  -- Oracle Soo-nee (29006), 21.6 yd
UPDATE `creature` SET `position_x`=6165,`position_y`=5092.98,`position_z`=-97.2936,`orientation`=0.750492 WHERE `guid`=99738 AND `id`=28114;  -- Mistcaller Soo-gan (28114), 8.3 yd
UPDATE `creature` SET `position_x`=5500.68,`position_y`=4753.16,`position_z`=-194.396,`orientation`=3.89208 WHERE `guid`=119715 AND `id`=28746;  -- Pilot Vic (28746), 7.5 yd
UPDATE `creature` SET `position_x`=5584.02,`position_y`=5200.42,`position_z`=-129.298,`orientation`=0.593412 WHERE `guid`=121090 AND `id`=27987;  -- Monte Muzzleshot (27987), 7.7 yd
UPDATE `creature` SET `position_x`=-5861.78,`position_y`=4685.24,`position_z`=-513.093,`orientation`=0.628318 WHERE `guid`=206321 AND `id`=40227;  -- Felice (40227), 6.7 yd

DELETE FROM `creature_addon` WHERE `guid` IN (111310,111312,206261,206341);
DELETE FROM `creature` WHERE `guid` IN (111310,111312,206261,206341) AND `id` IN (31737,39226,40918);
