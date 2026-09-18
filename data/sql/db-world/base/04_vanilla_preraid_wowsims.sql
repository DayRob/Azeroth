-- mod-playerbots-bis : palier 10 (Vanilla Pre-Raid), lot 2.
--
-- SOURCE : sets d'equipement pre-raid du simulateur WoWSims Classic,
--          https://github.com/wowsims/classic  (licence MIT).
--          Le projet demande un lien visible vers l'original : il figure ici et
--          dans le README. Les identifiants sont repris tels quels, seul le
--          rattachement classe/spe et la conversion d'emplacement sont de nous.
--
-- Ces listes ne comportent qu'UN choix par emplacement : le simulateur publie un
-- set optimal, pas une liste ordonnee. Toutes les lignes sont donc en rank 1,
-- sans alternative. Les listes issues des guides Wowhead (fichier 03) sont plus
-- riches sur ce point, avec leurs rangs Best / Optional.
--
-- Une meme liste est appliquee aux trois onglets de talents pour le mage et le
-- demoniste : en Vanilla pre-raid, leur equipement ne differe pas
-- significativement d'une spe a l'autre.
--
-- Le chasseur a ete retire de ce lot : sa liste vient du fichier 03, qui fournit
-- des alternatives classees par rang.
--
-- Les identifiants sont resolus contre item_template a l'import. Un identifiant
-- absent de la base n'est pas insere, et la requete de verification en fin de
-- fichier les liste.
--
-- NON COUVERT, faute de donnees en amont : paladins (3 spes), chamans (3 spes),
-- soigneurs prêtre et druide, voleur Assassinat et Subtilite, druide Ours,
-- guerrier Armes.

