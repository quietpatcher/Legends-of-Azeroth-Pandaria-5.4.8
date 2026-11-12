-- To-do 436 (quest 27045 Waiting to Exsanguinate): the scene camera never moved to Crowley/Bloodfang (the armoire stays in view) because 83763/83764 are only dummy auras in 5.4.8 and no script attached to them.
-- Change: attach spell_silverpine_armoire_camera (sets the player viewpoint to Crowley / Bloodfang while the aura is up).
-- Source: 5.4.8 SpellEffect.dbc (83763/83764: apply aura SPELL_AURA_DUMMY, targets 22/7, no conditions rows); TrinityCore Cataclysm Classic zone_silverpine_forest.cpp as comparison only.
-- Rollback: DELETE FROM spell_script_names WHERE spell_id IN (83763,83764) AND ScriptName='spell_silverpine_armoire_camera';

DELETE FROM `spell_script_names` WHERE `spell_id` IN (83763,83764);
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(83763,'spell_silverpine_armoire_camera'),
(83764,'spell_silverpine_armoire_camera');
