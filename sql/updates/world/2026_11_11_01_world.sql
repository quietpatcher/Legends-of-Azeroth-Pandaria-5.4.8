-- Innkeepers: "Make this inn your home" (and at Darnassus "I want to browse your goods", at Shattrath Floyd Pinkus' bind line,
-- elsewhere "What can I do at an inn?") only showed during Hallow's End.
-- The conditions below belonged to the old hourly "Trick or Treat" gossip option (event 12 Hallow's End active, player without
-- aura 24755 Tricked or Treated; menu 441 also area 1637). That option sits on OptionID 0 in the Cataclysm data, but in our
-- gossip_menu_option the real bind/browse/info lines are OptionID 0, so outside Hallow's End the condition hid them: in
-- Stormwind, Ironforge, Orgrimmar, Darnassus, Shattrath, Warsong Hold and other inns a player could not set the hearthstone
-- (a menu with only "browse goods" left opens the vendor window directly). The trick or treat option itself is gone
-- (60af774c: removed from the game in 2011, candy buckets took over), so these conditions have nothing left to guard.
-- Menus: 342 345 349 441 1290 1291 1293 1294 1296 1297 1581 7288 7290 7468 7481 7856 7949 9114 (OptionID 0, 37 rows).
-- Source: gossip_menu_option rows of these menus (bind/browse/info at OptionID 0); retail: every innkeeper offers the bind
--   line all year (wowhead.com/npc=6740 Innkeeper Allison); ref_cpp keeps the conditions on its separate sniffed OptionID 0.
-- Rollback: restore the 37 rows from the pre-image (prod: bundle pre-image; dev: ~/backups/pre_2026_11_11_01_conditions.sql).
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=15 AND `SourceEntry`=0
  AND `SourceGroup` IN (342,345,349,441,1290,1291,1293,1294,1296,1297,1581,7288,7290,7468,7481,7856,7949,9114)
  AND ((`ConditionTypeOrReference`=1 AND `ConditionValue1`=24755) OR (`ConditionTypeOrReference`=12 AND `ConditionValue1`=12)
       OR (`SourceGroup`=441 AND `ConditionTypeOrReference`=23 AND `ConditionValue1`=1637));
