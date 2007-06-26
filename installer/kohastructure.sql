-- phpMyAdmin SQL Dump
-- version 2.7.0-pl2
-- http://www.phpmyadmin.net
-- 
-- Serveur: localhost
-- Généré le : Mardi 26 Juin 2007 à 15:21
-- Version du serveur: 5.0.37
-- Version de PHP: 5.2.1
-- 
-- 

-- --------------------------------------------------------

-- 
-- Structure de la table `accountlines`
-- 

CREATE TABLE `accountlines` (
  `borrowernumber` int(11) NOT NULL default '0',
  `accountno` smallint(6) NOT NULL default '0',
  `itemnumber` int(11) default NULL,
  `date` date default NULL,
  `amount` decimal(28,6) default NULL,
  `description` mediumtext,
  `dispute` mediumtext,
  `accounttype` varchar(5) default NULL,
  `amountoutstanding` decimal(28,6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `notify_id` int(11) NOT NULL,
  `notify_level` int(2) NOT NULL,
  KEY `acctsborridx` (`borrowernumber`),
  KEY `timeidx` (`timestamp`),
  KEY `itemnumber` (`itemnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `accountoffsets`
-- 

CREATE TABLE `accountoffsets` (
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

CREATE TABLE `action_logs` (
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` int(11) NOT NULL,
  `module` mediumtext,
  `action` mediumtext,
  `object` int(11) default NULL,
  `info` mediumtext,
  PRIMARY KEY  (`timestamp`,`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `alert`
-- 

CREATE TABLE `alert` (
  `alertid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) NOT NULL default '0',
  `type` varchar(10) NOT NULL default '',
  `externalid` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`alertid`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `type` (`type`,`externalid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqbasket`
-- 

CREATE TABLE `aqbasket` (
  `basketno` int(11) NOT NULL auto_increment,
  `creationdate` date default NULL,
  `closedate` date default NULL,
  `booksellerid` int(11) NOT NULL default '1',
  `authorisedby` varchar(10) default NULL,
  `booksellerinvoicenumber` mediumtext,
  PRIMARY KEY  (`basketno`),
  KEY `booksellerid` (`booksellerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=182 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqbookfund`
-- 

CREATE TABLE `aqbookfund` (
  `bookfundid` varchar(5) NOT NULL default '''''',
  `bookfundname` mediumtext,
  `bookfundgroup` varchar(5) default NULL,
  `branchcode` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`bookfundid`,`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqbooksellers`
-- 

CREATE TABLE `aqbooksellers` (
  `id` int(11) NOT NULL auto_increment,
  `name` mediumtext,
  `address1` mediumtext,
  `address2` mediumtext,
  `address3` mediumtext,
  `address4` mediumtext,
  `phone` varchar(30) default NULL,
  `accountnumber` mediumtext,
  `othersupplier` mediumtext,
  `currency` char(3) NOT NULL default '',
  `deliverydays` smallint(6) default NULL,
  `followupdays` smallint(6) default NULL,
  `followupscancel` smallint(6) default NULL,
  `specialty` mediumtext,
  `booksellerfax` mediumtext,
  `notes` mediumtext,
  `bookselleremail` mediumtext,
  `booksellerurl` mediumtext,
  `contact` varchar(100) default NULL,
  `postal` mediumtext,
  `url` varchar(255) default NULL,
  `contpos` varchar(100) default NULL,
  `contphone` varchar(100) default NULL,
  `contfax` varchar(100) default NULL,
  `contaltphone` varchar(100) default NULL,
  `contemail` varchar(100) default NULL,
  `contnotes` mediumtext,
  `active` tinyint(4) default NULL,
  `listprice` varchar(10) default NULL,
  `invoiceprice` varchar(10) default NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=76 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqbudget`
-- 

CREATE TABLE `aqbudget` (
  `bookfundid` varchar(5) NOT NULL default '',
  `startdate` date NOT NULL default '0000-00-00',
  `enddate` date default NULL,
  `budgetamount` decimal(13,2) default NULL,
  `aqbudgetid` tinyint(4) NOT NULL auto_increment,
  `branchcode` varchar(4) default NULL,
  PRIMARY KEY  (`aqbudgetid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=12 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqorderbreakdown`
-- 

CREATE TABLE `aqorderbreakdown` (
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

CREATE TABLE `aqorderdelivery` (
  `ordernumber` date NOT NULL default '0000-00-00',
  `deliverynumber` smallint(6) NOT NULL default '0',
  `deliverydate` varchar(18) default NULL,
  `qtydelivered` smallint(6) default NULL,
  `deliverycomments` mediumtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `aqorders`
-- 

CREATE TABLE `aqorders` (
  `ordernumber` int(11) NOT NULL auto_increment,
  `biblionumber` int(11) default NULL,
  `title` mediumtext,
  `entrydate` date default NULL,
  `quantity` smallint(6) default NULL,
  `currency` char(3) default NULL,
  `listprice` decimal(28,6) default NULL,
  `totalamount` decimal(28,6) default NULL,
  `datereceived` date default NULL,
  `booksellerinvoicenumber` mediumtext,
  `freight` decimal(28,6) default NULL,
  `unitprice` decimal(28,6) default NULL,
  `quantityreceived` smallint(6) default NULL,
  `cancelledby` varchar(10) default NULL,
  `datecancellationprinted` date default NULL,
  `notes` mediumtext,
  `supplierreference` mediumtext,
  `purchaseordernumber` mediumtext,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=618 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_header`
-- 

CREATE TABLE `auth_header` (
  `authid` bigint(20) unsigned NOT NULL auto_increment,
  `authtypecode` varchar(10) NOT NULL default '',
  `datecreated` date NOT NULL default '0000-00-00',
  `datemodified` date default NULL,
  `origincode` varchar(20) default NULL,
  `authtrees` mediumtext,
  `marc` blob,
  `linkid` bigint(20) default NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY  (`authid`),
  KEY `origincode` (`origincode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=262156 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_subfield_structure`
-- 

CREATE TABLE `auth_subfield_structure` (
  `authtypecode` char(10) NOT NULL default '',
  `tagfield` char(3) NOT NULL default '',
  `tagsubfield` char(1) NOT NULL default '',
  `liblibrarian` char(255) NOT NULL default '',
  `libopac` char(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default '0',
  `mandatory` tinyint(4) NOT NULL default '0',
  `tab` tinyint(1) default NULL,
  `authorised_value` char(10) default NULL,
  `value_builder` char(80) default NULL,
  `seealso` char(255) default NULL,
  `isurl` tinyint(1) default NULL,
  `hidden` tinyint(3) NOT NULL default '0',
  `linkid` tinyint(1) NOT NULL default '0',
  `kohafield` varchar(45) NOT NULL default '',
  `frameworkcode` varchar(8) NOT NULL,
  PRIMARY KEY  (`authtypecode`,`tagfield`,`tagsubfield`),
  KEY `tab` (`authtypecode`,`tab`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `auth_tag_structure`
-- 

CREATE TABLE `auth_tag_structure` (
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

CREATE TABLE `auth_types` (
  `authtypecode` varchar(10) NOT NULL default '',
  `authtypetext` varchar(255) NOT NULL default '',
  `auth_tag_to_report` char(3) NOT NULL default '',
  `summary` mediumtext NOT NULL,
  PRIMARY KEY  (`authtypecode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `authorised_values`
-- 

CREATE TABLE `authorised_values` (
  `id` int(11) NOT NULL auto_increment,
  `category` char(10) NOT NULL default '',
  `authorised_value` char(80) NOT NULL default '',
  `lib` char(80) default NULL,
  PRIMARY KEY  (`id`),
  KEY `name` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=3611 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `biblio`
-- 

CREATE TABLE `biblio` (
  `biblionumber` int(11) NOT NULL default '0',
  `frameworkcode` varchar(4) NOT NULL,
  `author` mediumtext,
  `title` mediumtext,
  `unititle` mediumtext,
  `notes` mediumtext,
  `serial` tinyint(1) default NULL,
  `seriestitle` mediumtext,
  `copyrightdate` smallint(6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `abstract` mediumtext,
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `biblio_framework`
-- 

CREATE TABLE `biblio_framework` (
  `frameworkcode` char(4) NOT NULL default '',
  `frameworktext` char(255) NOT NULL default '',
  PRIMARY KEY  (`frameworkcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `biblioitems`
-- 

CREATE TABLE `biblioitems` (
  `biblioitemnumber` int(11) NOT NULL default '0',
  `biblionumber` int(11) NOT NULL default '0',
  `volume` mediumtext,
  `number` mediumtext,
  `classification` varchar(25) default NULL,
  `itemtype` varchar(4) default NULL,
  `isbn` varchar(14) default NULL,
  `issn` varchar(9) default NULL,
  `dewey` varchar(30) default NULL,
  `subclass` char(3) default NULL,
  `publicationyear` smallint(6) default NULL,
  `publishercode` varchar(255) default NULL,
  `volumedate` date default NULL,
  `volumeddesc` varchar(255) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL,
  `pages` varchar(255) default NULL,
  `notes` mediumtext,
  `size` varchar(255) default NULL,
  `place` varchar(255) default NULL,
  `lccn` varchar(25) default NULL,
  `marc` blob,
  `url` varchar(255) default NULL,
  `lcsort` varchar(25) default NULL,
  `ccode` varchar(4) default NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `isbn` (`isbn`),
  KEY `publishercode` (`publishercode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `bookshelf`
-- 

CREATE TABLE `bookshelf` (
  `shelfnumber` int(11) NOT NULL auto_increment,
  `shelfname` char(255) default NULL,
  `owner` char(80) default NULL,
  `category` char(1) default NULL,
  PRIMARY KEY  (`shelfnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=71 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `borrowers`
-- 

CREATE TABLE `borrowers` (
  `borrowernumber` int(11) NOT NULL auto_increment,
  `cardnumber` varchar(16) default NULL,
  `surname` mediumtext NOT NULL,
  `firstname` text,
  `title` mediumtext,
  `othernames` mediumtext,
  `initials` text,
  `streetnumber` char(10) default NULL,
  `streettype` char(50) default NULL,
  `address` mediumtext NOT NULL,
  `address2` text,
  `city` mediumtext NOT NULL,
  `zipcode` varchar(25) default NULL,
  `email` mediumtext,
  `phone` text,
  `mobile` varchar(50) default NULL,
  `fax` mediumtext,
  `emailpro` text,
  `phonepro` text,
  `B_streetnumber` char(10) default NULL,
  `B_streettype` char(50) default NULL,
  `B_address` varchar(100) default NULL,
  `B_city` mediumtext,
  `B_zipcode` varchar(25) default NULL,
  `B_email` text,
  `B_phone` mediumtext,
  `dateofbirth` date default NULL,
  `branchcode` varchar(10) NOT NULL,
  `categorycode` varchar(10) NOT NULL,
  `dateenrolled` date default NULL,
  `dateexpiry` date default NULL,
  `gonenoaddress` tinyint(1) default NULL,
  `lost` tinyint(1) default NULL,
  `debarred` tinyint(1) default NULL,
  `contactname` mediumtext,
  `contactfirstname` text,
  `contacttitle` text,
  `guarantorid` int(11) default NULL,
  `borrowernotes` mediumtext,
  `relationship` varchar(100) default NULL,
  `ethnicity` varchar(50) default NULL,
  `ethnotes` varchar(255) default NULL,
  `sex` char(1) default NULL,
  `password` varchar(30) default NULL,
  `flags` int(11) default NULL,
  `userid` varchar(30) default NULL,
  `opacnote` mediumtext,
  `contactnote` varchar(255) default NULL,
  `sort1` varchar(80) default NULL,
  `sort2` varchar(80) default NULL,
  UNIQUE KEY `cardnumber` (`cardnumber`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=529 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `branchcategories`
-- 

CREATE TABLE `branchcategories` (
  `categorycode` varchar(4) NOT NULL default '',
  `categoryname` mediumtext,
  `codedescription` mediumtext,
  PRIMARY KEY  (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `branches`
-- 

CREATE TABLE `branches` (
  `branchcode` varchar(10) NOT NULL,
  `branchname` mediumtext NOT NULL,
  `branchaddress1` mediumtext,
  `branchaddress2` mediumtext,
  `branchaddress3` mediumtext,
  `branchphone` mediumtext,
  `branchfax` mediumtext,
  `branchemail` mediumtext,
  `issuing` tinyint(4) default NULL,
  `branchip` varchar(15) default NULL,
  `branchprinter` varchar(100) default NULL,
  UNIQUE KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `branchrelations`
-- 

CREATE TABLE `branchrelations` (
  `branchcode` varchar(4) NOT NULL default '',
  `categorycode` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`branchcode`,`categorycode`),
  KEY `branchcode` (`branchcode`),
  KEY `categorycode` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `branchtransfers`
-- 

CREATE TABLE `branchtransfers` (
  `itemnumber` int(11) NOT NULL default '0',
  `datesent` datetime default NULL,
  `frombranch` varchar(10) NOT NULL,
  `datearrived` datetime default NULL,
  `tobranch` varchar(10) NOT NULL,
  `comments` mediumtext,
  KEY `frombranch` (`frombranch`),
  KEY `tobranch` (`tobranch`),
  KEY `itemnumber` (`itemnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `browser`
-- 

CREATE TABLE `browser` (
  `level` int(11) NOT NULL,
  `classification` varchar(20) NOT NULL,
  `description` varchar(255) NOT NULL,
  `number` bigint(20) NOT NULL,
  `endnode` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `catalogueentry`
-- 

CREATE TABLE `catalogueentry` (
  `catalogueentry` mediumtext NOT NULL,
  `entrytype` char(2) default NULL,
  `see` mediumtext,
  `seealso` mediumtext,
  `seeinstead` mediumtext,
  `biblionumber` int(11) default NULL,
  KEY `entrytype` (`entrytype`,`catalogueentry`(250))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `categories`
-- 

CREATE TABLE `categories` (
  `categorycode` varchar(10) NOT NULL,
  `description` mediumtext,
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

CREATE TABLE `categorytable` (
  `categorycode` char(5) NOT NULL default '',
  `description` mediumtext,
  `itemtypecodes` mediumtext,
  PRIMARY KEY  (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `charges`
-- 

CREATE TABLE `charges` (
  `charge_id` varchar(5) NOT NULL default '',
  `description` mediumtext NOT NULL,
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

CREATE TABLE `cities` (
  `cityid` int(11) NOT NULL auto_increment,
  `city_name` char(100) NOT NULL,
  `city_zipcode` char(20) default NULL,
  PRIMARY KEY  (`cityid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `currency`
-- 

CREATE TABLE `currency` (
  `currency` varchar(10) NOT NULL default '',
  `rate` float(7,5) default NULL,
  PRIMARY KEY  (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `deletedbiblio`
-- 

CREATE TABLE `deletedbiblio` (
  `biblionumber` int(11) NOT NULL default '0',
  `author` mediumtext,
  `title` mediumtext,
  `unititle` mediumtext,
  `notes` mediumtext,
  `serial` tinyint(1) default NULL,
  `seriestitle` mediumtext,
  `copyrightdate` smallint(6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `marc` blob,
  `abstract` mediumtext,
  `frameworkcode` varchar(4) NOT NULL,
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `deletedbiblioitems`
-- 

CREATE TABLE `deletedbiblioitems` (
  `biblioitemnumber` int(11) NOT NULL default '0',
  `biblionumber` int(11) NOT NULL default '0',
  `volume` mediumtext,
  `number` mediumtext,
  `classification` varchar(25) default NULL,
  `itemtype` varchar(4) default NULL,
  `isbn` varchar(14) default NULL,
  `issn` varchar(9) default NULL,
  `dewey` varchar(30) default NULL,
  `subclass` char(3) default NULL,
  `publicationyear` smallint(6) default NULL,
  `publishercode` varchar(255) default NULL,
  `volumedate` date default NULL,
  `volumeddesc` varchar(255) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL,
  `pages` varchar(255) default NULL,
  `notes` mediumtext,
  `size` varchar(255) default NULL,
  `lccn` varchar(25) default NULL,
  `marc` mediumtext,
  `url` varchar(255) default NULL,
  `place` varchar(255) default NULL,
  `lcsort` varchar(25) default NULL,
  `ccode` varchar(4) default NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `deletedborrowers`
-- 

CREATE TABLE `deletedborrowers` (
  `borrowernumber` int(11) NOT NULL default '0',
  `cardnumber` varchar(9) NOT NULL default '',
  `surname` mediumtext NOT NULL,
  `firstname` text,
  `title` mediumtext,
  `othernames` mediumtext,
  `initials` text,
  `streetnumber` char(10) default NULL,
  `streettype` char(50) default NULL,
  `address` mediumtext NOT NULL,
  `address2` text,
  `city` mediumtext NOT NULL,
  `zipcode` varchar(25) default NULL,
  `email` mediumtext,
  `phone` text,
  `mobile` varchar(50) default NULL,
  `fax` mediumtext,
  `emailpro` text,
  `phonepro` text,
  `B_streetnumber` char(10) default NULL,
  `B_streettype` char(50) default NULL,
  `B_address` varchar(100) default NULL,
  `B_city` mediumtext,
  `B_zipcode` varchar(25) default NULL,
  `B_email` text,
  `B_phone` mediumtext,
  `dateofbirth` date default NULL,
  `branchcode` varchar(4) NOT NULL default '',
  `categorycode` char(2) default NULL,
  `dateenrolled` date default NULL,
  `dateexpiry` date default NULL,
  `gonenoaddress` tinyint(1) default NULL,
  `lost` tinyint(1) default NULL,
  `debarred` tinyint(1) default NULL,
  `contactname` mediumtext,
  `contactfirstname` text,
  `contacttitle` text,
  `guarantorid` int(11) default NULL,
  `borrowernotes` mediumtext,
  `relationship` varchar(100) default NULL,
  `ethnicity` varchar(50) default NULL,
  `ethnotes` varchar(255) default NULL,
  `sex` char(1) default NULL,
  `password` varchar(30) default NULL,
  `flags` int(11) default NULL,
  `userid` varchar(30) default NULL,
  `opacnote` mediumtext,
  `contactnote` varchar(255) default NULL,
  `sort1` varchar(80) default NULL,
  `sort2` varchar(80) default NULL,
  KEY `borrowernumber` (`borrowernumber`),
  KEY `cardnumber` (`cardnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `deleteditems`
-- 

CREATE TABLE `deleteditems` (
  `itemnumber` int(11) NOT NULL default '0',
  `biblionumber` int(11) NOT NULL default '0',
  `multivolumepart` varchar(30) default NULL,
  `biblioitemnumber` int(11) NOT NULL default '0',
  `barcode` varchar(20) NOT NULL,
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
  `itemnotes` mediumtext,
  `holdingbranch` varchar(4) default NULL,
  `interim` tinyint(1) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `marc` blob,
  `paidfor` mediumtext,
  `location` varchar(80) default NULL,
  `itemcallnumber` varchar(30) default NULL,
  `onloan` date default '0000-00-00',
  `cutterextra` varchar(45) default NULL,
  `issue_date` date default NULL,
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

CREATE TABLE `ethnicity` (
  `code` varchar(10) NOT NULL default '',
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `issues`
-- 

CREATE TABLE `issues` (
  `borrowernumber` int(11) default NULL,
  `itemnumber` int(11) default NULL,
  `date_due` date default NULL,
  `branchcode` varchar(10) default NULL,
  `issuingbranch` char(18) default NULL,
  `returndate` date default NULL,
  `lastreneweddate` date default NULL,
  `return` char(4) default NULL,
  `renewals` tinyint(4) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `issuedate` date NOT NULL default '0000-00-00',
  KEY `issuesborridx` (`borrowernumber`),
  KEY `issuesitemidx` (`itemnumber`),
  KEY `bordate` (`borrowernumber`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `issuingrules`
-- 

CREATE TABLE `issuingrules` (
  `categorycode` char(2) NOT NULL default '',
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
  KEY `itemtype` (`itemtype`),
  KEY `categorycode` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `items`
-- 

CREATE TABLE `items` (
  `itemnumber` int(11) NOT NULL default '0',
  `biblionumber` int(11) NOT NULL default '0',
  `multivolumepart` varchar(30) default NULL,
  `biblioitemnumber` int(11) NOT NULL default '0',
  `barcode` varchar(20) default NULL,
  `dateaccessioned` date default NULL,
  `booksellerid` varchar(10) default NULL,
  `homebranch` varchar(10) default NULL,
  `price` decimal(8,2) default NULL,
  `replacementprice` decimal(8,2) default NULL,
  `replacementpricedate` date default NULL,
  `datelastborrowed` date default NULL,
  `datelastseen` date default NULL,
  `multivolume` tinyint(1) default NULL,
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) default NULL,
  `itemlost` tinyint(1) default NULL,
  `wthdrawn` tinyint(1) default NULL,
  `itemcallnumber` varchar(30) default NULL,
  `issues` smallint(6) default NULL,
  `renewals` smallint(6) default NULL,
  `reserves` smallint(6) default NULL,
  `restricted` tinyint(1) default NULL,
  `binding` decimal(28,6) default NULL,
  `itemnotes` mediumtext,
  `holdingbranch` varchar(10) default NULL,
  `paidfor` mediumtext,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `location` varchar(80) default NULL,
  `onloan` date default '0000-00-00',
  `cutterextra` varchar(45) default NULL,
  `issue_date` date default NULL,
  `itype` varchar(10) default NULL,
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

CREATE TABLE `itemsprices` (
  `itemnumber` int(11) default NULL,
  `price1` decimal(28,6) default NULL,
  `price2` decimal(28,6) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `itemtypes`
-- 

CREATE TABLE `itemtypes` (
  `itemtype` varchar(10) NOT NULL,
  `description` mediumtext,
  `renewalsallowed` smallint(6) default NULL,
  `rentalcharge` double(16,4) default NULL,
  `notforloan` smallint(6) default NULL,
  `imageurl` char(200) default NULL,
  `summary` text,
  PRIMARY KEY  (`itemtype`),
  UNIQUE KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `labels`
-- 

CREATE TABLE `labels` (
  `labelid` int(11) NOT NULL auto_increment,
  `itemnumber` varchar(100) NOT NULL default '',
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`labelid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `labels_conf`
-- 

CREATE TABLE `labels_conf` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `letter`
-- 

CREATE TABLE `letter` (
  `module` varchar(20) NOT NULL default '',
  `code` varchar(20) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  `title` varchar(200) NOT NULL default '',
  `content` mediumtext,
  PRIMARY KEY  (`module`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_biblio`
-- 

CREATE TABLE `marc_biblio` (
  `bibid` bigint(20) unsigned NOT NULL auto_increment,
  `biblionumber` int(11) NOT NULL default '0',
  `datecreated` date NOT NULL default '0000-00-00',
  `datemodified` date default NULL,
  `origincode` char(20) default NULL,
  `frameworkcode` char(4) NOT NULL default '',
  PRIMARY KEY  (`bibid`),
  KEY `origincode` (`origincode`),
  KEY `biblionumber` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1455122 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_breeding`
-- 

CREATE TABLE `marc_breeding` (
  `id` bigint(20) NOT NULL auto_increment,
  `file` varchar(80) NOT NULL default '',
  `isbn` varchar(10) NOT NULL default '',
  `title` varchar(128) default NULL,
  `author` varchar(80) default NULL,
  `marc` longblob,
  `encoding` varchar(40) NOT NULL default '',
  `z3950random` varchar(40) default NULL,
  PRIMARY KEY  (`id`),
  KEY `title` (`title`),
  KEY `isbn` (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_subfield_structure`
-- 

CREATE TABLE `marc_subfield_structure` (
  `tagfield` char(3) NOT NULL default '',
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
  `defaultvalue` text,
  PRIMARY KEY  (`frameworkcode`,`tagfield`,`tagsubfield`),
  KEY `kohafield_2` (`kohafield`),
  KEY `tab` (`frameworkcode`,`tab`),
  KEY `kohafield` (`frameworkcode`,`kohafield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `marc_tag_structure`
-- 

CREATE TABLE `marc_tag_structure` (
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
-- Structure de la table `notifys`
-- 

CREATE TABLE `notifys` (
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

CREATE TABLE `opac_news` (
  `idnew` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(250) NOT NULL default '',
  `new` mediumtext NOT NULL,
  `lang` varchar(4) NOT NULL default '',
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `expirationdate` date default NULL,
  `number` int(11) default NULL,
  PRIMARY KEY  (`idnew`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `overduerules`
-- 

CREATE TABLE `overduerules` (
  `branchcode` varchar(255) NOT NULL default '',
  `categorycode` char(2) NOT NULL default '',
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
-- Structure de la table `printers`
-- 

CREATE TABLE `printers` (
  `printername` char(40) NOT NULL default '''''',
  `printqueue` char(20) default NULL,
  `printtype` char(20) default NULL,
  PRIMARY KEY  (`printername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `repeatable_holidays`
-- 

CREATE TABLE `repeatable_holidays` (
  `id` int(11) NOT NULL auto_increment,
  `branchcode` varchar(4) NOT NULL default '',
  `weekday` smallint(6) default NULL,
  `day` smallint(6) default NULL,
  `month` smallint(6) default NULL,
  `title` varchar(50) NOT NULL default '',
  `description` mediumtext NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `reserveconstraints`
-- 

CREATE TABLE `reserveconstraints` (
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

CREATE TABLE `reserves` (
  `borrowernumber` int(11) NOT NULL default '0',
  `reservedate` date NOT NULL default '0000-00-00',
  `biblionumber` int(11) NOT NULL default '0',
  `constrainttype` char(1) default NULL,
  `branchcode` varchar(4) default NULL,
  `notificationdate` date default NULL,
  `reminderdate` date default NULL,
  `cancellationdate` date default NULL,
  `reservenotes` mediumtext,
  `priority` smallint(6) default NULL,
  `found` char(1) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `itemnumber` int(11) default NULL,
  `waitingdate` date default NULL,
  KEY `branchcode` (`branchcode`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `reviews`
-- 

CREATE TABLE `reviews` (
  `reviewid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `biblionumber` int(11) default NULL,
  `review` mediumtext,
  `approved` tinyint(4) default NULL,
  `datereviewed` datetime default NULL,
  PRIMARY KEY  (`reviewid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `roadtype`
-- 

CREATE TABLE `roadtype` (
  `roadtypeid` int(11) NOT NULL auto_increment,
  `road_type` char(100) NOT NULL,
  PRIMARY KEY  (`roadtypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `serial`
-- 

CREATE TABLE `serial` (
  `serialid` int(11) NOT NULL auto_increment,
  `biblionumber` varchar(100) NOT NULL default '',
  `subscriptionid` varchar(100) NOT NULL default '',
  `serialseq` varchar(100) NOT NULL default '',
  `status` tinyint(4) NOT NULL default '0',
  `planneddate` date NOT NULL default '0000-00-00',
  `notes` text,
  `publisheddate` date default NULL,
  `itemnumber` text,
  `claimdate` date default NULL,
  `routingnotes` text,
  PRIMARY KEY  (`serialid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=2034 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `sessionqueries`
-- 

CREATE TABLE `sessionqueries` (
  `sessionID` varchar(255) NOT NULL default '',
  `userid` varchar(100) NOT NULL default '',
  `ip` varchar(18) NOT NULL default '',
  `url` mediumtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `sessions`
-- 

CREATE TABLE `sessions` (
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

CREATE TABLE `shelfcontents` (
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

CREATE TABLE `special_holidays` (
  `id` int(11) NOT NULL auto_increment,
  `branchcode` varchar(4) NOT NULL default '',
  `day` smallint(6) NOT NULL default '0',
  `month` smallint(6) NOT NULL default '0',
  `year` smallint(6) NOT NULL default '0',
  `isexception` smallint(1) NOT NULL default '1',
  `title` varchar(50) NOT NULL default '',
  `description` mediumtext NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `statistics`
-- 

CREATE TABLE `statistics` (
  `datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  `branch` varchar(4) default NULL,
  `proccode` varchar(4) default NULL,
  `value` double(16,4) default NULL,
  `type` varchar(16) default NULL,
  `other` mediumtext,
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

CREATE TABLE `stopwords` (
  `word` varchar(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `subscription`
-- 

CREATE TABLE `subscription` (
  `biblionumber` int(11) NOT NULL default '0',
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
  `notes` mediumtext,
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
  `firstacquidate` date NOT NULL,
  `manualhistory` tinyint(1) NOT NULL default '0',
  `irregularity` text,
  `letter` char(20) default NULL,
  `numberpattern` tinyint(3) default '0',
  `distributedto` text,
  `internalnotes` longtext,
  `callnumber` text,
  `branchcode` varchar(12) NOT NULL default '',
  `hemisphere` tinyint(3) default '0',
  PRIMARY KEY  (`subscriptionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=190 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `subscriptionhistory`
-- 

CREATE TABLE `subscriptionhistory` (
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

CREATE TABLE `subscriptionroutinglist` (
  `routingid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `ranking` int(11) default NULL,
  `subscriptionid` int(11) default NULL,
  PRIMARY KEY  (`routingid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `suggestions`
-- 

CREATE TABLE `suggestions` (
  `suggestionid` int(8) NOT NULL auto_increment,
  `suggestedby` int(11) NOT NULL default '0',
  `managedby` int(11) default NULL,
  `STATUS` varchar(10) NOT NULL default '',
  `note` mediumtext,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=349 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `systempreferences`
-- 

CREATE TABLE `systempreferences` (
  `variable` varchar(50) NOT NULL default '',
  `value` text,
  `options` mediumtext,
  `explanation` text,
  `type` varchar(20) default NULL,
  PRIMARY KEY  (`variable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `tags`
-- 

CREATE TABLE `tags` (
  `entry` varchar(255) NOT NULL default '',
  `weight` bigint(20) NOT NULL default '0',
  PRIMARY KEY  (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `userflags`
-- 

CREATE TABLE `userflags` (
  `bit` int(11) NOT NULL default '0',
  `flag` char(30) default NULL,
  `flagdesc` char(255) default NULL,
  `defaulton` int(11) default NULL,
  PRIMARY KEY  (`bit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `users`
-- 

CREATE TABLE `users` (
  `usercode` varchar(10) default NULL,
  `username` mediumtext,
  `password` mediumtext,
  `level` smallint(6) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- Structure de la table `websites`
-- 

CREATE TABLE `websites` (
  `websitenumber` int(11) NOT NULL auto_increment,
  `biblionumber` int(11) NOT NULL default '0',
  `title` mediumtext,
  `description` mediumtext,
  `url` varchar(255) default NULL,
  PRIMARY KEY  (`websitenumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `z3950queue`
-- 

CREATE TABLE `z3950queue` (
  `id` int(11) NOT NULL auto_increment,
  `term` mediumtext,
  `type` varchar(10) default NULL,
  `startdate` int(11) default NULL,
  `enddate` int(11) default NULL,
  `done` smallint(6) default NULL,
  `results` longblob,
  `numrecords` int(11) default NULL,
  `servers` mediumtext,
  `identifier` varchar(30) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `z3950results`
-- 

CREATE TABLE `z3950results` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `z3950servers`
-- 

CREATE TABLE `z3950servers` (
  `host` varchar(255) default NULL,
  `port` int(11) default NULL,
  `db` varchar(255) default NULL,
  `userid` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `name` mediumtext,
  `id` int(11) NOT NULL auto_increment,
  `checked` smallint(6) default NULL,
  `rank` int(11) default NULL,
  `syntax` varchar(80) default NULL,
  `icon` text,
  `position` enum('primary','secondary','') NOT NULL default 'primary',
  `type` enum('zed','opensearch') NOT NULL default 'zed',
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

-- 
-- Structure de la table `zebraqueue`
-- 

CREATE TABLE `zebraqueue` (
  `id` int(11) NOT NULL auto_increment,
  `biblio_auth_number` int(11) NOT NULL,
  `operation` char(20) NOT NULL,
  `server` char(20) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 
-- Contraintes pour les tables exportées
-- 

-- 
-- Contraintes pour la table `accountlines`
-- 
ALTER TABLE `accountlines`
  ADD CONSTRAINT `accountlines_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `accountlines_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `accountlines_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `accountlines_ibfk_4` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL;

-- 
-- Contraintes pour la table `aqbasket`
-- 
ALTER TABLE `aqbasket`
  ADD CONSTRAINT `aqbasket_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `aqbooksellers`
-- 
ALTER TABLE `aqbooksellers`
  ADD CONSTRAINT `aqbooksellers_ibfk_1` FOREIGN KEY (`listprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `aqbooksellers_ibfk_2` FOREIGN KEY (`invoiceprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `aqorderbreakdown`
-- 
ALTER TABLE `aqorderbreakdown`
  ADD CONSTRAINT `aqorderbreakdown_ibfk_1` FOREIGN KEY (`ordernumber`) REFERENCES `aqorders` (`ordernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `aqorderbreakdown_ibfk_2` FOREIGN KEY (`bookfundid`) REFERENCES `aqbookfund` (`bookfundid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `aqorderbreakdown_ibfk_3` FOREIGN KEY (`bookfundid`) REFERENCES `aqbookfund` (`bookfundid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `aqorderbreakdown_ibfk_4` FOREIGN KEY (`ordernumber`) REFERENCES `aqorders` (`ordernumber`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `aqorders`
-- 
ALTER TABLE `aqorders`
  ADD CONSTRAINT `aqorders_ibfk_1` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `aqorders_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `aqorders_ibfk_3` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `aqorders_ibfk_4` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE;

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
  ADD CONSTRAINT `borrowers_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`),
  ADD CONSTRAINT `borrowers_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`),
  ADD CONSTRAINT `borrowers_ibfk_3` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`),
  ADD CONSTRAINT `borrowers_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`);

-- 
-- Contraintes pour la table `branchrelations`
-- 
ALTER TABLE `branchrelations`
  ADD CONSTRAINT `branchrelations_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `branchrelations_ibfk_2` FOREIGN KEY (`categorycode`) REFERENCES `branchcategories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `branchrelations_ibfk_3` FOREIGN KEY (`categorycode`) REFERENCES `branchcategories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `branchrelations_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `branchtransfers`
-- 
ALTER TABLE `branchtransfers`
  ADD CONSTRAINT `branchtransfers_ibfk_1` FOREIGN KEY (`frombranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `branchtransfers_ibfk_2` FOREIGN KEY (`tobranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `branchtransfers_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `branchtransfers_ibfk_4` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `branchtransfers_ibfk_5` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `issues`
-- 
ALTER TABLE `issues`
  ADD CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `issues_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `issues_ibfk_4` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL;

-- 
-- Contraintes pour la table `issuingrules`
-- 
ALTER TABLE `issuingrules`
  ADD CONSTRAINT `issuingrules_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `issuingrules_ibfk_2` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `issuingrules_ibfk_3` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `issuingrules_ibfk_4` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `items`
-- 
ALTER TABLE `items`
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblioitemnumber`) REFERENCES `biblioitems` (`biblioitemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `items_ibfk_2` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  ADD CONSTRAINT `items_ibfk_3` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  ADD CONSTRAINT `items_ibfk_4` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  ADD CONSTRAINT `items_ibfk_5` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  ADD CONSTRAINT `items_ibfk_6` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  ADD CONSTRAINT `items_ibfk_7` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `reserves`
-- 
ALTER TABLE `reserves`
  ADD CONSTRAINT `reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_10` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_5` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_6` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_7` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_8` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reserves_ibfk_9` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 
-- Contraintes pour la table `shelfcontents`
-- 
ALTER TABLE `shelfcontents`
  ADD CONSTRAINT `shelfcontents_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `bookshelf` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `shelfcontents_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `shelfcontents_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `shelfcontents_ibfk_4` FOREIGN KEY (`shelfnumber`) REFERENCES `bookshelf` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE;
