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
-- Contenu actuel : Guerrier Fureur (1/1), Paladin Sacre (2/0),
-- Chasseur (3/0,1,2), Voleur (4/0,1,2), Pretre soin (5/0,1)
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
(1, 1,  2, 0, 1, 'Black Dragonscale Shoulders'),
(1, 1,  2, 0, 3, 'Wyrmhide Spaulders'),
-- Torse (4)
(1, 1,  4, 0, 1, 'Savage Gladiator Chain'),
(1, 1,  4, 0, 2, 'Cadaverous Armor'),
(1, 1,  4, 0, 2, 'Tombstone Breastplate'),
(1, 1,  4, 0, 2, 'Deathdealer Breastplate'),
-- Ceinture (5)
(1, 1,  5, 0, 1, 'Omokk''s Girth Restrainer'),
(1, 1,  5, 0, 1, 'Brigam Girdle'),
(1, 1,  5, 0, 2, 'Cloudrunner Girdle'),
-- Jambes (6)
(1, 1,  6, 0, 1, 'Devilsaur Leggings'),
(1, 1,  6, 0, 1, 'Eldritch Reinforced Legplates'),
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
(1, 1,  9, 0, 1, 'Gauntlets of Heroism'),
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

-- =====================================================================
-- Chasseur (classe 3) - liste unique appliquee aux trois onglets :
-- en Vanilla pre-raid, Maitrise / Precision / Survie portent le meme stuff.
--
-- Les armes Dal'Rend sont volontairement ABSENTES de cette liste, bien que le
-- guide les propose en une-main. Elles sont beaucoup trop rares pour que le
-- chasseur les dispute au guerrier, dont elles sont le BiS de main droite ET de
-- main gauche. Les retirer d'ici ne fait pas que l'empecher de rouler dessus :
-- l'objet devient "le BiS d'une autre spe", donc le chasseur le laisse
-- activement au guerrier. L'arme a deux mains reste de toute facon son
-- meilleur choix d'apres le set d'exemple du guide.
-- =====================================================================
INSERT INTO `bis_seed` (`class`, `spec`, `slot`, `faction`, `rank`, `item_name`) VALUES
(3, 0,  0, 0, 1, 'Backwood Helm'),
(3, 1,  0, 0, 1, 'Backwood Helm'),
(3, 2,  0, 0, 1, 'Backwood Helm'),
(3, 0,  0, 0, 2, 'Beastmaster''s Cap'),
(3, 1,  0, 0, 2, 'Beastmaster''s Cap'),
(3, 2,  0, 0, 2, 'Beastmaster''s Cap'),
(3, 0,  0, 0, 2, 'Crown of Tyranny'),
(3, 1,  0, 0, 2, 'Crown of Tyranny'),
(3, 2,  0, 0, 2, 'Crown of Tyranny'),
(3, 0,  1, 0, 1, 'Pendant of Celerity'),
(3, 1,  1, 0, 1, 'Pendant of Celerity'),
(3, 2,  1, 0, 1, 'Pendant of Celerity'),
(3, 0,  1, 0, 2, 'Mark of Fordring'),
(3, 1,  1, 0, 2, 'Mark of Fordring'),
(3, 2,  1, 0, 2, 'Mark of Fordring'),
(3, 0,  1, 0, 2, 'Imperial Jewel'),
(3, 1,  1, 0, 2, 'Imperial Jewel'),
(3, 2,  1, 0, 2, 'Imperial Jewel'),
(3, 0,  1, 0, 2, 'Will of the Martyr'),
(3, 1,  1, 0, 2, 'Will of the Martyr'),
(3, 2,  1, 0, 2, 'Will of the Martyr'),
(3, 0,  2, 0, 1, 'Truestrike Shoulders'),
(3, 1,  2, 0, 1, 'Truestrike Shoulders'),
(3, 2,  2, 0, 1, 'Truestrike Shoulders'),
(3, 0,  2, 0, 2, 'Wyrmhide Spaulders'),
(3, 1,  2, 0, 2, 'Wyrmhide Spaulders'),
(3, 2,  2, 0, 2, 'Wyrmhide Spaulders'),
(3, 0,  2, 0, 2, 'Wyrmtongue Shoulders'),
(3, 1,  2, 0, 2, 'Wyrmtongue Shoulders'),
(3, 2,  2, 0, 2, 'Wyrmtongue Shoulders'),
(3, 0,  4, 0, 1, 'Savage Gladiator Chain'),
(3, 1,  4, 0, 1, 'Savage Gladiator Chain'),
(3, 2,  4, 0, 1, 'Savage Gladiator Chain'),
(3, 0,  4, 0, 2, 'Cadaverous Armor'),
(3, 1,  4, 0, 2, 'Cadaverous Armor'),
(3, 2,  4, 0, 2, 'Cadaverous Armor'),
(3, 0,  4, 0, 2, 'Nightbrace Tunic'),
(3, 1,  4, 0, 2, 'Nightbrace Tunic'),
(3, 2,  4, 0, 2, 'Nightbrace Tunic'),
(3, 0,  5, 0, 1, 'Marksman''s Girdle'),
(3, 1,  5, 0, 1, 'Marksman''s Girdle'),
(3, 2,  5, 0, 1, 'Marksman''s Girdle'),
(3, 0,  5, 0, 2, 'Warpwood Binding'),
(3, 1,  5, 0, 2, 'Warpwood Binding'),
(3, 2,  5, 0, 2, 'Warpwood Binding'),
(3, 0,  5, 0, 2, 'Chiselbrand Girdle'),
(3, 1,  5, 0, 2, 'Chiselbrand Girdle'),
(3, 2,  5, 0, 2, 'Chiselbrand Girdle'),
(3, 0,  6, 0, 1, 'Devilsaur Leggings'),
(3, 1,  6, 0, 1, 'Devilsaur Leggings'),
(3, 2,  6, 0, 1, 'Devilsaur Leggings'),
(3, 0,  6, 0, 2, 'Blademaster Leggings'),
(3, 1,  6, 0, 2, 'Blademaster Leggings'),
(3, 2,  6, 0, 2, 'Blademaster Leggings'),
(3, 0,  6, 0, 2, 'Beastmaster''s Pants'),
(3, 1,  6, 0, 2, 'Beastmaster''s Pants'),
(3, 2,  6, 0, 2, 'Beastmaster''s Pants'),
(3, 0,  7, 0, 1, 'Beastmaster''s Boots'),
(3, 1,  7, 0, 1, 'Beastmaster''s Boots'),
(3, 2,  7, 0, 1, 'Beastmaster''s Boots'),
(3, 0,  7, 0, 2, 'Mongoose Boots'),
(3, 1,  7, 0, 2, 'Mongoose Boots'),
(3, 2,  7, 0, 2, 'Mongoose Boots'),
(3, 0,  7, 0, 2, 'Windreaver Greaves'),
(3, 1,  7, 0, 2, 'Windreaver Greaves'),
(3, 2,  7, 0, 2, 'Windreaver Greaves'),
(3, 0,  8, 0, 1, 'Bracers of the Eclipse'),
(3, 1,  8, 0, 1, 'Bracers of the Eclipse'),
(3, 2,  8, 0, 1, 'Bracers of the Eclipse'),
(3, 0,  8, 0, 2, 'Slashclaw Bracers'),
(3, 1,  8, 0, 2, 'Slashclaw Bracers'),
(3, 2,  8, 0, 2, 'Slashclaw Bracers'),
(3, 0,  8, 0, 2, 'Beastmaster''s Bindings'),
(3, 1,  8, 0, 2, 'Beastmaster''s Bindings'),
(3, 2,  8, 0, 2, 'Beastmaster''s Bindings'),
(3, 0,  9, 0, 1, 'Devilsaur Gauntlets'),
(3, 1,  9, 0, 1, 'Devilsaur Gauntlets'),
(3, 2,  9, 0, 1, 'Devilsaur Gauntlets'),
(3, 0,  9, 0, 2, 'Beastmaster''s Gloves'),
(3, 1,  9, 0, 2, 'Beastmaster''s Gloves'),
(3, 2,  9, 0, 2, 'Beastmaster''s Gloves'),
(3, 0,  9, 0, 2, 'Skul''s Fingerbone Claws'),
(3, 1,  9, 0, 2, 'Skul''s Fingerbone Claws'),
(3, 2,  9, 0, 2, 'Skul''s Fingerbone Claws'),
(3, 0,  9, 0, 2, 'Trueaim Gauntlets'),
(3, 1,  9, 0, 2, 'Trueaim Gauntlets'),
(3, 2,  9, 0, 2, 'Trueaim Gauntlets'),
(3, 0, 10, 0, 1, 'Tarnished Elven Ring'),
(3, 1, 10, 0, 1, 'Tarnished Elven Ring'),
(3, 2, 10, 0, 1, 'Tarnished Elven Ring'),
(3, 0, 10, 0, 2, 'Blackstone Ring'),
(3, 1, 10, 0, 2, 'Blackstone Ring'),
(3, 2, 10, 0, 2, 'Blackstone Ring'),
(3, 0, 10, 0, 2, 'Painweaver Band'),
(3, 1, 10, 0, 2, 'Painweaver Band'),
(3, 2, 10, 0, 2, 'Painweaver Band'),
(3, 0, 12, 0, 1, 'Blackhand''s Breadth'),
(3, 1, 12, 0, 1, 'Blackhand''s Breadth'),
(3, 2, 12, 0, 1, 'Blackhand''s Breadth'),
(3, 0, 12, 0, 1, 'Royal Seal of Eldre''Thalas'),
(3, 1, 12, 0, 1, 'Royal Seal of Eldre''Thalas'),
(3, 2, 12, 0, 1, 'Royal Seal of Eldre''Thalas'),
(3, 0, 12, 0, 2, 'Devilsaur Eye'),
(3, 1, 12, 0, 2, 'Devilsaur Eye'),
(3, 2, 12, 0, 2, 'Devilsaur Eye'),
(3, 0, 14, 0, 1, 'Cape of the Black Baron'),
(3, 1, 14, 0, 1, 'Cape of the Black Baron'),
(3, 2, 14, 0, 1, 'Cape of the Black Baron'),
(3, 0, 14, 0, 2, 'Dark Phantom Cape'),
(3, 1, 14, 0, 2, 'Dark Phantom Cape'),
(3, 2, 14, 0, 2, 'Dark Phantom Cape'),
(3, 0, 14, 0, 2, 'Blackveil Cape'),
(3, 1, 14, 0, 2, 'Blackveil Cape'),
(3, 2, 14, 0, 2, 'Blackveil Cape'),
(3, 0, 15, 0, 1, 'Huntsman''s Harpoon'),
(3, 1, 15, 0, 1, 'Huntsman''s Harpoon'),
(3, 2, 15, 0, 1, 'Huntsman''s Harpoon'),
(3, 0, 15, 0, 1, 'Warmonger'),
(3, 1, 15, 0, 1, 'Warmonger'),
(3, 2, 15, 0, 1, 'Warmonger'),
(3, 0, 15, 0, 2, 'Barbarous Blade'),
(3, 1, 15, 0, 2, 'Barbarous Blade'),
(3, 2, 15, 0, 2, 'Barbarous Blade'),
(3, 0, 15, 0, 2, 'Peacemaker'),
(3, 1, 15, 0, 2, 'Peacemaker'),
(3, 2, 15, 0, 2, 'Peacemaker'),
(3, 0, 16, 0, 1, 'Bone Slicing Hatchet'),
(3, 1, 16, 0, 1, 'Bone Slicing Hatchet'),
(3, 2, 16, 0, 1, 'Bone Slicing Hatchet'),
(3, 0, 17, 0, 1, 'Bloodseeker'),
(3, 1, 17, 0, 1, 'Bloodseeker'),
(3, 2, 17, 0, 1, 'Bloodseeker'),
(3, 0, 17, 0, 2, 'Blackcrow'),
(3, 1, 17, 0, 2, 'Blackcrow'),
(3, 2, 17, 0, 2, 'Blackcrow'),
(3, 0, 17, 0, 2, 'Heartseeking Crossbow'),
(3, 1, 17, 0, 2, 'Heartseeking Crossbow'),
(3, 2, 17, 0, 2, 'Heartseeking Crossbow'),
(3, 0, 17, 0, 2, 'Dwarven Hand Cannon'),
(3, 1, 17, 0, 2, 'Dwarven Hand Cannon'),
(3, 2, 17, 0, 2, 'Dwarven Hand Cannon'),
(3, 0, 17, 0, 2, 'Carapace Spine Crossbow'),
(3, 1, 17, 0, 2, 'Carapace Spine Crossbow'),
(3, 2, 17, 0, 2, 'Carapace Spine Crossbow');

