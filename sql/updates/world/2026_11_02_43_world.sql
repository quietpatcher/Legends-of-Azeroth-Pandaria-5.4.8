-- To-do 405 (SmartAI check on mobs, batch 4: Darkshore, Ashenvale, Westfall, LochModan, RedridgeMountains, Duskwood, Wetlands): 92 creatures cast spells on retail but have no script, or only the old 3.3.5 script, in our world DB.
-- Cause: our smart_scripts for these entries come from the alexkulya import (identical to ref_alex) or are missing; the Cataclysm sniff data (ref_cpp) has SmartAI with the retail casts for them.
-- Change: port the ref_cpp SmartAI (smart_scripts source_type 0 + 2 timed action lists + waypoints) for 92 creatures (7 new, 85 replacing an unchanged alexkulya script); AIName set to SmartAI for 6 entries that had none.
-- Schema/enum mapping: target_param4 = 0; event_flags 512 (WHILE_CHARMED in TC master; RAID40 difficulty in our core, would disable the event) dropped, 256 -> 0x10000 (DONT_RESET); action 27 COMBAT_STOP -> 203, 85 SELF_CAST -> 11 CAST with flag 0x10, 134 INVOKER_CAST -> 85; cast triggerFlags/targetsLimit (param3/4) = 0.
-- Source: ref_cpp (Cataclysm Preservation Project TDB434.22011, sniff-based) smart_scripts/creature_text/waypoints/conditions, rows copied 1:1 apart from the mapping above. Every spell id checked against the 5.4.8 client Spell.dbc + SpellEffect.dbc on dev (exists, has effects, name matches the ref_cpp comment). Not yet seen in game.
-- Rollback: rollback/405_batch4_rollback.sql (re-inserts the 85 replaced old scripts, deletes the ported rows, resets AIName for the 6 entries that had none).
-- Rollback (short, loses the replaced old scripts of 533,1270,1251,889,205,534,218,507,300,315,522,574,1167,1161,1165,1177,1162,1173,1172,1164,1197,1398,1399,1425,2476,14267,45369,157,834,517,456,515,573,117,453,500,625,589,624,1065,391,519,1424,423,568,712,431,580,14271,579,947,703,32999,32890,34369,3713,3817,3717,3799,3823,3803,6115,6073,3772,3821,3767,3926,3762,3765,3754,3797,3755,3758,3757,3771,12037,10640,3735,10639,3696,3773,3987,4273,5314,17300): DELETE FROM smart_scripts WHERE source_type=0 AND entryorguid IN (533,1270,212,1251,889,205,534,218,507,300,315,522,574,43862,1167,1161,1165,1177,1162,1173,1172,1164,1197,1398,1399,1425,2476,14267,45369,157,834,517,456,515,573,117,453,500,625,589,624,1065,391,519,1424,423,568,712,431,580,43173,14271,579,947,703,32999,32890,33978,34282,34033,34369,3713,3817,3717,33419,3799,3823,3803,6115,6073,3772,3821,3767,3926,3762,3765,3754,3797,3755,3758,3757,3771,12037,10640,3735,10639,3696,3773,3987,4273,5314,17300); DELETE FROM smart_scripts WHERE source_type=9 AND entryorguid IN (3403300,4317300); UPDATE creature_template SET AIName='' WHERE entry IN (212,43862,43173,34282,34033,33419);

