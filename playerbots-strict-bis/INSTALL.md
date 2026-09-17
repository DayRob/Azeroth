# Tuto d'implémentation — mode BiS strict pour randombots

Cible : serveur AzerothCore local + mod-playerbots, config Vanilla (RandomBotMaxLevel = 60).
Patch validé contre `mod-playerbots/mod-playerbots` @ `b6696bd` (`git apply --check` OK).

---

## Étape 0 — Sauvegarde

```bash
mysqldump -u acore -p acore_playerbots > ~/backup_playerbots.sql
mysqldump -u acore -p acore_characters  > ~/backup_characters.sql
cp /chemin/vers/etc/playerbots.conf ~/playerbots.conf.bak
```

Le mode strict **détruit** l'équipement hors liste des randombots concernés. C'est voulu, mais c'est
irréversible bot par bot.

---

## Étape 1 — Appliquer le patch au module

```bash
cd /chemin/vers/azerothcore/modules/mod-playerbots
git status                 # doit être propre
git checkout -b strict-bis
git apply --check /chemin/vers/0001-randombots-strict-bis.patch   # doit ne rien afficher
git apply         /chemin/vers/0001-randombots-strict-bis.patch
git add -A && git commit -m "Strict BiS mode for randombots"
```

Si `git apply --check` râle, c'est que ton clone n'est pas sur `b6696bd` : fais un
`git apply -3` (merge à 3 points) ou rebase ton module sur la version amont.

Fichiers touchés :

| Fichier | Rôle |
|---|---|
| `src/Mgr/Item/BisListMgr.{h,cpp}` | résolution classe/spé/faction + helpers mode strict |
| `src/Bot/Factory/PlayerbotFactory.{h,cpp}` | `ApplyStrictBisEquipment()` + branchements |
| `src/Ai/Base/Value/ItemUsageValue.cpp` | verdict équiper/roll basé sur la liste |
| `src/Ai/Base/Actions/LootRollAction.cpp` | PASS sur les jetons de tier |
| `src/Ai/Base/Actions/AutoMaintenanceOnLevelupAction.cpp` | ré-application au levelup |
| `src/PlayerbotAIConfig.{h,cpp}` | 5 nouvelles options |
| `conf/playerbots.conf.dist` | documentation des options |

---

## Étape 2 — Recompiler

```bash
cd /chemin/vers/azerothcore/build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo   # seulement si tu as ajouté/supprimé des fichiers
make -j$(nproc)
make install
```

Aucun fichier source n'est **ajouté** par le patch, donc un simple `make -j$(nproc)` suffit
normalement. C'est l'étape qui valide le patch : il n'a pas été compilé à l'écriture.

---

## Étape 3 — Vérifier la table BiS en base

Le patch ne fournit aucun SQL : il consomme la table existante.

```sql
USE acore_playerbots;
SELECT auto_gear_score_limit AS ilvl, phase, COUNT(*) AS lignes
FROM playerbots_bis_gear
WHERE auto_gear_score_limit IN (66,76,78,83,88,92)
GROUP BY 1,2 ORDER BY 1;
```

Si la table n'existe pas : tu as `Playerbots.Updates.EnableDatabases = 1`, donc le worldserver
applique `data/sql/playerbots/updates/2026_04_28_00_playerbots_bis_gear.sql` au démarrage. Sinon,
importe-le à la main.

Paliers Vanilla disponibles :

| ilvl | Contenu |
|---|---|
| 66 | Tier 1 |
| 76 | Tier 2 |
| **78** | **Phase 1 — MC / Onyxia / ZG** |
| 83 | Phase 2 — BWL |
| 88 | Phase 2.5 — AQ40 |
| 92 | Phase 3 — Naxx40 |

---

## Étape 4 — Modifier `playerbots.conf`

