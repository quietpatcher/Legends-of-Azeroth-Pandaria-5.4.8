-- Kezan, quest 14125 "447": the Gasbot is sent in from the Gasbot Control Panel, the sabotage shows.
--
-- The Gasbot Control Panel (game object 201736, spellcaster, spell 70253 447: AICast Gasbot Master) did nothing: no
--   script on 70253. Instead a Gasbot (37598) stood next to it as a clickable NPC (spell click 70252), in phase 1,
--   which a goblin on this quest (phase 32+64) does not see. Now 70253 summons the Gasbot for the player
--   (spell_kezan_gasbot_control_panel); it rolls into the headquarters and gives the credit when it blows up. The
--   parked Gasbot, its spell click and the click condition go.
-- The Defective Generator, Leaky Stove and Flammable Bed make the player cast their master spells (70223, 70239,
--   70251); those now cast the summon of the visual (70198 / 70241 / 70249, the destination conditions on the three
--   objects were already there) through spell_kezan_447_sabotage and spell_kezan_447_bed_precast (the cigar 70251
--   has a range of zero yards for its nearby-entry missile, so 70247 is not relied on; not tested in game). The three visual bunnies (37561,
--   37590, 37594) that stood there permanently in phase 1 go: they are summons.
-- Source: 5.4.8 client: gameobject 201736 type 22 spell 70253, goober spells 70197 / 70238 / 70245 (force cast of the
--   master spells), Spell.dbc names and effects of 70197-70262, SummonProperties 942 (flags 0x110, personal);
--   warcraft.wiki.gg/wiki/447 ("come back outside and use the control panel to send in the gasbot"); ref_cpp has no
--   permanent spawn of 37598, 37561, 37590 or 37594.
-- Rollback: the statements at the bottom of this file (commented out).

DELETE FROM `spell_script_names` WHERE `spell_id` IN (70253,70223,70239,70251);
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(70253,'spell_kezan_gasbot_control_panel'),
(70223,'spell_kezan_447_sabotage'),
(70239,'spell_kezan_447_sabotage'),
(70251,'spell_kezan_447_bed_precast');

DELETE FROM `npc_spellclick_spells` WHERE `npc_entry`=37598;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=18 AND `SourceGroup`=37598 AND `SourceEntry`=70252;
UPDATE `creature_template` SET `npcflag`=0 WHERE `entry`=37598;

-- the parked Gasbot (371504) and the permanent visual bunnies (371518 generator, 371506 stove, 371519 bed)
DELETE FROM `creature` WHERE `guid` IN (371504,371506,371518,371519) AND `id` IN (37598,37590,37561,37594);

-- Rollback:
-- DELETE FROM `spell_script_names` WHERE `spell_id` IN (70253,70223,70239,70251);
-- DELETE FROM `npc_spellclick_spells` WHERE `npc_entry`=37598;
-- INSERT INTO `npc_spellclick_spells` (`npc_entry`,`spell_id`,`cast_flags`,`user_type`) VALUES (37598,70252,1,0);
-- DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=18 AND `SourceGroup`=37598 AND `SourceEntry`=70252;
-- INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES (18,37598,70252,0,0,9,0,14125,0,0,0,0,0,'','Gasbot: can be let loose while 447 is in the quest log');
-- UPDATE `creature_template` SET `npcflag`=16777216 WHERE `entry`=37598;
-- INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawntimesecs_max`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `npcflag2`, `unit_flags`, `unit_flags2`, `dynamicflags`, `ScriptName`, `walk_mode`, `VerifiedBuild`) VALUES (371504,37598,648,4737,4765,0,1,0,0,0,0,-8424.35,1328.04,102.043,1.53589,300,0,0,0,1,0,0,0,0,0,0,0,'',0,0);
-- INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawntimesecs_max`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `npcflag2`, `unit_flags`, `unit_flags2`, `dynamicflags`, `ScriptName`, `walk_mode`, `VerifiedBuild`) VALUES (371506,37590,648,4737,4765,1,1,0,0,0,0,-8402.42,1371.37,105.072,1.46943,300,0,5,0,1,0,1,0,0,0,0,0,'',0,0);
-- INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawntimesecs_max`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `npcflag2`, `unit_flags`, `unit_flags2`, `dynamicflags`, `ScriptName`, `walk_mode`, `VerifiedBuild`) VALUES (371518,37561,648,4737,4765,1,1,0,0,0,0,-8423.65,1372.83,105.755,1.54326,300,0,5,0,1,0,1,0,0,0,0,0,'',0,0);
-- INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `phaseId`, `phaseGroup`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawntimesecs_max`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `npcflag2`, `unit_flags`, `unit_flags2`, `dynamicflags`, `ScriptName`, `walk_mode`, `VerifiedBuild`) VALUES (371519,37594,648,4737,4765,1,1,0,0,0,0,-8402.31,1363.6,117.031,2.82267,300,0,5,0,1,0,1,0,0,0,0,0,'',0,0);
