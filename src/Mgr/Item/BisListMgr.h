/*
 * This file is part of the mod-playerbots module for AzerothCore. See AUTHORS file for Copyright
 * information; released under GNU GPL v2 license, redistribute/modify under version 2 of the License,
 * or (at your option) any later version.
 */

#ifndef PLAYERBOTS_BISLISTMGR_H
#define PLAYERBOTS_BISLISTMGR_H

#include "Define.h"
#include <map>

class Player;

class BisListMgr
{
public:
    static BisListMgr* instance()
    {
        static BisListMgr inst;
        return &inst;
    }

    void LoadAll();

    // faction: 1=Alliance, 2=Horde. Faction-specific rows override faction=0 (Both).
    // Returns slot -> itemId for the matching auto_gear_score_limit tier. Empty map = no data.
    std::map<uint8, uint32> GetBisFor(uint16 autoGearScoreLimit, uint8 cls, uint8 tab, uint8 faction) const;

    // Closest-lower fallback: scan ilvls down from requested to (requested - maxDrop), return first non-empty set.
    // outResolved receives the matched ilvl (0 if nothing matched within the window).
    std::map<uint8, uint32> GetBisForNearest(uint16 requestedIlvl, uint16 maxDrop, uint8 cls, uint8 tab,
                                             uint8 faction, uint16* outResolved = nullptr) const;

    // ---------------------------------------------------------------------
    // Strict BiS mode (randombots)
    // ---------------------------------------------------------------------
    // Resolves class / spec tab (including the Druid Bear sentinel tab) and faction
    // for a given bot, then returns the slot -> itemId set for the requested tier.
    std::map<uint8, uint32> ResolveForBot(Player* bot, uint16 requestedIlvl, uint16 maxDrop = 0,
                                          uint16* outResolved = nullptr) const;

    // The tier (auto_gear_score_limit) strict mode must use for this bot, or 0 when
    // strict mode does not apply (feature off, not a randombot, level too low, PvP spec).
    uint16 GetStrictBisTier(Player* bot) const;

    // True when this bot is currently under strict BiS rules AND a non-empty list exists.
    bool IsStrictBisBot(Player* bot) const;

    // The active BiS set for a strict-mode bot. Empty when strict mode does not apply.
    std::map<uint8, uint32> GetStrictBisSet(Player* bot) const;

    // True when itemId is the BiS item of one of this bot's slots. outSlot receives that slot.
    bool IsStrictBisItem(Player* bot, uint32 itemId, uint8* outSlot = nullptr) const;

private:
    BisListMgr() = default;

    static uint16 MakeKey(uint8 cls, uint8 tab) { return (uint16(cls) << 8) | tab; }

    // autoGearScoreLimit -> (cls<<8|tab) -> faction (0/1/2) -> slot -> itemId
    std::map<uint16, std::map<uint16, std::map<uint8, std::map<uint8, uint32>>>> _bis;
};

#define sBisListMgr BisListMgr::instance()

#endif
