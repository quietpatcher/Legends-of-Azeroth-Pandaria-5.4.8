-- Stratholme (map 329) review of 18-11-2026: Ysida's Trigger is missing and the Bastion Door and Hoard Door stand open.
-- What a player sees today: when the Baron Rivendare run (Dead Man's Plea, 45 minute timer) is completed, Ysida Harmon
--   never appears, because the instance script summons her at the creature "Ysida's Trigger" (16100) and that creature does
--   not exist in our world. The Bastion Door (175967) and the Hoard Door (175968) in the Scarlet Bastion are open from the
--   start, so the Scarlet Key (lock 1634) is bypassed.
-- Cause: the trigger spawn (reference guid 54416) was never added; both door spawns have state 0 (open), both references
--   have state 1 (closed) at the same positions. instance_stratholme.cpp does not touch these doors (no reference to them),
--   so only the spawn state decides.
-- Checked: instance_stratholme.cpp (TYPE_BARON_RUN DONE) summons NPC_YSIDA (16031) at the position of the creature with
--   entry NPC_YSIDA_TRIGGER (16100); both references spawn 16100 at 4042.35, -3335.88, 115.144 (ref_cpp guid 54416, ref_sf
--   guid 54416). Door positions are identical in world, ref_cpp and ref_sf (guid 187788 / 187793, 20916 / 20917).
--   Warcraft Tavern / WoW Forever guides: the Scarlet Key opens the Bastion Door, the Hoard Door and the Hall of High Command.
--   Our whole map 329 uses spawn mask 2 (references: 1 / 2), so the trigger gets mask 2 like the rest of the map.
-- Not changed: The Unforgiven (320207) and Timmy the Cruel (320144) already exist as static spawns in our world (mask 2,
--   respawn 12 h); the references have no static row (script / normal-dungeon spawns), nothing is missing. Ysida's Cage
--   (181071) is not added: it exists only in ref_cpp and no script opens it, so it would stay closed.
-- Reserved guids: creature 5310501-5310509 (used 5310501).
-- Source: Cataclysm Preservation database (comparison, ref_cpp / ref_sf), 18-11-2026; Warcraft Tavern Stratholme guide (key).
-- Not changed: the Bastion Door and the Hoard Door stay open for now. Bot groups carry no Scarlet Key and clear this
--   dungeon; closing them needs a key or door handling in the bot route first.
-- Rollback (the values and rows before this update):
--   DELETE FROM `creature` WHERE `guid`=5310501 AND `id`=16100;


DELETE FROM `creature` WHERE `guid`=5310501;
INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseMask`,`phaseId`,`phaseGroup`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`spawntimesecs_max`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`npcflag2`,`unit_flags`,`unit_flags2`,`dynamicflags`,`ScriptName`,`walk_mode`,`VerifiedBuild`) VALUES
(5310501,16100,329,2017,5917,2,1,0,0,0,0,4042.35,-3335.88,115.144,1.48353,7200,0,0,0,4120,0,0,0,0,0,0,0,'',0,0);
