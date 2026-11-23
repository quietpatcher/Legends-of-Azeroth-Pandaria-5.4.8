-- Lordaeron (quest 27098, to-do 502): Sylvanas rides her own warhorse, the player rides beside her.
-- Cause: Sylvanas (45051) had a display mount and followed the player's horse with a plain follow move, so she got stuck on the
-- terrain and lost her mount, and the horse searched its own path over flight-path nodes and crossed the river instead of the bridge.
-- Now (script npc_silverpine_sylvanas_windrunner_lordaeron): Sylvanas sits in seat 0 of her warhorse 45057 (vehicle 1077), the
-- player's warhorse 45041 (vehicle 1076) is carried in its side seat 1 and the player sits on it; 45057 runs the road over the bridge.
-- Source: client data 5.4.8 (spell 84128 summons 45057 and 45051, spell 84164 summons 45041, spell 84166 Ride Sylvanas Horse on 45057;
-- VehicleSeat 8455 = 1077 seat 0 (can control), 8464 = 1077 seat 1 at 2.5 yd to the side); sniffed creature_template_addon of 45051
-- without a mount (ref_cpp); TrinityCore PR #28340 (path 450570, speed 6.3564).
-- Rollback:
--   UPDATE `creature_template_addon` SET `mount`=29257 WHERE `entry`=45051;
--   UPDATE `creature_template` SET `ScriptName`='' WHERE `entry`=45041;

-- Lady Sylvanas Windrunner: no display mount, she rides warhorse 45057
UPDATE `creature_template_addon` SET `mount`=0 WHERE `entry`=45051;

-- Forsaken Warhorse (the player's horse)
UPDATE `creature_template` SET `ScriptName`='npc_silverpine_forsaken_warhorse_player_lordaeron' WHERE `entry`=45041;
