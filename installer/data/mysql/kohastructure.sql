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
  `frameworkcode` varchar(10) NOT NULL default '',
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
CREATE TABLE `authorised_values` ( -- stores values for authorized values categories and values
  `id` int(11) NOT NULL auto_increment, -- unique key, used to identify the authorized value
  `category` varchar(16) NOT NULL default '', -- key used to identify the authorized value category
  `authorised_value` varchar(80) NOT NULL default '', -- code use to identify the authorized value
  `lib` varchar(200) default NULL, -- authorized value description as printed in the staff client
  `lib_opac` varchar(200) default NULL, -- authorized value description as printed in the OPAC
  `imageurl` varchar(200) default NULL, -- authorized value URL
  PRIMARY KEY  (`id`),
  KEY `name` (`category`),
  KEY `lib` (`lib`),
  KEY `auth_value_idx` (`authorised_value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `biblio`
--

DROP TABLE IF EXISTS `biblio`;
CREATE TABLE `biblio` ( -- table that stores bibliographic information
  `biblionumber` int(11) NOT NULL auto_increment, -- unique identifier assigned to each bibliographic record
  `frameworkcode` varchar(4) NOT NULL default '', -- foriegn key from the biblio_framework table to identify which framework was used in cataloging this record
  `author` mediumtext, -- statement of responsibility from MARC record (100$a in MARC21)
  `title` mediumtext, -- title (without the subtitle) from the MARC record (245$a in MARC21)
  `unititle` mediumtext, -- uniform title (without the subtitle) from the MARC record (240$a in MARC21)
  `notes` mediumtext, -- values from the general notes field in the MARC record (500$a in MARC21) split by bar (|)
  `serial` tinyint(1) default NULL, -- foreign key, linking to the subscriptionid in the serial table
  `seriestitle` mediumtext,
  `copyrightdate` smallint(6) default NULL, -- publication or copyright date from the MARC record
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this record was last touched
  `datecreated` DATE NOT NULL, -- the date this record was added to Koha
  `abstract` mediumtext, -- summary from the MARC record (520$a in MARC21)
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `biblio_framework`
--

DROP TABLE IF EXISTS `biblio_framework`;
CREATE TABLE `biblio_framework` ( -- information about MARC frameworks
  `frameworkcode` varchar(4) NOT NULL default '', -- the unique code assigned to the framework
  `frameworktext` varchar(255) NOT NULL default '', -- the description/name given to the framework
  PRIMARY KEY  (`frameworkcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `biblioitems`
--

DROP TABLE IF EXISTS `biblioitems`;
CREATE TABLE `biblioitems` ( -- information related to bibliographic records in Koha
  `biblioitemnumber` int(11) NOT NULL auto_increment, -- primary key, unique identifier assigned by Koha
  `biblionumber` int(11) NOT NULL default 0, -- foreign key linking this table to the biblio table
  `volume` mediumtext,
  `number` mediumtext,
  `itemtype` varchar(10) default NULL, -- biblio level item type (MARC21 942$c)
  `isbn` varchar(30) default NULL, -- ISBN (MARC21 020$a)
  `issn` varchar(9) default NULL, -- ISSN (MARC21 022$a)
  `ean` varchar(13) default NULL,
  `publicationyear` text,
  `publishercode` varchar(255) default NULL, -- publisher (MARC21 260$b)
  `volumedate` date default NULL,
  `volumedesc` text, -- volume information (MARC21 362$a)
  `collectiontitle` mediumtext default NULL,
  `collectionissn` text default NULL,
  `collectionvolume` mediumtext default NULL,
  `editionstatement` text default NULL,
  `editionresponsibility` text default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL, -- illustrations (MARC21 300$b)
  `pages` varchar(255) default NULL, -- number of pages (MARC21 300$c)
  `notes` mediumtext,
  `size` varchar(255) default NULL, -- material size (MARC21 300$c)
  `place` varchar(255) default NULL, -- publication place (MARC21 260$a)
  `lccn` varchar(25) default NULL, -- library of congress control number (MARC21 010$a)
  `marc` longblob, -- full bibliographic MARC record
  `url` varchar(255) default NULL, -- url (MARC21 856$u)
  `cn_source` varchar(10) default NULL, -- classification source (MARC21 942$2)
  `cn_class` varchar(30) default NULL,
  `cn_item` varchar(10) default NULL,
  `cn_suffix` varchar(10) default NULL,
  `cn_sort` varchar(30) default NULL,
  `agerestriction` varchar(255) default NULL,
  `totalissues` int(10),
  `marcxml` longtext NOT NULL, -- full bibliographic MARC record in MARCXML
  PRIMARY KEY  (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `isbn` (`isbn`),
  KEY `issn` (`issn`),
  KEY `publishercode` (`publishercode`),
  CONSTRAINT `biblioitems_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `borrowers`
--

DROP TABLE IF EXISTS `borrowers`;
CREATE TABLE `borrowers` ( -- this table includes information about your patrons/borrowers/members
  `borrowernumber` int(11) NOT NULL auto_increment, -- primary key, Koha assigned ID number for patrons/borrowers
  `cardnumber` varchar(16) default NULL, -- unique key, library assigned ID number for patrons/borrowers
  `surname` mediumtext NOT NULL, -- patron/borrower's last name (surname)
  `firstname` text, -- patron/borrower's first name
  `title` mediumtext, -- patron/borrower's title, for example: Mr. or Mrs.
  `othernames` mediumtext, -- any other names associated with the patron/borrower
  `initials` text, -- initials for your patron/borrower
  `streetnumber` varchar(10) default NULL, -- the house number for your patron/borrower's primary address
  `streettype` varchar(50) default NULL, -- the street type (Rd., Blvd, etc) for your patron/borrower's primary address
  `address` mediumtext NOT NULL, -- the first address line for your patron/borrower's primary address
  `address2` text, -- the second address line for your patron/borrower's primary address
  `city` mediumtext NOT NULL, -- the city or town for your patron/borrower's primary address
  `state` text default NULL, -- the state or province for your patron/borrower's primary address
  `zipcode` varchar(25) default NULL, -- the zip or postal code for your patron/borrower's primary address
  `country` text, -- the country for your patron/borrower's primary address
  `email` mediumtext, -- the primary email address for your patron/borrower's primary address
  `phone` text, -- the primary phone number for your patron/borrower's primary address
  `mobile` varchar(50) default NULL, -- the other phone number for your patron/borrower's primary address
  `fax` mediumtext, -- the fax number for your patron/borrower's primary address
  `emailpro` text, -- the secondary email addres for your patron/borrower's primary address
  `phonepro` text, -- the secondary phone number for your patron/borrower's primary address
  `B_streetnumber` varchar(10) default NULL, -- the house number for your patron/borrower's alternate address
  `B_streettype` varchar(50) default NULL, -- the street type (Rd., Blvd, etc) for your patron/borrower's alternate address
  `B_address` varchar(100) default NULL, -- the first address line for your patron/borrower's alternate address
  `B_address2` text default NULL, -- the second address line for your patron/borrower's alternate address
  `B_city` mediumtext, -- the city or town for your patron/borrower's alternate address
  `B_state` text default NULL, -- the state for your patron/borrower's alternate address
  `B_zipcode` varchar(25) default NULL, -- the zip or postal code for your patron/borrower's alternate address
  `B_country` text, -- the country for your patron/borrower's alternate address
  `B_email` text, -- the patron/borrower's alternate email address
  `B_phone` mediumtext, -- the patron/borrower's alternate phone number
  `dateofbirth` date default NULL, -- the patron/borrower's date of birth (YYYY-MM-DD)
  `branchcode` varchar(10) NOT NULL default '', -- foreign key from the branches table, includes the code of the patron/borrower's home branch
  `categorycode` varchar(10) NOT NULL default '', -- foreign key from the categories table, includes the code of the patron category
  `dateenrolled` date default NULL, -- date the patron was added to Koha (YYYY-MM-DD)
  `dateexpiry` date default NULL, -- date the patron/borrower's card is set to expire (YYYY-MM-DD)
  `gonenoaddress` tinyint(1) default NULL, -- set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having an unconfirmed address
  `lost` tinyint(1) default NULL, -- set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having lost their card
  `debarred` date default NULL, -- until this date the patron can only check-in (no loans, no holds, etc.), is a fine based on days instead of money (YYY-MM-DD)
  `debarredcomment` VARCHAR(255) DEFAULT NULL, -- comment on the stop of the patron
  `contactname` mediumtext, -- used for children and profesionals to include surname or last name of guarentor or organization name
  `contactfirstname` text, -- used for children to include first name of guarentor
  `contacttitle` text, -- used for children to include title (Mr., Mrs., etc) of guarentor
  `guarantorid` int(11) default NULL, -- borrowernumber used for children or professionals to link them to guarentors or organizations
  `borrowernotes` mediumtext, -- a note on the patron/borroewr's account that is only visible in the staff client
  `relationship` varchar(100) default NULL, -- used for children to include the relationship to their guarentor
  `ethnicity` varchar(50) default NULL, -- unused in Koha
  `ethnotes` varchar(255) default NULL, -- unused in Koha
  `sex` varchar(1) default NULL, -- patron/borrower's gender
  `password` varchar(30) default NULL, -- patron/borrower's encrypted password
  `flags` int(11) default NULL, -- will include a number associated with the staff member's permissions
  `userid` varchar(75) default NULL, -- patron/borrower's opac and/or staff client log in
  `opacnote` mediumtext, -- a note on the patron/borrower's account that is visible in the OPAC and staff client
  `contactnote` varchar(255) default NULL, -- a note related to the patron/borrower's alternate address
  `sort1` varchar(80) default NULL, -- a field that can be used for any information unique to the library
  `sort2` varchar(80) default NULL, -- a field that can be used for any information unique to the library
  `altcontactfirstname` varchar(255) default NULL, -- first name of alternate contact for the patron/borrower
  `altcontactsurname` varchar(255) default NULL, -- surname or last name of the alternate contact for the patron/borrower
  `altcontactaddress1` varchar(255) default NULL, -- the first address line for the alternate contact for the patron/borrower
  `altcontactaddress2` varchar(255) default NULL, -- the second address line for the alternate contact for the patron/borrower
  `altcontactaddress3` varchar(255) default NULL, -- the third address line for the alternate contact for the patron/borrower
  `altcontactstate` text default NULL, -- the city and state for the alternate contact for the patron/borrower
  `altcontactzipcode` varchar(50) default NULL, -- the zipcode for the alternate contact for the patron/borrower
  `altcontactcountry` text default NULL, -- the country for the alternate contact for the patron/borrower
  `altcontactphone` varchar(50) default NULL, -- the phone number for the alternate contact for the patron/borrower
  `smsalertnumber` varchar(50) default NULL, -- the mobile phone number where the patron/borrower would like to receive notices (if SNS turned on)
  `privacy` integer(11) DEFAULT '1' NOT NULL, -- patron/borrower's privacy settings related to their reading history
  UNIQUE KEY `cardnumber` (`cardnumber`),
  PRIMARY KEY `borrowernumber` (`borrowernumber`),
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`),
  KEY `userid` (`userid`),
  KEY `guarantorid` (`guarantorid`),
  CONSTRAINT `borrowers_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`),
  CONSTRAINT `borrowers_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `password_allowed` tinyint(1) NOT NULL default 0, -- defines if it is possible to associate a password with this custom field (1 for yes, 0 for no)
  `staff_searchable` tinyint(1) NOT NULL default 0, -- defines if this field is searchable via the patron search in the staff client (1 for yes, 0 for no)
  `authorised_value_category` varchar(10) default NULL, -- foreign key from authorised_values that links this custom field to an authorized value category
  `display_checkout` tinyint(1) NOT NULL default 0,-- defines if this field displays in checkout screens
  `category_code` VARCHAR(10) NULL DEFAULT NULL,-- defines a category for an attribute_type
  `class` VARCHAR(255) NOT NULL DEFAULT '',-- defines a class for an attribute_type
  PRIMARY KEY  (`code`),
  KEY `auth_val_cat_idx` (`authorised_value_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `borrower_attributes`
--

DROP TABLE IF EXISTS `borrower_attributes`;
CREATE TABLE `borrower_attributes` ( -- values of custom patron fields known as extended patron attributes linked to patrons/borrowers
  `borrowernumber` int(11) NOT NULL, -- foreign key from the borrowers table, defines which patron/borrower has this attribute
  `code` varchar(10) NOT NULL, -- foreign key from the borrower_attribute_types table, defines which custom field this value was entered for
  `attribute` varchar(255) default NULL, -- custom patron field value
  `password` varchar(64) default NULL, -- password associated with this field
  KEY `borrowernumber` (`borrowernumber`),
  KEY `code_attribute` (`code`, `attribute`),
  CONSTRAINT `borrower_attributes_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_attributes_ibfk_2` FOREIGN KEY (`code`) REFERENCES `borrower_attribute_types` (`code`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `branch_item_rules`
--

DROP TABLE IF EXISTS `branch_item_rules`;
CREATE TABLE `branch_item_rules` ( -- information entered in the circulation and fine rules under 'Holds policy by item type'
  `branchcode` varchar(10) NOT NULL, -- the branch this rule is for (branches.branchcode)
  `itemtype` varchar(10) NOT NULL, -- the item type this rule applies to (items.itype)
  `holdallowed` tinyint(1) default NULL, -- the number of holds allowed
  `returnbranch` varchar(15) default NULL, -- the branch the item returns to (homebranch, holdingbranch, noreturn)
  PRIMARY KEY  (`itemtype`,`branchcode`),
  KEY `branch_item_rules_ibfk_2` (`branchcode`),
  CONSTRAINT `branch_item_rules_ibfk_1` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branch_item_rules_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `branchcategories`
--

DROP TABLE IF EXISTS `branchcategories`;
CREATE TABLE `branchcategories` ( -- information related to library/branch groups
  `categorycode` varchar(10) NOT NULL default '', -- unique identifier for the library/branch group
  `categoryname` varchar(32), -- name of the library/branch group
  `codedescription` mediumtext, -- longer description of the library/branch group
  `categorytype` varchar(16), -- says whether this is a search group or a properties group
  PRIMARY KEY  (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
CREATE TABLE `branches` ( -- information about your libraries or branches are stored here
  `branchcode` varchar(10) NOT NULL default '', -- a unique key assigned to each branch
  `branchname` mediumtext NOT NULL, -- the name of your library or branch
  `branchaddress1` mediumtext, -- the first address line of for your library or branch
  `branchaddress2` mediumtext, -- the second address line of for your library or branch
  `branchaddress3` mediumtext, -- the third address line of for your library or branch
  `branchzip` varchar(25) default NULL, -- the zip or postal code for your library or branch
  `branchcity` mediumtext, -- the city or province for your library or branch
  `branchstate` mediumtext, -- the state for your library or branch
  `branchcountry` text, -- the county for your library or branch
  `branchphone` mediumtext, -- the primary phone for your library or branch
  `branchfax` mediumtext, -- the fax number for your library or branch
  `branchemail` mediumtext, -- the primary email address for your library or branch
  `branchurl` mediumtext, -- the URL for your library or branch's website
  `issuing` tinyint(4) default NULL, -- unused in Koha
  `branchip` varchar(15) default NULL, -- the IP address for your library or branch
  `branchprinter` varchar(100) default NULL, -- unused in Koha
  `branchnotes` mediumtext, -- notes related to your library or branch
  opac_info text, -- HTML that displays in OPAC
  PRIMARY KEY (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `branchrelations`
--

DROP TABLE IF EXISTS `branchrelations`;
CREATE TABLE `branchrelations` ( -- this table links libraries/branches to groups
  `branchcode` varchar(10) NOT NULL default '', -- foreign key from the branches table to identify the branch
  `categorycode` varchar(10) NOT NULL default '', -- foreign key from the branchcategories table to identify the group
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
CREATE TABLE `branchtransfers` ( -- information for items that are in transit between branches
  `itemnumber` int(11) NOT NULL default 0, -- the itemnumber that it is in transit (items.itemnumber)
  `datesent` datetime default NULL, -- the date the transfer was initialized
  `frombranch` varchar(10) NOT NULL default '', -- the branch the transfer is coming from
  `datearrived` datetime default NULL, -- the date the transfer arrived at its destination
  `tobranch` varchar(10) NOT NULL default '', -- the branch the transfer was going to
  `comments` mediumtext, -- any comments related to the transfer
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
CREATE TABLE `categories` ( -- this table shows information related to Koha patron categories
  `categorycode` varchar(10) NOT NULL default '', -- unique primary key used to idenfity the patron category
  `description` mediumtext, -- description of the patron category
  `enrolmentperiod` smallint(6) default NULL, -- number of months the patron is enrolled for (will be NULL if enrolmentperioddate is set)
  `enrolmentperioddate` DATE NULL DEFAULT NULL, -- date the patron is enrolled until (will be NULL if enrolmentperiod is set)
  `upperagelimit` smallint(6) default NULL, -- age limit for the patron
  `dateofbirthrequired` tinyint(1) default NULL,
  `finetype` varchar(30) default NULL, -- unused in Koha
  `bulk` tinyint(1) default NULL,
  `enrolmentfee` decimal(28,6) default NULL, -- enrollment fee for the patron
  `overduenoticerequired` tinyint(1) default NULL, -- are overdue notices sent to this patron category (1 for yes, 0 for no)
  `issuelimit` smallint(6) default NULL, -- unused in Koha
  `reservefee` decimal(28,6) default NULL, -- cost to place holds
  `hidelostitems` tinyint(1) NOT NULL default '0', -- are lost items shown to this category (1 for yes, 0 for no)
  `category_type` varchar(1) NOT NULL default 'A', -- type of Koha patron (Adult, Child, Professional, Organizational, Statistical, Staff)
  PRIMARY KEY  (`categorycode`),
  UNIQUE KEY `categorycode` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table: collections
--
DROP TABLE IF EXISTS collections;
CREATE TABLE collections (
  colId integer(11) NOT NULL auto_increment,
  colTitle varchar(100) NOT NULL DEFAULT '',
  colDesc text NOT NULL,
  colBranchcode varchar(4) DEFAULT NULL comment 'branchcode for branch where item should be held.',
  PRIMARY KEY (colId)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table: collections_tracking
--
DROP TABLE IF EXISTS collections_tracking;
CREATE TABLE collections_tracking (
  ctId integer(11) NOT NULL auto_increment,
  colId integer(11) NOT NULL DEFAULT 0 comment 'collections.colId',
  itemnumber integer(11) NOT NULL DEFAULT 0 comment 'items.itemnumber',
  PRIMARY KEY (ctId)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `borrower_branch_circ_rules`
--

DROP TABLE IF EXISTS `branch_borrower_circ_rules`;
CREATE TABLE `branch_borrower_circ_rules` ( -- includes default circulation rules for patron categories found under "Checkout limit by patron category"
  `branchcode` VARCHAR(10) NOT NULL, -- the branch this rule applies to (branches.branchcode)
  `categorycode` VARCHAR(10) NOT NULL, -- the patron category this rule applies to (categories.categorycode)
  `maxissueqty` int(4) default NULL, -- the maximum number of checkouts this patron category can have at this branch
  PRIMARY KEY (`categorycode`, `branchcode`),
  CONSTRAINT `branch_borrower_circ_rules_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branch_borrower_circ_rules_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `default_borrower_circ_rules`
--

DROP TABLE IF EXISTS `default_borrower_circ_rules`;
CREATE TABLE `default_borrower_circ_rules` ( -- default checkout rules found under "Default checkout, hold and return policy"
  `categorycode` VARCHAR(10) NOT NULL, -- patron category this rul
  `maxissueqty` int(4) default NULL,
  PRIMARY KEY (`categorycode`),
  CONSTRAINT `borrower_borrower_circ_rules_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `default_branch_circ_rules`
--

DROP TABLE IF EXISTS `default_branch_circ_rules`;
CREATE TABLE `default_branch_circ_rules` (
  `branchcode` VARCHAR(10) NOT NULL,
  `maxissueqty` int(4) default NULL,
  `holdallowed` tinyint(1) default NULL,
  `returnbranch` varchar(15) default NULL,
  PRIMARY KEY (`branchcode`),
  CONSTRAINT `default_branch_circ_rules_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `default_branch_item_rules`
--
DROP TABLE IF EXISTS `default_branch_item_rules`;
CREATE TABLE `default_branch_item_rules` (
  `itemtype` varchar(10) NOT NULL,
  `holdallowed` tinyint(1) default NULL,
  `returnbranch` varchar(15) default NULL,
  PRIMARY KEY  (`itemtype`),
  CONSTRAINT `default_branch_item_rules_ibfk_1` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `default_circ_rules`
--

DROP TABLE IF EXISTS `default_circ_rules`;
CREATE TABLE `default_circ_rules` (
    `singleton` enum('singleton') NOT NULL default 'singleton',
    `maxissueqty` int(4) default NULL,
    `holdallowed` int(1) default NULL,
    `returnbranch` varchar(15) default NULL,
    PRIMARY KEY (`singleton`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `rate` float(15,5) default NULL,
  `active` tinyint(1) default NULL,
  PRIMARY KEY  (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `deletedbiblio`
--

DROP TABLE IF EXISTS `deletedbiblio`;
CREATE TABLE `deletedbiblio` ( -- stores information about bibliographic records that have been deleted
  `biblionumber` int(11) NOT NULL auto_increment, -- unique identifier assigned to each bibliographic record
  `frameworkcode` varchar(4) NOT NULL default '', -- foriegn key from the biblio_framework table to identify which framework was used in cataloging this record
  `author` mediumtext, -- statement of responsibility from MARC record (100$a in MARC21)
  `title` mediumtext, -- title (without the subtitle) from the MARC record (245$a in MARC21)
  `unititle` mediumtext, -- uniform title (without the subtitle) from the MARC record (240$a in MARC21)
  `notes` mediumtext, -- values from the general notes field in the MARC record (500$a in MARC21) split by bar (|)
  `serial` tinyint(1) default NULL, -- foreign key, linking to the subscriptionid in the serial table
  `seriestitle` mediumtext,
  `copyrightdate` smallint(6) default NULL, -- publication or copyright date from the MARC record
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this record was last touched
  `datecreated` DATE NOT NULL, -- the date this record was added to Koha
  `abstract` mediumtext, -- summary from the MARC record (520$a in MARC21)
  PRIMARY KEY  (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `deletedbiblioitems`
--

DROP TABLE IF EXISTS `deletedbiblioitems`;
CREATE TABLE `deletedbiblioitems` ( -- information about bibliographic records that have been deleted
  `biblioitemnumber` int(11) NOT NULL default 0, -- primary key, unique identifier assigned by Koha
  `biblionumber` int(11) NOT NULL default 0, -- foreign key linking this table to the biblio table
  `volume` mediumtext,
  `number` mediumtext,
  `itemtype` varchar(10) default NULL, -- biblio level item type (MARC21 942$c)
  `isbn` varchar(30) default NULL, -- ISBN (MARC21 020$a)
  `issn` varchar(9) default NULL, -- ISSN (MARC21 022$a)
  `ean` varchar(13) default NULL,
  `publicationyear` text,
  `publishercode` varchar(255) default NULL, -- publisher (MARC21 260$b)
  `volumedate` date default NULL,
  `volumedesc` text, -- volume information (MARC21 362$a)
  `collectiontitle` mediumtext default NULL,
  `collectionissn` text default NULL,
  `collectionvolume` mediumtext default NULL,
  `editionstatement` text default NULL,
  `editionresponsibility` text default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `illus` varchar(255) default NULL, -- illustrations (MARC21 300$b)
  `pages` varchar(255) default NULL, -- number of pages (MARC21 300$c)
  `notes` mediumtext,
  `size` varchar(255) default NULL, -- material size (MARC21 300$c)
  `place` varchar(255) default NULL, -- publication place (MARC21 260$a)
  `lccn` varchar(25) default NULL, -- library of congress control number (MARC21 010$a)
  `marc` longblob, -- full bibliographic MARC record
  `url` varchar(255) default NULL, -- url (MARC21 856$u)
  `cn_source` varchar(10) default NULL, -- classification source (MARC21 942$2)
  `cn_class` varchar(30) default NULL,
  `cn_item` varchar(10) default NULL,
  `cn_suffix` varchar(10) default NULL,
  `cn_sort` varchar(30) default NULL,
  `agerestriction` varchar(255) default NULL,
  `totalissues` int(10),
  `marcxml` longtext NOT NULL, -- full bibliographic MARC record in MARCXML
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
CREATE TABLE `deletedborrowers` ( -- stores data related to the patrons/borrowers you have deleted
  `borrowernumber` int(11) NOT NULL default 0, -- primary key, Koha assigned ID number for patrons/borrowers
  `cardnumber` varchar(16) default NULL, -- unique key, library assigned ID number for patrons/borrowers
  `surname` mediumtext NOT NULL, -- patron/borrower's last name (surname)
  `firstname` text, -- patron/borrower's first name
  `title` mediumtext, -- patron/borrower's title, for example: Mr. or Mrs.
  `othernames` mediumtext, -- any other names associated with the patron/borrower
  `initials` text, -- initials for your patron/borrower
  `streetnumber` varchar(10) default NULL, -- the house number for your patron/borrower's primary address
  `streettype` varchar(50) default NULL, -- the street type (Rd., Blvd, etc) for your patron/borrower's primary address
  `address` mediumtext NOT NULL, -- the first address line for your patron/borrower's primary address
  `address2` text, -- the second address line for your patron/borrower's primary address
  `city` mediumtext NOT NULL, -- the city or town for your patron/borrower's primary address
  `state` text default NULL, -- the state or province for your patron/borrower's primary address
  `zipcode` varchar(25) default NULL, -- the zip or postal code for your patron/borrower's primary address
  `country` text, -- the country for your patron/borrower's primary address
  `email` mediumtext, -- the primary email address for your patron/borrower's primary address
  `phone` text, -- the primary phone number for your patron/borrower's primary address
  `mobile` varchar(50) default NULL, -- the other phone number for your patron/borrower's primary address
  `fax` mediumtext, -- the fax number for your patron/borrower's primary address
  `emailpro` text, -- the secondary email addres for your patron/borrower's primary address
  `phonepro` text, -- the secondary phone number for your patron/borrower's primary address
  `B_streetnumber` varchar(10) default NULL, -- the house number for your patron/borrower's alternate address
  `B_streettype` varchar(50) default NULL, -- the street type (Rd., Blvd, etc) for your patron/borrower's alternate address
  `B_address` varchar(100) default NULL, -- the first address line for your patron/borrower's alternate address
  `B_address2` text default NULL, -- the second address line for your patron/borrower's alternate address
  `B_city` mediumtext, -- the city or town for your patron/borrower's alternate address
  `B_state` text default NULL, -- the state for your patron/borrower's alternate address
  `B_zipcode` varchar(25) default NULL, -- the zip or postal code for your patron/borrower's alternate address
  `B_country` text, -- the country for your patron/borrower's alternate address
  `B_email` text, -- the patron/borrower's alternate email address
  `B_phone` mediumtext, -- the patron/borrower's alternate phone number
  `dateofbirth` date default NULL, -- the patron/borrower's date of birth (YYYY-MM-DD)
  `branchcode` varchar(10) NOT NULL default '', -- foreign key from the branches table, includes the code of the patron/borrower's home branch
  `categorycode` varchar(10) NOT NULL default '', -- foreign key from the categories table, includes the code of the patron category
  `dateenrolled` date default NULL, -- date the patron was added to Koha (YYYY-MM-DD)
  `dateexpiry` date default NULL, -- date the patron/borrower's card is set to expire (YYYY-MM-DD)
  `gonenoaddress` tinyint(1) default NULL, -- set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having an unconfirmed address
  `lost` tinyint(1) default NULL, -- set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having lost their card
  `debarred` date default NULL, -- until this date the patron can only check-in (no loans, no holds, etc.), is a fine based on days instead of money (YYY-MM-DD)
  `debarredcomment` VARCHAR(255) DEFAULT NULL, -- comment on the stop of patron
  `contactname` mediumtext, -- used for children and profesionals to include surname or last name of guarentor or organization name
  `contactfirstname` text, -- used for children to include first name of guarentor
  `contacttitle` text, -- used for children to include title (Mr., Mrs., etc) of guarentor
  `guarantorid` int(11) default NULL, -- borrowernumber used for children or professionals to link them to guarentors or organizations
  `borrowernotes` mediumtext, -- a note on the patron/borroewr's account that is only visible in the staff client
  `relationship` varchar(100) default NULL, -- used for children to include the relationship to their guarentor
  `ethnicity` varchar(50) default NULL, -- unused in Koha
  `ethnotes` varchar(255) default NULL, -- unused in Koha
  `sex` varchar(1) default NULL, -- patron/borrower's gender
  `password` varchar(30) default NULL, -- patron/borrower's encrypted password
  `flags` int(11) default NULL, -- will include a number associated with the staff member's permissions
  `userid` varchar(30) default NULL, -- patron/borrower's opac and/or staff client log in
  `opacnote` mediumtext, -- a note on the patron/borrower's account that is visible in the OPAC and staff client
  `contactnote` varchar(255) default NULL, -- a note related to the patron/borrower's alternate address
  `sort1` varchar(80) default NULL, -- a field that can be used for any information unique to the library
  `sort2` varchar(80) default NULL, -- a field that can be used for any information unique to the library
  `altcontactfirstname` varchar(255) default NULL, -- first name of alternate contact for the patron/borrower
  `altcontactsurname` varchar(255) default NULL, -- surname or last name of the alternate contact for the patron/borrower
  `altcontactaddress1` varchar(255) default NULL, -- the first address line for the alternate contact for the patron/borrower
  `altcontactaddress2` varchar(255) default NULL, -- the second address line for the alternate contact for the patron/borrower
  `altcontactaddress3` varchar(255) default NULL, -- the third address line for the alternate contact for the patron/borrower
  `altcontactstate` text default NULL, -- the city and state for the alternate contact for the patron/borrower
  `altcontactzipcode` varchar(50) default NULL, -- the zipcode for the alternate contact for the patron/borrower
  `altcontactcountry` text default NULL, -- the country for the alternate contact for the patron/borrower
  `altcontactphone` varchar(50) default NULL, -- the phone number for the alternate contact for the patron/borrower
  `smsalertnumber` varchar(50) default NULL, -- the mobile phone number where the patron/borrower would like to receive notices (if SNS turned on)
  `privacy` integer(11) DEFAULT '1' NOT NULL, -- patron/borrower's privacy settings related to their reading history  KEY `borrowernumber` (`borrowernumber`),
  KEY borrowernumber (borrowernumber),
  KEY `cardnumber` (`cardnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `booksellerid` mediumtext default NULL, -- where the item was purchased (MARC21 952$e)
  `homebranch` varchar(10) default NULL, -- foreign key from the branches table for the library that owns this item (MARC21 952$a)
  `price` decimal(8,2) default NULL, -- purchase price (MARC21 952$g)
  `replacementprice` decimal(8,2) default NULL, -- cost the library charges to replace the item if it has been marked lost (MARC21 952$v)
  `replacementpricedate` date default NULL, -- the date the price is effective from (MARC21 952$w)
  `datelastborrowed` date default NULL, -- the date the item was last checked out
  `datelastseen` date default NULL, -- the date the item was last see (usually the last time the barcode was scanned or inventory was done)
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) NOT NULL default 0, -- authorized value defining why this item is not for loan (MARC21 952$7)
  `damaged` tinyint(1) NOT NULL default 0, -- authorized value defining this item as damaged (MARC21 952$4)
  `itemlost` tinyint(1) NOT NULL default 0, -- authorized value defining this item as lost (MARC21 952$1)
  `wthdrawn` tinyint(1) NOT NULL default 0, -- authorized value defining this item as withdrawn (MARC21 952$0)
  `itemcallnumber` varchar(255) default NULL, -- call number for this item (MARC21 952$o)
  `issues` smallint(6) default NULL, -- number of times this item has been checked out
  `renewals` smallint(6) default NULL, -- number of times this item has been renewed
  `reserves` smallint(6) default NULL, -- number of times this item has been placed on hold/reserved
  `restricted` tinyint(1) default NULL, -- authorized value defining use restrictions for this item (MARC21 952$5)
  `itemnotes` mediumtext, -- public notes on this item (MARC21 952$x)
  `holdingbranch` varchar(10) default NULL, -- foreign key from the branches table for the library that is currently in possession item (MARC21 952$b)
  `paidfor` mediumtext,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this item was last altered
  `location` varchar(80) default NULL, -- authorized value for the shelving location for this item (MARC21 952$c)
  `permanent_location` varchar(80) default NULL, -- linked to the CART and PROC temporary locations feature, stores the permanent shelving location
  `onloan` date default NULL, -- defines if item is checked out (NULL for not checked out, and checkout date for checked out)
  `cn_source` varchar(10) default NULL, -- classification source used on this item (MARC21 952$2)
  `cn_sort` varchar(30) default NULL, -- normalized form of the call number (MARC21 952$o) used for sorting
  `ccode` varchar(10) default NULL, -- authorized value for the collection code associated with this item (MARC21 952$8)
  `materials` varchar(10) default NULL, -- materials specified (MARC21 952$3)
  `uri` varchar(255) default NULL, -- URL for the item (MARC21 952$u)
  `itype` varchar(10) default NULL, -- foreign key from the itemtypes table defining the type for this item (MARC21 952$y)
  `more_subfields_xml` longtext default NULL, -- additional 952 subfields in XML format
  `enumchron` text default NULL, -- serial enumeration/chronology for the item (MARC21 952$h)
  `copynumber` varchar(32) default NULL, -- copy number (MARC21 952$t)
  `stocknumber` varchar(32) default NULL, -- inventory number (MARC21 952$i)
  `marc` longblob, -- unused in Koha
  PRIMARY KEY  (`itemnumber`),
  KEY `delitembarcodeidx` (`barcode`),
  KEY `delitemstocknumberidx` (`stocknumber`),
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
-- Table structure for table `export_format`
--

DROP TABLE IF EXISTS `export_format`;
CREATE TABLE `export_format` (
  `export_format_id` int(11) NOT NULL auto_increment,
  `profile` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  `marcfields` mediumtext NOT NULL,
  `csv_separator` varchar(2) NOT NULL,
  `field_separator` varchar(2) NOT NULL,
  `subfield_separator` varchar(2) NOT NULL,
  `encoding` varchar(255) NOT NULL,
  PRIMARY KEY  (`export_format_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Used for CSV export';


--
-- Table structure for table `hold_fill_targets`
--

DROP TABLE IF EXISTS `hold_fill_targets`;
CREATE TABLE hold_fill_targets (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `item_action` enum('always_add', 'add_only_for_matches', 'add_only_for_new', 'ignore') NOT NULL default 'always_add', -- what to do with item records
  `import_status` enum('staging', 'staged', 'importing', 'imported', 'reverting', 'reverted', 'cleaned') NOT NULL default 'staging', -- the status of the imported file
  `batch_type` enum('batch', 'z3950', 'webservice') NOT NULL default 'batch', -- where this batch has come from
  `record_type` enum('biblio', 'auth', 'holdings') NOT NULL default 'biblio', -- type of record in the batch
  `file_name` varchar(100), -- the name of the file uploaded
  `comments` mediumtext, -- any comments added when the file was uploaded
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
  `status` enum('error', 'staged', 'imported', 'reverted', 'items_reverted', 'ignored') NOT NULL default 'staged',
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
CREATE TABLE `import_record_matches` ( -- matches found when importing a batch of records
  `import_record_id` int(11) NOT NULL, -- the id given to the imported bib record (import_records.import_record_id)
  `candidate_match_id` int(11) NOT NULL, -- the biblio the imported record matches (biblio.biblionumber)
  `score` int(11) NOT NULL default 0, -- the match score
  CONSTRAINT `import_record_matches_ibfk_1` FOREIGN KEY (`import_record_id`)
             REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  KEY `record_score` (`import_record_id`, `score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `isbn` varchar(30) default NULL,
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
  `status` enum('error', 'staged', 'imported', 'reverted', 'ignored') NOT NULL default 'staged',
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
CREATE TABLE `issues` ( -- information related to check outs or issues
  `borrowernumber` int(11), -- foreign key, linking this to the borrowers table for the patron this item was checked out to
  `itemnumber` int(11), -- foreign key, linking this to the items table for the item that was checked out
  `date_due` datetime default NULL, -- datetime the item is due (yyyy-mm-dd hh:mm::ss)
  `branchcode` varchar(10) default NULL, -- foreign key, linking to the branches table for the location the item was checked out
  `issuingbranch` varchar(18) default NULL,
  `returndate` datetime default NULL, -- date the item was returned, will be NULL until moved to old_issues
  `lastreneweddate` datetime default NULL, -- date the item was last renewed
  `return` varchar(4) default NULL,
  `renewals` tinyint(4) default NULL, -- lists the number of times the item was renewed
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this record was last touched
  `issuedate` datetime default NULL, -- date the item was checked out or issued
  KEY `issuesborridx` (`borrowernumber`),
  KEY `bordate` (`borrowernumber`,`timestamp`),
  CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `issuingrules`
--

DROP TABLE IF EXISTS `issuingrules`;
CREATE TABLE `issuingrules` ( -- circulation and fine rules
  `categorycode` varchar(10) NOT NULL default '', -- patron category this rule is for (categories.categorycode)
  `itemtype` varchar(10) NOT NULL default '', -- item type this rule is for (itemtypes.itemtype)
  `restrictedtype` tinyint(1) default NULL, -- not used? always NULL
  `rentaldiscount` decimal(28,6) default NULL, -- percent discount on the rental charge for this item
  `reservecharge` decimal(28,6) default NULL,
  `fine` decimal(28,6) default NULL, -- fine amount
  `finedays` int(11) default NULL, -- suspension in days
  `firstremind` int(11) default NULL, -- fine grace period
  `chargeperiod` int(11) default NULL, -- how often the fine amount is charged
  `accountsent` int(11) default NULL, -- not used? always NULL
  `chargename` varchar(100) default NULL, -- not used? always NULL
  `maxissueqty` int(4) default NULL, -- total number of checkouts allowed
  `issuelength` int(4) default NULL, -- length of checkout in the unit set in issuingrules.lengthunit
  `lengthunit` varchar(10) default 'days', -- unit of checkout length (days, hours)
  `hardduedate` date default NULL, -- hard due date
  `hardduedatecompare` tinyint NOT NULL default "0", -- type of hard due date (1 = after, 0 = on, -1 = before)
  `renewalsallowed` smallint(6) NOT NULL default "0", -- how many renewals are allowed
  `reservesallowed` smallint(6) NOT NULL default "0", -- how many holds are allowed
  `branchcode` varchar(10) NOT NULL default '', -- the branch this rule is for (branches.branchcode)
  overduefinescap decimal default NULL, -- the maximum amount of an overdue fine
  PRIMARY KEY  (`branchcode`,`categorycode`,`itemtype`),
  KEY `categorycode` (`categorycode`),
  KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `booksellerid` mediumtext default NULL, -- where the item was purchased (MARC21 952$e)
  `homebranch` varchar(10) default NULL, -- foreign key from the branches table for the library that owns this item (MARC21 952$a)
  `price` decimal(8,2) default NULL, -- purchase price (MARC21 952$g)
  `replacementprice` decimal(8,2) default NULL, -- cost the library charges to replace the item if it has been marked lost (MARC21 952$v)
  `replacementpricedate` date default NULL, -- the date the price is effective from (MARC21 952$w)
  `datelastborrowed` date default NULL, -- the date the item was last checked out/issued
  `datelastseen` date default NULL, -- the date the item was last see (usually the last time the barcode was scanned or inventory was done)
  `stack` tinyint(1) default NULL,
  `notforloan` tinyint(1) NOT NULL default 0, -- authorized value defining why this item is not for loan (MARC21 952$7)
  `damaged` tinyint(1) NOT NULL default 0, -- authorized value defining this item as damaged (MARC21 952$4)
  `itemlost` tinyint(1) NOT NULL default 0, -- authorized value defining this item as lost (MARC21 952$1)
  `wthdrawn` tinyint(1) NOT NULL default 0, -- authorized value defining this item as withdrawn (MARC21 952$0)
  `itemcallnumber` varchar(255) default NULL, -- call number for this item (MARC21 952$o)
  `issues` smallint(6) default NULL, -- number of times this item has been checked out/issued
  `renewals` smallint(6) default NULL, -- number of times this item has been renewed
  `reserves` smallint(6) default NULL, -- number of times this item has been placed on hold/reserved
  `restricted` tinyint(1) default NULL, -- authorized value defining use restrictions for this item (MARC21 952$5)
  `itemnotes` mediumtext, -- public notes on this item (MARC21 952$x)
  `holdingbranch` varchar(10) default NULL, -- foreign key from the branches table for the library that is currently in possession item (MARC21 952$b)
  `paidfor` mediumtext,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this item was last altered
  `location` varchar(80) default NULL, -- authorized value for the shelving location for this item (MARC21 952$c)
  `permanent_location` varchar(80) default NULL, -- linked to the CART and PROC temporary locations feature, stores the permanent shelving location
  `onloan` date default NULL, -- defines if item is checked out (NULL for not checked out, and checkout date for checked out)
  `cn_source` varchar(10) default NULL, -- classification source used on this item (MARC21 952$2)
  `cn_sort` varchar(30) default NULL,  -- normalized form of the call number (MARC21 952$o) used for sorting
  `ccode` varchar(10) default NULL, -- authorized value for the collection code associated with this item (MARC21 952$8)
  `materials` text default NULL, -- materials specified (MARC21 952$3)
  `uri` varchar(255) default NULL, -- URL for the item (MARC21 952$u)
  `itype` varchar(10) default NULL, -- foreign key from the itemtypes table defining the type for this item (MARC21 952$y)
  `more_subfields_xml` longtext default NULL, -- additional 952 subfields in XML format
  `enumchron` text default NULL, -- serial enumeration/chronology for the item (MARC21 952$h)
  `copynumber` varchar(32) default NULL, -- copy number (MARC21 952$t)
  `stocknumber` varchar(32) default NULL, -- inventory number (MARC21 952$i)
  PRIMARY KEY  (`itemnumber`),
  UNIQUE KEY `itembarcodeidx` (`barcode`),
  KEY `itemstocknumberidx` (`stocknumber`),
  KEY `itembinoidx` (`biblioitemnumber`),
  KEY `itembibnoidx` (`biblionumber`),
  KEY `homebranch` (`homebranch`),
  KEY `holdingbranch` (`holdingbranch`),
  KEY `itemcallnumber` (`itemcallnumber`),
  KEY `items_location` (`location`),
  KEY `items_ccode` (`ccode`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblioitemnumber`) REFERENCES `biblioitems` (`biblioitemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `itemtypes`
--

DROP TABLE IF EXISTS `itemtypes`;
CREATE TABLE `itemtypes` ( -- defines the item types
  `itemtype` varchar(10) NOT NULL default '', -- unique key, a code associated with the item type
  `description` mediumtext, -- a plain text explanation of the item type
  `rentalcharge` double(16,4) default NULL, -- the amount charged when this item is checked out/issued
  `notforloan` smallint(6) default NULL, -- 1 if the item is not for loan, 0 if the item is available for loan
  `imageurl` varchar(200) default NULL, -- URL for the item type icon
  `summary` text, -- information from the summary field, may include HTML
  PRIMARY KEY  (`itemtype`),
  UNIQUE KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `creator_batches`
--

DROP TABLE IF EXISTS `creator_batches`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `creator_batches` (
  `label_id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(10) NOT NULL DEFAULT '1',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `layout_name` char(20) NOT NULL DEFAULT 'DEFAULT',
  `guidebox` int(1) DEFAULT '0',
  `font` char(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'TR',
  `font_size` int(4) NOT NULL DEFAULT '10',
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `callnum_split` int(1) DEFAULT '0',
  `text_justify` char(1) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'L',
  `format_string` varchar(210) NOT NULL DEFAULT 'barcode',
  `layout_xml` text NOT NULL,
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`layout_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `letter`
--

DROP TABLE IF EXISTS `letter`;
CREATE TABLE `letter` ( -- table for all notice templates in Koha
  `module` varchar(20) NOT NULL default '', -- Koha module that triggers this notice or slip
  `code` varchar(20) NOT NULL default '', -- unique identifier for this notice or slip
  `branchcode` varchar(10) default NULL, -- the branch this notice or slip is used at (branches.branchcode)
  `name` varchar(100) NOT NULL default '', -- plain text name for this notice or slip
  `is_html` tinyint(1) default 0, -- does this notice or slip use HTML (1 for yes, 0 for no)
  `title` varchar(200) NOT NULL default '', -- subject line of the notice
  `content` text, -- body text for the notice or slip
  PRIMARY KEY  (`module`,`code`, `branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `marc_subfield_structure`
--

DROP TABLE IF EXISTS `marc_subfield_structure`;
CREATE TABLE `marc_subfield_structure` (
  `tagfield` varchar(3) NOT NULL default '',
  `tagsubfield` varchar(1) NOT NULL default '' COLLATE utf8_bin,
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
  `maxlength` int(4) NOT NULL DEFAULT '9999',
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
-- Table structure for table `need_merge_authorities`
--

DROP TABLE IF EXISTS `need_merge_authorities`;
CREATE TABLE `need_merge_authorities` ( -- keeping track of authority records still to be merged by merge_authority cron job (used only if pref dontmerge is ON)
  `id` int NOT NULL auto_increment PRIMARY KEY, -- unique id
  `authid` bigint NOT NULL, -- reference to authority record
  `done` tinyint DEFAULT 0  -- indication whether merge has been executed (0=not done, 1= done, 2= in progress)
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
-- Table structure for table `oai_sets`
--

DROP TABLE IF EXISTS `oai_sets`;
CREATE TABLE `oai_sets` (
  `id` int(11) NOT NULL auto_increment,
  `spec` varchar(80) NOT NULL UNIQUE,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `oai_sets_descriptions`
--

DROP TABLE IF EXISTS `oai_sets_descriptions`;
CREATE TABLE `oai_sets_descriptions` (
  `set_id` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  CONSTRAINT `oai_sets_descriptions_ibfk_1` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `oai_sets_mappings`
--

DROP TABLE IF EXISTS `oai_sets_mappings`;
CREATE TABLE `oai_sets_mappings` (
  `set_id` int(11) NOT NULL,
  `marcfield` char(3) NOT NULL,
  `marcsubfield` char(1) NOT NULL,
  `marcvalue` varchar(80) NOT NULL,
  CONSTRAINT `oai_sets_mappings_ibfk_1` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `oai_sets_biblios`
--

DROP TABLE IF EXISTS `oai_sets_biblios`;
CREATE TABLE `oai_sets_biblios` (
  `biblionumber` int(11) NOT NULL,
  `set_id` int(11) NOT NULL,
  PRIMARY KEY (`biblionumber`, `set_id`),
  CONSTRAINT `oai_sets_biblios_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `oai_sets_biblios_ibfk_2` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `old_issues`
--

DROP TABLE IF EXISTS `old_issues`;
CREATE TABLE `old_issues` ( -- lists items that were checked out and have been returned
  `borrowernumber` int(11) default NULL, -- foreign key, linking this to the borrowers table for the patron this item was checked out to
  `itemnumber` int(11) default NULL, -- foreign key, linking this to the items table for the item that was checked out
  `date_due` datetime default NULL, -- date the item is due (yyyy-mm-dd)
  `branchcode` varchar(10) default NULL, -- foreign key, linking to the branches table for the location the item was checked out
  `issuingbranch` varchar(18) default NULL,
  `returndate` datetime default NULL, -- date the item was returned
  `lastreneweddate` datetime default NULL, -- date the item was last renewed
  `return` varchar(4) default NULL,
  `renewals` tinyint(4) default NULL, -- lists the number of times the item was renewed
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this record was last touched
  `issuedate` datetime default NULL, -- date the item was checked out or issued
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
CREATE TABLE `old_reserves` ( -- this table holds all holds/reserves that have been completed (either filled or cancelled)
  `reserve_id` int(11) NOT NULL, -- primary key
  `borrowernumber` int(11) default NULL, -- foreign key from the borrowers table defining which patron this hold is for
  `reservedate` date default NULL, -- the date the hold was places
  `biblionumber` int(11) default NULL, -- foreign key from the biblio table defining which bib record this hold is on
  `constrainttype` varchar(1) default NULL,
  `branchcode` varchar(10) default NULL, -- foreign key from the branches table defining which branch the patron wishes to pick this hold up at
  `notificationdate` date default NULL, -- currently unused
  `reminderdate` date default NULL, -- currently unused
  `cancellationdate` date default NULL, -- the date this hold was cancelled
  `reservenotes` mediumtext, -- notes related to this hold
  `priority` smallint(6) default NULL, -- where in the queue the patron sits
  `found` varchar(1) default NULL, -- a one letter code defining what the status is of the hold is after it has been confirmed
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this hold was last updated
  `itemnumber` int(11) default NULL, -- foreign key from the items table defining the specific item the patron has placed on hold or the item this hold was filled with
  `waitingdate` date default NULL, -- the date the item was marked as waiting for the patron at the library
  `expirationdate` DATE DEFAULT NULL, -- the date the hold expires (usually the date entered by the patron to say they don't need the hold after a certain date)
  `lowestPriority` tinyint(1) NOT NULL, -- has this hold been pinned to the lowest priority in the holds queue (1 for yes, 0 for no)
  `suspend` BOOLEAN NOT NULL DEFAULT 0, -- in this hold suspended (1 for yes, 0 for no)
  `suspend_until` DATETIME NULL DEFAULT NULL, -- the date this hold is suspended until (NULL for infinitely)
  PRIMARY KEY (`reserve_id`),
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
CREATE TABLE `opac_news` ( -- data from the news tool
  `idnew` int(10) unsigned NOT NULL auto_increment, -- unique identifier for the news article
  `title` varchar(250) NOT NULL default '', -- title of the news article
  `new` text NOT NULL, -- the body of your news article
  `lang` varchar(25) NOT NULL default '', -- location for the article (koha is the staff client, slip is the circulation receipt and language codes are for the opac)
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP, -- pulibcation date and time
  `expirationdate` date default NULL, -- date the article is set to expire or no longer be visible
  `number` int(11) default NULL, -- the order in which this article appears in that specific location
  PRIMARY KEY  (`idnew`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `overduerules`
--

DROP TABLE IF EXISTS `overduerules`;
CREATE TABLE `overduerules` ( -- overdue notice status and triggers
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
CREATE TABLE `patronimage` ( -- information related to patron images
  `cardnumber` varchar(16) NOT NULL, -- the cardnumber of the patron this image is attached to (borrowers.cardnumber)
  `mimetype` varchar(15) NOT NULL, -- the format of the image (png, jpg, etc)
  `imagefile` mediumblob NOT NULL, -- the image
  PRIMARY KEY  (`cardnumber`),
  CONSTRAINT `patronimage_fk1` FOREIGN KEY (`cardnumber`) REFERENCES `borrowers` (`cardnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table structure for table `pending_offline_operations`
--
-- this table is MyISAM, InnoDB tables are growing only and this table is filled/emptied/filled/emptied...
-- so MyISAM is better in this case

DROP TABLE IF EXISTS `pending_offline_operations`;
CREATE TABLE `pending_offline_operations` (
  `operationid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` varchar(30) NOT NULL,
  `branchcode` varchar(10) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `action` varchar(10) NOT NULL,
  `barcode` varchar(20) NOT NULL,
  `cardnumber` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`operationid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `repeatable_holidays`
--

DROP TABLE IF EXISTS `repeatable_holidays`;
CREATE TABLE `repeatable_holidays` ( -- information for the days the library is closed
  `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `branchcode` varchar(10) NOT NULL default '', -- foreign key from the branches table, defines which branch this closing is for
  `weekday` smallint(6) default NULL, -- day of the week (0=Sunday, 1=Monday, etc) this closing is repeated on
  `day` smallint(6) default NULL, -- day of the month this closing is on
  `month` smallint(6) default NULL, -- month this closing is in
  `title` varchar(50) NOT NULL default '', -- title of this closing
  `description` text NOT NULL, -- description for this closing
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `reports_dictionary`
--

DROP TABLE IF EXISTS `reports_dictionary`;
CREATE TABLE reports_dictionary ( -- definitions (or snippets of SQL) stored for use in reports
   `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
   `name` varchar(255) default NULL, -- name for this definition
   `description` text, -- description for this definition
   `date_created` datetime default NULL, -- date and time this definition was created
   `date_modified` datetime default NULL, -- date and time this definition was last modified
   `saved_sql` text, -- SQL snippet for us in reports
   report_area varchar(6) DEFAULT NULL, -- Koha module this definition is for Circulation, Catalog, Patrons, Acquistions, Accounts)
   PRIMARY KEY  (id),
   KEY dictionary_area_idx (report_area)
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
CREATE TABLE `reserves` ( -- information related to holds/reserves in Koha
  `reserve_id` int(11) NOT NULL auto_increment, -- primary key
  `borrowernumber` int(11) NOT NULL default 0, -- foreign key from the borrowers table defining which patron this hold is for
  `reservedate` date default NULL, -- the date the hold was places
  `biblionumber` int(11) NOT NULL default 0, -- foreign key from the biblio table defining which bib record this hold is on
  `constrainttype` varchar(1) default NULL,
  `branchcode` varchar(10) default NULL, -- foreign key from the branches table defining which branch the patron wishes to pick this hold up at
  `notificationdate` date default NULL, -- currently unused
  `reminderdate` date default NULL, -- currently unused
  `cancellationdate` date default NULL, -- the date this hold was cancelled
  `reservenotes` mediumtext, -- notes related to this hold
  `priority` smallint(6) default NULL, -- where in the queue the patron sits
  `found` varchar(1) default NULL, -- a one letter code defining what the status is of the hold is after it has been confirmed
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this hold was last updated
  `itemnumber` int(11) default NULL, -- foreign key from the items table defining the specific item the patron has placed on hold or the item this hold was filled with
  `waitingdate` date default NULL, -- the date the item was marked as waiting for the patron at the library
  `expirationdate` DATE DEFAULT NULL, -- the date the hold expires (usually the date entered by the patron to say they don't need the hold after a certain date)
  `lowestPriority` tinyint(1) NOT NULL,
  `suspend` BOOLEAN NOT NULL DEFAULT 0,
  `suspend_until` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`reserve_id`),
  KEY priorityfoundidx (priority,found),
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
CREATE TABLE `reviews` ( -- patron opac comments
  `reviewid` int(11) NOT NULL auto_increment, -- unique identifier for this comment
  `borrowernumber` int(11) default NULL, -- foreign key from the borrowers table defining which patron left this comment
  `biblionumber` int(11) default NULL, -- foreign key from the biblio table defining which bibliographic record this comment is for
  `review` text, -- the body of the comment
  `approved` tinyint(4) default NULL, -- whether this comment has been approved by a librarian (1 for yes, 0 for no)
  `datereviewed` datetime default NULL, -- the date the comment was left
  PRIMARY KEY  (`reviewid`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `roadtype`
--

DROP TABLE IF EXISTS `roadtype`;
CREATE TABLE `roadtype` ( -- road types defined in administration and used in patron management
  `roadtypeid` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha for each road type
  `road_type` varchar(100) NOT NULL default '', -- text for road type
  PRIMARY KEY  (`roadtypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `saved_sql`
--

DROP TABLE IF EXISTS `saved_sql`;
CREATE TABLE saved_sql ( -- saved sql reports
   `id` int(11) NOT NULL auto_increment, -- unique id and primary key assigned by Koha
   `borrowernumber` int(11) default NULL, -- the staff member who created this report (borrowers.borrowernumber)
   `date_created` datetime default NULL, -- the date this report was created
   `last_modified` datetime default NULL, -- the date this report was last edited
   `savedsql` text, -- the SQL for this report
   `last_run` datetime default NULL,
   `report_name` varchar(255) default NULL, -- the name of this report
   `type` varchar(255) default NULL, -- always 1 for tabular
   `notes` text, -- the notes or description given to this report
   `cache_expiry` int NOT NULL default 300,
   `public` boolean NOT NULL default FALSE,
    report_area varchar(6) default NULL,
    report_group varchar(80) default NULL,
    report_subgroup varchar(80) default NULL,
   PRIMARY KEY  (`id`),
   KEY sql_area_group_idx (report_group, report_subgroup),
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
-- Table structure for table `search_history`
--

DROP TABLE IF EXISTS `search_history`;
CREATE TABLE IF NOT EXISTS `search_history` ( -- patron's opac search history
  `userid` int(11) NOT NULL, -- the patron who performed the search (borrowers.borrowernumber)
  `sessionid` varchar(32) NOT NULL, -- a system generated session id
  `query_desc` varchar(255) NOT NULL, -- the search that was performed
  `query_cgi` text NOT NULL, -- the string to append to the search url to rerun the search
  `total` int(11) NOT NULL, -- the total of results found
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP, -- the date and time the search was run
  KEY `userid` (`userid`),
  KEY `sessionid` (`sessionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Opac search history results';


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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `special_holidays`
--

DROP TABLE IF EXISTS `special_holidays`;
CREATE TABLE `special_holidays` ( -- non repeatable holidays/library closings
  `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `branchcode` varchar(10) NOT NULL default '', -- foreign key from the branches table, defines which branch this closing is for
  `day` smallint(6) NOT NULL default 0, -- day of the month this closing is on
  `month` smallint(6) NOT NULL default 0, -- month this closing is in
  `year` smallint(6) NOT NULL default 0, -- year this closing is in
  `isexception` smallint(1) NOT NULL default 1, -- is this a holiday exception to a repeatable holiday (1 for yes, 0 for no)
  `title` varchar(50) NOT NULL default '', -- title for this closing
  `description` text NOT NULL, -- description of this closing
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
CREATE TABLE `statistics` ( -- information related to transactions (circulation and fines) in Koha
  `datetime` datetime default NULL, -- date and time of the transaction
  `branch` varchar(10) default NULL, -- foreign key, branch where the transaction occurred
  `proccode` varchar(4) default NULL, -- proceedure code 
  `value` double(16,4) default NULL, -- monetary value associated with the transaction
  `type` varchar(16) default NULL, -- transaction type (locause, issue, return, renew, writeoff, payment, Credit*)
  `other` mediumtext,
  `usercode` varchar(10) default NULL,
  `itemnumber` int(11) default NULL, -- foreign key from the items table, links transaction to a specific item
  `itemtype` varchar(10) default NULL, -- foreign key from the itemtypes table, links transaction to a specific item type
  `borrowernumber` int(11) default NULL, -- foreign key from the borrowers table, links transaction to a specific borrower
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
  `location` varchar(80) NULL default '',
  `branchcode` varchar(10) NOT NULL default '',
  `hemisphere` tinyint(3) default 0,
  `lastbranch` varchar(10),
  `serialsadditems` tinyint(1) NOT NULL default '0',
  `staffdisplaycount` VARCHAR(10) NULL,
  `opacdisplaycount` VARCHAR(10) NULL,
  `graceperiod` int(11) NOT NULL default '0',
  `enddate` date default NULL,
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
  `histenddate` date default NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `suggestions`
--

DROP TABLE IF EXISTS `suggestions`;
CREATE TABLE `suggestions` ( -- purchase suggestions
  `suggestionid` int(8) NOT NULL auto_increment, -- unique identifier assigned automatically by Koha
  `suggestedby` int(11) NOT NULL default 0, -- borrowernumber for the person making the suggestion, foreign key linking to the borrowers table
  `suggesteddate` date NOT NULL default 0, -- date the suggestion was submitted
  `managedby` int(11) default NULL, -- borrowernumber for the librarian managing the suggestion, foreign key linking to the borrowers table
  `manageddate` date default NULL, -- date the suggestion was updated
   acceptedby INT(11) default NULL, -- borrowernumber for the librarian who accepted the suggestion, foreign key linking to the borrowers table
   accepteddate date default NULL, -- date the suggestion was marked as accepted
   rejectedby INT(11) default NULL, -- borrowernumber for the librarian who rejected the suggestion, foreign key linking to the borrowers table
   rejecteddate date default NULL, -- date the suggestion was marked as rejected
  `STATUS` varchar(10) NOT NULL default '', -- suggestion status (ASKED, CHECKED, ACCEPTED, or REJECTED)
  `note` mediumtext, -- note entered on the suggestion
  `author` varchar(80) default NULL, -- author of the suggested item
  `title` varchar(80) default NULL, -- title of the suggested item
  `copyrightdate` smallint(6) default NULL, -- copyright date of the suggested item
  `publishercode` varchar(255) default NULL, -- publisher of the suggested item
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  -- date and time the suggestion was updated
  `volumedesc` varchar(255) default NULL,
  `publicationyear` smallint(6) default 0,
  `place` varchar(255) default NULL, -- publication place of the suggested item
  `isbn` varchar(30) default NULL, -- isbn of the suggested item
  `mailoverseeing` smallint(1) default 0,
  `biblionumber` int(11) default NULL, -- foreign key linking the suggestion to the biblio table after the suggestion has been ordered
  `reason` text, -- reason for accepting or rejecting the suggestion
  `patronreason` text, -- reason for making the suggestion
   budgetid INT(11), -- foreign key linking the suggested budget to the aqbudgets table
   branchcode VARCHAR(10) default NULL, -- foreign key linking the suggested branch to the branches table
   collectiontitle text default NULL, -- collection name for the suggested item
   itemtype VARCHAR(30) default NULL, -- suggested item type 
	quantity SMALLINT(6) default NULL, -- suggested quantity to be purchased
	currency VARCHAR(3) default NULL, -- suggested currency for the suggested price
	price DECIMAL(28,6) default NULL, -- suggested price
	total DECIMAL(28,6) default NULL, -- suggested total cost (price*quantity updated for currency)
  PRIMARY KEY  (`suggestionid`),
  KEY `suggestedby` (`suggestedby`),
  KEY `managedby` (`managedby`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `systempreferences`
--

DROP TABLE IF EXISTS `systempreferences`;
CREATE TABLE `systempreferences` ( -- global system preferences
  `variable` varchar(50) NOT NULL default '', -- system preference name
  `value` text, -- system preference values
  `options` mediumtext, -- options for multiple choice system preferences
  `explanation` text, -- descriptive text for the system preference
  `type` varchar(20) default NULL, -- type of question this preference asks (multiple choice, plain text, yes or no, etc)
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
-- Table structure for table `tags_all`
--

DROP TABLE IF EXISTS `tags_all`;
CREATE TABLE `tags_all` ( -- all of the tags
  `tag_id`         int(11) NOT NULL auto_increment, -- unique id and primary key
  `borrowernumber` int(11) NOT NULL, -- the patron who added the tag (borrowers.borrowernumber)
  `biblionumber`   int(11) NOT NULL, -- the bib record this tag was left on (biblio.biblionumber)
  `term`      varchar(255) NOT NULL, -- the tag
  `language`       int(4) default NULL, -- the language the tag was left in
  `date_created` datetime  NOT NULL, -- the date the tag was added
  PRIMARY KEY  (`tag_id`),
  KEY `tags_borrowers_fk_1` (`borrowernumber`),
  KEY `tags_biblionumber_fk_1` (`biblionumber`),
  CONSTRAINT `tags_borrowers_fk_1` FOREIGN KEY (`borrowernumber`)
        REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tags_biblionumber_fk_1` FOREIGN KEY (`biblionumber`)
        REFERENCES `biblio`     (`biblionumber`)  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `tags_approval`
--

DROP TABLE IF EXISTS `tags_approval`;
CREATE TABLE `tags_approval` ( -- approved tags
  `term`   varchar(255) NOT NULL, -- the tag
  `approved`     int(1) NOT NULL default '0', -- whether the tag is approved or not (1=yes, 0=pending, -1=rejected)
  `date_approved` datetime       default NULL, -- the date this tag was approved
  `approved_by` int(11)          default NULL, -- the librarian who approved the tag (borrowers.borrowernumber)
  `weight_total` int(9) NOT NULL default '1', -- the total number of times this tag was used
  PRIMARY KEY  (`term`),
  KEY `tags_approval_borrowers_fk_1` (`approved_by`),
  CONSTRAINT `tags_approval_borrowers_fk_1` FOREIGN KEY (`approved_by`)
        REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `tags_index`
--

DROP TABLE IF EXISTS `tags_index`;
CREATE TABLE `tags_index` ( -- a weighted list of all tags and where they are used
  `term`    varchar(255) NOT NULL, -- the tag
  `biblionumber` int(11) NOT NULL, -- the bib record this tag was used on (biblio.biblionumber)
  `weight`        int(9) NOT NULL default '1', -- the number of times this term was used on this bib record
  PRIMARY KEY  (`term`,`biblionumber`),
  KEY `tags_index_biblionumber_fk_1` (`biblionumber`),
  CONSTRAINT `tags_index_term_fk_1` FOREIGN KEY (`term`)
        REFERENCES `tags_approval` (`term`)  ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tags_index_biblionumber_fk_1` FOREIGN KEY (`biblionumber`)
        REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
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
CREATE TABLE `virtualshelves` ( -- information about lists (or virtual shelves) 
  `shelfnumber` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `shelfname` varchar(255) default NULL, -- name of the list
  `owner` int default NULL, -- foreign key linking to the borrowers table (using borrowernumber) for the creator of this list (changed from varchar(80) to int)
  `category` varchar(1) default NULL, -- type of list (private [1], public [2])
  `sortfield` varchar(16) default NULL, -- the field this list is sorted on
  `lastmodified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time the list was last modified
  `allow_add` tinyint(1) default 0, -- permission for adding entries to list
  `allow_delete_own` tinyint(1) default 1, -- permission for deleting entries frm list that you added yourself
  `allow_delete_other` tinyint(1) default 0, -- permission for deleting entries from list that another person added
  PRIMARY KEY  (`shelfnumber`),
  CONSTRAINT `virtualshelves_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL -- no cascaded delete, please see HandleDelBorrower in VirtualShelves.pm
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  CONSTRAINT `shelfcontents_ibfk_3` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL -- no cascaded delete, please see HandleDelBorrower in VirtualShelves.pm
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  CONSTRAINT `virtualshelfshares_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL -- no cascaded delete, please see HandleDelBorrower in VirtualShelves.pm
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `z3950servers`
--

DROP TABLE IF EXISTS `z3950servers`;
CREATE TABLE `z3950servers` ( -- connection information for the Z39.50 targets used in cataloging
  `host` varchar(255) default NULL, -- target's host name
  `port` int(11) default NULL, -- port number used to connect to target
  `db` varchar(255) default NULL, -- target's database name
  `userid` varchar(255) default NULL, -- username needed to log in to target
  `password` varchar(255) default NULL, -- password needed to log in to target
  `name` mediumtext, -- name given to the target by the library
  `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `checked` smallint(6) default NULL, -- whether this target is checked by default  (1 for yes, 0 for no)
  `rank` int(11) default NULL, -- where this target appears in the list of targets
  `syntax` varchar(80) default NULL, -- marc format provided by this target
  `timeout` int(11) NOT NULL DEFAULT '0', -- number of seconds before Koha stops trying to access this server
  `icon` text, -- unused in Koha
  `position` enum('primary','secondary','') NOT NULL default 'primary',
  `type` enum('zed','opensearch') NOT NULL default 'zed',
  `encoding` text default NULL, -- characters encoding provided by this target
  `description` text NOT NULL, -- unused in Koha
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `services_throttle`
--

DROP TABLE IF EXISTS `services_throttle`;
CREATE TABLE `services_throttle` (
  `service_type` varchar(10) NOT NULL default '',
  `service_count` varchar(45) default NULL,
  PRIMARY KEY  (`service_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `language_script_bidi`
-- bi-directional support, keyed by script subcode
--

DROP TABLE IF EXISTS language_script_bidi;
CREATE TABLE language_script_bidi (
        rfc4646_subtag varchar(25), -- script subtag, Arab, Hebr, etc.
        bidi varchar(3), -- rtl ltr
        KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `module_bit` int(11) NOT NULL DEFAULT 0,
  `code` varchar(64) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY  (`module_bit`, `code`),
  CONSTRAINT `permissions_ibfk_1` FOREIGN KEY (`module_bit`) REFERENCES `userflags` (`bit`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `serialitems`
--

DROP TABLE IF EXISTS `serialitems`;
CREATE TABLE `serialitems` (
	`itemnumber` int(11) NOT NULL,
	`serialid` int(11) NOT NULL,
	UNIQUE KEY `serialitemsidx` (`itemnumber`),
	KEY `serialitems_sfk_1` (`serialid`),
	CONSTRAINT `serialitems_sfk_1` FOREIGN KEY (`serialid`) REFERENCES `serial` (`serialid`) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT `serialitems_sfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `tmp_holdsqueue`
--

DROP TABLE IF EXISTS `tmp_holdsqueue`;
CREATE TABLE `tmp_holdsqueue` (
  `biblionumber` int(11) default NULL,
  `itemnumber` int(11) default NULL,
  `barcode` varchar(20) default NULL,
  `surname` mediumtext NOT NULL,
  `firstname` text,
  `phone` text,
  `borrowernumber` int(11) NOT NULL,
  `cardnumber` varchar(16) default NULL,
  `reservedate` date default NULL,
  `title` mediumtext,
  `itemcallnumber` varchar(255) default NULL,
  `holdingbranch` varchar(10) default NULL,
  `pickbranch` varchar(10) default NULL,
  `notes` text,
  `item_level_request` tinyint(4) NOT NULL default 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `message_queue`
--

DROP TABLE IF EXISTS `message_queue`;
CREATE TABLE `message_queue` (
  `message_id` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) default NULL,
  `subject` text,
  `content` text,
  `metadata` text DEFAULT NULL,
  `letter_code` varchar(64) DEFAULT NULL,
  `message_transport_type` varchar(20) NOT NULL,
  `status` enum('sent','pending','failed','deleted') NOT NULL default 'pending',
  `time_queued` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `to_address` mediumtext,
  `from_address` mediumtext,
  `content_type` text,
  KEY `message_id` (`message_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `message_transport_type` (`message_transport_type`),
  CONSTRAINT `messageq_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `messageq_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `message_transport_types`
--

DROP TABLE IF EXISTS `message_transport_types`;
CREATE TABLE `message_transport_types` (
  `message_transport_type` varchar(20) NOT NULL,
  PRIMARY KEY  (`message_transport_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  CONSTRAINT `message_transports_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_transports_ibfk_3` FOREIGN KEY (`letter_module`, `letter_code`, `branchcode`) REFERENCES `letter` (`module`, `code`, `branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for the table branch_transfer_limits
--

DROP TABLE IF EXISTS `branch_transfer_limits`;
CREATE TABLE branch_transfer_limits (
    limitId int(8) NOT NULL auto_increment,
    toBranch varchar(10) NOT NULL,
    fromBranch varchar(10) NOT NULL,
    itemtype varchar(10) NULL,
    ccode varchar(10) NULL,
    PRIMARY KEY  (limitId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `messages`
--
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` ( -- circulation messages left via the patron's check out screen
  `message_id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `borrowernumber` int(11) NOT NULL, -- foreign key linking this message to the borrowers table
  `branchcode` varchar(10) default NULL, -- foreign key linking the message to the branches table
  `message_type` varchar(1) NOT NULL, -- whether the message is for the librarians (L) or the patron (B)
  `message` text NOT NULL, -- the text of the message
  `message_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- the date and time the message was written
  PRIMARY KEY (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `accountlines`
--

DROP TABLE IF EXISTS `accountlines`;
CREATE TABLE `accountlines` (
  `accountlines_id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL default 0,
  `accountno` smallint(6) NOT NULL default 0,
  `itemnumber` int(11) default NULL,
  `date` date default NULL,
  `amount` decimal(28,6) default NULL,
  `description` mediumtext,
  `dispute` mediumtext,
  `accounttype` varchar(5) default NULL,
  `amountoutstanding` decimal(28,6) default NULL,
  `lastincrement` decimal(28,6) default NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `notify_id` int(11) NOT NULL default 0,
  `notify_level` int(2) NOT NULL default 0,
  `note` text NULL default NULL,
  `manager_id` int(11) NULL,
  PRIMARY KEY (`accountlines_id`),
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
CREATE TABLE `action_logs` ( -- logs of actions taken in Koha (requires that the logs be turned on)
  `action_id` int(11) NOT NULL auto_increment, -- unique identifier for each action
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time the action took place
  `user` int(11) NOT NULL default 0, -- the staff member who performed the action (borrowers.borrowernumber)
  `module` text, -- the module this action was taken against
  `action` text, -- the action (includes things like DELETED, ADDED, MODIFY, etc)
  `object` int(11) default NULL, -- the object that the action was taken against (could be a borrowernumber, itemnumber, etc)
  `info` text, -- information about the action (usually includes SQL statement)
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
-- Table structure for table `aqbasketgroups`
--

DROP TABLE IF EXISTS `aqbasketgroups`;
CREATE TABLE `aqbasketgroups` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `closed` tinyint(1) default NULL,
  `booksellerid` int(11) NOT NULL,
  `deliveryplace` varchar(10) default NULL,
  `freedeliveryplace` text default NULL,
  `deliverycomment` varchar(255) default NULL,
  `billingplace` varchar(10) default NULL,
  PRIMARY KEY  (`id`),
  KEY `booksellerid` (`booksellerid`),
  CONSTRAINT `aqbasketgroups_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqbasket`
--

DROP TABLE IF EXISTS `aqbasket`;
CREATE TABLE `aqbasket` ( -- stores data about baskets in acquisitions
  `basketno` int(11) NOT NULL auto_increment, -- primary key, Koha defined number
  `basketname` varchar(50) default NULL, -- name given to the basket at creation
  `note` mediumtext, -- the internal note added at basket creation
  `booksellernote` mediumtext, -- the vendor note added at basket creation
  `contractnumber` int(11), -- links this basket to the aqcontract table (aqcontract.contractnumber)
  `creationdate` date default NULL, -- the date the basket was created
  `closedate` date default NULL, -- the date the basket was closed
  `booksellerid` int(11) NOT NULL default 1, -- the Koha assigned ID for the vendor (aqbooksellers.id)
  `authorisedby` varchar(10) default NULL, -- the borrowernumber of the person who created the basket
  `booksellerinvoicenumber` mediumtext, -- appears to always be NULL
  `basketgroupid` int(11), -- links this basket to its group (aqbasketgroups.id)
  PRIMARY KEY  (`basketno`),
  KEY `booksellerid` (`booksellerid`),
  KEY `basketgroupid` (`basketgroupid`),
  KEY `contractnumber` (`contractnumber`),
  CONSTRAINT `aqbasket_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `aqbasket_ibfk_2` FOREIGN KEY (`contractnumber`) REFERENCES `aqcontract` (`contractnumber`),
  CONSTRAINT `aqbasket_ibfk_3` FOREIGN KEY (`basketgroupid`) REFERENCES `aqbasketgroups` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqbooksellers`
--

DROP TABLE IF EXISTS `aqbooksellers`;
CREATE TABLE `aqbooksellers` ( -- information about the vendors listed in acquisitions
  `id` int(11) NOT NULL auto_increment, -- primary key and unique identifier assigned by Koha
  `name` mediumtext NOT NULL, -- vendor name
  `address1` mediumtext, -- first line of vendor physical address
  `address2` mediumtext, -- second line of vendor physical address
  `address3` mediumtext, -- third line of vendor physical address
  `address4` mediumtext, -- fourth line of vendor physical address
  `phone` varchar(30) default NULL, -- vendor phone number
  `accountnumber` mediumtext, -- unused in Koha
  `othersupplier` mediumtext,  -- unused in Koha
  `currency` varchar(3) NOT NULL default '', -- unused in Koha
  `booksellerfax` mediumtext, -- vendor fax number
  `notes` mediumtext, -- order notes
  `bookselleremail` mediumtext, -- vendor email
  `booksellerurl` mediumtext, -- unused in Koha
  `contact` varchar(100) default NULL, -- name of contact at vendor
  `postal` mediumtext, -- vendor postal address (all lines)
  `url` varchar(255) default NULL, -- vendor web address
  `contpos` varchar(100) default NULL, -- contact person's position
  `contphone` varchar(100) default NULL, -- contact's phone number
  `contfax` varchar(100) default NULL,  -- contact's fax number
  `contaltphone` varchar(100) default NULL, -- contact's alternate phone number
  `contemail` varchar(100) default NULL, -- contact's email address
  `contnotes` mediumtext, -- notes related to the contact
  `active` tinyint(4) default NULL, -- is this vendor active (1 for yes, 0 for no)
  `listprice` varchar(10) default NULL, -- currency code for list prices
  `invoiceprice` varchar(10) default NULL, -- currency code for invoice prices
  `gstreg` tinyint(4) default NULL, -- is your library charged tax (1 for yes, 0 for no)
  `listincgst` tinyint(4) default NULL, -- is tax included in list prices (1 for yes, 0 for no)
  `invoiceincgst` tinyint(4) default NULL, -- is tax included in invoice prices (1 for yes, 0 for no)
  `gstrate` decimal(6,4) default NULL, -- the tax rate the library is charged
  `discount` float(6,4) default NULL, -- discount offered on all items ordered from this vendor
  `fax` varchar(50) default NULL, -- vendor fax number
  deliverytime int(11) default NULL, -- vendor delivery time
  PRIMARY KEY  (`id`),
  KEY `listprice` (`listprice`),
  KEY `invoiceprice` (`invoiceprice`),
  CONSTRAINT `aqbooksellers_ibfk_1` FOREIGN KEY (`listprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqbooksellers_ibfk_2` FOREIGN KEY (`invoiceprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `budget_encumb` decimal(28,6) NULL default '0.00', -- not used in the code
  `budget_expend` decimal(28,6) NULL default '0.00', -- not used in the code
  `budget_notes` mediumtext, -- notes related to this fund
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this fund was last touched (created or modified)
  `budget_period_id` int(11) default NULL, -- id of the budget that this fund belongs to (aqbudgetperiods.budget_period_id)
  `sort1_authcat` varchar(80) default NULL, -- statistical category for this fund
  `sort2_authcat` varchar(80) default NULL, -- second statistical category for this fund
  `budget_owner_id` int(11) default NULL, -- borrowernumber of the person who owns this fund (borrowers.borrowernumber)
  `budget_permission` int(1) default '0', -- level of permission for this fund (used only by the owner, only by the library, or anyone)
  PRIMARY KEY  (`budget_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `aqbudgetperiods`
--


DROP TABLE IF EXISTS `aqbudgetperiods`;
CREATE TABLE `aqbudgetperiods` ( -- information related to Budgets
  `budget_period_id` int(11) NOT NULL auto_increment, -- primary key and unique number assigned by Koha
  `budget_period_startdate` date NOT NULL, -- date when the budget starts
  `budget_period_enddate` date NOT NULL, -- date when the budget ends
  `budget_period_active` tinyint(1) default '0', -- whether this budget is active or not (1 for yes, 0 for no)
  `budget_period_description` mediumtext, -- description assigned to this budget
  `budget_period_total` decimal(28,6), -- total amount available in this budget
  `budget_period_locked` tinyint(1) default NULL, -- whether this budget is locked or not (1 for yes, 0 for no)
  `sort1_authcat` varchar(10) default NULL, -- statistical category for this budget
  `sort2_authcat` varchar(10) default NULL, -- second statistical category for this budget
  PRIMARY KEY  (`budget_period_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  CONSTRAINT `aqbudgets_planning_ifbk_1` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table 'aqcontract'
--

DROP TABLE IF EXISTS `aqcontract`;
CREATE TABLE `aqcontract` (
  `contractnumber` int(11) NOT NULL auto_increment,
  `contractstartdate` date default NULL,
  `contractenddate` date default NULL,
  `contractname` varchar(50) default NULL,
  `contractdescription` mediumtext,
  `booksellerid` int(11) not NULL,
  PRIMARY KEY  (`contractnumber`),
  CONSTRAINT `booksellerid_fk1` FOREIGN KEY (`booksellerid`)
       REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

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
CREATE TABLE `aqorders` ( -- information related to the basket line items
  `ordernumber` int(11) NOT NULL auto_increment, -- primary key and unique identifier assigned by Koha to each line
  `biblionumber` int(11) default NULL, -- links the order to the biblio being ordered (biblio.biblionumber)
  `entrydate` date default NULL, -- the date the bib was added to the basket
  `quantity` smallint(6) default NULL, -- the quantity ordered
  `currency` varchar(3) default NULL, -- the currency used for the purchase
  `listprice` decimal(28,6) default NULL, -- the vendor price for this line item
  `totalamount` decimal(28,6) default NULL, -- not used? always NULL
  `datereceived` date default NULL, -- the date this order was received
  invoiceid int(11) default NULL, -- id of invoice
  `freight` decimal(28,6) default NULL, -- shipping costs (not used)
  `unitprice` decimal(28,6) default NULL, -- the actual cost entered when receiving this line item
  `quantityreceived` smallint(6) NOT NULL default 0, -- the quantity that have been received so far
  `cancelledby` varchar(10) default NULL, -- not used? always NULL
  `datecancellationprinted` date default NULL, -- the date the line item was deleted
  `notes` mediumtext, -- notes related to this order line
  `supplierreference` mediumtext, -- not used? always NULL
  `purchaseordernumber` mediumtext, -- not used? always NULL
  `subscription` tinyint(1) default NULL, -- not used? always NULL
  `serialid` varchar(30) default NULL, -- not used? always NULL
  `basketno` int(11) default NULL, -- links this order line to a specific basket (aqbasket.basketno)
  `biblioitemnumber` int(11) default NULL, -- links this order line the biblioitems table (biblioitems.biblioitemnumber)
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this order line was last modified
  `rrp` decimal(13,2) default NULL, -- the replacement cost for this line item
  `ecost` decimal(13,2) default NULL, -- the estimated cost for this line item
  `gstrate` decimal(6,4) default NULL, -- the tax rate for this line item
  `discount` float(6,4) default NULL, -- the discount for this line item
  `budget_id` int(11) NOT NULL, -- the fund this order goes against (aqbudgets.budget_id)
  `budgetgroup_id` int(11) NOT NULL, -- not used? always zero
  `budgetdate` date default NULL, -- not used? always NULL
  `sort1` varchar(80) default NULL, -- statistical field
  `sort2` varchar(80) default NULL, -- second statistical field
  `sort1_authcat` varchar(10) default NULL,
  `sort2_authcat` varchar(10) default NULL,
  `uncertainprice` tinyint(1), -- was this price uncertain (1 for yes, 0 for no)
  `claims_count` int(11) default 0, -- count of claim letters generated
  `claimed_date` date default NULL, -- last date a claim was generated
  parent_ordernumber int(11) default NULL, -- ordernumber of parent order line, or same as ordernumber if no parent
  PRIMARY KEY  (`ordernumber`),
  KEY `basketno` (`basketno`),
  KEY `biblionumber` (`biblionumber`),
  KEY `budget_id` (`budget_id`),
  CONSTRAINT `aqorders_ibfk_1` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorders_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT aqorders_ibfk_3 FOREIGN KEY (invoiceid) REFERENCES aqinvoices (invoiceid) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `aqorders_items`
--

DROP TABLE IF EXISTS `aqorders_items`;
CREATE TABLE `aqorders_items` ( -- information on items entered in the acquisitions process
  `ordernumber` int(11) NOT NULL, -- the order this item is attached to (aqorders.ordernumber)
  `itemnumber` int(11) NOT NULL, -- the item number for this item (items.itemnumber)
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- the date and time this order item was last touched
  PRIMARY KEY  (`itemnumber`),
  KEY `ordernumber` (`ordernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table aqinvoices
--

DROP TABLE IF EXISTS aqinvoices;
CREATE TABLE aqinvoices (
  invoiceid int(11) NOT NULL AUTO_INCREMENT,    -- ID of the invoice, primary key
  invoicenumber mediumtext NOT NULL,    -- Name of invoice
  booksellerid int(11) NOT NULL,    -- foreign key to aqbooksellers
  shipmentdate date default NULL,   -- date of shipment
  billingdate date default NULL,    -- date of billing
  closedate date default NULL,  -- invoice close date, NULL means the invoice is open
  shipmentcost decimal(28,6) default NULL,  -- shipment cost
  shipmentcost_budgetid int(11) default NULL,   -- foreign key to aqbudgets, link the shipment cost to a budget
  PRIMARY KEY (invoiceid),
  CONSTRAINT aqinvoices_fk_aqbooksellerid FOREIGN KEY (booksellerid) REFERENCES aqbooksellers (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT aqinvoices_fk_shipmentcost_budgetid FOREIGN KEY (shipmentcost_budgetid) REFERENCES aqbudgets (budget_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `fieldmapping`
--

DROP TABLE IF EXISTS `fieldmapping`;
CREATE TABLE `fieldmapping` ( -- koha to keyword mapping
  `id` int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
  `field` varchar(255) NOT NULL, -- keyword to be mapped to (ex. subtitle)
  `frameworkcode` char(4) NOT NULL default '', -- foreign key from the biblio_framework table to link this mapping to a specific framework
  `fieldcode` char(3) NOT NULL, -- marc field number to map to this keyword
  `subfieldcode` char(1) NOT NULL, -- marc subfield associated with the fieldcode to map to this keyword
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `transport_cost`
--

DROP TABLE IF EXISTS transport_cost;
CREATE TABLE transport_cost (
      frombranch varchar(10) NOT NULL,
      tobranch varchar(10) NOT NULL,
      cost decimal(6,2) NOT NULL,
      disable_transfer tinyint(1) NOT NULL DEFAULT 0,
      CHECK ( frombranch <> tobranch ), -- a dud check, mysql does not support that
      PRIMARY KEY (frombranch, tobranch),
      CONSTRAINT transport_cost_ibfk_1 FOREIGN KEY (frombranch) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT transport_cost_ibfk_2 FOREIGN KEY (tobranch) REFERENCES branches (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `biblioimages`
--

DROP TABLE IF EXISTS `biblioimages`;

CREATE TABLE `biblioimages` (
 `imagenumber` int(11) NOT NULL AUTO_INCREMENT,
 `biblionumber` int(11) NOT NULL,
 `mimetype` varchar(15) NOT NULL,
 `imagefile` mediumblob NOT NULL,
 `thumbnail` mediumblob NOT NULL,
 PRIMARY KEY (`imagenumber`),
 CONSTRAINT `bibliocoverimage_fk1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `social_data`
--

DROP TABLE IF EXISTS `social_data`;
CREATE TABLE IF NOT EXISTS `social_data` (
  `isbn` VARCHAR(30),
  `num_critics` INT,
  `num_critics_pro` INT,
  `num_quotations` INT,
  `num_videos` INT,
  `score_avg` DECIMAL(5,2),
  `num_scores` INT,
  PRIMARY KEY  (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `quotes`
--

DROP TABLE IF EXISTS quotes;
CREATE TABLE `quotes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` text DEFAULT NULL,
  `text` mediumtext NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

