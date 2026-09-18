/*
 * mod-playerbots-bis — released under GNU GPL v2, matching mod-playerbots and
 * AzerothCore. Redistribute/modify under version 2 of the License, or (at your
 * option) any later version.
 */

#include "BisPriorityMgr.h"
#include "AiFactory.h"
#include "Config.h"
#include "DatabaseEnv.h"
#include "Field.h"
#include "Item.h"
#include "Log.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include "PlayerbotAIConfig.h"
#include "Playerbots.h"
#include "QueryResult.h"

namespace
{
    // mod-individual-progression stores a character's state as a rewarded hidden
    // quest, id 66000 + state. Reading it that way keeps this module free of any
    // compile-time dependency on that module: when it is not installed, no such
    // quest exists and the query simply returns nothing.
    constexpr uint32 IP_QUEST_BASE = 66000;
    constexpr uint32 IP_QUEST_MAX_STATE = 18;  // PROGRESSION_WOTLK_TIER_5

    // A tier always outranks every tier below it; rank orders items inside one
    // tier and slot, 1 being the best. 1000 leaves room for 255 ranks and keeps
    // the arithmetic obvious in logs.
    constexpr uint32 TIER_WEIGHT = 1000;
}

void BisPriorityMgr::LoadConfig()
{
    _enabled = sConfigMgr->GetOption<bool>("PlayerbotsBis.Enable", false);
    _applyToRandomBots = sConfigMgr->GetOption<bool>("PlayerbotsBis.ApplyToRandomBots", true);
    _applyToAddClassBots = sConfigMgr->GetOption<bool>("PlayerbotsBis.ApplyToAddClassBots", false);
    _applyToAltBots = sConfigMgr->GetOption<bool>("PlayerbotsBis.ApplyToAltBots", false);
    _blockOffListRolls = sConfigMgr->GetOption<bool>("PlayerbotsBis.BlockOffListRolls", true);
    _maxTier = static_cast<uint16>(sConfigMgr->GetOption<uint32>("PlayerbotsBis.MaxTier", 0));
    _minLevel = sConfigMgr->GetOption<uint32>("PlayerbotsBis.MinLevel", 0);
    _useIndividualProgression = sConfigMgr->GetOption<bool>("PlayerbotsBis.UseIndividualProgression", false);
    _progressionCacheSeconds = sConfigMgr->GetOption<uint32>("PlayerbotsBis.ProgressionCacheSeconds", 300);
}

