/*
 * the shared to-do inside the game.
 *
 * .issue list / show / add give the GM test addon  the open points of the website's to-do list
 * and take bug reports from inside the game. The website owns the list: its sync job mirrors the open points into
 * characters.todo_issues / todo_notes and turns the rows of characters.todo_reports into new points.
 *
 * .bugreport is the same report for every player (from the bug-report addon and the GM addon): a category, the place only
 * when the reporter wants it sent along, and a limit on how often a player account can report.
 * .bugmine lists the open points a player reported himself, with the question that is waiting for him, and
 * .bugreply answers it: the answer becomes a note on the point (a game master can add a note to any point).
 *
 * The lines for the addons start with "TGM^" and use ^ as separator; the addons hide and parse them.
 */

#include "ScriptMgr.h"
#include "Chat.h"
#include "Creature.h"
#include "DatabaseEnv.h"
#include "Player.h"
#include "RBAC.h"
#include "WorldSession.h"
#include <sstream>

namespace
{
    // auth.rbac_permissions 1346 "Command: issue", linked to role 197 (Gamemaster Commands)
    rbac::RBACPermissions const RBAC_PERM_COMMAND_ISSUE = rbac::RBACPermissions(1346);
    // auth.rbac_permissions 1347 "Command: bugreport", linked to role 199 (Player Commands)
    rbac::RBACPermissions const RBAC_PERM_COMMAND_BUGREPORT = rbac::RBACPermissions(1347);

    uint32 const REPORT_PAUSE_SECONDS = 20;     // between two reports of a player account
    uint32 const REPORT_DAY_LIMIT     = 30;     // reports of a player account in 24 hours
    uint32 const REPLY_PAUSE_SECONDS  = 10;     // between two answers of a player account
    uint32 const MINE_LIMIT           = 15;     // points in .bugmine
    size_t const REPORT_TEXT_MAX      = 255;
    size_t const REPORT_CATEGORY_MAX  = 20;

    // text inside a protocol line: no separator, no client escape codes, no line breaks
    std::string Clean(std::string text)
    {
        for (char& c : text)
            if (c == '^' || c == '|' || c == '\n' || c == '\r' || c == '\t')
                c = ' ';
        return text;
    }

    std::string Trim(std::string text)
    {
        while (!text.empty() && text.front() == ' ')
            text.erase(text.begin());
        while (!text.empty() && text.back() == ' ')
            text.pop_back();
        return text;
    }

    // a row in characters.todo_reports; the place and the target of the reporter only when withPlace is set
    void StoreReport(ChatHandler* handler, bool withPlace, std::string category, uint32 quest, std::string text)
    {
        uint32 account = 0, zone = 0, area = 0, targetEntry = 0, targetSpawn = 0;
        int32 map = -1;
        float x = 0.0f, y = 0.0f, z = 0.0f;
        std::string name = "console", targetName;
        if (WorldSession* session = handler->GetSession())
        {
            Player* player = session->GetPlayer();
            account = session->GetAccountId();
            name = player->GetName();
            if (withPlace)
            {
                map = int32(player->GetMapId());
                x = player->GetPositionX();
                y = player->GetPositionY();
                z = player->GetPositionZ();
                zone = player->GetZoneId();
                area = player->GetAreaId();
                if (Unit* target = player->GetSelectedUnit())
                {
                    if (target != player)
                    {
                        targetName = target->GetName();
                        if (Creature* creature = target->ToCreature())
                        {
                            targetEntry = creature->GetEntry();
                            targetSpawn = uint32(creature->GetSpawnId());
                        }
                    }
                }
            }
        }

        CharacterDatabase.EscapeString(name);
        CharacterDatabase.EscapeString(targetName);
        CharacterDatabase.EscapeString(category);
        CharacterDatabase.EscapeString(text);
        CharacterDatabase.PExecute("INSERT INTO todo_reports (account, name, map, x, y, z, zone, area, target_entry, target_spawn, target_name, quest, category, text) "
            "VALUES ({}, '{}', {}, {}, {}, {}, {}, {}, {}, {}, '{}', {}, '{}', '{}')",
            account, name, map, x, y, z, zone, area, targetEntry, targetSpawn, targetName, quest, category, text);
    }
}

class issue_commandscript : public CommandScript
{
public:
    issue_commandscript() : CommandScript("issue_commandscript") { }

