-- To-do 158: a new warrior got the button "Attack" (spell 88163) on action bar slots 0 and 72. In the 5.4.8 client that button
-- does not light up while attacking and does not stop the attack when pressed again; "Auto Attack" (6603) does both.
-- 88163 is the Cataclysm 4.3.4 start button (ref_cpp has it on slot 72 next to Strike 88161); both 5.4.8 references give 6603.
-- Source: ref_sf (SkyFire 5.4.8) and ref_alex playercreateinfo_action class 1: button 0 = 6603 (ref_sf also button 72 = 6603);
--         own client test 12-10 (note on the item): 88163 does not blink or toggle, 6603 from the spellbook does.
-- Rollback:
--   UPDATE playercreateinfo_action SET action=88163 WHERE class=1 AND button IN (0,72) AND action=6603 AND type=0;
UPDATE playercreateinfo_action SET action=6603 WHERE class=1 AND button IN (0,72) AND action=88163 AND type=0;
