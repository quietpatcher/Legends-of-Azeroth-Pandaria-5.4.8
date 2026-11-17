-- Quest givers of the review of 15-11-2026 (Mulgore to Nagrand, 20 zones): 55 quest giver spawns that lie 6 to 60 yards from the
--   position the sniff-based reference has for the same creature (Howling Fjord 15, Borean Tundra 10, Dragonblight 8, Ghostlands 4,
--   Hellfire Peninsula 4, Nagrand 4, Cape of Stranglethorn 3, Zangarmarsh 3, Blasted Lands 2, Bloodmyst Isle 1, Deepholm 1).
-- What a player sees today: the quest givers stand at a position from an older database instead of at the spot where quests
--   are given and handed in according to the sniffs (up to 60 yards away, for example Ortrosh 29 yards, Carter Tiffens 51 yards,
--   Thomas Kolichio 56 yards, Scout Tungok 55 yards).
-- Cause: positions come from an older database; the sniff-based reference has the observed position.
-- Checked per row: the reference has a spawn of the same id on the same map at exactly the new coordinates (MovementType 0 and
--   phase mask 1 in both, no phase id or group, same zone); no other spawn of that id lies within 3 yards of a new position;
--   no creature_formations, creature_addon waypoint path, waypoint_data, game_event_creature, pool_creature or linked_respawn row
--   refers to the changed spawns; none of the spawns has a ScriptName; no smart_script of the ids holds a waypoint, move-to-position
--   or teleport action. Amish Wildhammer (18931) only summons a creature on itself. Rows that differ more than 3 yards in height
--   are included only when the reference spawn is in the same area and at most 60 yards away. Area and zone columns are left
--   unchanged (Apprentice Shatharia: area 3433 here, 3505 in the reference). Terrath the Steady (42466): of the three reference
--   spawns, the one at (2136.55, 1015.07) is identical to the other spawn of ours, the one in area 5296 lies far away, so
--   guid 228583 follows the third one in the same area.
-- Left out on purpose: Beltrand McSorf and Watcher Moonleaf (5.2 and 5.4 yards, marginal); Bloodmage Drazial (different area, 8.5
--   yards of height); "Dead-Eye" Drederick McGumm, Gorsik the Tumultuous, Donny, Longrunner Pembe, Old Icefin, Steel Gate Chief
--   Archaeologist, Wartook Iceborn, Mage-Commander Evenstar and Saurfang the Younger (height difference and more than 60 yards,
--   or 60.7 yards); Lunk-tusk, Scout Valory and Surveyor Hansen (height difference and a different area); Thassarian and the Ember
--   Clutch Ancients (position uncertain); Spraggle Frock in Un'Goro Crater (our spawn walks a path, the reference spawn stands
--   still and has no path to copy).
-- Change: position_x, position_y, position_z and orientation of the 55 spawns are set to the reference values.
-- Source: Cataclysm Preservation sniff database (comparison), 15-11-2026.
-- Rollback (the values before this update):
--   UPDATE `creature` SET `position_x`=-1503.28,`position_y`=-12517.3,`position_z`=4.87378,`orientation`=4.21211 WHERE `guid`=68564 AND `id`=17674;
--   UPDATE `creature` SET `position_x`=6765.75,`position_y`=-7613.08,`position_z`=128.318,`orientation`=5.14041 WHERE `guid`=46028 AND `id`=23761;
--   UPDATE `creature` SET `position_x`=7199.63,`position_y`=-6313.65,`position_z`=33.1654,`orientation`=4.31731 WHERE `guid`=55931 AND `id`=16293;
--   UPDATE `creature` SET `position_x`=6775.83,`position_y`=-7585.22,`position_z`=127.581,`orientation`=4.75948 WHERE `guid`=126501 AND `id`=23559;
--   UPDATE `creature` SET `position_x`=6756.98,`position_y`=-7617.64,`position_z`=127.425,`orientation`=5.30143 WHERE `guid`=126519 AND `id`=23724;
--   UPDATE `creature` SET `position_x`=-11225.1,`position_y`=-3483.99,`position_z`=8.55129,`orientation`=4.72984 WHERE `guid`=163056 AND `id`=42298;
--   UPDATE `creature` SET `position_x`=-12718.9,`position_y`=-2919.74,`position_z`=5.83879,`orientation`=2.42809 WHERE `guid`=163618 AND `id`=42352;
--   UPDATE `creature` SET `position_x`=-14959.8,`position_y`=355.248,`position_z`=12.766,`orientation`=0.215016 WHERE `guid`=184035 AND `id`=2545;
--   UPDATE `creature` SET `position_x`=-14341.5,`position_y`=576.759,`position_z`=-6.05692,`orientation`=0.443736 WHERE `guid`=184054 AND `id`=48797;
--   UPDATE `creature` SET `position_x`=-13634.3,`position_y`=-61.6979,`position_z`=35.3639,`orientation`=4.90299 WHERE `guid`=300885 AND `id`=44100;
--   UPDATE `creature` SET `position_x`=1977.72,`position_y`=1363.34,`position_z`=177.339,`orientation`=0.927007 WHERE `guid`=228583 AND `id`=42466;
--   UPDATE `creature` SET `position_x`=-595.788,`position_y`=2890.9,`position_z`=59.204,`orientation`=1.29154 WHERE `guid`=59247 AND `id`=21209;
--   UPDATE `creature` SET `position_x`=517.928,`position_y`=3883.64,`position_z`=190.685,`orientation`=0.111718 WHERE `guid`=59754 AND `id`=17123;
--   UPDATE `creature` SET `position_x`=-538.044,`position_y`=4725.33,`position_z`=38.8247,`orientation`=1.06628 WHERE `guid`=60159 AND `id`=20678;
--   UPDATE `creature` SET `position_x`=-331.439,`position_y`=1020.91,`position_z`=54.2352,`orientation`=5.50787 WHERE `guid`=78042 AND `id`=18931;
--   UPDATE `creature` SET `position_x`=-214.89,`position_y`=8519.09,`position_z`=23.2445,`orientation`=5.78046 WHERE `guid`=63481 AND `id`=17923;
--   UPDATE `creature` SET `position_x`=318.238,`position_y`=6040.3,`position_z`=133.127,`orientation`=3.04632 WHERE `guid`=76851 AND `id`=18007;
--   UPDATE `creature` SET `position_x`=203.721,`position_y`=8511.7,`position_z`=23.9947,`orientation`=1.60236 WHERE `guid`=126532 AND `id`=22823;
--   UPDATE `creature` SET `position_x`=2884.42,`position_y`=6375.29,`position_z`=95.8144,`orientation`=0.244518 WHERE `guid`=78912 AND `id`=25437;
--   UPDATE `creature` SET `position_x`=4508.32,`position_y`=5686.07,`position_z`=81.7046,`orientation`=5.84222 WHERE `guid`=96112 AND `id`=25374;
--   UPDATE `creature` SET `position_x`=3130.01,`position_y`=4897.29,`position_z`=2.11234,`orientation`=4.06304 WHERE `guid`=97736 AND `id`=26169;
--   UPDATE `creature` SET `position_x`=3140.67,`position_y`=4890.99,`position_z`=2.94448,`orientation`=4.05362 WHERE `guid`=97737 AND `id`=26213;
--   UPDATE `creature` SET `position_x`=4175.93,`position_y`=4337.86,`position_z`=36.1662,`orientation`=3.21707 WHERE `guid`=116569 AND `id`=25705;
--   UPDATE `creature` SET `position_x`=3103.79,`position_y`=3844.48,`position_z`=22.2006,`orientation`=5.8945 WHERE `guid`=116580 AND `id`=26187;
--   UPDATE `creature` SET `position_x`=3519.05,`position_y`=4863.66,`position_z`=15.7624,`orientation`=4.42769 WHERE `guid`=117080 AND `id`=25984;
--   UPDATE `creature` SET `position_x`=3114.35,`position_y`=3845.29,`position_z`=22.7363,`orientation`=2.05156 WHERE `guid`=117307 AND `id`=26186;
--   UPDATE `creature` SET `position_x`=4144.28,`position_y`=3513.42,`position_z`=108.926,`orientation`=4.16848 WHERE `guid`=118480 AND `id`=25516;
--   UPDATE `creature` SET `position_x`=2866.19,`position_y`=5536.86,`position_z`=57.9337,`orientation`=4.43113 WHERE `guid`=120030 AND `id`=25440;
--   UPDATE `creature` SET `position_x`=656.029,`position_y`=-5050.94,`position_z`=2.62958,`orientation`=3.71567 WHERE `guid`=95040 AND `id`=23546;
--   UPDATE `creature` SET `position_x`=1960.98,`position_y`=-6145.47,`position_z`=25.1269,`orientation`=5.30452 WHERE `guid`=95502 AND `id`=26960;
--   UPDATE `creature` SET `position_x`=1878.5,`position_y`=-6214.25,`position_z`=35.3416,`orientation`=2.11386 WHERE `guid`=95519 AND `id`=26964;
--   UPDATE `creature` SET `position_x`=1875.37,`position_y`=-6132.34,`position_z`=23.5455,`orientation`=3.39485 WHERE `guid`=95525 AND `id`=26953;
--   UPDATE `creature` SET `position_x`=1551.89,`position_y`=-5702.86,`position_z`=250.875,`orientation`=2.3885 WHERE `guid`=96073 AND `id`=24027;
--   UPDATE `creature` SET `position_x`=-111.803,`position_y`=-3557.77,`position_z`=3.51896,`orientation`=2.51282 WHERE `guid`=116719 AND `id`=24537;
--   UPDATE `creature` SET `position_x`=1670.33,`position_y`=-6509.1,`position_z`=13.4781,`orientation`=2.29687 WHERE `guid`=116889 AND `id`=24037;
--   UPDATE `creature` SET `position_x`=2693.78,`position_y`=-4313.18,`position_z`=290.777,`orientation`=3.54398 WHERE `guid`=116947 AND `id`=24135;
--   UPDATE `creature` SET `position_x`=2673.61,`position_y`=-4313.9,`position_z`=290.96,`orientation`=5.19185 WHERE `guid`=116948 AND `id`=24234;
--   UPDATE `creature` SET `position_x`=1145.74,`position_y`=-4998,`position_z`=32.257,`orientation`=2.97862 WHERE `guid`=117238 AND `id`=24111;
--   UPDATE `creature` SET `position_x`=-135.174,`position_y`=-3572.07,`position_z`=3.25181,`orientation`=4.1413 WHERE `guid`=117247 AND `id`=24541;
--   UPDATE `creature` SET `position_x`=-134.642,`position_y`=-3554.11,`position_z`=2.31542,`orientation`=0.336045 WHERE `guid`=117252 AND `id`=24525;
--   UPDATE `creature` SET `position_x`=1767.55,`position_y`=-2833.06,`position_z`=4.21196,`orientation`=5.16935 WHERE `guid`=117315 AND `id`=23833;
--   UPDATE `creature` SET `position_x`=2196.42,`position_y`=-5105.28,`position_z`=236.626,`orientation`=1.0589 WHERE `guid`=117441 AND `id`=24117;
--   UPDATE `creature` SET `position_x`=2644.7,`position_y`=-4352.97,`position_z`=277.332,`orientation`=2.50439 WHERE `guid`=118498 AND `id`=24256;
--   UPDATE `creature` SET `position_x`=3867.06,`position_y`=1591.48,`position_z`=89.7238,`orientation`=3.35769 WHERE `guid`=117552 AND `id`=26652;
--   UPDATE `creature` SET `position_x`=4031.63,`position_y`=2385.51,`position_z`=155.123,`orientation`=4.78398 WHERE `guid`=117553 AND `id`=26733;
--   UPDATE `creature` SET `position_x`=3681.83,`position_y`=2154.76,`position_z`=35.0177,`orientation`=0.1914 WHERE `guid`=117615 AND `id`=26653;
--   UPDATE `creature` SET `position_x`=4700.28,`position_y`=541.03,`position_z`=120.792,`orientation`=3.84648 WHERE `guid`=117949 AND `id`=26647;
--   UPDATE `creature` SET `position_x`=2710.48,`position_y`=952.314,`position_z`=0.1343,`orientation`=5.2353 WHERE `guid`=120216 AND `id`=26245;
--   UPDATE `creature` SET `position_x`=4359.1,`position_y`=986.017,`position_z`=92.1073,`orientation`=2.08828 WHERE `guid`=120585 AND `id`=26979;
--   UPDATE `creature` SET `position_x`=3841.68,`position_y`=-1408.3,`position_z`=144.467,`orientation`=2.4432 WHERE `guid`=120669 AND `id`=27157;
--   UPDATE `creature` SET `position_x`=4514.34,`position_y`=-5.6714,`position_z`=72.4322,`orientation`=3.59564 WHERE `guid`=121088 AND `id`=27844;
--   UPDATE `creature` SET `position_x`=-2671.09,`position_y`=7210.86,`position_z`=23.7294,`orientation`=1.2904 WHERE `guid`=54436 AND `id`=24866;
--   UPDATE `creature` SET `position_x`=-2056.29,`position_y`=7441.62,`position_z`=0.843891,`orientation`=2.09855 WHERE `guid`=75954 AND `id`=19844;
--   UPDATE `creature` SET `position_x`=-2059.68,`position_y`=8613.24,`position_z`=21.553,`orientation`=4.7079 WHERE `guid`=99569 AND `id`=22836;
--   UPDATE `creature` SET `position_x`=-1278.12,`position_y`=9145.24,`position_z`=215.647,`orientation`=1.13283 WHERE `guid`=125589 AND `id`=22981;