    std::vector<ChatCommand> GetCommands() const override
    {
        static std::vector<ChatCommand> issueCommandTable =
        {
            { "list",   &HandleIssueList,   RBAC_PERM_COMMAND_ISSUE, Trinity::ChatCommands::Console::Yes },
            { "show",   &HandleIssueShow,   RBAC_PERM_COMMAND_ISSUE, Trinity::ChatCommands::Console::Yes },
            { "add",    &HandleIssueAdd,    RBAC_PERM_COMMAND_ISSUE, Trinity::ChatCommands::Console::Yes },
        };
        static std::vector<ChatCommand> commandTable =
        {
            { "issue",      issueCommandTable,  RBAC_PERM_COMMAND_ISSUE,     Trinity::ChatCommands::Console::Yes },
            { "bugreport",  &HandleBugReport,   RBAC_PERM_COMMAND_BUGREPORT, Trinity::ChatCommands::Console::Yes },
            { "bugmine",    &HandleBugMine,     RBAC_PERM_COMMAND_BUGREPORT, Trinity::ChatCommands::Console::Yes },
            { "bugreply",   &HandleBugReply,    RBAC_PERM_COMMAND_BUGREPORT, Trinity::ChatCommands::Console::Yes },
        };
        return commandTable;
    }

    // .issue list: TGM^B, a TGM^I line per open point, TGM^E^count
    static bool HandleIssueList(ChatHandler* handler, char const* /*args*/)
    {
        handler->SendSysMessage("TGM^B");

        uint32 count = 0;
        if (QueryResult result = CharacterDatabase.PQuery("SELECT id, pct, quest, map, x, y, z, author, area, title FROM todo_issues ORDER BY id"))
        {
            do
            {
                Field* fields = result->Fetch();
                std::ostringstream line;
                line << "TGM^I^" << fields[0].GetUInt32() << '^' << uint32(fields[1].GetUInt8()) << '^' << fields[2].GetUInt32()
                     << '^' << fields[3].GetInt32() << '^' << fields[4].GetFloat() << '^' << fields[5].GetFloat() << '^' << fields[6].GetFloat()
                     << '^' << Clean(fields[7].GetString()) << '^' << Clean(fields[8].GetString()) << '^' << Clean(fields[9].GetString());
                handler->SendSysMessage(line.str().c_str());
                ++count;
            } while (result->NextRow());
        }

        std::ostringstream end;
        end << "TGM^E^" << count;
        handler->SendSysMessage(end.str().c_str());
        return true;
    }

    // .issue show #id: TGM^S^id^status, a TGM^N^id^author^text line per note, TGM^F^id
    static bool HandleIssueShow(ChatHandler* handler, char const* args)
    {
        uint32 id = args ? uint32(atoi(args)) : 0;
        if (!id)
            return false;

        if (QueryResult result = CharacterDatabase.PQuery("SELECT status FROM todo_issues WHERE id = {}", id))
        {
            std::ostringstream line;
            line << "TGM^S^" << id << '^' << Clean(result->Fetch()[0].GetString());
            handler->SendSysMessage(line.str().c_str());
        }

        if (QueryResult result = CharacterDatabase.PQuery("SELECT author, text FROM todo_notes WHERE issue = {} ORDER BY id", id))
        {
            do
            {
                Field* fields = result->Fetch();
                std::ostringstream line;
                line << "TGM^N^" << id << '^' << Clean(fields[0].GetString()) << '^' << Clean(fields[1].GetString());
                handler->SendSysMessage(line.str().c_str());
            } while (result->NextRow());
        }

        std::ostringstream end;
        end << "TGM^F^" << id;
        handler->SendSysMessage(end.str().c_str());
        return true;
    }

    // .issue add #quest^text: a bug report; position, zone and target of the reporter are stored with it
    static bool HandleIssueAdd(ChatHandler* handler, char const* args)
    {
        std::string input = args ? args : "";
        size_t separator = input.find('^');
        if (separator == std::string::npos)
            return false;

        uint32 quest = uint32(atoi(input.substr(0, separator).c_str()));
        std::string text = Trim(input.substr(separator + 1));
        if (text.empty() || text.size() > REPORT_TEXT_MAX)
            return false;

        StoreReport(handler, true, "", quest, text);
        handler->SendSysMessage("TGM^A");
        return true;
    }

    // .bugreport #place^category^#quest^text: the report for every player. place 1 = send my position, zone and
    // target along, 0 = leave them out (a remark on an older report, or not at the spot where it happens).
    // Answers TGM^A, or TGM^X^wait^seconds / TGM^X^limit when a player account reports too often.
    static bool HandleBugReport(ChatHandler* handler, char const* args)
    {
        std::string input = args ? args : "";
        size_t first = input.find('^');
        size_t second = first == std::string::npos ? first : input.find('^', first + 1);
        size_t third = second == std::string::npos ? second : input.find('^', second + 1);
        if (third == std::string::npos)
            return false;

        bool withPlace = atoi(input.substr(0, first).c_str()) != 0;
        std::string category = Trim(Clean(input.substr(first + 1, second - first - 1)));
        uint32 quest = uint32(atoi(input.substr(second + 1, third - second - 1).c_str()));
        std::string text = Trim(Clean(input.substr(third + 1)));
        if (text.empty() || text.size() > REPORT_TEXT_MAX)
            return false;
        if (category.size() > REPORT_CATEGORY_MAX)
            category.resize(REPORT_CATEGORY_MAX);

        // game masters and the console report as often as they like
        WorldSession* session = handler->GetSession();
        if (session && !session->HasPermission(RBAC_PERM_COMMAND_ISSUE))
        {
            if (QueryResult result = CharacterDatabase.PQuery("SELECT COUNT(*), COUNT(IF(created > NOW() - INTERVAL {} SECOND, 1, NULL)) FROM todo_reports "
                "WHERE account = {} AND created > NOW() - INTERVAL 1 DAY", REPORT_PAUSE_SECONDS, session->GetAccountId()))
            {
                Field* fields = result->Fetch();
                if (fields[1].GetUInt64() > 0)
                {
                    std::ostringstream wait;
                    wait << "TGM^X^wait^" << REPORT_PAUSE_SECONDS;
                    handler->SendSysMessage(wait.str().c_str());
                    return true;
                }
                if (fields[0].GetUInt64() >= REPORT_DAY_LIMIT)
                {
                    handler->SendSysMessage("TGM^X^limit");
                    return true;
                }
            }
        }

        StoreReport(handler, withPlace, category, quest, text);
        handler->SendSysMessage("TGM^A");
        return true;
    }

