-- To-do 399: Deathstalker Invaders (43541) at Quel'Danil Lodge, The Hinterlands, stand at their posts again.
-- 2026_11_04_92 gave the 29 spawns a random wander of 8 yards after a player asked whether they should move. No source backs that:
-- the 5.4.8 reference world (ref_alex) has all 29 spawns idle (movement_type 0, wander_distance 0), and the retail walkthrough
-- videos of In Defense of Quel'Danil (27625) only show them being pulled from where they stand.
-- Source: ref_alex creature id 43541 (29 rows, movement_type 0, wander_distance 0); YouTube wdHqFTRJKzY and Sf83DeEzi7I (quest 27625).
-- Rollback: UPDATE `creature` SET `MovementType`=1, `wander_distance`=8 WHERE `id`=43541;
UPDATE `creature` SET `MovementType`=0, `wander_distance`=0 WHERE `id`=43541;
