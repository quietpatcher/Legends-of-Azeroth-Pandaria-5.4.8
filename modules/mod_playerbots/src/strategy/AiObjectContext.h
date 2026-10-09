/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU GPL v2 license, you may redistribute it
 * and/or modify it under version 2 of the License, or (at your option), any later version.
 */

#ifndef _PLAYERBOT_AIOBJECTCONTEXT_H
#define _PLAYERBOT_AIOBJECTCONTEXT_H

#include <sstream>
#include <type_traits>
#include <typeinfo>
#include <unordered_map>
#include <string>

#include "Common.h"
#include "NamedObjectContext.h"
#include "PlayerbotAIAware.h"
#include "Strategy.h"
#include "Trigger.h"
#include "Value.h"

class PlayerbotAI;

class AiObjectContext : public PlayerbotAIAware
{
public:
    AiObjectContext(PlayerbotAI* botAI);
    virtual ~AiObjectContext()
    {
        for (auto& missing : missingValues)
            delete missing.second;
    }

    virtual Strategy* GetStrategy(std::string const name);
    virtual std::set<std::string> GetSiblingStrategy(std::string const name);
    virtual Trigger* GetTrigger(std::string const name);
    virtual Action* GetAction(std::string const name);
    virtual UntypedValue* GetUntypedValue(std::string const name);

    template <class T>
    Value<T>* GetValue(std::string const name)
    {
        if (Value<T>* value = dynamic_cast<Value<T>*>(GetUntypedValue(name)))
            return value;
        // a value this port does not register (or of another type). Callers use the result right away
        // (AI_VALUE -> ->Get()), which was a null dereference / garbage read and crashed the server. Hand out a
        // default value owned by this context and built with this bot's AI (a value built without an AI crashes in
        // the AiObject constructor), and report the name once.
        if constexpr (!std::is_reference_v<T> && std::is_default_constructible_v<T>)
        {
            std::string key = name + "#" + typeid(T).name();
            auto it = missingValues.find(key);
            if (it == missingValues.end())
            {
                ReportMissingValue(name);
                it = missingValues.emplace(key, new ManualSetValue<T>(botAI, T(), "missing value")).first;
            }
            ManualSetValue<T>* missing = static_cast<ManualSetValue<T>*>(it->second);
            missing->Reset();
            return missing;
        }
        else
        {
            ReportMissingValue(name);
            return nullptr;
        }
    }

    static void ReportMissingValue(std::string const& name);

    template <class T>
    Value<T>* GetValue(std::string const name, std::string const param)
    {
        return GetValue<T>((std::string(name) + "::" + param));
    }

    template <class T>
    Value<T>* GetValue(std::string const name, int32 param)
    {
        std::ostringstream out;
        out << param;
        return GetValue<T>(name, out.str());
    }

    std::set<std::string> GetValues();
    std::set<std::string> GetSupportedStrategies();
    std::set<std::string> GetSupportedActions();
    std::string const FormatValues();

    virtual void Update();
    virtual void Reset();
    virtual void AddShared(NamedObjectContext<UntypedValue>* sharedValues);

    std::vector<std::string> Save();
    void Load(std::vector<std::string> data);

    std::vector<std::string> performanceStack;

protected:
    NamedObjectContextList<Strategy> strategyContexts;
    NamedObjectContextList<Action> actionContexts;
    NamedObjectContextList<Trigger> triggerContexts;
    NamedObjectContextList<UntypedValue> valueContexts;
    std::unordered_map<std::string, UntypedValue*> missingValues;   // defaults for unregistered values
};

#endif