-- =====================================================================
-- Pretre soin (classe 5) - onglets Discipline (0) et Sacre (1).
-- Le guide ne distingue pas les deux : en Vanilla, un pretre soigneur porte le
-- meme equipement quel que soit son arbre.
--
-- Rangs de la page : Best -> 1, Great -> 2, Optional -> 3.
--
-- ECARTES volontairement, car ce sont des objets a SUFFIXE ALEATOIRE, sans
-- identifiant fixe : Green Lens of Healing, Eternal Crown of Healing,
-- Archivists Cape of Healing, Masterwork Cape of Healing, Drakestone of Healing,
-- Lunar Wand of Healing. Ils ne resoudraient jamais par nom.
--
-- Redemption (baton) est mis au meme rang que la paire Hammer of Grace + Tome of
-- Divine Right : le guide les dit equivalents.
-- =====================================================================
INSERT INTO `bis_seed` (`class`, `spec`, `slot`, `faction`, `rank`, `item_name`) VALUES
(5, 0,  0, 0, 1, 'Cassandra''s Grace'),
(5, 1,  0, 0, 1, 'Cassandra''s Grace'),
(5, 0,  0, 0, 2, 'Crimson Felt Hat'),
(5, 1,  0, 0, 2, 'Crimson Felt Hat'),
(5, 0,  0, 0, 3, 'Virtuous Crown'),
(5, 1,  0, 0, 3, 'Virtuous Crown'),
(5, 0,  1, 0, 1, 'Animated Chain Necklace'),
(5, 1,  1, 0, 1, 'Animated Chain Necklace'),
(5, 0,  1, 0, 3, 'Amulet of the Redeemed'),
(5, 1,  1, 0, 3, 'Amulet of the Redeemed'),
(5, 0,  1, 0, 3, 'Tooth of Gnarr'),
(5, 1,  1, 0, 3, 'Tooth of Gnarr'),
(5, 0,  2, 0, 1, 'Mantle of Lost Hope'),
(5, 1,  2, 0, 1, 'Mantle of Lost Hope'),
(5, 0,  2, 0, 3, 'Mantle of the Scarlet Crusade'),
(5, 1,  2, 0, 3, 'Mantle of the Scarlet Crusade'),
(5, 0,  2, 0, 3, 'Burial Shawl'),
(5, 1,  2, 0, 3, 'Burial Shawl'),
(5, 0,  2, 0, 3, 'Virtuous Mantle'),
(5, 1,  2, 0, 3, 'Virtuous Mantle'),
(5, 0,  2, 0, 3, 'Kentic Amice'),
(5, 1,  2, 0, 3, 'Kentic Amice'),
(5, 0,  4, 0, 1, 'Truefaith Vestments'),
(5, 1,  4, 0, 1, 'Truefaith Vestments'),
(5, 0,  4, 0, 3, 'Robes of the Exalted'),
(5, 1,  4, 0, 3, 'Robes of the Exalted'),
(5, 0,  4, 0, 3, 'Virtuous Robe'),
(5, 1,  4, 0, 3, 'Virtuous Robe'),
(5, 0,  5, 0, 1, 'Whipvine Cord'),
(5, 1,  5, 0, 1, 'Whipvine Cord'),
(5, 0,  5, 0, 3, 'Virtuous Belt'),
(5, 1,  5, 0, 3, 'Virtuous Belt'),
(5, 0,  5, 0, 3, 'Thuzadin Sash'),
(5, 1,  5, 0, 3, 'Thuzadin Sash'),
(5, 0,  6, 0, 1, 'Padre''s Trousers'),
(5, 1,  6, 0, 1, 'Padre''s Trousers'),
(5, 0,  6, 0, 2, 'Senior Designer''s Pantaloons'),
(5, 1,  6, 0, 2, 'Senior Designer''s Pantaloons'),
(5, 0,  6, 0, 3, 'Virtuous Skirt'),
(5, 1,  6, 0, 3, 'Virtuous Skirt'),
(5, 0,  6, 0, 3, 'Wolfshear Leggings'),
(5, 1,  6, 0, 3, 'Wolfshear Leggings'),
(5, 0,  6, 0, 3, 'Cenarion Reservist''s Pants'),
(5, 1,  6, 0, 3, 'Cenarion Reservist''s Pants'),
(5, 0,  7, 0, 1, 'Virtuous Sandals'),
(5, 1,  7, 0, 1, 'Virtuous Sandals'),
(5, 0,  7, 0, 1, 'Faith Healer''s Boots'),
(5, 1,  7, 0, 1, 'Faith Healer''s Boots'),
(5, 0,  7, 0, 2, 'Boots of the Full Moon'),
(5, 1,  7, 0, 2, 'Boots of the Full Moon'),
(5, 0,  7, 0, 2, 'Soot Encrusted Footwear'),
(5, 1,  7, 0, 2, 'Soot Encrusted Footwear'),
(5, 0,  8, 0, 1, 'Sublime Wristguards'),
(5, 1,  8, 0, 1, 'Sublime Wristguards'),
(5, 0,  8, 0, 1, 'Virtuous Bracers'),
(5, 1,  8, 0, 1, 'Virtuous Bracers'),
(5, 0,  8, 0, 3, 'Wyrmthalak''s Shackles'),
(5, 1,  8, 0, 3, 'Wyrmthalak''s Shackles'),
(5, 0,  8, 0, 3, 'Aristocratic Cuffs'),
(5, 1,  8, 0, 3, 'Aristocratic Cuffs'),
(5, 0,  8, 0, 3, 'Devout Bracers'),
(5, 1,  8, 0, 3, 'Devout Bracers'),
(5, 0,  9, 0, 1, 'Desert Bloom Gloves'),
(5, 1,  9, 0, 1, 'Desert Bloom Gloves'),
(5, 0,  9, 0, 1, 'Hands of the Exalted Herald'),
(5, 1,  9, 0, 1, 'Hands of the Exalted Herald'),
(5, 0,  9, 0, 3, 'Virtuous Gloves'),
(5, 1,  9, 0, 3, 'Virtuous Gloves'),
(5, 0,  9, 0, 3, 'Hands of Power'),
(5, 1,  9, 0, 3, 'Hands of Power'),
(5, 0,  9, 0, 3, 'Runecloth Gloves'),
(5, 1,  9, 0, 3, 'Runecloth Gloves'),
(5, 0, 10, 0, 1, 'Rosewine Circle'),
(5, 1, 10, 0, 1, 'Rosewine Circle'),
(5, 0, 10, 0, 1, 'Band of Mending'),
(5, 1, 10, 0, 1, 'Band of Mending'),
(5, 0, 10, 0, 1, 'Fordring''s Seal'),
(5, 1, 10, 0, 1, 'Fordring''s Seal'),
(5, 0, 10, 0, 3, 'Emerald Flame Ring'),
(5, 1, 10, 0, 3, 'Emerald Flame Ring'),
(5, 0, 12, 0, 1, 'Royal Seal of Eldre''Thalas'),
(5, 1, 12, 0, 1, 'Royal Seal of Eldre''Thalas'),
(5, 0, 12, 0, 1, 'Draconic Infused Emblem'),
(5, 1, 12, 0, 1, 'Draconic Infused Emblem'),
(5, 0, 12, 0, 1, 'Blessed Prayer Beads'),
(5, 1, 12, 0, 1, 'Blessed Prayer Beads'),
(5, 0, 12, 0, 2, 'Briarwood Reed'),
(5, 1, 12, 0, 2, 'Briarwood Reed'),
(5, 0, 12, 0, 2, 'Second Wind'),
(5, 1, 12, 0, 2, 'Second Wind'),
(5, 0, 12, 0, 3, 'Mindtap Talisman'),
(5, 1, 12, 0, 3, 'Mindtap Talisman'),
(5, 0, 12, 0, 3, 'Burst of Knowledge'),
(5, 1, 12, 0, 3, 'Burst of Knowledge'),
(5, 0, 12, 0, 3, 'Major Recombobulator'),
(5, 1, 12, 0, 3, 'Major Recombobulator'),
(5, 0, 14, 0, 1, 'Hide of the Wild'),
(5, 1, 14, 0, 1, 'Hide of the Wild'),
(5, 0, 14, 0, 3, 'Cloak of the Cosmos'),
(5, 1, 14, 0, 3, 'Cloak of the Cosmos'),
(5, 0, 14, 0, 3, 'Spritecaster Cape'),
(5, 1, 14, 0, 3, 'Spritecaster Cape'),
(5, 0, 15, 0, 1, 'The Hammer of Grace'),
(5, 1, 15, 0, 1, 'The Hammer of Grace'),
(5, 0, 15, 0, 1, 'Redemption'),
(5, 1, 15, 0, 1, 'Redemption'),
(5, 0, 15, 0, 3, 'Hammer of Revitalization'),
(5, 1, 15, 0, 3, 'Hammer of Revitalization'),
(5, 0, 15, 0, 3, 'Hand of Righteousness'),
(5, 1, 15, 0, 3, 'Hand of Righteousness'),
(5, 0, 15, 0, 3, 'Guiding Stave of Wisdom'),
(5, 1, 15, 0, 3, 'Guiding Stave of Wisdom'),
(5, 0, 15, 0, 3, 'Staff of Metanoia'),
(5, 1, 15, 0, 3, 'Staff of Metanoia'),
(5, 0, 16, 0, 1, 'Tome of Divine Right'),
(5, 1, 16, 0, 1, 'Tome of Divine Right'),
(5, 0, 16, 0, 3, 'Brightly Glowing Stone'),
(5, 1, 16, 0, 3, 'Brightly Glowing Stone'),
(5, 0, 16, 0, 3, 'Thaurissan''s Royal Scepter'),
(5, 1, 16, 0, 3, 'Thaurissan''s Royal Scepter'),
(5, 0, 16, 0, 3, 'Spirit of Aquementas'),
(5, 1, 16, 0, 3, 'Spirit of Aquementas'),
(5, 0, 17, 0, 1, 'Wand of Eternal Light'),
(5, 1, 17, 0, 1, 'Wand of Eternal Light'),
(5, 0, 17, 0, 3, 'Mana Channeling Wand'),
(5, 1, 17, 0, 3, 'Mana Channeling Wand'),
(5, 0, 17, 0, 3, 'Bonecreeper Stylus'),
(5, 1, 17, 0, 3, 'Bonecreeper Stylus'),
(5, 0, 10, 2, 3, 'Eye of Orgrimmar'),
(5, 1, 10, 2, 3, 'Eye of Orgrimmar'),
(5, 0, 10, 1, 3, 'Songstone of Ironforge'),
(5, 1, 10, 1, 3, 'Songstone of Ironforge');

