-- 399 (Tirisfal block, Hinterlands): the 29 Deathstalker Invaders (43541) around Quel'Danil Lodge stand frozen.
-- Source: Wowhead MoP Classic npc=43541 (38 pins, spread over the lodge area, not on our fixed spawn points: sniffed while moving; objective of quest 27625 'In Defense of Quel'Danil'
--   = invaders attacking the lodge); wowpedia. ref_cpp has NO spawn for 43541 (no waypoints to copy), so no path exists in any source: random roaming instead of frozen.
-- Rollback: UPDATE creature SET MovementType=0, wander_distance=0 WHERE id=43541;  (values before: MovementType 0, wander_distance 0 for all 29, see dump)
UPDATE creature SET MovementType=1, wander_distance=8 WHERE id=43541 AND map=0;
