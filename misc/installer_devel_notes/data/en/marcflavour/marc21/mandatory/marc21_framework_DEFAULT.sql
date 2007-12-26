-- *************************************************************
--  KOHA 3.0 MARC 21 STANDARD DEFAULT BIBLIOGRAPHIC FRAMEWORK
--              DEVELOPMENT NOTES AND SUPPLEMENTARY SQL
--
--                     PRETEST VERSION 0.1.7
--                          2007-11-05
--
--                            edited
--                            by thd
--
--                          BASED UPON
--
--     KOHA MARC 21 STANDARD DEFAULT BIBLIOGRAPHIC FRAMEWORK
--
--                     PRETEST VERSION 0.2.8
--                          2007-11-05
--
--     original default requiring greater user customisation
--                  created by a few Koha Hands
--                    guided by Paul POULAIN
--
--          revised and greatly enlarged to completion,
--               well not quite complete yet today
--           but close enough for someone to have use,
--                      by thd for LibLime
-- *************************************************************


-- *********************************************************************
-- These development notes and supplementary SQL statements have been
-- moved from the main file for easier readability of the main file and
-- to avoid possible bugs with lack of time to test for the use of
-- letters in field names such as used by RLIN to avoid conflict with
-- numbered field names already in use.
--
-- Retaining this file is important for future MARC frameworks
-- development work.
-- *********************************************************************


SET FOREIGN_KEY_CHECKS = 0;


-- ******************************************************
-- KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- ******************************************************

-- These ought to be adjusted for different less conflicting and more
-- rationally chosen fields and subfields but I had left that for last.

-- ADJUST ME
-- Use values from your dump of marc_tag_structure and marc_subfield_structure
-- to provide support for your Koha database.


-- ******************************************************

-- Original Record ID Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- ('090', 'KOHA DATA', 'KOHA DATA', 1, 0, '', '');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`) VALUES
-- ('090', 'a', 'Koha Itemtype (NR)', 'Koha Itemtype (NR)', 0, 0, NULL, -1, NULL, NULL, '', NULL, '', NULL, NULL),
-- ('090', 'b', 'Koha Dewey Subclass (NR)', 'Koha Dewey Subclass (NR)', 0, 0, NULL, -1, NULL, NULL, '', NULL, '', NULL, NULL),
-- ('090', 'c', 'Koha biblionumber (NR)', 'Koha biblionumber (NR)', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, '', NULL, NULL),
-- ('090', 'd', 'Koha biblioitemnumber (NR)', 'Koha biblioitemnumber (NR)', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, '', NULL, NULL);


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', '');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, '', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, '', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, '', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, '', '', '', NULL);


-- ******************************************************

-- Original primary biblioitems Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('942', 'Biblioitem information', 'General classification', 0, 0, '', '');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`) VALUES
-- 		('942', 'a', 'Institution code', 'Institution code', 0, 0, '', 5, '', '', '', NULL, '', NULL, NULL),
-- 		('942', 'c', 'item type', 'item type', 0, 0, 'biblioitems.itemtype', 5, 'itemtypes', '', '', NULL, '', NULL, NULL),
-- 		('942', 'k', 'dewey', 'dewey', 0, 0, 'biblioitems.classification', 5, '', '', '', NULL, '', NULL, NULL);


