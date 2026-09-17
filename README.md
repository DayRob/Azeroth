# mod-playerbots-bis

Extension de [mod-playerbots](https://github.com/mod-playerbots/mod-playerbots) pour AzerothCore.

Les randombots s'équipent et rollent en suivant une **échelle de progression BiS** par
classe et par spécialisation, au lieu de la règle « ce nouvel objet vaut 1,1 fois mieux
que l'ancien ». Un objet absent de la liste de leur spé n'est ni équipé, ni convoité.

**Ce module ne modifie pas mod-playerbots.** Il s'installe à côté, comme n'importe quel
module AzerothCore, et vos modifications locales de mod-playerbots restent intactes.

---

## Le principe

Chaque objet de la table appartient à un **palier** (`tier_id`). Un palier plus haut
l'emporte toujours sur un palier plus bas, quelles que soient les statistiques :

```
Vanilla Pre-Raid  <  MC/Ony  <  BWL  <  ZG  <  AQ20  <  AQ40  <  Naxx40
                  <  TBC Pre-Raid  <  Karazhan  <  SSC/TK  <  Hyjal/BT  <  Sunwell
                  <  WotLK Pre-Raid  <  Naxx  <  Ulduar  <  ToC  <  ICC  <  Ruby Sanctum
```

À l'intérieur d'un même palier et d'un même emplacement, la colonne `rank` ordonne les
choix : 1 est le meilleur, puis 2, puis 3. Un guerrier Protection préférera donc toujours
sa pièce de Blackwing Lair à sa pièce de Molten Core, et parmi les pièces de Molten Core
celle de rank 1.

Un bot ne roll que sur ce qui peut le faire monter dans cette échelle. Tout le reste :
PASS.

## Ce que le module couvre — et ce qu'il ne couvre pas

| Décision | Gouvernée ? |
|---|---|
| Roll Need/Greed/Pass en groupe | Oui |
| Équipement d'un objet ramassé, échangé ou reçu en quête | Oui |
| Génération d'équipement au randomize d'un bot | **Non** — reste aux poids de stats |

La génération (`PlayerbotFactory::InitEquipment`) est un appel direct dans
mod-playerbots, pas un objet du registre : aucun module ne peut s'y substituer. En
pratique cela compte peu, car c'est la dérive au fil du loot qui éloigne les bots de
leur BiS, pas leur équipement initial.

## Comment ça marche

Le moteur de mod-playerbots résout ses valeurs **par nom**, et
`SharedNamedObjectContextList::Add()` *assigne* dans sa table de créateurs au lieu d'y
insérer. Le dernier contexte enregistré pour un nom l'emporte donc. Ce module enregistre
ses propres `"item usage"` et `"item upgrade"` au premier tick du monde — après
mod-playerbots, et avant la connexion du moindre bot.

Les deux valeurs délèguent d'abord à celles d'origine, puis ne restreignent le verdict
que pour les armes et armures. Tout le reste — quêtes, munitions, consommables, décisions
de vente, d'hôtel des ventes et de désenchantement — passe inchangé.

## Installation

> **Le nom du dossier est significatif.** AzerothCore dérive le point d'entrée du module de
> son nom de dossier : il doit être `modules/mod-playerbots-bis`. Cloné sous un autre nom, le
> module compile puis ne fait rien.

```bash
cd /chemin/vers/azerothcore/modules
git clone https://github.com/DayRob/Azeroth mod-playerbots-bis
cd ../build && cmake .. && make -j$(nproc) && make install
```

mod-playerbots doit être présent et activé. Importez ensuite les deux tables dans votre
base **world** si votre version d'AzerothCore n'applique pas automatiquement le SQL des
modules :

```bash
mysql -u acore -p acore_world < modules/mod-playerbots-bis/data/sql/db-world/base/01_playerbots_bis_tier.sql
mysql -u acore -p acore_world < modules/mod-playerbots-bis/data/sql/db-world/base/02_playerbots_bis_item.sql
```

Copiez `conf/playerbots_bis.conf.dist` vers `etc/playerbots_bis.conf` (le build le dépose
à côté de `playerbots.conf.dist`) et mettez `PlayerbotsBis.Enable = 1`.

Au démarrage, le worldserver affiche une de ces trois lignes :

```
[mod-playerbots-bis] Active - BiS ladder governs bot gear and loot rolls (18 tiers, 6323 items)
[mod-playerbots-bis] Dormant (PlayerbotsBis.Enable = 0) - ...
[mod-playerbots-bis] Tables unavailable - bot itemisation left untouched
```

La troisième signifie que le SQL n'a pas été importé. Dans ce cas le module reste inerte
même avec `Enable = 1`, et un `.playerbotsbis reload` ne suffira pas : il faut importer les
tables puis redémarrer.

## Configuration essentielle

```ini
PlayerbotsBis.Enable = 1
PlayerbotsBis.MaxTier = 20          # cale les bots sur la phase de ton serveur
PlayerbotsBis.BlockOffListRolls = 1 # PASS sur tout ce qui n'est pas dans la liste
```

Le fichier `.conf.dist` documente chaque réglage et donne la table des `tier_id`.

### mod-individual-progression

`PlayerbotsBis.UseIndividualProgression = 1` limite chaque bot aux paliers que **son
propre personnage** a débloqués, via la colonne `required_progression` de
`playerbots_bis_tier`. Un bot qui n'a pas fini Molten Core ne convoitera pas le stuff de
Blackwing Lair.

Il n'y a aucune dépendance de compilation : l'état est lu via les quêtes cachées
`66000 + état` dans lesquelles mod-individual-progression stocke la progression. Laissez
le réglage à 0 si vous n'avez pas ce module.

### Un piège de configuration côté mod-playerbots

Avec `AiPlayerbot.LootNeedRollLevel = 1`, mod-playerbots convertit tout vote NEED en
GREED avant de l'émettre — les bots ne rollent alors jamais Need, y compris sur leur BiS.
Passez ce réglage à `2` pour que les bots réservent un vrai Need à leurs pièces de liste.

## Les tables

`playerbots_bis_tier` définit l'échelle, `playerbots_bis_item` les objets. Les en-têtes
des deux fichiers SQL documentent chaque colonne : numéros de spé par classe, énumération
des emplacements, sentinelle 10 du druide ours, lignes de faction.

Les lignes fournies sont converties depuis la table `playerbots_bis_gear` de
mod-playerbots — identifiants et noms d'objets d'origine — réparties sur l'échelle de
paliers. `tools/convert_playerbots_bis_gear.py` permet de régénérer le fichier.

**Ce jeu de données est un point de départ, pas une liste BiS de référence.** Lacunes
connues :

- Paliers vides : Vanilla Pre-Raid (10), Zul'Gurub (40), AQ20 (50), WotLK Pre-Raid (130),
  Ruby Sanctum (180).
- Sur les quatre paliers Vanilla renseignés, aucune ligne pour : Guerrier Armes, Voleur
  Assassinat, Voleur Subtilité, Prêtre Discipline.

Une spé sans aucune ligne au palier courant retombe proprement sur la logique d'origine
de mod-playerbots — le bot n'est jamais laissé nu.

Après édition des tables, `.playerbotsbis reload` les recharge sans redémarrer. La même
commande prend aussi en compte un changement de `PlayerbotsBis.Enable` ou de
`PlayerbotsBis.MaxTier` : le module s'enregistre auprès du moteur dès le premier tick du
monde, même désactivé, précisément pour pouvoir être basculé à chaud.

## Licence

GNU GPL v2, comme AzerothCore et mod-playerbots.
