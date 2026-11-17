-- Western Plaguelands, Andorhal (to-do 423): the battle armies of Ace in the Hole and the Alliance Val'kyr chain were
-- always visible. Retail shows them only while that part of the story is active: the plaza and Thassarian's camp are
-- sparse during the earlier Andorhal quests and fill with Provincial Minutemen, Forsaken Troopers and Lesser Val'kyr
-- once the battle starts. Before this change every player in Andorhal saw both factions' battle armies at once.
-- This puts those spawns in phase 2 of zone 28, and adds a zone phase (normal phase 1 + 2) that is active:
--   Horde:    Ace in the Hole (27089) in the log, or rewarded and Andorhal, Once and For All (27090) not yet rewarded;
--   Alliance: The Depravity of the Forsaken (27205) in the log, or rewarded and Alas, Andorhal (27206) not yet rewarded.
-- Entries moved: Provincial Minuteman 44944, Frightened Provincial Minuteman 45101 (Ace in the Hole charm/convert
-- targets), Lesser Val'kyr 45239 (Val'kyr Incursion 27201), Forsaken Trooper 45240/45242 (Brother Against Brother
-- 27202), Aradne 45235 (27204). The earlier-stage soldiers (44447/44448/44449/44450, 44326/44328/44331/44332) stay in
-- phase 1 for now: there is no source yet for their exact phase.
-- Source: Cataclysm-era 2011 playthrough videos (Horde: plaza sparse during the Scourge quests, crowded front line
-- during Ace in the Hole; Alliance: Thassarian's camp nearly empty at Ashes to Ashes, full of Provincial Minutemen at
-- Val'kyr Incursion); the Cataclysm sniff data (Cata Preservation) of Andorhal contains none of these six entries,
-- while it does contain the normal battle set; quest objectives of 27089/27201/27202/27204.
-- Rollback:
--   DELETE FROM conditions WHERE SourceTypeOrReferenceId=25 AND SourceGroup=28 AND SourceEntry=1;
--   DELETE FROM phase_definitions WHERE zoneId=28 AND entry=1;
--   UPDATE creature SET phaseMask=1 WHERE map=0 AND zoneId=28 AND phaseMask=2 AND id IN (44944,45101,45239,45240,45242,45235);

UPDATE `creature` SET `phaseMask`=2 WHERE `map`=0 AND `phaseMask`=1 AND `id` IN (44944,45101,45239,45240,45242,45235) AND `guid` IN (311822,311824,311825,311826,311827,311828,311829,311830,311831,311832,311833,311841,311842,311843,311844,311845,311860,311890,311892,311893,311921,311922,311928,311929,311930,311931,312012,312016,312019,312020,312022,312023,312025,312026,312040,312042,312046,312049,312050,312053,312062,312063,312071,312073,312075,312076,312077,312078,312079,312080,312081,312082,312087,312088,312091,312092,373593,373594,373595,373596,373597,373598,373599,373600,373601,373602,373603,373604,373605,373606,373607,373608,373609,373610,373611,373612,373613,373614,373615,373616,373617,373618,373619,373620,373621,373703,373704,373705,373706,373707,373708,373709,373710,373711,373712,373713,373714);

DELETE FROM `phase_definitions` WHERE `zoneId`=28 AND `entry`=1;
INSERT INTO `phase_definitions` (`zoneId`,`entry`,`phasemask`,`phaseId`,`terrainswapmap`,`worldMapArea`,`flags`,`comment`) VALUES
(28,1,3,0,0,0,0,'Western Plaguelands: Andorhal battle (Ace in the Hole / The Depravity of the Forsaken until Alas, Andorhal)');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=25 AND `SourceGroup`=28 AND `SourceEntry`=1;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(25,28,1,0,0, 9,0,27089,0,0,0,0,0,'','Andorhal battle phase: Ace in the Hole in progress'),
(25,28,1,0,1,28,0,27089,0,0,0,0,0,'','Andorhal battle phase: Ace in the Hole complete'),
(25,28,1,0,2, 8,0,27089,0,0,0,0,0,'','Andorhal battle phase: Ace in the Hole rewarded'),
(25,28,1,0,2, 8,0,27090,0,0,1,0,0,'','Andorhal battle phase: and Andorhal, Once and For All not rewarded'),
(25,28,1,0,3, 9,0,27205,0,0,0,0,0,'','Andorhal battle phase: The Depravity of the Forsaken in progress'),
(25,28,1,0,4,28,0,27205,0,0,0,0,0,'','Andorhal battle phase: The Depravity of the Forsaken complete'),
(25,28,1,0,5, 8,0,27205,0,0,0,0,0,'','Andorhal battle phase: The Depravity of the Forsaken rewarded'),
(25,28,1,0,5, 8,0,27206,0,0,1,0,0,'','Andorhal battle phase: and Alas, Andorhal not rewarded');
