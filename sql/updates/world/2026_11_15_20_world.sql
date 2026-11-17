-- Quest 25189 "Spirits Be Praised" (Durotar): Grandmatron Tekla (39325) escorts the player to Raggaran (39326) like in retail.
-- Problem: Tekla has no escort at all. The quest has no objective, so it is complete the moment it is accepted, Tekla stays in
--   her hut and says nothing; the only thing that happens is the credit for quest 25188 when the player hands the quest in at
--   Raggaran. Her creature template uses a script name whose AI is empty, which keeps any SmartAI row from running, spawn
--   253749 (the hut) carries the invisibility aura 49414 with no detection spell for it in this zone, so nobody sees her there,
--   and the hand-in dialogue of Raggaran has no emote.
-- Retail behaviour (Wowhead quest 25189 and its comments, the sniffed broadcast texts): accepting makes Tekla say 39456 and
--   walk slowly (walk speed 1.4) to Raggaran; she attacks what comes near her; when she gets too far behind or the player runs
--   too far ahead the escort fails and she goes back to the hut, where she is back after about 300 seconds (spawn time 300);
--   at the second stretch of water she says 39452 and casts Water Walking (73887) on herself and the player; in the last third
--   she says 39457, yells 39458, casts Air Spirit's Boon (73889) and says 39459; at Raggaran she says 39454 and Raggaran answers
--   39455; the quest is complete when she arrives.
-- Checked before building: the references hold no escort rows, waypoints or creature_text for these two creatures; the
--   broadcast_text rows 39452 and 39454 to 39459 exist in our world and in the sniff database; the spells 73887 and 73889 exist
--   in Spell.dbc; the quest has no quest_objective row in our world and the sniff quest_poi of 25189 points at an objective
--   (ObjectiveIndex 16), so a quest event objective is the retail shape; SmartAI escorts with a quest id complete a quest whose
--   objective is of type 10 (area trigger / event) through Player::AreaExploredOrEventHappens, which is what the SmartAI path end
--   calls for the escort target and group; the credit for quest 25188 stays with the existing script of Raggaran (the
--   quest reward script of 39326 runs through its script name), so no second credit is added.
-- Change:
--   * creature_template 39325: AIName SmartAI and an empty ScriptName (the script only handled quest rewards, Tekla never ends a
--     quest; 3193, 39324 and 39326 keep it). unit_flags are not touched.
--   * smart_scripts for the two Tekla spawns (a spawn script each, because 253749 stands in the hut and 253489 stands on the
--     road at 392 -4081, where a route that starts in the hut would first send her 170 yards back): on accepting 25189 she
--     stands up from her kneeling pose, loses the quest giver flag (one escort per spawn at a time), says text 1 and starts the
--     walk with the standard SmartAI escort (quest 25189, reaction aggressive, despawn 9 s after arrival, escort fails when the
--     player is more than 60 yards away). Texts 2 to 6 and the two spells follow the route points below; Raggaran's line is
--     spoken by Raggaran himself after Tekla's last text.
--   * waypoints 393250 (12 points from the hut) and 393251 (8 points for the spawn on the road): the route of the Wowhead
--     sightings (562 -4103, 492 -4092, 388 -4082, 313 -4114, 205 -4156, 59 -4210, Raggaran) with extra points about every 50
--     yards; z of every point is the terrain height read from the extracted map data with the same interpolation the core
--     uses, checked against the nearest spawns of our own world (within 40 yards of each point, they differ by 0.1 to 3.5 yards from the terrain); the
--     last point stands 2 yards from Raggaran at his own spawn height (35.38) because the terrain there is 2.7 yards lower than
--     where he stands. The second water starts at point 7 (full route) and 3 (short route): the map liquid data shows the first
--     water at the hut and the second at 301 -4118.
--   * creature_text for 39325 (groups 1 to 6, broadcast texts 39456, 39452, 39457, 39458, 39459, 39454) and for 39326 (group 1,
--     broadcast text 39455); the text is the sniffed broadcast text (female variant for Tekla, male for Raggaran).
--   * quest_objective: one event objective "Escort Grandmatron Tekla to Raggaran" for 25189 (id 289861), so the quest is no
--     longer complete on accept.
--   * creature_addon 253749: aura 49414 removed (the sniffed hut spawn has no aura; 253489 is left as it is).
--   * quest_offer_reward 25189: Emote1 2 as in the sniff. RewardSpell 73750 is not added: the spell is not in our Spell.dbc.
-- Source: Wowhead mop-classic quest 25189 and npc 39325 (page and comments, 15-11-2026), Wowhead sightings for the route,
--   Cataclysm Preservation sniff database (broadcast_text 39452, 39454 to 39459, creature spawns 309907 and 310152,
--   quest_offer_reward 25189, quest_poi 25189), 5.4.8 map data for the heights.
-- Rollback (the values before this update):
--   DELETE FROM `smart_scripts` WHERE `entryorguid` IN (-253749,-253489) AND `source_type`=0;
--   DELETE FROM `waypoints` WHERE `entry` IN (393250,393251);
--   DELETE FROM `creature_text` WHERE `CreatureID` IN (39325,39326);
--   DELETE FROM `quest_objective` WHERE `questId`=25189 AND `id`=289861;
--   UPDATE `creature_template` SET `AIName`='',`ScriptName`='npc_watershed_patrol' WHERE `entry`=39325;
--   UPDATE `creature_addon` SET `auras`='49414' WHERE `guid`=253749;
--   UPDATE `quest_offer_reward` SET `Emote1`=0 WHERE `ID`=25189;

