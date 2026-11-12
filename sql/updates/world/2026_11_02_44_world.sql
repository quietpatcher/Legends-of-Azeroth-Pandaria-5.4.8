-- To-do 405 (SmartAI check on mobs, batch 5: manual review of the 55 creatures batches 1-4 skipped because our script holds quest/credit/scene mechanics or was changed by us): 49 creatures get their retail combat abilities, 6 stay as they are.
-- Cause: these creatures cast spells on retail (Cataclysm sniff data, ref_cpp) but our smart_scripts only hold the quest/credit/scene logic (alexkulya import or our own work) and no, or only the old 3.3.5, combat casts.
-- Change: decided per creature by hand (see the per-entry comments): merge (44) = our rows kept 1:1 with their ids and the ref_cpp combat rows appended with new ids (links remapped); port (5) = our plain combat-only script replaced by the ref_cpp rows. Quest/credit/scene rows are never touched. Left out: cpp rows duplicating a spell we already cast, casts with target NONE (cast nothing in our core), dummy-only spells without SpellScript, rows conflicting with our scene scripts. Timed action lists 6800,6801,6802,6803,6804 added. AIName set to SmartAI for 35304.
-- Schema/enum mapping as in batches 1-4: target_param4 = 0; event_flags 512 (WHILE_CHARMED in TC master; RAID40 difficulty in our core) dropped, 256 -> 0x10000; action 27 -> 203, 85 SELF_CAST -> 11 CAST with flag 0x10, 134 -> 85; cast triggerFlags/targetsLimit (param3/4) = 0.
-- Source: ref_cpp (Cataclysm Preservation Project TDB434.22011, sniff-based) smart_scripts/creature_text, rows copied 1:1 apart from the mapping above; our own rows re-inserted unchanged from the world DB of dev. Every spell id checked against the 5.4.8 client Spell.dbc + SpellEffect.dbc on dev (exists, has effects, name matches the ref_cpp comment). Not yet seen in game.
-- Rollback: rollback/405_batch5_rollback.sql (deletes every row of these entries and the added lists, re-inserts the current scripts in full, resets AIName for 35304).
-- Rollback (short, loses the kept/old rows): DELETE FROM smart_scripts WHERE source_type=0 AND entryorguid IN (3255,33277,33262,210,948,604,3,3256,501,48187,37090,45750,2165,33043,39596,39595,41251,33206,48269,33044,36845,34318,34707,3275,43923,7980,44164,11917,2011,11918,41611,48741,48742,11915,54373,35304,34415,33688,35660,36931,35880,35881,36638,34846,3396,37659,37171,43761,12940); DELETE FROM smart_scripts WHERE source_type=9 AND entryorguid IN (6800,6801,6802,6803,6804); UPDATE creature_template SET AIName='' WHERE entry IN (35304);