void BisPriorityMgr::LoadTables()
{
    _tiers.clear();
    _items.clear();
    _minTierByCombo.clear();
    _itemCount = 0;
    _loaded = false;

    QueryResult tierResult = WorldDatabase.Query(
        "SELECT `tier_id`, `expansion`, `name`, `required_progression` "
        "FROM `playerbots_bis_tier` ORDER BY `tier_id`");
    if (!tierResult)
    {
        LOG_ERROR("server.loading", "[mod-playerbots-bis] playerbots_bis_tier is missing or empty - module inactive");
        return;
    }

    do
    {
        Field* fields = tierResult->Fetch();
        BisTier tier;
        tier.tierId = fields[0].Get<uint16>();
        tier.expansion = fields[1].Get<uint8>();
        tier.name = fields[2].Get<std::string>();
        tier.requiredProgression = fields[3].Get<uint8>();
        _tiers[tier.tierId] = tier;
    } while (tierResult->NextRow());

    QueryResult itemResult = WorldDatabase.Query(
        // Every identifier is back-quoted: `rank` is a reserved word from MySQL 8
        // onward (the RANK() window function), and an unquoted one aborts the
        // whole statement with error 1064.
        "SELECT `class`, `spec`, `slot`, `faction`, `tier_id`, `item_id`, `rank` "
        "FROM `playerbots_bis_item`");
    if (!itemResult)
    {
        LOG_WARN("server.loading", "[mod-playerbots-bis] playerbots_bis_item is empty - no bot will be governed");
        _loaded = true;
        return;
    }

    uint32 skipped = 0;
    do
    {
        Field* fields = itemResult->Fetch();
        uint8 cls = fields[0].Get<uint8>();
        uint8 spec = fields[1].Get<uint8>();
        uint8 slot = fields[2].Get<uint8>();
        uint8 faction = fields[3].Get<uint8>();
        uint16 tierId = fields[4].Get<uint16>();
        uint32 itemId = fields[5].Get<uint32>();
        uint8 rank = fields[6].Get<uint8>();

        if (_tiers.find(tierId) == _tiers.end())
        {
            ++skipped;  // row points at a tier the ladder does not define
            continue;
        }

        BisItem entry;
        entry.itemId = itemId;
        entry.slot = slot;
        entry.tierId = tierId;
        entry.rank = rank ? rank : 1;

        // Faction rows are stored alongside the neutral ones; the lookup below
        // reads the neutral map first and lets the faction map override it.
        uint32 const comboKey = MakeKey(cls, spec, faction);
        auto& bucket = _items[comboKey];

        auto minIt = _minTierByCombo.find(comboKey);
        if (minIt == _minTierByCombo.end() || tierId < minIt->second)
            _minTierByCombo[comboKey] = tierId;

        // Keep the strongest row when the same item appears twice for a combo.
        auto existing = bucket.find(itemId);
        if (existing == bucket.end() || existing->second.tierId < entry.tierId ||
            (existing->second.tierId == entry.tierId && existing->second.rank > entry.rank))
        {
            bucket[itemId] = entry;
        }

        ++_itemCount;
    } while (itemResult->NextRow());

    if (skipped)
        LOG_WARN("server.loading", "[mod-playerbots-bis] {} item rows reference an undefined tier and were ignored",
                 skipped);

    _loaded = true;
    LOG_INFO("server.loading", "[mod-playerbots-bis] Loaded {} tiers and {} item rows",
             static_cast<uint32>(_tiers.size()), static_cast<uint32>(_itemCount));
}

uint8 BisPriorityMgr::ResolveSpec(Player* bot)
{
    uint8 spec = static_cast<uint8>(AiFactory::GetPlayerSpecTab(bot));

    // Feral Druids share tab 1. The list separates Bear from Cat, so a tank
    // Druid is looked up under the sentinel spec instead.
    if (bot->getClass() == CLASS_DRUID && spec == DRUID_TAB_FERAL && PlayerbotAI::IsTank(bot))
        return BIS_SPEC_DRUID_BEAR;

    return spec;
}

bool BisPriorityMgr::AppliesTo(Player* bot)
{
    if (!_enabled || !_loaded || !bot)
        return false;

    if (!GET_PLAYERBOT_AI(bot))
        return false;

    // A list holds level-cap gear for its tier, so a levelling bot must keep the
    // original logic or it would be barred from equipping anything at all.
    // MinLevel = 0 means "playerbots' own RandomBotMaxLevel".
    uint32 const minLevel = _minLevel ? _minLevel : sPlayerbotAIConfig.randomBotMaxLevel;
    if (minLevel && bot->GetLevel() < minLevel)
        return false;

    // No list for this class/spec at the current cap: leave the bot alone rather
    // than blocking every item as "off-list".
    if (!HasListFor(bot))
        return false;

    if (sRandomPlayerbotMgr.IsRandomBot(bot))
        return _applyToRandomBots;

    if (sRandomPlayerbotMgr.IsAddclassBot(bot))
        return _applyToAddClassBots;

    return _applyToAltBots;
}

bool BisPriorityMgr::HasListFor(Player* bot)
{
    uint8 const cls = bot->getClass();
    uint8 const spec = ResolveSpec(bot);
    uint8 const faction = bot->GetTeamId() == TEAM_ALLIANCE ? 1 : 2;
    uint16 const cap = GetEffectiveTierCap(bot);

    for (uint8 f : {uint8(0), faction})
    {
        auto it = _minTierByCombo.find(MakeKey(cls, spec, f));
        if (it != _minTierByCombo.end() && it->second <= cap)
            return true;
    }

    return false;
}

