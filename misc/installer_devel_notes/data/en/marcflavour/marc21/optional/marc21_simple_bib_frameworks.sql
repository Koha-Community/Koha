-- *************************************************************
--       SIMPLE KOHA 3.0 MARC 21 BIBLIOGRAPHIC FRAMEWORKS
--           DEVELOPMENT NOTES AND SUPPLEMENTARY SQL
--
--                     PRETEST VERSION 0.1.7
--                          2007-11-05
--
--                            edited
--                            by thd
--
--                          BASED UPON
--
--       SIMPLE KOHA 3.0 MARC 21 BIBLIOGRAPHIC FRAMEWORKS
--                    POST-INSTALLATION SCRIPT
--
--                     PRETEST VERSION 0.1.7
--                          2007-11-05
--
--                            edited
--                            by thd
--
--                          BASED UPON
--
--  KOHA 3.0 MARC 21 STANDARD DEFAULT BIBLIOGRAPHIC FRAMEWORK
--
--                    PRETEST VERSION 0.1.7
--                          2007-11-05
--
--                            edited
--                            by thd
--
--                        AND BASED UPON
--
--          SIMPLE KOHA MARC 21 BIBLIOGRAPHIC FRAMEWORKS
--                    POST-INSTALLATION SCRIPT
--
--                     PRETEST VERSION 0.1.11
--                          2007-10-14
--
--                           drafted
--                      by thd for LibLime
--
--            with a frameworks nomenclature correction
--                     by kados at LibLime
--
--                             WITH
--
--     KOHA MARC 21 STANDARD DEFAULT BIBLIOGRAPHIC FRAMEWORK
--                    POST-INSTALLATION SCRIPT
--
--                     PRETEST VERSION 0.2.8
--                          2007-11-05
--
--                            edited
--                      by thd for LibLime
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

-- Retaining this file is important for future MARC frameworks
-- development work.
-- *********************************************************************


SET FOREIGN_KEY_CHECKS = 0;


-- ********************************
-- SIMPLE KOHA MARC 21 FRAMEWORKS.
-- ********************************


INSERT INTO `biblio_framework` (`frameworkcode`,`frameworktext`) VALUES
		('BKS', 'Books, Booklets, Workbooks'),
		('CF', 'CD-ROMs, DVD-ROMs, General Online Resources'),
		('SR', 'Audio Cassettes, CDs'),
		('VR', 'DVDs, VHS'),
		('AR', 'Models'),
		('KT', 'Kits'),
		('IR', 'Binders'),
		('SER', 'Serials');


-- ******************************************************



-- *******************************************************************
-- SIMPLE BOOKS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- *******************************************************************


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'BKS');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, 'BKS', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, 'BKS', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'BKS', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'BKS', '', '', NULL);


-- ******************************************************


-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, 'BKS', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, 'BKS', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', 'BKS');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, 'BKS', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, 'BKS', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, 'BKS', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, 'BKS', '', '', NULL),
		('942', 'c', 'Item type', 'Item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, 'BKS', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, 'BKS', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, 'BKS', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, 'BKS', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, 'biblioitems.cn_prefix', 9, '', '', '', NULL, 0, 'BKS', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, 'BKS', '', '', NULL);


-- ******************************************************


-- Recommended items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'BKS');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'BKS', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, 'BKS', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, 'BKS', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, 'BKS', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'BKS', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'BKS', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'BKS', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, 'BKS', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL);



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'BKS');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'BKS', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'BKS', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'BKS', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, 'BKS', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, 'BKS', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'BKS', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'BKS', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'BKS', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, 'BKS', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'BKS', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'BKS', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'BKS', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'BKS', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'BKS', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'BKS', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, 'BKS', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'BKS', '', '', NULL);



-- *******************************************************



-- *********************************************************************
-- SIMPLE BOOKS MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED EXTENSIONS.
-- *********************************************************************


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', 'BKS'),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', 'BKS'),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', 'BKS'),
		('91r', 'RLG STANDARDS NOTE (RLIN)', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', 'BKS'),
		('93r', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 1, 0, '', 'BKS'),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'BKS'),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', 'BKS'),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', 'BKS'),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'BKS'),
		('95r', 'CLUSTER MEMBER (RLIN)', 'CLUSTER MEMBER (RLIN)', 1, 0, '', 'BKS'),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', 'BKS'),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', 'BKS'),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', 'BKS'),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', 'BKS'),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', 'BKS'),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', 'BKS'),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', 'BKS'),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', 'BKS'),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', 'BKS'),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', 'BKS'),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', 'BKS'),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', 'BKS'),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', 'BKS'),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', 'BKS'),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', 'BKS'),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', 'BKS'),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', 'BKS'),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', 'BKS'),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', 'BKS'),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', 'BKS'),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', 'BKS'),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', 'BKS'),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', 'BKS'),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', 'BKS'),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', 'BKS'),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', 'BKS'),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', 'BKS'),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', 'BKS');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, 'BKS', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, 'BKS', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'BKS', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, 'BKS', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL);


-- *******************************************************



-- ****************************************************************************
-- SIMPLE COMPUTER FILES KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- ****************************************************************************


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'CF');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, 'CF', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, 'CF', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'CF', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'CF', '', '', NULL);


-- ******************************************************


-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, 'CF', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, 'CF', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', 'CF');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, 'CF', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, 'CF', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, 'CF', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, 'CF', '', '', NULL),
		('942', 'c', 'Item type', 'Item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, 'CF', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, 'CF', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, 'CF', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, 'CF', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, 'biblioitems.cn_prefix', 9, '', '', '', NULL, 0, 'CF', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, 'CF', '', '', NULL);


-- ******************************************************


-- Recommended items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'CF');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'CF', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, 'CF', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, 'CF', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, 'CF', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'CF', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'CF', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'CF', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, 'CF', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'CF', '', '', NULL);



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'CF');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'CF', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'CF', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'CF', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'CF', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'CF', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'CF', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, 'CF', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'CF', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'CF', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, 'CF', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'CF', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'CF', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'CF', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'CF', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'CF', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'CF', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'CF', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, 'CF', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'CF', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'CF', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'CF', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'CF', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'CF', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'CF', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'CF', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'CF', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, 'CF', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'CF', '', '', NULL);



