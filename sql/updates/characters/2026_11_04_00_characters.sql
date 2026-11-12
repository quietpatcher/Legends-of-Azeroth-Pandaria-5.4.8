-- To-do 475 (Dwarfhunter, 1-11-2026): in-game bug reports also store the phase of the reporter
-- (phase mask, phase ids, terrain swaps), so a report from a phased area can be reproduced.
-- Repeatable: the column is only added when it is missing.
-- Rollback: ALTER TABLE `todo_reports` DROP COLUMN `phase`;
-- Source: own tool (cs_issue.cpp), no Blizzard data involved.
SET @has := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'todo_reports' AND COLUMN_NAME = 'phase');
SET @sql := IF(@has = 0, 'ALTER TABLE `todo_reports` ADD COLUMN `phase` VARCHAR(255) NOT NULL DEFAULT '''' AFTER `text`', 'DO 0');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
