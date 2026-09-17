-- mod-playerbots-bis : l'échelle de progression.
--
-- tier_id définit l'ordre : un palier plus haut l'emporte TOUJOURS sur un palier
-- plus bas, quelles que soient les stats. Les identifiants avancent par pas de 10
-- pour laisser de la place à des paliers intercalaires (contenu custom, demi-phases).
--
-- required_progression se raccorde à mod-individual-progression : c'est l'état que
-- le personnage doit avoir atteint pour accéder à ce contenu. 0 = jamais bloqué.
-- La colonne est ignorée tant que PlayerbotsBis.UseIndividualProgression = 0, et
-- le module n'a aucune dépendance de compilation envers mod-individual-progression :
-- il lit l'état via les quêtes cachées 66000 + état, absentes si le module ne
-- tourne pas (dans ce cas l'état vaut 0 et seuls les paliers ungated s'appliquent).

DROP TABLE IF EXISTS `playerbots_bis_tier`;
CREATE TABLE `playerbots_bis_tier` (
    `tier_id`              SMALLINT UNSIGNED NOT NULL,
    `expansion`            TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=Vanilla 1=TBC 2=WotLK',
    `name`                 VARCHAR(64) NOT NULL,
    `required_progression` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'mod-individual-progression state, 0 = ungated',
    PRIMARY KEY (`tier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `playerbots_bis_tier` (`tier_id`, `expansion`, `name`, `required_progression`) VALUES
-- Vanilla
( 10, 0, 'Vanilla Pre-Raid',                              0),
( 20, 0, 'Vanilla Phase 1 - Molten Core / Onyxia',        0),
( 30, 0, 'Vanilla Phase 2 - Blackwing Lair',              1),
( 40, 0, 'Vanilla Phase 3 - Zul Gurub',                   3),
( 50, 0, 'Vanilla Phase 4 - Ahn Qiraj 20',                4),
( 60, 0, 'Vanilla Phase 5 - Ahn Qiraj 40',                4),
( 70, 0, 'Vanilla Phase 6 - Naxxramas 40',                6),
-- The Burning Crusade
( 80, 1, 'TBC Pre-Raid',                                  8),
( 90, 1, 'TBC Phase 1 - Karazhan / Gruul / Magtheridon',  8),
(100, 1, 'TBC Phase 2 - Serpentshrine / Tempest Keep',    9),
(110, 1, 'TBC Phase 3 - Hyjal / Black Temple',           10),
(120, 1, 'TBC Phase 4 - Sunwell Plateau',                12),
-- Wrath of the Lich King
(130, 2, 'WotLK Pre-Raid',                               13),
(140, 2, 'WotLK Phase 1 - Naxxramas / EoE / OS',         13),
(150, 2, 'WotLK Phase 2 - Ulduar',                       14),
(160, 2, 'WotLK Phase 3 - Trial of the Crusader',        15),
(170, 2, 'WotLK Phase 4 - Icecrown Citadel',             16),
(180, 2, 'WotLK Phase 5 - Ruby Sanctum',                 17);
