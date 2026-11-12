-- To-do 489 (quest 8487 Corrupted Soil, Eversong Woods): the green glow (Tainted Soil Trap 181583, a separate spawn on every
-- Tainted Soil Sample 180921) stayed after the sample was looted, so a looted pile still looked available.
-- The new script go_tainted_soil (zone_eversong_woods.cpp) despawns the trap next to a looted sample for the sample's respawn
-- delay; the trap respawn time is aligned with the sample (120 s instead of 900 s) so both come back together.
-- Source: an internal proposal (reviewed); gameobject_template 180921 data7 = linked trap 181583; this core has
-- no linked-trap summoning (GameObject.cpp only triggers goober traps), so the trap is a static spawn.
-- Rollback: UPDATE gameobject_template SET ScriptName = '' WHERE entry = 180921; UPDATE gameobject SET spawntimesecs = 900 WHERE id = 181583;
UPDATE `gameobject_template` SET `ScriptName` = 'go_tainted_soil' WHERE `entry` = 180921;
UPDATE `gameobject` SET `spawntimesecs` = 120 WHERE `id` = 181583;
