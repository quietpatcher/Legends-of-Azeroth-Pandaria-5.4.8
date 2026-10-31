-- To-do 457 (Andorhal Fore-Commanders clustered; proposal Gemini item457_20261030_2220 reviewed against the DB):
-- 22 of 23 Alliance Fore-Commander (44450) spawns wander (MovementType 1, radius 3) while the Horde counterpart Deathguard War-Captain (44449)
-- has all 15 spawns stationary (MovementType 0). Set the wandering ones stationary. The proposed deletion of 4 "phantom" spawns is NOT applied (no source).
-- Source: our world DB, creature id 44449 (15x MovementType 0, wander 0) as the faction twin; no sniff of the movement.
-- Rollback: UPDATE creature SET wander_distance=3, MovementType=1 WHERE id=44450 AND guid IN (311820,311856,311857,311877,311888,311897,311898,311899,311900,311901,311905,311906,311926,311947,311949,311978,311985,311995,311999,312005,312009,312011);
UPDATE creature SET wander_distance=0, MovementType=0 WHERE id=44450 AND MovementType=1;