Ajoute ce bloc (les options n'existent pas dans ta conf actuelle) :

```ini
AiPlayerbot.RandomBotStrictBis = 1
AiPlayerbot.RandomBotStrictBisIlvl = 78          # Phase 1 Vanilla
AiPlayerbot.RandomBotStrictBisMinLevel = 0       # 0 = RandomBotMaxLevel (60)
AiPlayerbot.RandomBotStrictBisClearUncovered = 1
AiPlayerbot.RandomBotStrictBisGrantReputation = 1
```

Et **modifie** ces lignes existantes :

```ini
AiPlayerbot.RandomGearQualityLimit = 4    # était 3 : sinon le fallback autogear plafonne au rare
AiPlayerbot.AutoGearQualityLimit = 4      # était 3 : requis si tu veux aussi "autogear bis"
AiPlayerbot.AutoGearBisCommand = 1        # était 0 : active la commande manuelle (optionnel)
```

Laisse tel quel (déjà compatible) : `EquipAndSpecPersistence = 1`, `AutoUpgradeEquip = 0`,
`LootNeedRollLevel = 1`, `LootGreedRollLevel = 0`. Le patch passe **avant** la persistance et
**avant** `AutoUpgradeEquip`, donc ces réglages ne bloquent plus la ré-application de la liste.

---

## Étape 5 — Redémarrer et forcer la ré-application

```
# dans la console worldserver, ou en jeu en GM :
.playerbots rndbot init
```

`init` lance un `RandomizeFirst` (randomize complet) sur **tous les randombots connectés**, ce qui
déclenche `ApplyStrictBisEquipment`. Pour un seul bot : `.playerbots rndbot init NomDuBot`.

Sans cette commande, les bots déjà en jeu ne basculeront que lors de leur prochaine
re-randomisation périodique (entre `MinRandomBotRandomizeTime` = 2 h et
`MaxRandomBotRandomizeTime` = 14 j chez toi).

---

## Étape 6 — Vérifier

1. Cible un randombot niveau 60 en jeu, `.pinfo` ou inspecte-le : chaque slot doit correspondre à
   une ligne de la table.
2. Requête de contrôle pour un bot précis :

```sql
SELECT g.slot, g.item_id, g.item_name, g.phase
FROM acore_playerbots.playerbots_bis_gear g
WHERE g.class = <classe> AND g.tab = <spé> AND g.auto_gear_score_limit = 78
ORDER BY g.slot;
```

3. Groupe-toi avec un bot, fais tomber un épique hors liste : il doit **PASS**, pas NEED.

---

## Point de blocage à connaître : 4 spés n'ont aucune ligne BiS en Vanilla

La table ne couvre pas tout. En Vanilla (ilvl 66 → 92), les combinaisons présentes sont :

| Classe | Spés couvertes | Spés **absentes** |
|---|---|---|
| Guerrier (1) | fury (1), prot (2) | **arms (0)** |
| Paladin (2) | 0, 1, 2 | — |
| Chasseur (3) | 0, 1, 2 | — |
| Voleur (4) | combat (1) | **assassination (0), subtlety (2)** |
| Prêtre (5) | holy (1), shadow (2) | **discipline (0)** |
| Chaman (7) | 0, 1, 2 | — |
| Mage (8) | 0, 1, 2 | — |
| Démoniste (9) | 0, 1, 2 | — |
| Druide (11) | balance (0), cat (1), resto (2), bear (10) | — |

Les bots dans une spé absente **gardent l'ancienne logique** (repli propre, pas de bot à poil).
Vu tes probabilités actuelles (`RandomClassSpecProb`), ça touche beaucoup de monde :
voleur assassination 45 %, prêtre disc 40 %, guerrier arms 20 %, voleur subtlety 10 %.

Deux solutions :

**A. Rediriger les spés non couvertes** (le plus rapide) — dans `playerbots.conf` :

```ini
AiPlayerbot.RandomClassSpecProb.1.0 = 0    # arms -> 0
AiPlayerbot.RandomClassSpecProb.1.1 = 60   # fury
AiPlayerbot.RandomClassSpecProb.1.2 = 40   # prot

AiPlayerbot.RandomClassSpecProb.4.0 = 0    # assassination -> 0
AiPlayerbot.RandomClassSpecProb.4.1 = 100  # combat
AiPlayerbot.RandomClassSpecProb.4.2 = 0    # subtlety -> 0

AiPlayerbot.RandomClassSpecProb.5.0 = 0    # disc -> 0
AiPlayerbot.RandomClassSpecProb.5.1 = 60   # holy
AiPlayerbot.RandomClassSpecProb.5.2 = 40   # shadow
```

**B. Ajouter les lignes manquantes** dans `playerbots_bis_gear` :

```sql
INSERT INTO playerbots_bis_gear
(class, tab, slot, faction, auto_gear_score_limit, item_id, phase, class_name, spec_name, slot_name, faction_name, item_name)
VALUES
(1, 0, 0, 0, 78, 16963, 'Phase 1', 'Warrior', 'Arms', 'Head', 'Both', 'Helm of Wrath');
-- slots : head=0 neck=1 shoulders=2 chest=4 waist=5 legs=6 feet=7 wrists=8 hands=9
--         finger1=10 finger2=11 trinket1=12 trinket2=13 back=14 mainhand=15 offhand=16 ranged=17
-- faction : 0=Both, 1=Alliance, 2=Horde (une ligne faction-spécifique écrase la ligne Both)
```

---

## Autres limites

- **Bots en leveling** : les listes BiS ne contiennent que du stuff niveau 60. Seuls les bots au cap
  passent en strict (`RandomBotStrictBisMinLevel`). Avec tes brackets de niveau actifs (11 % des
  bots dans le bracket 60), ça concerne ~55 bots sur 500.
- **Specs PvP** : exclues (`IsSpecPvp`), les listes sont PvE.
- **Jetons de tier** : les bots strict PASS dessus (ils ne peuvent pas les échanger). Bon pour toi
  en groupe, mais ils ne progresseront jamais « naturellement » vers leur BiS — c'est la table qui
  les habille.

---

## Rollback

```ini
AiPlayerbot.RandomBotStrictBis = 0
```

puis `.playerbots rndbot reload` (relit la conf sans redémarrer) et `.playerbots rndbot init`.
Pour retirer complètement le code : `git revert` / `git checkout` sur le module + recompilation.
