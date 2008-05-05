-- MySQL dump 10.9
--
-- Host: localhost    Database: koha30test
-- ------------------------------------------------------
-- Server version	4.1.22

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accountlines`
--

DROP TABLE IF EXISTS `accountlines`;
CREATE TABLE `accountlines` (
  `borrowernumber` int(11) NOT NULL default 0,
  `accountno` smallint(6) NOT NULL default 0,
  `itemnumber` int(11) default NULL,
  `date` date default NULL,
  `amount` decimal(28,6) default NULL,
  `description` mediumtext,
  `dispute` mediumtext,
  `accounttype` varchar(5) default NULL,
  `amountoutstanding` decimal(28,6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `notify_id` int(11) NOT NULL default 0,
  `notify_level` int(2) NOT NULL default 0,
  KEY `acctsborridx` (`borrowernumber`),
  KEY `timeidx` (`timestamp`),
  KEY `itemnumber` (`itemnumber`),
  CONSTRAINT `accountlines_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `accountoffsets`
--

DROP TABLE IF EXISTS `accountoffsets`;
CREATE TABLE `accountoffsets` (
  `borrowernumber` int(11) NOT NULL default 0,
  `accountno` smallint(6) NOT NULL default 0,
  `offsetaccount` smallint(6) NOT NULL default 0,
  `offsetamount` decimal(28,6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  CONSTRAINT `accountoffsets_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `action_logs`
--

DROP TABLE IF EXISTS `action_logs`;
CREATE TABLE `action_logs` (
  `action_id` int(11) NOT NULL auto_increment,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` int(11) NOT NULL default 0,
  `module` text,
  `action` text,
  `object` int(11) default NULL,
  `info` text,
  PRIMARY KEY (`action_id`),
  KEY  (`timestamp`,`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `alert`
--

DROP TABLE IF EXISTS `alert`;
CREATE TABLE `alert` (
  `alertid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) NOT NULL default 0,
  `type` varchar(10) NOT NULL default '',
  `externalid` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`alertid`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `type` (`type`,`externalid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqbasket`
--

DROP TABLE IF EXISTS `aqbasket`;
CREATE TABLE `aqbasket` (
  `basketno` int(11) NOT NULL auto_increment,
  `creationdate` date default NULL,
  `closedate` date default NULL,
  `booksellerid` int(11) NOT NULL default 1,
  `authorisedby` varchar(10) default NULL,
  `booksellerinvoicenumber` mediumtext,
  PRIMARY KEY  (`basketno`),
  KEY `booksellerid` (`booksellerid`),
  CONSTRAINT `aqbasket_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqbookfund`
--

DROP TABLE IF EXISTS `aqbookfund`;
CREATE TABLE `aqbookfund` (
  `bookfundid` varchar(10) NOT NULL default '',
  `bookfundname` mediumtext,
  `bookfundgroup` varchar(5) default NULL,
  `branchcode` varchar(10) NOT NULL default '',
  PRIMARY KEY  (`bookfundid`,`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqbooksellers`
--

DROP TABLE IF EXISTS `aqbooksellers`;
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
  `currency` varchar(3) NOT NULL default '',
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
  KEY `invoiceprice` (`invoiceprice`),
  CONSTRAINT `aqbooksellers_ibfk_1` FOREIGN KEY (`listprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqbooksellers_ibfk_2` FOREIGN KEY (`invoiceprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqbudget`
--

DROP TABLE IF EXISTS `aqbudget`;
CREATE TABLE `aqbudget` (
  `bookfundid` varchar(10) NOT NULL default '',
  `startdate` date NOT NULL default 0,
  `enddate` date default NULL,
  `budgetamount` decimal(13,2) default NULL,
  `aqbudgetid` tinyint(4) NOT NULL auto_increment,
  `branchcode` varchar(10) default NULL,
  PRIMARY KEY  (`aqbudgetid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqorderbreakdown`
--

DROP TABLE IF EXISTS `aqorderbreakdown`;
CREATE TABLE `aqorderbreakdown` (
  `ordernumber` int(11) default NULL,
  `linenumber` int(11) default NULL,
  `branchcode` varchar(10) default NULL,
  `bookfundid` varchar(10) NOT NULL default '',
  `allocation` smallint(6) default NULL,
  KEY `ordernumber` (`ordernumber`),
  KEY `bookfundid` (`bookfundid`),
  CONSTRAINT `aqorderbreakdown_ibfk_1` FOREIGN KEY (`ordernumber`) REFERENCES `aqorders` (`ordernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorderbreakdown_ibfk_2` FOREIGN KEY (`bookfundid`) REFERENCES `aqbookfund` (`bookfundid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqorderdelivery`
--

DROP TABLE IF EXISTS `aqorderdelivery`;
CREATE TABLE `aqorderdelivery` (
  `ordernumber` date default NULL,
  `deliverynumber` smallint(6) NOT NULL default 0,
  `deliverydate` varchar(18) default NULL,
  `qtydelivered` smallint(6) default NULL,
  `deliverycomments` mediumtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqorders`
--

DROP TABLE IF EXISTS `aqorders`;
CREATE TABLE `aqorders` (
  `ordernumber` int(11) NOT NULL auto_increment,
  `biblionumber` int(11) default NULL,
  `title` mediumtext,
  `entrydate` date default NULL,
  `quantity` smallint(6) default NULL,
  `currency` varchar(3) default NULL,
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
  KEY `biblionumber` (`biblionumber`),
  CONSTRAINT `aqorders_ibfk_1` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorders_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `auth_header`
--

DROP TABLE IF EXISTS `auth_header`;
CREATE TABLE `auth_header` (
  `authid` bigint(20) unsigned NOT NULL auto_increment,
  `authtypecode` varchar(10) NOT NULL default '',
  `datecreated` date default NULL,
  `datemodified` date default NULL,
  `origincode` varchar(20) default NULL,
  `authtrees` mediumtext,
  `marc` blob,
  `linkid` bigint(20) default NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY  (`authid`),
  KEY `origincode` (`origincode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `auth_subfield_structure`
--

DROP TABLE IF EXISTS `auth_subfield_structure`;
CREATE TABLE `auth_subfield_structure` (
  `authtypecode` varchar(10) NOT NULL default '',
  `tagfield` varchar(3) NOT NULL default '',
  `tagsubfield` varchar(1) NOT NULL default '',
  `liblibrarian` varchar(255) NOT NULL default '',
  `libopac` varchar(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default 0,
  `mandatory` tinyint(4) NOT NULL default 0,
  `tab` tinyint(1) default NULL,
  `authorised_value` varchar(10) default NULL,
  `value_builder` varchar(80) default NULL,
  `seealso` varchar(255) default NULL,
  `isurl` tinyint(1) default NULL,
  `hidden` tinyint(3) NOT NULL default 0,
  `linkid` tinyint(1) NOT NULL default 0,
  `kohafield` varchar(45) NULL default '',
  `frameworkcode` varchar(8) NOT NULL default '',
  PRIMARY KEY  (`authtypecode`,`tagfield`,`tagsubfield`),
  KEY `tab` (`authtypecode`,`tab`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `auth_tag_structure`
--

DROP TABLE IF EXISTS `auth_tag_structure`;
CREATE TABLE `auth_tag_structure` (
  `authtypecode` varchar(10) NOT NULL default '',
  `tagfield` varchar(3) NOT NULL default '',
  `liblibrarian` varchar(255) NOT NULL default '',
  `libopac` varchar(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default 0,
  `mandatory` tinyint(4) NOT NULL default 0,
  `authorised_value` varchar(10) default NULL,
  PRIMARY KEY  (`authtypecode`,`tagfield`),
  CONSTRAINT `auth_tag_structure_ibfk_1` FOREIGN KEY (`authtypecode`) REFERENCES `auth_types` (`authtypecode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `auth_types`
--

DROP TABLE IF EXISTS `auth_types`;
CREATE TABLE `auth_types` (
  `authtypecode` varchar(10) NOT NULL default '',
  `authtypetext` varchar(255) NOT NULL default '',
  `auth_tag_to_report` varchar(3) NOT NULL default '',
  `summary` mediumtext NOT NULL,
  PRIMARY KEY  (`authtypecode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `authorised_values`
--

DROP TABLE IF EXISTS `authorised_values`;
CREATE TABLE `authorised_values` (
  `id` int(11) NOT NULL auto_increment,
  `category` varchar(10) NOT NULL default '',
  `authorised_value` varchar(80) NOT NULL default '',
  `lib` varchar(80) default NULL,
  PRIMARY KEY  (`id`),
  KEY `name` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `biblio`
--

DROP TABLE IF EXISTS `biblio`;
CREATE TABLE `biblio` (
  `biblionumber` int(11) NOT NULL auto_increment,
  `frameworkcode` varchar(4) NOT NULL default '',
  `author` mediumtext,
  `title` mediumtext,
  `unititle` mediumtext,
  `notes` mediumtext,
  `serial` tinyint(1) default NULL,
  `seriestitle` mediumtext,
  `copyrightdate` smallint(6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `datecreated` DATE NOT NULL,
  `abstract` mediumtext,
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `biblio_framework`
--

DROP TABLE IF EXISTS `biblio_framework`;
CREATE TABLE `biblio_framework` (
  `frameworkcode` varchar(4) NOT NULL default '',
  `frameworktext` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`frameworkcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `biblioitems`
--

DROP TABLE IF EXISTS `biblioitems`;
CREATE TABLE `biblioitems` (
  `biblioitemnumber` int(11) NOT NULL auto_increment,
  `biblionumber` int(11) NOT NULL default 0,
  `volume` mediumtext,
  `number` mediumtext,
  `itemtype` varchar(10) default NULL,
  `isbn` varchar(14) default NULL,
  `issn` varchar(9) default NULL,
  `publicationyear` text,
  `publishercode` varchar(255) default NULL,
  `volumedate` date default NULL,
  `volumedesc` text,
  `collectiontitle` mediumtext default NULL,
  `collectionissn` text default NULL,
  `collectionvolume` mediumtext default NULL,
  `editionstatement` text default NULL,
  `editionresponsibility` text default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL,
  `pages` varchar(255) default NULL,
  `notes` mediumtext,
  `size` varchar(255) default NULL,
  `place` varchar(255) default NULL,
  `lccn` varchar(25) default NULL,
  `marc` longblob,
  `url` varchar(255) default NULL,
  `cn_source` varchar(10) default NULL,
  `cn_class` varchar(30) default NULL,
  `cn_item` varchar(10) default NULL,
  `cn_suffix` varchar(10) default NULL,
  `cn_sort` varchar(30) default NULL,
  `totalissues` int(10),
  `marcxml` longtext NOT NULL,
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `isbn` (`isbn`),
  KEY `publishercode` (`publishercode`),
  CONSTRAINT `biblioitems_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `borrowers`
--

DROP TABLE IF EXISTS `borrowers`;
CREATE TABLE `borrowers` (
  `borrowernumber` int(11) NOT NULL auto_increment,
  `cardnumber` varchar(16) default NULL,
  `surname` mediumtext NOT NULL,
  `firstname` text,
  `title` mediumtext,
  `othernames` mediumtext,
  `initials` text,
  `streetnumber` varchar(10) default NULL,
  `streettype` varchar(50) default NULL,
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
  `B_streetnumber` varchar(10) default NULL,
  `B_streettype` varchar(50) default NULL,
  `B_address` varchar(100) default NULL,
  `B_city` mediumtext,
  `B_zipcode` varchar(25) default NULL,
  `B_email` text,
  `B_phone` mediumtext,
  `dateofbirth` date default NULL,
  `branchcode` varchar(10) NOT NULL default '',
  `categorycode` varchar(10) NOT NULL default '',
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
  `sex` varchar(1) default NULL,
  `password` varchar(30) default NULL,
  `flags` int(11) default NULL,
  `userid` varchar(30) default NULL,
  `opacnote` mediumtext,
  `contactnote` varchar(255) default NULL,
  `sort1` varchar(80) default NULL,
  `sort2` varchar(80) default NULL,
  `altcontactfirstname` varchar(255) default NULL,
  `altcontactsurname` varchar(255) default NULL,
  `altcontactaddress1` varchar(255) default NULL,
  `altcontactaddress2` varchar(255) default NULL,
  `altcontactaddress3` varchar(255) default NULL,
  `altcontactzipcode` varchar(50) default NULL,
  `altcontactphone` varchar(50) default NULL,
  UNIQUE KEY `cardnumber` (`cardnumber`),
  PRIMARY KEY `borrowernumber` (`borrowernumber`),
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`),
  KEY `userid` (`userid`),
  CONSTRAINT `borrowers_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`),
  CONSTRAINT `borrowers_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `branchcategories`
--

DROP TABLE IF EXISTS `branchcategories`;
CREATE TABLE `branchcategories` (
  `categorycode` varchar(10) NOT NULL default '',
  `categoryname` varchar(32),
  `codedescription` mediumtext,
  `categorytype` varchar(16),
  PRIMARY KEY  (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
CREATE TABLE `branches` (
  `branchcode` varchar(10) NOT NULL default '',
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

--
-- Table structure for table `branchrelations`
--

DROP TABLE IF EXISTS `branchrelations`;
CREATE TABLE `branchrelations` (
  `branchcode` varchar(10) NOT NULL default '',
  `categorycode` varchar(10) NOT NULL default '',
  PRIMARY KEY  (`branchcode`,`categorycode`),
  KEY `branchcode` (`branchcode`),
  KEY `categorycode` (`categorycode`),
  CONSTRAINT `branchrelations_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchrelations_ibfk_2` FOREIGN KEY (`categorycode`) REFERENCES `branchcategories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `branchtransfers`
--

DROP TABLE IF EXISTS `branchtransfers`;
CREATE TABLE `branchtransfers` (
  `itemnumber` int(11) NOT NULL default 0,
  `datesent` datetime default NULL,
  `frombranch` varchar(10) NOT NULL default '',
  `datearrived` datetime default NULL,
  `tobranch` varchar(10) NOT NULL default '',
  `comments` mediumtext,
  KEY `frombranch` (`frombranch`),
  KEY `tobranch` (`tobranch`),
  KEY `itemnumber` (`itemnumber`),
  CONSTRAINT `branchtransfers_ibfk_1` FOREIGN KEY (`frombranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchtransfers_ibfk_2` FOREIGN KEY (`tobranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchtransfers_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `browser`
--
DROP TABLE IF EXISTS `browser`;
CREATE TABLE `browser` (
  `level` int(11) NOT NULL,
  `classification` varchar(20) NOT NULL,
  `description` varchar(255) NOT NULL,
  `number` bigint(20) NOT NULL,
  `endnode` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `categorycode` varchar(10) NOT NULL default '',
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
  `category_type` varchar(1) NOT NULL default 'A',
  PRIMARY KEY  (`categorycode`),
  UNIQUE KEY `categorycode` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `categorytable`
--

DROP TABLE IF EXISTS `categorytable`;
CREATE TABLE `categorytable` (
  `categorycode` varchar(5) NOT NULL default '',
  `description` text,
  `itemtypecodes` text,
  PRIMARY KEY  (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
CREATE TABLE `cities` (
  `cityid` int(11) NOT NULL auto_increment,
  `city_name` varchar(100) NOT NULL default '',
  `city_zipcode` varchar(20) default NULL,
  PRIMARY KEY  (`cityid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `class_sort_rules`
--

DROP TABLE IF EXISTS `class_sort_rules`;
CREATE TABLE `class_sort_rules` (
  `class_sort_rule` varchar(10) NOT NULL default '',
  `description` mediumtext,
  `sort_routine` varchar(30) NOT NULL default '',
  PRIMARY KEY (`class_sort_rule`),
  UNIQUE KEY `class_sort_rule_idx` (`class_sort_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `class_sources`
--

DROP TABLE IF EXISTS `class_sources`;
CREATE TABLE `class_sources` (
  `cn_source` varchar(10) NOT NULL default '',
  `description` mediumtext,
  `used` tinyint(4) NOT NULL default 0,
  `class_sort_rule` varchar(10) NOT NULL default '',
  PRIMARY KEY (`cn_source`),
  UNIQUE KEY `cn_source_idx` (`cn_source`),
  KEY `used_idx` (`used`),
  CONSTRAINT `class_source_ibfk_1` FOREIGN KEY (`class_sort_rule`) REFERENCES `class_sort_rules` (`class_sort_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `currency`
--

DROP TABLE IF EXISTS `currency`;
CREATE TABLE `currency` (
  `currency` varchar(10) NOT NULL default '',
  `symbol` varchar(5) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `rate` float(7,5) default NULL,
  PRIMARY KEY  (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `deletedbiblio`
--

DROP TABLE IF EXISTS `deletedbiblio`;
CREATE TABLE `deletedbiblio` (
  `biblionumber` int(11) NOT NULL default 0,
  `frameworkcode` varchar(4) NOT NULL default '',
  `author` mediumtext,
  `title` mediumtext,
  `unititle` mediumtext,
  `notes` mediumtext,
  `serial` tinyint(1) default NULL,
  `seriestitle` mediumtext,
  `copyrightdate` smallint(6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `datecreated` DATE NOT NULL,
  `abstract` mediumtext,
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `deletedbiblioitems`
--

DROP TABLE IF EXISTS `deletedbiblioitems`;
CREATE TABLE `deletedbiblioitems` (
  `biblioitemnumber` int(11) NOT NULL default 0,
  `biblionumber` int(11) NOT NULL default 0,
  `volume` mediumtext,
  `number` mediumtext,
  `itemtype` varchar(10) default NULL,
  `isbn` varchar(14) default NULL,
  `issn` varchar(9) default NULL,
  `publicationyear` text,
  `publishercode` varchar(255) default NULL,
  `volumedate` date default NULL,
  `volumedesc` text,
  `collectiontitle` mediumtext default NULL,
  `collectionissn` text default NULL,
  `collectionvolume` mediumtext default NULL,
  `editionstatement` text default NULL,
  `editionresponsibility` text default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL,
  `pages` varchar(255) default NULL,
  `notes` mediumtext,
  `size` varchar(255) default NULL,
  `place` varchar(255) default NULL,
  `lccn` varchar(25) default NULL,
  `marc` longblob,
  `url` varchar(255) default NULL,
  `cn_source` varchar(10) default NULL,
  `cn_class` varchar(30) default NULL,
  `cn_item` varchar(10) default NULL,
  `cn_suffix` varchar(10) default NULL,
  `cn_sort` varchar(30) default NULL,
  `totalissues` int(10),
  `marcxml` longtext NOT NULL,
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `isbn` (`isbn`),
  KEY `publishercode` (`publishercode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `deletedborrowers`
--

DROP TABLE IF EXISTS `deletedborrowers`;
CREATE TABLE `deletedborrowers` (
  `borrowernumber` int(11) NOT NULL default 0,
  `cardnumber` varchar(9) NOT NULL default '',
  `surname` mediumtext NOT NULL,
  `firstname` text,
  `title` mediumtext,
  `othernames` mediumtext,
  `initials` text,
  `streetnumber` varchar(10) default NULL,
  `streettype` varchar(50) default NULL,
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
  `B_streetnumber` varchar(10) default NULL,
  `B_streettype` varchar(50) default NULL,
  `B_address` varchar(100) default NULL,
  `B_city` mediumtext,
  `B_zipcode` varchar(25) default NULL,
  `B_email` text,
  `B_phone` mediumtext,
  `dateofbirth` date default NULL,
  `branchcode` varchar(10) NOT NULL default '',
  `categorycode` varchar(2) default NULL,
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
  `sex` varchar(1) default NULL,
  `password` varchar(30) default NULL,
  `flags` int(11) default NULL,
  `userid` varchar(30) default NULL,
  `opacnote` mediumtext,
  `contactnote` varchar(255) default NULL,
  `sort1` varchar(80) default NULL,
  `sort2` varchar(80) default NULL,
  `altcontactfirstname` varchar(255) default NULL,
  `altcontactsurname` varchar(255) default NULL,
  `altcontactaddress1` varchar(255) default NULL,
  `altcontactaddress2` varchar(255) default NULL,
  `altcontactaddress3` varchar(255) default NULL,
  `altcontactzipcode` varchar(50) default NULL,
  `altcontactphone` varchar(50) default NULL,
  KEY `borrowernumber` (`borrowernumber`),
  KEY `cardnumber` (`cardnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `deleteditems`
--

DROP TABLE IF EXISTS `deleteditems`;
CREATE TABLE `deleteditems` (
  `itemnumber` int(11) NOT NULL default 0,
  `biblionumber` int(11) NOT NULL default 0,
  `biblioitemnumber` int(11) NOT NULL default 0,
  `barcode` varchar(20) default NULL,
  `dateaccessioned` date default NULL,
  `booksellerid` mediumtext default NULL,
  `homebranch` varchar(10) default NULL,
  `price` decimal(8,2) default NULL,
  `replacementprice` decimal(8,2) default NULL,
  `replacementpricedate` date default NULL,
  `datelastborrowed` date default NULL,
  `datelastseen` date default NULL,
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) NOT NULL default 0,
  `damaged` tinyint(1) NOT NULL default 0,
  `itemlost` tinyint(1) NOT NULL default 0,
  `wthdrawn` tinyint(1) NOT NULL default 0,
  `itemcallnumber` varchar(30) default NULL,
  `issues` smallint(6) default NULL,
  `renewals` smallint(6) default NULL,
  `reserves` smallint(6) default NULL,
  `restricted` tinyint(1) default NULL,
  `itemnotes` mediumtext,
  `holdingbranch` varchar(10) default NULL,
  `paidfor` mediumtext,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `location` varchar(80) default NULL,
  `onloan` date default NULL,
  `cn_source` varchar(10) default NULL,
  `cn_sort` varchar(30) default NULL,
  `ccode` varchar(10) default NULL,
  `materials` varchar(10) default NULL,
  `uri` varchar(255) default NULL,
  `itype` varchar(10) default NULL,
  `more_subfields_xml` longtext default NULL,
  `enumchron` varchar(80) default NULL,
  `copynumber` smallint(6) default NULL,
  `marc` longblob,
  PRIMARY KEY  (`itemnumber`),
  KEY `delitembarcodeidx` (`barcode`),
  KEY `delitembinoidx` (`biblioitemnumber`),
  KEY `delitembibnoidx` (`biblionumber`),
  KEY `delhomebranch` (`homebranch`),
  KEY `delholdingbranch` (`holdingbranch`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `ethnicity`
--

DROP TABLE IF EXISTS `ethnicity`;
CREATE TABLE `ethnicity` (
  `code` varchar(10) NOT NULL default '',
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `import_batches`
--

DROP TABLE IF EXISTS `import_batches`;
CREATE TABLE `import_batches` (
  `import_batch_id` int(11) NOT NULL auto_increment,
  `matcher_id` int(11) default NULL,
  `template_id` int(11) default NULL,
  `branchcode` varchar(10) default NULL,
  `num_biblios` int(11) NOT NULL default 0,
  `num_items` int(11) NOT NULL default 0,
  `upload_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `overlay_action` enum('replace', 'create_new', 'use_template') NOT NULL default 'create_new',
  `import_status` enum('staging', 'staged', 'importing', 'imported', 'reverting', 'reverted', 'cleaned') NOT NULL default 'staging',
  `batch_type` enum('batch', 'z3950') NOT NULL default 'batch',
  `file_name` varchar(100),
  `comments` mediumtext,
  PRIMARY KEY (`import_batch_id`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `import_records`
--

DROP TABLE IF EXISTS `import_records`;
CREATE TABLE `import_records` (
  `import_record_id` int(11) NOT NULL auto_increment,
  `import_batch_id` int(11) NOT NULL,
  `branchcode` varchar(10) default NULL,
  `record_sequence` int(11) NOT NULL default 0,
  `upload_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `import_date` DATE default NULL,
  `marc` longblob NOT NULL,
  `marcxml` longtext NOT NULL,
  `marcxml_old` longtext NOT NULL,
  `record_type` enum('biblio', 'auth', 'holdings') NOT NULL default 'biblio',
  `overlay_status` enum('no_match', 'auto_match', 'manual_match', 'match_applied') NOT NULL default 'no_match',
  `status` enum('error', 'staged', 'imported', 'reverted', 'items_reverted') NOT NULL default 'staged',
  `import_error` mediumtext,
  `encoding` varchar(40) NOT NULL default '',
  `z3950random` varchar(40) default NULL,
  PRIMARY KEY (`import_record_id`),
  CONSTRAINT `import_records_ifbk_1` FOREIGN KEY (`import_batch_id`)
             REFERENCES `import_batches` (`import_batch_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `branchcode` (`branchcode`),
  KEY `batch_sequence` (`import_batch_id`, `record_sequence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for `import_record_matches`
--
DROP TABLE IF EXISTS `import_record_matches`;
CREATE TABLE `import_record_matches` (
  `import_record_id` int(11) NOT NULL,
  `candidate_match_id` int(11) NOT NULL,
  `score` int(11) NOT NULL default 0,
  CONSTRAINT `import_record_matches_ibfk_1` FOREIGN KEY (`import_record_id`) 
             REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `record_score` (`import_record_id`, `score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `import_biblios`
--

DROP TABLE IF EXISTS `import_biblios`;
CREATE TABLE `import_biblios` (
  `import_record_id` int(11) NOT NULL,
  `matched_biblionumber` int(11) default NULL,
  `control_number` varchar(25) default NULL,
  `original_source` varchar(25) default NULL,
  `title` varchar(128) default NULL,
  `author` varchar(80) default NULL,
  `isbn` varchar(14) default NULL,
  `issn` varchar(9) default NULL,
  `has_items` tinyint(1) NOT NULL default 0,
  CONSTRAINT `import_biblios_ibfk_1` FOREIGN KEY (`import_record_id`) 
             REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `matched_biblionumber` (`matched_biblionumber`),
  KEY `title` (`title`),
  KEY `isbn` (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `import_items`
--

DROP TABLE IF EXISTS `import_items`;
CREATE TABLE `import_items` (
  `import_items_id` int(11) NOT NULL auto_increment,
  `import_record_id` int(11) NOT NULL,
  `itemnumber` int(11) default NULL,
  `branchcode` varchar(10) default NULL,
  `status` enum('error', 'staged', 'imported', 'reverted') NOT NULL default 'staged',
  `marcxml` longtext NOT NULL,
  `import_error` mediumtext,
  PRIMARY KEY (`import_items_id`),
  CONSTRAINT `import_items_ibfk_1` FOREIGN KEY (`import_record_id`) 
             REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `issues`
--

DROP TABLE IF EXISTS `issues`;
CREATE TABLE `issues` (
  `borrowernumber` int(11) default NULL,
  `itemnumber` int(11) default NULL,
  `date_due` date default NULL,
  `branchcode` varchar(10) default NULL,
  `issuingbranch` varchar(18) default NULL,
  `returndate` date default NULL,
  `lastreneweddate` date default NULL,
  `return` varchar(4) default NULL,
  `renewals` tinyint(4) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `issuedate` date default NULL,
  KEY `issuesborridx` (`borrowernumber`),
  KEY `issuesitemidx` (`itemnumber`),
  KEY `bordate` (`borrowernumber`,`timestamp`),
  CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `issuingrules`
--

DROP TABLE IF EXISTS `issuingrules`;
CREATE TABLE `issuingrules` (
  `categorycode` varchar(10) NOT NULL default '',
  `itemtype` varchar(10) NOT NULL default '',
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
  `branchcode` varchar(10) NOT NULL default '',
  PRIMARY KEY  (`branchcode`,`categorycode`,`itemtype`),
  KEY `categorycode` (`categorycode`),
  KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
CREATE TABLE `items` (
  `itemnumber` int(11) NOT NULL auto_increment,
  `biblionumber` int(11) NOT NULL default 0,
  `biblioitemnumber` int(11) NOT NULL default 0,
  `barcode` varchar(20) default NULL,
  `dateaccessioned` date default NULL,
  `booksellerid` mediumtext default NULL,
  `homebranch` varchar(10) default NULL,
  `price` decimal(8,2) default NULL,
  `replacementprice` decimal(8,2) default NULL,
  `replacementpricedate` date default NULL,
  `datelastborrowed` date default NULL,
  `datelastseen` date default NULL,
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) NOT NULL default 0,
  `damaged` tinyint(1) NOT NULL default 0,
  `itemlost` tinyint(1) NOT NULL default 0,
  `wthdrawn` tinyint(1) NOT NULL default 0,
  `itemcallnumber` varchar(30) default NULL,
  `issues` smallint(6) default NULL,
  `renewals` smallint(6) default NULL,
  `reserves` smallint(6) default NULL,
  `restricted` tinyint(1) default NULL,
  `itemnotes` mediumtext,
  `holdingbranch` varchar(10) default NULL,
  `paidfor` mediumtext,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `location` varchar(80) default NULL,
  `onloan` date default NULL,
  `cn_source` varchar(10) default NULL,
  `cn_sort` varchar(30) default NULL,
  `ccode` varchar(10) default NULL,
  `materials` varchar(10) default NULL,
  `uri` varchar(255) default NULL,
  `itype` varchar(10) default NULL,
  `more_subfields_xml` longtext default NULL,
  `enumchron` varchar(80) default NULL,
  `copynumber` smallint(6) default NULL,
  PRIMARY KEY  (`itemnumber`),
  UNIQUE KEY `itembarcodeidx` (`barcode`),
  KEY `itembinoidx` (`biblioitemnumber`),
  KEY `itembibnoidx` (`biblionumber`),
  KEY `homebranch` (`homebranch`),
  KEY `holdingbranch` (`holdingbranch`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblioitemnumber`) REFERENCES `biblioitems` (`biblioitemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `itemtypes`
--

DROP TABLE IF EXISTS `itemtypes`;
CREATE TABLE `itemtypes` (
  `itemtype` varchar(10) NOT NULL default '',
  `description` mediumtext,
  `renewalsallowed` smallint(6) default NULL,
  `rentalcharge` double(16,4) default NULL,
  `notforloan` smallint(6) default NULL,
  `imageurl` varchar(200) default NULL,
  `summary` text,
  PRIMARY KEY  (`itemtype`),
  UNIQUE KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `labels`
--

DROP TABLE IF EXISTS `labels`;
CREATE TABLE `labels` (
  `labelid` int(11) NOT NULL auto_increment,
  `batch_id` varchar(10) NOT NULL default 1,
  `itemnumber` varchar(100) NOT NULL default '',
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`labelid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `labels_conf`
--

DROP TABLE IF EXISTS `labels_conf`;
CREATE TABLE `labels_conf` (
 `id` int(4) NOT NULL auto_increment,
  `barcodetype` char(100) default '',
  `title` int(1) default '0',
  `subtitle` int(1) default '0',
  `itemtype` int(1) default '0',
  `barcode` int(1) default '0',
  `dewey` int(1) default '0',
  `class` int(1) default NULL,
  `subclass` int(1) default '0',
  `itemcallnumber` int(1) default '0',
  `author` int(1) default '0',
  `issn` int(1) default '0',
  `isbn` int(1) default '0',
  `startlabel` int(2) NOT NULL default '1',
  `printingtype` char(32) default 'BAR',
  `layoutname` char(20) NOT NULL default 'TEST',
  `guidebox` int(1) default '0',
  `active` tinyint(1) default '1',
  `fonttype` char(10) collate utf8_unicode_ci default NULL,
  `ccode` char(4) collate utf8_unicode_ci default NULL,
  `callnum_split` int(1) default NULL,
  `text_justify` char(1) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `labels_profile`
--

DROP TABLE IF EXISTS `labels_profile`;
CREATE TABLE `labels_profile` (
  `tmpl_id` int(4) NOT NULL,
  `prof_id` int(4) NOT NULL,
  UNIQUE KEY `tmpl_id` (`tmpl_id`),
  UNIQUE KEY `prof_id` (`prof_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `labels_templates`
--

DROP TABLE IF EXISTS `labels_templates`;
CREATE TABLE `labels_templates` (
`tmpl_id` int(4) NOT NULL auto_increment,
  `tmpl_code` char(100)  default '',
  `tmpl_desc` char(100) default '',
  `page_width` float default '0',
  `page_height` float default '0',
  `label_width` float default '0',
  `label_height` float default '0',
  `topmargin` float default '0',
  `leftmargin` float default '0',
  `cols` int(2) default '0',
  `rows` int(2) default '0',
  `colgap` float default '0',
  `rowgap` float default '0',
  `active` int(1) default NULL,
  `units` char(20)  default 'PX',
  `fontsize` int(4) NOT NULL default '3',
  `font` char(10) NOT NULL default 'TR',
  PRIMARY KEY  (`tmpl_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `letter`
--

DROP TABLE IF EXISTS `letter`;
CREATE TABLE `letter` (
  `module` varchar(20) NOT NULL default '',
  `code` varchar(20) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  `title` varchar(200) NOT NULL default '',
  `content` text,
  PRIMARY KEY  (`module`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `marc_subfield_structure`
--

DROP TABLE IF EXISTS `marc_subfield_structure`;
CREATE TABLE `marc_subfield_structure` (
  `tagfield` varchar(3) NOT NULL default '',
  `tagsubfield` varchar(1) NOT NULL default '',
  `liblibrarian` varchar(255) NOT NULL default '',
  `libopac` varchar(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default 0,
  `mandatory` tinyint(4) NOT NULL default 0,
  `kohafield` varchar(40) default NULL,
  `tab` tinyint(1) default NULL,
  `authorised_value` varchar(20) default NULL,
  `authtypecode` varchar(20) default NULL,
  `value_builder` varchar(80) default NULL,
  `isurl` tinyint(1) default NULL,
  `hidden` tinyint(1) default NULL,
  `frameworkcode` varchar(4) NOT NULL default '',
  `seealso` varchar(1100) default NULL,
  `link` varchar(80) default NULL,
  `defaultvalue` text default NULL,
  PRIMARY KEY  (`frameworkcode`,`tagfield`,`tagsubfield`),
  KEY `kohafield_2` (`kohafield`),
  KEY `tab` (`frameworkcode`,`tab`),
  KEY `kohafield` (`frameworkcode`,`kohafield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `marc_tag_structure`
--

DROP TABLE IF EXISTS `marc_tag_structure`;
CREATE TABLE `marc_tag_structure` (
  `tagfield` varchar(3) NOT NULL default '',
  `liblibrarian` varchar(255) NOT NULL default '',
  `libopac` varchar(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default 0,
  `mandatory` tinyint(4) NOT NULL default 0,
  `authorised_value` varchar(10) default NULL,
  `frameworkcode` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`frameworkcode`,`tagfield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `marc_matchers`
--

DROP TABLE IF EXISTS `marc_matchers`;
CREATE TABLE `marc_matchers` (
  `matcher_id` int(11) NOT NULL auto_increment,
  `code` varchar(10) NOT NULL default '',
  `description` varchar(255) NOT NULL default '',
  `record_type` varchar(10) NOT NULL default 'biblio',
  `threshold` int(11) NOT NULL default 0,
  PRIMARY KEY (`matcher_id`),
  KEY `code` (`code`),
  KEY `record_type` (`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `matchpoints`
--
DROP TABLE IF EXISTS `matchpoints`;
CREATE TABLE `matchpoints` (
  `matcher_id` int(11) NOT NULL,
  `matchpoint_id` int(11) NOT NULL auto_increment,
  `search_index` varchar(30) NOT NULL default '',
  `score` int(11) NOT NULL default 0,
  PRIMARY KEY (`matchpoint_id`),
  CONSTRAINT `matchpoints_ifbk_1` FOREIGN KEY (`matcher_id`)
  REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `matchpoint_components`
--
DROP TABLE IF EXISTS `matchpoint_components`;
CREATE TABLE `matchpoint_components` (
  `matchpoint_id` int(11) NOT NULL,
  `matchpoint_component_id` int(11) NOT NULL auto_increment,
  sequence int(11) NOT NULL default 0,
  tag varchar(3) NOT NULL default '',
  subfields varchar(40) NOT NULL default '',
  offset int(4) NOT NULL default 0,
  length int(4) NOT NULL default 0,
  PRIMARY KEY (`matchpoint_component_id`),
  KEY `by_sequence` (`matchpoint_id`, `sequence`),
  CONSTRAINT `matchpoint_components_ifbk_1` FOREIGN KEY (`matchpoint_id`)
  REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `matcher_component_norms`
--
DROP TABLE IF EXISTS `matchpoint_component_norms`;
CREATE TABLE `matchpoint_component_norms` (
  `matchpoint_component_id` int(11) NOT NULL,
  `sequence`  int(11) NOT NULL default 0,
  `norm_routine` varchar(50) NOT NULL default '',
  KEY `matchpoint_component_norms` (`matchpoint_component_id`, `sequence`),
  CONSTRAINT `matchpoint_component_norms_ifbk_1` FOREIGN KEY (`matchpoint_component_id`)
  REFERENCES `matchpoint_components` (`matchpoint_component_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `matcher_matchpoints`
--
DROP TABLE IF EXISTS `matcher_matchpoints`;
CREATE TABLE `matcher_matchpoints` (
  `matcher_id` int(11) NOT NULL,
  `matchpoint_id` int(11) NOT NULL,
  CONSTRAINT `matcher_matchpoints_ifbk_1` FOREIGN KEY (`matcher_id`)
  REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchpoints_ifbk_2` FOREIGN KEY (`matchpoint_id`)
  REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `matchchecks`
--
DROP TABLE IF EXISTS `matchchecks`;
CREATE TABLE `matchchecks` (
  `matcher_id` int(11) NOT NULL,
  `matchcheck_id` int(11) NOT NULL auto_increment,
  `source_matchpoint_id` int(11) NOT NULL,
  `target_matchpoint_id` int(11) NOT NULL,
  PRIMARY KEY (`matchcheck_id`),
  CONSTRAINT `matcher_matchchecks_ifbk_1` FOREIGN KEY (`matcher_id`)
  REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchchecks_ifbk_2` FOREIGN KEY (`source_matchpoint_id`)
  REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchchecks_ifbk_3` FOREIGN KEY (`target_matchpoint_id`)
  REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `mediatypetable`
--

DROP TABLE IF EXISTS `mediatypetable`;
CREATE TABLE `mediatypetable` (
  `mediatypecode` varchar(5) NOT NULL default '',
  `description` text,
  `itemtypecodes` text,
  PRIMARY KEY  (`mediatypecode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `notifys`
--

DROP TABLE IF EXISTS `notifys`;
CREATE TABLE `notifys` (
  `notify_id` int(11) NOT NULL default 0,
  `borrowernumber` int(11) NOT NULL default 0,
  `itemnumber` int(11) NOT NULL default 0,
  `notify_date` date default NULL,
  `notify_send_date` date default NULL,
  `notify_level` int(1) NOT NULL default 0,
  `method` varchar(20) NOT NULL default ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `nozebra`
--

DROP TABLE IF EXISTS `nozebra`;
CREATE TABLE `nozebra` (
                `server` varchar(20)     NOT NULL,
                `indexname` varchar(40)  NOT NULL,
                `value` varchar(250)     NOT NULL,
                `biblionumbers` longtext NOT NULL,
                KEY `indexname` (`server`,`indexname`),
                KEY `value` (`server`,`value`))
                ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `old_issues`
--

DROP TABLE IF EXISTS `old_issues`;
CREATE TABLE `old_issues` (
  `borrowernumber` int(11) default NULL,
  `itemnumber` int(11) default NULL,
  `date_due` date default NULL,
  `branchcode` varchar(10) default NULL,
  `issuingbranch` varchar(18) default NULL,
  `returndate` date default NULL,
  `lastreneweddate` date default NULL,
  `return` varchar(4) default NULL,
  `renewals` tinyint(4) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `issuedate` date default NULL,
  KEY `old_issuesborridx` (`borrowernumber`),
  KEY `old_issuesitemidx` (`itemnumber`),
  KEY `old_bordate` (`borrowernumber`,`timestamp`),
  CONSTRAINT `old_issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) 
    ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) 
    ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `old_reserves`
--
DROP TABLE IF EXISTS `old_reserves`;
CREATE TABLE `old_reserves` (
  `borrowernumber` int(11) default NULL,
  `reservedate` date default NULL,
  `biblionumber` int(11) default NULL,
  `constrainttype` varchar(1) default NULL,
  `branchcode` varchar(10) default NULL,
  `notificationdate` date default NULL,
  `reminderdate` date default NULL,
  `cancellationdate` date default NULL,
  `reservenotes` mediumtext,
  `priority` smallint(6) default NULL,
  `found` varchar(1) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `itemnumber` int(11) default NULL,
  `waitingdate` date default NULL,
  KEY `old_reserves_borrowernumber` (`borrowernumber`),
  KEY `old_reserves_biblionumber` (`biblionumber`),
  KEY `old_reserves_itemnumber` (`itemnumber`),
  KEY `old_reserves_branchcode` (`branchcode`),
  CONSTRAINT `old_reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) 
    ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) 
    ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) 
    ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `opac_news`
--

DROP TABLE IF EXISTS `opac_news`;
CREATE TABLE `opac_news` (
  `idnew` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(250) NOT NULL default '',
  `new` text NOT NULL,
  `lang` varchar(25) NOT NULL default '',
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `expirationdate` date default NULL,
  `number` int(11) default NULL,
  PRIMARY KEY  (`idnew`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `overduerules`
--

DROP TABLE IF EXISTS `overduerules`;
CREATE TABLE `overduerules` (
  `branchcode` varchar(10) NOT NULL default '',
  `categorycode` varchar(2) NOT NULL default '',
  `delay1` int(4) default 0,
  `letter1` varchar(20) default NULL,
  `debarred1` varchar(1) default 0,
  `delay2` int(4) default 0,
  `debarred2` varchar(1) default 0,
  `letter2` varchar(20) default NULL,
  `delay3` int(4) default 0,
  `letter3` varchar(20) default NULL,
  `debarred3` int(1) default 0,
  PRIMARY KEY  (`branchcode`,`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `patroncards`
--

DROP TABLE IF EXISTS `patroncards`;
CREATE TABLE `patroncards` (
  `cardid` int(11) NOT NULL auto_increment,
  `batch_id` varchar(10) NOT NULL default '1',
  `borrowernumber` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
   PRIMARY KEY  (`cardid`),
   KEY `patroncards_ibfk_1` (`borrowernumber`),
   CONSTRAINT `patroncards_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `patronimage`
--

DROP TABLE IF EXISTS `patronimage`;
CREATE TABLE `patronimage` (
  `cardnumber` varchar(16) NOT NULL,
  `mimetype` varchar(15) NOT NULL,
  `imagefile` mediumblob NOT NULL,
  PRIMARY KEY  (`cardnumber`),
  CONSTRAINT `patronimage_fk1` FOREIGN KEY (`cardnumber`) REFERENCES `borrowers` (`cardnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `printers`
--

DROP TABLE IF EXISTS `printers`;
CREATE TABLE `printers` (
  `printername` varchar(40) NOT NULL default '',
  `printqueue` varchar(20) default NULL,
  `printtype` varchar(20) default NULL,
  PRIMARY KEY  (`printername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `printers_profile`
--

DROP TABLE IF EXISTS `printers_profile`;
CREATE TABLE `printers_profile` (
  `prof_id` int(4) NOT NULL auto_increment,
  `printername` varchar(40) NOT NULL,
  `tmpl_id` int(4) NOT NULL,
  `paper_bin` varchar(20) NOT NULL,
  `offset_horz` float default NULL,
  `offset_vert` float default NULL,
  `creep_horz` float default NULL,
  `creep_vert` float default NULL,
  `unit` char(20) NOT NULL default 'POINT',
  PRIMARY KEY  (`prof_id`),
  UNIQUE KEY `printername` (`printername`,`tmpl_id`,`paper_bin`),
  CONSTRAINT `printers_profile_pnfk_1` FOREIGN KEY (`tmpl_id`) REFERENCES `labels_templates` (`tmpl_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `repeatable_holidays`
--

DROP TABLE IF EXISTS `repeatable_holidays`;
CREATE TABLE `repeatable_holidays` (
  `id` int(11) NOT NULL auto_increment,
  `branchcode` varchar(10) NOT NULL default '',
  `weekday` smallint(6) default NULL,
  `day` smallint(6) default NULL,
  `month` smallint(6) default NULL,
  `title` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `reports_dictionary`
-- 

DROP TABLE IF EXISTS `reports_dictionary`;
CREATE TABLE reports_dictionary (
   `id` int(11) NOT NULL auto_increment,
   `name` varchar(255) default NULL,
   `description` text,
   `date_created` datetime default NULL,
   `date_modified` datetime default NULL,
   `saved_sql` text,
   `area` int(11) default NULL,
   PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `reserveconstraints`
--

DROP TABLE IF EXISTS `reserveconstraints`;
CREATE TABLE `reserveconstraints` (
  `borrowernumber` int(11) NOT NULL default 0,
  `reservedate` date default NULL,
  `biblionumber` int(11) NOT NULL default 0,
  `biblioitemnumber` int(11) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `reserves`
--

DROP TABLE IF EXISTS `reserves`;
CREATE TABLE `reserves` (
  `borrowernumber` int(11) NOT NULL default 0,
  `reservedate` date default NULL,
  `biblionumber` int(11) NOT NULL default 0,
  `constrainttype` varchar(1) default NULL,
  `branchcode` varchar(10) default NULL,
  `notificationdate` date default NULL,
  `reminderdate` date default NULL,
  `cancellationdate` date default NULL,
  `reservenotes` mediumtext,
  `priority` smallint(6) default NULL,
  `found` varchar(1) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `itemnumber` int(11) default NULL,
  `waitingdate` date default NULL,
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `reviewid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `biblionumber` int(11) default NULL,
  `review` text,
  `approved` tinyint(4) default NULL,
  `datereviewed` datetime default NULL,
  PRIMARY KEY  (`reviewid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `roadtype`
--

DROP TABLE IF EXISTS `roadtype`;
CREATE TABLE `roadtype` (
  `roadtypeid` int(11) NOT NULL auto_increment,
  `road_type` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`roadtypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `saved_sql`
--

DROP TABLE IF EXISTS `saved_sql`;
CREATE TABLE saved_sql (
   `id` int(11) NOT NULL auto_increment,
   `borrowernumber` int(11) default NULL,
   `date_created` datetime default NULL,
   `last_modified` datetime default NULL,
   `savedsql` text,
   `last_run` datetime default NULL,
   `report_name` varchar(255) default NULL,
   `type` varchar(255) default NULL,
   `notes` text,
   PRIMARY KEY  (`id`),
   KEY boridx (`borrowernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for `saved_reports`
--

DROP TABLE IF EXISTS `saved_reports`;
CREATE TABLE saved_reports (
   `id` int(11) NOT NULL auto_increment,
   `report_id` int(11) default NULL,
   `report` longtext,
   `date_run` datetime default NULL,
   PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
		   
		   
--
-- Table structure for table `serial`
--

DROP TABLE IF EXISTS `serial`;
CREATE TABLE `serial` (
  `serialid` int(11) NOT NULL auto_increment,
  `biblionumber` varchar(100) NOT NULL default '',
  `subscriptionid` varchar(100) NOT NULL default '',
  `serialseq` varchar(100) NOT NULL default '',
  `status` tinyint(4) NOT NULL default 0,
  `planneddate` date default NULL,
  `notes` text,
  `publisheddate` date default NULL,
  `itemnumber` text default NULL,
  `claimdate` date default NULL,
  `routingnotes` text,
  PRIMARY KEY  (`serialid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS sessions;                         
CREATE TABLE sessions (
  `id` varchar(32) NOT NULL,
  `a_session` text NOT NULL,
  UNIQUE KEY id (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `special_holidays`
--

DROP TABLE IF EXISTS `special_holidays`;
CREATE TABLE `special_holidays` (
  `id` int(11) NOT NULL auto_increment,
  `branchcode` varchar(10) NOT NULL default '',
  `day` smallint(6) NOT NULL default 0,
  `month` smallint(6) NOT NULL default 0,
  `year` smallint(6) NOT NULL default 0,
  `isexception` smallint(1) NOT NULL default 1,
  `title` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
CREATE TABLE `statistics` (
  `datetime` datetime default NULL,
  `branch` varchar(10) default NULL,
  `proccode` varchar(4) default NULL,
  `value` double(16,4) default NULL,
  `type` varchar(16) default NULL,
  `other` mediumtext,
  `usercode` varchar(10) default NULL,
  `itemnumber` int(11) default NULL,
  `itemtype` varchar(10) default NULL,
  `borrowernumber` int(11) default NULL,
  `associatedborrower` int(11) default NULL,
  KEY `timeidx` (`datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `stopwords`
--

DROP TABLE IF EXISTS `stopwords`;
  CREATE TABLE `stopwords` (
  `word` varchar(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `subcategorytable`
--

DROP TABLE IF EXISTS `subcategorytable`;
CREATE TABLE `subcategorytable` (
  `subcategorycode` varchar(5) NOT NULL default '',
  `description` text,
  `itemtypecodes` text,
  PRIMARY KEY  (`subcategorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `subscription`
--

DROP TABLE IF EXISTS `subscription`;
CREATE TABLE `subscription` (
  `biblionumber` int(11) NOT NULL default 0,
  `subscriptionid` int(11) NOT NULL auto_increment,
  `librarian` varchar(100) default '',
  `startdate` date default NULL,
  `aqbooksellerid` int(11) default 0,
  `cost` int(11) default 0,
  `aqbudgetid` int(11) default 0,
  `weeklength` int(11) default 0,
  `monthlength` int(11) default 0,
  `numberlength` int(11) default 0,
  `periodicity` tinyint(4) default 0,
  `dow` varchar(100) default '',
  `numberingmethod` varchar(100) default '',
  `notes` mediumtext,
  `status` varchar(100) NOT NULL default '',
  `add1` int(11) default 0,
  `every1` int(11) default 0,
  `whenmorethan1` int(11) default 0,
  `setto1` int(11) default NULL,
  `lastvalue1` int(11) default NULL,
  `add2` int(11) default 0,
  `every2` int(11) default 0,
  `whenmorethan2` int(11) default 0,
  `setto2` int(11) default NULL,
  `lastvalue2` int(11) default NULL,
  `add3` int(11) default 0,
  `every3` int(11) default 0,
  `innerloop1` int(11) default 0,
  `innerloop2` int(11) default 0,
  `innerloop3` int(11) default 0,
  `whenmorethan3` int(11) default 0,
  `setto3` int(11) default NULL,
  `lastvalue3` int(11) default NULL,
  `issuesatonce` tinyint(3) NOT NULL default 1,
  `firstacquidate` date default NULL,
  `manualhistory` tinyint(1) NOT NULL default 0,
  `irregularity` text,
  `letter` varchar(20) default NULL,
  `numberpattern` tinyint(3) default 0,
  `distributedto` text,
  `internalnotes` longtext,
  `callnumber` text,
  `branchcode` varchar(10) NOT NULL default '',
  `hemisphere` tinyint(3) default 0,
  `lastbranch` varchar(10),
  PRIMARY KEY  (`subscriptionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `subscriptionhistory`
--

DROP TABLE IF EXISTS `subscriptionhistory`;
CREATE TABLE `subscriptionhistory` (
  `biblionumber` int(11) NOT NULL default 0,
  `subscriptionid` int(11) NOT NULL default 0,
  `histstartdate` date default NULL,
  `enddate` date default NULL,
  `missinglist` longtext NOT NULL,
  `recievedlist` longtext NOT NULL,
  `opacnote` varchar(150) NOT NULL default '',
  `librariannote` varchar(150) NOT NULL default '',
  PRIMARY KEY  (`subscriptionid`),
  KEY `biblionumber` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `subscriptionroutinglist`
--

DROP TABLE IF EXISTS `subscriptionroutinglist`;
CREATE TABLE `subscriptionroutinglist` (
  `routingid` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `ranking` int(11) default NULL,
  `subscriptionid` int(11) default NULL,
  PRIMARY KEY  (`routingid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `suggestions`
--

DROP TABLE IF EXISTS `suggestions`;
CREATE TABLE `suggestions` (
  `suggestionid` int(8) NOT NULL auto_increment,
  `suggestedby` int(11) NOT NULL default 0,
  `managedby` int(11) default NULL,
  `STATUS` varchar(10) NOT NULL default '',
  `note` mediumtext,
  `author` varchar(80) default NULL,
  `title` varchar(80) default NULL,
  `copyrightdate` smallint(6) default NULL,
  `publishercode` varchar(255) default NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `volumedesc` varchar(255) default NULL,
  `publicationyear` smallint(6) default 0,
  `place` varchar(255) default NULL,
  `isbn` varchar(10) default NULL,
  `mailoverseeing` smallint(1) default 0,
  `biblionumber` int(11) default NULL,
  `reason` text,
  PRIMARY KEY  (`suggestionid`),
  KEY `suggestedby` (`suggestedby`),
  KEY `managedby` (`managedby`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `systempreferences`
--

DROP TABLE IF EXISTS `systempreferences`;
CREATE TABLE `systempreferences` (
  `variable` varchar(50) NOT NULL default '',
  `value` text,
  `options` mediumtext,
  `explanation` text,
  `type` varchar(20) default NULL,
  PRIMARY KEY  (`variable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `entry` varchar(255) NOT NULL default '',
  `weight` bigint(20) NOT NULL default 0,
  PRIMARY KEY  (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `userflags`
--

DROP TABLE IF EXISTS `userflags`;
CREATE TABLE `userflags` (
  `bit` int(11) NOT NULL default 0,
  `flag` varchar(30) default NULL,
  `flagdesc` varchar(255) default NULL,
  `defaulton` int(11) default NULL,
  PRIMARY KEY  (`bit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `virtualshelves`
--

DROP TABLE IF EXISTS `virtualshelves`;
CREATE TABLE `virtualshelves` (
  `shelfnumber` int(11) NOT NULL auto_increment,
  `shelfname` varchar(255) default NULL,
  `owner` varchar(80) default NULL,
  `category` varchar(1) default NULL,
  `sortfield` varchar(16) default NULL,
  PRIMARY KEY  (`shelfnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `virtualshelfcontents`
--

DROP TABLE IF EXISTS `virtualshelfcontents`;
CREATE TABLE `virtualshelfcontents` (
  `shelfnumber` int(11) NOT NULL default 0,
  `biblionumber` int(11) NOT NULL default 0,
  `flags` int(11) default NULL,
  `dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `shelfnumber` (`shelfnumber`),
  KEY `biblionumber` (`biblionumber`),
  CONSTRAINT `virtualshelfcontents_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `virtualshelves` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `shelfcontents_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `z3950servers`
--

DROP TABLE IF EXISTS `z3950servers`;
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
  `encoding` text default NULL,
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `zebraqueue`
--

DROP TABLE IF EXISTS `zebraqueue`;
CREATE TABLE `zebraqueue` (
  `id` int(11) NOT NULL auto_increment,
  `biblio_auth_number` int(11) NOT NULL default '0',
  `operation` char(20) NOT NULL default '',
  `server` char(20) NOT NULL default '',
  `done` int(11) NOT NULL default '0',
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `zebraqueue_lookup` (`server`, `biblio_auth_number`, `operation`, `done`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `services_throttle`;
CREATE TABLE `services_throttle` (
  `service_type` varchar(10) NOT NULL default '',
  `service_count` varchar(45) default NULL,
  PRIMARY KEY  (`service_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- http://www.w3.org/International/articles/language-tags/

-- RFC4646
DROP TABLE IF EXISTS language_subtag_registry;
CREATE TABLE language_subtag_registry (
        subtag varchar(25),
        type varchar(25), -- language-script-region-variant-extension-privateuse
        description varchar(25), -- only one of the possible descriptions for ease of reference, see language_descriptions for the complete list
        added date,
        KEY `subtag` (`subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- TODO: add suppress_scripts
-- this maps three letter codes defined in iso639.2 back to their
-- two letter equivilents in rfc4646 (LOC maintains iso639+)
DROP TABLE IF EXISTS language_rfc4646_to_iso639;
CREATE TABLE language_rfc4646_to_iso639 (
        rfc4646_subtag varchar(25),
        iso639_2_code varchar(25),
        KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS language_descriptions;
CREATE TABLE language_descriptions (
        subtag varchar(25),
        type varchar(25),
        lang varchar(25),
        description varchar(255),
        KEY `lang` (`lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- bi-directional support, keyed by script subcode
DROP TABLE IF EXISTS language_script_bidi;
CREATE TABLE language_script_bidi (
        rfc4646_subtag varchar(25), -- script subtag, Arab, Hebr, etc.
        bidi varchar(3), -- rtl ltr
        KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- TODO: need to map language subtags to script subtags for detection
-- of bidi when script is not specified (like ar, he)
DROP TABLE IF EXISTS language_script_mapping;
CREATE TABLE language_script_mapping (
        language_subtag varchar(25),
        script_subtag varchar(25),
        KEY `language_subtag` (`language_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS serialitems;
CREATE TABLE serialitems (
        serialid int(11) NOT NULL,
        itemnumber int(11) NOT NULL,
        UNIQUE KEY `serialididx` (`serialid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

