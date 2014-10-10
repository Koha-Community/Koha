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
('099','Type de document','Type de document',0,0,'','FA'),
('100', 'Données générales de traitement', '', 0, 1, '', 'FA'),
('200', 'Titre et mention de responsabilité', 'Titre', 0, 1, '', 'FA'),
('205', 'Mention d''édition', '', 1, 0, '', 'FA'),
('210', 'Publication, production, diffusion, etc.', 'Editeur', 1, 0, '', 'FA'),
('225', 'collection', 'collection', 1, 0, '', 'FA'),
('995', 'Exemplaires', '', 0, 0, '', 'FA');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
('000', '@', 'leader', '', 0, 0, '', 1, '', '', 'unimarc_leader.pl', NULL, 0, 'FA', '', NULL, '     nam         3  4500'),
('001', '@', 'numéro d&#39;identification notice','',0,0,'biblio.biblionumber',1,'','','',0,0,'FA','','',NULL),
('090', '9', 'numéro biblio (koha)','Numéro biblio (koha)',0,0,'',-1,'','','',0,0,'FA','','',NULL),
('090', 'a', 'numéro biblioitem (koha)','',0,0,'biblioitems.biblioitemnumber',-1,'','','',0,0,'FA','','',NULL),
('099', 't', 'type de document','',0,0,'biblioitems.itemtypes',0,'itemtypes','','',0,0,'FA','','',NULL),
('100', 'a', 'données générales de traitement', '', 0, 1, '', 1, '', '', 'unimarc_field_100.pl', NULL, 0, 'FA', '', NULL, 'YYYYMMDDd        u||y0frey50      ba'),
('200', 'a', 'titre propre', '', 1, 1, 'biblio.title', 0, '', '', '', 0, 0, 'FA', NULL, '', ''),
('200', 'f', '1ère mention de resp.', 'Auteur', 1, 0, 'biblio.author', 0, '', '', '', 0, 0, 'FA', NULL, '', ''),
('205', 'a', 'mention d''édition', '', 0, 0, '', 0, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'a', 'lieu de publication', '', 1, 0, '', 0, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'c', 'nom de l''éditeur', '', 1, 0, 'biblioitems.publishercode', 0, '', '', '', 0, 0, 'FA', NULL, '', ''),
('210', 'd', 'date de publication', '', 1, 0, 'biblioitems.publicationyear', 0, '', '', '', 0, 0, 'FA', NULL, '', ''),
('225', 'a', 'titre de la collection', '', 0, 0, 'biblioitems.collectiontitle', 0, '', '', 'unimarc_field_225a.pl', 0, 0, 'FA', NULL, '', ''),
('995', '9', 'itemnumber (koha)', '', 0, 0, 'items.itemnumber', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'b', 'propriétaire', '', 0, 1, 'items.homebranch', 10, 'branches', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'c', 'dépositaire permanent', '', 0, 1, 'items.holdingbranch', 10, 'branches', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'e', 'niveau de localisation', '', 0, 1, 'items.location', 10, 'LOC', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'f', 'code barre', '', 0, 0, 'items.barcode', 10, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'j', 'numéro d''inventaire', '', 0, 0, 'items.stocknumber', -1, '', '', '', NULL, 0, 'FA', NULL, NULL, ''),
('995', 'k', 'cote', 'cote', 0, 1, 'items.itemcallnumber', 10, '', '', '', NULL, 0, 'FA', NULL, NULL, '');