-- =====================================================================
-- Voleur (classe 4) - Assassinat (0), Combat (1), Subtilite (2).
-- L'armure et les bijoux sont communs aux trois onglets : le guide ne les
-- distingue pas, et l'ensemble Darkmantle est le coeur du set pre-raid.
--
-- Les ARMES en revanche sont reparties par onglet, car le guide propose deux
-- montages : dague et epee. Assassinat et Subtilite prennent les dagues
-- (Felstriker / Distracting Dagger), Combat prend les epees.
--
-- Les Dal'Rend sont VOLONTAIREMENT CONSERVEES ici pour Combat, contrairement au
-- chasseur a qui on les a retirees. Elles sont un vrai BiS de voleur Combat, pas
-- un simple depannage. Consequence mecanique : guerrier Fureur et voleur Combat
-- les listent tous les deux, donc aucun des deux ne laisse l'objet a l'autre -
-- les deux rollent. C'est le comportement voulu : la regle "je le laisse a
-- l'autre" ne se declenche que quand l'objet n'est PAS dans ma propre liste.
--
-- Rangs de la page : Best -> 1, Optional -> 3.
-- =====================================================================
INSERT INTO `bis_seed` (`class`, `spec`, `slot`, `faction`, `rank`, `item_name`) VALUES
(4, 0,  0, 0, 1, 'Darkmantle Cap'),
(4, 1,  0, 0, 1, 'Darkmantle Cap'),
(4, 2,  0, 0, 1, 'Darkmantle Cap'),
(4, 0,  0, 0, 3, 'Shadowcraft Cap'),
(4, 1,  0, 0, 3, 'Shadowcraft Cap'),
(4, 2,  0, 0, 3, 'Shadowcraft Cap'),
(4, 0,  0, 0, 3, 'Mask of the Unforgiven'),
(4, 1,  0, 0, 3, 'Mask of the Unforgiven'),
(4, 2,  0, 0, 3, 'Mask of the Unforgiven'),
(4, 0,  0, 0, 3, 'Eye of Rend'),
(4, 1,  0, 0, 3, 'Eye of Rend'),
(4, 2,  0, 0, 3, 'Eye of Rend'),
(4, 0,  1, 0, 1, 'Pendant of Celerity'),
(4, 1,  1, 0, 1, 'Pendant of Celerity'),
(4, 2,  1, 0, 1, 'Pendant of Celerity'),
(4, 0,  1, 0, 1, 'Mark of Fordring'),
(4, 1,  1, 0, 1, 'Mark of Fordring'),
(4, 2,  1, 0, 1, 'Mark of Fordring'),
(4, 0,  1, 0, 3, 'Beads of Ogre Might'),
(4, 1,  1, 0, 3, 'Beads of Ogre Might'),
(4, 2,  1, 0, 3, 'Beads of Ogre Might'),
(4, 0,  2, 0, 1, 'Darkmantle Spaulders'),
(4, 1,  2, 0, 1, 'Darkmantle Spaulders'),
(4, 2,  2, 0, 1, 'Darkmantle Spaulders'),
(4, 0,  2, 0, 3, 'Shadowcraft Spaulders'),
(4, 1,  2, 0, 3, 'Shadowcraft Spaulders'),
(4, 2,  2, 0, 3, 'Shadowcraft Spaulders'),
(4, 0,  2, 0, 3, 'Truestrike Shoulders'),
(4, 1,  2, 0, 3, 'Truestrike Shoulders'),
(4, 2,  2, 0, 3, 'Truestrike Shoulders'),
(4, 0,  2, 0, 3, 'Wyrmhide Spaulders'),
(4, 1,  2, 0, 3, 'Wyrmhide Spaulders'),
(4, 2,  2, 0, 3, 'Wyrmhide Spaulders'),
(4, 0,  4, 0, 1, 'Darkmantle Tunic'),
(4, 1,  4, 0, 1, 'Darkmantle Tunic'),
(4, 2,  4, 0, 1, 'Darkmantle Tunic'),
(4, 0,  4, 0, 3, 'Shadowcraft Tunic'),
(4, 1,  4, 0, 3, 'Shadowcraft Tunic'),
(4, 2,  4, 0, 3, 'Shadowcraft Tunic'),
(4, 0,  4, 0, 3, 'Cadaverous Armor'),
(4, 1,  4, 0, 3, 'Cadaverous Armor'),
(4, 2,  4, 0, 3, 'Cadaverous Armor'),
(4, 0,  4, 0, 3, 'Traphook Jerkin'),
(4, 1,  4, 0, 3, 'Traphook Jerkin'),
(4, 2,  4, 0, 3, 'Traphook Jerkin'),
(4, 0,  5, 0, 1, 'Darkmantle Belt'),
(4, 1,  5, 0, 1, 'Darkmantle Belt'),
(4, 2,  5, 0, 1, 'Darkmantle Belt'),
(4, 0,  5, 0, 3, 'Shadowcraft Belt'),
(4, 1,  5, 0, 3, 'Shadowcraft Belt'),
(4, 2,  5, 0, 3, 'Shadowcraft Belt'),
(4, 0,  5, 0, 3, 'Cloudrunner Girdle'),
(4, 1,  5, 0, 3, 'Cloudrunner Girdle'),
(4, 2,  5, 0, 3, 'Cloudrunner Girdle'),
(4, 0,  5, 0, 3, 'Mugger''s Belt'),
(4, 1,  5, 0, 3, 'Mugger''s Belt'),
(4, 2,  5, 0, 3, 'Mugger''s Belt'),
(4, 0,  6, 0, 1, 'Devilsaur Leggings'),
(4, 1,  6, 0, 1, 'Devilsaur Leggings'),
(4, 2,  6, 0, 1, 'Devilsaur Leggings'),
(4, 0,  6, 0, 3, 'Darkmantle Pants'),
(4, 1,  6, 0, 3, 'Darkmantle Pants'),
(4, 2,  6, 0, 3, 'Darkmantle Pants'),
(4, 0,  6, 0, 3, 'Shadowcraft Pants'),
(4, 1,  6, 0, 3, 'Shadowcraft Pants'),
(4, 2,  6, 0, 3, 'Shadowcraft Pants'),
(4, 0,  7, 0, 1, 'Darkmantle Boots'),
(4, 1,  7, 0, 1, 'Darkmantle Boots'),
(4, 2,  7, 0, 1, 'Darkmantle Boots'),
(4, 0,  7, 0, 3, 'Shadowcraft Boots'),
(4, 1,  7, 0, 3, 'Shadowcraft Boots'),
(4, 2,  7, 0, 3, 'Shadowcraft Boots'),
(4, 0,  7, 0, 3, 'Swiftwalker Boots'),
(4, 1,  7, 0, 3, 'Swiftwalker Boots'),
(4, 2,  7, 0, 3, 'Swiftwalker Boots'),
(4, 0,  8, 0, 1, 'Darkmantle Bracers'),
(4, 1,  8, 0, 1, 'Darkmantle Bracers'),
(4, 2,  8, 0, 1, 'Darkmantle Bracers'),
(4, 0,  8, 0, 3, 'Shadowcraft Bracers'),
(4, 1,  8, 0, 3, 'Shadowcraft Bracers'),
(4, 2,  8, 0, 3, 'Shadowcraft Bracers'),
(4, 0,  8, 0, 3, 'Bracers of the Eclipse'),
(4, 1,  8, 0, 3, 'Bracers of the Eclipse'),
(4, 2,  8, 0, 3, 'Bracers of the Eclipse'),
(4, 0,  8, 0, 3, 'Deepfury Bracers'),
(4, 1,  8, 0, 3, 'Deepfury Bracers'),
(4, 2,  8, 0, 3, 'Deepfury Bracers'),
(4, 0,  9, 0, 1, 'Devilsaur Gauntlets'),
(4, 1,  9, 0, 1, 'Devilsaur Gauntlets'),
(4, 2,  9, 0, 1, 'Devilsaur Gauntlets'),
(4, 0,  9, 0, 3, 'Darkmantle Gloves'),
(4, 1,  9, 0, 3, 'Darkmantle Gloves'),
(4, 2,  9, 0, 3, 'Darkmantle Gloves'),
(4, 0,  9, 0, 3, 'Shadowcraft Gloves'),
(4, 1,  9, 0, 3, 'Shadowcraft Gloves'),
(4, 2,  9, 0, 3, 'Shadowcraft Gloves'),
(4, 0, 10, 0, 1, 'Tarnished Elven Ring'),
(4, 1, 10, 0, 1, 'Tarnished Elven Ring'),
(4, 2, 10, 0, 1, 'Tarnished Elven Ring'),
(4, 0, 10, 0, 3, 'Painweaver Band'),
(4, 1, 10, 0, 3, 'Painweaver Band'),
(4, 2, 10, 0, 3, 'Painweaver Band'),
(4, 0, 10, 0, 3, 'Blackstone Ring'),
(4, 1, 10, 0, 3, 'Blackstone Ring'),
(4, 2, 10, 0, 3, 'Blackstone Ring'),
(4, 0, 12, 0, 1, 'Hand of Justice'),
(4, 1, 12, 0, 1, 'Hand of Justice'),
(4, 2, 12, 0, 1, 'Hand of Justice'),
(4, 0, 12, 0, 1, 'Blackhand''s Breadth'),
(4, 1, 12, 0, 1, 'Blackhand''s Breadth'),
(4, 2, 12, 0, 1, 'Blackhand''s Breadth'),
(4, 0, 12, 0, 3, 'Royal Seal of Eldre''Thalas'),
(4, 1, 12, 0, 3, 'Royal Seal of Eldre''Thalas'),
(4, 2, 12, 0, 3, 'Royal Seal of Eldre''Thalas'),
(4, 0, 14, 0, 1, 'Cape of the Black Baron'),
(4, 1, 14, 0, 1, 'Cape of the Black Baron'),
(4, 2, 14, 0, 1, 'Cape of the Black Baron'),
(4, 0, 14, 0, 3, 'Shadow Prowler''s Cloak'),
(4, 1, 14, 0, 3, 'Shadow Prowler''s Cloak'),
(4, 2, 14, 0, 3, 'Shadow Prowler''s Cloak'),
(4, 0, 14, 0, 3, 'Blackveil Cape'),
(4, 1, 14, 0, 3, 'Blackveil Cape'),
(4, 2, 14, 0, 3, 'Blackveil Cape'),
(4, 0, 17, 0, 1, 'Precisely Calibrated Boomstick'),
(4, 1, 17, 0, 1, 'Precisely Calibrated Boomstick'),
(4, 2, 17, 0, 1, 'Precisely Calibrated Boomstick'),
(4, 0, 17, 0, 3, 'Blackcrow'),
(4, 1, 17, 0, 3, 'Blackcrow'),
(4, 2, 17, 0, 3, 'Blackcrow'),
(4, 0, 17, 0, 3, 'Satyr''s Bow'),
(4, 1, 17, 0, 3, 'Satyr''s Bow'),
(4, 2, 17, 0, 3, 'Satyr''s Bow'),
(4, 0, 17, 0, 3, 'Ancient Bone Bow'),
(4, 1, 17, 0, 3, 'Ancient Bone Bow'),
(4, 2, 17, 0, 3, 'Ancient Bone Bow'),
(4, 0, 15, 0, 1, 'Felstriker'),
(4, 0, 15, 0, 3, 'Heartseeker'),
(4, 0, 16, 0, 1, 'Distracting Dagger'),
(4, 0, 16, 0, 3, 'Bonescraper'),
(4, 2, 15, 0, 1, 'Felstriker'),
(4, 2, 15, 0, 3, 'Heartseeker'),
(4, 2, 16, 0, 1, 'Distracting Dagger'),
(4, 2, 16, 0, 3, 'Bonescraper'),
(4, 1, 15, 0, 1, 'Dal''Rend''s Sacred Charge'),
(4, 1, 15, 0, 3, 'Sword of Zeal'),
(4, 1, 16, 0, 1, 'Dal''Rend''s Tribal Guardian'),
(4, 1, 16, 0, 3, 'Mirah''s Song'),
(4, 0, 12, 2, 3, 'Rune of the Guard Captain'),
(4, 1, 12, 2, 3, 'Rune of the Guard Captain'),
(4, 2, 12, 2, 3, 'Rune of the Guard Captain');