-- rel_2_2 primary biblioitems Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', '');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, '', '', '', NULL),
-- 		('942', 'c', 'Koha item type', 'Koha item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, '', '', '', NULL),
-- 		('942', 'j', 'Location (call number prefix code)', 'Location (call number prefix code)', 0, 0, 'biblioitems.classification', 9, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('942', 'k', 'Classification base (DDC to decimal or LCC letter class padded after single letter classes with trailing 0', 'Classification base', 0, 0, 'biblioitems.dewey', 9, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('942', 'l', 'Classification subclass (DDC after decimal or LCC number after letters', 'Classification subclass', 0, 0, 'biblioitems.subclass', 9, '', '', '', NULL, 0, '', '', '', NULL);



-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, '', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, '', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', '');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, '', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, '', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, '', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, '', '', '', NULL),
		('942', 'c', 'Koha item type', 'Koha item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, '', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, '', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, '', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, '', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, '', 9, '', '', '', NULL, 0, '', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, '', '', '', NULL);


-- ******************************************************

-- Original items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('952', 'ITEM INFORMATION', 'ITEM INFORMATION', 1, 0, '', '');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`) VALUES
-- 		('952', 'b', 'homebranch', 'homebranch', 0, 0, 'items.homebranch', 10, 'branches', '', '', '', '', NULL, NULL),
-- 		('952', 'd', 'holdingbranch', 'holdingbranch', 0, 0, 'items.holdingbranch', 10, 'branches', '', '', '\'952b\'', '', NULL, NULL),
-- 		('952', 'p', 'barcode', 'barcode', 0, 1, 'items.barcode', 10, '', '', '', '', '', NULL, NULL),
-- 		('952', 'r', 'price', 'price', 0, 0, 'items.replacementprice', 10, '', '', '', '', '', NULL, NULL),
-- 		('952', 'v', 'dateaccessioned', 'dateaccessioned', 0, 0, 'items.dateaccessioned', 10, '', '', '', '', '', NULL, NULL),
-- 		('952', 'y', 'notforloan', 'notforloan', 0, 0, 'items.notforloan', 10, '', '', '', '', '', NULL, NULL),
-- 		('952', 'u', 'itemnumber', 'itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', '', '', NULL, NULL);



-- rel_2-2 items Field/Subfields

-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', '');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WTHDRAWN', '', '', 0, 0, '', '', '', NULL),
-- 		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, '', '', '', NULL),
-- 		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, '', 10, '', '', 'marc21_classcodes.pl', NULL, 0, '', '', '', NULL),
-- 		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, '', 10, '', '', '', NULL, -1, '', '', '', NULL),
-- 		('952', '4', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, '', '', '', NULL),
-- 		('952', '6', 'Linkage', 'Linkage', 0, 0, '', 10, '', '', '', NULL, -6, '', '', '', NULL),
-- 		('952', '8', 'Sequence number', 'Sequence number', 1, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', '9', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, '', '', '', NULL),
-- 		('952', 'a', 'Canceled barcode', 'Canceled barcode', 1, 0, '', 10, '', '', '', NULL, -1, '', '', '', NULL),
-- 		('952', 'b', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
-- 		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, '', '', '', NULL),
-- 		('952', 'd', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 0, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, '', '''952b''', '', NULL),
-- 		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', '', 0, 0, '', '', '', NULL),
-- 		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, '', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, '', '', '', NULL),
-- 		('952', 'g', 'Non-coded location qualifier', 'Non-coded location qualifier', 1, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'h', 'Classification part', 'Classification part', 0, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'i', 'Item part', 'Item part', 1, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, '', '', 'STOCK', NULL, 0, '', '', '', NULL),
-- 		('952', 'k', 'Kohqa full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', '', NULL, 0, 0, '', '', '', NULL),
-- 		('952', 'l', 'Shelving form of title', 'Shelving form of title', 0, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'm', 'Call number suffix', 'Call number suffix', 0, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'n', 'Country code', 'Country code', 0, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'o', 'Call number prefix', 'Call number prefix', 0, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'p', 'Barcode', 'Barcode', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, '', '', '', NULL),
-- 		('952', 'q', 'Piece physical condition', 'Piece physical condition', 0, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'r', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, '', '', '', NULL),
-- 		('952', 's', 'Copyright article-fee code', 'Copyright article-fee code', 1, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 't', 'Copy number', 'Copy number', 0, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('952', 'u', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, '', '', '', NULL),
-- 		('952', 'v', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'usmarc_field_952v.pl', 0, 0, '', '', '', NULL),
-- 		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, '', '', '', NULL),
-- 		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 6, '', '', '', NULL),
-- 		('952', 'y', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, '', '', '', 0, 0, '', '', '', NULL),
-- 		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, '', '', '', NULL);



-- Recommended items Field/Subfields

-- Because of upgrade issues, the following recomendation may be a problematic
-- recomendation.

-- Using recommended items fields/subfields might require adding columns to
-- the Koha 'items' table and might not upgrade well without special effort.
-- The following columns may not be present in 'items' and would need
-- adding.
--
-- Repeatedly recreating and dropping a stored procedure avoids the risk of an
-- 'illegal mix of collations' error from calling the stored procedure with
-- variables where MySQL has multiple UTF8 collations.
--
-- yourKohaDatabaseName must be changed appropriately below.

-- DELIMITER //
-- -- CREATE PROCEDURE tempaddcolumn(c VARCHAR(32), a VARCHAR(256))
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'linkage')
-- 	THEN ALTER TABLE `items` ADD `linkage` TEXT CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;
-- 
-- DELIMITER //
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'sequence')
-- 	THEN ALTER TABLE `items` ADD `sequence` TEXT CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;
-- 
-- 
-- DELIMITER //
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'non_coded_location_qualifier')
-- 	THEN ALTER TABLE `items` ADD `non_coded_location_qualifier` TEXT CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;
-- 
-- DELIMITER //
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'cn_class')
-- 	THEN ALTER TABLE `items` ADD `cn_class` VARCHAR(127) CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;
-- 
-- DELIMITER //
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'cn_item')
-- 	THEN ALTER TABLE `items` ADD `cn_item` VARCHAR(63) CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;
-- 
-- DELIMITER //
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'cn_prefix')
-- 	THEN ALTER TABLE `items` ADD `cn_prefix` VARCHAR(31) CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;
-- 
-- DELIMITER //
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'shelving_title')
-- 	THEN ALTER TABLE `items` ADD `shelving_title` VARCHAR(255) CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;
-- 
-- DELIMITER //
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'cancelled_barcode')
-- 	THEN ALTER TABLE `items` ADD `cancelled_barcode` VARCHAR(255) CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;
-- 
-- DELIMITER //
-- CREATE PROCEDURE tempaddcolumn()
-- BEGIN
-- IF NOT EXISTS (
-- 		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_SCHEMA = 'yourKohaDatabaseName'
-- 		AND TABLE_NAME = 'items'
-- 		AND COLUMN_NAME = 'copyright_fee')
-- 	THEN ALTER TABLE `items` ADD `copyright_fee` TEXT CHARACTER SET utf8 DEFAULT NULL;
-- END IF;
-- END //
-- DELIMITER ;
-- call tempaddcolumn();
-- DROP PROCEDURE tempaddcolumn;

-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', '');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, '', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, '', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, '', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, '', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, '', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, '', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, '', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, '', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, '', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, '', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 0, 0, 'items.onloan', 10, '', '', '', NULL, -5, '', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 0, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, '', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 0, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, '', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, '', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, '', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, '', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, '', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, '', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, '', '', '', NULL);



-- Plugins which need to be written for items Field/Subfields


-- 		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, '', '', '', NULL),
-- 		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, '', '', '', NULL),



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', '');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, '', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, '', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', '', NULL, 0, '', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, '', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, '', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, '', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, '', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, '', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, '', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, '', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, '', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, '', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, '', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, '', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, '', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, '', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, '', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, '', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, '', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', '', NULL, 0, 0, '', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, '', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 0, 0, 'items.onloan', 10, '', '', '', NULL, -5, '', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 0, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, '', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 0, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, '', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, '', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, '', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, '', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, '', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, '', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, '', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, '', '', '', NULL);




-- *******************************************************



-- *******************************************************
-- MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED EXTENSIONS
-- *******************************************************


-- A Few local use codes need specifying.  Several seealso, plugin, and
-- authority framework columns need improving.  $9 for authority record linking
-- needs to be added where not already provided by RLIN specifications.
-- Needs checking for errors but probably tolerable for use on a production.
-- A server can be upgraded easily from later versions of this file.
--
-- In the absense of more column support for qualifying the relative
-- importance of subfields to the record editor, some modest modification of
-- the default framework is needed setting the not-useful non-Koha holdings
-- subfields to not managed in Koha.

-- MARC fields including letters as part of the field identifier are from RLIN
-- and should be expected to remain along with RLIN $% subfields.  RLIN has
-- been using letters in fields because there are not enough local use number
-- fields which have not already been specified for very large union catalogue
-- networks such as RLIN itself.


-- Fields ending in c, o, or r are temporary placeholders for information from
-- a numeric value until a non-conflicting way to treat the content under the
-- proper original numeric field is adopted.
--
-- 090 for LC call numbers has been restored.  Formerly, 999, now used for the
-- Koha record ID, had been provided as a temporary place holder until all
-- Koha code for finding control fields has been changed from a numeric test
-- of < 10 to a regular expression match of m/^00/ to prevent mistaken
-- matching of fields with letters such as 09o if they were control fields.


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', ''),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', ''),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA], 910', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', ''),
		('91r', 'RLG STANDARDS NOTE (RLIN), 910', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', ''),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only], 945', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', ''),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', ''),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', ''),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only], 952', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', ''),
		('95r', 'CLUSTER MEMBER (RLIN), 952', 'CLUSTER MEMBER (RLIN)', 1, 0, '', ''),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', ''),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', ''),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', ''),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', ''),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', ''),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', ''),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', ''),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', ''),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', ''),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', ''),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', ''),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', ''),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', ''),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', ''),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', ''),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', ''),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', ''),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', ''),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', ''),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', ''),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', ''),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', ''),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', ''),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', ''),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', ''),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', ''),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', ''),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', '');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, '', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, '', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, '', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, '', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, '', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, '', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, '', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, '', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, '', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, '', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, '', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, '', '', '', NULL);



