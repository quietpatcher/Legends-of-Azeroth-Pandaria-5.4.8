-- SI7-BLIZZ 29727 SI:7 Report: Take No Prisoners: Amber's perch within Sniper Shot range of the hozen camp.
-- (1) The derived perch of 2026_11_03_03 (103620 Sniper Rifle Teleport -> 1230,-520 z326.9) lies 95-126 yd from the four stage-A guards and 148 yd from the Vanguard orcs, while Sniper Shot 103621 has SpellRange 135 "Tower 100" (100 yd, 5.4.8 SpellMisc/SpellRange.dbc). The perch moves to 1270,-480 z345.5 (map height grid 0870_29_32.map: 345.0), 37 yd south-west of Sully's spot at the village entrance (1306.4,-475.3 z344.7): guards 39-80 yd, barrels 44-59 yd, Vanguard 86-98 yd, all inside 100 yd.
-- (2) (tried and dropped 5-11 07:20) UNIT_FLAG_IMMUNE_TO_NPC on the vehicle: Unit::IsValidAttackTarget of this core forbids a unit with IMMUNE_TO_NPC to attack creatures, so Sniper Shot would not fire at the guards.
-- Source: 5.4.8 Spell.dbc/SpellMisc.dbc/SpellRange.dbc (103621 range index 135 = 100 yd), creature spawns around Grookin Hill (56582/56264/59296), dev test 5-11-2026 07:08, maps/0870_29_32.map height data, video https://www.youtube.com/watch?v=HLplKibsp_A (Amber shoots the guards from a vantage point next to the village).
-- DERIVED (no sniff): the exact perch; retail has Amber on the mountain above the village, which needs the retail camp layout that we do not have (all guard/barrel/orc positions are derived too).
-- Rollback: UPDATE `spell_target_position` SET `target_position_x` = 1230, `target_position_y` = -520, `target_position_z` = 326.86, `target_orientation` = 5.5 WHERE `id` = 103620 AND `effIndex` = 0;

UPDATE `spell_target_position` SET `target_position_x` = 1270, `target_position_y` = -480, `target_position_z` = 345.5, `target_orientation` = 1.05 WHERE `id` = 103620 AND `effIndex` = 0;

