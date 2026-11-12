-- Health_mod of creature_template rows that was computed against the classic base-health column (basehp0) while the
-- template exp selects a later column (basehp1-4). The core takes health = basehp{exp} x Health_mod, so these creatures
-- got 1.5x to 16x too much health (Trade Prince Gallywix 39582: 1.55M instead of 98k; Highlord Darion Mograine 30838: 33M).
-- Source: for each row the new Health_mod gives ceil(basehp{exp} x Health_mod) equal (within 1000 HP) to the sniffed
-- spawn health stored in creature.curhealth of that entry; Gallywix also matches Wowpedia "Final Confrontation" (almost 100,000 HP).
-- Values from 1LineAtaTime/LoA-Pandaria-Playerbots cbff32b2 and 1db8796e (GPLv2), re-checked against our own spawn data.
-- Zarjira 38306 is left out (its value does not reproduce its sniffed health). Idempotent: WHERE on the old value.
-- Rollback: the commented UPDATEs at the end of this file.

UPDATE `creature_template` SET `Health_mod` = 12.1907 WHERE `entry` = 13840 AND ABS(`Health_mod` - 20) < 0.001; -- Warmaster Laggrond: 62880 HP at level 61, exp 1
UPDATE `creature_template` SET `Health_mod` = 4.8763 WHERE `entry` = 13841 AND ABS(`Health_mod` - 8) < 0.001; -- Lieutenant Haggerdin: 25152 HP at level 61, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.4292 WHERE `entry` = 29475 AND ABS(`Health_mod` - 1) < 0.001; -- Improved Land Mine: 5052 HP at level 78, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.6826 WHERE `entry` = 30001 AND ABS(`Health_mod` - 1.6) < 0.001; -- Blackmaw: 8311 HP at level 79, exp 2
UPDATE `creature_template` SET `Health_mod` = 1.3122 WHERE `entry` = 30039 AND ABS(`Health_mod` - 3) < 0.001; -- Asgari: 13956 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.43459 WHERE `entry` = 30058 AND ABS(`Health_mod` - 1) < 0.001; -- Warden of the Chamber: 4781 HP at level 76, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 30066 AND ABS(`Health_mod` - 1) < 0.001; -- Valkyrion Harpoon Gun: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 30094 AND ABS(`Health_mod` - 1) < 0.001; -- Dalaran Sewer Rat: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 30326 AND ABS(`Health_mod` - 1) < 0.001; -- Rotclaw: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 42.3968 WHERE `entry` = 30378 AND ABS(`Health_mod` - 100) < 0.001; -- Iydallus: 534200 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.613 WHERE `entry` = 30481 AND ABS(`Health_mod` - 1) < 0.001; -- Darkmoon Fortune Teller: 2136 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 4.4466 WHERE `entry` = 30488 AND ABS(`Health_mod` - 10.5522) < 0.001; -- Travis Day: 57953 HP at level 81, exp 2
UPDATE `creature_template` SET `Health_mod` = 5.8972 WHERE `entry` = 30489 AND ABS(`Health_mod` - 13.8233) < 0.001; -- Morgan Day: 71799 HP at level 79, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.613 WHERE `entry` = 30721 AND ABS(`Health_mod` - 1) < 0.001; -- Michael Schwan: 2136 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.613 WHERE `entry` = 30722 AND ABS(`Health_mod` - 1) < 0.001; -- Neferatti: 2136 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.613 WHERE `entry` = 30734 AND ABS(`Health_mod` - 1) < 0.001; -- Jezebel Bican: 2136 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.613 WHERE `entry` = 30735 AND ABS(`Health_mod` - 1) < 0.001; -- Kul Inkspiller: 2136 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 800.03155 WHERE `entry` = 30838 AND ABS(`Health_mod` - 2401.3) < 0.001; -- Highlord Darion Mograine: 11156440 HP at level 83, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 31031 AND ABS(`Health_mod` - 1) < 0.001; -- Misensi: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3826 WHERE `entry` = 31032 AND ABS(`Health_mod` - 1) < 0.001; -- Derek Odds: 3256 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 31081 AND ABS(`Health_mod` - 1) < 0.001; -- Officer Van Rossem: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.6087 WHERE `entry` = 31646 AND ABS(`Health_mod` - 1.35) < 0.001; -- Cosmetic Trigger - Phase 3 - LAB: 5468 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4451 WHERE `entry` = 31706 AND ABS(`Health_mod` - 1) < 0.001; -- Crewman Stembolt: 4278 HP at level 72, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.5958 WHERE `entry` = 31804 AND ABS(`Health_mod` - 1) < 0.001; -- Qatiichii: 3524 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.5958 WHERE `entry` = 31805 AND ABS(`Health_mod` - 1) < 0.001; -- Nagojut: 3524 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.5958 WHERE `entry` = 31806 AND ABS(`Health_mod` - 1) < 0.001; -- Oomailiq: 3524 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.5958 WHERE `entry` = 31916 AND ABS(`Health_mod` - 1) < 0.001; -- Tanaika: 3524 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.4509 WHERE `entry` = 32206 AND ABS(`Health_mod` - 1) < 0.001; -- Armored Brown Bear: 4050 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 32286 AND ABS(`Health_mod` - 1) < 0.001; -- Mekgineers Chopper: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4509 WHERE `entry` = 32321 AND ABS(`Health_mod` - 1) < 0.001; -- Green Warrior: 4050 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4509 WHERE `entry` = 32322 AND ABS(`Health_mod` - 1) < 0.001; -- Gold Warrior: 4050 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3156 WHERE `entry` = 32325 AND ABS(`Health_mod` - 0.8) < 0.001; -- Gold Priest: 2268 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3945 WHERE `entry` = 32328 AND ABS(`Health_mod` - 1) < 0.001; -- [DND] Dalaran Sewer Arena - Controller - Death: 2835 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3945 WHERE `entry` = 32339 AND ABS(`Health_mod` - 1) < 0.001; -- [DND] Dalaran Sewer Arena - Controller: 2835 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3607 WHERE `entry` = 32340 AND ABS(`Health_mod` - 1) < 0.001; -- Gold Shaman: 3240 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3607 WHERE `entry` = 32342 AND ABS(`Health_mod` - 1) < 0.001; -- Green Paladin: 3240 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3156 WHERE `entry` = 32343 AND ABS(`Health_mod` - 0.8) < 0.001; -- Green Priest: 2268 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 32415 AND ABS(`Health_mod` - 1) < 0.001; -- Hamaka: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 32416 AND ABS(`Health_mod` - 1) < 0.001; -- Stefen Cotter: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4324 WHERE `entry` = 32435 AND ABS(`Health_mod` - 1.02) < 0.001; -- Vern: 5449 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4324 WHERE `entry` = 32441 AND ABS(`Health_mod` - 1.02) < 0.001; -- Underbelly Croc: 5449 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.8276 WHERE `entry` = 32504 AND ABS(`Health_mod` - 1.35) < 0.001; -- The Lich Kings Presence: 4121 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 32509 AND ABS(`Health_mod` - 1) < 0.001; -- Brammold Deepmine: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 1.2719 WHERE `entry` = 32523 AND ABS(`Health_mod` - 3) < 0.001; -- Johnny Yes: 16026 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 1.2719 WHERE `entry` = 32524 AND ABS(`Health_mod` - 3) < 0.001; -- Willy Maybe: 16026 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 32529 AND ABS(`Health_mod` - 1) < 0.001; -- Horde Infra-green Engineer: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 779.6589 WHERE `entry` = 32547 AND ABS(`Health_mod` - 1871.96) < 0.001; -- Highlords Nemesis Trainer: 10872344 HP at level 83, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3826 WHERE `entry` = 32631 AND ABS(`Health_mod` - 1) < 0.001; -- Alfred Copperworth: 3256 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4292 WHERE `entry` = 32743 AND ABS(`Health_mod` - 1) < 0.001; -- Willard Blauvelt: 5052 HP at level 78, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 32749 AND ABS(`Health_mod` - 1) < 0.001; -- Tuff Gorehoof: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.5958 WHERE `entry` = 32763 AND ABS(`Health_mod` - 1) < 0.001; -- Sairuk: 3524 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.4451 WHERE `entry` = 32804 AND ABS(`Health_mod` - 1) < 0.001; -- Howling Fjord Flame Warden: 4278 HP at level 72, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4451 WHERE `entry` = 32812 AND ABS(`Health_mod` - 1) < 0.001; -- Howling Fjord Flame Keeper: 4278 HP at level 72, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.7937 WHERE `entry` = 33229 AND ABS(`Health_mod` - 1.87196) < 0.001; -- Melee Target: 10001 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.7937 WHERE `entry` = 33272 AND ABS(`Health_mod` - 1.87196) < 0.001; -- Charge Target: 10001 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.9259 WHERE `entry` = 33447 AND ABS(`Health_mod` - 2.18401) < 0.001; -- Squire David: 11667 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 33513 AND ABS(`Health_mod` - 1) < 0.001; -- Black Knights Gryphon: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.9259 WHERE `entry` = 33518 AND ABS(`Health_mod` - 2.18401) < 0.001; -- Squire Danny: 11667 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.9259 WHERE `entry` = 33522 AND ABS(`Health_mod` - 2.18401) < 0.001; -- Squire Cavin: 11667 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3826 WHERE `entry` = 33595 AND ABS(`Health_mod` - 1) < 0.001; -- Mera Mistrunner: 3256 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33608 AND ABS(`Health_mod` - 3) < 0.001; -- Alchemy: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33609 AND ABS(`Health_mod` - 3) < 0.001; -- Blacksmithing: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33610 AND ABS(`Health_mod` - 3) < 0.001; -- Enchanting: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33611 AND ABS(`Health_mod` - 3) < 0.001; -- Engineering: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33612 AND ABS(`Health_mod` - 3) < 0.001; -- Leatherworking: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33613 AND ABS(`Health_mod` - 3) < 0.001; -- Tailoring: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33614 AND ABS(`Health_mod` - 3) < 0.001; -- Jewelcrafting: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33615 AND ABS(`Health_mod` - 3) < 0.001; -- Inscription: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33616 AND ABS(`Health_mod` - 3) < 0.001; -- Herbalism: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33617 AND ABS(`Health_mod` - 3) < 0.001; -- Mining: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33618 AND ABS(`Health_mod` - 3) < 0.001; -- Skinning: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33619 AND ABS(`Health_mod` - 3) < 0.001; -- Cooking: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33621 AND ABS(`Health_mod` - 3) < 0.001; -- First Aid: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 33623 AND ABS(`Health_mod` - 3) < 0.001; -- Fishing: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33630 AND ABS(`Health_mod` - 1) < 0.001; -- Aelthin: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33631 AND ABS(`Health_mod` - 1) < 0.001; -- Barien: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33633 AND ABS(`Health_mod` - 1) < 0.001; -- Enchantress Andiala: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33634 AND ABS(`Health_mod` - 1) < 0.001; -- Engineer Sinbei: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33635 AND ABS(`Health_mod` - 1) < 0.001; -- Daenril: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33636 AND ABS(`Health_mod` - 1) < 0.001; -- Miralisse: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33637 AND ABS(`Health_mod` - 1) < 0.001; -- Kirembri Silvermane: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33638 AND ABS(`Health_mod` - 1) < 0.001; -- Scribe Lanloer: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33639 AND ABS(`Health_mod` - 1) < 0.001; -- Botanist Alaenra: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33640 AND ABS(`Health_mod` - 1) < 0.001; -- Hanlir: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33641 AND ABS(`Health_mod` - 1) < 0.001; -- Irduil: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.3945 WHERE `entry` = 33642 AND ABS(`Health_mod` - 1) < 0.001; -- Loremaster Skosiris: 2835 HP at level 70, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33674 AND ABS(`Health_mod` - 1) < 0.001; -- Alchemist Kanhu: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33675 AND ABS(`Health_mod` - 1) < 0.001; -- Onodo: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33676 AND ABS(`Health_mod` - 1) < 0.001; -- Zurii: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33677 AND ABS(`Health_mod` - 1) < 0.001; -- Technician Mihila: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33678 AND ABS(`Health_mod` - 1) < 0.001; -- Jijia: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33679 AND ABS(`Health_mod` - 1) < 0.001; -- Recorder Lidio: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33680 AND ABS(`Health_mod` - 1) < 0.001; -- Nemiha: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33681 AND ABS(`Health_mod` - 1) < 0.001; -- Korim: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33682 AND ABS(`Health_mod` - 1) < 0.001; -- Fono: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33683 AND ABS(`Health_mod` - 1) < 0.001; -- Dremm: 3237 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.606 WHERE `entry` = 33684 AND ABS(`Health_mod` - 1) < 0.001; -- Weaver Aoa: 2266 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.3122 WHERE `entry` = 33854 AND ABS(`Health_mod` - 3) < 0.001; -- Thomas Partridge: 13956 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 33871 AND ABS(`Health_mod` - 1) < 0.001; -- Julie Osworth: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.9259 WHERE `entry` = 34210 AND ABS(`Health_mod` - 2.18401) < 0.001; -- Squire Artie: 11667 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 34244 AND ABS(`Health_mod` - 1) < 0.001; -- Jean Pierre Poulain: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 34252 AND ABS(`Health_mod` - 1) < 0.001; -- Dubin Clay: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.6129 WHERE `entry` = 34435 AND ABS(`Health_mod` - 1) < 0.001; -- Cheerful Human Spirit: 3052 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.6129 WHERE `entry` = 34476 AND ABS(`Health_mod` - 1) < 0.001; -- Cheerful Forsaken Spirit: 3052 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.6129 WHERE `entry` = 34477 AND ABS(`Health_mod` - 1) < 0.001; -- Cheerful Orc Spirit: 3052 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.6129 WHERE `entry` = 34478 AND ABS(`Health_mod` - 1) < 0.001; -- Cheerful Dwarf Spirit: 3052 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.6129 WHERE `entry` = 34479 AND ABS(`Health_mod` - 1) < 0.001; -- Cheerful Night Elf Spirit: 2442 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.6129 WHERE `entry` = 34480 AND ABS(`Health_mod` - 1) < 0.001; -- Cheerful Tauren Spirit: 3052 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.613 WHERE `entry` = 34481 AND ABS(`Health_mod` - 1) < 0.001; -- Cheerful Gnome Spirit: 2136 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 34653 AND ABS(`Health_mod` - 1) < 0.001; -- Bountiful Table Hostess: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 34654 AND ABS(`Health_mod` - 1) < 0.001; -- Bountiful Feast Hostess: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 34952 AND ABS(`Health_mod` - 1) < 0.001; -- Isle of Conquest Portal: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 34953 AND ABS(`Health_mod` - 1) < 0.001; -- Isle of Conquest Portal: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3499 WHERE `entry` = 35290 AND ABS(`Health_mod` - 1) < 0.001; -- Steen Horngrass: 3722 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 35291 AND ABS(`Health_mod` - 1) < 0.001; -- Moonbell: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 35344 AND ABS(`Health_mod` - 1) < 0.001; -- Bognar Ironfoot: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.3826 WHERE `entry` = 35496 AND ABS(`Health_mod` - 1) < 0.001; -- Rueben Lauren: 3256 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4374 WHERE `entry` = 35498 AND ABS(`Health_mod` - 1) < 0.001; -- Horace Hunderland: 4652 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 35594 AND ABS(`Health_mod` - 1) < 0.001; -- Brassbolt Mechawrench: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 35607 AND ABS(`Health_mod` - 1) < 0.001; -- Reginald Arcfire: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 37734 AND ABS(`Health_mod` - 1) < 0.001; -- Evacuation Portal: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 38294 AND ABS(`Health_mod` - 1) < 0.001; -- Elder Clearwater: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 39130 AND ABS(`Health_mod` - 1) < 0.001; -- Blazing Servant: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 39131 AND ABS(`Health_mod` - 1) < 0.001; -- Watery Servant: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 0.4239 WHERE `entry` = 39132 AND ABS(`Health_mod` - 1) < 0.001; -- Earthen Servant: 5342 HP at level 80, exp 2
UPDATE `creature_template` SET `Health_mod` = 1.7876 WHERE `entry` = 33037 AND ABS(`Health_mod` - 3) < 0.001; -- Caylais Moonfeather: 10572 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.7876 WHERE `entry` = 33039 AND ABS(`Health_mod` - 3) < 0.001; -- Enraged Hippogryph: 10572 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.63401 WHERE `entry` = 35222 AND ABS(`Health_mod` - 10) < 0.001; -- Trade Prince Gallywix: 49130 HP at level 85, exp 3
UPDATE `creature_template` SET `Health_mod` = 5.40973 WHERE `entry` = 35867 AND ABS(`Health_mod` - 50) < 0.001; -- Kalec: 290400 HP at level 83, exp 3
UPDATE `creature_template` SET `Health_mod` = 0.63401 WHERE `entry` = 36403 AND ABS(`Health_mod` - 10) < 0.001; -- Trade Prince Gallywix: 49130 HP at level 85, exp 3
UPDATE `creature_template` SET `Health_mod` = 21.3553 WHERE `entry` = 36436 AND ABS(`Health_mod` - 275) < 0.001; -- Spirit of Azuregos: 1834250 HP at level 88, exp 3
UPDATE `creature_template` SET `Health_mod` = 21.3553 WHERE `entry` = 36676 AND ABS(`Health_mod` - 275) < 0.001; -- Azuregos: 1834250 HP at level 88, exp 3
UPDATE `creature_template` SET `Health_mod` = 1.7876 WHERE `entry` = 37142 AND ABS(`Health_mod` - 3) < 0.001; -- Gurlorn: 10572 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 53.4249 WHERE `entry` = 38225 AND ABS(`Health_mod` - 617.284) < 0.001; -- Voljin: 2867903 HP at level 83, exp 3
UPDATE `creature_template` SET `Health_mod` = 79.24893 WHERE `entry` = 38504 AND ABS(`Health_mod` - 1000) < 0.001; -- UnGoro Examinant: 6141000 HP at level 85, exp 3
UPDATE `creature_template` SET `Health_mod` = 0.63401 WHERE `entry` = 39615 AND ABS(`Health_mod` - 10) < 0.001; -- Trade Prince Gallywix: 49130 HP at level 85, exp 3
UPDATE `creature_template` SET `Health_mod` = 1.7876 WHERE `entry` = 40344 AND ABS(`Health_mod` - 3) < 0.001; -- Nyse: 10572 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.7876 WHERE `entry` = 40345 AND ABS(`Health_mod` - 3) < 0.001; -- Thyssiana: 10572 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 17.8762 WHERE `entry` = 41124 AND ABS(`Health_mod` - 30) < 0.001; -- Okrilla: 105720 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.1917 WHERE `entry` = 41138 AND ABS(`Health_mod` - 2) < 0.001; -- Okrillon Defender: 7048 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.1917 WHERE `entry` = 41158 AND ABS(`Health_mod` - 2) < 0.001; -- Nethergarde Defender: 7048 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.57169 WHERE `entry` = 42673 AND ABS(`Health_mod` - 5.284) < 0.001; -- Hellscream Demolisher: 30689 HP at level 83, exp 3
UPDATE `creature_template` SET `Health_mod` = 1.58497 WHERE `entry` = 43099 AND ABS(`Health_mod` - 20) < 0.001; -- Stone Guard Towhide: 122820 HP at level 85, exp 3
UPDATE `creature_template` SET `Health_mod` = 1.8389 WHERE `entry` = 44084 AND ABS(`Health_mod` - 3) < 0.001; -- Maywiki: 9156 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 55.1677 WHERE `entry` = 44106 AND ABS(`Health_mod` - 90) < 0.001; -- Hambone: 274680 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 17.8762 WHERE `entry` = 44309 AND ABS(`Health_mod` - 30) < 0.001; -- Innkeeper Grak: 105720 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 17.8762 WHERE `entry` = 44310 AND ABS(`Health_mod` - 30) < 0.001; -- Kroff: 105720 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 17.8762 WHERE `entry` = 44311 AND ABS(`Health_mod` - 30) < 0.001; -- Overseer Struk: 105720 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 17.8762 WHERE `entry` = 44312 AND ABS(`Health_mod` - 30) < 0.001; -- Chef Braf: 105720 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 17.8762 WHERE `entry` = 44313 AND ABS(`Health_mod` - 30) < 0.001; -- Neka: 105720 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.86548 WHERE `entry` = 44875 AND ABS(`Health_mod` - 10) < 0.001; -- Millhouse Manastorm: 46460 HP at level 83, exp 3
UPDATE `creature_template` SET `Health_mod` = 6.1297 WHERE `entry` = 44984 AND ABS(`Health_mod` - 10) < 0.001; -- Commander Vines: 30520 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 3.0648 WHERE `entry` = 44985 AND ABS(`Health_mod` - 5) < 0.001; -- Sergeant Krolan: 15260 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.2259 WHERE `entry` = 45262 AND ABS(`Health_mod` - 2) < 0.001; -- Narixxus the Doombringer: 6104 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 6.5613 WHERE `entry` = 45534 AND ABS(`Health_mod` - 15) < 0.001; -- Forward Commander Onslaught: 69780 HP at level 75, exp 2
UPDATE `creature_template` SET `Health_mod` = 1.7876 WHERE `entry` = 47368 AND ABS(`Health_mod` - 3) < 0.001; -- Joran: 10572 HP at level 65, exp 1
UPDATE `creature_template` SET `Health_mod` = 18.1819 WHERE `entry` = 48292 AND ABS(`Health_mod` - 30) < 0.001; -- Acride: 97110 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 1.58497 WHERE `entry` = 48568 AND ABS(`Health_mod` - 20) < 0.001; -- Eitrigg: 122820 HP at level 85, exp 3
UPDATE `creature_template` SET `Health_mod` = 1.58497 WHERE `entry` = 48569 AND ABS(`Health_mod` - 20) < 0.001; -- Eitrigg: 122820 HP at level 85, exp 3
UPDATE `creature_template` SET `Health_mod` = 9.0898 WHERE `entry` = 50609 AND ABS(`Health_mod` - 15) < 0.001; -- Nathanos Blightcaller: 38850 HP at level 62, exp 1
UPDATE `creature_template` SET `Health_mod` = 4.9037 WHERE `entry` = 51375 AND ABS(`Health_mod` - 8) < 0.001; -- Cenarion Scout Jalia: 24416 HP at level 60, exp 1
UPDATE `creature_template` SET `Health_mod` = 0.86548 WHERE `entry` = 51434 AND ABS(`Health_mod` - 10) < 0.001; -- Millhouse Manastorm: 46460 HP at level 83, exp 3
UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 67071 AND ABS(`Health_mod` - 22.609) < 0.001; -- Wary Forest Prowler: 135552 HP at level 84, exp 4
UPDATE `creature_template` SET `Health_mod` = 1.26803 WHERE `entry` = 39582 AND ABS(`Health_mod` - 20) < 0.001; -- Trade Prince Gallywix: 98260 HP at level 85, exp 3