uint8 BisPriorityMgr::GetProgressionLevel(Player* bot)
{
    uint32 const accountId = bot->GetSession() ? bot->GetSession()->GetAccountId() : 0;
    if (!accountId)
        return 0;

    time_t const now = time(nullptr);
    {
        std::lock_guard<std::mutex> guard(_progressionMutex);
        auto it = _progressionCache.find(accountId);
        if (it != _progressionCache.end() && it->second.expiry > now)
            return it->second.level;
    }

    uint8 level = 0;
    QueryResult result = CharacterDatabase.Query(
        "SELECT MAX(cc.quest) FROM character_queststatus_rewarded cc "
        "JOIN characters c ON cc.guid = c.guid "
        "WHERE c.account = {} AND cc.quest BETWEEN {} AND {}",
        accountId, IP_QUEST_BASE + 1, IP_QUEST_BASE + IP_QUEST_MAX_STATE);

    if (result)
    {
        Field* fields = result->Fetch();
        if (!fields[0].IsNull())
        {
            uint32 const questId = fields[0].Get<uint32>();
            if (questId > IP_QUEST_BASE)
                level = static_cast<uint8>(questId - IP_QUEST_BASE);
        }
    }

    {
        std::lock_guard<std::mutex> guard(_progressionMutex);
        ProgressionCacheEntry& entry = _progressionCache[accountId];
        entry.level = level;
        entry.expiry = now + _progressionCacheSeconds;
    }

    return level;
}

uint16 BisPriorityMgr::GetEffectiveTierCap(Player* bot)
{
    uint16 cap = _maxTier;
    if (!cap)
    {
        // No configured cap: the ladder's own top is the ceiling.
        for (auto const& kv : _tiers)
            cap = std::max(cap, kv.first);
    }

    if (!_useIndividualProgression)
        return cap;

    uint8 const progression = GetProgressionLevel(bot);

    // Walk the ladder down until a tier this character has actually unlocked.
    // A tier with required_progression = 0 is never gated.
    uint16 allowed = 0;
    for (auto const& kv : _tiers)
    {
        BisTier const& tier = kv.second;
        if (tier.tierId > cap)
            continue;
        if (tier.requiredProgression && tier.requiredProgression > progression)
            continue;
        allowed = std::max(allowed, tier.tierId);
    }

    return allowed;
}

uint32 BisPriorityMgr::GetItemPriority(Player* bot, uint32 itemId, uint8* outSlot)
{
    if (!_loaded || !itemId)
        return 0;

    uint8 const cls = bot->getClass();
    uint8 const spec = ResolveSpec(bot);
    uint8 const faction = bot->GetTeamId() == TEAM_ALLIANCE ? 1 : 2;

    BisItem const* found = nullptr;

    // Neutral rows first, faction rows override them.
    auto neutral = _items.find(MakeKey(cls, spec, 0));
    if (neutral != _items.end())
    {
        auto it = neutral->second.find(itemId);
        if (it != neutral->second.end())
            found = &it->second;
    }

    auto factional = _items.find(MakeKey(cls, spec, faction));
    if (factional != _items.end())
    {
        auto it = factional->second.find(itemId);
        if (it != factional->second.end())
            found = &it->second;
    }

    if (!found)
        return 0;

    if (found->tierId > GetEffectiveTierCap(bot))
        return 0;  // content this bot has not unlocked yet

    if (outSlot)
        *outSlot = found->slot;

    return uint32(found->tierId) * TIER_WEIGHT + (255u - std::min<uint32>(found->rank, 255u));
}

uint32 BisPriorityMgr::GetWornPriority(Player* bot, uint8 slot)
{
    Item* worn = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
    if (!worn)
        return 0;

    return GetItemPriority(bot, worn->GetEntry(), nullptr);
}
