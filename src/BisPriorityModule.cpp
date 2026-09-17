/*
 * mod-playerbots-bis — released under GNU GPL v2, matching mod-playerbots and
 * AzerothCore. Redistribute/modify under version 2 of the License, or (at your
 * option) any later version.
 */

#include "BisPriorityMgr.h"
#include "BisValueContext.h"
#include "Chat.h"
#include "DKAiObjectContext.h"
#include "DruidAiObjectContext.h"
#include "HunterAiObjectContext.h"
#include "Log.h"
#include "MageAiObjectContext.h"
#include "PaladinAiObjectContext.h"
#include "PriestAiObjectContext.h"
#include "RogueAiObjectContext.h"
#include "ScriptMgr.h"
#include "ShamanAiObjectContext.h"
#include "WarlockAiObjectContext.h"
#include "WarriorAiObjectContext.h"

namespace
{
    // Append our value context to one class's shared list. Add() assigns into
    // that list's creator map, so our "item usage" / "item upgrade" creators
    // replace playerbots'. Per-bot context lists hold the map by reference, so
    // bots that already exist pick this up as soon as they next resolve the
    // value by name.
    template <class Ctx>
    void RegisterClassValueContext()
    {
        Ctx::sharedValueContexts.Add(new BisValueContext());
    }
}

// Registration happens on the first world tick rather than at load time, for
// two reasons. The module config is certainly loaded by then, and script
// registration order is alphabetical - registering here guarantees we land
// AFTER mod-playerbots' own ValueContext, which is what makes the override win.
// It is also still before any bot logs in, so no bot has cached the old value.
class BisPriorityWorldScript : public WorldScript
{
public:
    BisPriorityWorldScript() : WorldScript("BisPriorityWorldScript") {}

    void OnUpdate(uint32 /*diff*/) override
    {
        if (_registered)
            return;
        _registered = true;

        sBisPriorityMgr->LoadConfig();
        sBisPriorityMgr->LoadTables();

        if (!sBisPriorityMgr->IsLoaded())
        {
            LOG_ERROR("server.loading", "[mod-playerbots-bis] Tables unavailable - bot itemisation left untouched");
            return;
        }

        // Registration happens even when the module is switched off, so that
        // PlayerbotsBis.Enable can be toggled at runtime with ".playerbotsbis
        // reload". This is the only moment at which registering is safe (after
        // playerbots, before any bot exists), so skipping it here would leave
        // the module permanently inert until the next restart.
        //
        // A disabled module costs one delegated virtual call per gear decision:
        // BisPriorityMgr::AppliesTo() returns false, and the replacement values
        // hand back exactly what playerbots would have answered.

        RegisterClassValueContext<WarriorAiObjectContext>();
        RegisterClassValueContext<PaladinAiObjectContext>();
        RegisterClassValueContext<HunterAiObjectContext>();
        RegisterClassValueContext<RogueAiObjectContext>();
        RegisterClassValueContext<PriestAiObjectContext>();
        RegisterClassValueContext<DKAiObjectContext>();
        RegisterClassValueContext<ShamanAiObjectContext>();
        RegisterClassValueContext<MageAiObjectContext>();
        RegisterClassValueContext<WarlockAiObjectContext>();
        RegisterClassValueContext<DruidAiObjectContext>();

        if (sBisPriorityMgr->IsEnabled())
            LOG_INFO("server.loading",
                     "[mod-playerbots-bis] Active - BiS ladder governs bot gear and loot rolls ({} tiers, {} items)",
                     static_cast<uint32>(sBisPriorityMgr->TierCount()),
                     static_cast<uint32>(sBisPriorityMgr->ItemCount()));
        else
            LOG_INFO("server.loading",
                     "[mod-playerbots-bis] Dormant (PlayerbotsBis.Enable = 0) - set it to 1 and run "
                     "\".playerbotsbis reload\" to activate without a restart");
    }

private:
    bool _registered = false;
};

// ".playerbotsbis reload" re-reads the conf file and both tables without a
// server restart, so a tier or item row can be edited and tried immediately.
class BisPriorityCommandScript : public CommandScript
{
public:
    BisPriorityCommandScript() : CommandScript("BisPriorityCommandScript") {}

    Acore::ChatCommands::ChatCommandTable GetCommands() const override
    {
        using namespace Acore::ChatCommands;

        static ChatCommandTable bisCommandTable = {
            {"reload", HandleBisReloadCommand, SEC_GAMEMASTER, Console::Yes},
        };

        static ChatCommandTable commandTable = {
            {"playerbotsbis", bisCommandTable},
        };

        return commandTable;
    }

    static bool HandleBisReloadCommand(ChatHandler* handler, char const* /*args*/)
    {
        sBisPriorityMgr->LoadConfig();
        sBisPriorityMgr->LoadTables();

        handler->PSendSysMessage("mod-playerbots-bis: reloaded {} tiers, {} item rows (enabled: {})",
                                 static_cast<uint32>(sBisPriorityMgr->TierCount()),
                                 static_cast<uint32>(sBisPriorityMgr->ItemCount()),
                                 sBisPriorityMgr->IsEnabled() ? "yes" : "no");
        return true;
    }
};

void AddSC_playerbots_bis()
{
    new BisPriorityWorldScript();
    new BisPriorityCommandScript();
}