-- *******************************************************



-- ******************************************************************
-- SIMPLE COMPUTER FILES MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED
-- EXTENSIONS.
-- ******************************************************************


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', 'CF'),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', 'CF'),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', 'CF'),
		('91r', 'RLG STANDARDS NOTE (RLIN)', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', 'CF'),
		('93r', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 1, 0, '', 'CF'),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'CF'),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', 'CF'),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', 'CF'),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'CF'),
		('95r', 'CLUSTER MEMBER (RLIN)', 'CLUSTER MEMBER (RLIN)', 1, 0, '', 'CF'),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', 'CF'),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', 'CF'),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', 'CF'),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', 'CF'),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', 'CF'),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', 'CF'),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', 'CF'),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', 'CF'),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', 'CF'),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', 'CF'),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', 'CF'),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', 'CF'),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', 'CF'),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', 'CF'),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', 'CF'),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', 'CF'),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', 'CF'),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', 'CF'),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', 'CF'),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', 'CF'),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', 'CF'),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', 'CF'),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', 'CF'),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', 'CF'),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', 'CF'),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', 'CF'),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', 'CF'),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', 'CF');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, 'CF', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, 'CF', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, 'CF', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'CF', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'CF', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'CF', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'CF', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'CF', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, 'CF', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, 'CF', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'CF', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'CF', '', '', NULL);


-- *******************************************************



-- ************************************************************
-- SIMPLE SOUND RECORDINGS KOHA RECORD AND HOLDINGS MANAGEMENT
-- FIELDS/SUBFIELDS.
-- ************************************************************


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'SR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, 'SR', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, 'SR', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'SR', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'SR', '', '', NULL);


-- ******************************************************


-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, 'SR', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, 'SR', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', 'SR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, 'SR', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, 'SR', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, 'SR', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, 'SR', '', '', NULL),
		('942', 'c', 'Item type', 'Item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, 'SR', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, 'SR', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, 'SR', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, 'SR', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, 'biblioitems.cn_prefix', 9, '', '', '', NULL, 0, 'SR', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, 'SR', '', '', NULL);


-- ******************************************************


-- Recommended items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'SR');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'SR', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, 'SR', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, 'SR', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, 'SR', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'SR', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'SR', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'SR', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, 'SR', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'SR', '', '', NULL);



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'SR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'SR', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'SR', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'SR', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'SR', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'SR', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'SR', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, 'SR', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'SR', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'SR', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, 'SR', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'SR', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'SR', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'SR', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'SR', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'SR', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'SR', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'SR', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, 'SR', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'SR', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'SR', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'SR', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'SR', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'SR', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'SR', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'SR', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'SR', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, 'SR', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'SR', '', '', NULL);



-- *******************************************************



-- *********************************************************************
-- SIMPLE SOUND RECORDINGS MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED
-- EXTENSIONS.
-- *********************************************************************


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', 'SR'),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', 'SR'),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', 'SR'),
		('91r', 'RLG STANDARDS NOTE (RLIN)', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', 'SR'),
		('93r', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 1, 0, '', 'SR'),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'SR'),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', 'SR'),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', 'SR'),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'SR'),
		('95r', 'CLUSTER MEMBER (RLIN)', 'CLUSTER MEMBER (RLIN)', 1, 0, '', 'SR'),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', 'SR'),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', 'SR'),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', 'SR'),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', 'SR'),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', 'SR'),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', 'SR'),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', 'SR'),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', 'SR'),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', 'SR'),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', 'SR'),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', 'SR'),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', 'SR'),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', 'SR'),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', 'SR'),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', 'SR'),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', 'SR'),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', 'SR'),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', 'SR'),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', 'SR'),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', 'SR'),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', 'SR'),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', 'SR'),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', 'SR'),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', 'SR'),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', 'SR'),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', 'SR'),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', 'SR'),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', 'SR');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, 'SR', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, 'SR', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, 'SR', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SR', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SR', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SR', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SR', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SR', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, 'SR', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, 'SR', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SR', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SR', '', '', NULL);


-- *******************************************************



-- ***********************************************************
-- SIMPLE VIDEORECORDINGS KOHA RECORD AND HOLDINGS MANAGEMENT
-- FIELDS/SUBFIELDS.
-- ***********************************************************


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'VR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, 'VR', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, 'VR', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'VR', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'VR', '', '', NULL);


-- ******************************************************


-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, 'VR', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, 'VR', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', 'VR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, 'VR', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, 'VR', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, 'VR', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, 'VR', '', '', NULL),
		('942', 'c', 'Item type', 'Item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, 'VR', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, 'VR', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, 'VR', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, 'VR', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, 'biblioitems.cn_prefix', 9, '', '', '', NULL, 0, 'VR', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, 'VR', '', '', NULL);


-- ******************************************************


-- Recommended items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'VR');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'VR', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, 'VR', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, 'VR', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, 'VR', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'VR', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'VR', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'VR', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, 'VR', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'VR', '', '', NULL);



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'VR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'VR', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'VR', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'VR', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'VR', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'VR', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'VR', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, 'VR', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'VR', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'VR', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, 'VR', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'VR', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'VR', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'VR', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'VR', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'VR', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'VR', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'VR', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, 'VR', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'VR', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'VR', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'VR', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'VR', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'VR', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'VR', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'VR', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'VR', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, 'VR', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'VR', '', '', NULL);



