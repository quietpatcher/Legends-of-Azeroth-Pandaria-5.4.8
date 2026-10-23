/*
* This file is part of the Pandaria 5.4.8 Project. See THANKS file for Copyright information
*
* This program is free software; you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the
* Free Software Foundation; either version 2 of the License, or (at your
* option) any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef DEF_DEADMINES_H
#define DEF_DEADMINES_H

enum CannonState
{
    CANNON_NOT_USED,
    CANNON_BLAST_INITIATED,
    PIRATES_ATTACK,
    EVENT_DONE
};

enum NPCs
{
    NPC_GLUBTOK              = 47162,
    NPC_HELIX_GEARBREAKER    = 47296,
    NPC_LUMBERING_OAF        = 47297,
    NPC_FOE_REAPER_5000      = 43778,
    NPC_ADMIRAL_RIPSNARL     = 47626,
    NPC_CAPTAIN_COOKIE       = 47739,
    NPC_VANESSA_VANCLEEF     = 49541,
    NPC_VANESSA_SITTING      = 49429,
    NPC_NOTE_FROM_VANESSA    = 49564,
    // Horde npc
    NPC_KAGTHA               = 46889,
    NPC_SLINKY_SHARPSHIV     = 46906,
    NPC_MISS_MAYHEM          = 46902,
    NPC_MAYHEM_REAPER        = 46903,
    NPC_HAND_ASSASIN         = 46890,
    // Alliance npc
    NPC_HORATIO_LAINE        = 46612,
    NPC_INVESTIGATOR         = 46614,
    NPC_DEFENDER             = 50595,
    NPC_CRIME_SCENE_BOT      = 46613,
    // Trash
    NPC_MINING_POWDER        = 48284,
    // deadmines 314a-4: values follow creature_template (47403 = Reaper, 47404 = Watcher); they were swapped
    NPC_DEFIAS_REAPER        = 47403,
    NPC_DEFIAS_WATCHER       = 47404,

    // Misc
    NPC_FROST_BLOSSOM_BUNNY  = 47284,
    NPC_FIRE_BLOSSOM_BUNNY   = 47282,
};

enum eSpells
{
    SPELL_EXPLODE_MINE = 89769,
    SPELL_OFF_LINE     = 88348,
};

enum Data
{
    DATA_GLUBTOK          = 0,
    DATA_HELIX            = 1,
    DATA_FOEREAPER        = 2,
    DATA_ADMIRAL          = 3,
    DATA_CAPTAIN          = 4,
    DATA_VANESSA          = 5,
    DATA_CANNON_EVENT     = 6,
    DATA_OAF              = 7,
    DATA_VANESSA_EVENT    = 8,
    DATA_TEAM_IN_INSTANCE = 9,
};

enum GameObjects
{
    GO_FOUNDRY_DOOR      = 16399,
    GO_FACTORY_DOOR      = 13965,
    GO_MAST_ROOM_DOOR    = 16400,
    GO_IRONCLAD_DOOR     = 16397,
    GO_DEFIAS_CANNON     = 16398,
    GO_DOOR_LEVER        = 101833,
    GO_HEAVY_DOOR        = 17153,
    GO_HEAVY_DOOR_2      = 17154,
    GO_GOBLIN_TELEPORTER = 208002,
};

enum Sounds
{
    SOUND_CANNONFIRE  = 1400,
    SOUND_DESTROYDOOR = 3079,
};

enum Worldstates
{
    WORLDSTATE_PROTOTYPE_PRODIGY    = 8938,
    WORLDSTATE_VANCLEEF_VINDICATION = 8993,
};

const Position centershipPos = {-63.167f, -819.315f, 41.27f, 6.25f};
const Position notePos = {-74.3611f, -820.014f, 40.3714f, 4.01426f};
const Position vanessaPos = {-75.5851f, -819.964f, 47.0673f, 6.17846f};

// deadmines 314b: Vanessa VanCleef nightmare run (heroic). Ids: 5.4.8 creature_template / Spell.dbc on dev.
// Stage positions: world.creature rows of map 36 with spawnMask 0 (the nightmare figures; identical to the sniff positions of
// the CPP reference). Harrington, worgen, spider and forge-floor positions: CPP reference only (no DB row), marked below.
enum VanessaNightmareStages
{
    // DATA_VANESSA_EVENT keeps NOT_STARTED / IN_PROGRESS / FAIL / DONE (EncounterState); the stages sit above those values
    NIGHTMARE_STAGE_GLUBTOK    = 10,
    NIGHTMARE_STAGE_HELIX      = 11,
    NIGHTMARE_STAGE_FOE_REAPER = 12,
    NIGHTMARE_STAGE_RIPSNARL   = 13,
};

enum VanessaNightmareNpcs
{
    NPC_NM_NARRATOR          = 49671,   // "Vanessa VanCleef" event copy, creature_text 0-11 (DB) + 12-16 (fix_251)
    NPC_NM_GLUBTOK           = 49670,
    NPC_NM_HELIX             = 49674,   // creature_text 0 "You have entered Helix's nightmare!", 1 spiders emote
    NPC_NM_SKITTERLING       = 49493,
    NPC_NM_DARKWEB_DEVOURER  = 49494,
    NPC_NM_CHATTERING_HORROR = 49495,
    NPC_NM_FOE_REAPER        = 49681,
    NPC_NM_RIPSNARL          = 49682,
    NPC_NM_ENRAGED_WORGEN    = 49532,
    NPC_NM_EMME              = 49534,
    NPC_NM_ERIK              = 49535,
    NPC_NM_CALISSA           = 49536,   // creature_text 0 "James...please...I love you...", 1 "Calissa is dying!"
    NPC_NM_JAMES             = 49539,   // vehicle 1403 (holds Calissa), creature_text 0 "Calissa...I am so sorry..."
};

enum VanessaNightmareSpells
{
    SPELL_NM_ELIXIR          = 92113,   // Nightmare Elixir (dummy aura on the players, "Make your way back to Vanessa...")
    SPELL_NM_AURA            = 92563,   // Nightmare Aura (screen effect)
    SPELL_NM_ADRENALINE      = 92604,   // movement speed +50 %, from a saved Harrington
    SPELL_NM_CHOKING         = 92608,   // Calissa in James' grip, 3 % health per second
    SPELL_NM_SPIRIT_STRIKE   = 59304,   // creature_template.spell1 of 49670 / 49674 / 49681
};

enum VanessaNightmareTexts    // creature_text of 49671
{
    NM_SAY_GLUBTOK_1        = 0,
    NM_SAY_GLUBTOK_2        = 1,
    NM_SAY_GLUBTOK_ENTER    = 2,
    NM_SAY_BACK_TO_SHIP     = 3,
    NM_SAY_HELIX_1          = 4,
    NM_SAY_HELIX_2          = 5,
    NM_SAY_MECHANICAL_1     = 6,
    NM_SAY_MECHANICAL_2     = 7,
    NM_SAY_MECHANICAL_ENTER = 8,
    NM_SAY_RIPSNARL_1       = 9,
    NM_SAY_RIPSNARL_2       = 10,
    NM_SAY_RIPSNARL_ENTER   = 11,
    NM_SAY_SHIFTS           = 12,   // fix_251
    NM_SAY_SAVE_EMME        = 13,
    NM_SAY_SAVE_ERIK        = 14,
    NM_SAY_SAVE_CALISSA     = 15,
    NM_SAY_ELIXIR_WEARS_OFF = 16,

    NM_SAY_HELIX_ENTER      = 0,    // 49674
    NM_SAY_HELIX_SPIDERS    = 1,
    NM_SAY_CALISSA_PLEASE   = 0,    // 49536
    NM_SAY_CALISSA_DYING    = 1,
    NM_SAY_JAMES_SORRY      = 0,    // 49539
};

// world.creature rows (map 36, spawnMask 0) of 49671 / 49670 / 49674 / 49681 / 49682
const Position nmNarratorPos[4] =
{
    {-230.717f, -563.014f, 51.3129f, 1.047198f},
    {-172.809f, -576.911f, 19.3976f, 4.817109f},
    {-159.392f, -580.517f, 19.3982f, 6.195919f},
    {-98.5816f, -662.663f, 7.49801f, 3.490659f}
};
const Position nmGlubtokIntroPos   = {-229.34f, -560.363f, 51.3129f, 5.742133f};    // ledge above the forge
const Position nmGlubtokPos        = {-174.821f, -579.755f, 19.396f, 3.193953f};    // forge floor, far end
const Position nmHelixPos          = {-172.686f, -580.047f, 19.3975f, 3.176499f};
const Position nmFoeReaperIntroPos = {-155.471f, -580.695f, 19.3978f, 0.0f};
const Position nmFoeReaperPos      = {-108.114f, -654.451f, 7.42374f, 1.850049f};   // end of the tunnel, before the cove
const Position nmRipsnarlPos       = {-101.214f, -663.453f, 7.50482f, 1.867502f};
// CPP reference (sniff positions, no DB row): where the trap drops the players, the Harringtons and their worgen
const Position nmForgeFloorPos     = {-205.4688f, -567.2049f, 21.06016f, 0.0f};
const Position nmEmmePos           = {-98.63194f, -721.6268f, 8.547067f, 1.53589f};
const Position nmWorgenEmmePos[3]  =
{
    {-97.79166f, -717.8542f, 8.668088f, 4.520403f},
    {-94.40278f, -719.7274f, 8.598646f, 3.560472f},
    {-101.9167f, -718.7552f, 8.726379f, 5.51524f}
};
const Position nmErikPos           = {5.239583f, -763.0868f, 9.800426f, 2.007129f};
const Position nmWorgenErikPos[3]  =
{
    {3.326038f, -760.3063f, 9.713999f, 5.31516f},
    {8.798013f, -762.2252f, 9.625132f, 3.379143f},
    {4.232807f, -766.6125f, 9.804724f, 1.292649f}
};
const Position nmCalissaPos        = {-83.86406f, -775.2837f, 28.37906f, 1.710423f};
const Position nmJamesPos          = {-83.16319f, -774.9636f, 26.90351f, 1.710423f};
const Position nmDarkwebPos[3]     =
{
    {-215.7064f, -553.3212f, 51.29544f, 0.7243207f},
    {-229.285f, -568.6863f, 51.31313f, 0.8218399f},
    {-231.3453f, -584.1043f, 51.31514f, 1.05134f}
};
const Position nmChatteringHorrorPos = {-233.625f, -570.5868f, 19.3898f, 0.0f};
#define NM_SKITTERLING_COUNT 100
const Position nmSkitterlingPos[NM_SKITTERLING_COUNT] =
{
    { -184.9618f, -552.9132f, 19.3898f, 0.0f },
    { -199.1406f, -573.6893f, 21.06016f, 0.0f },
    { -194.5851f, -578.3386f, 21.06015f, 0.0f },
    { -193.3264f, -569.809f, 21.06016f, 0.0f },
    { -185.7622f, -566.6059f, 19.3898f, 0.0f },
    { -181.401f, -561.684f, 19.3898f, 0.0f },
    { -221.2569f, -549.3316f, 19.3898f, 0.0f },
    { -215.125f, -546.0486f, 19.3898f, 0.0f },
    { -210.3854f, -550.6736f, 19.3898f, 0.0f },
    { -206.8715f, -545.3837f, 19.3898f, 0.0f },
    { -208.3247f, -556.5833f, 19.3898f, 0.0f },
    { -203.1233f, -550.8281f, 19.3898f, 0.0f },
    { -198.2465f, -546.9288f, 19.3898f, 0.0f },
    { -178.6389f, -564.4479f, 19.39f, 0.0f },
    { -193.3698f, -581.8663f, 21.06015f, 0.0f },
    { -188.1788f, -578.3715f, 21.06015f, 0.0f },
    { -185.3385f, -562.592f, 19.3898f, 0.0f },
    { -179.6458f, -557.9063f, 19.3898f, 0.0f },
    { -226.5208f, -587.257f, 19.53274f, 0.0f },
    { -199.3351f, -586.7952f, 21.06015f, 0.0f },
    { -207.6545f, -594.809f, 21.06015f, 0.0f },
    { -201.2587f, -593.309f, 21.06016f, 0.0f },
    { -224.2743f, -592.7917f, 20.29579f, 0.0f },
    { -211.9844f, -569.5417f, 21.06016f, 0.0f },
    { -208.9288f, -563.6094f, 21.06016f, 0.0f },
    { -200.8715f, -557.2518f, 19.3898f, 0.0f },
    { -196.2396f, -553.6927f, 19.3898f, 0.0f },
    { -192.1163f, -550.1024f, 19.3898f, 0.0f },
    { -202.4063f, -563.1337f, 21.06016f, 0.0f },
    { -195.9635f, -560.8889f, 20.58139f, 0.0f },
    { -190.1094f, -557.4722f, 19.3898f, 0.0f },
    { -199.3229f, -550.3785f, 19.3898f, 0.0f },
    { -195.2552f, -557.0087f, 19.3898f, 0.0f },
    { -190.1372f, -553.0625f, 19.3898f, 0.0f },
    { -185.2118f, -557.6406f, 19.3898f, 0.0f },
    { -190.6406f, -561.441f, 19.3898f, 0.0f },
    { -197.7413f, -564.3021f, 21.06016f, 0.0f },
    { -215.5365f, -549.8021f, 19.3898f, 0.0f },
    { -212.1719f, -555.0226f, 19.3898f, 0.0f },
    { -213.2344f, -561.8577f, 21.06016f, 0.0f },
    { -208.5451f, -568.1146f, 21.06016f, 0.0f },
    { -202.7257f, -572.5174f, 21.06016f, 0.0f },
    { -205.6354f, -559.1563f, 21.06016f, 0.0f },
    { -206.1615f, -553.3507f, 19.3898f, 0.0f },
    { -202.5451f, -546.118f, 19.3898f, 0.0f },
    { -204.1024f, -596.7518f, 21.06016f, 0.0f },
    { -204.0087f, -590.8386f, 21.06016f, 0.0f },
    { -198.8316f, -591.7239f, 21.06015f, 0.0f },
    { -195.4375f, -586.2934f, 21.06015f, 0.0f },
    { -197.6493f, -582.4653f, 21.06015f, 0.0f },
    { -219.1337f, -559.7899f, 19.3898f, 0.0f },
    { -221.4063f, -553.1406f, 19.3898f, 0.0f },
    { -216.1215f, -564.882f, 21.06016f, 0.0f },
    { -199.3125f, -578.1996f, 21.06016f, 0.0f },
    { -204.684f, -569.3542f, 21.06016f, 0.0f },
    { -197.8576f, -569.3489f, 21.06016f, 0.0f },
    { -191.7656f, -565.8559f, 21.06016f, 0.0f },
    { -213.4635f, -591.625f, 21.06015f, 0.0f },
    { -206.0781f, -588.0712f, 21.06016f, 0.0f },
    { -213.1997f, -585.125f, 21.06015f, 0.0f },
    { -220.5174f, -581.8143f, 21.06016f, 0.0f },
    { -182.8004f, -569.368f, 19.39167f, 0.0f },
    { -189.0191f, -571.2674f, 21.06016f, 0.0f },
    { -193.7674f, -574.7014f, 21.06016f, 0.0f },
    { -226.1285f, -581.059f, 20.79114f, 0.0f },
    { -218.6076f, -581.0746f, 21.06016f, 0.0f },
    { -216.1094f, -576.8264f, 21.06016f, 0.0f },
    { -222.1545f, -555.1077f, 19.3898f, 0.0f },
    { -212.6059f, -567.2239f, 21.06016f, 0.0f },
    { -203.9184f, -551.0608f, 19.3898f, 0.0f },
    { -202.8663f, -590.1371f, 21.06016f, 0.0f },
    { -196.4757f, -573.0833f, 21.06016f, 0.0f },
    { -185.9288f, -558.125f, 19.3898f, 0.0f },
    { -213.8767f, -559.3125f, 20.02806f, 0.0f },
    { -221.8142f, -556.3976f, 19.3898f, 0.0f },
    { -216.5017f, -553.9722f, 19.3898f, 0.0f },
    { -223.7483f, -574.9896f, 21.06015f, 0.0f },
    { -226.1215f, -563.0382f, 19.3898f, 0.0f },
    { -213.8559f, -574.6094f, 21.06016f, 0.0f },
    { -208.3854f, -571.8004f, 21.06016f, 0.0f },
    { -224.5625f, -568.1476f, 19.92673f, 0.0f },
    { -219.7083f, -588.6094f, 21.06015f, 0.0f },
    { -218.8872f, -570.5643f, 21.06016f, 0.0f },
    { -221.8264f, -562.2795f, 19.3898f, 0.0f },
    { -227.9063f, -559.566f, 19.3898f, 0.0f },
    { -230.4948f, -566.0191f, 19.3898f, 0.0f },
    { -227.0243f, -552.6736f, 19.3898f, 0.0f },
    { -231.566f, -572.1979f, 19.3898f, 0.0f },
    { -231.8802f, -578.5677f, 19.3898f, 0.0f },
    { -232.4462f, -562.8837f, 19.3898f, 0.0f },
    { -232.4514f, -586.2518f, 19.3898f, 0.0f },
    { -230.3767f, -592.8577f, 19.3898f, 0.0f },
    { -232.8004f, -591.1805f, 19.3898f, 0.0f },
    { -234.5208f, -559.4809f, 19.3898f, 0.0f },
    { -236.5712f, -565.5573f, 19.3898f, 0.0f },
    { -237.5799f, -571.5903f, 19.3898f, 0.0f },
    { -238.9063f, -578.1528f, 19.3898f, 0.0f },
    { -234.0608f, -598.0f, 19.95063f, 0.0f },
    { -236.5122f, -591.9913f, 19.3898f, 0.0f },
    { -238.8021f, -584.8594f, 19.3898f, 0.0f }
};

template<class AI>
CreatureAI* GetInstanceAI(Creature* creature)
{
    if (InstanceMap* instance = creature->GetMap()->ToInstanceMap())
        if (instance->GetInstanceScript())
            if (instance->GetScriptId() == sObjectMgr->GetScriptId("instance_deadmines"))
                return new AI(creature);
    return NULL;
}

#endif