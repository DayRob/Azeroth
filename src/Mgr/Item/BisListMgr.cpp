/*
 * This file is part of the mod-playerbots module for AzerothCore. See AUTHORS file for Copyright
 * information; released under GNU GPL v2 license, redistribute/modify under version 2 of the License,
 * or (at your option) any later version.
 */

#include "BisListMgr.h"
#include "AiFactory.h"
#include "DatabaseEnv.h"
#include "Field.h"
#include "Log.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "PlayerbotAIConfig.h"
#include "Playerbots.h"
#include "QueryResult.h"

void BisListMgr::LoadAll()
{
    _bis.clear();

    QueryResult result = PlayerbotsDatabase.Query(
        "SELECT class, tab, slot, faction, auto_gear_score_limit, item_id FROM playerbots_bis_gear");
    if (!result)
    {
        LOG_INFO("server.loading", "playerbots_bis_gear table missing or empty");
        return;
    }

    uint32 count = 0;
    do
    {
        Field* fields = result->Fetch();
        uint8  cls       = fields[0].Get<uint8>();
        uint8  tab       = fields[1].Get<uint8>();
        uint8  slot      = fields[2].Get<uint8>();
        uint8  faction   = fields[3].Get<uint8>();
        uint16 autoGearScoreLimit = fields[4].Get<uint16>();
        uint32 item      = fields[5].Get<uint32>();

        _bis[autoGearScoreLimit][MakeKey(cls, tab)][faction][slot] = item;
        ++count;
    } while (result->NextRow());

    LOG_INFO("server.loading", "Loaded {} BiS entries across {} item levels",
             count, static_cast<uint32>(_bis.size()));
}

std::map<uint8, uint32> BisListMgr::GetBisFor(uint16 autoGearScoreLimit, uint8 cls, uint8 tab, uint8 faction) const
{
    auto ilvlIt = _bis.find(autoGearScoreLimit);
    if (ilvlIt == _bis.end())
        return {};

    auto comboIt = ilvlIt->second.find(MakeKey(cls, tab));
    if (comboIt == ilvlIt->second.end())
        return {};

    std::map<uint8, uint32> result;

    // Base: faction=0 (Both).
    auto bothIt = comboIt->second.find(0);
    if (bothIt != comboIt->second.end())
        result = bothIt->second;

    // Faction-specific overrides Both.
    if (faction == 1 || faction == 2)
    {
        auto facIt = comboIt->second.find(faction);
        if (facIt != comboIt->second.end())
            for (auto const& kv : facIt->second)
                result[kv.first] = kv.second;
    }

    return result;
}

std::map<uint8, uint32> BisListMgr::GetBisForNearest(uint16 requestedIlvl, uint16 maxDrop, uint8 cls, uint8 tab,
                                                    uint8 faction, uint16* outResolved) const
{
    uint16 floor = requestedIlvl > maxDrop ? requestedIlvl - maxDrop : 1;
    for (uint16 try_ilvl = requestedIlvl; try_ilvl >= floor; --try_ilvl)
    {
        auto result = GetBisFor(try_ilvl, cls, tab, faction);
        if (!result.empty())
        {
            if (outResolved)
                *outResolved = try_ilvl;
            return result;
        }
        if (try_ilvl == 0)
            break;
    }
    if (outResolved)
        *outResolved = 0;
    return {};
}

// ---------------------------------------------------------------------------
// Strict BiS mode
// ---------------------------------------------------------------------------

std::map<uint8, uint32> BisListMgr::ResolveForBot(Player* bot, uint16 requestedIlvl, uint16 maxDrop,
                                                  uint16* outResolved) const
{
    if (!bot || !requestedIlvl)
    {
        if (outResolved)
            *outResolved = 0;
        return {};
    }

    // Druid Bear (Feral Tank) shares tab 1 with Cat, so the table stores it under sentinel tab 10.
    constexpr uint8 BIS_TAB_DRUID_BEAR = 10;

    uint8 const cls = bot->getClass();
    uint8 const tab = AiFactory::GetPlayerSpecTab(bot);
    uint8 const faction = bot->GetTeamId() == TEAM_ALLIANCE ? 1 : 2;

    std::map<uint8, uint32> bisMap;
    if (cls == CLASS_DRUID && tab == DRUID_TAB_FERAL && PlayerbotAI::IsTank(bot))
        bisMap = GetBisForNearest(requestedIlvl, maxDrop, cls, BIS_TAB_DRUID_BEAR, faction, outResolved);

    if (bisMap.empty())
        bisMap = GetBisForNearest(requestedIlvl, maxDrop, cls, tab, faction, outResolved);

    return bisMap;
}

uint16 BisListMgr::GetStrictBisTier(Player* bot) const
{
    if (!sPlayerbotAIConfig.randomBotStrictBis || !bot)
        return 0;

    // Strict mode is a randombot-only policy. Addclass bots and player alts keep the
    // normal score-based itemisation (and the on-demand "autogear bis" command).
    if (!sRandomPlayerbotMgr.IsRandomBot(bot))
        return 0;

    // BiS lists only hold level-cap gear for a tier, so leveling bots are left alone.
    uint32 minLevel = sPlayerbotAIConfig.randomBotStrictBisMinLevel
                          ? sPlayerbotAIConfig.randomBotStrictBisMinLevel
                          : sPlayerbotAIConfig.randomBotMaxLevel;
    if (bot->GetLevel() < minLevel)
        return 0;

    // The lists are PvE lists; PvP-specced bots keep resilience-weighted itemisation.
    if (sRandomPlayerbotMgr.IsSpecPvp(bot->GetGUID().GetCounter(), bot->getClass()))
        return 0;

    int32 tier = sPlayerbotAIConfig.randomBotStrictBisIlvl;
    if (tier <= 0)
        tier = sPlayerbotAIConfig.autoGearScoreLimit;

    if (tier <= 0 || tier > 0xFFFF)
        return 0;

    return static_cast<uint16>(tier);
}

std::map<uint8, uint32> BisListMgr::GetStrictBisSet(Player* bot) const
{
    uint16 const tier = GetStrictBisTier(bot);
    if (!tier)
        return {};

    // maxDrop = 0: exact tier only. Mixing phases is precisely what strict mode forbids.
    return ResolveForBot(bot, tier, 0, nullptr);
}

bool BisListMgr::IsStrictBisBot(Player* bot) const { return !GetStrictBisSet(bot).empty(); }

bool BisListMgr::IsStrictBisItem(Player* bot, uint32 itemId, uint8* outSlot) const
{
    for (auto const& kv : GetStrictBisSet(bot))
    {
        if (kv.second == itemId)
        {
            if (outSlot)
                *outSlot = kv.first;
            return true;
        }
    }
    return false;
}