-- 3255 Sunscale Screecher (TheBarrens, 156 spawns): merge, 4 of our rows kept, 2 ref_cpp rows added: 82608 Howling Screech [e6/a33,e6/a166]; 44531 Dash [e6/a31]. our Stolen Silver follow/set-data/die rows stay; retail Howling Screech + Dash added
-- 33277 Greymist Warrior (Darkshore, 108 spawns): merge, 4 of our rows kept, 2 ref_cpp rows added: 3427 Infected Wound [e6/a87]; 74972 Greymist [e6/a54]. our respawn/aggro-follow/death-credit rows stay; retail Infected Wound + Greymist added
-- 33262 Greymist Tidehunter (Darkshore, 93 spawns): merge, 4 of our rows kept, 2 ref_cpp rows added: 86249 Throw [e31/a0]. our respawn/aggro-follow/death-credit rows stay; retail Throw + flee added
-- 210 Bone Chewer (Duskwood, 89 spawns): merge, 1 of our rows kept, 1 ref_cpp row added: 82625 Bone Toss [e2/a0]. our Morbent Fel data-set die row stays; retail Bone Toss added
-- 948 Rotted One (Duskwood, 84 spawns): merge, 2 of our rows kept, 1 ref_cpp row added: 85234 Fetid Breath [e2/a0,e6/a26]. Fetid Breath added; cpp id 1 left out: duplicate: we already cast Summon Flesh Eating Worms on death (triggered)
-- 604 Plague Spreader (Duskwood, 72 spawns): merge, 2 of our rows kept, 1 ref_cpp row added: 3436 Wandering Plague [e6/a87,e6/a80,e6/a42]. Wandering Plague added; cpp id 1 left out: duplicate: we already cast Corpse Rot on death
-- 3 Flesh Eater (Duskwood, 70 spawns): merge, 1 of our rows kept, 1 ref_cpp row added: 83884 Cannibalize [e6/a20]. our data-set die row stays; retail Cannibalize at 50% added
-- 3256 Sunscale Scytheclaw (TheBarrens, 61 spawns): merge, 4 of our rows kept, 1 ref_cpp row added: 12787 Thrash [e6/a42]. our Stolen Silver rows stay; retail Thrash added
-- 501 Riverpaw Herbalist (Westfall, 56 spawns): port, 0 of our rows kept, 5 ref_cpp rows added: 80472 Elixir of Agility [e6/a80]; 80471 Potion of Strength [e6/a80]; 80473 Tonic of Health [e6/a80]. our only row was a random action list with the three potions (lists 50101-50103 stay in the DB); replaced by the sniffed version (each potion 50%, flee, aggro say)
-- 48187 Hill Fawn (HillsbradFoothills, 52 spawns): merge, 8 of our rows kept, 1 ref_cpp row added: 32019 Gore [e6/a3,e2/a0]. Gore added; cpp id 0 left out: duplicate: Duskingdawn's Blessing already cast in our quest chain; cpp id 2 left out: Fawnplode with target NONE casts nothing in our core (GetTargets returns no target)
-- 37090 Deviate Terrortooth (SouthernBarrens, 38 spawns): merge, 1 of our rows kept, 2 ref_cpp rows added: 6268 Rushing Charge [e96/a0,e6/a79]; 80608 Summon Pebble [e28/a0]. our Soothing Seeds spellhit list rows stay; our plain Rushing Charge row replaced by the sniffed one, Summon Pebble added; our ids 1 replaced
-- 45750 Inconspicuous Bear (SilverpineForest, 33 spawns): merge, 6 of our rows kept, 3 ref_cpp rows added: 87187 Feral Charge [e96/a0]; 87185 Demoralizing Roar [e6/a166]; 31279 Swipe [e2/a0]. our 1%-credit/worgen transform rows stay; retail Feral Charge, Demoralizing Roar, Swipe added
-- 2165 Grizzled Thistle Bear (Darkshore, 26 spawns): merge, 3 of our rows kept, 2 ref_cpp rows added: 3242 Ravage [e31/a0,e6/a12]; 75002 Leaping Rush [e41/a0,e31/a0]. our Darkshore Protection spellhit rows stay; retail Ravage + Leaping Rush added
-- 33043 Maddened Blackwood (Darkshore, 26 spawns): merge, 9 of our rows kept, 1 ref_cpp row added: 75014 Howl of Madness [e6/a99]. our Blessed Herb Bundle phase rows stay; retail Howl of Madness added
-- 39596 Teeming Waterguard (Durotar, 25 spawns): merge, 2 of our rows kept, 1 ref_cpp row added: 78542 Splash [e2/a0,e98/a0]. our own out-of-combat face/strike rows stay; retail Splash added
-- 39595 Furious Earthguard (Durotar, 25 spawns): merge, 2 of our rows kept, 1 ref_cpp row added: 80117 Earth Spike [e32/a0]. our own out-of-combat face/strike rows stay; retail Earth Spike added
-- 41251 Frostmane Builder (DunMorogh, 25 spawns): merge, 2 of our rows kept, 3 ref_cpp rows added: 38557 Throw [e31/a0]; 58461 Sunder Armor [e6/a101]. our build emote + spellhit action list stay; retail Throw, flee, Sunder Armor added
-- 33206 Darkscale Scout (Darkshore, 25 spawns): merge, 1 of our rows kept, 1 ref_cpp row added: 31553 Hamstring [e31/a0,e6/a33]. our Twice Removed spellhit credit stays; retail Hamstring added
-- 48269 Dark Ranger (HillsbradFoothills, 23 spawns): merge, 3 of our rows kept, 3 ref_cpp rows added: 74613 Shoot [e2/a0]; 89702 Camouflage [e6/a312]. our Helcular's Rod rows stay; retail Shoot + Camouflage (aura 312 anim replacement, no stealth) added
-- 33044 Corrupted Blackwood (Darkshore, 23 spawns): merge, 9 of our rows kept, 3 ref_cpp rows added: 9739 Wrath [e2/a0]; 15039 Flame Shock [e2/a0,e6/a3]. our Blessed Herb Bundle phase rows stay; retail Wrath, flee, Flame Shock added; cpp id 2: event_flags 512 (WHILE_CHARMED) dropped
-- 36845 Agitated Earth Spirit (Mulgore, 22 spawns): merge, 2 of our rows kept, 1 ref_cpp row added: 81305 Rock Barrage [e2/a0]. our Soothe Earth Spirit rows stay; retail Rock Barrage added
-- 34318 Whitetail Stag (Darkshore, 21 spawns): merge, 3 of our rows kept, 2 ref_cpp rows added: 22120 Charge [e96/a0,e58/a0]; 31274 Knockdown [e6/a12,e2/a0]. our Darkshore Protection rows stay; retail Charge + Knockdown added
-- 34707 Theramore Deck Hand (TheBarrens, 18 spawns): merge, 1 of our rows kept, 1 ref_cpp row added: 75361 Swashbuckling Slice [e31/a0]. our scene attack row stays; Swashbuckling Slice added; cpp id 0 left out: Throw 66076 has only a dummy effect and no SpellScript in our core
-- 3275 Kolkar Marauder (TheBarrens, 17 spawns): port, 0 of our rows kept, 3 ref_cpp rows added: 6268 Rushing Charge [e96/a0,e6/a79]; 11976 Strike [e58/a0]; 8014 Tetanus [e6/a29]. our only row was the plain Strike cast (the alexkulya Verog summon was removed by us earlier and ref_cpp has none either); sniffed Rushing Charge, Strike, Tetanus
-- 43923 Forlorn Spirit (Duskwood, 16 spawns): merge, 2 of our rows kept, 1 ref_cpp row added: 81193 Unrelenting Anguish [e6/a3,e6/a33]. our Soothing Incense Cloud credit rows stay; retail Unrelenting Anguish added
-- 7980 Deathguard Elite (TirisfalGlades, 15 spawns): merge, 2 of our rows kept, 8 ref_cpp rows added + lists 6800,6801,6802,6803,6804: 18950 Invisibility and Stealth Detection [e6/a19,e6/a17]. our #484 Strike/Hamstring rows stay; stealth detection on reset and the emote responses (lists 6800-6804) added; cpp id 2 left out: identical to our row 0 (Strike); cpp id 3 left out: identical to our row 1 (Hamstring)
-- 44164 Sunscale Ravager (TheBarrens, 15 spawns): merge, 4 of our rows kept, 1 ref_cpp row added: 82608 Howling Screech [e6/a33,e6/a166]. our Stolen Silver rows stay; retail Howling Screech added
-- 11917 Boulderslide Geomancer (StonetalonMountains, 15 spawns): merge, 1 of our rows kept, 3 ref_cpp rows added: 20793 Fireball [e2/a0]; 81309 Cave-in [e27/a3]. our Whip 'Em spellhit lists stay; retail Fireball, flee, Cave-in added; cpp id 2: event_flags 512 (WHILE_CHARMED) dropped
-- 2011 Gnarlpine Augur (Teldrassil, 13 spawns): port, 0 of our rows kept, 3 ref_cpp rows added: 17227 Curse of Weakness [e6/a13]; 5628 Gnarlpine Vengeance [e6/a138,e6/a31,e6/a61]. our single row (Gnarlpine Vengeance every 9 s in combat) is an undocumented change of the alexkulya script; sniffed version = flee, Curse of Weakness, Vengeance at 20% (old row in the rollback)
-- 11918 Boulderslide Stonepounder (StonetalonMountains, 12 spawns): merge, 1 of our rows kept, 1 ref_cpp row added: 81361 Ground Spike [e2/a0,e98/a0]. our Whip 'Em spellhit lists stay; retail Ground Spike added
-- 41611 Amberstill Mountaineer (DunMorogh, 11 spawns): merge, 1 of our rows kept, 2 ref_cpp rows added: 8258 Devotion Aura [e35/a22]; 81460 Fierce Strike [e58/a0]. our reached-home despawn row stays; retail Devotion Aura + Fierce Strike added
-- 48741 SI:7 Operative (HillsbradFoothills, 10 spawns): merge, 1 of our rows kept, 3 ref_cpp rows added: 79851 Fan of Knives [e31/a0]; 60842 Expose Armor [e6/a101]; 79853 Evasion [e6/a49]. our spellhit credit row stays; retail Fan of Knives, Expose Armor, Evasion added
-- 48742 SI:7 Assassin (HillsbradFoothills, 9 spawns): merge, 1 of our rows kept, 3 ref_cpp rows added: 66060 Sprint [e6/a31]; 3583 Deadly Poison [e6/a3]; 60850 Mutilate [e80/a0,e64/a0,e64/a0]. our spellhit credit row stays; retail Sprint, Deadly Poison, Mutilate added
-- 11915 Boulderslide Rock Keeper (StonetalonMountains, 8 spawns): merge, 1 of our rows kept, 1 ref_cpp row added: 81305 Rock Barrage [e2/a0]. our Whip 'Em spellhit lists stay; retail Rock Barrage added
-- 54373 Riverpaw Herbalist (Westfall, 8 spawns): port, 0 of our rows kept, 5 ref_cpp rows added: 80472 Elixir of Agility [e6/a80]; 80471 Potion of Strength [e6/a80]; 80473 Tonic of Health [e6/a80]. same as 501 Riverpaw Herbalist (Horde phase copy)
-- 35304 Brute Enforcer (Kezan, 4 spawns): port, 0 of our rows kept, 1 ref_cpp row added: 76136 Acidic Sweat [e6/a42]. no script before (only an orphan smart_event condition); Acidic Sweat out of combat added, AIName set; cpp id 1 left out: gossip hello on a creature with npcflag 0 never fires; cpp id 2 left out: creature_text 35304 is machine-translated garbage in both DBs, not yelled until fixed
-- 34415 Darkscale Priestess (Darkshore, 4 spawns): merge, 1 of our rows kept, 3 ref_cpp rows added: 9672 Frostbolt [e2/a0,e6/a33]; 75062 Frost Nova [e2/a0,e6/a26]. our death data-set row (with its conditions) stays; retail Frostbolt, flee, Frost Nova added; cpp id 2: event_flags 512 (WHILE_CHARMED) dropped
-- 33688 Raging Ancient (Ashenvale, 3 spawns): merge, 2 of our rows kept, 2 ref_cpp rows added: 11922 Entangling Roots [e6/a26,e6/a3]; 45 War Stomp [e98/a0]. our data-set/die rows (with condition) stay; retail Entangling Roots + War Stomp added
-- 35660 Rampaging Worgen (GilneasCity, 2 spawns): merge, 1 of our rows kept, 2 ref_cpp rows added: 8599 Enrage [e6/a79,e6/a138]. our summon-attack script stays; Enrage at 30% + text added; cpp id 2 left out: conflicts with our summon script (passive); cpp id 3 left out: conflicts with our summon script (despawn); cpp id 4 left out: follow Gilneas Evacuation Facing Marker is the cpp scene, not ours; cpp id 5 left out: conflicts with our summon script (aggressive)
-- 36931 Orno Grimtotem (Mulgore, 1 spawn): merge, 25 of our rows kept, 1 ref_cpp row added: 77558 Bloody Strike [e31/a0,e6/a79,e6/a54]. our 25-row War Dance quest script stays; retail Bloody Strike added
-- 35880 Lady Silisthra (Azshara, 1 spawn): merge, 4 of our rows kept, 7 ref_cpp rows added: 6660 Shoot [e2/a0]; 15495 Explosive Shot [e58/a0]; 20299 Forked Lightning [e2/a0]; 12551 Frost Shot [e58/a0,e6/a33]; 15507 Lightning Shield [e6/a43]. our power-stone shield rows stay; retail Shoot, flee, Explosive Shot, Forked Lightning, Frost Shot, Lightning Shield added
-- 35881 Lady Vesthra (Azshara, 1 spawn): merge, 4 of our rows kept, 6 ref_cpp rows added: 9672 Frostbolt [e2/a0,e6/a33]; 11831 Frost Nova [e2/a0,e6/a26]; 21067 Poison Bolt [e2/a0,e6/a3]; 38663 Slow [e6/a33,e6/a193]; 81039 Toxic Nova [e2/a0,e6/a3]. our power-stone shield rows stay; retail Frostbolt, flee, Frost Nova, Poison Bolt, Slow, Toxic Nova added
-- 36638 Twilight Lord Katrana (Azshara, 1 spawn): merge, 2 of our rows kept, 1 ref_cpp row added: 69135 Twilight Barrier [e6/a87]. our death data-set row (with quest condition) stays; Twilight Barrier at 60% added; cpp id 0 left out: duplicate: we already say line 0 on aggro
-- 34846 Wyneth (TheBarrens, 1 spawn): merge, 2 of our rows kept, 3 ref_cpp rows added: 9532 Lightning Bolt [e2/a0]; 6535 Lightning Cloud [e2/a0,e27/a3]. our death say + Verog summon rows stay; retail Lightning Bolt, flee, Lightning Cloud added
-- 3396 Hezrul Bloodmark (TheBarrens, 1 spawn): merge, 2 of our rows kept, 2 ref_cpp rows added: 6958 Blood Leech [e9/a0]. our Bloodguard summon rows stay; retail Blood Leech + out-of-combat say added
-- 37659 Horde Field Defender (SouthernBarrens, 1 spawn): merge, 6 of our rows kept, 2 ref_cpp rows added: 70316 Cleave [e31/a0]; 29426 Heroic Strike [e58/a0]. our waypoint scene rows stay; retail Cleave + Heroic Strike added
-- 37171 Escaped Stonetalon Prisoner (SouthernBarrens, 1 spawn): merge, 3 of our rows kept, 2 ref_cpp rows added: 8599 Enrage [e6/a79,e6/a138]. our summon/waypoint rows stay; retail Enrage at 30% + text added
-- 43761 Morbent Fel (Duskwood, 1 spawn): merge, 7 of our rows kept, 2 ref_cpp rows added: 3108 Touch of Death [e9/a0]; 3109 Presence of Death [e6/a12]. our Sacred Cleansing/weakened rows stay; Touch of Death + Presence of Death added; cpp id 2 left out: Unholy Shield 8909 is already applied through creature_template_addon.auras
-- 12940 Vorsha the Lasher (Ashenvale, 1 spawn): merge, 1 of our rows kept, 3 ref_cpp rows added: 12787 Thrash [e6/a42]; 6607 Lash [e6/a12,e64/a0,e64/a0]; 33126 Dropped Weapon [e6/a67]. our Quest Complete row stays; our plain Thrash 3391/Lash rows replaced by the sniffed Thrash 12787, Lash, Dropped Weapon; our ids 0,1 replaced
-- Reviewed and kept unchanged:
-- 3125 Clattering Scorpid (Durotar, 73 spawns): keep. cpp Poison 79687 is Sundering Cleave in 5.4.8 (name mismatch), cpp Envenom duplicates ours; our Envenom + emote is the Poison Extraction Totem hint
-- 1539 Scarlet Neophyte (TirisfalGlades, 12 spawns): keep. our script comes from upstream #484 (Tirisfal fixes); the cpp rows are placeholder quality (Frost Armor cast on the victim, Death Grip 64431)
-- 47091 Wounded Guard (GilneasCity, 4 spawns): keep. cpp has our two Spell Practice credit rows plus Wounded 46577, which has only a script effect and no SpellScript in our core
-- 34790 Southsea Mutineer (TheBarrens, 2 spawns): keep. scripted fight with Alicia Cuthbert below decks (our own scene rows); the cpp combat profile (flee, ranged Shoot) would disturb it
-- 22936 Auhula (Ashenvale, 1 spawn): keep. the only cpp cast, 14329, does not exist in 5.4.8; our hippogryph summon rows stay
-- 34295 Lord Magmathar (Ashenvale, 1 spawn): keep. cpp casts Lordly Immolate 65214 (periodic damage, implicit target src-area-entry) on himself while our alexkulya row removes that aura on hit; needs a retail check before touching