-- =====================================================================
-- Paladin Sacre (classe 2, spe 0) - soigneur.
--
-- Le libram va sur l'emplacement 17 (l'emplacement "distance" d'AzerothCore,
-- qui accueille aussi les reliques de paladin, druide, chaman et chevalier).
--
-- Rangs de la page : Best -> 1, Optional -> 3. Exception a la ceinture :
-- Sash of Mercy est le vrai BiS mais c'est un drop monde aleatoire, donc le
-- guide batit son set d'exemple avec Whipvine Cord. On garde donc Sash of Mercy
-- en 1 et on remonte Whipvine Cord en 2 : le bot portera Whipvine Cord en
-- pratique, et basculera tout seul s'il met la main sur la Sash.
--
-- "Uncommon Legs of Healing" n'est pas importe : c'est un drop monde a suffixe
-- aleatoire, il n'a pas de nom fixe resolvable dans item_template.
-- =====================================================================
INSERT INTO `bis_seed` (`class`, `spec`, `slot`, `faction`, `rank`, `item_name`) VALUES
(2, 0,  0, 0, 1, 'Insightful Hood'),
(2, 0,  0, 0, 3, 'Whitesoul Helm'),
(2, 0,  0, 0, 3, 'Tribal War Feathers'),
(2, 0,  1, 0, 1, 'Animated Chain Necklace'),
(2, 0,  1, 0, 3, 'Amulet of the Redeemed'),
(2, 0,  1, 0, 3, 'Tooth of Gnarr'),
(2, 0,  2, 0, 1, 'Royal Cap Spaulders'),
(2, 0,  2, 0, 3, 'Living Shoulders'),
(2, 0,  2, 0, 3, 'Burial Shawl'),
(2, 0,  4, 0, 1, 'Robes of the Exalted'),
(2, 0,  4, 0, 3, 'Red Dragonscale Breastplate'),
(2, 0,  4, 0, 3, 'Chestplate of Tranquility'),
(2, 0,  5, 0, 1, 'Sash of Mercy'),
(2, 0,  5, 0, 2, 'Whipvine Cord'),
(2, 0,  5, 0, 3, 'Belt of the Ordained'),
(2, 0,  6, 0, 1, 'Padre''s Trousers'),
(2, 0,  6, 0, 3, 'Senior Designer''s Pantaloons'),
(2, 0,  7, 0, 1, 'Boots of the Full Moon'),
(2, 0,  7, 0, 3, 'Verdant Footpads'),
(2, 0,  7, 0, 3, 'Merciful Greaves'),
(2, 0,  8, 0, 1, 'Gallant''s Wristguards'),
(2, 0,  8, 0, 3, 'Loomguard Armbraces'),
(2, 0,  8, 0, 3, 'Bracers of Prosperity'),
(2, 0,  9, 0, 1, 'Harmonious Gauntlets'),
(2, 0,  9, 0, 3, 'Atal''ai Gloves'),
(2, 0,  9, 0, 3, 'Gloves of Restoration'),
(2, 0, 10, 0, 1, 'Fordring''s Seal'),
(2, 0, 11, 0, 1, 'Fordring''s Seal'),
(2, 0, 10, 0, 1, 'Rosewine Circle'),
(2, 0, 11, 0, 1, 'Rosewine Circle'),
(2, 0, 10, 0, 3, 'Band of Mending'),
(2, 0, 11, 0, 3, 'Band of Mending'),
(2, 0, 10, 0, 3, 'Emerald Flame Ring'),
(2, 0, 11, 0, 3, 'Emerald Flame Ring'),
(2, 0, 12, 0, 1, 'Briarwood Reed'),
(2, 0, 13, 0, 1, 'Briarwood Reed'),
(2, 0, 12, 0, 1, 'Second Wind'),
(2, 0, 13, 0, 1, 'Second Wind'),
(2, 0, 12, 0, 3, 'Royal Seal of Eldre''Thalas'),
(2, 0, 13, 0, 3, 'Royal Seal of Eldre''Thalas'),
(2, 0, 14, 0, 1, 'Hide of the Wild'),
(2, 0, 14, 0, 3, 'Cloak of the Cosmos'),
(2, 0, 14, 0, 3, 'Archivist Cape'),
(2, 0, 15, 0, 1, 'The Hammer of Grace'),
(2, 0, 15, 0, 3, 'Hammer of Revitalization'),
(2, 0, 15, 0, 3, 'Energetic Rod'),
(2, 0, 16, 0, 1, 'Brightly Glowing Stone'),
(2, 0, 16, 0, 3, 'Tome of Divine Right'),
(2, 0, 16, 0, 3, 'Thaurissan''s Royal Scepter'),
(2, 0, 17, 0, 1, 'Libram of Divinity');

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