UPDATE `creature_template` SET `AIName`='SmartAI',`ScriptName`='' WHERE `entry`=39325;
UPDATE `creature_addon` SET `auras`=NULL WHERE `guid`=253749;
UPDATE `quest_offer_reward` SET `Emote1`=2 WHERE `ID`=25189;

DELETE FROM `quest_objective` WHERE `questId`=25189 AND `id`=289861;
INSERT INTO `quest_objective` (`questId`,`id`,`index`,`type`,`objectId`,`amount`,`flags`,`description`) VALUES
(25189,289861,0,10,0,0,0,'Escort Grandmatron Tekla to Raggaran');

DELETE FROM `creature_text` WHERE `CreatureID` IN (39325,39326);
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(39325,1,0,'Let us be off then.  Take me to my grandson Raggaran.',12,0,100,0,0,0,0,39456,0,'Grandmatron Tekla - accept'),
(39325,2,0,'I''m tired of wading in water.  Let''s make this a little bit easier on ourselves, shall we?  Spirit of water, come to our aid!',12,0,100,0,0,0,0,39452,0,'Grandmatron Tekla - water spirit'),
(39325,3,0,'No!  M-my ankle!  I''m not sure I can make it... after we''ve come so far...',12,0,100,0,0,0,0,39457,0,'Grandmatron Tekla - ankle'),
(39325,4,0,'Spirits of air!  Come to my aid!',14,0,100,0,0,0,0,39458,0,'Grandmatron Tekla - call to the air spirits'),
(39325,5,0,'We can continue now, I think.  Let us press on.',12,0,100,0,0,0,0,39459,0,'Grandmatron Tekla - continue'),
(39325,6,0,'Raggaran, I''m safe.',12,0,100,0,0,0,0,39454,0,'Grandmatron Tekla - arrival'),
(39326,1,0,'Grandmatron... you''re alive!',12,0,100,0,0,0,0,39455,0,'Raggaran - greeting after the escort');

