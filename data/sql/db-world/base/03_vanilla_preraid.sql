-- mod-playerbots-bis : palier 10 (Vanilla Pre-Raid).
--
-- Les identifiants d'objets ne sont PAS ecrits en dur : chaque ligne est resolue
-- par nom contre item_template au moment de l'import. Un nom errone n'insere
-- simplement rien, au lieu de faire equiper un mauvais objet a un bot. La requete
-- de verification en fin de fichier liste les noms non resolus.
--
-- Les noms sont les noms ANGLAIS d'item_template. Si ta base world est localisee,
-- item_template garde quand meme les noms anglais (les traductions vivent dans
-- item_template_locale), donc rien a changer.
--
-- rank : 1 = premier choix, 2 = alternative, 3 = depannage. Le bot prend la
-- meilleure ligne qu'il possede. Un palier superieur bat toujours ce palier-ci.
--
-- Source : guides Best-in-Slot Pre-Raid de Wowhead Classic.
-- Contenu actuel : Guerrier Fureur (classe 1, spe 1), 56 lignes, toutes verifiees
-- contre item_template sur un serveur AzerothCore reel.

DROP TEMPORARY TABLE IF EXISTS `bis_seed`;
CREATE TEMPORARY TABLE `bis_seed` (
    `class`     TINYINT UNSIGNED NOT NULL,
    `spec`      TINYINT UNSIGNED NOT NULL,
    `slot`      TINYINT UNSIGNED NOT NULL,
    `faction`   TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `rank`      TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `item_name` VARCHAR(100) NOT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4;

-- Note collation : item_template.name est en utf8mb4_unicode_ci sur AzerothCore,
-- alors qu'une table creee sans COLLATE explicite herite du defaut du serveur
-- (utf8mb4_0900_ai_ci sur MySQL 8 et 9). Comparer les deux directement leve
-- ERROR 1267 "Illegal mix of collations". Les deux jointures ci-dessous forcent
-- donc explicitement la meme collation des deux cotes, ce qui rend le fichier
-- portable quelle que soit la configuration du serveur.

-- =====================================================================
-- Guerrier Fureur (classe 1, spe 1)
-- =====================================================================
INSERT INTO `bis_seed` (`class`, `spec`, `slot`, `faction`, `rank`, `item_name`) VALUES
-- Tete (0)
(1, 1,  0, 0, 1, 'Lionheart Helm'),
(1, 1,  0, 0, 2, 'Helm of the Executioner'),
(1, 1,  0, 0, 3, 'Eye of Rend'),
(1, 1,  0, 0, 3, 'Mask of the Unforgiven'),
-- Cou (1)
(1, 1,  1, 0, 1, 'Mark of Fordring'),
(1, 1,  1, 0, 2, 'Pendant of Celerity'),
(1, 1,  1, 0, 3, 'Imperial Jewel'),
-- Epaules (2)
(1, 1,  2, 0, 1, 'Truestrike Shoulders'),
(1, 1,  2, 0, 2, 'Black Dragonscale Shoulders'),
(1, 1,  2, 0, 3, 'Wyrmhide Spaulders'),
-- Torse (4)
(1, 1,  4, 0, 1, 'Savage Gladiator Chain'),
(1, 1,  4, 0, 2, 'Cadaverous Armor'),
(1, 1,  4, 0, 3, 'Tombstone Breastplate'),
(1, 1,  4, 0, 3, 'Deathdealer Breastplate'),
-- Ceinture (5)
(1, 1,  5, 0, 1, 'Omokk''s Girth Restrainer'),
(1, 1,  5, 0, 1, 'Brigam Girdle'),
(1, 1,  5, 0, 2, 'Cloudrunner Girdle'),
-- Jambes (6)
(1, 1,  6, 0, 1, 'Devilsaur Leggings'),
(1, 1,  6, 0, 1, 'Black Dragonscale Leggings'),
(1, 1,  6, 0, 2, 'Cloudkeeper Legplates'),
-- Pieds (7)
(1, 1,  7, 0, 1, 'Boots of Heroism'),
(1, 1,  7, 0, 2, 'Black Dragonscale Boots'),
(1, 1,  7, 0, 3, 'Battlechaser''s Greaves'),
(1, 1,  7, 0, 3, 'Shadefiend Boots'),
-- Poignets (8)
(1, 1,  8, 0, 1, 'Vambraces of the Sadist'),
(1, 1,  8, 0, 1, 'Battleborn Armbraces'),
(1, 1,  8, 0, 2, 'Wristguards of Renown'),
-- Mains (9)
(1, 1,  9, 0, 1, 'Edgemaster''s Handguards'),
(1, 1,  9, 0, 1, 'Devilsaur Gauntlets'),
(1, 1,  9, 0, 2, 'Gauntlets of Heroism'),
(1, 1,  9, 0, 3, 'Gargoyle Slashers'),
-- Anneaux (10) - le module compare automatiquement avec l'emplacement 11
(1, 1, 10, 0, 1, 'Painweaver Band'),
(1, 1, 10, 0, 1, 'Blackstone Ring'),
(1, 1, 10, 0, 2, 'Tarnished Elven Ring'),
-- Bijoux (12) - le module compare automatiquement avec l'emplacement 13
(1, 1, 12, 0, 1, 'Diamond Flask'),
(1, 1, 12, 0, 1, 'Blackhand''s Breadth'),
(1, 1, 12, 0, 1, 'Hand of Justice'),
(1, 1, 12, 2, 2, 'Rune of the Guard Captain'),   -- Horde uniquement
-- Dos (14)
(1, 1, 14, 0, 1, 'Cape of the Black Baron'),
(1, 1, 14, 0, 2, 'Blackveil Cape'),
(1, 1, 14, 0, 3, 'Shroud of Domination'),
-- Main droite (15) - les lignes rank 2 sont les choix orcs (specialisation hache)
(1, 1, 15, 0, 1, 'Ironfoe'),
(1, 1, 15, 0, 1, 'Dal''Rend''s Sacred Charge'),
(1, 1, 15, 0, 1, 'Krol Blade'),
(1, 1, 15, 0, 2, 'Rivenspike'),
(1, 1, 15, 0, 2, 'Axe of the Deep Woods'),
(1, 1, 15, 0, 3, 'Assassination Blade'),
(1, 1, 15, 0, 3, 'Mass of McGowan'),
-- Main gauche (16)
(1, 1, 16, 0, 1, 'Dal''Rend''s Tribal Guardian'),
(1, 1, 16, 0, 2, 'Bone Slicing Hatchet'),
(1, 1, 16, 0, 2, 'Mirah''s Song'),
(1, 1, 16, 0, 3, 'Serathil'),
(1, 1, 16, 0, 3, 'Bonescraper'),
-- Distance (17)
(1, 1, 17, 0, 1, 'Satyr''s Bow'),
(1, 1, 17, 0, 2, 'Blackcrow'),
(1, 1, 17, 0, 3, 'Riphook');

-- Resolution des noms -> item_template.entry.
-- MIN(entry) departage les rares homonymes d'item_template.
INSERT IGNORE INTO `playerbots_bis_item`
    (`class`, `spec`, `slot`, `faction`, `tier_id`, `item_id`, `rank`, `comment`)
SELECT s.`class`, s.`spec`, s.`slot`, s.`faction`, 10, r.entry, s.`rank`,
       CONCAT('Vanilla Pre-Raid - ', s.`item_name`)
FROM `bis_seed` s
JOIN (SELECT `name`, MIN(`entry`) AS entry FROM `item_template` GROUP BY `name`) r
  ON r.`name` COLLATE utf8mb4_general_ci = s.`item_name` COLLATE utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- VERIFICATION - a executer apres l'import.
-- Toute ligne renvoyee est un nom qui n'existe pas dans item_template :
-- l'objet n'a pas ete insere, corrige le nom et relance le fichier.
-- ---------------------------------------------------------------------
SELECT s.`class`, s.`spec`, s.`slot`, s.`item_name` AS nom_non_resolu
FROM `bis_seed` s
LEFT JOIN `item_template` it
  ON it.`name` COLLATE utf8mb4_general_ci = s.`item_name` COLLATE utf8mb4_general_ci
WHERE it.`entry` IS NULL;

DROP TEMPORARY TABLE IF EXISTS `bis_seed`;
