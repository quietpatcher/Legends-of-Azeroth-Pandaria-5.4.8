-- To-do 453 (Stormstout Brewery, bots do not progress after Hoptallus; proposal Gemini item453_20261030_2127 reviewed against the source):
-- the two cellar sliding doors 211135 (guid 534679) and 211137 (guid 534681) are spawned closed (state 1) and no script ever opens them, so the way
-- from the Hoptallus hall to Stout Brew Alemental / Yan-Zhu is blocked. SkyFire (ref_sf, comparison material, not truth) has the same doors open (state 0),
-- as the sibling doors 211132/211133/211134 are in ours; no sniff available. Source order: DB2/GO data not checked for initial state.
-- Rollback: UPDATE `gameobject` SET `state`=1 WHERE `guid` IN (534679,534681);
UPDATE `gameobject` SET `state`=0 WHERE `guid` IN (534679,534681) AND `id` IN (211135,211137);
