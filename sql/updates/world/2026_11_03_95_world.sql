-- Extra creature abilities (652 smart_scripts rows) for 474 creatures that already have SmartAI rows.
-- Zones: 002_silverpine_forest, 003_elwynn_forest_and_northshire, 004_dun_morogh_coldridge_valley_and_new_tinkertown, 005_teldrassil_and_shadowglen, 006_azuremyst_isle_and_ammen_vale, 007_gilneas_and_gilneas_city, 008_durotar_valley_of_trials_and_echo_isles, 010_eversong_woods_and_sunstrider_isle, 012_westfall, 013_loch_modan, 014_darkshore, 016_azshara, 017_ghostlands, 018_redridge_mountains, 019_shadowfang_keep, 020_blackfathom_deeps, 021_duskwood, 022_wetlands, 023_ashenvale, 024_hillsbrad_foothills, 025_arathi_highlands, 026_northern_stranglethorn, 027_stonetalon_mountains, 028_gnomeregan, 029_the_cape_of_stranglethorn, 030_southern_barrens, 031_desolace, 032_the_hinterlands, 033_dustwallow_marsh, 034_western_plaguelands, 035_feralas, 036_eastern_plaguelands, 037_thousand_needles, 038_badlands, 039_tanaris, 040_felwood, 041_searing_gorge, 042_burning_steppes, 043_un_goro_crater, 044_swamp_of_sorrows, 045_blasted_lands, 046_silithus, 047_deadwind_pass, 048_razorfen_kraul, 049_maraudon, 050_uldaman, 051_dire_maul, 052_razorfen_downs, 053_stratholme, 054_zul_farrak, 055_blackrock_depths, 056_the_temple_of_atal_hakkar, 057_hellfire_peninsula, 058_zangarmarsh, 059_terokkar_forest, 060_nagrand, 061_blade_s_edge_mountains, 062_netherstorm, 063_shadowmoon_valley, 064_isle_of_quel_danas, 065_hellfire_ramparts, 066_the_blood_furnace, 067_auchenai_crypts, 068_old_hillsbrad_foothills, 069_sethekk_halls, 070_the_steamvault, 071_the_mechanar, 072_the_botanica, 073_the_arcatraz, 074_shadow_labyrinth, 075_the_shattered_halls, 076_magisters_terrace, 077_borean_tundra, 078_howling_fjord, 079_dragonblight, 080_grizzly_hills, 081_zul_drak, 082_sholazar_basin, 083_the_storm_peaks, 084_icecrown, 085_the_nexus, 086_ahn_kahet, 087_drak_tharon_keep, 088_gundrak, 089_halls_of_stone, 090_the_oculus, 091_mount_hyjal, 092_abyssal_depths, 093_uldum, 094_tol_barad_peninsula, 095_throne_of_the_tides, 096_halls_of_origination, 097_zul_gurub
-- Source: DeltaTho PR 15 creature abilities as ported in 1LineAtaTime/LoA-Pandaria-Playerbots d9db430a (wave 2, GPLv2), renumbered:
-- the new rows are appended after the current highest id of each creature (links remapped), a cast the creature already has is skipped.
-- Creatures with a ScriptName or touched by open work branches are left out. Plausibility: spell names fit the creature class.
-- Idempotent: the DELETE of the appended id range per creature runs first (ranges are listed in the Rollback note).
-- Rollback: the commented DELETE statements at the end of this file (ranges entry:first_id-last_id).

DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND (
  (`entryorguid` = 1781 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 1642 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 6866 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 808 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 1260 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 8503 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 42291 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 43230 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 2002 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 2003 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 2004 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 2005 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 2008 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 16522 AND `id` BETWEEN 14 AND 14)
  OR (`entryorguid` = 17591 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 35660 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 47091 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 3099 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 3108 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 3111 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 3125 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 3127 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 3183 AND `id` BETWEEN 2 AND 4)
  OR (`entryorguid` = 3281 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 5809 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 5826 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 10676 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 39072 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 39317 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 15274 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 154 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 391 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 449 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 506 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 594 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 833 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 1109 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 1174 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 2476 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 2071 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 2237 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 35111 AND `id` BETWEEN 10 AND 10)
  OR (`entryorguid` = 35759 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 36131 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 16318 AND `id` BETWEEN 15 AND 15)
  OR (`entryorguid` = 334 AND `id` BETWEEN 3 AND 5)
  OR (`entryorguid` = 428 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 486 AND `id` BETWEEN 5 AND 7)
  OR (`entryorguid` = 578 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 711 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 4462 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 3875 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 4805 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 4818 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 4831 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 48 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 202 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 206 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 511 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 628 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 920 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 930 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 3946 AND `id` BETWEEN 4 AND 6)
  OR (`entryorguid` = 43761 AND `id` BETWEEN 11 AND 11)
  OR (`entryorguid` = 1036 AND `id` BETWEEN 6 AND 7)
  OR (`entryorguid` = 3733 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 3734 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 3743 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 3745 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 3750 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 3752 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 3763 AND `id` BETWEEN 3 AND 5)
  OR (`entryorguid` = 3770 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 3780 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 3810 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 3846 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 3847 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 3917 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 3921 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 3922 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 3924 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 3925 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 3943 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 3944 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 10559 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 10641 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 10642 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 11697 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 12474 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 12475 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 12476 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 12759 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 14733 AND `id` BETWEEN 17 AND 17)
  OR (`entryorguid` = 14753 AND `id` BETWEEN 19 AND 19)
  OR (`entryorguid` = 34295 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 2270 AND `id` BETWEEN 8 AND 9)
  OR (`entryorguid` = 2319 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 2344 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2358 AND `id` BETWEEN 5 AND 6)
  OR (`entryorguid` = 2369 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 2555 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2560 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 2566 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2585 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 2591 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2599 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 2602 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2606 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2619 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 2761 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 2783 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 10696 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 15126 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 942 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 4458 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 4459 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 4460 AND `id` BETWEEN 2 AND 4)
  OR (`entryorguid` = 41437 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 7079 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 689 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 1562 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2522 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 2545 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 4457 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 43376 AND `id` BETWEEN 12 AND 13)
  OR (`entryorguid` = 43377 AND `id` BETWEEN 9 AND 11)
  OR (`entryorguid` = 43659 AND `id` BETWEEN 8 AND 9)
  OR (`entryorguid` = 43660 AND `id` BETWEEN 8 AND 9)
  OR (`entryorguid` = 3374 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 37091 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 37171 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 4666 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 4667 AND `id` BETWEEN 3 AND 5)
  OR (`entryorguid` = 4670 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 4672 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 4674 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 4675 AND `id` BETWEEN 8 AND 9)
  OR (`entryorguid` = 4728 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 4729 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 5760 AND `id` BETWEEN 2 AND 4)
  OR (`entryorguid` = 35412 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 36094 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 2574 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2657 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 42536 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 42555 AND `id` BETWEEN 3 AND 5)
  OR (`entryorguid` = 4344 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 4345 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 4393 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 4394 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 4967 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 4979 AND `id` BETWEEN 10 AND 12)
  OR (`entryorguid` = 1783 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 1784 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 1815 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 1831 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 1852 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 44482 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 5268 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 5278 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 5286 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 5359 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 11443 AND `id` BETWEEN 16 AND 16)
  OR (`entryorguid` = 8519 AND `id` BETWEEN 8 AND 8)
  OR (`entryorguid` = 8520 AND `id` BETWEEN 7 AND 8)
  OR (`entryorguid` = 8521 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 8522 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 8526 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 8535 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 8541 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 8551 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 9450 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 9452 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 10824 AND `id` BETWEEN 19 AND 19)
  OR (`entryorguid` = 11896 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 12261 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 16184 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 40959 AND `id` BETWEEN 4 AND 6)
  OR (`entryorguid` = 41131 AND `id` BETWEEN 2 AND 5)
  OR (`entryorguid` = 41196 AND `id` BETWEEN 12 AND 12)
  OR (`entryorguid` = 41199 AND `id` BETWEEN 12 AND 13)
  OR (`entryorguid` = 47487 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 47602 AND `id` BETWEEN 6 AND 8)
  OR (`entryorguid` = 47619 AND `id` BETWEEN 6 AND 9)
  OR (`entryorguid` = 47620 AND `id` BETWEEN 6 AND 9)
  OR (`entryorguid` = 2717 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 2739 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 2740 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 5429 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 5450 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 5451 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 5455 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 5459 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 5645 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 5647 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 7855 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 7858 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 39081 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 9516 AND `id` BETWEEN 2 AND 5)
  OR (`entryorguid` = 48259 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 48331 AND `id` BETWEEN 9 AND 10)
  OR (`entryorguid` = 5840 AND `id` BETWEEN 9 AND 9)
  OR (`entryorguid` = 5846 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 5856 AND `id` BETWEEN 7 AND 8)
  OR (`entryorguid` = 8391 AND `id` BETWEEN 5 AND 6)
  OR (`entryorguid` = 8400 AND `id` BETWEEN 21 AND 21)
  OR (`entryorguid` = 47311 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 615 AND `id` BETWEEN 4 AND 6)
  OR (`entryorguid` = 7025 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 7027 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 7035 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 7038 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 9697 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 9776 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 10078 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 48111 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 48119 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 48121 AND `id` BETWEEN 3 AND 5)
  OR (`entryorguid` = 48201 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 6557 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 46714 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 46770 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 46775 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 5983 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 5998 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 6004 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 6005 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 6008 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 6009 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 8299 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 42235 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 42334 AND `id` BETWEEN 1 AND 4)
  OR (`entryorguid` = 15196 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 7379 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 4436 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 4442 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 4517 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 12242 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 12243 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 13142 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 13596 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 4852 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 7023 AND `id` BETWEEN 8 AND 8)
  OR (`entryorguid` = 11441 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 11448 AND `id` BETWEEN 16 AND 16)
  OR (`entryorguid` = 11452 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 11455 AND `id` BETWEEN 16 AND 16)
  OR (`entryorguid` = 11465 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 11473 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 11486 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 11487 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 11488 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 13021 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 13197 AND `id` BETWEEN 12 AND 12)
  OR (`entryorguid` = 13285 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 14327 AND `id` BETWEEN 14 AND 14)
  OR (`entryorguid` = 14354 AND `id` BETWEEN 22 AND 22)
  OR (`entryorguid` = 7332 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 7347 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 7348 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 7352 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 7353 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 10393 AND `id` BETWEEN 16 AND 16)
  OR (`entryorguid` = 10398 AND `id` BETWEEN 12 AND 12)
  OR (`entryorguid` = 10413 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 10425 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 11032 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 5648 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 7246 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 7797 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 8921 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 8933 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 9024 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 9029 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 5277 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 16880 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 16915 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 16977 AND `id` BETWEEN 15 AND 15)
  OR (`entryorguid` = 16978 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 22259 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 22267 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 17877 AND `id` BETWEEN 26 AND 26)
  OR (`entryorguid` = 18088 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 18130 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 18131 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 18285 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 19706 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19729 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19730 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 20196 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 20279 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 20280 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 17088 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 18482 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 18670 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 21651 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 21787 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 22199 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 23066 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 23067 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 23068 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 23219 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 17160 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 18069 AND `id` BETWEEN 19 AND 19)
  OR (`entryorguid` = 18202 AND `id` BETWEEN 5 AND 7)
  OR (`entryorguid` = 18203 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 18207 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 18261 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 18297 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 18391 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 18688 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 19067 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19210 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19945 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19948 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 19973 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 19985 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19988 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19989 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 19990 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19993 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 20600 AND `id` BETWEEN 3 AND 5)
  OR (`entryorguid` = 20924 AND `id` BETWEEN 3 AND 4)
  OR (`entryorguid` = 20925 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 21326 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 21497 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 21956 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 22160 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 22181 AND `id` BETWEEN 10 AND 10)
  OR (`entryorguid` = 22204 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 22221 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 22242 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 22289 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 18850 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 18853 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 19466 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 19541 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 20102 AND `id` BETWEEN 2 AND 10)
  OR (`entryorguid` = 20132 AND `id` BETWEEN 1 AND 5)
  OR (`entryorguid` = 20134 AND `id` BETWEEN 14 AND 14)
  OR (`entryorguid` = 20139 AND `id` BETWEEN 15 AND 15)
  OR (`entryorguid` = 20248 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 20409 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 20607 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 20673 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 20769 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 20928 AND `id` BETWEEN 4 AND 5)
  OR (`entryorguid` = 21337 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 21450 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 21453 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 21503 AND `id` BETWEEN 7 AND 8)
  OR (`entryorguid` = 21506 AND `id` BETWEEN 2 AND 5)
  OR (`entryorguid` = 21663 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 21876 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 22017 AND `id` BETWEEN 15 AND 15)
  OR (`entryorguid` = 22093 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 24960 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 24999 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 25087 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 17264 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 17269 AND `id` BETWEEN 16 AND 17)
  OR (`entryorguid` = 17478 AND `id` BETWEEN 2 AND 4)
  OR (`entryorguid` = 17371 AND `id` BETWEEN 16 AND 17)
  OR (`entryorguid` = 17397 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 17398 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 17477 AND `id` BETWEEN 15 AND 15)
  OR (`entryorguid` = 17626 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 18493 AND `id` BETWEEN 20 AND 20)
  OR (`entryorguid` = 18702 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 28132 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 18320 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 17800 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 19167 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 19231 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 19712 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 19713 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 20059 AND `id` BETWEEN 3 AND 5)
  OR (`entryorguid` = 17994 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 18405 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 18422 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 19507 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 19509 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 19511 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 20866 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 20879 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 20880 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 20882 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 20902 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 18640 AND `id` BETWEEN 14 AND 14)
  OR (`entryorguid` = 18794 AND `id` BETWEEN 34 AND 35)
  OR (`entryorguid` = 16704 AND `id` BETWEEN 24 AND 24)
  OR (`entryorguid` = 17465 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 24683 AND `id` BETWEEN 22 AND 22)
  OR (`entryorguid` = 24684 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 24685 AND `id` BETWEEN 19 AND 19)
  OR (`entryorguid` = 24686 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 24687 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 24688 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 24689 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 24957 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 25428 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 25465 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 25479 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 25584 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 25596 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 25601 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 25613 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 25678 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 25712 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 25716 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 25719 AND `id` BETWEEN 10 AND 10)
  OR (`entryorguid` = 25720 AND `id` BETWEEN 10 AND 10)
  OR (`entryorguid` = 25722 AND `id` BETWEEN 9 AND 9)
  OR (`entryorguid` = 25789 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 26452 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 24014 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 24018 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 24271 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 24677 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 24797 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 26402 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 26467 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 26926 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 26942 AND `id` BETWEEN 11 AND 11)
  OR (`entryorguid` = 27406 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 27539 AND `id` BETWEEN 12 AND 12)
  OR (`entryorguid` = 27564 AND `id` BETWEEN 15 AND 15)
  OR (`entryorguid` = 27725 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 27749 AND `id` BETWEEN 15 AND 15)
  OR (`entryorguid` = 26261 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 26417 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 27259 AND `id` BETWEEN 13 AND 13)
  OR (`entryorguid` = 27959 AND `id` BETWEEN 10 AND 12)
  OR (`entryorguid` = 28779 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 28083 AND `id` BETWEEN 23 AND 23)
  OR (`entryorguid` = 32517 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 30152 AND `id` BETWEEN 6 AND 6)
  OR (`entryorguid` = 30174 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 29648 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 29769 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 29770 AND `id` BETWEEN 1 AND 4)
  OR (`entryorguid` = 29840 AND `id` BETWEEN 1 AND 3)
  OR (`entryorguid` = 30409 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 30922 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 31277 AND `id` BETWEEN 12 AND 12)
  OR (`entryorguid` = 31397 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 32149 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 32262 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 33429 AND `id` BETWEEN 7 AND 7)
  OR (`entryorguid` = 26730 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 26734 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 30111 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 30179 AND `id` BETWEEN 4 AND 4)
  OR (`entryorguid` = 30319 AND `id` BETWEEN 5 AND 5)
  OR (`entryorguid` = 30338 AND `id` BETWEEN 1 AND 2)
  OR (`entryorguid` = 26623 AND `id` BETWEEN 5 AND 6)
  OR (`entryorguid` = 29768 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 29774 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 27965 AND `id` BETWEEN 14 AND 14)
  OR (`entryorguid` = 27639 AND `id` BETWEEN 16 AND 16)
  OR (`entryorguid` = 27640 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 39436 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 46925 AND `id` BETWEEN 5 AND 7)
  OR (`entryorguid` = 41644 AND `id` BETWEEN 3 AND 3)
  OR (`entryorguid` = 42108 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 42112 AND `id` BETWEEN 2 AND 3)
  OR (`entryorguid` = 42113 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 50409 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 46582 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 40577 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 40925 AND `id` BETWEEN 1 AND 1)
  OR (`entryorguid` = 39373 AND `id` BETWEEN 2 AND 2)
  OR (`entryorguid` = 52086 AND `id` BETWEEN 5 AND 6)
  OR (`entryorguid` = 52381 AND `id` BETWEEN 1 AND 1));
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(1781, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 18000, 24000, 0, 11, 82715, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Skitterweb Lurker - In Combat - Cast ''Flee into the Shadows'''),
(1642, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Northshire Guard - In Combat - Cast ''Shoot'''),
(6866, 0, 3, 0, 9, 0, 100, 0, 0, 8, 15800, 18300, 0, 11, 66060, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bodyguard - Within 0-8 Range - Cast ''Sprint'''),
(6866, 0, 4, 0, 0, 0, 100, 0, 5000, 7800, 16800, 17900, 0, 11, 60842, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bodyguard - In Combat - Cast ''Expose Armor'''),
(808, 0, 2, 0, 0, 0, 100, 0, 2000, 4500, 12000, 15000, 0, 11, 79895, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grik''nir the Cold - In Combat - Cast ''Frost Strike'''),
(1260, 0, 3, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 18501, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Great Father Arctikus - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(1260, 0, 4, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 77808, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Great Father Arctikus - On Aggro - Cast ''Battle Shout'' (No Repeat)'),
(8503, 0, 3, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 20793, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gibblewilt - In Combat - Cast ''Fireball'''),
(42291, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 84152, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Crushcog Sentry-Bot - On Aggro - Cast ''Wailing Siren'' (No Repeat)'),
(43230, 0, 2, 0, 0, 0, 100, 0, 4500, 6500, 18000, 19000, 0, 11, 84148, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Crushcog Technician - In Combat - Cast ''Irradiation Gun'''),
(2002, 0, 4, 0, 0, 0, 100, 0, 2000, 4000, 15000, 16000, 0, 11, 6950, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Rascal Sprite - IC - Cast Faerie Fire'),
(2003, 0, 4, 0, 0, 0, 100, 0, 2000, 4000, 3500, 4000, 0, 11, 9613, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadow Sprite - IC - Cast Shadow Bolt'),
(2004, 0, 4, 0, 0, 0, 100, 0, 2000, 4000, 12000, 13000, 0, 11, 5514, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Dark Sprite - IC - Cast Darken Vision'),
(2005, 0, 4, 0, 0, 0, 80, 0, 1000, 1000, 10000, 10000, 0, 11, 5515, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Vicious Grell - In Combat - Cast ''Savagery'' (No Repeat)'),
(2008, 0, 1, 0, 9, 0, 100, 0, 0, 5, 7000, 12000, 0, 11, 41056, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gnarlpine Warrior - Within 0-5 Range - Cast ''Strike'''),
(16522, 0, 14, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 9053, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Surveyor Candress - In Combat - Cast ''Fireball'''),
(17591, 0, 6, 0, 0, 0, 100, 0, 9000, 14000, 16000, 21000, 0, 11, 15691, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Blood Elf Bandit - In Combat - Cast ''Eviscerate'''),
(35660, 0, 4, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, ' Linked - Self: Talk 0 // Rampaging Worgen - Between 0-30% Health - Say Line 0 (No Repeat)'),
(47091, 0, 3, 0, 1, 0, 100, 0, 1, 1, 30000, 30000, 0, 11, 46577, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'When out of combat and timer at the begining between 1 and 1 ms (and later repeats every 30000 and 30000 ms) - Self: Cast spell 46577 on Self // '),
(3099, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Dire Mottled Boar - On Aggro - Cast ''Rushing Charge'' (No Repeat)'),
(3108, 0, 1, 0, 2, 0, 100, 0, 0, 50, 24000, 26000, 0, 11, 79840, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Encrusted Surf Crawler - Between 0-50% Health - Cast ''Harden'''),
(3111, 0, 3, 0, 0, 0, 100, 0, 4000, 4500, 17000, 24500, 0, 11, 80146, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Razormane Quilboar - In Combat - Cast ''Bonk'''),
(3125, 0, 3, 0, 0, 0, 100, 0, 4000, 4500, 32000, 38000, 0, 11, 79687, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Clattering Scorpid - In Combat - Cast Poison (No Repeat)'),
(3127, 0, 1, 0, 0, 0, 100, 0, 3500, 4500, 15000, 24000, 0, 11, 79607, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Venomtail Scorpid - In Combat - Cast ''Venom Splash'''),
(3183, 0, 2, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 35913, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Yarrog Baneshadow - In Combat - Cast ''Fel Fireball'''),
(3183, 0, 3, 0, 1, 0, 100, 1, 1000, 1000, 1000, 1000, 0, 11, 51733, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Yarrog Baneshadow - Out of Combat - Cast ''Shadow Channelling'' (No Repeat)'),
(3183, 0, 4, 0, 0, 0, 100, 0, 8000, 12000, 22000, 29000, 0, 11, 37628, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Yarrog Baneshadow - In Combat - Cast ''Fel Immolate'''),
(3281, 0, 1, 0, 0, 0, 100, 0, 4000, 6000, 18000, 25000, 0, 11, 79607, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sarkoth - In Combat - Cast ''Venom Splash'''),
(5809, 0, 4, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 78894, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Sergeant Curtis - On Aggro - Cast ''Leaping Cleave'' (No Repeat)'),
(5809, 0, 5, 0, 0, 0, 100, 0, 7000, 9000, 22000, 27000, 0, 11, 79726, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sergeant Curtis - In Combat - Cast ''Ticking Time Bomb'''),
(5826, 0, 4, 0, 0, 0, 100, 0, 5000, 6000, 16000, 18000, 0, 11, 80117, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Geolord Mottle - In Combat - Cast ''Earth Spike'''),
(5826, 0, 5, 0, 1, 0, 100, 0, 500, 1000, 600000, 600000, 0, 11, 79927, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Geolord Mottle - Out of Combat - Cast ''Earth Shield'''),
(10676, 0, 3, 0, 9, 0, 100, 0, 0, 20, 7000, 9000, 0, 11, 6533, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Raider Jhash - Within 0-20 Range - Cast ''Net'''),
(39072, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 24000, 32000, 0, 11, 79782, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Naj''tess - In Combat - Cast ''Orb of Corruption'''),
(39317, 0, 1, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Scout - In Combat - Cast ''Shoot'''),
(39317, 0, 2, 0, 9, 0, 100, 0, 0, 10, 15000, 22000, 0, 11, 79584, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Northwatch Scout - Within 0-10 Range - Cast ''Fan of Knives'''),
(15274, 0, 6, 0, 0, 0, 100, 0, 4000, 8000, 8000, 12000, 0, 11, 25602, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Mana Wyrm - In Combat - Cast ''Faerie Fire'''),
(154, 0, 1, 0, 0, 0, 100, 0, 4500, 9500, 17500, 22300, 0, 11, 13443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Greater Fleshripper - In Combat - Cast ''Rend'''),
(391, 0, 7, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Old Murk-Eye - Between 0-30% Health - Say Line 0 (No Repeat)'),
(449, 0, 4, 0, 0, 0, 100, 0, 2000, 4500, 12000, 20000, 0, 11, 75356, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Defias Knuckleduster - In Combat - Cast ''Fisticuffs'''),
(449, 0, 5, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 80597, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Defias Knuckleduster - Between 0-30% Health - Cast ''Bash and Smash'' (No Repeat)'),
(506, 0, 4, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 79853, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sergeant Brashclaw - Between 0-30% Health - Cast ''Evasion'' (No Repeat)'),
(594, 0, 4, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 78894, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Defias Henchman - On Aggro - Cast ''Leaping Cleave'' (No Repeat)'),
(833, 0, 1, 0, 0, 0, 100, 0, 7000, 12000, 24000, 32000, 0, 11, 80362, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Coyote Packleader - In Combat - Cast ''Crushing Bite'''),
(1109, 0, 1, 0, 0, 0, 100, 0, 4500, 9500, 17500, 22300, 0, 11, 13443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Fleshripper - In Combat - Cast ''Rend'''),
(1174, 0, 5, 0, 0, 0, 100, 0, 2000, 4500, 9000, 11000, 0, 11, 81305, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Tunnel Rat Geomancer - In Combat - Cast ''Rock Barrage'''),
(2476, 0, 5, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Gosh-Haldir - Between 0-25% Health - Say Line 0 (No Repeat)'),
(2071, 0, 3, 0, 1, 0, 100, 1, 3000, 5000, 0, 0, 0, 11, 8594, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Moonstalker Matriarch - Out of Combat - Cast ''Summon Moonstalker Runt'' (No Repeat)'),
(2071, 0, 4, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 66060, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Moonstalker Matriarch - On Aggro - Cast ''Sprint'' (No Repeat)'),
(2237, 0, 3, 0, 0, 0, 100, 0, 4000, 4500, 12000, 17000, 0, 11, 75008, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Moonstalker Sire - In Combat - Cast ''Pounce'''),
(2237, 0, 4, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 66060, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Moonstalker Sire - On Aggro - Cast ''Sprint'' (No Repeat)'),
(35111, 0, 10, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 32735, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Runaway Shredder - On Aggro - Cast ''Saw Blade'' (No Repeat)'),
(35759, 0, 2, 0, 0, 0, 100, 0, 4000, 6000, 15000, 18000, 0, 11, 80835, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Balboa - In Combat - Cast ''Thundering Stomp'''),
(36131, 0, 2, 0, 0, 0, 100, 0, 2000, 3000, 9000, 12000, 0, 11, 32011, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Vile Splash - In Combat - Cast ''Water Bolt'''),
(16318, 0, 15, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 28729, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Deatholme Darkmage - On reset - Cast Ribbon of Souls'),
(334, 0, 3, 0, 0, 0, 100, 0, 5000, 5000, 12000, 13000, 0, 11, 79901, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Blood Plague'),
(334, 0, 4, 0, 0, 0, 100, 0, 4000, 4000, 10000, 15000, 0, 11, 79903, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Death Coil'),
(334, 0, 5, 0, 0, 0, 100, 0, 10000, 12000, 10000, 22000, 0, 11, 79902, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Plague Strike'),
(428, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 3427, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Infected Wound'),
(486, 0, 5, 0, 0, 0, 100, 0, 6000, 8000, 18000, 22000, 0, 11, 79893, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Bloodworm'),
(486, 0, 6, 0, 0, 0, 100, 0, 4000, 4000, 10000, 18000, 0, 11, 79887, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Death and Decay'),
(486, 0, 7, 0, 9, 0, 100, 0, 10, 30, 15000, 25000, 0, 11, 79894, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Death Grip on Close'),
(578, 0, 2, 0, 0, 0, 100, 0, 2000, 3000, 13000, 15000, 0, 11, 7357, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc Scout - In Combat - Cast ''Poisonous Stab'''),
(711, 0, 4, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 9613, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Shadow Bolt'),
(4462, 0, 5, 0, 11, 0, 100, 1, 0, 0, 0, 0, 0, 11, 80673, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Camouflage on Spawn'),
(3875, 0, 1, 0, 0, 0, 100, 4, 3000, 3000, 3000, 3000, 0, 11, 91291, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 3000 and 3000 ms (and later repeats every 3000 and 3000 ms) - Self: Cast spell Drain Life (91291) on Random hostile // '),
(4805, 0, 4, 0, 0, 0, 100, 3, 3000, 6000, 0, 0, 0, 11, 15044, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Blackfathom Sea Witch - In Combat - Cast ''Frost Ward'' (No Repeat)'),
(4818, 0, 1, 0, 0, 0, 75, 2, 3000, 5000, 8000, 11000, 0, 11, 22691, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Blindlight Murloc - In Combat - Cast ''Sunder Armor'' (No Repeat) (Normal Dungeon)'),
(4831, 0, 6, 0, 0, 0, 100, 2, 6000, 8500, 9000, 13000, 0, 11, 11831, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Lady Sarevess - In Combat - Cast ''Frost Nova'' (Normal Dungeon)'),
(48, 0, 2, 0, 0, 0, 100, 0, 8000, 9000, 7000, 11000, 0, 11, 85240, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 8000 and 9000 ms (and later repeats every 7000 and 11000 ms) - Self: Cast spell Sundering Cleave (85240) on Victim // '),
(202, 0, 1, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 85236, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'On death - Self: Cast spell Corpse Rot (85236) on Self // '),
(206, 0, 1, 0, 0, 0, 100, 0, 7000, 8000, 20000, 21000, 0, 11, 84308, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Update (In Combat) 7000 min and 8000 max ms (repeat 20000 min 21000 max ms) - Self: Cast spell Furious Howl (84308) on Self // '),
(511, 0, 2, 0, 0, 0, 100, 0, 8000, 9000, 30000, 30000, 0, 11, 83586, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 8000 and 9000 ms (and later repeats every 30000 and 30000 ms) - Self: Cast spell Insane Rambling (83586) on Self // '),
(511, 0, 3, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 85236, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'On death - Self: Cast spell Corpse Rot (85236) on Self // '),
(628, 0, 1, 0, 0, 0, 100, 0, 7000, 8000, 31000, 31000, 0, 11, 80365, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Update (In Combat) 7000 min and 8000 max ms (repeat 31000 min 31000 max ms) - Self: Cast spell Flurry of Claws (80365) on Self // '),
(920, 0, 2, 3, 0, 0, 100, 0, 10000, 10000, 61000, 61000, 0, 11, 85244, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Update (In Combat) 10000 min and 10000 max ms (repeat 61000 min 61000 max ms) - Self: Cast spell Worgen Taint (85244) on Victim // '),
(920, 0, 3, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 11, 98531, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, ' Linked - Self: Cast spell Worgen Taint (98531) on Victim // '),
(930, 0, 2, 0, 0, 0, 100, 0, 25000, 25000, 30000, 30000, 0, 11, 12023, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 25000 and 25000 ms (and later repeats every 30000 and 30000 ms) - Self: Cast spell Web (12023) on Victim // '),
(3946, 0, 4, 0, 0, 0, 100, 0, 6000, 9000, 25000, 32000, 0, 11, 13860, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Velinde Starsong - In Combat - Cast ''Mind Blast'''),
(3946, 0, 5, 0, 0, 0, 100, 0, 5000, 12000, 15000, 27000, 0, 11, 16568, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Velinde Starsong - In Combat - Cast ''Mind Flay'''),
(3946, 0, 6, 0, 2, 0, 100, 0, 0, 50, 17000, 21000, 0, 11, 11640, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Velinde Starsong - Between 0-50% Health - Cast ''Renew'''),
(43761, 0, 11, 0, 11, 0, 100, 1, 0, 0, 0, 0, 0, 11, 8909, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Morbent Fel - On Respawn - Cast ''Unholy Shield'' (No Repeat)'),
(1036, 0, 6, 0, 0, 0, 90, 1, 3000, 5000, 4000, 5000, 0, 11, 78660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Centurion - In Combat - Cast ''Devotion Aura'' (No Repeat)'),
(1036, 0, 7, 0, 0, 0, 70, 0, 1200, 3800, 11900, 13700, 0, 11, 76622, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Dragonmaw Centurion - In Combat - Cast ''Shield Bash'' (No Repeat)'),
(3733, 0, 1, 0, 0, 0, 100, 0, 5000, 5500, 21000, 25000, 0, 11, 78705, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Forsaken Herbalist - In Combat - Cast ''Poison Bottle'''),
(3734, 0, 1, 0, 0, 0, 100, 0, 3000, 4000, 34000, 35000, 0, 11, 78710, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Orc Overseer - In Combat - Cast ''Threatening Shout'''),
(3743, 0, 2, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Foulweald Warrior - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(3745, 0, 3, 0, 9, 0, 100, 0, 0, 8, 18000, 21000, 0, 11, 6817, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Foulweald Pathfinder - Within 0-8 Range - Cast ''Corrupted Agility'''),
(3750, 0, 3, 0, 9, 0, 100, 0, 0, 8, 18000, 21000, 0, 11, 6817, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Foulweald Totemic - Within 0-8 Range - Cast ''Corrupted Agility'''),
(3750, 0, 4, 0, 0, 0, 100, 0, 5000, 7000, 24000, 26000, 0, 11, 39591, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Foulweald Totemic - In Combat - Cast ''Searing Totem'''),
(3752, 0, 4, 0, 0, 0, 100, 0, 4000, 6000, 22000, 29000, 0, 11, 60842, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Xavian Rogue - In Combat - Cast ''Expose Armor'''),
(3763, 0, 3, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 11, 10277, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Felmusk Shadowstalker - In Combat - Cast ''Throw'''),
(3763, 0, 4, 0, 11, 0, 100, 1, 0, 0, 0, 0, 0, 11, 77806, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Felmusk Shadowstalker - On Respawn - Cast ''Stealth'' (No Repeat)'),
(3763, 0, 5, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Felmusk Shadowstalker - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(3770, 0, 1, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bleakheart Shadowstalker - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(3770, 0, 2, 0, 2, 0, 100, 0, 0, 50, 35000, 40000, 0, 11, 77471, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bleakheart Shadowstalker - Between 0-50% Health - Cast ''Shadow Shield'''),
(3770, 0, 3, 0, 11, 0, 100, 1, 0, 0, 0, 0, 0, 11, 77806, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bleakheart Shadowstalker - On Respawn - Cast ''Stealth'' (No Repeat)'),
(3780, 0, 2, 0, 0, 0, 100, 0, 2000, 3000, 120000, 125000, 0, 11, 78810, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Singed Shambler - In Combat - Cast ''Smouldering'''),
(3780, 0, 3, 0, 0, 0, 100, 0, 5000, 7000, 15000, 21000, 0, 11, 78808, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Singed Shambler - In Combat - Cast ''Sunbeam'''),
(3810, 0, 1, 0, 0, 0, 100, 0, 2000, 4500, 12000, 20000, 0, 11, 84867, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Elder Ashenvale Bear - In Combat - Cast ''Sundering Swipe'''),
(3846, 0, 1, 0, 0, 0, 100, 0, 2000, 4500, 12000, 20000, 0, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Talen - In Combat - Cast ''Strike'''),
(3846, 0, 2, 0, 0, 0, 100, 0, 6000, 8000, 25000, 29000, 0, 11, 11977, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Talen - In Combat - Cast ''Rend'''),
(3847, 0, 1, 0, 2, 0, 100, 0, 0, 40, 14000, 21000, 0, 11, 62804, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Orendil Broadleaf - Between 0-40% Health - Cast ''Rejuvenation'''),
(3917, 0, 2, 0, 0, 0, 100, 0, 8000, 8000, 20000, 25000, 0, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Befouled Water Elemental - In Combat - Cast ''Splash'''),
(3921, 0, 4, 0, 0, 0, 100, 0, 5000, 6000, 24000, 32000, 0, 11, 8078, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Thistlefur Ursa - In Combat - Cast ''Thunderclap'''),
(3921, 0, 5, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 3490, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Thistlefur Ursa - Between 0-30% Health - Cast ''Frenzied Rage'' (No Repeat)'),
(3922, 0, 3, 0, 0, 0, 100, 0, 5000, 9000, 21000, 35000, 0, 11, 78770, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Thistlefur Totemic - In Combat - Cast ''Magma Totem'''),
(3924, 0, 4, 0, 0, 0, 100, 0, 5000, 8000, 25000, 29000, 0, 11, 39591, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Thistlefur Shaman - In Combat - Cast ''Searing Totem'''),
(3925, 0, 4, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 75002, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Thistlefur Avenger - On Aggro - Cast ''Leaping Rush'' (No Repeat)'),
(3943, 0, 3, 0, 9, 0, 100, 0, 0, 5, 15000, 20000, 0, 11, 77522, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ruuzel - Within 0-5 Range - Cast ''Swoop'''),
(3943, 0, 4, 0, 9, 0, 100, 0, 0, 30, 28000, 32000, 0, 11, 78747, 0, 0, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 'Ruuzel - Within 0-30 Range - Cast ''Hand of Azshara'''),
(3944, 0, 3, 0, 0, 0, 100, 0, 4000, 7000, 17000, 28000, 0, 11, 17140, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Wrathtail Priestess - In Combat - Cast ''Holy Fire'''),
(3944, 0, 4, 0, 2, 0, 100, 0, 0, 50, 45000, 57000, 0, 11, 11835, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wrathtail Priestess - Between 0-50% Health - Cast ''Power Word: Shield'''),
(10559, 0, 3, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 32011, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lady Vespia - In Combat - Cast ''Water Bolt'''),
(10559, 0, 4, 0, 9, 0, 100, 0, 0, 10, 15000, 16000, 0, 11, 78542, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Lady Vespia - Within 0-10 Range - Cast ''Splash'''),
(10641, 0, 2, 0, 9, 0, 100, 0, 0, 30, 9000, 11000, 0, 11, 33844, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Branch Snapper - Within 0-30 Range - Cast ''Entangling Roots'''),
(10641, 0, 3, 0, 0, 0, 100, 0, 5000, 7000, 15000, 21000, 0, 11, 78808, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Branch Snapper - In Combat - Cast ''Sunbeam'''),
(10642, 0, 2, 0, 0, 0, 100, 0, 2000, 3000, 120000, 125000, 0, 11, 6873, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Eck''alom - In Combat - Cast ''Foul Chill'''),
(10642, 0, 3, 0, 0, 0, 100, 0, 8000, 8000, 20000, 25000, 0, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eck''alom - In Combat - Cast ''Splash'''),
(11697, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 18000, 24000, 0, 11, 18543, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Mannoroc Lasher - In Combat - Cast ''Flame Lash'''),
(12474, 0, 3, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Emeraldon Boughguard - On Aggro - Cast ''Rushing Charge'' (No Repeat)'),
(12475, 0, 2, 0, 0, 0, 100, 0, 4000, 4500, 12000, 14000, 0, 11, 78921, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Emeraldon Tree Warder - In Combat - Cast ''Dream Lash'''),
(12476, 0, 2, 0, 0, 0, 100, 0, 2000, 4500, 9000, 18000, 0, 11, 9591, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Emeraldon Oracle - In Combat - Cast ''Acid Spit'''),
(12759, 0, 4, 0, 0, 0, 100, 0, 8000, 8000, 20000, 25000, 0, 11, 78542, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tideress - In Combat - Cast ''Splash'''),
(14733, 0, 17, 0, 9, 0, 100, 0, 0, 5, 12000, 17000, 0, 11, 15496, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sentinel Farsong - Within 0-5 Range - Cast ''Cleave'''),
(14753, 0, 19, 0, 9, 0, 100, 0, 5, 30, 22000, 27000, 0, 11, 21390, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Illiyana Moonblaze - Within 5-30 Range - Cast ''Multi-Shot'''),
(34295, 0, 7, 0, 0, 0, 100, 0, 2000, 2000, 15000, 18000, 0, 11, 65214, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Lord Magmathar - In Combat - Cast ''Lordly Immolate'''),
(2270, 0, 8, 0, 0, 0, 100, 0, 3000, 5000, 120000, 125000, 0, 11, 32064, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Battle Shout'),
(2270, 0, 9, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 22120, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Charge on Aggro'),
(2319, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 20000, 22000, 0, 11, 13323, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Polymorph'),
(2344, 0, 3, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 8258, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Dun Garok Mountaineer - On Reset - Cast Devotion Aura'),
(2358, 0, 5, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 79858, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Frostbolt'),
(2358, 0, 6, 0, 2, 0, 100, 1, 0, 40, 0, 0, 0, 11, 87179, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Summon Water Elemental at 40% HP'),
(2369, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 12555, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Pummel'),
(2555, 0, 3, 0, 0, 0, 100, 0, 5000, 8000, 25000, 37000, 0, 11, 39591, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Searing Totem'),
(2560, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 15000, 15000, 0, 11, 83366, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Howling Screech'),
(2566, 0, 3, 0, 9, 0, 100, 0, 0, 8, 15000, 25000, 0, 11, 84709, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Stomp on Close'),
(2585, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 7164, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Defensive Stance on Aggro'),
(2591, 0, 3, 0, 0, 0, 100, 0, 8000, 8000, 18000, 25000, 0, 11, 8364, 1, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Blizzard'),
(2599, 0, 4, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 80182, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Uppercut'),
(2602, 0, 3, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 20822, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Frostbolt'),
(2606, 0, 3, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 32064, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Battle Shout on Aggro'),
(2619, 0, 3, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 15572, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Sunder Armor'),
(2619, 0, 4, 0, 2, 0, 100, 1, 0, 40, 0, 0, 0, 11, 82836, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Blood Fury at 40% HP'),
(2761, 0, 1, 0, 0, 0, 100, 0, 1400, 7300, 25600, 32300, 0, 11, 11831, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cresting Exile - In Combat - Cast Frost Nova'),
(2783, 0, 2, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 9613, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Shadow Bolt'),
(10696, 0, 2, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Shoot'),
(15126, 0, 3, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 32064, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Battle Shout on Aggro'),
(942, 0, 3, 0, 0, 0, 100, 0, 1000, 3000, 3000, 4000, 0, 11, 57780, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Kurzen Witch Doctor - In Combat - Cast ''Searing Totem'' (No Repeat)'),
(4458, 0, 2, 0, 0, 0, 100, 0, 0, 0, 2600, 4800, 0, 11, 10277, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkgill Hunter - In Combat CMC - Cast ''Throw'''),
(4459, 0, 2, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 0, 11, 9532, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkgill Oracle - In Combat CMC - Cast ''Lightning Bolt'''),
(4460, 0, 2, 0, 0, 0, 100, 0, 1000, 1000, 1800000, 1800000, 0, 11, 12544, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkgill Lord - Out of Combat - Cast ''Frost Armor'''),
(4460, 0, 3, 0, 0, 0, 100, 0, 0, 0, 2400, 3800, 0, 11, 9672, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkgill Lord - In Combat CMC - Cast ''Frostbolt'''),
(4460, 0, 4, 0, 0, 0, 100, 0, 6000, 9000, 15000, 18500, 0, 11, 11831, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Spellbinder - In Combat - Cast ''Frost Nova'''),
(41437, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 81505, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Pump Controller - On Aggro - Cast ''Rocket Launched Support Shredder'' (No Repeat)'),
(7079, 0, 1, 0, 0, 0, 100, 1, 1000, 2000, 0, 0, 0, 75, 10341, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Viscous Fallout - In Combat - Add Aura ''Radiation Cloud'''),
(7079, 0, 2, 0, 0, 0, 100, 0, 2000, 9000, 11000, 14000, 0, 11, 9459, 64, 0, 0, 0, 0, 17, 0, 50, 0, 0, 0, 0, 0, 0, 'Viscous Fallout - In Combat CMC - Cast ''Corrosive Ooze'''),
(689, 0, 2, 0, 0, 0, 75, 0, 5000, 5000, 16000, 16000, 0, 11, 3635, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Crystal Spine Basilisk - In Combat - Cast ''Crystal Gaze'' (No Repeat) (Normal Dungeon)'),
(1562, 0, 3, 0, 9, 0, 100, 0, 0, 8, 15000, 25000, 0, 11, 75062, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Frost Nova on Close'),
(2522, 0, 2, 0, 1, 0, 100, 1, 1000, 1500, 0, 0, 0, 11, 22766, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Jaguero Stalker - Out of Combat - Cast ''Sneak'' (No Repeat)'),
(2545, 0, 7, 0, 0, 0, 100, 0, 2700, 4600, 8700, 9600, 0, 11, 14873, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, '"Pretty Boy" Duncan - In Combat - Cast ''Sinister Strike'''),
(4457, 0, 2, 0, 0, 0, 100, 0, 1000, 2000, 19900, 30000, 0, 11, 13443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkgill Forager - In Combat - Cast ''Rend'''),
(4457, 0, 3, 0, 0, 0, 100, 0, 2600, 2600, 3700, 9100, 0, 11, 744, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkgill Forager - In Combat - Cast ''Poison'''),
(43376, 0, 12, 0, 0, 0, 100, 0, 0, 0, 3500, 4100, 0, 11, 38558, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Throw'),
(43376, 0, 13, 0, 0, 0, 100, 0, 5000, 5000, 12000, 13000, 0, 11, 54962, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Ticking Bomb'),
(43377, 0, 9, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 83017, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Insect Swarm'),
(43377, 0, 10, 0, 0, 0, 100, 0, 0, 0, 3500, 4700, 0, 11, 78907, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Starfire'),
(43377, 0, 11, 0, 0, 0, 100, 0, 10000, 10000, 15000, 18000, 0, 11, 79823, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Starfall'),
(43659, 0, 8, 0, 0, 0, 100, 0, 5000, 6000, 12000, 15000, 0, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Cleave'),
(43659, 0, 9, 0, 0, 0, 100, 0, 10000, 10000, 18000, 19000, 0, 11, 3583, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Deadly Poison'),
(43660, 0, 8, 0, 9, 0, 100, 0, 0, 10, 19000, 22000, 0, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Demoralizing Shout on Close'),
(43660, 0, 9, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 34159, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Hulk at 30% HP'),
(3374, 0, 2, 0, 0, 0, 100, 0, 2000, 4500, 12000, 14000, 0, 11, 57846, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bael''dun Excavator - In Combat - Cast ''Heroic Strike'''),
(37091, 0, 2, 0, 11, 0, 100, 1, 0, 0, 0, 0, 0, 11, 80807, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Deviate Plainstrider - On Respawn - Cast ''Sand Blast'' (No Repeat)'),
(37171, 0, 6, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Escaped Stonetalon Prisoner - Between 0-30% Health - Say Line 0 (No Repeat)'),
(4666, 0, 1, 0, 0, 0, 100, 0, 4000, 5000, 60000, 65000, 0, 11, 77645, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Burning Blade Felsworn - In Combat - Cast ''Felblood'''),
(4667, 0, 3, 0, 1, 0, 100, 1, 1000, 1000, 1000, 1000, 0, 11, 74919, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Burning Blade Shadowmage - Out of Combat - Cast ''Shadow Channeling'' (No Repeat)'),
(4667, 0, 4, 0, 0, 0, 100, 0, 2000, 3000, 60000, 65000, 0, 11, 77645, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Burning Blade Shadowmage - In Combat - Cast ''Felblood'''),
(4667, 0, 5, 0, 0, 0, 100, 0, 6000, 7000, 15000, 21000, 0, 11, 77722, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Burning Blade Shadowmage - In Combat - Cast ''Void Whip'''),
(4670, 0, 3, 0, 11, 0, 100, 1, 0, 0, 0, 0, 0, 11, 77806, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hatefury Rogue - On Respawn - Cast ''Stealth'' (No Repeat)'),
(4672, 0, 2, 0, 0, 0, 100, 0, 3000, 4500, 18000, 22000, 0, 11, 77469, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Hatefury Felsworn - In Combat - Cast ''Taint of Sargeras'''),
(4674, 0, 3, 0, 2, 0, 100, 0, 0, 30, 45000, 51000, 0, 11, 77471, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hatefury Shadowstalker - Between 0-30% Health - Cast ''Shadow Shield'''),
(4675, 0, 8, 0, 0, 0, 100, 0, 3000, 4500, 21000, 25000, 0, 11, 77425, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Hatefury Hellcaller - In Combat - Cast ''Immolate'''),
(4675, 0, 9, 0, 1, 0, 100, 1, 3000, 5000, 0, 0, 0, 11, 77426, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hatefury Hellcaller - Out of Combat - Cast ''Summon Burning Minion'' (No Repeat)'),
(4728, 0, 1, 0, 0, 0, 100, 0, 4000, 5000, 18000, 25000, 0, 11, 77503, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gritjaw Basilisk - In Combat - Cast ''Petrifying Stare'''),
(4729, 0, 1, 0, 0, 0, 100, 0, 4000, 5000, 18000, 25000, 0, 11, 77503, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Hulking Gritjaw Basilisk - In Combat - Cast ''Petrifying Stare'''),
(5760, 0, 2, 0, 0, 0, 100, 0, 4000, 8000, 22000, 27000, 0, 11, 68545, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lord Azrethoc - In Combat - Cast ''Lord Azrethoc''s Bellow'''),
(5760, 0, 3, 0, 0, 0, 100, 0, 2000, 3000, 18000, 25000, 0, 11, 68548, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lord Azrethoc - In Combat - Cast ''Shadow Torch'''),
(5760, 0, 4, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 68541, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Lord Azrethoc - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(35412, 0, 2, 0, 0, 0, 100, 0, 2000, 3500, 12000, 14000, 0, 11, 15611, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Rejuvenated Thunder Lizard - In Combat - Cast ''Lizard Bolt'''),
(35412, 0, 3, 0, 0, 0, 100, 0, 6000, 8000, 24000, 27000, 0, 11, 77601, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Rejuvenated Thunder Lizard - In Combat - Cast ''Lightning Nova'''),
(36094, 0, 4, 0, 0, 0, 100, 0, 4000, 5000, 18000, 22000, 0, 11, 5568, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Enraged Kodo - In Combat - Cast ''Trample'''),
(36094, 0, 5, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 18501, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Enraged Kodo - Between 0-30% Health - Cast ''Enrage'' (No Repeat)'),
(2574, 0, 3, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 82617, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Heave'),
(2657, 0, 2, 0, 0, 0, 100, 0, 2000, 4500, 14000, 15000, 0, 11, 3147, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Trained Razorbeak - In Combat - Cast ''Rend Flesh'''),
(42536, 0, 3, 0, 0, 0, 100, 0, 5000, 7000, 16000, 18000, 0, 11, 80182, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Revantusk Stalker - In Combat - Cast ''Uppercut'''),
(42555, 0, 3, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 9613, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Revantusk Hexxer - In Combat - Cast ''Shadow Bolt'''),
(42555, 0, 4, 0, 0, 0, 100, 0, 7000, 8000, 30000, 33000, 0, 11, 18267, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Revantusk Hexxer - In Combat - Cast ''Curse of Weakness'''),
(42555, 0, 5, 0, 0, 0, 100, 0, 11000, 12000, 18000, 20000, 0, 11, 16568, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Revantusk Hexxer - In Combat - Cast ''Mind Flay'''),
(4344, 0, 1, 0, 0, 0, 100, 0, 2000, 4500, 12000, 20000, 0, 11, 90171, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Mottled Drywallow Crocolisk - In Combat - Cast ''Jagged Tooth Snap'''),
(4345, 0, 1, 0, 0, 0, 100, 0, 3000, 3000, 45000, 50000, 0, 11, 6016, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Drywallow Daggermaw - In Combat - Cast ''Pierce Armor'''),
(4393, 0, 2, 0, 0, 0, 100, 0, 2000, 3000, 17000, 21000, 0, 11, 73135, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Acidic Swamp Ooze - In Combat - Cast ''Old Friends: Quest Accept & Bind'''),
(4394, 0, 2, 0, 0, 0, 100, 0, 2000, 3000, 17000, 21000, 0, 11, 73135, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bubbling Swamp Ooze - In Combat - Cast ''Old Friends: Quest Accept & Bind'''),
(4967, 0, 2, 0, 1, 0, 100, 0, 500, 1000, 1800000, 1800000, 0, 11, 7120, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Archmage Tervosh - Out of Combat - Cast ''Proudmoore''s Defense'''),
(4979, 0, 10, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 11, 95826, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Theramore Guard - In Combat - Cast ''Shoot'''),
(4979, 0, 11, 0, 2, 0, 100, 0, 0, 50, 12000, 13000, 0, 11, 12169, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Theramore Guard - Between 0-50% Health - Cast ''Shield Block'''),
(4979, 0, 12, 0, 0, 0, 100, 0, 3000, 4000, 12000, 15000, 0, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Theramore Guard - In Combat - Cast ''Revenge'''),
(1783, 0, 1, 0, 2, 0, 100, 0, 0, 60, 22000, 25000, 0, 11, 85521, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Vile Aegis at 60% HP'),
(1784, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 85434, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Tombkeeper''s Curse'),
(1815, 0, 6, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 85842, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Survival Instincts at 30% HP'),
(1831, 0, 2, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 17164, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Scarlet Hunter - On Reset - Cast to summon Scarlet Hound'),
(1852, 0, 4, 0, 0, 0, 100, 0, 18000, 23000, 50000, 65000, 0, 11, 83701, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Summon Berserkers'),
(44482, 0, 2, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 85842, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Survival Instincts at 30% HP'),
(5268, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 75002, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Ironfur Bear - On Aggro - Cast ''Leaping Rush'' (No Repeat)'),
(5268, 0, 2, 0, 2, 0, 100, 0, 0, 40, 18000, 21000, 0, 11, 81122, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ironfur Bear - Between 0-40% Health - Cast ''Ironfur'''),
(5278, 0, 3, 0, 0, 0, 100, 0, 2000, 3000, 11000, 12000, 0, 11, 50273, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sprite Darter - In Combat - Cast ''Arcane Barrage'''),
(5286, 0, 1, 0, 0, 0, 100, 0, 4000, 5000, 17000, 20000, 0, 11, 3149, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Longtooth Runner - In Combat - Cast ''Furious Howl'''),
(5359, 0, 1, 0, 0, 0, 100, 0, 2000, 3000, 12000, 14000, 0, 11, 79810, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shore Strider - In Combat - Cast ''Frost Cleave'''),
(5359, 0, 2, 0, 0, 0, 100, 0, 7000, 9000, 18000, 23000, 0, 11, 10987, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Shore Strider - In Combat - Cast ''Geyser'''),
(11443, 0, 16, 0, 0, 0, 100, 0, 1000, 3000, 9000, 9000, 0, 11, 20822, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gordok Ogre-Mage - IC - Cast ''Frostbolt'''),
(8519, 0, 8, 0, 0, 0, 100, 0, 5000, 8000, 24000, 25000, 0, 11, 16555, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Drowning Death'),
(8520, 0, 7, 0, 0, 0, 100, 0, 5000, 8000, 24000, 25000, 0, 11, 16555, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Drowning Death'),
(8520, 0, 8, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 14099, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Mighty Blow'),
(8521, 0, 3, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 85873, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Flow of Gratitude on Aggro'),
(8522, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 24000, 25000, 0, 11, 16555, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Drowning Death'),
(8522, 0, 3, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 85873, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Flow of Gratitude on Aggro'),
(8526, 0, 2, 0, 0, 0, 100, 0, 8000, 8000, 17000, 19000, 0, 11, 11639, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Shadow Word: Pain'),
(8535, 0, 1, 0, 0, 0, 100, 0, 7000, 9000, 14000, 19000, 0, 11, 16573, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Putrid Bile'),
(8541, 0, 2, 0, 9, 0, 100, 0, 0, 5, 25000, 25000, 0, 11, 6605, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Terrifying Screech on Close'),
(8551, 0, 3, 0, 1, 0, 100, 1, 1000, 1000, 1000, 1000, 0, 11, 51733, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Shadow Aura on Spawn'),
(9450, 0, 4, 0, 2, 0, 100, 0, 0, 40, 22000, 25000, 0, 11, 25058, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Renew at 40% HP'),
(9452, 0, 2, 0, 9, 0, 100, 0, 0, 8, 15000, 25000, 0, 11, 11975, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Arcane Explosion on Close'),
(10824, 0, 19, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 12057, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Strike'),
(11896, 0, 2, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 6917, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Venom Spit'),
(12261, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 22000, 25000, 0, 11, 3427, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Infected Wound'),
(16184, 0, 2, 0, 13, 0, 100, 0, 20000, 30000, 0, 0, 0, 11, 32322, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Dark Shriek on Player Spell Cast'),
(40959, 0, 4, 0, 9, 0, 100, 0, 0, 5, 15000, 17000, 0, 11, 80182, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Den Whomper - Within 0-5 Range - Cast ''Uppercut'''),
(40959, 0, 5, 0, 2, 0, 100, 0, 0, 60, 14000, 16000, 0, 11, 4955, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Den Whomper - Between 0-60% Health - Cast ''Fist of Stone'''),
(40959, 0, 6, 0, 2, 0, 100, 0, 0, 30, 32000, 35000, 0, 11, 21049, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Den Whomper - Between 0-30% Health - Cast ''Bloodlust'''),
(41131, 0, 2, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 13901, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Mad Magus Tirth - In Combat - Cast ''Arcane Bolt'''),
(41131, 0, 3, 0, 9, 0, 100, 0, 0, 8, 13600, 14500, 0, 11, 11975, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Mad Magus Tirth - Within 0-8 Range - Cast ''Arcane Explosion'''),
(41131, 0, 4, 0, 2, 0, 100, 0, 0, 40, 33000, 35000, 0, 11, 6742, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Mad Magus Tirth - Between 0-40% Health - Cast ''Bloodlust'''),
(41131, 0, 5, 0, 0, 0, 100, 0, 5000, 7000, 18000, 20000, 0, 11, 13747, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Mad Magus Tirth - In Combat - Cast ''Slow'''),
(41196, 0, 12, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 11, 38557, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Kravel Koalbeard - In Combat - Cast ''Throw'''),
(41199, 0, 12, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Trackmaster Zherin - In Combat - Cast ''Shoot'''),
(41199, 0, 13, 0, 9, 0, 100, 0, 0, 5, 13000, 14000, 0, 11, 57846, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Trackmaster Zherin - Within 0-5 Range - Cast ''Heroic Strike'''),
(47487, 0, 1, 0, 0, 0, 100, 0, 2000, 4500, 12000, 13000, 0, 11, 40505, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Twilight Subduer - In Combat - Cast ''Cleave'''),
(47602, 0, 6, 0, 9, 0, 100, 0, 5, 30, 5000, 6000, 0, 11, 79866, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Codemaster Deethuk - Within 5-30 Range - Cast ''Deadly Throw'''),
(47602, 0, 7, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 79864, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Codemaster Deethuk - Between 0-30% Health - Cast ''Shadowstep'' (No Repeat)'),
(47602, 0, 8, 0, 0, 0, 100, 0, 8000, 11000, 23000, 26500, 0, 11, 79863, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Codemaster Deethuk - In Combat - Cast ''Hemorrhage'''),
(47619, 0, 6, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 79564, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Elementalist Starion - In Combat - Cast ''Twilight Fireball'''),
(47619, 0, 7, 0, 0, 0, 100, 0, 5000, 7000, 12000, 14000, 0, 11, 80117, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Elementalist Starion - In Combat - Cast ''Earth Spike'''),
(47619, 0, 8, 0, 0, 0, 100, 0, 9000, 12000, 24000, 27000, 0, 11, 79886, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Elementalist Starion - In Combat - Cast ''Lava Burst'''),
(47619, 0, 9, 0, 0, 0, 100, 0, 4000, 17000, 25000, 36000, 0, 11, 88771, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Elementalist Starion - In Combat - Cast ''Twilight Immolate'''),
(47620, 0, 6, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 32064, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Commander Fastfuse - On Aggro - Cast ''Battle Shout'' (No Repeat)'),
(47620, 0, 7, 0, 2, 0, 100, 0, 0, 40, 20000, 21000, 0, 11, 79878, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Commander Fastfuse - Between 0-40% Health - Cast ''Bloodthirst'''),
(47620, 0, 8, 0, 0, 0, 100, 0, 2000, 4500, 16000, 17000, 0, 11, 11977, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Commander Fastfuse - In Combat - Cast ''Rend'''),
(47620, 0, 9, 0, 0, 0, 100, 0, 8000, 9000, 22000, 28000, 0, 11, 79881, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Commander Fastfuse - In Combat - Cast ''Slam'''),
(2717, 0, 2, 0, 9, 0, 100, 0, 0, 5, 17000, 27000, 0, 11, 90208, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Mauler Mash on Close'),
(2739, 0, 3, 0, 0, 0, 100, 0, 5000, 5000, 12000, 13000, 0, 11, 76622, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Sunder Armor'),
(2740, 0, 3, 0, 1, 0, 100, 0, 500, 1000, 600000, 600000, 0, 11, 79934, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Demon Armor on Spawn'),
(5429, 0, 4, 0, 9, 0, 100, 0, 0, 8, 19000, 22000, 0, 11, 24423, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Fire Roc - Within 0-8 Range - Cast ''Demoralizing Screech'''),
(5450, 0, 2, 0, 0, 0, 100, 0, 2000, 3000, 9000, 9800, 0, 11, 3391, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hazzali Stinger - In Combat - Cast ''Thrash'''),
(5450, 0, 3, 0, 0, 0, 100, 0, 6000, 7000, 25000, 27000, 0, 11, 81224, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Hazzali Stinger - In Combat - Cast ''Silithid Toxin'''),
(5451, 0, 6, 0, 0, 0, 100, 0, 6000, 7000, 25000, 27000, 0, 11, 81224, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Hazzali Swarmer - In Combat - Cast ''Silithid Toxin'''),
(5455, 0, 2, 0, 0, 0, 100, 0, 3500, 3500, 18500, 22000, 0, 11, 81109, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Centipaar Wasp - In Combat - Cast ''Poison Bolt'''),
(5455, 0, 3, 0, 0, 0, 100, 0, 4000, 4000, 60000, 65000, 0, 11, 81224, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Centipaar Wasp - In Combat - Cast ''Silithid Toxin'''),
(5459, 0, 2, 0, 0, 0, 100, 0, 4000, 4000, 60000, 65000, 0, 11, 81224, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Centipaar Tunneler - In Combat - Cast ''Silithid Toxin'''),
(5645, 0, 1, 0, 0, 0, 100, 0, 2000, 4500, 15000, 18000, 0, 11, 81705, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sandfury Hideskinner - In Combat - Cast ''Scalp Slash'''),
(5647, 0, 3, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 82641, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sandfury Firecaller - In Combat - Cast ''Lava Gout'''),
(5647, 0, 4, 0, 0, 0, 100, 0, 9000, 12000, 33000, 35000, 0, 11, 79886, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sandfury Firecaller - In Combat - Cast ''Lava Burst'''),
(7855, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 83622, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Southsea Pirate - On Aggro - Cast ''Leaping Cleave'' (No Repeat)'),
(7858, 0, 2, 0, 0, 0, 100, 0, 2000, 4500, 12000, 14000, 0, 11, 75361, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Southsea Swashbuckler - In Combat - Cast ''Swashbuckling Slice'''),
(7858, 0, 3, 0, 13, 0, 100, 0, 20000, 30000, 0, 0, 0, 11, 79732, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Southsea Swashbuckler - On Victim Casting ''Alexander''s Test Periodic Aura'' - Cast ''Shield Bash'''),
(39081, 0, 2, 0, 6, 0, 100, 1, 0, 0, 0, 0, 0, 11, 73441, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hazzali Cocoon - On Just Died - Cast ''Summon Captured Bughunter'' (No Repeat)'),
(9516, 0, 2, 0, 9, 0, 100, 0, 0, 5, 12000, 21000, 0, 11, 16247, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lord Banehollow - Within 0-5 Range - Cast ''Curse of Thorns'''),
(9516, 0, 3, 0, 9, 0, 100, 0, 0, 15, 8000, 13000, 0, 11, 17399, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lord Banehollow - Within 0-15 Range - Cast ''Shadow Shock'''),
(9516, 0, 4, 0, 0, 0, 100, 0, 4000, 5000, 19000, 27000, 0, 11, 37624, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lord Banehollow - In Combat - Cast ''Carrion Swarm'''),
(9516, 0, 5, 0, 0, 0, 100, 0, 2000, 11000, 12000, 22000, 0, 11, 92713, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lord Banehollow - In Combat - Cast ''Mind Blast'''),
(48259, 0, 3, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 32735, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Irontree Shredder - On Aggro - Cast ''Saw Blade'' (No Repeat)'),
(48331, 0, 9, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 36099, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Panicking Worker - On Aggro - Cast ''Throw Hammer'' (No Repeat)'),
(48331, 0, 10, 0, 2, 0, 100, 0, 0, 30, 15000, 17000, 0, 11, 30615, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Panicking Worker - Between 0-30% Health - Cast ''Fear'''),
(5840, 0, 9, 0, 0, 0, 100, 0, 5000, 7000, 15000, 20000, 0, 11, 11983, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Steamsmith - In Combat - Cast ''Steam Jet'''),
(5846, 0, 2, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 22120, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Taskmaster - On Aggro - Cast ''Charge'' (No Repeat)'),
(5846, 0, 3, 0, 0, 0, 100, 0, 5000, 7000, 120000, 125000, 0, 11, 32064, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Dark Iron Taskmaster - In Combat - Cast ''Battle Shout'''),
(5856, 0, 7, 0, 0, 0, 100, 0, 4000, 4500, 16000, 20000, 0, 11, 744, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Glassweb Spider - In Combat - Cast ''Poison'''),
(5856, 0, 8, 0, 9, 0, 100, 0, 0, 20, 8000, 9000, 0, 11, 745, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Glassweb Spider - Within 0-20 Range - Cast ''Web'''),
(8391, 0, 5, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 9613, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lathoric the Black - In Combat - Cast ''Shadow Bolt'''),
(8391, 0, 6, 0, 0, 0, 100, 0, 6000, 9000, 15000, 17000, 0, 11, 32063, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lathoric the Black - In Combat - Cast ''Corruption'''),
(8400, 0, 21, 0, 0, 0, 100, 0, 5000, 8000, 18000, 20000, 0, 11, 84165, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Obsidion - In Combat - Cast ''Flame Blast'''),
(47311, 0, 3, 0, 0, 0, 100, 0, 3000, 12000, 25000, 29000, 0, 11, 78906, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Minister Finister - In Combat - Cast ''Goblin Orderly'''),
(615, 0, 4, 0, 2, 0, 100, 1, 0, 55, 0, 0, 0, 11, 82836, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Blood Fury at 55% HP'),
(615, 0, 5, 0, 0, 0, 100, 0, 5000, 6000, 14000, 15000, 0, 11, 11971, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Sunder Armor'),
(615, 0, 6, 0, 11, 0, 100, 1, 0, 0, 0, 0, 0, 11, 80676, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Spyglass on Spawn'),
(7025, 0, 2, 0, 2, 0, 100, 0, 0, 55, 22000, 25000, 0, 11, 48153, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Improved Blocking at 55% HP'),
(7027, 0, 2, 0, 0, 0, 100, 0, 5000, 6000, 12000, 13000, 0, 11, 87081, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Strike'),
(7035, 0, 3, 0, 0, 0, 100, 0, 5000, 5500, 12000, 13000, 0, 11, 87081, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Strike'),
(7038, 0, 3, 0, 0, 0, 100, 0, 4000, 5000, 12000, 13000, 0, 11, 14873, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Sinister Strike'),
(7038, 0, 4, 0, 2, 0, 100, 0, 0, 40, 15000, 15000, 0, 11, 80576, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Shadowstep at 40% HP'),
(9697, 0, 3, 0, 2, 0, 100, 0, 0, 55, 22000, 25000, 0, 11, 3149, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Furious Howl at 55% HP'),
(9776, 0, 3, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 15664, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Venom Spit'),
(10078, 0, 4, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 11962, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Immolate'),
(48111, 0, 7, 0, 9, 0, 100, 0, 0, 8, 15000, 25000, 0, 11, 6266, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Kodo Stomp on Close'),
(48119, 0, 3, 0, 9, 0, 100, 0, 0, 100, 15000, 25000, 0, 11, 89596, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Unmask on Close'),
(48121, 0, 3, 0, 0, 0, 100, 0, 7000, 8000, 17000, 22000, 0, 11, 79846, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Flamestrike'),
(48121, 0, 4, 0, 9, 0, 100, 0, 0, 100, 15000, 25000, 0, 11, 89596, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Unmask on Close'),
(48121, 0, 5, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 9053, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Fireball'),
(48201, 0, 3, 0, 2, 0, 100, 0, 0, 55, 22000, 25000, 0, 11, 3248, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Improved Blocking at 55% HP'),
(48201, 0, 4, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 12170, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Revenge'),
(6557, 0, 7, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 14146, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Primal Ooze - Between 0-30% Health - Cast Clone (No Repeat)'),
(46714, 0, 3, 0, 9, 0, 100, 0, 5, 30, 10000, 20000, 0, 11, 80012, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Chimera Shot on Close'),
(46770, 0, 3, 0, 1, 0, 100, 1, 8000, 15000, 0, 0, 0, 11, 87116, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Ritual of Summoning - Summon Portal'),
(46775, 0, 2, 0, 1, 0, 100, 1, 8000, 15000, 0, 0, 0, 11, 87116, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Ritual of Summoning - Summon Portal'),
(5983, 0, 1, 0, 0, 0, 100, 0, 2000, 4500, 12000, 14000, 0, 11, 37945, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bonepicker Felfeeder - In Combat - Cast ''Fel Fireball'''),
(5998, 0, 2, 0, 9, 0, 100, 0, 0, 8, 14000, 15000, 0, 11, 81140, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Nethergarde Foreman - Within 0-8 Range - Cast ''Thunderclap'''),
(6004, 0, 2, 0, 2, 0, 100, 1, 0, 30, 0, 0, 0, 11, 84325, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowsworn Ritualist - Between 0-30% Health - Cast ''Fel-Infused'' (No Repeat)'),
(6005, 0, 3, 0, 9, 0, 100, 0, 0, 5, 18000, 22000, 0, 11, 80182, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowsworn Thug - Within 0-5 Range - Cast ''Uppercut'''),
(6005, 0, 4, 0, 0, 0, 100, 0, 2000, 4500, 15000, 15500, 0, 11, 3148, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowsworn Thug - In Combat - Cast ''Head Crack'''),
(6008, 0, 4, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 79939, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowsworn Warlock - In Combat - Cast ''Chaos Bolt'''),
(6008, 0, 5, 0, 0, 0, 100, 0, 8000, 9000, 22000, 27000, 0, 11, 79955, 1, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowsworn Warlock - In Combat - Cast ''Rain of Fire'''),
(6009, 0, 3, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 77722, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowsworn Dreadweaver - In Combat - Cast ''Void Whip'''),
(6009, 0, 4, 0, 0, 0, 100, 0, 6000, 9000, 18000, 22000, 0, 11, 79930, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowsworn Dreadweaver - In Combat - Cast ''Corruption'''),
(8299, 0, 2, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 66060, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Spiteflayer - On Aggro - Cast ''Sprint'' (No Repeat)'),
(8299, 0, 3, 0, 0, 0, 100, 0, 2000, 4500, 12000, 14000, 0, 11, 37945, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Spiteflayer - In Combat - Cast ''Fel Fireball'''),
(42235, 0, 2, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 66060, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Darktail Bonepicker - On Aggro - Cast ''Sprint'' (No Repeat)'),
(42235, 0, 3, 0, 0, 0, 100, 0, 3000, 5000, 22000, 25000, 0, 11, 8139, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Darktail Bonepicker - In Combat - Cast ''Fevered Fatigue'''),
(42334, 0, 1, 0, 0, 0, 100, 0, 0, 0, 3400, 4700, 0, 11, 9739, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Marl Wormthorn - In Combat - Cast ''Wrath'''),
(42334, 0, 2, 0, 1, 0, 100, 0, 500, 1000, 600000, 600000, 0, 11, 79833, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Marl Wormthorn - Out of Combat - Cast ''Mark of the Wild'''),
(42334, 0, 3, 0, 0, 0, 100, 0, 7000, 9000, 14000, 20000, 0, 11, 33844, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Marl Wormthorn - In Combat - Cast ''Entangling Roots'''),
(42334, 0, 4, 0, 2, 0, 100, 0, 0, 40, 19000, 27000, 0, 11, 12160, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Marl Wormthorn - Between 0-40% Health - Cast ''Rejuvenation'''),
(15196, 0, 2, 0, 0, 0, 100, 0, 3000, 3500, 20000, 23000, 0, 11, 13298, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Deathclasp - In Combat - Cast ''Poison'''),
(7379, 0, 4, 0, 0, 0, 100, 0, 4700, 8800, 10500, 13800, 0, 11, 15039, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Deadwind Mauler - In Combat - Cast ''Flame Shock'''),
(4436, 0, 2, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 11, 7165, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Razorfen Quilguard - On Aggro - Cast Battle Stance'),
(4442, 0, 2, 0, 0, 0, 100, 0, 0, 2000, 120000, 120000, 0, 11, 7164, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Razorfen Defender - In Combat - Cast Defensive Stance'),
(4517, 0, 4, 0, 1, 0, 100, 2, 1000, 1000, 1800000, 1800000, 0, 11, 21562, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Death''s Head Priest - Out of Combat - Cast ''Power Word: Fortitude'''),
(12242, 0, 1, 0, 0, 0, 100, 0, 0, 1000, 2000, 2000, 0, 11, 15795, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Spirit of Maraudos - In Combat - Cast Throw'),
(12242, 0, 2, 0, 0, 0, 100, 0, 3000, 5000, 5000, 7000, 0, 11, 14873, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Spirit of Maraudos - In Combat - Cast Sinister Strike'),
(12243, 0, 1, 0, 0, 0, 100, 0, 0, 1000, 2000, 2000, 0, 11, 15547, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Spirit of Veng - In Combat - Cast Shoot'),
(12243, 0, 2, 0, 0, 0, 100, 0, 4000, 9000, 10000, 17000, 0, 11, 14443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Spirit of Veng - In Combat - Cast Multi-Shot'),
(13142, 0, 1, 0, 0, 0, 100, 0, 4000, 11000, 22500, 30000, 0, 11, 21331, 0, 0, 0, 0, 0, 5, 30, 0, 0, 0, 0, 0, 0, 0, 'Deeprot Tangler - In Combat - Cast Entangling Roots'),
(13596, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 21911, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Rotgrip - On Reset - Cast Puncture'),
(4852, 0, 5, 0, 2, 0, 100, 2, 0, 50, 20000, 20000, 0, 11, 11986, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Stonevault Oracle - Between 0-50% Health - Cast ''Healing Wave'' (Normal Dungeon)'),
(7023, 0, 8, 0, 0, 0, 100, 0, 1000, 11000, 16000, 24000, 0, 11, 9906, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Obsidian Sentinel - In Combat - Cast Reflection'),
(11441, 0, 6, 0, 0, 0, 100, 0, 8000, 17000, 14000, 21000, 0, 11, 6253, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gordok Brute - In Combat - Cast Backhand'),
(11448, 0, 16, 0, 1, 0, 100, 1, 10000, 10000, 0, 0, 0, 11, 21157, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Gordok Warlock - Out of Combat - Cast Dark Channeling'),
(11452, 0, 2, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 13299, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wildspawn Rogue - On Reset - Cast Poison Proc'),
(11455, 0, 16, 0, 0, 0, 100, 0, 0, 2000, 120000, 120000, 0, 11, 22418, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wildspawn Felsworn - In Combat - Cast Chaotic Focus'),
(11465, 0, 1, 0, 0, 0, 100, 0, 4000, 15000, 10000, 25000, 0, 11, 16727, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warpwood Stomper - In Combat - Cast War Stomp'),
(11473, 0, 6, 0, 0, 0, 100, 0, 4000, 11000, 14000, 25000, 0, 11, 17831, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Eldreth Spectre - In Combat - Cast Call of the Graves'),
(11486, 0, 6, 0, 25, 0, 100, 65537, 0, 0, 0, 0, 0, 11, 674, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prince Tortheldrin - On Reset - Cast Dual Wield'),
(11487, 0, 6, 0, 1, 0, 100, 1, 10000, 10000, 0, 0, 0, 11, 21157, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tendris Warpwood - Out of Combat - Cast Dark Channeling'),
(11488, 0, 4, 0, 0, 0, 100, 0, 0, 500, 2000, 2000, 0, 11, 16100, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Illyanna Ravenoak - In Combat - Cast Shoot'),
(11488, 0, 5, 0, 0, 0, 100, 0, 3000, 12000, 10000, 15000, 0, 11, 20735, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Illyanna Ravenoak - In Combat - Cast Multi-Shot'),
(13021, 0, 1, 0, 0, 0, 100, 0, 5000, 7000, 11000, 15000, 0, 11, 15550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warpwood Crusher - In Combat - Cast Trample'),
(13197, 0, 12, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 35187, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Fel Lash - On Reset - Cast Arcane Explosion Proc'),
(13285, 0, 2, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 16428, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Death Lash - On Reset - Cast Virulent Poison Proc'),
(14327, 0, 14, 0, 0, 0, 100, 0, 11000, 11000, 30000, 30000, 0, 11, 22710, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Lethtendris - In Combat - Cast Enlarge'),
(14354, 0, 22, 0, 7, 0, 100, 0, 0, 0, 0, 0, 0, 11, 22735, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Pusillin - On Evade - Cast Spirit of Runn Tum'),
(7332, 0, 4, 0, 0, 0, 100, 0, 4000, 9000, 12000, 20000, 0, 11, 11397, 0, 0, 0, 0, 0, 5, 30, 0, 0, 0, 0, 0, 0, 0, 'Withered Spearhide - In Combat - Cast Diseased Shot'),
(7347, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 12539, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Boneflayer Ghoul - On Reset - Cast Ghoul Rot'),
(7348, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 12539, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Thorn Eater Ghoul - On Reset - Cast Ghoul Rot'),
(7352, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 12529, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Frozen Soul - On Reset - Cast Chilling Touch'),
(7353, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 12529, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Freezing Spirit - On Reset - Cast Chilling Touch'),
(10393, 0, 16, 0, 0, 0, 100, 0, 10000, 20000, 20000, 40000, 0, 11, 8364, 0, 0, 0, 0, 0, 5, 20, 0, 0, 0, 0, 0, 0, 0, 'Skul - In Combat - Cast Blizzard'),
(10398, 0, 12, 0, 1, 0, 100, 0, 6000, 6000, 0, 0, 0, 11, 12380, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Thuzadin Shadowcaster - Out of Combat - Cast Shadow Channeling'),
(10413, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 16428, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Crypt Beast - On Reset - Cast Virulent Poison Proc'),
(10425, 0, 3, 0, 0, 0, 100, 0, 2000, 7000, 11000, 15000, 0, 11, 15732, 32, 0, 0, 0, 0, 5, 20, 0, 0, 0, 0, 0, 0, 0, 'Crimson Battle Mage - In Combat - Cast Immolate'),
(11032, 0, 6, 0, 2, 0, 100, 0, 0, 70, 10000, 10000, 0, 11, 15493, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Malor the Zealous - Between Health 0-50% - Cast Holy Light'),
(5648, 0, 4, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 11, 18396, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Sandfury Shadowcaster - On Aggro - Cast Dismounting Blast'),
(7246, 0, 3, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 11, 18396, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Sandfury Shadowhunter - On Aggro - Cast Dismounting Blast'),
(7797, 0, 2, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 11, 7366, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ruuzlu - On Aggro - Cast Berserker Stance'),
(8921, 0, 2, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 8279, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodhound - On Reset - Cast Stealth Detection'),
(8933, 0, 2, 0, 0, 0, 100, 0, 5000, 6000, 4000, 8000, 0, 11, 15656, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Cave Creeper - In Combat - Cast Poisonous Stab'),
(9024, 0, 3, 0, 0, 0, 100, 0, 2000, 7000, 30000, 45000, 0, 11, 15041, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Pyromancer Loregrain - In Combat - Cast Fire Ward'),
(9029, 0, 3, 0, 0, 0, 100, 0, 5000, 6000, 15000, 16000, 0, 11, 8269, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Eviscerator - In Combat - Cast Anti-Magic Shield'),
(5277, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 3637, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Nightmare Scalebane - On Reset - Cast Improved Blocking III'),
(16880, 0, 2, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 33908, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hulking Helboar - On Reset - Cast ''Burning Spikes'''),
(16915, 0, 1, 0, 1, 0, 100, 0, 45000, 90000, 45000, 90000, 0, 11, 34396, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Foreman Razelcraz - OOC - Cast Zap'),
(16977, 0, 15, 0, 1, 0, 100, 0, 317000, 317000, 300000, 300000, 0, 11, 29459, 0, 0, 0, 0, 0, 10, 86056, 0, 0, 0, 0, 0, 0, 0, 'Arch Mage Xintor - OOC - Cast ''Pyroblast'''),
(16978, 0, 3, 0, 0, 0, 50, 0, 4000, 7000, 5000, 8000, 0, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lieutenant Commander Thalvos - In Combat - Cast Strike'),
(22259, 0, 1, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 38891, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hellfire Wardling - On Death - Cast Magic Sucker Device (Despawn Visual)'),
(22267, 0, 2, 0, 1, 0, 100, 0, 0, 0, 3000, 3000, 0, 11, 38719, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Magic Sucker Device Buttress - IC - Cast Magic Sucker Device Buttress Appearance'),
(22267, 0, 3, 0, 0, 0, 100, 0, 0, 0, 3000, 3000, 0, 11, 38919, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Magic Sucker Device Buttress - OOC - Cast Magic Sucker Device Buttress Appearance'),
(17877, 0, 26, 0, 0, 0, 100, 0, 11000, 12000, 15000, 25000, 0, 11, 31964, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Fhwoor - In Combat - Cast Thundershock'),
(18088, 0, 4, 0, 0, 0, 100, 0, 6000, 8000, 16000, 22000, 0, 11, 33245, 35, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodscale Enchantress - In Combat - Cast ''Ice Barrier'''),
(18130, 0, 2, 0, 0, 0, 100, 0, 3000, 3000, 3000, 6000, 0, 11, 33860, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Marshfang Ripper - In Combat - Cast ''Arcane Explosion'''),
(18131, 0, 2, 0, 3, 0, 100, 0, 25, 100, 3600, 3600, 0, 11, 35334, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Marshfang Slicer - Between 25-100% Mana - Cast ''Nether Shock'''),
(18285, 0, 2, 0, 0, 0, 100, 0, 10000, 12000, 10000, 12000, 0, 11, 35335, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, '''Count'' Ungula - In Combat - Cast ''Nether Leech'''),
(19706, 0, 1, 0, 2, 0, 50, 0, 0, 15, 0, 0, 0, 11, 28728, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Marshrock Threshalisk - Between 0-15% Health - Cast ''Feign Death'''),
(19729, 0, 1, 0, 2, 0, 60, 0, 0, 15, 0, 0, 0, 11, 28728, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ironspine Threshalisk - Between 0-15% Health - Cast ''Feign Death'''),
(19730, 0, 2, 0, 2, 0, 30, 0, 0, 15, 0, 0, 0, 11, 28728, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ironspine Gazer - Between 0-15% Health - Cast ''Feign Death'''),
(20196, 0, 1, 0, 0, 0, 100, 0, 10000, 12000, 10000, 12000, 0, 11, 35335, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodthirsty Marshfang - In Combat - Cast ''Nether Leech'''),
(20279, 0, 2, 0, 2, 0, 30, 0, 0, 15, 0, 0, 0, 11, 28728, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ragestone Threshalisk - Between 0-15% Health - Cast ''Feign Death'''),
(20279, 0, 3, 0, 0, 0, 100, 0, 6000, 6000, 0, 0, 0, 11, 35385, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ragestone Threshalisk - In Combat - Cast ''Threshalisk Charge'' (Phase 1)'),
(20280, 0, 3, 0, 2, 0, 30, 0, 0, 15, 0, 0, 0, 11, 28728, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ragestone Trampler - Between 0-15% Health - Cast ''Feign Death'''),
(20280, 0, 4, 0, 0, 0, 100, 0, 6000, 6000, 0, 0, 0, 11, 35385, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ragestone Trampler - In Combat - Cast ''Threshalisk Charge'' (Phase 1)'),
(17088, 0, 2, 0, 0, 0, 100, 0, 6000, 15000, 21000, 35000, 0, 11, 32940, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowy Summoner - In Combat - Cast ''Shadow Rush'''),
(18482, 0, 1, 0, 0, 0, 100, 0, 3000, 5000, 9000, 12000, 0, 11, 12548, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Empoor - In Combat - Cast ''Frost Shock'''),
(18670, 0, 3, 0, 0, 0, 100, 0, 0, 0, 2300, 3900, 0, 11, 6660, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ironjaw - In Combat - Cast ''Shoot'''),
(18670, 0, 4, 0, 9, 0, 100, 0, 0, 5, 15000, 17000, 0, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ironjaw - Within 0-5 Range - Cast ''Cleave'''),
(21651, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 42247, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Time-Lost Skettis Reaver - On Aggro - Cast ''Battle Shout'' (No Repeat)'),
(21651, 0, 2, 0, 0, 0, 100, 0, 2500, 5000, 10000, 15000, 0, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Time-Lost Skettis Reaver - In Combat - Cast ''Cleave'''),
(21651, 0, 3, 0, 2, 0, 100, 1, 5, 30, 0, 0, 0, 11, 3019, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Time-Lost Skettis Reaver - Between 5-30% Health - Cast ''Frenzy'' (No Repeat)'),
(21787, 0, 1, 0, 0, 0, 100, 0, 4000, 8000, 7000, 16000, 0, 11, 11639, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Time-Lost Skettis High Priest - In Combat - Cast ''Shadow Word: Pain'''),
(21787, 0, 2, 0, 0, 0, 100, 0, 2300, 3000, 8000, 12000, 0, 11, 9734, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Time-Lost Skettis High Priest - In Combat - Cast ''Holy Smite'''),
(22199, 0, 3, 0, 0, 0, 100, 0, 27000, 32000, 27000, 32000, 0, 11, 21909, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Slaag - In Combat - Cast ''Dust Field'''),
(23066, 0, 1, 0, 0, 0, 100, 0, 10000, 15000, 10000, 15000, 0, 11, 17843, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Talonpriest Ishaal - In Combat - Cast Flash Heal'),
(23066, 0, 2, 0, 0, 0, 100, 0, 4000, 5000, 10000, 15000, 0, 11, 12160, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Talonpriest Ishaal - In Combat - Cast Rejuvenation'),
(23066, 0, 3, 0, 0, 0, 100, 0, 1000, 3000, 10000, 15000, 0, 11, 15654, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Talonpriest Ishaal - In Combat - Cast Shadow Word: Pain'),
(23067, 0, 1, 0, 0, 0, 100, 0, 2000, 3000, 8000, 12000, 0, 11, 17165, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Talonpriest Skizzik - In Combat - Cast Mind Flay'),
(23067, 0, 2, 0, 0, 0, 100, 0, 10000, 15000, 15000, 25000, 0, 11, 22884, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Talonpriest Skizzik - In Combat - Cast Psychic Scream'),
(23067, 0, 3, 0, 0, 0, 100, 0, 7000, 8000, 7000, 10000, 0, 11, 32712, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Talonpriest Skizzik - In Combat - Cast Shadow Nova'),
(23068, 0, 1, 0, 0, 0, 100, 0, 4000, 7000, 10000, 15000, 0, 11, 15652, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Talonpriest Zellek - In Combat - Cast Head Smash'),
(23068, 0, 2, 0, 0, 0, 100, 0, 10000, 15000, 18000, 25000, 0, 11, 17173, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Talonpriest Zellek - In Combat - Cast Drain Life'),
(23219, 0, 7, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 11, 37417, 1, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Blackwind Warp Chaser - On Aggro - Cast ''Warp Charge'' (No Repeat) (Normal Dungeon)'),
(17160, 0, 1, 0, 9, 0, 100, 0, 8, 40, 10000, 15000, 0, 11, 31705, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Living Cyclone - On Range - Cast Magnetic Pull'),
(18069, 0, 19, 0, 0, 0, 100, 0, 3400, 6400, 13200, 26400, 0, 11, 18975, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Mogor - In Combat - Cast ''Summon Ice Totem'''),
(18202, 0, 5, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 32133, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkblood Putrifier - On Aggro - Cast ''Corrupted Earth'' (No Repeat)'),
(18202, 0, 6, 0, 0, 0, 100, 0, 2500, 4000, 9500, 12000, 0, 11, 32132, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkblood Putrifier - In Combat - Cast ''Tainted Chain Lightning'''),
(18202, 0, 7, 0, 2, 0, 100, 1, 20, 80, 0, 0, 0, 11, 32134, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkblood Putrifier - Between 20-80% Health - Cast ''Putrid Cloud'' (No Repeat)'),
(18203, 0, 4, 0, 0, 0, 100, 0, 5000, 10000, 15000, 20000, 0, 11, 11971, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkblood Raider - In Combat - Cast ''Sunder Armor'''),
(18203, 0, 5, 0, 2, 0, 100, 1, 20, 80, 0, 0, 0, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkblood Raider - Between 20-80% Health - Cast ''Cleave'' (No Repeat)'),
(18207, 0, 4, 0, 2, 0, 100, 1, 20, 80, 0, 0, 0, 11, 3391, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murkblood Scavenger - Between 20-80% Health - Cast ''Thrash'' (No Repeat)'),
(18261, 0, 3, 0, 1, 0, 100, 1, 0, 0, 0, 0, 0, 11, 32281, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Lantresor of the Blade - Out of Combat - Cast ''Burning Blade Blademaster'' (Phase 1) (No Repeat)'),
(18297, 0, 1, 0, 0, 0, 100, 0, 5000, 7000, 11000, 13000, 0, 11, 30981, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gankly Rottenfist - In Combat - Cast ''Crippling Poison'''),
(18297, 0, 2, 0, 0, 0, 100, 0, 9000, 11000, 15000, 17000, 0, 11, 41176, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gankly Rottenfist - In Combat - Cast ''Shadowstep'''),
(18297, 0, 3, 0, 0, 0, 100, 0, 3000, 5000, 9000, 11000, 0, 11, 15581, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gankly Rottenfist - In Combat - Cast ''Sinister Strike'''),
(18391, 0, 1, 0, 0, 0, 100, 0, 4500, 8500, 3600, 14500, 0, 11, 32000, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Giselda the Crone - In Combat - Cast ''Mind Sear'''),
(18688, 0, 3, 0, 0, 0, 100, 0, 6000, 10000, 25000, 30000, 0, 11, 31293, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'consuming shadow'),
(19067, 0, 1, 0, 1, 0, 100, 0, 3000, 3000, 10000, 10000, 0, 11, 33535, 0, 0, 0, 0, 0, 19, 19212, 100, 0, 0, 0, 0, 0, 0, 'When out of combat and timer at the begining between 3000 and 3000 ms (and later repeats every 10000 and 10000 ms) - Self: Cast spell ''Fel Energy Beam'' (33535) on closest alive creature ''Fel Cannon: Hate Target'' (19212) in 100 yards'),
(19210, 0, 1, 0, 1, 0, 100, 0, 3000, 3000, 10000, 10000, 0, 11, 33535, 0, 0, 0, 0, 0, 19, 19211, 100, 0, 0, 0, 0, 0, 0, 'When out of combat and timer at the begining between 3000 and 3000 ms (and later repeats every 10000 and 10000 ms) - Self: Cast spell ''Fel Energy Beam'' (33535) on closest alive creature ''Fel Cannon: Fear Target'' (19211) in 100 yards'),
(19945, 0, 1, 0, 0, 0, 100, 0, 1500, 3000, 6500, 9000, 0, 11, 9532, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lashh''an Windwalker - In Combat - Cast ''Lightning Bolt'''),
(19948, 0, 3, 0, 2, 0, 100, 1, 20, 80, 0, 0, 0, 11, 34802, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodmaul Skirmisher - Between 20-80% Health - Cast ''Kick'' (No Repeat)'),
(19973, 0, 2, 0, 0, 0, 100, 0, 6000, 15000, 18000, 28000, 0, 11, 37633, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Abyssal Flamebringer - IC - Cast Abyssal Strike'),
(19985, 0, 1, 0, 0, 0, 100, 0, 2500, 3500, 7500, 8000, 0, 11, 9532, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ruuan''ok Cloudgazer - In Combat - Cast ''Lightning Bolt'''),
(19988, 0, 1, 0, 0, 0, 100, 0, 2500, 5500, 10000, 11000, 0, 11, 37587, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grishna Falconwing - In Combat - Cast Bestial Wrath'),
(19989, 0, 1, 0, 0, 0, 100, 0, 2500, 5500, 20000, 21000, 0, 11, 37589, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grishna Harbinger - In Combat - Cast Shriveling Gaze'),
(19989, 0, 2, 0, 0, 0, 100, 0, 1000, 6000, 10000, 15000, 0, 11, 9532, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grishna Harbinger - In Combat - Cast Lightning Bolt'),
(19990, 0, 1, 0, 0, 0, 100, 0, 2500, 5500, 10000, 11000, 0, 11, 35321, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grishna Scorncrow - In Combat - Cast Gushing Wound'),
(19993, 0, 3, 0, 0, 0, 100, 0, 15000, 30000, 30000, 60000, 0, 11, 37592, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodmaul Mauler - In Combat - Cast Knockdown'),
(20600, 0, 3, 0, 0, 0, 100, 0, 3000, 6000, 8000, 12000, 0, 11, 38770, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Maggoc - In Combat - Cast ''Mortal Wound'''),
(20600, 0, 4, 0, 0, 0, 100, 0, 3000, 6000, 5000, 10000, 0, 11, 38777, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Maggoc - In Combat - Cast ''Rock Rumble'''),
(20600, 0, 5, 0, 0, 0, 100, 0, 4000, 7000, 5000, 10000, 0, 11, 42139, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Maggoc - In Combat - Cast ''Boulder'''),
(20924, 0, 3, 0, 2, 0, 30, 0, 0, 15, 0, 0, 0, 11, 28728, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Grishnath Basilisk - Between 0-15% Health - Cast ''Feign Death'''),
(20924, 0, 4, 0, 0, 0, 100, 0, 6000, 6000, 0, 0, 0, 11, 35385, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grishnath Basilisk - In Combat - Cast ''Threshalisk Charge'' (Phase 1)'),
(20925, 0, 1, 0, 2, 0, 30, 0, 0, 15, 0, 0, 0, 11, 28728, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Scalded Basilisk - Between 0-15% Health - Cast ''Feign Death'''),
(20925, 0, 2, 0, 0, 0, 100, 0, 6000, 6000, 0, 0, 0, 11, 35385, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Scalded Basilisk - In Combat - Cast ''Threshalisk Charge'' (Phase 1)'),
(21326, 0, 7, 0, 0, 0, 100, 0, 10000, 12000, 35000, 40000, 0, 11, 37696, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Raven''s Wood Leafbeard - IC - cast Force of Nature'),
(21497, 0, 3, 0, 0, 0, 85, 0, 15000, 15000, 30000, 30000, 0, 11, 15847, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Blackscale - In Combat - Cast ''Tail Sweep'''),
(21956, 0, 1, 0, 0, 0, 100, 0, 4000, 5000, 19000, 20000, 0, 11, 13443, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Rema - In Combat - Cast ''Rend'''),
(21956, 0, 2, 0, 2, 0, 100, 1, 20, 80, 0, 0, 0, 11, 5781, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Rema - Between 20-80% Health - Cast ''Threatening Growl'' (No Repeat)'),
(21956, 0, 3, 0, 2, 0, 100, 1, 10, 30, 0, 0, 0, 11, 8599, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Rema - Between 10-30% Health - Cast ''Enrage'' (No Repeat)'),
(22160, 0, 5, 0, 0, 0, 100, 0, 20000, 50000, 60000, 90000, 0, 11, 37592, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodmaul Taskmaster - In Combat - Cast Knockdown'),
(22181, 0, 10, 0, 3, 0, 100, 0, 0, 75, 20000, 20000, 0, 11, 17008, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Aether Ray - Between 0-75% Mana - Cast ''Mana Drain'''),
(22204, 0, 2, 0, 0, 0, 100, 0, 9000, 20000, 13000, 27000, 0, 11, 38356, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Fear Fiend - IC - Cast Fel Flames'),
(22221, 0, 1, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 37628, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Felstorm Overseer - On Aggro - Cast ''Fel Immolate'' (No Repeat)'),
(22221, 0, 2, 0, 0, 0, 100, 0, 2700, 3000, 6700, 7000, 0, 11, 37945, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Felstorm Overseer - In Combat - Cast ''Fel Fireball'''),
(22221, 0, 3, 0, 2, 0, 100, 1, 10, 30, 0, 0, 0, 11, 37488, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Felstorm Overseer - Between 10-30% Health - Cast ''Fel Flames'' (No Repeat)'),
(22242, 0, 2, 0, 0, 0, 100, 0, 2500, 4500, 12000, 15000, 0, 11, 29881, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bash''ir Spell-Thief - In Combat - Cast ''Drain Mana'''),
(22289, 0, 1, 0, 2, 0, 100, 1, 5, 20, 0, 0, 0, 11, 7139, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Darkflame Infernal - Between 5-20% Health - Cast ''Fel Stomp'' (No Repeat)'),
(18850, 0, 3, 0, 0, 0, 100, 0, 1000, 2000, 30000, 30000, 0, 11, 35877, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunfury Guardsman - In Combat - Cast Mark of the Sunfury'),
(18853, 0, 3, 0, 0, 0, 100, 0, 1000, 2000, 30000, 30000, 0, 11, 35877, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunfury Bloodwarder - In Combat - Cast Mark of the Sunfury'),
(19466, 0, 1, 0, 0, 0, 100, 0, 0, 3500, 15000, 21000, 0, 11, 29426, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Exarch Orelis - In Combat - Cast ''Heroic Strike'''),
(19466, 0, 2, 0, 0, 0, 100, 0, 10000, 15000, 30000, 30000, 0, 11, 16509, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Exarch Orelis - In Combat - Cast ''Rend'''),
(19466, 0, 3, 0, 0, 0, 100, 0, 7500, 21000, 20000, 45000, 0, 11, 13730, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Exarch Orelis - In Combat - Cast ''Demoralizing Shout'''),
(19541, 0, 1, 0, 9, 0, 100, 0, 5, 30, 3600, 3600, 0, 11, 36246, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Netherstorm Agent - Within 5-30 Range - Cast ''Shoot Tech Gun'''),
(20102, 0, 2, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65526, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Midsummer'''),
(20102, 0, 3, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65522, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Winter Veil'''),
(20102, 0, 4, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65524, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Lunar Festival'''),
(20102, 0, 5, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65523, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Default'''),
(20102, 0, 6, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65525, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Hallow''s End'''),
(20102, 0, 7, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65511, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Brewfest'''),
(20102, 0, 8, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65527, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Spirit of Competition'''),
(20102, 0, 9, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65528, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Pirates'' Day'''),
(20102, 0, 10, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 65529, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Goblin Commoner - On Respawn - Cast ''Gossip NPC Appearance - Day of the Dead (DotD)'''),
(20132, 0, 1, 0, 0, 0, 100, 0, 2500, 7500, 15000, 25000, 0, 11, 15496, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Socrethar - In Combat - Cast ''Cleave'''),
(20132, 0, 2, 0, 0, 0, 100, 0, 10000, 15000, 40000, 60000, 0, 11, 37538, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Socrethar - In Combat - Cast ''Anti-Magic Shield'''),
(20132, 0, 3, 0, 0, 0, 100, 0, 17000, 24000, 10000, 35000, 0, 11, 28448, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Socrethar - In Combat - Cast ''Shadow Bolt Volley'''),
(20132, 0, 4, 0, 0, 0, 100, 0, 30000, 40000, 30000, 40000, 0, 11, 37540, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Socrethar - In Combat - Cast ''Fireball Barrage'''),
(20132, 0, 5, 0, 0, 0, 100, 0, 30000, 45000, 35000, 50000, 0, 11, 37537, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Socrethar - In Combat - Cast ''Backlash'''),
(20134, 0, 14, 0, 1, 0, 50, 0, 10000, 20000, 15000, 30000, 0, 11, 34397, 0, 0, 0, 0, 0, 19, 19421, 30, 0, 0, 0, 0, 0, 0, '20134 - Ooc - Cast Red Beam'),
(20139, 0, 15, 0, 1, 0, 50, 0, 10000, 20000, 15000, 30000, 0, 11, 34397, 0, 0, 0, 0, 0, 19, 19421, 30, 0, 0, 0, 0, 0, 0, '20139 - Ooc - Cast Red Beam'),
(20248, 0, 5, 0, 1, 0, 50, 0, 10000, 20000, 15000, 30000, 0, 11, 34397, 0, 0, 0, 0, 0, 19, 19421, 30, 0, 0, 0, 0, 0, 0, 'When out of combat and timer at the begining between 10000 and 20000 ms (and later repeats every 15000 and 30000 ms) (50% chance) - Self: Cast spell Red Beam (34397) on Closest alive creature Netherstorm Crystal Target (19421) in 30 yards. 20248 - Ooc - Cast Red Beam'),
(20409, 0, 1, 0, 9, 0, 100, 0, 10, 35, 0, 0, 0, 11, 36099, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Kirin''Var Apprentice - Within 10-35 Range - Cast ''Throw Hammer'''),
(20607, 0, 2, 0, 2, 0, 30, 0, 0, 15, 0, 0, 0, 11, 28728, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Craghide Basilisk - Between 0-15% Health - Cast ''Feign Death'''),
(20673, 0, 1, 0, 0, 0, 100, 0, 2000, 5000, 4000, 6000, 0, 11, 36594, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Swiftwing Shredder - IC - Cast Lightning Breath'),
(20769, 0, 1, 0, 1, 0, 100, 1, 5000, 5000, 0, 0, 0, 11, 35515, 0, 0, 0, 0, 0, 9, 20454, 0, 200, 0, 0, 0, 0, 0, 'Salaadin''s Energy Ball - Out of Combat - Cast ''Salaadin''s Tesla'''),
(20928, 0, 4, 0, 0, 0, 100, 0, 1000, 1000, 7000, 9000, 0, 11, 37179, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ironspine Forgelord - In Combat - Cast ''Hammer Slam'''),
(20928, 0, 5, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 33962, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ironspine Forgelord - On Aggro - Cast ''Toughen'' (No Repeat)'),
(21337, 0, 1, 0, 0, 0, 100, 0, 2500, 5000, 10000, 12500, 0, 11, 7159, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Illidari Shadowstalker - In Combat - Cast ''Backstab'''),
(21450, 0, 1, 0, 2, 0, 100, 1, 20, 80, 0, 0, 0, 11, 38254, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Skethyl Owl - Between 20-80% Health - Cast ''Festering Wound'' (No Repeat)'),
(21450, 0, 2, 0, 2, 0, 100, 1, 10, 30, 0, 0, 0, 11, 38021, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Skethyl Owl - Between 10-30% Health - Cast ''Terrifying Screech'' (No Repeat)'),
(21453, 0, 1, 0, 0, 0, 100, 0, 5000, 10000, 20000, 25000, 0, 11, 32062, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ashtongue Shaman - In Combat - Cast ''Fire Nova Totem'''),
(21453, 0, 2, 0, 2, 0, 100, 1, 5, 30, 0, 0, 0, 11, 37067, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ashtongue Shaman - Between 5-30% Health - Cast ''Bloodlust'' (No Repeat)'),
(21503, 0, 7, 0, 0, 0, 100, 0, 5000, 8000, 10000, 16000, 0, 11, 32707, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunfury Warlock - IC - Cast Incinerate'),
(21503, 0, 8, 0, 0, 0, 100, 0, 0, 3000, 3000, 3000, 0, 11, 9613, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunfury Warlock - IC - Cast Shadow Bolt'),
(21506, 0, 2, 0, 23, 0, 100, 0, 38722, 1, 5000, 5000, 0, 11, 37833, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Azaloth - On aura x1 - Cast ban'),
(21506, 0, 3, 0, 9, 0, 100, 0, 0, 5, 8000, 15000, 0, 11, 40504, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Azaloth - On Range - Cast Cleave'),
(21506, 0, 4, 0, 0, 0, 100, 0, 8000, 8000, 8000, 12000, 0, 11, 11443, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Azaloth - IC - Cast Cripple'),
(21506, 0, 5, 0, 0, 0, 100, 0, 5000, 10000, 12000, 15000, 0, 11, 38741, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Azaloth - IC - Cast Rain of Fire'),
(21663, 0, 1, 0, 2, 0, 100, 1, 20, 80, 0, 0, 0, 11, 34079, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Oronu the Elder - Between 20-80% Health - Cast ''Grounding Totem'' (No Repeat)'),
(21663, 0, 2, 0, 2, 0, 100, 1, 10, 30, 0, 0, 0, 11, 11986, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Oronu the Elder - Between 10-30% Health - Cast ''Healing Wave'' (No Repeat)'),
(21876, 0, 1, 0, 1, 0, 33, 0, 8000, 21000, 8000, 21000, 0, 11, 37784, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Chain of Shadows - Out of Combat - Cast ''Enforced Submission'''),
(22017, 0, 15, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 35190, 0, 0, 0, 0, 0, 19, 20431, 20, 0, 0, 0, 0, 0, 0, 'Eclipsion Spellbinder - On Reset - Cast ''Crystal Channel'''),
(22093, 0, 1, 0, 0, 0, 100, 0, 5000, 10000, 15000, 20000, 0, 11, 32736, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Illidari Watcher - In Combat - Cast ''Mortal Strike'''),
(24960, 0, 3, 0, 0, 0, 100, 0, 15000, 17000, 12000, 13000, 0, 11, 33390, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Wretched Devourer - In Combat - Cast ''Arcane Torrent'''),
(24999, 0, 2, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 45023, 0, 0, 0, 0, 0, 19, 25953, 13, 0, 0, 0, 0, 0, 0, 'Irespeaker - On Reset - Cast ''Fel Consumption'''),
(25087, 0, 3, 0, 0, 0, 100, 0, 2500, 6000, 6000, 10000, 0, 11, 56641, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Dawnblade Reservist - In Combat - Cast ''Steady Shot'' (No Repeat)'),
(17264, 0, 1, 0, 0, 0, 100, 0, 6100, 17200, 20650, 26950, 0, 11, 30621, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bonechewer Ravener - In Combat - Cast Kidney Shot'),
(17269, 0, 16, 0, 0, 0, 100, 2, 0, 2050, 1750, 2050, 0, 11, 15241, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bleeding Hollow Darkcaster - In Combat - Cast ''Scorch'' (Normal Dungeon)'),
(17269, 0, 17, 0, 0, 0, 100, 2, 15650, 23000, 20650, 31600, 0, 11, 20754, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Bleeding Hollow Darkcaster - In Combat - Cast ''Rain of Fire'' (Normal Dungeon)'),
(17478, 0, 2, 0, 0, 0, 100, 2, 800, 1700, 3600, 4700, 0, 11, 12471, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bleeding Hollow Scryer - In Combat - Cast ''Shadow Bolt'' (Normal Dungeon)'),
(17478, 0, 3, 0, 0, 0, 100, 0, 4850, 23500, 15450, 23800, 0, 11, 30615, 1, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 'Bleeding Hollow Scryer - In Combat - Cast ''Fear'''),
(17478, 0, 4, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 30659, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bleeding Hollow Scryer - On Death - Cast Fel Infusion'),
(17371, 0, 16, 0, 0, 0, 100, 4, 2300, 16600, 21850, 43750, 0, 11, 32863, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowmoon Warlock - In Combat - Cast ''Seed of Corruption'' (Heroic Dungeon)'),
(17371, 0, 17, 0, 1, 0, 100, 0, 12600, 13700, 21900, 24900, 0, 11, 33111, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowmoon Warlock - Out of Combat - Cast ''Fel Power'''),
(17397, 0, 4, 0, 1, 0, 100, 1, 1000, 1000, 0, 0, 0, 11, 31059, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Shadowmoon Adept - Out Of Combat - Cast Hellfire Channeling'),
(17398, 0, 2, 0, 0, 0, 100, 0, 6000, 18500, 1200, 27950, 0, 11, 22427, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Nascent Fel Orc - In Combat - Cast ''Concussion Blow'''),
(17398, 0, 3, 0, 0, 0, 100, 0, 1200, 12150, 12150, 27950, 0, 11, 31900, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Nascent Fel Orc - In Combat - Cast ''Stomp'''),
(17477, 0, 15, 0, 1, 0, 100, 1, 1000, 1000, 0, 0, 0, 11, 30540, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Hellfire Imp - Out of Combat - Cast ''Summon Visual'' (No Repeat)'),
(17626, 0, 3, 0, 0, 0, 100, 0, 5000, 12000, 25000, 35000, 0, 11, 18765, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Laughing Skull Legionnaire - In Combat - Cast Sweeping Strikes'),
(18493, 0, 20, 0, 0, 0, 100, 0, 13800, 31900, 13800, 31900, 0, 11, 32859, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Auchenai Soulpriest - In Combat - Cast ''Falter'''),
(18702, 0, 3, 0, 0, 0, 100, 2, 12100, 29000, 22900, 35000, 0, 11, 32863, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Auchenai Necromancer - In Combat - Cast ''Seed of Corruption'' (Normal Dungeon)'),
(28132, 0, 5, 0, 9, 0, 100, 2, 0, 10, 20000, 20000, 0, 11, 50733, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Don Carlos - In Combat - Cast Scatter Shot'),
(18320, 0, 2, 0, 0, 0, 100, 2, 6600, 18600, 9300, 21800, 0, 11, 32675, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Time-Lost Shadowmage - In Combat - Cast ''Shadow Missiles'' (Normal Dungeon)'),
(17800, 0, 2, 0, 0, 0, 100, 0, 15000, 30000, 30000, 30000, 0, 11, 18765, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Coilfang Myrmidon - In Combat - Cast ''Sweeping Strikes'''),
(19167, 0, 3, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 11, 35191, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodwarder Slayer - On Spawn - Cast ''Arcane Explosion Proc'''),
(19231, 0, 1, 0, 0, 0, 100, 0, 11100, 19300, 22900, 28900, 0, 11, 35056, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Mechanar Crusher - In Combat - Cast ''Glob of Machine Fluid'''),
(19712, 0, 3, 0, 0, 0, 100, 0, 13300, 37400, 21700, 33800, 0, 11, 35056, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Mechanar Driller - In Combat - Cast ''Glob of Machine Fluid'''),
(19713, 0, 1, 0, 0, 0, 100, 0, 15200, 27700, 21700, 36800, 0, 11, 35056, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Mechanar Wrecker - In Combat - Cast ''Glob of Machine Fluid'''),
(20059, 0, 3, 0, 0, 0, 100, 0, 12100, 19300, 10800, 25300, 0, 11, 35243, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunseeker Netherbinder - In Combat - Cast ''Starfire'''),
(20059, 0, 4, 5, 0, 0, 100, 0, 14100, 18900, 63200, 68100, 0, 11, 35251, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunseeker Netherbinder - In Combat - Cast ''Summon Arcane Golem'''),
(20059, 0, 5, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 11, 35260, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunseeker Netherbinder - In Combat - Cast ''Summon Arcane Golem'''),
(17994, 0, 1, 0, 0, 0, 100, 0, 4000, 6000, 22000, 25000, 0, 11, 31567, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodwarder Falconer - In Combat - Cast ''Deterrence'''),
(17994, 0, 2, 0, 0, 0, 100, 0, 8000, 10000, 15000, 20000, 0, 11, 34879, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodwarder Falconer - In Combat - Cast ''Multi-Shot'''),
(17994, 0, 3, 0, 0, 0, 100, 0, 8500, 10900, 14150, 21850, 0, 11, 32908, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Bloodwarder Falconer - In Combat - Cast ''Wing Clip'''),
(18405, 0, 2, 0, 0, 0, 100, 0, 7600, 16400, 15700, 25300, 0, 11, 34793, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Tempest-Forge Peacekeeper - In Combat - Cast ''Arcane Blast'''),
(18422, 0, 2, 0, 0, 0, 100, 0, 8500, 20600, 15800, 20600, 0, 11, 34350, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunseeker Botanist - In Combat - Cast ''Nature`s Rage'''),
(19507, 0, 4, 0, 0, 0, 100, 0, 21850, 25500, 35000, 35000, 0, 11, 34247, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunseeker Gene-Splicer - In Combat - Cast ''Summon Lasher Beast'''),
(19509, 0, 4, 0, 0, 0, 100, 0, 6050, 19500, 7300, 23100, 0, 11, 34640, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunseeker Harvester - In Combat - Cast ''Wilting Touch'''),
(19511, 0, 2, 0, 0, 0, 100, 0, 13400, 20600, 20600, 29000, 0, 11, 30621, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Nethervine Inciter - In Combat - Cast ''Kidney Shot'''),
(20866, 0, 4, 0, 2, 0, 100, 0, 0, 30, 14000, 21000, 0, 11, 33958, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Soul Devourer - Between 0-30% Health - Cast ''Enrage'''),
(20879, 0, 2, 0, 0, 0, 100, 0, 15000, 17000, 14000, 21000, 0, 11, 36778, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Eredar Soul-Eater - In Combat - Cast ''Soul Steal'''),
(20880, 0, 1, 0, 0, 0, 100, 0, 6000, 12000, 8000, 14000, 0, 11, 36787, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Eredar Deathbringer - In Combat - Cast ''Forceful Cleave'''),
(20882, 0, 1, 0, 0, 0, 100, 0, 4000, 10000, 10000, 20000, 0, 11, 36862, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Skulking Witch - In Combat - Cast ''Gouge'''),
(20902, 0, 3, 0, 0, 0, 100, 0, 7000, 10000, 13000, 20000, 0, 11, 36829, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Sargeron Hellcaller - In Combat - Cast ''Hell Rain'''),
(18640, 0, 14, 0, 0, 0, 100, 0, 7800, 24100, 19300, 36200, 0, 11, 32863, 32, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Cabal Warlock - In Combat - Cast ''Seed of Corruption'''),
(18794, 0, 34, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 32958, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Cabal Ritualist - On Reset - Cast ''Crystal Channel'''),
(18794, 0, 35, 0, 15, 0, 100, 4, 15, 15000, 20000, 0, 0, 11, 17201, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Cabal Ritualist - Friendly Crowd Controlled - Cast ''Dispel Magic'' (Heroic Dungeon)'),
(16704, 0, 24, 0, 0, 0, 100, 0, 13350, 21000, 20700, 39250, 0, 11, 23601, 64, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Shattered Hand Sharpshooter - In Combat - Cast ''Scatter Shot'''),
(17465, 0, 2, 0, 0, 0, 100, 2, 3000, 7000, 17000, 21000, 0, 11, 30931, 32, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Shattered Hand Centurion - In Combat - Cast ''Battle Shout'' (Normal Dungeon)'),
(24683, 0, 22, 0, 1, 0, 100, 1, 2000, 2000, 0, 0, 0, 11, 44574, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunblade Mage Guard - Out of Combat - Cast Fel Energy Cosmetic'),
(24684, 0, 6, 0, 1, 0, 100, 1, 2000, 2000, 0, 0, 0, 11, 44574, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunblade Blood Knight - Out of Combat - Cast Fel Energy Cosmetic'),
(24685, 0, 19, 0, 1, 0, 100, 1, 2000, 2000, 0, 0, 0, 11, 44574, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunblade Magister - Out of Combat - Cast Fel Energy Cosmetic'),
(24686, 0, 6, 0, 1, 0, 100, 1, 2000, 2000, 0, 0, 0, 11, 44574, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunblade Warlock - Out of Combat - Cast Fel Energy Cosmetic'),
(24687, 0, 6, 0, 1, 0, 100, 1, 2000, 2000, 0, 0, 0, 11, 44574, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Sunblade Physician - Out of Combat - Cast Fel Energy Cosmetic'),
(24688, 0, 2, 0, 1, 0, 100, 1, 2000, 2000, 0, 0, 0, 11, 44374, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wretched Skulker - Out of Combat - Cast Spell Fel Crystal Cosmetic'),
(24689, 0, 2, 0, 1, 0, 100, 1, 2000, 2000, 0, 0, 0, 11, 44374, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wretched Bruiser - Out of Combat - Cast Spell Fel Crystal Cosmetic'),
(24957, 0, 4, 0, 1, 0, 100, 0, 5000, 10000, 10000, 15000, 0, 11, 45864, 0, 0, 0, 0, 0, 19, 23837, 20, 0, 0, 0, 0, 0, 0, 'Cult Plaguebringer - Out of Combat - Cast ''Soul Missile'''),
(25428, 0, 2, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 45575, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Magmoth Shaman - On Reset - Cast ''Magmoth Fire Totem'''),
(25465, 0, 2, 0, 1, 0, 100, 0, 0, 0, 2000, 10000, 0, 11, 50319, 0, 0, 0, 0, 0, 21, 70, 0, 0, 0, 0, 0, 0, 0, 'Kel''Thuzad - Out of Combat - Cast ''Soul Flay'''),
(25479, 0, 1, 0, 0, 0, 100, 0, 2000, 3000, 9000, 11000, 0, 11, 49816, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Kvaldir Mistweaver - In Combat - Cast ''Mist of Strangulation'''),
(25584, 0, 6, 0, 1, 0, 100, 0, 5000, 5000, 10000, 10000, 0, 11, 45777, 0, 0, 0, 0, 0, 11, 25594, 19, 0, 0, 0, 0, 0, 0, 'Inquisitor Salrand - Out of Combat - Cast ''Salrand''s Beam'''),
(25596, 0, 3, 0, 0, 0, 100, 0, 10000, 12000, 20000, 22000, 0, 11, 45876, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Infected Kodo Beast - In Combat - Cast ''Stampede'''),
(25601, 0, 3, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 46482, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Prince Valanar - On Reset - Cast ''Naxxanar Beam 2'''),
(25613, 0, 1, 0, 0, 0, 100, 0, 2000, 3000, 9000, 11000, 0, 11, 49816, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Skadir Mistweaver - In Combat - Cast ''Mist of Strangulation'''),
(25678, 0, 1, 0, 1, 0, 100, 0, 3000, 3000, 30000, 30000, 0, 11, 45872, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Doctor Razorgin - OOC - Cast Defibrillate'),
(25712, 0, 2, 0, 1, 0, 100, 0, 100, 100, 45000, 45000, 0, 11, 39550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Warbringer Goredrak - Out of Combat - Cast ''Arcane Channeling'''),
(25716, 0, 1, 0, 1, 0, 100, 0, 100, 100, 45000, 45000, 0, 11, 39550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'General Cerulean - Out of Combat - Cast ''Arcane Channeling'''),
(25719, 0, 10, 0, 1, 0, 100, 1, 100, 100, 0, 0, 0, 11, 39550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Coldarra Spellbinder - Out of Combat - Cast Arcane Channeling'),
(25720, 0, 10, 0, 1, 0, 100, 0, 100, 100, 45000, 45000, 0, 11, 39550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Inquisitor Caleras - Out of Combat - Cast ''Arcane Channeling'''),
(25722, 0, 9, 0, 1, 0, 100, 1, 100, 100, 0, 0, 0, 11, 39550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Coldarra Spellweaver - Out of Combat - Cast Arcane Channeling'),
(25789, 0, 1, 0, 0, 0, 100, 0, 0, 1000, 10000, 12000, 0, 11, 50413, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Gammothra the Tormentor - In Combat - Cast ''Magnataur Charge'''),
(25789, 0, 2, 0, 0, 0, 100, 0, 3000, 5000, 6000, 10000, 0, 11, 50410, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Gammothra the Tormentor - In Combat - Cast ''Tusk Strike'''),
(26452, 0, 1, 0, 0, 0, 100, 0, 5000, 10000, 7000, 9000, 0, 11, 19643, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Leviroth - In Combat - Cast ''Mortal Strike'''),
(24014, 0, 1, 0, 0, 0, 100, 0, 4000, 6000, 8000, 12000, 0, 11, 9613, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Necrolord - In Combat - Cast ''Shadow Bolt'''),
(24014, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 25000, 35000, 0, 11, 18267, 32, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Necrolord - In Combat - Cast ''Curse of Weakness'''),
(24014, 0, 3, 0, 0, 0, 100, 0, 8000, 12000, 8000, 12000, 0, 11, 17173, 64, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Necrolord - In Combat - Cast ''Drain Life'''),
(24018, 0, 1, 0, 0, 0, 100, 0, 2000, 4000, 3000, 5000, 0, 11, 32862, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Necro Overlord Mezhen - IC - cast Drain soul'),
(24271, 0, 5, 0, 0, 0, 100, 0, 5000, 5000, 7000, 10000, 0, 11, 49729, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'IRONGolem - IC - Cast'),
(24677, 0, 1, 0, 0, 0, 100, 0, 2000, 6000, 6000, 9000, 0, 11, 50075, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Spearfang Worg - In Combat - Cast ''Maim Flesh'''),
(24797, 0, 3, 0, 0, 0, 100, 0, 4000, 6000, 6000, 16000, 0, 11, 50169, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Reef Cow - In Combat - Cast ''Flipper Thwack'''),
(26402, 0, 2, 0, 1, 0, 100, 0, 2000, 3000, 8000, 16000, 0, 11, 46977, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Anub''ar Ambusher - Out of Combat - Cast ''Digging through Snow'''),
(26467, 0, 4, 0, 0, 0, 100, 0, 4000, 6000, 19000, 21000, 0, 11, 32738, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Jormungar Tunneler  - In Combat - Cast Bore'),
(26926, 0, 2, 0, 2, 0, 100, 0, 0, 50, 13000, 19000, 0, 11, 51873, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Duke Vallenhal - Between 0-50% Health - Cast ''Bloodworm'''),
(26942, 0, 11, 0, 1, 0, 100, 1, 0, 0, 0, 0, 0, 11, 45491, 0, 0, 0, 0, 0, 19, 27180, 10, 0, 0, 0, 0, 0, 0, 'Decrepit Necromancer - Out of Combat - Cast Necrotic Purple Beam'),
(27406, 0, 5, 0, 0, 0, 100, 0, 2000, 2000, 28000, 28000, 0, 11, 50713, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Onslaught Footman - IC - Unrelenting Onslaught'),
(27539, 0, 12, 0, 1, 0, 100, 1, 5000, 5000, 0, 0, 0, 11, 49292, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'On OOC Update - Cast Ruby Corrupt'),
(27564, 0, 15, 0, 1, 0, 100, 0, 0, 5000, 0, 10000, 0, 11, 49329, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Alliance Conscript - OOC - Cast Summon Frigid Ghoul Attacker'),
(27725, 0, 1, 0, 1, 0, 100, 0, 0, 5000, 5000, 15000, 0, 11, 49068, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ruby Guardian - OOC - Cast Summon Frigid Ghoul'),
(27749, 0, 15, 0, 1, 0, 100, 0, 0, 5000, 0, 10000, 0, 11, 49329, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Horde Conscript - OOC - Cast Summon Frigid Ghoul Attacker'),
(26261, 0, 1, 0, 1, 0, 100, 0, 2000, 5000, 4000, 6000, 0, 11, 46815, 0, 0, 0, 0, 0, 19, 26264, 85, 0, 0, 0, 0, 0, 0, 'Grizzly Hills Giant - Out of Combat - Cast ''Toss Boulder'''),
(26417, 0, 2, 0, 0, 0, 100, 1, 10000, 10000, 0, 0, 0, 11, 49717, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'IC - cast spell'),
(26417, 0, 3, 0, 0, 0, 100, 0, 5000, 6000, 15000, 16000, 0, 11, 55196, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'IC - cast spell'),
(27259, 0, 13, 0, 1, 0, 100, 0, 5000, 8000, 5000, 8000, 0, 11, 48213, 0, 0, 0, 0, 0, 19, 26785, 25, 0, 0, 0, 0, 0, 0, 'Dragonflayer Flamebinder - Out of Combat - Cast ''Dragonflayer Crone Fire'''),
(27959, 0, 10, 0, 2, 0, 100, 1, 0, 50, 0, 0, 0, 11, 50222, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Your Inner Turmoil - Between 0-50% Health - Cast ''The Cleansing: Your Inner Turmoil`s Whisper to Controller - On Health 50%'' (No Repeat)'),
(27959, 0, 11, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 50223, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Your Inner Turmoil - On Just Died - Cast ''The Cleansing: Your Inner Turmoil`s Whisper to Controller - On Death'''),
(27959, 0, 12, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 50238, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Your Inner Turmoil - On Just Died - Cast ''The Cleansing: Your Inner Turmoil`s On Death Cast on Master'''),
(28779, 0, 1, 0, 0, 0, 100, 0, 2000, 3000, 9000, 11000, 0, 11, 54580, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Blood of Mam''toth - IC - Cast ''Coagulate'''),
(28083, 0, 23, 0, 9, 0, 100, 0, 1, 50, 2000, 3500, 0, 11, 31747, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Serfex the Reaver - Within Range 1-50yd - Cast Poison'),
(32517, 0, 1, 0, 0, 0, 100, 0, 5000, 9000, 8000, 13000, 0, 11, 61186, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Loque''nahak - In Combat - Cast ''Frozen Bite'''),
(30152, 0, 6, 0, 2, 0, 100, 0, 0, 30, 120000, 130000, 0, 11, 56330, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bruor Ironbane - Between 0-30% Health - Cast ''Iron''s Bane'' (No Repeat)'),
(30174, 0, 4, 0, 0, 0, 100, 0, 2000, 5000, 15000, 22500, 0, 11, 15971, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Brunnhildar Challenger - In Combat - Cast Demoralizing Roar'),
(29648, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 54476, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Bone Gryphon - On Reset - Cast ''Blood Presence'''),
(29769, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 29266, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Vile - On Reset - Cast Permament Feign Death'),
(29769, 0, 2, 0, 9, 0, 100, 0, 0, 5, 5000, 8000, 0, 11, 6253, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Vile - On Range - Cast Back Hand'),
(29769, 0, 3, 0, 0, 0, 100, 0, 10000, 15000, 15000, 23000, 0, 11, 56646, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Vile - IC - Cast Enrage'),
(29770, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 29266, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Lady Nightswood - On Reset - Cast Permament Feign Death'),
(29770, 0, 2, 0, 0, 0, 100, 0, 0, 8000, 13000, 18000, 0, 11, 5884, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Lady Nightswood - IC - Cast Banshee Curse'),
(29770, 0, 3, 0, 9, 0, 100, 0, 0, 5, 4000, 7000, 0, 11, 16838, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Lady Nightswood - On Range - Cast Banshee Banshee Shiek'),
(29770, 0, 4, 0, 1, 0, 100, 0, 0, 0, 3000, 3000, 0, 11, 55070, 0, 0, 0, 0, 0, 19, 29771, 0, 0, 0, 0, 0, 0, 0, 'Lady Nightswood - OOC - Cast Shadow Cultist: Blue Smoke Beam'),
(29840, 0, 1, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 29266, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'The Leaper - On Reset - Cast Permament Feign Death'),
(29840, 0, 2, 0, 9, 0, 100, 0, 0, 5, 4000, 7000, 0, 11, 60195, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'The Leaper - On Range - Cast Sinister Strike'),
(29840, 0, 3, 0, 0, 0, 100, 0, 5000, 8000, 30000, 35000, 0, 11, 60177, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'The Leaper - In Combat - Cast Hunger For Blood'),
(30409, 0, 7, 0, 9, 0, 100, 0, 0, 10, 5000, 7000, 0, 11, 60290, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Apprentice Osterkilgr - In Combat - cast Blast Wave'),
(30922, 0, 3, 0, 0, 0, 100, 0, 6000, 7000, 10000, 11000, 0, 11, 10966, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'IC Update - cast uppercut'),
(31277, 0, 12, 0, 0, 0, 100, 0, 17000, 18000, 15000, 17000, 0, 11, 61139, 64, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'IC spell cast'),
(31397, 0, 1, 0, 0, 0, 100, 0, 1000, 1000, 14000, 14000, 0, 11, 3148, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Saronite Mine Slave - IC - Cast Head Crack'),
(32149, 0, 1, 0, 0, 0, 100, 0, 3000, 5200, 9200, 11500, 0, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Fallen Hero''s Spirit - In Combat - Cast ''Strike'''),
(32262, 0, 3, 0, 1, 0, 100, 1, 0, 0, 0, 0, 0, 11, 60309, 0, 0, 0, 0, 0, 19, 32264, 30, 0, 0, 0, 0, 0, 0, 'Shadow Channeler - OOC - Cast Channel Souls'),
(33429, 0, 7, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 64100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Boneguard Lieutenant - On Spawn - Defend Aura'),
(26730, 0, 2, 0, 0, 0, 100, 0, 2000, 10000, 15000, 25000, 0, 11, 50131, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Mage Slayer - In Combat - Cast Draw Magic'),
(26734, 0, 2, 0, 0, 0, 100, 0, 2000, 10000, 10000, 15000, 0, 11, 58460, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Azure Enforcer - In Combat - Cast Brutal Strike'),
(30111, 0, 4, 0, 1, 0, 100, 1, 1000, 1000, 0, 0, 0, 11, 56711, 32, 0, 0, 0, 0, 19, 30413, 5, 0, 0, 0, 0, 0, 0, 'Twilight Worshipper - Out of Combat - Cast ''Image Channel'' (No Repeat)'),
(30179, 0, 4, 0, 1, 0, 100, 1, 1000, 1000, 0, 0, 0, 11, 56711, 32, 0, 0, 0, 0, 19, 30413, 5, 0, 0, 0, 0, 0, 0, 'Twilight Apostle - Out of Combat - Cast ''Image Channel'' (No Repeat)'),
(30319, 0, 5, 0, 1, 0, 100, 1, 1000, 1000, 0, 0, 0, 11, 56711, 32, 0, 0, 0, 0, 19, 30413, 5, 0, 0, 0, 0, 0, 0, 'Twilight Darkcaster - Out of Combat - Cast ''Image Channel'' (No Repeat)'),
(30338, 0, 1, 2, 11, 0, 100, 6, 0, 0, 0, 0, 0, 11, 56158, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ahn''kahar Swarmer - In Combat - Cast ''Sprint'''),
(30338, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 11, 56281, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ahn''kahar Swarmer - On Spawn - Cast Swarm (Dungeon Only)'),
(26623, 0, 5, 0, 0, 0, 100, 0, 1000, 6000, 7000, 12000, 0, 11, 16856, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Scourge Brute - In Combat - Cast Mortal Strike'),
(26623, 0, 6, 0, 0, 0, 100, 0, 10000, 12000, 13000, 15000, 0, 11, 35011, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Scourge Brute - In Combat - Cast Knockdown'),
(29768, 0, 2, 0, 0, 0, 100, 1, 1000, 1000, 0, 0, 0, 11, 55603, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Unyielding Constrictor - In Combat - Cast ''Puncturing Strike'' (No Repeat)'),
(29774, 0, 2, 0, 0, 0, 100, 0, 1000, 5000, 7000, 11000, 0, 11, 55700, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Spitting Cobra - In Combat - Cast ''Venom Spit'''),
(27965, 0, 14, 0, 1, 0, 100, 0, 2000, 2000, 4000, 4000, 0, 11, 50563, 0, 0, 0, 0, 0, 19, 28055, 50, 0, 0, 0, 0, 0, 0, 'Dark Rune Shaper - On Reset - Cast ''Carve Stone'''),
(27639, 0, 16, 0, 1, 0, 100, 0, 1000, 1000, 0, 0, 0, 11, 51518, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ring-Lord Sorceress - Out of Combat - Cast ''Nexus Energy Cosmetic'''),
(27640, 0, 2, 0, 1, 0, 100, 0, 1000, 1000, 0, 0, 0, 11, 51518, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Ring-Lord Conjurer - Out of combat - Cast Visual'),
(39436, 0, 1, 0, 0, 0, 100, 0, 5000, 5000, 12000, 14000, 0, 11, 80182, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Twilight Proveditor - In Combat - Cast ''Uppercut'''),
(46925, 0, 5, 0, 0, 0, 100, 0, 5100, 5200, 11300, 12500, 0, 11, 80561, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ashbearer - In Combat - Cast ''Flame Edge'''),
(46925, 0, 6, 0, 0, 0, 100, 0, 9900, 9900, 23400, 26800, 0, 11, 80594, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Ashbearer - In Combat - Cast ''Flame Thrower'''),
(46925, 0, 7, 0, 0, 0, 100, 0, 3000, 4000, 17800, 19200, 0, 11, 18543, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'Ashbearer - In Combat - Cast ''Flame Lash'''),
(41644, 0, 3, 0, 0, 0, 100, 0, 5000, 8000, 14000, 15000, 0, 11, 13860, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Mind Blast'),
(42108, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 79384, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Sea Slam'),
(42112, 0, 2, 0, 4, 0, 100, 1, 0, 0, 0, 0, 0, 11, 79449, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Body Slam on Aggro'),
(42112, 0, 3, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 79490, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Diseased Bite'),
(42113, 0, 2, 0, 0, 0, 100, 0, 5000, 8000, 12000, 15000, 0, 11, 79384, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cast Sea Slam'),
(50409, 0, 1, 0, 0, 0, 100, 0, 3000, 3500, 11000, 11500, 0, 11, 93473, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Mysterious Camel Figurine - In Combat - Cast ''Sandstorm'''),
(46582, 0, 1, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 85236, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'On death - Self: Cast spell Corpse Rot (85236) on Self // '),
(40577, 0, 1, 0, 0, 0, 100, 0, 4000, 6000, 4000, 6000, 0, 11, 77218, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 4000 and 6000 ms (and later repeats every 4000 and 6000 ms) - Self: Cast spell 77218 on Random hostile // '),
(40925, 0, 1, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 76625, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'On death - Self: Cast spell Summon Unstable Corruptions (76625) on Self // '),
(39373, 0, 2, 0, 1, 0, 100, 0, 3000, 3000, 12000, 12000, 0, 11, 74632, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'When out of combat and timer at the begining between 3000 and 3000 ms (and later repeats every 12000 and 12000 ms) - Self: Cast spell 74632 on Self // '),
(52086, 0, 5, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 11, 45104, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'On reset (e.g. after reaching home) - Self: Cast spell 45104 on Self // '),
(52086, 0, 6, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 11, 96418, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'On death - Self: Cast spell 96418 on Self // '),
(52381, 0, 1, 0, 0, 0, 100, 0, 7000, 7000, 14000, 14000, 0, 11, 96475, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'When in combat and timer at the begining between 7000 and 7000 ms (and later repeats every 14000 and 14000 ms) - Self: Cast spell 96475 on Self // ');

-- Rollback:
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1781 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1642 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 6866 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 808 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1260 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8503 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 42291 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 43230 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2002 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2003 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2004 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2005 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2008 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 16522 AND `id` BETWEEN 14 AND 14;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17591 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 35660 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 47091 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3099 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3108 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3111 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3125 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3127 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3183 AND `id` BETWEEN 2 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3281 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5809 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5826 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10676 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 39072 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 39317 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 15274 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 154 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 391 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 449 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 506 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 594 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 833 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1109 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1174 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2476 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2071 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2237 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 35111 AND `id` BETWEEN 10 AND 10;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 35759 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 36131 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 16318 AND `id` BETWEEN 15 AND 15;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 334 AND `id` BETWEEN 3 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 428 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 486 AND `id` BETWEEN 5 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 578 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 711 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4462 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3875 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4805 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4818 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4831 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 48 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 202 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 206 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 511 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 628 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 920 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 930 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3946 AND `id` BETWEEN 4 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 43761 AND `id` BETWEEN 11 AND 11;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1036 AND `id` BETWEEN 6 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3733 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3734 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3743 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3745 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3750 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3752 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3763 AND `id` BETWEEN 3 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3770 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3780 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3810 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3846 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3847 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3917 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3921 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3922 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3924 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3925 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3943 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3944 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10559 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10641 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10642 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11697 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 12474 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 12475 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 12476 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 12759 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 14733 AND `id` BETWEEN 17 AND 17;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 14753 AND `id` BETWEEN 19 AND 19;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 34295 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2270 AND `id` BETWEEN 8 AND 9;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2319 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2344 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2358 AND `id` BETWEEN 5 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2369 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2555 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2560 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2566 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2585 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2591 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2599 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2602 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2606 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2619 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2761 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2783 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10696 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 15126 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 942 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4458 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4459 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4460 AND `id` BETWEEN 2 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 41437 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7079 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 689 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1562 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2522 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2545 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4457 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 43376 AND `id` BETWEEN 12 AND 13;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 43377 AND `id` BETWEEN 9 AND 11;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 43659 AND `id` BETWEEN 8 AND 9;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 43660 AND `id` BETWEEN 8 AND 9;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 3374 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 37091 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 37171 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4666 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4667 AND `id` BETWEEN 3 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4670 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4672 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4674 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4675 AND `id` BETWEEN 8 AND 9;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4728 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4729 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5760 AND `id` BETWEEN 2 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 35412 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 36094 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2574 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2657 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 42536 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 42555 AND `id` BETWEEN 3 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4344 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4345 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4393 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4394 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4967 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4979 AND `id` BETWEEN 10 AND 12;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1783 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1784 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1815 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1831 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 1852 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 44482 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5268 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5278 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5286 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5359 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11443 AND `id` BETWEEN 16 AND 16;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8519 AND `id` BETWEEN 8 AND 8;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8520 AND `id` BETWEEN 7 AND 8;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8521 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8522 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8526 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8535 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8541 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8551 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 9450 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 9452 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10824 AND `id` BETWEEN 19 AND 19;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11896 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 12261 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 16184 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 40959 AND `id` BETWEEN 4 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 41131 AND `id` BETWEEN 2 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 41196 AND `id` BETWEEN 12 AND 12;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 41199 AND `id` BETWEEN 12 AND 13;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 47487 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 47602 AND `id` BETWEEN 6 AND 8;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 47619 AND `id` BETWEEN 6 AND 9;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 47620 AND `id` BETWEEN 6 AND 9;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2717 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2739 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 2740 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5429 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5450 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5451 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5455 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5459 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5645 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5647 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7855 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7858 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 39081 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 9516 AND `id` BETWEEN 2 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 48259 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 48331 AND `id` BETWEEN 9 AND 10;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5840 AND `id` BETWEEN 9 AND 9;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5846 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5856 AND `id` BETWEEN 7 AND 8;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8391 AND `id` BETWEEN 5 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8400 AND `id` BETWEEN 21 AND 21;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 47311 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 615 AND `id` BETWEEN 4 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7025 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7027 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7035 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7038 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 9697 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 9776 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10078 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 48111 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 48119 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 48121 AND `id` BETWEEN 3 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 48201 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 6557 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 46714 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 46770 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 46775 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5983 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5998 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 6004 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 6005 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 6008 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 6009 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8299 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 42235 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 42334 AND `id` BETWEEN 1 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 15196 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7379 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4436 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4442 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4517 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 12242 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 12243 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 13142 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 13596 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 4852 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7023 AND `id` BETWEEN 8 AND 8;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11441 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11448 AND `id` BETWEEN 16 AND 16;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11452 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11455 AND `id` BETWEEN 16 AND 16;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11465 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11473 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11486 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11487 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11488 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 13021 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 13197 AND `id` BETWEEN 12 AND 12;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 13285 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 14327 AND `id` BETWEEN 14 AND 14;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 14354 AND `id` BETWEEN 22 AND 22;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7332 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7347 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7348 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7352 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7353 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10393 AND `id` BETWEEN 16 AND 16;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10398 AND `id` BETWEEN 12 AND 12;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10413 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 10425 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 11032 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5648 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7246 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 7797 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8921 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 8933 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 9024 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 9029 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 5277 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 16880 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 16915 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 16977 AND `id` BETWEEN 15 AND 15;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 16978 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22259 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22267 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17877 AND `id` BETWEEN 26 AND 26;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18088 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18130 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18131 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18285 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19706 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19729 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19730 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20196 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20279 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20280 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17088 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18482 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18670 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21651 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21787 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22199 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 23066 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 23067 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 23068 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 23219 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17160 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18069 AND `id` BETWEEN 19 AND 19;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18202 AND `id` BETWEEN 5 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18203 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18207 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18261 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18297 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18391 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18688 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19067 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19210 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19945 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19948 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19973 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19985 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19988 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19989 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19990 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19993 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20600 AND `id` BETWEEN 3 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20924 AND `id` BETWEEN 3 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20925 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21326 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21497 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21956 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22160 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22181 AND `id` BETWEEN 10 AND 10;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22204 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22221 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22242 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22289 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18850 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18853 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19466 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19541 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20102 AND `id` BETWEEN 2 AND 10;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20132 AND `id` BETWEEN 1 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20134 AND `id` BETWEEN 14 AND 14;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20139 AND `id` BETWEEN 15 AND 15;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20248 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20409 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20607 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20673 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20769 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20928 AND `id` BETWEEN 4 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21337 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21450 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21453 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21503 AND `id` BETWEEN 7 AND 8;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21506 AND `id` BETWEEN 2 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21663 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 21876 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22017 AND `id` BETWEEN 15 AND 15;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 22093 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24960 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24999 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25087 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17264 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17269 AND `id` BETWEEN 16 AND 17;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17478 AND `id` BETWEEN 2 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17371 AND `id` BETWEEN 16 AND 17;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17397 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17398 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17477 AND `id` BETWEEN 15 AND 15;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17626 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18493 AND `id` BETWEEN 20 AND 20;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18702 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 28132 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18320 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17800 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19167 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19231 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19712 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19713 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20059 AND `id` BETWEEN 3 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17994 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18405 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18422 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19507 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19509 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 19511 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20866 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20879 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20880 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20882 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 20902 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18640 AND `id` BETWEEN 14 AND 14;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 18794 AND `id` BETWEEN 34 AND 35;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 16704 AND `id` BETWEEN 24 AND 24;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17465 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24683 AND `id` BETWEEN 22 AND 22;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24684 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24685 AND `id` BETWEEN 19 AND 19;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24686 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24687 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24688 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24689 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24957 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25428 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25465 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25479 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25584 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25596 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25601 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25613 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25678 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25712 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25716 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25719 AND `id` BETWEEN 10 AND 10;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25720 AND `id` BETWEEN 10 AND 10;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25722 AND `id` BETWEEN 9 AND 9;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 25789 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26452 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24014 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24018 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24271 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24677 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 24797 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26402 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26467 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26926 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26942 AND `id` BETWEEN 11 AND 11;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27406 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27539 AND `id` BETWEEN 12 AND 12;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27564 AND `id` BETWEEN 15 AND 15;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27725 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27749 AND `id` BETWEEN 15 AND 15;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26261 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26417 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27259 AND `id` BETWEEN 13 AND 13;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27959 AND `id` BETWEEN 10 AND 12;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 28779 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 28083 AND `id` BETWEEN 23 AND 23;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 32517 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 30152 AND `id` BETWEEN 6 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 30174 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 29648 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 29769 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 29770 AND `id` BETWEEN 1 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 29840 AND `id` BETWEEN 1 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 30409 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 30922 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 31277 AND `id` BETWEEN 12 AND 12;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 31397 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 32149 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 32262 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 33429 AND `id` BETWEEN 7 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26730 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26734 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 30111 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 30179 AND `id` BETWEEN 4 AND 4;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 30319 AND `id` BETWEEN 5 AND 5;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 30338 AND `id` BETWEEN 1 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 26623 AND `id` BETWEEN 5 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 29768 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 29774 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27965 AND `id` BETWEEN 14 AND 14;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27639 AND `id` BETWEEN 16 AND 16;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 27640 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 39436 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 46925 AND `id` BETWEEN 5 AND 7;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 41644 AND `id` BETWEEN 3 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 42108 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 42112 AND `id` BETWEEN 2 AND 3;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 42113 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 50409 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 46582 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 40577 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 40925 AND `id` BETWEEN 1 AND 1;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 39373 AND `id` BETWEEN 2 AND 2;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 52086 AND `id` BETWEEN 5 AND 6;
-- DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 52381 AND `id` BETWEEN 1 AND 1;
