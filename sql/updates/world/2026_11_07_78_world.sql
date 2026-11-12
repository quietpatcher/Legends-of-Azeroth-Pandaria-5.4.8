-- Faldir's Cove: 18 Blackwater Deckhands stood on two spots, within 1.2 yd each and inside their 3 yard wander, and 2 on a third: one mob each, many times. No TDB spawns them.
-- Sourced: AzerothCore has one each at (-2101, -2047.5), (-2088.7, -2061.8) and (-2070.5, -1997.3); the copy nearest to those stays. The three other Deckhands below deck are not doubles and stay.
-- Leaves 6. No guid here is in a pool, event, formation, addon, linked respawn or per-spawn script.
-- Reconcile 2026-11-11 (l1/R1111-reconcile): guids 161255, 161264, 161253, 161257 and 161261 are taken out of the list. Our closed fix 275
-- (to-do 350, repeat check 350 expects 9 Deckhands, counted against the Wowhead map and on the live server) had already removed the stack and
-- kept other guids than upstream did, so on our data this list emptied two of the three spots completely (9 -> 4, not the 6 it meant to
-- leave). The remaining guids of the list do not exist with us any more; the statement is now a no-op and stays for the record.
-- Source of the kept state: fix 275 / Wowhead npc 2636. Rollback: none (nothing is deleted on our data).
DELETE FROM `creature` WHERE `id` = 2636 AND `guid` IN (161303,161332,161337,161339,161268,161280,161285,161287,161291,161340,161344,161346);
