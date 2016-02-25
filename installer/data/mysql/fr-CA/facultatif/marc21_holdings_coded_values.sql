-- Valeurs codées conformes aux mentions de fonds Z39.71-2006 pour les éléments bibliographiques
-- ISSN: 1041-5653
-- Voir to http://www.niso.org/standards/index.html

-- Fonds général : Désignateur de type d'unité
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','0','Information non disponible; Non applicable');INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','a','Unité bibliographique de base');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','c','Unité bibliographique secondaire : suppléments, numéros spéciaux, matériel d\'accompagnement, autres unités bibliographiques secondaires');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','d','Index');

-- Désignateur de forme physique :
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','au','Matériel cartographique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ad','Matériel cartographique, atlas');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ag' ,'Matériel cartographique, diagramme');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','aj' ,'Matériel cartographique, carte');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ak' ,'Matériel cartographique, profil');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','aq' ,'Matériel cartographique, modèle');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ar' ,'Matériel cartographique, image de télédétection');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','as' ,'Matériel cartographique, section');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ay' ,'Matériel cartographique, vue');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','az' ,'Matériel cartographique, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cu' ,'Fichiers d\'ordinateur');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ca' ,'Fichiers d\'ordinateur, cartouche de bande magnétique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cb' ,'Fichiers d\'ordinateur, cartouche de mémoire');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cc' ,'Fichiers d\'ordinateur, cartouche de disque optique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cf' ,'Fichiers d\'ordinateur, bande en cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ch' ,'Fichiers d\'ordinateur, bande sur bobine');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cj' ,'Fichiers d\'ordinateur, disque magnétique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cm' ,'Fichiers d\'ordinateur, disque magnéto-optique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','co' ,'Fichiers d\'ordinateur, disque optique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cr' ,'Fichiers d\'ordinateur, accès à distance');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cz' ,'Fichiers d\'ordinateur, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','du' ,'Globe');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','da' ,'Globe, céleste');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','db' ,'Globe, planétaire ou lunaire');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','dc' ,'Globe, terrestre');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','de' ,'Globe, lunaire de la Terre');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','dz' ,'Globe, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ou' ,'Kit');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hu' ,'Microforme');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ha' ,'Microforme, carte à fenêtres ');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hb',' Microforme, microfilm en cartouche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hc',' Microforme, microfilm en cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hd',' Microforme, bobine de microfilm');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','he' ,'Microforme, microfiche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hf' ,'Microforme, microfiche en cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hg' ,'Microforme, microcopie opaque');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hz' ,'Microforme, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mu' ,'Film cinématographique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mc' ,'Film cinématographique, film en cartouche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mf' ,'Film cinématographique, film en cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mr' ,'Film cinématographique, rouleau de film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mz' ,'Film cinématographique, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ku' ,'Document iconique non projeté');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kc' ,'Document iconique non projeté, collage');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kd' ,'Document iconique non projeté, dessin');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ke' ,'Document iconique non projeté, tableau');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kf' ,'Document iconique non projeté, reproduction photomécanique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kg' ,'Document iconique non projeté, négatif');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kh' ,'Document iconique non projeté, épreuve photographique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ki' ,'Document iconique non projeté, image');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kj' ,'Document iconique non projeté, tirage');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kl' ,'Document iconique non projeté, dessin technique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kn' ,'Document iconique non projeté, graphique');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ko' ,'Document iconique non projeté, carte éclair');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kz' ,'Document iconique non projeté, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','qu' ,'Notation musicale');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gu' ,'Document iconique projeté');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gc' ,'Document iconique projeté, film fixe en cartouche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gd' ,'Document iconique projeté, film fixe court');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gf' ,'Document iconique projeté, film fixe, genre non précisé');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','go' ,'Document iconique projeté, film fixe en rouleau');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gs' ,'Document iconique projeté, diapositive');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gt' ,'Document iconique projeté, transparent');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gz' ,'Document iconique projeté, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ru' ,'Image de télédétection');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','su' ,'Enregistrement sonore');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sd' ,'Enregistrement sonore, disque sonore');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','se' ,'Enregistrement sonore, cylindre');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sg' ,'Enregistrement sonore, cartouche sonore');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','si' ,'Enregistrement sonore, piste sonore d\'un film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sq' ,'Enregistrement sonore, rouleau');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ss' ,'Enregistrement sonore, audio cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','st' ,'Enregistrement sonore, bobine de bande sonore');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sw' ,'Enregistrement sonore, wire recording');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sz' ,'Enregistrement sonore, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tu' ,'Document textuel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ta' ,'Document textuel, caractères normaux');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tb' ,'Document textuel, gros caractères');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tc' ,'Document textuel, braille');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','td' ,'Document textuel, feuille mobile');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tz' ,'Document textuel, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vu' ,'Enregistrement vidéo');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vc' ,'Enregistrement vidéo, vidéo en cartouche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vd' ,'Enregistrement vidéo, vidéodisque');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vf' ,'Enregistrement vidéo, vidéocassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vr' ,'Enregistrement vidéo, bobine vidéo');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vz' ,'Enregistrement vidéo, autre');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zu' ,'Forme physique non indiquée');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zm' ,'Formes physiques multiples');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zz' ,'Autre média physique');

-- Fonds général : Désignateur d'intégralité
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','0','Information non disponible, ou conservation limitée');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','1','Complet (détient 95%-100%)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','2','Incomplet (détient 50%-94%)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','3','Fragmenté (détient moins de 50%)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','4','Sans objet');

-- Fonds général : Désignateur de statut d'acquisitions
-- Cette donnée indique le statut d'acquisitions de l'unité au moment du rapport sur les fonds.

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','0','Information non disponible, ou conservation limitée');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','1','Autre');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','2','Reçu et complété ou interrompu');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','3','Commandé');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','4','Reçu actuellement');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','5','N\'est pas reçu actuellement');

-- Fonds général : Désignateur de conservation
-- Cette donnée indique la politique de conservation pour cette unité au moment du rapport sur les fonds.

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','0','Information non disponible');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','1','Autre');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','2','Conservé sauf lorsque remplacé par des mises à jour');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','3','Échantillon conservé');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','4','Conservé jusqu\'au remplacement par microforme, ou un autre format de conservation');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','5','Conservé jusqu\'au remplacement par refonte, volume de remplacement ou révision');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','6','Conservé seulement pour une période limitée');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','7','N\'est pas conservé ');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','8','Conservé en permanence');