-- Rollback:
--   UPDATE `creature_template` SET `Health_mod` = 20 WHERE `entry` = 13840;
--   UPDATE `creature_template` SET `Health_mod` = 8 WHERE `entry` = 13841;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 29475;
--   UPDATE `creature_template` SET `Health_mod` = 1.6 WHERE `entry` = 30001;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 30039;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30058;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30066;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30094;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30326;
--   UPDATE `creature_template` SET `Health_mod` = 100 WHERE `entry` = 30378;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30481;
--   UPDATE `creature_template` SET `Health_mod` = 10.5522 WHERE `entry` = 30488;
--   UPDATE `creature_template` SET `Health_mod` = 13.8233 WHERE `entry` = 30489;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30721;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30722;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30734;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 30735;
--   UPDATE `creature_template` SET `Health_mod` = 2401.3 WHERE `entry` = 30838;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 31031;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 31032;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 31081;
--   UPDATE `creature_template` SET `Health_mod` = 1.35 WHERE `entry` = 31646;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 31706;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 31804;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 31805;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 31806;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 31916;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32206;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32286;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32321;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32322;
--   UPDATE `creature_template` SET `Health_mod` = 0.8 WHERE `entry` = 32325;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32328;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32339;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32340;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32342;
--   UPDATE `creature_template` SET `Health_mod` = 0.8 WHERE `entry` = 32343;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32415;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32416;
--   UPDATE `creature_template` SET `Health_mod` = 1.02 WHERE `entry` = 32435;
--   UPDATE `creature_template` SET `Health_mod` = 1.02 WHERE `entry` = 32441;
--   UPDATE `creature_template` SET `Health_mod` = 1.35 WHERE `entry` = 32504;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32509;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 32523;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 32524;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32529;
--   UPDATE `creature_template` SET `Health_mod` = 1871.96 WHERE `entry` = 32547;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32631;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32743;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32749;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32763;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32804;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 32812;
--   UPDATE `creature_template` SET `Health_mod` = 1.87196 WHERE `entry` = 33229;
--   UPDATE `creature_template` SET `Health_mod` = 1.87196 WHERE `entry` = 33272;
--   UPDATE `creature_template` SET `Health_mod` = 2.18401 WHERE `entry` = 33447;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33513;
--   UPDATE `creature_template` SET `Health_mod` = 2.18401 WHERE `entry` = 33518;
--   UPDATE `creature_template` SET `Health_mod` = 2.18401 WHERE `entry` = 33522;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33595;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33608;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33609;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33610;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33611;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33612;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33613;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33614;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33615;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33616;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33617;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33618;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33619;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33621;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33623;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33630;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33631;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33633;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33634;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33635;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33636;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33637;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33638;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33639;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33640;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33641;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33642;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33674;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33675;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33676;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33677;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33678;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33679;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33680;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33681;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33682;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33683;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33684;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33854;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 33871;
--   UPDATE `creature_template` SET `Health_mod` = 2.18401 WHERE `entry` = 34210;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34244;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34252;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34435;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34476;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34477;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34478;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34479;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34480;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34481;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34653;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34654;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34952;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 34953;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 35290;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 35291;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 35344;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 35496;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 35498;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 35594;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 35607;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 37734;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 38294;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 39130;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 39131;
--   UPDATE `creature_template` SET `Health_mod` = 1 WHERE `entry` = 39132;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33037;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 33039;
--   UPDATE `creature_template` SET `Health_mod` = 10 WHERE `entry` = 35222;
--   UPDATE `creature_template` SET `Health_mod` = 50 WHERE `entry` = 35867;
--   UPDATE `creature_template` SET `Health_mod` = 10 WHERE `entry` = 36403;
--   UPDATE `creature_template` SET `Health_mod` = 275 WHERE `entry` = 36436;
--   UPDATE `creature_template` SET `Health_mod` = 275 WHERE `entry` = 36676;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 37142;
--   UPDATE `creature_template` SET `Health_mod` = 617.284 WHERE `entry` = 38225;
--   UPDATE `creature_template` SET `Health_mod` = 1000 WHERE `entry` = 38504;
--   UPDATE `creature_template` SET `Health_mod` = 10 WHERE `entry` = 39615;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 40344;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 40345;
--   UPDATE `creature_template` SET `Health_mod` = 30 WHERE `entry` = 41124;
--   UPDATE `creature_template` SET `Health_mod` = 2 WHERE `entry` = 41138;
--   UPDATE `creature_template` SET `Health_mod` = 2 WHERE `entry` = 41158;
--   UPDATE `creature_template` SET `Health_mod` = 5.284 WHERE `entry` = 42673;
--   UPDATE `creature_template` SET `Health_mod` = 20 WHERE `entry` = 43099;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 44084;
--   UPDATE `creature_template` SET `Health_mod` = 90 WHERE `entry` = 44106;
--   UPDATE `creature_template` SET `Health_mod` = 30 WHERE `entry` = 44309;
--   UPDATE `creature_template` SET `Health_mod` = 30 WHERE `entry` = 44310;
--   UPDATE `creature_template` SET `Health_mod` = 30 WHERE `entry` = 44311;
--   UPDATE `creature_template` SET `Health_mod` = 30 WHERE `entry` = 44312;
--   UPDATE `creature_template` SET `Health_mod` = 30 WHERE `entry` = 44313;
--   UPDATE `creature_template` SET `Health_mod` = 10 WHERE `entry` = 44875;
--   UPDATE `creature_template` SET `Health_mod` = 10 WHERE `entry` = 44984;
--   UPDATE `creature_template` SET `Health_mod` = 5 WHERE `entry` = 44985;
--   UPDATE `creature_template` SET `Health_mod` = 2 WHERE `entry` = 45262;
--   UPDATE `creature_template` SET `Health_mod` = 15 WHERE `entry` = 45534;
--   UPDATE `creature_template` SET `Health_mod` = 3 WHERE `entry` = 47368;
--   UPDATE `creature_template` SET `Health_mod` = 30 WHERE `entry` = 48292;
--   UPDATE `creature_template` SET `Health_mod` = 20 WHERE `entry` = 48568;
--   UPDATE `creature_template` SET `Health_mod` = 20 WHERE `entry` = 48569;
--   UPDATE `creature_template` SET `Health_mod` = 15 WHERE `entry` = 50609;
--   UPDATE `creature_template` SET `Health_mod` = 8 WHERE `entry` = 51375;
--   UPDATE `creature_template` SET `Health_mod` = 10 WHERE `entry` = 51434;
--   UPDATE `creature_template` SET `Health_mod` = 22.609 WHERE `entry` = 67071;
--   UPDATE `creature_template` SET `Health_mod` = 20 WHERE `entry` = 39582;
