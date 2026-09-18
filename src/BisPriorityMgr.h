/*
 * mod-playerbots-bis — released under GNU GPL v2, matching mod-playerbots and
 * AzerothCore. Redistribute/modify under version 2 of the License, or (at your
 * option) any later version.
 */

#ifndef MOD_PLAYERBOTS_BIS_MGR_H
#define MOD_PLAYERBOTS_BIS_MGR_H

#include "Define.h"
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

class Player;

// Sentinel spec used for Druid Feral Tank, which shares talent tab 1 with Cat.
// Resolved at runtime from the bot's tank strategy.
#define BIS_SPEC_DRUID_BEAR 10

struct BisTier
{
    uint16 tierId = 0;
    uint8 expansion = 0;          // 0 = Vanilla, 1 = TBC, 2 = WotLK
    std::string name;
    uint8 requiredProgression = 0;  // mod-individual-progression state, 0 = ungated
};

struct BisItem
{
    uint32 itemId = 0;
    uint8 slot = 0;
    uint16 tierId = 0;
    uint8 rank = 1;  // 1 = best within its slot and tier
};

class BisPriorityMgr
{
public:
    static BisPriorityMgr* instance()
    {
        static BisPriorityMgr inst;
        return &inst;
    }

    void LoadConfig();
    void LoadTables();

    bool IsEnabled() const { return _enabled; }
    bool LeaveOtherSpecsBis() const { return _leaveOtherSpecsBis; }
    bool AnnounceOwnBis() const { return _announceOwnBis; }

    // True when this bot's gear decisions get the BiS layer on top of
    // playerbots' own logic. False when the feature is off or the bot is a type
    // the server excluded; there is no level gate, because the BiS layer only
    // ever adds to the original logic, never replaces it.
    bool AppliesTo(Player* bot);

    // Priority of itemId for this bot's class/spec, or 0 when the item is not on
    // the bot's list (wrong spec, unknown item, or tier above the current cap).
    // Higher wins. outSlot receives the slot the list assigns it to, outTierId
    // the tier the entry belongs to.
    uint32 GetItemPriority(Player* bot, uint32 itemId, uint8* outSlot = nullptr,
                           uint16* outTierId = nullptr);

    // True when this bot's class/spec has at least one row it can actually reach
    // (a tier at or below its cap). False means nothing is maintained for that
    // spec yet, and the bot must NOT defer to other specs: with no list of its
    // own it would refuse everything anybody else claims and end up naked.
    bool HasReachableList(Player* bot);

    // True when itemId is on SOMEONE's list but not on this bot's - the bot then
    // leaves it to whoever it belongs to instead of rolling on it as an upgrade.
    // Ignores the tier cap: an item is somebody's best in slot whatever phase
    // the server currently runs.
    bool IsBisForAnotherSpec(Player* bot, uint32 itemId);

    // Human-readable tier name for the whisper, e.g. "Vanilla Phase 1 - Molten
    // Core / Onyxia". Empty when the tier is unknown.
    std::string GetTierName(uint16 tierId) const;

    // Priority of whatever the bot currently wears in that slot. 0 when the slot
    // is empty or holds something absent from the list.
    uint32 GetWornPriority(Player* bot, uint8 slot);

    // Highest tier this bot may pursue: the configured cap, optionally narrowed
    // by the bot's mod-individual-progression state.
    uint16 GetEffectiveTierCap(Player* bot);

    bool IsLoaded() const { return _loaded; }
    size_t TierCount() const { return _tiers.size(); }
    size_t ItemCount() const { return _itemCount; }

private:
    BisPriorityMgr() = default;

    static uint32 MakeKey(uint8 cls, uint8 spec, uint8 faction)
    {
        return (uint32(cls) << 16) | (uint32(spec) << 8) | faction;
    }

    // Resolves the bot's spec, including the Druid Bear sentinel.
    static uint8 ResolveSpec(Player* bot);

    // Account-wide progression level derived from mod-individual-progression's
    // hidden reward quests (66000 + state). 0 when the module is absent.
    uint8 GetProgressionLevel(Player* bot);

    // Read-only after LoadTables(); safe to share across map threads.
    std::unordered_map<uint16, BisTier> _tiers;
    // (cls<<16|spec<<8|faction) -> itemId -> entry
    std::unordered_map<uint32, std::unordered_map<uint32, BisItem>> _items;
    // (cls<<16|spec<<8|faction) -> lowest tier present, so an empty or
    // out-of-reach list is detected without scanning the bucket.
    std::unordered_map<uint32, uint16> _minTierByCombo;
    // itemId -> every (cls<<8|spec) that lists it. Backs IsBisForAnotherSpec
    // without scanning the whole table on each decision.
    std::unordered_map<uint32, std::vector<uint16>> _bisOwners;
    size_t _itemCount = 0;
    bool _loaded = false;

    // Progression cache: accountId -> (level, expiry). Written from map threads.
    struct ProgressionCacheEntry
    {
        uint8 level = 0;
        time_t expiry = 0;
    };
    std::unordered_map<uint32, ProgressionCacheEntry> _progressionCache;
    std::mutex _progressionMutex;

    bool _enabled = false;
    bool _applyToRandomBots = true;
    bool _applyToAddClassBots = false;
    bool _applyToAltBots = false;
    bool _leaveOtherSpecsBis = true;
    bool _announceOwnBis = true;
    uint16 _maxTier = 0;
    bool _useIndividualProgression = false;
    uint32 _progressionCacheSeconds = 300;
};

#define sBisPriorityMgr BisPriorityMgr::instance()

#endif
