-- To-do 460 (Unstable Mana Crystal Crate: animation/sound without clicking, repeats every 15s; proposal Gemini item460_20261030_2320 reviewed):
-- The 28 world spawns of Battered Crate Trap (181584, GAMEOBJECT_TYPE_TRAP radius 3, spell 29420, persistent) sit exactly on the crates (180600) and fire as proximity trap on every player. Our core only fires linked traps for goobers, not chests; ref_cpp has 0 spawns of 181584, ref_sf has 34.
-- Source: reviewed against core GameObject.cpp trap update + ref_cpp (0 spawns); no retail sniff of the crate, so the removal is a best-fit fix (changed), not a verified retail copy.
-- Rollback: re-insert the 28 gameobject rows (guid 26329-26356, id 181584); full row dump in state/rollback/460_gameobject_181584.sql.

DELETE FROM `gameobject` WHERE `id` = 181584;
