--
-- Fichiers de valeurs autorisées
-- Authorised values samples for unimarc
-- Copyright Paul POULAIN, BibLibre SARL

-- This file is part of Koha.
--
-- Koha is free software; you can redistribute it and/or modify it under the
-- terms of the GNU General Public License as published by the Free Software
-- Foundation; either version 2 of the License, or (at your option) any later
-- version.
--
-- Koha is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
-- A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with
-- Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
-- Suite 330, Boston, MA  02111-1307 USA
--
set NAMES 'utf8';

INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (1, 'genre', 'Biographie', 'Biographie');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (2, 'genre', 'Nouvelle', 'Nouvelle');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (3, 'genre', 'Policier', 'Policier');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (4, 'genre', 'Poésie', 'Poésie');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (5, 'genre', 'Théâtre', 'Théâtre');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (6, 'genre', 'Conte', 'Conte');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (7, 'genre', 'Science fiction', 'Science fiction');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (8, 'genre', 'Roman', 'Roman');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (9, 'Bsort1', '01', 'Agriculteurs, exploitant');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (10, 'Bsort1', '02', 'Artisants, commerçants, chefs d''entreprise');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (11, 'Bsort1', '03', 'Cadres, professions intellectuelles Supérieures');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (12, 'Bsort1', '04', 'Professions intermédiaires');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (13, 'Bsort1', '05', 'Employés');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (14, 'Bsort1', '06', 'Ouvriers');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (15, 'Bsort1', '07', 'Retraités');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (16, 'Bsort1', '08', 'Demandeurs d''emploi');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (17, 'Bsort1', '09', 'Sans emploi');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (18, 'Bsort1', '10', 'Etudiants');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (19, 'Bsort1', '11', ' CSP non déclarée');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (20, 'Bsort1', '12', 'Elèves ou enfants non scolarisés');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (21, 'statut', '0', '  Disponible');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (22, 'langue', 'fre', ' Français');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (23, 'langue', 'eng', 'Anglais');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (24, 'langue', 'ger', 'Allemand');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (25, 'langue', 'dut', 'Hollandais');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (26, 'pcdm', '0- Généralités, sciences et techniques musicales', '0- Généralités, sciences et techniques musicales');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (27, 'pcdm', '0.1 Philosophie, esthétique, critique, sociologie, pratiques', '0.1 Philosophie, esthétique, critique, sociologie, pratiques');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (28, 'pcdm', '0.2 Institutions musicales', '0.2 Institutions musicales');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (29, 'pcdm', '0.3 Dictionnaires', '0.3 Dictionnaires');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (30, 'pcdm', '0.4 Répertoires, catalogues', '0.4 Répertoires, catalogues');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (31, 'pcdm', '0.5 Apprentissage et enseignement', '0.5 Apprentissage et enseignement');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (32, 'pcdm', '0.6 Techniques musicales et vocales', '0.6 Techniques musicales et vocales');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (33, 'pcdm', '0.7 Sciences et techniques en lien', '0.7 Sciences et techniques en lien');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (34, 'pcdm', '0.9 Histoire de la musique', '0.9 Histoire de la musique');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (35, 'pcdm', '1- Musiques d''influence afro-américaine', '1- Musiques d''influence afro-américaine');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (36, 'pcdm', '1.1 Blues', '1.1 Blues');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (37, 'pcdm', '1.2 Negro spirituals, Gospel', '1.2 Negro spirituals, Gospel');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (38, 'pcdm', '1.3 Jazz', '1.3 Jazz');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (39, 'pcdm', '1.4 Soul music, Rhythm''n''Blues, R''n''B', '1.4 Soul music, Rhythm''n''Blues, R''n''B');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (40, 'pcdm', '1.5 Rap', '1.5 Rap');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (41, 'pcdm', '1.6 Reggae', '1.6 Reggae');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (42, 'pcdm', '2- Rock et variété internationale apparentée', '2- Rock et variété internationale apparentée');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (43, 'pcdm', '2.1 Rock''n''roll, rockabilly', '2.1 Rock''n''roll, rockabilly');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (44, 'pcdm', '2.2 Pop', '2.2 Pop');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (45, 'pcdm', '2.3 Folk rock, country rock, blues rock', '2.3 Folk rock, country rock, blues rock');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (46, 'pcdm', '2.4 Rock psychédélique, progressif, symphonique', '2.4 Rock psychédélique, progressif, symphonique');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (47, 'pcdm', '2.5 Hard rock, metal', '2.5 Hard rock, metal');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (48, 'pcdm', '2.6 Punk et apparentés', '2.6 Punk et apparentés');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (49, 'pcdm', '2.7 New wave, cold wave, rock indus, techno pop', '2.7 New wave, cold wave, rock indus, techno pop');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (50, 'pcdm', '2.8 Fusion de styles, rock d''influences...', '2.8 Fusion de styles, rock d''influences...');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (51, 'pcdm', '2.9 Rock et variétés rock', '2.9 Rock et variétés rock');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (52, 'pcdm', '3- Musique classique', '3- Musique classique');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (53, 'pcdm', '3.1 Musique de chambre, concertante', '3.1 Musique de chambre, concertante');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (54, 'pcdm', '3.2 Musique orchestrale', '3.2 Musique orchestrale');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (55, 'pcdm', '3.3 Musique vocale profane', '3.3 Musique vocale profane');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (56, 'pcdm', '3.4 Musique vocale sacrée', '3.4 Musique vocale sacrée');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (57, 'pcdm', '3.5 Musiques utilisant l''électronique', '3.5 Musiques utilisant l''électronique');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (58, 'pcdm', '4- Musiques électroniques', '4- Musiques électroniques');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (59, 'pcdm', '4.1 Précurseurs, pionniers', '4.1 Précurseurs, pionniers');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (60, 'pcdm', '4.2 Ambient, downtempo', '4.2 Ambient, downtempo');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (61, 'pcdm', '4.3 House', '4.3 House');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (62, 'pcdm', '4.4 Techno', '4.4 Techno');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (63, 'pcdm', '4.5 Fusion de styles, électro d''influences', '4.5 Fusion de styles, électro d''influences');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (64, 'pcdm', '4.6 Elecronica', '4.6 Elecronica');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (65, 'pcdm', '4.7 Jungle drum''n''bass', '4.7 Jungle drum''n''bass');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (66, 'pcdm', '4.8 Dance', '4.8 Dance');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (67, 'pcdm', '5- Musiques fonctionnelles', '5- Musiques fonctionnelles');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (68, 'pcdm', '5.1 Musique et les autres arts', '5.1 Musique et les autres arts');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (69, 'pcdm', '5.2 Musiques liées à l''audiovisuel', '5.2 Musiques liées à l''audiovisuel');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (70, 'pcdm', '5.3 Musiques de circonstances, musique et histoire', '5.3 Musiques de circonstances, musique et histoire');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (71, 'pcdm', '5.4 Musique de détente et d''activités physiques', '5.4 Musique de détente et d''activités physiques');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (72, 'pcdm', '5.5 Variétés instrumentales et vocales', '5.5 Variétés instrumentales et vocales');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (73, 'pcdm', '5.6 Musiques de danses populaires et festives', '5.6 Musiques de danses populaires et festives');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (74, 'pcdm', '5.7 Musique de plein air et musique de sociétés musicales', '5.7 Musique de plein air et musique de sociétés musicales');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (75, 'pcdm', '5.8 Instruments particuliers, musiques mécaniques', '5.8 Instruments particuliers, musiques mécaniques');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (76, 'pcdm', '5.9 Sons divers', '5.9 Sons divers');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (77, 'pcdm', '6- Musique et cinéma', '6- Musique et cinéma');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (78, 'pcdm', '6.1 Musique concernant une oeuvre filmique', '6.1 Musique concernant une oeuvre filmique');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (79, 'pcdm', '6.2 Compilations', '6.2 Compilations');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (80, 'pcdm', '6.2 Compilations', '6.2 Compilations');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (81, 'pcdm', '8.0 Anthologies générales', '8.0 Anthologies générales');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (82, 'pcdm', '8.2 Chansons sociales', '8.2 Chansons sociales');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (83, 'pcdm', '8.3 Chansons humoristiques', '8.3 Chansons humoristiques');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (84, 'pcdm', '8.4 Chansons à texte', '8.4 Chansons à texte');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (85, 'pcdm', '8.5 chansons de variétés', '8.5 chansons de variétés');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (86, 'pcdm', '8.6 chansons en lien avec d''autres genres', '8.6 chansons en lien avec d''autres genres');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (87, 'pcdm', '9- Musiques du monde', '9- Musiques du monde');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (88, 'pcdm', '9.0 Anthologies générales', '9.0 Anthologies générales');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (89, 'pcdm', '9.1 Afrique', '9.1 Afrique');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (90, 'pcdm', '9.2 Maghreb, proche et moyen orient', '9.2 Maghreb, proche et moyen orient');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (91, 'pcdm', '9.3 Asie', '9.3 Asie');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (92, 'pcdm', '9.4 Extrême orient', '9.4 Extrême orient');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (93, 'pcdm', '9.5 Europe de l''est et méridionale', '9.5 Europe de l''est et méridionale');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (94, 'pcdm', '9.6 France', '9.6 France');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (95, 'pcdm', '9.7 Europe, Ouest et Nord', '9.7 Europe, Ouest et Nord');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (96, 'pcdm', '9.8 Amérique du Nord', '9.8 Amérique du Nord');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (97, 'pcdm', '9.9 Amérique latine', '9.9 Amérique latine');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (98, 'public', 'a', '  Adulte');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (99, 'public', 'j', 'Jeune');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (100, 'public', 'u', ' Indéterminé');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (101, 'public', 'z', 'Autre');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (107, 'local', 'Espace enfant', 'Espace enfant');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (108, 'statut', '2', 'Consultation sur RdV');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (109, 'statut', '1', ' Exclu du prêt');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (110, 'statut', '3', 'En réparation');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (111, 'statut', '4', 'En reliure');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (113, 'statut', '6', 'Rachat en cours');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (114, 'local', 'Périodiques', 'Périodiques');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (118, 'local', 'Espace petite enfance', 'Espace petite enfance');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (119, 'local', 'Magasin/réserve', 'Magasin/réserve');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (120, 'local', 'Espace audiovisuel', 'Espace audiovisuel');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (121, 'local', 'Espace multimédia', 'Espace multimédia');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (122, 'local', 'Espace consultation', 'Espace consultation');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (123, 'local', 'Fiction adultes', 'Fiction adultes');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (124, 'local', 'Doc adultes', 'Doc adultes');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (125, 'local', 'Fiction jeunesse', 'Fiction jeunesse');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (126, 'local', 'Doc jeunesse', 'Doc jeunesse');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (127, 'langue', 'spa', 'Espagnol');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (128, 'langue', 'ita', 'Italien');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (130, 'Bsort2', 'Crèche', 'Crèche');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (131, 'Bsort2', 'Ecole', 'Ecole');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (132, 'Bsort2', 'CLSH', 'CLSH');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (133, 'Bsort2', 'PMI', 'PMI');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (134, 'Bsort2', 'Prison', 'Prison');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (135, 'langue', 'chi', 'Chinois');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (136, 'langue', 'jap', 'Japonais');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (137, 'local', 'Espace document adapté', 'Espace document adapté');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (138, 'local', 'Espace local', 'Espace local');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (139, 'local', 'Espace théâtre/poésie', 'Espace théâtre/poésie');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (140, 'langue', 'dan', 'Danois');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (141, 'langue', 'por', 'Portugais');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (142, 'langue', 'pro', 'Provençal');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (143, 'pcdm', '8.1 Chansons pour enfants', '8.1 Chansons pour enfants');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (144, 'SUGGEST', 'Pas assez de budget', 'Pas assez de budget');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (145, 'SUGGEST', 'Document trop onéreux', 'Document trop onéreux');
INSERT INTO `authorised_values` (`id`, `category`, `authorised_value`, `lib`) VALUES (146, 'SUGGEST', 'Document ne correspondant pas à notre politique d''acquisition', 'Document ne correspondant pas à notre politique d''acquisition');
