-- Quest givers and quest-related NPCs whose spawn lies 6 to 150 yards from the position the sniff-based references have
-- for the same creature (review of 15-11-2026, verified one by one): 27 spawns of 26 creature entries.
-- What a player sees today: the NPC stands at a position from an older database instead of at the spot where quests
--   are given and handed in according to the sniffs (for example Dentaria Silverglade 104 yards, Serendia Oakwhisper
--   150 yards, Houndmaster Jonathan 73 yards and one Mudsnout Gnoll 46 yards from the sniffed spot).
-- Cause: positions come from an older database; the sniff-based reference has the observed position.
-- Checked per row: the reference has a spawn of the same id on the same map at exactly the new coordinates (same zone
--   and area, MovementType 0 in both); no other spawn of that id lies within 3 yards of the new position; no
--   creature_formations, creature_addon waypoint path, waypoint_data, game_event_creature, pool_creature or
--   linked_respawn row refers to these spawns; template and spawn have no ScriptName and the entries are not used by
--   any core script; the smart_scripts of the entries that have any (Ley-Keeper Velania, Mudsnout Gnoll, Illiyana,
--   Kayneth Stillwind, Gaivan Shadewalker, Sentinel Shyela, Moon Priestess Maestra) hold only spell, flee and
--   combat-movement actions and no waypoint, move-to-position or position-target action.
-- Left out on purpose: Totem of Tikti (guid 55140, 11.8 yards): its quest script summons Stillpine Ancestor Tikti at
--   absolute coordinates next to the current totem position, so the summon would have to move with it. The marginal
--   cases (about 5 yards), the cases that also remove a path or MovementType 2 and the duplicate candidates are
--   handled separately.
-- Change: position_x, position_y, position_z and orientation of each spawn are set to the reference values.
-- Source: Cataclysm Preservation sniff database, checked 15-11-2026.
-- Rollback (the values before this update):
--   UPDATE `creature` SET `position_x`=-3886.22,`position_y`=-13422.4,`position_z`=76.0865,`orientation`=3.76991 WHERE `guid`=71997 AND `id`=17087;
--   UPDATE `creature` SET `position_x`=9153.78,`position_y`=-6279.31,`position_z`=22.942,`orientation`=4.18847 WHERE `guid`=55296 AND `id`=15401;
--   UPDATE `creature` SET `position_x`=9126.26,`position_y`=-5976.05,`position_z`=33.8036,`orientation`=2.53769 WHERE `guid`=74964 AND `id`=15920;
--   UPDATE `creature` SET `position_x`=-5366.93,`position_y`=-3014.87,`position_z`=319.565,`orientation`=0.139627 WHERE `guid`=180904 AND `id`=1681;
--   UPDATE `creature` SET `position_x`=-5359.15,`position_y`=-3020.87,`position_z`=319.565,`orientation`=4.06662 WHERE `guid`=180927 AND `id`=1105;
--   UPDATE `creature` SET `position_x`=-5281.8,`position_y`=-2950.63,`position_z`=330.091,`orientation`=4.03171 WHERE `guid`=180935 AND `id`=1139;
--   UPDATE `creature` SET `position_x`=-5275.26,`position_y`=-2971.02,`position_z`=338.737,`orientation`=1.72788 WHERE `guid`=180976 AND `id`=1777;
--   UPDATE `creature` SET `position_x`=-5366.19,`position_y`=-3021.68,`position_z`=319.565,`orientation`=2.46091 WHERE `guid`=181278 AND `id`=1153;
--   UPDATE `creature` SET `position_x`=7372.83,`position_y`=-257.545,`position_z`=7.45998,`orientation`=4.59022 WHERE `guid`=245551 AND `id`=32973;
--   UPDATE `creature` SET `position_x`=7372.44,`position_y`=-259.293,`position_z`=7.43216,`orientation`=1.39626 WHERE `guid`=245553 AND `id`=32971;
--   UPDATE `creature` SET `position_x`=7344.24,`position_y`=-220.542,`position_z`=9.50614,`orientation`=2.11185 WHERE `guid`=245705 AND `id`=32972;
--   UPDATE `creature` SET `position_x`=1242.1,`position_y`=-2989.36,`position_z`=92.1667,`orientation`=0.780294 WHERE `guid`=264664 AND `id`=7233;
--   UPDATE `creature` SET `position_x`=-1449.45,`position_y`=-3280.75,`position_z`=207.929,`orientation`=0.144389 WHERE `guid`=265073 AND `id`=34626;
--   UPDATE `creature` SET `position_x`=-987.303,`position_y`=-975.06,`position_z`=40.1645,`orientation`=0.993832 WHERE `guid`=177039 AND `id`=2372;
--   UPDATE `creature` SET `position_x`=-880.398,`position_y`=-954.404,`position_z`=31.3568,`orientation`=2.3668 WHERE `guid`=177044 AND `id`=2372;
--   UPDATE `creature` SET `position_x`=3031.33,`position_y`=-3300.17,`position_z`=155.13,`orientation`=0.509955 WHERE `guid`=237242 AND `id`=3901;
--   UPDATE `creature` SET `position_x`=2966.37,`position_y`=-3213.98,`position_z`=168.899,`orientation`=0.816333 WHERE `guid`=237243 AND `id`=3848;
--   UPDATE `creature` SET `position_x`=1769.51,`position_y`=-2661.68,`position_z`=108.638,`orientation`=6.25033 WHERE `guid`=238394 AND `id`=33777;
--   UPDATE `creature` SET `position_x`=2639.94,`position_y`=-1777.75,`position_z`=186.101,`orientation`=5.31758 WHERE `guid`=239363 AND `id`=34518;
--   UPDATE `creature` SET `position_x`=3816.11,`position_y`=150.176,`position_z`=7.56937,`orientation`=2.73175 WHERE `guid`=239804 AND `id`=33187;
--   UPDATE `creature` SET `position_x`=3305.15,`position_y`=127.831,`position_z`=16.0761,`orientation`=5.78968 WHERE `guid`=239867 AND `id`=33276;
--   UPDATE `creature` SET `position_x`=1935.53,`position_y`=-331.759,`position_z`=118.342,`orientation`=1.60475 WHERE `guid`=239890 AND `id`=40894;
--   UPDATE `creature` SET `position_x`=1235.61,`position_y`=449.819,`position_z`=80.2987,`orientation`=3.75759 WHERE `guid`=271229 AND `id`=40908;
--   UPDATE `creature` SET `position_x`=898.483,`position_y`=1.15278,`position_z`=93.17,`orientation`=0.506145 WHERE `guid`=271510 AND `id`=41023;
--   UPDATE `creature` SET `position_x`=152.306,`position_y`=71.1979,`position_z`=49.2988,`orientation`=3.17976 WHERE `guid`=271911 AND `id`=11821;
--   UPDATE `creature` SET `position_x`=110.363,`position_y`=-359.464,`position_z`=2.18895,`orientation`=1.81976 WHERE `guid`=272347 AND `id`=11858;
--   UPDATE `creature` SET `position_x`=1064.93,`position_y`=1954.46,`position_z`=126.458,`orientation`=4.92475 WHERE `guid`=273901 AND `id`=41638;

