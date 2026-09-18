/*
 * mod-playerbots-bis — released under GNU GPL v2, matching mod-playerbots and
 * AzerothCore. Redistribute/modify under version 2 of the License, or (at your
 * option) any later version.
 */

#include "BisItemUsageValue.h"
#include "BisPriorityMgr.h"
#include "Item.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "PlayerbotAI.h"
#include <sstream>
#include <string>

namespace
{
    // Rings and trinkets have two interchangeable slots. The list names one of
    // them; an item is an upgrade as soon as it beats the weaker of the pair.
    uint8 PairedSlot(uint8 slot)
    {
        switch (slot)
        {
            case EQUIPMENT_SLOT_FINGER1:  return EQUIPMENT_SLOT_FINGER2;
            case EQUIPMENT_SLOT_FINGER2:  return EQUIPMENT_SLOT_FINGER1;
            case EQUIPMENT_SLOT_TRINKET1: return EQUIPMENT_SLOT_TRINKET2;
            case EQUIPMENT_SLOT_TRINKET2: return EQUIPMENT_SLOT_TRINKET1;
            default:                      return 0xFF;
        }
    }

    // The BiS layer, applied on top of whatever playerbots already decided.
    //
    // Three branches, in order:
    //   1. the item is this bot's best in slot  -> announce it and take it
    //   2. it is somebody else's best in slot   -> leave it to them
    //   3. it belongs to no list                -> playerbots' own verdict stands
    //
    // Branch 3 is the common case and is exactly the original behaviour: the
    // stat-weight comparison against the equipped item, with its 1.1x threshold.
    // This layer only ever overrides that verdict for items the lists know, at
    // any level - a level 30 bot recognises its level 60 best in slot just as
    // well as a capped one.
    ItemUsage ApplyBisPolicy(PlayerbotAI* botAI, Player* bot, uint32 itemId, ItemUsage base)
    {
        if (!sBisPriorityMgr->AppliesTo(bot))
            return base;

        ItemTemplate const* proto = sObjectMgr->GetItemTemplate(itemId);
        if (!proto)
            return base;

        // Only gear is arbitrated. Quest items, ammo, reagents, consumables and
        // every vendor / auction / disenchant verdict pass through untouched.
        if (proto->Class != ITEM_CLASS_WEAPON && proto->Class != ITEM_CLASS_ARMOR)
            return base;

        uint8 slot = 0;
        uint16 tierId = 0;
        uint32 const priority = sBisPriorityMgr->GetItemPriority(bot, itemId, &slot, &tierId);

        // ── Branch 2 ──────────────────────────────────────────────────────────
        if (!priority)
        {
            if (sBisPriorityMgr->LeaveOtherSpecsBis() && sBisPriorityMgr->IsBisForAnotherSpec(bot, itemId))
                return ITEM_USAGE_NONE;

            return base;  // ── Branch 3: nobody's list, original logic wins
        }

        // ── Branch 1 ──────────────────────────────────────────────────────────
        // Wanting an item the bot cannot physically wear would make it roll on
        // something it can never equip, so the class/race/skill/level gate is
        // re-checked here: the forced verdict below bypasses the one playerbots
        // applies upstream.
        if (bot->BotCanUseItem(proto) != EQUIP_ERR_OK)
            return base;

        uint32 wornPriority = sBisPriorityMgr->GetWornPriority(bot, slot);
        uint8 targetSlot = slot;

        if (uint8 const paired = PairedSlot(slot); paired != 0xFF)
        {
            uint32 const pairedPriority = sBisPriorityMgr->GetWornPriority(bot, paired);
            if (pairedPriority < wornPriority)
            {
                wornPriority = pairedPriority;
                targetSlot = paired;
            }
        }

        // Already wearing this piece, or something higher up the ladder.
        if (priority <= wornPriority)
            return ITEM_USAGE_NONE;

        if (sBisPriorityMgr->AnnounceOwnBis() && botAI)
        {
            std::string const tierName = sBisPriorityMgr->GetTierName(tierId);
            std::ostringstream out;
            out << "|cff1eff00" << proto->Name1 << "|r - c'est mon BiS";
            if (!tierName.empty())
                out << " (" << tierName << ")";
            botAI->TellMaster(out.str());
        }

        return bot->GetItemByPos(INVENTORY_SLOT_BAG_0, targetSlot) ? ITEM_USAGE_REPLACE : ITEM_USAGE_EQUIP;
    }
}

ItemUsage BisItemUsageValue::Calculate()
{
    ItemUsage const base = ItemUsageValue::Calculate();
    return ApplyBisPolicy(botAI, bot, GetItemIdFromQualifier().itemId, base);
}

ItemUsage BisItemUpgradeValue::Calculate()
{
    ItemUsage const base = ItemUpgradeValue::Calculate();
    return ApplyBisPolicy(botAI, bot, GetItemIdFromQualifier().itemId, base);
}
