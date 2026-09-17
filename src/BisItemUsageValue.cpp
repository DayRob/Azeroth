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

    bool IsEquipVerdict(ItemUsage usage)
    {
        return usage == ITEM_USAGE_EQUIP || usage == ITEM_USAGE_REPLACE || usage == ITEM_USAGE_BAD_EQUIP ||
               usage == ITEM_USAGE_BROKEN_EQUIP;
    }

    // Shared policy for both values. `base` is whatever playerbots would have
    // answered; this only ever narrows it for gear.
    ItemUsage ApplyBisPolicy(Player* bot, uint32 itemId, ItemUsage base)
    {
        if (!sBisPriorityMgr->AppliesTo(bot))
            return base;

        ItemTemplate const* proto = sObjectMgr->GetItemTemplate(itemId);
        if (!proto)
            return base;

        // Only gear is arbitrated by the ladder.
        if (proto->Class != ITEM_CLASS_WEAPON && proto->Class != ITEM_CLASS_ARMOR)
            return base;

        uint8 slot = 0;
        uint32 const priority = sBisPriorityMgr->GetItemPriority(bot, itemId, &slot);

        if (!priority)
        {
            // Not on this spec's list. Never equipped, never rolled for; the
            // vendor / auction / disenchant verdicts are left untouched so the
            // bot still handles the item sensibly once it owns it.
            if (sBisPriorityMgr->BlockOffListRolls() && IsEquipVerdict(base))
                return ITEM_USAGE_NONE;

            return base;
        }

        // On the list. Compare against the slot it targets, and for rings and
        // trinkets against the weaker half of the pair.
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

        if (priority <= wornPriority)
            return ITEM_USAGE_NONE;  // already wearing this, or something higher on the ladder

        return bot->GetItemByPos(INVENTORY_SLOT_BAG_0, targetSlot) ? ITEM_USAGE_REPLACE : ITEM_USAGE_EQUIP;
    }
}

ItemUsage BisItemUsageValue::Calculate()
{
    ItemUsage const base = ItemUsageValue::Calculate();
    return ApplyBisPolicy(bot, GetItemIdFromQualifier().itemId, base);
}

ItemUsage BisItemUpgradeValue::Calculate()
{
    ItemUsage const base = ItemUpgradeValue::Calculate();
    return ApplyBisPolicy(bot, GetItemIdFromQualifier().itemId, base);
}
