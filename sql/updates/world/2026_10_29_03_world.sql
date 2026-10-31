-- Silverpine Forest, Fenris Isle: the Forsaken Troopers (44958-44965) carried unit_flags 33536 (IMMUNE_TO_PC | IMMUNE_TO_NPC | CAN_SWIM), so they and
-- the Hillsbrad Refugees (44954/44966, unit_flags 32768) could not attack each other. Cataclysm sniff data (ref_cpp) has unit_flags 0; use CAN_SWIM like the refugees.
-- Rollback: UPDATE `creature_template` SET `unit_flags` = 33536 WHERE `entry` BETWEEN 44958 AND 44965;
UPDATE `creature_template` SET `unit_flags` = 32768 WHERE `entry` BETWEEN 44958 AND 44965 AND `unit_flags` = 33536;
-- Snarlmane (1948) was removed together with the Rot Hide gnolls from Fenris Keep in patch 4.0.3a; remove the leftover spawn (guid 14780).
-- Rollback: import backups/445/creature_14780.sql
DELETE FROM `creature` WHERE `guid` = 14780 AND `id` = 1948;
