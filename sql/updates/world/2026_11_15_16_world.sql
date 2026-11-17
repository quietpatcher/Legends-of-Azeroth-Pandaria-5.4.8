-- Mount Hyjal (map 1, zone 616): split the Sanctuary of Malorne and Nordune Ridge into the normal stage and the
--   Firelands Invasion stage (step 1 of the Malorne phasing plan).
-- Problem: a player at the Sanctuary of Malorne (area 5019) sees both Arch Druid Hamuul Runetotem (39858 and 52838),
--   and on Nordune Ridge (area 5781) every player sees the Charred Invaders (52853) and the ritual troops, because all
--   invasion spawns have phase id 0, phase group 0 and phase mask 1. Three Hamuul spawns stand at the Sanctuary: 284439
--   (39858, normal stage), 293611 (52838, hub stage) and 293624 (52932, the burned Hamuul of a later quest step).
-- Cause: the sniffs keep the normal stage in phase 194 and the invasion in five stages (425, 426, 431, 432, 433;
--   Phase.dbc puts exactly these five in phase group 609). Our world has phase 194 in every Hyjal area without a
--   condition and no rule at all for the invasion stages.
-- Change:
--   1. phase_area 616/426 (zone level) with two conditions (AND): level 85 or higher, and Aessina's Miracle (25372)
--      rewarded. This is the same mechanism as the Stormwind prelude stages 372 and 373 (phase_area plus conditions
--      type 26); a quest status change recalculates the phases at once (Player::SendQuestUpdate calls
--      UpdateAreaAndZonePhase).
--   2. Phase 194 gets two conditions in different else groups (OR): level below 85, or Aessina's Miracle not
--      rewarded. SourceEntry 0 attaches them to every phase_area row of phase 194 (ConditionMgr::addToPhases), all
--      of which are Hyjal areas. Players for whom the invasion stage is on lose phase 194, and the reverse.
--   3. The 116 invasion creature spawns and the two invasion gameobjects get phase group 609, so they stay visible in
--      each of the five invasion stages (a spawn with a phase group is loaded into every phase of the group,
--      Creature::Create and GameObject::Create). Players without phase 426 see none of them. A spawn may not have
--      both a phase id and a phase group (ObjectMgr creature load), so these keep phase id 0.
--   4. The eight Cata spawns at the Sanctuary (Hamuul 39858, Rayne Feathersong 40331, five Defenders of Malorne
--      40333, Nenduil Meadowshade 43551) get phase id 194, and Inoho Stronghide (43550, spawn 284438, spawn mask 0)
--      is switched on in phase 194. Players in the invasion stage then see the invasion twins instead (Inoho 53075,
--      Nenduil 53076, Rayne 52899, Hamuul 52838 and 293611) and exactly one Hamuul.
--   Not touched: Ranela Featherglen 293649 (54392; her phase 426 twin was deleted in the earlier twin update, so she
--   stays visible to everyone), the stage-specific split of 425/431/432/433 (later steps), the earlier Hyjal service
--   NPC twin deletions and the Limiah, Isara and Inoho deletions (different guids; none of them is referenced here).
--   Known limit: the core recalculates area phases on area change and quest status change, not on level up, so a
--   player who reaches level 85 inside Hyjal gets the invasion stage after the next area change or relog.
-- Source: the Cataclysm Preservation world database (built from sniffs): creature and gameobject PhaseId per spawn and
--   phase_area; Phase.dbc and PhaseGroup (group 609 = phases 425, 426, 431, 432, 433); Wowpedia "Firelands Invasion"
--   and "Sanctuary of Malorne" ("after completing Aessina's Miracle ... the shrine is rebuilt"); Wowhead quest 29195
--   (Charred Invaders on Nordune Ridge belong to the ritual). Checked 15-11-2026.
-- Rollback:
--   DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 26 AND `SourceGroup` IN (194,426) AND `Comment` LIKE 'Malorne:%';
--   DELETE FROM `phase_area` WHERE `AreaId` = 616 AND `PhaseId` = 426;
--   UPDATE `creature` SET `phaseId` = 0 WHERE `guid` IN (284433,284434,284435,284436,284437,284439,284497,284498);
--   UPDATE `creature` SET `phaseId` = 0, `spawnMask` = 0 WHERE `guid` = 284438;
--   UPDATE `gameobject` SET `phaseGroup` = 0 WHERE `guid` IN (180060,180219);
--   UPDATE `creature` SET `phaseGroup` = 0 WHERE `guid` IN (
--   293578,293579,293580,293581,293582,293583,293584,293585,293586,293589,293590,293591,293592,293595,293597,293598,293599,293605,293607,293608,293609,293610,293611,293612,293616,293617,293618,293619,293620,293621,293622,293623,293624,293627,293628,293629,293630,293631,293632,293639,293646,293654,293670,293673,293677,293682,293683,293684,293686,293687,293688,293689,293691,293692,293713,293715,293716,293719,293720,293738,293752,293771,295066,295067,295068,295069,295373,295456,295493,295494,295563,295671,295750,295764,295768,297320,297321,298070,298071,298147,298174,298176,298207,298221,298264,298266,298267,298269,298270,298274,298275,298278,298279,298280,298282,298283,298286,298292,298321,298332,298333,298355,298356,298375,298429,298579,298619,298632,298692,298719,298902,304256,305544,305545,356238,356347
--   );
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 26 AND `SourceGroup` IN (194,426) AND `Comment` LIKE 'Malorne:%';
DELETE FROM `phase_area` WHERE `AreaId` = 616 AND `PhaseId` = 426;
INSERT INTO `phase_area` (`AreaId`,`PhaseId`,`Comment`) VALUES
(616,426,'Mount Hyjal - Firelands Invasion (level 85 and Aessina''s Miracle rewarded)');
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(26,426,616,0,0,27,0,85,3,0,0,0,0,'','Malorne: phase 426 at level 85 or higher'),
(26,426,616,0,0,8,0,25372,0,0,0,0,0,'','Malorne: phase 426 once Aessina''s Miracle is rewarded'),
(26,194,0,0,0,27,0,85,2,0,0,0,0,'','Malorne: phase 194 below level 85'),
(26,194,0,0,1,8,0,25372,0,0,1,0,0,'','Malorne: phase 194 while Aessina''s Miracle is not rewarded');
UPDATE `creature` SET `phaseId` = 194 WHERE `guid` IN (284433,284434,284435,284436,284437,284439,284497,284498);
UPDATE `creature` SET `phaseId` = 194, `spawnMask` = 1 WHERE `guid` = 284438;
UPDATE `creature` SET `phaseGroup` = 609 WHERE `guid` IN (
293578,293579,293580,293581,293582,293583,293584,293585,293586,293589,293590,293591,293592,293595,293597,293598,293599,293605,293607,293608,293609,293610,293611,293612,293616,293617,293618,293619,293620,293621,293622,293623,293624,293627,293628,293629,293630,293631,293632,293639,293646,293654,293670,293673,293677,293682,293683,293684,293686,293687,293688,293689,293691,293692,293713,293715,293716,293719,293720,293738,293752,293771,295066,295067,295068,295069,295373,295456,295493,295494,295563,295671,295750,295764,295768,297320,297321,298070,298071,298147,298174,298176,298207,298221,298264,298266,298267,298269,298270,298274,298275,298278,298279,298280,298282,298283,298286,298292,298321,298332,298333,298355,298356,298375,298429,298579,298619,298632,298692,298719,298902,304256,305544,305545,356238,356347
);
UPDATE `gameobject` SET `phaseGroup` = 609 WHERE `guid` IN (180060,180219);
