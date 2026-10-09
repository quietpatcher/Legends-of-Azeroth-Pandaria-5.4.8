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

#include "GameObject.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "AreaTrigger.h"
//#include "AreaTriggerAI.h"
#include "LFGMgr.h"
#include "CinematicMgr.h"
#include "Player.h"
#include "WorldSession.h"
#include <memory>
//#include "SceneHelper.h"

// The Eye of the Storm (28805 / 28826). The Waters black the screen out (94687), two seconds later
// the player goes to the Maelstrom (target of 94689 "Teleport Player") and the fly-by of Thrall holding the Maelstrom
// plays there (cinematic 173, camera FlyBy_Maelstrom: its path only exists on map 730). Back to the Waters when the
// client reports the end of the cinematic.
namespace WatersOfFarseeing
{
    enum
    {
        SPELL_WATERS_OF_FARSEEING   = 94687,
        CINEMATIC_MAELSTROM_FLYBY   = 173,
        NPC_VISION_KILL_CREDIT      = 50054,
        QUEST_EYE_OF_THE_STORM_H    = 28805,
        QUEST_EYE_OF_THE_STORM_A    = 28826,
        MAP_MAELSTROM               = 730,
        MAX_VISION_TIME             = 3 * MINUTE * IN_MILLISECONDS
    };

    // spell_target_position of 94689
    WorldLocation const VisionLoc(MAP_MAELSTROM, 529.838f, 842.595f, 36.1126f, 1.5708f);
    // the quest givers next to the Waters (Farseer Krogar, Naraat the Earthspeaker)
    WorldLocation const WatersHorde(1, 2041.6f, -4384.2f, 99.2f, 0.79f);
    WorldLocation const WatersAlliance(0, -8216.3f, 427.7f, 118.2f, 0.12f);

    struct Vision
    {
        WorldLocation back;
        uint32 waited = 0;
    };
    typedef std::shared_ptr<Vision> VisionPtr;

    void Credit(Player* player)
    {
        if (player->GetQuestStatus(QUEST_EYE_OF_THE_STORM_H) == QUEST_STATUS_INCOMPLETE || player->GetQuestStatus(QUEST_EYE_OF_THE_STORM_A) == QUEST_STATUS_INCOMPLETE)
            player->KilledMonsterCredit(NPC_VISION_KILL_CREDIT);
    }

    // every second during the fly-by
    void Watch(Player* player, VisionPtr vision)
    {
        if (player->GetMapId() != MAP_MAELSTROM)
            return;

        vision->waited += IN_MILLISECONDS;
        if (!player->GetCinematicMgr()->HasActiveCinematic() || vision->waited >= MAX_VISION_TIME)
        {
            player->GetCinematicMgr()->EndCinematic();
            player->TeleportTo(vision->back);
            return;
        }

        player->m_Events.AddLambdaEventAtOffset([player, vision] { Watch(player, vision); }, IN_MILLISECONDS);
    }

    // first moments on the Maelstrom map
    void Begin(Player* player, VisionPtr vision)
    {
        player->RemoveAurasDueToSpell(SPELL_WATERS_OF_FARSEEING);
        Credit(player);
        if (player->GetMapId() != MAP_MAELSTROM)
            return;

        player->SendCinematicStart(CINEMATIC_MAELSTROM_FLYBY);
        player->m_Events.AddLambdaEventAtOffset([player, vision] { Watch(player, vision); }, IN_MILLISECONDS);
    }

    void Depart(Player* player, VisionPtr vision)
    {
        if (!player->IsAlive() || player->GetMapId() != vision->back.GetMapId() || !player->TeleportTo(VisionLoc))
        {
            player->RemoveAurasDueToSpell(SPELL_WATERS_OF_FARSEEING);
            Credit(player);
            return;
        }

        // the player's events stand still until the client has loaded the new map
        player->m_Events.AddLambdaEventAtOffset([player, vision] { Begin(player, vision); }, 1500);
    }
}

class spell_waters_of_farseeing_94687 : public SpellScriptLoader
{
public:
    spell_waters_of_farseeing_94687() : SpellScriptLoader("spell_waters_of_farseeing_94687") { }

    class spell_waters_of_farseeing_94687_AuraScript : public AuraScript
    {
        PrepareAuraScript(spell_waters_of_farseeing_94687_AuraScript);

        void OnApply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
        {
            Unit* caster = GetCaster();
            Player* player = caster ? caster->ToPlayer() : nullptr;
            if (!player)
                return;

            // bots have no client to play (or end) a cinematic
            if (player->GetSession()->IsBot() || player->GetMapId() == WatersOfFarseeing::MAP_MAELSTROM)
            {
                WatersOfFarseeing::Credit(player);
                return;
            }

            WatersOfFarseeing::VisionPtr vision = std::make_shared<WatersOfFarseeing::Vision>();
            vision->back.WorldRelocate(*player);
            // 94688 "Timer Aura" lasts two seconds
            player->m_Events.AddLambdaEventAtOffset([player, vision] { WatersOfFarseeing::Depart(player, vision); }, 2 * IN_MILLISECONDS);
        }

        void Register()
        {
            OnEffectApply += AuraEffectApplyFn(spell_waters_of_farseeing_94687_AuraScript::OnApply, EFFECT_0, SPELL_AURA_SCREEN_EFFECT, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new spell_waters_of_farseeing_94687_AuraScript();
    }
};

// logged out during the vision: back to the Waters
class player_waters_of_farseeing : public PlayerScript
{
public:
    player_waters_of_farseeing() : PlayerScript("player_waters_of_farseeing") { }

    void OnLogin(Player* player) override
    {
        if (player->GetMapId() != WatersOfFarseeing::MAP_MAELSTROM || player->GetExactDist(&WatersOfFarseeing::VisionLoc) > 15.0f)
            return;

        player->TeleportTo(player->GetTeam() == HORDE ? WatersOfFarseeing::WatersHorde : WatersOfFarseeing::WatersAlliance);
    }
};

void AddSC_orgrimmar()
{
    new spell_waters_of_farseeing_94687();
    new player_waters_of_farseeing();
}
