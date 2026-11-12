-- Sharpbeak's ride (The Hinterlands, Doran Steelwing 43157, menu 11716, see 2026_11_09_63): the gossip option did nothing.
-- Doran cast 83486 (force cast of 80657 on the player) as a normal creature cast; on this core that creature-to-player cast fails
-- silently (the same class of failure as the innkeeper bind, see NPCHandler.cpp SendBindPoint). The player casting 80657 himself
-- works (tested 11-11-2026: Sharpbeak 43161 appears, the player boards and flies to the top of Jintha'Alor), so the option now
-- makes the invoker cast 80657 directly (SMART_ACTION_INVOKER_CAST, triggered).
-- Source: TDB 442/1210 chain (menu 11716 -> 83486 -> 80657), test server 11-11-2026.
-- Rollback: UPDATE `smart_scripts` SET `action_type`=11, `action_param1`=83486, `action_param2`=0,
--   `comment`='Doran Steelwing - On Gossip Option 0 Selected - Cast ''Sharpbeak Taxi - Camp to Jintha''''Alor - Force Cast''' WHERE `entryorguid`=43157 AND `source_type`=0 AND `id`=0;
UPDATE `smart_scripts` SET `action_type`=85, `action_param1`=80657, `action_param2`=2,
  `comment`='Doran Steelwing - On Gossip Option 0 Selected - Invoker Cast Sharpbeak Taxi - Camp to Jintha''Alor (triggered)'
WHERE `entryorguid`=43157 AND `source_type`=0 AND `id`=0;
