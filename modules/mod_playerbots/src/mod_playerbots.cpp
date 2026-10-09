/*
** Made by Traesh https://github.com/Traesh
** AzerothCore 2019 http://www.azerothcore.org/
** Conan513 https://github.com/conan513
** Made into a module by Micrah https://github.com/milestorme/
*/

#include "Chat.h"
#include "ChannelMgr.h"
#include "Config.h"
#include "cs_playerbots.h"
#include "Log.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "World.h"
#include "WorldPacket.h"
#include "WorldSocket.h"

#include "Playerbots.h"
#include "PlayerbotAIConfig.h"
#include "RandomPlayerbotMgr.h"
#include "RandomItemManager.h"
#include "RandomPlayerbotBracketMgr.h"

#include "Authentication/AuthCrypt.h"
#include "CharacterHandler.h"

#include <boost/filesystem.hpp>
#include <vector>
#include <future>
#include <unordered_set>
#include <random>
#include <thread>

#ifndef _PLAYERBOT_CONFIG
# define _PLAYERBOT_CONFIG  "playerbots.conf"
#endif

class mod_playerbots : public PlayerScript
{
public:
    mod_playerbots() : PlayerScript("mod_playerbots") {}

    void OnLogin(Player* player) override
    {
        // Announce Module
        ChatHandler(player->GetSession()).SendSysMessage("This server is running the |cff4CFF00mod playerbots |rmodule.");
    }

};

class PlayerbotsWorldScript : public WorldScript
{
public:
    PlayerbotsWorldScript() : WorldScript("PlayerbotsWorldScript") {}

    void OnConfigLoad(bool reloaded) override
    {
        if (!reloaded)
        {
            uint32 oldMSTime = getMSTime();
            std::string conf_file = boost::filesystem::absolute(_PLAYERBOT_CONFIG).generic_string();

            TC_LOG_INFO("playerbots", " ");
            TC_LOG_INFO("playerbots", "Loading Playerbots Config at {} ...", conf_file.c_str());

            std::string err;
            if (!sConfigMgr->LoadAdditionalFile(conf_file, true, err))
            {
                TC_LOG_FATAL("playerbots", ">> Load playerbots failed, {}", err.c_str());
                std::this_thread::sleep_for(std::chrono::seconds(5));
                sWorld->StopNow(1);
                return;
            }
            sPlayerbotAIConfig->Initialize();

            TC_LOG_INFO("playerbots", ">> Loaded playerbots config in {} ms", GetMSTimeDiffToNow(oldMSTime));
            TC_LOG_INFO("playerbots", " ");

            sRandomPlayerbotMgr->Reserve(sPlayerbotAIConfig->maxRandomBots);
            sRandomItemMgr->Init();

            TC_LOG_INFO("playerbots", "Playerbots enabled: {}", sPlayerbotAIConfig->enabled ? "Yes" : "No");
            TC_LOG_INFO("playerbots", "Playerbots min/max to load: {}/{}", sPlayerbotAIConfig->minRandomBots, sPlayerbotAIConfig->maxRandomBots);
            TC_LOG_INFO("playerbots", "Playerbots autologin: {}", sPlayerbotAIConfig->randomBotAutologin ? "Yes" : "No");
        }
    }
    void OnUpdate(uint32 diff) override
    {
        // the bracket manager hands out levels (and with them a full set of gear) to keep a fixed
        // spread over the level ranges; with natural progression the bots level themselves
        static bool const brackets = sConfigMgr->GetBoolDefault("AiPlayerbot.LevelBrackets", true)
            && !sConfigMgr->GetBoolDefault("AiPlayerbot.NaturalProgression", false);
        if (brackets)
            sBracketMgr->Update(diff);
    }
};

class PlayerbotsServerScript : public ServerScript
{
public:
    PlayerbotsServerScript() : ServerScript("PlayerbotsServerScript") {}
    void OnPacketReceive(WorldSession* sessionBot, WorldPacket& packet) override
    {
        Player* playerBot = sessionBot->GetPlayer();
            if (PlayerbotMgr* playerbotMgr = GET_PLAYERBOT_MGR(playerBot))
                playerbotMgr->HandleMasterIncomingPacket(packet);
    }
};

class PlayerbotsScript : public PlayerbotScript
{
public:
    PlayerbotsScript() : PlayerbotScript("PlayerbotsScript") {}

