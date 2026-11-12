-- sync98 follow-up to the L1 Silverpine/Hillsbrad port (2026_11_06_13/14/52): SmartAIMgr reported at load
-- "Creature entry X has SmartAI scripts, but its AIName is not SmartAI" for 44951, 45405, 45525 and 48912.
-- * Lady Sylvanas Windrunner 45525 (2026_11_06_13) now runs her C++ script npc_silverpine_sylvanas_forsaken_front with
--   AIName ''; her old SmartAI rows are dead data and are removed.
-- * Master Sergeant Pietro Zaren 45405 (2026_11_06_14) and Stormpike Trainee 48912 (2026_11_06_52) got new SmartAI rows
--   from the port but no AIName and no ScriptName, so the rows never ran: AIName set to SmartAI.
-- * Agatha 44951 is NOT touched here: her SmartAI rows are the live fix of to-do 446 (No Escape, regression check 446),
--   while 2026_11_06_11 switches her to the C++ script of the port. Which one stays is decided in the sync98 review.
-- Source: SmartAIMgr load errors on dev 06-11 16:49 (DBErrors.log), 1LineAtaTime port notes state/l1_silverpine_hillsbrad_diff.md.
-- Rollback: restore the smart_scripts rows of 45525 (source_type 0) from ~/backups/sql/smart_44951_45525_pre_20261106_94.sql
-- on dev (or world_pre_sync98_20261106.sql.gz) and UPDATE creature_template SET AIName = '' WHERE entry IN (45405, 48912);
DELETE FROM `smart_scripts` WHERE `entryorguid` = 45525 AND `source_type` = 0;
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` IN (45405, 48912) AND `ScriptName` = '';
