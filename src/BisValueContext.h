/*
 * mod-playerbots-bis — released under GNU GPL v2, matching mod-playerbots and
 * AzerothCore. Redistribute/modify under version 2 of the License, or (at your
 * option) any later version.
 */

#ifndef MOD_PLAYERBOTS_BIS_VALUECONTEXT_H
#define MOD_PLAYERBOTS_BIS_VALUECONTEXT_H

#include "BisItemUsageValue.h"
#include "NamedObjectContext.h"

// Registering these two names again replaces playerbots' creators for them:
// SharedNamedObjectContextList::Add() assigns into its creator map rather than
// inserting, so the last context added for a name wins. Nothing else in the
// engine is touched.
class BisValueContext : public NamedObjectContext<UntypedValue>
{
public:
    BisValueContext()
    {
        creators["item usage"] = &BisValueContext::item_usage;
        creators["item upgrade"] = &BisValueContext::item_upgrade;
    }

private:
    static UntypedValue* item_usage(PlayerbotAI* botAI) { return new BisItemUsageValue(botAI); }
    static UntypedValue* item_upgrade(PlayerbotAI* botAI) { return new BisItemUpgradeValue(botAI); }
};

#endif
