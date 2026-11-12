-- Heroic dungeons (player path): The Burning Crusade heroics no longer need a heroic key,
-- and the Black Morass no longer needs the Old Hillsbrad attunement quest.
-- Cause: access_requirement still carried the pre-4.2 keys (30622/30623/30633/30634/30635/30637) and quest 10285,
--        so a player without the removed key items was refused at the portal and locked in the dungeon finder.
-- Source: Wowpedia "Instance attunement" (Patch 4.2.0: removed the keyring and the Heroic mode keys, all Heroic
--         Burning Crusade dungeons can be entered without a key); Wowpedia "Heroic mode"; Warcraft Wiki
--         "Black Morass (instance)" (Patch 4.2.0: attunement removed).
-- Rollback:
--   UPDATE access_requirement SET item=30637, item2=30622 WHERE mapId IN (540,542,543) AND difficulty='DUNGEON_HEROIC';
--   UPDATE access_requirement SET item=30623 WHERE mapId IN (545,546,547) AND difficulty='DUNGEON_HEROIC';
--   UPDATE access_requirement SET item=30634 WHERE mapId IN (552,553,554) AND difficulty='DUNGEON_HEROIC';
--   UPDATE access_requirement SET item=30633 WHERE mapId IN (555,556,557,558) AND difficulty='DUNGEON_HEROIC';
--   UPDATE access_requirement SET item=30635 WHERE mapId=560 AND difficulty='DUNGEON_HEROIC';
--   UPDATE access_requirement SET quest_done_A=10285, quest_done_H=10285 WHERE mapId=269;
UPDATE access_requirement SET item=0, item2=0
 WHERE mapId IN (540,542,543,545,546,547,552,553,554,555,556,557,558,560) AND difficulty='DUNGEON_HEROIC'
   AND item IN (30623,30633,30634,30635,30637);
UPDATE access_requirement SET quest_done_A=0, quest_done_H=0
 WHERE mapId=269 AND quest_done_A=10285 AND quest_done_H=10285;