-- *******************************************************



-- *******************************************************************
-- SIMPLE VIDEORECORDINGS MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED
-- EXTENSIONS.
-- *******************************************************************


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', 'VR'),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', 'VR'),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', 'VR'),
		('91r', 'RLG STANDARDS NOTE (RLIN)', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', 'VR'),
		('93r', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 1, 0, '', 'VR'),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'VR'),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', 'VR'),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', 'VR'),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'VR'),
		('95r', 'CLUSTER MEMBER (RLIN)', 'CLUSTER MEMBER (RLIN)', 1, 0, '', 'VR'),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', 'VR'),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', 'VR'),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', 'VR'),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', 'VR'),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', 'VR'),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', 'VR'),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', 'VR'),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', 'VR'),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', 'VR'),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', 'VR'),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', 'VR'),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', 'VR'),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', 'VR'),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', 'VR'),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', 'VR'),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', 'VR'),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', 'VR'),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', 'VR'),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', 'VR'),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', 'VR'),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', 'VR'),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', 'VR'),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', 'VR'),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', 'VR'),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', 'VR'),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', 'VR'),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', 'VR'),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', 'VR');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, 'VR', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, 'VR', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, 'VR', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'VR', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'VR', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'VR', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'VR', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'VR', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, 'VR', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, 'VR', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'VR', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'VR', '', '', NULL);



-- *******************************************************


-- **************************************************************************
-- SIMPLE 3D ARTIFACTS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- **************************************************************************


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'AR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, 'AR', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, 'AR', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'AR', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'AR', '', '', NULL);


-- ******************************************************


-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, 'AR', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, 'AR', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', 'AR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, 'AR', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, 'AR', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, 'AR', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, 'AR', '', '', NULL),
		('942', 'c', 'Item type', 'Item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, 'AR', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, 'AR', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, 'AR', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, 'AR', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, 'biblioitems.cn_prefix', 9, '', '', '', NULL, 0, 'AR', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, 'AR', '', '', NULL);


-- ******************************************************


-- Recommended items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'AR');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'AR', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, 'AR', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, 'AR', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, 'AR', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'AR', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'AR', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'AR', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, 'AR', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'AR', '', '', NULL);



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'AR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'AR', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'AR', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'AR', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'AR', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'AR', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'AR', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, 'AR', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'AR', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'AR', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, 'AR', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'AR', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'AR', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'AR', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'AR', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'AR', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'AR', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'AR', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, 'AR', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'AR', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'AR', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'AR', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'AR', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'AR', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'AR', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'AR', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'AR', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, 'AR', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'AR', '', '', NULL);



-- *******************************************************



-- ****************************************************************************
-- SIMPLE 3D ARTIFACTS MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED EXTENSIONS.
-- ****************************************************************************


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', 'AR'),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', 'AR'),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', 'AR'),
		('91r', 'RLG STANDARDS NOTE (RLIN)', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', 'AR'),
		('93r', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 1, 0, '', 'AR'),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'AR'),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', 'AR'),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', 'AR'),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'AR'),
		('95r', 'CLUSTER MEMBER (RLIN)', 'CLUSTER MEMBER (RLIN)', 1, 0, '', 'AR'),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', 'AR'),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', 'AR'),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', 'AR'),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', 'AR'),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', 'AR'),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', 'AR'),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', 'AR'),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', 'AR'),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', 'AR'),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', 'AR'),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', 'AR'),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', 'AR'),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', 'AR'),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', 'AR'),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', 'AR'),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', 'AR'),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', 'AR'),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', 'AR'),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', 'AR'),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', 'AR'),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', 'AR'),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', 'AR'),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', 'AR'),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', 'AR'),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', 'AR'),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', 'AR'),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', 'AR'),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', 'AR');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, 'AR', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, 'AR', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, 'AR', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'AR', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'AR', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'AR', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'AR', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'AR', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, 'AR', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, 'AR', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'AR', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'AR', '', '', NULL);



-- *******************************************************


-- ******************************************************************
-- SIMPLE KITS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- ******************************************************************


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'KT');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, 'KT', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, 'KT', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'KT', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'KT', '', '', NULL);


-- ******************************************************


-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, 'KT', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, 'KT', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', 'KT');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, 'KT', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, 'KT', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, 'KT', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, 'KT', '', '', NULL),
		('942', 'c', 'Item type', 'Item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, 'KT', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, 'KT', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, 'KT', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, 'KT', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, 'biblioitems.cn_prefix', 9, '', '', '', NULL, 0, 'KT', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, 'KT', '', '', NULL);


-- ******************************************************


-- Recommended items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'KT');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'KT', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, 'KT', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, 'KT', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, 'KT', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'KT', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'KT', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'KT', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, 'KT', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'KT', '', '', NULL);



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'KT');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'KT', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'KT', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'KT', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'KT', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'KT', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'KT', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, 'KT', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'KT', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'KT', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, 'KT', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'KT', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'KT', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'KT', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'KT', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'KT', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'KT', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'KT', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, 'KT', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'KT', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'KT', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'KT', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'KT', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'KT', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'KT', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'KT', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'KT', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, 'KT', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'KT', '', '', NULL);



-- *******************************************************



