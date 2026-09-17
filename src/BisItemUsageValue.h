/*
 * mod-playerbots-bis — released under GNU GPL v2, matching mod-playerbots and
 * AzerothCore. Redistribute/modify under version 2 of the License, or (at your
 * option) any later version.
 */

#ifndef MOD_PLAYERBOTS_BIS_ITEMUSAGEVALUE_H
#define MOD_PLAYERBOTS_BIS_ITEMUSAGEVALUE_H

#include "ItemUsageValue.h"

// Replacement for playerbots' "item usage" value.
//
// The engine resolves values by name, and SharedNamedObjectContextList::Add()
// overwrites a creator when the same name is registered again, so registering
// these after playerbots' own ValueContext puts them in charge of every equip
// and loot-roll decision without touching mod-playerbots itself.
//
// Both keep the original verdict for everything that is not weapon or armor
// (quest items, ammo, reagents, consumables, vendor/AH/disenchant decisions);
// the BiS ladder only arbitrates gear.
class BisItemUsageValue : public ItemUsageValue
{
public:
    BisItemUsageValue(PlayerbotAI* botAI) : ItemUsageValue(botAI, "item usage") {}

    ItemUsage Calculate() override;
};

// Same policy for "item upgrade", which EquipAction consults when deciding
// whether to put a looted or traded item on.
class BisItemUpgradeValue : public ItemUpgradeValue
{
public:
    BisItemUpgradeValue(PlayerbotAI* botAI) : ItemUpgradeValue(botAI, "item upgrade") {}

    ItemUsage Calculate() override;
};

#endif
