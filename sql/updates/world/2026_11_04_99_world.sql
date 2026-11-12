-- l1-D: Endgame (quest 26706) flight to the gunship held back until it can be built on the real transport.
-- The port placed a static stand-in 'Orc Gunship' (gameobject 800100, type 5 GENERIC, display 8253 = the transport model of
-- Orc Gunship 203428) above Gilneas; the 5.4.8 client crashes (ACCESS_VIOLATION 0x14019D136) every time it comes into view
-- (4 of 4 flights on dev 4-11; with guid 4100001 removed at runtime the flight ran 3 minutes without a crash).
-- On retail the gunship is the moving transport 203428 (taxi path 2338). Until that version exists, Endgame stays as on the
-- live server: hippogryph 43747 offers no gossip (npcflag back to 0 as on live), no stand-in ship, no ropes.
-- Source: dev97 validation 4-11-2026 'Pakket D hertest dev97f' (bisect); ref_cpp/ref_sf gameobject_template 203428 type 15 display 8253.
-- Rollback: re-run 2026_11_04_78_world.sql (gameobject 800100 + guids 4100001-4100004) and
--   UPDATE `creature_template` SET `npcflag` = `npcflag` | 1 WHERE `entry` = 43747;
-- Re-runnable.
UPDATE `creature_template` SET `npcflag` = `npcflag` & ~1 WHERE `entry` = 43747;
DELETE FROM `gameobject` WHERE `guid` BETWEEN 4100001 AND 4100004;
DELETE FROM `gameobject_template` WHERE `entry` = 800100;