-- 533 Nightbane Shadow Weaver (Duskwood, 25 spawns): replace, 6 rows, 2 casts: 85072 Woven Shadows [e28/a0]; 77721 Shadow Weave [e2/a0]
-- 1270 Fetid Corpse (Duskwood, 21 spawns): replace, 3 rows, 3 casts: 85234 Fetid Breath [e2/a0,e6/a26]; 7102 Contagion of Rot [e6/a138,e6/a65,e6/a42]; 26047 Birth [e46/a0]
-- 212 Splinter Fist Warrior (Duskwood, 17 spawns): insert, 7 rows, 2 casts: 78828 Bladestorm [e6/a23]; 35856 Stun [e6/a12,e68/a0]
-- 1251 Splinter Fist Firemonger (Duskwood, 14 spawns): replace, 3 rows, 2 casts: 78509 Torch Toss [e2/a0,e6/a3]; 13878 Scorch [e2/a0]
-- 889 Splinter Fist Ogre (Duskwood, 7 spawns): replace, 2 rows, 1 casts: 80182 Uppercut [e31/a0,e98/a0]
-- 205 Nightbane Dark Runner (Duskwood, 4 spawns): replace, 2 rows, 2 casts: 7137 Shadow Charge [e6/a31,e6/a13,e6/a42]; 6595 Exploit Weakness [e31/a0]
-- 534 Nefaru (Duskwood, 3 spawns): replace, 3 rows, 3 casts: 3604 Tendon Rip [e6/a33]; 3427 Infected Wound [e6/a87]; 8715 Terrifying Howl [e6/a7]
-- 218 Grave Robber (Duskwood, 2 spawns): replace, 2 rows, 1 casts: 6595 Exploit Weakness [e31/a0]
-- 507 Fenros (Duskwood, 2 spawns): replace, 3 rows, 3 casts: 7137 Shadow Charge [e6/a31,e6/a13,e6/a42]; 6595 Exploit Weakness [e31/a0]; 84308 Furious Howl [e6/a80]
-- 300 Zzarc' Vul (Duskwood, 1 spawns): replace, 5 rows, 4 casts: 78828 Bladestorm [e6/a23]; 80182 Uppercut [e31/a0,e98/a0]; 8716 Low Swipe [e31/a0,e6/a33,e64/a0]; 5164 Knockdown [e6/a12]
-- 315 Stalvan Mistmantle (Duskwood, 1 spawns): replace, 2 rows, 2 casts: 85234 Fetid Breath [e2/a0,e6/a26]; 3105 Curse of Stalvan [e6/a80]
-- 522 Mor'Ladim (Duskwood, 1 spawns): replace, 2 rows, 2 casts: 79961 Holy Shock [e2/a0]; 3547 Enraging Memories [e6/a138,e6/a33,e6/a13]
-- 574 Naraxis (Duskwood, 1 spawns): replace, 3 rows, 3 casts: 13884 Withering Poison [e6/a3,e6/a80,e6/a80]; 87080 Vanish [e6/a16,e6/a138,e6/a42]; 12023 Web [e6/a26,e64/a0]
-- 43862 Stitches (Duskwood, 1 spawns): insert, 1 rows, 1 casts: 3106 Aura of Rot [e2/a0]
-- 1167 Stonesplinter Digger (LochModan, 24 spawns): replace, 3 rows, 3 casts: 84857 Stone Splinter [e2/a0,e98/a0]; 80382 Dirt Toss [e6/a33,e6/a5]; 6016 Pierce Armor [e6/a101]
-- 1161 Stonesplinter Trogg (LochModan, 23 spawns): replace, 1 rows, 1 casts: 84857 Stone Splinter [e2/a0,e98/a0]
-- 1165 Stonesplinter Geomancer (LochModan, 22 spawns): replace, 4 rows, 4 casts: 84857 Stone Splinter [e2/a0,e98/a0]; 79927 Earth Shield [e6/a42]; 79886 Lava Burst [e2/a0]
-- 1177 Tunnel Rat Surveyor (LochModan, 21 spawns): replace, 2 rows, 2 casts: 84863 Tunnel [e5/a0,e6/a77]; 80382 Dirt Toss [e6/a33,e6/a5]
-- 1162 Stonesplinter Scout (LochModan, 16 spawns): replace, 2 rows, 2 casts: 84857 Stone Splinter [e2/a0,e98/a0]; 78509 Torch Toss [e2/a0,e6/a3]
-- 1173 Tunnel Rat Scout (LochModan, 13 spawns): replace, 2 rows, 2 casts: 6660 Shoot [e2/a0]; 82708 Flaming Arrow [e2/a0]
-- 1172 Tunnel Rat Vermin (LochModan, 10 spawns): replace, 1 rows, 1 casts: 84863 Tunnel [e5/a0,e6/a77]
-- 1164 Stonesplinter Bonesnapper (LochModan, 9 spawns): replace, 2 rows, 2 casts: 84857 Stone Splinter [e2/a0,e98/a0]; 82625 Bone Toss [e2/a0]
-- 1197 Stonesplinter Shaman (LochModan, 9 spawns): replace, 4 rows, 4 casts: 9739 Wrath [e2/a0]; 84857 Stone Splinter [e2/a0,e98/a0]; 79927 Earth Shield [e6/a42]
-- 1398 Boss Galgosh (LochModan, 3 spawns): replace, 4 rows, 3 casts: 8599 Enrage [e6/a79,e6/a138]; 82625 Bone Toss [e2/a0]; 80983 Commanding Shout [e6/a137]
-- 1399 Magosh (LochModan, 2 spawns): replace, 5 rows, 5 casts: 79927 Earth Shield [e6/a42]; 39591 Searing Totem [e28/a0]; 13281 Earth Shock [e2/a0,e6/a138]; 84857 Stone Splinter [e2/a0,e98/a0]
-- 1425 Kubb (LochModan, 2 spawns): replace, 1 rows, 1 casts: 81252 Full of Meat [e2/a0,e6/a193,e6/a33]
-- 2476 Gosh-Haldir (LochModan, 2 spawns): replace, 4 rows, 3 casts: 81173 Frenzy [e6/a138,e6/a61,e0/a0]; 54663 Fatal Bite [e9/a0]; 3427 Infected Wound [e6/a87]
-- 14267 Emogg the Crusher (LochModan, 2 spawns): replace, 3 rows, 2 casts: 8599 Enrage [e6/a79,e6/a138]; 84709 Stomp [e98/a0,e31/a0]
-- 45369 Morick Darkbrew (LochModan, 1 spawns): replace, 3 rows, 3 casts: 13340 Fire Blast [e2/a0]; 37591 Drunken Haze [e6/a193,e100/a0,e6/a31]; 80576 Shadowstep [e5/a0]
-- 157 Goretusk (Westfall, 93 spawns): replace, 2 rows, 2 casts: 6268 Rushing Charge [e96/a0,e6/a79]; 32019 Gore [e6/a3,e2/a0]
-- 834 Coyote (Westfall, 66 spawns): replace, 3 rows, 1 casts: 80362 Crushing Bite [e6/a101]
-- 517 Murloc Oracle (Westfall, 35 spawns): replace, 3 rows, 2 casts: 9734 Holy Smite [e2/a0]; 11835 Power Word: Shield [e6/a69]
-- 456 Murloc Minor Oracle (Westfall, 28 spawns): replace, 3 rows, 3 casts: 79831 Wave Crash [e2/a0]; 79892 Water Shield [e6/a4,e6/a42]
-- 515 Murloc Raider (Westfall, 23 spawns): replace, 2 rows, 2 casts: 6533 Net [e6/a26,e64/a0]; 80522 Demoralizing Mmmrrrggglll [e6/a166,e6/a79]
-- 573 Foe Reaper 4000 (Westfall, 22 spawns): replace, 2 rows, 2 casts: 7342 Wide Slash [e58/a0]; 80572 Energize! [e6/a61,e6/a79,e6/a193]
-- 117 Riverpaw Gnoll (Westfall, 18 spawns): replace, 3 rows, 1 casts: 80475 Riverpaw Brand [e6/a3,e2/a0]
-- 453 Riverpaw Mystic (Westfall, 16 spawns): replace, 5 rows, 3 casts: 79913 Chain Lightning [e2/a0]; 79924 Healing Wave [e10/a0]
-- 500 Riverpaw Scout (Westfall, 14 spawns): replace, 4 rows, 2 casts: 6660 Shoot [e2/a0]; 78509 Torch Toss [e2/a0,e6/a3]
-- 625 Undead Dynamiter (Westfall, 9 spawns): replace, 2 rows, 2 casts: 7395 Deadmines Dynamite [e2/a0]; 26047 Birth [e46/a0]
-- 589 Defias Pillager (Westfall, 5 spawns): replace, 3 rows, 3 casts: 13878 Scorch [e2/a0]; 79849 Molten Armor [e6/a42,e6/a197,e6/a57]; 79857 Blast Wave [e2/a0,e6/a33]
-- 624 Undead Excavator (Westfall, 5 spawns): replace, 2 rows, 2 casts: 5137 Call of the Grave [e6/a3]; 26047 Birth [e46/a0]
-- 1065 Riverpaw Shaman (Westfall, 4 spawns): replace, 4 rows, 3 casts: 9532 Lightning Bolt [e2/a0]; 12550 Lightning Shield [e6/a43]
-- 391 Old Murk-Eye (Westfall, 3 spawns): replace, 4 rows, 3 casts: 80555 Sonic Spear [e3/a0,e2/a0]; 78542 Splash [e2/a0,e98/a0]; 8599 Enrage [e6/a79,e6/a138]
-- 519 Slark (Westfall, 2 spawns): replace, 3 rows, 3 casts: 79831 Wave Crash [e2/a0]; 79892 Water Shield [e6/a4,e6/a42]
-- 1424 Master Digger (Westfall, 1 spawns): replace, 3 rows, 2 casts: 80382 Dirt Toss [e6/a33,e6/a5]; 6016 Pierce Armor [e6/a101]
-- 423 Redridge Mongrel (RedridgeMountains, 27 spawns): replace, 1 rows, 1 casts: 3427 Infected Wound [e6/a87]
-- 568 Shadowhide Warrior (RedridgeMountains, 24 spawns): replace, 2 rows, 2 casts: 7164 Defensive Stance [e6/a36]; 11971 Sunder Armor [e6/a22]
-- 712 Redridge Thrasher (RedridgeMountains, 21 spawns): replace, 1 rows, 1 casts: 80182 Uppercut [e31/a0,e98/a0]
-- 431 Shadowhide Slayer (RedridgeMountains, 14 spawns): replace, 2 rows, 2 casts: 8599 Enrage [e6/a79,e6/a138]; 77720 Execute [e31/a0]
-- 580 Redridge Drudger (RedridgeMountains, 6 spawns): replace, 2 rows, 1 casts: 80512 Fling Filth [e2/a0]
-- 43173 Redridge Garrison Watchman (RedridgeMountains, 6 spawns): insert, 6 rows, 2 casts: 12170 Revenge [e2/a0]; 12169 Shield Block [e6/a51]
-- 14271 Ribchaser (RedridgeMountains, 3 spawns): replace, 1 rows, 1 casts: 8599 Enrage [e6/a79,e6/a138]
-- 579 Shadowhide Assassin (RedridgeMountains, 2 spawns): replace, 3 rows, 3 casts: 22766 Sneak [e6/a16,e6/a33]; 744 Poison [e6/a3]
-- 947 Rohh the Silent (RedridgeMountains, 2 spawns): replace, 3 rows, 3 casts: 22766 Sneak [e6/a16,e6/a33]; 744 Poison [e6/a3]
-- 703 General Fangore (RedridgeMountains, 1 spawns): replace, 2 rows, 2 casts: 32736 Mortal Strike [e31/a0,e6/a118]; 6268 Rushing Charge [e96/a0,e6/a79]
-- 32999 Unbound Fire Elemental (Darkshore, 23 spawns): replace, 2 rows, 2 casts: 75025 Rush of Flame [e149/a0,e77/a0]; 13729 Flame Shock [e2/a0,e6/a3]
-- 32890 Enraged Tidal Spirit (Darkshore, 19 spawns): replace, 1 rows, 1 casts: 39207 Water Spout [e32/a0]
-- 33978 Hungry Thistle Bear (Darkshore, 17 spawns): insert, 1 rows, 1 casts: 5422 Lacerate [e58/a0,e6/a33]
-- 34282 Twilight Rider (Darkshore, 7 spawns): insert, 1 rows, 1 casts: 65060 Twilight Bolt [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 34033 Teegan Holloway (Darkshore, 1 spawns): insert, 11 rows, 2 casts: 7137 Shadow Charge [e6/a31,e6/a13,e6/a42]; 38926 Dark Strike [e58/a0]
-- 34369 Hermit Tide Crawler (Darkshore, 1 spawns): replace, 1 rows, 1 casts: 75004 Pinch [e31/a0,e6/a4]
-- 3713 Wrathtail Wave Rider (Ashenvale, 81 spawns): replace, 2 rows, 1 casts: 78732 Whirlpool [e6/a23,e6/a147,e6/a263]
-- 3817 Shadowhorn Stag (Ashenvale, 77 spawns): replace, 2 rows, 2 casts: 6921 Shadowhorn Charge [e6/a31,e6/a13,e6/a42]; 6922 Curse of the Shadowhorn [e6/a14,e6/a13,e6/a13]
-- 3717 Wrathtail Sorceress (Ashenvale, 64 spawns): replace, 4 rows, 3 casts: 9672 Frostbolt [e2/a0,e6/a33]; 11831 Frost Nova [e2/a0,e6/a26]; 34827 Water Shield [e6/a4,e6/a42]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 33419 Tendril from Below (Ashenvale, 35 spawns): insert, 3 rows, 2 casts: 62975 Shadow Bolt [e2/a0]; 78751 Mind Flay [e6/a3,e6/a33]; event_flags 512 (WHILE_CHARMED) dropped on 3 rows
-- 3799 Severed Druid (Ashenvale, 34 spawns): replace, 2 rows, 2 casts: 9739 Wrath [e2/a0]; 12160 Rejuvenation [e6/a8]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 3823 Ghostpaw Runner (Ashenvale, 34 spawns): replace, 4 rows, 3 casts: 78703 Ghostform [e6/a56]; 78702 Arcane Explosion [e2/a0]; 8599 Enrage [e6/a79,e6/a138]
-- 3803 Severed Keeper (Ashenvale, 32 spawns): replace, 2 rows, 2 casts: 78907 Starfire [e2/a0]; 15798 Moonfire [e6/a3,e2/a0]
-- 6115 Roaming Felguard (Ashenvale, 28 spawns): replace, 3 rows, 2 casts: 22859 Mortal Cleave [e31/a0,e6/a118]; 8599 Enrage [e6/a79,e6/a138]
-- 6073 Searing Infernal (Ashenvale, 21 spawns): replace, 2 rows, 2 casts: 36247 Fel Fireball [e2/a0]; 32749 Fire Shield [e6/a23]
-- 3772 Lesser Felguard (Ashenvale, 18 spawns): replace, 4 rows, 3 casts: 18812 Knockdown [e6/a12,e31/a0]; 184 Fire Shield [e6/a23]; 8599 Enrage [e6/a79,e6/a138]
-- 3821 Wildthorn Lurker (Ashenvale, 15 spawns): replace, 3 rows, 3 casts: 77806 Stealth [e6/a16]; 744 Poison [e6/a3]
-- 3767 Bleakheart Trickster (Ashenvale, 10 spawns): replace, 3 rows, 2 casts: 8599 Enrage [e6/a79,e6/a138]; 77457 Dazzling Lights [e6/a49]
-- 3926 Thistlefur Pathfinder (Ashenvale, 9 spawns): replace, 4 rows, 3 casts: 6660 Shoot [e2/a0]; 6813 Coat of Thistlefur [e6/a15]; 78754 Arcane Shot [e2/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 3762 Felmusk Felsworn (Ashenvale, 7 spawns): replace, 5 rows, 4 casts: 32707 Incinerate [e2/a0]; 11962 Immolate [e6/a3,e2/a0]; 6942 Overwhelming Stench [e6/a23]; 8599 Enrage [e6/a79,e6/a138]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows
-- 3765 Bleakheart Satyr (Ashenvale, 7 spawns): replace, 3 rows, 2 casts: 8599 Enrage [e6/a79,e6/a138]; 31279 Swipe [e2/a0]
-- 3754 Xavian Betrayer (Ashenvale, 6 spawns): replace, 2 rows, 2 casts: 77522 Swoop [e31/a0,e98/a0]; 6925 Gift of the Xavian [e10/a0]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 3797 Cenarion Protector (Ashenvale, 6 spawns): replace, 5 rows, 4 casts: 7090 Bear Form [e6/a36]; 15727 Demoralizing Roar [e6/a99]; 12160 Rejuvenation [e6/a8]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows
-- 3755 Xavian Felsworn (Ashenvale, 5 spawns): replace, 2 rows, 2 casts: 35913 Fel Fireball [e2/a0]; 6925 Gift of the Xavian [e10/a0]
-- 3758 Felmusk Satyr (Ashenvale, 5 spawns): replace, 4 rows, 3 casts: 31279 Swipe [e2/a0]; 6942 Overwhelming Stench [e6/a23]; 8599 Enrage [e6/a79,e6/a138]
-- 3757 Xavian Hellcaller (Ashenvale, 4 spawns): replace, 3 rows, 3 casts: 9053 Fireball [e2/a0]; 6925 Gift of the Xavian [e10/a0]; 39273 Rain of Fire [e27/a3]
-- 3771 Bleakheart Hellcaller (Ashenvale, 4 spawns): replace, 6 rows, 3 casts: 12746 Summon Voidwalker [e56/a0]; 11939 Summon Imp [e28/a0]; 8599 Enrage [e6/a79,e6/a138]
-- 12037 Ursol'lok (Ashenvale, 4 spawns): replace, 2 rows, 2 casts: 75002 Leaping Rush [e41/a0,e31/a0]; 84867 Sundering Swipe [e31/a0,e6/a101]
-- 10640 Oakpaw (Ashenvale, 3 spawns): replace, 2 rows, 2 casts: 6819 Corrupted Stamina [e6/a29]; 12160 Rejuvenation [e6/a8]
-- 3735 Apothecary Falthis (Ashenvale, 2 spawns): replace, 3 rows, 2 casts: 21067 Poison Bolt [e2/a0,e6/a3]; 78705 Poison Bottle [e32/a0]
-- 10639 Rorgish Jowl (Ashenvale, 2 spawns): replace, 4 rows, 3 casts: 6813 Coat of Thistlefur [e6/a15]; 8078 Thunderclap [e2/a0,e6/a33,e6/a138]; 3490 Frenzied Rage [e6/a138,e6/a13]
-- 3696 Ran Bloodtooth (Ashenvale, 1 spawns): replace, 7 rows, 4 casts: 6660 Shoot [e2/a0]; 78842 Carnivorous Bite [e2/a0,e6/a3]; 78841 Aimed Shot [e31/a0,e6/a118]; 8599 Enrage [e6/a79,e6/a138]; event_flags 512 (WHILE_CHARMED) dropped on 2 rows
-- 3773 Akkrilus (Ashenvale, 1 spawns): replace, 2 rows, 2 casts: 37628 Fel Immolate [e6/a3,e2/a0]; 35913 Fel Fireball [e2/a0]
-- 3987 Dal Bloodclaw (Ashenvale, 1 spawns): replace, 5 rows, 4 casts: 6813 Coat of Thistlefur [e6/a15]; 77558 Bloody Strike [e31/a0,e6/a79,e6/a54]; 21049 Bloodlust [e6/a138]; 8599 Enrage [e6/a79,e6/a138]
-- 4273 Keeper Ordanus (Ashenvale, 1 spawns): replace, 4 rows, 3 casts: 9739 Wrath [e2/a0]; 12747 Entangling Roots [e6/a26,e6/a3]; 8599 Enrage [e6/a79,e6/a138]; event_flags 512 (WHILE_CHARMED) dropped on 1 rows
-- 5314 Phantim (Ashenvale, 1 spawns): replace, 2 rows, 2 casts: 20667 Corrosive Acid Breath [e6/a3,e2/a0,e6/a22]; 20671 Summon Phantim Illusion [e28/a0]
-- 17300 Gorgannon (Ashenvale, 1 spawns): replace, 5 rows, 3 casts: 9613 Shadow Bolt [e2/a0]; 11428 Knockdown [e6/a12,e31/a0]; 37624 Carrion Swarm [e2/a0]

DELETE FROM `smart_scripts` WHERE `source_type`=0 AND `entryorguid` IN (533,1270,212,1251,889,205,534,218,507,300,315,522,574,43862,1167,1161,1165,1177,1162,1173,1172,1164,1197,1398,1399,1425,2476,14267,45369,157,834,517,456,515,573,117,453,500,625,589,624,1065,391,519,1424,423,568,712,431,580,43173,14271,579,947,703,32999,32890,33978,34282,34033,34369,3713,3817,3717,33419,3799,3823,3803,6115,6073,3772,3821,3767,3926,3762,3765,3754,3797,3755,3758,3757,3771,12037,10640,3735,10639,3696,3773,3987,4273,5314,17300);
DELETE FROM `smart_scripts` WHERE `source_type`=9 AND `entryorguid` IN (3403300,4317300);
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (212,43862,43173,34282,34033,33419);
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(533,0,0,0,25,0,100,0,0,0,0,0,0,22,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On reset (e.g. after reaching home) - Self: Set event phase to 1 // '),
(533,0,1,2,1,1,100,0,1000,10000,21000,24000,0,5,479,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'When out of combat and timer at the begining between 1000 and 10000 ms (and later repeats every 21000 and 24000 ms) - Self: Play emote ONESHOT_SNIFF (479) // '),
(533,0,2,0,61,0,100,0,0,0,0,0,0,67,0,4000,4000,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,' Linked - Trigger timed event #0 in 4000 - 4000 ms // '),
(533,0,3,0,59,1,100,0,0,0,0,0,0,11,85072,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On timed event 0 triggered - Self: Cast spell Woven Shadows (85072) on Self // '),
(533,0,4,0,0,0,100,0,6000,6000,11000,11000,0,11,77721,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'When in combat and timer at the begining between 6000 and 6000 ms (and later repeats every 11000 and 11000 ms) - Self: Cast spell Shadow Weave (77721) on Victim // '),
(533,0,5,0,4,0,100,0,0,0,0,0,0,23,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On aggro - Self: Increment phase by 1 and decrement by 0 // '),
(1270,0,0,0,0,0,100,0,4000,7000,16000,18000,0,11,85234,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Fetid Corpse - In Combat - Cast \'Fetid Breath\''),
(1270,0,1,0,0,0,100,0,2000,8000,22000,26000,0,11,7102,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Fetid Corpse - In Combat - Cast \'Contagion of Rot\''),
(1270,0,2,0,1,0,100,1,0,0,0,0,0,11,26047,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Fetid Corpse - Out of Combat - Cast \'Birth\' (No Repeat)'),
(212,0,0,0,25,0,100,0,0,0,0,0,0,22,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On reset (e.g. after reaching home) - Self: Set event phase to 1 // '),
(212,0,1,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On aggro (20% chance) - Self: Talk 0 // '),
(212,0,2,0,4,0,100,0,0,0,0,0,0,22,2,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On aggro - Self: Set event phase to 2 // '),
(212,0,3,0,0,0,100,0,11000,12000,31000,31000,0,11,78828,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 11000 min and 12000 max ms (repeat 31000 min 31000 max ms) - Self: Cast spell Bladestorm (78828) on Self // '),
(212,0,4,0,8,0,100,0,78828,0,0,0,0,67,0,6000,6000,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On spell Bladestorm (78828) hit  - Trigger timed event #0 in 6000 - 6000 ms // '),
(212,0,5,0,59,2,100,0,0,0,0,0,0,11,35856,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On timed event 0 triggered - Self: Cast spell Stun (35856) on Self // '),
(212,0,6,0,8,0,100,0,35856,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On spell Stun (35856) hit  - Self: Talk 1 // '),
(1251,0,0,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On aggro (20% chance) - Self: Talk 0 // '),
(1251,0,1,0,0,0,100,0,11000,12000,23000,24000,0,11,78509,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 11000 min and 12000 max ms (repeat 23000 min 24000 max ms) - Self: Cast spell Torch Toss (78509) on Victim // '),
(1251,0,2,0,0,0,100,0,3000,4000,8000,12000,0,11,13878,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 3000 min and 4000 max ms (repeat 8000 min 12000 max ms) - Self: Cast spell Scorch (13878) on Victim // '),
(889,0,0,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On aggro (20% chance) - Self: Talk 0 // '),
(889,0,1,0,0,0,100,0,7000,9000,31000,31000,0,11,80182,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 7000 min and 9000 max ms (repeat 31000 min 31000 max ms) - Self: Cast spell Uppercut (80182) on Victim // '),
(205,0,0,0,0,0,100,0,1000,2000,31000,32000,0,11,7137,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 1000 min and 2000 max ms (repeat 31000 min 32000 max ms) - Self: Cast spell Shadow Charge (7137) on Victim // '),
(205,0,1,0,0,0,100,0,7000,8000,13000,16000,0,11,6595,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 7000 min and 8000 max ms (repeat 13000 min 16000 max ms) - Self: Cast spell Exploit Weakness (6595) on Victim // '),
(534,0,0,0,0,0,100,0,2000,3000,15000,17000,0,11,3604,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Nefaru - In Combat - Cast \'Tendon Rip\''),
(534,0,1,0,0,0,100,0,6000,11000,25000,28000,0,11,3427,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Nefaru - In Combat - Cast \'Infected Wound\''),
(534,0,2,0,0,0,100,0,12000,15000,33000,36000,0,11,8715,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Nefaru - In Combat - Cast \'Terrifying Howl\''),
(218,0,0,0,2,0,100,1,0,15,0,0,0,25,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Grave Robber - Between 0-15% Health - Flee For Assist (No Repeat)'),
(218,0,1,0,0,0,100,0,2000,3000,9000,12000,0,11,6595,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Grave Robber - In Combat - Cast \'Exploit Weakness\''),
(507,0,0,0,4,0,100,1,0,0,0,0,0,11,7137,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Fenros - On Aggro - Cast \'Shadow Charge\' (No Repeat)'),
(507,0,1,0,0,0,100,0,2000,3000,9000,12000,0,11,6595,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Fenros - In Combat - Cast \'Exploit Weakness\''),
(507,0,2,0,0,0,100,0,6000,9000,19000,22000,0,11,84308,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Fenros - In Combat - Cast \'Furious Howl\''),
(300,0,0,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Zzarc\' Vul - On Aggro - Say Line 0 (No Repeat)'),
(300,0,1,0,0,0,100,0,6000,9000,17000,24000,0,11,78828,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Zzarc\' Vul - In Combat - Cast \'Bladestorm\''),
(300,0,2,0,0,0,100,0,2000,4000,12000,18000,0,11,80182,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Zzarc\' Vul - In Combat - Cast \'Uppercut\''),
(300,0,3,0,9,0,100,0,0,5,22000,22000,0,11,8716,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Zzarc\' Vul - Within 0-5 Range - Cast \'Low Swipe\''),
(300,0,4,0,0,0,100,0,12000,15000,8000,25000,0,11,5164,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Zzarc\' Vul - In Combat - Cast \'Knockdown\''),
(315,0,0,0,0,0,100,0,4000,7000,16000,18000,0,11,85234,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stalvan Mistmantle - In Combat - Cast \'Fetid Breath\''),
(315,0,1,0,0,0,100,0,2000,3000,65000,68000,0,11,3105,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stalvan Mistmantle - In Combat - Cast \'Curse of Stalvan\''),
(522,0,0,0,0,0,100,0,3500,6000,12000,15000,0,11,79961,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Mor\'Ladim - In Combat - Cast \'Holy Shock\''),
(522,0,1,0,2,0,100,1,0,30,0,0,0,11,3547,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Mor\'Ladim - Between 0-30% Health - Cast \'Enraging Memories\' (No Repeat)'),
(574,0,0,0,0,0,100,0,3000,4500,15000,17000,0,11,13884,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Naraxis - In Combat - Cast \'Withering Poison\''),
(574,0,1,0,2,0,100,0,0,40,15000,21000,0,11,87080,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Naraxis - Between 0-40% Health - Cast \'Vanish\''),
(574,0,2,0,9,0,100,0,0,30,8000,9000,0,11,12023,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Naraxis - Within 0-30 Range - Cast \'Web\''),
(43862,0,0,0,11,0,100,1,0,0,0,0,0,11,3106,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stitches - On Respawn - Cast \'Aura of Rot\' (No Repeat)'),
(1167,0,0,0,0,0,100,0,9000,12000,22000,22000,0,11,84857,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Digger - In Combat - Cast \'Stone Splinter\''),
(1167,0,1,0,0,0,100,0,12000,15000,28000,33000,0,11,80382,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Digger - In Combat - Cast \'Dirt Toss\''),
(1167,0,2,0,0,0,100,0,7000,8000,12000,18000,0,11,6016,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Digger - In Combat - Cast \'Pierce Armor\''),
(1161,0,0,0,0,0,100,0,9000,12000,22000,22000,0,11,84857,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Trogg - In Combat - Cast \'Stone Splinter\''),
(1165,0,0,0,0,0,100,0,9000,12000,22000,22000,0,11,84857,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Geomancer - In Combat - Cast \'Stone Splinter\''),
(1165,0,1,0,1,0,100,0,500,1000,600000,600000,0,11,79927,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Geomancer - Out of Combat - Cast \'Earth Shield\''),
(1165,0,2,0,16,0,100,0,79927,1,15000,30000,0,11,79927,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Geomancer - On Friendly Unit Missing Buff \'Earth Shield\' - Cast \'Earth Shield\''),
(1165,0,3,0,0,0,100,0,8500,8500,10000,10500,0,11,79886,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Geomancer - In Combat - Cast \'Lava Burst\''),
(1177,0,0,0,0,0,100,0,6000,8000,27000,32000,0,11,84863,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Tunnel Rat Surveyor - In Combat - Cast \'Tunnel\''),
(1177,0,1,0,0,0,100,0,10000,13000,26000,27000,0,11,80382,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Tunnel Rat Surveyor - In Combat - Cast \'Dirt Toss\''),
(1162,0,0,0,0,0,100,0,9000,12000,22000,22000,0,11,84857,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Scout - In Combat - Cast \'Stone Splinter\''),
(1162,0,1,0,0,0,100,0,5000,6000,11000,18000,0,11,78509,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Scout - In Combat - Cast \'Torch Toss\''),
(1173,0,0,0,0,0,100,0,0,0,2300,3900,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Tunnel Rat Scout - In Combat - Cast \'Shoot\''),
(1173,0,1,0,0,0,100,0,8000,11000,18000,22000,0,11,82708,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Tunnel Rat Scout - In Combat - Cast \'Flaming Arrow\''),
(1172,0,0,0,0,0,100,0,6000,8000,27000,32000,0,11,84863,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Tunnel Rat Vermin - In Combat - Cast \'Tunnel\''),
(1164,0,0,0,0,0,100,0,9000,12000,22000,22000,0,11,84857,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Bonesnapper - In Combat - Cast \'Stone Splinter\''),
(1164,0,1,0,0,0,100,0,2000,4500,9000,12000,0,11,82625,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Bonesnapper - In Combat - Cast \'Bone Toss\''),
(1197,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9739,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Shaman - In Combat - Cast \'Wrath\''),
(1197,0,1,0,0,0,100,0,9000,12000,22000,22000,0,11,84857,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Shaman - In Combat - Cast \'Stone Splinter\''),
(1197,0,2,0,1,0,100,0,500,1000,600000,600000,0,11,79927,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Shaman - Out of Combat - Cast \'Earth Shield\''),
(1197,0,3,0,16,0,100,0,79927,1,15000,30000,0,11,79927,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stonesplinter Shaman - On Friendly Unit Missing Buff \'Earth Shield\' - Cast \'Earth Shield\''),
(1398,0,0,1,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Boss Galgosh - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(1398,0,1,0,61,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Boss Galgosh - Between 0-30% Health - Say Line 0 (No Repeat)'),
(1398,0,2,0,0,0,100,0,5800,9500,10500,12500,0,11,82625,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Boss Galgosh - In Combat - Cast \'Bone Toss\''),
(1398,0,3,0,4,0,100,1,0,0,0,0,0,11,80983,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Boss Galgosh - On Aggro - Cast \'Commanding Shout\' (No Repeat)'),
(1399,0,0,0,1,0,100,0,500,1000,600000,600000,0,11,79927,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Magosh - Out of Combat - Cast \'Earth Shield\''),
(1399,0,1,0,16,0,100,0,79927,1,15000,30000,0,11,79927,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Magosh - On Friendly Unit Missing Buff \'Earth Shield\' - Cast \'Earth Shield\''),
(1399,0,2,0,0,0,100,0,10000,12000,38000,42000,0,11,39591,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Magosh - In Combat - Cast \'Searing Totem\''),
(1399,0,3,0,0,0,100,0,8000,8500,12000,20000,0,11,13281,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Magosh - In Combat - Cast \'Earth Shock\''),
(1399,0,4,0,0,0,100,0,9000,12000,22000,22000,0,11,84857,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Magosh - In Combat - Cast \'Stone Splinter\''),
(1425,0,0,0,0,0,100,0,5000,5000,15000,15000,0,11,81252,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Kubb - In Combat - Cast \'Full of Meat\''),
(2476,0,0,1,2,0,100,1,0,25,0,0,0,11,81173,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Gosh-Haldir - Between 0-25% Health - Cast \'Frenzy\' (No Repeat)'),
(2476,0,1,0,61,0,100,1,0,25,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Gosh-Haldir - Between 0-25% Health - Say Line 0 (No Repeat)'),
(2476,0,2,0,12,0,100,0,0,20,9000,13000,0,11,54663,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gosh-Haldir - Target Between 0-20% Health - Cast \'Fatal Bite\''),
(2476,0,3,0,0,0,100,0,3500,6500,24000,25000,0,11,3427,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gosh-Haldir - In Combat - Cast \'Infected Wound\''),
(14267,0,0,1,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Emogg the Crusher - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(14267,0,1,0,61,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Emogg the Crusher - Between 0-30% Health - Say Line 0 (No Repeat)'),
(14267,0,2,0,0,0,100,0,8000,11000,22000,28000,0,11,84709,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Emogg the Crusher - In Combat - Cast \'Stomp\''),
(45369,0,0,0,0,0,100,0,2000,4500,12000,13000,0,11,13340,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Morick Darkbrew - In Combat - Cast \'Fire Blast\''),
(45369,0,1,0,0,0,100,0,9000,12000,33000,45000,0,11,37591,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Morick Darkbrew - In Combat - Cast \'Drunken Haze\''),
(45369,0,2,0,2,0,100,1,0,30,0,0,0,11,80576,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Morick Darkbrew - Between 0-30% Health - Cast \'Shadowstep\' (No Repeat)'),
(157,0,0,0,4,0,100,1,0,0,0,0,0,11,6268,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Goretusk - On Aggro - Cast \'Rushing Charge\' (No Repeat)'),
(157,0,1,0,0,0,100,0,5500,7800,18500,26300,0,11,32019,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Goretusk - In Combat - Cast \'Gore\''),
(834,0,0,1,1,0,10,0,30000,600000,120000,600000,0,4,1018,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Coyote - Out of Combat - Play Sound 1018'),
(834,0,1,0,61,0,100,0,30000,600000,120000,600000,0,5,393,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Coyote - Out of Combat - Play Emote 393'),
(834,0,2,0,0,0,100,0,7000,12000,24000,32000,0,11,80362,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Coyote - In Combat - Cast \'Crushing Bite\''),
(517,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9734,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Murloc Oracle - In Combat - Cast \'Holy Smite\''),
(517,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Murloc Oracle - Between 0-15% Health - Flee For Assist (No Repeat)'),
(517,0,2,0,2,1,100,1,0,30,0,0,0,11,11835,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Murloc Oracle - Between 0-30% Health - Cast \'Power Word: Shield\' (Phase 1) (No Repeat)'),
(456,0,0,0,0,0,100,0,5500,7500,25000,35000,0,11,79831,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Every 25 - 35 seconds (5.5 - 7.5s initially) - Self: Cast spell Wave Crash (79831) on Victim'),
(456,0,1,0,1,0,100,0,500,1000,500000,600000,0,11,79892,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Every 500 - 600 seconds (0.5 - 1s initially) - Self: Cast spell Water Shield (79892) on Self'),
(456,0,2,0,16,0,100,0,79892,1,15000,30000,0,11,79892,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'When friendly unit in range 1 yards has not got aura Water Shield (79892) (check every 15000 - 30000 ms) - Self: Cast spell Water Shield (79892) on Self'),
(515,0,0,0,0,0,100,0,2000,5000,50000,60000,0,11,6533,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Every 50 - 60 seconds (2 - 5s initially) - Self: Cast spell Net (6533) on Victim'),
(515,0,1,0,0,0,100,0,4000,6000,27500,33500,0,11,80522,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Every 27.5 - 33.5 seconds (4 - 6s initially) - Self: Cast spell Demoralizing Mmmrrrggglll (80522) on Self'),
(573,0,0,0,0,0,100,0,5000,8000,15000,20000,0,11,7342,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Foe Reaper 4000 - In Combat - Cast \'Wide Slash\''),
(573,0,1,0,2,0,100,0,0,40,25000,29000,0,11,80572,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Foe Reaper 4000 - Between 0-40% Health - Cast \'Energize!\''),
(117,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'When health between 0%-15%% (check once) - Self: Flee for assist'),
(117,0,1,0,0,0,100,0,3500,7200,25000,35000,0,11,80475,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Every 25 - 35 seconds (3.5 - 7.2s initially) - Self: Cast spell Riverpaw Brand (80475) on Victim'),
(117,0,2,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On aggro - Self: Talk 0 to invoker'),
(453,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Mystic - Between 0-15% Health - Flee For Assist (No Repeat)'),
(453,0,1,0,0,0,100,0,3500,4500,12500,15500,0,11,79913,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Mystic - In Combat - Cast \'Chain Lightning\''),
(453,0,2,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Mystic - On Aggro - Say Line 0 (No Repeat)'),
(453,0,3,0,14,0,100,0,250,40,15000,18000,0,11,79924,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Mystic - Friendly At 250 Health - Cast \'Healing Wave\''),
(453,0,4,0,2,0,100,1,0,30,0,0,0,11,79924,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Mystic - Between 0-30% Health - Cast \'Healing Wave\' (No Repeat)'),
(500,0,0,0,0,0,100,0,0,0,2300,3900,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Every 2.3 - 3.9 seconds (0 - 0s initially) - Self: Cast spell Shoot (6660) on Victim (flags: combat move)'),
(500,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'When health between 0%-15%% (check once) - Self: Flee for assist'),
(500,0,2,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'On aggro - Self: Talk 0 to invoker'),
(500,0,3,0,0,0,100,0,5000,7000,25000,30000,0,11,78509,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Every 25 - 30 seconds (5 - 7s initially) - Self: Cast spell Torch Toss (78509) on Victim'),
(625,0,0,0,0,0,100,0,500,4500,14000,32000,0,11,7395,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Undead Dynamiter - In Combat - Cast \'Deadmines Dynamite\''),
(625,0,1,0,1,0,100,1,0,0,0,0,0,11,26047,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Undead Dynamiter - Out of Combat - Cast \'Birth\' (No Repeat)'),
(589,0,0,0,0,0,100,0,0,0,3400,4700,0,11,13878,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Defias Pillager - In Combat - Cast \'Scorch\''),
(589,0,1,0,1,0,100,0,500,1000,600000,600000,0,11,79849,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Defias Pillager - Out of Combat - Cast \'Molten Armor\''),
(589,0,2,0,9,0,100,0,0,8,13600,14500,0,11,79857,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Defias Pillager - Within 0-8 Range - Cast \'Blast Wave\''),
(624,0,0,0,0,0,100,0,4000,8000,5000,16000,0,11,5137,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Undead Excavator - In Combat - Cast \'Call of the Grave\''),
(624,0,1,0,1,0,100,1,0,0,0,0,0,11,26047,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Undead Excavator - Out of Combat - Cast \'Birth\' (No Repeat)'),
(1065,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9532,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Shaman - In Combat - Cast \'Lightning Bolt\''),
(1065,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Shaman - Between 0-15% Health - Flee For Assist (No Repeat)'),
(1065,0,2,0,1,0,100,0,500,1000,600000,600000,0,11,12550,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Shaman - Out of Combat - Cast \'Lightning Shield\''),
(1065,0,3,0,16,0,100,0,12550,1,15000,30000,0,11,12550,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Shaman - On Friendly Unit Missing Buff \'Lightning Shield\' - Cast \'Lightning Shield\''),
(391,0,0,0,0,0,100,0,2000,3000,12000,14000,0,11,80555,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Old Murk-Eye - In Combat - Cast \'Sonic Spear\''),
(391,0,1,0,0,0,100,0,12000,15000,27000,35000,0,11,78542,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Old Murk-Eye - In Combat - Cast \'Splash\''),
(391,0,2,3,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Old Murk-Eye - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(391,0,3,0,61,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Old Murk-Eye - Between 0-30% Health - Say Line 0 (No Repeat)'),
(519,0,0,0,0,0,100,0,5500,7500,12500,18500,0,11,79831,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Slark - In Combat - Cast \'Wave Crash\''),
(519,0,1,0,1,0,100,0,500,1000,600000,600000,0,11,79892,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Slark - Out of Combat - Cast \'Water Shield\''),
(519,0,2,0,16,0,100,0,79892,1,15000,30000,0,11,79892,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Slark - On Friendly Unit Missing Buff \'Water Shield\' - Cast \'Water Shield\''),
(1424,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Master Digger - Between 0-15% Health - Flee For Assist (No Repeat)'),
(1424,0,1,0,0,0,100,0,6000,12000,27000,33000,0,11,80382,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Master Digger - In Combat - Cast \'Dirt Toss\''),
(1424,0,2,0,0,0,100,0,4000,7000,18000,27000,0,11,6016,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Master Digger - In Combat - Cast \'Pierce Armor\''),
(423,0,0,0,0,0,100,0,5000,8000,16000,20000,0,11,3427,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Infected Wound'),
(568,0,0,0,4,0,100,1,0,0,0,0,0,11,7164,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Defensive Stance on Aggro'),
(568,0,1,0,0,0,100,0,5000,8000,15000,15000,0,11,11971,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sunder Armor'),
(712,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,80182,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Uppercut'),
(431,0,0,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Enrage at 30% HP'),
(431,0,1,0,0,0,100,0,5000,5000,6000,6000,0,11,77720,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Execute'),
(580,0,0,0,0,0,100,0,0,0,3500,4100,0,11,80512,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Fling Filth'),
(580,0,1,0,2,0,100,1,0,15,0,0,0,25,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Flee at 15% HP'),
(43173,0,0,0,0,0,100,0,5000,8000,12000,13000,0,11,12170,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Revenge'),
(43173,0,1,0,2,0,100,0,0,55,15000,16000,0,11,12169,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shield Block at 55% HP'),
(43173,0,2,3,38,0,100,0,1,1,10000,10000,0,66,0,0,0,0,0,0,12,1,0,0,0,0.0,0.0,0.0,0.0,'S.A.F.E. Officer - On Data Set - Turn to Invoker'),
(43173,0,3,4,61,0,100,0,0,0,0,0,0,1,0,1,0,0,0,0,12,1,0,0,0,0.0,0.0,0.0,0.0,'S.A.F.E. Officer - On Data Set - Say 0 to target'),
(43173,0,4,0,61,0,100,0,0,0,0,0,0,80,4317300,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'S.A.F.E. Officer - On Data Set - Say 0 to target'),
(4317300,9,0,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'S.A.F.E. Officer - Script - Reset Orientation'),
(14271,0,0,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Enrage at 30% HP'),
(579,0,0,0,11,0,100,1,0,0,0,0,0,11,22766,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sneak on Spawn'),
(579,0,1,0,7,0,100,1,0,0,0,0,0,11,22766,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sneak on Evade'),
(579,0,2,0,0,0,100,0,5000,7000,15000,16000,0,11,744,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Poison'),
(947,0,0,0,11,0,100,1,0,0,0,0,0,11,22766,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sneak on Spawn'),
(947,0,1,0,7,0,100,1,0,0,0,0,0,11,22766,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sneak on Evade'),
(947,0,2,0,0,0,100,0,5000,7000,15000,16000,0,11,744,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Poison'),
(703,0,0,0,0,0,100,0,5000,8000,12000,15000,0,11,32736,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Mortal Strike'),
(703,0,1,0,4,0,100,1,0,0,0,0,0,11,6268,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Rushing Charge on Aggro'),
(32999,0,0,0,4,0,100,1,0,0,0,0,0,11,75025,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Unbound Fire Elemental - On Aggro - Cast \'Rush of Flame\' (No Repeat)'),
(32999,0,1,0,0,0,100,0,2000,4500,9000,15000,0,11,13729,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Unbound Fire Elemental - In Combat - Cast \'Flame Shock\''),
(32890,0,0,0,0,0,100,0,4000,6000,14000,22000,0,11,39207,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Enraged Tidal Spirit - In Combat - Cast \'Water Spout\''),
(33978,0,0,0,0,0,100,0,6000,8000,18000,22000,0,11,5422,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Hungry Thistle Bear - In Combat - Cast \'Lacerate\''),
(34282,0,0,0,0,0,100,0,0,0,3400,4700,0,11,65060,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Rider - In Combat - Cast \'Twilight Bolt\''),
(34033,0,0,0,25,0,100,0,0,0,0,0,0,53,0,34033,1,0,0,1,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Reset - Start Waypoint'),
(34033,0,1,0,40,0,100,0,3,34033,0,0,0,54,8000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Waypoint 3 Reached - Pause Waypoint'),
(34033,0,2,0,40,0,100,0,4,34033,0,0,0,54,5000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Waypoint 4 Reached - Pause Waypoint'),
(34033,0,3,0,40,0,100,0,7,34033,0,0,0,80,3403300,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Waypoint 7 Reached - Run Script'),
(34033,0,4,0,40,0,100,0,10,34033,0,0,0,54,10000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Waypoint 10 Reached - Pause Waypoint'),
(34033,0,5,6,4,0,100,1,0,0,0,0,0,11,7137,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Aggro - Cast \'Shadow Charge\' (No Repeat)'),
(34033,0,6,0,61,1,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Aggro - Say Line 0 (No Repeat)'),
(34033,0,7,0,0,0,100,0,2000,4500,12000,14000,0,11,38926,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - In Combat - Cast \'Dark Strike\''),
(3403300,9,0,0,0,0,100,0,0,0,0,0,0,54,10000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Script - Pause Waypoint'),
(3403300,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,8,0,0,0,0,0.0,0.0,0.0,0.855211,'Teegan Holloway - On Script - Turn to'),
(3403300,9,2,0,0,0,100,0,1000,1000,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teegan Holloway - On Script - Say Line 1'),
(34369,0,0,0,0,0,100,0,3000,4500,17000,23000,0,11,75004,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Hermit Tide Crawler - In Combat - Cast \'Pinch\''),
(3713,0,0,0,0,0,100,0,4000,5000,18000,24500,0,11,78732,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Wrathtail Wave Rider - In Combat - Cast \'Whirlpool\''),
(3713,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Wrathtail Wave Rider - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3817,0,0,0,4,0,100,1,0,0,0,0,0,11,6921,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowhorn Stag - On Aggro - Cast \'Shadowhorn Charge\' (No Repeat)'),
(3817,0,1,0,0,0,100,0,5000,6000,300000,300000,0,11,6922,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Shadowhorn Stag - In Combat - Cast \'Curse of the Shadowhorn\''),
(3717,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9672,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Wrathtail Sorceress - In Combat - Cast \'Frostbolt\''),
(3717,0,1,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Wrathtail Sorceress - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3717,0,2,0,9,0,100,0,0,8,12000,13000,0,11,11831,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Wrathtail Sorceress - Within 0-8 Range - Cast \'Frost Nova\''),
(3717,0,3,0,1,0,100,0,500,1000,600000,600000,0,11,34827,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Wrathtail Sorceress - Out of Combat - Cast \'Water Shield\''),
(33419,0,0,0,4,0,100,1,0,0,0,0,0,21,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Tendril from Below - On Aggro - Disable Combat Movement (No Repeat)'),
(33419,0,1,0,0,0,100,0,2000,3000,12000,19000,0,11,62975,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Tendril from Below - In Combat - Cast \'Shadow Bolt\''),
(33419,0,2,0,0,0,100,0,7000,8000,28000,35000,0,11,78751,2,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Tendril from Below - In Combat - Cast \'Mind Flay\''),
(3799,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9739,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Severed Druid - In Combat - Cast \'Wrath\''),
(3799,0,1,0,2,0,100,0,0,55,20000,34000,0,11,12160,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Severed Druid - Between 0-55% Health - Cast \'Rejuvenation\''),
(3823,0,0,0,4,0,100,1,0,0,0,0,0,11,78703,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ghostpaw Runner - On Aggro - Cast \'Ghostform\' (No Repeat)'),
(3823,0,1,0,0,0,100,0,4000,5000,15000,21000,0,11,78702,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ghostpaw Runner - In Combat - Cast \'Arcane Explosion\''),
(3823,0,2,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ghostpaw Runner - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3823,0,3,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ghostpaw Runner - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3803,0,0,0,0,0,100,0,0,0,3400,4700,0,11,78907,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Severed Keeper - In Combat - Cast \'Starfire\''),
(3803,0,1,0,0,0,100,0,8000,9000,24000,28000,0,11,15798,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Severed Keeper - In Combat - Cast \'Moonfire\''),
(6115,0,0,0,0,0,100,0,2000,3000,12000,19000,0,11,22859,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Roaming Felguard - In Combat - Cast \'Mortal Cleave\''),
(6115,0,1,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Roaming Felguard - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(6115,0,2,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Roaming Felguard - Between 0-30% Health - Say Line 0 (No Repeat)'),
(6073,0,0,0,0,0,100,0,6000,8000,18000,22000,0,11,36247,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Searing Infernal - In Combat - Cast \'Fel Fireball\''),
(6073,0,1,0,0,0,100,0,2000,3000,15000,15000,0,11,32749,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Searing Infernal - In Combat - Cast \'Fire Shield\''),
(3772,0,0,0,9,0,100,0,0,5,14000,19000,0,11,18812,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Lesser Felguard - Within 0-5 Range - Cast \'Knockdown\''),
(3772,0,1,0,0,0,100,0,2000,4500,66000,77000,0,11,184,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lesser Felguard - In Combat - Cast \'Fire Shield\''),
(3772,0,2,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lesser Felguard - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3772,0,3,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lesser Felguard - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3821,0,0,0,11,0,100,1,0,0,0,0,0,11,77806,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Wildthorn Lurker - On Respawn - Cast \'Stealth\' (No Repeat)'),
(3821,0,1,0,7,0,100,1,0,0,0,0,0,11,77806,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Wildthorn Lurker - On Evade - Cast \'Stealth\' (No Repeat)'),
(3821,0,2,0,0,0,100,0,4000,4000,17000,26000,0,11,744,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Wildthorn Lurker - In Combat - Cast \'Poison\''),
(3767,0,0,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Trickster - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3767,0,1,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Trickster - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3767,0,2,0,4,0,100,1,0,0,0,0,0,11,77457,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Trickster - On Aggro - Cast \'Dazzling Lights\' (No Repeat)'),
(3926,0,0,0,0,0,100,0,0,0,2300,3900,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Thistlefur Pathfinder - In Combat - Cast \'Shoot\''),
(3926,0,1,0,2,0,100,1,0,15,0,0,0,25,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Thistlefur Pathfinder - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3926,0,2,0,11,0,100,1,0,0,0,0,0,11,6813,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Thistlefur Pathfinder - On Respawn - Cast \'Coat of Thistlefur\' (No Repeat)'),
(3926,0,3,0,9,0,100,0,5,30,14000,19000,0,11,78754,2,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Thistlefur Pathfinder - Within 5-30 Range - Cast \'Arcane Shot\''),
(3762,0,0,0,0,0,100,0,0,0,3400,4700,0,11,32707,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Felsworn - In Combat - Cast \'Incinerate\''),
(3762,0,1,0,0,0,100,0,7000,8000,22000,26000,0,11,11962,2,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Felsworn - In Combat - Cast \'Immolate\''),
(3762,0,2,0,0,0,100,0,10000,12000,600000,600000,0,11,6942,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Felsworn - In Combat - Cast \'Overwhelming Stench\''),
(3762,0,3,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Felsworn - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3762,0,4,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Felsworn - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3765,0,0,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Satyr - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3765,0,1,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Satyr - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3765,0,2,0,0,0,100,0,5000,5500,12000,16000,0,11,31279,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Satyr - In Combat - Cast \'Swipe\''),
(3754,0,0,0,0,0,100,0,4000,4500,12000,18000,0,11,77522,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Xavian Betrayer - In Combat - Cast \'Swoop\''),
(3754,0,1,0,2,0,100,1,0,15,0,0,0,11,6925,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Xavian Betrayer - Between 0-15% Health - Cast \'Gift of the Xavian\' (No Repeat)'),
(3797,0,0,0,1,0,100,0,500,1000,300000,300000,0,11,7090,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cenarion Protector - Out of Combat - Cast \'Bear Form\''),
(3797,0,1,0,0,0,100,0,9000,20000,19000,24000,0,11,15727,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cenarion Protector - In Combat - Cast \'Demoralizing Roar\''),
(3797,0,2,3,2,0,100,0,0,50,14000,21000,0,28,7090,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cenarion Protector - Between 0-50% Health - Remove Aura \'Bear Form\''),
(3797,0,3,0,61,0,100,0,0,50,14000,21000,0,11,12160,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cenarion Protector - Between 0-50% Health - Cast \'Rejuvenation\''),
(3797,0,4,0,3,0,100,0,60,100,100,100,0,11,7090,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cenarion Protector - Between 60-100% Mana - Cast \'Bear Form\''),
(3755,0,0,0,0,0,100,0,0,0,3400,4700,0,11,35913,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Xavian Felsworn - In Combat - Cast \'Fel Fireball\''),
(3755,0,1,0,2,0,100,1,0,15,0,0,0,11,6925,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Xavian Felsworn - Between 0-15% Health - Cast \'Gift of the Xavian\' (No Repeat)'),
(3758,0,0,0,0,0,100,0,4000,5000,12000,19500,0,11,31279,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Satyr - In Combat - Cast \'Swipe\''),
(3758,0,1,0,0,0,100,0,10000,12000,600000,600000,0,11,6942,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Satyr - In Combat - Cast \'Overwhelming Stench\''),
(3758,0,2,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Satyr - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3758,0,3,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Felmusk Satyr - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3757,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9053,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Xavian Hellcaller - In Combat - Cast \'Fireball\''),
(3757,0,1,0,2,0,100,1,0,15,0,0,0,11,6925,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Xavian Hellcaller - Between 0-15% Health - Cast \'Gift of the Xavian\' (No Repeat)'),
(3757,0,2,0,0,0,100,0,5000,5000,21000,32000,0,11,39273,1,0,0,0,0,4,0,0,0,0,0.0,0.0,0.0,0.0,'Xavian Hellcaller - In Combat - Cast \'Rain of Fire\''),
(3771,0,0,0,1,0,100,1,0,0,0,0,0,31,1,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Hellcaller - Out of Combat - Set Phase Random Between 1-2 (No Repeat)'),
(3771,0,1,2,1,1,100,1,0,1000,0,0,0,11,12746,3,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Hellcaller - Out of Combat - Cast \'Summon Voidwalker\' (Phase 1)'),
(3771,0,2,0,61,1,100,0,0,1000,0,0,0,22,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Hellcaller - Out of Combat - Set Event Phase 0 (Phase 1)'),
(3771,0,3,4,1,2,100,1,0,1000,0,0,0,11,11939,3,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Hellcaller - Out of Combat - Cast \'Summon Imp\' (Phase 2)'),
(3771,0,4,0,61,2,100,0,0,1000,0,0,0,22,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Hellcaller - Out of Combat - Set Event Phase 0 (Phase 2)'),
(3771,0,5,0,2,0,100,1,0,15,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bleakheart Hellcaller - Between 0-15% Health - cast enrage (No Repeat)'),
(12037,0,0,0,4,0,100,1,0,0,0,0,0,11,75002,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Ursol\'lok - On Aggro - Cast \'Leaping Rush\' (No Repeat)'),
(12037,0,1,0,0,0,100,0,5000,7000,24000,32000,0,11,84867,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ursol\'lok - In Combat - Cast \'Sundering Swipe\''),
(10640,0,0,0,0,0,100,0,3000,4000,11000,12000,0,11,6819,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Oakpaw - In Combat - Cast \'Corrupted Stamina\''),
(10640,0,1,0,2,0,100,0,0,50,19000,25000,0,11,12160,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Oakpaw - Between 0-50% Health - Cast \'Rejuvenation\''),
(3735,0,0,0,0,0,100,0,2000,4500,12000,20000,0,11,21067,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Apothecary Falthis - In Combat - Cast \'Poison Bolt\''),
(3735,0,1,0,0,0,100,0,5000,8000,19000,25000,0,11,78705,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Apothecary Falthis - In Combat - Cast \'Poison Bottle\''),
(3735,0,2,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Apothecary Falthis - Between 0-15% Health - Flee For Assist (No Repeat)'),
(10639,0,0,0,11,0,100,1,0,0,0,0,0,11,6813,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Rorgish Jowl - On Respawn - Cast \'Coat of Thistlefur\' (No Repeat)'),
(10639,0,1,0,0,0,100,0,4000,6000,19000,27000,0,11,8078,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Rorgish Jowl - In Combat - Cast \'Thunderclap\''),
(10639,0,2,0,2,0,100,1,0,30,0,0,0,11,3490,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Rorgish Jowl - Between 0-30% Health - Cast \'Frenzied Rage\' (No Repeat)'),
(10639,0,3,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Rorgish Jowl - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3696,0,0,0,0,0,100,0,0,0,2300,3900,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ran Bloodtooth - In Combat - Cast \'Shoot\''),
(3696,0,1,2,2,0,100,1,0,15,0,0,0,25,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Ran Bloodtooth - Between 0-15% Health - Flee For Assist (No Repeat)'),
(3696,0,2,0,61,0,100,1,0,15,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ran Bloodtooth - Between 0-15% Health - Say Line 0 (No Repeat)'),
(3696,0,3,0,9,0,100,0,0,5,15000,25000,0,11,78842,2,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ran Bloodtooth - Within 0-5 Range - Cast \'Carnivorous Bite\''),
(3696,0,4,0,9,0,100,0,5,30,9000,22000,0,11,78841,2,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Ran Bloodtooth - Within 5-30 Range - Cast \'Aimed Shot\''),
(3696,0,5,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ran Bloodtooth - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3696,0,6,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Ran Bloodtooth - Between 0-30% Health - Say Line 0 (No Repeat)'),
(3773,0,0,0,0,0,100,0,5000,9000,21000,28000,0,11,37628,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Akkrilus - In Combat - Cast \'Fel Immolate\''),
(3773,0,1,0,0,0,100,0,2000,4000,24000,38000,0,11,35913,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Akkrilus - In Combat - Cast \'Fel Fireball\''),
(3987,0,0,0,11,0,100,1,0,0,0,0,0,11,6813,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dal Bloodclaw - On Respawn - Cast \'Coat of Thistlefur\' (No Repeat)'),
(3987,0,1,0,9,0,100,1,0,5,14000,17000,0,11,77558,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Dal Bloodclaw - Within 0-5 Range - Cast \'Bloody Strike\''),
(3987,0,2,0,2,0,100,1,0,50,0,0,0,11,21049,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dal Bloodclaw - Between 0-50% Health - Cast \'Bloodlust\' (No Repeat)'),
(3987,0,3,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dal Bloodclaw - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(3987,0,4,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dal Bloodclaw - Between 0-30% Health - Say Line 0 (No Repeat)'),
(4273,0,0,0,0,0,100,0,0,0,3400,4700,0,11,9739,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Keeper Ordanus - In Combat - Cast \'Wrath\''),
(4273,0,1,0,9,0,100,0,0,30,9000,11000,0,11,12747,2,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Keeper Ordanus - Within 0-30 Range - Cast \'Entangling Roots\''),
(4273,0,2,0,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Keeper Ordanus - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(4273,0,3,0,2,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Keeper Ordanus - Between 0-30% Health - Say Line 0 (No Repeat)'),
(5314,0,0,0,0,0,100,0,3000,6000,12000,19000,0,11,20667,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Phantim - In Combat - Cast \'Corrosive Acid Breath\''),
(5314,0,1,0,2,0,100,0,0,50,24000,32000,0,11,20671,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Phantim - Between 0-50% Health - Cast \'Summon Phantim Illusion\''),
(17300,0,0,0,9,0,100,0,0,40,15000,32000,0,11,9613,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gorgannon - Within 0-40 Range - Cast \'Shadow Bolt\''),
(17300,0,1,0,9,0,100,0,0,5,12000,24000,0,11,11428,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gorgannon - Within 0-5 Range - Cast \'Knockdown\''),
(17300,0,2,3,2,0,100,1,0,50,0,0,0,39,20,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Gorgannon - Between 0-50% Health - Call For Help (No Repeat)'),
(17300,0,3,0,61,0,100,1,0,50,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Gorgannon - Between 0-50% Health - Say Line 0 (No Repeat)'),
(17300,0,4,0,0,0,100,0,8000,9000,24000,32000,0,11,37624,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gorgannon - In Combat - Cast \'Carrion Swarm\'');
DELETE FROM `waypoints` WHERE `entry` IN (34033);
INSERT INTO `waypoints` (`entry`,`pointid`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`point_comment`) VALUES
(34033,1,7184.16,-738.466,72.3762,NULL,0,'Teegan Holloway'),
(34033,2,7185.9,-733.903,72.2967,NULL,0,'Teegan Holloway'),
(34033,3,7194.48,-739.729,69.6053,NULL,0,'Teegan Holloway'),
(34033,4,7184.9,-733.101,72.2967,NULL,0,'Teegan Holloway'),
(34033,5,7184.33,-741.907,73.0132,NULL,0,'Teegan Holloway'),
(34033,6,7185.54,-745.456,74.3206,NULL,0,'Teegan Holloway'),
(34033,7,7187.72,-747.922,75.4496,NULL,0,'Teegan Holloway'),
(34033,8,7195.9,-751.89,78.195,NULL,0,'Teegan Holloway'),
(34033,9,7201.9,-751.161,78.8961,NULL,0,'Teegan Holloway'),
(34033,10,7205.03,-747.945,78.9633,NULL,0,'Teegan Holloway'),
(34033,11,7196.89,-751.682,78.4019,NULL,0,'Teegan Holloway'),
(34033,12,7192.06,-751.099,77.035,NULL,0,'Teegan Holloway'),
(34033,13,7186.84,-747.746,75.217,NULL,0,'Teegan Holloway'),
(34033,14,7184.71,-743.697,73.666,NULL,0,'Teegan Holloway');
