-- phpMyAdmin SQL Dump
-- version 2.9.0.2
-- http://www.phpmyadmin.net
-- 
-- Serveur: localhost
-- Généré le : Mardi 06 Février 2007 à 15:21
-- Version du serveur: 4.1.12
-- Version de PHP: 5.0.4
-- 
-- Base de données: `Kohazebratest`
-- 

-- --------------------------------------------------------

-- 
-- Structure de la table `accountlines`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `accountlines`;
CREATE TABLE IF NOT EXISTS `accountlines` (
  `borrowernumber` int(11) NOT NULL default '0',
  `accountno` smallint(6) NOT NULL default '0',
  `itemnumber` int(11) default NULL,
  `date` date default NULL,
  `amount` decimal(28,6) default NULL,
  `description` text,
  `dispute` text,
  `accounttype` varchar(5) default NULL,
  `amountoutstanding` decimal(28,6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `notify_id` int(11) NOT NULL default '0',
  `notify_level` int(2) NOT NULL default '0',
  KEY `acctsborridx` (`borrowernumber`),
  KEY `timeidx` (`timestamp`),
  KEY `itemnumber` (`itemnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `accountoffsets`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:56
-- 

DROP TABLE IF EXISTS `accountoffsets`;
CREATE TABLE IF NOT EXISTS `accountoffsets` (
  `borrowernumber` int(11) NOT NULL default '0',
  `accountno` smallint(6) NOT NULL default '0',
  `offsetaccount` smallint(6) NOT NULL default '0',
  `offsetamount` decimal(28,6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `action_logs`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:56
-- 

DROP TABLE IF EXISTS `action_logs`;
CREATE TABLE IF NOT EXISTS `action_logs` (
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` int(11) NOT NULL default '0',
  `module` text,
  `action` text,
  `object` int(11) default '0',
  `info` text,
  PRIMARY KEY  (`timestamp`,`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `alert`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:56
-- 

DROP TABLE IF EXISTS `alert`;
CREATE TABLE IF NOT EXISTS `alert` (
  `alertid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) NOT NULL default '0',
  `type` varchar(10) NOT NULL default '',
  `externalid` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`alertid`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `type` (`type`,`externalid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqbasket`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `aqbasket`;
CREATE TABLE IF NOT EXISTS `aqbasket` (
  `basketno` int(11) NOT NULL auto_increment,
  `creationdate` date default NULL,
  `closedate` date default NULL,
  `booksellerid` int(11) NOT NULL default '1',
  `authorisedby` varchar(10) default NULL,
  `booksellerinvoicenumber` text,
  PRIMARY KEY  (`basketno`),
  KEY `booksellerid` (`booksellerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqbookfund`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `aqbookfund`;
CREATE TABLE IF NOT EXISTS `aqbookfund` (
  `bookfundid` varchar(5) NOT NULL default '''''',
  `bookfundname` text,
  `bookfundgroup` varchar(5) default NULL,
  `branchcode` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`bookfundid`,`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqbooksellers`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `aqbooksellers`;
CREATE TABLE IF NOT EXISTS `aqbooksellers` (
  `id` int(11) NOT NULL default '0',
  `name` text,
  `address1` text,
  `address2` text,
  `address3` text,
  `address4` text,
  `phone` varchar(30) default NULL,
  `accountnumber` text,
  `othersupplier` text,
  `currency` varchar(3) NOT NULL default '',
  `deliverydays` smallint(6) default NULL,
  `followupdays` smallint(6) default NULL,
  `followupscancel` smallint(6) default NULL,
  `specialty` text,
  `booksellerfax` text,
  `notes` text,
  `bookselleremail` text,
  `booksellerurl` text,
  `contact` varchar(100) default NULL,
  `postal` text,
  `url` varchar(255) default NULL,
  `contpos` varchar(100) default NULL,
  `contphone` varchar(100) default NULL,
  `contfax` varchar(100) default NULL,
  `contaltphone` varchar(100) default NULL,
  `contemail` varchar(100) default NULL,
  `contnotes` text,
  `active` tinyint(4) default NULL,
  `listprice` varchar(10) default '',
  `invoiceprice` varchar(10) default '',
  `gstreg` tinyint(4) default NULL,
  `listincgst` tinyint(4) default NULL,
  `invoiceincgst` tinyint(4) default NULL,
  `discount` float(6,4) default NULL,
  `fax` varchar(50) default NULL,
  `nocalc` int(11) default NULL,
  `invoicedisc` float(6,4) default NULL,
  PRIMARY KEY  (`id`),
  KEY `listprice` (`listprice`),
  KEY `invoiceprice` (`invoiceprice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqbudget`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:56
-- 

DROP TABLE IF EXISTS `aqbudget`;
CREATE TABLE IF NOT EXISTS `aqbudget` (
  `bookfundid` varchar(5) NOT NULL default '',
  `startdate` date NOT NULL default '0000-00-00',
  `enddate` date default NULL,
  `budgetamount` decimal(13,2) default NULL,
  `aqbudgetid` tinyint(4) NOT NULL auto_increment,
  `branchcode` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`aqbudgetid`,`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqorderbreakdown`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:41
-- 

DROP TABLE IF EXISTS `aqorderbreakdown`;
CREATE TABLE IF NOT EXISTS `aqorderbreakdown` (
  `ordernumber` int(11) default NULL,
  `linenumber` int(11) default NULL,
  `branchcode` char(4) default NULL,
  `bookfundid` char(5) NOT NULL default '',
  `allocation` smallint(6) default NULL,
  KEY `ordernumber` (`ordernumber`),
  KEY `bookfundid` (`bookfundid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqorderdelivery`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:56
-- 

DROP TABLE IF EXISTS `aqorderdelivery`;
CREATE TABLE IF NOT EXISTS `aqorderdelivery` (
  `ordernumber` date NOT NULL default '0000-00-00',
  `deliverynumber` smallint(6) NOT NULL default '0',
  `deliverydate` varchar(18) default NULL,
  `qtydelivered` smallint(6) default NULL,
  `deliverycomments` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqorders`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:41
-- 

DROP TABLE IF EXISTS `aqorders`;
CREATE TABLE IF NOT EXISTS `aqorders` (
  `ordernumber` int(11) NOT NULL auto_increment,
  `biblionumber` int(11) default NULL,
  `title` text,
  `entrydate` date default NULL,
  `quantity` smallint(6) default NULL,
  `currency` varchar(3) default NULL,
  `listprice` decimal(28,6) default NULL,
  `totalamount` decimal(28,6) default NULL,
  `datereceived` date default NULL,
  `booksellerinvoicenumber` text,
  `freight` decimal(28,6) default NULL,
  `unitprice` decimal(28,6) default NULL,
  `quantityreceived` smallint(6) default NULL,
  `cancelledby` varchar(10) default NULL,
  `datecancellationprinted` date default NULL,
  `notes` text,
  `supplierreference` text,
  `purchaseordernumber` text,
  `subscription` tinyint(1) default NULL,
  `serialid` varchar(30) default NULL,
  `basketno` int(11) default NULL,
  `biblioitemnumber` int(11) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `rrp` decimal(13,2) default NULL,
  `ecost` decimal(13,2) default NULL,
  `gst` decimal(13,2) default NULL,
  `budgetdate` date default NULL,
  `sort1` varchar(80) default NULL,
  `sort2` varchar(80) default NULL,
  PRIMARY KEY  (`ordernumber`),
  KEY `basketno` (`basketno`),
  KEY `biblionumber` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_header`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:56
-- 

DROP TABLE IF EXISTS `auth_header`;
CREATE TABLE IF NOT EXISTS `auth_header` (
  `authid` bigint(20) unsigned NOT NULL auto_increment,
  `authtypecode` varchar(10) NOT NULL default '',
  `datecreated` date NOT NULL default '0000-00-00',
  `datemodified` date default NULL,
  `origincode` varchar(20) default NULL,
  `marc` blob,
  `linkid` bigint(20) default NULL,
  `authtrees` text,
  `marcxml` text NOT NULL,
  PRIMARY KEY  (`authid`),
  KEY `origincode` (`origincode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_subfield_structure`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `auth_subfield_structure`;
CREATE TABLE IF NOT EXISTS `auth_subfield_structure` (
  `authtypecode` varchar(10) NOT NULL default '',
  `tagfield` varchar(3) NOT NULL default '',
  `tagsubfield` char(1) NOT NULL default '',
  `liblibrarian` varchar(255) NOT NULL default '',
  `libopac` varchar(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default '0',
  `mandatory` tinyint(4) NOT NULL default '0',
  `tab` tinyint(1) default NULL,
  `authorised_value` varchar(10) default NULL,
  `value_builder` varchar(80) default NULL,
  `seealso` varchar(255) default NULL,
  `hidden` tinyint(1) unsigned NOT NULL default '0',
  `isurl` tinyint(1) unsigned NOT NULL default '0',
  `link` varchar(80) default NULL,
  `frameworkcode` varchar(8) NOT NULL default '',
  `kohafield` varchar(40) default NULL,
  `linkid` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`authtypecode`,`tagfield`,`tagsubfield`),
  KEY `tab` (`authtypecode`,`tab`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_subfield_table`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:56
-- 

DROP TABLE IF EXISTS `auth_subfield_table`;
CREATE TABLE IF NOT EXISTS `auth_subfield_table` (
  `subfieldid` bigint(20) unsigned NOT NULL auto_increment,
  `authid` bigint(20) unsigned NOT NULL default '0',
  `tag` varchar(3) NOT NULL default '',
  `tagorder` tinyint(4) NOT NULL default '1',
  `tag_indicator` varchar(2) NOT NULL default '',
  `subfieldcode` char(1) NOT NULL default '',
  `subfieldorder` tinyint(4) NOT NULL default '1',
  `subfieldvalue` varchar(255) default NULL,
  PRIMARY KEY  (`subfieldid`),
  KEY `authid` (`authid`),
  KEY `tag` (`tag`),
  KEY `subfieldcode` (`subfieldcode`),
  KEY `subfieldvalue` (`subfieldvalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_tag_structure`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:41
-- 

DROP TABLE IF EXISTS `auth_tag_structure`;
CREATE TABLE IF NOT EXISTS `auth_tag_structure` (
  `authtypecode` char(10) NOT NULL default '',
  `tagfield` char(3) NOT NULL default '',
  `liblibrarian` char(255) NOT NULL default '',
  `libopac` char(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default '0',
  `mandatory` tinyint(4) NOT NULL default '0',
  `authorised_value` char(10) default NULL,
  PRIMARY KEY  (`authtypecode`,`tagfield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_types`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:56
-- 

DROP TABLE IF EXISTS `auth_types`;
CREATE TABLE IF NOT EXISTS `auth_types` (
  `authtypecode` varchar(10) NOT NULL default '',
  `authtypetext` varchar(255) NOT NULL default '',
  `auth_tag_to_report` varchar(3) NOT NULL default '',
  `summary` text NOT NULL,
  PRIMARY KEY  (`authtypecode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_word`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `auth_word`;
CREATE TABLE IF NOT EXISTS `auth_word` (
  `authid` bigint(20) NOT NULL default '0',
  `tagsubfield` varchar(4) NOT NULL default '',
  `tagorder` tinyint(4) NOT NULL default '1',
  `subfieldorder` tinyint(4) NOT NULL default '1',
  `word` varchar(255) NOT NULL default '',
  `sndx_word` varchar(255) NOT NULL default '',
  KEY `authid` (`authid`),
  KEY `marc_search` (`tagsubfield`,`word`),
  KEY `word` (`word`),
  KEY `sndx_word` (`sndx_word`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `authorised_values`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `authorised_values`;
CREATE TABLE IF NOT EXISTS `authorised_values` (
  `id` int(11) NOT NULL auto_increment,
  `category` char(10) NOT NULL default '',
  `authorised_value` char(80) NOT NULL default '',
  `lib` char(80) default NULL,
  PRIMARY KEY  (`id`),
  KEY `name` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `biblio`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `biblio`;
CREATE TABLE IF NOT EXISTS `biblio` (
  `biblionumber` int(11) NOT NULL default '0',
  `author` text,
  `title` text,
  `unititle` text,
  `notes` text,
  `serial` tinyint(1) default NULL,
  `seriestitle` text,
  `copyrightdate` smallint(6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `abstract` text,
  `frameworkcode` varchar(4) default NULL,
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `biblio_framework`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `biblio_framework`;
CREATE TABLE IF NOT EXISTS `biblio_framework` (
  `frameworkcode` char(4) NOT NULL default '',
  `frameworktext` char(255) NOT NULL default '',
  PRIMARY KEY  (`frameworkcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `biblioanalysis`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `biblioanalysis`;
CREATE TABLE IF NOT EXISTS `biblioanalysis` (
  `analyticaltitle` text,
  `biblionumber` int(11) NOT NULL default '0',
  `analyticalauthor` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `biblioitems`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `biblioitems`;
CREATE TABLE IF NOT EXISTS `biblioitems` (
  `biblioitemnumber` int(11) NOT NULL default '0',
  `biblionumber` int(11) NOT NULL default '0',
  `volume` text,
  `number` text,
  `classification` varchar(25) default NULL,
  `itemtype` varchar(4) default NULL,
  `isbn` varchar(14) default NULL,
  `issn` varchar(9) default NULL,
  `dewey` varchar(30) default '',
  `subclass` varchar(3) default NULL,
  `publicationyear` smallint(6) default NULL,
  `publishercode` varchar(255) default NULL,
  `volumedate` date default NULL,
  `volumeddesc` varchar(255) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL,
  `pages` varchar(255) default NULL,
  `notes` text,
  `size` varchar(255) default NULL,
  `place` varchar(255) default NULL,
  `lccn` varchar(25) default NULL,
  `marc` blob,
  `url` varchar(255) default NULL,
  `marcxml` text,
  `lcsort` varchar(25) default NULL,
  `ccode` varchar(4) default '',
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `itemtype` (`itemtype`),
  KEY `isbn` (`isbn`),
  KEY `publishercode` (`publishercode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `bibliothesaurus`
-- 
-- Création: Mercredi 04 Octobre 2006 à 23:21
-- Dernière modification: Mercredi 04 Octobre 2006 à 23:21
-- Dernière vérification: Mercredi 04 Octobre 2006 à 23:21
-- 

DROP TABLE IF EXISTS `bibliothesaurus`;
CREATE TABLE IF NOT EXISTS `bibliothesaurus` (
  `id` bigint(20) NOT NULL auto_increment,
  `freelib` char(255) NOT NULL default '',
  `stdlib` char(255) NOT NULL default '',
  `category` char(10) NOT NULL default '',
  `level` tinyint(4) NOT NULL default '1',
  `hierarchy` char(80) NOT NULL default '',
  `father` char(80) NOT NULL default '',
  PRIMARY KEY  (`id`),
  KEY `freelib` (`freelib`),
  KEY `stdlib` (`stdlib`),
  KEY `category` (`category`),
  KEY `hierarchy` (`hierarchy`),
  KEY `category_2` (`category`,`freelib`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `bookshelf`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `bookshelf`;
CREATE TABLE IF NOT EXISTS `bookshelf` (
  `shelfnumber` int(11) NOT NULL auto_increment,
  `shelfname` char(255) default NULL,
  `owner` char(80) default NULL,
  `category` char(1) default NULL,
  PRIMARY KEY  (`shelfnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `borexp`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `borexp`;
CREATE TABLE IF NOT EXISTS `borexp` (
  `borrowernumber` int(11) default NULL,
  `newexp` date default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `borrowers`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `borrowers`;
CREATE TABLE IF NOT EXISTS `borrowers` (
  `borrowernumber` int(11) NOT NULL auto_increment,
  `cardnumber` varchar(16) NOT NULL default '',
  `surname` text NOT NULL,
  `firstname` text,
  `title` text,
  `othernames` text,
  `initials` text,
  `streetnumber` varchar(10) default NULL,
  `streettype` varchar(50) default NULL,
  `address` text NOT NULL,
  `address2` text,
  `city` text NOT NULL,
  `zipcode` varchar(25) default NULL,
  `email` text,
  `phone` text,
  `mobile` varchar(50) default NULL,
  `fax` text,
  `B_streetnumber` varchar(10) default NULL,
  `B_streettype` varchar(50) default NULL,
  `emailpro` text,
  `phonepro` text,
  `B_address` varchar(100) default NULL,
  `B_city` text,
  `B_zipcode` varchar(25) default NULL,
  `B_email` text,
  `B_phone` text,
  `dateofbirth` date default NULL,
  `branchcode` varchar(10) NOT NULL default '',
  `categorycode` varchar(10) NOT NULL default '',
  `dateenrolled` date default NULL,
  `dateexpiry` date default NULL,
  `gonenoaddress` tinyint(1) default NULL,
  `lost` tinyint(1) default NULL,
  `debarred` tinyint(1) default NULL,
  `contactname` text,
  `contactfirstname` text,
  `contacttitle` text,
  `guarantorid` int(11) default NULL,
  `borrowernotes` text,
  `relationship` varchar(100) default NULL,
  `ethnicity` varchar(50) default NULL,
  `ethnotes` varchar(255) default NULL,
  `sex` char(1) default NULL,
  `password` varchar(30) default NULL,
  `flags` int(11) default NULL,
  `userid` varchar(30) default NULL,
  `opacnote` text,
  `contactnote` varchar(255) default NULL,
  `sort1` varchar(80) default NULL,
  `sort2` varchar(80) default NULL,
  `textmessaging` varchar(30) default NULL,
  `homezipcode` varchar(25) default NULL,
  UNIQUE KEY `cardnumber` (`cardnumber`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `borrowers_to_borrowers`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `borrowers_to_borrowers`;
CREATE TABLE IF NOT EXISTS `borrowers_to_borrowers` (
  `borrower1` int(11) default NULL,
  `borrower2` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `branchcategories`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `branchcategories`;
CREATE TABLE IF NOT EXISTS `branchcategories` (
  `categorycode` varchar(4) NOT NULL default '',
  `categoryname` text,
  `codedescription` text,
  PRIMARY KEY  (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `branches`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `branches`;
CREATE TABLE IF NOT EXISTS `branches` (
  `branchcode` varchar(10) NOT NULL default '',
  `branchname` text NOT NULL,
  `branchaddress1` text,
  `branchaddress2` text,
  `branchaddress3` text,
  `branchphone` text,
  `branchfax` text,
  `branchemail` text,
  `issuing` tinyint(4) default NULL,
  `branchip` varchar(15) default '',
  `branchprinter` varchar(100) default '',
  UNIQUE KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `branchrelations`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `branchrelations`;
CREATE TABLE IF NOT EXISTS `branchrelations` (
  `branchcode` varchar(4) default NULL,
  `categorycode` varchar(4) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `branchtransfers`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `branchtransfers`;
CREATE TABLE IF NOT EXISTS `branchtransfers` (
  `itemnumber` int(11) NOT NULL default '0',
  `datesent` datetime default NULL,
  `frombranch` varchar(10) NOT NULL default '',
  `datearrived` datetime default NULL,
  `tobranch` varchar(10) NOT NULL default '',
  `comments` text,
  KEY `frombranch` (`frombranch`),
  KEY `tobranch` (`tobranch`),
  KEY `itemnumber` (`itemnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `catalogueentry`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `catalogueentry`;
CREATE TABLE IF NOT EXISTS `catalogueentry` (
  `catalogueentry` text NOT NULL,
  `entrytype` varchar(2) default NULL,
  `see` text,
  `seealso` text,
  `seeinstead` text,
  `biblionumber` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `categories`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `categorycode` varchar(10) NOT NULL default '',
  `description` text,
  `enrolmentperiod` smallint(6) default NULL,
  `upperagelimit` smallint(6) default NULL,
  `dateofbirthrequired` tinyint(1) default NULL,
  `finetype` varchar(30) default NULL,
  `bulk` tinyint(1) default NULL,
  `enrolmentfee` decimal(28,6) default NULL,
  `overduenoticerequired` tinyint(1) default NULL,
  `issuelimit` smallint(6) default NULL,
  `reservefee` decimal(28,6) default NULL,
  `category_type` char(1) NOT NULL default 'A',
  PRIMARY KEY  (`categorycode`),
  UNIQUE KEY `categorycode` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `categorytable`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `categorytable`;
CREATE TABLE IF NOT EXISTS `categorytable` (
  `categorycode` varchar(5) NOT NULL default '',
  `description` text,
  `itemtypecodes` text,
  PRIMARY KEY  (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `charges`
-- 
-- Création: Vendredi 08 Décembre 2006 à 16:47
-- 

DROP TABLE IF EXISTS `charges`;
CREATE TABLE IF NOT EXISTS `charges` (
  `charge_id` varchar(5) NOT NULL default '',
  `description` text NOT NULL,
  `amount` decimal(28,6) NOT NULL default '0.000000',
  `min` int(4) NOT NULL default '0',
  `max` int(4) NOT NULL default '0',
  `level` int(1) NOT NULL default '0',
  PRIMARY KEY  (`charge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `cities`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `cities`;
CREATE TABLE IF NOT EXISTS `cities` (
  `cityid` int(11) NOT NULL auto_increment,
  `city_name` char(100) NOT NULL default '',
  `city_zipcode` char(20) default NULL,
  PRIMARY KEY  (`cityid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `currency`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `currency`;
CREATE TABLE IF NOT EXISTS `currency` (
  `currency` varchar(10) NOT NULL default '',
  `rate` float(7,5) default NULL,
  PRIMARY KEY  (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `deletedbiblio`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `deletedbiblio`;
CREATE TABLE IF NOT EXISTS `deletedbiblio` (
  `biblionumber` int(11) NOT NULL default '0',
  `author` text,
  `title` text,
  `unititle` text,
  `notes` text,
  `serial` tinyint(1) default NULL,
  `seriestitle` text,
  `copyrightdate` smallint(6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `marc` blob,
  `abstract` text,
  `frameworkcode` varchar(4) default NULL,
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `deletedbiblioitems`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:40
-- 

DROP TABLE IF EXISTS `deletedbiblioitems`;
CREATE TABLE IF NOT EXISTS `deletedbiblioitems` (
  `biblioitemnumber` int(11) NOT NULL default '0',
  `biblionumber` int(11) NOT NULL default '0',
  `volume` text,
  `number` text,
  `classification` varchar(25) default NULL,
  `itemtype` varchar(4) default NULL,
  `isbn` varchar(14) default NULL,
  `issn` varchar(9) default NULL,
  `dewey` double(8,6) default NULL,
  `subclass` varchar(3) default NULL,
  `publicationyear` smallint(6) default NULL,
  `publishercode` varchar(255) default NULL,
  `volumedate` date default NULL,
  `volumeddesc` varchar(255) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL,
  `pages` varchar(255) default NULL,
  `notes` text,
  `size` varchar(255) default NULL,
  `lccn` varchar(25) default NULL,
  `marc` text,
  `url` varchar(255) default NULL,
  `place` varchar(255) default NULL,
  `marcxml` text,
  `lcsort` varchar(25) default NULL,
  `ccode` varchar(4) default NULL,
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `deletedborrowers`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `deletedborrowers`;
CREATE TABLE IF NOT EXISTS `deletedborrowers` (
  `borrowernumber` int(11) NOT NULL default '0',
  `cardnumber` varchar(9) NOT NULL default '',
  `surname` text NOT NULL,
  `firstname` text,
  `title` text,
  `othernames` text,
  `initials` text,
  `streetnumber` varchar(10) default NULL,
  `streettype` varchar(50) default NULL,
  `address` text NOT NULL,
  `address2` text,
  `city` text NOT NULL,
  `zipcode` varchar(25) default NULL,
  `email` text,
  `phone` text,
  `mobile` varchar(50) default NULL,
  `fax` text,
  `B_streetnumber` varchar(10) default NULL,
  `B_streettype` varchar(50) default NULL,
  `emailpro` text,
  `phonepro` text,
  `B_address` varchar(100) default NULL,
  `B_city` text,
  `B_zipcode` varchar(25) default NULL,
  `B_email` text,
  `B_phone` text,
  `dateofbirth` date default NULL,
  `branchcode` varchar(4) NOT NULL default '',
  `categorycode` varchar(2) default NULL,
  `dateenrolled` date default NULL,
  `dateexpiry` date default NULL,
  `gonenoaddress` tinyint(1) default NULL,
  `lost` tinyint(1) default NULL,
  `debarred` tinyint(1) default NULL,
  `contactname` text,
  `contactfirstname` text,
  `contacttitle` text,
  `guarantorid` int(11) default NULL,
  `borrowernotes` text,
  `relationship` varchar(100) default NULL,
  `ethnicity` varchar(50) default NULL,
  `ethnotes` varchar(255) default NULL,
  `sex` char(1) default NULL,
  `password` varchar(30) default NULL,
  `flags` int(11) default NULL,
  `userid` varchar(30) default NULL,
  `opacnote` text,
  `contactnote` varchar(255) default NULL,
  `sort1` varchar(80) default NULL,
  `sort2` varchar(80) default NULL,
  `textmessaging` varchar(30) default NULL,
  `homezipcode` varchar(25) default NULL,
  KEY `borrowernumber` (`borrowernumber`),
  KEY `cardnumber` (`cardnumber`),
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `deleteditems`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:40
-- 

DROP TABLE IF EXISTS `deleteditems`;
CREATE TABLE IF NOT EXISTS `deleteditems` (
  `itemnumber` int(11) NOT NULL default '0',
  `biblionumber` int(11) NOT NULL default '0',
  `multivolumepart` varchar(30) default NULL,
  `biblioitemnumber` int(11) NOT NULL default '0',
  `barcode` varchar(9) NOT NULL default '',
  `dateaccessioned` date default NULL,
  `booksellerid` varchar(10) default NULL,
  `homebranch` varchar(4) default NULL,
  `price` decimal(28,6) default NULL,
  `replacementprice` decimal(28,6) default NULL,
  `replacementpricedate` date default NULL,
  `datelastborrowed` date default NULL,
  `datelastseen` date default NULL,
  `multivolume` tinyint(1) default NULL,
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) default NULL,
  `itemlost` tinyint(1) default NULL,
  `wthdrawn` tinyint(1) default NULL,
  `bulk` varchar(30) default NULL,
  `issues` smallint(6) default NULL,
  `renewals` smallint(6) default NULL,
  `reserves` smallint(6) default NULL,
  `restricted` tinyint(1) default NULL,
  `binding` decimal(28,6) default NULL,
  `itemnotes` text,
  `holdingbranch` varchar(4) default NULL,
  `interim` tinyint(1) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `marc` blob,
  `paidfor` text,
  `location` varchar(80) default NULL,
  `itemcallnumber` varchar(30) default NULL,
  `onloan` date default NULL,
  `Cutterextra` varchar(45) default NULL,
  `issue_date` date default '0000-00-00',
  `itype` varchar(10) default NULL,
  PRIMARY KEY  (`itemnumber`),
  UNIQUE KEY `barcode` (`barcode`),
  KEY `itembarcodeidx` (`barcode`),
  KEY `itembinoidx` (`biblioitemnumber`),
  KEY `itembibnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `ethnicity`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `ethnicity`;
CREATE TABLE IF NOT EXISTS `ethnicity` (
  `code` varchar(10) NOT NULL default '',
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `issues`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `issues`;
CREATE TABLE IF NOT EXISTS `issues` (
  `borrowernumber` int(11) default '0',
  `itemnumber` int(11) default '0',
  `date_due` date default NULL,
  `branchcode` varchar(10) default '',
  `issuingbranch` varchar(18) default NULL,
  `issuedate` date NOT NULL default '0000-00-00',
  `returndate` date default NULL,
  `lastreneweddate` date default NULL,
  `return` varchar(4) default NULL,
  `renewals` tinyint(4) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  KEY `issuesborridx` (`borrowernumber`),
  KEY `issuesitemidx` (`itemnumber`),
  KEY `bordate` (`borrowernumber`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `issuingrules`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:41
-- 

DROP TABLE IF EXISTS `issuingrules`;
CREATE TABLE IF NOT EXISTS `issuingrules` (
  `categorycode` varchar(2) NOT NULL default '',
  `itemtype` varchar(4) NOT NULL default '',
  `restrictedtype` tinyint(1) default NULL,
  `rentaldiscount` decimal(28,6) default NULL,
  `reservecharge` decimal(28,6) default NULL,
  `fine` decimal(28,6) default NULL,
  `firstremind` int(11) default NULL,
  `chargeperiod` int(11) default NULL,
  `accountsent` int(11) default NULL,
  `chargename` varchar(100) default NULL,
  `maxissueqty` int(4) default NULL,
  `issuelength` int(4) default NULL,
  `branchcode` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`branchcode`,`categorycode`,`itemtype`),
  KEY `categorycode` (`categorycode`),
  KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `items`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `items`;
CREATE TABLE IF NOT EXISTS `items` (
  `itemnumber` int(11) NOT NULL default '0',
  `biblionumber` int(11) NOT NULL default '0',
  `multivolumepart` varchar(30) default NULL,
  `biblioitemnumber` int(11) NOT NULL default '0',
  `barcode` varchar(20) default NULL,
  `dateaccessioned` date default NULL,
  `booksellerid` varchar(10) default NULL,
  `homebranch` varchar(4) default NULL,
  `price` decimal(8,2) default NULL,
  `replacementprice` decimal(8,2) default NULL,
  `replacementpricedate` date default NULL,
  `datelastborrowed` date default NULL,
  `datelastseen` date default NULL,
  `multivolume` tinyint(1) default NULL,
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) default '0',
  `itemlost` tinyint(1) default NULL,
  `wthdrawn` tinyint(1) default NULL,
  `itemcallnumber` varchar(30) default NULL,
  `issues` smallint(6) default NULL,
  `renewals` smallint(6) default NULL,
  `reserves` smallint(6) default NULL,
  `restricted` tinyint(1) default NULL,
  `binding` decimal(28,6) default NULL,
  `itemnotes` text,
  `holdingbranch` varchar(10) default '',
  `paidfor` text,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `location` varchar(80) default NULL,
  `onloan` date default NULL,
  `Cutterextra` varchar(45) default NULL,
  `issue_date` date default '0000-00-00',
  `itype` varchar(10) default '',
  PRIMARY KEY  (`itemnumber`),
  KEY `itembarcodeidx` (`barcode`),
  KEY `itembinoidx` (`biblioitemnumber`),
  KEY `itembibnoidx` (`biblionumber`),
  KEY `homebranch` (`homebranch`),
  KEY `holdingbranch` (`holdingbranch`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `itemsprices`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `itemsprices`;
CREATE TABLE IF NOT EXISTS `itemsprices` (
  `itemnumber` int(11) default NULL,
  `price1` decimal(28,6) default NULL,
  `price2` decimal(28,6) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `itemtypes`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `itemtypes`;
CREATE TABLE IF NOT EXISTS `itemtypes` (
  `itemtype` varchar(10) NOT NULL default '',
  `description` text,
  `renewalsallowed` smallint(6) default NULL,
  `rentalcharge` double(16,4) default NULL,
  `notforloan` smallint(6) default '0',
  `imageurl` varchar(200) default NULL,
  `summary` text,
  PRIMARY KEY  (`itemtype`),
  UNIQUE KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `labels`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `labels`;
CREATE TABLE IF NOT EXISTS `labels` (
  `labelid` int(11) NOT NULL auto_increment,
  `itemnumber` varchar(100) NOT NULL default '',
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`labelid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `labels_conf`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `labels_conf`;
CREATE TABLE IF NOT EXISTS `labels_conf` (
  `id` int(4) NOT NULL auto_increment,
  `barcodetype` char(100) default '',
  `title` tinyint(1) default '0',
  `isbn` tinyint(1) default '0',
  `itemtype` tinyint(1) default '0',
  `barcode` tinyint(1) default '0',
  `dewey` tinyint(1) default '0',
  `class` tinyint(1) default '0',
  `author` tinyint(1) default '0',
  `papertype` char(100) default '',
  `startrow` int(2) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `letter`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `letter`;
CREATE TABLE IF NOT EXISTS `letter` (
  `module` varchar(20) NOT NULL default '',
  `code` varchar(20) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  `title` varchar(200) NOT NULL default '',
  `content` text,
  PRIMARY KEY  (`module`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_biblio`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `marc_biblio`;
CREATE TABLE IF NOT EXISTS `marc_biblio` (
  `bibid` bigint(20) unsigned NOT NULL auto_increment,
  `biblionumber` int(11) NOT NULL default '0',
  `datecreated` date NOT NULL default '0000-00-00',
  `datemodified` date default NULL,
  `origincode` char(20) default NULL,
  `frameworkcode` char(4) NOT NULL default '',
  PRIMARY KEY  (`bibid`),
  KEY `origincode` (`origincode`),
  KEY `biblionumber` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_blob_subfield`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:57
-- 

DROP TABLE IF EXISTS `marc_blob_subfield`;
CREATE TABLE IF NOT EXISTS `marc_blob_subfield` (
  `blobidlink` bigint(20) NOT NULL auto_increment,
  `subfieldvalue` longtext NOT NULL,
  PRIMARY KEY  (`blobidlink`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_breeding`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:58
-- 

DROP TABLE IF EXISTS `marc_breeding`;
CREATE TABLE IF NOT EXISTS `marc_breeding` (
  `id` bigint(20) NOT NULL auto_increment,
  `file` varchar(80) NOT NULL default '',
  `isbn` varchar(10) NOT NULL default '',
  `title` varchar(128) default NULL,
  `author` varchar(80) default NULL,
  `marc` text NOT NULL,
  `encoding` varchar(40) NOT NULL default '',
  `z3950random` varchar(40) default NULL,
  PRIMARY KEY  (`id`),
  KEY `title` (`title`),
  KEY `isbn` (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_subfield_structure`
-- 
-- Création: Lundi 27 Novembre 2006 à 17:58
-- 

DROP TABLE IF EXISTS `marc_subfield_structure`;
CREATE TABLE IF NOT EXISTS `marc_subfield_structure` (
  `tagfield` varchar(3) NOT NULL default '',
  `tagsubfield` char(1) NOT NULL default '',
  `liblibrarian` varchar(255) NOT NULL default '',
  `libopac` varchar(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default '0',
  `mandatory` tinyint(4) NOT NULL default '0',
  `kohafield` varchar(40) default NULL,
  `tab` tinyint(1) default NULL,
  `authorised_value` varchar(10) default NULL,
  `authtypecode` varchar(10) default NULL,
  `value_builder` varchar(80) default NULL,
  `isurl` tinyint(1) default NULL,
  `hidden` tinyint(1) default NULL,
  `frameworkcode` varchar(4) NOT NULL default '',
  `seealso` varchar(255) default NULL,
  `link` varchar(80) default NULL,
  PRIMARY KEY  (`frameworkcode`,`tagfield`,`tagsubfield`),
  KEY `tab` (`frameworkcode`,`tab`),
  KEY `kohafield` (`frameworkcode`,`kohafield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_subfield_table`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:11
-- 

DROP TABLE IF EXISTS `marc_subfield_table`;
CREATE TABLE IF NOT EXISTS `marc_subfield_table` (
  `subfieldid` bigint(20) unsigned NOT NULL auto_increment,
  `bibid` bigint(20) unsigned NOT NULL default '0',
  `tag` varchar(3) NOT NULL default '',
  `tagorder` int(11) NOT NULL default '1',
  `tag_indicator` varchar(2) NOT NULL default '',
  `subfieldcode` char(1) NOT NULL default '',
  `subfieldorder` tinyint(4) NOT NULL default '1',
  `subfieldvalue` varchar(255) default NULL,
  `valuebloblink` bigint(20) default NULL,
  PRIMARY KEY  (`subfieldid`),
  KEY `bibid` (`bibid`),
  KEY `tag` (`tag`),
  KEY `tag_indicator` (`tag_indicator`),
  KEY `subfieldorder` (`subfieldorder`),
  KEY `subfieldcode` (`subfieldcode`),
  KEY `subfieldvalue` (`subfieldvalue`),
  KEY `tagorder` (`tagorder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_tag_structure`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:11
-- 

DROP TABLE IF EXISTS `marc_tag_structure`;
CREATE TABLE IF NOT EXISTS `marc_tag_structure` (
  `tagfield` char(3) NOT NULL default '',
  `liblibrarian` char(255) NOT NULL default '',
  `libopac` char(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default '0',
  `mandatory` tinyint(4) NOT NULL default '0',
  `authorised_value` char(10) default NULL,
  `frameworkcode` char(4) NOT NULL default '',
  PRIMARY KEY  (`frameworkcode`,`tagfield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_word`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `marc_word`;
CREATE TABLE IF NOT EXISTS `marc_word` (
  `bibid` bigint(20) NOT NULL default '0',
  `tagsubfield` varchar(4) NOT NULL default '',
  `tagorder` tinyint(4) NOT NULL default '1',
  `subfieldorder` tinyint(4) NOT NULL default '1',
  `word` varchar(255) NOT NULL default '',
  `sndx_word` varchar(255) NOT NULL default '',
  KEY `bibid` (`bibid`),
  KEY `tagorder` (`tagorder`),
  KEY `subfieldorder` (`subfieldorder`),
  KEY `word` (`word`),
  KEY `sndx_word` (`sndx_word`),
  KEY `Search_Marc` (`tagsubfield`,`word`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marcrecorddone`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `marcrecorddone`;
CREATE TABLE IF NOT EXISTS `marcrecorddone` (
  `isbn` char(40) default NULL,
  `issn` char(40) default NULL,
  `lccn` char(40) default NULL,
  `controlnumber` char(40) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `mediatypetable`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `mediatypetable`;
CREATE TABLE IF NOT EXISTS `mediatypetable` (
  `mediatypecode` varchar(5) NOT NULL default '',
  `description` text,
  `itemtypecodes` text,
  PRIMARY KEY  (`mediatypecode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `notifys`
-- 
-- Création: Vendredi 08 Décembre 2006 à 16:47
-- 

DROP TABLE IF EXISTS `notifys`;
CREATE TABLE IF NOT EXISTS `notifys` (
  `notify_id` int(11) NOT NULL default '0',
  `borrowernumber` int(11) NOT NULL default '0',
  `itemnumber` int(11) NOT NULL default '0',
  `notify_date` date NOT NULL default '0000-00-00',
  `notify_send_date` date default NULL,
  `notify_level` int(1) NOT NULL default '0',
  `method` varchar(20) NOT NULL default ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `opac_news`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `opac_news`;
CREATE TABLE IF NOT EXISTS `opac_news` (
  `idnew` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(250) NOT NULL default '',
  `new` text NOT NULL,
  `lang` varchar(4) NOT NULL default '',
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `expirationdate` date default NULL,
  `number` int(11) default '0',
  PRIMARY KEY  (`idnew`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `overduerules`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `overduerules`;
CREATE TABLE IF NOT EXISTS `overduerules` (
  `branchcode` varchar(255) NOT NULL default '',
  `categorycode` varchar(2) NOT NULL default '',
  `delay1` int(4) default '0',
  `letter1` varchar(20) default NULL,
  `debarred1` char(1) default '0',
  `delay2` int(4) default '0',
  `debarred2` char(1) default '0',
  `letter2` varchar(20) default NULL,
  `delay3` int(4) default '0',
  `letter3` varchar(20) default NULL,
  `debarred3` int(1) default '0',
  PRIMARY KEY  (`branchcode`,`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `phrase_log`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `phrase_log`;
CREATE TABLE IF NOT EXISTS `phrase_log` (
  `phr_phrase` varchar(100) NOT NULL default '',
  `phr_resultcount` int(11) NOT NULL default '0',
  `phr_ip` varchar(30) NOT NULL default '',
  `user` varchar(45) default NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `actual` text NOT NULL,
  KEY `phr_ip` (`phr_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `printers`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `printers`;
CREATE TABLE IF NOT EXISTS `printers` (
  `printername` char(40) NOT NULL default '''''',
  `printqueue` char(20) default NULL,
  `printtype` char(20) default NULL,
  PRIMARY KEY  (`printername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `repeatable_holidays`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `repeatable_holidays`;
CREATE TABLE IF NOT EXISTS `repeatable_holidays` (
  `id` int(11) NOT NULL auto_increment,
  `branchcode` varchar(4) NOT NULL default '',
  `weekday` smallint(6) default NULL,
  `day` smallint(6) default NULL,
  `month` smallint(6) default NULL,
  `title` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `reserveconstraints`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `reserveconstraints`;
CREATE TABLE IF NOT EXISTS `reserveconstraints` (
  `borrowernumber` int(11) NOT NULL default '0',
  `reservedate` date NOT NULL default '0000-00-00',
  `biblionumber` int(11) NOT NULL default '0',
  `biblioitemnumber` int(11) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `reserves`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:41
-- 

DROP TABLE IF EXISTS `reserves`;
CREATE TABLE IF NOT EXISTS `reserves` (
  `borrowernumber` int(11) NOT NULL default '0',
  `reservedate` date NOT NULL default '0000-00-00',
  `biblionumber` int(11) NOT NULL default '0',
  `constrainttype` char(1) default NULL,
  `branchcode` varchar(4) default NULL,
  `notificationdate` date default NULL,
  `reminderdate` date default NULL,
  `cancellationdate` date default NULL,
  `reservenotes` text,
  `priority` smallint(6) default NULL,
  `found` char(1) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `itemnumber` int(11) default NULL,
  `waitingdate` date default '0000-00-00',
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `reviews`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE IF NOT EXISTS `reviews` (
  `reviewid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `biblionumber` int(11) default NULL,
  `review` text,
  `approved` tinyint(4) default NULL,
  `datereviewed` datetime default NULL,
  PRIMARY KEY  (`reviewid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `roadtype`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `roadtype`;
CREATE TABLE IF NOT EXISTS `roadtype` (
  `roadtypeid` int(11) NOT NULL auto_increment,
  `road_type` char(100) NOT NULL default '',
  PRIMARY KEY  (`roadtypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `serial`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `serial`;
CREATE TABLE IF NOT EXISTS `serial` (
  `serialid` int(11) NOT NULL auto_increment,
  `biblionumber` varchar(100) NOT NULL default '',
  `subscriptionid` varchar(100) NOT NULL default '',
  `serialseq` varchar(100) NOT NULL default '',
  `status` tinyint(4) NOT NULL default '0',
  `planneddate` date NOT NULL default '0000-00-00',
  `notes` text,
  `itemnumber` text,
  `routingnotes` text,
  `publisheddate` date default NULL,
  `claimdate` date default '0000-00-00',
  PRIMARY KEY  (`serialid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `sessionqueries`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `sessionqueries`;
CREATE TABLE IF NOT EXISTS `sessionqueries` (
  `sessionID` varchar(255) NOT NULL default '',
  `userid` varchar(100) NOT NULL default '',
  `ip` varchar(18) NOT NULL default '',
  `url` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `sessions`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE IF NOT EXISTS `sessions` (
  `sessionID` varchar(255) NOT NULL default '',
  `userid` varchar(255) default NULL,
  `ip` varchar(16) default NULL,
  `lasttime` int(11) default NULL,
  PRIMARY KEY  (`sessionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `shelfcontents`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:41
-- 

DROP TABLE IF EXISTS `shelfcontents`;
CREATE TABLE IF NOT EXISTS `shelfcontents` (
  `shelfnumber` int(11) NOT NULL default '0',
  `itemnumber` int(11) NOT NULL default '0',
  `flags` int(11) default NULL,
  `dateadded` timestamp NULL default NULL,
  KEY `shelfnumber` (`shelfnumber`),
  KEY `itemnumber` (`itemnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `special_holidays`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `special_holidays`;
CREATE TABLE IF NOT EXISTS `special_holidays` (
  `id` int(11) NOT NULL auto_increment,
  `branchcode` varchar(4) NOT NULL default '',
  `day` smallint(6) NOT NULL default '0',
  `month` smallint(6) NOT NULL default '0',
  `year` smallint(6) NOT NULL default '0',
  `isexception` smallint(1) NOT NULL default '1',
  `title` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `statistics`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `statistics`;
CREATE TABLE IF NOT EXISTS `statistics` (
  `datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  `branch` varchar(4) default NULL,
  `proccode` varchar(4) default NULL,
  `value` double(16,4) default NULL,
  `type` varchar(16) default NULL,
  `other` text,
  `usercode` varchar(10) default NULL,
  `itemnumber` int(11) default NULL,
  `itemtype` varchar(4) default NULL,
  `borrowernumber` int(11) default NULL,
  `associatedborrower` int(11) default NULL,
  KEY `timeidx` (`datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `stopwords`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `stopwords`;
CREATE TABLE IF NOT EXISTS `stopwords` (
  `word` varchar(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `subcategorytable`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `subcategorytable`;
CREATE TABLE IF NOT EXISTS `subcategorytable` (
  `subcategorycode` varchar(5) NOT NULL default '',
  `description` text,
  `itemtypecodes` text,
  PRIMARY KEY  (`subcategorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `subscription`
-- 
-- Création: Vendredi 26 Janvier 2007 à 12:44
-- 

DROP TABLE IF EXISTS `subscription`;
CREATE TABLE IF NOT EXISTS `subscription` (
  `biblionumber` int(11) NOT NULL default '0',
  `manualhistory` tinyint(1) NOT NULL default '0',
  `subscriptionid` int(11) NOT NULL auto_increment,
  `librarian` varchar(100) default '',
  `startdate` date default '0000-00-00',
  `aqbooksellerid` int(11) default '0',
  `cost` int(11) default '0',
  `aqbudgetid` int(11) default '0',
  `weeklength` tinyint(4) default '0',
  `monthlength` tinyint(4) default '0',
  `numberlength` tinyint(4) default '0',
  `periodicity` tinyint(4) default '0',
  `dow` varchar(100) default '',
  `numberingmethod` varchar(100) default '',
  `notes` text,
  `status` varchar(100) NOT NULL default '',
  `add1` int(11) default '0',
  `every1` int(11) default '0',
  `whenmorethan1` int(11) default '0',
  `setto1` int(11) default NULL,
  `lastvalue1` int(11) default NULL,
  `add2` int(11) default '0',
  `every2` int(11) default '0',
  `whenmorethan2` int(11) default '0',
  `setto2` int(11) default NULL,
  `lastvalue2` int(11) default NULL,
  `add3` int(11) default '0',
  `every3` int(11) default '0',
  `innerloop1` int(11) default '0',
  `innerloop2` int(11) default '0',
  `innerloop3` int(11) default '0',
  `whenmorethan3` int(11) default '0',
  `setto3` int(11) default NULL,
  `lastvalue3` int(11) default NULL,
  `issuesatonce` tinyint(3) NOT NULL default '1',
  `firstacquidate` date NOT NULL default '0000-00-00',
  `irregularity` text,
  `letter` varchar(20) default NULL,
  `numberpattern` tinyint(3) default '0',
  `distributedto` text,
  `callnumber` text,
  `hemisphere` tinyint(3) default '0',
  `branchcode` varchar(12) NOT NULL default '''''',
  `internalnotes` longtext,
  PRIMARY KEY  (`subscriptionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `subscriptionhistory`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `subscriptionhistory`;
CREATE TABLE IF NOT EXISTS `subscriptionhistory` (
  `biblionumber` int(11) NOT NULL default '0',
  `subscriptionid` int(11) NOT NULL default '0',
  `histstartdate` date NOT NULL default '0000-00-00',
  `enddate` date default '0000-00-00',
  `missinglist` longtext NOT NULL,
  `recievedlist` longtext NOT NULL,
  `opacnote` varchar(150) NOT NULL default '',
  `librariannote` varchar(150) NOT NULL default '',
  PRIMARY KEY  (`subscriptionid`),
  KEY `biblionumber` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `subscriptionroutinglist`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `subscriptionroutinglist`;
CREATE TABLE IF NOT EXISTS `subscriptionroutinglist` (
  `routingid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `ranking` int(11) default NULL,
  `subscriptionid` int(11) default NULL,
  PRIMARY KEY  (`routingid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `suggestions`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:40
-- 

DROP TABLE IF EXISTS `suggestions`;
CREATE TABLE IF NOT EXISTS `suggestions` (
  `suggestionid` int(8) NOT NULL auto_increment,
  `suggestedby` int(11) NOT NULL default '0',
  `managedby` int(11) default NULL,
  `STATUS` varchar(10) NOT NULL default '',
  `note` text,
  `author` varchar(80) default NULL,
  `title` varchar(80) default NULL,
  `copyrightdate` smallint(6) default NULL,
  `publishercode` varchar(255) default NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `volumedesc` varchar(255) default NULL,
  `publicationyear` smallint(6) default '0',
  `place` varchar(255) default NULL,
  `isbn` varchar(10) default NULL,
  `mailoverseeing` smallint(1) default '0',
  `biblionumber` int(11) default NULL,
  `reason` text,
  PRIMARY KEY  (`suggestionid`),
  KEY `suggestedby` (`suggestedby`),
  KEY `managedby` (`managedby`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `systempreferences`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:40
-- 

DROP TABLE IF EXISTS `systempreferences`;
CREATE TABLE IF NOT EXISTS `systempreferences` (
  `variable` varchar(50) NOT NULL default '',
  `value` text,
  `options` text,
  `explanation` text,
  `type` varchar(20) default NULL,
  PRIMARY KEY  (`variable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `tags`
-- 
-- Création: Mardi 06 Février 2007 à 11:14
-- 

DROP TABLE IF EXISTS `tags`;
CREATE TABLE IF NOT EXISTS `tags` (
  `entry` varchar(255) NOT NULL default '',
  `weight` bigint(20) NOT NULL default '0',
  PRIMARY KEY  (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `uploadedmarc`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `uploadedmarc`;
CREATE TABLE IF NOT EXISTS `uploadedmarc` (
  `id` int(11) NOT NULL auto_increment,
  `marc` longblob,
  `hidden` smallint(6) default NULL,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `userflags`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `userflags`;
CREATE TABLE IF NOT EXISTS `userflags` (
  `bit` int(11) NOT NULL default '0',
  `flag` char(30) default NULL,
  `flagdesc` char(255) default NULL,
  `defaulton` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `users`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `usercode` varchar(10) default NULL,
  `username` text,
  `password` text,
  `level` smallint(6) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `websites`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `websites`;
CREATE TABLE IF NOT EXISTS `websites` (
  `websitenumber` int(11) NOT NULL auto_increment,
  `biblionumber` int(11) NOT NULL default '0',
  `title` text,
  `description` text,
  `url` varchar(255) default NULL,
  PRIMARY KEY  (`websitenumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `z3950queue`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `z3950queue`;
CREATE TABLE IF NOT EXISTS `z3950queue` (
  `id` int(11) NOT NULL auto_increment,
  `term` text,
  `type` varchar(10) default NULL,
  `startdate` int(11) default NULL,
  `enddate` int(11) default NULL,
  `done` smallint(6) default NULL,
  `results` longblob,
  `numrecords` int(11) default NULL,
  `servers` text,
  `identifier` varchar(30) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `z3950results`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `z3950results`;
CREATE TABLE IF NOT EXISTS `z3950results` (
  `id` int(11) NOT NULL auto_increment,
  `queryid` int(11) default NULL,
  `server` varchar(255) default NULL,
  `startdate` int(11) default NULL,
  `enddate` int(11) default NULL,
  `results` longblob,
  `numrecords` int(11) default NULL,
  `numdownloaded` int(11) default NULL,
  `highestseen` int(11) default NULL,
  `active` smallint(6) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `query_server` (`queryid`,`server`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `z3950servers`
-- 
-- Création: Lundi 27 Novembre 2006 à 18:39
-- 

DROP TABLE IF EXISTS `z3950servers`;
CREATE TABLE IF NOT EXISTS `z3950servers` (
  `host` varchar(255) default NULL,
  `port` int(11) default NULL,
  `db` varchar(255) default NULL,
  `userid` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `name` text,
  `description` text NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  `checked` smallint(6) default NULL,
  `rank` int(11) default NULL,
  `syntax` varchar(80) default NULL,
  `position` enum('primary','secondary','') NOT NULL default 'primary',
  `icon` text,
  `type` enum('zed','opensearch') NOT NULL default 'zed',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `zebraqueue`
-- 
-- Création: Mardi 16 Janvier 2007 à 14:19
-- 

DROP TABLE IF EXISTS `zebraqueue`;
CREATE TABLE IF NOT EXISTS `zebraqueue` (
  `id` int(11) NOT NULL auto_increment,
  `biblio_auth_number` int(11) NOT NULL default '0',
  `operation` char(20) NOT NULL default '',
  `server` char(20) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
-- Contraintes pour les tables exportées
-- 

-- 
-- Contraintes pour la table `accountlines`
-- 
ALTER TABLE `accountlines`
  ADD CONSTRAINT `accountlines_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `accountlines`
  ADD CONSTRAINT `accountlines_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL;

-- 
-- Contraintes pour la table `aqbasket`
-- 
ALTER TABLE `aqbasket`
  ADD CONSTRAINT `aqbasket_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `aqbooksellers`
-- 
ALTER TABLE `aqbooksellers`
  ADD CONSTRAINT `aqbooksellers_ibfk_1` FOREIGN KEY (`listprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `aqbooksellers`
  ADD CONSTRAINT `aqbooksellers_ibfk_2` FOREIGN KEY (`invoiceprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `aqorderbreakdown`
-- 
ALTER TABLE `aqorderbreakdown`
  ADD CONSTRAINT `aqorderbreakdown_ibfk_1` FOREIGN KEY (`ordernumber`) REFERENCES `aqorders` (`ordernumber`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `aqorderbreakdown`
    ADD CONSTRAINT `aqorderbreakdown_ibfk_2` FOREIGN KEY (`bookfundid`) REFERENCES `aqbookfund` (`bookfundid`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `aqorders`
-- 
ALTER TABLE `aqorders`
  ADD CONSTRAINT `aqorders_ibfk_1` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `aqorders`
    ADD CONSTRAINT `aqorders_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE SET NULL;

-- 
-- Contraintes pour la table `auth_tag_structure`
-- 
ALTER TABLE `auth_tag_structure`
  ADD CONSTRAINT `auth_tag_structure_ibfk_1` FOREIGN KEY (`authtypecode`) REFERENCES `auth_types` (`authtypecode`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `biblioitems`
-- 
ALTER TABLE `biblioitems`
  ADD CONSTRAINT `biblioitems_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `borrowers`
-- 
ALTER TABLE `borrowers`
  ADD CONSTRAINT `borrowers_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`);
ALTER TABLE `borrowers`
    ADD CONSTRAINT `borrowers_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`);

-- 
-- Contraintes pour la table `branchtransfers`
-- 
ALTER TABLE `branchtransfers`
  ADD CONSTRAINT `branchtransfers_ibfk_1` FOREIGN KEY (`frombranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `branchtransfers`
   ADD CONSTRAINT `branchtransfers_ibfk_2` FOREIGN KEY (`tobranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `branchtransfers`
   ADD CONSTRAINT `branchtransfers_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `issues`
-- 
ALTER TABLE `issues`
  ADD CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL;
ALTER TABLE `issues`
    ADD CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL;

-- 
-- Contraintes pour la table `issuingrules`
-- 
ALTER TABLE `issuingrules`
  ADD CONSTRAINT `issuingrules_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `issuingrules`
    ADD CONSTRAINT `issuingrules_ibfk_2` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `items`
-- 
ALTER TABLE `items`
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblioitemnumber`) REFERENCES `biblioitems` (`biblioitemnumber`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `items`
    ADD CONSTRAINT `items_ibfk_2` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `reserves`
-- 
ALTER TABLE `reserves`
  ADD CONSTRAINT `reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `reserves`
  ADD CONSTRAINT `reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `reserves`
  ADD CONSTRAINT `reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `reserves`
   ADD CONSTRAINT `reserves_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `shelfcontents`
-- 
ALTER TABLE `shelfcontents`
  ADD CONSTRAINT `shelfcontents_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `bookshelf` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `shelfcontents`
    ADD CONSTRAINT `shelfcontents_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE;