UPDATE `creature` SET `position_x`=-3855.21,`position_y`=-13403.1,`position_z`=77.1313,`orientation`=3.82876 WHERE `guid`=71997 AND `id`=17087;
UPDATE `creature` SET `position_x`=9155.78,`position_y`=-6294.84,`position_z`=21.1295,`orientation`=3.7001 WHERE `guid`=55296 AND `id`=15401;
UPDATE `creature` SET `position_x`=9123.11,`position_y`=-5959.77,`position_z`=32.6951,`orientation`=0.383692 WHERE `guid`=74964 AND `id`=15920;
UPDATE `creature` SET `position_x`=-5350.7,`position_y`=-3021.61,`position_z`=326.415,`orientation`=1.06465 WHERE `guid`=180904 AND `id`=1681;
UPDATE `creature` SET `position_x`=-5352.41,`position_y`=-3014.12,`position_z`=326.415,`orientation`=6.02139 WHERE `guid`=180927 AND `id`=1105;
UPDATE `creature` SET `position_x`=-5305.39,`position_y`=-2948.04,`position_z`=334.363,`orientation`=3.42085 WHERE `guid`=180935 AND `id`=1139;
UPDATE `creature` SET `position_x`=-5298.06,`position_y`=-2985.69,`position_z`=340.706,`orientation`=4.26087 WHERE `guid`=180976 AND `id`=1777;
UPDATE `creature` SET `position_x`=-5340.51,`position_y`=-3020.24,`position_z`=324.096,`orientation`=4.04215 WHERE `guid`=181278 AND `id`=1153;
UPDATE `creature` SET `position_x`=7446.51,`position_y`=-331.072,`position_z`=8.13822,`orientation`=4.50295 WHERE `guid`=245551 AND `id`=32973;
UPDATE `creature` SET `position_x`=7369.98,`position_y`=-229.738,`position_z`=8.53517,`orientation`=1.69297 WHERE `guid`=245553 AND `id`=32971;
UPDATE `creature` SET `position_x`=7444.11,`position_y`=-332.095,`position_z`=8.21732,`orientation`=4.83456 WHERE `guid`=245705 AND `id`=32972;
UPDATE `creature` SET `position_x`=1250.2,`position_y`=-2989.1,`position_z`=92.0373,`orientation`=0.0328501 WHERE `guid`=264664 AND `id`=7233;
UPDATE `creature` SET `position_x`=-1460.99,`position_y`=-3282.68,`position_z`=209.53,`orientation`=1.76278 WHERE `guid`=265073 AND `id`=34626;
UPDATE `creature` SET `position_x`=-995.756,`position_y`=-988.049,`position_z`=40.5961,`orientation`=1.25171 WHERE `guid`=177039 AND `id`=2372;
UPDATE `creature` SET `position_x`=-908.948,`position_y`=-918.906,`position_z`=32.5298,`orientation`=5.52044 WHERE `guid`=177044 AND `id`=2372;
UPDATE `creature` SET `position_x`=3024.12,`position_y`=-3320.48,`position_z`=152.145,`orientation`=0.196246 WHERE `guid`=237242 AND `id`=3901;
UPDATE `creature` SET `position_x`=2954.25,`position_y`=-3215.41,`position_z`=169.205,`orientation`=3.49066 WHERE `guid`=237243 AND `id`=3848;
UPDATE `creature` SET `position_x`=1761.43,`position_y`=-2661.42,`position_z`=108.596,`orientation`=6.172 WHERE `guid`=238394 AND `id`=33777;
UPDATE `creature` SET `position_x`=2627.06,`position_y`=-1759.89,`position_z`=180.574,`orientation`=2.11628 WHERE `guid`=239363 AND `id`=34518;
UPDATE `creature` SET `position_x`=3836.79,`position_y`=150.012,`position_z`=7.36536,`orientation`=0.355358 WHERE `guid`=239804 AND `id`=33187;
UPDATE `creature` SET `position_x`=3286.73,`position_y`=140.897,`position_z`=14.3846,`orientation`=1.78538 WHERE `guid`=239867 AND `id`=33276;
UPDATE `creature` SET `position_x`=1935.78,`position_y`=-338.904,`position_z`=118.356,`orientation`=4.74635 WHERE `guid`=239890 AND `id`=40894;
UPDATE `creature` SET `position_x`=1226.7,`position_y`=453.523,`position_z`=78.9801,`orientation`=2.48003 WHERE `guid`=271229 AND `id`=40908;
UPDATE `creature` SET `position_x`=895.636,`position_y`=6.69413,`position_z`=92.8991,`orientation`=5.12609 WHERE `guid`=271510 AND `id`=41023;
UPDATE `creature` SET `position_x`=158.443,`position_y`=71.4323,`position_z`=48.8667,`orientation`=0.038171 WHERE `guid`=271911 AND `id`=11821;
UPDATE `creature` SET `position_x`=105.733,`position_y`=-355.128,`position_z`=2.18895,`orientation`=2.38915 WHERE `guid`=272347 AND `id`=11858;
UPDATE `creature` SET `position_x`=1008.83,`position_y`=2000.91,`position_z`=126.343,`orientation`=0.732715 WHERE `guid`=273901 AND `id`=41638;
