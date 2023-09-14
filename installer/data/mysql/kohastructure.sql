-- MariaDB dump 10.19  Distrib 10.5.19-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: db    Database: koha_kohadev
-- ------------------------------------------------------
-- Server version	10.11.3-MariaDB-1:10.11.3+maria~ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_credit_types`
--

DROP TABLE IF EXISTS `account_credit_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_credit_types` (
  `code` varchar(80) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `can_be_added_manually` tinyint(4) NOT NULL DEFAULT 1,
  `credit_number_enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Is autogeneration of credit number enabled for this credit type',
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `archived` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean flag to denote if this till is archived or not',
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_credit_types_branches`
--

DROP TABLE IF EXISTS `account_credit_types_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_credit_types_branches` (
  `credit_type_code` varchar(80) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  KEY `credit_type_code` (`credit_type_code`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `account_credit_types_branches_ibfk_1` FOREIGN KEY (`credit_type_code`) REFERENCES `account_credit_types` (`code`) ON DELETE CASCADE,
  CONSTRAINT `account_credit_types_branches_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_debit_types`
--

DROP TABLE IF EXISTS `account_debit_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_debit_types` (
  `code` varchar(80) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `can_be_invoiced` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'boolean flag to denote if this debit type is available for manual invoicing',
  `can_be_sold` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean flag to denote if this debit type is available at point of sale',
  `default_amount` decimal(28,6) DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `archived` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean flag to denote if this till is archived or not',
  `restricts_checkouts` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'boolean flag to denote if the noissuescharge syspref for this debit type is active',
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_debit_types_branches`
--

