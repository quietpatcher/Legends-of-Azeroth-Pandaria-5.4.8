-- To-do 446 (quest 27099 No Escape, Fenris Keep) and 436 follow-up. Causes found in code and DB:
--  (a) spell_area 83979 (Bond of the Val'kyr = Agatha) was one row, start quest 27097 status 74 (rewarded|incomplete|complete) and
--      end quest 27099 status 11 (incomplete|complete|NONE). Status NONE of 27099 fits, so after abandoning No Escape the row
--      fits again: the next area change re-casts the bond and Agatha is back ("does not always despawn"). The row also needs 27097
--      rewarded/incomplete/complete, so a character that has 27099 without the chain (GM add, .quest add) has Agatha removed by the
--      next area update (dev test 11-11: summoned Agatha reset and removed, no scene).
--      Now two rows (any fitting row keeps the aura): while Rise, Forsaken runs (27097 incomplete/complete, 27099 not taken) and
--      while No Escape runs (27099 incomplete/complete, whatever 27097 is). 27099 is auto-accept, so no gap in between.
--  (b) Only area trigger 6230 (south door of the main hall) had the script at_silverpine_no_escape. The north door is trigger 6231,
--      same box (1.98 x 6.92 x 8 yd) 37 yd away at 983.0 707.6 77.9; zone coordinates 65.44 24.59 of the report are 978.2 701.5.
-- Source: AreaTrigger.dbc 5.4.8 (6230 at 984.373 670.884 77.87, 6231 at 983.007 707.627 77.915, same box); WorldMapArea.dbc 5.4.8
--   Silverpine (130) for the zone coordinates; SpellMgr.cpp SpellArea::IsFitToRequirements / SpellInfo::CheckLocation (any row fits);
--   Wowhead comments on quest 27099 ("once you get to the door of the big room at the top ... the cinematic takes over", "leave the
--   room and re-enter, they appear again", abandoning: the Val'kyr is gone until the quest is taken again from Sylvanas).
-- Rollback:
--   DELETE FROM `areatrigger_scripts` WHERE `entry` = 6231;
--   DELETE FROM `spell_area` WHERE `spell` = 83979;
--   INSERT INTO `spell_area` (`spell`, `area`, `quest_start`, `quest_end`, `aura_spell`, `racemask`, `gender`, `autocast`, `quest_start_status`, `quest_end_status`) VALUES
--   (83979, 130, 27097, 27099, 0, 0, 2, 1, 74, 11);

DELETE FROM `spell_area` WHERE `spell` = 83979;
INSERT INTO `spell_area` (`spell`, `area`, `quest_start`, `quest_end`, `aura_spell`, `racemask`, `gender`, `autocast`, `quest_start_status`, `quest_end_status`) VALUES
(83979, 130, 27097, 27099, 0, 0, 2, 1, 10, 1),
(83979, 130, 27099, 0, 0, 0, 2, 1, 10, 0);

DELETE FROM `areatrigger_scripts` WHERE `entry` = 6231;
INSERT INTO `areatrigger_scripts` (`entry`, `ScriptName`) VALUES
(6231, 'at_silverpine_no_escape');
