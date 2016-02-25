-- Raisons de l'acceptation ou du rejet d'une suggestion d'achat
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('SUGGEST','Bestseller','Succès de librairie');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('SUGGEST','Endommagé','L\'exemplaire de la bibliothèque endommagé');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('SUGGEST','Perdu','L\'exemplaire de la bibliothèque est perdu');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('SUGGEST','PEB','Document disponible via le Prêt Entre Bibliothèques');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('SUGGEST','Budget','Budget insuffisant');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('SUGGEST','Onéreux','Document trop onéreux');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('SUGGEST','Poldoc','Document ne correspondant pas à notre politique d\'acquisition');

-- Formats demandés pour la suggestion de nouveaux documents
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`, `lib_opac`) VALUES ('SUGGEST_FORMAT', 'LIVRE', 'Livre', 'Livre');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`, `lib_opac`) VALUES ('SUGGEST_FORMAT', 'GC', 'Grands caractères', 'Grands caractères');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`, `lib_opac`) VALUES ('SUGGEST_FORMAT', 'LNUM', 'Livre numérique', 'Livre numérique');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`, `lib_opac`) VALUES ('SUGGEST_FORMAT', 'LIVAUDIO', 'Livre audio', 'Livre audio');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`, `lib_opac`) VALUES ('SUGGEST_FORMAT', 'DVD', 'DVD', 'DVD');

-- Raisons de la suggestion d'achat
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('OPAC_SUG','damaged','L''exemplaire de la bibliothèque est endommagé');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('OPAC_SUG','bestseller','Succès de librairie');

-- Statut Perdu
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('LOST','1','Perdu');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('LOST','2','Long retard (perdu)');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('LOST','3','Perdu et remboursé');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('LOST','4','Introuvable');

-- Statut Endommagé
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('DAMAGED','1','Endommagé');

-- Localisation d'un exemplaire. Par défaut, celle liste est liée à items.location
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'LOC', 'Magasin', ' Magasin');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'LOC', 'Salle de lecture', 'Salle de lecture');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'LOC', 'Magasin des périodiques', 'Magasin des périodiques');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'LOC', 'Bureau des bibliothécaires', 'Bureau des bibliothécaires');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'LOC', 'Manquant', 'Manquant');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'LOC', 'Secrétariat', 'Secrétariat');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'LOC', 'En reliure', 'En reliure');

-- Codes de collection des exemplaires
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','REF','Référence');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','NFIC','Non-fiction');

-- Satut Élagué
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('WITHDRAWN','1','Élagage');

-- Statuts de disponibilités
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'NOT_LOAN', '0', 'Empruntable');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'NOT_LOAN', '1', 'Prêt restreint');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'NOT_LOAN', '3', 'En reliure');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'NOT_LOAN', '4', 'Indisponible');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'NOT_LOAN', '5', 'En traitement');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'NOT_LOAN', '6', 'Non communicable');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'NOT_LOAN', '-1', 'En commande');

-- Statut Limité
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('RESTRICTED','1','Exclu du prêt');

-- Facture manuelle
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('MANUAL_INV','Frais de copie','.25');

-- Message personnalisable aux utilisateurs
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('BOR_NOTES','ADDR','Address Notes');

-- Types d'autorité
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'CAND', 'Candidat descripteur', 'Candidat descripteur');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'CAND', 'Rejeté', 'Mot clé abandonné');

-- Groupes de rapports
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('REPORT_GROUP', 'CIRC', 'Circulation');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('REPORT_GROUP', 'CAT', 'Catalogue');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('REPORT_GROUP', 'PAT', 'Adhérents');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('REPORT_GROUP', 'ACQ', 'Acquisitions');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ('REPORT_GROUP', 'ACC', 'Comptes');

-- Types de documents pour SIP2
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '000', 'Autre');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '001', 'Livre');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '002', 'Magazine');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '003', 'Périodique relié');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '004', 'Cassette audio');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '005', 'Cassette vidéo');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '006', 'CD/CDROM');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '007', 'Disquette');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '008', 'Livre avec disquette');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '009', 'Livre avec CD');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '010', 'Livre avec cassette audio');
