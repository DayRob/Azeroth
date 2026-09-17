# Randombots : itémisation BiS stricte (mod-playerbots)

Analyse et patch basés sur `mod-playerbots/mod-playerbots` @ `b6696bd`.

## 1. Où se trouve réellement la logique BiS

La table `playerbots_bis_gear` n'est lue qu'à **un seul endroit** :

| Élément | Fichier |
|---|---|
| Chargement de la table | `src/Mgr/Item/BisListMgr.cpp` → `LoadAll()`, appelé par `PlayerbotAIConfig.cpp:772` |
| Unique consommateur | `src/Ai/Base/Actions/TrainerAction.cpp` → `BisGearAction::Execute()` (commande de chat `autogear bis`) |

`BisGearAction` est enregistrée comme `ChatCommandTrigger` (`ChatActionContext.h:143`,
`ChatTriggerContext.h:69`) : elle ne peut être déclenchée que par un **maître qui parle au bot**.
Aucun code du cycle de vie autonome des randombots ne l'appelle. C'est la cause racine :
**la logique BiS n'existe pas dans le chemin d'équipement automatique**, quel que soit le type de bot.

## 2. Ce qui décide vraiment de l'équipement et des rolls

Tous les types de bots (randombot, addclass, altbot) partagent le même moteur :

- `PlayerbotFactory::InitEquipment()` (`PlayerbotFactory.cpp:2280`) — sélection par score
  (`StatsWeightCalculator`), quality/ilvl caps, `skipProb = 25 %` aléatoire, et en mode incrémental
  la règle « remplace seulement si `newScore >= 1.2 * oldScore` ».
- `ItemUsageValue::QueryItemUsageForEquip()` (`ItemUsageValue.cpp:161`) — verdict
  EQUIP / REPLACE / BAD_EQUIP basé sur `itemScore > oldScore * EquipUpgradeThreshold`.
  Utilisé par `ItemUsageValue` (« item usage ») **et** `ItemUpgradeValue` (« item upgrade »).
- `LootRollAction::Execute()` (`LootRollAction.cpp:16`) — NEED si l'usage vaut
  EQUIP/REPLACE/BAD_EQUIP, sinon GREED/PASS.

Chemins d'entrée par type de bot :

| Type | Équipement initial | Dérive ensuite |
|---|---|---|
| Randombot | `Randomize()` → `InitEquipment()` | `AutoMaintenanceOnLevelupAction::AutoUpgradeEquip()` → `InitEquipment(true)` ; `EquipUpgradesPacketAction` sur loot ; rolls |
| AddClass bot | `.bot init` → `Randomize()`/`AutoGear()` | idem, mais peut recevoir `autogear bis` du maître |
| Altbot | `AutoGear()` / `autogear` | `AutoEquipUpgradeLoot` + `EquipUpgradeThreshold` |

Autrement dit, la différence entre types de bots ne vient pas d'un algorithme différent, mais de
**qui peut envoyer une commande** : seuls les bots ayant un maître reçoivent `autogear bis`.

## 3. Pourquoi les phases se mélangent

- `BisListMgr::GetBisForNearest()` accepte un `maxDrop` (20 dans la commande de chat) et descend
  jusqu'à 20 ilvl plus bas → un palier voisin peut être servi.
- `BisGearAction` lance d'abord un **autogear complet** puis n'écrase que les slots couverts par la
  table : les slots non couverts gardent un item hors table.
- Le chemin automatique n'utilise aucun palier : il prend le meilleur score sous `RandomGearScoreLimit`,
  d'où des pièces de n'importe quelle phase.

## 4. Le patch

`0001-randombots-strict-bis.patch` (à appliquer sur le clone du module, puis recompiler) :

- `BisListMgr` : résolution classe/spé/faction/tab (sentinelle Bear = 10) + helpers
  `GetStrictBisTier()`, `GetStrictBisSet()`, `IsStrictBisItem()`. Palier **exact** (`maxDrop = 0`).
- `PlayerbotFactory::ApplyStrictBisEquipment()` : appelé en tête de `InitEquipment()`, court-circuite
  toute la sélection par score. Couvre donc l'init, la re-randomisation et le levelup.
- `ItemUsageValue::QueryItemUsageForEquip()` : en mode strict, seule l'appartenance à la liste
  produit EQUIP/REPLACE. Tout le reste → `ITEM_USAGE_NONE` (donc jamais équipé, jamais NEED).
- `LootRollAction` : PASS sur les jetons de tier (un bot ne peut pas les échanger).

Config ajoutée (voir `conf/playerbots.conf.dist`) :

```
AiPlayerbot.RandomBotStrictBis = 1
AiPlayerbot.RandomBotStrictBisIlvl = 78        # exemple : Vanilla Phase 1 (MC/Ony/ZG)
AiPlayerbot.RandomBotStrictBisMinLevel = 0     # 0 = RandomBotMaxLevel
AiPlayerbot.RandomBotStrictBisClearUncovered = 1
AiPlayerbot.RandomBotStrictBisGrantReputation = 1
```

## 5. Limites à connaître

- Les tables BiS ne contiennent que du stuff de niveau max par palier : les bots en cours de
  leveling gardent l'ancienne logique (`RandomBotStrictBisMinLevel`).
- Avec `RandomGearQualityLimit = 3` et `AutoGearQualityLimit = 3`, les épiques BiS seraient refusés
  par l'autogear classique ; le mode strict équipe directement depuis la table et ignore ce cap,
  mais passez `AutoGearQualityLimit = 4` si vous utilisez aussi `autogear bis`.
- Les specs PvP (`IsSpecPvp`) sont exclues : les listes sont PvE.
- Patch non compilé ici (AzerothCore absent de cet environnement) : à valider par un build.
