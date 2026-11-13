-- To-do 158 (characters DB): existing warriors keep the old "Attack" button (88163) on their bars; replace it with Auto Attack
-- (6603), the 5.4.8 button (see the world update of the same item). Only the button itself changes, on the same slot.
-- Rollback (the pre-image of the touched rows is dumped by the bundle apply script before this runs):
-- Source: ref_sf (SkyFire 5.4.8) and ref_alex playercreateinfo_action class 1 button 0 = 6603; own client test 12-10 (88163 does not blink or toggle).
--   UPDATE character_action ca JOIN characters c ON c.guid=ca.guid SET ca.action=88163 WHERE c.class=1 AND ca.type=0 AND ca.action=6603 AND ca.button IN (0,72);
UPDATE character_action ca JOIN characters c ON c.guid=ca.guid SET ca.action=6603 WHERE c.class=1 AND ca.type=0 AND ca.action=88163;