    // .bugmine: the open points of this account (reported by it, or with a question for it), newest first.
    // TGM^Y, a TGM^M^id^pct^asked^title^question line per point, TGM^Z^count. asked 1 = the question is for you.
    // From the console: .bugmine #account
    static bool HandleBugMine(ChatHandler* handler, char const* args)
    {
        WorldSession* session = handler->GetSession();
        uint32 account = session ? session->GetAccountId() : uint32(args ? atoi(args) : 0);

        handler->SendSysMessage("TGM^Y");

        uint32 count = 0;
        if (account)
        {
            if (QueryResult result = CharacterDatabase.PQuery("SELECT id, pct, ask_account, title, question FROM todo_issues "
                "WHERE account = {} OR ask_account = {} ORDER BY id DESC LIMIT {}", account, account, MINE_LIMIT))
            {
                do
                {
                    Field* fields = result->Fetch();
                    bool asked = fields[2].GetUInt32() == account;
                    std::ostringstream line;
                    line << "TGM^M^" << fields[0].GetUInt32() << '^' << uint32(fields[1].GetUInt8()) << '^' << (asked ? 1 : 0)
                         << '^' << Clean(fields[3].GetString()) << '^' << (asked ? Clean(fields[4].GetString()) : std::string());
                    handler->SendSysMessage(line.str().c_str());
                    ++count;
                } while (result->NextRow());
            }
        }

        std::ostringstream end;
        end << "TGM^Z^" << count;
        handler->SendSysMessage(end.str().c_str());
        return true;
    }

    // .bugreply #id^text: a note on a point. A player only on a point he reported or was asked about.
    // Answers TGM^R^id, or TGM^X^unknown / TGM^X^notyours / TGM^X^wait^seconds.
    static bool HandleBugReply(ChatHandler* handler, char const* args)
    {
        std::string input = args ? args : "";
        size_t separator = input.find('^');
        if (separator == std::string::npos)
            return false;

        uint32 id = uint32(atoi(input.substr(0, separator).c_str()));
        std::string text = Trim(Clean(input.substr(separator + 1)));
        if (!id || text.empty() || text.size() > REPORT_TEXT_MAX)
            return false;

        QueryResult issue = CharacterDatabase.PQuery("SELECT account, ask_account FROM todo_issues WHERE id = {}", id);
        if (!issue)
        {
            handler->SendSysMessage("TGM^X^unknown");
            return true;
        }

        uint32 account = 0;
        std::string name = "console";
        WorldSession* session = handler->GetSession();
        if (session)
        {
            account = session->GetAccountId();
            name = session->GetPlayer()->GetName();
            if (!session->HasPermission(RBAC_PERM_COMMAND_ISSUE))
            {
                Field* fields = issue->Fetch();
                if (fields[0].GetUInt32() != account && fields[1].GetUInt32() != account)
                {
                    handler->SendSysMessage("TGM^X^notyours");
                    return true;
                }

                if (QueryResult recent = CharacterDatabase.PQuery("SELECT COUNT(*) FROM todo_replies WHERE account = {} AND created > NOW() - INTERVAL {} SECOND",
                    account, REPLY_PAUSE_SECONDS))
                {
                    if (recent->Fetch()[0].GetUInt64() > 0)
                    {
                        std::ostringstream wait;
                        wait << "TGM^X^wait^" << REPLY_PAUSE_SECONDS;
                        handler->SendSysMessage(wait.str().c_str());
                        return true;
                    }
                }
            }
        }

        CharacterDatabase.EscapeString(name);
        CharacterDatabase.EscapeString(text);
        CharacterDatabase.PExecute("INSERT INTO todo_replies (issue, account, name, text) VALUES ({}, {}, '{}', '{}')", id, account, name, text);

        std::ostringstream done;
        done << "TGM^R^" << id;
        handler->SendSysMessage(done.str().c_str());
        return true;
    }
};

void AddSC_issue_commandscript()
{
    new issue_commandscript();
}
