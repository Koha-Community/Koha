-- MySQL dump 10.9
--
-- Host: localhost    Database: koha30test
-- ------------------------------------------------------
-- Server version    4.1.22

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_header`
--

DROP TABLE IF EXISTS `auth_header`;
CREATE TABLE `auth_header` (
  `authid` bigint(20) unsigned NOT NULL auto_increment,
  `authtypecode` varchar(10) NOT NULL default '',
  `datecreated` date default NULL,
  `modification_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `origincode` varchar(20) default NULL,
  `authtrees` LONGTEXT,
  `marc` blob,
  `linkid` bigint(20) default NULL,
  `marcxml` LONGTEXT NOT NULL,
  PRIMARY KEY  (`authid`),
  KEY `origincode` (`origincode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `auth_types`
--

DROP TABLE IF EXISTS `auth_types`;
CREATE TABLE `auth_types` (
  `authtypecode` varchar(10) NOT NULL default '',
  `authtypetext` varchar(255) NOT NULL default '',
  `auth_tag_to_report` varchar(3) NOT NULL default '',
  `summary` LONGTEXT NOT NULL,
  PRIMARY KEY  (`authtypecode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `frameworkcode` varchar(10) NOT NULL default '',
  `defaultvalue` MEDIUMTEXT,
  PRIMARY KEY  (`authtypecode`,`tagfield`,`tagsubfield`),
  KEY `tab` (`authtypecode`,`tab`),
  CONSTRAINT `auth_subfield_structure_ibfk_1` FOREIGN KEY (`authtypecode`) REFERENCES `auth_types` (`authtypecode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Table structure for table `authorised_value_categories`
--

DROP TABLE IF EXISTS `authorised_value_categories`;
CREATE TABLE `authorised_value_categories` (
  `category_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `is_system` tinyint(1) default 0,
  PRIMARY KEY (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `authorised_values`
--

DROP TABLE IF EXISTS `authorised_values`;
CREATE TABLE `authorised_values` ( -- stores values for authorized values categories and values
  `id` int(11) NOT NULL auto_increment, -- unique key, used to identify the authorized value
  `category` varchar(32) NOT NULL default '', -- key used to identify the authorized value category
  `authorised_value` varchar(80) NOT NULL default '', -- code use to identify the authorized value
  `lib` varchar(200) default NULL, -- authorized value description as printed in the staff client
  `lib_opac` varchar(200) default NULL, -- authorized value description as printed in the OPAC
  `imageurl` varchar(200) default NULL, -- authorized value URL
  PRIMARY KEY  (`id`),
  KEY `name` (`category`),
  KEY `lib` (`lib` (191)),
  KEY `auth_value_idx` (`authorised_value`),
  CONSTRAINT `av_uniq` UNIQUE (`category`,`authorised_value`),
  CONSTRAINT `authorised_values_authorised_values_category` FOREIGN KEY (`category`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `biblio`
--

DROP TABLE IF EXISTS `biblio`;
CREATE TABLE `biblio` ( -- table that stores bibliographic information
  `biblionumber` int(11) NOT NULL auto_increment, -- unique identifier assigned to each bibliographic record
  `frameworkcode` varchar(4) NOT NULL default '', -- foreign key from the biblio_framework table to identify which framework was used in cataloging this record
  `author` LONGTEXT, -- statement of responsibility from MARC record (100$a in MARC21)
  `title` LONGTEXT, -- title (without the subtitle) from the MARC record (245$a in MARC21)
  `medium` LONGTEXT, -- medium from the MARC record (245$h in MARC21)
  `subtitle` LONGTEXT, -- remainder of the title from the MARC record (245$b in MARC21)
  `part_number` LONGTEXT, -- part number from the MARC record (245$n in MARC21)
  `part_name` LONGTEXT, -- part name from the MARC record (245$p in MARC21)
  `unititle` LONGTEXT, -- uniform title (without the subtitle) from the MARC record (240$a in MARC21)
  `notes` LONGTEXT, -- values from the general notes field in the MARC record (500$a in MARC21) split by bar (|)
  `serial` tinyint(1) default NULL, -- Boolean indicating whether biblio is for a serial
  `seriestitle` LONGTEXT,
  `copyrightdate` smallint(6) default NULL, -- publication or copyright date from the MARC record
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this record was last touched
  `datecreated` DATE NOT NULL, -- the date this record was added to Koha
  `abstract` LONGTEXT, -- summary from the MARC record (520$a in MARC21)
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `biblio_framework`
--

DROP TABLE IF EXISTS `biblio_framework`;
CREATE TABLE `biblio_framework` ( -- information about MARC frameworks
  `frameworkcode` varchar(4) NOT NULL default '', -- the unique code assigned to the framework
  `frameworktext` varchar(255) NOT NULL default '', -- the description/name given to the framework
  PRIMARY KEY  (`frameworkcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `biblioitems`
--

DROP TABLE IF EXISTS `biblioitems`;
CREATE TABLE `biblioitems` ( -- information related to bibliographic records in Koha
  `biblioitemnumber` int(11) NOT NULL auto_increment, -- primary key, unique identifier assigned by Koha
  `biblionumber` int(11) NOT NULL default 0, -- foreign key linking this table to the biblio table
  `volume` LONGTEXT,
  `number` LONGTEXT,
  `itemtype` varchar(10) default NULL, -- biblio level item type (MARC21 942$c)
  `isbn` LONGTEXT, -- ISBN (MARC21 020$a)
  `issn` LONGTEXT, -- ISSN (MARC21 022$a)
  `ean` LONGTEXT default NULL,
  `publicationyear` MEDIUMTEXT,
  `publishercode` varchar(255) default NULL, -- publisher (MARC21 260$b)
  `volumedate` date default NULL,
  `volumedesc` MEDIUMTEXT, -- volume information (MARC21 362$a)
  `collectiontitle` LONGTEXT default NULL,
  `collectionissn` MEDIUMTEXT default NULL,
  `collectionvolume` LONGTEXT default NULL,
  `editionstatement` MEDIUMTEXT default NULL,
  `editionresponsibility` MEDIUMTEXT default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL, -- illustrations (MARC21 300$b)
  `pages` varchar(255) default NULL, -- number of pages (MARC21 300$c)
  `notes` LONGTEXT,
  `size` varchar(255) default NULL, -- material size (MARC21 300$c)
  `place` varchar(255) default NULL, -- publication place (MARC21 260$a)
  `lccn` varchar(25) default NULL, -- library of congress control number (MARC21 010$a)
  `url` MEDIUMTEXT default NULL, -- url (MARC21 856$u)
  `cn_source` varchar(10) default NULL, -- classification source (MARC21 942$2)
  `cn_class` varchar(30) default NULL,
  `cn_item` varchar(10) default NULL,
  `cn_suffix` varchar(10) default NULL,
  `cn_sort` varchar(255) default NULL, -- normalized version of the call number used for sorting
  `agerestriction` varchar(255) default NULL, -- target audience/age restriction from the bib record (MARC21 521$a)
  `totalissues` int(10),
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `itemtype_idx` (`itemtype`),
  KEY `isbn` (`isbn`(255)),
  KEY `issn` (`issn`(255)),
  KEY `ean` (`ean`(255)),
  KEY `publishercode` (`publishercode` (191)),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `biblioitems_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrower_attribute_types`
--

DROP TABLE IF EXISTS `borrower_attribute_types`;
CREATE TABLE `borrower_attribute_types` ( -- definitions for custom patron fields known as extended patron attributes
  `code` varchar(10) NOT NULL, -- unique key used to identify each custom field
  `description` varchar(255) NOT NULL, -- description for each custom field
  `repeatable` tinyint(1) NOT NULL default 0, -- defines whether one patron/borrower can have multiple values for this custom field  (1 for yes, 0 for no)
  `unique_id` tinyint(1) NOT NULL default 0, -- defines if this value needs to be unique (1 for yes, 0 for no)
  `opac_display` tinyint(1) NOT NULL default 0, -- defines if this field is visible to patrons on their account in the OPAC (1 for yes, 0 for no)
  `opac_editable` tinyint(1) NOT NULL default 0, -- defines if this field is editable by patrons on their account in the OPAC (1 for yes, 0 for no)
  `staff_searchable` tinyint(1) NOT NULL default 0, -- defines if this field is searchable via the patron search in the staff client (1 for yes, 0 for no)
  `authorised_value_category` varchar(32) default NULL, -- foreign key from authorised_values that links this custom field to an authorized value category
  `display_checkout` tinyint(1) NOT NULL default 0,-- defines if this field displays in checkout screens
  `category_code` VARCHAR(10) NULL DEFAULT NULL,-- defines a category for an attribute_type
  `class` VARCHAR(255) NOT NULL DEFAULT '',-- defines a class for an attribute_type
  PRIMARY KEY  (`code`),
  KEY `auth_val_cat_idx` (`authorised_value_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrower_password_recovery`
--

DROP TABLE IF EXISTS `borrower_password_recovery`;
CREATE TABLE IF NOT EXISTS `borrower_password_recovery` ( -- holds information about password recovery attempts
  `borrowernumber` int(11) NOT NULL, -- the user asking a password recovery
  `uuid` varchar(128) NOT NULL, -- a unique string to identify a password recovery attempt
  `valid_until` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, -- a time limit on the password recovery attempt
  PRIMARY KEY (`borrowernumber`),
  KEY borrowernumber (borrowernumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
CREATE TABLE `branches` ( -- information about your libraries or branches are stored here
  `branchcode` varchar(10) NOT NULL default '', -- a unique key assigned to each branch
  `branchname` LONGTEXT NOT NULL, -- the name of your library or branch
  `branchaddress1` LONGTEXT, -- the first address line of for your library or branch
  `branchaddress2` LONGTEXT, -- the second address line of for your library or branch
  `branchaddress3` LONGTEXT, -- the third address line of for your library or branch
  `branchzip` varchar(25) default NULL, -- the zip or postal code for your library or branch
  `branchcity` LONGTEXT, -- the city or province for your library or branch
  `branchstate` LONGTEXT, -- the state for your library or branch
  `branchcountry` MEDIUMTEXT, -- the county for your library or branch
  `branchphone` LONGTEXT, -- the primary phone for your library or branch
  `branchfax` LONGTEXT, -- the fax number for your library or branch
  `branchemail` LONGTEXT, -- the primary email address for your library or branch
  `branchillemail` LONGTEXT, -- the ILL staff email address for your library or branch
  `branchreplyto` LONGTEXT, -- the email to be used as a Reply-To
  `branchreturnpath` LONGTEXT, -- the email to be used as Return-Path
  `branchurl` LONGTEXT, -- the URL for your library or branch's website
  `issuing` tinyint(4) default NULL, -- unused in Koha
  `branchip` varchar(15) default NULL, -- the IP address for your library or branch
  `branchnotes` LONGTEXT, -- notes related to your library or branch
  opac_info MEDIUMTEXT, -- HTML that displays in OPAC
  `geolocation` VARCHAR(255) default NULL, -- geolocation of your library
  `marcorgcode` VARCHAR(16) default NULL, -- MARC Organization Code, see http://www.loc.gov/marc/organizations/orgshome.html, when empty defaults to syspref MARCOrgCode
  `pickup_location` tinyint(1) NOT NULL default 1, -- the ability to act as a pickup location
  PRIMARY KEY (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `branches_overdrive`
--

DROP TABLE IF EXISTS `branches_overdrive`;
CREATE TABLE IF NOT EXISTS branches_overdrive (
  `branchcode` VARCHAR( 10 ) NOT NULL ,
  `authname` VARCHAR( 255 ) NOT NULL ,
  PRIMARY KEY (`branchcode`) ,
  CONSTRAINT `branches_overdrive_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` ( -- this table shows information related to Koha patron categories
  `categorycode` varchar(10) NOT NULL default '', -- unique primary key used to idenfity the patron category
  `description` LONGTEXT, -- description of the patron category
  `enrolmentperiod` smallint(6) default NULL, -- number of months the patron is enrolled for (will be NULL if enrolmentperioddate is set)
  `enrolmentperioddate` DATE NULL DEFAULT NULL, -- date the patron is enrolled until (will be NULL if enrolmentperiod is set)
  `upperagelimit` smallint(6) default NULL, -- age limit for the patron
  `dateofbirthrequired` tinyint(1) default NULL, -- the minimum age required for the patron category
  `finetype` varchar(30) default NULL, -- unused in Koha
  `bulk` tinyint(1) default NULL,
  `enrolmentfee` decimal(28,6) default NULL, -- enrollment fee for the patron
  `overduenoticerequired` tinyint(1) default NULL, -- are overdue notices sent to this patron category (1 for yes, 0 for no)
  `issuelimit` smallint(6) default NULL, -- unused in Koha
  `reservefee` decimal(28,6) default NULL, -- cost to place holds
  `hidelostitems` tinyint(1) NOT NULL default '0', -- are lost items shown to this category (1 for yes, 0 for no)
  `category_type` varchar(1) NOT NULL default 'A', -- type of Koha patron (Adult, Child, Professional, Organizational, Statistical, Staff)
  `BlockExpiredPatronOpacActions` tinyint(1) NOT NULL default '-1', -- wheither or not a patron of this category can renew books or place holds once their card has expired. 0 means they can, 1 means they cannot, -1 means use syspref BlockExpiredPatronOpacActions
  `default_privacy` ENUM( 'default', 'never', 'forever' ) NOT NULL DEFAULT 'default', -- Default privacy setting for this patron category
  `checkprevcheckout` varchar(7) NOT NULL default 'inherit', -- produce a warning for this patron category if this item has previously been checked out to this patron if 'yes', not if 'no', defer to syspref setting if 'inherit'.
  `reset_password` TINYINT(1) NULL DEFAULT NULL, -- if patrons of this category can do the password reset flow,
  `change_password` TINYINT(1) NULL DEFAULT NULL, -- if patrons of this category can change their passwords in the OAPC
  PRIMARY KEY  (`categorycode`),
  UNIQUE KEY `categorycode` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table: collections
--
DROP TABLE IF EXISTS collections;
CREATE TABLE collections (
  colId integer(11) NOT NULL auto_increment,
  colTitle varchar(100) NOT NULL DEFAULT '',
  colDesc MEDIUMTEXT NOT NULL,
  colBranchcode varchar(10) DEFAULT NULL, -- 'branchcode for branch where item should be held.'
  PRIMARY KEY (colId)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Constraints for table `collections`
--
ALTER TABLE `collections`
  ADD CONSTRAINT `collections_ibfk_1` FOREIGN KEY (`colBranchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table: collections_tracking
--

DROP TABLE IF EXISTS collections_tracking;
CREATE TABLE collections_tracking (
  collections_tracking_id integer(11) NOT NULL auto_increment,
  colId integer(11) NOT NULL DEFAULT 0 comment 'collections.colId',
  itemnumber integer(11) NOT NULL DEFAULT 0 comment 'items.itemnumber',
  PRIMARY KEY (collections_tracking_id)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
CREATE TABLE `cities` ( -- authorized values for cities/states/countries to choose when adding/editing a patron/borrower
  `cityid` int(11) NOT NULL auto_increment, -- unique identifier added by Koha
  `city_name` varchar(100) NOT NULL default '', -- name of the city
  `city_state` VARCHAR( 100 ) NULL DEFAULT NULL, -- name of the state/province
  `city_country` VARCHAR( 100 ) NULL DEFAULT NULL, -- name of the country
  `city_zipcode` varchar(20) default NULL, -- zip or postal code
  PRIMARY KEY  (`cityid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table desks
--

DROP TABLE IF EXISTS desks;
CREATE TABLE desks ( -- desks available in a library
  desk_id int(11) NOT NULL auto_increment, -- unique identifier
  desk_name varchar(100) NOT NULL default '', -- name of the desk
  branchcode varchar(10) NOT NULL,       -- library the desk is located at
  PRIMARY KEY  (desk_id),
  KEY `fk_desks_branchcode` (branchcode),
  CONSTRAINT `fk_desks_branchcode` FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `class_sort_rules`
--

DROP TABLE IF EXISTS `class_sort_rules`;
CREATE TABLE `class_sort_rules` (
  `class_sort_rule` varchar(10) NOT NULL default '',
  `description` LONGTEXT,
  `sort_routine` varchar(30) NOT NULL default '',
  PRIMARY KEY (`class_sort_rule`),
  UNIQUE KEY `class_sort_rule_idx` (`class_sort_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `class_split_rules`
--

DROP TABLE IF EXISTS `class_split_rules`;

CREATE TABLE class_split_rules (
  class_split_rule varchar(10) NOT NULL default '',
  description LONGTEXT,
  split_routine varchar(30) NOT NULL default '',
  split_regex varchar(255) NOT NULL default '',
  PRIMARY KEY (class_split_rule),
  UNIQUE KEY class_split_rule_idx (class_split_rule)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `class_sources`
--

DROP TABLE IF EXISTS `class_sources`;
CREATE TABLE `class_sources` (
  `cn_source` varchar(10) NOT NULL default '',
  `description` LONGTEXT,
  `used` tinyint(4) NOT NULL default 0,
  `class_sort_rule` varchar(10) NOT NULL default '',
  `class_split_rule` varchar(10) NOT NULL default '',
  PRIMARY KEY (`cn_source`),
  UNIQUE KEY `cn_source_idx` (`cn_source`),
  KEY `used_idx` (`used`),
  CONSTRAINT `class_source_ibfk_1` FOREIGN KEY (`class_sort_rule`) REFERENCES `class_sort_rules` (`class_sort_rule`),
  CONSTRAINT `class_source_ibfk_2` FOREIGN KEY (`class_split_rule`) REFERENCES `class_split_rules` (`class_split_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `currency`
--

DROP TABLE IF EXISTS `currency`;
CREATE TABLE `currency` (
  `currency` varchar(10) NOT NULL default '',
  `symbol` varchar(5) default NULL,
  `isocode` varchar(5) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `rate` float(15,5) default NULL,
  `active` tinyint(1) default NULL,
  `archived` tinyint(1) DEFAULT 0,
  `p_sep_by_space` tinyint(1) DEFAULT 0,
  PRIMARY KEY  (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `deletedbiblio`
--

DROP TABLE IF EXISTS `deletedbiblio`;
CREATE TABLE `deletedbiblio` ( -- stores information about bibliographic records that have been deleted
  `biblionumber` int(11) NOT NULL auto_increment, -- unique identifier assigned to each bibliographic record
  `frameworkcode` varchar(4) NOT NULL default '', -- foriegn key from the biblio_framework table to identify which framework was used in cataloging this record
  `author` LONGTEXT, -- statement of responsibility from MARC record (100$a in MARC21)
  `title` LONGTEXT, -- title (without the subtitle) from the MARC record (245$a in MARC21)
  `medium` LONGTEXT, -- medium from the MARC record (245$h in MARC21)
  `subtitle` LONGTEXT, -- remainder of the title from the MARC record (245$b in MARC21)
  `part_number` LONGTEXT, -- part number from the MARC record (245$n in MARC21)
  `part_name` LONGTEXT, -- part name from the MARC record (245$p in MARC21)
  `unititle` LONGTEXT, -- uniform title (without the subtitle) from the MARC record (240$a in MARC21)
  `notes` LONGTEXT, -- values from the general notes field in the MARC record (500$a in MARC21) split by bar (|)
  `serial` tinyint(1) default NULL, -- Boolean indicating whether biblio is for a serial
  `seriestitle` LONGTEXT,
  `copyrightdate` smallint(6) default NULL, -- publication or copyright date from the MARC record
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this record was last touched
  `datecreated` DATE NOT NULL, -- the date this record was added to Koha
  `abstract` LONGTEXT, -- summary from the MARC record (520$a in MARC21)
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `deletedbiblioitems`
--

DROP TABLE IF EXISTS `deletedbiblioitems`;
CREATE TABLE `deletedbiblioitems` ( -- information about bibliographic records that have been deleted
  `biblioitemnumber` int(11) NOT NULL default 0, -- primary key, unique identifier assigned by Koha
  `biblionumber` int(11) NOT NULL default 0, -- foreign key linking this table to the biblio table
  `volume` LONGTEXT,
  `number` LONGTEXT,
  `itemtype` varchar(10) default NULL, -- biblio level item type (MARC21 942$c)
  `isbn` LONGTEXT default NULL, -- ISBN (MARC21 020$a)
  `issn` LONGTEXT default NULL, -- ISSN (MARC21 022$a)
  `ean` LONGTEXT default NULL,
  `publicationyear` MEDIUMTEXT,
  `publishercode` varchar(255) default NULL, -- publisher (MARC21 260$b)
  `volumedate` date default NULL,
  `volumedesc` MEDIUMTEXT, -- volume information (MARC21 362$a)
  `collectiontitle` LONGTEXT default NULL,
  `collectionissn` MEDIUMTEXT default NULL,
  `collectionvolume` LONGTEXT default NULL,
  `editionstatement` MEDIUMTEXT default NULL,
  `editionresponsibility` MEDIUMTEXT default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL, -- illustrations (MARC21 300$b)
  `pages` varchar(255) default NULL, -- number of pages (MARC21 300$c)
  `notes` LONGTEXT,
  `size` varchar(255) default NULL, -- material size (MARC21 300$c)
  `place` varchar(255) default NULL, -- publication place (MARC21 260$a)
  `lccn` varchar(25) default NULL, -- library of congress control number (MARC21 010$a)
  `url` MEDIUMTEXT default NULL, -- url (MARC21 856$u)
  `cn_source` varchar(10) default NULL, -- classification source (MARC21 942$2)
  `cn_class` varchar(30) default NULL,
  `cn_item` varchar(10) default NULL,
  `cn_suffix` varchar(10) default NULL,
  `cn_sort` varchar(255) default NULL, -- normalized version of the call number used for sorting
  `agerestriction` varchar(255) default NULL, -- target audience/age restriction from the bib record (MARC21 521$a)
  `totalissues` int(10),
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `itemtype_idx` (`itemtype`),
  KEY `isbn` (`isbn`(255)),
  KEY `ean` (`ean`(255)),
  KEY `publishercode` (`publishercode` (191)),
  KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `deletedborrowers`
--

DROP TABLE IF EXISTS `deletedborrowers`;
CREATE TABLE `deletedborrowers` ( -- stores data related to the patrons/borrowers you have deleted
  `borrowernumber` int(11) NOT NULL default 0, -- primary key, Koha assigned ID number for patrons/borrowers
  `cardnumber` varchar(32) default NULL, -- unique key, library assigned ID number for patrons/borrowers
  `surname` LONGTEXT, -- patron/borrower's last name (surname)
  `firstname` MEDIUMTEXT, -- patron/borrower's first name
  `title` LONGTEXT, -- patron/borrower's title, for example: Mr. or Mrs.
  `othernames` LONGTEXT, -- any other names associated with the patron/borrower
  `initials` MEDIUMTEXT, -- initials for your patron/borrower
  `streetnumber` TINYTEXT default NULL, -- the house number for your patron/borrower's primary address
  `streettype` TINYTEXT default NULL, -- the street type (Rd., Blvd, etc) for your patron/borrower's primary address
  `address` LONGTEXT, -- the first address line for your patron/borrower's primary address
  `address2` MEDIUMTEXT, -- the second address line for your patron/borrower's primary address
  `city` LONGTEXT, -- the city or town for your patron/borrower's primary address
  `state` MEDIUMTEXT default NULL, -- the state or province for your patron/borrower's primary address
  `zipcode` TINYTEXT default NULL, -- the zip or postal code for your patron/borrower's primary address
  `country` MEDIUMTEXT, -- the country for your patron/borrower's primary address
  `email` LONGTEXT, -- the primary email address for your patron/borrower's primary address
  `phone` MEDIUMTEXT, -- the primary phone number for your patron/borrower's primary address
  `mobile` TINYTEXT default NULL, -- the other phone number for your patron/borrower's primary address
  `fax` LONGTEXT, -- the fax number for your patron/borrower's primary address
  `emailpro` MEDIUMTEXT, -- the secondary email addres for your patron/borrower's primary address
  `phonepro` MEDIUMTEXT, -- the secondary phone number for your patron/borrower's primary address
  `B_streetnumber` TINYTEXT default NULL, -- the house number for your patron/borrower's alternate address
  `B_streettype` TINYTEXT default NULL, -- the street type (Rd., Blvd, etc) for your patron/borrower's alternate address
  `B_address` MEDIUMTEXT default NULL, -- the first address line for your patron/borrower's alternate address
  `B_address2` MEDIUMTEXT default NULL, -- the second address line for your patron/borrower's alternate address
  `B_city` LONGTEXT, -- the city or town for your patron/borrower's alternate address
  `B_state` MEDIUMTEXT default NULL, -- the state for your patron/borrower's alternate address
  `B_zipcode` TINYTEXT default NULL, -- the zip or postal code for your patron/borrower's alternate address
  `B_country` MEDIUMTEXT, -- the country for your patron/borrower's alternate address
  `B_email` MEDIUMTEXT, -- the patron/borrower's alternate email address
  `B_phone` LONGTEXT, -- the patron/borrower's alternate phone number
  `dateofbirth` date default NULL, -- the patron/borrower's date of birth (YYYY-MM-DD)
  `branchcode` varchar(10) NOT NULL default '', -- foreign key from the branches table, includes the code of the patron/borrower's home branch
  `categorycode` varchar(10) NOT NULL default '', -- foreign key from the categories table, includes the code of the patron category
  `dateenrolled` date default NULL, -- date the patron was added to Koha (YYYY-MM-DD)
  `dateexpiry` date default NULL, -- date the patron/borrower's card is set to expire (YYYY-MM-DD)
  `date_renewed` date default NULL, -- date the patron/borrower's card was last renewed
  `gonenoaddress` tinyint(1) default NULL, -- set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having an unconfirmed address
  `lost` tinyint(1) default NULL, -- set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having lost their card
  `debarred` date default NULL, -- until this date the patron can only check-in (no loans, no holds, etc.), is a fine based on days instead of money (YYYY-MM-DD)
  `debarredcomment` VARCHAR(255) DEFAULT NULL, -- comment on the stop of patron
  `contactname` LONGTEXT, -- used for children and profesionals to include surname or last name of guarantor or organization name
  `contactfirstname` MEDIUMTEXT, -- used for children to include first name of guarantor
  `contacttitle` MEDIUMTEXT, -- used for children to include title (Mr., Mrs., etc) of guarantor
  `borrowernotes` LONGTEXT, -- a note on the patron/borrower's account that is only visible in the staff client
  `relationship` varchar(100) default NULL, -- used for children to include the relationship to their guarantor
  `sex` varchar(1) default NULL, -- patron/borrower's gender
  `password` varchar(60) default NULL, -- patron/borrower's encrypted password
  `flags` int(11) default NULL, -- will include a number associated with the staff member's permissions
  `userid` varchar(75) default NULL, -- patron/borrower's opac and/or staff client log in
  `opacnote` LONGTEXT, -- a note on the patron/borrower's account that is visible in the OPAC and staff client
  `contactnote` varchar(255) default NULL, -- a note related to the patron/borrower's alternate address
  `sort1` varchar(80) default NULL, -- a field that can be used for any information unique to the library
  `sort2` varchar(80) default NULL, -- a field that can be used for any information unique to the library
  `altcontactfirstname` MEDIUMTEXT default NULL, -- first name of alternate contact for the patron/borrower
  `altcontactsurname` MEDIUMTEXT default NULL, -- surname or last name of the alternate contact for the patron/borrower
  `altcontactaddress1` MEDIUMTEXT default NULL, -- the first address line for the alternate contact for the patron/borrower
  `altcontactaddress2` MEDIUMTEXT default NULL, -- the second address line for the alternate contact for the patron/borrower
  `altcontactaddress3` MEDIUMTEXT default NULL, -- the city for the alternate contact for the patron/borrower
  `altcontactstate` MEDIUMTEXT default NULL, -- the state for the alternate contact for the patron/borrower
  `altcontactzipcode` MEDIUMTEXT default NULL, -- the zipcode for the alternate contact for the patron/borrower
  `altcontactcountry` MEDIUMTEXT default NULL, -- the country for the alternate contact for the patron/borrower
  `altcontactphone` MEDIUMTEXT default NULL, -- the phone number for the alternate contact for the patron/borrower
  `smsalertnumber` varchar(50) default NULL, -- the mobile phone number where the patron/borrower would like to receive notices (if SMS turned on)
  `sms_provider_id` int(11) DEFAULT NULL, -- the provider of the mobile phone number defined in smsalertnumber
  `privacy` integer(11) DEFAULT '1' NOT NULL, -- patron/borrower's privacy settings related to their reading history  KEY `borrowernumber` (`borrowernumber`),
  `privacy_guarantor_fines` tinyint(1) NOT NULL DEFAULT '0', -- controls if relatives can see this patron's fines
  `privacy_guarantor_checkouts` tinyint(1) NOT NULL DEFAULT '0', -- controls if relatives can see this patron's checkouts
  `checkprevcheckout` varchar(7) NOT NULL default 'inherit', -- produce a warning for this patron if this item has previously been checked out to this patron if 'yes', not if 'no', defer to category setting if 'inherit'.
  `updated_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- time of last change could be useful for synchronization with external systems (among others)
  `lastseen` datetime default NULL, -- last time a patron has been seen (connected at the OPAC or staff interface)
  `lang` varchar(25) NOT NULL default 'default', -- lang to use to send notices to this patron
  `login_attempts` int(4) default 0, -- number of failed login attemps
  `overdrive_auth_token` MEDIUMTEXT default NULL, -- persist OverDrive auth token
  `anonymized` TINYINT(1) NOT NULL DEFAULT 0, -- flag for data anonymization
  `autorenew_checkouts` TINYINT(1) NOT NULL DEFAULT 1, -- flag for allowing auto-renewal
  KEY borrowernumber (borrowernumber),
  KEY `cardnumber` (`cardnumber`),
  KEY `sms_provider_id` (`sms_provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `deleteditems`
--

DROP TABLE IF EXISTS `deleteditems`;
CREATE TABLE `deleteditems` (
  `itemnumber` int(11) NOT NULL default 0, -- primary key and unique identifier added by Koha
  `biblionumber` int(11) NOT NULL default 0, -- foreign key from biblio table used to link this item to the right bib record
  `biblioitemnumber` int(11) NOT NULL default 0, -- foreign key from the biblioitems table to link to item to additional information
  `barcode` varchar(20) default NULL, -- item barcode (MARC21 952$p)
  `dateaccessioned` date default NULL, -- date the item was acquired or added to Koha (MARC21 952$d)
  `booksellerid` LONGTEXT default NULL, -- where the item was purchased (MARC21 952$e)
  `homebranch` varchar(10) default NULL, -- foreign key from the branches table for the library that owns this item (MARC21 952$a)
  `price` decimal(8,2) default NULL, -- purchase price (MARC21 952$g)
  `replacementprice` decimal(8,2) default NULL, -- cost the library charges to replace the item if it has been marked lost (MARC21 952$v)
  `replacementpricedate` date default NULL, -- the date the price is effective from (MARC21 952$w)
  `datelastborrowed` date default NULL, -- the date the item was last checked out
  `datelastseen` date default NULL, -- the date the item was last see (usually the last time the barcode was scanned or inventory was done)
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) NOT NULL default 0, -- authorized value defining why this item is not for loan (MARC21 952$7)
  `damaged` tinyint(1) NOT NULL default 0, -- authorized value defining this item as damaged (MARC21 952$4)
  `damaged_on` datetime DEFAULT NULL, -- the date and time an item was last marked as damaged, NULL if not damaged
  `itemlost` tinyint(1) NOT NULL default 0, -- authorized value defining this item as lost (MARC21 952$1)
  `itemlost_on` datetime DEFAULT NULL, -- the date and time an item was last marked as lost, NULL if not lost
  `withdrawn` tinyint(1) NOT NULL default 0, -- authorized value defining this item as withdrawn (MARC21 952$0)
  `withdrawn_on` datetime DEFAULT NULL, -- the date and time an item was last marked as withdrawn, NULL if not withdrawn
  `itemcallnumber` varchar(255) default NULL, -- call number for this item (MARC21 952$o)
  `coded_location_qualifier` varchar(10) default NULL, -- coded location qualifier(MARC21 952$f)
  `issues` smallint(6) default 0, -- number of times this item has been checked out
  `renewals` smallint(6) default NULL, -- number of times this item has been renewed
  `reserves` smallint(6) default NULL, -- number of times this item has been placed on hold/reserved
  `restricted` tinyint(1) default NULL, -- authorized value defining use restrictions for this item (MARC21 952$5)
  `itemnotes` LONGTEXT, -- public notes on this item (MARC21 952$z)
  `itemnotes_nonpublic` LONGTEXT default NULL, -- non-public notes on this item (MARC21 952$x)
  `holdingbranch` varchar(10) default NULL, -- foreign key from the branches table for the library that is currently in possession item (MARC21 952$b)
  `paidfor` LONGTEXT,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this item was last altered
  `location` varchar(80) default NULL, -- authorized value for the shelving location for this item (MARC21 952$c)
  `permanent_location` varchar(80) default NULL, -- linked to the CART and PROC temporary locations feature, stores the permanent shelving location
  `onloan` date default NULL, -- defines if item is checked out (NULL for not checked out, and due date for checked out)
  `cn_source` varchar(10) default NULL, -- classification source used on this item (MARC21 952$2)
  `cn_sort` varchar(255) default NULL, -- normalized form of the call number (MARC21 952$o) used for sorting
  `ccode` varchar(80) default NULL, -- authorized value for the collection code associated with this item (MARC21 952$8)
  `materials` MEDIUMTEXT default NULL, -- materials specified (MARC21 952$3)
  `uri` MEDIUMTEXT default NULL, -- URL for the item (MARC21 952$u)
  `itype` varchar(10) default NULL, -- foreign key from the itemtypes table defining the type for this item (MARC21 952$y)
  `more_subfields_xml` LONGTEXT default NULL, -- additional 952 subfields in XML format
  `enumchron` MEDIUMTEXT default NULL, -- serial enumeration/chronology for the item (MARC21 952$h)
  `copynumber` varchar(32) default NULL, -- copy number (MARC21 952$t)
  `stocknumber` varchar(32) default NULL, -- inventory number (MARC21 952$i)
  `new_status` VARCHAR(32) DEFAULT NULL, -- 'new' value, you can put whatever free-text information. This field is intented to be managed by the automatic_item_modification_by_age cronjob.
  PRIMARY KEY  (`itemnumber`),
  KEY `delitembarcodeidx` (`barcode`),
  KEY `delitemstocknumberidx` (`stocknumber`),
  KEY `delitembinoidx` (`biblioitemnumber`),
  KEY `delitembibnoidx` (`biblionumber`),
  KEY `delhomebranch` (`homebranch`),
  KEY `delholdingbranch` (`holdingbranch`),
  KEY `itype_idx` (`itype`),
  KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `export_format`
--

DROP TABLE IF EXISTS `export_format`;
CREATE TABLE `export_format` (
  `export_format_id` int(11) NOT NULL auto_increment,
  `profile` varchar(255) NOT NULL,
  `description` LONGTEXT NOT NULL,
  `content` LONGTEXT NOT NULL,
  `csv_separator` varchar(2) NOT NULL DEFAULT ',',
  `field_separator` varchar(2),
  `subfield_separator` varchar(2),
  `encoding` varchar(255) NOT NULL DEFAULT 'utf8',
  `type` varchar(255) DEFAULT 'marc',
  `used_for` varchar(255) DEFAULT 'export_records',
  PRIMARY KEY  (`export_format_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Used for CSV export';

--
-- Table structure for table `import_batches`
--

DROP TABLE IF EXISTS `import_batches`;
CREATE TABLE `import_batches` ( -- information about batches of marc records that have been imported
  `import_batch_id` int(11) NOT NULL auto_increment, -- unique identifier and primary key
  `matcher_id` int(11) default NULL, -- the id of the match rule used (matchpoints.matcher_id)
  `template_id` int(11) default NULL,
  `branchcode` varchar(10) default NULL,
  `num_records` int(11) NOT NULL default 0, -- number of records in the file
  `num_items` int(11) NOT NULL default 0, -- number of items in the file
  `upload_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP, -- date and time the file was uploaded
  `overlay_action` enum('replace', 'create_new', 'use_template', 'ignore') NOT NULL default 'create_new', -- how to handle duplicate records
  `nomatch_action` enum('create_new', 'ignore') NOT NULL default 'create_new', -- how to handle records where no match is found
  `item_action` enum('always_add', 'add_only_for_matches', 'add_only_for_new', 'ignore', 'replace') NOT NULL default 'always_add', -- what to do with item records
  `import_status` enum('staging', 'staged', 'importing', 'imported', 'reverting', 'reverted', 'cleaned') NOT NULL default 'staging', -- the status of the imported file
  `batch_type` enum('batch', 'z3950', 'webservice') NOT NULL default 'batch', -- where this batch has come from
  `record_type` enum('biblio', 'auth', 'holdings') NOT NULL default 'biblio', -- type of record in the batch
  `file_name` varchar(100), -- the name of the file uploaded
  `comments` LONGTEXT, -- any comments added when the file was uploaded
  PRIMARY KEY (`import_batch_id`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `marcxml` LONGTEXT NOT NULL,
  `marcxml_old` LONGTEXT NOT NULL,
  `record_type` enum('biblio', 'auth', 'holdings') NOT NULL default 'biblio',
  `overlay_status` enum('no_match', 'auto_match', 'manual_match', 'match_applied') NOT NULL default 'no_match',
  `status` enum('error', 'staged', 'imported', 'reverted', 'items_reverted', 'ignored') NOT NULL default 'staged',
  `import_error` LONGTEXT,
  `encoding` varchar(40) NOT NULL default '',
  PRIMARY KEY (`import_record_id`),
  CONSTRAINT `import_records_ifbk_1` FOREIGN KEY (`import_batch_id`)
             REFERENCES `import_batches` (`import_batch_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `branchcode` (`branchcode`),
  KEY `batch_sequence` (`import_batch_id`, `record_sequence`),
  KEY `batch_id_record_type` (`import_batch_id`,`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for `import_record_matches`
--
DROP TABLE IF EXISTS `import_record_matches`;
CREATE TABLE `import_record_matches` ( -- matches found when importing a batch of records
  `import_record_id` int(11) NOT NULL, -- the id given to the imported bib record (import_records.import_record_id)
  `candidate_match_id` int(11) NOT NULL, -- the biblio the imported record matches (biblio.biblionumber)
  `score` int(11) NOT NULL default 0, -- the match score
  CONSTRAINT `import_record_matches_ibfk_1` FOREIGN KEY (`import_record_id`)
             REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `record_score` (`import_record_id`, `score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `import_auths`
--

DROP TABLE IF EXISTS `import_auths`;
CREATE TABLE `import_auths` (
  `import_record_id` int(11) NOT NULL,
  `matched_authid` int(11) default NULL,
  `control_number` varchar(25) default NULL,
  `authorized_heading` varchar(128) default NULL,
  `original_source` varchar(25) default NULL,
  CONSTRAINT `import_auths_ibfk_1` FOREIGN KEY (`import_record_id`)
             REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `matched_authid` (`matched_authid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `isbn` varchar(30) default NULL,
  `issn` varchar(9) default NULL,
  `has_items` tinyint(1) NOT NULL default 0,
  CONSTRAINT `import_biblios_ibfk_1` FOREIGN KEY (`import_record_id`)
             REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `matched_biblionumber` (`matched_biblionumber`),
  KEY `title` (`title`),
  KEY `isbn` (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `import_items`
--

DROP TABLE IF EXISTS `import_items`;
CREATE TABLE `import_items` (
  `import_items_id` int(11) NOT NULL auto_increment,
  `import_record_id` int(11) NOT NULL,
  `itemnumber` int(11) default NULL,
  `branchcode` varchar(10) default NULL,
  `status` enum('error', 'staged', 'imported', 'reverted', 'ignored') NOT NULL default 'staged',
  `marcxml` LONGTEXT NOT NULL,
  `import_error` LONGTEXT,
  PRIMARY KEY (`import_items_id`),
  CONSTRAINT `import_items_ibfk_1` FOREIGN KEY (`import_record_id`)
             REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
CREATE TABLE `items` ( -- holdings/item information
  `itemnumber` int(11) NOT NULL auto_increment, -- primary key and unique identifier added by Koha
  `biblionumber` int(11) NOT NULL default 0, -- foreign key from biblio table used to link this item to the right bib record
  `biblioitemnumber` int(11) NOT NULL default 0, -- foreign key from the biblioitems table to link to item to additional information
  `barcode` varchar(20) default NULL, -- item barcode (MARC21 952$p)
  `dateaccessioned` date default NULL, -- date the item was acquired or added to Koha (MARC21 952$d)
  `booksellerid` LONGTEXT default NULL, -- where the item was purchased (MARC21 952$e)
  `homebranch` varchar(10) default NULL, -- foreign key from the branches table for the library that owns this item (MARC21 952$a)
  `price` decimal(8,2) default NULL, -- purchase price (MARC21 952$g)
  `replacementprice` decimal(8,2) default NULL, -- cost the library charges to replace the item if it has been marked lost (MARC21 952$v)
  `replacementpricedate` date default NULL, -- the date the price is effective from (MARC21 952$w)
  `datelastborrowed` date default NULL, -- the date the item was last checked out/issued
  `datelastseen` date default NULL, -- the date the item was last see (usually the last time the barcode was scanned or inventory was done)
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) NOT NULL default 0, -- authorized value defining why this item is not for loan (MARC21 952$7)
  `damaged` tinyint(1) NOT NULL default 0, -- authorized value defining this item as damaged (MARC21 952$4)
  `damaged_on` datetime DEFAULT NULL, -- the date and time an item was last marked as damaged, NULL if not damaged
  `itemlost` tinyint(1) NOT NULL default 0, -- authorized value defining this item as lost (MARC21 952$1)
  `itemlost_on` datetime DEFAULT NULL, -- the date and time an item was last marked as lost, NULL if not lost
  `withdrawn` tinyint(1) NOT NULL default 0, -- authorized value defining this item as withdrawn (MARC21 952$0)
  `withdrawn_on` datetime DEFAULT NULL, -- the date and time an item was last marked as withdrawn, NULL if not withdrawn
  `itemcallnumber` varchar(255) default NULL, -- call number for this item (MARC21 952$o)
  `coded_location_qualifier` varchar(10) default NULL, -- coded location qualifier(MARC21 952$f)
  `issues` smallint(6) default 0, -- number of times this item has been checked out/issued
  `renewals` smallint(6) default NULL, -- number of times this item has been renewed
  `reserves` smallint(6) default NULL, -- number of times this item has been placed on hold/reserved
  `restricted` tinyint(1) default NULL, -- authorized value defining use restrictions for this item (MARC21 952$5)
  `itemnotes` LONGTEXT, -- public notes on this item (MARC21 952$z)
  `itemnotes_nonpublic` LONGTEXT default NULL, -- non-public notes on this item (MARC21 952$x)
  `holdingbranch` varchar(10) default NULL, -- foreign key from the branches table for the library that is currently in possession item (MARC21 952$b)
  `paidfor` LONGTEXT,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this item was last altered
  `location` varchar(80) default NULL, -- authorized value for the shelving location for this item (MARC21 952$c)
  `permanent_location` varchar(80) default NULL, -- linked to the CART and PROC temporary locations feature, stores the permanent shelving location
  `onloan` date default NULL, -- defines if item is checked out (NULL for not checked out, and due date for checked out)
  `cn_source` varchar(10) default NULL, -- classification source used on this item (MARC21 952$2)
  `cn_sort` varchar(255) default NULL,  -- normalized form of the call number (MARC21 952$o) used for sorting
  `ccode` varchar(80) default NULL, -- authorized value for the collection code associated with this item (MARC21 952$8)
  `materials` MEDIUMTEXT default NULL, -- materials specified (MARC21 952$3)
  `uri` MEDIUMTEXT default NULL, -- URL for the item (MARC21 952$u)
  `itype` varchar(10) default NULL, -- foreign key from the itemtypes table defining the type for this item (MARC21 952$y)
  `more_subfields_xml` LONGTEXT default NULL, -- additional 952 subfields in XML format
  `enumchron` MEDIUMTEXT default NULL, -- serial enumeration/chronology for the item (MARC21 952$h)
  `copynumber` varchar(32) default NULL, -- copy number (MARC21 952$t)
  `stocknumber` varchar(32) default NULL, -- inventory number (MARC21 952$i)
  `new_status` VARCHAR(32) DEFAULT NULL, -- 'new' value, you can put whatever free-text information. This field is intented to be managed by the automatic_item_modification_by_age cronjob.
  PRIMARY KEY  (`itemnumber`),
  UNIQUE KEY `itembarcodeidx` (`barcode`),
  KEY `itemstocknumberidx` (`stocknumber`),
  KEY `itembinoidx` (`biblioitemnumber`),
  KEY `itembibnoidx` (`biblionumber`),
  KEY `homebranch` (`homebranch`),
  KEY `holdingbranch` (`holdingbranch`),
  KEY `itemcallnumber` (`itemcallnumber` (191)),
  KEY `items_location` (`location`),
  KEY `items_ccode` (`ccode`),
  KEY `itype_idx` (`itype`),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblioitemnumber`) REFERENCES `biblioitems` (`biblioitemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_4` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `itemtypes`
--

DROP TABLE IF EXISTS `itemtypes`;
CREATE TABLE `itemtypes` ( -- defines the item types
  itemtype varchar(10) NOT NULL default '', -- unique key, a code associated with the item type
  description LONGTEXT, -- a plain text explanation of the item type
  rentalcharge decimal(28,6) default NULL, -- the amount charged when this item is checked out/issued
  rentalcharge_daily decimal(28,6) default NULL, -- the amount charged for each day between checkout date and due date
  rentalcharge_daily_calendar tinyint(1) NOT NULL DEFAULT 1, -- controls if the daily retnal fee is calculated directly or using finesCalendar
  rentalcharge_hourly decimal(28,6) default NULL, -- the amount charged for each hour between checkout date and due date
  rentalcharge_hourly_calendar tinyint(1) NOT NULL DEFAULT 1, -- controls if the hourly retnal fee is calculated directly or using finesCalendar
  defaultreplacecost decimal(28,6) default NULL, -- default replacement cost
  processfee decimal(28,6) default NULL, -- default text be recorded in the column note when the processing fee is applied
  notforloan smallint(6) default NULL, -- 1 if the item is not for loan, 0 if the item is available for loan
  imageurl varchar(200) default NULL, -- URL for the item type icon
  summary MEDIUMTEXT, -- information from the summary field, may include HTML
  checkinmsg VARCHAR(255), -- message that is displayed when an item with the given item type is checked in
  checkinmsgtype CHAR(16) DEFAULT 'message' NOT NULL, -- type (CSS class) for the checkinmsg, can be "alert" or "message"
  sip_media_type VARCHAR(3) DEFAULT NULL, -- SIP2 protocol media type for this itemtype
  hideinopac tinyint(1) NOT NULL DEFAULT 0, -- Hide the item type from the search options in OPAC
  searchcategory varchar(80) default NULL, -- Group this item type with others with the same value on OPAC search options
  PRIMARY KEY  (`itemtype`),
  UNIQUE KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `branchtransfers`
--

DROP TABLE IF EXISTS `branchtransfers`;
CREATE TABLE `branchtransfers` ( -- information for items that are in transit between branches
  `branchtransfer_id` int(12) NOT NULL auto_increment, -- primary key
  `itemnumber` int(11) NOT NULL default 0, -- the itemnumber that it is in transit (items.itemnumber)
  `datesent` datetime default NULL, -- the date the transfer was initialized
  `frombranch` varchar(10) NOT NULL default '', -- the branch the transfer is coming from
  `datearrived` datetime default NULL, -- the date the transfer arrived at its destination
  `tobranch` varchar(10) NOT NULL default '', -- the branch the transfer was going to
  `comments` LONGTEXT, -- any comments related to the transfer
  `reason` ENUM('Manual', 'StockrotationAdvance', 'StockrotationRepatriation', 'ReturnToHome', 'ReturnToHolding', 'RotatingCollection', 'Reserve', 'LostReserve', 'CancelReserve'), -- what triggered the transfer
  PRIMARY KEY (`branchtransfer_id`),
  KEY `frombranch` (`frombranch`),
  KEY `tobranch` (`tobranch`),
  KEY `itemnumber` (`itemnumber`),
  CONSTRAINT `branchtransfers_ibfk_1` FOREIGN KEY (`frombranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchtransfers_ibfk_2` FOREIGN KEY (`tobranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchtransfers_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `creator_images`
--

DROP TABLE IF EXISTS `creator_images`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `creator_images` (
  `image_id` int(4) NOT NULL AUTO_INCREMENT,
  `imagefile` mediumblob,
  `image_name` char(20) NOT NULL DEFAULT 'DEFAULT',
  PRIMARY KEY (`image_id`),
  UNIQUE KEY `image_name_index` (`image_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `creator_layouts`
--

DROP TABLE IF EXISTS `creator_layouts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `creator_layouts` (
  `layout_id` int(4) NOT NULL AUTO_INCREMENT,
  `barcode_type` char(100) NOT NULL DEFAULT 'CODE39',
  `start_label` int(2) NOT NULL DEFAULT '1',
  `printing_type` char(32) NOT NULL DEFAULT 'BAR',
  `layout_name` char(25) NOT NULL DEFAULT 'DEFAULT',
  `guidebox` int(1) DEFAULT '0',
  `oblique_title` int(1) DEFAULT '1',
  `font` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'TR',
  `font_size` int(4) NOT NULL DEFAULT '10',
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `callnum_split` int(1) DEFAULT '0',
  `text_justify` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'L',
  `format_string` varchar(210) NOT NULL DEFAULT 'barcode',
  `layout_xml` MEDIUMTEXT NOT NULL,
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`layout_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `creator_templates`
--

DROP TABLE IF EXISTS `creator_templates`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `creator_templates` (
  `template_id` int(4) NOT NULL AUTO_INCREMENT,
  `profile_id` int(4) DEFAULT NULL,
  `template_code` char(100) NOT NULL DEFAULT 'DEFAULT TEMPLATE',
  `template_desc` char(100) NOT NULL DEFAULT 'Default description',
  `page_width` float NOT NULL DEFAULT '0',
  `page_height` float NOT NULL DEFAULT '0',
  `label_width` float NOT NULL DEFAULT '0',
  `label_height` float NOT NULL DEFAULT '0',
  `top_text_margin` float NOT NULL DEFAULT '0',
  `left_text_margin` float NOT NULL DEFAULT '0',
  `top_margin` float NOT NULL DEFAULT '0',
  `left_margin` float NOT NULL DEFAULT '0',
  `cols` int(2) NOT NULL DEFAULT '0',
  `rows` int(2) NOT NULL DEFAULT '0',
  `col_gap` float NOT NULL DEFAULT '0',
  `row_gap` float NOT NULL DEFAULT '0',
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`template_id`),
  KEY `template_profile_fk_constraint` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `marc_subfield_structure`
--

DROP TABLE IF EXISTS `marc_subfield_structure`;
CREATE TABLE `marc_subfield_structure` (
  `tagfield` varchar(3) NOT NULL default '',
  `tagsubfield` varchar(1) NOT NULL default '' COLLATE utf8mb4_bin,
  `liblibrarian` varchar(255) NOT NULL default '',
  `libopac` varchar(255) NOT NULL default '',
  `repeatable` tinyint(4) NOT NULL default 0,
  `mandatory` tinyint(4) NOT NULL default 0,
  `important` tinyint(4) NOT NULL DEFAULT '0',
  `kohafield` varchar(40) default NULL,
  `tab` tinyint(1) default NULL,
  `authorised_value` varchar(32) default NULL,
  `authtypecode` varchar(20) default NULL,
  `value_builder` varchar(80) default NULL,
  `isurl` tinyint(1) default NULL,
  `hidden` tinyint(1) NOT NULL default 8,
  `frameworkcode` varchar(4) NOT NULL default '',
  `seealso` varchar(1100) default NULL,
  `link` varchar(80) default NULL,
  `defaultvalue` MEDIUMTEXT default NULL,
  `maxlength` int(4) NOT NULL DEFAULT '9999',
  PRIMARY KEY  (`frameworkcode`,`tagfield`,`tagsubfield`),
  KEY `kohafield_2` (`kohafield`),
  KEY `tab` (`frameworkcode`,`tab`),
  KEY `kohafield` (`frameworkcode`,`kohafield`),
  CONSTRAINT `marc_subfield_structure_ibfk_1` FOREIGN KEY (`authorised_value`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `important` tinyint(4) NOT NULL DEFAULT '0',
  `authorised_value` varchar(10) default NULL,
  `ind1_defaultvalue` varchar(1) NOT NULL default '',
  `ind2_defaultvalue` varchar(1) NOT NULL default '',
  `frameworkcode` varchar(4) NOT NULL default '',
  PRIMARY KEY  (`frameworkcode`,`tagfield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `need_merge_authorities`
--

DROP TABLE IF EXISTS `need_merge_authorities`;
CREATE TABLE `need_merge_authorities` ( -- keeping track of authority records still to be merged by merge_authority cron job
  `id` int NOT NULL auto_increment PRIMARY KEY, -- unique id
  `authid` bigint NOT NULL, -- reference to original authority record
  `authid_new` bigint, -- reference to optional new authority record
  `reportxml` MEDIUMTEXT, -- xml showing original reporting tag
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- date and time last modified
  `done` tinyint DEFAULT 0  -- indication whether merge has been executed (0=not done, 1=done, 2=in progress)
-- Note: authid and authid_new should NOT be FOREIGN keys !
-- authid may have been deleted; authid_new may be zero
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `oai_sets`
--

DROP TABLE IF EXISTS `oai_sets`;
CREATE TABLE `oai_sets` (
  `id` int(11) NOT NULL auto_increment,
  `spec` varchar(80) NOT NULL UNIQUE,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `oai_sets_descriptions`
--

DROP TABLE IF EXISTS `oai_sets_descriptions`;
CREATE TABLE `oai_sets_descriptions` (
  `set_id` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  CONSTRAINT `oai_sets_descriptions_ibfk_1` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `oai_sets_mappings`
--

DROP TABLE IF EXISTS `oai_sets_mappings`;
CREATE TABLE `oai_sets_mappings` (
  `set_id` int(11) NOT NULL,
  `rule_order` int NULL,
  `rule_operator` varchar(3) NULL,
  `marcfield` char(3) NOT NULL,
  `marcsubfield` char(1) NOT NULL,
  `operator` varchar(8) NOT NULL default 'equal',
  `marcvalue` varchar(80) NOT NULL,
  CONSTRAINT `oai_sets_mappings_ibfk_1` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `oai_sets_biblios`
--

DROP TABLE IF EXISTS `oai_sets_biblios`;
CREATE TABLE `oai_sets_biblios` (
  `biblionumber` int(11) NOT NULL,
  `set_id` int(11) NOT NULL,
  PRIMARY KEY (`biblionumber`, `set_id`),
  CONSTRAINT `oai_sets_biblios_ibfk_2` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `overduerules`
--

DROP TABLE IF EXISTS `overduerules`;
CREATE TABLE `overduerules` ( -- overdue notice status and triggers
  `overduerules_id` int(11) NOT NULL AUTO_INCREMENT, -- unique identifier for the overduerules
  `branchcode` varchar(10) NOT NULL default '', -- foreign key from the branches table to define which branch this rule is for (if blank it's all libraries)
  `categorycode` varchar(10) NOT NULL default '', -- foreign key from the categories table to define which patron category this rule is for
  `delay1` int(4) default NULL, -- number of days after the item is overdue that the first notice is sent
  `letter1` varchar(20) default NULL, -- foreign key from the letter table to define which notice should be sent as the first notice
  `debarred1` varchar(1) default 0, -- is the patron restricted when the first notice is sent (1 for yes, 0 for no)
  `delay2` int(4) default NULL, -- number of days after the item is overdue that the second notice is sent
  `debarred2` varchar(1) default 0, -- is the patron restricted when the second notice is sent (1 for yes, 0 for no)
  `letter2` varchar(20) default NULL, -- foreign key from the letter table to define which notice should be sent as the second notice
  `delay3` int(4) default NULL, -- number of days after the item is overdue that the third notice is sent
  `letter3` varchar(20) default NULL, -- foreign key from the letter table to define which notice should be sent as the third notice
  `debarred3` int(1) default 0, -- is the patron restricted when the third notice is sent (1 for yes, 0 for no)
  PRIMARY KEY  (`overduerules_id`),
  UNIQUE KEY `overduerules_branch_cat` (`branchcode`,`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `pending_offline_operations`
--
-- this table is MyISAM, InnoDB tables are growing only and this table is filled/emptied/filled/emptied...
-- so MyISAM is better in this case

DROP TABLE IF EXISTS `pending_offline_operations`;
CREATE TABLE pending_offline_operations (
  operationid int(11) NOT NULL AUTO_INCREMENT,
  userid varchar(30) NOT NULL,
  branchcode varchar(10) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `action` varchar(10) NOT NULL,
  barcode varchar(20) DEFAULT NULL,
  cardnumber varchar(32) DEFAULT NULL,
  amount decimal(28,6) DEFAULT NULL,
  PRIMARY KEY (operationid)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `printers_profile`
--

DROP TABLE IF EXISTS `printers_profile`;
CREATE TABLE `printers_profile` (
  `profile_id` int(4) NOT NULL auto_increment,
  `printer_name` varchar(40) NOT NULL default 'Default Printer',
  `template_id` int(4) NOT NULL default '0',
  `paper_bin` varchar(20) NOT NULL default 'Bypass',
  `offset_horz` float NOT NULL default '0',
  `offset_vert` float NOT NULL default '0',
  `creep_horz` float NOT NULL default '0',
  `creep_vert` float NOT NULL default '0',
  `units` char(20) NOT NULL default 'POINT',
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY  (`profile_id`),
  UNIQUE KEY `printername` (`printer_name`,`template_id`,`paper_bin`,`creator`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `repeatable_holidays`
--

DROP TABLE IF EXISTS `repeatable_holidays`;
CREATE TABLE `repeatable_holidays` ( -- information for the days the library is closed
  `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `branchcode` varchar(10) NOT NULL, -- foreign key from the branches table, defines which branch this closing is for
  `weekday` smallint(6) default NULL, -- day of the week (0=Sunday, 1=Monday, etc) this closing is repeated on
  `day` smallint(6) default NULL, -- day of the month this closing is on
  `month` smallint(6) default NULL, -- month this closing is in
  `title` varchar(50) NOT NULL default '', -- title of this closing
  `description` MEDIUMTEXT NOT NULL, -- description for this closing
  PRIMARY KEY  (`id`),
  CONSTRAINT `repeatable_holidays_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `reports_dictionary`
--

DROP TABLE IF EXISTS `reports_dictionary`;
CREATE TABLE reports_dictionary ( -- definitions (or snippets of SQL) stored for use in reports
   `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
   `name` varchar(255) default NULL, -- name for this definition
   `description` MEDIUMTEXT, -- description for this definition
   `date_created` datetime default NULL, -- date and time this definition was created
   `date_modified` datetime default NULL, -- date and time this definition was last modified
   `saved_sql` MEDIUMTEXT, -- SQL snippet for us in reports
   report_area varchar(6) DEFAULT NULL, -- Koha module this definition is for Circulation, Catalog, Patrons, Acquistions, Accounts)
   PRIMARY KEY  (id),
   KEY dictionary_area_idx (report_area)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `saved_sql`
--

DROP TABLE IF EXISTS `saved_sql`;
CREATE TABLE saved_sql ( -- saved sql reports
   `id` int(11) NOT NULL auto_increment, -- unique id and primary key assigned by Koha
   `borrowernumber` int(11) default NULL, -- the staff member who created this report (borrowers.borrowernumber)
   `date_created` datetime default NULL, -- the date this report was created
   `last_modified` datetime default NULL, -- the date this report was last edited
   `savedsql` MEDIUMTEXT, -- the SQL for this report
   `last_run` datetime default NULL,
   `report_name` varchar(255) NOT NULL default '', -- the name of this report
   `type` varchar(255) default NULL, -- always 1 for tabular
   `notes` MEDIUMTEXT, -- the notes or description given to this report
   `cache_expiry` int NOT NULL default 300,
   `public` tinyint(1) NOT NULL default FALSE,
    report_area varchar(6) default NULL,
    report_group varchar(80) default NULL,
    report_subgroup varchar(80) default NULL,
    `mana_id` int(11) NULL DEFAULT NULL,
   PRIMARY KEY  (`id`),
   KEY sql_area_group_idx (report_group, report_subgroup),
   KEY boridx (`borrowernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Table structure for `saved_reports`
--

DROP TABLE IF EXISTS `saved_reports`;
CREATE TABLE saved_reports (
   `id` int(11) NOT NULL auto_increment,
   `report_id` int(11) default NULL,
   `report` LONGTEXT,
   `date_run` datetime default NULL,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'search_field'
--

DROP TABLE IF EXISTS search_field;
CREATE TABLE `search_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'the name of the field as it will be stored in the search engine',
  `label` varchar(255) NOT NULL COMMENT 'the human readable name of the field, for display',
  `type` ENUM('', 'string', 'date', 'number', 'boolean', 'sum', 'isbn', 'stdno') NOT NULL COMMENT 'what type of data this holds, relevant when storing it in the search engine',
  `weight` decimal(5,2) DEFAULT NULL,
  `facet_order` TINYINT(4) DEFAULT NULL COMMENT 'the order place of the field in facet list if faceted',
  `staff_client` tinyint(1) NOT NULL DEFAULT 1,
  `opac` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name` (191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `search_history`
--

DROP TABLE IF EXISTS `search_history`;
CREATE TABLE IF NOT EXISTS `search_history` ( -- patron's opac search history
  `id` int(11) NOT NULL auto_increment, -- search history id
  `userid` int(11) NOT NULL, -- the patron who performed the search (borrowers.borrowernumber)
  `sessionid` varchar(32) NOT NULL, -- a system generated session id
  `query_desc` varchar(255) NOT NULL, -- the search that was performed
  `query_cgi` MEDIUMTEXT NOT NULL, -- the string to append to the search url to rerun the search
  `type` varchar(16) NOT NULL DEFAULT 'biblio', -- search type, must be 'biblio' or 'authority'
  `total` int(11) NOT NULL, -- the total of results found
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP, -- the date and time the search was run
  KEY `userid` (`userid`),
  KEY `sessionid` (`sessionid`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Opac search history results';

--
-- Table structure for table 'search_marc_map'
--

DROP TABLE IF EXISTS search_marc_map;
CREATE TABLE `search_marc_map` (
  id int(11) NOT NULL AUTO_INCREMENT,
  index_name ENUM('biblios','authorities') NOT NULL COMMENT 'what storage index this map is for',
  marc_type ENUM('marc21', 'unimarc', 'normarc') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'what MARC type this map is for',
  marc_field VARCHAR(255) NOT NULL COLLATE utf8mb4_bin COMMENT 'the MARC specifier for this field',
  PRIMARY KEY(`id`),
  UNIQUE key `index_name` (`index_name`, `marc_field` (191), `marc_type`),
  INDEX (`index_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'search_marc_to_field'
--

DROP TABLE IF EXISTS search_marc_to_field;
CREATE TABLE `search_marc_to_field` (
  search tinyint(1) NOT NULL DEFAULT 1,
  search_marc_map_id int(11) NOT NULL,
  search_field_id int(11) NOT NULL,
  facet tinyint(1) DEFAULT FALSE COMMENT 'true if a facet field should be generated for this',
  suggestible tinyint(1) DEFAULT FALSE COMMENT 'true if this field can be used to generate suggestions for browse',
  sort tinyint(1) DEFAULT NULL COMMENT 'true/false creates special sort handling, null doesn''t',
  PRIMARY KEY(search_marc_map_id, search_field_id),
  FOREIGN KEY(search_marc_map_id) REFERENCES search_marc_map(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY(search_field_id) REFERENCES search_field(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS sessions;
CREATE TABLE sessions (
  `id` varchar(32) NOT NULL,
  `a_session` LONGTEXT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `sms_providers`
--

DROP TABLE IF EXISTS sms_providers;
CREATE TABLE `sms_providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `domain` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name` (191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrowers`
--

DROP TABLE IF EXISTS `borrowers`;
CREATE TABLE `borrowers` ( -- this table includes information about your patrons/borrowers/members
  `borrowernumber` int(11) NOT NULL auto_increment, -- primary key, Koha assigned ID number for patrons/borrowers
  `cardnumber` varchar(32) default NULL, -- unique key, library assigned ID number for patrons/borrowers
  `surname` LONGTEXT, -- patron/borrower's last name (surname)
  `firstname` MEDIUMTEXT, -- patron/borrower's first name
  `title` LONGTEXT, -- patron/borrower's title, for example: Mr. or Mrs.
  `othernames` LONGTEXT, -- any other names associated with the patron/borrower
  `initials` MEDIUMTEXT, -- initials for your patron/borrower
  `streetnumber` TINYTEXT default NULL, -- the house number for your patron/borrower's primary address
  `streettype` TINYTEXT default NULL, -- the street type (Rd., Blvd, etc) for your patron/borrower's primary address
  `address` LONGTEXT, -- the first address line for your patron/borrower's primary address
  `address2` MEDIUMTEXT, -- the second address line for your patron/borrower's primary address
  `city` LONGTEXT, -- the city or town for your patron/borrower's primary address
  `state` MEDIUMTEXT default NULL, -- the state or province for your patron/borrower's primary address
  `zipcode` TINYTEXT default NULL, -- the zip or postal code for your patron/borrower's primary address
  `country` MEDIUMTEXT, -- the country for your patron/borrower's primary address
  `email` LONGTEXT, -- the primary email address for your patron/borrower's primary address
  `phone` MEDIUMTEXT, -- the primary phone number for your patron/borrower's primary address
  `mobile` TINYTEXT default NULL, -- the other phone number for your patron/borrower's primary address
  `fax` LONGTEXT, -- the fax number for your patron/borrower's primary address
  `emailpro` MEDIUMTEXT, -- the secondary email addres for your patron/borrower's primary address
  `phonepro` MEDIUMTEXT, -- the secondary phone number for your patron/borrower's primary address
  `B_streetnumber` TINYTEXT default NULL, -- the house number for your patron/borrower's alternate address
  `B_streettype` TINYTEXT default NULL, -- the street type (Rd., Blvd, etc) for your patron/borrower's alternate address
  `B_address` MEDIUMTEXT default NULL, -- the first address line for your patron/borrower's alternate address
  `B_address2` MEDIUMTEXT default NULL, -- the second address line for your patron/borrower's alternate address
  `B_city` LONGTEXT, -- the city or town for your patron/borrower's alternate address
  `B_state` MEDIUMTEXT default NULL, -- the state for your patron/borrower's alternate address
  `B_zipcode` TINYTEXT default NULL, -- the zip or postal code for your patron/borrower's alternate address
  `B_country` MEDIUMTEXT, -- the country for your patron/borrower's alternate address
  `B_email` MEDIUMTEXT, -- the patron/borrower's alternate email address
  `B_phone` LONGTEXT, -- the patron/borrower's alternate phone number
  `dateofbirth` date default NULL, -- the patron/borrower's date of birth (YYYY-MM-DD)
  `branchcode` varchar(10) NOT NULL default '', -- foreign key from the branches table, includes the code of the patron/borrower's home branch
  `categorycode` varchar(10) NOT NULL default '', -- foreign key from the categories table, includes the code of the patron category
  `dateenrolled` date default NULL, -- date the patron was added to Koha (YYYY-MM-DD)
  `dateexpiry` date default NULL, -- date the patron/borrower's card is set to expire (YYYY-MM-DD)
  `date_renewed` date default NULL, -- date the patron/borrower's card was last renewed
  `gonenoaddress` tinyint(1) default NULL, -- set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having an unconfirmed address
  `lost` tinyint(1) default NULL, -- set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having lost their card
  `debarred` date default NULL, -- until this date the patron can only check-in (no loans, no holds, etc.), is a fine based on days instead of money (YYYY-MM-DD)
  `debarredcomment` VARCHAR(255) DEFAULT NULL, -- comment on the stop of the patron
  `contactname` LONGTEXT, -- used for children and profesionals to include surname or last name of guarantor or organization name
  `contactfirstname` MEDIUMTEXT, -- used for children to include first name of guarantor
  `contacttitle` MEDIUMTEXT, -- used for children to include title (Mr., Mrs., etc) of guarantor
  `borrowernotes` LONGTEXT, -- a note on the patron/borrower's account that is only visible in the staff client
  `relationship` varchar(100) default NULL, -- used for children to include the relationship to their guarantor
  `sex` varchar(1) default NULL, -- patron/borrower's gender
  `password` varchar(60) default NULL, -- patron/borrower's Bcrypt encrypted password
  `flags` int(11) default NULL, -- will include a number associated with the staff member's permissions
  `userid` varchar(75) default NULL, -- patron/borrower's opac and/or staff client log in
  `opacnote` LONGTEXT, -- a note on the patron/borrower's account that is visible in the OPAC and staff client
  `contactnote` varchar(255) default NULL, -- a note related to the patron/borrower's alternate address
  `sort1` varchar(80) default NULL, -- a field that can be used for any information unique to the library
  `sort2` varchar(80) default NULL, -- a field that can be used for any information unique to the library
  `altcontactfirstname` MEDIUMTEXT  default NULL, -- first name of alternate contact for the patron/borrower
  `altcontactsurname` MEDIUMTEXT default NULL, -- surname or last name of the alternate contact for the patron/borrower
  `altcontactaddress1` MEDIUMTEXT default NULL, -- the first address line for the alternate contact for the patron/borrower
  `altcontactaddress2` MEDIUMTEXT default NULL, -- the second address line for the alternate contact for the patron/borrower
  `altcontactaddress3` MEDIUMTEXT default NULL, -- the city for the alternate contact for the patron/borrower
  `altcontactstate` MEDIUMTEXT default NULL, -- the state for the alternate contact for the patron/borrower
  `altcontactzipcode` MEDIUMTEXT default NULL, -- the zipcode for the alternate contact for the patron/borrower
  `altcontactcountry` MEDIUMTEXT default NULL, -- the country for the alternate contact for the patron/borrower
  `altcontactphone` MEDIUMTEXT default NULL, -- the phone number for the alternate contact for the patron/borrower
  `smsalertnumber` varchar(50) default NULL, -- the mobile phone number where the patron/borrower would like to receive notices (if SMS turned on)
  `sms_provider_id` int(11) DEFAULT NULL, -- the provider of the mobile phone number defined in smsalertnumber
  `privacy` integer(11) DEFAULT '1' NOT NULL, -- patron/borrower's privacy settings related to their reading history
  `privacy_guarantor_fines` tinyint(1) NOT NULL DEFAULT '0', -- controls if relatives can see this patron's fines
  `privacy_guarantor_checkouts` tinyint(1) NOT NULL DEFAULT '0', -- controls if relatives can see this patron's checkouts
  `checkprevcheckout` varchar(7) NOT NULL default 'inherit', -- produce a warning for this patron if this item has previously been checked out to this patron if 'yes', not if 'no', defer to category setting if 'inherit'.
  `updated_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- time of last change could be useful for synchronization with external systems (among others)
  `lastseen` datetime default NULL, -- last time a patron has been seen (connected at the OPAC or staff interface)
  `lang` varchar(25) NOT NULL default 'default', -- lang to use to send notices to this patron
  `login_attempts` int(4) default 0, -- number of failed login attemps
  `overdrive_auth_token` MEDIUMTEXT default NULL, -- persist OverDrive auth token
  `anonymized` TINYINT(1) NOT NULL DEFAULT 0, -- flag for data anonymization
  `autorenew_checkouts` TINYINT(1) NOT NULL DEFAULT 1, -- flag for allowing auto-renewal
  UNIQUE KEY `cardnumber` (`cardnumber`),
  PRIMARY KEY `borrowernumber` (`borrowernumber`),
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`),
  UNIQUE KEY `userid` (`userid`),
  KEY `surname_idx` (`surname` (191)),
  KEY `firstname_idx` (`firstname` (191)),
  KEY `othernames_idx` (`othernames` (191)),
  KEY `sms_provider_id` (`sms_provider_id`),
  CONSTRAINT `borrowers_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`),
  CONSTRAINT `borrowers_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`),
  CONSTRAINT `borrowers_ibfk_3` FOREIGN KEY (`sms_provider_id`) REFERENCES `sms_providers` (`id`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrower_attributes`
--

DROP TABLE IF EXISTS `borrower_attributes`;
CREATE TABLE `borrower_attributes` ( -- values of custom patron fields known as extended patron attributes linked to patrons/borrowers
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Row id field
  `borrowernumber` int(11) NOT NULL, -- foreign key from the borrowers table, defines which patron/borrower has this attribute
  `code` varchar(10) NOT NULL, -- foreign key from the borrower_attribute_types table, defines which custom field this value was entered for
  `attribute` varchar(255) default NULL, -- custom patron field value
  KEY `borrowernumber` (`borrowernumber`),
  KEY `code_attribute` (`code`, `attribute` (191)),
  CONSTRAINT `borrower_attributes_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_attributes_ibfk_2` FOREIGN KEY (`code`) REFERENCES `borrower_attribute_types` (`code`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrower_debarments`
--

DROP TABLE IF EXISTS `borrower_debarments`;
CREATE TABLE borrower_debarments ( -- tracks restrictions on the patron's record
  borrower_debarment_id int(11) NOT NULL AUTO_INCREMENT, -- unique key for the restriction
  borrowernumber int(11) NOT NULL, -- foreign key for borrowers.borrowernumber for patron who is restricted
  expiration date DEFAULT NULL, -- expiration date of the restriction
  `type` enum('SUSPENSION','OVERDUES','MANUAL','DISCHARGE') NOT NULL DEFAULT 'MANUAL', -- type of restriction
  `comment` MEDIUMTEXT, -- comments about the restriction
  manager_id int(11) DEFAULT NULL, -- foreign key for borrowers.borrowernumber for the librarian managing the restriction
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- date the restriction was added
  updated timestamp NULL DEFAULT NULL, -- date the restriction was updated
  PRIMARY KEY (borrower_debarment_id),
  KEY borrowernumber (borrowernumber),
  CONSTRAINT `borrower_debarments_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table api_keys
--

DROP TABLE IF EXISTS `api_keys`;
CREATE TABLE `api_keys` (
    `client_id`   VARCHAR(191) NOT NULL,           -- API client ID
    `secret`      VARCHAR(191) NOT NULL,           -- API client secret used for API authentication
    `description` VARCHAR(255) NOT NULL,           -- API client description
    `patron_id`   INT(11) NOT NULL,                -- Foreign key to the borrowers table
    `active`      TINYINT(1) DEFAULT 1 NOT NULL,   -- 0 means this API key is revoked
    PRIMARY KEY `client_id` (`client_id`),
    UNIQUE KEY `secret` (`secret`),
    KEY `patron_id` (`patron_id`),
    CONSTRAINT `api_keys_fk_patron_id`
      FOREIGN KEY (`patron_id`)
      REFERENCES `borrowers` (`borrowernumber`)
      ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `issues`
--

DROP TABLE IF EXISTS `issues`;
CREATE TABLE `issues` ( -- information related to check outs or issues
  `issue_id` int(11) NOT NULL AUTO_INCREMENT, -- primary key for issues table
  `borrowernumber` int(11), -- foreign key, linking this to the borrowers table for the patron this item was checked out to
  `itemnumber` int(11), -- foreign key, linking this to the items table for the item that was checked out
  `date_due` datetime default NULL, -- datetime the item is due (yyyy-mm-dd hh:mm::ss)
  `branchcode` varchar(10) default NULL, -- foreign key, linking to the branches table for the location the item was checked out
  `returndate` datetime default NULL, -- date the item was returned, will be NULL until moved to old_issues
  `lastreneweddate` datetime default NULL, -- date the item was last renewed
  `renewals` tinyint(4) NOT NULL default 0, -- lists the number of times the item was renewed
  `auto_renew` tinyint(1) default FALSE, -- automatic renewal
  `auto_renew_error` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL, -- automatic renewal error
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this record was last touched
  `issuedate` datetime default NULL, -- date the item was checked out or issued
  `onsite_checkout` int(1) NOT NULL default 0, -- in house use flag
  `note` LONGTEXT default NULL, -- issue note text
  `notedate` datetime default NULL, -- datetime of issue note (yyyy-mm-dd hh:mm::ss)
  `noteseen` int(1) default NULL, -- describes whether checkout note has been seen 1, not been seen 0 or doesn't exist null
  PRIMARY KEY (`issue_id`),
  UNIQUE KEY `itemnumber` (`itemnumber`),
  KEY `issuesborridx` (`borrowernumber`),
  KEY `itemnumber_idx` (`itemnumber`),
  KEY `branchcode_idx` (`branchcode`),
  KEY `bordate` (`borrowernumber`,`timestamp`),
  CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `old_issues`
--

DROP TABLE IF EXISTS `old_issues`;
CREATE TABLE `old_issues` ( -- lists items that were checked out and have been returned
  `issue_id` int(11) NOT NULL, -- primary key for issues table
  `borrowernumber` int(11) default NULL, -- foreign key, linking this to the borrowers table for the patron this item was checked out to
  `itemnumber` int(11) default NULL, -- foreign key, linking this to the items table for the item that was checked out
  `date_due` datetime default NULL, -- date the item is due (yyyy-mm-dd)
  `branchcode` varchar(10) default NULL, -- foreign key, linking to the branches table for the location the item was checked out
  `returndate` datetime default NULL, -- date the item was returned
  `lastreneweddate` datetime default NULL, -- date the item was last renewed
  `renewals` tinyint(4) NOT NULL default 0, -- lists the number of times the item was renewed
  `auto_renew` tinyint(1) default FALSE, -- automatic renewal
  `auto_renew_error` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL, -- automatic renewal error
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this record was last touched
  `issuedate` datetime default NULL, -- date the item was checked out or issued
  `onsite_checkout` int(1) NOT NULL default 0, -- in house use flag
  `note` LONGTEXT default NULL, -- issue note text
  `notedate` datetime default NULL, -- datetime of issue note (yyyy-mm-dd hh:mm::ss)
  `noteseen` int(1) default NULL, -- describes whether checkout note has been seen 1, not been seen 0 or doesn't exist null
  PRIMARY KEY (`issue_id`),
  KEY `old_issuesborridx` (`borrowernumber`),
  KEY `old_issuesitemidx` (`itemnumber`),
  KEY `branchcode_idx` (`branchcode`),
  KEY `old_bordate` (`borrowernumber`,`timestamp`),
  CONSTRAINT `old_issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
    ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`)
    ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `items_last_borrower`
--

CREATE TABLE IF NOT EXISTS `items_last_borrower` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `itemnumber` int(11) NOT NULL,
  `borrowernumber` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `itemnumber` (`itemnumber`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT `items_last_borrower_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_last_borrower_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `creator_batches`
--

DROP TABLE IF EXISTS `creator_batches`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `creator_batches` (
  `label_id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(10) NOT NULL DEFAULT '1',
  `description` mediumtext DEFAULT NULL,
  `item_number` int(11) DEFAULT NULL,
  `borrower_number` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `branch_code` varchar(10) NOT NULL DEFAULT 'NB',
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`label_id`),
  KEY `branch_fk_constraint` (`branch_code`),
  KEY `item_fk_constraint` (`item_number`),
  KEY `borrower_fk_constraint` (`borrower_number`),
  CONSTRAINT `creator_batches_ibfk_1` FOREIGN KEY (`borrower_number`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `creator_batches_ibfk_2` FOREIGN KEY (`branch_code`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE,
  CONSTRAINT `creator_batches_ibfk_3` FOREIGN KEY (`item_number`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `opac_news`
--

DROP TABLE IF EXISTS `opac_news`;
CREATE TABLE `opac_news` ( -- data from the news tool
  `idnew` int(10) unsigned NOT NULL auto_increment, -- unique identifier for the news article
  `branchcode` varchar(10) default NULL, -- branch code users to create branch specific news, NULL is every branch.
  `title` varchar(250) NOT NULL default '', -- title of the news article
  `content` MEDIUMTEXT NOT NULL, -- the body of your news article
  `lang` varchar(25) NOT NULL default '', -- location for the article (koha is the staff client, slip is the circulation receipt and language codes are for the opac)
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP, -- pulibcation date and time
  `expirationdate` date default NULL, -- date the article is set to expire or no longer be visible
  `number` int(11) default NULL, -- the order in which this article appears in that specific location
  `borrowernumber` int(11) default NULL, -- The user who created the news article
  PRIMARY KEY  (`idnew`),
  CONSTRAINT `borrowernumber_fk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT opac_news_branchcode_ibfk FOREIGN KEY (branchcode) REFERENCES branches (branchcode)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `patronimage`
--

DROP TABLE IF EXISTS `patronimage`;
CREATE TABLE `patronimage` ( -- information related to patron images
  `borrowernumber` int(11) NOT NULL, -- the borrowernumber of the patron this image is attached to (borrowers.borrowernumber)
  `mimetype` varchar(15) NOT NULL, -- the format of the image (png, jpg, etc)
  `imagefile` mediumblob NOT NULL, -- the image
  PRIMARY KEY  (`borrowernumber`),
  CONSTRAINT `patronimage_fk1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `reserves`
--

DROP TABLE IF EXISTS `reserves`;
CREATE TABLE `reserves` ( -- information related to holds/reserves in Koha
  `reserve_id` int(11) NOT NULL auto_increment, -- primary key
  `borrowernumber` int(11) NOT NULL default 0, -- foreign key from the borrowers table defining which patron this hold is for
  `reservedate` date default NULL, -- the date the hold was placed
  `biblionumber` int(11) NOT NULL default 0, -- foreign key from the biblio table defining which bib record this hold is on
  `branchcode` varchar(10) default NULL, -- foreign key from the branches table defining which branch the patron wishes to pick this hold up at
  `notificationdate` date default NULL, -- currently unused
  `reminderdate` date default NULL, -- currently unused
  `cancellationdate` date default NULL, -- the date this hold was cancelled
  `reservenotes` LONGTEXT, -- notes related to this hold
  `priority` smallint(6) NOT NULL DEFAULT 1, -- where in the queue the patron sits
  `found` varchar(1) default NULL, -- a one letter code defining what the status is of the hold is after it has been confirmed
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this hold was last updated
  `itemnumber` int(11) default NULL, -- foreign key from the items table defining the specific item the patron has placed on hold or the item this hold was filled with
  `waitingdate` date default NULL, -- the date the item was marked as waiting for the patron at the library
  `expirationdate` DATE DEFAULT NULL, -- the date the hold expires (usually the date entered by the patron to say they don't need the hold after a certain date)
  `lowestPriority` tinyint(1) NOT NULL DEFAULT 0,
  `suspend` tinyint(1) NOT NULL DEFAULT 0,
  `suspend_until` DATETIME NULL DEFAULT NULL,
  `itemtype` VARCHAR(10) NULL DEFAULT NULL, -- If record level hold, the optional itemtype of the item the patron is requesting
  `item_level_hold` tinyint(1) NOT NULL DEFAULT 0, -- Is the hpld placed at item level
  PRIMARY KEY (`reserve_id`),
  KEY priorityfoundidx (priority,found),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  KEY `itemtype` (`itemtype`),
  CONSTRAINT `reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_5` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `old_reserves`
--

DROP TABLE IF EXISTS `old_reserves`;
CREATE TABLE `old_reserves` ( -- this table holds all holds/reserves that have been completed (either filled or cancelled)
  `reserve_id` int(11) NOT NULL, -- primary key
  `borrowernumber` int(11) default NULL, -- foreign key from the borrowers table defining which patron this hold is for
  `reservedate` date default NULL, -- the date the hold was places
  `biblionumber` int(11) default NULL, -- foreign key from the biblio table defining which bib record this hold is on
  `branchcode` varchar(10) default NULL, -- foreign key from the branches table defining which branch the patron wishes to pick this hold up at
  `notificationdate` date default NULL, -- currently unused
  `reminderdate` date default NULL, -- currently unused
  `cancellationdate` date default NULL, -- the date this hold was cancelled
  `reservenotes` LONGTEXT, -- notes related to this hold
  `priority` smallint(6) NOT NULL DEFAULT 1, -- where in the queue the patron sits
  `found` varchar(1) default NULL, -- a one letter code defining what the status is of the hold is after it has been confirmed
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this hold was last updated
  `itemnumber` int(11) default NULL, -- foreign key from the items table defining the specific item the patron has placed on hold or the item this hold was filled with
  `waitingdate` date default NULL, -- the date the item was marked as waiting for the patron at the library
  `expirationdate` DATE DEFAULT NULL, -- the date the hold expires (usually the date entered by the patron to say they don't need the hold after a certain date)
  `lowestPriority` tinyint(1) NOT NULL DEFAULT 0, -- has this hold been pinned to the lowest priority in the holds queue (1 for yes, 0 for no)
  `suspend` tinyint(1) NOT NULL DEFAULT 0, -- in this hold suspended (1 for yes, 0 for no)
  `suspend_until` DATETIME NULL DEFAULT NULL, -- the date this hold is suspended until (NULL for infinitely)
  `itemtype` VARCHAR(10) NULL DEFAULT NULL, -- If record level hold, the optional itemtype of the item the patron is requesting
  `item_level_hold` tinyint(1) NOT NULL DEFAULT 0, -- Is the hpld placed at item level
  PRIMARY KEY (`reserve_id`),
  KEY `old_reserves_borrowernumber` (`borrowernumber`),
  KEY `old_reserves_biblionumber` (`biblionumber`),
  KEY `old_reserves_itemnumber` (`itemnumber`),
  KEY `old_reserves_branchcode` (`branchcode`),
  KEY `old_reserves_itemtype` (`itemtype`),
  CONSTRAINT `old_reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
    ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`)
    ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`)
    ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_4` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`)
    ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` ( -- patron opac comments
  `reviewid` int(11) NOT NULL auto_increment, -- unique identifier for this comment
  `borrowernumber` int(11) default NULL, -- foreign key from the borrowers table defining which patron left this comment
  `biblionumber` int(11) default NULL, -- foreign key from the biblio table defining which bibliographic record this comment is for
  `review` MEDIUMTEXT, -- the body of the comment
  `approved` tinyint(4) default 0, -- whether this comment has been approved by a librarian (1 for yes, 0 for no)
  `datereviewed` datetime default NULL, -- the date the comment was left
  PRIMARY KEY  (`reviewid`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `special_holidays`
--

DROP TABLE IF EXISTS `special_holidays`;
CREATE TABLE `special_holidays` ( -- non repeatable holidays/library closings
  `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `branchcode` varchar(10) NOT NULL, -- foreign key from the branches table, defines which branch this closing is for
  `day` smallint(6) NOT NULL default 0, -- day of the month this closing is on
  `month` smallint(6) NOT NULL default 0, -- month this closing is in
  `year` smallint(6) NOT NULL default 0, -- year this closing is in
  `isexception` smallint(1) NOT NULL default 1, -- is this a holiday exception to a repeatable holiday (1 for yes, 0 for no)
  `title` varchar(50) NOT NULL default '', -- title for this closing
  `description` MEDIUMTEXT NOT NULL, -- description of this closing
  PRIMARY KEY  (`id`),
  CONSTRAINT `special_holidays_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
CREATE TABLE `statistics` ( -- information related to transactions (circulation and fines) in Koha
  `datetime` datetime default NULL, -- date and time of the transaction
  `branch` varchar(10) default NULL, -- foreign key, branch where the transaction occurred
  `value` double(16,4) default NULL, -- monetary value associated with the transaction
  `type` varchar(16) default NULL, -- transaction type (localuse, issue, return, renew, writeoff, payment)
  `other` LONGTEXT, -- used by SIP
  `itemnumber` int(11) default NULL, -- foreign key from the items table, links transaction to a specific item
  `itemtype` varchar(10) default NULL, -- foreign key from the itemtypes table, links transaction to a specific item type
  `location` varchar(80) default NULL, -- authorized value for the shelving location for this item (MARC21 952$c)
  `borrowernumber` int(11) default NULL, -- foreign key from the borrowers table, links transaction to a specific borrower
  `ccode` varchar(80) default NULL, -- foreign key from the items table, links transaction to a specific collection code
  KEY `timeidx` (`datetime`),
  KEY `branch_idx` (`branch`),
  KEY `type_idx` (`type`),
  KEY `itemnumber_idx` (`itemnumber`),
  KEY `itemtype_idx` (`itemtype`),
  KEY `borrowernumber_idx` (`borrowernumber`),
  KEY `ccode_idx` (`ccode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table subscription_frequencies
--

DROP TABLE IF EXISTS subscription_frequencies;
CREATE TABLE subscription_frequencies (
    id INTEGER NOT NULL AUTO_INCREMENT,
    description MEDIUMTEXT NOT NULL,
    displayorder INT DEFAULT NULL,
    unit ENUM('day','week','month','year') DEFAULT NULL,
    unitsperissue INTEGER NOT NULL DEFAULT '1',
    issuesperunit INTEGER NOT NULL DEFAULT '1',
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table subscription_numberpatterns
--

DROP TABLE IF EXISTS subscription_numberpatterns;
CREATE TABLE subscription_numberpatterns (
    id INTEGER NOT NULL AUTO_INCREMENT,
    label VARCHAR(255) NOT NULL,
    displayorder INTEGER DEFAULT NULL,
    description MEDIUMTEXT NOT NULL,
    numberingmethod VARCHAR(255) NOT NULL,
    label1 VARCHAR(255) DEFAULT NULL,
    add1 INTEGER DEFAULT NULL,
    every1 INTEGER DEFAULT NULL,
    whenmorethan1 INTEGER DEFAULT NULL,
    setto1 INTEGER DEFAULT NULL,
    numbering1 VARCHAR(255) DEFAULT NULL,
    label2 VARCHAR(255) DEFAULT NULL,
    add2 INTEGER DEFAULT NULL,
    every2 INTEGER DEFAULT NULL,
    whenmorethan2 INTEGER DEFAULT NULL,
    setto2 INTEGER DEFAULT NULL,
    numbering2 VARCHAR(255) DEFAULT NULL,
    label3 VARCHAR(255) DEFAULT NULL,
    add3 INTEGER DEFAULT NULL,
    every3 INTEGER DEFAULT NULL,
    whenmorethan3 INTEGER DEFAULT NULL,
    setto3 INTEGER DEFAULT NULL,
    numbering3 VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `subscription`
--

DROP TABLE IF EXISTS `subscription`;
CREATE TABLE `subscription` ( -- information related to the subscription
  `biblionumber` int(11) NOT NULL, -- foreign key for biblio.biblionumber that this subscription is attached to
  `subscriptionid` int(11) NOT NULL auto_increment, -- unique key for this subscription
  `librarian` varchar(100) default '', -- the librarian's username from borrowers.userid
  `startdate` date default NULL, -- start date for this subscription
  `aqbooksellerid` int(11) default 0, -- foreign key for aqbooksellers.id to link to the vendor
  `cost` int(11) default 0,
  `aqbudgetid` int(11) default 0,
  `weeklength` int(11) default 0, -- subscription length in weeks (will not be filled in if monthlength or numberlength is set)
  `monthlength` int(11) default 0, -- subscription length in weeks (will not be filled in if weeklength or numberlength is set)
  `numberlength` int(11) default 0, -- subscription length in weeks (will not be filled in if monthlength or weeklength is set)
  `periodicity` integer default null, -- frequency type links to subscription_frequencies.id
  countissuesperunit INTEGER NOT NULL DEFAULT 1,
  `notes` LONGTEXT, -- notes
  `status` varchar(100) NOT NULL default '',  -- status of this subscription
  `lastvalue1` int(11) default NULL,
  `innerloop1` int(11) default 0,
  `lastvalue2` int(11) default NULL,
  `innerloop2` int(11) default 0,
  `lastvalue3` int(11) default NULL,
  `innerloop3` int(11) default 0,
  `firstacquidate` date default NULL, -- first issue received date
  `manualhistory` tinyint(1) NOT NULL default 0, -- yes or no to managing the history manually
  `irregularity` MEDIUMTEXT, -- any irregularities in the subscription
  skip_serialseq tinyint(1) NOT NULL DEFAULT 0,
  `letter` varchar(20) default NULL,
  `numberpattern` integer default null, -- the numbering pattern used links to subscription_numberpatterns.id
  locale VARCHAR(80) DEFAULT NULL, -- for foreign language subscriptions to display months, seasons, etc correctly
  `distributedto` MEDIUMTEXT,
  `internalnotes` LONGTEXT,
  `callnumber` MEDIUMTEXT, -- default call number
  `location` varchar(80) NULL default '', -- default shelving location (items.location)
  `branchcode` varchar(10) NOT NULL default '', -- default branches (items.homebranch)
  `lastbranch` varchar(10),
  `serialsadditems` tinyint(1) NOT NULL default '0', -- does receiving this serial create an item record
  `staffdisplaycount` VARCHAR(10) NULL, -- how many issues to show to the staff
  `opacdisplaycount` VARCHAR(10) NULL, -- how many issues to show to the public
  `graceperiod` int(11) NOT NULL default '0', -- grace period in days
  `enddate` date default NULL, -- subscription end date
  `closed` TINYINT(1) NOT NULL DEFAULT 0, -- yes / no if the subscription is closed
  `reneweddate` date default NULL, -- date of last renewal for the subscription
  `itemtype` VARCHAR( 10 ) NULL,
  `previousitemtype` VARCHAR( 10 ) NULL,
  `mana_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY  (`subscriptionid`),
  CONSTRAINT subscription_ibfk_1 FOREIGN KEY (periodicity) REFERENCES subscription_frequencies (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT subscription_ibfk_2 FOREIGN KEY (numberpattern) REFERENCES subscription_numberpatterns (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT subscription_ibfk_3 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `serial`
--

DROP TABLE IF EXISTS `serial`;
CREATE TABLE `serial` ( -- issues related to subscriptions
  `serialid` int(11) NOT NULL auto_increment, -- unique key for the issue
  `biblionumber` int(11) NOT NULL, -- foreign key for the biblio.biblionumber that this issue is attached to
  `subscriptionid` int(11) NOT NULL, -- foreign key to the subscription.subscriptionid that this issue is part of
  `serialseq` varchar(100) NOT NULL default '', -- issue information (volume, number, etc)
  `serialseq_x` varchar( 100 ) NULL DEFAULT NULL, -- first part of issue information
  `serialseq_y` varchar( 100 ) NULL DEFAULT NULL, -- second part of issue information
  `serialseq_z` varchar( 100 ) NULL DEFAULT NULL, -- third part of issue information
  `status` tinyint(4) NOT NULL default 0, -- status code for this issue (see manual for full descriptions)
  `planneddate` date default NULL, -- date expected
  `notes` MEDIUMTEXT, -- notes
  `publisheddate` date default NULL, -- date published
  publisheddatetext varchar(100) default NULL, -- date published (descriptive)
  `claimdate` date default NULL, -- date claimed
  claims_count int(11) default 0, -- number of claims made related to this issue
  `routingnotes` MEDIUMTEXT, -- notes from the routing list
  PRIMARY KEY (`serialid`),
  CONSTRAINT serial_ibfk_1 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT serial_ibfk_2 FOREIGN KEY (subscriptionid) REFERENCES subscription (subscriptionid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `subscriptionhistory`
--

DROP TABLE IF EXISTS `subscriptionhistory`;
CREATE TABLE `subscriptionhistory` (
  `biblionumber` int(11) NOT NULL,
  `subscriptionid` int(11) NOT NULL,
  `histstartdate` date default NULL,
  `histenddate` date default NULL,
  `missinglist` LONGTEXT NOT NULL,
  `recievedlist` LONGTEXT NOT NULL,
  `opacnote` LONGTEXT NULL,
  `librariannote` LONGTEXT NULL,
  PRIMARY KEY  (`subscriptionid`),
  CONSTRAINT subscription_history_ibfk_1 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT subscription_history_ibfk_2 FOREIGN KEY (subscriptionid) REFERENCES subscription (subscriptionid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `subscriptionroutinglist`
--

DROP TABLE IF EXISTS `subscriptionroutinglist`;
CREATE TABLE `subscriptionroutinglist` ( -- information related to the routing lists attached to subscriptions
  `routingid` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `borrowernumber` int(11) NOT NULL, -- foreign key from the borrowers table, defines with patron is on the routing list
  `ranking` int(11) default NULL, -- where the patron stands in line to receive the serial
  `subscriptionid` int(11) NOT NULL, -- foreign key from the subscription table, defines which subscription this routing list is for
  PRIMARY KEY  (`routingid`),
  UNIQUE (`subscriptionid`, `borrowernumber`),
  CONSTRAINT `subscriptionroutinglist_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `subscriptionroutinglist_ibfk_2` FOREIGN KEY (`subscriptionid`) REFERENCES `subscription` (`subscriptionid`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `systempreferences`
--

DROP TABLE IF EXISTS `systempreferences`;
CREATE TABLE `systempreferences` ( -- global system preferences
  `variable` varchar(50) NOT NULL default '', -- system preference name
  `value` MEDIUMTEXT, -- system preference values
  `options` LONGTEXT, -- options for multiple choice system preferences
  `explanation` MEDIUMTEXT, -- descriptive text for the system preference
  `type` varchar(20) default NULL, -- type of question this preference asks (multiple choice, plain text, yes or no, etc)
  PRIMARY KEY  (`variable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `entry` varchar(255) NOT NULL default '',
  `weight` bigint(20) NOT NULL default 0,
  PRIMARY KEY  (`entry` (191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `tags_all`
--

DROP TABLE IF EXISTS `tags_all`;
CREATE TABLE `tags_all` ( -- all of the tags
  `tag_id`         int(11) NOT NULL auto_increment, -- unique id and primary key
  `borrowernumber` int(11) DEFAULT NULL, -- the patron who added the tag (borrowers.borrowernumber)
  `biblionumber`   int(11) NOT NULL, -- the bib record this tag was left on (biblio.biblionumber)
  `term`      varchar(191) NOT NULL COLLATE utf8mb4_bin, -- the tag
  `language`       int(4) default NULL, -- the language the tag was left in
  `date_created` datetime  NOT NULL, -- the date the tag was added
  PRIMARY KEY  (`tag_id`),
  KEY `tags_borrowers_fk_1` (`borrowernumber`),
  KEY `tags_biblionumber_fk_1` (`biblionumber`),
  CONSTRAINT `tags_borrowers_fk_1` FOREIGN KEY (`borrowernumber`)
        REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `tags_biblionumber_fk_1` FOREIGN KEY (`biblionumber`)
        REFERENCES `biblio`     (`biblionumber`)  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `tags_approval`
--

DROP TABLE IF EXISTS `tags_approval`;
CREATE TABLE `tags_approval` ( -- approved tags
  `term`   varchar(191) NOT NULL COLLATE utf8mb4_bin, -- the tag
  `approved`     int(1) NOT NULL default '0', -- whether the tag is approved or not (1=yes, 0=pending, -1=rejected)
  `date_approved` datetime       default NULL, -- the date this tag was approved
  `approved_by` int(11)          default NULL, -- the librarian who approved the tag (borrowers.borrowernumber)
  `weight_total` int(9) NOT NULL default '1', -- the total number of times this tag was used
  PRIMARY KEY  (`term`),
  KEY `tags_approval_borrowers_fk_1` (`approved_by`),
  CONSTRAINT `tags_approval_borrowers_fk_1` FOREIGN KEY (`approved_by`)
        REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `tags_index`
--

DROP TABLE IF EXISTS `tags_index`;
CREATE TABLE `tags_index` ( -- a weighted list of all tags and where they are used
  `term`    varchar(191) NOT NULL COLLATE utf8mb4_bin, -- the tag
  `biblionumber` int(11) NOT NULL, -- the bib record this tag was used on (biblio.biblionumber)
  `weight`        int(9) NOT NULL default '1', -- the number of times this term was used on this bib record
  PRIMARY KEY  (`term`,`biblionumber`),
  KEY `tags_index_biblionumber_fk_1` (`biblionumber`),
  CONSTRAINT `tags_index_term_fk_1` FOREIGN KEY (`term`)
        REFERENCES `tags_approval` (`term`)  ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tags_index_biblionumber_fk_1` FOREIGN KEY (`biblionumber`)
        REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `virtualshelves`
--

DROP TABLE IF EXISTS `virtualshelves`;
CREATE TABLE `virtualshelves` ( -- information about lists (or virtual shelves)
  `shelfnumber` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `shelfname` varchar(255) default NULL, -- name of the list
  `owner` int default NULL, -- foreign key linking to the borrowers table (using borrowernumber) for the creator of this list (changed from varchar(80) to int)
  `category` varchar(1) default NULL, -- type of list (private [1], public [2])
  `sortfield` varchar(16) default 'title', -- the field this list is sorted on
  `lastmodified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time the list was last modified
  `created_on` datetime NOT NULL, -- creation time
  `allow_change_from_owner` tinyint(1) default 1, -- can owner change contents?
  `allow_change_from_others` tinyint(1) default 0, -- can others change contents?
  PRIMARY KEY  (`shelfnumber`),
  CONSTRAINT `virtualshelves_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL -- no cascaded delete, please see HandleDelBorrower in Members.pm
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `virtualshelfcontents`
--

DROP TABLE IF EXISTS `virtualshelfcontents`;
CREATE TABLE `virtualshelfcontents` ( -- information about the titles in a list (or virtual shelf)
  `shelfnumber` int(11) NOT NULL default 0, -- foreign key linking to the virtualshelves table, defines the list that this record has been added to
  `biblionumber` int(11) NOT NULL default 0, -- foreign key linking to the biblio table, defines the bib record that has been added to the list
  `flags` int(11) default NULL,
  `dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- date and time this bib record was added to the list
  `borrowernumber` int, -- borrower number that created this list entry (only the first one is saved: no need for use in/as key)
  KEY `shelfnumber` (`shelfnumber`),
  KEY `biblionumber` (`biblionumber`),
  CONSTRAINT `virtualshelfcontents_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `virtualshelves` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `shelfcontents_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `shelfcontents_ibfk_3` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL -- no cascaded delete, please see HandleDelBorrower in Members.pm
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `virtualshelfshares`
--

DROP TABLE IF EXISTS `virtualshelfshares`;
CREATE TABLE `virtualshelfshares` ( -- shared private lists
  `id` int AUTO_INCREMENT PRIMARY KEY,  -- unique key
  `shelfnumber` int NOT NULL,  -- foreign key for virtualshelves
  `borrowernumber` int,  -- borrower that accepted access to this list
  `invitekey` varchar(10), -- temporary string used in accepting the invitation to access thist list; not-empty means that the invitation has not been accepted yet
  `sharedate` datetime,  -- date of invitation or acceptance of invitation
  CONSTRAINT `virtualshelfshares_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `virtualshelves` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `virtualshelfshares_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL -- no cascaded delete, please see HandleDelBorrower in Members.pm
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `z3950servers`
--

DROP TABLE IF EXISTS `z3950servers`;
CREATE TABLE `z3950servers` ( -- connection information for the Z39.50 targets used in cataloging
  `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `host` varchar(255) default NULL, -- target's host name
  `port` int(11) default NULL, -- port number used to connect to target
  `db` varchar(255) default NULL, -- target's database name
  `userid` varchar(255) default NULL, -- username needed to log in to target
  `password` varchar(255) default NULL, -- password needed to log in to target
  `servername` LONGTEXT NOT NULL, -- name given to the target by the library
  `checked` smallint(6) default NULL, -- whether this target is checked by default  (1 for yes, 0 for no)
  `rank` int(11) default NULL, -- where this target appears in the list of targets
  `syntax` varchar(80) default NULL, -- marc format provided by this target
  `timeout` int(11) NOT NULL DEFAULT '0', -- number of seconds before Koha stops trying to access this server
  `servertype` enum('zed','sru') NOT NULL default 'zed', -- zed means z39.50 server
  `encoding` MEDIUMTEXT default NULL, -- characters encoding provided by this target
  `recordtype` enum('authority','biblio') NOT NULL default 'biblio', -- server contains bibliographic or authority records
  `sru_options` varchar(255) default NULL, -- options like sru=get, sru_version=1.1; will be passed to the server via ZOOM
  `sru_fields` LONGTEXT default NULL, -- contains the mapping between the Z3950 search fields and the specific SRU server indexes
  `add_xslt` LONGTEXT default NULL, -- zero or more paths to XSLT files to be processed on the search results
  `attributes` VARCHAR(255) default NULL, -- additional attributes passed to PQF queries
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `zebraqueue`
--

DROP TABLE IF EXISTS `zebraqueue`;
CREATE TABLE `zebraqueue` (
  `id` int(11) NOT NULL auto_increment,
  `biblio_auth_number` bigint(20) unsigned NOT NULL default '0',
  `operation` char(20) NOT NULL default '',
  `server` char(20) NOT NULL default '',
  `done` int(11) NOT NULL default '0',
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `zebraqueue_lookup` (`server`, `biblio_auth_number`, `operation`, `done`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `language_subtag_registry`
-- http://www.w3.org/International/articles/language-tags/
-- RFC4646
--

DROP TABLE IF EXISTS language_subtag_registry;
CREATE TABLE language_subtag_registry (
        subtag varchar(25),
        type varchar(25), -- language-script-region-variant-extension-privateuse
        description varchar(25), -- only one of the possible descriptions for ease of reference, see language_descriptions for the complete list
        added date,
        id int(11) NOT NULL auto_increment,
        PRIMARY KEY  (`id`),
        KEY `subtag` (`subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `language_rfc4646_to_iso639`
-- TODO: add suppress_scripts
-- this maps three letter codes defined in iso639.2 back to their
-- two letter equivilents in rfc4646 (LOC maintains iso639+)
--

DROP TABLE IF EXISTS language_rfc4646_to_iso639;
CREATE TABLE language_rfc4646_to_iso639 (
        rfc4646_subtag varchar(25),
        iso639_2_code varchar(25),
        id int(11) NOT NULL auto_increment,
        PRIMARY KEY  (`id`),
        KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `language_descriptions`
--

DROP TABLE IF EXISTS language_descriptions;
CREATE TABLE language_descriptions (
        subtag varchar(25),
        type varchar(25),
        lang varchar(25),
        description varchar(255),
        id int(11) NOT NULL auto_increment,
        PRIMARY KEY  (`id`),
        KEY `lang` (`lang`),
        KEY `subtag_type_lang` (`subtag`, `type`, `lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `language_script_bidi`
-- bi-directional support, keyed by script subcode
--

DROP TABLE IF EXISTS language_script_bidi;
CREATE TABLE language_script_bidi (
        rfc4646_subtag varchar(25), -- script subtag, Arab, Hebr, etc.
        bidi varchar(3), -- rtl ltr
        KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `language_script_mapping`
-- TODO: need to map language subtags to script subtags for detection
-- of bidi when script is not specified (like ar, he)
--

DROP TABLE IF EXISTS language_script_mapping;
CREATE TABLE language_script_mapping (
        language_subtag varchar(25),
        script_subtag varchar(25),
        KEY `language_subtag` (`language_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `module_bit` int(11) NOT NULL DEFAULT 0,
  `code` varchar(64) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY  (`module_bit`, `code`),
  CONSTRAINT `permissions_ibfk_1` FOREIGN KEY (`module_bit`) REFERENCES `userflags` (`bit`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `serialitems`
--

DROP TABLE IF EXISTS `serialitems`;
CREATE TABLE `serialitems` (
	`itemnumber` int(11) NOT NULL,
	`serialid` int(11) NOT NULL,
    PRIMARY KEY (`itemnumber`),
	KEY `serialitems_sfk_1` (`serialid`),
	CONSTRAINT `serialitems_sfk_1` FOREIGN KEY (`serialid`) REFERENCES `serial` (`serialid`) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT `serialitems_sfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
CREATE TABLE `user_permissions` (
  `borrowernumber` int(11) NOT NULL DEFAULT 0,
  `module_bit` int(11) NOT NULL DEFAULT 0,
  `code` varchar(64) DEFAULT NULL,
  CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_permissions_ibfk_2` FOREIGN KEY (`module_bit`, `code`) REFERENCES `permissions` (`module_bit`, `code`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `tmp_holdsqueue`
--

DROP TABLE IF EXISTS `tmp_holdsqueue`;
CREATE TABLE `tmp_holdsqueue` (
  `biblionumber` int(11) default NULL,
  `itemnumber` int(11) default NULL,
  `barcode` varchar(20) default NULL,
  `surname` LONGTEXT NOT NULL,
  `firstname` MEDIUMTEXT,
  `phone` MEDIUMTEXT,
  `borrowernumber` int(11) NOT NULL,
  `cardnumber` varchar(32) default NULL,
  `reservedate` date default NULL,
  `title` LONGTEXT,
  `itemcallnumber` varchar(255) default NULL,
  `holdingbranch` varchar(10) default NULL,
  `pickbranch` varchar(10) default NULL,
  `notes` MEDIUMTEXT,
  `item_level_request` tinyint(4) NOT NULL default 0,
  CONSTRAINT `tmp_holdsqueue_ibfk_1` FOREIGN KEY (`itemnumber`)
    REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `message_transport_types`
--

DROP TABLE IF EXISTS `message_transport_types`;
CREATE TABLE `message_transport_types` (
  `message_transport_type` varchar(20) NOT NULL,
  PRIMARY KEY  (`message_transport_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `message_queue`
--

DROP TABLE IF EXISTS `message_queue`;
CREATE TABLE `message_queue` (
  `message_id` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `subject` MEDIUMTEXT,
  `content` MEDIUMTEXT,
  `metadata` MEDIUMTEXT DEFAULT NULL,
  `letter_code` varchar(64) DEFAULT NULL,
  `message_transport_type` varchar(20) NOT NULL,
  `status` enum('sent','pending','failed','deleted') NOT NULL default 'pending',
  `time_queued` timestamp NULL,
  `updated_on` timestamp NOT NULL default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `to_address` LONGTEXT,
  `from_address` LONGTEXT,
  `reply_address` LONGTEXT,
  `content_type` MEDIUMTEXT,
  PRIMARY KEY `message_id` (`message_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `message_transport_type` (`message_transport_type`),
  CONSTRAINT `messageq_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `messageq_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `letter`
--

DROP TABLE IF EXISTS `letter`;
CREATE TABLE `letter` ( -- table for all notice templates in Koha
  `module` varchar(20) NOT NULL default '', -- Koha module that triggers this notice or slip
  `code` varchar(20) NOT NULL default '', -- unique identifier for this notice or slip
  `branchcode` varchar(10) NOT NULL default '', -- the branch this notice or slip is used at (branches.branchcode)
  `name` varchar(100) NOT NULL default '', -- plain text name for this notice or slip
  `is_html` tinyint(1) default 0, -- does this notice or slip use HTML (1 for yes, 0 for no)
  `title` varchar(200) NOT NULL default '', -- subject line of the notice
  `content` MEDIUMTEXT, -- body text for the notice or slip
  `message_transport_type` varchar(20) NOT NULL DEFAULT 'email', -- transport type for this notice
  `lang` varchar(25) NOT NULL DEFAULT 'default', -- lang of the notice
  PRIMARY KEY  (`module`,`code`, `branchcode`, `message_transport_type`, `lang`),
  CONSTRAINT `message_transport_type_fk` FOREIGN KEY (`message_transport_type`)
  REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `overduerules_transport_types`
--

DROP TABLE IF EXISTS `overduerules_transport_types`;
CREATE TABLE overduerules_transport_types(
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `letternumber` INT(1) NOT NULL DEFAULT 1,
    `message_transport_type` VARCHAR(20) NOT NULL DEFAULT 'email',
    `overduerules_id` INT(11) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT overduerules_fk FOREIGN KEY (overduerules_id) REFERENCES overduerules (overduerules_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT mtt_fk FOREIGN KEY (message_transport_type) REFERENCES message_transport_types (message_transport_type) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `message_attributes`
--

DROP TABLE IF EXISTS `message_attributes`;
CREATE TABLE `message_attributes` (
  `message_attribute_id` int(11) NOT NULL auto_increment,
  `message_name` varchar(40) NOT NULL default '',
  `takes_days` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`message_attribute_id`),
  UNIQUE KEY `message_name` (`message_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `message_transports`
--

DROP TABLE IF EXISTS `message_transports`;
CREATE TABLE `message_transports` (
  `message_attribute_id` int(11) NOT NULL,
  `message_transport_type` varchar(20) NOT NULL,
  `is_digest` tinyint(1) NOT NULL default '0',
  `letter_module` varchar(20) NOT NULL default '',
  `letter_code` varchar(20) NOT NULL default '',
  `branchcode` varchar(10) NOT NULL default '',
  PRIMARY KEY  (`message_attribute_id`,`message_transport_type`,`is_digest`),
  KEY `message_transport_type` (`message_transport_type`),
  KEY `letter_module` (`letter_module`,`letter_code`),
  CONSTRAINT `message_transports_ibfk_1` FOREIGN KEY (`message_attribute_id`) REFERENCES `message_attributes` (`message_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_transports_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrower_files`
--

DROP TABLE IF EXISTS `borrower_files`;
CREATE TABLE IF NOT EXISTS `borrower_files` ( -- files attached to the patron/borrower record
  `file_id` int(11) NOT NULL AUTO_INCREMENT, -- unique key
  `borrowernumber` int(11) NOT NULL, -- foreign key linking to the patron via the borrowernumber
  `file_name` varchar(255) NOT NULL, -- file name
  `file_type` varchar(255) NOT NULL, -- type of file
  `file_description` varchar(255) DEFAULT NULL, -- description given to the file
  `file_content` longblob NOT NULL, -- the file
  `date_uploaded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, -- date and time the file was added
  PRIMARY KEY (`file_id`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT borrower_files_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrower_message_preferences`
--

DROP TABLE IF EXISTS `borrower_message_preferences`;
CREATE TABLE `borrower_message_preferences` (
  `borrower_message_preference_id` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `categorycode` varchar(10) default NULL,
  `message_attribute_id` int(11) default '0',
  `days_in_advance` int(11) default '0',
  `wants_digest` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`borrower_message_preference_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `categorycode` (`categorycode`),
  KEY `message_attribute_id` (`message_attribute_id`),
  CONSTRAINT `borrower_message_preferences_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_preferences_ibfk_2` FOREIGN KEY (`message_attribute_id`) REFERENCES `message_attributes` (`message_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_preferences_ibfk_3` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrower_message_transport_preferences`
--

DROP TABLE IF EXISTS `borrower_message_transport_preferences`;
CREATE TABLE `borrower_message_transport_preferences` (
  `borrower_message_preference_id` int(11) NOT NULL default '0',
  `message_transport_type` varchar(20) NOT NULL default '0',
  PRIMARY KEY  (`borrower_message_preference_id`,`message_transport_type`),
  KEY `message_transport_type` (`message_transport_type`),
  CONSTRAINT `borrower_message_transport_preferences_ibfk_1` FOREIGN KEY (`borrower_message_preference_id`) REFERENCES `borrower_message_preferences` (`borrower_message_preference_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_transport_preferences_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for the table branch_transfer_limits
--

DROP TABLE IF EXISTS `branch_transfer_limits`;
CREATE TABLE branch_transfer_limits (
    limitId int(8) NOT NULL auto_increment,
    toBranch varchar(10) NOT NULL,
    fromBranch varchar(10) NOT NULL,
    itemtype varchar(10) NULL,
    ccode varchar(80) NULL,
    PRIMARY KEY  (limitId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `item_circulation_alert_preferences`
--

DROP TABLE IF EXISTS `item_circulation_alert_preferences`;
CREATE TABLE `item_circulation_alert_preferences` (
  `id` int(11) NOT NULL auto_increment,
  `branchcode` varchar(10) NOT NULL,
  `categorycode` varchar(10) NOT NULL,
  `item_type` varchar(10) NOT NULL,
  `notification` varchar(16) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `branchcode` (`branchcode`,`categorycode`,`item_type`, `notification`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `messages`
--
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` ( -- circulation messages left via the patron's check out screen
  `message_id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `borrowernumber` int(11) NOT NULL, -- foreign key linking this message to the borrowers table
  `branchcode` varchar(10) default NULL, -- foreign key linking the message to the branches table
  `message_type` varchar(1) NOT NULL, -- whether the message is for the librarians (L) or the patron (B)
  `message` MEDIUMTEXT NOT NULL, -- the text of the message
  `message_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- the date and time the message was written
  `manager_id` int(11) default NULL, -- creator of message
  PRIMARY KEY (`message_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL,
  CONSTRAINT `messages_borrowernumber` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `cash_registers`
--

DROP TABLE IF EXISTS `cash_registers`;
CREATE TABLE `cash_registers` (
  `id` int(11) NOT NULL auto_increment, -- unique identifier for each account register
  `name` varchar(24) NOT NULL, -- the user friendly identifier for each account register
  `description` longtext NOT NULL, -- the user friendly description for each account register
  `branch` varchar(10) NOT NULL, -- the foreign key the library this account register belongs
  `branch_default` tinyint(1) NOT NULL DEFAULT 0, -- boolean flag to denote that this till is the branch default
  `starting_float` decimal(28, 6), -- the starting float this account register should be assigned
  `archived` tinyint(1) NOT NULL DEFAULT 0, -- boolean flag to denote if this till is archived or not
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`branch`),
  CONSTRAINT cash_registers_branch FOREIGN KEY (branch) REFERENCES branches (branchcode) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

--
-- Table structure for table `account_credit_types`
--

DROP TABLE IF EXISTS `account_credit_types`;
CREATE TABLE `account_credit_types` (
  `code` varchar(80) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `can_be_added_manually` tinyint(4) NOT NULL DEFAULT 1,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `archived` tinyint(1) NOT NULL DEFAULT 0, -- boolean flag to denote if this till is archived or not
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `account_credit_types_branches`
--

DROP TABLE IF EXISTS `account_credit_types_branches`;
CREATE TABLE `account_credit_types_branches` (
    `credit_type_code` VARCHAR(80),
    `branchcode` VARCHAR(10),
    FOREIGN KEY (`credit_type_code`) REFERENCES `account_credit_types` (`code`) ON DELETE CASCADE,
    FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `account_debit_types`
--

DROP TABLE IF EXISTS `account_debit_types`;
CREATE TABLE `account_debit_types` (
  `code` varchar(80) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `can_be_invoiced` tinyint(1) NOT NULL DEFAULT 1, -- boolean flag to denote if this debit type is available for manual invoicing
  `can_be_sold` tinyint(1) NOT NULL DEFAULT 0, -- boolean flag to denote if this debit type is available at point of sale
  `default_amount` decimal(28,6) DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `archived` tinyint(1) NOT NULL DEFAULT 0, -- boolean flag to denote if this till is archived or not
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `account_debit_types_branches`
--

DROP TABLE IF EXISTS `account_debit_types_branches`;
CREATE TABLE `account_debit_types_branches` (
    `debit_type_code` VARCHAR(80),
    `branchcode` VARCHAR(10),
    FOREIGN KEY (`debit_type_code`) REFERENCES `account_debit_types` (`code`) ON DELETE CASCADE,
    FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `accountlines`
--

DROP TABLE IF EXISTS `accountlines`;
CREATE TABLE `accountlines` (
  `accountlines_id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_id` int(11) NULL DEFAULT NULL,
  `borrowernumber` int(11) DEFAULT NULL,
  `itemnumber` int(11) default NULL,
  `date` timestamp NULL,
  `amount` decimal(28,6) default NULL,
  `description` LONGTEXT,
  `credit_type_code` varchar(80) default NULL,
  `debit_type_code` varchar(80) default NULL,
  `status` varchar(16) default NULL,
  `payment_type` varchar(80) default NULL, -- optional authorised value PAYMENT_TYPE
  `amountoutstanding` decimal(28,6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `note` MEDIUMTEXT NULL default NULL,
  `manager_id` int(11) NULL DEFAULT NULL,
  `register_id` int(11) NULL DEFAULT NULL,
  `interface` VARCHAR(16) NOT NULL,
  `branchcode` VARCHAR( 10 ) NULL DEFAULT NULL, -- the branchcode of the library where a payment was made, a manual invoice created, etc.
  PRIMARY KEY (`accountlines_id`),
  KEY `acctsborridx` (`borrowernumber`),
  KEY `timeidx` (`timestamp`),
  KEY `credit_type_code` (`credit_type_code`),
  KEY `debit_type_code` (`debit_type_code`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  KEY `manager_id` (`manager_id`),
  CONSTRAINT `accountlines_ibfk_borrowers` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_items` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_borrowers_2` FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_branches` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_registers` FOREIGN KEY (`register_id`) REFERENCES `cash_registers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_credit_type` FOREIGN KEY (`credit_type_code`) REFERENCES `account_credit_types` (`code`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_debit_type` FOREIGN KEY (`debit_type_code`) REFERENCES `account_debit_types` (`code`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `account_offset_types`
--

DROP TABLE IF EXISTS `account_offset_types`;
CREATE TABLE `account_offset_types` (
  `type` varchar(16) NOT NULL, -- The type of offset this is
  PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `account_offsets`
--

DROP TABLE IF EXISTS `account_offsets`;
CREATE TABLE `account_offsets` (
  `id` int(11) NOT NULL auto_increment, -- unique identifier for each offset
  `credit_id` int(11) NULL DEFAULT NULL, -- The id of the accountline the increased the patron's balance
  `debit_id` int(11) NULL DEFAULT NULL, -- The id of the accountline that decreased the patron's balance
  `type` varchar(16) NOT NULL, -- The type of offset this is
  `amount` decimal(26,6) NOT NULL, -- The amount of the change
  `created_on` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `account_offsets_ibfk_p` FOREIGN KEY (`credit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_offsets_ibfk_f` FOREIGN KEY (`debit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_offsets_ibfk_t` FOREIGN KEY (`type`) REFERENCES `account_offset_types` (`type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `cash_register_actions`
--

DROP TABLE IF EXISTS `cash_register_actions`;
CREATE TABLE `cash_register_actions` (
  `id` int(11) NOT NULL auto_increment, -- unique identifier for each account register action
  `code` varchar(24) NOT NULL, -- action code denoting the type of action recorded (enum),
  `register_id` int(11) NOT NULL, -- id of cash_register this action belongs to,
  `manager_id` int(11) NOT NULL, -- staff member performing the action
  `amount` decimal(28,6) DEFAULT NULL, -- amount recorded in action (signed)
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `cash_register_actions_manager` FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `cash_register_actions_register` FOREIGN KEY (`register_id`) REFERENCES `cash_registers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

--
-- Table structure for table `action_logs`
--

DROP TABLE IF EXISTS `action_logs`;
CREATE TABLE `action_logs` ( -- logs of actions taken in Koha (requires that the logs be turned on)
  `action_id` int(11) NOT NULL auto_increment, -- unique identifier for each action
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP, -- the date and time the action took place
  `user` int(11) NOT NULL default 0, -- the staff member who performed the action (borrowers.borrowernumber)
  `module` MEDIUMTEXT, -- the module this action was taken against
  `action` MEDIUMTEXT, -- the action (includes things like DELETED, ADDED, MODIFY, etc)
  `object` int(11) default NULL, -- the object that the action was taken against (could be a borrowernumber, itemnumber, etc)
  `info` MEDIUMTEXT, -- information about the action (usually includes SQL statement)
  `interface` VARCHAR(30) DEFAULT NULL, -- the context this action was taken in
  PRIMARY KEY (`action_id`),
  KEY `timestamp_idx` (`timestamp`),
  KEY `user_idx` (`user`),
  KEY `module_idx` (`module`(255)),
  KEY `action_idx` (`action`(255)),
  KEY `object_idx` (`object`),
  KEY `info_idx` (`info`(255)),
  KEY `interface` (`interface`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `aqbooksellers`
--

DROP TABLE IF EXISTS `aqbooksellers`;
CREATE TABLE `aqbooksellers` ( -- information about the vendors listed in acquisitions
  `id` int(11) NOT NULL auto_increment, -- primary key and unique identifier assigned by Koha
  `name` LONGTEXT NOT NULL, -- vendor name
  `address1` LONGTEXT, -- first line of vendor physical address
  `address2` LONGTEXT, -- second line of vendor physical address
  `address3` LONGTEXT, -- third line of vendor physical address
  `address4` LONGTEXT, -- fourth line of vendor physical address
  `phone` varchar(30) default NULL, -- vendor phone number
  `accountnumber` LONGTEXT, -- vendor account number
  `notes` LONGTEXT, -- order notes
  `postal` LONGTEXT, -- vendor postal address (all lines)
  `url` varchar(255) default NULL, -- vendor web address
  `active` tinyint(4) default NULL, -- is this vendor active (1 for yes, 0 for no)
  `listprice` varchar(10) default NULL, -- currency code for list prices
  `invoiceprice` varchar(10) default NULL, -- currency code for invoice prices
  `gstreg` tinyint(4) default NULL, -- is your library charged tax (1 for yes, 0 for no)
  `listincgst` tinyint(4) default NULL, -- is tax included in list prices (1 for yes, 0 for no)
  `invoiceincgst` tinyint(4) default NULL, -- is tax included in invoice prices (1 for yes, 0 for no)
  `tax_rate` decimal(6,4) default NULL, -- the tax rate the library is charged
  `discount` float(6,4) default NULL, -- discount offered on all items ordered from this vendor
  `fax` varchar(50) default NULL, -- vendor fax number
  deliverytime int(11) default NULL, -- vendor delivery time
  PRIMARY KEY  (`id`),
  KEY `listprice` (`listprice`),
  KEY `invoiceprice` (`invoiceprice`),
  KEY `name` (`name`(255)),
  CONSTRAINT `aqbooksellers_ibfk_1` FOREIGN KEY (`listprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqbooksellers_ibfk_2` FOREIGN KEY (`invoiceprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `aqbasketgroups`
--

DROP TABLE IF EXISTS `aqbasketgroups`;
CREATE TABLE `aqbasketgroups` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `closed` tinyint(1) default NULL,
  `booksellerid` int(11) NOT NULL,
  `deliveryplace` varchar(10) default NULL,
  `freedeliveryplace` MEDIUMTEXT default NULL,
  `deliverycomment` varchar(255) default NULL,
  `billingplace` varchar(10) default NULL,
  PRIMARY KEY  (`id`),
  KEY `booksellerid` (`booksellerid`),
  CONSTRAINT `aqbasketgroups_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `aqbudgets`
--

DROP TABLE IF EXISTS `aqbudgets`;
CREATE TABLE `aqbudgets` ( -- information related to Funds
  `budget_id` int(11) NOT NULL auto_increment, -- primary key and unique number assigned to each fund by Koha
  `budget_parent_id` int(11) default NULL, -- if this fund is a child of another this will include the parent id (aqbudgets.budget_id)
  `budget_code` varchar(30) default NULL, -- code assigned to the fund by the user
  `budget_name` varchar(80) default NULL, -- name assigned to the fund by the user
  `budget_branchcode` varchar(10) default NULL, -- branch that this fund belongs to (branches.branchcode)
  `budget_amount` decimal(28,6) NULL default '0.00', -- total amount for this fund
  `budget_encumb` decimal(28,6) NULL default '0.00', -- budget warning at percentage
  `budget_expend` decimal(28,6) NULL default '0.00', -- budget warning at amount
  `budget_notes` LONGTEXT, -- notes related to this fund
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this fund was last touched (created or modified)
  `budget_period_id` int(11) default NULL, -- id of the budget that this fund belongs to (aqbudgetperiods.budget_period_id)
  `sort1_authcat` varchar(80) default NULL, -- statistical category for this fund
  `sort2_authcat` varchar(80) default NULL, -- second statistical category for this fund
  `budget_owner_id` int(11) default NULL, -- borrowernumber of the person who owns this fund (borrowers.borrowernumber)
  `budget_permission` int(1) default '0', -- level of permission for this fund (used only by the owner, only by the library, or anyone)
  PRIMARY KEY  (`budget_id`),
  KEY `budget_parent_id` (`budget_parent_id`),
  KEY `budget_code` (`budget_code`),
  KEY `budget_branchcode` (`budget_branchcode`),
  KEY `budget_period_id` (`budget_period_id`),
  KEY `budget_owner_id` (`budget_owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table aqbudgetborrowers
--

DROP TABLE IF EXISTS aqbudgetborrowers;
CREATE TABLE aqbudgetborrowers (
  budget_id int(11) NOT NULL,
  borrowernumber int(11) NOT NULL,
  PRIMARY KEY (budget_id, borrowernumber),
  CONSTRAINT aqbudgetborrowers_ibfk_1 FOREIGN KEY (budget_id)
    REFERENCES aqbudgets (budget_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT aqbudgetborrowers_ibfk_2 FOREIGN KEY (borrowernumber)
    REFERENCES borrowers (borrowernumber)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `aqbudgetperiods`
--


DROP TABLE IF EXISTS `aqbudgetperiods`;
CREATE TABLE `aqbudgetperiods` ( -- information related to Budgets
  `budget_period_id` int(11) NOT NULL auto_increment, -- primary key and unique number assigned by Koha
  `budget_period_startdate` date NOT NULL, -- date when the budget starts
  `budget_period_enddate` date NOT NULL, -- date when the budget ends
  `budget_period_active` tinyint(1) default '0', -- whether this budget is active or not (1 for yes, 0 for no)
  `budget_period_description` LONGTEXT, -- description assigned to this budget
  `budget_period_total` decimal(28,6), -- total amount available in this budget
  `budget_period_locked` tinyint(1) default NULL, -- whether this budget is locked or not (1 for yes, 0 for no)
  `sort1_authcat` varchar(10) default NULL, -- statistical category for this budget
  `sort2_authcat` varchar(10) default NULL, -- second statistical category for this budget
  PRIMARY KEY  (`budget_period_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `aqbudgets_planning`
--

DROP TABLE IF EXISTS `aqbudgets_planning`;
CREATE TABLE `aqbudgets_planning` (
  `plan_id` int(11) NOT NULL auto_increment,
  `budget_id` int(11) NOT NULL,
  `budget_period_id` int(11) NOT NULL,
  `estimated_amount` decimal(28,6) default NULL,
  `authcat` varchar(30) NOT NULL,
  `authvalue` varchar(30) NOT NULL,
  `display` tinyint(1) DEFAULT 1,
  PRIMARY KEY  (`plan_id`),
  KEY `budget_period_id` (`budget_period_id`),
  CONSTRAINT `aqbudgets_planning_ifbk_1` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'aqcontacts'
--

DROP TABLE IF EXISTS aqcontacts;
CREATE TABLE aqcontacts (
  id int(11) NOT NULL auto_increment, -- primary key and unique number assigned by Koha
  name varchar(100) default NULL, -- name of contact at vendor
  position varchar(100) default NULL, -- contact person's position
  phone varchar(100) default NULL, -- contact's phone number
  altphone varchar(100) default NULL, -- contact's alternate phone number
  fax varchar(100) default NULL,  -- contact's fax number
  email varchar(100) default NULL, -- contact's email address
  notes LONGTEXT, -- notes related to the contact
  orderacquisition tinyint(1) NOT NULL DEFAULT 0, -- should this contact receive acquisition orders
  claimacquisition tinyint(1) NOT NULL DEFAULT 0, -- should this contact receive acquisitions claims
  claimissues tinyint(1) NOT NULL DEFAULT 0, -- should this contact receive serial claims
  acqprimary tinyint(1) NOT NULL DEFAULT 0, -- is this the primary contact for acquisitions messages
  serialsprimary tinyint(1) NOT NULL DEFAULT 0, -- is this the primary contact for serials messages
  booksellerid int(11) not NULL,
  PRIMARY KEY  (id),
  CONSTRAINT booksellerid_aqcontacts_fk FOREIGN KEY (booksellerid)
       REFERENCES aqbooksellers (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1;

--
-- Table structure for table 'aqcontract'
--

DROP TABLE IF EXISTS `aqcontract`;
CREATE TABLE `aqcontract` (
  `contractnumber` int(11) NOT NULL auto_increment,
  `contractstartdate` date default NULL,
  `contractenddate` date default NULL,
  `contractname` varchar(50) default NULL,
  `contractdescription` LONGTEXT,
  `booksellerid` int(11) not NULL,
  PRIMARY KEY  (`contractnumber`),
  CONSTRAINT `booksellerid_fk1` FOREIGN KEY (`booksellerid`)
       REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

--
-- Table structure for table `aqbasket`
--

DROP TABLE IF EXISTS `aqbasket`;
CREATE TABLE `aqbasket` ( -- stores data about baskets in acquisitions
  `basketno` int(11) NOT NULL auto_increment, -- primary key, Koha defined number
  `basketname` varchar(50) default NULL, -- name given to the basket at creation
  `note` LONGTEXT, -- the internal note added at basket creation
  `booksellernote` LONGTEXT, -- the vendor note added at basket creation
  `contractnumber` int(11), -- links this basket to the aqcontract table (aqcontract.contractnumber)
  `creationdate` date default NULL, -- the date the basket was created
  `closedate` date default NULL, -- the date the basket was closed
  `booksellerid` int(11) NOT NULL default 1, -- the Koha assigned ID for the vendor (aqbooksellers.id)
  `authorisedby` varchar(10) default NULL, -- the borrowernumber of the person who created the basket
  `booksellerinvoicenumber` LONGTEXT, -- appears to always be NULL
  `basketgroupid` int(11), -- links this basket to its group (aqbasketgroups.id)
  `deliveryplace` varchar(10) default NULL, -- basket delivery place
  `billingplace` varchar(10) default NULL, -- basket billing place
  branch varchar(10) default NULL, -- basket branch
  is_standing TINYINT(1) NOT NULL DEFAULT 0, -- orders in this basket are standing
  create_items ENUM('ordering', 'receiving', 'cataloguing') default NULL, -- when items should be created for orders in this basket
  PRIMARY KEY  (`basketno`),
  KEY `booksellerid` (`booksellerid`),
  KEY `basketgroupid` (`basketgroupid`),
  KEY `contractnumber` (`contractnumber`),
  KEY `authorisedby` (`authorisedby`),
  CONSTRAINT `aqbasket_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `aqbasket_ibfk_2` FOREIGN KEY (`contractnumber`) REFERENCES `aqcontract` (`contractnumber`),
  CONSTRAINT `aqbasket_ibfk_3` FOREIGN KEY (`basketgroupid`) REFERENCES `aqbasketgroups` (`id`) ON UPDATE CASCADE,
  CONSTRAINT aqbasket_ibfk_4 FOREIGN KEY (branch) REFERENCES branches (branchcode) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table aqbasketusers
--

DROP TABLE IF EXISTS aqbasketusers;
CREATE TABLE aqbasketusers (
  basketno int(11) NOT NULL,
  borrowernumber int(11) NOT NULL,
  PRIMARY KEY (basketno,borrowernumber),
  CONSTRAINT aqbasketusers_ibfk_1 FOREIGN KEY (basketno) REFERENCES aqbasket (basketno) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT aqbasketusers_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `suggestions`
--

DROP TABLE IF EXISTS `suggestions`;
CREATE TABLE `suggestions` ( -- purchase suggestions
  `suggestionid` int(8) NOT NULL auto_increment, -- unique identifier assigned automatically by Koha
  `suggestedby` int(11) DEFAULT NULL, -- borrowernumber for the person making the suggestion, foreign key linking to the borrowers table
  `suggesteddate` date NOT NULL, -- date the suggestion was submitted
  `managedby` int(11) default NULL, -- borrowernumber for the librarian managing the suggestion, foreign key linking to the borrowers table
  `manageddate` date default NULL, -- date the suggestion was updated
   acceptedby INT(11) default NULL, -- borrowernumber for the librarian who accepted the suggestion, foreign key linking to the borrowers table
   accepteddate date default NULL, -- date the suggestion was marked as accepted
   rejectedby INT(11) default NULL, -- borrowernumber for the librarian who rejected the suggestion, foreign key linking to the borrowers table
   rejecteddate date default NULL, -- date the suggestion was marked as rejected
   lastmodificationby INT(11) default NULL, -- borrowernumber for the librarian who edit the suggestion for the last time
   lastmodificationdate date default NULL, -- date of the last modification
  `STATUS` varchar(10) NOT NULL default '', -- suggestion status (ASKED, CHECKED, ACCEPTED, REJECTED, ORDERED, AVAILABLE or a value from the SUGGEST_STATUS authorised value category)
  `archived` TINYINT(1) NOT NULL DEFAULT 0, -- is the suggestion archived?
  `note` LONGTEXT, -- note entered on the suggestion
  `author` varchar(80) default NULL, -- author of the suggested item
  `title` varchar(255) default NULL, -- title of the suggested item
  `copyrightdate` smallint(6) default NULL, -- copyright date of the suggested item
  `publishercode` varchar(255) default NULL, -- publisher of the suggested item
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  -- date and time the suggestion was updated
  `volumedesc` varchar(255) default NULL,
  `publicationyear` smallint(6) default 0,
  `place` varchar(255) default NULL, -- publication place of the suggested item
  `isbn` varchar(30) default NULL, -- isbn of the suggested item
  `biblionumber` int(11) default NULL, -- foreign key linking the suggestion to the biblio table after the suggestion has been ordered
  `reason` MEDIUMTEXT, -- reason for accepting or rejecting the suggestion
  `patronreason` MEDIUMTEXT, -- reason for making the suggestion
   budgetid INT(11), -- foreign key linking the suggested budget to the aqbudgets table
   branchcode VARCHAR(10) default NULL, -- foreign key linking the suggested branch to the branches table
   collectiontitle MEDIUMTEXT default NULL, -- collection name for the suggested item
   itemtype VARCHAR(30) default NULL, -- suggested item type
   quantity SMALLINT(6) default NULL, -- suggested quantity to be purchased
   currency VARCHAR(10) default NULL, -- suggested currency for the suggested price
   price DECIMAL(28,6) default NULL, -- suggested price
   total DECIMAL(28,6) default NULL, -- suggested total cost (price*quantity updated for currency)
  PRIMARY KEY  (`suggestionid`),
  KEY `suggestedby` (`suggestedby`),
  KEY `managedby` (`managedby`),
  KEY `acceptedby` (`acceptedby`),
  KEY `rejectedby` (`rejectedby`),
  KEY `biblionumber` (`biblionumber`),
  KEY `budgetid` (`budgetid`),
  KEY `branchcode` (`branchcode`),
  KEY `status` (`STATUS`),
  CONSTRAINT `suggestions_ibfk_suggestedby` FOREIGN KEY (`suggestedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_managedby` FOREIGN KEY (`managedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_acceptedby` FOREIGN KEY (`acceptedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_rejectedby` FOREIGN KEY (`rejectedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_lastmodificationby` FOREIGN KEY (`lastmodificationby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_biblionumber` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_budget_id_fk` FOREIGN KEY (`budgetid`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_branchcode` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table vendor_edi_accounts
--

DROP TABLE IF EXISTS vendor_edi_accounts;
CREATE TABLE IF NOT EXISTS vendor_edi_accounts (
  id INT(11) NOT NULL auto_increment,
  description MEDIUMTEXT NOT NULL,
  host VARCHAR(40),
  username VARCHAR(40),
  password VARCHAR(40),
  last_activity DATE,
  vendor_id INT(11) REFERENCES aqbooksellers( id ),
  download_directory MEDIUMTEXT,
  upload_directory MEDIUMTEXT,
  san VARCHAR(20),
  id_code_qualifier VARCHAR(3) default '14',
  transport VARCHAR(6) default 'FTP',
  quotes_enabled TINYINT(1) not null default 0,
  invoices_enabled TINYINT(1) not null default 0,
  orders_enabled TINYINT(1) not null default 0,
  responses_enabled TINYINT(1) not null default 0,
  auto_orders TINYINT(1) not null default 0,
  shipment_budget INTEGER(11) REFERENCES aqbudgets( budget_id ),
  plugin varchar(256) NOT NULL DEFAULT "",
  PRIMARY KEY  (id),
  KEY vendorid (vendor_id),
  KEY shipmentbudget (shipment_budget),
  CONSTRAINT vfk_vendor_id FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ),
  CONSTRAINT vfk_shipment_budget FOREIGN KEY ( shipment_budget ) REFERENCES aqbudgets ( budget_id )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table edifact_messages
--

DROP TABLE IF EXISTS edifact_messages;
CREATE TABLE IF NOT EXISTS edifact_messages (
  id INT(11) NOT NULL auto_increment,
  message_type VARCHAR(10) NOT NULL,
  transfer_date DATE,
  vendor_id INT(11) REFERENCES aqbooksellers( id ),
  edi_acct  INTEGER REFERENCES vendor_edi_accounts( id ),
  status MEDIUMTEXT,
  basketno INT(11) REFERENCES aqbasket( basketno),
  raw_msg LONGTEXT,
  filename MEDIUMTEXT,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY  (id),
  KEY vendorid ( vendor_id),
  KEY ediacct (edi_acct),
  KEY basketno ( basketno),
  CONSTRAINT emfk_vendor FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT emfk_edi_acct FOREIGN KEY ( edi_acct ) REFERENCES vendor_edi_accounts ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT emfk_basketno FOREIGN KEY ( basketno ) REFERENCES aqbasket ( basketno ) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table aqinvoices
--

DROP TABLE IF EXISTS aqinvoices;
CREATE TABLE aqinvoices (
  invoiceid int(11) NOT NULL AUTO_INCREMENT,    -- ID of the invoice, primary key
  invoicenumber LONGTEXT NOT NULL,    -- Name of invoice
  booksellerid int(11) NOT NULL,    -- foreign key to aqbooksellers
  shipmentdate date default NULL,   -- date of shipment
  billingdate date default NULL,    -- date of billing
  closedate date default NULL,  -- invoice close date, NULL means the invoice is open
  shipmentcost decimal(28,6) default NULL,  -- shipment cost
  shipmentcost_budgetid int(11) default NULL,   -- foreign key to aqbudgets, link the shipment cost to a budget
  message_id int(11) default NULL, -- foreign key to edifact invoice message
  PRIMARY KEY (invoiceid),
  CONSTRAINT aqinvoices_fk_aqbooksellerid FOREIGN KEY (booksellerid) REFERENCES aqbooksellers (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT edifact_msg_fk FOREIGN KEY ( message_id ) REFERENCES edifact_messages ( id ) ON DELETE SET NULL,
  CONSTRAINT aqinvoices_fk_shipmentcost_budgetid FOREIGN KEY (shipmentcost_budgetid) REFERENCES aqbudgets (budget_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'aqinvoice_adjustments'
--

DROP TABLE IF EXISTS aqinvoice_adjustments;
CREATE TABLE aqinvoice_adjustments (
    adjustment_id int(11) NOT NULL AUTO_INCREMENT, -- primary key for adjustments
    invoiceid int(11) NOT NULL, -- foreign key to link an adjustment to an invoice
    adjustment decimal(28,6), -- amount of adjustment
    reason varchar(80) default NULL, -- reason for adjustment defined by authorised values in ADJ_REASON category
    note mediumtext default NULL, -- text to explain adjustment
    budget_id int(11) default NULL, -- optional link to budget to apply adjustment to
    encumber_open smallint(1) NOT NULL default 1, -- whether or not to encumber the funds when invoice is still open, 1 = yes, 0 = no
    timestamp timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- timestamp  of last adjustment to adjustment
    PRIMARY KEY (adjustment_id),
    CONSTRAINT aqinvoice_adjustments_fk_invoiceid FOREIGN KEY (invoiceid) REFERENCES aqinvoices (invoiceid) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT aqinvoice_adjustments_fk_budget_id FOREIGN KEY (budget_id) REFERENCES aqbudgets (budget_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `aqorders`
--

DROP TABLE IF EXISTS `aqorders`;
CREATE TABLE `aqorders` ( -- information related to the basket line items
  `ordernumber` int(11) NOT NULL auto_increment, -- primary key and unique identifier assigned by Koha to each line
  `biblionumber` int(11) default NULL, -- links the order to the biblio being ordered (biblio.biblionumber)
  `entrydate` date default NULL, -- the date the bib was added to the basket
  `quantity` smallint(6) default NULL, -- the quantity ordered
  `currency` varchar(10) default NULL, -- the currency used for the purchase
  `listprice` decimal(28,6) default NULL, -- the vendor price for this line item
  `datereceived` date default NULL, -- the date this order was received
  invoiceid int(11) default NULL, -- id of invoice
  `freight` decimal(28,6) DEFAULT NULL, -- shipping costs (not used)
  `unitprice` decimal(28,6) DEFAULT NULL, -- the actual cost entered when receiving this line item
  `unitprice_tax_excluded` decimal(28,6) default NULL, -- the unit price excluding tax (on receiving)
  `unitprice_tax_included` decimal(28,6) default NULL, -- the unit price including tax (on receiving)
  `quantityreceived` smallint(6) NOT NULL default 0, -- the quantity that have been received so far
  `created_by` int(11) NULL DEFAULT NULL, -- the borrowernumber of order line's creator
  `datecancellationprinted` date default NULL, -- the date the line item was deleted
  `cancellationreason` MEDIUMTEXT default NULL, -- reason of cancellation
  `order_internalnote` LONGTEXT, -- notes related to this order line, made for staff
  `order_vendornote` LONGTEXT, -- notes related to this order line, made for vendor
  `purchaseordernumber` LONGTEXT, -- not used? always NULL
  `basketno` int(11) default NULL, -- links this order line to a specific basket (aqbasket.basketno)
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this order line was last modified
  `rrp` decimal(13,2) DEFAULT NULL, -- the retail cost for this line item
  `replacementprice` decimal(28,6) DEFAULT NULL, -- the replacement cost for this line item
  `rrp_tax_excluded` decimal(28,6) default NULL, -- the replacement cost excluding tax
  `rrp_tax_included` decimal(28,6) default NULL, -- the replacement cost including tax
  `ecost` decimal(13,2) DEFAULT NULL, -- the replacement cost for this line item
  `ecost_tax_excluded` decimal(28,6) default NULL, -- the estimated cost excluding tax
  `ecost_tax_included` decimal(28,6) default NULL, -- the estimated cost including tax
  `tax_rate_bak` decimal(6,4) DEFAULT NULL, -- the tax rate for this line item (%)
  `tax_rate_on_ordering` decimal(6,4) DEFAULT NULL, -- the tax rate on ordering for this line item (%)
  `tax_rate_on_receiving` decimal(6,4) DEFAULT NULL, -- the tax rate on receiving for this line item (%)
  `tax_value_bak` decimal(28,6) default NULL, -- the tax value for this line item
  `tax_value_on_ordering` decimal(28,6) DEFAULT NULL, -- the tax value on ordering for this line item
  `tax_value_on_receiving` decimal(28,6) DEFAULT NULL, -- the tax value on receiving for this line item
  `discount` float(6,4) default NULL, -- the discount for this line item (%)
  `budget_id` int(11) NOT NULL, -- the fund this order goes against (aqbudgets.budget_id)
  `budgetdate` date default NULL, -- not used? always NULL
  `sort1` varchar(80) default NULL, -- statistical field
  `sort2` varchar(80) default NULL, -- second statistical field
  `sort1_authcat` varchar(10) default NULL,
  `sort2_authcat` varchar(10) default NULL,
  `uncertainprice` tinyint(1), -- was this price uncertain (1 for yes, 0 for no)
  `subscriptionid` int(11) default NULL, -- links this order line to a subscription (subscription.subscriptionid)
  parent_ordernumber int(11) default NULL, -- ordernumber of parent order line, or same as ordernumber if no parent
  `orderstatus` varchar(16) default 'new', -- the current status for this line item. Can be 'new', 'ordered', 'partial', 'complete' or 'cancelled'
  line_item_id varchar(35) default NULL, -- Supplier's article id for Edifact orderline
  suppliers_reference_number varchar(35) default NULL, -- Suppliers unique edifact quote ref
  suppliers_reference_qualifier varchar(3) default NULL, -- Type of number above usually 'QLI'
  `suppliers_report` MEDIUMTEXT COLLATE utf8mb4_unicode_ci, -- reports received from suppliers
  PRIMARY KEY  (`ordernumber`),
  KEY `basketno` (`basketno`),
  KEY `biblionumber` (`biblionumber`),
  KEY `budget_id` (`budget_id`),
  KEY `parent_ordernumber` (`parent_ordernumber`),
  KEY `orderstatus` (`orderstatus`),
  CONSTRAINT aqorders_created_by FOREIGN KEY (created_by) REFERENCES borrowers (borrowernumber) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `aqorders_budget_id_fk` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorders_ibfk_1` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorders_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT aqorders_ibfk_3 FOREIGN KEY (invoiceid) REFERENCES aqinvoices (invoiceid) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `aqorders_subscriptionid` FOREIGN KEY (`subscriptionid`) REFERENCES `subscription` (`subscriptionid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorders_currency` FOREIGN KEY (`currency`) REFERENCES `currency` (`currency`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `aqorder_users`
--

DROP TABLE IF EXISTS `aqorder_users`;
CREATE TABLE aqorder_users ( -- Mapping orders to patrons for notification sending
    ordernumber int(11) NOT NULL, -- the order this patrons receive notifications from (aqorders.ordernumber)
    borrowernumber int(11) NOT NULL, -- the borrowernumber for the patron receiving notifications for this order (borrowers.borrowernumber)
    PRIMARY KEY (ordernumber, borrowernumber),
    CONSTRAINT aqorder_users_ibfk_1 FOREIGN KEY (ordernumber) REFERENCES aqorders (ordernumber) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT aqorder_users_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `aqorders_items`
--

DROP TABLE IF EXISTS `aqorders_items`;
CREATE TABLE `aqorders_items` ( -- information on items entered in the acquisitions process
  `ordernumber` int(11) NOT NULL, -- the order this item is attached to (aqorders.ordernumber)
  `itemnumber` int(11) NOT NULL, -- the item number for this item (items.itemnumber)
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this order item was last touched
  PRIMARY KEY  (`itemnumber`),
  KEY `ordernumber` (`ordernumber`),
  CONSTRAINT aqorders_items_ibfk_1 FOREIGN KEY (ordernumber) REFERENCES aqorders (ordernumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table aqorders_transfers
--

DROP TABLE IF EXISTS aqorders_transfers;
CREATE TABLE aqorders_transfers (
  ordernumber_from int(11) NULL,
  ordernumber_to int(11) NULL,
  timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY ordernumber_from (ordernumber_from),
  UNIQUE KEY ordernumber_to (ordernumber_to),
  CONSTRAINT aqorders_transfers_ordernumber_from FOREIGN KEY (ordernumber_from) REFERENCES aqorders (ordernumber) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT aqorders_transfers_ordernumber_to FOREIGN KEY (ordernumber_to) REFERENCES aqorders (ordernumber) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table aqorders_claims
--

DROP TABLE IF EXISTS aqorders_claims;
CREATE TABLE aqorders_claims (
    id int(11) AUTO_INCREMENT, -- ID of the claims
    ordernumber INT(11) NOT NULL, -- order linked to this claim
    claimed_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Date of the claims
    PRIMARY KEY (id),
    CONSTRAINT aqorders_claims_ibfk_1 FOREIGN KEY (ordernumber) REFERENCES aqorders (ordernumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

--
-- Table structure for table `transport_cost`
--

DROP TABLE IF EXISTS transport_cost;
CREATE TABLE transport_cost (
      frombranch varchar(10) NOT NULL,
      tobranch varchar(10) NOT NULL,
      cost decimal(6,2) NOT NULL,
      disable_transfer tinyint(1) NOT NULL DEFAULT 0,
      PRIMARY KEY (frombranch, tobranch),
      CONSTRAINT transport_cost_ibfk_1 FOREIGN KEY (frombranch) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT transport_cost_ibfk_2 FOREIGN KEY (tobranch) REFERENCES branches (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `biblioimages`
--

DROP TABLE IF EXISTS `biblioimages`;

CREATE TABLE `biblioimages` ( -- local cover images
 `imagenumber` int(11) NOT NULL AUTO_INCREMENT, -- unique identifier for the image
 `biblionumber` int(11) NOT NULL, -- foreign key from biblio table to link to biblionumber
 `mimetype` varchar(15) NOT NULL, -- image type
 `imagefile` mediumblob NOT NULL, -- image file contents
 `thumbnail` mediumblob NOT NULL, -- thumbnail file contents
 `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- image creation/update time
 PRIMARY KEY (`imagenumber`),
 CONSTRAINT `bibliocoverimage_fk1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `social_data`
--

DROP TABLE IF EXISTS `social_data`;
CREATE TABLE IF NOT EXISTS `social_data` (
  `isbn` VARCHAR(30) NOT NULL DEFAULT '',
  `num_critics` INT,
  `num_critics_pro` INT,
  `num_quotations` INT,
  `num_videos` INT,
  `score_avg` DECIMAL(5,2),
  `num_scores` INT,
  PRIMARY KEY  (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 'Ratings' table. This tracks the star ratings set by borrowers.
--

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings ( -- information related to the star ratings in the OPAC
    borrowernumber int(11) NOT NULL, -- the borrowernumber of the patron who left this rating (borrowers.borrowernumber)
    biblionumber int(11) NOT NULL, -- the biblio this rating is for (biblio.biblionumber)
    rating_value tinyint(1) NOT NULL, -- the rating, from 1 to 5
    timestamp timestamp NOT NULL default CURRENT_TIMESTAMP,
    PRIMARY KEY  (borrowernumber,biblionumber),
    CONSTRAINT ratings_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ratings_ibfk_2 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `quotes`
--

DROP TABLE IF EXISTS quotes;
CREATE TABLE `quotes` ( -- data for the quote of the day feature
  `id` int(11) NOT NULL AUTO_INCREMENT, -- unique id for the quote
  `source` MEDIUMTEXT DEFAULT NULL, -- source/credit for the quote
  `text` LONGTEXT NOT NULL, -- text of the quote
  `timestamp` datetime NULL, -- date and time that the quote last appeared in the opac
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table categories_branches
--

DROP TABLE IF EXISTS categories_branches;
CREATE TABLE categories_branches( -- association table between categories and branches
    categorycode VARCHAR(10),
    branchcode VARCHAR(10),
    FOREIGN KEY (categorycode) REFERENCES categories(categorycode) ON DELETE CASCADE,
    FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table authorised_values_branches
--

DROP TABLE IF EXISTS authorised_values_branches;
CREATE TABLE authorised_values_branches( -- association table between authorised_values and branches
    av_id INT(11) NOT NULL,
    branchcode VARCHAR(10) NOT NULL,
    FOREIGN KEY (av_id) REFERENCES authorised_values(id) ON DELETE CASCADE,
    FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Table structure for table borrower_attribute_types_branches
--

DROP TABLE IF EXISTS borrower_attribute_types_branches;
CREATE TABLE borrower_attribute_types_branches( -- association table between borrower_attribute_types and branches
    bat_code VARCHAR(10),
    b_branchcode VARCHAR(10),
    FOREIGN KEY (bat_code) REFERENCES borrower_attribute_types(code) ON DELETE CASCADE,
    FOREIGN KEY (b_branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `borrower_modifications`
--

CREATE TABLE IF NOT EXISTS `borrower_modifications` (
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `verification_token` varchar(255) NOT NULL DEFAULT '',
  `changed_fields` MEDIUMTEXT DEFAULT NULL,
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `cardnumber` varchar(32) DEFAULT NULL,
  `surname` LONGTEXT,
  `firstname` MEDIUMTEXT,
  `title` LONGTEXT,
  `othernames` LONGTEXT,
  `initials` MEDIUMTEXT,
  `streetnumber` varchar(10) DEFAULT NULL,
  `streettype` varchar(50) DEFAULT NULL,
  `address` LONGTEXT,
  `address2` MEDIUMTEXT,
  `city` LONGTEXT,
  `state` MEDIUMTEXT,
  `zipcode` varchar(25) DEFAULT NULL,
  `country` MEDIUMTEXT,
  `email` LONGTEXT,
  `phone` MEDIUMTEXT,
  `mobile` varchar(50) DEFAULT NULL,
  `fax` LONGTEXT,
  `emailpro` MEDIUMTEXT,
  `phonepro` MEDIUMTEXT,
  `B_streetnumber` varchar(10) DEFAULT NULL,
  `B_streettype` varchar(50) DEFAULT NULL,
  `B_address` varchar(100) DEFAULT NULL,
  `B_address2` MEDIUMTEXT,
  `B_city` LONGTEXT,
  `B_state` MEDIUMTEXT,
  `B_zipcode` varchar(25) DEFAULT NULL,
  `B_country` MEDIUMTEXT,
  `B_email` MEDIUMTEXT,
  `B_phone` LONGTEXT,
  `dateofbirth` date DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `categorycode` varchar(10) DEFAULT NULL,
  `dateenrolled` date DEFAULT NULL,
  `dateexpiry` date DEFAULT NULL,
  `date_renewed` date default NULL,
  `gonenoaddress` tinyint(1) DEFAULT NULL,
  `lost` tinyint(1) DEFAULT NULL,
  `debarred` date DEFAULT NULL,
  `debarredcomment` varchar(255) DEFAULT NULL,
  `contactname` LONGTEXT,
  `contactfirstname` MEDIUMTEXT,
  `contacttitle` MEDIUMTEXT,
  `borrowernotes` LONGTEXT,
  `relationship` varchar(100) DEFAULT NULL,
  `sex` varchar(1) DEFAULT NULL,
  `password` varchar(30) DEFAULT NULL,
  `flags` int(11) DEFAULT NULL,
  `userid` varchar(75) DEFAULT NULL,
  `opacnote` LONGTEXT,
  `contactnote` varchar(255) DEFAULT NULL,
  `sort1` varchar(80) DEFAULT NULL,
  `sort2` varchar(80) DEFAULT NULL,
  `altcontactfirstname` varchar(255) DEFAULT NULL,
  `altcontactsurname` varchar(255) DEFAULT NULL,
  `altcontactaddress1` varchar(255) DEFAULT NULL,
  `altcontactaddress2` varchar(255) DEFAULT NULL,
  `altcontactaddress3` varchar(255) DEFAULT NULL,
  `altcontactstate` MEDIUMTEXT,
  `altcontactzipcode` varchar(50) DEFAULT NULL,
  `altcontactcountry` MEDIUMTEXT,
  `altcontactphone` varchar(50) DEFAULT NULL,
  `smsalertnumber` varchar(50) DEFAULT NULL,
  `privacy` int(11) DEFAULT NULL,
  `extended_attributes` MEDIUMTEXT DEFAULT NULL,
  `gdpr_proc_consent` datetime, -- data processing consent
  PRIMARY KEY (`verification_token` (191),`borrowernumber`),
  KEY `verification_token` (`verification_token` (191)),
  KEY `borrowernumber` (`borrowernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table uploaded_files
--

DROP TABLE IF EXISTS uploaded_files;
CREATE TABLE uploaded_files (
    id int(11) NOT NULL AUTO_INCREMENT,
    hashvalue CHAR(40) NOT NULL,
    filename MEDIUMTEXT NOT NULL,
    dir MEDIUMTEXT NOT NULL,
    filesize int(11),
    dtcreated timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    uploadcategorycode TEXT,
    owner int(11),
    public tinyint,
    permanent tinyint,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table linktracker
-- This stores clicks to external links
--

DROP TABLE IF EXISTS linktracker;
CREATE TABLE linktracker (
   id int(11) NOT NULL AUTO_INCREMENT, -- primary key identifier
   biblionumber int(11) DEFAULT NULL, -- biblionumber of the record the link is from
   itemnumber int(11) DEFAULT NULL, -- itemnumber if applicable that the link was from
   borrowernumber int(11) DEFAULT NULL, -- borrowernumber who clicked the link
   url MEDIUMTEXT, -- the link itself
   timeclicked datetime DEFAULT NULL, -- the date and time the link was clicked
   PRIMARY KEY (id),
   KEY bibidx (biblionumber),
   KEY itemidx (itemnumber),
   KEY borridx (borrowernumber),
   KEY dateidx (timeclicked)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'plugin_data'
--

CREATE TABLE IF NOT EXISTS plugin_data (
  plugin_class varchar(255) NOT NULL,
  plugin_key varchar(255) NOT NULL,
  plugin_value MEDIUMTEXT,
  PRIMARY KEY ( `plugin_class` (191), `plugin_key` (191) )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table patron_consent
--

DROP TABLE IF EXISTS patron_consent;
CREATE TABLE patron_consent (
  id int AUTO_INCREMENT,
  borrowernumber int NOT NULL,
  type enum('GDPR_PROCESSING' ), -- allows for future extension
  given_on datetime,
  refused_on datetime,
  PRIMARY KEY (id),
  FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'plugin_methods'
--

DROP TABLE IF EXISTS plugin_methods;
CREATE TABLE plugin_methods (
  plugin_class varchar(255) NOT NULL,
  plugin_method varchar(255) NOT NULL,
  PRIMARY KEY ( `plugin_class` (191), `plugin_method` (191) )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `patron_lists`
--

DROP TABLE IF EXISTS patron_lists;
CREATE TABLE patron_lists (
  patron_list_id int(11) NOT NULL AUTO_INCREMENT, -- unique identifier
  name varchar(255) CHARACTER SET utf8mb4 NOT NULL,  -- the list's name
  owner int(11) NOT NULL,                         -- borrowernumber of the list creator
  shared tinyint(1) default 0,
  PRIMARY KEY (patron_list_id),
  KEY owner (owner)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Constraints for table `patron_lists`
--
ALTER TABLE `patron_lists`
  ADD CONSTRAINT patron_lists_ibfk_1 FOREIGN KEY (`owner`) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table structure for table 'patron_list_patrons'
--

DROP TABLE IF EXISTS patron_list_patrons;
CREATE TABLE patron_list_patrons (
  patron_list_patron_id int(11) NOT NULL AUTO_INCREMENT, -- unique identifier
  patron_list_id int(11) NOT NULL,                       -- the list this entry is part of
  borrowernumber int(11) NOT NULL,                       -- the borrower that is part of this list
  PRIMARY KEY (patron_list_patron_id),
  KEY patron_list_id (patron_list_id),
  KEY borrowernumber (borrowernumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Constraints for table `patron_list_patrons`
--
ALTER TABLE `patron_list_patrons`
  ADD CONSTRAINT patron_list_patrons_ibfk_1 FOREIGN KEY (patron_list_id) REFERENCES patron_lists (patron_list_id) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT patron_list_patrons_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table structure for table 'marc_modification_templates'
--

CREATE TABLE IF NOT EXISTS marc_modification_templates (
    template_id int(11) NOT NULL AUTO_INCREMENT,
    name MEDIUMTEXT NOT NULL,
    PRIMARY KEY (template_id)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'marc_modification_template_actions'
--

CREATE TABLE IF NOT EXISTS marc_modification_template_actions (
  mmta_id int(11) NOT NULL AUTO_INCREMENT,
  template_id int(11) NOT NULL,
  ordering int(3) NOT NULL,
  action ENUM('delete_field','add_field','update_field','move_field','copy_field','copy_and_replace_field') NOT NULL,
  field_number smallint(6) NOT NULL DEFAULT '0',
  from_field varchar(3) NOT NULL,
  from_subfield varchar(1) DEFAULT NULL,
  field_value varchar(100) DEFAULT NULL,
  to_field varchar(3) DEFAULT NULL,
  to_subfield varchar(1) DEFAULT NULL,
  to_regex_search MEDIUMTEXT,
  to_regex_replace MEDIUMTEXT,
  to_regex_modifiers varchar(8) DEFAULT '',
  conditional enum('if','unless') DEFAULT NULL,
  conditional_field varchar(3) DEFAULT NULL,
  conditional_subfield varchar(1) DEFAULT NULL,
  conditional_comparison enum('exists','not_exists','equals','not_equals') DEFAULT NULL,
  conditional_value MEDIUMTEXT,
  conditional_regex tinyint(1) NOT NULL DEFAULT '0',
  description MEDIUMTEXT,
  PRIMARY KEY (mmta_id),
  CONSTRAINT `mmta_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `marc_modification_templates` (`template_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `misc_files`
--

CREATE TABLE IF NOT EXISTS `misc_files` ( -- miscellaneous files attached to records from various tables
  `file_id` int(11) NOT NULL AUTO_INCREMENT, -- unique id for the file record
  `table_tag` varchar(255) NOT NULL, -- usually table name, or arbitrary unique tag
  `record_id` int(11) NOT NULL, -- record id from the table this file is associated to
  `file_name` varchar(255) NOT NULL, -- file name
  `file_type` varchar(255) NOT NULL, -- MIME type of the file
  `file_description` varchar(255) DEFAULT NULL, -- description given to the file
  `file_content` longblob NOT NULL, -- file content
  `date_uploaded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, -- date and time the file was added
  PRIMARY KEY (`file_id`),
  KEY `table_tag` (`table_tag`),
  KEY `record_id` (`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `columns_settings`
--

CREATE TABLE IF NOT EXISTS columns_settings (
    module varchar(255) NOT NULL,
    page varchar(255) NOT NULL,
    tablename varchar(255) NOT NULL,
    columnname varchar(255) NOT NULL,
    cannot_be_toggled int(1) NOT NULL DEFAULT 0,
    is_hidden int(1) NOT NULL DEFAULT 0,
    PRIMARY KEY(module (191), page (191), tablename (191), columnname (191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `tables_settings`
--

CREATE TABLE IF NOT EXISTS tables_settings (
    module varchar(255) NOT NULL,
    page varchar(255) NOT NULL,
    tablename varchar(255) NOT NULL,
    default_display_length smallint(6) NOT NULL DEFAULT 20 ,
    default_sort_order varchar(255),
    PRIMARY KEY(module (191), page (191), tablename (191) )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'items_search_fields'
--

DROP TABLE IF EXISTS items_search_fields;
CREATE TABLE items_search_fields (
  name VARCHAR(255) NOT NULL,
  label VARCHAR(255) NOT NULL,
  tagfield CHAR(3) NOT NULL,
  tagsubfield CHAR(1) NULL DEFAULT NULL,
  authorised_values_category VARCHAR(32) NULL DEFAULT NULL,
  PRIMARY KEY(name (191)),
  CONSTRAINT items_search_fields_authorised_values_category
    FOREIGN KEY (authorised_values_category) REFERENCES authorised_value_categories (category_name)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'discharges'
--

DROP TABLE IF EXISTS discharges;
CREATE TABLE discharges (
  discharge_id int(11) NOT NULL AUTO_INCREMENT,
  borrower int(11) DEFAULT NULL,
  needed timestamp NULL DEFAULT NULL,
  validated timestamp NULL DEFAULT NULL,
  PRIMARY KEY (discharge_id),
  KEY borrower_discharges_ibfk1 (borrower),
  CONSTRAINT borrower_discharges_ibfk1 FOREIGN KEY (borrower) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table additional_fields
-- This table add the ability to add new fields for a record
--

DROP TABLE IF EXISTS additional_fields;
CREATE TABLE `additional_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT, -- primary key identifier
  `tablename` varchar(255) NOT NULL DEFAULT '', -- tablename of the new field
  `name` varchar(255) NOT NULL DEFAULT '', -- name of the field
  `authorised_value_category` varchar(16) NOT NULL DEFAULT '', -- is an authorised value category
  `marcfield` varchar(16) NOT NULL DEFAULT '', -- contains the marc field to copied into the record
  `searchable` tinyint(1) NOT NULL DEFAULT '0', -- is the field searchable?
  PRIMARY KEY (`id`),
  UNIQUE KEY `fields_uniq` (`tablename` (191),`name` (191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table additional_field_values
-- This table store values for additional fields
--

DROP TABLE IF EXISTS additional_field_values;
CREATE TABLE `additional_field_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT, -- primary key identifier
  `field_id` int(11) NOT NULL, -- foreign key references additional_fields(id)
  `record_id` int(11) NOT NULL, -- record_id
  `value` varchar(255) NOT NULL DEFAULT '', -- value for this field
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_record` (`field_id`,`record_id`),
  CONSTRAINT `afv_fk` FOREIGN KEY (`field_id`) REFERENCES `additional_fields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'localization'
--

DROP TABLE IF EXISTS localization;
CREATE TABLE `localization` (
      localization_id int(11) NOT NULL AUTO_INCREMENT,
      entity varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
      code varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
      lang varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL, -- could be a foreign key
      translation MEDIUMTEXT COLLATE utf8mb4_unicode_ci,
      PRIMARY KEY (localization_id),
      UNIQUE KEY `entity_code_lang` (`entity`,`code`,`lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'audio_alerts'
--

DROP TABLE IF EXISTS audio_alerts;
CREATE TABLE audio_alerts (
  id int(11) NOT NULL AUTO_INCREMENT,
  precedence smallint(5) unsigned NOT NULL,
  selector varchar(255) NOT NULL,
  sound varchar(255) NOT NULL,
  PRIMARY KEY (id),
  KEY precedence (precedence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'edifact_ean'
--

DROP TABLE IF EXISTS edifact_ean;
CREATE TABLE IF NOT EXISTS edifact_ean (
  ee_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  description VARCHAR(128) NULL DEFAULT NULL,
  branchcode VARCHAR(10) NULL DEFAULT NULL REFERENCES branches (branchcode),
  ean VARCHAR(15) NOT NULL,
  id_code_qualifier VARCHAR(3) NOT NULL DEFAULT '14',
  CONSTRAINT efk_branchcode FOREIGN KEY ( branchcode ) REFERENCES branches ( branchcode )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `courses`
--

-- The courses table stores the courses created for the
-- course reserves feature.

DROP TABLE IF EXISTS courses;
CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL AUTO_INCREMENT, -- unique id for the course
  `department` varchar(80) DEFAULT NULL, -- the authorised value for the DEPARTMENT
  `course_number` varchar(255) DEFAULT NULL, -- the "course number" assigned to a course
  `section` varchar(255) DEFAULT NULL, -- the 'section' of a course
  `course_name` varchar(255) DEFAULT NULL, -- the name of the course
  `term` varchar(80) DEFAULT NULL, -- the authorised value for the TERM
  `staff_note` LONGTEXT, -- the text of the staff only note
  `public_note` LONGTEXT, -- the text of the public / opac note
  `students_count` varchar(20) DEFAULT NULL, -- how many students will be taking this course/section
  `enabled` enum('yes','no') NOT NULL DEFAULT 'yes', -- determines whether the course is active
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`course_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `course_instructors`
--

-- The course instructors table links Koha borrowers to the
-- courses they are teaching. Many instructors can teach many
-- courses. course_instructors is just a many-to-many join table.

DROP TABLE IF EXISTS course_instructors;
CREATE TABLE `course_instructors` (
  `course_id` int(11) NOT NULL, -- foreign key to link to courses.course_id
  `borrowernumber` int(11) NOT NULL, -- foreign key to link to borrowers.borrowernumber for instructor information
  PRIMARY KEY (`course_id`,`borrowernumber`),
  KEY `borrowernumber` (`borrowernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Constraints for table `course_instructors`
--
ALTER TABLE `course_instructors`
  ADD CONSTRAINT `course_instructors_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  ADD CONSTRAINT `course_instructors_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table structure for table `course_items`
--

-- If an item is placed on course reserve for one or more courses
-- it will have an entry in this table. No matter how many courses an item
-- is part of, it will only have one row in this table.

DROP TABLE IF EXISTS course_items;
CREATE TABLE `course_items` (
  `ci_id` int(11) NOT NULL AUTO_INCREMENT, -- course item id
  `itemnumber` int(11) NOT NULL, -- items.itemnumber for the item on reserve
  `itype` varchar(10) DEFAULT NULL, -- new itemtype for the item to have while on reserve (optional)
  `itype_enabled` tinyint(1) NOT NULL DEFAULT 0, -- indicates if itype should be changed while on course reserve
  `itype_storage` varchar(10) DEFAULT NULL, -- a place to store the itype when item is on course reserve
  `ccode` varchar(80) DEFAULT NULL, -- new category code for the item to have while on reserve (optional)
  `ccode_enabled` tinyint(1) NOT NULL DEFAULT 0, -- indicates if ccode should be changed while on course reserve
  `ccode_storage` varchar(80) DEFAULT NULL, -- a place to store the ccode when item is on course reserve
  `homebranch` varchar(10) DEFAULT NULL, -- new home branch for the item to have while on reserve (optional)
  `homebranch_enabled` tinyint(1) NOT NULL DEFAULT 0, -- indicates if homebranch should be changed while on course reserve
  `homebranch_storage` varchar(10) DEFAULT NULL, -- a place to store the homebranch when item is on course reserve
  `holdingbranch` varchar(10) DEFAULT NULL, -- new holding branch for the item to have while on reserve (optional)
  `holdingbranch_enabled` tinyint(1) NOT NULL DEFAULT 0, -- indicates if itype should be changed while on course reserve
  `holdingbranch_storage` varchar(10) DEFAULT NULL, -- a place to store the holdingbranch when item is on course reserve
  `location` varchar(80) DEFAULT NULL, -- new shelving location for the item to have while on reseve (optional)
  `location_enabled` tinyint(1) NOT NULL DEFAULT 0, -- indicates if itype should be changed while on course reserve
  `location_storage` varchar(80) DEFAULT NULL, -- a place to store the location when the item is on course reserve
  `enabled` enum('yes','no') NOT NULL DEFAULT 'no', -- if at least one enabled course has this item on reseve, this field will be 'yes', otherwise it will be 'no'
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`ci_id`),
   UNIQUE KEY `itemnumber` (`itemnumber`),
   KEY `holdingbranch` (`holdingbranch`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Constraints for table `course_items`
--
ALTER TABLE `course_items`
  ADD CONSTRAINT `course_items_ibfk_2` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `course_items_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT fk_course_items_homebranch FOREIGN KEY (homebranch) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT fk_course_items_homebranch_storage FOREIGN KEY (homebranch_storage) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table structure for table `course_reserves`
--

-- This table connects an item placed on course reserve to a course it is on reserve for.
-- There will be a row in this table for each course an item is on reserve for.

DROP TABLE IF EXISTS course_reserves;
CREATE TABLE `course_reserves` (
  `cr_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL, -- foreign key to link to courses.course_id
  `ci_id` int(11) NOT NULL, -- foreign key to link to courses_items.ci_id
  `staff_note` LONGTEXT, -- staff only note
  `public_note` LONGTEXT, -- public, OPAC visible note
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`cr_id`),
   UNIQUE KEY `pseudo_key` (`course_id`,`ci_id`),
   KEY `course_id` (`course_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Constraints for table `course_reserves`
--
ALTER TABLE `course_reserves`
  ADD CONSTRAINT `course_reserves_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  ADD CONSTRAINT `course_reserves_ibfk_2` FOREIGN KEY (`ci_id`) REFERENCES `course_items` (`ci_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table structure for table `hold_fill_targets`
--

DROP TABLE IF EXISTS `hold_fill_targets`;
CREATE TABLE `hold_fill_targets` (
  `borrowernumber` int(11) NOT NULL,
  `biblionumber` int(11) NOT NULL,
  `itemnumber` int(11) NOT NULL,
  `source_branchcode`  varchar(10) default NULL,
  `item_level_request` tinyint(4) NOT NULL default 0,
  PRIMARY KEY `itemnumber` (`itemnumber`),
  KEY `bib_branch` (`biblionumber`, `source_branchcode`),
  CONSTRAINT `hold_fill_targets_ibfk_1` FOREIGN KEY (`borrowernumber`)
    REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_2` FOREIGN KEY (`biblionumber`)
    REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_3` FOREIGN KEY (`itemnumber`)
    REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_4` FOREIGN KEY (`source_branchcode`)
    REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `housebound_profile`
--

DROP TABLE IF EXISTS `housebound_profile`;
CREATE TABLE `housebound_profile` (
  `borrowernumber` int(11) NOT NULL, -- Number of the borrower associated with this profile.
  `day` MEDIUMTEXT NOT NULL,  -- The preferred day of the week for delivery.
  `frequency` MEDIUMTEXT NOT NULL, -- The Authorised_Value definining the pattern for delivery.
  `fav_itemtypes` MEDIUMTEXT default NULL, -- Free text describing preferred itemtypes.
  `fav_subjects` MEDIUMTEXT default NULL, -- Free text describing preferred subjects.
  `fav_authors` MEDIUMTEXT default NULL, -- Free text describing preferred authors.
  `referral` MEDIUMTEXT default NULL, -- Free text indicating how the borrower was added to the service.
  `notes` MEDIUMTEXT default NULL, -- Free text for additional notes.
  PRIMARY KEY  (`borrowernumber`),
  CONSTRAINT `housebound_profile_bnfk`
    FOREIGN KEY (`borrowernumber`)
    REFERENCES `borrowers` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `housebound_visit`
--

DROP TABLE IF EXISTS `housebound_visit`;
CREATE TABLE `housebound_visit` (
  `id` int(11) NOT NULL auto_increment, -- ID of the visit.
  `borrowernumber` int(11) NOT NULL, -- Number of the borrower, & the profile, linked to this visit.
  `appointment_date` date default NULL, -- Date of visit.
  `day_segment` varchar(10),  -- Rough time frame: 'morning', 'afternoon' 'evening'
  `chooser_brwnumber` int(11) default NULL, -- Number of the borrower to choose items  for delivery.
  `deliverer_brwnumber` int(11) default NULL, -- Number of the borrower to deliver items.
  PRIMARY KEY  (`id`),
  CONSTRAINT `houseboundvisit_bnfk`
    FOREIGN KEY (`borrowernumber`)
    REFERENCES `housebound_profile` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `houseboundvisit_bnfk_1`
    FOREIGN KEY (`chooser_brwnumber`)
    REFERENCES `borrowers` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `houseboundvisit_bnfk_2`
    FOREIGN KEY (`deliverer_brwnumber`)
    REFERENCES `borrowers` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `housebound_role`
--

DROP TABLE IF EXISTS `housebound_role`;
CREATE TABLE IF NOT EXISTS `housebound_role` (
  `borrowernumber_id` int(11) NOT NULL, -- borrowernumber link
  `housebound_chooser` tinyint(1) NOT NULL DEFAULT 0, -- set to 1 to indicate this patron is a housebound chooser volunteer
  `housebound_deliverer` tinyint(1) NOT NULL DEFAULT 0, -- set to 1 to indicate this patron is a housebound deliverer volunteer
  PRIMARY KEY (`borrowernumber_id`),
  CONSTRAINT `houseboundrole_bnfk`
    FOREIGN KEY (`borrowernumber_id`)
    REFERENCES `borrowers` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'article_requests'
--

DROP TABLE IF EXISTS `article_requests`;
CREATE TABLE `article_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL,
  `biblionumber` int(11) NOT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `branchcode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` MEDIUMTEXT,
  `author` MEDIUMTEXT,
  `volume` MEDIUMTEXT,
  `issue` MEDIUMTEXT,
  `date` MEDIUMTEXT,
  `pages` MEDIUMTEXT,
  `chapters` MEDIUMTEXT,
  `patron_notes` MEDIUMTEXT,
  `status` enum('PENDING','PROCESSING','COMPLETED','CANCELED') NOT NULL DEFAULT 'PENDING',
  `notes` MEDIUMTEXT,
  `created_on` timestamp NULL DEFAULT NULL, -- Be careful with two timestamps in one table not allowing NULL
  `updated_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `article_requests_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `biblio_metadata`
--

DROP TABLE IF EXISTS `biblio_metadata`;
CREATE TABLE biblio_metadata (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `biblionumber` INT(11) NOT NULL,
    `format` VARCHAR(16) NOT NULL,
    `schema` VARCHAR(16) NOT NULL,
    `metadata` LONGTEXT NOT NULL,
    `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
    PRIMARY KEY(id),
    UNIQUE KEY `biblio_metadata_uniq_key` (`biblionumber`,`format`,`schema`),
    CONSTRAINT `record_metadata_fk_1` FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE,
    KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `deletedbiblio_metadata`
--

DROP TABLE IF EXISTS `deletedbiblio_metadata`;
CREATE TABLE deletedbiblio_metadata (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `biblionumber` INT(11) NOT NULL,
    `format` VARCHAR(16) NOT NULL,
    `schema` VARCHAR(16) NOT NULL,
    `metadata` LONGTEXT NOT NULL,
    `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
    PRIMARY KEY(id),
    UNIQUE KEY `deletedbiblio_metadata_uniq_key` (`biblionumber`,`format`,`schema`),
    CONSTRAINT `deletedrecord_metadata_fk_1` FOREIGN KEY (biblionumber) REFERENCES deletedbiblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE,
    KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'club_templates'
--

CREATE TABLE IF NOT EXISTS club_templates (
  id int(11) NOT NULL AUTO_INCREMENT,
  `name` TEXT NOT NULL,
  description MEDIUMTEXT,
  is_enrollable_from_opac tinyint(1) NOT NULL DEFAULT '0',
  is_email_required tinyint(1) NOT NULL DEFAULT '0',
  branchcode varchar(10) NULL DEFAULT NULL,
  date_created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_updated timestamp NULL DEFAULT NULL,
  is_deletable tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (id),
  KEY ct_branchcode (branchcode),
  CONSTRAINT `club_templates_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'clubs'
--

CREATE TABLE IF NOT EXISTS clubs (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_template_id int(11) NOT NULL,
  `name` TEXT NOT NULL,
  description MEDIUMTEXT,
  date_start date DEFAULT NULL,
  date_end date DEFAULT NULL,
  branchcode varchar(10) NULL DEFAULT NULL,
  date_created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_updated timestamp NULL DEFAULT NULL,
  PRIMARY KEY (id),
  KEY club_template_id (club_template_id),
  KEY branchcode (branchcode),
  CONSTRAINT clubs_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT clubs_ibfk_2 FOREIGN KEY (branchcode) REFERENCES branches (branchcode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'club_holds'
--

CREATE TABLE IF NOT EXISTS club_holds (
    id        INT(11) NOT NULL AUTO_INCREMENT,
    club_id   INT(11) NOT NULL, -- id for the club the hold was generated for
    biblio_id INT(11) NOT NULL, -- id for the bibliographic record the hold has been placed against
    item_id   INT(11) NULL DEFAULT NULL, -- If item-level, the id for the item the hold has been placed agains
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp for the placed hold
    PRIMARY KEY (id),
    -- KEY club_id (club_id),
    CONSTRAINT clubs_holds_ibfk_1 FOREIGN KEY (club_id)   REFERENCES clubs  (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT clubs_holds_ibfk_2 FOREIGN KEY (biblio_id) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT clubs_holds_ibfk_3 FOREIGN KEY (item_id)   REFERENCES items  (itemnumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'club_holds_to_patron_holds'
--

CREATE TABLE IF NOT EXISTS club_holds_to_patron_holds (
    id              INT(11) NOT NULL AUTO_INCREMENT,
    club_hold_id    INT(11) NOT NULL,
    patron_id       INT(11) NOT NULL,
    hold_id         INT(11),
    error_code      ENUM ( 'damaged', 'ageRestricted', 'itemAlreadyOnHold',
                        'tooManyHoldsForThisRecord', 'tooManyReservesToday',
                        'tooManyReserves', 'notReservable', 'cannotReserveFromOtherBranches',
                        'libraryNotFound', 'libraryNotPickupLocation', 'cannotBeTransferred'
                    ) NULL DEFAULT NULL,
    error_message   varchar(100) NULL DEFAULT NULL,
    PRIMARY KEY (id),
    -- KEY club_hold_id (club_hold_id),
    CONSTRAINT clubs_holds_paton_holds_ibfk_1 FOREIGN KEY (club_hold_id) REFERENCES club_holds (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT clubs_holds_paton_holds_ibfk_2 FOREIGN KEY (patron_id) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT clubs_holds_paton_holds_ibfk_3 FOREIGN KEY (hold_id) REFERENCES reserves (reserve_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'club_enrollments'
--

CREATE TABLE IF NOT EXISTS club_enrollments (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_id int(11) NOT NULL,
  borrowernumber int(11) NOT NULL,
  date_enrolled timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_canceled timestamp NULL DEFAULT NULL,
  date_created timestamp NULL DEFAULT NULL,
  date_updated timestamp NULL DEFAULT NULL,
  branchcode varchar(10) NULL DEFAULT NULL,
  PRIMARY KEY (id),
  KEY club_id (club_id),
  KEY borrowernumber (borrowernumber),
  KEY branchcode (branchcode),
  CONSTRAINT club_enrollments_ibfk_1 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT club_enrollments_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT club_enrollments_ibfk_3 FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'club_template_enrollment_fields'
--

CREATE TABLE IF NOT EXISTS club_template_enrollment_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_template_id int(11) NOT NULL,
  `name` TEXT NOT NULL,
  description MEDIUMTEXT,
  authorised_value_category varchar(16) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY club_template_id (club_template_id),
  CONSTRAINT club_template_enrollment_fields_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'club_enrollment_fields'
--

CREATE TABLE IF NOT EXISTS club_enrollment_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_enrollment_id int(11) NOT NULL,
  club_template_enrollment_field_id int(11) NOT NULL,
  `value` MEDIUMTEXT NOT NULL,
  PRIMARY KEY (id),
  KEY club_enrollment_id (club_enrollment_id),
  KEY club_template_enrollment_field_id (club_template_enrollment_field_id),
  CONSTRAINT club_enrollment_fields_ibfk_1 FOREIGN KEY (club_enrollment_id) REFERENCES club_enrollments (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT club_enrollment_fields_ibfk_2 FOREIGN KEY (club_template_enrollment_field_id) REFERENCES club_template_enrollment_fields (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'club_template_fields'
--

CREATE TABLE IF NOT EXISTS club_template_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_template_id int(11) NOT NULL,
  `name` TEXT NOT NULL,
  description MEDIUMTEXT,
  authorised_value_category varchar(16) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY club_template_id (club_template_id),
  CONSTRAINT club_template_fields_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'club_fields'
--

CREATE TABLE IF NOT EXISTS club_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_template_field_id int(11) NOT NULL,
  club_id int(11) NOT NULL,
  `value` MEDIUMTEXT,
  PRIMARY KEY (id),
  KEY club_template_field_id (club_template_field_id),
  KEY club_id (club_id),
  CONSTRAINT club_fields_ibfk_3 FOREIGN KEY (club_template_field_id) REFERENCES club_template_fields (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT club_fields_ibfk_4 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'guarantors_guarantees'
--

DROP TABLE IF EXISTS borrower_relationships;
CREATE TABLE `borrower_relationships` (
      id INT(11) NOT NULL AUTO_INCREMENT,
      guarantor_id INT(11) NULL DEFAULT NULL,
      guarantee_id INT(11) NOT NULL,
      relationship VARCHAR(100) NOT NULL,
      PRIMARY KEY (id),
      UNIQUE KEY `guarantor_guarantee_idx` ( `guarantor_id`, `guarantee_id` ),
      CONSTRAINT r_guarantor FOREIGN KEY ( guarantor_id ) REFERENCES borrowers ( borrowernumber ) ON UPDATE CASCADE ON DELETE CASCADE,
      CONSTRAINT r_guarantee FOREIGN KEY ( guarantee_id ) REFERENCES borrowers ( borrowernumber ) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `illrequests`
--

DROP TABLE IF EXISTS `illrequests`;
CREATE TABLE illrequests (
    illrequest_id serial PRIMARY KEY,           -- ILL request number
    borrowernumber integer DEFAULT NULL,        -- Patron associated with request
    biblio_id integer DEFAULT NULL,             -- Potential bib linked to request
    branchcode varchar(50) NOT NULL,            -- The branch associated with the request
    status varchar(50) DEFAULT NULL,            -- Current Koha status of request
    status_alias varchar(80) DEFAULT NULL,      -- Foreign key to relevant authorised_values.authorised_value
    placed date DEFAULT NULL,                   -- Date the request was placed
    replied date DEFAULT NULL,                  -- Last API response
    updated timestamp DEFAULT CURRENT_TIMESTAMP -- Last modification to request
      ON UPDATE CURRENT_TIMESTAMP,
    completed date DEFAULT NULL,                -- Date the request was completed
    medium varchar(30) DEFAULT NULL,            -- The Koha request type
    accessurl varchar(500) DEFAULT NULL,        -- Potential URL for accessing item
    cost varchar(20) DEFAULT NULL,              -- Quotes cost of request
    price_paid varchar(20) DEFAULT NULL,              -- Final cost of request
    notesopac MEDIUMTEXT DEFAULT NULL,                -- Patron notes attached to request
    notesstaff MEDIUMTEXT DEFAULT NULL,               -- Staff notes attached to request
    orderid varchar(50) DEFAULT NULL,           -- Backend id attached to request
    backend varchar(20) DEFAULT NULL,           -- The backend used to create request
    CONSTRAINT `illrequests_bnfk`
      FOREIGN KEY (`borrowernumber`)
      REFERENCES `borrowers` (`borrowernumber`)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `illrequests_bcfk_2`
      FOREIGN KEY (`branchcode`)
      REFERENCES `branches` (`branchcode`)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `illrequests_safk`
      FOREIGN KEY (`status_alias`)
      REFERENCES `authorised_values` (`authorised_value`)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `illrequestattributes`
--

DROP TABLE IF EXISTS `illrequestattributes`;
CREATE TABLE illrequestattributes (
    illrequest_id bigint(20) unsigned NOT NULL, -- ILL request number
    type varchar(200) NOT NULL,                 -- API ILL property name
    value MEDIUMTEXT NOT NULL,                  -- API ILL property value
    readonly tinyint(1) NOT NULL DEFAULT 1,     -- Is this attribute read only
    PRIMARY KEY  (`illrequest_id`, `type` (191)),
    CONSTRAINT `illrequestattributes_ifk`
      FOREIGN KEY (illrequest_id)
      REFERENCES `illrequests` (`illrequest_id`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'library_groups'
--

DROP TABLE IF EXISTS `library_groups`;
CREATE TABLE library_groups (
    id INT(11) NOT NULL auto_increment,    -- unique id for each group
    parent_id INT(11) NULL DEFAULT NULL,   -- if this is a child group, the id of the parent group
    branchcode VARCHAR(10) NULL DEFAULT NULL, -- The branchcode of a branch belonging to the parent group
    title VARCHAR(100) NULL DEFAULT NULL,     -- Short description of the goup
    description MEDIUMTEXT NULL DEFAULT NULL,    -- Longer explanation of the group, if necessary
    ft_hide_patron_info tinyint(1) NOT NULL DEFAULT 0, -- Turn on the feature "Hide patron's info" for this group
    ft_search_groups_opac tinyint(1) NOT NULL DEFAULT 0, -- Use this group for staff side search groups
    ft_search_groups_staff tinyint(1) NOT NULL DEFAULT 0, -- Use this group for opac side search groups
    ft_local_hold_group tinyint(1) NOT NULL DEFAULT 0, -- Use this group to identify libraries as pick up location for holds
    created_on TIMESTAMP NULL,             -- Date and time of creation
    updated_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Date and time of last
    PRIMARY KEY id ( id ),
    FOREIGN KEY (parent_id) REFERENCES library_groups(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE KEY title ( title ),
    UNIQUE KEY library_groups_uniq_2 ( parent_id, branchcode )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table 'oauth_access_tokens'
--

DROP TABLE IF EXISTS `oauth_access_tokens`;
CREATE TABLE `oauth_access_tokens` (
    `access_token` VARCHAR(191) NOT NULL, -- generarated access token
    `client_id`    VARCHAR(191) NOT NULL, -- the client id the access token belongs to
    `expires`      INT NOT NULL,          -- expiration time in seconds
    PRIMARY KEY (`access_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table illcomments
--

DROP TABLE IF EXISTS `illcomments`;
CREATE TABLE illcomments (
    illcomment_id int(11) NOT NULL AUTO_INCREMENT, -- Unique ID of the comment
    illrequest_id bigint(20) unsigned NOT NULL,    -- ILL request number
    borrowernumber integer DEFAULT NULL,           -- Link to the user who made the comment (could be librarian, patron or ILL partner library)
    comment text DEFAULT NULL,                     -- The text of the comment
    timestamp timestamp DEFAULT CURRENT_TIMESTAMP, -- Date and time when the comment was made
    PRIMARY KEY  ( illcomment_id ),
    CONSTRAINT illcomments_bnfk
      FOREIGN KEY ( borrowernumber )
      REFERENCES  borrowers  ( borrowernumber )
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT illcomments_ifk
      FOREIGN KEY (illrequest_id)
      REFERENCES illrequests ( illrequest_id )
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `circulation_rules`
--

DROP TABLE IF EXISTS `circulation_rules`;
CREATE TABLE `circulation_rules` (
  `id` int(11) NOT NULL auto_increment,
  `branchcode` varchar(10) NULL default NULL,
  `categorycode` varchar(10) NULL default NULL,
  `itemtype` varchar(10) NULL default NULL,
  `rule_name` varchar(32) NOT NULL,
  `rule_value` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `circ_rules_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `circ_rules_ibfk_2` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `circ_rules_ibfk_3` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `rule_name` (`rule_name`),
  UNIQUE (`branchcode`,`categorycode`,`itemtype`,`rule_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `stockrotationrotas`
--

DROP TABLE IF EXISTS stockrotationrotas;
CREATE TABLE stockrotationrotas (
    rota_id int(11) auto_increment,         -- Stockrotation rota ID
    title varchar(100) NOT NULL,            -- Title for this rota
    description text NOT NULL,              -- Description for this rota
    cyclical tinyint(1) NOT NULL default 0, -- Should items on this rota keep cycling?
    active tinyint(1) NOT NULL default 0,   -- Is this rota currently active?
    PRIMARY KEY (`rota_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `stockrotationstages`
--

DROP TABLE IF EXISTS stockrotationstages;
CREATE TABLE stockrotationstages (
    stage_id int(11) auto_increment,     -- Unique stage ID
    position int(11) NOT NULL,           -- The position of this stage within its rota
    rota_id int(11) NOT NULL,            -- The rota this stage belongs to
    branchcode_id varchar(10) NOT NULL,  -- Branch this stage relates to
    duration int(11) NOT NULL default 4, -- The number of days items shoud occupy this stage
    PRIMARY KEY (`stage_id`),
    CONSTRAINT `stockrotationstages_rifk`
      FOREIGN KEY (`rota_id`)
      REFERENCES `stockrotationrotas` (`rota_id`)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `stockrotationstages_bifk`
      FOREIGN KEY (`branchcode_id`)
      REFERENCES `branches` (`branchcode`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `stockrotationitems`
--

DROP TABLE IF EXISTS stockrotationitems;
CREATE TABLE stockrotationitems (
    itemnumber_id int(11) NOT NULL,         -- Itemnumber to link to a stage & rota
    stage_id int(11) NOT NULL,              -- stage ID to link the item to
    indemand tinyint(1) NOT NULL default 0, -- Should this item be skipped for rotation?
    fresh tinyint(1) NOT NULL default 0,    -- Flag showing item is only just added to rota
    PRIMARY KEY (itemnumber_id),
    CONSTRAINT `stockrotationitems_iifk`
      FOREIGN KEY (`itemnumber_id`)
      REFERENCES `items` (`itemnumber`)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `stockrotationitems_sifk`
      FOREIGN KEY (`stage_id`)
      REFERENCES `stockrotationstages` (`stage_id`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `keyboardshortcuts`
--

DROP TABLE IF EXISTS `keyboard_shortcuts`;
CREATE TABLE keyboard_shortcuts (
shortcut_name varchar(80) NOT NULL,
shortcut_keys varchar(80) NOT NULL,
PRIMARY KEY (shortcut_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table itemtypes_branches
--

DROP TABLE IF EXISTS itemtypes_branches;
CREATE TABLE itemtypes_branches( -- association table between authorised_values and branches
    itemtype VARCHAR(10) NOT NULL,
    branchcode VARCHAR(10) NOT NULL,
    FOREIGN KEY (itemtype) REFERENCES itemtypes(itemtype) ON DELETE CASCADE,
    FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `return_claims`
--

DROP TABLE IF EXISTS `return_claims`;
CREATE TABLE return_claims (
    id int(11) auto_increment,                             -- Unique ID of the return claim
    itemnumber int(11) NOT NULL,                           -- ID of the item
    issue_id int(11) NULL DEFAULT NULL,                    -- ID of the checkout that triggered the claim
    borrowernumber int(11) NOT NULL,                       -- ID of the patron
    notes MEDIUMTEXT DEFAULT NULL,                         -- Notes about the claim
    created_on TIMESTAMP NULL,                             -- Time and date the claim was created
    created_by int(11) NULL DEFAULT NULL,                  -- ID of the staff member that registered the claim
    updated_on TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- Time and date of the latest change on the claim (notes)
    updated_by int(11) NULL DEFAULT NULL,                  -- ID of the staff member that updated the claim
    resolution  varchar(80) NULL DEFAULT NULL,             -- Resolution code (RETURN_CLAIM_RESOLUTION AVs)
    resolved_on TIMESTAMP NULL DEFAULT NULL,               -- Time and date the claim was resolved
    resolved_by int(11) NULL DEFAULT NULL,                 -- ID of the staff member that resolved the claim
    PRIMARY KEY (`id`),
    KEY `itemnumber` (`itemnumber`),
    CONSTRAINT UNIQUE `issue_id` ( issue_id ),
    CONSTRAINT `issue_id` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`issue_id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `rc_items_ibfk` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `rc_borrowers_ibfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `rc_created_by_ibfk` FOREIGN KEY (`created_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `rc_updated_by_ibfk` FOREIGN KEY (`updated_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `rc_resolved_by_ibfk` FOREIGN KEY (`resolved_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `problem_reports`
--

DROP TABLE IF EXISTS `problem_reports`;
CREATE TABLE `problem_reports` (
    `reportid` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
    `title` varchar(40) NOT NULL default '', -- report subject line
    `content` varchar(255) NOT NULL default '', -- report message content
    `borrowernumber` int(11) NOT NULL default 0, -- the user who created the problem report
    `branchcode` varchar(10) NOT NULL default '', -- borrower's branch
    `username` varchar(75) default NULL, -- OPAC username
    `problempage` TEXT default NULL, -- page the user triggered the problem report form from
    `recipient` enum('admin','library') NOT NULL default 'library', -- the 'to-address' of the problem report
    `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, -- timestamp of report submission
    `status` varchar(6) NOT NULL default 'New', -- status of the report. New, Viewed, Closed
    PRIMARY KEY (`reportid`),
    CONSTRAINT `problem_reports_ibfk1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `problem_reports_ibfk2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table advanced_editor_macros
--

DROP TABLE IF EXISTS advanced_editor_macros;
CREATE TABLE advanced_editor_macros (
    id INT(11) NOT NULL AUTO_INCREMENT,     -- Unique ID of the macro
    name varchar(80) NOT NULL,              -- Name of the macro
    macro longtext NULL,                    -- The macro code itself
    borrowernumber INT(11) default NULL,    -- ID of the borrower who created this macro
    shared TINYINT(1) default 0,            -- Bit to define if shared or private macro
    PRIMARY KEY (id),
    CONSTRAINT borrower_macro_fk FOREIGN KEY ( borrowernumber ) REFERENCES borrowers ( borrowernumber ) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
