-- Dragonwrath/Tarecgosa chain, Fangs of the Father, Mini Mana Bomb and pet scaling: the scripts exist in the tree but
--   were never loaded, and the database never named them.
-- Cause: no AddSC_* call for tarecgosa_scripts, fangs_of_father_scripts and npc_toy (the Toys directory was not part
--   of the build either), creature_template.ScriptName is empty for all 16 creatures, and spell_gen_pet_calculate
--   is bound to no spell. Gossip menu 6539 has only option 16 and no condition on it; the Anachronos script expects
--   options 16 and 17, each shown only while its quest (29134 / 29193) is in progress.
-- Change: set ScriptName on 16 creature_template rows, bind spell_gen_pet_calculate to 19591, 35695, 61013, 61017 and
--   61697, add gossip option 17 of menu 6539 (option 16 already exists and stays as it is) and add the two quest
--   conditions for options 16 and 17 (source type 15). Each ScriptName has a registration in the C++ of this commit.
-- Source: Legends-of-Azeroth/Legends-of-Azeroth-Pandaria-5.4.8 pull request #500 "Add missing scripts" (author lee).
-- Rollback:
--   UPDATE `creature_template` SET `ScriptName`='' WHERE `entry` IN (15192,52835,53098,53149,53349,53371,53466,53392,53396,53394,53422,53472,65903,56314,57777,57802);
--   DELETE FROM `spell_script_names` WHERE `ScriptName`='spell_gen_pet_calculate' AND `spell_id` IN (19591,35695,61013,61017,61697);
--   DELETE FROM `gossip_menu_option` WHERE `MenuID`=6539 AND `OptionID`=17;
--   DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=15 AND `SourceGroup`=6539 AND `SourceEntry` IN (16,17);
UPDATE `creature_template` SET `ScriptName`='npc_anachronos_15192' WHERE `entry`=15192;
UPDATE `creature_template` SET `ScriptName`='npc_tarecgosa_52835' WHERE `entry`=52835;
UPDATE `creature_template` SET `ScriptName`='npc_tarecgosa_53098' WHERE `entry`=53098;
UPDATE `creature_template` SET `ScriptName`='npc_kalecgos_53149' WHERE `entry`=53149;
UPDATE `creature_template` SET `ScriptName`='npc_thyrinar' WHERE `entry`=53472;
UPDATE `creature_template` SET `ScriptName`='npc_kalecgos_53349' WHERE `entry`=53349;
UPDATE `creature_template` SET `ScriptName`='npc_hallegosa' WHERE `entry` IN (53371,53466);
UPDATE `creature_template` SET `ScriptName`='npc_kalecgos_53392' WHERE `entry`=53392;
UPDATE `creature_template` SET `ScriptName`='npc_tarecgosa_53396' WHERE `entry`=53396;
UPDATE `creature_template` SET `ScriptName`='npc_blue_dragon_53394' WHERE `entry`=53394;
UPDATE `creature_template` SET `ScriptName`='npc_stalker_53422' WHERE `entry`=53422;
UPDATE `creature_template` SET `ScriptName`='npc_toy_mini_maba_bomb' WHERE `entry`=65903;
UPDATE `creature_template` SET `ScriptName`='npc_mostrasz_56314' WHERE `entry`=56314;
UPDATE `creature_template` SET `ScriptName`='npc_wrathion_57777' WHERE `entry`=57777;
UPDATE `creature_template` SET `ScriptName`='npc_lord_hiram_creed' WHERE `entry`=57802;
DELETE FROM `spell_script_names` WHERE `ScriptName`='spell_gen_pet_calculate' AND `spell_id` IN (19591,35695,61013,61017,61697);
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(19591,'spell_gen_pet_calculate'),
(35695,'spell_gen_pet_calculate'),
(61013,'spell_gen_pet_calculate'),
(61017,'spell_gen_pet_calculate'),
(61697,'spell_gen_pet_calculate');
DELETE FROM `gossip_menu_option` WHERE `MenuID`=6539 AND `OptionID`=17;
INSERT INTO `gossip_menu_option` (`MenuID`,`OptionID`,`OptionIcon`,`OptionText`,`OptionBroadcastTextID`,`OptionType`,`OptionNpcflag`,`ActionMenuID`,`ActionPoiID`,`BoxCoded`,`BoxMoney`,`BoxText`,`BoxBroadcastTextID`,`VerifiedBuild`) VALUES
(6539,17,0,'Yes, Anachronos. I am ready to witness your vision of the future.',51305,1,1,0,0,0,0,NULL,0,0);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=15 AND `SourceGroup`=6539 AND `SourceEntry` IN (16,17);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`NegativeCondition`,`ErrorType`,`ErrorTextId`,`ScriptName`,`Comment`) VALUES
(15,6539,16,0,0,9,0,29134,0,0,0,0,0,'','Anachronos (15192) gossip 6539 option 16: show while quest 29134 (A Wrinkle in Time) is in progress'),
(15,6539,17,0,0,9,0,29193,0,0,0,0,0,'','Anachronos (15192) gossip 6539 option 17: show while quest 29193 (On a Wing and a Prayer) is in progress');