DROP TABLE IF EXISTS `account_debit_types_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_debit_types_branches` (
  `debit_type_code` varchar(80) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  KEY `debit_type_code` (`debit_type_code`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `account_debit_types_branches_ibfk_1` FOREIGN KEY (`debit_type_code`) REFERENCES `account_debit_types` (`code`) ON DELETE CASCADE,
  CONSTRAINT `account_debit_types_branches_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_offsets`
--

DROP TABLE IF EXISTS `account_offsets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_offsets` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for each offset',
  `credit_id` int(11) DEFAULT NULL COMMENT 'The id of the accountline the increased the patron''s balance',
  `debit_id` int(11) DEFAULT NULL COMMENT 'The id of the accountline that decreased the patron''s balance',
  `type` enum('CREATE','APPLY','VOID','OVERDUE_INCREASE','OVERDUE_DECREASE') NOT NULL COMMENT 'The type of offset this is',
  `amount` decimal(26,6) NOT NULL COMMENT 'The amount of the change',
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `account_offsets_ibfk_p` (`credit_id`),
  KEY `account_offsets_ibfk_f` (`debit_id`),
  CONSTRAINT `account_offsets_ibfk_f` FOREIGN KEY (`debit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_offsets_ibfk_p` FOREIGN KEY (`credit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `accountlines`
--

DROP TABLE IF EXISTS `accountlines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountlines` (
  `accountlines_id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_id` int(11) DEFAULT NULL,
  `borrowernumber` int(11) DEFAULT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `date` timestamp NULL DEFAULT NULL,
  `amount` decimal(28,6) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `credit_type_code` varchar(80) DEFAULT NULL,
  `debit_type_code` varchar(80) DEFAULT NULL,
  `credit_number` varchar(20) DEFAULT NULL COMMENT 'autogenerated number for credits',
  `status` varchar(16) DEFAULT NULL,
  `payment_type` varchar(80) DEFAULT NULL COMMENT 'optional authorised value PAYMENT_TYPE',
  `amountoutstanding` decimal(28,6) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `note` mediumtext DEFAULT NULL,
  `manager_id` int(11) DEFAULT NULL,
  `register_id` int(11) DEFAULT NULL,
  `interface` varchar(16) NOT NULL,
  `branchcode` varchar(10) DEFAULT NULL COMMENT 'the branchcode of the library where a payment was made, a manual invoice created, etc.',
  PRIMARY KEY (`accountlines_id`),
  KEY `acctsborridx` (`borrowernumber`),
  KEY `timeidx` (`timestamp`),
  KEY `credit_type_code` (`credit_type_code`),
  KEY `debit_type_code` (`debit_type_code`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  KEY `manager_id` (`manager_id`),
  KEY `accountlines_ibfk_registers` (`register_id`),
  CONSTRAINT `accountlines_ibfk_borrowers` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_borrowers_2` FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_branches` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_credit_type` FOREIGN KEY (`credit_type_code`) REFERENCES `account_credit_types` (`code`) ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_debit_type` FOREIGN KEY (`debit_type_code`) REFERENCES `account_debit_types` (`code`) ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_items` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_registers` FOREIGN KEY (`register_id`) REFERENCES `cash_registers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `action_logs`
--

DROP TABLE IF EXISTS `action_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `action_logs` (
  `action_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for each action',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'the date and time the action took place',
  `user` int(11) NOT NULL DEFAULT 0 COMMENT 'the staff member who performed the action (borrowers.borrowernumber)',
  `module` mediumtext DEFAULT NULL COMMENT 'the module this action was taken against',
  `action` mediumtext DEFAULT NULL COMMENT 'the action (includes things like DELETED, ADDED, MODIFY, etc)',
  `object` int(11) DEFAULT NULL COMMENT 'the object that the action was taken against (could be a borrowernumber, itemnumber, etc)',
  `info` mediumtext DEFAULT NULL COMMENT 'information about the action (usually includes SQL statement)',
  `interface` varchar(30) DEFAULT NULL COMMENT 'the context this action was taken in',
  `script` varchar(255) DEFAULT NULL COMMENT 'the name of the cron script that caused this change',
  `trace` text DEFAULT NULL COMMENT 'An optional stack trace enabled by ActionLogsTraceDepth',
  PRIMARY KEY (`action_id`),
  KEY `timestamp_idx` (`timestamp`),
  KEY `user_idx` (`user`),
  KEY `module_idx` (`module`(191)),
  KEY `action_idx` (`action`(191)),
  KEY `object_idx` (`object`),
  KEY `info_idx` (`info`(191)),
  KEY `interface` (`interface`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `additional_contents`
--

DROP TABLE IF EXISTS `additional_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `additional_contents` (
  `idnew` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for the additional content',
  `category` varchar(20) NOT NULL COMMENT 'category for the additional content',
  `code` varchar(100) NOT NULL COMMENT 'code to group content per lang',
  `location` varchar(255) NOT NULL COMMENT 'location of the additional content',
  `branchcode` varchar(10) DEFAULT NULL COMMENT 'branch code users to create branch specific additional content, NULL is every branch.',
  `title` varchar(250) NOT NULL DEFAULT '' COMMENT 'title of the additional content',
  `content` mediumtext NOT NULL COMMENT 'the body of your additional content',
  `lang` varchar(50) NOT NULL DEFAULT '' COMMENT 'location for the additional content(koha is the staff interface, slip is the circulation receipt and language codes are for the opac)',
  `published_on` date DEFAULT NULL COMMENT 'publication date',
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'last modification',
  `expirationdate` date DEFAULT NULL COMMENT 'date the additional content is set to expire or no longer be visible',
  `number` int(11) DEFAULT NULL COMMENT 'the order in which this additional content appears in that specific location',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'The user who created the additional content',
  PRIMARY KEY (`idnew`),
  UNIQUE KEY `additional_contents_uniq` (`category`,`code`,`branchcode`,`lang`),
  KEY `additional_contents_borrowernumber_fk` (`borrowernumber`),
  KEY `additional_contents_branchcode_ibfk` (`branchcode`),
  CONSTRAINT `additional_contents_branchcode_ibfk` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrowernumber_fk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `additional_field_values`
--

DROP TABLE IF EXISTS `additional_field_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `additional_field_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key identifier',
  `field_id` int(11) NOT NULL COMMENT 'foreign key references additional_fields(id)',
  `record_id` int(11) NOT NULL COMMENT 'record_id',
  `value` varchar(255) NOT NULL DEFAULT '' COMMENT 'value for this field',
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_record` (`field_id`,`record_id`),
  CONSTRAINT `afv_fk` FOREIGN KEY (`field_id`) REFERENCES `additional_fields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `additional_fields`
--

DROP TABLE IF EXISTS `additional_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `additional_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key identifier',
  `tablename` varchar(255) NOT NULL DEFAULT '' COMMENT 'tablename of the new field',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT 'name of the field',
  `authorised_value_category` varchar(32) NOT NULL DEFAULT '' COMMENT 'is an authorised value category',
  `marcfield` varchar(16) NOT NULL DEFAULT '' COMMENT 'contains the marc field to copied into the record',
  `marcfield_mode` enum('get','set') NOT NULL DEFAULT 'get' COMMENT 'mode of operation (get or set) for marcfield',
  `searchable` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'is the field searchable?',
  PRIMARY KEY (`id`),
  UNIQUE KEY `fields_uniq` (`tablename`(191),`name`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `advanced_editor_macros`
--

DROP TABLE IF EXISTS `advanced_editor_macros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `advanced_editor_macros` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID of the macro',
  `name` varchar(80) NOT NULL COMMENT 'Name of the macro',
  `macro` longtext DEFAULT NULL COMMENT 'The macro code itself',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'ID of the borrower who created this macro',
  `shared` tinyint(1) DEFAULT 0 COMMENT 'Bit to define if shared or private macro',
  PRIMARY KEY (`id`),
  KEY `borrower_macro_fk` (`borrowernumber`),
  CONSTRAINT `borrower_macro_fk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alert`
--

DROP TABLE IF EXISTS `alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alert` (
  `alertid` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL DEFAULT 0,
  `type` varchar(10) NOT NULL DEFAULT '',
  `externalid` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`alertid`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `type` (`type`,`externalid`),
  CONSTRAINT `alert_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_keys` (
  `client_id` varchar(191) NOT NULL COMMENT 'API client ID',
  `secret` varchar(191) NOT NULL COMMENT 'API client secret used for API authentication',
  `description` varchar(255) NOT NULL COMMENT 'API client description',
  `patron_id` int(11) NOT NULL COMMENT 'Foreign key to the borrowers table',
  `active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 means this API key is revoked',
  PRIMARY KEY (`client_id`),
  UNIQUE KEY `secret` (`secret`),
  KEY `patron_id` (`patron_id`),
  CONSTRAINT `api_keys_fk_patron_id` FOREIGN KEY (`patron_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbasket`
--

DROP TABLE IF EXISTS `aqbasket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbasket` (
  `basketno` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key, Koha defined number',
  `basketname` varchar(50) DEFAULT NULL COMMENT 'name given to the basket at creation',
  `note` longtext DEFAULT NULL COMMENT 'the internal note added at basket creation',
  `booksellernote` longtext DEFAULT NULL COMMENT 'the vendor note added at basket creation',
  `contractnumber` int(11) DEFAULT NULL COMMENT 'links this basket to the aqcontract table (aqcontract.contractnumber)',
  `creationdate` date DEFAULT NULL COMMENT 'the date the basket was created',
  `closedate` date DEFAULT NULL COMMENT 'the date the basket was closed',
  `booksellerid` int(11) NOT NULL DEFAULT 1 COMMENT 'the Koha assigned ID for the vendor (aqbooksellers.id)',
  `authorisedby` varchar(10) DEFAULT NULL COMMENT 'the borrowernumber of the person who created the basket',
  `booksellerinvoicenumber` longtext DEFAULT NULL COMMENT 'appears to always be NULL',
  `basketgroupid` int(11) DEFAULT NULL COMMENT 'links this basket to its group (aqbasketgroups.id)',
  `deliveryplace` varchar(10) DEFAULT NULL COMMENT 'basket delivery place',
  `billingplace` varchar(10) DEFAULT NULL COMMENT 'basket billing place',
  `branch` varchar(10) DEFAULT NULL COMMENT 'basket branch',
  `is_standing` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'orders in this basket are standing',
  `create_items` enum('ordering','receiving','cataloguing') DEFAULT NULL COMMENT 'when items should be created for orders in this basket',
  PRIMARY KEY (`basketno`),
  KEY `booksellerid` (`booksellerid`),
  KEY `basketgroupid` (`basketgroupid`),
  KEY `contractnumber` (`contractnumber`),
  KEY `authorisedby` (`authorisedby`),
  KEY `aqbasket_ibfk_4` (`branch`),
  CONSTRAINT `aqbasket_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `aqbasket_ibfk_2` FOREIGN KEY (`contractnumber`) REFERENCES `aqcontract` (`contractnumber`),
  CONSTRAINT `aqbasket_ibfk_3` FOREIGN KEY (`basketgroupid`) REFERENCES `aqbasketgroups` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `aqbasket_ibfk_4` FOREIGN KEY (`branch`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbasketgroups`
--

DROP TABLE IF EXISTS `aqbasketgroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbasketgroups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `closed` tinyint(1) DEFAULT NULL,
  `booksellerid` int(11) NOT NULL,
  `deliveryplace` varchar(10) DEFAULT NULL,
  `freedeliveryplace` mediumtext DEFAULT NULL,
  `deliverycomment` varchar(255) DEFAULT NULL,
  `billingplace` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `booksellerid` (`booksellerid`),
  CONSTRAINT `aqbasketgroups_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbasketusers`
--

DROP TABLE IF EXISTS `aqbasketusers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbasketusers` (
  `basketno` int(11) NOT NULL,
  `borrowernumber` int(11) NOT NULL,
  PRIMARY KEY (`basketno`,`borrowernumber`),
  KEY `aqbasketusers_ibfk_2` (`borrowernumber`),
  CONSTRAINT `aqbasketusers_ibfk_1` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqbasketusers_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbookseller_aliases`
--

DROP TABLE IF EXISTS `aqbookseller_aliases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbookseller_aliases` (
  `alias_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique identifier assigned by Koha',
  `vendor_id` int(11) NOT NULL COMMENT 'link to the vendor',
  `alias` varchar(255) NOT NULL COMMENT 'the alias',
  PRIMARY KEY (`alias_id`),
  KEY `aqbookseller_aliases_ibfk_1` (`vendor_id`),
  CONSTRAINT `aqbookseller_aliases_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbookseller_interfaces`
--

DROP TABLE IF EXISTS `aqbookseller_interfaces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbookseller_interfaces` (
  `interface_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique identifier assigned by Koha',
  `vendor_id` int(11) NOT NULL COMMENT 'link to the vendor',
  `type` varchar(80) DEFAULT NULL COMMENT 'type of the interface, authorised value VENDOR_INTERFACE_TYPE',
  `name` varchar(255) NOT NULL COMMENT 'name of the interface',
  `uri` mediumtext DEFAULT NULL COMMENT 'uri of the interface',
  `login` varchar(255) DEFAULT NULL COMMENT 'login',
  `password` mediumtext DEFAULT NULL COMMENT 'hashed password',
  `account_email` mediumtext DEFAULT NULL COMMENT 'account email',
  `notes` longtext DEFAULT NULL COMMENT 'notes',
  PRIMARY KEY (`interface_id`),
  KEY `aqbookseller_interfaces_ibfk_1` (`vendor_id`),
  CONSTRAINT `aqbookseller_interfaces_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbooksellers`
--

DROP TABLE IF EXISTS `aqbooksellers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbooksellers` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique identifier assigned by Koha',
  `name` longtext NOT NULL COMMENT 'vendor name',
  `address1` longtext DEFAULT NULL COMMENT 'first line of vendor physical address',
  `address2` longtext DEFAULT NULL COMMENT 'second line of vendor physical address',
  `address3` longtext DEFAULT NULL COMMENT 'third line of vendor physical address',
  `address4` longtext DEFAULT NULL COMMENT 'fourth line of vendor physical address',
  `phone` varchar(30) DEFAULT NULL COMMENT 'vendor phone number',
  `accountnumber` longtext DEFAULT NULL COMMENT 'vendor account number',
  `type` varchar(255) DEFAULT NULL,
  `notes` longtext DEFAULT NULL COMMENT 'order notes',
  `postal` longtext DEFAULT NULL COMMENT 'vendor postal address (all lines)',
  `url` varchar(255) DEFAULT NULL COMMENT 'vendor web address',
  `active` tinyint(4) DEFAULT NULL COMMENT 'is this vendor active (1 for yes, 0 for no)',
  `listprice` varchar(10) DEFAULT NULL COMMENT 'currency code for list prices',
  `invoiceprice` varchar(10) DEFAULT NULL COMMENT 'currency code for invoice prices',
  `gstreg` tinyint(4) DEFAULT NULL COMMENT 'is your library charged tax (1 for yes, 0 for no)',
  `listincgst` tinyint(4) DEFAULT NULL COMMENT 'is tax included in list prices (1 for yes, 0 for no)',
  `invoiceincgst` tinyint(4) DEFAULT NULL COMMENT 'is tax included in invoice prices (1 for yes, 0 for no)',
  `tax_rate` decimal(6,4) DEFAULT NULL COMMENT 'the tax rate the library is charged',
  `discount` float(6,4) DEFAULT NULL COMMENT 'discount offered on all items ordered from this vendor',
  `fax` varchar(50) DEFAULT NULL COMMENT 'vendor fax number',
  `deliverytime` int(11) DEFAULT NULL COMMENT 'vendor delivery time',
  `external_id` varchar(255) DEFAULT NULL COMMENT 'external id of the vendor',
  PRIMARY KEY (`id`),
  KEY `listprice` (`listprice`),
  KEY `invoiceprice` (`invoiceprice`),
  KEY `name` (`name`(191)),
  CONSTRAINT `aqbooksellers_ibfk_1` FOREIGN KEY (`listprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqbooksellers_ibfk_2` FOREIGN KEY (`invoiceprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbudgetborrowers`
--

DROP TABLE IF EXISTS `aqbudgetborrowers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbudgetborrowers` (
  `budget_id` int(11) NOT NULL,
  `borrowernumber` int(11) NOT NULL,
  PRIMARY KEY (`budget_id`,`borrowernumber`),
  KEY `aqbudgetborrowers_ibfk_2` (`borrowernumber`),
  CONSTRAINT `aqbudgetborrowers_ibfk_1` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqbudgetborrowers_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbudgetperiods`
--

DROP TABLE IF EXISTS `aqbudgetperiods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbudgetperiods` (
  `budget_period_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique number assigned by Koha',
  `budget_period_startdate` date NOT NULL COMMENT 'date when the budget starts',
  `budget_period_enddate` date NOT NULL COMMENT 'date when the budget ends',
  `budget_period_active` tinyint(1) DEFAULT 0 COMMENT 'whether this budget is active or not (1 for yes, 0 for no)',
  `budget_period_description` longtext DEFAULT NULL COMMENT 'description assigned to this budget',
  `budget_period_total` decimal(28,6) DEFAULT NULL COMMENT 'total amount available in this budget',
  `budget_period_locked` tinyint(1) DEFAULT NULL COMMENT 'whether this budget is locked or not (1 for yes, 0 for no)',
  `sort1_authcat` varchar(10) DEFAULT NULL COMMENT 'statistical category for this budget',
  `sort2_authcat` varchar(10) DEFAULT NULL COMMENT 'second statistical category for this budget',
  PRIMARY KEY (`budget_period_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbudgets`
--

DROP TABLE IF EXISTS `aqbudgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbudgets` (
  `budget_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique number assigned to each fund by Koha',
  `budget_parent_id` int(11) DEFAULT NULL COMMENT 'if this fund is a child of another this will include the parent id (aqbudgets.budget_id)',
  `budget_code` varchar(30) DEFAULT NULL COMMENT 'code assigned to the fund by the user',
  `budget_name` varchar(80) DEFAULT NULL COMMENT 'name assigned to the fund by the user',
  `budget_branchcode` varchar(10) DEFAULT NULL COMMENT 'branch that this fund belongs to (branches.branchcode)',
  `budget_amount` decimal(28,6) DEFAULT 0.000000 COMMENT 'total amount for this fund',
  `budget_encumb` decimal(28,6) DEFAULT 0.000000 COMMENT 'budget warning at percentage',
  `budget_expend` decimal(28,6) DEFAULT 0.000000 COMMENT 'budget warning at amount',
  `budget_notes` longtext DEFAULT NULL COMMENT 'notes related to this fund',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time this fund was last touched (created or modified)',
  `budget_period_id` int(11) DEFAULT NULL COMMENT 'id of the budget that this fund belongs to (aqbudgetperiods.budget_period_id)',
  `sort1_authcat` varchar(80) DEFAULT NULL COMMENT 'statistical category for this fund',
  `sort2_authcat` varchar(80) DEFAULT NULL COMMENT 'second statistical category for this fund',
  `budget_owner_id` int(11) DEFAULT NULL COMMENT 'borrowernumber of the person who owns this fund (borrowers.borrowernumber)',
  `budget_permission` int(1) DEFAULT 0 COMMENT 'level of permission for this fund (used only by the owner, only by the library, or anyone)',
  PRIMARY KEY (`budget_id`),
  KEY `budget_parent_id` (`budget_parent_id`),
  KEY `budget_code` (`budget_code`),
  KEY `budget_branchcode` (`budget_branchcode`),
  KEY `budget_period_id` (`budget_period_id`),
  KEY `budget_owner_id` (`budget_owner_id`),
  CONSTRAINT `aqbudgetperiods_ibfk_1` FOREIGN KEY (`budget_period_id`) REFERENCES `aqbudgetperiods` (`budget_period_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqbudgets_planning`
--

DROP TABLE IF EXISTS `aqbudgets_planning`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbudgets_planning` (
  `plan_id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_id` int(11) NOT NULL,
  `budget_period_id` int(11) NOT NULL,
  `estimated_amount` decimal(28,6) DEFAULT NULL,
  `authcat` varchar(30) NOT NULL,
  `authvalue` varchar(30) NOT NULL,
  `display` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`plan_id`),
  KEY `budget_period_id` (`budget_period_id`),
  KEY `aqbudgets_planning_ifbk_1` (`budget_id`),
  CONSTRAINT `aqbudgets_planning_ifbk_1` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqcontacts`
--

DROP TABLE IF EXISTS `aqcontacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqcontacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique number assigned by Koha',
  `name` varchar(100) DEFAULT NULL COMMENT 'name of contact at vendor',
  `position` varchar(100) DEFAULT NULL COMMENT 'contact person''s position',
  `phone` varchar(100) DEFAULT NULL COMMENT 'contact''s phone number',
  `altphone` varchar(100) DEFAULT NULL COMMENT 'contact''s alternate phone number',
  `fax` varchar(100) DEFAULT NULL COMMENT 'contact''s fax number',
  `email` varchar(100) DEFAULT NULL COMMENT 'contact''s email address',
  `notes` longtext DEFAULT NULL COMMENT 'notes related to the contact',
  `orderacquisition` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'should this contact receive acquisition orders',
  `claimacquisition` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'should this contact receive acquisitions claims',
  `claimissues` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'should this contact receive serial claims',
  `acqprimary` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'is this the primary contact for acquisitions messages',
  `serialsprimary` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'is this the primary contact for serials messages',
  `booksellerid` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booksellerid_aqcontacts_fk` (`booksellerid`),
  CONSTRAINT `booksellerid_aqcontacts_fk` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqcontract`
--

DROP TABLE IF EXISTS `aqcontract`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqcontract` (
  `contractnumber` int(11) NOT NULL AUTO_INCREMENT,
  `contractstartdate` date DEFAULT NULL,
  `contractenddate` date DEFAULT NULL,
  `contractname` varchar(50) DEFAULT NULL,
  `contractdescription` longtext DEFAULT NULL,
  `booksellerid` int(11) NOT NULL,
  PRIMARY KEY (`contractnumber`),
  KEY `booksellerid_fk1` (`booksellerid`),
  CONSTRAINT `booksellerid_fk1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqinvoice_adjustments`
--

DROP TABLE IF EXISTS `aqinvoice_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqinvoice_adjustments` (
  `adjustment_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key for adjustments',
  `invoiceid` int(11) NOT NULL COMMENT 'foreign key to link an adjustment to an invoice',
  `adjustment` decimal(28,6) DEFAULT NULL COMMENT 'amount of adjustment',
  `reason` varchar(80) DEFAULT NULL COMMENT 'reason for adjustment defined by authorised values in ADJ_REASON category',
  `note` mediumtext DEFAULT NULL COMMENT 'text to explain adjustment',
  `budget_id` int(11) DEFAULT NULL COMMENT 'optional link to budget to apply adjustment to',
  `encumber_open` smallint(1) NOT NULL DEFAULT 1 COMMENT 'whether or not to encumber the funds when invoice is still open, 1 = yes, 0 = no',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'timestamp  of last adjustment to adjustment',
  PRIMARY KEY (`adjustment_id`),
  KEY `aqinvoice_adjustments_fk_invoiceid` (`invoiceid`),
  KEY `aqinvoice_adjustments_fk_budget_id` (`budget_id`),
  CONSTRAINT `aqinvoice_adjustments_fk_budget_id` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `aqinvoice_adjustments_fk_invoiceid` FOREIGN KEY (`invoiceid`) REFERENCES `aqinvoices` (`invoiceid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqinvoices`
--

DROP TABLE IF EXISTS `aqinvoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqinvoices` (
  `invoiceid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID of the invoice, primary key',
  `invoicenumber` longtext NOT NULL COMMENT 'Name of invoice',
  `booksellerid` int(11) NOT NULL COMMENT 'foreign key to aqbooksellers',
  `shipmentdate` date DEFAULT NULL COMMENT 'date of shipment',
  `billingdate` date DEFAULT NULL COMMENT 'date of billing',
  `closedate` date DEFAULT NULL COMMENT 'invoice close date, NULL means the invoice is open',
  `shipmentcost` decimal(28,6) DEFAULT NULL COMMENT 'shipment cost',
  `shipmentcost_budgetid` int(11) DEFAULT NULL COMMENT 'foreign key to aqbudgets, link the shipment cost to a budget',
  `message_id` int(11) DEFAULT NULL COMMENT 'foreign key to edifact invoice message',
  PRIMARY KEY (`invoiceid`),
  KEY `aqinvoices_fk_aqbooksellerid` (`booksellerid`),
  KEY `edifact_msg_fk` (`message_id`),
  KEY `aqinvoices_fk_shipmentcost_budgetid` (`shipmentcost_budgetid`),
  CONSTRAINT `aqinvoices_fk_aqbooksellerid` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqinvoices_fk_shipmentcost_budgetid` FOREIGN KEY (`shipmentcost_budgetid`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `edifact_msg_fk` FOREIGN KEY (`message_id`) REFERENCES `edifact_messages` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqorder_users`
--

DROP TABLE IF EXISTS `aqorder_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqorder_users` (
  `ordernumber` int(11) NOT NULL COMMENT 'the order this patrons receive notifications from (aqorders.ordernumber)',
  `borrowernumber` int(11) NOT NULL COMMENT 'the borrowernumber for the patron receiving notifications for this order (borrowers.borrowernumber)',
  PRIMARY KEY (`ordernumber`,`borrowernumber`),
  KEY `aqorder_users_ibfk_2` (`borrowernumber`),
  CONSTRAINT `aqorder_users_ibfk_1` FOREIGN KEY (`ordernumber`) REFERENCES `aqorders` (`ordernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorder_users_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqorders`
--

DROP TABLE IF EXISTS `aqorders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqorders` (
  `ordernumber` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique identifier assigned by Koha to each line',
  `biblionumber` int(11) DEFAULT NULL COMMENT 'links the order to the biblio being ordered (biblio.biblionumber)',
  `deleted_biblionumber` int(11) DEFAULT NULL COMMENT 'links the order to the deleted bibliographic record (deletedbiblio.biblionumber)',
  `entrydate` date DEFAULT NULL COMMENT 'the date the bib was added to the basket',
  `quantity` smallint(6) DEFAULT NULL COMMENT 'the quantity ordered',
  `currency` varchar(10) DEFAULT NULL COMMENT 'the currency used for the purchase',
  `listprice` decimal(28,6) DEFAULT NULL COMMENT 'the vendor price for this line item',
  `datereceived` date DEFAULT NULL COMMENT 'the date this order was received',
  `invoiceid` int(11) DEFAULT NULL COMMENT 'id of invoice',
  `freight` decimal(28,6) DEFAULT NULL COMMENT 'shipping costs (not used)',
  `unitprice` decimal(28,6) DEFAULT NULL COMMENT 'the actual cost entered when receiving this line item',
  `unitprice_tax_excluded` decimal(28,6) DEFAULT NULL COMMENT 'the unit price excluding tax (on receiving)',
  `unitprice_tax_included` decimal(28,6) DEFAULT NULL COMMENT 'the unit price including tax (on receiving)',
  `quantityreceived` smallint(6) NOT NULL DEFAULT 0 COMMENT 'the quantity that have been received so far',
  `created_by` int(11) DEFAULT NULL COMMENT 'the borrowernumber of order line''s creator',
  `datecancellationprinted` date DEFAULT NULL COMMENT 'the date the line item was deleted',
  `cancellationreason` mediumtext DEFAULT NULL COMMENT 'reason of cancellation',
  `order_internalnote` longtext DEFAULT NULL COMMENT 'notes related to this order line, made for staff',
  `order_vendornote` longtext DEFAULT NULL COMMENT 'notes related to this order line, made for vendor',
  `purchaseordernumber` longtext DEFAULT NULL COMMENT 'not used? always NULL',
  `basketno` int(11) DEFAULT NULL COMMENT 'links this order line to a specific basket (aqbasket.basketno)',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'the date and time this order line was last modified',
  `rrp` decimal(13,2) DEFAULT NULL COMMENT 'the retail cost for this line item',
  `replacementprice` decimal(28,6) DEFAULT NULL COMMENT 'the replacement cost for this line item',
  `rrp_tax_excluded` decimal(28,6) DEFAULT NULL COMMENT 'the replacement cost excluding tax',
  `rrp_tax_included` decimal(28,6) DEFAULT NULL COMMENT 'the replacement cost including tax',
  `ecost` decimal(13,2) DEFAULT NULL COMMENT 'the replacement cost for this line item',
  `ecost_tax_excluded` decimal(28,6) DEFAULT NULL COMMENT 'the estimated cost excluding tax',
  `ecost_tax_included` decimal(28,6) DEFAULT NULL COMMENT 'the estimated cost including tax',
  `tax_rate_bak` decimal(6,4) DEFAULT NULL COMMENT 'the tax rate for this line item (%)',
  `tax_rate_on_ordering` decimal(6,4) DEFAULT NULL COMMENT 'the tax rate on ordering for this line item (%)',
  `tax_rate_on_receiving` decimal(6,4) DEFAULT NULL COMMENT 'the tax rate on receiving for this line item (%)',
  `tax_value_bak` decimal(28,6) DEFAULT NULL COMMENT 'the tax value for this line item',
  `tax_value_on_ordering` decimal(28,6) DEFAULT NULL COMMENT 'the tax value on ordering for this line item',
  `tax_value_on_receiving` decimal(28,6) DEFAULT NULL COMMENT 'the tax value on receiving for this line item',
  `discount` float(6,4) DEFAULT NULL COMMENT 'the discount for this line item (%)',
  `budget_id` int(11) NOT NULL COMMENT 'the fund this order goes against (aqbudgets.budget_id)',
  `budgetdate` date DEFAULT NULL COMMENT 'not used? always NULL',
  `sort1` varchar(80) DEFAULT NULL COMMENT 'statistical field',
  `sort2` varchar(80) DEFAULT NULL COMMENT 'second statistical field',
  `sort1_authcat` varchar(10) DEFAULT NULL,
  `sort2_authcat` varchar(10) DEFAULT NULL,
  `uncertainprice` tinyint(1) DEFAULT NULL COMMENT 'was this price uncertain (1 for yes, 0 for no)',
  `subscriptionid` int(11) DEFAULT NULL COMMENT 'links this order line to a subscription (subscription.subscriptionid)',
  `parent_ordernumber` int(11) DEFAULT NULL COMMENT 'ordernumber of parent order line, or same as ordernumber if no parent',
  `orderstatus` varchar(16) DEFAULT 'new' COMMENT 'the current status for this line item. Can be ''new'', ''ordered'', ''partial'', ''complete'' or ''cancelled''',
  `line_item_id` varchar(35) DEFAULT NULL COMMENT 'Supplier''s article id for Edifact orderline',
  `suppliers_reference_number` varchar(35) DEFAULT NULL COMMENT 'Suppliers unique edifact quote ref',
  `suppliers_reference_qualifier` varchar(3) DEFAULT NULL COMMENT 'Type of number above usually ''QLI''',
  `suppliers_report` mediumtext DEFAULT NULL COMMENT 'reports received from suppliers',
  `estimated_delivery_date` date DEFAULT NULL COMMENT 'Estimated delivery date',
  `invoice_unitprice` decimal(28,6) DEFAULT NULL COMMENT 'the unit price in foreign currency',
  `invoice_currency` varchar(10) DEFAULT NULL COMMENT 'the currency of the invoice_unitprice',
  PRIMARY KEY (`ordernumber`),
  KEY `basketno` (`basketno`),
  KEY `biblionumber` (`biblionumber`),
  KEY `budget_id` (`budget_id`),
  KEY `parent_ordernumber` (`parent_ordernumber`),
  KEY `orderstatus` (`orderstatus`),
  KEY `aqorders_created_by` (`created_by`),
  KEY `aqorders_ibfk_3` (`invoiceid`),
  KEY `aqorders_subscriptionid` (`subscriptionid`),
  KEY `aqorders_currency` (`currency`),
  KEY `aqorders_invoice_currency` (`invoice_currency`),
  CONSTRAINT `aqorders_budget_id_fk` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorders_created_by` FOREIGN KEY (`created_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `aqorders_currency` FOREIGN KEY (`currency`) REFERENCES `currency` (`currency`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `aqorders_ibfk_1` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorders_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `aqorders_ibfk_3` FOREIGN KEY (`invoiceid`) REFERENCES `aqinvoices` (`invoiceid`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `aqorders_invoice_currency` FOREIGN KEY (`invoice_currency`) REFERENCES `currency` (`currency`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `aqorders_subscriptionid` FOREIGN KEY (`subscriptionid`) REFERENCES `subscription` (`subscriptionid`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqorders_claims`
--

DROP TABLE IF EXISTS `aqorders_claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqorders_claims` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID of the claims',
  `ordernumber` int(11) NOT NULL COMMENT 'order linked to this claim',
  `claimed_on` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Date of the claims',
  PRIMARY KEY (`id`),
  KEY `aqorders_claims_ibfk_1` (`ordernumber`),
  CONSTRAINT `aqorders_claims_ibfk_1` FOREIGN KEY (`ordernumber`) REFERENCES `aqorders` (`ordernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqorders_items`
--

DROP TABLE IF EXISTS `aqorders_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqorders_items` (
  `ordernumber` int(11) NOT NULL COMMENT 'the order this item is attached to (aqorders.ordernumber)',
  `itemnumber` int(11) NOT NULL COMMENT 'the item number for this item (items.itemnumber)',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'the date and time this order item was last touched',
  PRIMARY KEY (`itemnumber`),
  KEY `ordernumber` (`ordernumber`),
  CONSTRAINT `aqorders_items_ibfk_1` FOREIGN KEY (`ordernumber`) REFERENCES `aqorders` (`ordernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aqorders_transfers`
--

DROP TABLE IF EXISTS `aqorders_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqorders_transfers` (
  `ordernumber_from` int(11) DEFAULT NULL,
  `ordernumber_to` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `ordernumber_from` (`ordernumber_from`),
  UNIQUE KEY `ordernumber_to` (`ordernumber_to`),
  CONSTRAINT `aqorders_transfers_ordernumber_from` FOREIGN KEY (`ordernumber_from`) REFERENCES `aqorders` (`ordernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `aqorders_transfers_ordernumber_to` FOREIGN KEY (`ordernumber_to`) REFERENCES `aqorders` (`ordernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article_requests`
--

DROP TABLE IF EXISTS `article_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL,
  `biblionumber` int(11) NOT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `title` mediumtext DEFAULT NULL,
  `author` mediumtext DEFAULT NULL,
  `volume` mediumtext DEFAULT NULL,
  `issue` mediumtext DEFAULT NULL,
  `date` mediumtext DEFAULT NULL,
  `pages` mediumtext DEFAULT NULL,
  `chapters` mediumtext DEFAULT NULL,
  `patron_notes` mediumtext DEFAULT NULL,
  `status` enum('REQUESTED','PENDING','PROCESSING','COMPLETED','CANCELED') NOT NULL DEFAULT 'REQUESTED',
  `notes` mediumtext DEFAULT NULL,
  `format` enum('PHOTOCOPY','SCAN') NOT NULL DEFAULT 'PHOTOCOPY',
  `urls` mediumtext DEFAULT NULL,
  `cancellation_reason` varchar(80) DEFAULT NULL COMMENT 'optional authorised value AR_CANCELLATION',
  `debit_id` int(11) DEFAULT NULL COMMENT 'Debit line with cost for article scan request',
  `created_on` timestamp NULL DEFAULT NULL COMMENT 'Be careful with two timestamps in one table not allowing NULL',
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `toc_request` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'borrower requested table of contents',
  PRIMARY KEY (`id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  KEY `debit_id` (`debit_id`),
  CONSTRAINT `article_requests_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_5` FOREIGN KEY (`debit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `audio_alerts`
--

DROP TABLE IF EXISTS `audio_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audio_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `precedence` smallint(5) unsigned NOT NULL,
  `selector` varchar(255) NOT NULL,
  `sound` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `precedence` (`precedence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_header`
--

DROP TABLE IF EXISTS `auth_header`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_header` (
  `authid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `datecreated` date DEFAULT NULL,
  `modification_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `origincode` varchar(20) DEFAULT NULL,
  `authtrees` longtext DEFAULT NULL,
  `marc` blob DEFAULT NULL,
  `linkid` bigint(20) DEFAULT NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY (`authid`),
  KEY `origincode` (`origincode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_subfield_structure`
--

DROP TABLE IF EXISTS `auth_subfield_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_subfield_structure` (
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `tagfield` varchar(3) NOT NULL DEFAULT '',
  `tagsubfield` varchar(1) NOT NULL DEFAULT '',
  `liblibrarian` varchar(255) NOT NULL DEFAULT '',
  `libopac` varchar(255) NOT NULL DEFAULT '',
  `repeatable` tinyint(4) NOT NULL DEFAULT 0,
  `mandatory` tinyint(4) NOT NULL DEFAULT 0,
  `tab` tinyint(1) DEFAULT NULL,
  `authorised_value` varchar(32) DEFAULT NULL,
  `value_builder` varchar(80) DEFAULT NULL,
  `seealso` varchar(255) DEFAULT NULL,
  `isurl` tinyint(1) DEFAULT NULL,
  `hidden` tinyint(3) NOT NULL DEFAULT 0,
  `linkid` tinyint(1) NOT NULL DEFAULT 0,
  `kohafield` varchar(45) DEFAULT '',
  `frameworkcode` varchar(10) NOT NULL DEFAULT '',
  `defaultvalue` mediumtext DEFAULT NULL,
  `display_order` int(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`authtypecode`,`tagfield`,`tagsubfield`),
  KEY `tab` (`authtypecode`,`tab`),
  CONSTRAINT `auth_subfield_structure_ibfk_1` FOREIGN KEY (`authtypecode`) REFERENCES `auth_types` (`authtypecode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_tag_structure`
--

DROP TABLE IF EXISTS `auth_tag_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_tag_structure` (
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `tagfield` varchar(3) NOT NULL DEFAULT '',
  `liblibrarian` varchar(255) NOT NULL DEFAULT '',
  `libopac` varchar(255) NOT NULL DEFAULT '',
  `repeatable` tinyint(4) NOT NULL DEFAULT 0,
  `mandatory` tinyint(4) NOT NULL DEFAULT 0,
  `authorised_value` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`authtypecode`,`tagfield`),
  CONSTRAINT `auth_tag_structure_ibfk_1` FOREIGN KEY (`authtypecode`) REFERENCES `auth_types` (`authtypecode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_types`
--

DROP TABLE IF EXISTS `auth_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_types` (
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `authtypetext` varchar(255) NOT NULL DEFAULT '',
  `auth_tag_to_report` varchar(3) NOT NULL DEFAULT '',
  `summary` longtext NOT NULL,
  PRIMARY KEY (`authtypecode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authorised_value_categories`
--

DROP TABLE IF EXISTS `authorised_value_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authorised_value_categories` (
  `category_name` varchar(32) NOT NULL DEFAULT '',
  `is_system` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authorised_values`
--

DROP TABLE IF EXISTS `authorised_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authorised_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key, used to identify the authorized value',
  `category` varchar(32) NOT NULL DEFAULT '' COMMENT 'key used to identify the authorized value category',
  `authorised_value` varchar(80) NOT NULL DEFAULT '' COMMENT 'code use to identify the authorized value',
  `lib` varchar(200) DEFAULT NULL COMMENT 'authorized value description as printed in the staff interface',
  `lib_opac` varchar(200) DEFAULT NULL COMMENT 'authorized value description as printed in the OPAC',
  `imageurl` varchar(200) DEFAULT NULL COMMENT 'authorized value URL',
  PRIMARY KEY (`id`),
  UNIQUE KEY `av_uniq` (`category`,`authorised_value`),
  KEY `name` (`category`),
  KEY `lib` (`lib`(191)),
  KEY `auth_value_idx` (`authorised_value`),
  CONSTRAINT `authorised_values_authorised_values_category` FOREIGN KEY (`category`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authorised_values_branches`
--

DROP TABLE IF EXISTS `authorised_values_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authorised_values_branches` (
  `av_id` int(11) NOT NULL,
  `branchcode` varchar(10) NOT NULL,
  KEY `av_id` (`av_id`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `authorised_values_branches_ibfk_1` FOREIGN KEY (`av_id`) REFERENCES `authorised_values` (`id`) ON DELETE CASCADE,
  CONSTRAINT `authorised_values_branches_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `background_jobs`
--

DROP TABLE IF EXISTS `background_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `background_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(32) DEFAULT NULL,
  `progress` int(11) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `borrowernumber` int(11) DEFAULT NULL,
  `type` varchar(64) DEFAULT NULL,
  `queue` varchar(191) NOT NULL DEFAULT 'default' COMMENT 'Name of the queue the job is sent to',
  `data` longtext DEFAULT NULL,
  `context` longtext DEFAULT NULL COMMENT 'JSON-serialized context information for the job',
  `enqueued_on` datetime DEFAULT NULL,
  `started_on` datetime DEFAULT NULL,
  `ended_on` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `queue` (`queue`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biblio`
--

DROP TABLE IF EXISTS `biblio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biblio` (
  `biblionumber` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned to each bibliographic record',
  `frameworkcode` varchar(4) NOT NULL DEFAULT '' COMMENT 'foreign key from the biblio_framework table to identify which framework was used in cataloging this record',
  `author` longtext DEFAULT NULL COMMENT 'statement of responsibility from MARC record (100$a in MARC21)',
  `title` longtext DEFAULT NULL COMMENT 'title (without the subtitle) from the MARC record (245$a in MARC21)',
  `medium` longtext DEFAULT NULL COMMENT 'medium from the MARC record (245$h in MARC21)',
  `subtitle` longtext DEFAULT NULL COMMENT 'remainder of the title from the MARC record (245$b in MARC21)',
  `part_number` longtext DEFAULT NULL COMMENT 'part number from the MARC record (245$n in MARC21)',
  `part_name` longtext DEFAULT NULL COMMENT 'part name from the MARC record (245$p in MARC21)',
  `unititle` longtext DEFAULT NULL COMMENT 'uniform title (without the subtitle) from the MARC record (240$a in MARC21)',
  `notes` longtext DEFAULT NULL COMMENT 'values from the general notes field in the MARC record (500$a in MARC21) split by bar (|)',
  `serial` tinyint(1) DEFAULT NULL COMMENT 'Boolean indicating whether biblio is for a serial',
  `seriestitle` longtext DEFAULT NULL,
  `copyrightdate` smallint(6) DEFAULT NULL COMMENT 'publication or copyright date from the MARC record',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time this record was last touched',
  `datecreated` date NOT NULL COMMENT 'the date this record was added to Koha',
  `abstract` longtext DEFAULT NULL COMMENT 'summary from the MARC record (520$a in MARC21)',
  PRIMARY KEY (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biblio_framework`
--

DROP TABLE IF EXISTS `biblio_framework`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biblio_framework` (
  `frameworkcode` varchar(4) NOT NULL DEFAULT '' COMMENT 'the unique code assigned to the framework',
  `frameworktext` varchar(255) NOT NULL DEFAULT '' COMMENT 'the description/name given to the framework',
  PRIMARY KEY (`frameworkcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biblio_metadata`
--

DROP TABLE IF EXISTS `biblio_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biblio_metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `biblionumber` int(11) NOT NULL,
  `format` varchar(16) NOT NULL,
  `schema` varchar(16) NOT NULL,
  `metadata` longtext NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `biblio_metadata_uniq_key` (`biblionumber`,`format`,`schema`),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `record_metadata_fk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biblioitems`
--

DROP TABLE IF EXISTS `biblioitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biblioitems` (
  `biblioitemnumber` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key, unique identifier assigned by Koha',
  `biblionumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key linking this table to the biblio table',
  `volume` longtext DEFAULT NULL,
  `number` longtext DEFAULT NULL,
  `itemtype` varchar(10) DEFAULT NULL COMMENT 'biblio level item type (MARC21 942$c)',
  `isbn` longtext DEFAULT NULL COMMENT 'ISBN (MARC21 020$a)',
  `issn` longtext DEFAULT NULL COMMENT 'ISSN (MARC21 022$a)',
  `ean` longtext DEFAULT NULL,
  `publicationyear` mediumtext DEFAULT NULL,
  `publishercode` text DEFAULT NULL COMMENT 'publisher (MARC21 260$b and 246$b)',
  `volumedate` date DEFAULT NULL,
  `volumedesc` mediumtext DEFAULT NULL COMMENT 'volume information (MARC21 362$a)',
  `collectiontitle` longtext DEFAULT NULL,
  `collectionissn` mediumtext DEFAULT NULL,
  `collectionvolume` longtext DEFAULT NULL,
  `editionstatement` mediumtext DEFAULT NULL,
  `editionresponsibility` mediumtext DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `illus` text DEFAULT NULL COMMENT 'illustrations (MARC21 300$b)',
  `pages` text DEFAULT NULL COMMENT 'number of pages (MARC21 300$a)',
  `notes` longtext DEFAULT NULL,
  `size` text DEFAULT NULL COMMENT 'material size (MARC21 300$c)',
  `place` text DEFAULT NULL COMMENT 'publication place (MARC21 260$a and 264$a)',
  `lccn` longtext DEFAULT NULL COMMENT 'library of congress control number (MARC21 010$a)',
  `url` mediumtext DEFAULT NULL COMMENT 'url (MARC21 856$u)',
  `cn_source` varchar(10) DEFAULT NULL COMMENT 'classification source (MARC21 942$2)',
  `cn_class` varchar(30) DEFAULT NULL,
  `cn_item` varchar(10) DEFAULT NULL,
  `cn_suffix` varchar(10) DEFAULT NULL,
  `cn_sort` varchar(255) DEFAULT NULL COMMENT 'normalized version of the call number used for sorting',
  `agerestriction` varchar(255) DEFAULT NULL COMMENT 'target audience/age restriction from the bib record (MARC21 521$a)',
  `totalissues` int(10) DEFAULT NULL,
  PRIMARY KEY (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `itemtype_idx` (`itemtype`),
  KEY `isbn` (`isbn`(191)),
  KEY `issn` (`issn`(191)),
  KEY `ean` (`ean`(191)),
  KEY `publishercode` (`publishercode`(191)),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `biblioitems_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_attribute_types`
--

DROP TABLE IF EXISTS `borrower_attribute_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_attribute_types` (
  `code` varchar(10) NOT NULL COMMENT 'unique key used to identify each custom field',
  `description` varchar(255) NOT NULL COMMENT 'description for each custom field',
  `repeatable` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines whether one patron/borrower can have multiple values for this custom field  (1 for yes, 0 for no)',
  `unique_id` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if this value needs to be unique (1 for yes, 0 for no)',
  `opac_display` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if this field is visible to patrons on their account in the OPAC (1 for yes, 0 for no)',
  `opac_editable` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if this field is editable by patrons on their account in the OPAC (1 for yes, 0 for no)',
  `staff_searchable` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if this field is searchable via the patron search in the staff interface (1 for yes, 0 for no)',
  `authorised_value_category` varchar(32) DEFAULT NULL COMMENT 'foreign key from authorised_values that links this custom field to an authorized value category',
  `display_checkout` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if this field displays in checkout screens',
  `category_code` varchar(10) DEFAULT NULL COMMENT 'defines a category for an attribute_type',
  `class` varchar(255) NOT NULL DEFAULT '' COMMENT 'defines a class for an attribute_type',
  `keep_for_pseudonymization` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if this field is copied to anonymized_borrower_attributes (1 for yes, 0 for no)',
  `mandatory` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if the attribute is mandatory or not',
  PRIMARY KEY (`code`),
  KEY `auth_val_cat_idx` (`authorised_value_category`),
  KEY `category_code` (`category_code`),
  CONSTRAINT `borrower_attribute_types_ibfk_1` FOREIGN KEY (`category_code`) REFERENCES `categories` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_attribute_types_branches`
--

DROP TABLE IF EXISTS `borrower_attribute_types_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_attribute_types_branches` (
  `bat_code` varchar(10) DEFAULT NULL,
  `b_branchcode` varchar(10) DEFAULT NULL,
  KEY `bat_code` (`bat_code`),
  KEY `b_branchcode` (`b_branchcode`),
  CONSTRAINT `borrower_attribute_types_branches_ibfk_1` FOREIGN KEY (`bat_code`) REFERENCES `borrower_attribute_types` (`code`) ON DELETE CASCADE,
  CONSTRAINT `borrower_attribute_types_branches_ibfk_2` FOREIGN KEY (`b_branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_attributes`
--

DROP TABLE IF EXISTS `borrower_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Row id field',
  `borrowernumber` int(11) NOT NULL COMMENT 'foreign key from the borrowers table, defines which patron/borrower has this attribute',
  `code` varchar(10) NOT NULL COMMENT 'foreign key from the borrower_attribute_types table, defines which custom field this value was entered for',
  `attribute` varchar(255) DEFAULT NULL COMMENT 'custom patron field value',
  PRIMARY KEY (`id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `code_attribute` (`code`,`attribute`(191)),
  CONSTRAINT `borrower_attributes_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_attributes_ibfk_2` FOREIGN KEY (`code`) REFERENCES `borrower_attribute_types` (`code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_debarments`
--

DROP TABLE IF EXISTS `borrower_debarments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_debarments` (
  `borrower_debarment_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key for the restriction',
  `borrowernumber` int(11) NOT NULL COMMENT 'foreign key for borrowers.borrowernumber for patron who is restricted',
  `expiration` date DEFAULT NULL COMMENT 'expiration date of the restriction',
  `type` varchar(50) NOT NULL COMMENT 'type of restriction, FK to restriction_types.code',
  `comment` mediumtext DEFAULT NULL COMMENT 'comments about the restriction',
  `manager_id` int(11) DEFAULT NULL COMMENT 'foreign key for borrowers.borrowernumber for the librarian managing the restriction',
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date the restriction was added',
  `updated` timestamp NULL DEFAULT NULL COMMENT 'date the restriction was updated',
  PRIMARY KEY (`borrower_debarment_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `borrower_debarments_ibfk_2` (`type`),
  CONSTRAINT `borrower_debarments_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_debarments_ibfk_2` FOREIGN KEY (`type`) REFERENCES `restriction_types` (`code`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_files`
--

DROP TABLE IF EXISTS `borrower_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_files` (
  `file_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key',
  `borrowernumber` int(11) NOT NULL COMMENT 'foreign key linking to the patron via the borrowernumber',
  `file_name` varchar(255) NOT NULL COMMENT 'file name',
  `file_type` varchar(255) NOT NULL COMMENT 'type of file',
  `file_description` varchar(255) DEFAULT NULL COMMENT 'description given to the file',
  `file_content` longblob NOT NULL COMMENT 'the file',
  `date_uploaded` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date and time the file was added',
  PRIMARY KEY (`file_id`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT `borrower_files_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_message_preferences`
--

DROP TABLE IF EXISTS `borrower_message_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_message_preferences` (
  `borrower_message_preference_id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) DEFAULT NULL,
  `categorycode` varchar(10) DEFAULT NULL,
  `message_attribute_id` int(11) DEFAULT 0,
  `days_in_advance` int(11) DEFAULT NULL,
  `wants_digest` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`borrower_message_preference_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `categorycode` (`categorycode`),
  KEY `message_attribute_id` (`message_attribute_id`),
  CONSTRAINT `borrower_message_preferences_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_preferences_ibfk_2` FOREIGN KEY (`message_attribute_id`) REFERENCES `message_attributes` (`message_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_preferences_ibfk_3` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_message_transport_preferences`
--

DROP TABLE IF EXISTS `borrower_message_transport_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_message_transport_preferences` (
  `borrower_message_preference_id` int(11) NOT NULL DEFAULT 0,
  `message_transport_type` varchar(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`borrower_message_preference_id`,`message_transport_type`),
  KEY `message_transport_type` (`message_transport_type`),
  CONSTRAINT `borrower_message_transport_preferences_ibfk_1` FOREIGN KEY (`borrower_message_preference_id`) REFERENCES `borrower_message_preferences` (`borrower_message_preference_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_transport_preferences_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_modifications`
--

DROP TABLE IF EXISTS `borrower_modifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_modifications` (
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `verification_token` varchar(255) NOT NULL DEFAULT '',
  `changed_fields` mediumtext DEFAULT NULL,
  `borrowernumber` int(11) NOT NULL DEFAULT 0,
  `cardnumber` varchar(32) DEFAULT NULL,
  `surname` longtext DEFAULT NULL,
  `firstname` mediumtext DEFAULT NULL,
  `middle_name` longtext DEFAULT NULL COMMENT 'patron/borrower''s middle name',
  `title` longtext DEFAULT NULL,
  `othernames` longtext DEFAULT NULL,
  `initials` mediumtext DEFAULT NULL,
  `pronouns` longtext DEFAULT NULL,
  `streetnumber` varchar(10) DEFAULT NULL,
  `streettype` varchar(50) DEFAULT NULL,
  `address` longtext DEFAULT NULL,
  `address2` mediumtext DEFAULT NULL,
  `city` longtext DEFAULT NULL,
  `state` mediumtext DEFAULT NULL,
  `zipcode` varchar(25) DEFAULT NULL,
  `country` mediumtext DEFAULT NULL,
  `email` longtext DEFAULT NULL,
  `phone` mediumtext DEFAULT NULL,
  `mobile` varchar(50) DEFAULT NULL,
  `fax` longtext DEFAULT NULL,
  `emailpro` mediumtext DEFAULT NULL,
  `phonepro` mediumtext DEFAULT NULL,
  `B_streetnumber` varchar(10) DEFAULT NULL,
  `B_streettype` varchar(50) DEFAULT NULL,
  `B_address` varchar(100) DEFAULT NULL,
  `B_address2` mediumtext DEFAULT NULL,
  `B_city` longtext DEFAULT NULL,
  `B_state` mediumtext DEFAULT NULL,
  `B_zipcode` varchar(25) DEFAULT NULL,
  `B_country` mediumtext DEFAULT NULL,
  `B_email` mediumtext DEFAULT NULL,
  `B_phone` longtext DEFAULT NULL,
  `dateofbirth` date DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `categorycode` varchar(10) DEFAULT NULL,
  `dateenrolled` date DEFAULT NULL,
  `dateexpiry` date DEFAULT NULL,
  `date_renewed` date DEFAULT NULL,
  `gonenoaddress` tinyint(1) DEFAULT NULL,
  `lost` tinyint(1) DEFAULT NULL,
  `debarred` date DEFAULT NULL,
  `debarredcomment` varchar(255) DEFAULT NULL,
  `contactname` longtext DEFAULT NULL,
  `contactfirstname` mediumtext DEFAULT NULL,
  `contacttitle` mediumtext DEFAULT NULL,
  `borrowernotes` longtext DEFAULT NULL,
  `relationship` varchar(100) DEFAULT NULL,
  `sex` varchar(1) DEFAULT NULL,
  `password` varchar(30) DEFAULT NULL,
  `flags` bigint(11) DEFAULT NULL,
  `userid` varchar(75) DEFAULT NULL,
  `opacnote` longtext DEFAULT NULL,
  `contactnote` varchar(255) DEFAULT NULL,
  `sort1` varchar(80) DEFAULT NULL,
  `sort2` varchar(80) DEFAULT NULL,
  `altcontactfirstname` varchar(255) DEFAULT NULL,
  `altcontactsurname` varchar(255) DEFAULT NULL,
  `altcontactaddress1` varchar(255) DEFAULT NULL,
  `altcontactaddress2` varchar(255) DEFAULT NULL,
  `altcontactaddress3` varchar(255) DEFAULT NULL,
  `altcontactstate` mediumtext DEFAULT NULL,
  `altcontactzipcode` varchar(50) DEFAULT NULL,
  `altcontactcountry` mediumtext DEFAULT NULL,
  `altcontactphone` varchar(50) DEFAULT NULL,
  `smsalertnumber` varchar(50) DEFAULT NULL,
  `privacy` int(11) DEFAULT NULL,
  `extended_attributes` mediumtext DEFAULT NULL,
  `gdpr_proc_consent` datetime DEFAULT NULL COMMENT 'data processing consent',
  `primary_contact_method` varchar(45) DEFAULT NULL COMMENT 'useful for reporting purposes',
  PRIMARY KEY (`verification_token`(191),`borrowernumber`),
  KEY `verification_token` (`verification_token`(191)),
  KEY `borrowernumber` (`borrowernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_password_recovery`
--

DROP TABLE IF EXISTS `borrower_password_recovery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_password_recovery` (
  `borrowernumber` int(11) NOT NULL COMMENT 'the user asking a password recovery',
  `uuid` varchar(128) NOT NULL COMMENT 'a unique string to identify a password recovery attempt',
  `valid_until` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'a time limit on the password recovery attempt',
  PRIMARY KEY (`borrowernumber`),
  KEY `borrowernumber` (`borrowernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_relationships`
--

DROP TABLE IF EXISTS `borrower_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guarantor_id` int(11) NOT NULL,
  `guarantee_id` int(11) NOT NULL,
  `relationship` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `guarantor_guarantee_idx` (`guarantor_id`,`guarantee_id`),
  KEY `r_guarantee` (`guarantee_id`),
  CONSTRAINT `r_guarantee` FOREIGN KEY (`guarantee_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `r_guarantor` FOREIGN KEY (`guarantor_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrowers`
--

DROP TABLE IF EXISTS `borrowers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrowers` (
  `borrowernumber` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key, Koha assigned ID number for patrons/borrowers',
  `cardnumber` varchar(32) DEFAULT NULL COMMENT 'unique key, library assigned ID number for patrons/borrowers',
  `surname` longtext DEFAULT NULL COMMENT 'patron/borrower''s last name (surname)',
  `firstname` mediumtext DEFAULT NULL COMMENT 'patron/borrower''s first name',
  `middle_name` longtext DEFAULT NULL COMMENT 'patron/borrower''s middle name',
  `title` longtext DEFAULT NULL COMMENT 'patron/borrower''s title, for example: Mr. or Mrs.',
  `othernames` longtext DEFAULT NULL COMMENT 'any other names associated with the patron/borrower',
  `initials` mediumtext DEFAULT NULL COMMENT 'initials for your patron/borrower',
  `pronouns` longtext DEFAULT NULL COMMENT 'patron/borrower pronouns',
  `streetnumber` tinytext DEFAULT NULL COMMENT 'the house number for your patron/borrower''s primary address',
  `streettype` tinytext DEFAULT NULL COMMENT 'the street type (Rd., Blvd, etc) for your patron/borrower''s primary address',
  `address` longtext DEFAULT NULL COMMENT 'the first address line for your patron/borrower''s primary address',
  `address2` mediumtext DEFAULT NULL COMMENT 'the second address line for your patron/borrower''s primary address',
  `city` longtext DEFAULT NULL COMMENT 'the city or town for your patron/borrower''s primary address',
  `state` mediumtext DEFAULT NULL COMMENT 'the state or province for your patron/borrower''s primary address',
  `zipcode` tinytext DEFAULT NULL COMMENT 'the zip or postal code for your patron/borrower''s primary address',
  `country` mediumtext DEFAULT NULL COMMENT 'the country for your patron/borrower''s primary address',
  `email` longtext DEFAULT NULL COMMENT 'the primary email address for your patron/borrower''s primary address',
  `phone` mediumtext DEFAULT NULL COMMENT 'the primary phone number for your patron/borrower''s primary address',
  `mobile` tinytext DEFAULT NULL COMMENT 'the other phone number for your patron/borrower''s primary address',
  `fax` longtext DEFAULT NULL COMMENT 'the fax number for your patron/borrower''s primary address',
  `emailpro` mediumtext DEFAULT NULL COMMENT 'the secondary email addres for your patron/borrower''s primary address',
  `phonepro` mediumtext DEFAULT NULL COMMENT 'the secondary phone number for your patron/borrower''s primary address',
  `B_streetnumber` tinytext DEFAULT NULL COMMENT 'the house number for your patron/borrower''s alternate address',
  `B_streettype` tinytext DEFAULT NULL COMMENT 'the street type (Rd., Blvd, etc) for your patron/borrower''s alternate address',
  `B_address` mediumtext DEFAULT NULL COMMENT 'the first address line for your patron/borrower''s alternate address',
  `B_address2` mediumtext DEFAULT NULL COMMENT 'the second address line for your patron/borrower''s alternate address',
  `B_city` longtext DEFAULT NULL COMMENT 'the city or town for your patron/borrower''s alternate address',
  `B_state` mediumtext DEFAULT NULL COMMENT 'the state for your patron/borrower''s alternate address',
  `B_zipcode` tinytext DEFAULT NULL COMMENT 'the zip or postal code for your patron/borrower''s alternate address',
  `B_country` mediumtext DEFAULT NULL COMMENT 'the country for your patron/borrower''s alternate address',
  `B_email` mediumtext DEFAULT NULL COMMENT 'the patron/borrower''s alternate email address',
  `B_phone` longtext DEFAULT NULL COMMENT 'the patron/borrower''s alternate phone number',
  `dateofbirth` date DEFAULT NULL COMMENT 'the patron/borrower''s date of birth (YYYY-MM-DD)',
  `branchcode` varchar(10) NOT NULL DEFAULT '' COMMENT 'foreign key from the branches table, includes the code of the patron/borrower''s home branch',
  `categorycode` varchar(10) NOT NULL DEFAULT '' COMMENT 'foreign key from the categories table, includes the code of the patron category',
  `dateenrolled` date DEFAULT NULL COMMENT 'date the patron was added to Koha (YYYY-MM-DD)',
  `dateexpiry` date DEFAULT NULL COMMENT 'date the patron/borrower''s card is set to expire (YYYY-MM-DD)',
  `password_expiration_date` date DEFAULT NULL COMMENT 'date the patron/borrower''s password is set to expire (YYYY-MM-DD)',
  `date_renewed` date DEFAULT NULL COMMENT 'date the patron/borrower''s card was last renewed',
  `gonenoaddress` tinyint(1) DEFAULT NULL COMMENT 'set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having an unconfirmed address',
  `lost` tinyint(1) DEFAULT NULL COMMENT 'set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having lost their card',
  `debarred` date DEFAULT NULL COMMENT 'until this date the patron can only check-in (no loans, no holds, etc.), is a fine based on days instead of money (YYYY-MM-DD)',
  `debarredcomment` varchar(255) DEFAULT NULL COMMENT 'comment on the stop of the patron',
  `contactname` longtext DEFAULT NULL COMMENT 'used for children and profesionals to include surname or last name of guarantor or organization name',
  `contactfirstname` mediumtext DEFAULT NULL COMMENT 'used for children to include first name of guarantor',
  `contacttitle` mediumtext DEFAULT NULL COMMENT 'used for children to include title (Mr., Mrs., etc) of guarantor',
  `borrowernotes` longtext DEFAULT NULL COMMENT 'a note on the patron/borrower''s account that is only visible in the staff interface',
  `relationship` varchar(100) DEFAULT NULL COMMENT 'used for children to include the relationship to their guarantor',
  `sex` varchar(1) DEFAULT NULL COMMENT 'patron/borrower''s gender',
  `password` varchar(60) DEFAULT NULL COMMENT 'patron/borrower''s Bcrypt encrypted password',
  `secret` mediumtext DEFAULT NULL COMMENT 'Secret for 2FA',
  `auth_method` enum('password','two-factor') NOT NULL DEFAULT 'password' COMMENT 'Authentication method',
  `flags` bigint(11) DEFAULT NULL COMMENT 'will include a number associated with the staff member''s permissions',
  `userid` varchar(75) DEFAULT NULL COMMENT 'patron/borrower''s opac and/or staff interface log in',
  `opacnote` longtext DEFAULT NULL COMMENT 'a note on the patron/borrower''s account that is visible in the OPAC and staff interface',
  `contactnote` varchar(255) DEFAULT NULL COMMENT 'a note related to the patron/borrower''s alternate address',
  `sort1` varchar(80) DEFAULT NULL COMMENT 'a field that can be used for any information unique to the library',
  `sort2` varchar(80) DEFAULT NULL COMMENT 'a field that can be used for any information unique to the library',
  `altcontactfirstname` mediumtext DEFAULT NULL COMMENT 'first name of alternate contact for the patron/borrower',
  `altcontactsurname` mediumtext DEFAULT NULL COMMENT 'surname or last name of the alternate contact for the patron/borrower',
  `altcontactaddress1` mediumtext DEFAULT NULL COMMENT 'the first address line for the alternate contact for the patron/borrower',
  `altcontactaddress2` mediumtext DEFAULT NULL COMMENT 'the second address line for the alternate contact for the patron/borrower',
  `altcontactaddress3` mediumtext DEFAULT NULL COMMENT 'the city for the alternate contact for the patron/borrower',
  `altcontactstate` mediumtext DEFAULT NULL COMMENT 'the state for the alternate contact for the patron/borrower',
  `altcontactzipcode` mediumtext DEFAULT NULL COMMENT 'the zipcode for the alternate contact for the patron/borrower',
  `altcontactcountry` mediumtext DEFAULT NULL COMMENT 'the country for the alternate contact for the patron/borrower',
  `altcontactphone` mediumtext DEFAULT NULL COMMENT 'the phone number for the alternate contact for the patron/borrower',
  `smsalertnumber` varchar(50) DEFAULT NULL COMMENT 'the mobile phone number where the patron/borrower would like to receive notices (if SMS turned on)',
  `sms_provider_id` int(11) DEFAULT NULL COMMENT 'the provider of the mobile phone number defined in smsalertnumber',
  `privacy` int(11) NOT NULL DEFAULT 1 COMMENT 'patron/borrower''s privacy settings related to their checkout history',
  `privacy_guarantor_fines` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'controls if relatives can see this patron''s fines',
  `privacy_guarantor_checkouts` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'controls if relatives can see this patron''s checkouts',
  `checkprevcheckout` varchar(7) NOT NULL DEFAULT 'inherit' COMMENT 'produce a warning for this patron if this item has previously been checked out to this patron if ''yes'', not if ''no'', defer to category setting if ''inherit''.',
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'time of last change could be useful for synchronization with external systems (among others)',
  `lastseen` datetime DEFAULT NULL COMMENT 'last time a patron has been seen (connected at the OPAC or staff interface)',
  `lang` varchar(25) NOT NULL DEFAULT 'default' COMMENT 'lang to use to send notices to this patron',
  `login_attempts` int(4) NOT NULL DEFAULT 0 COMMENT 'number of failed login attemps',
  `overdrive_auth_token` mediumtext DEFAULT NULL COMMENT 'persist OverDrive auth token',
  `anonymized` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'flag for data anonymization',
  `autorenew_checkouts` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'flag for allowing auto-renewal',
  `primary_contact_method` varchar(45) DEFAULT NULL COMMENT 'useful for reporting purposes',
  PRIMARY KEY (`borrowernumber`),
  UNIQUE KEY `cardnumber` (`cardnumber`),
  UNIQUE KEY `userid` (`userid`),
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`),
  KEY `surname_idx` (`surname`(191)),
  KEY `firstname_idx` (`firstname`(191)),
  KEY `othernames_idx` (`othernames`(191)),
  KEY `sms_provider_id` (`sms_provider_id`),
  KEY `cardnumber_idx` (`cardnumber`),
  KEY `userid_idx` (`userid`),
  KEY `middle_name_idx` (`middle_name`(768)),
  CONSTRAINT `borrowers_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`),
  CONSTRAINT `borrowers_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`),
  CONSTRAINT `borrowers_ibfk_3` FOREIGN KEY (`sms_provider_id`) REFERENCES `sms_providers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `branch_transfer_limits`
--

DROP TABLE IF EXISTS `branch_transfer_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_transfer_limits` (
  `limitId` int(8) NOT NULL AUTO_INCREMENT,
  `toBranch` varchar(10) NOT NULL,
  `fromBranch` varchar(10) NOT NULL,
  `itemtype` varchar(10) DEFAULT NULL,
  `ccode` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`limitId`),
  KEY `fromBranch_idx` (`fromBranch`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branches` (
  `branchcode` varchar(10) NOT NULL DEFAULT '' COMMENT 'a unique key assigned to each branch',
  `branchname` longtext NOT NULL COMMENT 'the name of your library or branch',
  `branchaddress1` longtext DEFAULT NULL COMMENT 'the first address line of for your library or branch',
  `branchaddress2` longtext DEFAULT NULL COMMENT 'the second address line of for your library or branch',
  `branchaddress3` longtext DEFAULT NULL COMMENT 'the third address line of for your library or branch',
  `branchzip` varchar(25) DEFAULT NULL COMMENT 'the zip or postal code for your library or branch',
  `branchcity` longtext DEFAULT NULL COMMENT 'the city or province for your library or branch',
  `branchstate` longtext DEFAULT NULL COMMENT 'the state for your library or branch',
  `branchcountry` mediumtext DEFAULT NULL COMMENT 'the county for your library or branch',
  `branchphone` longtext DEFAULT NULL COMMENT 'the primary phone for your library or branch',
  `branchfax` longtext DEFAULT NULL COMMENT 'the fax number for your library or branch',
  `branchemail` longtext DEFAULT NULL COMMENT 'the primary email address for your library or branch',
  `branchillemail` longtext DEFAULT NULL COMMENT 'the ILL staff email address for your library or branch',
  `branchreplyto` longtext DEFAULT NULL COMMENT 'the email to be used as a Reply-To',
  `branchreturnpath` longtext DEFAULT NULL COMMENT 'the email to be used as Return-Path',
  `branchurl` longtext DEFAULT NULL COMMENT 'the URL for your library or branch''s website',
  `issuing` tinyint(4) DEFAULT NULL COMMENT 'unused in Koha',
  `branchip` varchar(15) DEFAULT NULL COMMENT 'the IP address for your library or branch',
  `branchnotes` longtext DEFAULT NULL COMMENT 'notes related to your library or branch',
  `geolocation` varchar(255) DEFAULT NULL COMMENT 'geolocation of your library',
  `marcorgcode` varchar(16) DEFAULT NULL COMMENT 'MARC Organization Code, see http://www.loc.gov/marc/organizations/orgshome.html, when empty defaults to syspref MARCOrgCode',
  `pickup_location` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'the ability to act as a pickup location',
  `public` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'whether this library should show in the opac',
  PRIMARY KEY (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `branches_overdrive`
--

DROP TABLE IF EXISTS `branches_overdrive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branches_overdrive` (
  `branchcode` varchar(10) NOT NULL,
  `authname` varchar(255) NOT NULL,
  PRIMARY KEY (`branchcode`),
  CONSTRAINT `branches_overdrive_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `branchtransfers`
--

DROP TABLE IF EXISTS `branchtransfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branchtransfers` (
  `branchtransfer_id` int(12) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `itemnumber` int(11) NOT NULL DEFAULT 0 COMMENT 'the itemnumber that it is in transit (items.itemnumber)',
  `daterequested` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'the date the transfer was requested',
  `datesent` datetime DEFAULT NULL COMMENT 'the date the transfer was initialized',
  `frombranch` varchar(10) NOT NULL DEFAULT '' COMMENT 'the branch the transfer is coming from',
  `datearrived` datetime DEFAULT NULL COMMENT 'the date the transfer arrived at its destination',
  `datecancelled` datetime DEFAULT NULL COMMENT 'the date the transfer was cancelled',
  `tobranch` varchar(10) NOT NULL DEFAULT '' COMMENT 'the branch the transfer was going to',
  `comments` longtext DEFAULT NULL COMMENT 'any comments related to the transfer',
  `reason` enum('Manual','StockrotationAdvance','StockrotationRepatriation','ReturnToHome','ReturnToHolding','RotatingCollection','Reserve','LostReserve','CancelReserve','TransferCancellation','Recall','RecallCancellation') DEFAULT NULL COMMENT 'what triggered the transfer',
  `cancellation_reason` enum('Manual','StockrotationAdvance','StockrotationRepatriation','ReturnToHome','ReturnToHolding','RotatingCollection','Reserve','LostReserve','CancelReserve','ItemLost','WrongTransfer','RecallCancellation') DEFAULT NULL COMMENT 'what triggered the transfer cancellation',
  PRIMARY KEY (`branchtransfer_id`),
  KEY `frombranch` (`frombranch`),
  KEY `tobranch` (`tobranch`),
  KEY `itemnumber` (`itemnumber`),
  CONSTRAINT `branchtransfers_ibfk_1` FOREIGN KEY (`frombranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchtransfers_ibfk_2` FOREIGN KEY (`tobranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchtransfers_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `browser`
--

DROP TABLE IF EXISTS `browser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `browser` (
  `level` int(11) NOT NULL,
  `classification` varchar(20) NOT NULL,
  `description` varchar(255) NOT NULL,
  `number` bigint(20) NOT NULL,
  `endnode` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cash_register_actions`
--

DROP TABLE IF EXISTS `cash_register_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cash_register_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for each account register action',
  `code` varchar(24) NOT NULL COMMENT 'action code denoting the type of action recorded (enum),',
  `register_id` int(11) NOT NULL COMMENT 'id of cash_register this action belongs to,',
  `manager_id` int(11) NOT NULL COMMENT 'staff member performing the action',
  `amount` decimal(28,6) DEFAULT NULL COMMENT 'amount recorded in action (signed)',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `cash_register_actions_manager` (`manager_id`),
  KEY `cash_register_actions_register` (`register_id`),
  CONSTRAINT `cash_register_actions_manager` FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `cash_register_actions_register` FOREIGN KEY (`register_id`) REFERENCES `cash_registers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cash_registers`
--

DROP TABLE IF EXISTS `cash_registers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cash_registers` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for each account register',
  `name` varchar(24) NOT NULL COMMENT 'the user friendly identifier for each account register',
  `description` longtext NOT NULL COMMENT 'the user friendly description for each account register',
  `branch` varchar(10) NOT NULL COMMENT 'the foreign key the library this account register belongs',
  `branch_default` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean flag to denote that this till is the branch default',
  `starting_float` decimal(28,6) DEFAULT NULL COMMENT 'the starting float this account register should be assigned',
  `archived` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean flag to denote if this till is archived or not',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`branch`),
  KEY `cash_registers_branch` (`branch`),
  CONSTRAINT `cash_registers_branch` FOREIGN KEY (`branch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `categorycode` varchar(10) NOT NULL DEFAULT '' COMMENT 'unique primary key used to idenfity the patron category',
  `description` longtext DEFAULT NULL COMMENT 'description of the patron category',
  `enrolmentperiod` smallint(6) DEFAULT NULL COMMENT 'number of months the patron is enrolled for (will be NULL if enrolmentperioddate is set)',
  `enrolmentperioddate` date DEFAULT NULL COMMENT 'date the patron is enrolled until (will be NULL if enrolmentperiod is set)',
  `password_expiry_days` smallint(6) DEFAULT NULL COMMENT 'number of days after which the patron must reset their password',
  `upperagelimit` smallint(6) DEFAULT NULL COMMENT 'age limit for the patron',
  `dateofbirthrequired` tinyint(1) DEFAULT NULL COMMENT 'the minimum age required for the patron category',
  `finetype` varchar(30) DEFAULT NULL COMMENT 'unused in Koha',
  `bulk` tinyint(1) DEFAULT NULL,
  `enrolmentfee` decimal(28,6) DEFAULT NULL COMMENT 'enrollment fee for the patron',
  `overduenoticerequired` tinyint(1) DEFAULT NULL COMMENT 'are overdue notices sent to this patron category (1 for yes, 0 for no)',
  `issuelimit` smallint(6) DEFAULT NULL COMMENT 'unused in Koha',
  `reservefee` decimal(28,6) DEFAULT NULL COMMENT 'cost to place holds',
  `hidelostitems` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'are lost items shown to this category (1 for yes, 0 for no)',
  `category_type` varchar(1) NOT NULL DEFAULT 'A' COMMENT 'type of Koha patron (Adult, Child, Professional, Organizational, Statistical, Staff)',
  `BlockExpiredPatronOpacActions` tinyint(1) NOT NULL DEFAULT -1 COMMENT 'wheither or not a patron of this category can renew books or place holds once their card has expired. 0 means they can, 1 means they cannot, -1 means use syspref BlockExpiredPatronOpacActions',
  `default_privacy` enum('default','never','forever') NOT NULL DEFAULT 'default' COMMENT 'Default privacy setting for this patron category',
  `checkprevcheckout` varchar(7) NOT NULL DEFAULT 'inherit' COMMENT 'produce a warning for this patron category if this item has previously been checked out to this patron if ''yes'', not if ''no'', defer to syspref setting if ''inherit''.',
  `can_be_guarantee` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'if patrons of this category can be guarantees',
  `reset_password` tinyint(1) DEFAULT NULL COMMENT 'if patrons of this category can do the password reset flow,',
  `change_password` tinyint(1) DEFAULT NULL COMMENT 'if patrons of this category can change their passwords in the OAPC',
  `min_password_length` smallint(6) DEFAULT NULL COMMENT 'set minimum password length for patrons in this category',
  `require_strong_password` tinyint(1) DEFAULT NULL COMMENT 'set required password strength for patrons in this category',
  `exclude_from_local_holds_priority` tinyint(1) DEFAULT NULL COMMENT 'Exclude patrons of this category from local holds priority',
  PRIMARY KEY (`categorycode`),
  UNIQUE KEY `categorycode` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories_branches`
--

DROP TABLE IF EXISTS `categories_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories_branches` (
  `categorycode` varchar(10) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `categories_branches_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE,
  CONSTRAINT `categories_branches_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `checkout_renewals`
--

DROP TABLE IF EXISTS `checkout_renewals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `checkout_renewals` (
  `renewal_id` int(11) NOT NULL AUTO_INCREMENT,
  `checkout_id` int(11) DEFAULT NULL COMMENT 'the id of the checkout this renewal pertains to',
  `renewer_id` int(11) DEFAULT NULL COMMENT 'the id of the user who processed the renewal',
  `seen` tinyint(1) DEFAULT 0 COMMENT 'boolean denoting whether the item was present or not',
  `interface` varchar(16) NOT NULL COMMENT 'the interface this renewal took place on',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'the date and time the renewal took place',
  `renewal_type` enum('Automatic','Manual') NOT NULL DEFAULT 'Manual' COMMENT 'whether the renewal was an automatic or manual renewal',
  PRIMARY KEY (`renewal_id`),
  KEY `renewer_id` (`renewer_id`),
  CONSTRAINT `renewals_renewer_id` FOREIGN KEY (`renewer_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `circulation_rules`
--

DROP TABLE IF EXISTS `circulation_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `circulation_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branchcode` varchar(10) DEFAULT NULL,
  `categorycode` varchar(10) DEFAULT NULL,
  `itemtype` varchar(10) DEFAULT NULL,
  `rule_name` varchar(32) NOT NULL,
  `rule_value` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branchcode` (`branchcode`,`categorycode`,`itemtype`,`rule_name`),
  KEY `circ_rules_ibfk_2` (`categorycode`),
  KEY `circ_rules_ibfk_3` (`itemtype`),
  KEY `rule_name` (`rule_name`),
  CONSTRAINT `circ_rules_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `circ_rules_ibfk_2` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `circ_rules_ibfk_3` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cities` (
  `cityid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier added by Koha',
  `city_name` varchar(100) NOT NULL DEFAULT '' COMMENT 'name of the city',
  `city_state` varchar(100) DEFAULT NULL COMMENT 'name of the state/province',
  `city_country` varchar(100) DEFAULT NULL COMMENT 'name of the country',
  `city_zipcode` varchar(20) DEFAULT NULL COMMENT 'zip or postal code',
  PRIMARY KEY (`cityid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_sort_rules`
--

DROP TABLE IF EXISTS `class_sort_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `class_sort_rules` (
  `class_sort_rule` varchar(10) NOT NULL DEFAULT '',
  `description` longtext DEFAULT NULL,
  `sort_routine` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`class_sort_rule`),
  UNIQUE KEY `class_sort_rule_idx` (`class_sort_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_sources`
--

DROP TABLE IF EXISTS `class_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `class_sources` (
  `cn_source` varchar(10) NOT NULL DEFAULT '',
  `description` longtext DEFAULT NULL,
  `used` tinyint(4) NOT NULL DEFAULT 0,
  `class_sort_rule` varchar(10) NOT NULL DEFAULT '',
  `class_split_rule` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`cn_source`),
  UNIQUE KEY `cn_source_idx` (`cn_source`),
  KEY `used_idx` (`used`),
  KEY `class_source_ibfk_1` (`class_sort_rule`),
  KEY `class_source_ibfk_2` (`class_split_rule`),
  CONSTRAINT `class_source_ibfk_1` FOREIGN KEY (`class_sort_rule`) REFERENCES `class_sort_rules` (`class_sort_rule`),
  CONSTRAINT `class_source_ibfk_2` FOREIGN KEY (`class_split_rule`) REFERENCES `class_split_rules` (`class_split_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_split_rules`
--

DROP TABLE IF EXISTS `class_split_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `class_split_rules` (
  `class_split_rule` varchar(10) NOT NULL DEFAULT '',
  `description` longtext DEFAULT NULL,
  `split_routine` varchar(30) NOT NULL DEFAULT '',
  `split_regex` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`class_split_rule`),
  UNIQUE KEY `class_split_rule_idx` (`class_split_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_enrollment_fields`
--

DROP TABLE IF EXISTS `club_enrollment_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_enrollment_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_enrollment_id` int(11) NOT NULL,
  `club_template_enrollment_field_id` int(11) NOT NULL,
  `value` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `club_enrollment_id` (`club_enrollment_id`),
  KEY `club_template_enrollment_field_id` (`club_template_enrollment_field_id`),
  CONSTRAINT `club_enrollment_fields_ibfk_1` FOREIGN KEY (`club_enrollment_id`) REFERENCES `club_enrollments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `club_enrollment_fields_ibfk_2` FOREIGN KEY (`club_template_enrollment_field_id`) REFERENCES `club_template_enrollment_fields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_enrollments`
--

DROP TABLE IF EXISTS `club_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_enrollments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_id` int(11) NOT NULL,
  `borrowernumber` int(11) NOT NULL,
  `date_enrolled` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_canceled` timestamp NULL DEFAULT NULL,
  `date_created` timestamp NULL DEFAULT NULL,
  `date_updated` timestamp NULL DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `club_id` (`club_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `club_enrollments_ibfk_1` FOREIGN KEY (`club_id`) REFERENCES `clubs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `club_enrollments_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `club_enrollments_ibfk_3` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_fields`
--

DROP TABLE IF EXISTS `club_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_template_field_id` int(11) NOT NULL,
  `club_id` int(11) NOT NULL,
  `value` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `club_template_field_id` (`club_template_field_id`),
  KEY `club_id` (`club_id`),
  CONSTRAINT `club_fields_ibfk_3` FOREIGN KEY (`club_template_field_id`) REFERENCES `club_template_fields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `club_fields_ibfk_4` FOREIGN KEY (`club_id`) REFERENCES `clubs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_holds`
--

DROP TABLE IF EXISTS `club_holds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_holds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_id` int(11) NOT NULL COMMENT 'id for the club the hold was generated for',
  `biblio_id` int(11) NOT NULL COMMENT 'id for the bibliographic record the hold has been placed against',
  `item_id` int(11) DEFAULT NULL COMMENT 'If item-level, the id for the item the hold has been placed agains',
  `date_created` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp for the placed hold',
  PRIMARY KEY (`id`),
  KEY `clubs_holds_ibfk_1` (`club_id`),
  KEY `clubs_holds_ibfk_2` (`biblio_id`),
  KEY `clubs_holds_ibfk_3` (`item_id`),
  CONSTRAINT `clubs_holds_ibfk_1` FOREIGN KEY (`club_id`) REFERENCES `clubs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clubs_holds_ibfk_2` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clubs_holds_ibfk_3` FOREIGN KEY (`item_id`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_holds_to_patron_holds`
--

DROP TABLE IF EXISTS `club_holds_to_patron_holds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_holds_to_patron_holds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_hold_id` int(11) NOT NULL,
  `patron_id` int(11) NOT NULL,
  `hold_id` int(11) DEFAULT NULL,
  `error_code` enum('damaged','ageRestricted','itemAlreadyOnHold','tooManyHoldsForThisRecord','tooManyReservesToday','tooManyReserves','notReservable','cannotReserveFromOtherBranches','libraryNotFound','libraryNotPickupLocation','cannotBeTransferred','noReservesAllowed') DEFAULT NULL,
  `error_message` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `clubs_holds_paton_holds_ibfk_1` (`club_hold_id`),
  KEY `clubs_holds_paton_holds_ibfk_2` (`patron_id`),
  KEY `clubs_holds_paton_holds_ibfk_3` (`hold_id`),
  CONSTRAINT `clubs_holds_paton_holds_ibfk_1` FOREIGN KEY (`club_hold_id`) REFERENCES `club_holds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clubs_holds_paton_holds_ibfk_2` FOREIGN KEY (`patron_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clubs_holds_paton_holds_ibfk_3` FOREIGN KEY (`hold_id`) REFERENCES `reserves` (`reserve_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_template_enrollment_fields`
--

DROP TABLE IF EXISTS `club_template_enrollment_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_template_enrollment_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_template_id` int(11) NOT NULL,
  `name` text NOT NULL,
  `description` mediumtext DEFAULT NULL,
  `authorised_value_category` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `club_template_id` (`club_template_id`),
  CONSTRAINT `club_template_enrollment_fields_ibfk_1` FOREIGN KEY (`club_template_id`) REFERENCES `club_templates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_template_fields`
--

DROP TABLE IF EXISTS `club_template_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_template_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_template_id` int(11) NOT NULL,
  `name` text NOT NULL,
  `description` mediumtext DEFAULT NULL,
  `authorised_value_category` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `club_template_id` (`club_template_id`),
  CONSTRAINT `club_template_fields_ibfk_1` FOREIGN KEY (`club_template_id`) REFERENCES `club_templates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `club_templates`
--

DROP TABLE IF EXISTS `club_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `club_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `description` mediumtext DEFAULT NULL,
  `is_enrollable_from_opac` tinyint(1) NOT NULL DEFAULT 0,
  `is_email_required` tinyint(1) NOT NULL DEFAULT 0,
  `branchcode` varchar(10) DEFAULT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_updated` timestamp NULL DEFAULT NULL,
  `is_deletable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `ct_branchcode` (`branchcode`),
  CONSTRAINT `club_templates_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clubs`
--

DROP TABLE IF EXISTS `clubs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clubs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_template_id` int(11) NOT NULL,
  `name` text NOT NULL,
  `description` mediumtext DEFAULT NULL,
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_updated` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `club_template_id` (`club_template_id`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `clubs_ibfk_1` FOREIGN KEY (`club_template_id`) REFERENCES `club_templates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clubs_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collections`
--

DROP TABLE IF EXISTS `collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collections` (
  `colId` int(11) NOT NULL AUTO_INCREMENT,
  `colTitle` varchar(100) NOT NULL DEFAULT '',
  `colDesc` mediumtext NOT NULL,
  `colBranchcode` varchar(10) DEFAULT NULL COMMENT '''branchcode for branch where item should be held.''',
  PRIMARY KEY (`colId`),
  KEY `collections_ibfk_1` (`colBranchcode`),
  CONSTRAINT `collections_ibfk_1` FOREIGN KEY (`colBranchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collections_tracking`
--

DROP TABLE IF EXISTS `collections_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collections_tracking` (
  `collections_tracking_id` int(11) NOT NULL AUTO_INCREMENT,
  `colId` int(11) NOT NULL DEFAULT 0 COMMENT 'collections.colId',
  `itemnumber` int(11) NOT NULL DEFAULT 0 COMMENT 'items.itemnumber',
  PRIMARY KEY (`collections_tracking_id`),
  KEY `collectionst_ibfk_1` (`colId`),
  CONSTRAINT `collectionst_ibfk_1` FOREIGN KEY (`colId`) REFERENCES `collections` (`colId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `columns_settings`
--

DROP TABLE IF EXISTS `columns_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `columns_settings` (
  `module` varchar(255) NOT NULL,
  `page` varchar(255) NOT NULL,
  `tablename` varchar(255) NOT NULL,
  `columnname` varchar(255) NOT NULL,
  `cannot_be_toggled` int(1) NOT NULL DEFAULT 0,
  `is_hidden` int(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`module`(191),`page`(191),`tablename`(191),`columnname`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `course_instructors`
--

DROP TABLE IF EXISTS `course_instructors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `course_instructors` (
  `course_id` int(11) NOT NULL COMMENT 'foreign key to link to courses.course_id',
  `borrowernumber` int(11) NOT NULL COMMENT 'foreign key to link to borrowers.borrowernumber for instructor information',
  PRIMARY KEY (`course_id`,`borrowernumber`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT `course_instructors_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `course_instructors_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `course_items`
--

DROP TABLE IF EXISTS `course_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `course_items` (
  `ci_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'course item id',
  `itemnumber` int(11) DEFAULT NULL COMMENT 'items.itemnumber for the item on reserve',
  `biblionumber` int(11) NOT NULL COMMENT 'biblio.biblionumber for the bibliographic record on reserve',
  `itype` varchar(10) DEFAULT NULL COMMENT 'new itemtype for the item to have while on reserve (optional)',
  `itype_enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'indicates if itype should be changed while on course reserve',
  `itype_storage` varchar(10) DEFAULT NULL COMMENT 'a place to store the itype when item is on course reserve',
  `ccode` varchar(80) DEFAULT NULL COMMENT 'new category code for the item to have while on reserve (optional)',
  `ccode_enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'indicates if ccode should be changed while on course reserve',
  `ccode_storage` varchar(80) DEFAULT NULL COMMENT 'a place to store the ccode when item is on course reserve',
  `homebranch` varchar(10) DEFAULT NULL COMMENT 'new home branch for the item to have while on reserve (optional)',
  `homebranch_enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'indicates if homebranch should be changed while on course reserve',
  `homebranch_storage` varchar(10) DEFAULT NULL COMMENT 'a place to store the homebranch when item is on course reserve',
  `holdingbranch` varchar(10) DEFAULT NULL COMMENT 'new holding branch for the item to have while on reserve (optional)',
  `holdingbranch_enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'indicates if itype should be changed while on course reserve',
  `holdingbranch_storage` varchar(10) DEFAULT NULL COMMENT 'a place to store the holdingbranch when item is on course reserve',
  `location` varchar(80) DEFAULT NULL COMMENT 'new shelving location for the item to have while on reseve (optional)',
  `location_enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'indicates if itype should be changed while on course reserve',
  `location_storage` varchar(80) DEFAULT NULL COMMENT 'a place to store the location when the item is on course reserve',
  `enabled` enum('yes','no') NOT NULL DEFAULT 'no' COMMENT 'if at least one enabled course has this item on reseve, this field will be ''yes'', otherwise it will be ''no''',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ci_id`),
  UNIQUE KEY `itemnumber` (`itemnumber`),
  KEY `holdingbranch` (`holdingbranch`),
  KEY `fk_course_items_homebranch` (`homebranch`),
  KEY `fk_course_items_homebranch_storage` (`homebranch_storage`),
  KEY `fk_course_items_biblionumber` (`biblionumber`),
  CONSTRAINT `course_items_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `course_items_ibfk_2` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_course_items_biblionumber` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_course_items_homebranch` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_course_items_homebranch_storage` FOREIGN KEY (`homebranch_storage`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `course_reserves`
--

DROP TABLE IF EXISTS `course_reserves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `course_reserves` (
  `cr_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL COMMENT 'foreign key to link to courses.course_id',
  `ci_id` int(11) NOT NULL COMMENT 'foreign key to link to courses_items.ci_id',
  `staff_note` longtext DEFAULT NULL COMMENT 'staff only note',
  `public_note` longtext DEFAULT NULL COMMENT 'public, OPAC visible note',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`cr_id`),
  UNIQUE KEY `pseudo_key` (`course_id`,`ci_id`),
  KEY `course_id` (`course_id`),
  KEY `course_reserves_ibfk_2` (`ci_id`),
  CONSTRAINT `course_reserves_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  CONSTRAINT `course_reserves_ibfk_2` FOREIGN KEY (`ci_id`) REFERENCES `course_items` (`ci_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id for the course',
  `department` varchar(80) DEFAULT NULL COMMENT 'the authorised value for the DEPARTMENT',
  `course_number` varchar(255) DEFAULT NULL COMMENT 'the ''course number'' assigned to a course',
  `section` varchar(255) DEFAULT NULL COMMENT 'the ''section'' of a course',
  `course_name` varchar(255) DEFAULT NULL COMMENT 'the name of the course',
  `term` varchar(80) DEFAULT NULL COMMENT 'the authorised value for the TERM',
  `staff_note` longtext DEFAULT NULL COMMENT 'the text of the staff only note',
  `public_note` longtext DEFAULT NULL COMMENT 'the text of the public / opac note',
  `students_count` varchar(20) DEFAULT NULL COMMENT 'how many students will be taking this course/section',
  `enabled` enum('yes','no') NOT NULL DEFAULT 'yes' COMMENT 'determines whether the course is active',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cover_images`
--

DROP TABLE IF EXISTS `cover_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cover_images` (
  `imagenumber` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for the image',
  `biblionumber` int(11) DEFAULT NULL COMMENT 'foreign key from biblio table to link to biblionumber',
  `itemnumber` int(11) DEFAULT NULL COMMENT 'foreign key from item table to link to itemnumber',
  `mimetype` varchar(15) NOT NULL COMMENT 'image type',
  `imagefile` mediumblob NOT NULL COMMENT 'image file contents',
  `thumbnail` mediumblob NOT NULL COMMENT 'thumbnail file contents',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'image creation/update time',
  PRIMARY KEY (`imagenumber`),
  KEY `bibliocoverimage_fk1` (`biblionumber`),
  KEY `bibliocoverimage_fk2` (`itemnumber`),
  CONSTRAINT `bibliocoverimage_fk1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bibliocoverimage_fk2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `creator_batches`
--

DROP TABLE IF EXISTS `creator_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `creator_batches` (
  `label_id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(10) NOT NULL DEFAULT 1,
  `description` mediumtext DEFAULT NULL,
  `item_number` int(11) DEFAULT NULL,
  `borrower_number` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `creator_images`
--

DROP TABLE IF EXISTS `creator_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `creator_images` (
  `image_id` int(4) NOT NULL AUTO_INCREMENT,
  `imagefile` mediumblob DEFAULT NULL,
  `image_name` char(20) NOT NULL DEFAULT 'DEFAULT',
  PRIMARY KEY (`image_id`),
  UNIQUE KEY `image_name_index` (`image_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `creator_layouts`
--

DROP TABLE IF EXISTS `creator_layouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `creator_layouts` (
  `layout_id` int(4) NOT NULL AUTO_INCREMENT,
  `barcode_type` char(100) NOT NULL DEFAULT 'CODE39',
  `start_label` int(2) NOT NULL DEFAULT 1,
  `printing_type` char(32) NOT NULL DEFAULT 'BAR',
  `layout_name` char(25) NOT NULL DEFAULT 'DEFAULT',
  `guidebox` int(1) DEFAULT 0,
  `oblique_title` int(1) DEFAULT 1,
  `font` char(10) NOT NULL DEFAULT 'TR',
  `font_size` int(4) NOT NULL DEFAULT 10,
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `callnum_split` int(1) DEFAULT 0,
  `text_justify` char(1) NOT NULL DEFAULT 'L',
  `format_string` varchar(210) NOT NULL DEFAULT 'barcode',
  `layout_xml` mediumtext NOT NULL,
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`layout_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `creator_templates`
--

DROP TABLE IF EXISTS `creator_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `creator_templates` (
  `template_id` int(4) NOT NULL AUTO_INCREMENT,
  `profile_id` int(4) DEFAULT NULL,
  `template_code` char(100) NOT NULL DEFAULT 'DEFAULT TEMPLATE',
  `template_desc` char(100) NOT NULL DEFAULT 'Default description',
  `page_width` float NOT NULL DEFAULT 0,
  `page_height` float NOT NULL DEFAULT 0,
  `label_width` float NOT NULL DEFAULT 0,
  `label_height` float NOT NULL DEFAULT 0,
  `top_text_margin` float NOT NULL DEFAULT 0,
  `left_text_margin` float NOT NULL DEFAULT 0,
  `top_margin` float NOT NULL DEFAULT 0,
  `left_margin` float NOT NULL DEFAULT 0,
  `cols` int(2) NOT NULL DEFAULT 0,
  `rows` int(2) NOT NULL DEFAULT 0,
  `col_gap` float NOT NULL DEFAULT 0,
  `row_gap` float NOT NULL DEFAULT 0,
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`template_id`),
  KEY `template_profile_fk_constraint` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `curbside_pickup_issues`
--

DROP TABLE IF EXISTS `curbside_pickup_issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curbside_pickup_issues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `curbside_pickup_id` int(11) NOT NULL,
  `issue_id` int(11) NOT NULL,
  `reserve_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `curbside_pickup_id` (`curbside_pickup_id`),
  CONSTRAINT `curbside_pickup_issues_ibfk_1` FOREIGN KEY (`curbside_pickup_id`) REFERENCES `curbside_pickups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `curbside_pickup_opening_slots`
--

DROP TABLE IF EXISTS `curbside_pickup_opening_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curbside_pickup_opening_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `curbside_pickup_policy_id` int(11) NOT NULL,
  `day` tinyint(1) NOT NULL,
  `start_hour` int(2) NOT NULL,
  `start_minute` int(2) NOT NULL,
  `end_hour` int(2) NOT NULL,
  `end_minute` int(2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `curbside_pickup_policy_id` (`curbside_pickup_policy_id`),
  CONSTRAINT `curbside_pickup_opening_slots_ibfk_1` FOREIGN KEY (`curbside_pickup_policy_id`) REFERENCES `curbside_pickup_policy` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `curbside_pickup_policy`
--

DROP TABLE IF EXISTS `curbside_pickup_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curbside_pickup_policy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branchcode` varchar(10) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `enable_waiting_holds_only` tinyint(1) NOT NULL DEFAULT 0,
  `pickup_interval` int(2) NOT NULL DEFAULT 0,
  `patrons_per_interval` int(2) NOT NULL DEFAULT 0,
  `patron_scheduled_pickup` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branchcode` (`branchcode`),
  CONSTRAINT `curbside_pickup_policy_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `curbside_pickups`
--

DROP TABLE IF EXISTS `curbside_pickups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curbside_pickups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL,
  `branchcode` varchar(10) NOT NULL,
  `scheduled_pickup_datetime` datetime NOT NULL,
  `staged_datetime` datetime DEFAULT NULL,
  `staged_by` int(11) DEFAULT NULL,
  `arrival_datetime` datetime DEFAULT NULL,
  `delivered_datetime` datetime DEFAULT NULL,
  `delivered_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branchcode` (`branchcode`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `staged_by` (`staged_by`),
  CONSTRAINT `curbside_pickups_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `curbside_pickups_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `curbside_pickups_ibfk_3` FOREIGN KEY (`staged_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `currency`
--

DROP TABLE IF EXISTS `currency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currency` (
  `currency` varchar(10) NOT NULL DEFAULT '',
  `symbol` varchar(5) DEFAULT NULL,
  `isocode` varchar(5) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `rate` float(15,5) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `archived` tinyint(1) DEFAULT 0,
  `p_sep_by_space` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deletedbiblio`
--

DROP TABLE IF EXISTS `deletedbiblio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deletedbiblio` (
  `biblionumber` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned to each bibliographic record',
  `frameworkcode` varchar(4) NOT NULL DEFAULT '' COMMENT 'foriegn key from the biblio_framework table to identify which framework was used in cataloging this record',
  `author` longtext DEFAULT NULL COMMENT 'statement of responsibility from MARC record (100$a in MARC21)',
  `title` longtext DEFAULT NULL COMMENT 'title (without the subtitle) from the MARC record (245$a in MARC21)',
  `medium` longtext DEFAULT NULL COMMENT 'medium from the MARC record (245$h in MARC21)',
  `subtitle` longtext DEFAULT NULL COMMENT 'remainder of the title from the MARC record (245$b in MARC21)',
  `part_number` longtext DEFAULT NULL COMMENT 'part number from the MARC record (245$n in MARC21)',
  `part_name` longtext DEFAULT NULL COMMENT 'part name from the MARC record (245$p in MARC21)',
  `unititle` longtext DEFAULT NULL COMMENT 'uniform title (without the subtitle) from the MARC record (240$a in MARC21)',
  `notes` longtext DEFAULT NULL COMMENT 'values from the general notes field in the MARC record (500$a in MARC21) split by bar (|)',
  `serial` tinyint(1) DEFAULT NULL COMMENT 'Boolean indicating whether biblio is for a serial',
  `seriestitle` longtext DEFAULT NULL,
  `copyrightdate` smallint(6) DEFAULT NULL COMMENT 'publication or copyright date from the MARC record',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time this record was last touched',
  `datecreated` date NOT NULL COMMENT 'the date this record was added to Koha',
  `abstract` longtext DEFAULT NULL COMMENT 'summary from the MARC record (520$a in MARC21)',
  PRIMARY KEY (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deletedbiblio_metadata`
--

DROP TABLE IF EXISTS `deletedbiblio_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deletedbiblio_metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `biblionumber` int(11) NOT NULL,
  `format` varchar(16) NOT NULL,
  `schema` varchar(16) NOT NULL,
  `metadata` longtext NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `deletedbiblio_metadata_uniq_key` (`biblionumber`,`format`,`schema`),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `deletedrecord_metadata_fk_1` FOREIGN KEY (`biblionumber`) REFERENCES `deletedbiblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deletedbiblioitems`
--

DROP TABLE IF EXISTS `deletedbiblioitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deletedbiblioitems` (
  `biblioitemnumber` int(11) NOT NULL DEFAULT 0 COMMENT 'primary key, unique identifier assigned by Koha',
  `biblionumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key linking this table to the biblio table',
  `volume` longtext DEFAULT NULL,
  `number` longtext DEFAULT NULL,
  `itemtype` varchar(10) DEFAULT NULL COMMENT 'biblio level item type (MARC21 942$c)',
  `isbn` longtext DEFAULT NULL COMMENT 'ISBN (MARC21 020$a)',
  `issn` longtext DEFAULT NULL COMMENT 'ISSN (MARC21 022$a)',
  `ean` longtext DEFAULT NULL,
  `publicationyear` mediumtext DEFAULT NULL,
  `publishercode` text DEFAULT NULL COMMENT 'publisher (MARC21 260$b and 264$b)',
  `volumedate` date DEFAULT NULL,
  `volumedesc` mediumtext DEFAULT NULL COMMENT 'volume information (MARC21 362$a)',
  `collectiontitle` longtext DEFAULT NULL,
  `collectionissn` mediumtext DEFAULT NULL,
  `collectionvolume` longtext DEFAULT NULL,
  `editionstatement` mediumtext DEFAULT NULL,
  `editionresponsibility` mediumtext DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `illus` text DEFAULT NULL COMMENT 'illustrations (MARC21 300$b)',
  `pages` text DEFAULT NULL COMMENT 'number of pages (MARC21 300$a)',
  `notes` longtext DEFAULT NULL,
  `size` text DEFAULT NULL COMMENT 'material size (MARC21 300$c)',
  `place` text DEFAULT NULL COMMENT 'publication place (MARC21 260$a and 264$a)',
  `lccn` longtext DEFAULT NULL COMMENT 'library of congress control number (MARC21 010$a)',
  `url` mediumtext DEFAULT NULL COMMENT 'url (MARC21 856$u)',
  `cn_source` varchar(10) DEFAULT NULL COMMENT 'classification source (MARC21 942$2)',
  `cn_class` varchar(30) DEFAULT NULL,
  `cn_item` varchar(10) DEFAULT NULL,
  `cn_suffix` varchar(10) DEFAULT NULL,
  `cn_sort` varchar(255) DEFAULT NULL COMMENT 'normalized version of the call number used for sorting',
  `agerestriction` varchar(255) DEFAULT NULL COMMENT 'target audience/age restriction from the bib record (MARC21 521$a)',
  `totalissues` int(10) DEFAULT NULL,
  PRIMARY KEY (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `itemtype_idx` (`itemtype`),
  KEY `isbn` (`isbn`(191)),
  KEY `ean` (`ean`(191)),
  KEY `publishercode` (`publishercode`(191)),
  KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deletedborrowers`
--

DROP TABLE IF EXISTS `deletedborrowers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deletedborrowers` (
  `borrowernumber` int(11) NOT NULL DEFAULT 0 COMMENT 'primary key, Koha assigned ID number for patrons/borrowers',
  `cardnumber` varchar(32) DEFAULT NULL COMMENT 'unique key, library assigned ID number for patrons/borrowers',
  `surname` longtext DEFAULT NULL COMMENT 'patron/borrower''s last name (surname)',
  `firstname` mediumtext DEFAULT NULL COMMENT 'patron/borrower''s first name',
  `middle_name` longtext DEFAULT NULL COMMENT 'patron/borrower''s middle name',
  `title` longtext DEFAULT NULL COMMENT 'patron/borrower''s title, for example: Mr. or Mrs.',
  `othernames` longtext DEFAULT NULL COMMENT 'any other names associated with the patron/borrower',
  `initials` mediumtext DEFAULT NULL COMMENT 'initials for your patron/borrower',
  `pronouns` longtext DEFAULT NULL COMMENT 'patron/borrower pronouns',
  `streetnumber` tinytext DEFAULT NULL COMMENT 'the house number for your patron/borrower''s primary address',
  `streettype` tinytext DEFAULT NULL COMMENT 'the street type (Rd., Blvd, etc) for your patron/borrower''s primary address',
  `address` longtext DEFAULT NULL COMMENT 'the first address line for your patron/borrower''s primary address',
  `address2` mediumtext DEFAULT NULL COMMENT 'the second address line for your patron/borrower''s primary address',
  `city` longtext DEFAULT NULL COMMENT 'the city or town for your patron/borrower''s primary address',
  `state` mediumtext DEFAULT NULL COMMENT 'the state or province for your patron/borrower''s primary address',
  `zipcode` tinytext DEFAULT NULL COMMENT 'the zip or postal code for your patron/borrower''s primary address',
  `country` mediumtext DEFAULT NULL COMMENT 'the country for your patron/borrower''s primary address',
  `email` longtext DEFAULT NULL COMMENT 'the primary email address for your patron/borrower''s primary address',
  `phone` mediumtext DEFAULT NULL COMMENT 'the primary phone number for your patron/borrower''s primary address',
  `mobile` tinytext DEFAULT NULL COMMENT 'the other phone number for your patron/borrower''s primary address',
  `fax` longtext DEFAULT NULL COMMENT 'the fax number for your patron/borrower''s primary address',
  `emailpro` mediumtext DEFAULT NULL COMMENT 'the secondary email addres for your patron/borrower''s primary address',
  `phonepro` mediumtext DEFAULT NULL COMMENT 'the secondary phone number for your patron/borrower''s primary address',
  `B_streetnumber` tinytext DEFAULT NULL COMMENT 'the house number for your patron/borrower''s alternate address',
  `B_streettype` tinytext DEFAULT NULL COMMENT 'the street type (Rd., Blvd, etc) for your patron/borrower''s alternate address',
  `B_address` mediumtext DEFAULT NULL COMMENT 'the first address line for your patron/borrower''s alternate address',
  `B_address2` mediumtext DEFAULT NULL COMMENT 'the second address line for your patron/borrower''s alternate address',
  `B_city` longtext DEFAULT NULL COMMENT 'the city or town for your patron/borrower''s alternate address',
  `B_state` mediumtext DEFAULT NULL COMMENT 'the state for your patron/borrower''s alternate address',
  `B_zipcode` tinytext DEFAULT NULL COMMENT 'the zip or postal code for your patron/borrower''s alternate address',
  `B_country` mediumtext DEFAULT NULL COMMENT 'the country for your patron/borrower''s alternate address',
  `B_email` mediumtext DEFAULT NULL COMMENT 'the patron/borrower''s alternate email address',
  `B_phone` longtext DEFAULT NULL COMMENT 'the patron/borrower''s alternate phone number',
  `dateofbirth` date DEFAULT NULL COMMENT 'the patron/borrower''s date of birth (YYYY-MM-DD)',
  `branchcode` varchar(10) NOT NULL DEFAULT '' COMMENT 'foreign key from the branches table, includes the code of the patron/borrower''s home branch',
  `categorycode` varchar(10) NOT NULL DEFAULT '' COMMENT 'foreign key from the categories table, includes the code of the patron category',
  `dateenrolled` date DEFAULT NULL COMMENT 'date the patron was added to Koha (YYYY-MM-DD)',
  `dateexpiry` date DEFAULT NULL COMMENT 'date the patron/borrower''s card is set to expire (YYYY-MM-DD)',
  `password_expiration_date` date DEFAULT NULL COMMENT 'date the patron/borrower''s password is set to expire (YYYY-MM-DD)',
  `date_renewed` date DEFAULT NULL COMMENT 'date the patron/borrower''s card was last renewed',
  `gonenoaddress` tinyint(1) DEFAULT NULL COMMENT 'set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having an unconfirmed address',
  `lost` tinyint(1) DEFAULT NULL COMMENT 'set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having lost their card',
  `debarred` date DEFAULT NULL COMMENT 'until this date the patron can only check-in (no loans, no holds, etc.), is a fine based on days instead of money (YYYY-MM-DD)',
  `debarredcomment` varchar(255) DEFAULT NULL COMMENT 'comment on the stop of patron',
  `contactname` longtext DEFAULT NULL COMMENT 'used for children and profesionals to include surname or last name of guarantor or organization name',
  `contactfirstname` mediumtext DEFAULT NULL COMMENT 'used for children to include first name of guarantor',
  `contacttitle` mediumtext DEFAULT NULL COMMENT 'used for children to include title (Mr., Mrs., etc) of guarantor',
  `borrowernotes` longtext DEFAULT NULL COMMENT 'a note on the patron/borrower''s account that is only visible in the staff interface',
  `relationship` varchar(100) DEFAULT NULL COMMENT 'used for children to include the relationship to their guarantor',
  `sex` varchar(1) DEFAULT NULL COMMENT 'patron/borrower''s gender',
  `password` varchar(60) DEFAULT NULL COMMENT 'patron/borrower''s encrypted password',
  `secret` mediumtext DEFAULT NULL COMMENT 'Secret for 2FA',
  `auth_method` enum('password','two-factor') NOT NULL DEFAULT 'password' COMMENT 'Authentication method',
  `flags` bigint(11) DEFAULT NULL COMMENT 'will include a number associated with the staff member''s permissions',
  `userid` varchar(75) DEFAULT NULL COMMENT 'patron/borrower''s opac and/or staff interface log in',
  `opacnote` longtext DEFAULT NULL COMMENT 'a note on the patron/borrower''s account that is visible in the OPAC and staff interface',
  `contactnote` varchar(255) DEFAULT NULL COMMENT 'a note related to the patron/borrower''s alternate address',
  `sort1` varchar(80) DEFAULT NULL COMMENT 'a field that can be used for any information unique to the library',
  `sort2` varchar(80) DEFAULT NULL COMMENT 'a field that can be used for any information unique to the library',
  `altcontactfirstname` mediumtext DEFAULT NULL COMMENT 'first name of alternate contact for the patron/borrower',
  `altcontactsurname` mediumtext DEFAULT NULL COMMENT 'surname or last name of the alternate contact for the patron/borrower',
  `altcontactaddress1` mediumtext DEFAULT NULL COMMENT 'the first address line for the alternate contact for the patron/borrower',
  `altcontactaddress2` mediumtext DEFAULT NULL COMMENT 'the second address line for the alternate contact for the patron/borrower',
  `altcontactaddress3` mediumtext DEFAULT NULL COMMENT 'the city for the alternate contact for the patron/borrower',
  `altcontactstate` mediumtext DEFAULT NULL COMMENT 'the state for the alternate contact for the patron/borrower',
  `altcontactzipcode` mediumtext DEFAULT NULL COMMENT 'the zipcode for the alternate contact for the patron/borrower',
  `altcontactcountry` mediumtext DEFAULT NULL COMMENT 'the country for the alternate contact for the patron/borrower',
  `altcontactphone` mediumtext DEFAULT NULL COMMENT 'the phone number for the alternate contact for the patron/borrower',
  `smsalertnumber` varchar(50) DEFAULT NULL COMMENT 'the mobile phone number where the patron/borrower would like to receive notices (if SMS turned on)',
  `sms_provider_id` int(11) DEFAULT NULL COMMENT 'the provider of the mobile phone number defined in smsalertnumber',
  `privacy` int(11) NOT NULL DEFAULT 1 COMMENT 'patron/borrower''s privacy settings related to their checkout history  KEY `borrowernumber` (`borrowernumber`),',
  `privacy_guarantor_fines` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'controls if relatives can see this patron''s fines',
  `privacy_guarantor_checkouts` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'controls if relatives can see this patron''s checkouts',
  `checkprevcheckout` varchar(7) NOT NULL DEFAULT 'inherit' COMMENT 'produce a warning for this patron if this item has previously been checked out to this patron if ''yes'', not if ''no'', defer to category setting if ''inherit''.',
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'time of last change could be useful for synchronization with external systems (among others)',
  `lastseen` datetime DEFAULT NULL COMMENT 'last time a patron has been seen (connected at the OPAC or staff interface)',
  `lang` varchar(25) NOT NULL DEFAULT 'default' COMMENT 'lang to use to send notices to this patron',
  `login_attempts` int(4) NOT NULL DEFAULT 0 COMMENT 'number of failed login attemps',
  `overdrive_auth_token` mediumtext DEFAULT NULL COMMENT 'persist OverDrive auth token',
  `anonymized` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'flag for data anonymization',
  `autorenew_checkouts` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'flag for allowing auto-renewal',
  `primary_contact_method` varchar(45) DEFAULT NULL COMMENT 'useful for reporting purposes',
  KEY `borrowernumber` (`borrowernumber`),
  KEY `cardnumber` (`cardnumber`),
  KEY `sms_provider_id` (`sms_provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deleteditems`
--

DROP TABLE IF EXISTS `deleteditems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deleteditems` (
  `itemnumber` int(11) NOT NULL DEFAULT 0 COMMENT 'primary key and unique identifier added by Koha',
  `biblionumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key from biblio table used to link this item to the right bib record',
  `biblioitemnumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key from the biblioitems table to link to item to additional information',
  `barcode` varchar(20) DEFAULT NULL COMMENT 'item barcode (MARC21 952$p)',
  `dateaccessioned` date DEFAULT NULL COMMENT 'date the item was acquired or added to Koha (MARC21 952$d)',
  `booksellerid` longtext DEFAULT NULL COMMENT 'where the item was purchased (MARC21 952$e)',
  `homebranch` varchar(10) DEFAULT NULL COMMENT 'foreign key from the branches table for the library that owns this item (MARC21 952$a)',
  `price` decimal(8,2) DEFAULT NULL COMMENT 'purchase price (MARC21 952$g)',
  `replacementprice` decimal(8,2) DEFAULT NULL COMMENT 'cost the library charges to replace the item if it has been marked lost (MARC21 952$v)',
  `replacementpricedate` date DEFAULT NULL COMMENT 'the date the price is effective from (MARC21 952$w)',
  `datelastborrowed` date DEFAULT NULL COMMENT 'the date the item was last checked out',
  `datelastseen` datetime DEFAULT NULL COMMENT 'the date the item was last see (usually the last time the barcode was scanned or inventory was done)',
  `stack` tinyint(1) DEFAULT NULL,
  `notforloan` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'authorized value defining why this item is not for loan (MARC21 952$7)',
  `damaged` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'authorized value defining this item as damaged (MARC21 952$4)',
  `damaged_on` datetime DEFAULT NULL COMMENT 'the date and time an item was last marked as damaged, NULL if not damaged',
  `itemlost` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'authorized value defining this item as lost (MARC21 952$1)',
  `itemlost_on` datetime DEFAULT NULL COMMENT 'the date and time an item was last marked as lost, NULL if not lost',
  `withdrawn` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'authorized value defining this item as withdrawn (MARC21 952$0)',
  `withdrawn_on` datetime DEFAULT NULL COMMENT 'the date and time an item was last marked as withdrawn, NULL if not withdrawn',
  `itemcallnumber` varchar(255) DEFAULT NULL COMMENT 'call number for this item (MARC21 952$o)',
  `coded_location_qualifier` varchar(10) DEFAULT NULL COMMENT 'coded location qualifier(MARC21 952$f)',
  `issues` smallint(6) DEFAULT 0 COMMENT 'number of times this item has been checked out',
  `renewals` smallint(6) DEFAULT NULL COMMENT 'number of times this item has been renewed',
  `reserves` smallint(6) DEFAULT NULL COMMENT 'number of times this item has been placed on hold/reserved',
  `restricted` tinyint(1) DEFAULT NULL COMMENT 'authorized value defining use restrictions for this item (MARC21 952$5)',
  `itemnotes` longtext DEFAULT NULL COMMENT 'public notes on this item (MARC21 952$z)',
  `itemnotes_nonpublic` longtext DEFAULT NULL COMMENT 'non-public notes on this item (MARC21 952$x)',
  `holdingbranch` varchar(10) DEFAULT NULL COMMENT 'foreign key from the branches table for the library that is currently in possession item (MARC21 952$b)',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time this item was last altered',
  `deleted_on` datetime DEFAULT NULL COMMENT 'date/time of deletion',
  `location` varchar(80) DEFAULT NULL COMMENT 'authorized value for the shelving location for this item (MARC21 952$c)',
  `permanent_location` varchar(80) DEFAULT NULL COMMENT 'linked to the CART and PROC temporary locations feature, stores the permanent shelving location',
  `onloan` date DEFAULT NULL COMMENT 'defines if item is checked out (NULL for not checked out, and due date for checked out)',
  `cn_source` varchar(10) DEFAULT NULL COMMENT 'classification source used on this item (MARC21 952$2)',
  `cn_sort` varchar(255) DEFAULT NULL COMMENT 'normalized form of the call number (MARC21 952$o) used for sorting',
  `ccode` varchar(80) DEFAULT NULL COMMENT 'authorized value for the collection code associated with this item (MARC21 952$8)',
  `materials` mediumtext DEFAULT NULL COMMENT 'materials specified (MARC21 952$3)',
  `uri` mediumtext DEFAULT NULL COMMENT 'URL for the item (MARC21 952$u)',
  `itype` varchar(10) DEFAULT NULL COMMENT 'foreign key from the itemtypes table defining the type for this item (MARC21 952$y)',
  `more_subfields_xml` longtext DEFAULT NULL COMMENT 'additional 952 subfields in XML format',
  `enumchron` mediumtext DEFAULT NULL COMMENT 'serial enumeration/chronology for the item (MARC21 952$h)',
  `copynumber` varchar(32) DEFAULT NULL COMMENT 'copy number (MARC21 952$t)',
  `stocknumber` varchar(32) DEFAULT NULL COMMENT 'inventory number (MARC21 952$i)',
  `new_status` varchar(32) DEFAULT NULL COMMENT '''new'' value, you can put whatever free-text information. This field is intented to be managed by the automatic_item_modification_by_age cronjob.',
  `exclude_from_local_holds_priority` tinyint(1) DEFAULT NULL COMMENT 'Exclude this item from local holds priority',
  PRIMARY KEY (`itemnumber`),
  KEY `delitembarcodeidx` (`barcode`),
  KEY `delitemstocknumberidx` (`stocknumber`),
  KEY `delitembinoidx` (`biblioitemnumber`),
  KEY `delitembibnoidx` (`biblionumber`),
  KEY `delhomebranch` (`homebranch`),
  KEY `delholdingbranch` (`holdingbranch`),
  KEY `itype_idx` (`itype`),
  KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `desks`
--

DROP TABLE IF EXISTS `desks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `desks` (
  `desk_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `desk_name` varchar(100) NOT NULL DEFAULT '' COMMENT 'name of the desk',
  `branchcode` varchar(10) NOT NULL COMMENT 'library the desk is located at',
  PRIMARY KEY (`desk_id`),
  KEY `fk_desks_branchcode` (`branchcode`),
  CONSTRAINT `fk_desks_branchcode` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `discharges`
--

DROP TABLE IF EXISTS `discharges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `discharges` (
  `discharge_id` int(11) NOT NULL AUTO_INCREMENT,
  `borrower` int(11) DEFAULT NULL,
  `needed` timestamp NULL DEFAULT NULL,
  `validated` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`discharge_id`),
  KEY `borrower_discharges_ibfk1` (`borrower`),
  CONSTRAINT `borrower_discharges_ibfk1` FOREIGN KEY (`borrower`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `edifact_ean`
--

DROP TABLE IF EXISTS `edifact_ean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `edifact_ean` (
  `ee_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(128) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `ean` varchar(15) NOT NULL,
  `id_code_qualifier` varchar(3) NOT NULL DEFAULT '14',
  PRIMARY KEY (`ee_id`),
  KEY `efk_branchcode` (`branchcode`),
  CONSTRAINT `efk_branchcode` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `edifact_messages`
--

DROP TABLE IF EXISTS `edifact_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `edifact_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_type` varchar(10) NOT NULL,
  `transfer_date` date DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `edi_acct` int(11) DEFAULT NULL,
  `status` mediumtext DEFAULT NULL,
  `basketno` int(11) DEFAULT NULL,
  `raw_msg` longtext DEFAULT NULL,
  `filename` mediumtext DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `vendorid` (`vendor_id`),
  KEY `ediacct` (`edi_acct`),
  KEY `basketno` (`basketno`),
  CONSTRAINT `emfk_basketno` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `emfk_edi_acct` FOREIGN KEY (`edi_acct`) REFERENCES `vendor_edi_accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `emfk_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_agreement_licenses`
--

DROP TABLE IF EXISTS `erm_agreement_licenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_agreement_licenses` (
  `agreement_license_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `agreement_id` int(11) NOT NULL COMMENT 'link to the agreement',
  `license_id` int(11) NOT NULL COMMENT 'link to the license',
  `status` varchar(80) NOT NULL COMMENT 'current status of the license',
  `physical_location` varchar(80) DEFAULT NULL COMMENT 'physical location of the license',
  `notes` mediumtext DEFAULT NULL COMMENT 'notes about this license',
  `uri` varchar(255) DEFAULT NULL COMMENT 'URI of the license',
  PRIMARY KEY (`agreement_license_id`),
  UNIQUE KEY `erm_agreement_licenses_uniq` (`agreement_id`,`license_id`),
  KEY `erm_agreement_licenses_ibfk_2` (`license_id`),
  CONSTRAINT `erm_agreement_licenses_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `erm_agreement_licenses_ibfk_2` FOREIGN KEY (`license_id`) REFERENCES `erm_licenses` (`license_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_agreement_periods`
--

DROP TABLE IF EXISTS `erm_agreement_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_agreement_periods` (
  `agreement_period_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `agreement_id` int(11) NOT NULL COMMENT 'link to the agreement',
  `started_on` date NOT NULL COMMENT 'start of the agreement period',
  `ended_on` date DEFAULT NULL COMMENT 'end of the agreement period',
  `cancellation_deadline` date DEFAULT NULL COMMENT 'Deadline for the cancellation',
  `notes` mediumtext DEFAULT NULL COMMENT 'notes about this period',
  PRIMARY KEY (`agreement_period_id`),
  KEY `erm_agreement_periods_ibfk_1` (`agreement_id`),
  CONSTRAINT `erm_agreement_periods_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_agreement_relationships`
--

DROP TABLE IF EXISTS `erm_agreement_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_agreement_relationships` (
  `agreement_id` int(11) NOT NULL COMMENT 'link to the agreement',
  `related_agreement_id` int(11) NOT NULL COMMENT 'link to the related agreement',
  `relationship` enum('supersedes','is-superseded-by','provides_post-cancellation_access_for','has-post-cancellation-access-in','tracks_demand-driven_acquisitions_for','has-demand-driven-acquisitions-in','has_backfile_in','has_frontfile_in','related_to') NOT NULL COMMENT 'relationship between the two agreements',
  `notes` mediumtext DEFAULT NULL COMMENT 'notes about this relationship',
  PRIMARY KEY (`agreement_id`,`related_agreement_id`),
  KEY `erm_agreement_relationships_ibfk_2` (`related_agreement_id`),
  CONSTRAINT `erm_agreement_relationships_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `erm_agreement_relationships_ibfk_2` FOREIGN KEY (`related_agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_agreements`
--

DROP TABLE IF EXISTS `erm_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_agreements` (
  `agreement_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `vendor_id` int(11) DEFAULT NULL COMMENT 'foreign key to aqbooksellers',
  `name` varchar(255) NOT NULL COMMENT 'name of the agreement',
  `description` longtext DEFAULT NULL COMMENT 'description of the agreement',
  `status` varchar(80) NOT NULL COMMENT 'current status of the agreement',
  `closure_reason` varchar(80) DEFAULT NULL COMMENT 'reason of the closure',
  `is_perpetual` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'is the agreement perpetual',
  `renewal_priority` varchar(80) DEFAULT NULL COMMENT 'priority of the renewal',
  `license_info` varchar(80) DEFAULT NULL COMMENT 'info about the license',
  PRIMARY KEY (`agreement_id`),
  KEY `erm_agreements_ibfk_1` (`vendor_id`),
  CONSTRAINT `erm_agreements_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_documents`
--

DROP TABLE IF EXISTS `erm_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_documents` (
  `document_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `agreement_id` int(11) DEFAULT NULL COMMENT 'link to the agreement',
  `license_id` int(11) DEFAULT NULL COMMENT 'link to the license',
  `file_name` varchar(255) DEFAULT NULL COMMENT 'name of the file',
  `file_type` varchar(255) DEFAULT NULL COMMENT 'type of the file',
  `file_description` varchar(255) DEFAULT NULL COMMENT 'description of the file',
  `file_content` longblob DEFAULT NULL COMMENT 'the content of the file',
  `uploaded_on` datetime DEFAULT NULL COMMENT 'datetime when the file as attached',
  `physical_location` varchar(255) DEFAULT NULL COMMENT 'physical location of the document',
  `uri` varchar(255) DEFAULT NULL COMMENT 'URI of the document',
  `notes` mediumtext DEFAULT NULL COMMENT 'notes about this relationship',
  PRIMARY KEY (`document_id`),
  KEY `erm_documents_ibfk_1` (`agreement_id`),
  KEY `erm_documents_ibfk_2` (`license_id`),
  CONSTRAINT `erm_documents_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `erm_documents_ibfk_2` FOREIGN KEY (`license_id`) REFERENCES `erm_licenses` (`license_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_eholdings_packages`
--

DROP TABLE IF EXISTS `erm_eholdings_packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_eholdings_packages` (
  `package_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `vendor_id` int(11) DEFAULT NULL COMMENT 'foreign key to aqbooksellers',
  `name` varchar(255) NOT NULL COMMENT 'name of the package',
  `external_id` varchar(255) DEFAULT NULL COMMENT 'External key',
  `provider` enum('ebsco') DEFAULT NULL COMMENT 'External provider',
  `package_type` varchar(80) DEFAULT NULL COMMENT 'type of the package',
  `content_type` varchar(80) DEFAULT NULL COMMENT 'type of the package',
  `notes` mediumtext DEFAULT NULL COMMENT 'notes about this package',
  `created_on` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date of creation of the package',
  PRIMARY KEY (`package_id`),
  KEY `erm_eholdings_packages_ibfk_1` (`vendor_id`),
  CONSTRAINT `erm_eholdings_packages_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_eholdings_packages_agreements`
--

DROP TABLE IF EXISTS `erm_eholdings_packages_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_eholdings_packages_agreements` (
  `package_id` int(11) NOT NULL COMMENT 'link to the package',
  `agreement_id` int(11) NOT NULL COMMENT 'link to the agreement',
  PRIMARY KEY (`package_id`,`agreement_id`),
  KEY `erm_eholdings_packages_agreements_ibfk_2` (`agreement_id`),
  CONSTRAINT `erm_eholdings_packages_agreements_ibfk_1` FOREIGN KEY (`package_id`) REFERENCES `erm_eholdings_packages` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `erm_eholdings_packages_agreements_ibfk_2` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_eholdings_resources`
--

DROP TABLE IF EXISTS `erm_eholdings_resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_eholdings_resources` (
  `resource_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `title_id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `started_on` date DEFAULT NULL,
  `ended_on` date DEFAULT NULL,
  `proxy` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`resource_id`),
  UNIQUE KEY `erm_eholdings_resources_uniq` (`title_id`,`package_id`),
  KEY `erm_eholdings_resources_ibfk_2` (`package_id`),
  KEY `erm_eholdings_resources_ibfk_3` (`vendor_id`),
  CONSTRAINT `erm_eholdings_resources_ibfk_1` FOREIGN KEY (`title_id`) REFERENCES `erm_eholdings_titles` (`title_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `erm_eholdings_resources_ibfk_2` FOREIGN KEY (`package_id`) REFERENCES `erm_eholdings_packages` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `erm_eholdings_resources_ibfk_3` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_eholdings_titles`
--

DROP TABLE IF EXISTS `erm_eholdings_titles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_eholdings_titles` (
  `title_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `biblio_id` int(11) DEFAULT NULL,
  `publication_title` mediumtext DEFAULT NULL,
  `external_id` varchar(255) DEFAULT NULL,
  `print_identifier` varchar(255) DEFAULT NULL,
  `online_identifier` varchar(255) DEFAULT NULL,
  `date_first_issue_online` varchar(255) DEFAULT NULL,
  `num_first_vol_online` varchar(255) DEFAULT NULL,
  `num_first_issue_online` varchar(255) DEFAULT NULL,
  `date_last_issue_online` varchar(255) DEFAULT NULL,
  `num_last_vol_online` varchar(255) DEFAULT NULL,
  `num_last_issue_online` varchar(255) DEFAULT NULL,
  `title_url` varchar(255) DEFAULT NULL,
  `first_author` varchar(255) DEFAULT NULL,
  `embargo_info` varchar(255) DEFAULT NULL,
  `coverage_depth` varchar(255) DEFAULT NULL,
  `notes` mediumtext DEFAULT NULL,
  `publisher_name` varchar(255) DEFAULT NULL,
  `publication_type` varchar(80) DEFAULT NULL,
  `date_monograph_published_print` varchar(255) DEFAULT NULL,
  `date_monograph_published_online` varchar(255) DEFAULT NULL,
  `monograph_volume` varchar(255) DEFAULT NULL,
  `monograph_edition` varchar(255) DEFAULT NULL,
  `first_editor` varchar(255) DEFAULT NULL,
  `parent_publication_title_id` varchar(255) DEFAULT NULL,
  `preceding_publication_title_id` varchar(255) DEFAULT NULL,
  `access_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`title_id`),
  KEY `erm_eholdings_titles_ibfk_2` (`biblio_id`),
  CONSTRAINT `erm_eholdings_titles_ibfk_2` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_licenses`
--

DROP TABLE IF EXISTS `erm_licenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_licenses` (
  `license_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `vendor_id` int(11) DEFAULT NULL COMMENT 'foreign key to aqbooksellers',
  `name` varchar(255) NOT NULL COMMENT 'name of the license',
  `description` longtext DEFAULT NULL COMMENT 'description of the license',
  `type` varchar(80) NOT NULL COMMENT 'type of the license',
  `status` varchar(80) NOT NULL COMMENT 'current status of the license',
  `started_on` date DEFAULT NULL COMMENT 'start of the license',
  `ended_on` date DEFAULT NULL COMMENT 'end of the license',
  PRIMARY KEY (`license_id`),
  KEY `erm_licenses_ibfk_1` (`vendor_id`),
  CONSTRAINT `erm_licenses_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `erm_user_roles`
--

DROP TABLE IF EXISTS `erm_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `erm_user_roles` (
  `user_role_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `agreement_id` int(11) DEFAULT NULL COMMENT 'link to the agreement',
  `license_id` int(11) DEFAULT NULL COMMENT 'link to the license',
  `user_id` int(11) NOT NULL COMMENT 'link to the user',
  `role` varchar(80) NOT NULL COMMENT 'role of the user',
  PRIMARY KEY (`user_role_id`),
  KEY `erm_user_roles_ibfk_1` (`agreement_id`),
  KEY `erm_user_roles_ibfk_2` (`license_id`),
  KEY `erm_user_roles_ibfk_3` (`user_id`),
  CONSTRAINT `erm_user_roles_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `erm_user_roles_ibfk_2` FOREIGN KEY (`license_id`) REFERENCES `erm_licenses` (`license_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `erm_user_roles_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `export_format`
--

DROP TABLE IF EXISTS `export_format`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_format` (
  `export_format_id` int(11) NOT NULL AUTO_INCREMENT,
  `profile` varchar(255) NOT NULL,
  `description` longtext NOT NULL,
  `content` longtext NOT NULL,
  `csv_separator` varchar(2) NOT NULL DEFAULT ',',
  `field_separator` varchar(2) DEFAULT NULL,
  `subfield_separator` varchar(2) DEFAULT NULL,
  `encoding` varchar(255) NOT NULL DEFAULT 'utf8',
  `type` varchar(255) DEFAULT 'marc',
  `used_for` varchar(255) DEFAULT 'export_records',
  `staff_only` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`export_format_id`),
  KEY `used_for_idx` (`used_for`(191)),
  KEY `staff_only_idx` (`staff_only`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Used for CSV export';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hold_cancellation_requests`
--

DROP TABLE IF EXISTS `hold_cancellation_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hold_cancellation_requests` (
  `hold_cancellation_request_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID of the cancellation request',
  `hold_id` int(11) NOT NULL COMMENT 'ID of the hold',
  `creation_date` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Time and date the cancellation request was created',
  PRIMARY KEY (`hold_cancellation_request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hold_fill_targets`
--

DROP TABLE IF EXISTS `hold_fill_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hold_fill_targets` (
  `borrowernumber` int(11) NOT NULL,
  `biblionumber` int(11) NOT NULL,
  `itemnumber` int(11) NOT NULL,
  `source_branchcode` varchar(10) DEFAULT NULL,
  `item_level_request` tinyint(4) NOT NULL DEFAULT 0,
  `reserve_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`itemnumber`),
  KEY `bib_branch` (`biblionumber`,`source_branchcode`),
  KEY `hold_fill_targets_ibfk_1` (`borrowernumber`),
  KEY `hold_fill_targets_ibfk_4` (`source_branchcode`),
  CONSTRAINT `hold_fill_targets_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_4` FOREIGN KEY (`source_branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `housebound_profile`
--

DROP TABLE IF EXISTS `housebound_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `housebound_profile` (
  `borrowernumber` int(11) NOT NULL COMMENT 'Number of the borrower associated with this profile.',
  `day` mediumtext NOT NULL COMMENT 'The preferred day of the week for delivery.',
  `frequency` mediumtext NOT NULL COMMENT 'The Authorised_Value definining the pattern for delivery.',
  `fav_itemtypes` mediumtext DEFAULT NULL COMMENT 'Free text describing preferred itemtypes.',
  `fav_subjects` mediumtext DEFAULT NULL COMMENT 'Free text describing preferred subjects.',
  `fav_authors` mediumtext DEFAULT NULL COMMENT 'Free text describing preferred authors.',
  `referral` mediumtext DEFAULT NULL COMMENT 'Free text indicating how the borrower was added to the service.',
  `notes` mediumtext DEFAULT NULL COMMENT 'Free text for additional notes.',
  PRIMARY KEY (`borrowernumber`),
  CONSTRAINT `housebound_profile_bnfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `housebound_role`
--

DROP TABLE IF EXISTS `housebound_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `housebound_role` (
  `borrowernumber_id` int(11) NOT NULL COMMENT 'borrowernumber link',
  `housebound_chooser` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'set to 1 to indicate this patron is a housebound chooser volunteer',
  `housebound_deliverer` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'set to 1 to indicate this patron is a housebound deliverer volunteer',
  PRIMARY KEY (`borrowernumber_id`),
  CONSTRAINT `houseboundrole_bnfk` FOREIGN KEY (`borrowernumber_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `housebound_visit`
--

DROP TABLE IF EXISTS `housebound_visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `housebound_visit` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID of the visit.',
  `borrowernumber` int(11) NOT NULL COMMENT 'Number of the borrower, & the profile, linked to this visit.',
  `appointment_date` date DEFAULT NULL COMMENT 'Date of visit.',
  `day_segment` varchar(10) DEFAULT NULL COMMENT 'Rough time frame: ''morning'', ''afternoon'' ''evening''',
  `chooser_brwnumber` int(11) DEFAULT NULL COMMENT 'Number of the borrower to choose items  for delivery.',
  `deliverer_brwnumber` int(11) DEFAULT NULL COMMENT 'Number of the borrower to deliver items.',
  PRIMARY KEY (`id`),
  KEY `houseboundvisit_bnfk` (`borrowernumber`),
  KEY `houseboundvisit_bnfk_1` (`chooser_brwnumber`),
  KEY `houseboundvisit_bnfk_2` (`deliverer_brwnumber`),
  CONSTRAINT `houseboundvisit_bnfk` FOREIGN KEY (`borrowernumber`) REFERENCES `housebound_profile` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `houseboundvisit_bnfk_1` FOREIGN KEY (`chooser_brwnumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `houseboundvisit_bnfk_2` FOREIGN KEY (`deliverer_brwnumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `identity_provider_domains`
--

DROP TABLE IF EXISTS `identity_provider_domains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `identity_provider_domains` (
  `identity_provider_domain_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key, used to identify providers domain',
  `identity_provider_id` int(11) NOT NULL COMMENT 'Reference to provider',
  `domain` varchar(100) DEFAULT NULL COMMENT 'Domain name. If null means all domains',
  `auto_register` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Allow user auto register',
  `update_on_auth` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Update user data on auth login',
  `default_library_id` varchar(10) DEFAULT NULL COMMENT 'Default library to create user if auto register is enabled',
  `default_category_id` varchar(10) DEFAULT NULL COMMENT 'Default category to create user if auto register is enabled',
  `allow_opac` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Allow provider from opac interface',
  `allow_staff` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Allow provider from staff interface',
  PRIMARY KEY (`identity_provider_domain_id`),
  UNIQUE KEY `identity_provider_id` (`identity_provider_id`,`domain`),
  KEY `domain` (`domain`),
  KEY `allow_opac` (`allow_opac`),
  KEY `allow_staff` (`allow_staff`),
  KEY `identity_provider_domain_ibfk_2` (`default_library_id`),
  KEY `identity_provider_domain_ibfk_3` (`default_category_id`),
  CONSTRAINT `identity_provider_domain_ibfk_1` FOREIGN KEY (`identity_provider_id`) REFERENCES `identity_providers` (`identity_provider_id`) ON DELETE CASCADE,
  CONSTRAINT `identity_provider_domain_ibfk_2` FOREIGN KEY (`default_library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE,
  CONSTRAINT `identity_provider_domain_ibfk_3` FOREIGN KEY (`default_category_id`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `identity_providers`
--

DROP TABLE IF EXISTS `identity_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `identity_providers` (
  `identity_provider_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key, used to identify the provider',
  `code` varchar(20) NOT NULL COMMENT 'Provider code',
  `description` varchar(255) NOT NULL COMMENT 'Description for the provider',
  `protocol` enum('OAuth','OIDC','LDAP','CAS') NOT NULL COMMENT 'Protocol provider speaks',
  `config` longtext NOT NULL COMMENT 'Configuration of the provider in JSON format',
  `mapping` longtext NOT NULL COMMENT 'Configuration to map provider data to Koha user',
  `matchpoint` enum('email','userid','cardnumber') NOT NULL COMMENT 'The patron attribute to be used as matchpoint',
  `icon_url` varchar(255) DEFAULT NULL COMMENT 'Provider icon URL',
  PRIMARY KEY (`identity_provider_id`),
  UNIQUE KEY `code` (`code`),
  KEY `protocol` (`protocol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `illcomments`
--

DROP TABLE IF EXISTS `illcomments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `illcomments` (
  `illcomment_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID of the comment',
  `illrequest_id` bigint(20) unsigned NOT NULL COMMENT 'ILL request number',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'Link to the user who made the comment (could be librarian, patron or ILL partner library)',
  `comment` text DEFAULT NULL COMMENT 'The text of the comment',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Date and time when the comment was made',
  PRIMARY KEY (`illcomment_id`),
  KEY `illcomments_bnfk` (`borrowernumber`),
  KEY `illcomments_ifk` (`illrequest_id`),
  CONSTRAINT `illcomments_bnfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `illcomments_ifk` FOREIGN KEY (`illrequest_id`) REFERENCES `illrequests` (`illrequest_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `illrequestattributes`
--

DROP TABLE IF EXISTS `illrequestattributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `illrequestattributes` (
  `illrequest_id` bigint(20) unsigned NOT NULL COMMENT 'ILL request number',
  `type` varchar(200) NOT NULL COMMENT 'API ILL property name',
  `value` mediumtext NOT NULL COMMENT 'API ILL property value',
  `readonly` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Is this attribute read only',
  PRIMARY KEY (`illrequest_id`,`type`(191)),
  CONSTRAINT `illrequestattributes_ifk` FOREIGN KEY (`illrequest_id`) REFERENCES `illrequests` (`illrequest_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `illrequests`
--

DROP TABLE IF EXISTS `illrequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `illrequests` (
  `illrequest_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ILL request number',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'Patron associated with request',
  `biblio_id` int(11) DEFAULT NULL COMMENT 'Potential bib linked to request',
  `deleted_biblio_id` int(11) DEFAULT NULL COMMENT 'Deleted bib linked to request',
  `due_date` datetime DEFAULT NULL COMMENT 'Custom date due specified by backend, leave NULL for default date_due calculation',
  `branchcode` varchar(50) NOT NULL COMMENT 'The branch associated with the request',
  `status` varchar(50) DEFAULT NULL COMMENT 'Current Koha status of request',
  `status_alias` varchar(80) DEFAULT NULL COMMENT 'Foreign key to relevant authorised_values.authorised_value',
  `placed` date DEFAULT NULL COMMENT 'Date the request was placed',
  `replied` date DEFAULT NULL COMMENT 'Last API response',
  `updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `completed` date DEFAULT NULL COMMENT 'Date the request was completed',
  `medium` varchar(30) DEFAULT NULL COMMENT 'The Koha request type',
  `accessurl` varchar(500) DEFAULT NULL COMMENT 'Potential URL for accessing item',
  `cost` varchar(20) DEFAULT NULL COMMENT 'Quotes cost of request',
  `price_paid` varchar(20) DEFAULT NULL COMMENT 'Final cost of request',
  `notesopac` mediumtext DEFAULT NULL COMMENT 'Patron notes attached to request',
  `notesstaff` mediumtext DEFAULT NULL COMMENT 'Staff notes attached to request',
  `orderid` varchar(50) DEFAULT NULL COMMENT 'Backend id attached to request',
  `backend` varchar(20) DEFAULT NULL COMMENT 'The backend used to create request',
  PRIMARY KEY (`illrequest_id`),
  KEY `illrequests_bnfk` (`borrowernumber`),
  KEY `illrequests_bcfk_2` (`branchcode`),
  KEY `illrequests_safk` (`status_alias`),
  KEY `illrequests_bibfk` (`biblio_id`),
  CONSTRAINT `illrequests_bcfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `illrequests_bibfk` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `illrequests_bnfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `illrequests_safk` FOREIGN KEY (`status_alias`) REFERENCES `authorised_values` (`authorised_value`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `import_auths`
--

DROP TABLE IF EXISTS `import_auths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_auths` (
  `import_record_id` int(11) NOT NULL,
  `matched_authid` int(11) DEFAULT NULL,
  `control_number` varchar(25) DEFAULT NULL,
  `authorized_heading` varchar(128) DEFAULT NULL,
  `original_source` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`import_record_id`),
  KEY `import_auths_ibfk_1` (`import_record_id`),
  KEY `matched_authid` (`matched_authid`),
  CONSTRAINT `import_auths_ibfk_1` FOREIGN KEY (`import_record_id`) REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `import_batch_profiles`
--

DROP TABLE IF EXISTS `import_batch_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_batch_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier and primary key',
  `name` varchar(100) NOT NULL COMMENT 'name of this profile',
  `matcher_id` int(11) DEFAULT NULL COMMENT 'the id of the match rule used (matchpoints.matcher_id)',
  `template_id` int(11) DEFAULT NULL COMMENT 'the id of the marc modification template',
  `overlay_action` varchar(50) DEFAULT NULL COMMENT 'how to handle duplicate records',
  `nomatch_action` varchar(50) DEFAULT NULL COMMENT 'how to handle records where no match is found',
  `item_action` varchar(50) DEFAULT NULL COMMENT 'what to do with item records',
  `parse_items` tinyint(1) DEFAULT NULL COMMENT 'should items be parsed',
  `record_type` varchar(50) DEFAULT NULL COMMENT 'type of record in the batch',
  `encoding` varchar(50) DEFAULT NULL COMMENT 'file encoding',
  `format` varchar(50) DEFAULT NULL COMMENT 'marc format',
  `comments` longtext DEFAULT NULL COMMENT 'any comments added when the file was uploaded',
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_import_batch_profiles__name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `import_batches`
--

DROP TABLE IF EXISTS `import_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_batches` (
  `import_batch_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier and primary key',
  `matcher_id` int(11) DEFAULT NULL COMMENT 'the id of the match rule used (matchpoints.matcher_id)',
  `template_id` int(11) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `num_records` int(11) NOT NULL DEFAULT 0 COMMENT 'number of records in the file',
  `num_items` int(11) NOT NULL DEFAULT 0 COMMENT 'number of items in the file',
  `upload_timestamp` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date and time the file was uploaded',
  `overlay_action` enum('replace','create_new','use_template','ignore') NOT NULL DEFAULT 'create_new' COMMENT 'how to handle duplicate records',
  `nomatch_action` enum('create_new','ignore') NOT NULL DEFAULT 'create_new' COMMENT 'how to handle records where no match is found',
  `item_action` enum('always_add','add_only_for_matches','add_only_for_new','ignore','replace') NOT NULL DEFAULT 'always_add' COMMENT 'what to do with item records',
  `import_status` enum('staging','staged','importing','imported','reverting','reverted','cleaned') NOT NULL DEFAULT 'staging' COMMENT 'the status of the imported file',
  `batch_type` enum('batch','z3950','webservice') NOT NULL DEFAULT 'batch' COMMENT 'where this batch has come from',
  `record_type` enum('biblio','auth','holdings') NOT NULL DEFAULT 'biblio' COMMENT 'type of record in the batch',
  `file_name` varchar(100) DEFAULT NULL COMMENT 'the name of the file uploaded',
  `comments` longtext DEFAULT NULL COMMENT 'any comments added when the file was uploaded',
  `profile_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`import_batch_id`),
  KEY `branchcode` (`branchcode`),
  KEY `import_batches_ibfk_1` (`profile_id`),
  CONSTRAINT `import_batches_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `import_batch_profiles` (`id`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `import_biblios`
--

DROP TABLE IF EXISTS `import_biblios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_biblios` (
  `import_record_id` int(11) NOT NULL,
  `matched_biblionumber` int(11) DEFAULT NULL,
  `control_number` varchar(25) DEFAULT NULL,
  `original_source` varchar(25) DEFAULT NULL,
  `title` longtext DEFAULT NULL,
  `author` longtext DEFAULT NULL,
  `isbn` longtext DEFAULT NULL,
  `issn` longtext DEFAULT NULL,
  `has_items` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`import_record_id`),
  KEY `import_biblios_ibfk_1` (`import_record_id`),
  KEY `matched_biblionumber` (`matched_biblionumber`),
  KEY `title` (`title`(191)),
  KEY `isbn` (`isbn`(191)),
  CONSTRAINT `import_biblios_ibfk_1` FOREIGN KEY (`import_record_id`) REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `import_items`
--

DROP TABLE IF EXISTS `import_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_items` (
  `import_items_id` int(11) NOT NULL AUTO_INCREMENT,
  `import_record_id` int(11) NOT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `status` enum('error','staged','imported','reverted','ignored') NOT NULL DEFAULT 'staged',
  `marcxml` longtext NOT NULL,
  `import_error` longtext DEFAULT NULL,
  PRIMARY KEY (`import_items_id`),
  KEY `import_items_ibfk_1` (`import_record_id`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `import_items_ibfk_1` FOREIGN KEY (`import_record_id`) REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `import_record_matches`
--

DROP TABLE IF EXISTS `import_record_matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_record_matches` (
  `import_record_id` int(11) NOT NULL COMMENT 'the id given to the imported bib record (import_records.import_record_id)',
  `candidate_match_id` int(11) NOT NULL COMMENT 'the biblio the imported record matches (biblio.biblionumber)',
  `score` int(11) NOT NULL DEFAULT 0 COMMENT 'the match score',
  `chosen` tinyint(1) DEFAULT NULL COMMENT 'whether this match has been allowed or denied',
  PRIMARY KEY (`import_record_id`,`candidate_match_id`),
  KEY `record_score` (`import_record_id`,`score`),
  CONSTRAINT `import_record_matches_ibfk_1` FOREIGN KEY (`import_record_id`) REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `import_records`
--

DROP TABLE IF EXISTS `import_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_records` (
  `import_record_id` int(11) NOT NULL AUTO_INCREMENT,
  `import_batch_id` int(11) NOT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `record_sequence` int(11) NOT NULL DEFAULT 0,
  `upload_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `import_date` date DEFAULT NULL,
  `marc` longblob NOT NULL,
  `marcxml` longtext NOT NULL,
  `marcxml_old` longtext NOT NULL,
  `record_type` enum('biblio','auth','holdings') NOT NULL DEFAULT 'biblio',
  `overlay_status` enum('no_match','auto_match','manual_match','match_applied') NOT NULL DEFAULT 'no_match',
  `status` enum('error','staged','imported','reverted','items_reverted','ignored') NOT NULL DEFAULT 'staged',
  `import_error` longtext DEFAULT NULL,
  `encoding` varchar(40) NOT NULL DEFAULT '',
  PRIMARY KEY (`import_record_id`),
  KEY `branchcode` (`branchcode`),
  KEY `batch_sequence` (`import_batch_id`,`record_sequence`),
  KEY `batch_id_record_type` (`import_batch_id`,`record_type`),
  CONSTRAINT `import_records_ifbk_1` FOREIGN KEY (`import_batch_id`) REFERENCES `import_batches` (`import_batch_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `issues`
--

DROP TABLE IF EXISTS `issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issues` (
  `issue_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key for issues table',
  `borrowernumber` int(11) NOT NULL COMMENT 'foreign key, linking this to the borrowers table for the patron this item was checked out to',
  `issuer_id` int(11) DEFAULT NULL COMMENT 'foreign key, linking this to the borrowers table for the user who checked out this item',
  `itemnumber` int(11) NOT NULL COMMENT 'foreign key, linking this to the items table for the item that was checked out',
  `date_due` datetime DEFAULT NULL COMMENT 'datetime the item is due (yyyy-mm-dd hh:mm::ss)',
  `branchcode` varchar(10) DEFAULT NULL COMMENT 'foreign key, linking to the branches table for the location the item was checked out',
  `returndate` datetime DEFAULT NULL COMMENT 'date the item was returned, will be NULL until moved to old_issues',
  `lastreneweddate` datetime DEFAULT NULL COMMENT 'date the item was last renewed',
  `renewals_count` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'lists the number of times the item was renewed',
  `unseen_renewals` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'lists the number of consecutive times the item was renewed without being seen',
  `auto_renew` tinyint(1) DEFAULT 0 COMMENT 'automatic renewal',
  `auto_renew_error` varchar(32) DEFAULT NULL COMMENT 'automatic renewal error',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'the date and time this record was last touched',
  `issuedate` datetime DEFAULT NULL COMMENT 'date the item was checked out or issued',
  `onsite_checkout` int(1) NOT NULL DEFAULT 0 COMMENT 'in house use flag',
  `note` longtext DEFAULT NULL COMMENT 'issue note text',
  `notedate` datetime DEFAULT NULL COMMENT 'datetime of issue note (yyyy-mm-dd hh:mm::ss)',
  `noteseen` int(1) DEFAULT NULL COMMENT 'describes whether checkout note has been seen 1, not been seen 0 or doesn''t exist null',
  PRIMARY KEY (`issue_id`),
  UNIQUE KEY `itemnumber` (`itemnumber`),
  KEY `issuesborridx` (`borrowernumber`),
  KEY `itemnumber_idx` (`itemnumber`),
  KEY `branchcode_idx` (`branchcode`),
  KEY `bordate` (`borrowernumber`,`timestamp`),
  KEY `issues_ibfk_borrowers_borrowernumber` (`issuer_id`),
  CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON UPDATE CASCADE,
  CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON UPDATE CASCADE,
  CONSTRAINT `issues_ibfk_borrowers_borrowernumber` FOREIGN KEY (`issuer_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_bundles`
--

DROP TABLE IF EXISTS `item_bundles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_bundles` (
  `item` int(11) NOT NULL,
  `host` int(11) NOT NULL,
  PRIMARY KEY (`host`,`item`),
  UNIQUE KEY `item_bundles_uniq_1` (`item`),
  CONSTRAINT `item_bundles_ibfk_1` FOREIGN KEY (`item`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_bundles_ibfk_2` FOREIGN KEY (`host`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_circulation_alert_preferences`
--

DROP TABLE IF EXISTS `item_circulation_alert_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_circulation_alert_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branchcode` varchar(10) NOT NULL,
  `categorycode` varchar(10) NOT NULL,
  `item_type` varchar(10) NOT NULL,
  `notification` varchar(16) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `branchcode` (`branchcode`,`categorycode`,`item_type`,`notification`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_editor_templates`
--

DROP TABLE IF EXISTS `item_editor_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_editor_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id for the template',
  `patron_id` int(11) DEFAULT NULL COMMENT 'creator of this template',
  `name` mediumtext NOT NULL COMMENT 'template name',
  `is_shared` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'controls if template is shared',
  `contents` longtext NOT NULL COMMENT 'json encoded template data',
  PRIMARY KEY (`id`),
  KEY `bn` (`patron_id`),
  CONSTRAINT `bn` FOREIGN KEY (`patron_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_group_items`
--

DROP TABLE IF EXISTS `item_group_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_group_items` (
  `item_group_items_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id for the group/item link',
  `item_group_id` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key making this table a 1 to 1 join from items to item groups',
  `item_id` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key linking this table to the items table',
  PRIMARY KEY (`item_group_items_id`),
  UNIQUE KEY `item_id` (`item_id`),
  KEY `item_group_items_gifk_1` (`item_group_id`),
  CONSTRAINT `item_group_items_gifk_1` FOREIGN KEY (`item_group_id`) REFERENCES `item_groups` (`item_group_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item_group_items_iifk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_groups`
--

DROP TABLE IF EXISTS `item_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_groups` (
  `item_group_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id for the items group',
  `biblio_id` int(11) NOT NULL COMMENT 'id for the bibliographic record the group belongs to',
  `display_order` int(4) NOT NULL DEFAULT 0 COMMENT 'The ''sort order'' for item_groups',
  `description` mediumtext DEFAULT NULL COMMENT 'A group description',
  `created_on` timestamp NULL DEFAULT NULL COMMENT 'Time and date the group was created',
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Time and date of the latest change on the group',
  PRIMARY KEY (`item_group_id`),
  KEY `item_groups_ibfk_1` (`biblio_id`),
  CONSTRAINT `item_groups_ibfk_1` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `itemnumber` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique identifier added by Koha',
  `biblionumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key from biblio table used to link this item to the right bib record',
  `biblioitemnumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key from the biblioitems table to link to item to additional information',
  `barcode` varchar(20) DEFAULT NULL COMMENT 'item barcode (MARC21 952$p)',
  `dateaccessioned` date DEFAULT NULL COMMENT 'date the item was acquired or added to Koha (MARC21 952$d)',
  `booksellerid` longtext DEFAULT NULL COMMENT 'where the item was purchased (MARC21 952$e)',
  `homebranch` varchar(10) DEFAULT NULL COMMENT 'foreign key from the branches table for the library that owns this item (MARC21 952$a)',
  `price` decimal(8,2) DEFAULT NULL COMMENT 'purchase price (MARC21 952$g)',
  `replacementprice` decimal(8,2) DEFAULT NULL COMMENT 'cost the library charges to replace the item if it has been marked lost (MARC21 952$v)',
  `replacementpricedate` date DEFAULT NULL COMMENT 'the date the price is effective from (MARC21 952$w)',
  `datelastborrowed` date DEFAULT NULL COMMENT 'the date the item was last checked out/issued',
  `datelastseen` datetime DEFAULT NULL COMMENT 'the date the item was last see (usually the last time the barcode was scanned or inventory was done)',
  `stack` tinyint(1) DEFAULT NULL,
  `notforloan` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'authorized value defining why this item is not for loan (MARC21 952$7)',
  `damaged` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'authorized value defining this item as damaged (MARC21 952$4)',
  `damaged_on` datetime DEFAULT NULL COMMENT 'the date and time an item was last marked as damaged, NULL if not damaged',
  `itemlost` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'authorized value defining this item as lost (MARC21 952$1)',
  `itemlost_on` datetime DEFAULT NULL COMMENT 'the date and time an item was last marked as lost, NULL if not lost',
  `withdrawn` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'authorized value defining this item as withdrawn (MARC21 952$0)',
  `withdrawn_on` datetime DEFAULT NULL COMMENT 'the date and time an item was last marked as withdrawn, NULL if not withdrawn',
  `itemcallnumber` varchar(255) DEFAULT NULL COMMENT 'call number for this item (MARC21 952$o)',
  `coded_location_qualifier` varchar(10) DEFAULT NULL COMMENT 'coded location qualifier(MARC21 952$f)',
  `issues` smallint(6) DEFAULT 0 COMMENT 'number of times this item has been checked out/issued',
  `renewals` smallint(6) DEFAULT NULL COMMENT 'number of times this item has been renewed',
  `reserves` smallint(6) DEFAULT NULL COMMENT 'number of times this item has been placed on hold/reserved',
  `restricted` tinyint(1) DEFAULT NULL COMMENT 'authorized value defining use restrictions for this item (MARC21 952$5)',
  `itemnotes` longtext DEFAULT NULL COMMENT 'public notes on this item (MARC21 952$z)',
  `itemnotes_nonpublic` longtext DEFAULT NULL COMMENT 'non-public notes on this item (MARC21 952$x)',
  `holdingbranch` varchar(10) DEFAULT NULL COMMENT 'foreign key from the branches table for the library that is currently in possession item (MARC21 952$b)',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time this item was last altered',
  `deleted_on` datetime DEFAULT NULL COMMENT 'date/time of deletion',
  `location` varchar(80) DEFAULT NULL COMMENT 'authorized value for the shelving location for this item (MARC21 952$c)',
  `permanent_location` varchar(80) DEFAULT NULL COMMENT 'linked to the CART and PROC temporary locations feature, stores the permanent shelving location',
  `onloan` date DEFAULT NULL COMMENT 'defines if item is checked out (NULL for not checked out, and due date for checked out)',
  `cn_source` varchar(10) DEFAULT NULL COMMENT 'classification source used on this item (MARC21 952$2)',
  `cn_sort` varchar(255) DEFAULT NULL COMMENT 'normalized form of the call number (MARC21 952$o) used for sorting',
  `ccode` varchar(80) DEFAULT NULL COMMENT 'authorized value for the collection code associated with this item (MARC21 952$8)',
  `materials` mediumtext DEFAULT NULL COMMENT 'materials specified (MARC21 952$3)',
  `uri` mediumtext DEFAULT NULL COMMENT 'URL for the item (MARC21 952$u)',
  `itype` varchar(10) DEFAULT NULL COMMENT 'foreign key from the itemtypes table defining the type for this item (MARC21 952$y)',
  `more_subfields_xml` longtext DEFAULT NULL COMMENT 'additional 952 subfields in XML format',
  `enumchron` mediumtext DEFAULT NULL COMMENT 'serial enumeration/chronology for the item (MARC21 952$h)',
  `copynumber` varchar(32) DEFAULT NULL COMMENT 'copy number (MARC21 952$t)',
  `stocknumber` varchar(32) DEFAULT NULL COMMENT 'inventory number (MARC21 952$i)',
  `new_status` varchar(32) DEFAULT NULL COMMENT '''new'' value, you can put whatever free-text information. This field is intented to be managed by the automatic_item_modification_by_age cronjob.',
  `exclude_from_local_holds_priority` tinyint(1) DEFAULT NULL COMMENT 'Exclude this item from local holds priority',
  PRIMARY KEY (`itemnumber`),
  UNIQUE KEY `itembarcodeidx` (`barcode`),
  KEY `itemstocknumberidx` (`stocknumber`),
  KEY `itembinoidx` (`biblioitemnumber`),
  KEY `itembibnoidx` (`biblionumber`),
  KEY `homebranch` (`homebranch`),
  KEY `holdingbranch` (`holdingbranch`),
  KEY `itemcallnumber` (`itemcallnumber`(191)),
  KEY `items_location` (`location`),
  KEY `items_ccode` (`ccode`),
  KEY `itype_idx` (`itype`),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblioitemnumber`) REFERENCES `biblioitems` (`biblioitemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_4` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items_last_borrower`
--

DROP TABLE IF EXISTS `items_last_borrower`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items_last_borrower` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `itemnumber` int(11) NOT NULL,
  `borrowernumber` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `itemnumber` (`itemnumber`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT `items_last_borrower_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_last_borrower_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items_search_fields`
--

DROP TABLE IF EXISTS `items_search_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items_search_fields` (
  `name` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `tagfield` char(3) NOT NULL,
  `tagsubfield` char(1) DEFAULT NULL,
  `authorised_values_category` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`name`(191)),
  KEY `items_search_fields_authorised_values_category` (`authorised_values_category`),
  CONSTRAINT `items_search_fields_authorised_values_category` FOREIGN KEY (`authorised_values_category`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itemtypes`
--

DROP TABLE IF EXISTS `itemtypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itemtypes` (
  `itemtype` varchar(10) NOT NULL DEFAULT '' COMMENT 'unique key, a code associated with the item type',
  `parent_type` varchar(10) DEFAULT NULL COMMENT 'unique key, a code associated with the item type',
  `description` longtext DEFAULT NULL COMMENT 'a plain text explanation of the item type',
  `rentalcharge` decimal(28,6) DEFAULT NULL COMMENT 'the amount charged when this item is checked out/issued',
  `rentalcharge_daily` decimal(28,6) DEFAULT NULL COMMENT 'the amount charged for each day between checkout date and due date',
  `rentalcharge_daily_calendar` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'controls if the daily rental fee is calculated directly or using finesCalendar',
  `rentalcharge_hourly` decimal(28,6) DEFAULT NULL COMMENT 'the amount charged for each hour between checkout date and due date',
  `rentalcharge_hourly_calendar` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'controls if the hourly rental fee is calculated directly or using finesCalendar',
  `defaultreplacecost` decimal(28,6) DEFAULT NULL COMMENT 'default replacement cost',
  `processfee` decimal(28,6) DEFAULT NULL COMMENT 'default text be recorded in the column note when the processing fee is applied',
  `notforloan` smallint(6) DEFAULT NULL COMMENT '1 if the item is not for loan, 0 if the item is available for loan',
  `imageurl` varchar(200) DEFAULT NULL COMMENT 'URL for the item type icon',
  `summary` mediumtext DEFAULT NULL COMMENT 'information from the summary field, may include HTML',
  `checkinmsg` varchar(255) DEFAULT NULL COMMENT 'message that is displayed when an item with the given item type is checked in',
  `checkinmsgtype` char(16) NOT NULL DEFAULT 'message' COMMENT 'type (CSS class) for the checkinmsg, can be ''alert'' or ''message''',
  `sip_media_type` varchar(3) DEFAULT NULL COMMENT 'SIP2 protocol media type for this itemtype',
  `hideinopac` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Hide the item type from the search options in OPAC',
  `searchcategory` varchar(80) DEFAULT NULL COMMENT 'Group this item type with others with the same value on OPAC search options',
  `automatic_checkin` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'If automatic checkin is enabled for items of this type',
  PRIMARY KEY (`itemtype`),
  UNIQUE KEY `itemtype` (`itemtype`),
  KEY `itemtypes_ibfk_1` (`parent_type`),
  CONSTRAINT `itemtypes_ibfk_1` FOREIGN KEY (`parent_type`) REFERENCES `itemtypes` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itemtypes_branches`
--

DROP TABLE IF EXISTS `itemtypes_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itemtypes_branches` (
  `itemtype` varchar(10) NOT NULL,
  `branchcode` varchar(10) NOT NULL,
  KEY `itemtype` (`itemtype`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `itemtypes_branches_ibfk_1` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE,
  CONSTRAINT `itemtypes_branches_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `keyboard_shortcuts`
--

DROP TABLE IF EXISTS `keyboard_shortcuts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyboard_shortcuts` (
  `shortcut_name` varchar(80) NOT NULL,
  `shortcut_keys` varchar(80) NOT NULL,
  PRIMARY KEY (`shortcut_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `language_descriptions`
--

DROP TABLE IF EXISTS `language_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_descriptions` (
  `subtag` varchar(25) DEFAULT NULL,
  `type` varchar(25) DEFAULT NULL,
  `lang` varchar(25) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_desc` (`subtag`,`type`,`lang`),
  KEY `lang` (`lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `language_rfc4646_to_iso639`
--

DROP TABLE IF EXISTS `language_rfc4646_to_iso639`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_rfc4646_to_iso639` (
  `rfc4646_subtag` varchar(25) DEFAULT NULL,
  `iso639_2_code` varchar(25) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_code` (`rfc4646_subtag`,`iso639_2_code`),
  KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `language_script_bidi`
--

DROP TABLE IF EXISTS `language_script_bidi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_script_bidi` (
  `rfc4646_subtag` varchar(25) DEFAULT NULL COMMENT 'script subtag, Arab, Hebr, etc.',
  `bidi` varchar(3) DEFAULT NULL COMMENT 'rtl ltr',
  KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `language_script_mapping`
--

DROP TABLE IF EXISTS `language_script_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_script_mapping` (
  `language_subtag` varchar(25) NOT NULL,
  `script_subtag` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`language_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `language_subtag_registry`
--

DROP TABLE IF EXISTS `language_subtag_registry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_subtag_registry` (
  `subtag` varchar(25) DEFAULT NULL,
  `type` varchar(25) DEFAULT NULL COMMENT 'language-script-region-variant-extension-privateuse',
  `description` varchar(255) DEFAULT NULL COMMENT 'only one of the possible descriptions for ease of reference, see language_descriptions for the complete list',
  `added` date DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_lang` (`subtag`,`type`),
  KEY `subtag` (`subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `letter`
--

DROP TABLE IF EXISTS `letter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `letter` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key identifier',
  `module` varchar(20) NOT NULL DEFAULT '' COMMENT 'Koha module that triggers this notice or slip',
  `code` varchar(20) NOT NULL DEFAULT '' COMMENT 'unique identifier for this notice or slip',
  `branchcode` varchar(10) NOT NULL DEFAULT '' COMMENT 'the branch this notice or slip is used at (branches.branchcode)',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT 'plain text name for this notice or slip',
  `is_html` tinyint(1) DEFAULT 0 COMMENT 'does this notice or slip use HTML (1 for yes, 0 for no)',
  `title` varchar(200) NOT NULL DEFAULT '' COMMENT 'subject line of the notice',
  `content` mediumtext DEFAULT NULL COMMENT 'body text for the notice or slip',
  `message_transport_type` varchar(20) NOT NULL DEFAULT 'email' COMMENT 'transport type for this notice',
  `lang` varchar(25) NOT NULL DEFAULT 'default' COMMENT 'lang of the notice',
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'last modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `letter_uniq_1` (`module`,`code`,`branchcode`,`message_transport_type`,`lang`),
  KEY `message_transport_type_fk` (`message_transport_type`),
  CONSTRAINT `message_transport_type_fk` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `library_groups`
--

DROP TABLE IF EXISTS `library_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `library_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id for each group',
  `parent_id` int(11) DEFAULT NULL COMMENT 'if this is a child group, the id of the parent group',
  `branchcode` varchar(10) DEFAULT NULL COMMENT 'The branchcode of a branch belonging to the parent group',
  `title` varchar(100) DEFAULT NULL COMMENT 'Short description of the goup',
  `description` mediumtext DEFAULT NULL COMMENT 'Longer explanation of the group, if necessary',
  `ft_hide_patron_info` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Turn on the feature ''Hide patron''s info'' for this group',
  `ft_limit_item_editing` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Turn on the feature "Limit item editing by group" for this group',
  `ft_search_groups_opac` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Use this group for staff side search groups',
  `ft_search_groups_staff` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Use this group for opac side search groups',
  `ft_local_hold_group` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Use this group to identify libraries as pick up location for holds',
  `created_on` timestamp NULL DEFAULT NULL COMMENT 'Date and time of creation',
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Date and time of last',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`),
  UNIQUE KEY `library_groups_uniq_2` (`parent_id`,`branchcode`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `library_groups_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `library_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `library_groups_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `library_smtp_servers`
--

DROP TABLE IF EXISTS `library_smtp_servers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `library_smtp_servers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `library_id` varchar(10) NOT NULL,
  `smtp_server_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `library_id_idx` (`library_id`),
  KEY `smtp_server_id_idx` (`smtp_server_id`),
  CONSTRAINT `library_smtp_servers_library_fk` FOREIGN KEY (`library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `library_smtp_servers_smtp_servers_fk` FOREIGN KEY (`smtp_server_id`) REFERENCES `smtp_servers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linktracker`
--

DROP TABLE IF EXISTS `linktracker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `linktracker` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key identifier',
  `biblionumber` int(11) DEFAULT NULL COMMENT 'biblionumber of the record the link is from',
  `itemnumber` int(11) DEFAULT NULL COMMENT 'itemnumber if applicable that the link was from',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'borrowernumber who clicked the link',
  `url` mediumtext DEFAULT NULL COMMENT 'the link itself',
  `timeclicked` datetime DEFAULT NULL COMMENT 'the date and time the link was clicked',
  PRIMARY KEY (`id`),
  KEY `bibidx` (`biblionumber`),
  KEY `itemidx` (`itemnumber`),
  KEY `borridx` (`borrowernumber`),
  KEY `dateidx` (`timeclicked`),
  CONSTRAINT `linktracker_biblio_ibfk` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `linktracker_borrower_ibfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `linktracker_item_ibfk` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `localization`
--

DROP TABLE IF EXISTS `localization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `localization` (
  `localization_id` int(11) NOT NULL AUTO_INCREMENT,
  `entity` varchar(16) NOT NULL,
  `code` varchar(64) NOT NULL,
  `lang` varchar(25) NOT NULL COMMENT 'could be a foreign key',
  `translation` mediumtext DEFAULT NULL,
  PRIMARY KEY (`localization_id`),
  UNIQUE KEY `entity_code_lang` (`entity`,`code`,`lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marc_matchers`
--

DROP TABLE IF EXISTS `marc_matchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_matchers` (
  `matcher_id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(10) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `record_type` varchar(10) NOT NULL DEFAULT 'biblio',
  `threshold` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`matcher_id`),
  KEY `code` (`code`),
  KEY `record_type` (`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marc_modification_template_actions`
--

DROP TABLE IF EXISTS `marc_modification_template_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_modification_template_actions` (
  `mmta_id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `ordering` int(3) NOT NULL,
  `action` enum('delete_field','add_field','update_field','move_field','copy_field','copy_and_replace_field') NOT NULL,
  `field_number` smallint(6) NOT NULL DEFAULT 0,
  `from_field` varchar(3) NOT NULL,
  `from_subfield` varchar(1) DEFAULT NULL,
  `field_value` text DEFAULT NULL,
  `to_field` varchar(3) DEFAULT NULL,
  `to_subfield` varchar(1) DEFAULT NULL,
  `to_regex_search` mediumtext DEFAULT NULL,
  `to_regex_replace` mediumtext DEFAULT NULL,
  `to_regex_modifiers` varchar(8) DEFAULT '',
  `conditional` enum('if','unless') DEFAULT NULL,
  `conditional_field` varchar(3) DEFAULT NULL,
  `conditional_subfield` varchar(1) DEFAULT NULL,
  `conditional_comparison` enum('exists','not_exists','equals','not_equals') DEFAULT NULL,
  `conditional_value` mediumtext DEFAULT NULL,
  `conditional_regex` tinyint(1) NOT NULL DEFAULT 0,
  `description` mediumtext DEFAULT NULL,
  PRIMARY KEY (`mmta_id`),
  KEY `mmta_ibfk_1` (`template_id`),
  CONSTRAINT `mmta_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `marc_modification_templates` (`template_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marc_modification_templates`
--

DROP TABLE IF EXISTS `marc_modification_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_modification_templates` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` mediumtext NOT NULL,
  PRIMARY KEY (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marc_overlay_rules`
--

DROP TABLE IF EXISTS `marc_overlay_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_overlay_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag` varchar(255) NOT NULL,
  `module` varchar(127) NOT NULL,
  `filter` varchar(255) NOT NULL,
  `add` tinyint(1) NOT NULL DEFAULT 0,
  `append` tinyint(1) NOT NULL DEFAULT 0,
  `remove` tinyint(1) NOT NULL DEFAULT 0,
  `delete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marc_subfield_structure`
--

DROP TABLE IF EXISTS `marc_subfield_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_subfield_structure` (
  `tagfield` varchar(3) NOT NULL DEFAULT '',
  `tagsubfield` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `liblibrarian` varchar(255) NOT NULL DEFAULT '',
  `libopac` varchar(255) NOT NULL DEFAULT '',
  `repeatable` tinyint(4) NOT NULL DEFAULT 0,
  `mandatory` tinyint(4) NOT NULL DEFAULT 0,
  `important` tinyint(4) NOT NULL DEFAULT 0,
  `kohafield` varchar(40) DEFAULT NULL,
  `tab` tinyint(1) DEFAULT NULL,
  `authorised_value` varchar(32) DEFAULT NULL,
  `authtypecode` varchar(20) DEFAULT NULL,
  `value_builder` varchar(80) DEFAULT NULL,
  `isurl` tinyint(1) DEFAULT NULL,
  `hidden` tinyint(1) NOT NULL DEFAULT 8,
  `frameworkcode` varchar(4) NOT NULL DEFAULT '',
  `seealso` varchar(1100) DEFAULT NULL,
  `link` varchar(80) DEFAULT NULL,
  `defaultvalue` mediumtext DEFAULT NULL,
  `maxlength` int(4) NOT NULL DEFAULT 9999,
  `display_order` int(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`frameworkcode`,`tagfield`,`tagsubfield`),
  KEY `kohafield_2` (`kohafield`),
  KEY `tab` (`frameworkcode`,`tab`),
  KEY `kohafield` (`frameworkcode`,`kohafield`),
  KEY `marc_subfield_structure_ibfk_1` (`authorised_value`),
  CONSTRAINT `marc_subfield_structure_ibfk_1` FOREIGN KEY (`authorised_value`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marc_tag_structure`
--

DROP TABLE IF EXISTS `marc_tag_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_tag_structure` (
  `tagfield` varchar(3) NOT NULL DEFAULT '',
  `liblibrarian` varchar(255) NOT NULL DEFAULT '',
  `libopac` varchar(255) NOT NULL DEFAULT '',
  `repeatable` tinyint(4) NOT NULL DEFAULT 0,
  `mandatory` tinyint(4) NOT NULL DEFAULT 0,
  `important` tinyint(4) NOT NULL DEFAULT 0,
  `authorised_value` varchar(32) DEFAULT NULL,
  `ind1_defaultvalue` varchar(1) NOT NULL DEFAULT '',
  `ind2_defaultvalue` varchar(1) NOT NULL DEFAULT '',
  `frameworkcode` varchar(4) NOT NULL DEFAULT '',
  PRIMARY KEY (`frameworkcode`,`tagfield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `matchchecks`
--

DROP TABLE IF EXISTS `matchchecks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matchchecks` (
  `matcher_id` int(11) NOT NULL,
  `matchcheck_id` int(11) NOT NULL AUTO_INCREMENT,
  `source_matchpoint_id` int(11) NOT NULL,
  `target_matchpoint_id` int(11) NOT NULL,
  PRIMARY KEY (`matchcheck_id`),
  KEY `matcher_matchchecks_ifbk_1` (`matcher_id`),
  KEY `matcher_matchchecks_ifbk_2` (`source_matchpoint_id`),
  KEY `matcher_matchchecks_ifbk_3` (`target_matchpoint_id`),
  CONSTRAINT `matcher_matchchecks_ifbk_1` FOREIGN KEY (`matcher_id`) REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchchecks_ifbk_2` FOREIGN KEY (`source_matchpoint_id`) REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchchecks_ifbk_3` FOREIGN KEY (`target_matchpoint_id`) REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `matcher_matchpoints`
--

DROP TABLE IF EXISTS `matcher_matchpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matcher_matchpoints` (
  `matcher_id` int(11) NOT NULL,
  `matchpoint_id` int(11) NOT NULL,
  KEY `matcher_matchpoints_ifbk_1` (`matcher_id`),
  KEY `matcher_matchpoints_ifbk_2` (`matchpoint_id`),
  CONSTRAINT `matcher_matchpoints_ifbk_1` FOREIGN KEY (`matcher_id`) REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchpoints_ifbk_2` FOREIGN KEY (`matchpoint_id`) REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `matchpoint_component_norms`
--

DROP TABLE IF EXISTS `matchpoint_component_norms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matchpoint_component_norms` (
  `matchpoint_component_id` int(11) NOT NULL,
  `sequence` int(11) NOT NULL DEFAULT 0,
  `norm_routine` varchar(50) NOT NULL DEFAULT '',
  KEY `matchpoint_component_norms` (`matchpoint_component_id`,`sequence`),
  CONSTRAINT `matchpoint_component_norms_ifbk_1` FOREIGN KEY (`matchpoint_component_id`) REFERENCES `matchpoint_components` (`matchpoint_component_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `matchpoint_components`
--

DROP TABLE IF EXISTS `matchpoint_components`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matchpoint_components` (
  `matchpoint_id` int(11) NOT NULL,
  `matchpoint_component_id` int(11) NOT NULL AUTO_INCREMENT,
  `sequence` int(11) NOT NULL DEFAULT 0,
  `tag` varchar(3) NOT NULL DEFAULT '',
  `subfields` varchar(40) NOT NULL DEFAULT '',
  `offset` int(4) NOT NULL DEFAULT 0,
  `length` int(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`matchpoint_component_id`),
  KEY `by_sequence` (`matchpoint_id`,`sequence`),
  CONSTRAINT `matchpoint_components_ifbk_1` FOREIGN KEY (`matchpoint_id`) REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `matchpoints`
--

DROP TABLE IF EXISTS `matchpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matchpoints` (
  `matcher_id` int(11) NOT NULL,
  `matchpoint_id` int(11) NOT NULL AUTO_INCREMENT,
  `search_index` varchar(30) NOT NULL DEFAULT '',
  `score` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`matchpoint_id`),
  KEY `matchpoints_ifbk_1` (`matcher_id`),
  CONSTRAINT `matchpoints_ifbk_1` FOREIGN KEY (`matcher_id`) REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `message_attributes`
--

DROP TABLE IF EXISTS `message_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_attributes` (
  `message_attribute_id` int(11) NOT NULL AUTO_INCREMENT,
  `message_name` varchar(40) NOT NULL DEFAULT '',
  `takes_days` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`message_attribute_id`),
  UNIQUE KEY `message_name` (`message_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `message_queue`
--

DROP TABLE IF EXISTS `message_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_queue` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `letter_id` int(11) DEFAULT NULL COMMENT 'Foreign key to the letters table',
  `borrowernumber` int(11) DEFAULT NULL,
  `subject` mediumtext DEFAULT NULL,
  `content` mediumtext DEFAULT NULL,
  `metadata` mediumtext DEFAULT NULL,
  `letter_code` varchar(64) DEFAULT NULL,
  `message_transport_type` varchar(20) NOT NULL,
  `status` enum('sent','pending','failed','deleted') NOT NULL DEFAULT 'pending',
  `time_queued` timestamp NULL DEFAULT NULL,
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `to_address` longtext DEFAULT NULL,
  `from_address` longtext DEFAULT NULL,
  `reply_address` longtext DEFAULT NULL,
  `content_type` mediumtext DEFAULT NULL,
  `failure_code` mediumtext DEFAULT NULL,
  PRIMARY KEY (`message_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `message_transport_type` (`message_transport_type`),
  KEY `letter_fk` (`letter_id`),
  CONSTRAINT `letter_fk` FOREIGN KEY (`letter_id`) REFERENCES `letter` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `messageq_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `messageq_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `message_transport_types`
--

DROP TABLE IF EXISTS `message_transport_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_transport_types` (
  `message_transport_type` varchar(20) NOT NULL,
  PRIMARY KEY (`message_transport_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `message_transports`
--

DROP TABLE IF EXISTS `message_transports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_transports` (
  `message_attribute_id` int(11) NOT NULL,
  `message_transport_type` varchar(20) NOT NULL,
  `is_digest` tinyint(1) NOT NULL DEFAULT 0,
  `letter_module` varchar(20) NOT NULL DEFAULT '',
  `letter_code` varchar(20) NOT NULL DEFAULT '',
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`message_attribute_id`,`message_transport_type`,`is_digest`),
  KEY `message_transport_type` (`message_transport_type`),
  KEY `letter_module` (`letter_module`,`letter_code`),
  CONSTRAINT `message_transports_ibfk_1` FOREIGN KEY (`message_attribute_id`) REFERENCES `message_attributes` (`message_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_transports_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
  `borrowernumber` int(11) NOT NULL COMMENT 'foreign key linking this message to the borrowers table',
  `branchcode` varchar(10) DEFAULT NULL COMMENT 'foreign key linking the message to the branches table',
  `message_type` varchar(1) NOT NULL COMMENT 'whether the message is for the librarians (L) or the patron (B)',
  `message` mediumtext NOT NULL COMMENT 'the text of the message',
  `message_date` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'the date and time the message was written',
  `manager_id` int(11) DEFAULT NULL COMMENT 'creator of message',
  `patron_read_date` timestamp NULL DEFAULT NULL COMMENT 'the date and time the patron dismissed the message',
  PRIMARY KEY (`message_id`),
  KEY `messages_ibfk_1` (`manager_id`),
  KEY `messages_borrowernumber` (`borrowernumber`),
  CONSTRAINT `messages_borrowernumber` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `misc_files`
--

DROP TABLE IF EXISTS `misc_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `misc_files` (
  `file_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id for the file record',
  `table_tag` varchar(255) NOT NULL COMMENT 'usually table name, or arbitrary unique tag',
  `record_id` int(11) NOT NULL COMMENT 'record id from the table this file is associated to',
  `file_name` varchar(255) NOT NULL COMMENT 'file name',
  `file_type` varchar(255) NOT NULL COMMENT 'MIME type of the file',
  `file_description` varchar(255) DEFAULT NULL COMMENT 'description given to the file',
  `file_content` longblob NOT NULL COMMENT 'file content',
  `date_uploaded` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date and time the file was added',
  PRIMARY KEY (`file_id`),
  KEY `table_tag` (`table_tag`(191)),
  KEY `record_id` (`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `need_merge_authorities`
--

DROP TABLE IF EXISTS `need_merge_authorities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `need_merge_authorities` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `authid` bigint(20) NOT NULL COMMENT 'reference to original authority record',
  `authid_new` bigint(20) DEFAULT NULL COMMENT 'reference to optional new authority record',
  `reportxml` mediumtext DEFAULT NULL COMMENT 'xml showing original reporting tag',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time last modified',
  `done` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oai_sets`
--

DROP TABLE IF EXISTS `oai_sets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oai_sets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `spec` varchar(80) NOT NULL,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `spec` (`spec`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oai_sets_biblios`
--

DROP TABLE IF EXISTS `oai_sets_biblios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oai_sets_biblios` (
  `biblionumber` int(11) NOT NULL,
  `set_id` int(11) NOT NULL,
  PRIMARY KEY (`biblionumber`,`set_id`),
  KEY `oai_sets_biblios_ibfk_2` (`set_id`),
  CONSTRAINT `oai_sets_biblios_ibfk_2` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oai_sets_descriptions`
--

DROP TABLE IF EXISTS `oai_sets_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oai_sets_descriptions` (
  `set_id` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  KEY `oai_sets_descriptions_ibfk_1` (`set_id`),
  CONSTRAINT `oai_sets_descriptions_ibfk_1` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oai_sets_mappings`
--

DROP TABLE IF EXISTS `oai_sets_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oai_sets_mappings` (
  `set_id` int(11) NOT NULL,
  `rule_order` int(11) DEFAULT NULL,
  `rule_operator` varchar(3) DEFAULT NULL,
  `marcfield` char(3) NOT NULL,
  `marcsubfield` char(1) NOT NULL,
  `operator` varchar(8) NOT NULL DEFAULT 'equal',
  `marcvalue` varchar(80) NOT NULL,
  KEY `oai_sets_mappings_ibfk_1` (`set_id`),
  CONSTRAINT `oai_sets_mappings_ibfk_1` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oauth_access_tokens`
--

DROP TABLE IF EXISTS `oauth_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_access_tokens` (
  `access_token` varchar(191) NOT NULL COMMENT 'generarated access token',
  `client_id` varchar(191) NOT NULL COMMENT 'the client id the access token belongs to',
  `expires` int(11) NOT NULL COMMENT 'expiration time in seconds',
  PRIMARY KEY (`access_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `old_issues`
--

DROP TABLE IF EXISTS `old_issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `old_issues` (
  `issue_id` int(11) NOT NULL COMMENT 'primary key for issues table',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'foreign key, linking this to the borrowers table for the patron this item was checked out to',
  `issuer_id` int(11) DEFAULT NULL COMMENT 'foreign key, linking this to the borrowers table for the user who checked out this item',
  `itemnumber` int(11) DEFAULT NULL COMMENT 'foreign key, linking this to the items table for the item that was checked out',
  `date_due` datetime DEFAULT NULL COMMENT 'date the item is due (yyyy-mm-dd)',
  `branchcode` varchar(10) DEFAULT NULL COMMENT 'foreign key, linking to the branches table for the location the item was checked out',
  `returndate` datetime DEFAULT NULL COMMENT 'date the item was returned',
  `lastreneweddate` datetime DEFAULT NULL COMMENT 'date the item was last renewed',
  `renewals_count` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'lists the number of times the item was renewed',
  `unseen_renewals` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'lists the number of consecutive times the item was renewed without being seen',
  `auto_renew` tinyint(1) DEFAULT 0 COMMENT 'automatic renewal',
  `auto_renew_error` varchar(32) DEFAULT NULL COMMENT 'automatic renewal error',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'the date and time this record was last touched',
  `issuedate` datetime DEFAULT NULL COMMENT 'date the item was checked out or issued',
  `onsite_checkout` int(1) NOT NULL DEFAULT 0 COMMENT 'in house use flag',
  `note` longtext DEFAULT NULL COMMENT 'issue note text',
  `notedate` datetime DEFAULT NULL COMMENT 'datetime of issue note (yyyy-mm-dd hh:mm::ss)',
  `noteseen` int(1) DEFAULT NULL COMMENT 'describes whether checkout note has been seen 1, not been seen 0 or doesn''t exist null',
  PRIMARY KEY (`issue_id`),
  KEY `old_issuesborridx` (`borrowernumber`),
  KEY `old_issuesitemidx` (`itemnumber`),
  KEY `branchcode_idx` (`branchcode`),
  KEY `old_bordate` (`borrowernumber`,`timestamp`),
  KEY `old_issues_ibfk_borrowers_borrowernumber` (`issuer_id`),
  CONSTRAINT `old_issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_issues_ibfk_borrowers_borrowernumber` FOREIGN KEY (`issuer_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `old_reserves`
--

DROP TABLE IF EXISTS `old_reserves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `old_reserves` (
  `reserve_id` int(11) NOT NULL COMMENT 'primary key',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'foreign key from the borrowers table defining which patron this hold is for',
  `reservedate` date DEFAULT NULL COMMENT 'the date the hold was places',
  `biblionumber` int(11) DEFAULT NULL COMMENT 'foreign key from the biblio table defining which bib record this hold is on',
  `item_group_id` int(11) DEFAULT NULL COMMENT 'foreign key from the item_groups table defining if this is an item group level hold',
  `branchcode` varchar(10) DEFAULT NULL COMMENT 'foreign key from the branches table defining which branch the patron wishes to pick this hold up at',
  `desk_id` int(11) DEFAULT NULL COMMENT 'foreign key from the desks table defining which desk the patron should pick this hold up at',
  `notificationdate` date DEFAULT NULL COMMENT 'currently unused',
  `reminderdate` date DEFAULT NULL COMMENT 'currently unused',
  `cancellationdate` date DEFAULT NULL COMMENT 'the date this hold was cancelled',
  `cancellation_reason` varchar(80) DEFAULT NULL COMMENT 'optional authorised value CANCELLATION_REASON',
  `reservenotes` longtext DEFAULT NULL COMMENT 'notes related to this hold',
  `priority` smallint(6) NOT NULL DEFAULT 1 COMMENT 'where in the queue the patron sits',
  `found` varchar(1) DEFAULT NULL COMMENT 'a one letter code defining what the status is of the hold is after it has been confirmed',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'the date and time this hold was last updated',
  `itemnumber` int(11) DEFAULT NULL COMMENT 'foreign key from the items table defining the specific item the patron has placed on hold or the item this hold was filled with',
  `waitingdate` date DEFAULT NULL COMMENT 'the date the item was marked as waiting for the patron at the library',
  `expirationdate` date DEFAULT NULL COMMENT 'the date the hold expires (usually the date entered by the patron to say they don''t need the hold after a certain date)',
  `patron_expiration_date` date DEFAULT NULL COMMENT 'the date the hold expires - usually the date entered by the patron to say they don''t need the hold after a certain date',
  `lowestPriority` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'has this hold been pinned to the lowest priority in the holds queue (1 for yes, 0 for no)',
  `suspend` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'in this hold suspended (1 for yes, 0 for no)',
  `suspend_until` datetime DEFAULT NULL COMMENT 'the date this hold is suspended until (NULL for infinitely)',
  `itemtype` varchar(10) DEFAULT NULL COMMENT 'If record level hold, the optional itemtype of the item the patron is requesting',
  `item_level_hold` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Is the hold placed at item level',
  `non_priority` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Is this a non priority hold',
  PRIMARY KEY (`reserve_id`),
  KEY `old_reserves_borrowernumber` (`borrowernumber`),
  KEY `old_reserves_biblionumber` (`biblionumber`),
  KEY `old_reserves_itemnumber` (`itemnumber`),
  KEY `old_reserves_branchcode` (`branchcode`),
  KEY `old_reserves_itemtype` (`itemtype`),
  KEY `old_reserves_ibfk_ig` (`item_group_id`),
  CONSTRAINT `old_reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_4` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_ig` FOREIGN KEY (`item_group_id`) REFERENCES `item_groups` (`item_group_id`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `overduerules`
--

DROP TABLE IF EXISTS `overduerules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `overduerules` (
  `overduerules_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for the overduerules',
  `branchcode` varchar(10) NOT NULL DEFAULT '' COMMENT 'foreign key from the branches table to define which branch this rule is for (if blank it''s all libraries)',
  `categorycode` varchar(10) NOT NULL DEFAULT '' COMMENT 'foreign key from the categories table to define which patron category this rule is for',
  `delay1` int(4) DEFAULT NULL COMMENT 'number of days after the item is overdue that the first notice is sent',
  `letter1` varchar(20) DEFAULT NULL COMMENT 'foreign key from the letter table to define which notice should be sent as the first notice',
  `debarred1` varchar(1) DEFAULT '0' COMMENT 'is the patron restricted when the first notice is sent (1 for yes, 0 for no)',
  `delay2` int(4) DEFAULT NULL COMMENT 'number of days after the item is overdue that the second notice is sent',
  `debarred2` varchar(1) DEFAULT '0' COMMENT 'is the patron restricted when the second notice is sent (1 for yes, 0 for no)',
  `letter2` varchar(20) DEFAULT NULL COMMENT 'foreign key from the letter table to define which notice should be sent as the second notice',
  `delay3` int(4) DEFAULT NULL COMMENT 'number of days after the item is overdue that the third notice is sent',
  `letter3` varchar(20) DEFAULT NULL COMMENT 'foreign key from the letter table to define which notice should be sent as the third notice',
  `debarred3` int(1) DEFAULT 0 COMMENT 'is the patron restricted when the third notice is sent (1 for yes, 0 for no)',
  PRIMARY KEY (`overduerules_id`),
  UNIQUE KEY `overduerules_branch_cat` (`branchcode`,`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `overduerules_transport_types`
--

DROP TABLE IF EXISTS `overduerules_transport_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `overduerules_transport_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `letternumber` int(1) NOT NULL DEFAULT 1,
  `message_transport_type` varchar(20) NOT NULL DEFAULT 'email',
  `overduerules_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `overduerules_fk` (`overduerules_id`),
  KEY `mtt_fk` (`message_transport_type`),
  CONSTRAINT `mtt_fk` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `overduerules_fk` FOREIGN KEY (`overduerules_id`) REFERENCES `overduerules` (`overduerules_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patron_consent`
--

DROP TABLE IF EXISTS `patron_consent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patron_consent` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL,
  `type` enum('GDPR_PROCESSING') DEFAULT NULL COMMENT 'allows for future extension',
  `given_on` datetime DEFAULT NULL,
  `refused_on` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT `patron_consent_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patron_list_patrons`
--

DROP TABLE IF EXISTS `patron_list_patrons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patron_list_patrons` (
  `patron_list_patron_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `patron_list_id` int(11) NOT NULL COMMENT 'the list this entry is part of',
  `borrowernumber` int(11) NOT NULL COMMENT 'the borrower that is part of this list',
  PRIMARY KEY (`patron_list_patron_id`),
  KEY `patron_list_id` (`patron_list_id`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT `patron_list_patrons_ibfk_1` FOREIGN KEY (`patron_list_id`) REFERENCES `patron_lists` (`patron_list_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `patron_list_patrons_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patron_lists`
--

DROP TABLE IF EXISTS `patron_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patron_lists` (
  `patron_list_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'the list''s name',
  `owner` int(11) NOT NULL COMMENT 'borrowernumber of the list creator',
  `shared` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`patron_list_id`),
  KEY `owner` (`owner`),
  CONSTRAINT `patron_lists_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patronimage`
--

DROP TABLE IF EXISTS `patronimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patronimage` (
  `borrowernumber` int(11) NOT NULL COMMENT 'the borrowernumber of the patron this image is attached to (borrowers.borrowernumber)',
  `mimetype` varchar(15) NOT NULL COMMENT 'the format of the image (png, jpg, etc)',
  `imagefile` mediumblob NOT NULL COMMENT 'the image',
  PRIMARY KEY (`borrowernumber`),
  CONSTRAINT `patronimage_fk1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pending_offline_operations`
--

DROP TABLE IF EXISTS `pending_offline_operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pending_offline_operations` (
  `operationid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` varchar(30) NOT NULL,
  `branchcode` varchar(10) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `action` varchar(10) NOT NULL,
  `barcode` varchar(20) DEFAULT NULL,
  `cardnumber` varchar(32) DEFAULT NULL,
  `amount` decimal(28,6) DEFAULT NULL,
  PRIMARY KEY (`operationid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `module_bit` int(11) NOT NULL DEFAULT 0,
  `code` varchar(64) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`module_bit`,`code`),
  CONSTRAINT `permissions_ibfk_1` FOREIGN KEY (`module_bit`) REFERENCES `userflags` (`bit`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_data`
--

DROP TABLE IF EXISTS `plugin_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plugin_data` (
  `plugin_class` varchar(255) NOT NULL,
  `plugin_key` varchar(255) NOT NULL,
  `plugin_value` mediumtext DEFAULT NULL,
  PRIMARY KEY (`plugin_class`(191),`plugin_key`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_methods`
--

DROP TABLE IF EXISTS `plugin_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plugin_methods` (
  `plugin_class` varchar(255) NOT NULL,
  `plugin_method` varchar(255) NOT NULL,
  PRIMARY KEY (`plugin_class`(191),`plugin_method`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `printers_profile`
--

DROP TABLE IF EXISTS `printers_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `printers_profile` (
  `profile_id` int(4) NOT NULL AUTO_INCREMENT,
  `printer_name` varchar(40) NOT NULL DEFAULT 'Default Printer',
  `template_id` int(4) NOT NULL DEFAULT 0,
  `paper_bin` varchar(20) NOT NULL DEFAULT 'Bypass',
  `offset_horz` float NOT NULL DEFAULT 0,
  `offset_vert` float NOT NULL DEFAULT 0,
  `creep_horz` float NOT NULL DEFAULT 0,
  `creep_vert` float NOT NULL DEFAULT 0,
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`profile_id`),
  UNIQUE KEY `printername` (`printer_name`,`template_id`,`paper_bin`,`creator`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `problem_reports`
--

DROP TABLE IF EXISTS `problem_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `problem_reports` (
  `reportid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
  `title` varchar(40) NOT NULL DEFAULT '' COMMENT 'report subject line',
  `content` text NOT NULL COMMENT 'report message content',
  `borrowernumber` int(11) NOT NULL DEFAULT 0 COMMENT 'the user who created the problem report',
  `branchcode` varchar(10) NOT NULL DEFAULT '' COMMENT 'borrower''s branch',
  `username` varchar(75) DEFAULT NULL COMMENT 'OPAC username',
  `problempage` text DEFAULT NULL COMMENT 'page the user triggered the problem report form from',
  `recipient` enum('admin','library') NOT NULL DEFAULT 'library' COMMENT 'the ''to-address'' of the problem report',
  `created_on` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'timestamp of report submission',
  `status` varchar(6) NOT NULL DEFAULT 'New' COMMENT 'status of the report. New, Viewed, Closed',
  PRIMARY KEY (`reportid`),
  KEY `problem_reports_ibfk1` (`borrowernumber`),
  KEY `problem_reports_ibfk2` (`branchcode`),
  CONSTRAINT `problem_reports_ibfk1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `problem_reports_ibfk2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pseudonymized_borrower_attributes`
--

DROP TABLE IF EXISTS `pseudonymized_borrower_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pseudonymized_borrower_attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Row id field',
  `transaction_id` int(11) NOT NULL,
  `code` varchar(10) NOT NULL COMMENT 'foreign key from the borrower_attribute_types table, defines which custom field this value was entered for',
  `attribute` varchar(255) DEFAULT NULL COMMENT 'custom patron field value',
  PRIMARY KEY (`id`),
  KEY `pseudonymized_borrower_attributes_ibfk_1` (`transaction_id`),
  KEY `anonymized_borrower_attributes_ibfk_2` (`code`),
  CONSTRAINT `anonymized_borrower_attributes_ibfk_2` FOREIGN KEY (`code`) REFERENCES `borrower_attribute_types` (`code`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `pseudonymized_borrower_attributes_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `pseudonymized_transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pseudonymized_transactions`
--

DROP TABLE IF EXISTS `pseudonymized_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pseudonymized_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hashed_borrowernumber` varchar(60) NOT NULL,
  `has_cardnumber` tinyint(1) NOT NULL DEFAULT 0,
  `title` longtext DEFAULT NULL,
  `city` longtext DEFAULT NULL,
  `state` mediumtext DEFAULT NULL,
  `zipcode` varchar(25) DEFAULT NULL,
  `country` mediumtext DEFAULT NULL,
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `categorycode` varchar(10) NOT NULL DEFAULT '',
  `dateenrolled` date DEFAULT NULL,
  `sex` varchar(1) DEFAULT NULL,
  `sort1` varchar(80) DEFAULT NULL,
  `sort2` varchar(80) DEFAULT NULL,
  `datetime` datetime DEFAULT NULL,
  `transaction_branchcode` varchar(10) DEFAULT NULL,
  `transaction_type` varchar(16) DEFAULT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `itemtype` varchar(10) DEFAULT NULL,
  `holdingbranch` varchar(10) DEFAULT NULL,
  `homebranch` varchar(10) DEFAULT NULL,
  `location` varchar(80) DEFAULT NULL,
  `itemcallnumber` varchar(255) DEFAULT NULL,
  `ccode` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pseudonymized_transactions_ibfk_1` (`categorycode`),
  KEY `pseudonymized_transactions_borrowers_ibfk_2` (`branchcode`),
  KEY `pseudonymized_transactions_borrowers_ibfk_3` (`transaction_branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quotes`
--

DROP TABLE IF EXISTS `quotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quotes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id for the quote',
  `source` mediumtext DEFAULT NULL COMMENT 'source/credit for the quote',
  `text` longtext NOT NULL COMMENT 'text of the quote',
  `timestamp` datetime DEFAULT NULL COMMENT 'date and time that the quote last appeared in the opac',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ratings`
--

DROP TABLE IF EXISTS `ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ratings` (
  `borrowernumber` int(11) NOT NULL COMMENT 'the borrowernumber of the patron who left this rating (borrowers.borrowernumber)',
  `biblionumber` int(11) NOT NULL COMMENT 'the biblio this rating is for (biblio.biblionumber)',
  `rating_value` tinyint(1) NOT NULL COMMENT 'the rating, from 1 to 5',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`borrowernumber`,`biblionumber`),
  KEY `ratings_ibfk_2` (`biblionumber`),
  CONSTRAINT `ratings_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ratings_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recalls`
--

DROP TABLE IF EXISTS `recalls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recalls` (
  `recall_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for this recall',
  `patron_id` int(11) NOT NULL DEFAULT 0 COMMENT 'Identifier for patron who requested recall',
  `created_date` datetime DEFAULT NULL COMMENT 'Date the recall was requested',
  `biblio_id` int(11) NOT NULL COMMENT 'Identifier for bibliographic record that has been recalled',
  `pickup_library_id` varchar(10) DEFAULT NULL COMMENT 'Identifier for recall pickup library',
  `completed_date` datetime DEFAULT NULL COMMENT 'Date the recall is completed (fulfilled, cancelled or expired)',
  `notes` mediumtext DEFAULT NULL COMMENT 'Notes related to the recall',
  `priority` smallint(6) DEFAULT NULL COMMENT 'Where in the queue the patron sits',
  `status` enum('requested','overdue','waiting','in_transit','cancelled','expired','fulfilled') DEFAULT 'requested' COMMENT 'Status of recall',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Date and time the recall was last updated',
  `item_id` int(11) DEFAULT NULL COMMENT 'Identifier for item record that was recalled, if an item-level recall',
  `waiting_date` datetime DEFAULT NULL COMMENT 'Date an item was marked as waiting for the patron at the library',
  `expiration_date` datetime DEFAULT NULL COMMENT 'Date recall is no longer required, or date recall will expire after waiting on shelf for pickup',
  `completed` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Flag if recall is old and no longer active, i.e. expired, cancelled or completed',
  `item_level` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Flag if recall is for a specific item',
  PRIMARY KEY (`recall_id`),
  KEY `recalls_ibfk_1` (`patron_id`),
  KEY `recalls_ibfk_2` (`biblio_id`),
  KEY `recalls_ibfk_3` (`item_id`),
  KEY `recalls_ibfk_4` (`pickup_library_id`),
  CONSTRAINT `recalls_ibfk_1` FOREIGN KEY (`patron_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recalls_ibfk_2` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recalls_ibfk_3` FOREIGN KEY (`item_id`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recalls_ibfk_4` FOREIGN KEY (`pickup_library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Information related to recalls in Koha';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `repeatable_holidays`
--

DROP TABLE IF EXISTS `repeatable_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `repeatable_holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
  `branchcode` varchar(10) NOT NULL COMMENT 'foreign key from the branches table, defines which branch this closing is for',
  `weekday` smallint(6) DEFAULT NULL COMMENT 'day of the week (0=Sunday, 1=Monday, etc) this closing is repeated on',
  `day` smallint(6) DEFAULT NULL COMMENT 'day of the month this closing is on',
  `month` smallint(6) DEFAULT NULL COMMENT 'month this closing is in',
  `title` varchar(50) NOT NULL DEFAULT '' COMMENT 'title of this closing',
  `description` mediumtext NOT NULL COMMENT 'description for this closing',
  PRIMARY KEY (`id`),
  KEY `repeatable_holidays_ibfk_1` (`branchcode`),
  CONSTRAINT `repeatable_holidays_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reports_dictionary`
--

DROP TABLE IF EXISTS `reports_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_dictionary` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
  `name` varchar(255) DEFAULT NULL COMMENT 'name for this definition',
  `description` mediumtext DEFAULT NULL COMMENT 'description for this definition',
  `date_created` datetime DEFAULT NULL COMMENT 'date and time this definition was created',
  `date_modified` datetime DEFAULT NULL COMMENT 'date and time this definition was last modified',
  `saved_sql` mediumtext DEFAULT NULL COMMENT 'SQL snippet for us in reports',
  `report_area` varchar(6) DEFAULT NULL COMMENT 'Koha module this definition is for Circulation, Catalog, Patrons, Acquistions, Accounts)',
  PRIMARY KEY (`id`),
  KEY `dictionary_area_idx` (`report_area`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reserves`
--

DROP TABLE IF EXISTS `reserves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reserves` (
  `reserve_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `borrowernumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key from the borrowers table defining which patron this hold is for',
  `reservedate` date DEFAULT NULL COMMENT 'the date the hold was placed',
  `biblionumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key from the biblio table defining which bib record this hold is on',
  `item_group_id` int(11) DEFAULT NULL COMMENT 'foreign key from the item_groups table defining if this is an item group level hold',
  `branchcode` varchar(10) NOT NULL COMMENT 'foreign key from the branches table defining which branch the patron wishes to pick this hold up at',
  `desk_id` int(11) DEFAULT NULL COMMENT 'foreign key from the desks table defining which desk the patron should pick this hold up at',
  `notificationdate` date DEFAULT NULL COMMENT 'currently unused',
  `reminderdate` date DEFAULT NULL COMMENT 'currently unused',
  `cancellationdate` date DEFAULT NULL COMMENT 'the date this hold was cancelled',
  `cancellation_reason` varchar(80) DEFAULT NULL COMMENT 'optional authorised value CANCELLATION_REASON',
  `reservenotes` longtext DEFAULT NULL COMMENT 'notes related to this hold',
  `priority` smallint(6) NOT NULL DEFAULT 1 COMMENT 'where in the queue the patron sits',
  `found` varchar(1) DEFAULT NULL COMMENT 'a one letter code defining what the status is of the hold is after it has been confirmed',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'the date and time this hold was last updated',
  `itemnumber` int(11) DEFAULT NULL COMMENT 'foreign key from the items table defining the specific item the patron has placed on hold or the item this hold was filled with',
  `waitingdate` date DEFAULT NULL COMMENT 'the date the item was marked as waiting for the patron at the library',
  `expirationdate` date DEFAULT NULL COMMENT 'the date the hold expires (calculated value)',
  `patron_expiration_date` date DEFAULT NULL COMMENT 'the date the hold expires - usually the date entered by the patron to say they don''t need the hold after a certain date',
  `lowestPriority` tinyint(1) NOT NULL DEFAULT 0,
  `suspend` tinyint(1) NOT NULL DEFAULT 0,
  `suspend_until` datetime DEFAULT NULL,
  `itemtype` varchar(10) DEFAULT NULL COMMENT 'If record level hold, the optional itemtype of the item the patron is requesting',
  `item_level_hold` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Is the hold placed at item level',
  `non_priority` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Is this a non priority hold',
  PRIMARY KEY (`reserve_id`),
  KEY `priorityfoundidx` (`priority`,`found`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  KEY `desk_id` (`desk_id`),
  KEY `itemtype` (`itemtype`),
  KEY `reserves_ibfk_ig` (`item_group_id`),
  CONSTRAINT `reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_5` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_6` FOREIGN KEY (`desk_id`) REFERENCES `desks` (`desk_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_ig` FOREIGN KEY (`item_group_id`) REFERENCES `item_groups` (`item_group_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restriction_types`
--

DROP TABLE IF EXISTS `restriction_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `restriction_types` (
  `code` varchar(50) NOT NULL,
  `display_text` text NOT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `return_claims`
--

DROP TABLE IF EXISTS `return_claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `return_claims` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID of the return claim',
  `itemnumber` int(11) NOT NULL COMMENT 'ID of the item',
  `issue_id` int(11) DEFAULT NULL COMMENT 'ID of the checkout that triggered the claim',
  `borrowernumber` int(11) NOT NULL COMMENT 'ID of the patron',
  `notes` mediumtext DEFAULT NULL COMMENT 'Notes about the claim',
  `created_on` timestamp NULL DEFAULT NULL COMMENT 'Time and date the claim was created',
  `created_by` int(11) DEFAULT NULL COMMENT 'ID of the staff member that registered the claim',
  `updated_on` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp() COMMENT 'Time and date of the latest change on the claim (notes)',
  `updated_by` int(11) DEFAULT NULL COMMENT 'ID of the staff member that updated the claim',
  `resolution` varchar(80) DEFAULT NULL COMMENT 'Resolution code (RETURN_CLAIM_RESOLUTION AVs)',
  `resolved_on` timestamp NULL DEFAULT NULL COMMENT 'Time and date the claim was resolved',
  `resolved_by` int(11) DEFAULT NULL COMMENT 'ID of the staff member that resolved the claim',
  PRIMARY KEY (`id`),
  UNIQUE KEY `item_issue` (`itemnumber`,`issue_id`),
  KEY `itemnumber` (`itemnumber`),
  KEY `rc_borrowers_ibfk` (`borrowernumber`),
  KEY `rc_created_by_ibfk` (`created_by`),
  KEY `rc_updated_by_ibfk` (`updated_by`),
  KEY `rc_resolved_by_ibfk` (`resolved_by`),
  CONSTRAINT `rc_borrowers_ibfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `rc_created_by_ibfk` FOREIGN KEY (`created_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `rc_items_ibfk` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `rc_resolved_by_ibfk` FOREIGN KEY (`resolved_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `rc_updated_by_ibfk` FOREIGN KEY (`updated_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reviews` (
  `reviewid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for this comment',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'foreign key from the borrowers table defining which patron left this comment',
  `biblionumber` int(11) DEFAULT NULL COMMENT 'foreign key from the biblio table defining which bibliographic record this comment is for',
  `review` mediumtext DEFAULT NULL COMMENT 'the body of the comment',
  `approved` tinyint(4) DEFAULT 0 COMMENT 'whether this comment has been approved by a librarian (1 for yes, 0 for no)',
  `datereviewed` datetime DEFAULT NULL COMMENT 'the date the comment was left',
  PRIMARY KEY (`reviewid`),
  KEY `reviews_ibfk_1` (`borrowernumber`),
  KEY `reviews_ibfk_2` (`biblionumber`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `saved_reports`
--

DROP TABLE IF EXISTS `saved_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saved_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) DEFAULT NULL,
  `report` longtext DEFAULT NULL,
  `date_run` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `saved_sql`
--

DROP TABLE IF EXISTS `saved_sql`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saved_sql` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id and primary key assigned by Koha',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'the staff member who created this report (borrowers.borrowernumber)',
  `date_created` datetime DEFAULT NULL COMMENT 'the date this report was created',
  `last_modified` datetime DEFAULT NULL COMMENT 'the date this report was last edited',
  `savedsql` mediumtext DEFAULT NULL COMMENT 'the SQL for this report',
  `last_run` datetime DEFAULT NULL,
  `report_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'the name of this report',
  `type` varchar(255) DEFAULT NULL COMMENT 'always 1 for tabular',
  `notes` mediumtext DEFAULT NULL COMMENT 'the notes or description given to this report',
  `cache_expiry` int(11) NOT NULL DEFAULT 300,
  `public` tinyint(1) NOT NULL DEFAULT 0,
  `report_area` varchar(6) DEFAULT NULL,
  `report_group` varchar(80) DEFAULT NULL,
  `report_subgroup` varchar(80) DEFAULT NULL,
  `mana_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sql_area_group_idx` (`report_group`,`report_subgroup`),
  KEY `boridx` (`borrowernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `search_field`
--

DROP TABLE IF EXISTS `search_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'the name of the field as it will be stored in the search engine',
  `label` varchar(255) NOT NULL COMMENT 'the human readable name of the field, for display',
  `type` enum('','string','date','number','boolean','sum','isbn','stdno','year','callnumber') NOT NULL COMMENT 'what type of data this holds, relevant when storing it in the search engine',
  `weight` decimal(5,2) DEFAULT NULL,
  `facet_order` tinyint(4) DEFAULT NULL COMMENT 'the order place of the field in facet list if faceted',
  `staff_client` tinyint(1) NOT NULL DEFAULT 1,
  `opac` tinyint(1) NOT NULL DEFAULT 1,
  `mandatory` tinyint(1) DEFAULT NULL COMMENT 'if marked this field is not editable or removable',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `search_filters`
--

DROP TABLE IF EXISTS `search_filters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_filters` (
  `search_filter_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'filter name',
  `query` mediumtext DEFAULT NULL COMMENT 'filter query part',
  `limits` mediumtext DEFAULT NULL COMMENT 'filter limits part',
  `opac` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'whether this filter is shown on OPAC',
  `staff_client` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'whether this filter is shown in staff client',
  PRIMARY KEY (`search_filter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `search_history`
--

DROP TABLE IF EXISTS `search_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'search history id',
  `userid` int(11) NOT NULL COMMENT 'the patron who performed the search (borrowers.borrowernumber)',
  `sessionid` varchar(32) NOT NULL COMMENT 'a system generated session id',
  `query_desc` varchar(255) NOT NULL COMMENT 'the search that was performed',
  `query_cgi` mediumtext NOT NULL COMMENT 'the string to append to the search url to rerun the search',
  `type` varchar(16) NOT NULL DEFAULT 'biblio' COMMENT 'search type, must be ''biblio'' or ''authority''',
  `total` int(11) NOT NULL COMMENT 'the total of results found',
  `time` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'the date and time the search was run',
  PRIMARY KEY (`id`),
  KEY `userid` (`userid`),
  KEY `sessionid` (`sessionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Opac search history results';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `search_marc_map`
--

DROP TABLE IF EXISTS `search_marc_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_marc_map` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `index_name` enum('biblios','authorities') NOT NULL COMMENT 'what storage index this map is for',
  `marc_type` enum('marc21','unimarc') NOT NULL COMMENT 'what MARC type this map is for',
  `marc_field` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'the MARC specifier for this field',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_name` (`index_name`,`marc_field`(191),`marc_type`),
  KEY `index_name_2` (`index_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `search_marc_to_field`
--

DROP TABLE IF EXISTS `search_marc_to_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_marc_to_field` (
  `search` tinyint(1) NOT NULL DEFAULT 1,
  `search_marc_map_id` int(11) NOT NULL,
  `search_field_id` int(11) NOT NULL,
  `facet` tinyint(1) DEFAULT 0 COMMENT 'true if a facet field should be generated for this',
  `suggestible` tinyint(1) DEFAULT 0 COMMENT 'true if this field can be used to generate suggestions for browse',
  `sort` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Sort defaults to 1 (Yes) and creates sort fields in the index, 0 (no) will prevent this',
  PRIMARY KEY (`search_marc_map_id`,`search_field_id`),
  KEY `search_field_id` (`search_field_id`),
  CONSTRAINT `search_marc_to_field_ibfk_1` FOREIGN KEY (`search_marc_map_id`) REFERENCES `search_marc_map` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `search_marc_to_field_ibfk_2` FOREIGN KEY (`search_field_id`) REFERENCES `search_field` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `serial`
--

DROP TABLE IF EXISTS `serial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `serial` (
  `serialid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key for the issue',
  `biblionumber` int(11) NOT NULL COMMENT 'foreign key for the biblio.biblionumber that this issue is attached to',
  `subscriptionid` int(11) NOT NULL COMMENT 'foreign key to the subscription.subscriptionid that this issue is part of',
  `serialseq` varchar(100) NOT NULL DEFAULT '' COMMENT 'issue information (volume, number, etc)',
  `serialseq_x` varchar(100) DEFAULT NULL COMMENT 'first part of issue information',
  `serialseq_y` varchar(100) DEFAULT NULL COMMENT 'second part of issue information',
  `serialseq_z` varchar(100) DEFAULT NULL COMMENT 'third part of issue information',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'status code for this issue (see manual for full descriptions)',
  `planneddate` date DEFAULT NULL COMMENT 'date expected',
  `notes` mediumtext DEFAULT NULL COMMENT 'notes',
  `publisheddate` date DEFAULT NULL COMMENT 'date published',
  `publisheddatetext` varchar(100) DEFAULT NULL COMMENT 'date published (descriptive)',
  `claimdate` date DEFAULT NULL COMMENT 'date claimed',
  `claims_count` int(11) DEFAULT 0 COMMENT 'number of claims made related to this issue',
  `routingnotes` mediumtext DEFAULT NULL COMMENT 'notes from the routing list',
  PRIMARY KEY (`serialid`),
  KEY `serial_ibfk_1` (`biblionumber`),
  KEY `serial_ibfk_2` (`subscriptionid`),
  CONSTRAINT `serial_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `serial_ibfk_2` FOREIGN KEY (`subscriptionid`) REFERENCES `subscription` (`subscriptionid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `serialitems`
--

DROP TABLE IF EXISTS `serialitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `serialitems` (
  `itemnumber` int(11) NOT NULL,
  `serialid` int(11) NOT NULL,
  PRIMARY KEY (`itemnumber`),
  KEY `serialitems_sfk_1` (`serialid`),
  CONSTRAINT `serialitems_sfk_1` FOREIGN KEY (`serialid`) REFERENCES `serial` (`serialid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `serialitems_sfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(32) NOT NULL,
  `a_session` longblob NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sms_providers`
--

DROP TABLE IF EXISTS `sms_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `domain` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smtp_servers`
--

DROP TABLE IF EXISTS `smtp_servers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smtp_servers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `host` varchar(80) NOT NULL DEFAULT 'localhost',
  `port` int(11) NOT NULL DEFAULT 25,
  `timeout` int(11) NOT NULL DEFAULT 120,
  `ssl_mode` enum('disabled','ssl','starttls') NOT NULL,
  `user_name` varchar(80) DEFAULT NULL,
  `password` varchar(80) DEFAULT NULL,
  `debug` tinyint(1) NOT NULL DEFAULT 0,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `host_idx` (`host`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `social_data`
--

DROP TABLE IF EXISTS `social_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_data` (
  `isbn` varchar(30) NOT NULL DEFAULT '',
  `num_critics` int(11) DEFAULT NULL,
  `num_critics_pro` int(11) DEFAULT NULL,
  `num_quotations` int(11) DEFAULT NULL,
  `num_videos` int(11) DEFAULT NULL,
  `score_avg` decimal(5,2) DEFAULT NULL,
  `num_scores` int(11) DEFAULT NULL,
  PRIMARY KEY (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `special_holidays`
--

DROP TABLE IF EXISTS `special_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `special_holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
  `branchcode` varchar(10) NOT NULL COMMENT 'foreign key from the branches table, defines which branch this closing is for',
  `day` smallint(6) NOT NULL DEFAULT 0 COMMENT 'day of the month this closing is on',
  `month` smallint(6) NOT NULL DEFAULT 0 COMMENT 'month this closing is in',
  `year` smallint(6) NOT NULL DEFAULT 0 COMMENT 'year this closing is in',
  `isexception` smallint(1) NOT NULL DEFAULT 1 COMMENT 'is this a holiday exception to a repeatable holiday (1 for yes, 0 for no)',
  `title` varchar(50) NOT NULL DEFAULT '' COMMENT 'title for this closing',
  `description` mediumtext NOT NULL COMMENT 'description of this closing',
  PRIMARY KEY (`id`),
  KEY `special_holidays_ibfk_1` (`branchcode`),
  CONSTRAINT `special_holidays_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statistics` (
  `datetime` datetime DEFAULT NULL COMMENT 'date and time of the transaction',
  `branch` varchar(10) DEFAULT NULL COMMENT 'foreign key, branch where the transaction occurred',
  `value` double(16,4) DEFAULT NULL COMMENT 'monetary value associated with the transaction',
  `type` varchar(16) DEFAULT NULL COMMENT 'transaction type (localuse, issue, return, renew, writeoff, payment)',
  `other` longtext DEFAULT NULL COMMENT 'used by SIP',
  `itemnumber` int(11) DEFAULT NULL COMMENT 'foreign key from the items table, links transaction to a specific item',
  `itemtype` varchar(10) DEFAULT NULL COMMENT 'foreign key from the itemtypes table, links transaction to a specific item type',
  `location` varchar(80) DEFAULT NULL COMMENT 'authorized value for the shelving location for this item (MARC21 952$c)',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'foreign key from the borrowers table, links transaction to a specific borrower',
  `ccode` varchar(80) DEFAULT NULL COMMENT 'foreign key from the items table, links transaction to a specific collection code',
  `categorycode` varchar(10) DEFAULT NULL COMMENT 'foreign key from the borrowers table, links transaction to a specific borrower category',
  `interface` varchar(30) DEFAULT NULL COMMENT 'the context this action was taken in',
  KEY `timeidx` (`datetime`),
  KEY `branch_idx` (`branch`),
  KEY `type_idx` (`type`),
  KEY `itemnumber_idx` (`itemnumber`),
  KEY `itemtype_idx` (`itemtype`),
  KEY `borrowernumber_idx` (`borrowernumber`),
  KEY `ccode_idx` (`ccode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stockrotationitems`
--

DROP TABLE IF EXISTS `stockrotationitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stockrotationitems` (
  `itemnumber_id` int(11) NOT NULL COMMENT 'Itemnumber to link to a stage & rota',
  `stage_id` int(11) NOT NULL COMMENT 'stage ID to link the item to',
  `indemand` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Should this item be skipped for rotation?',
  `fresh` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Flag showing item is only just added to rota',
  PRIMARY KEY (`itemnumber_id`),
  KEY `stockrotationitems_sifk` (`stage_id`),
  CONSTRAINT `stockrotationitems_iifk` FOREIGN KEY (`itemnumber_id`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `stockrotationitems_sifk` FOREIGN KEY (`stage_id`) REFERENCES `stockrotationstages` (`stage_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stockrotationrotas`
--

DROP TABLE IF EXISTS `stockrotationrotas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stockrotationrotas` (
  `rota_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Stockrotation rota ID',
  `title` varchar(100) NOT NULL COMMENT 'Title for this rota',
  `description` text NOT NULL COMMENT 'Description for this rota',
  `cyclical` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Should items on this rota keep cycling?',
  `active` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Is this rota currently active?',
  PRIMARY KEY (`rota_id`),
  UNIQUE KEY `stockrotationrotas_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stockrotationstages`
--

DROP TABLE IF EXISTS `stockrotationstages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stockrotationstages` (
  `stage_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique stage ID',
  `position` int(11) NOT NULL COMMENT 'The position of this stage within its rota',
  `rota_id` int(11) NOT NULL COMMENT 'The rota this stage belongs to',
  `branchcode_id` varchar(10) NOT NULL COMMENT 'Branch this stage relates to',
  `duration` int(11) NOT NULL DEFAULT 4 COMMENT 'The number of days items shoud occupy this stage',
  PRIMARY KEY (`stage_id`),
  KEY `stockrotationstages_rifk` (`rota_id`),
  KEY `stockrotationstages_bifk` (`branchcode_id`),
  CONSTRAINT `stockrotationstages_bifk` FOREIGN KEY (`branchcode_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `stockrotationstages_rifk` FOREIGN KEY (`rota_id`) REFERENCES `stockrotationrotas` (`rota_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscription`
--

DROP TABLE IF EXISTS `subscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription` (
  `biblionumber` int(11) NOT NULL COMMENT 'foreign key for biblio.biblionumber that this subscription is attached to',
  `subscriptionid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key for this subscription',
  `librarian` varchar(100) DEFAULT '' COMMENT 'the librarian''s username from borrowers.userid',
  `startdate` date DEFAULT NULL COMMENT 'start date for this subscription',
  `aqbooksellerid` int(11) DEFAULT 0 COMMENT 'foreign key for aqbooksellers.id to link to the vendor',
  `cost` int(11) DEFAULT 0,
  `aqbudgetid` int(11) DEFAULT 0,
  `weeklength` int(11) DEFAULT 0 COMMENT 'subscription length in weeks (will not be filled in if monthlength or numberlength is set)',
  `monthlength` int(11) DEFAULT 0 COMMENT 'subscription length in weeks (will not be filled in if weeklength or numberlength is set)',
  `numberlength` int(11) DEFAULT 0 COMMENT 'subscription length in weeks (will not be filled in if monthlength or weeklength is set)',
  `periodicity` int(11) DEFAULT NULL COMMENT 'frequency type links to subscription_frequencies.id',
  `countissuesperunit` int(11) NOT NULL DEFAULT 1,
  `notes` longtext DEFAULT NULL COMMENT 'notes',
  `status` varchar(100) NOT NULL DEFAULT '' COMMENT 'status of this subscription',
  `lastvalue1` int(11) DEFAULT NULL,
  `innerloop1` int(11) DEFAULT 0,
  `lastvalue2` int(11) DEFAULT NULL,
  `innerloop2` int(11) DEFAULT 0,
  `lastvalue3` int(11) DEFAULT NULL,
  `innerloop3` int(11) DEFAULT 0,
  `firstacquidate` date DEFAULT NULL COMMENT 'first issue received date',
  `manualhistory` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'yes or no to managing the history manually',
  `irregularity` mediumtext DEFAULT NULL COMMENT 'any irregularities in the subscription',
  `skip_serialseq` tinyint(1) NOT NULL DEFAULT 0,
  `letter` varchar(20) DEFAULT NULL,
  `numberpattern` int(11) DEFAULT NULL COMMENT 'the numbering pattern used links to subscription_numberpatterns.id',
  `locale` varchar(80) DEFAULT NULL COMMENT 'for foreign language subscriptions to display months, seasons, etc correctly',
  `distributedto` mediumtext DEFAULT NULL,
  `internalnotes` longtext DEFAULT NULL,
  `callnumber` mediumtext DEFAULT NULL COMMENT 'default call number',
  `location` varchar(80) DEFAULT '' COMMENT 'default shelving location (items.location)',
  `branchcode` varchar(10) NOT NULL DEFAULT '' COMMENT 'default branches (items.homebranch)',
  `lastbranch` varchar(10) DEFAULT NULL,
  `serialsadditems` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'does receiving this serial create an item record',
  `staffdisplaycount` int(11) DEFAULT NULL COMMENT 'how many issues to show to the staff',
  `opacdisplaycount` int(11) DEFAULT NULL COMMENT 'how many issues to show to the public',
  `graceperiod` int(11) NOT NULL DEFAULT 0 COMMENT 'grace period in days',
  `enddate` date DEFAULT NULL COMMENT 'subscription end date',
  `closed` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'yes / no if the subscription is closed',
  `reneweddate` date DEFAULT NULL COMMENT 'date of last renewal for the subscription',
  `itemtype` varchar(10) DEFAULT NULL,
  `previousitemtype` varchar(10) DEFAULT NULL,
  `mana_id` int(11) DEFAULT NULL,
  `ccode` varchar(80) DEFAULT NULL COMMENT 'collection code to assign to serial items',
  PRIMARY KEY (`subscriptionid`),
  KEY `subscription_ibfk_1` (`periodicity`),
  KEY `subscription_ibfk_2` (`numberpattern`),
  KEY `subscription_ibfk_3` (`biblionumber`),
  CONSTRAINT `subscription_ibfk_1` FOREIGN KEY (`periodicity`) REFERENCES `subscription_frequencies` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `subscription_ibfk_2` FOREIGN KEY (`numberpattern`) REFERENCES `subscription_numberpatterns` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `subscription_ibfk_3` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscription_frequencies`
--

DROP TABLE IF EXISTS `subscription_frequencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_frequencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` mediumtext NOT NULL,
  `displayorder` int(11) DEFAULT NULL,
  `unit` enum('day','week','month','year') DEFAULT NULL,
  `unitsperissue` int(11) NOT NULL DEFAULT 1,
  `issuesperunit` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscription_numberpatterns`
--

DROP TABLE IF EXISTS `subscription_numberpatterns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_numberpatterns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) NOT NULL,
  `displayorder` int(11) DEFAULT NULL,
  `description` mediumtext NOT NULL,
  `numberingmethod` varchar(255) NOT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `add1` int(11) DEFAULT NULL,
  `every1` int(11) DEFAULT NULL,
  `whenmorethan1` int(11) DEFAULT NULL,
  `setto1` int(11) DEFAULT NULL,
  `numbering1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `add2` int(11) DEFAULT NULL,
  `every2` int(11) DEFAULT NULL,
  `whenmorethan2` int(11) DEFAULT NULL,
  `setto2` int(11) DEFAULT NULL,
  `numbering2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `add3` int(11) DEFAULT NULL,
  `every3` int(11) DEFAULT NULL,
  `whenmorethan3` int(11) DEFAULT NULL,
  `setto3` int(11) DEFAULT NULL,
  `numbering3` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscriptionhistory`
--

DROP TABLE IF EXISTS `subscriptionhistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptionhistory` (
  `biblionumber` int(11) NOT NULL,
  `subscriptionid` int(11) NOT NULL,
  `histstartdate` date DEFAULT NULL,
  `histenddate` date DEFAULT NULL,
  `missinglist` longtext NOT NULL,
  `recievedlist` longtext NOT NULL,
  `opacnote` longtext DEFAULT NULL,
  `librariannote` longtext DEFAULT NULL,
  PRIMARY KEY (`subscriptionid`),
  KEY `subscription_history_ibfk_1` (`biblionumber`),
  CONSTRAINT `subscription_history_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `subscription_history_ibfk_2` FOREIGN KEY (`subscriptionid`) REFERENCES `subscription` (`subscriptionid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscriptionroutinglist`
--

DROP TABLE IF EXISTS `subscriptionroutinglist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptionroutinglist` (
  `routingid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
  `borrowernumber` int(11) NOT NULL COMMENT 'foreign key from the borrowers table, defines with patron is on the routing list',
  `ranking` int(11) DEFAULT NULL COMMENT 'where the patron stands in line to receive the serial',
  `subscriptionid` int(11) NOT NULL COMMENT 'foreign key from the subscription table, defines which subscription this routing list is for',
  PRIMARY KEY (`routingid`),
  UNIQUE KEY `subscriptionid` (`subscriptionid`,`borrowernumber`),
  KEY `subscriptionroutinglist_ibfk_1` (`borrowernumber`),
  CONSTRAINT `subscriptionroutinglist_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `subscriptionroutinglist_ibfk_2` FOREIGN KEY (`subscriptionid`) REFERENCES `subscription` (`subscriptionid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `suggestions`
--

DROP TABLE IF EXISTS `suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suggestions` (
  `suggestionid` int(8) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned automatically by Koha',
  `suggestedby` int(11) DEFAULT NULL COMMENT 'borrowernumber for the person making the suggestion, foreign key linking to the borrowers table',
  `suggesteddate` date NOT NULL COMMENT 'date the suggestion was submitted',
  `managedby` int(11) DEFAULT NULL COMMENT 'borrowernumber for the librarian managing the suggestion, foreign key linking to the borrowers table',
  `manageddate` date DEFAULT NULL COMMENT 'date the suggestion was updated',
  `acceptedby` int(11) DEFAULT NULL COMMENT 'borrowernumber for the librarian who accepted the suggestion, foreign key linking to the borrowers table',
  `accepteddate` date DEFAULT NULL COMMENT 'date the suggestion was marked as accepted',
  `rejectedby` int(11) DEFAULT NULL COMMENT 'borrowernumber for the librarian who rejected the suggestion, foreign key linking to the borrowers table',
  `rejecteddate` date DEFAULT NULL COMMENT 'date the suggestion was marked as rejected',
  `lastmodificationby` int(11) DEFAULT NULL COMMENT 'borrowernumber for the librarian who edit the suggestion for the last time',
  `lastmodificationdate` date DEFAULT NULL COMMENT 'date of the last modification',
  `STATUS` varchar(10) NOT NULL DEFAULT '' COMMENT 'suggestion status (ASKED, CHECKED, ACCEPTED, REJECTED, ORDERED, AVAILABLE or a value from the SUGGEST_STATUS authorised value category)',
  `archived` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'is the suggestion archived?',
  `note` longtext DEFAULT NULL COMMENT 'note entered on the suggestion',
  `staff_note` longtext DEFAULT NULL COMMENT 'non-public note entered on the suggestion',
  `author` varchar(80) DEFAULT NULL COMMENT 'author of the suggested item',
  `title` varchar(255) DEFAULT NULL COMMENT 'title of the suggested item',
  `copyrightdate` smallint(6) DEFAULT NULL COMMENT 'copyright date of the suggested item',
  `publishercode` varchar(255) DEFAULT NULL COMMENT 'publisher of the suggested item',
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time the suggestion was updated',
  `volumedesc` varchar(255) DEFAULT NULL,
  `publicationyear` smallint(6) DEFAULT 0,
  `place` varchar(255) DEFAULT NULL COMMENT 'publication place of the suggested item',
  `isbn` varchar(30) DEFAULT NULL COMMENT 'isbn of the suggested item',
  `biblionumber` int(11) DEFAULT NULL COMMENT 'foreign key linking the suggestion to the biblio table after the suggestion has been ordered',
  `reason` mediumtext DEFAULT NULL COMMENT 'reason for accepting or rejecting the suggestion',
  `patronreason` mediumtext DEFAULT NULL COMMENT 'reason for making the suggestion',
  `budgetid` int(11) DEFAULT NULL COMMENT 'foreign key linking the suggested budget to the aqbudgets table',
  `branchcode` varchar(10) DEFAULT NULL COMMENT 'foreign key linking the suggested branch to the branches table',
  `collectiontitle` mediumtext DEFAULT NULL COMMENT 'collection name for the suggested item',
  `itemtype` varchar(30) DEFAULT NULL COMMENT 'suggested item type',
  `quantity` smallint(6) DEFAULT NULL COMMENT 'suggested quantity to be purchased',
  `currency` varchar(10) DEFAULT NULL COMMENT 'suggested currency for the suggested price',
  `price` decimal(28,6) DEFAULT NULL COMMENT 'suggested price',
  `total` decimal(28,6) DEFAULT NULL COMMENT 'suggested total cost (price*quantity updated for currency)',
  PRIMARY KEY (`suggestionid`),
  KEY `suggestedby` (`suggestedby`),
  KEY `managedby` (`managedby`),
  KEY `acceptedby` (`acceptedby`),
  KEY `rejectedby` (`rejectedby`),
  KEY `biblionumber` (`biblionumber`),
  KEY `budgetid` (`budgetid`),
  KEY `branchcode` (`branchcode`),
  KEY `status` (`STATUS`),
  KEY `suggestions_ibfk_lastmodificationby` (`lastmodificationby`),
  CONSTRAINT `suggestions_budget_id_fk` FOREIGN KEY (`budgetid`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_acceptedby` FOREIGN KEY (`acceptedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_biblionumber` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_branchcode` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_lastmodificationby` FOREIGN KEY (`lastmodificationby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_managedby` FOREIGN KEY (`managedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_rejectedby` FOREIGN KEY (`rejectedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `suggestions_ibfk_suggestedby` FOREIGN KEY (`suggestedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `systempreferences`
--

DROP TABLE IF EXISTS `systempreferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `systempreferences` (
  `variable` varchar(50) NOT NULL DEFAULT '' COMMENT 'system preference name',
  `value` mediumtext DEFAULT NULL COMMENT 'system preference values',
  `options` longtext DEFAULT NULL COMMENT 'options for multiple choice system preferences',
  `explanation` mediumtext DEFAULT NULL COMMENT 'descriptive text for the system preference',
  `type` varchar(20) DEFAULT NULL COMMENT 'type of question this preference asks (multiple choice, plain text, yes or no, etc)',
  PRIMARY KEY (`variable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tables_settings`
--

DROP TABLE IF EXISTS `tables_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tables_settings` (
  `module` varchar(255) NOT NULL,
  `page` varchar(255) NOT NULL,
  `tablename` varchar(255) NOT NULL,
  `default_display_length` smallint(6) DEFAULT NULL,
  `default_sort_order` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`module`(191),`page`(191),`tablename`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `entry` varchar(255) NOT NULL DEFAULT '',
  `weight` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`entry`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags_all`
--

DROP TABLE IF EXISTS `tags_all`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_all` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id and primary key',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'the patron who added the tag (borrowers.borrowernumber)',
  `biblionumber` int(11) NOT NULL COMMENT 'the bib record this tag was left on (biblio.biblionumber)',
  `term` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'the tag',
  `language` int(4) DEFAULT NULL COMMENT 'the language the tag was left in',
  `date_created` datetime NOT NULL COMMENT 'the date the tag was added',
  PRIMARY KEY (`tag_id`),
  KEY `tags_borrowers_fk_1` (`borrowernumber`),
  KEY `tags_biblionumber_fk_1` (`biblionumber`),
  CONSTRAINT `tags_biblionumber_fk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tags_borrowers_fk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags_approval`
--

DROP TABLE IF EXISTS `tags_approval`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_approval` (
  `term` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'the tag',
  `approved` int(1) NOT NULL DEFAULT 0 COMMENT 'whether the tag is approved or not (1=yes, 0=pending, -1=rejected)',
  `date_approved` datetime DEFAULT NULL COMMENT 'the date this tag was approved',
  `approved_by` int(11) DEFAULT NULL COMMENT 'the librarian who approved the tag (borrowers.borrowernumber)',
  `weight_total` int(9) NOT NULL DEFAULT 1 COMMENT 'the total number of times this tag was used',
  PRIMARY KEY (`term`),
  KEY `tags_approval_borrowers_fk_1` (`approved_by`),
  CONSTRAINT `tags_approval_borrowers_fk_1` FOREIGN KEY (`approved_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags_index`
--

DROP TABLE IF EXISTS `tags_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_index` (
  `term` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'the tag',
  `biblionumber` int(11) NOT NULL COMMENT 'the bib record this tag was used on (biblio.biblionumber)',
  `weight` int(9) NOT NULL DEFAULT 1 COMMENT 'the number of times this term was used on this bib record',
  PRIMARY KEY (`term`,`biblionumber`),
  KEY `tags_index_biblionumber_fk_1` (`biblionumber`),
  CONSTRAINT `tags_index_biblionumber_fk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tags_index_term_fk_1` FOREIGN KEY (`term`) REFERENCES `tags_approval` (`term`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ticket_updates`
--

DROP TABLE IF EXISTS `ticket_updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ticket_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `ticket_id` int(11) NOT NULL COMMENT 'id of catalog ticket the update relates to',
  `user_id` int(11) NOT NULL DEFAULT 0 COMMENT 'id of the user who logged the update',
  `public` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean flag to denote whether this update is public',
  `date` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date and time this update was logged',
  `message` text NOT NULL COMMENT 'update message content',
  PRIMARY KEY (`id`),
  KEY `ticket_updates_ibfk_1` (`ticket_id`),
  KEY `ticket_updates_ibfk_2` (`user_id`),
  CONSTRAINT `ticket_updates_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ticket_updates_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tickets`
--

DROP TABLE IF EXISTS `tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `reporter_id` int(11) NOT NULL DEFAULT 0 COMMENT 'id of the patron who reported the ticket',
  `reported_date` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date and time this ticket was reported',
  `title` text NOT NULL COMMENT 'ticket title',
  `body` text NOT NULL COMMENT 'ticket details',
  `resolver_id` int(11) DEFAULT NULL COMMENT 'id of the user who resolved the ticket',
  `resolved_date` datetime DEFAULT NULL COMMENT 'date and time this ticket was resolved',
  `biblio_id` int(11) DEFAULT NULL COMMENT 'id of biblio linked',
  PRIMARY KEY (`id`),
  KEY `tickets_ibfk_1` (`reporter_id`),
  KEY `tickets_ibfk_2` (`resolver_id`),
  KEY `tickets_ibfk_3` (`biblio_id`),
  CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tickets_ibfk_2` FOREIGN KEY (`resolver_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tickets_ibfk_3` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmp_holdsqueue`
--

DROP TABLE IF EXISTS `tmp_holdsqueue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tmp_holdsqueue` (
  `biblionumber` int(11) DEFAULT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `barcode` varchar(20) DEFAULT NULL,
  `surname` longtext NOT NULL,
  `firstname` mediumtext DEFAULT NULL,
  `phone` mediumtext DEFAULT NULL,
  `borrowernumber` int(11) NOT NULL,
  `cardnumber` varchar(32) DEFAULT NULL,
  `reservedate` date DEFAULT NULL,
  `title` longtext DEFAULT NULL,
  `itemcallnumber` varchar(255) DEFAULT NULL,
  `holdingbranch` varchar(10) DEFAULT NULL,
  `pickbranch` varchar(10) DEFAULT NULL,
  `notes` mediumtext DEFAULT NULL,
  `item_level_request` tinyint(4) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time this entry as added/last updated',
  KEY `tmp_holdsqueue_ibfk_1` (`itemnumber`),
  KEY `tmp_holdsqueue_ibfk_2` (`biblionumber`),
  KEY `tmp_holdsqueue_ibfk_3` (`borrowernumber`),
  CONSTRAINT `tmp_holdsqueue_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tmp_holdsqueue_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tmp_holdsqueue_ibfk_3` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transport_cost`
--

DROP TABLE IF EXISTS `transport_cost`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transport_cost` (
  `frombranch` varchar(10) NOT NULL,
  `tobranch` varchar(10) NOT NULL,
  `cost` decimal(6,2) NOT NULL,
  `disable_transfer` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`frombranch`,`tobranch`),
  KEY `transport_cost_ibfk_2` (`tobranch`),
  CONSTRAINT `transport_cost_ibfk_1` FOREIGN KEY (`frombranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `transport_cost_ibfk_2` FOREIGN KEY (`tobranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uploaded_files`
--

DROP TABLE IF EXISTS `uploaded_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uploaded_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hashvalue` char(40) NOT NULL,
  `filename` mediumtext NOT NULL,
  `dir` mediumtext NOT NULL,
  `filesize` int(11) DEFAULT NULL,
  `dtcreated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `uploadcategorycode` text DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `public` tinyint(4) DEFAULT NULL,
  `permanent` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_permissions` (
  `borrowernumber` int(11) NOT NULL DEFAULT 0,
  `module_bit` int(11) NOT NULL DEFAULT 0,
  `code` varchar(64) NOT NULL,
  PRIMARY KEY (`borrowernumber`,`module_bit`,`code`),
  KEY `user_permissions_ibfk_1` (`borrowernumber`),
  KEY `user_permissions_ibfk_2` (`module_bit`,`code`),
  CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_permissions_ibfk_2` FOREIGN KEY (`module_bit`, `code`) REFERENCES `permissions` (`module_bit`, `code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userflags`
--

DROP TABLE IF EXISTS `userflags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userflags` (
  `bit` int(11) NOT NULL DEFAULT 0,
  `flag` varchar(30) DEFAULT NULL,
  `flagdesc` varchar(255) DEFAULT NULL,
  `defaulton` int(11) DEFAULT NULL,
  PRIMARY KEY (`bit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_edi_accounts`
--

DROP TABLE IF EXISTS `vendor_edi_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_edi_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` mediumtext NOT NULL,
  `host` varchar(40) DEFAULT NULL,
  `username` varchar(40) DEFAULT NULL,
  `password` mediumtext DEFAULT NULL,
  `last_activity` date DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `download_directory` mediumtext DEFAULT NULL,
  `upload_directory` mediumtext DEFAULT NULL,
  `san` varchar(20) DEFAULT NULL,
  `standard` varchar(3) DEFAULT 'EUR',
  `id_code_qualifier` varchar(3) DEFAULT '14',
  `transport` varchar(6) DEFAULT 'FTP',
  `quotes_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `invoices_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `orders_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `responses_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `auto_orders` tinyint(1) NOT NULL DEFAULT 0,
  `shipment_budget` int(11) DEFAULT NULL,
  `plugin` varchar(256) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `vendorid` (`vendor_id`),
  KEY `shipmentbudget` (`shipment_budget`),
  CONSTRAINT `vfk_shipment_budget` FOREIGN KEY (`shipment_budget`) REFERENCES `aqbudgets` (`budget_id`),
  CONSTRAINT `vfk_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtualshelfcontents`
--

DROP TABLE IF EXISTS `virtualshelfcontents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtualshelfcontents` (
  `shelfnumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key linking to the virtualshelves table, defines the list that this record has been added to',
  `biblionumber` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key linking to the biblio table, defines the bib record that has been added to the list',
  `flags` int(11) DEFAULT NULL,
  `dateadded` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time this bib record was added to the list',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'borrower number that created this list entry (only the first one is saved: no need for use in/as key)',
  KEY `shelfnumber` (`shelfnumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `shelfcontents_ibfk_3` (`borrowernumber`),
  CONSTRAINT `shelfcontents_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `shelfcontents_ibfk_3` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `virtualshelfcontents_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `virtualshelves` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtualshelfshares`
--

DROP TABLE IF EXISTS `virtualshelfshares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtualshelfshares` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key',
  `shelfnumber` int(11) NOT NULL COMMENT 'foreign key for virtualshelves',
  `borrowernumber` int(11) DEFAULT NULL COMMENT 'borrower that accepted access to this list',
  `invitekey` varchar(10) DEFAULT NULL COMMENT 'temporary string used in accepting the invitation to access thist list; not-empty means that the invitation has not been accepted yet',
  `sharedate` datetime DEFAULT NULL COMMENT 'date of invitation or acceptance of invitation',
  PRIMARY KEY (`id`),
  KEY `virtualshelfshares_ibfk_1` (`shelfnumber`),
  KEY `virtualshelfshares_ibfk_2` (`borrowernumber`),
  CONSTRAINT `virtualshelfshares_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `virtualshelves` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `virtualshelfshares_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtualshelves`
--

DROP TABLE IF EXISTS `virtualshelves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtualshelves` (
  `shelfnumber` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
  `shelfname` varchar(255) DEFAULT NULL COMMENT 'name of the list',
  `owner` int(11) DEFAULT NULL COMMENT 'foreign key linking to the borrowers table (using borrowernumber) for the creator of this list (changed from varchar(80) to int)',
  `public` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'If the list is public',
  `sortfield` varchar(16) DEFAULT 'title' COMMENT 'the field this list is sorted on',
  `lastmodified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'date and time the list was last modified',
  `created_on` datetime NOT NULL COMMENT 'creation time',
  `allow_change_from_owner` tinyint(1) DEFAULT 1 COMMENT 'can owner change contents?',
  `allow_change_from_others` tinyint(1) DEFAULT 0 COMMENT 'can others change contents?',
  `allow_change_from_staff` tinyint(1) DEFAULT 0 COMMENT 'can staff change contents?',
  `allow_change_from_permitted_staff` tinyint(1) DEFAULT 0 COMMENT 'can staff with edit_public_list_contents permission change contents?',
  PRIMARY KEY (`shelfnumber`),
  KEY `virtualshelves_ibfk_1` (`owner`),
  CONSTRAINT `virtualshelves_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `z3950servers`
--

DROP TABLE IF EXISTS `z3950servers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `z3950servers` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
  `host` varchar(255) NOT NULL COMMENT 'target''s host name',
  `port` int(11) DEFAULT NULL COMMENT 'port number used to connect to target',
  `db` varchar(255) DEFAULT NULL COMMENT 'target''s database name',
  `userid` varchar(255) DEFAULT NULL COMMENT 'username needed to log in to target',
  `password` varchar(255) DEFAULT NULL COMMENT 'password needed to log in to target',
  `servername` longtext NOT NULL COMMENT 'name given to the target by the library',
  `checked` smallint(6) DEFAULT NULL COMMENT 'whether this target is checked by default  (1 for yes, 0 for no)',
  `rank` int(11) DEFAULT NULL COMMENT 'where this target appears in the list of targets',
  `syntax` varchar(80) NOT NULL COMMENT 'MARC format provided by this target',
  `timeout` int(11) NOT NULL DEFAULT 0 COMMENT 'number of seconds before Koha stops trying to access this server',
  `servertype` enum('zed','sru') NOT NULL DEFAULT 'zed' COMMENT 'zed means z39.50 server',
  `encoding` mediumtext NOT NULL COMMENT 'characters encoding provided by this target',
  `recordtype` enum('authority','biblio') NOT NULL DEFAULT 'biblio' COMMENT 'server contains bibliographic or authority records',
  `sru_options` varchar(255) DEFAULT NULL COMMENT 'options like sru=get, sru_version=1.1; will be passed to the server via ZOOM',
  `sru_fields` longtext DEFAULT NULL COMMENT 'contains the mapping between the Z3950 search fields and the specific SRU server indexes',
  `add_xslt` longtext DEFAULT NULL COMMENT 'zero or more paths to XSLT files to be processed on the search results',
  `attributes` varchar(255) DEFAULT NULL COMMENT 'additional attributes passed to PQF queries',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `zebraqueue`
--

DROP TABLE IF EXISTS `zebraqueue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zebraqueue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `biblio_auth_number` bigint(20) unsigned NOT NULL DEFAULT 0,
  `operation` char(20) NOT NULL DEFAULT '',
  `server` char(20) NOT NULL DEFAULT '',
  `done` int(11) NOT NULL DEFAULT 0,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `zebraqueue_lookup` (`server`,`biblio_auth_number`,`operation`,`done`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-05-31 12:31:12