-- ********************************************************************
-- SIMPLE KITS MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED EXTENSIONS.
-- ********************************************************************


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', 'KT'),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', 'KT'),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', 'KT'),
		('91r', 'RLG STANDARDS NOTE (RLIN)', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', 'KT'),
		('93r', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 1, 0, '', 'KT'),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'KT'),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', 'KT'),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', 'KT'),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'KT'),
		('95r', 'CLUSTER MEMBER (RLIN)', 'CLUSTER MEMBER (RLIN)', 1, 0, '', 'KT'),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', 'KT'),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', 'KT'),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', 'KT'),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', 'KT'),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', 'KT'),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', 'KT'),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', 'KT'),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', 'KT'),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', 'KT'),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', 'KT'),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', 'KT'),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', 'KT'),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', 'KT'),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', 'KT'),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', 'KT'),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', 'KT'),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', 'KT'),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', 'KT'),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', 'KT'),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', 'KT'),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', 'KT'),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', 'KT'),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', 'KT'),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', 'KT'),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', 'KT'),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', 'KT'),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', 'KT'),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', 'KT');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, 'KT', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, 'KT', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, 'KT', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'KT', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'KT', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'KT', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'KT', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'KT', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, 'KT', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, 'KT', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'KT', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'KT', '', '', NULL);



-- ******************************************************


-- *****************************************************************
-- SIMPLE INTEGRATING RESOURCES KOHA RECORD AND HOLDINGS MANAGEMENT
-- FIELDS/SUBFIELDS.
-- *****************************************************************


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'IR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, 'IR', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, 'IR', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'IR', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'IR', '', '', NULL);


-- ******************************************************


-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, 'IR', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, 'IR', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', 'IR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, 'IR', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, 'IR', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, 'IR', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, 'IR', '', '', NULL),
		('942', 'c', 'Item type', 'Item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, 'IR', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, 'IR', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, 'IR', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, 'IR', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, 'biblioitems.cn_prefix', 9, '', '', '', NULL, 0, 'IR', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, 'IR', '', '', NULL);


-- ******************************************************


-- Recommended items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'IR');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'IR', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, 'IR', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, 'IR', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, 'IR', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'IR', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'IR', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'IR', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, 'IR', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'IR', '', '', NULL);



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'IR');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'IR', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'IR', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'IR', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'IR', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'IR', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'IR', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, 'IR', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'IR', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'IR', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, 'IR', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'IR', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'IR', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'IR', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'IR', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'IR', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'IR', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'IR', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, 'IR', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'IR', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'IR', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'IR', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'IR', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'IR', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'IR', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'IR', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'IR', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, 'IR', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'IR', '', '', NULL);



-- *******************************************************



-- *************************************************************************
-- SIMPLE INTEGRATING RESOURCES MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED
-- EXTENSIONS.
-- *************************************************************************


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', 'IR'),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', 'IR'),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', 'IR'),
		('91r', 'RLG STANDARDS NOTE (RLIN)', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', 'IR'),
		('93r', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 1, 0, '', 'IR'),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'IR'),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', 'IR'),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', 'IR'),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'IR'),
		('95r', 'CLUSTER MEMBER (RLIN)', 'CLUSTER MEMBER (RLIN)', 1, 0, '', 'IR'),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', 'IR'),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', 'IR'),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', 'IR'),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', 'IR'),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', 'IR'),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', 'IR'),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', 'IR'),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', 'IR'),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', 'IR'),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', 'IR'),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', 'IR'),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', 'IR'),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', 'IR'),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', 'IR'),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', 'IR'),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', 'IR'),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', 'IR'),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', 'IR'),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', 'IR'),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', 'IR'),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', 'IR'),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', 'IR'),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', 'IR'),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', 'IR'),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', 'IR'),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', 'IR'),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', 'IR'),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', 'IR');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, 'IR', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, 'IR', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, 'IR', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'IR', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'IR', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'IR', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'IR', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'IR', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, 'IR', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, 'IR', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'IR', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'IR', '', '', NULL);


-- *******************************************************


-- *********************************************************************
-- SIMPLE SERIALS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- *********************************************************************