DELETE FROM `waypoints` WHERE `entry` IN (393250,393251);
INSERT INTO `waypoints` (`entry`,`pointid`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`point_comment`) VALUES
(393250,1,528,-4098,16.77,NULL,0,'Grandmatron Tekla route from the hut point 1 - start of the route'),
(393250,2,492,-4092,20.62,NULL,0,'Grandmatron Tekla route from the hut point 2'),
(393250,3,440,-4087,17.74,NULL,0,'Grandmatron Tekla route from the hut point 3'),
(393250,4,388,-4082,20.77,NULL,0,'Grandmatron Tekla route from the hut point 4'),
(393250,5,350,-4098,23.08,NULL,0,'Grandmatron Tekla route from the hut point 5'),
(393250,6,313,-4114,20.4,NULL,0,'Grandmatron Tekla route from the hut point 6'),
(393250,7,301,-4118,17.45,NULL,0,'Grandmatron Tekla route from the hut point 7 - second water: water spirit'),
(393250,8,255,-4136,17.74,NULL,0,'Grandmatron Tekla route from the hut point 8'),
(393250,9,205,-4156,22.41,NULL,0,'Grandmatron Tekla route from the hut point 9 - last third: ankle and air spirit'),
(393250,10,132,-4183,20.79,NULL,0,'Grandmatron Tekla route from the hut point 10'),
(393250,11,59,-4210,30.3,NULL,0,'Grandmatron Tekla route from the hut point 11'),
(393250,12,51.5,-4218.8,35.38,NULL,0,'Grandmatron Tekla route from the hut point 12 - arrival at Raggaran'),
(393251,1,350,-4098,23.08,NULL,0,'Grandmatron Tekla route from the road point 1'),
(393251,2,313,-4114,20.4,NULL,0,'Grandmatron Tekla route from the road point 2'),
(393251,3,301,-4118,17.45,NULL,0,'Grandmatron Tekla route from the road point 3 - second water: water spirit'),
(393251,4,255,-4136,17.74,NULL,0,'Grandmatron Tekla route from the road point 4'),
(393251,5,205,-4156,22.41,NULL,0,'Grandmatron Tekla route from the road point 5 - last third: ankle and air spirit'),
(393251,6,132,-4183,20.79,NULL,0,'Grandmatron Tekla route from the road point 6'),
(393251,7,59,-4210,30.3,NULL,0,'Grandmatron Tekla route from the road point 7'),
(393251,8,51.5,-4218.8,35.38,NULL,0,'Grandmatron Tekla route from the road point 8 - arrival at Raggaran');

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (-253749,-253489) AND `source_type`=0;
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(-253749,0,0,1,19,0,100,0,25189,0,0,0,0,91,8,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Quest 'Spirits Be Praised' Accepted - Remove Kneeling"),
(-253749,0,1,2,61,0,100,0,0,0,0,0,0,83,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Remove Quest Giver Flag"),
(-253749,0,2,3,61,0,100,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Say Text 1"),
(-253749,0,3,0,61,0,100,0,0,0,0,0,0,53,0,393250,0,25189,9000,2,7,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Start Waypoint (walk, quest 25189, despawn after arrival)"),
(-253749,0,4,5,40,0,100,0,7,393250,0,0,0,1,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Waypoint Reached (second water) - Say Text 2"),
(-253749,0,5,6,61,0,100,0,0,0,0,0,0,11,73887,2,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Cast Water Walking On Self"),
(-253749,0,6,0,61,0,100,0,0,0,0,0,0,11,73887,2,0,0,0,0,17,0,40,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Cast Water Walking On Players In Range"),
(-253749,0,7,8,40,0,100,0,9,393250,0,0,0,54,6500,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Waypoint Reached (last third) - Pause Path"),
(-253749,0,8,0,61,0,100,0,0,0,0,0,0,1,3,2500,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Say Text 3"),
(-253749,0,9,10,52,0,100,0,3,39325,0,0,0,1,4,2500,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Text 3 Over - Yell Text 4"),
(-253749,0,10,0,61,0,100,0,0,0,0,0,0,11,73889,2,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Cast Air Spirit's Boon On Self"),
(-253749,0,11,0,52,0,100,0,4,39325,0,0,0,1,5,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Text 4 Over - Say Text 5"),
(-253749,0,12,0,40,0,100,0,12,393250,0,0,0,1,6,2000,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Waypoint Reached (arrival) - Say Text 6"),
(-253749,0,13,0,52,0,100,0,6,39325,0,0,0,1,1,0,0,0,0,0,9,39326,0,60,0,0,0,0,0,"Grandmatron Tekla - On Text 6 Over - Raggaran Says Text 1"),
(-253489,0,0,1,19,0,100,0,25189,0,0,0,0,91,8,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Quest 'Spirits Be Praised' Accepted - Remove Kneeling"),
(-253489,0,1,2,61,0,100,0,0,0,0,0,0,83,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Remove Quest Giver Flag"),
(-253489,0,2,3,61,0,100,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Say Text 1"),
(-253489,0,3,0,61,0,100,0,0,0,0,0,0,53,0,393251,0,25189,9000,2,7,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Start Waypoint (walk, quest 25189, despawn after arrival)"),
(-253489,0,4,5,40,0,100,0,3,393251,0,0,0,1,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Waypoint Reached (second water) - Say Text 2"),
(-253489,0,5,6,61,0,100,0,0,0,0,0,0,11,73887,2,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Cast Water Walking On Self"),
(-253489,0,6,0,61,0,100,0,0,0,0,0,0,11,73887,2,0,0,0,0,17,0,40,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Cast Water Walking On Players In Range"),
(-253489,0,7,8,40,0,100,0,5,393251,0,0,0,54,6500,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Waypoint Reached (last third) - Pause Path"),
(-253489,0,8,0,61,0,100,0,0,0,0,0,0,1,3,2500,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Say Text 3"),
(-253489,0,9,10,52,0,100,0,3,39325,0,0,0,1,4,2500,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Text 3 Over - Yell Text 4"),
(-253489,0,10,0,61,0,100,0,0,0,0,0,0,11,73889,2,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - Linked - Cast Air Spirit's Boon On Self"),
(-253489,0,11,0,52,0,100,0,4,39325,0,0,0,1,5,0,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Text 4 Over - Say Text 5"),
(-253489,0,12,0,40,0,100,0,8,393251,0,0,0,1,6,2000,0,0,0,0,1,0,0,0,0,0,0,0,0,"Grandmatron Tekla - On Waypoint Reached (arrival) - Say Text 6"),
(-253489,0,13,0,52,0,100,0,6,39325,0,0,0,1,1,0,0,0,0,0,9,39326,0,60,0,0,0,0,0,"Grandmatron Tekla - On Text 6 Over - Raggaran Says Text 1");
