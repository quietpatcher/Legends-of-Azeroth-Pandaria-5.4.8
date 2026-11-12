-- Heroic dungeons (player path): the dungeon finder run now completes on the last boss of
-- The Culling of Stratholme (LFG 209/210) and Throne of the Tides (LFG 302/324).
-- Cause 1: Mal'ganis casts the server-side credit spell 58630 (boss_mal_ganis.cpp, JustDied), and
--          instance_encounters 296/300 expect that spell, but 58630 had no spell_gen_dungeon_credit script,
--          so UpdateEncounterState was never called and the group got no dungeon finder reward.
-- Cause 2: boss_ozumat.cpp CompleteEncounter() reported ENCOUNTER_CREDIT_CAST_SPELL 95673, while
--          instance_encounters 1047 waited for a kill of creature 42172, which never dies in this fight.
--          A server-side marker spell 95673 (spell_dbc + spellmisc_dbc) was tried but the loader rejects it
--          (DBErrors.log: "Table `instance_encounters` has an invalid spell (entry 95673) linked to the encounter
--          1047 (Ozumat), skipped!"), so the row was dropped. Fallback: CompleteEncounter() now reports
--          ENCOUNTER_CREDIT_KILL_CREATURE 42172 and instance_encounters 1047 keeps creditType 0 / creditEntry 42172
--          (this file only handles the Culling of Stratholme credit now).
-- Source: ref_cpp spell_script_names (58630 spell_gen_dungeon_credit); our scripts boss_mal_ganis.cpp and
--         boss_ozumat.cpp (Ozumat credit by kill of 42172); 5.4.8 DungeonEncounter.dbc (1047 Ozumat, 296/300 Mal'ganis).
-- Rollback:
--   DELETE FROM spell_script_names WHERE spell_id=58630 AND ScriptName='spell_gen_dungeon_credit';
DELETE FROM spell_script_names WHERE spell_id=58630 AND ScriptName='spell_gen_dungeon_credit';
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES (58630, 'spell_gen_dungeon_credit');
