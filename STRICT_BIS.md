# mod-playerbots — fork « BiS strict » pour randombots

Ce dépôt est une **copie modifiée de [mod-playerbots](https://github.com/mod-playerbots/mod-playerbots)**
(base : commit `b6696bd`), pas un module additionnel. Il s'installe **à la place** du module
mod-playerbots original.

## Ce que le fork ajoute

Un mode dans lequel les randombots suivent **strictement** la table `playerbots_bis_gear` de leur
classe/spé pour un palier de progression donné :

- équipement pris uniquement dans la table, au **palier exact** (aucun mélange de phases)
- aucun item hors table n'est équipé
- NEED uniquement sur les items de la liste, PASS sur tout le reste
- PASS sur les jetons de tier (un bot ne peut pas les échanger)

Hors mode strict, le comportement du module est **inchangé**. Les bots addclass et les altbots ne
sont jamais concernés : ils gardent l'itémisation par poids de stats et la commande `autogear bis`.

## Activation

```ini
AiPlayerbot.RandomBotStrictBis = 1
AiPlayerbot.RandomBotStrictBisIlvl = 78          # Vanilla Phase 1 (MC / Onyxia / ZG)
AiPlayerbot.RandomBotStrictBisMinLevel = 0       # 0 = RandomBotMaxLevel
AiPlayerbot.RandomBotStrictBisClearUncovered = 1
AiPlayerbot.RandomBotStrictBisGrantReputation = 1
```

## Documentation

| Fichier | Contenu |
|---|---|
| [`docs/strict-bis/INSTALL.md`](docs/strict-bis/INSTALL.md) | procédure d'installation pas à pas |
| [`docs/strict-bis/ANALYSE.md`](docs/strict-bis/ANALYSE.md) | pourquoi le module ne respectait pas la table BiS |
| [`docs/strict-bis/0001-randombots-strict-bis.patch`](docs/strict-bis/0001-randombots-strict-bis.patch) | le diff seul, pour l'appliquer sur un autre clone |

## Suivi amont

Ce dépôt est une copie à plat : il ne partage pas l'historique git de mod-playerbots. Pour récupérer
une mise à jour du module, il faut repartir d'un clone amont à jour et y réappliquer
`docs/strict-bis/0001-randombots-strict-bis.patch`.