DELETE FROM `smart_scripts` WHERE `source_type`=0 AND `entryorguid` IN (3255,33277,33262,210,948,604,3,3256,501,48187,37090,45750,2165,33043,39596,39595,41251,33206,48269,33044,36845,34318,34707,3275,43923,7980,44164,11917,2011,11918,41611,48741,48742,11915,54373,35304,34415,33688,35660,36931,35880,35881,36638,34846,3396,37659,37171,43761,12940);
DELETE FROM `smart_scripts` WHERE `source_type`=9 AND `entryorguid` IN (6800,6801,6802,6803,6804);
UPDATE `creature_template` SET `AIName`='SmartAI' WHERE `entry` IN (35304);
INSERT INTO `smart_scripts` (`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`event_param5`,`action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,`target_type`,`target_param1`,`target_param2`,`target_param3`,`target_param4`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES
(3255,0,0,0,10,0,100,0,1,30,0,0,0,69,1,0,0,0,0,0,11,34831,30,0,0,0.0,0.0,0.0,0.0,'Sunscale - Follow Target'),
(3255,0,1,2,34,0,100,0,0,1,0,0,0,45,1,1,0,0,0,0,11,34831,2,0,0,0.0,0.0,0.0,0.0,'Sunscale - Set Data'),
(3255,0,2,3,61,0,100,0,0,0,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale'),
(3255,0,3,0,61,0,100,0,0,0,0,0,0,41,2000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale'),
(3255,0,4,0,0,0,100,0,4000,7000,18000,24000,0,11,82608,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale Screecher - In Combat - Cast \'Howling Screech\''),
(3255,0,5,0,4,0,100,1,0,0,0,0,0,11,44531,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale Screecher - On Aggro - Cast \'Dash\' (No Repeat)'),
(33277,0,0,0,11,0,100,0,0,0,0,0,0,117,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Warrior - On Respawn - Disable Evade'),
(33277,0,1,2,4,0,100,0,0,0,0,0,0,29,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Warrior - On Aggro - Follow Target'),
(33277,0,2,0,61,0,100,0,0,0,0,0,0,59,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Warrior - Linked To Id 0 - Set Run 1'),
(33277,0,3,0,6,0,100,0,0,0,0,0,0,33,32852,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Warrior - On Death - Quest Credit'),
(33277,0,4,0,9,0,100,0,0,5,25000,29000,0,11,3427,0,0,0,0,0,2,32,0,0,0,0.0,0.0,0.0,0.0,'Greymist Warrior - Within 0-5 Range - Cast \'Infected Wound\''),
(33277,0,5,0,0,0,100,0,5000,8000,17000,21000,0,11,74972,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Warrior - In Combat - Cast \'Greymist\''),
(33262,0,0,0,11,0,100,0,0,0,0,0,0,117,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Warrior - On Respawn - Disable Evade'),
(33262,0,1,2,4,0,100,0,0,0,0,0,0,29,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Tidehunter - On Aggro - Follow Target'),
(33262,0,2,0,61,0,100,0,0,0,0,0,0,59,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Tidehunter - Linked To Id 0 - Set Run 1'),
(33262,0,3,0,6,0,100,0,0,0,0,0,0,33,32852,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Tidehunter - On Death - Quest Credit'),
(33262,0,4,0,0,0,100,0,0,0,2300,3900,0,11,86249,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Tidehunter - In Combat - Cast \'Throw\''),
(33262,0,5,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Greymist Tidehunter - Between 0-15% Health - Flee For Assist (No Repeat)'),
(210,0,0,0,38,0,100,0,0,1,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Bone Chewer - On Data Set 0 1 - Die'),
(210,0,1,0,0,0,100,0,10000,10000,12000,17000,0,11,82625,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 10000 min and 10000 max ms (repeat 12000 min 17000 max ms) - Self: Cast spell Bone Toss (82625) on Victim // '),
(948,0,0,0,38,0,100,0,0,1,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Rotted One - On Data Set 0 1 - Die'),
(948,0,1,0,6,0,100,0,0,0,0,0,0,11,3428,3,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Rotted One - Linked To Id 0 - Cast Summon Flesh Eating Worms'),
(948,0,2,0,0,0,100,0,17000,17000,32000,33000,0,11,85234,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 17000 min and 17000 max ms (repeat 32000 min 33000 max ms) - Self: Cast spell Fetid Breath (85234) on Victim // '),
(604,0,0,0,38,0,100,0,0,1,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Plague Spreader - On Data Set 0 1 - Die'),
(604,0,1,0,6,0,100,0,0,0,0,0,0,11,85236,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Plague Spreader - Linked To Id 0 - Cast Corpse Rot'),
(604,0,2,0,0,0,100,0,14000,15000,32000,33000,0,11,3436,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 14000 min and 15000 max ms (repeat 32000 min 33000 max ms) - Self: Cast spell Wandering Plague (3436) on Victim // '),
(3,0,0,0,38,0,100,0,0,1,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Flesh Eater - On Data Set 0 1 - Die'),
(3,0,1,0,2,0,100,0,0,50,31000,31000,0,11,83884,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'When health between 0% and 50% (check every 31000 - 31000 ms) - Self: Cast spell Cannibalize (83884) on Self // '),
(3256,0,0,0,10,0,100,0,1,30,0,0,0,69,1,0,0,0,0,0,11,34831,30,0,0,0.0,0.0,0.0,0.0,'Sunscale - Follow Target'),
(3256,0,1,2,34,0,100,0,0,1,0,0,0,45,1,1,0,0,0,0,11,34831,2,0,0,0.0,0.0,0.0,0.0,'Sunscale - Set Data'),
(3256,0,2,3,61,0,100,0,0,0,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale'),
(3256,0,3,0,61,0,100,0,0,0,0,0,0,41,2000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale'),
(3256,0,4,0,0,0,60,0,15000,15000,20000,20000,0,11,12787,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale Scytheclaw - In Combat - Cast \'Thrash\' (No Repeat)'),
(501,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - Between 0-15% Health - Flee For Assist (No Repeat)'),
(501,0,1,0,0,0,50,0,1000,1000,120000,120000,0,11,80472,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - In Combat - Cast \'Elixir of Agility\''),
(501,0,2,0,0,0,50,0,1000,1000,120000,120000,0,11,80471,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - In Combat - Cast \'Potion of Strength\''),
(501,0,3,0,0,0,50,0,1000,1000,120000,120000,0,11,80473,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - In Combat - Cast \'Tonic of Health\''),
(501,0,4,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - On Aggro - Say Line 0 (No Repeat)'),
(48187,0,0,1,11,0,100,0,0,0,0,0,0,2,1999,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hill Fawn - On Respawn - Set Faction 1999'),
(48187,0,1,0,61,0,100,0,0,0,0,0,0,22,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hill Fawn - Linked To Id 0 - Set Phase 0 '),
(48187,0,2,3,8,0,100,0,90679,0,20000,20000,0,22,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hill Fawn - On SpellHit Duskingdawn\'s Blessing - Set Phase 1'),
(48187,0,3,4,61,0,100,0,0,0,0,0,0,33,48684,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Hill Fawn - Linked To Id 2 - Quest Credit'),
(48187,0,4,5,61,0,100,0,0,0,0,0,0,11,90685,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hill Fawn - Linked To Id 3 - Cast Duskingdawn\'s Blessing'),
(48187,0,5,6,61,0,100,0,0,0,0,0,0,2,14,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hill Fawn - Linked To Id 4 - Set Faction 14'),
(48187,0,6,7,61,0,100,0,0,0,0,0,0,8,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hill Fawn - Linked To Id 5 - Set React State Defensive'),
(48187,0,7,0,61,0,100,0,0,0,0,0,0,41,20000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hill Fawn - Linked To Id 6 - Despawn after 20 sec'),
(48187,0,8,0,0,0,100,0,5000,8000,12000,15000,0,11,32019,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Gore'),
(37090,0,0,0,8,0,100,0,70458,0,0,0,0,87,3709000,3709001,3709002,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deviate Terrortooth - On SpellHit Soothing Seeds - Run Random Script'),
(37090,0,1,0,4,0,100,1,0,0,0,0,0,11,6268,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deviate Terrortooth - On Aggro - Cast \'Rushing Charge\' (No Repeat)'),
(37090,0,2,0,0,0,100,0,4000,5000,15000,21000,0,11,80608,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deviate Terrortooth - In Combat - Cast \'Summon Pebble\''),
(45750,0,0,0,11,0,100,0,0,0,0,0,0,42,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - On Respawn - Set Invincibility Hp 1'),
(45750,0,1,0,4,0,100,0,0,0,0,0,0,64,1,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - On Aggro - Store Target List'),
(45750,0,2,3,2,0,100,1,0,1,0,0,0,33,45750,0,0,0,0,0,12,1,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - Between 0-1% Health - Quest Credit'),
(45750,0,3,4,61,0,100,0,0,0,0,0,0,36,45751,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - Linked To Id 2 - Update Template On Worgen Druid'),
(45750,0,4,5,61,0,100,0,0,0,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - Linked To Id 3 - Die'),
(45750,0,5,0,61,0,100,0,0,0,0,0,0,41,60000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - Linked To Id 4 - Despawn after 60 sec'),
(45750,0,6,0,9,0,100,0,8,25,15000,18000,0,11,87187,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - Within 8-25 Range - Cast \'Feral Charge\''),
(45750,0,7,0,0,0,100,0,6000,8000,25000,27500,0,11,87185,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - In Combat - Cast \'Demoralizing Roar\''),
(45750,0,8,0,0,0,100,0,2000,4500,12000,15000,0,11,31279,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Inconspicuous Bear - In Combat - Cast \'Swipe\''),
(2165,0,0,1,8,0,100,0,65188,0,10000,10000,0,64,1,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Grizzled Thistle Bear - On SpellHit Darkshore Protection - Store Target List'),
(2165,0,1,2,61,0,100,0,0,0,0,0,0,49,0,0,0,0,0,0,12,1,0,0,0,0.0,0.0,0.0,0.0,'Grizzled Thistle Bear - Linked To Id 0 - Attack Start'),
(2165,0,2,0,61,0,100,0,0,0,0,0,0,80,216500,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Grizzled Thistle Bear - Linked To Id 1 - Run Script'),
(2165,0,3,0,0,0,100,0,5000,5000,7000,10000,0,11,3242,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Grizzled Thistle Bear - In Combat - Cast \'Ravage\''),
(2165,0,4,0,4,0,100,1,0,0,0,0,0,11,75002,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Grizzled Thistle Bear - On Aggro - Cast \'Leaping Rush\' (No Repeat)'),
(33043,0,0,1,8,0,100,0,62092,0,0,0,0,64,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - On SpellHit Blessed Herb Bundle - Store Target List'),
(33043,0,1,2,61,0,100,0,0,0,0,0,0,42,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - Linked To Id 0 - Set Invincibility Hp 1'),
(33043,0,2,3,61,0,100,0,0,0,0,0,0,22,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - Linked To Id 1 - Set Event Phase 1'),
(33043,0,3,0,61,0,100,0,0,0,0,0,0,100,1,0,0,0,0,0,19,33000,25,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - Linked To Id 2 - Send Target To Target'),
(33043,0,4,5,38,0,100,0,0,1,0,0,0,2,35,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - On Data Set 0 1 - Set Faction 35'),
(33043,0,5,6,61,0,100,0,0,0,0,0,0,203,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - Linked To Id 4 - Combat Stop'),
(33043,0,6,0,61,0,100,0,0,0,0,0,0,67,33043,3000,3000,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - Linked To Id 5 - Create Timed Event'),
(33043,0,7,8,59,0,100,0,33043,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - On Timed Event Triggered - Say Line 0'),
(33043,0,8,0,61,0,100,0,0,0,0,0,0,41,5000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - Linked To Id 7 - Despawn after 5 sec'),
(33043,0,9,0,0,0,100,0,2000,4500,30000,35000,0,11,75014,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Maddened Blackwood - In Combat - Cast \'Howl of Madness\''),
(39596,0,0,1,1,0,100,0,1500,3500,2500,4000,0,66,0,0,0,0,0,0,19,39595,8,0,0,0.0,0.0,0.0,0.0,'Teeming Waterguard - Out of Combat - Face the nearest Furious Earthguard'),
(39596,0,1,0,61,0,100,0,0,0,0,0,0,5,35,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teeming Waterguard - Link - Strike at it (unarmed attack animation)'),
(39596,0,2,0,0,0,100,0,4000,6000,24000,26000,0,11,78542,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Teeming Waterguard - In Combat - Cast \'Splash\''),
(39595,0,0,1,1,0,100,0,1000,3000,2500,4000,0,66,0,0,0,0,0,0,19,39596,8,0,0,0.0,0.0,0.0,0.0,'Furious Earthguard - Out of Combat - Face the nearest Teeming Waterguard'),
(39595,0,1,0,61,0,100,0,0,0,0,0,0,5,35,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Furious Earthguard - Link - Strike at it (unarmed attack animation)'),
(39595,0,2,0,0,0,100,0,5000,6000,16000,18000,0,11,80117,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Furious Earthguard - In Combat - Cast \'Earth Spike\''),
(41251,0,0,0,11,0,100,0,0,0,0,0,0,17,173,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Frostmane Builder - on spawn - set emote state (173)'),
(41251,0,1,0,8,0,100,1,93773,0,0,0,0,80,4125100,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Frostmane Builder - on spell hit (93773) - run actionlist'),
(41251,0,2,0,0,0,100,0,0,0,2300,3900,0,11,38557,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Frostmane Builder - In Combat - Cast \'Throw\''),
(41251,0,3,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Frostmane Builder - Between 0-15% Health - Flee For Assist (No Repeat)'),
(41251,0,4,0,9,0,100,0,0,5,18000,19000,0,11,58461,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Frostmane Builder - Within 0-5 Range - Cast \'Sunder Armor\''),
(33206,0,0,0,8,0,100,0,64306,0,0,0,0,33,34010,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Darkscale Scout - On Spellhit 64306 - Quest Credit \'Twice Removed\''),
(33206,0,1,0,9,0,100,0,0,5,21000,22000,0,11,31553,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Darkscale Scout - Within 0-5 Range - Cast \'Hamstring\''),
(48269,0,0,0,8,0,100,0,89821,0,0,0,0,64,1,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Ranger - On SpellHit Helcular\'s Rod - Store Target List'),
(48269,0,1,2,8,0,100,0,89824,0,60000,60000,0,33,48269,0,0,0,0,0,12,1,0,0,0,0.0,0.0,0.0,0.0,'Dark Ranger - On SpellHit Helcular\'s Ire - Quest Credit'),
(48269,0,2,0,61,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Dark Ranger - Linked To Id 1 - Say Line Random'),
(48269,0,3,0,0,0,100,0,0,0,2300,3900,0,11,74613,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Shoot'),
(48269,0,4,0,11,0,100,1,0,0,0,0,0,11,89702,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Camouflage on Spawn'),
(48269,0,5,0,7,0,100,1,0,0,0,0,0,11,89702,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Camouflage on Evade'),
(33044,0,0,1,8,0,100,0,62092,0,0,0,0,64,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - On SpellHit Blessed Herb Bundle - Store Target List'),
(33044,0,1,2,61,0,100,0,0,0,0,0,0,42,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - Linked To Id 0 - Set Invincibility Hp 1'),
(33044,0,2,3,61,0,100,0,0,0,0,0,0,22,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - Linked To Id 1 - Set Event Phase 1'),
(33044,0,3,0,61,0,100,0,0,0,0,0,0,100,1,0,0,0,0,0,19,33000,25,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - Linked To Id 2 - Send Target To Target'),
(33044,0,4,5,38,0,100,0,0,1,0,0,0,2,35,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - On Data Set 0 1 - Set Faction 35'),
(33044,0,5,6,61,0,100,0,0,0,0,0,0,203,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - Linked To Id 4 - Combat Stop'),
(33044,0,6,0,61,0,100,0,0,0,0,0,0,67,33044,3000,3000,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - Linked To Id 5 - Create Timed Event'),
(33044,0,7,8,59,0,100,0,33044,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - On Timed Event Triggered - Say Line 0'),
(33044,0,8,0,61,0,100,0,0,0,0,0,0,41,5000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - Linked To Id 7 - Despawn after 5 sec'),
(33044,0,9,0,0,0,100,0,0,0,3400,4700,0,11,9739,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - In Combat - Cast \'Wrath\''),
(33044,0,10,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - Between 0-15% Health - Flee For Assist (No Repeat)'),
(33044,0,11,0,0,0,100,0,4000,5800,12000,14700,0,11,15039,2,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Corrupted Blackwood - In Combat - Cast \'Flame Shock\''),
(36845,0,0,1,8,0,100,0,69453,0,0,0,0,64,1,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Agitated Earth Spirit - On SpellHit Soothe Earth Spirit - Store Target List'),
(36845,0,1,0,61,0,100,0,0,0,0,0,0,87,3684501,3684502,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Agitated Earth Spirit - Linked To Id 0 - Run Random Script'),
(36845,0,2,0,0,0,100,0,4500,5500,18500,21500,0,11,81305,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Agitated Earth Spirit - In Combat - Cast \'Rock Barrage\''),
(34318,0,0,1,8,0,100,0,65188,0,10000,10000,0,64,1,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Whitetail Stag - On SpellHit Darkshore Protection - Store Target List'),
(34318,0,1,2,61,0,100,0,0,0,0,0,0,49,0,0,0,0,0,0,12,1,0,0,0,0.0,0.0,0.0,0.0,'Whitetail Stag - Linked To Id 0 - Attack Start'),
(34318,0,2,0,61,0,100,0,0,0,0,0,0,80,3431800,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Whitetail Stag - Linked To Id 1 - Run Script'),
(34318,0,3,0,4,0,100,1,0,0,0,0,0,11,22120,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Whitetail Stag - On Aggro - Cast \'Charge\' (No Repeat)'),
(34318,0,4,0,0,0,100,0,2000,4500,12000,15000,0,11,31274,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Whitetail Stag - In Combat - Cast \'Knockdown\''),
(34707,0,0,0,38,0,100,0,1,1,0,0,0,49,0,0,0,0,0,0,21,20,0,0,0,0.0,0.0,0.0,0.0,'Theramore Deck Hand - On Data Set 1 1 (Foote knocked out) - Attack the nearest player'),
(34707,0,1,0,0,0,100,0,2000,4500,12000,16000,0,11,75361,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Theramore Deck Hand - In Combat - Cast \'Swashbuckling Slice\''),
(3275,0,0,0,4,0,100,1,0,0,0,0,0,11,6268,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Kolkar Marauder - On Aggro - Cast \'Rushing Charge\' (No Repeat)'),
(3275,0,1,0,0,0,100,0,2000,3000,12000,12500,0,11,11976,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Kolkar Marauder - In Combat - Cast \'Strike\''),
(3275,0,2,0,0,0,100,0,5000,7000,25000,29000,0,11,8014,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Kolkar Marauder - In Combat - Cast \'Tetanus\''),
(43923,0,0,1,8,0,100,0,82198,0,0,0,0,33,43930,0,0,0,0,0,21,10,0,0,0,0.0,0.0,0.0,0.0,'Forlorn Spirit - On SpellHit Soothing Incense Cloud - Quest Credit'),
(43923,0,1,0,61,0,100,0,0,0,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Forlorn Spirit - Linked To Id 0 - Die'),
(43923,0,2,0,0,0,100,0,8000,9000,12000,15000,0,11,81193,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Update (In Combat) 8000 min and 9000 max ms (repeat 12000 min 15000 max ms) - Self: Cast spell Unrelenting Anguish (81193) on Victim // '),
(7980,0,0,0,0,0,100,0,5000,7000,7000,10000,0,11,14516,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - In Combat - Cast \'Strike\''),
(7980,0,1,0,9,0,100,0,0,5,12000,16000,0,11,9080,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - Within 0-5 Range - Cast \'Hamstring\''),
(7980,0,2,0,25,0,100,0,0,0,0,0,0,11,18950,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - On Reset - Cast \'Invisibility and Stealth Detection\''),
(7980,0,3,0,22,0,100,0,101,5000,5000,0,0,80,6800,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - On Received Emote \'Wave\' - Run Script'),
(7980,0,4,0,22,0,100,0,78,5000,5000,0,0,80,6801,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - On Received Emote \'Salute\' - Run Script'),
(7980,0,5,0,22,0,100,0,58,5000,5000,0,0,80,6802,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - On Received Emote \'Kiss\' - Run Script'),
(7980,0,6,0,22,0,100,0,84,5000,5000,0,0,80,6803,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - On Received Emote \'Shy\' - Run Script'),
(7980,0,7,0,22,0,100,0,77,5000,5000,0,0,80,6804,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - On Received Emote \'Rude\' - Run Script'),
(7980,0,8,0,22,0,100,0,22,5000,5000,0,0,80,6804,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - On Received Emote \'Chicken\' - Run Script'),
(7980,0,9,0,22,0,100,0,17,5000,5000,0,0,80,6802,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Deathguard Elite - On Received Emote \'Bow\' - Run Script'),
(6802,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6802,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6802,9,2,0,0,0,100,0,2000,2000,0,0,0,5,2,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Bow\''),
(6802,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6802,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(6804,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6804,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6804,9,2,0,0,0,100,0,2000,2000,0,0,0,5,25,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Point\''),
(6804,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6804,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(6803,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6803,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6803,9,2,0,0,0,100,0,2000,2000,0,0,0,5,23,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Flex\''),
(6803,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6803,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(6801,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6801,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6801,9,2,0,0,0,100,0,2000,2000,0,0,0,5,66,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Salute\''),
(6801,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6801,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(6800,9,0,0,0,0,100,0,0,0,0,0,0,103,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted On'),
(6800,9,1,0,0,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6800,9,2,0,0,0,100,0,2000,2000,0,0,0,5,3,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Play Emote \'Wave\''),
(6800,9,3,0,0,0,100,0,4000,4000,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Orientation'),
(6800,9,4,0,0,0,100,0,0,0,0,0,0,103,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Stormwind City Guard - On Script - Set Rooted Off'),
(44164,0,0,0,10,0,100,0,1,30,0,0,0,69,1,0,0,0,0,0,11,34831,30,0,0,0.0,0.0,0.0,0.0,'Sunscale - Follow Target'),
(44164,0,1,2,34,0,100,0,0,1,0,0,0,45,1,1,0,0,0,0,11,34831,2,0,0,0.0,0.0,0.0,0.0,'Sunscale - Set Data'),
(44164,0,2,3,61,0,100,0,0,0,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale'),
(44164,0,3,0,61,0,100,0,0,0,0,0,0,41,2000,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale'),
(44164,0,4,0,0,0,100,0,4000,7000,18000,24000,0,11,82608,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Sunscale Ravager - In Combat - Cast \'Howling Screech\''),
(11917,0,0,0,8,0,100,0,78315,0,5000,5000,0,87,1191701,1191702,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Boulderslide Geomancer - On SpellHit Whip \'Em - Run Random Script'),
(11917,0,1,0,0,0,100,0,0,0,3400,4700,0,11,20793,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Boulderslide Geomancer - In Combat - Cast \'Fireball\''),
(11917,0,2,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Boulderslide Geomancer - Between 0-15% Health - Flee For Assist (No Repeat)'),
(11917,0,3,0,0,0,100,0,5000,9000,25000,27000,0,11,81309,2,0,0,0,0,4,0,0,0,0,0.0,0.0,0.0,0.0,'Boulderslide Geomancer - In Combat - Cast \'Cave-in\''),
(2011,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Gnarlpine Augur - Between 0-15% Health - Flee For Assist (No Repeat)'),
(2011,0,1,0,0,0,100,0,2000,4000,8000,11000,0,11,17227,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Gnarlpine Augur - IC - Cast Curse of Weakness'),
(2011,0,2,0,2,0,100,1,0,20,0,0,0,11,5628,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Gnarlpine Augur - IN health pct 20% - Cast Gnarlpine Vengeance'),
(11918,0,0,0,8,0,100,0,78315,0,5000,5000,0,87,1191801,1191802,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Boulderslide Stonepounder - On SpellHit Whip \'Em - Run Random Script'),
(11918,0,1,0,9,0,100,0,0,20,12000,19000,0,11,81361,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Boulderslide Stonepounder - Within 0-20 Range - Cast \'Ground Spike\''),
(41611,0,0,0,21,0,100,0,0,0,0,0,0,41,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Amberstill Mountaineer'),
(41611,0,1,0,0,0,100,0,5000,5000,240000,240000,0,11,8258,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Amberstill Mountaineer - In Combat - Cast \'Devotion Aura\''),
(41611,0,2,0,0,0,100,0,8000,9000,14000,18000,0,11,81460,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Amberstill Mountaineer - In Combat - Cast \'Fierce Strike\''),
(48741,0,0,0,8,0,100,0,90976,0,0,0,0,33,48752,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'SI:7 Operative - On Spellhit - Killcredit'),
(48741,0,1,0,9,0,100,0,0,10,15000,25000,0,11,79851,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Fan of Knives on Close'),
(48741,0,2,0,0,0,100,0,5000,8000,12000,15000,0,11,60842,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Expose Armor'),
(48741,0,3,0,2,0,100,0,0,55,22000,25000,0,11,79853,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Evasion at 55% HP'),
(48742,0,0,0,8,0,100,0,90976,0,0,0,0,33,48752,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'SI:7 Assassin - On Spellhit - Killcredit'),
(48742,0,1,0,4,0,100,1,0,0,0,0,0,11,66060,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Sprint on Aggro'),
(48742,0,2,0,0,0,100,0,5000,8000,17000,20000,0,11,3583,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Deadly Poison'),
(48742,0,3,0,0,0,100,0,10000,10000,12000,14000,0,11,60850,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Cast Mutilate'),
(11915,0,0,0,8,0,100,0,78315,0,5000,5000,0,87,1191501,1191502,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Boulderslide Rock Keeper - On SpellHit Whip \'Em - Run Random Script'),
(11915,0,1,0,9,0,100,0,0,30,13600,14500,0,11,81305,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Boulderslide Rock Keeper - Within 0-30 Range - Cast \'Rock Barrage\''),
(54373,0,0,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - Between 0-15% Health - Flee For Assist (No Repeat)'),
(54373,0,1,0,0,0,50,0,1000,1000,120000,120000,0,11,80472,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - In Combat - Cast \'Elixir of Agility\''),
(54373,0,2,0,0,0,50,0,1000,1000,120000,120000,0,11,80471,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - In Combat - Cast \'Potion of Strength\''),
(54373,0,3,0,0,0,50,0,1000,1000,120000,120000,0,11,80473,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - In Combat - Cast \'Tonic of Health\''),
(54373,0,4,0,4,0,20,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Riverpaw Herbalist - On Aggro - Say Line 0 (No Repeat)'),
(35304,0,0,0,1,0,100,1,500,1000,0,0,0,11,76136,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Brute Enforcer - Out of Combat - Cast \'Acidic Sweat\' (No Repeat)'),
(34415,0,0,0,6,0,100,0,0,0,0,0,0,45,0,3,0,0,0,0,10,245970,24042,0,0,0.0,0.0,0.0,0.0,'Darkscale Priestess - On Death - Set Data 0 3'),
(34415,0,1,0,0,0,100,0,0,0,3400,4700,0,11,9672,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Darkscale Priestess - In Combat - Cast \'Frostbolt\''),
(34415,0,2,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Darkscale Priestess - Between 0-15% Health - Flee For Assist (No Repeat)'),
(34415,0,3,0,9,0,100,0,0,8,11000,16000,0,11,75062,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Darkscale Priestess - Within 0-8 Range - Cast \'Frost Nova\''),
(33688,0,0,1,38,0,100,1,1,0,0,0,0,45,3,0,0,0,0,0,9,33965,0,5,0,0.0,0.0,0.0,0.0,'Raging Ancient'),
(33688,0,1,0,61,0,100,0,0,0,0,0,0,37,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Raging Ancient'),
(33688,0,2,0,9,0,100,0,0,30,13600,14500,0,11,11922,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Raging Ancient - Within 0-30 Range - Cast \'Entangling Roots\''),
(33688,0,3,0,0,0,100,0,5000,8000,17000,25000,0,11,45,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Raging Ancient - In Combat - Cast \'War Stomp\''),
(35660,0,0,0,54,0,100,0,0,0,0,0,0,80,3566000,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Rampaging Worgen - On Just Summoned - Start Script'),
(35660,0,1,2,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'When health between 0% and 30% (check every 0 - 0 ms) - Self: Cast spell 8599 on Self // Rampaging Worgen - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(35660,0,2,0,61,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,' Linked - Self: Talk 0 // Rampaging Worgen - Between 0-30% Health - Say Line 0 (No Repeat)'),
(36931,0,0,1,25,0,100,0,0,0,0,0,0,19,768,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - On Reset - Remove UnitFlag 768'),
(36931,0,1,24,61,0,100,0,0,0,0,0,0,17,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 0 - Set Emote State 0'),
(36931,0,2,3,4,0,100,0,0,0,0,0,0,64,1,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - On Aggro - Store Target List'),
(36931,0,3,0,61,0,100,1,0,0,0,0,0,42,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 2 - Set Invincibility Hp 1'),
(36931,0,4,5,2,0,100,1,0,80,0,0,0,203,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Between 0-20% Health - Combat Stop'),
(36931,0,5,6,61,0,100,0,0,0,0,0,0,102,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 4 - Set Health Regen 0'),
(36931,0,6,7,61,0,100,0,0,0,0,0,0,33,36931,0,0,0,0,0,12,1,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 5 - Quest Credit'),
(36931,0,7,8,61,0,100,0,0,0,0,0,0,18,768,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 6 - Set UnitFlag 768'),
(36931,0,8,21,61,0,100,0,0,0,0,0,0,1,0,3000,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 7 - Say Line 0'),
(36931,0,9,0,61,0,100,0,0,0,0,0,0,69,0,0,0,0,0,0,8,0,0,0,0,-600.932,189.823,53.1532,0.0,'Orno Grimtotem - Move To Pos'),
(36931,0,10,11,52,0,100,0,0,36931,0,0,0,12,37058,8,0,0,0,0,8,0,0,0,0,-626.309,207.384,53.1094,0.0,'Orno Grimtotem - On Text Over 0 - Summon Creature Baine Bloodhoof'),
(36931,0,11,12,61,0,100,0,0,0,0,0,0,66,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 10 - Set Orientation'),
(36931,0,12,0,61,0,100,0,0,0,0,0,0,17,375,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 11 - Set Emote State 375'),
(36931,0,13,14,38,0,100,0,0,1,0,0,0,66,0,0,0,0,0,0,11,37058,60,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - On Data Set 0 1 - Set Orientation'),
(36931,0,14,15,61,0,100,0,0,0,0,0,0,1,1,5000,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 13 - Say Line 1'),
(36931,0,15,16,61,0,100,0,0,0,0,0,0,12,37062,6,10000,0,0,0,8,0,0,0,0,-602.066,197.131,53.134,0.0,'Orno Grimtotem - Linked To Id 14 - Summon Creature Grimtotem Ambushe'),
(36931,0,16,0,61,0,100,0,0,0,0,0,0,12,37062,6,10000,0,0,0,8,0,0,0,0,-606.793,196.004,53.134,0.0,'Orno Grimtotem - Linked To Id 15 - Summon Creature Grimtotem Ambushe'),
(36931,0,17,0,52,0,100,0,1,36931,0,0,0,1,2,3000,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - On Text Over 1 - Say Line 2'),
(36931,0,18,0,52,0,100,0,2,36931,0,0,0,45,0,1,0,0,0,0,11,37058,60,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - On Text Over 2 - Set Data 0 1'),
(36931,0,19,0,38,0,100,0,0,2,0,0,0,80,3693100,2,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - On Data Set 0 2 - Run Script'),
(36931,0,20,0,38,0,100,0,0,3,0,0,0,41,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - On Data Set 0 3 - Despawn'),
(36931,0,21,22,61,0,100,0,0,0,0,0,0,2,35,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 8 - Set Faction Friendly'),
(36931,0,22,0,61,0,100,0,0,0,0,0,0,8,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 21 - Set React State Passive'),
(36931,0,23,0,11,0,100,0,0,0,0,0,0,2,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - On Respawn - Restore Faction'),
(36931,0,24,0,61,0,100,0,0,0,0,0,0,42,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - Linked To Id 1 (On Reset) - Set Invincibility Hp 1'),
(36931,0,25,0,0,0,100,0,2000,4500,19000,25000,0,11,77558,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Orno Grimtotem - In Combat - Cast \'Bloody Strike\''),
(35880,0,0,1,11,0,100,0,0,0,0,0,0,45,0,1,0,0,0,0,19,35892,30,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - On Respawn - Set Data 0 1'),
(35880,0,1,0,61,0,100,0,0,0,0,0,0,11,46933,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - Linked To Id 0 - Cast Cosmetic - Arcane Force Shield (Blue)'),
(35880,0,2,3,38,0,100,0,0,1,0,0,0,28,46933,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - On Data Set 0 1 - Remove Aura Cast Cosmetic - Arcane Force Shield (Blue)'),
(35880,0,3,0,61,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - Linked To Id 2 - Say Line 0'),
(35880,0,4,0,0,0,100,0,0,0,2300,3900,0,11,6660,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - In Combat - Cast \'Shoot\''),
(35880,0,5,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - Between 0-15% Health - Flee For Assist (No Repeat)'),
(35880,0,6,0,9,0,100,0,5,30,12000,18000,0,11,15495,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - Within 5-30 Range - Cast \'Explosive Shot\''),
(35880,0,7,0,0,0,100,0,4000,7000,15000,22000,0,11,20299,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - In Combat - Cast \'Forked Lightning\''),
(35880,0,8,0,9,0,100,0,5,30,9000,26000,0,11,12551,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - Within 5-30 Range - Cast \'Frost Shot\''),
(35880,0,9,0,1,0,100,0,500,1000,600000,600000,0,11,15507,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - Out of Combat - Cast \'Lightning Shield\''),
(35880,0,10,0,16,0,100,0,15507,1,15000,30000,0,11,15507,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Silisthra - On Friendly Unit Missing Buff \'Lightning Shield\' - Cast \'Lightning Shield\''),
(35881,0,0,1,11,0,100,0,0,0,0,0,0,45,0,1,0,0,0,0,19,35968,30,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - On Respawn - Set Data 0 1'),
(35881,0,1,0,61,0,100,0,0,0,0,0,0,11,68268,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - Linked To Id 0 - Cast Cosmetic - Arcane Force Shield (Blue)'),
(35881,0,2,3,38,0,100,0,0,1,0,0,0,28,68268,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - On Data Set 0 1 - Remove Aura Cast Cosmetic - Arcane Force Shield (Blue)'),
(35881,0,3,0,61,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - Linked To Id 2 - Say Line 0'),
(35881,0,4,0,0,0,100,0,0,0,3400,4700,0,11,9672,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - In Combat - Cast \'Frostbolt\''),
(35881,0,5,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - Between 0-15% Health - Flee For Assist (No Repeat)'),
(35881,0,6,0,9,0,100,0,0,8,13600,14500,0,11,11831,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - Within 0-8 Range - Cast \'Frost Nova\''),
(35881,0,7,0,9,0,100,0,0,25,15000,18000,0,11,21067,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - Within 0-25 Range - Cast \'Poison Bolt\''),
(35881,0,8,0,0,0,100,0,4000,5000,14500,15800,0,11,38663,1,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - In Combat - Cast \'Slow\''),
(35881,0,9,0,9,0,100,0,0,15,25000,28000,0,11,81039,1,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Lady Vesthra - Within 0-15 Range - Cast \'Toxic Nova\''),
(36638,0,0,0,4,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Lord Katrana - On Aggro - Say Line 0'),
(36638,0,1,0,6,0,100,0,0,0,0,0,0,45,0,1,0,0,0,0,19,36649,20,0,0,0.0,0.0,0.0,0.0,'Twilight Lord Katrana - On Death - Set Data 0 1'),
(36638,0,2,0,2,0,100,0,0,60,28000,32000,0,11,69135,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Twilight Lord Katrana - Between 0-60% Health - Cast \'Twilight Barrier\''),
(34846,0,0,1,6,0,100,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Wyneth - On Death - Say Line 0'),
(34846,0,1,0,61,0,100,0,0,0,0,0,0,12,3395,6,30000,0,0,0,8,0,0,0,0,-1158.47,-2809.09,92.4256,2.84086,'Wyneth - Linked To Id 0 - Summon Creature Verog the Dervish'),
(34846,0,2,0,0,0,100,0,0,0,3400,4700,0,11,9532,64,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Wyneth - In Combat - Cast \'Lightning Bolt\''),
(34846,0,3,0,2,0,100,1,0,15,0,0,0,25,1,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,'Wyneth - Between 0-15% Health - Flee For Assist (No Repeat)'),
(34846,0,4,0,0,0,100,0,5000,7000,18000,26000,0,11,6535,1,0,0,0,0,4,0,0,0,0,0.0,0.0,0.0,0.0,'Wyneth - In Combat - Cast \'Lightning Cloud\''),
(3396,0,0,1,11,0,100,0,0,0,0,0,0,12,44170,5,30000,2,0,0,8,0,0,0,0,-1062.04,-2278.94,90.0085,0.0,'Hezrul Bloodmark - On Respawn - Summon Creature Hezrul\'s Bloodguard'),
(3396,0,1,0,61,0,100,0,0,0,0,0,0,12,44170,5,30000,2,0,0,8,0,0,0,0,-1060.2,-2281.08,90.6286,0.0,'Hezrul Bloodmark - Linked To Id 0 - Summon Creature Hezrul\'s Bloodguard'),
(3396,0,2,0,0,0,100,0,8000,9000,21000,22000,0,11,6958,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Hezrul Bloodmark - In Combat - Cast \'Blood Leech\''),
(3396,0,3,0,1,0,100,0,5000,10000,25000,35000,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Hezrul Bloodmark - Out of Combat - Say Line 0'),
(37659,0,0,0,11,0,100,0,0,0,0,0,0,42,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Horde Field Defender - On Respawn - Set Invincibility Hp 1'),
(37659,0,1,0,38,0,100,0,0,1,0,0,0,53,0,37659,0,24637,0,2,1,0,0,0,0,0.0,0.0,0.0,0.0,'Horde Field Defender - On Data Set 0 1 - Waypoint Start'),
(37659,0,2,0,58,0,100,0,0,0,0,0,0,17,375,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Horde Field Defender - On Waypoint Ended - Set Emote State 375'),
(37659,0,3,4,38,0,100,0,0,2,0,0,0,59,1,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Horde Field Defender - On Data Set 0 2 - Set Run 1'),
(37659,0,4,0,61,0,100,0,0,0,0,0,0,49,0,0,0,0,0,0,19,38018,20,0,0,0.0,0.0,0.0,0.0,'Horde Field Defender - Linked To Id 2 - Attack Start'),
(37659,0,5,0,7,0,100,0,0,0,0,0,0,17,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Horde Field Defender - On Evade - Set Emote State 0'),
(37659,0,6,0,9,0,100,0,0,5,12000,13000,0,11,70316,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Horde Field Defender - Within 0-5 Range - Cast \'Cleave\''),
(37659,0,7,0,0,0,100,0,4000,6000,16000,21000,0,11,29426,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Horde Field Defender - In Combat - Cast \'Heroic Strike\''),
(37171,0,0,0,54,0,100,0,0,0,0,0,0,67,37171,1000,1000,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Escaped Stonetalon Prisoner - On Summoned - Create Timed Event'),
(37171,0,1,0,59,0,100,0,37171,0,0,0,0,53,1,37171,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Escaped Stonetalon Prisoner - On Timed Event Triggered - Waypoint Start'),
(37171,0,2,0,58,0,100,0,1,37171,0,0,0,41,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Escaped Stonetalon Prisoner - On Waypoint Ended - Despawn'),
(37171,0,3,4,2,0,100,1,0,30,0,0,0,11,8599,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Escaped Stonetalon Prisoner - Between 0-30% Health - Cast \'Enrage\' (No Repeat)'),
(37171,0,4,0,61,0,100,1,0,30,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Escaped Stonetalon Prisoner - Between 0-30% Health - Say Line 0 (No Repeat)'),
(43761,0,0,1,8,0,100,0,82130,0,0,0,0,28,8909,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - On SpellHit Sacred Cleansing - Remove Aura Unholy Shield'),
(43761,0,1,2,61,0,100,0,0,0,0,0,0,36,43762,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - Linked To Id 0 - Update Template On Weakened Morbent Fel'),
(43761,0,2,0,61,0,100,0,0,0,0,0,0,49,0,0,0,0,0,0,7,0,0,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - Linked To Id 1 - Attack Start'),
(43761,0,3,4,6,0,100,0,0,0,0,0,0,45,0,1,0,0,0,0,11,3,100,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - On Death - Set Data 0 1'),
(43761,0,4,5,61,0,100,0,0,0,0,0,0,45,0,1,0,0,0,0,11,604,100,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - Linked To Id 3 - Set Data 0 1'),
(43761,0,5,6,61,0,100,0,0,0,0,0,0,45,0,1,0,0,0,0,11,210,100,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - Linked To Id 4 - Set Data 0 1'),
(43761,0,6,0,61,0,100,0,0,0,0,0,0,45,0,1,0,0,0,0,11,948,100,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - Linked To Id 5 - Set Data 0 1'),
(43761,0,7,0,2,0,100,0,0,55,22000,26000,0,11,3108,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - Between 0-55% Health - Cast \'Touch of Death\''),
(43761,0,8,0,0,0,100,0,6000,9000,18000,20000,0,11,3109,0,0,0,0,0,5,0,0,0,0,0.0,0.0,0.0,0.0,'Morbent Fel - In Combat - Cast \'Presence of Death\''),
(12940,0,2,0,6,0,100,0,0,0,0,0,0,15,6641,0,0,0,0,0,17,0,50,0,0,0.0,0.0,0.0,0.0,'Vorsha the Lasher - Quest Complete'),
(12940,0,3,0,0,0,100,0,2000,4500,9000,12000,0,11,12787,0,0,0,0,0,1,0,0,0,0,0.0,0.0,0.0,0.0,'Vorsha the Lasher - In Combat - Cast \'Thrash\''),
(12940,0,4,0,0,0,100,0,7000,9000,24000,32000,0,11,6607,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Vorsha the Lasher - In Combat - Cast \'Lash\''),
(12940,0,5,0,0,0,100,0,2000,4000,18000,28000,0,11,33126,0,0,0,0,0,2,0,0,0,0,0.0,0.0,0.0,0.0,'Vorsha the Lasher - In Combat - Cast \'Dropped Weapon\'');
