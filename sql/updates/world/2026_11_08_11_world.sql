-- Source: 1LineAtaTime 1ff234ce (GPLv2). Cause: Angry Blight Slime 48319 On Death row (own 2026_11_06_76) needs AIName SmartAI; no-op where already set.
-- Rollback: UPDATE creature_template SET AIName='' WHERE entry=48319 (only if it was empty before; dev already had SmartAI, so nothing to roll back).
-- Hillsbrad Foothills: Angry Blight Slime 48319 starts Angry Scrubbing Bubbles (28329) from its On Death smart_scripts row
-- (own: 2026_11_06_76_world.sql), but that file does not set its AIName: it counted on an abilities update having done so. Without
-- SmartAI the row never runs and the quest cannot start.
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry`=48319 AND `ScriptName`='';