-- Current Record ID Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'SER');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('999', 'a', 'Item type [OBSOLETE]', 'Item type [OBSOLETE]', 0, 0, NULL, -1, NULL, NULL, '', NULL, -5, 'SER', '', '', NULL),
		('999', 'b', 'Koha Dewey Subclass [OBSOLETE]', 'Koha Dewey Subclass [OBSOLETE]', 0, 0, NULL, 0, NULL, NULL, '', NULL, -5, 'SER', '', '', NULL),
		('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'SER', '', '', NULL),
		('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'SER', '', '', NULL);


-- ******************************************************


-- Plugins which need to be written for primary biblioitems Field/Subfields.


-- 		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', 'marc21_classcodes.pl', NULL, 0, 'SER', '', '', NULL),
-- 		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', 'marc21_callnumber.pl', NULL, 0, 'SER', '', '', NULL),



-- Current primary biblioitems Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('942', 'ADDED ENTRY ELEMENTS (KOHA)', 'ADDED ENTRY ELEMENTS (KOHA)', 0, 0, '', 'SER');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('942', '0', 'Koha issues (borrowed), all copies', 'Koha issues (borrowed), all copies', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, -5, 'SER', '', '', NULL),
		('942', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'biblioitems.cn_source', 9, '', '', '', NULL, 0, 'SER', '', '', NULL),
		('942', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'biblioitems.cn_sort', -1, '', '', '', 0, 7, 'SER', '', '', NULL),
		('942', 'a', 'Institution code [OBSOLETE]', 'Institution code [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -5, 'SER', '', '', NULL),
		('942', 'c', 'Item type', 'Item type', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 0, 'SER', '', '', NULL),
		('942', 'e', 'Edition', 'Edition', 0, 0, 'biblioitems.cn_edition', 9, 'CN_EDITION', '', '', NULL, 0, 'SER', '', '', NULL),
		('942', 'h', 'Classification part', 'Classification part', 0, 0, 'biblioitems.cn_class', 9, '', '', '', NULL, 0, 'SER', '', '', NULL),
		('942', 'i', 'Item part', 'Item part', 1, 0, 'biblioitems.cn_item', 9, '', '', '', NULL, 9, 'SER', '', '', NULL),
		('942', 'k', 'Call number prefix', 'Call number prefix', 0, 0, 'biblioitems.cn_prefix', 9, '', '', '', NULL, 0, 'SER', '', '', NULL),
		('942', 'm', 'Call number suffix', 'Call number suffix', 0, 0, 'biblioitems.cn_suffix', 9, '', '', '', 0, 0, 'SER', '', '', NULL);


-- ******************************************************


-- Recommended items Field/Subfields


-- INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
-- 		('95k', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'SER');

-- INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
-- 		('95k', '0', 'Item status (withdrawn) (similar to 876-8 $j)', 'Item status (withdrawn)', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', '1', 'Item status (lost) (similar to 876-8 $j)', 'Item status (lost)', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', '2', 'Source of classification or shelving scheme (similar to 852 $2)', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', '3', 'Materials specified (bound volume or other part) (similar to 852, 876-8 $3)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'SER', '', '', NULL),
-- 		('95k', '4', 'Item status (damaged) (similar to 876-8 $j)', 'Item status (damaged)', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', '5', 'Use restrictions (similar to 506 $a, 876-8 $h)', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', '6', 'Linkage (similar to 852, 876-8 $6)', 'Linkage', 0, 0, 'items.linkage', 10, '', '', '', NULL, -6, 'SER', '', '', NULL),
-- 		('95k', '7', 'Use restrictions (not for loan) (similar to 506 $a, 876-8 $h)', 'Use restrictions (not for loan)', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', '8', 'Sequence number (similar to 852, 876-8 $8)', 'Sequence number', 1, 0, 'items.sequence', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', '9', 'Koha itemnumber (autogenerated similar to 852, 876-8 $3 $8 $t combined)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, -5, 'SER', '', '', NULL),
-- 		('95k', 'a', 'Location (home branch) (similar to 852 $a)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'b', 'Sublocation or collection (holding branch) (similar to 852 $b)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'c', 'Shelving location (similar to 852 $c, 876-8 $l)', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'd', 'Date acquired (similar to 541, 876-8 $d)', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'e', 'Source of acquisition (similar to 541 $a, 876-8 $e)', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'f', 'Coded location qualifier (similar to 852 $f)', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'g', 'Non-coded location qualifier (similar to 852 $g)', 'Non-coded location qualifier', 1, 0, 'items.non_coded_location_qualifier', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'h', 'Classification part (similar to 852 $h)', 'Classification part', 0, 0, 'items.cn_class', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'i', 'Item part (similar to 852 $i)', 'Item part', 1, 0, 'items.cn_item', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'j', 'Shelving control number (similar to 852 $j)', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'k', 'Call number prefix (similar to 852 $k)', 'Call number prefix', 0, 0, 'items.cn_prefix', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'l', 'Shelving form of title (similar to 852 $l)', 'Shelving form of title', 0, 0, 'items.shelving_title', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'm', 'Cost, normal purchase price (similar to 541 $h, 876-8 $c)', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'n', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'o', 'Koha full call number (similar to 852 $k $h $i $m $t combined)', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'p', 'Piece designation (barcode) (similar to 852, 876-8 $p)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'q', 'Piece physical condition (similar to 562 $a, 852 $q)', 'Piece physical condition', 0, 0, 'items.condition', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'r', 'Invalid or canceled piece designation (canceled barcode) (similar to 876-8 $r)', 'Invalid or canceled piece designation (canceled barcode)', 1, 0, 'items.cancelled_barcode', 10, '', '', '', NULL, -1, 'SER', '', '', NULL),
-- 		('95k', 's', 'Copyright article-fee code (similar to 018 $a, 852 $s)', 'Copyright article-fee code', 1, 0, 'items.copyright_fee', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
-- 		('95k', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
-- 		('95k', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
-- 		('95k', 't', 'Copy number (similar to 852, 876-8 $t)', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
-- 		('95k', 'u', 'Uniform Resource Identifier (similar to 852 $u)', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'SER', '', '', NULL),
-- 		('95k', 'v', 'Cost, replacement price (similar to 365 $b, 876-8 $c)', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'w', 'Price effective from (similar to 365 $f)', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'SER', '', '', NULL),
-- 		('95k', 'x', 'Nonpublic note (lost item payment) (similar to 852, 876-8 $x)', 'Nonpublic note', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'SER', '', '', NULL),
-- 		('95k', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -5, 'SER', '', '', NULL),
-- 		('95k', 'z', 'Public note (similar to 852, 876-8 $z)', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'SER', '', '', NULL);



-- Current items Field/Subfields


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('952', 'LOCATION AND ITEM INFORMATION (KOHA)', 'LOCATION AND ITEM INFORMATION (KOHA)', 1, 0, '', 'SER');

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('952', '0', 'Withdrawn status', 'Withdrawn status', 0, 0, 'items.wthdrawn', 10, 'WITHDRAWN', '', '', 0, 0, 'SER', '', '', NULL),
		('952', '1', 'Lost status', 'Lost status', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, 'SER', '', '', NULL),
		('952', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, 'items.cn_source', 10, '', '', 'marc21_classcodes.pl', NULL, 0, 'SER', '', '', NULL),
		('952', '3', 'Materials specified (bound volume or other part)', 'Materials specified (bound volume or other part)', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, 'SER', '', '', NULL),
		('952', '4', 'Damaged status', 'Damaged status', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, 'SER', '', '', NULL),
		('952', '5', 'Use restrictions', 'Use restrictions', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, 'SER', '', '', NULL),
		('952', '6', 'Koha normalized classification for sorting', 'Koha normalized classification for sorting', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, 'SER', '', '', NULL),
		('952', '7', 'Not for loan', 'Not for loan', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, 'SER', '', '', NULL),
		('952', '8', 'Koha collection', 'Koha collection', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, 'SER', '', '', NULL),
		('952', '9', 'Koha itemnumber (autogenerated)', 'Koha itemnumber', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 7, 'SER', '', '', NULL),
		('952', 'a', 'Location (home branch)', 'Location (home branch)', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, 'SER', '', '', NULL),
		('952', 'b', 'Sublocation or collection (holding branch)', 'Sublocation or collection (holding branch)', 1, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, 'SER', '', '', NULL),
		('952', 'c', 'Shelving location', 'Shelving location', 1, 0, 'items.location', 10, 'LOC', '', '', 0, 0, 'SER', '', '', NULL),
		('952', 'd', 'Date acquired', 'Date acquired', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, 'SER', '', '', NULL),
		('952', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, 'items.booksellerid', 10, '', '', 'bookseller.pl', 0, 0, 'SER', '', '', NULL),
		('952', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, 'items.coded_location_qualifier', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, 'SER', '', '', NULL),
		('952', 'g', 'Cost, normal purchase price', 'Cost, normal purchase price', 0, 0, 'items.price', 10, '', '', '', 0, 0, 'SER', '', '', NULL),
		('952', 'j', 'Shelving control number', 'Shelving control number', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, 'SER', '', '', NULL),
		('952', 'l', 'Koha issues (times borrowed)', 'Koha issues (times borrowed)', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
		('952', 'm', 'Koha renewals', 'Koha renewals', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
		('952', 'n', 'Koha reserves (requests)', 'Koha reserves (requests)', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
		('952', 'o', 'Koha full call number', 'Koha full call number', 0, 0, 'items.itemcallnumber', 10, '', 'marc21_itemcallnumber.pl', NULL, 0, 0, 'SER', '', '', NULL),
		('952', 'p', 'Piece designation (barcode)', 'Piece designation (barcode)', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, 'SER', '', '', NULL),
		('952', 'q', 'Koha out on loan', 'Koha out on loan', 1, 0, 'items.onloan', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
		('952', 'r', 'Koha date last seen', 'Koha date last seen', 1, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
		('952', 's', 'Koha date last borrowed', 'Koha date last borrowed', 1, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, 'SER', '', '', NULL),
		('952', 't', 'Copy number', 'Copy number', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, 'SER', '', '', NULL),
		('952', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'items.uri', 10, '', '', '', 1, 0, 'SER', '', '', NULL),
		('952', 'v', 'Cost, replacement price', 'Cost, replacement price', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, 'SER', '', '', NULL),
		('952', 'w', 'Price effective from', 'Price effective from', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, 'SER', '', '', NULL),
		('952', 'x', 'Nonpublic note (lost item payment)', 'Nonpublic note (lost item payment)', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, 'SER', '', '', NULL),
		('952', 'y', 'Koha item type', 'Koha item type', 1, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, -1, 'SER', '', '', NULL),
		('952', 'z', 'Public note', 'Public note', 1, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, 'SER', '', '', NULL);



-- *******************************************************


-- ***********************************************************************
-- SIMPLE SERIALS MARC 21 FIELDS/SUBFIELDS AND COMMMONLY USED EXTENSIONS.
-- ***********************************************************************


INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
		('01e', 'CODED FIELD ERROR (RLIN)', 'CODED FIELD ERROR (RLIN)', 1, 0, '', 'SER'),
		('89e', 'ERRONEOUS FIELD, ERR (RLIN)', 'ERRONEOUS FIELD, ERR (RLIN)', 1, 0, '', 'SER'),
		('91c', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 'EQUIVALENCE OR CROSS-REFERENCE-CORPORATE NAME [LOCAL, CANADA]', 1, 0, '', 'SER'),
		('91r', 'RLG STANDARDS NOTE (RLIN)', 'RLG STANDARDS NOTE (RLIN)', 1, 0, '', 'SER'),
		('93r', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 'SUMMARY HOLDINGS STATEMENT (RLIN)', 1, 0, '', 'SER'),
		('94c', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE--TITLE [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'SER'),
		('94a', 'ANALYSIS TREATMENT NOTE (RLIN)', 'ANALYSIS TREATMENT NOTE (RLIN)', 1, 0, '', 'SER'),
		('94b', 'TREATMENT CODES (RLIN)', 'TREATMENT CODES (RLIN)', 1, 0, '', 'SER'),
		('95c', 'EQUIVALENCE OR CROSS-REFERENCE--HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 'EQUIVALENCE OR CROSS-REFERENCE-HIERARCHICAL PLACE NAME [OBSOLETE] [CAN/MARC only]', 1, 0, '', 'SER'),
		('95r', 'CLUSTER MEMBER (RLIN)', 'CLUSTER MEMBER (RLIN)', 1, 0, '', 'SER'),
		('b99', 'PRIVATE LOCAL INFORMATION (RLIN)', 'PRIVATE LOCAL INFORMATION (RLIN)', 1, 0, '', 'SER'),
		('u01', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 'UNIT IDENTIFICATION, STATUS, AND TYPE (RLIN)', 0, 0, '', 'SER'),
		('u02', 'STANDARD NUMBER (RLIN)', 'STANDARD NUMBER (RLIN)', 0, 0, '', 'SER'),
		('u08', 'CODED INFORMATION (RLIN)', 'CODED INFORMATION (RLIN)', 0, 0, '', 'SER'),
		('u10', 'REQUESTER IDENTIFICATION (RLIN)', 'REQUESTER IDENTIFICATION (RLIN)', 1, 0, '', 'SER'),
		('u11', 'DEPARTMENT REPORT REQUEST (RLIN)', 'DEPARTMENT REPORT REQUEST (RLIN)', 1, 0, '', 'SER'),
		('u20', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 'SUPPLIER IDENTIFICATION, SUPN (RLIN)', 0, 0, '', 'SER'),
		('u21', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 'LIBRARY CODES FOR VENDOR AND ORDER (RLIN)', 0, 0, '', 'SER'),
		('u22', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 'SUPPLIER CODES AND CATALOG INFORMATION (RLIN)', 0, 0, '', 'SER'),
		('u25', 'SUPPLIER REPORT(S) (RLIN)', 'SUPPLIER REPORT(S) (RLIN)', 0, 0, '', 'SER'),
		('u30', 'INTERVALS (RLIN)', 'INTERVALS (RLIN)', 0, 0, '', 'SER'),
		('u31', 'CLAIM COUNTS (RLIN)', 'CLAIM COUNTS (RLIN)', 0, 0, '', 'SER'),
		('u33', 'INVOICE CLAIM (RLIN)', 'INVOICE CLAIM (RLIN)', 0, 0, '', 'SER'),
		('u34', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 'EXTENDED PROCUREMENT CLAIM AND REVIEW (RLIN)', 0, 0, '', 'SER'),
		('u40', 'EXTENDED PROCUREMENT CODES (RLIN)', 'EXTENDED PROCUREMENT CODES (RLIN)', 0, 0, '', 'SER'),
		('u50', 'ACQUISITIONS NOTES (RLIN)', 'ACQUISITIONS NOTES (RLIN)', 0, 0, '', 'SER'),
		('u51', 'SELECTION NOTES (RLIN)', 'SELECTION NOTES (RLIN)', 0, 0, '', 'SER'),
		('u52', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 'SUPPLIER INSTRUCTIONS AND NOTES, SINT (RLIN)', 0, 0, '', 'SER'),
		('u53', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 'CLAIM INSTRUCTIONS AND NOTES, CLNT (RLIN)', 0, 0, '', 'SER'),
		('u54', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 'NOTES TO SERIALS DEPARTMENT (RLIN)', 0, 0, '', 'SER'),
		('u55', 'CATALOGING NOTES (RLIN)', 'CATALOGING NOTES (RLIN)', 0, 0, '', 'SER'),
		('u5f', 'ACCOUNTING NOTES (RLIN)', 'ACCOUNTING NOTES (RLIN)', 0, 0, '', 'SER'),
		('u70', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 'MATERIAL AND LOCATION INFORMATION (RLIN)', 0, 0, '', 'SER'),
		('u71', 'FUND ACCOUNT (RLIN)', 'FUND ACCOUNT (RLIN)', 0, 0, '', 'SER'),
		('u75', 'ITEM DETAILS (RLIN)', 'ITEM DETAILS (RLIN)', 1, 0, '', 'SER'),
		('u7f', 'PRICE INFORMATION (RLIN)', 'PRICE INFORMATION (RLIN)', 1, 0, '', 'SER'),
		('u90', 'TAPE OUTPUT, TAPE (RLIN)', 'TAPE OUTPUT, TAPE (RLIN)', 0, 0, '', 'SER'),
		('ufi', 'FISCAL INFORMATION, FI (RLIN)', 'FISCAL INFORMATION, FI (RLIN)', 1, 0, '', 'SER');



INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('01e', 'a', 'Coded field error', 'Coded field error', 0, 0, '', 0, '', '', '', 0, -6, 'SER', '', '', NULL),
		('89e', '0', '0', '0', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '1', '1', '1', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '2', '2', '2', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '3', '3', '3', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '4', '4', '4', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '5', '5', '5', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '6', '6', '6', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '7', '7', '7', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '8', '8', '8', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', '9', '9', '9', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'a', 'a', 'a', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'b', 'b', 'b', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'c', 'c', 'c', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'd', 'd', 'd', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'e', 'e', 'e', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'f', 'f', 'f', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'g', 'g', 'g', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'h', 'h', 'h', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'i', 'i', 'i', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'j', 'j', 'j', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'k', 'k', 'k', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'l', 'l', 'l', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'm', 'm', 'm', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'n', 'n', 'n', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'o', 'o', 'o', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'p', 'p', 'p', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'q', 'q', 'q', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'r', 'r', 'r', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 's', 's', 's', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 't', 't', 't', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'u', 'u', 'u', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'v', 'v', 'v', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'w', 'w', 'w', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'x', 'x', 'x', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'y', 'y', 'y', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('89e', 'z', 'z', 'z', 1, 0, '', 8, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', '4', 'Relator code', 'Relator code', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'a', 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'b', 'Subordinate unit', 'Subordinate unit', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'c', 'Location of meeting', 'Location of meeting', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'd', 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'e', 'Relator term', 'Relator term', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'f', 'Date of a work', 'Date of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'g', 'Miscellaneous information', 'Miscellaneous information', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'k', 'Form subheading', 'Form subheading', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'l', 'Language of a work', 'Language of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'n', 'Number of part/section/meeting', 'Number of part/section/meeting', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 't', 'Title of a work', 'Title of a work', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91c', 'u', 'Affiliation', 'Affiliation', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('91r', 'a', 'RLG standards note', 'RLG standards note', 0, 0, '', 9, '', '', '', 0, -6, 'SER', '', '', NULL),
		('93r', 'a', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'b', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'c', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'd', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'e', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'f', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'g', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'h', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'i', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('93r', 'k', 'SHS', 'SHS', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('94c', '6', 'Linkage', 'Linkage', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'a', 'Title', 'Title', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'b', 'Remainder of title', 'Remainder of title', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'c', 'Statement of responsibility, etc', 'Statement of responsibility, etc', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'd', 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'e', 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'f', 'Inclusive dates', 'Inclusive dates', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'g', 'Bulk dates', 'Bulk dates', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'h', 'Medium', 'Medium', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'k', 'Form', 'Form', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'n', 'Number of part/section of a work', 'Number of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 'p', 'Name of part/section of a work', 'Name of part/section of a work', 1, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94c', 's', 'Version', 'Version', 0, 0, '', 9, '', '', '', NULL, -6, 'SER', '', '', NULL),
		('94a', 'a', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SER', '', '', NULL),
		('94a', 'b', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SER', '', '', NULL),
		('94a', 'c', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SER', '', '', NULL),
		('94a', 'd', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SER', '', '', NULL),
		('94a', 'e', 'ATN', 'ATN', 0, 0, '', 9, '', '', '', 0, -6, 'SER', '', '', NULL),
		('94b', 'a', 'ATC', 'ATC', 0, 0, '', 9, '', '', '', 0, -6, 'SER', '', '', NULL),
		('94b', 'b', 'SNR', 'SNR', 0, 0, '', 9, '', '', '', 0, -6, 'SER', '', '', NULL),
		('95c', 'a', 'Country', 'Country', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('95c', 'b', 'State, province, territory', 'State, province, territory', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('95c', 'c', 'County, region, islands area', 'County, region, islands area', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('95c', 'd', 'City', 'City', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('95r', '6', 'Linkage', 'Linkage', 0, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('95r', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 9, NULL, NULL, '', NULL, 5, 'SER', '', '', NULL),
		('95r', 'a', 'Record ID (RLIN)', 'Record ID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('95r', 'b', 'Institution name (RLIN)', 'Institution name (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u01', 'a', 'Operator\'s initials, OID (RLIN)', 'Operator\'s initials, OID (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u01', 'd', 'UAD (RLIN)', 'UAD (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u01', 'f', 'FPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u01', 'h', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u01', 'i', 'CPST (RLIN)', 'FPST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u01', 's', 'UST (RLIN)', 'UST (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u01', 't', 'UTYP (RLIN)', 'UTYP (RLIN)', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u02', '2', 'Source of number or code', 'Source of number or code', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u02', 'a', 'Standard number or code', 'Standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u02', 'b', 'Additional codes following the standard number', 'Additional codes following the standard number', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u02', 'c', 'Terms of availability', 'Terms of availability', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u02', 'z', 'Canceled/invalid standard number or code', 'Canceled/invalid standard number or code', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u08', 'n', 'LSI', 'LSI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u08', 'o', 'SID', 'SID', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u08', 'p', 'DP', 'DP', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u08', 'r', 'RUSH', 'RUSH', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u10', 'a', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u10', 'b', 'SID', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u10', 'c', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u10', 'd', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u10', 'e', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u10', 's', 'REQ', 'REQ', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u11', 'a', 'Department report request, DRR (DRRH for earlier occurrences)', 'DRR (DRRH for earlier occurrences)', 1, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u20', 'a', 'SUPN', 'SUPN', 1, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u20', 'b', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u20', 'c', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u20', 'd', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u20', 'e', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u20', 'x', 'SUPN', 'SUPN', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u21', 'a', 'SHIP', 'SHIP', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u21', 'b', 'BILL', 'BILL', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u21', 'c', 'DAC', 'DAC', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u21', 'n', 'LSAC', 'LSAC', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u22', 'a', 'SICO', 'SICO', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u22', 'b', 'SICO', 'SICO', 1, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u22', 'c', 'SCAT', 'SCAT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u25', 'a', 'Supplier report(s), SRPT', 'Supplier report(s), SRPT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u30', 'a', 'NCC [OBSOLETE]', 'NCC [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u30', 'i', 'ICI', 'ICI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u30', 'm', 'MCI', 'MCI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u31', 'a', 'NCC', 'NCC', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u31', 'b', 'NCS', 'NCS', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u33', 'a', 'ICL', 'ICL', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u33', 'd', 'ICAD', 'ICAD', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u34', 'a', 'EPCL', 'EPCL', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u34', 'r', 'ERI', 'ERI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u40', 'd', 'EPDT [OBSOLETE]', 'EPDT [OBSOLETE]', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u40', 'f', 'EFRQ', 'EFRQ', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u40', 's', 'EPST', 'EPST', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u40', 't', 'ETYP', 'ETYP', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u50', 'a', 'Acquisitions notes, AQNT', 'Acquisitions notes, AQNT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u51', 'a', 'Selection notes, SLNT', 'Selection notes, SLNT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u52', 'a', 'INT', 'INT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u52', 'b', 'INT', 'NT', 1, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u53', 'a', 'CLNT', 'CLNT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u53', 'b', 'CLNT', 'CLNT', 1, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u54', 'a', 'Notes to serials department, SRNT', 'Notes to serials department, SRNT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u55', 'a', 'Cataloging notes, CTNT', 'Cataloging notes, CTNT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u5f', 'a', 'Accounting notes, ACNT', 'Accounting notes, ACNT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u70', 'a', 'QTY', 'QTY', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u70', 'b', 'MAT', 'MAT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u70', 'l', 'MLOC', 'MLOC', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u71', 'a', 'Fund account, FUND', 'Fund account, FUND', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u75', 'a', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u75', 'c', 'CIRC', 'CIRC', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u75', 'h', 'IPST', 'IPST', 1, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u75', 'i', 'ITEM', 'ITEM', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u75', 'l', 'SLOC', 'SLOC', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u7f', 'a', 'LPRI', 'LPRI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u7f', 'b', 'CURR', 'CURR', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u7f', 'k', 'CVRT [OBSOLETE]', 'CVRT [OBSOLETE]', 1, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u7f', 'p', 'LPD', 'LPD', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u7f', 'r', 'EDRT', 'EDRT', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u90', 'h', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('u90', 'i', 'TAPE', 'TAPE', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'a', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'b', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'c', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'd', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'e', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'f', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'g', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'h', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL),
		('ufi', 'n', 'FI', 'FI', 0, 0, '', 9, '', '', '', 0, 5, 'SER', '', '', NULL);