UPDATE `creature` SET `position_x`=-1507.09,`position_y`=-12525.4,`position_z`=4.62696,`orientation`=4.24377 WHERE `guid`=68564 AND `id`=17674;  -- Prince Toreth (17674), 9.0 yd
UPDATE `creature` SET `position_x`=6750.4,`position_y`=-7626.49,`position_z`=126.564,`orientation`=0.126456 WHERE `guid`=46028 AND `id`=23761;  -- Prigmon (23761), 20.5 yd
UPDATE `creature` SET `position_x`=7203.48,`position_y`=-6320.68,`position_z`=33.5638,`orientation`=1.3439 WHERE `guid`=55931 AND `id`=16293;  -- Apprentice Shatharia (16293), 8.0 yd
UPDATE `creature` SET `position_x`=6774.26,`position_y`=-7604.58,`position_z`=128.62,`orientation`=5.35 WHERE `guid`=126501 AND `id`=23559;  -- Budd Nedreck (23559), 19.5 yd
UPDATE `creature` SET `position_x`=6757.14,`position_y`=-7631.21,`position_z`=126.866,`orientation`=5.23704 WHERE `guid`=126519 AND `id`=23724;  -- Samir (23724), 13.6 yd
UPDATE `creature` SET `position_x`=-11226.1,`position_y`=-3473.4,`position_z`=9.45138,`orientation`=2.34991 WHERE `guid`=163056 AND `id`=42298;  -- Kasim Sharim (42298), 10.7 yd
UPDATE `creature` SET `position_x`=-12689.9,`position_y`=-2906.84,`position_z`=2.05465,`orientation`=4.69349 WHERE `guid`=163618 AND `id`=42352;  -- Cenarion Observer Shayana (42352), 32.0 yd
UPDATE `creature` SET `position_x`=-14978.7,`position_y`=349.448,`position_z`=13.1613,`orientation`=3.553 WHERE `guid`=184035 AND `id`=2545;  -- "Pretty Boy" Duncan (2545), 19.8 yd
UPDATE `creature` SET `position_x`=-14342.3,`position_y`=541.516,`position_z`=-6.05692,`orientation`=2.6634 WHERE `guid`=184054 AND `id`=48797;  -- Gim'hila (48797), 35.3 yd
UPDATE `creature` SET `position_x`=-13632.8,`position_y`=-55.0567,`position_z`=35.3639,`orientation`=4.59023 WHERE `guid`=300885 AND `id`=44100;  -- Goris (44100), 6.8 yd
UPDATE `creature` SET `position_x`=1962.55,`position_y`=1332.75,`position_z`=175.695,`orientation`=1.25619 WHERE `guid`=228583 AND `id`=42466;  -- Terrath the Steady (42466), 34.2 yd
UPDATE `creature` SET `position_x`=-595.426,`position_y`=2899.24,`position_z`=59.2054,`orientation`=2.37375 WHERE `guid`=59247 AND `id`=21209;  -- Dumphry (21209), 8.3 yd
UPDATE `creature` SET `position_x`=504.592,`position_y`=3882.13,`position_z`=192.156,`orientation`=5.79449 WHERE `guid`=59754 AND `id`=17123;  -- Earthcaller Ryga (17123), 13.5 yd
UPDATE `creature` SET `position_x`=-541.787,`position_y`=4734.32,`position_z`=38.7961,`orientation`=1.46608 WHERE `guid`=60159 AND `id`=20678;  -- Akoru the Firecaller (20678), 9.7 yd
UPDATE `creature` SET `position_x`=-323.81,`position_y`=1027.61,`position_z`=54.2399,`orientation`=6.14356 WHERE `guid`=78042 AND `id`=18931;  -- Amish Wildhammer (18931), 10.2 yd
UPDATE `creature` SET `position_x`=-205.36,`position_y`=8516.55,`position_z`=22.8028,`orientation`=3.34133 WHERE `guid`=63481 AND `id`=17923;  -- Fahssn (17923), 9.9 yd
UPDATE `creature` SET `position_x`=301.947,`position_y`=6025.05,`position_z`=131.693,`orientation`=2.14675 WHERE `guid`=76851 AND `id`=18007;  -- Ruam (18007), 22.4 yd
UPDATE `creature` SET `position_x`=203.588,`position_y`=8550.11,`position_z`=22.3256,`orientation`=4.47675 WHERE `guid`=126532 AND `id`=22823;  -- Hch'uu (22823), 38.4 yd
UPDATE `creature` SET `position_x`=2874.85,`position_y`=6375.61,`position_z`=95.0773,`orientation`=3.10723 WHERE `guid`=78912 AND `id`=25437;  -- Shadowstalker Ickoris (25437), 9.6 yd
UPDATE `creature` SET `position_x`=4514.34,`position_y`=5714.3,`position_z`=81.658,`orientation`=4.31096 WHERE `guid`=96112 AND `id`=25374;  -- Ortrosh (25374), 28.9 yd
UPDATE `creature` SET `position_x`=3124.74,`position_y`=4893.01,`position_z`=1.92765,`orientation`=4.50295 WHERE `guid`=97736 AND `id`=26169;  -- Ataika (26169), 6.8 yd
UPDATE `creature` SET `position_x`=3140.63,`position_y`=4884.43,`position_z`=3.13888,`orientation`=4.04916 WHERE `guid`=97737 AND `id`=26213;  -- Utaik (26213), 6.6 yd
UPDATE `creature` SET `position_x`=4183.23,`position_y`=4335.51,`position_z`=36.4576,`orientation`=1.60537 WHERE `guid`=116569 AND `id`=25705;  -- Bixie Wrenchshanker (25705), 7.7 yd
UPDATE `creature` SET `position_x`=3113.86,`position_y`=3843.32,`position_z`=22.7575,`orientation`=5.74213 WHERE `guid`=116580 AND `id`=26187;  -- Corporal Venn (26187), 10.2 yd
UPDATE `creature` SET `position_x`=3521.55,`position_y`=4876.76,`position_z`=15.5655,`orientation`=0.0665141 WHERE `guid`=117080 AND `id`=25984;  -- Crashed Recon Pilot (25984), 13.3 yd
UPDATE `creature` SET `position_x`=3114.17,`position_y`=3834.13,`position_z`=22.8447,`orientation`=5.75959 WHERE `guid`=117307 AND `id`=26186;  -- Private Casey (26186), 11.2 yd
UPDATE `creature` SET `position_x`=4131.38,`position_y`=3522.5,`position_z`=109.094,`orientation`=3.03687 WHERE `guid`=118480 AND `id`=25516;  -- Snow Tracker Grumm (25516), 15.8 yd
UPDATE `creature` SET `position_x`=2904.37,`position_y`=5497.64,`position_z`=53.6851,`orientation`=3.16112 WHERE `guid`=120030 AND `id`=25440;  -- Scout Tungok (25440), 54.9 yd
UPDATE `creature` SET `position_x`=654.667,`position_y`=-5057.84,`position_z`=1.79658,`orientation`=5.62547 WHERE `guid`=95040 AND `id`=23546;  -- Vice Admiral Keller (23546), 7.1 yd
UPDATE `creature` SET `position_x`=1955.86,`position_y`=-6196.06,`position_z`=24.0925,`orientation`=2.28638 WHERE `guid`=95502 AND `id`=26960;  -- Carter Tiffens (26960), 50.9 yd
UPDATE `creature` SET `position_x`=1875.43,`position_y`=-6198.47,`position_z`=23.8265,`orientation`=0.226893 WHERE `guid`=95519 AND `id`=26964;  -- Alexandra McQueen (26964), 19.8 yd
UPDATE `creature` SET `position_x`=1927.98,`position_y`=-6150.21,`position_z`=23.0406,`orientation`=5.07891 WHERE `guid`=95525 AND `id`=26953;  -- Thomas Kolichio (26953), 55.6 yd
UPDATE `creature` SET `position_x`=1541.28,`position_y`=-5697.27,`position_z`=250.059,`orientation`=1.65806 WHERE `guid`=96073 AND `id`=24027;  -- Sergeant Gorth (24027), 12.0 yd
UPDATE `creature` SET `position_x`=-117.444,`position_y`=-3550.41,`position_z`=3.81863,`orientation`=0.122173 WHERE `guid`=116719 AND `id`=24537;  -- Handsome Terry (24537), 9.3 yd
UPDATE `creature` SET `position_x`=1647.06,`position_y`=-6516.57,`position_z`=20.0708,`orientation`=1.0472 WHERE `guid`=116889 AND `id`=24037;  -- Captain Harker (24037), 25.3 yd
UPDATE `creature` SET `position_x`=2686.72,`position_y`=-4309.49,`position_z`=290.529,`orientation`=4.31096 WHERE `guid`=116947 AND `id`=24135;  -- Greatmother Ankha (24135), 8.0 yd
UPDATE `creature` SET `position_x`=2696.28,`position_y`=-4325.72,`position_z`=289.99,`orientation`=3.87463 WHERE `guid`=116948 AND `id`=24234;  -- Junat the Wanderer (24234), 25.6 yd
UPDATE `creature` SET `position_x`=1138.35,`position_y`=-4988.17,`position_z`=32.4988,`orientation`=2.87671 WHERE `guid`=117238 AND `id`=24111;  -- Defender Mordun (24111), 12.3 yd
UPDATE `creature` SET `position_x`=-127.645,`position_y`=-3593.84,`position_z`=3.0425,`orientation`=5.02655 WHERE `guid`=117247 AND `id`=24541;  -- Taruk (24541), 23.0 yd
UPDATE `creature` SET `position_x`=-133.511,`position_y`=-3547.52,`position_z`=2.92667,`orientation`=1.58825 WHERE `guid`=117252 AND `id`=24525;  -- Zeh'gehn (24525), 6.7 yd
UPDATE `creature` SET `position_x`=1808.19,`position_y`=-2863.75,`position_z`=3.72625,`orientation`=1.27409 WHERE `guid`=117315 AND `id`=23833;  -- Explorer Jaren (23833), 50.9 yd
UPDATE `creature` SET `position_x`=2195.11,`position_y`=-5115.1,`position_z`=236.583,`orientation`=5.75959 WHERE `guid`=117441 AND `id`=24117;  -- Lurielle (24117), 9.9 yd
UPDATE `creature` SET `position_x`=2633.84,`position_y`=-4355.65,`position_z`=276.804,`orientation`=1.81514 WHERE `guid`=118498 AND `id`=24256;  -- Wind Tamer Kagan (24256), 11.2 yd
UPDATE `creature` SET `position_x`=3819.54,`position_y`=1618.86,`position_z`=89.8234,`orientation`=0.256114 WHERE `guid`=117552 AND `id`=26652;  -- Greatmother Icemist (26652), 54.8 yd
UPDATE `creature` SET `position_x`=4014.54,`position_y`=2359.66,`position_z`=126.748,`orientation`=4.24115 WHERE `guid`=117553 AND `id`=26733;  -- Banthok Icemist (26733), 42.0 yd
UPDATE `creature` SET `position_x`=3675.86,`position_y`=2158.72,`position_z`=35.2196,`orientation`=0.069813 WHERE `guid`=117615 AND `id`=26653;  -- Kilix the Unraveler (26653), 7.2 yd
UPDATE `creature` SET `position_x`=4691.45,`position_y`=571.628,`position_z`=119.784,`orientation`=5.63741 WHERE `guid`=117949 AND `id`=26647;  -- Narf (26647), 31.9 yd
UPDATE `creature` SET `position_x`=2728.97,`position_y`=935.776,`position_z`=0.223537,`orientation`=3.50811 WHERE `guid`=120216 AND `id`=26245;  -- Tua'kea (26245), 24.8 yd
UPDATE `creature` SET `position_x`=4322.3,`position_y`=1009.02,`position_z`=95.6906,`orientation`=2.56563 WHERE `guid`=120585 AND `id`=26979;  -- Kontokanis (26979), 43.5 yd
UPDATE `creature` SET `position_x`=3841.22,`position_y`=-1402.29,`position_z`=144.478,`orientation`=2.47837 WHERE `guid`=120669 AND `id`=27157;  -- Duke August Foehammer (27157), 6.0 yd
UPDATE `creature` SET `position_x`=4530.59,`position_y`=-3.87463,`position_z`=72.5144,`orientation`=1.6057 WHERE `guid`=121088 AND `id`=27844;  -- Legion Commander Tyralion (27844), 16.3 yd
UPDATE `creature` SET `position_x`=-2673.13,`position_y`=7204.22,`position_z`=25.7696,`orientation`=1.53589 WHERE `guid`=54436 AND `id`=24866;  -- Lakoor (24866), 7.2 yd
UPDATE `creature` SET `position_x`=-2052.09,`position_y`=7432.76,`position_z`=-24.9648,`orientation`=1.91986 WHERE `guid`=75954 AND `id`=19844;  -- Nitrin the Learned (19844), 27.6 yd
UPDATE `creature` SET `position_x`=-2080.21,`position_y`=8556.21,`position_z`=22.7558,`orientation`=0.754017 WHERE `guid`=99569 AND `id`=22836;  -- Jheel (22836), 60.6 yd
UPDATE `creature` SET `position_x`=-1274.44,`position_y`=9158.71,`position_z`=216.662,`orientation`=1.23781 WHERE `guid`=125589 AND `id`=22981;  -- Watcher Elaira (22981), 14.0 yd