-- ---------------------------------------------------------------------
-- VERIFICATION 2 - coherence de l'emplacement.
-- Un nom peut tres bien exister tout en etant range dans le mauvais
-- emplacement (une arme notee en main gauche alors qu'elle est en main droite,
-- par exemple). Le module cherche l'objet par emplacement : si l'emplacement
-- declare ici ne correspond pas a celui de l'objet, la ligne ne servira jamais.
-- Toute ligne renvoyee par cette requete est a corriger.
--
-- Correspondance InventoryType d'item_template -> emplacement :
--   1 tete | 2 cou | 3 epaules | 5,20 torse | 6 taille | 7 jambes | 8 pieds
--   9 poignets | 10 mains | 11 doigt | 12 bijou | 16 dos
--   13 une-main | 17 deux-mains | 21 main droite | 22,23 main gauche
--   14 bouclier | 15,25,26 distance | 28 relique
-- ---------------------------------------------------------------------
SELECT s.`class`, s.`spec`, s.`slot` AS emplacement_declare,
       it.`InventoryType` AS emplacement_reel, s.`item_name`
FROM `bis_seed` s
JOIN `item_template` it
  ON it.`name` COLLATE utf8mb4_general_ci = s.`item_name` COLLATE utf8mb4_general_ci
WHERE NOT (
       (s.`slot` =  0 AND it.`InventoryType` = 1)
    OR (s.`slot` =  1 AND it.`InventoryType` = 2)
    OR (s.`slot` =  2 AND it.`InventoryType` = 3)
    OR (s.`slot` =  4 AND it.`InventoryType` IN (5, 20))
    OR (s.`slot` =  5 AND it.`InventoryType` = 6)
    OR (s.`slot` =  6 AND it.`InventoryType` = 7)
    OR (s.`slot` =  7 AND it.`InventoryType` = 8)
    OR (s.`slot` =  8 AND it.`InventoryType` = 9)
    OR (s.`slot` =  9 AND it.`InventoryType` = 10)
    OR (s.`slot` IN (10, 11) AND it.`InventoryType` = 11)
    OR (s.`slot` IN (12, 13) AND it.`InventoryType` = 12)
    OR (s.`slot` = 14 AND it.`InventoryType` = 16)
    OR (s.`slot` = 15 AND it.`InventoryType` IN (13, 17, 21))
    OR (s.`slot` = 16 AND it.`InventoryType` IN (13, 14, 22, 23))
    OR (s.`slot` = 17 AND it.`InventoryType` IN (15, 25, 26, 28))
);

DROP TEMPORARY TABLE IF EXISTS `bis_seed`;
