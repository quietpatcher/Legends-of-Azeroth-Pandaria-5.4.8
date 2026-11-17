-- Rollback: re-run the REPLACE statements saved as l1_rollback_20261106_10.sql (4 smart_scripts rows, entryorguid 96036 / 9603600).
-- Shoeshine Seat (gameobject template 194115, action list 19411500): the same rows also exist under the non-existent
-- gameobject template 96036 (no template in world, none in the reference data), where SmartAIMgr rejects them at load.
-- Source: MityaFoxy/Legends-of-Azeroth-Pandaria-5.4.8 9ad090b4 (GPLv2); verified: no gameobject_template 96036 here, none in ref_sf.
DELETE FROM `smart_scripts`
WHERE (`entryorguid` = 96036 AND `source_type` = 1)
   OR (`entryorguid` = 9603600 AND `source_type` = 9);