    void OnPlayerbotCheckKillTask(Player* /*player*/, Unit* /*victim*/) override
    {
    }

    void OnPlayerbotCheckPetitionAccount(Player* player, bool& found) override
    {
        if (found && GET_PLAYERBOT_AI(player))
            found = false;
    }

    bool OnPlayerbotCheckUpdatesToSend(Player* player) override
    {
        if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(player))
            return botAI->IsRealPlayer();

        return true;
    }

    void OnPlayerbotPacketSent(Player* player, WorldPacket const* packet) override
    {
        if (!player)
            return;
        
        if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(player))
        {
            botAI->HandleBotOutgoingPacket(*packet);
            // bots are never a master; otherwise every bot packet would loop over all random bots (O(n^2))
            if (!botAI->IsRealPlayer())
                return;
        }
        if (PlayerbotMgr* playerbotMgr = GET_PLAYERBOT_MGR(player))
        {
            playerbotMgr->HandleMasterOutgoingPacket(*packet);
        }
    }

    void OnPlayerbotUpdate(uint32 diff) override
    {
        sRandomPlayerbotMgr->UpdateAI(diff);
        sRandomPlayerbotMgr->UpdateSessions();
        // teleports of the bots of real players, here in the world thread (maps idle)
        for (auto const& pair : sWorld->GetAllSessions())
            if (Player* player = pair.second ? pair.second->GetPlayer() : nullptr)
                if (PlayerbotMgr* playerbotMgr = GET_PLAYERBOT_MGR(player))
                    playerbotMgr->UpdateSessions(true);
    }

    void OnPlayerbotUpdateSessions(Player* player) override
    {
        // called from WorldSession::Update, which also runs inside map threads: no teleports here (see UpdateSessions)
        if (player)
            if (PlayerbotMgr* playerbotMgr = GET_PLAYERBOT_MGR(player))
                playerbotMgr->UpdateSessions(false);
    }

    void OnPlayerbotLogout(Player* player) override
    {
        if (PlayerbotMgr* playerbotMgr = GET_PLAYERBOT_MGR(player))
        {
            PlayerbotAI* botAI = GET_PLAYERBOT_AI(player);
            if (!botAI || botAI->IsRealPlayer())
            {
                playerbotMgr->LogoutAllBots();
            }
        }

        sRandomPlayerbotMgr->OnPlayerLogout(player);
    }

    void OnPlayerbotLogoutBots() override { sRandomPlayerbotMgr->LogoutAllBots(); }
};
class PlayerbotsPlayerScript : public PlayerScript
{
public:
    PlayerbotsPlayerScript() : PlayerScript("PlayerbotsPlayerScript") {}

    void OnLogin(Player* player) override
    {
        if (!player->GetSession()->IsBot())
        {
            sPlayerbotsMgr->AddPlayerbotData(player, false);
            sRandomPlayerbotMgr->OnPlayerLogin(player);

            if (sPlayerbotAIConfig->enabled || sPlayerbotAIConfig->randomBotAutologin)
            {
                std::string roundedTime =
                    std::to_string(std::ceil((sPlayerbotAIConfig->maxRandomBots * 0.11 / 60) * 10) / 10.0);
                roundedTime = roundedTime.substr(0, roundedTime.find('.') + 2);

                ChatHandler(player->GetSession()).SendSysMessage(std::string("Playerbots: bot initialization at server startup takes about '" + roundedTime + "' minutes.").c_str());
            }
        }
    }

    void OnAfterUpdate(Player* player, uint32 diff) override
    {
        if (PlayerbotAI* botAI = GET_PLAYERBOT_AI(player))
        {
            botAI->UpdateAI(diff);
        }

        if (PlayerbotMgr* playerbotMgr = GET_PLAYERBOT_MGR(player))
        {
            playerbotMgr->UpdateAI(diff);
        }
    }
};
void AddSC_bot_life();   // BotLife/BotLifeScripts.cpp: 

void AddSC_mod_playerbots()
{
    new mod_playerbots();

    new PlayerbotsServerScript();
    new PlayerbotsWorldScript();
    new PlayerbotsScript();
    new PlayerbotsPlayerScript();

    AddSC_playerbots_commandscript();
    AddSC_bot_life();
}
