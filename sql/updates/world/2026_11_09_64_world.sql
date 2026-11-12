-- Ongo'longo 42815: his two shackles ride him as vehicle passengers, and he throws them off when he breaks free
-- Sourced: Ongo'longo's VehicleId 924 (both TDBs and mop), whose two seats sit on his elbows (VehicleSeat 8134 attachment 4,
-- left elbow; 8135 attachment 3, right elbow; 5.4.8 DBC); TCPP's sniffed template addons give both shackles 46598 Ride Vehicle
-- Hardcoded, and no TDB spawns the shackles (passengers are not sniffed as spawns); mop's static shackle spawns (192304/192305)
-- stand exactly on his right and left elbow; Wowhead: "the right/left shackle holding Ongo'Longo ... It cannot be targeted".
-- Ours: which shackle takes which seat (the right shackle stands on his right in the old spawns), the accessory rows (minion,
-- summoned until removed), the spellclick that seats them limited to the two shackles (the Twinkles pattern), and throwing
-- them off when he breaks free (they go 2 s later with him).
-- Reconcile 2026-11-11 (l1/R1111-reconcile): the SmartAI rewrite at the end of this file (13 rows for 42815) is left out, our closed fix
-- 294 keeps its 19 rows (to-do 394/397, see 2026_11_09_61). The shackles are still seated on him (vehicle accessory, spellclick,
-- conditions) and their two static spawns go. Cause of the cut: upstream row 12 (remove 46598 on the break, the shackles drop off) lived
-- in the rewritten script; with our script the shackles stay on his elbows while he walks to the Handler and go when he despawns.
-- Rollback: DELETE FROM vehicle_template_accessory WHERE entry=42815; DELETE FROM npc_spellclick_spells WHERE npc_entry=42815;
--   DELETE FROM conditions WHERE SourceTypeOrReferenceId=18 AND SourceGroup=42815; spawns 192304/192305 from the pre-L1 dump of creature.
DELETE FROM `creature` WHERE `guid` IN (192304,192305) AND `id` IN (42816,42817);

DELETE FROM `vehicle_template_accessory` WHERE `entry`=42815;
INSERT INTO `vehicle_template_accessory` (`entry`,`accessory_entry`,`seat_id`,`minion`,`description`,`summontype`,`summontimer`) VALUES
(42815,42817,0,1,'Ongo''longo - Ongolongo''s Left Shackle (left elbow)',8,0),
(42815,42816,1,1,'Ongo''longo - Ongolongo''s Right Shackle (right elbow)',8,0);

DELETE FROM `npc_spellclick_spells` WHERE `npc_entry`=42815;
INSERT INTO `npc_spellclick_spells` (`npc_entry`,`spell_id`,`cast_flags`,`user_type`) VALUES
(42815,46598,1,0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=18 AND `SourceGroup`=42815;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(18,42815,46598,0,0,31,0,3,42816,0,0,0,0,'','Ongo''longo: only his right shackle may ride him'),
(18,42815,46598,0,1,31,0,3,42817,0,0,0,0,'','Ongo''longo: only his left shackle may ride him');