DROP TEMPORARY TABLE IF EXISTS `bis_seed_ids`;
CREATE TEMPORARY TABLE `bis_seed_ids` (
    `class`   TINYINT UNSIGNED NOT NULL,
    `spec`    TINYINT UNSIGNED NOT NULL,
    `slot`    TINYINT UNSIGNED NOT NULL,
    `item_id` INT UNSIGNED NOT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4;

INSERT INTO `bis_seed_ids` (`class`, `spec`, `slot`, `item_id`) VALUES
(1, 2, 0, 16731),
(1, 2, 2, 16733),
(1, 2, 4, 16730),
(1, 2, 5, 16736),
(1, 2, 6, 16732),
(1, 2, 7, 16734),
(1, 2, 8, 16735),
(1, 2, 9, 16737),
(4, 1, 0, 16707),
(4, 1, 1, 15411),
(4, 1, 2, 23258),
(4, 1, 4, 22879),
(4, 1, 5, 16713),
(4, 1, 6, 16709),
(4, 1, 7, 16711),
(4, 1, 8, 16710),
(4, 1, 9, 16712),
(4, 1, 10, 19325),
(4, 1, 11, 18500),
(4, 1, 12, 13965),
(4, 1, 13, 11815),
(4, 1, 14, 13340),
(4, 1, 15, 12940),
(4, 1, 16, 12939),
(4, 1, 17, 2100),
(5, 2, 0, 10504),
(5, 2, 1, 18691),
(5, 2, 2, 14112),
(5, 2, 4, 14136),
(5, 2, 5, 11662),
(5, 2, 6, 13170),
(5, 2, 7, 18735),
(5, 2, 8, 10248),
(5, 2, 9, 18407),
(5, 2, 10, 13001),
(5, 2, 11, 13001),
(5, 2, 12, 13968),
(5, 2, 13, 12930),
(5, 2, 14, 13386),
(5, 2, 15, 13349),
(5, 2, 16, 15942),
(5, 2, 17, 13396),
(8, 0, 0, 14332),
(8, 0, 1, 12103),
(8, 0, 2, 11782),
(8, 0, 4, 14152),
(8, 0, 5, 11662),
(8, 0, 6, 13170),
(8, 0, 7, 10247),
(8, 0, 8, 11766),
(8, 0, 9, 13253),
(8, 0, 10, 942),
(8, 0, 11, 942),
(8, 0, 12, 13968),
(8, 0, 13, 12930),
(8, 0, 14, 13386),
(8, 0, 15, 13964),
(8, 0, 16, 10796),
(8, 0, 17, 15283),
(8, 1, 0, 14332),
(8, 1, 1, 12103),
(8, 1, 2, 11782),
(8, 1, 4, 14152),
(8, 1, 5, 11662),
(8, 1, 6, 13170),
(8, 1, 7, 10247),
(8, 1, 8, 11766),
(8, 1, 9, 13253),
(8, 1, 10, 942),
(8, 1, 11, 942),
(8, 1, 12, 13968),
(8, 1, 13, 12930),
(8, 1, 14, 13386),
(8, 1, 15, 13964),
(8, 1, 16, 10796),
(8, 1, 17, 15283),
(8, 2, 0, 14332),
(8, 2, 1, 12103),
(8, 2, 2, 11782),
(8, 2, 4, 14152),
(8, 2, 5, 11662),
(8, 2, 6, 13170),
(8, 2, 7, 10247),
(8, 2, 8, 11766),
(8, 2, 9, 13253),
(8, 2, 10, 942),
(8, 2, 11, 942),
(8, 2, 12, 13968),
(8, 2, 13, 12930),
(8, 2, 14, 13386),
(8, 2, 15, 13964),
(8, 2, 16, 10796),
(8, 2, 17, 15283),
(9, 0, 0, 14111),
(9, 0, 1, 18691),
(9, 0, 2, 14112),
(9, 0, 4, 14153),
(9, 0, 5, 13956),
(9, 0, 6, 13170),
(9, 0, 7, 18735),
(9, 0, 8, 13107),
(9, 0, 9, 13253),
(9, 0, 10, 13001),
(9, 0, 11, 12543),
(9, 0, 12, 12930),
(9, 0, 13, 13968),
(9, 0, 14, 13386),
(9, 0, 15, 13964),
(9, 0, 16, 10796),
(9, 0, 17, 13396),
(9, 1, 0, 14111),
(9, 1, 1, 18691),
(9, 1, 2, 14112),
(9, 1, 4, 14153),
(9, 1, 5, 13956),
(9, 1, 6, 13170),
(9, 1, 7, 18735),
(9, 1, 8, 13107),
(9, 1, 9, 13253),
(9, 1, 10, 13001),
(9, 1, 11, 12543),
(9, 1, 12, 12930),
(9, 1, 13, 13968),
(9, 1, 14, 13386),
(9, 1, 15, 13964),
(9, 1, 16, 10796),
(9, 1, 17, 13396),
(9, 2, 0, 14111),
(9, 2, 1, 18691),
(9, 2, 2, 14112),
(9, 2, 4, 14153),
(9, 2, 5, 13956),
(9, 2, 6, 13170),
(9, 2, 7, 18735),
(9, 2, 8, 13107),
(9, 2, 9, 13253),
(9, 2, 10, 13001),
(9, 2, 11, 12543),
(9, 2, 12, 12930),
(9, 2, 13, 13968),
(9, 2, 14, 13386),
(9, 2, 15, 13964),
(9, 2, 16, 10796),
(9, 2, 17, 13396),
(11, 0, 0, 18727),
(11, 0, 1, 12103),
(11, 0, 2, 18681),
(11, 0, 4, 10246),
(11, 0, 5, 15191),
(11, 0, 6, 13170),
(11, 0, 7, 10247),
(11, 0, 8, 10248),
(11, 0, 9, 13253),
(11, 0, 10, 12543),
(11, 0, 11, 13001),
(11, 0, 12, 13968),
(11, 0, 13, 13515),
(11, 0, 14, 10249),
(11, 0, 15, 15278),
(11, 1, 0, 16720),
(11, 1, 2, 16718),
(11, 1, 4, 16706),
(11, 1, 5, 16716),
(11, 1, 6, 16719),
(11, 1, 7, 16715),
(11, 1, 8, 16714),
(11, 1, 9, 16717);

INSERT IGNORE INTO `playerbots_bis_item`
    (`class`, `spec`, `slot`, `faction`, `tier_id`, `item_id`, `rank`, `comment`)
SELECT s.`class`, s.`spec`, s.`slot`, 0, 10, s.`item_id`, 1,
       CONCAT('Vanilla Pre-Raid (wowsims) - ', it.`name`)
FROM `bis_seed_ids` s
JOIN `item_template` it ON it.`entry` = s.`item_id`;

-- ---------------------------------------------------------------------
-- VERIFICATION - toute ligne renvoyee est un identifiant absent de ta base.
-- ---------------------------------------------------------------------
SELECT s.`class`, s.`spec`, s.`slot`, s.`item_id` AS id_introuvable
FROM `bis_seed_ids` s
LEFT JOIN `item_template` it ON it.`entry` = s.`item_id`
WHERE it.`entry` IS NULL;

DROP TEMPORARY TABLE IF EXISTS `bis_seed_ids`;
