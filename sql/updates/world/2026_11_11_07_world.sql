-- To-do 495: Magister Duskwither's Journal (GO 181012) and its Fire (GO 181013) at Farstrider Retreat burned permanently.
-- Cause: both stood as static world spawns (guid 184093/184094, respawn 300 s); Magister Duskwither (15951) already summons the journal
--        on quest 8891 reward (smart_scripts 15951 id 0, SMART_ACTION_SUMMON_GO 181012) and burns it with a fireball.
-- Source: ref_cpp and ref_sf (world DBs) have no static spawn of GO 181012/181013 (only ref_alex has the same two rows as ours); SmartAI of 15951 in our DB.
-- To-do 496: Ven'jashi (15406, guid 74958) lay 2 yd in front of the cage (GO 181379) instead of inside it.
-- Source: ref_cpp and ref_sf creature 55362 (entry 15406): 8666.61 -7960.89 151.876 o=2.84489 (same cage position as ours, GO 21721 = 8666.62 -7961.04).
-- Rollback:
--   DELETE FROM gameobject WHERE guid IN (184093,184094);
--   INSERT INTO gameobject (guid,id,map,zoneId,areaId,spawnMask,phaseMask,phaseId,phaseGroup,position_x,position_y,position_z,orientation,rotation0,rotation1,rotation2,rotation3,spawntimesecs,animprogress,state,ScriptName,VerifiedBuild) VALUES
--     (184093,181012,530,3430,3464,1,1,0,0,9049.71,-7434.27,84.6563,2.09439,0,0,0.866025,0.500001,300,255,1,'',0),
--     (184094,181013,530,3430,3464,1,1,0,0,9049.43,-7434.17,85.137,1.25664,0,0,0.587785,0.809017,300,255,1,'',0);
--   UPDATE creature SET position_x=8665.88, position_y=-7959.15, position_z=151.794, orientation=2.73631 WHERE guid=74958 AND id=15406;
DELETE FROM gameobject WHERE guid IN (184093,184094) AND id IN (181012,181013);
UPDATE creature SET position_x=8666.61, position_y=-7960.89, position_z=151.876, orientation=2.84489 WHERE guid=74958 AND id=15406;
