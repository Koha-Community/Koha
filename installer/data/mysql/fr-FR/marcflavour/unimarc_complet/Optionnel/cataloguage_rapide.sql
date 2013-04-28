-- phpMyAdmin SQL Dump
-- version 2.11.8.1deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Nov 12, 2008 at 10:51 AM
-- Server version: 5.0.67
-- PHP Version: 5.2.6-2ubuntu4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

INSERT INTO biblio_framework (frameworkcode,frameworktext) VALUES ('FA', 'Fast cataloging');

INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
('000', 'Label', '', 0, 1, '', 'FA'),
('001', 'Numéro de notice','Numéro de notice',0,0,'','FA'),
('090','Numéro biblio (koha)','Numéro biblio (koha',0,0,'','FA'),
('100', 'Données générales de traitement', '', 0, 1, '', 'FA'),
('200', 'Titre et mention de responsabilité', 'Titre', 0, 1, '', 'FA'),
('205', 'Mention d''édition', '', 1, 0, '', 'FA'),
('210', 'Publication, production, diffusion, etc.', 'Editeur', 1, 0, '', 'FA'),
('225', 'collection', 'collection', 1, 0, '', 'FA'),
('995', 'Exemplaires', '', 0, 0, '', 'FA');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
('000', '@', 'leader', '', 0, 0, '', 0, '', '', 'unimarc_leader.pl', NULL, 0, 'FA', '', NULL, ''),
('001', '@', 'Numéro d&#39;identification notice','',0,0,'biblio.biblionumber',0,'','','',0,0,'FA','','',NULL),
('090', '9', 'Numéro biblio (koha)','Numéro biblio (koha)',0,0,'',-1,'','','',0,0,'FA','','',NULL),
('090', 'a', 'Numéro biblioitem (koha)','',0,0,'biblioitems.biblioitemnumber',-1,'','','',0,0,'FA','','',NULL),
('100', 'a', 'données générales de traitement', '', 0, 1, '', 1, '', '', 'unimarc_field_100.pl', NULL, 0, 'FA', '', NULL, ''),
('200', '5', 'nom de l''institution à laquelle s''applique cette zone', '', 0, 0, '', -1, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'a', 'titre propre', '', 1, 1, 'biblio.title', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'b', 'type de document', '', 1, 1, 'biblioitems.itemtype', 2, 'itemtypes', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'c', 'titre propre d''un auteur différent', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'd', 'titre parallèle', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'e', 'complément du titre', '', 1, 0, 'biblioitems.volume', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'f', '1ère mention de resp.', 'Auteur', 1, 0, 'biblio.author', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'g', 'mention de responsabilité suivante', 'Auteur secondaire', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'h', 'numéro de partie', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'i', 'titre de partie', '', 1, 0, 'biblio.unititle', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'v', 'numéro du volume', '', 0, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'z', 'langue du titre parallèle', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('205', 'a', 'mention d''édition', '', 0, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('205', 'b', 'autre mention d''édition', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('205', 'd', 'mention parallèle d''édition', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('205', 'f', 'mention de responsabilitérelative à l''édition', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('205', 'g', 'mention de responsabilité suivante', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'a', 'lieu de publication', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'b', 'adresse de l''éditeur, du diffuseur', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'c', 'nom de l''éditeur', '', 1, 0, 'biblioitems.publishercode', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'd', 'date de publication', '', 1, 0, 'biblioitems.publicationyear', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'e', 'lieu de fabrication', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'f', 'adresse du fabricant', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'g', 'nom du fabricant', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'h', 'date de fabrication', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'a', 'titre de la collection', '', 0, 0, 'biblioitems.collectiontitle', 2, '', '', 'unimarc_field_225a.pl', 0, 0, 'FA', NULL, '', ''),
('225', 'd', 'titre parallèle de la collection', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'e', 'complément du titre', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'f', 'mention de responsabilité', '', 1, 0, 'biblioitems.editionresponsibility', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'h', 'numéro de partie', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'i', 'titre de partie', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'v', 'numérotation du volume', '', 1, 0, 'biblioitems.collectionvolume', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'x', 'ISSN de la collection', '', 1, 0, 'biblioitems.collectionissn', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'z', 'langue du titre parallèle', '', 1, 0, '', 2, '', '', '', 0, 0, 'FA', NULL, '', ''),
('995', '2', 'Perdu', '', 0, 0, 'items.itemlost', 10, 'LOST', '', '', NULL, 1, 'FA', NULL, NULL, ''),
('995', '9', 'itemnumber (koha)', '', 0, 0, 'items.itemnumber', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'a', 'origine du document, texte libre', '', 0, 1, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'b', 'Propriétaire', '', 0, 1, 'items.homebranch', 10, 'branches', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'c', 'dépositaire permanent', '', 0, 1, 'items.holdingbranch', 10, 'branches', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'd', 'Etablissement prêteur ou déposant, donnée codée', '', 0, 0, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'e', 'niveau de localisation', '', 0, 1, 'items.location', 10, 'LOC', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'f', 'Code barre', '', 0, 0, 'items.barcode', 10, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'g', 'code à barres, préfixe', '', 0, 0, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'h', 'code à barres, incrémentation', '', 0, 0, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'i', 'code à barres, suffixe', '', 0, 0, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'j', 'Numéro Inventaire', '', 0, 0, 'items.stocknumber', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'k', 'cote', 'cote', 0, 1, 'items.itemcallnumber', 10, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'l', 'volumaison', '', 0, 1, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'm', 'date de prêt ou de dépôt', '', 0, 0, '', 10, '', '', '', NULL, 1, 'FA', NULL, NULL, ''),
('995', 'n', 'date de restitution prévue', 'à rendre pour le', 0, 0, 'items.onloan', 10, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'o', 'Statut', '', 0, 1, 'items.notforloan', 10, 'ETAT', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'q', 'public visé', '', 0, 0, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'r', 'type de document et support matériel', '', 0, 1, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 's', 'élément de tri', '', 0, 1, '', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'u', 'note', '', 0, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'FA', NULL, NULL, ''); 

