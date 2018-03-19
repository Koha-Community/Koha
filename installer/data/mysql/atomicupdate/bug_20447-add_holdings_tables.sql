--
-- Table structure for table `holdings`
--

CREATE TABLE `holdings` ( -- table that stores summary holdings information
    `holding_id` int(11) NOT NULL auto_increment, -- unique identifier assigned to each holdings record
    `biblionumber` int(11) NOT NULL default 0, -- foreign key from biblio table used to link this record to the right bib record
    `biblioitemnumber` int(11) NOT NULL default 0, -- foreign key from the biblioitems table to link record to additional information
    `frameworkcode` varchar(4) NOT NULL default '', -- foreign key from the biblio_framework table to identify which framework was used in cataloging this record
    `holdingbranch` varchar(10) default NULL, -- foreign key from the branches table for the library that owns this record (MARC21 852$a)
    `location` varchar(80) default NULL, -- authorized value for the shelving location for this record (MARC21 852$b)
    `callnumber` varchar(255) default NULL, -- call number (852$h+$i in MARC21)
    `suppress` tinyint(1) default NULL, -- Boolean indicating whether the record is suppressed in OPAC
    `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, -- date and time this record was last touched
    `datecreated` DATE NOT NULL, -- the date this record was added to Koha
    `deleted_on` DATETIME DEFAULT NULL, -- the date this record was deleted
    PRIMARY KEY  (`holding_id`),
    KEY `hldnoidx` (`holding_id`),
    KEY `hldbinoidx` (`biblioitemnumber`),
    KEY `hldbibnoidx` (`biblionumber`),
    CONSTRAINT `holdings_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `holdings_ibfk_2` FOREIGN KEY (`biblioitemnumber`) REFERENCES `biblioitems` (`biblioitemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `holdings_ibfk_3` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `holdings_metadata`
--

CREATE TABLE holdings_metadata (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `holding_id` INT(11) NOT NULL,
    `format` VARCHAR(16) NOT NULL,
    `marcflavour` VARCHAR(16) NOT NULL,
    `metadata` LONGTEXT NOT NULL,
    `deleted_on` DATETIME DEFAULT NULL, -- the date this record was deleted
    PRIMARY KEY(id),
    UNIQUE KEY `holdings_metadata_uniq_key` (`holding_id`,`format`,`marcflavour`),
    KEY `hldnoidx` (`holding_id`),
    CONSTRAINT `holdings_metadata_fk_1` FOREIGN KEY (`holding_id`) REFERENCES `holdings` (`holding_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Add holding_id to items table
--

ALTER TABLE `items` ADD COLUMN `holding_id` int(11) default NULL;
ALTER TABLE `items` ADD CONSTRAINT `items_ibfk_5` FOREIGN KEY (`holding_id`) REFERENCES `holdings` (`holding_id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `items` ADD KEY `hldid_idx` (`holding_id`);

--
-- Add holding_id to deleteditems table
--

ALTER TABLE `deleteditems` ADD COLUMN `holding_id` int(11) default NULL;

--
-- Insert a new category to authorised_value_categories table
--

INSERT INTO authorised_value_categories( category_name ) VALUES ('holdings');


--
-- Insert 999e to the default framework
--

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
        ('999', 'e', 'Koha holding_id', 'Koha holding_id', 0, 0, 'holdings.holding_id', -1, NULL, NULL, '', NULL, -5, '', '', '', NULL);


--
-- Insert 952v to marc_subfield_structure table
--

INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
        ('952', 'V', 'Holding record',  'Holding record',  0, 0, 'items.holding_id', 10, 'holdings', '', '', NULL, 0,  '', '', '', NULL);

-- HOLDINGS RECORD FRAMEWORK

INSERT IGNORE INTO `biblio_framework` (`frameworkcode`, `frameworktext`) VALUES ('HLD', 'Default holdings framework');
INSERT IGNORE INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
        ('999', 'SYSTEM CONTROL NUMBERS (KOHA)', 'SYSTEM CONTROL NUMBERS (KOHA)', 1, 0, '', 'HLD');

INSERT IGNORE INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
        ('999', 'c', 'Koha biblionumber', 'Koha biblionumber', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'HLD', '', '', NULL),
        ('999', 'd', 'Koha biblioitemnumber', 'Koha biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'HLD', '', '', NULL),
        ('999', 'e', 'Koha holding_id', 'Koha holding_id', 0, 0, 'holdings.holding_id', -1, NULL, NULL, '', NULL, -5, 'HLD', '', '', NULL);


INSERT IGNORE INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
        ('942', 'n', 'Suppress in OPAC', 'Suppress in OPAC', 0, 0, 'holdings.suppress', 9, '', '', '', 0, 0, 'HLD', '', '', NULL);

INSERT IGNORE INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
        ('000', 'LEADER', 'LEADER', 0, 1, '', 'HLD'),
        ('001', 'CONTROL NUMBER', 'CONTROL NUMBER', 0, 0, '', 'HLD'),
        ('003', 'CONTROL NUMBER IDENTIFIER', 'CONTROL NUMBER IDENTIFIER', 0, 1, '', 'HLD'),
        ('005', 'DATE AND TIME OF LATEST TRANSACTION', 'DATE AND TIME OF LATEST TRANSACTION', 0, 1, '', 'HLD'),
        ('006', 'FIXED-LENGTH DATA ELEMENTS--ADDITIONAL MATERIAL CHARACTERISTICS', 'FIXED-LENGTH DATA ELEMENTS--ADDITIONAL MATERIAL CHARACTERISTICS', 1, 0, '', 'HLD'),
        ('007', 'PHYSICAL DESCRIPTION FIXED FIELD--GENERAL INFORMATION', 'PHYSICAL DESCRIPTION FIXED FIELD--GENERAL INFORMATION', 1, 0, '', 'HLD'),
        ('008', 'FIXED-LENGTH DATA ELEMENTS--GENERAL INFORMATION', 'FIXED-LENGTH DATA ELEMENTS--GENERAL INFORMATION', 0, 1, '', 'HLD');

INSERT IGNORE INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
        ('850', 'HOLDING INSTITUTION', 'HOLDING INSTITUTION', 1, 0, NULL, 'HLD'),
        ('852', 'LOCATION', 'LOCATION', 1, 0, NULL, 'HLD'),
        ('853', 'CAPTIONS AND PATTERN--BASIC BIBLIOGRAPHIC UNIT', 'CAPTIONS AND PATTERN--BASIC BIBLIOGRAPHIC UNIT', 1, 0, NULL, 'HLD'),
        ('854', 'CAPTIONS AND PATTERN--SUPPLEMENTARY MATERIAL', 'CAPTIONS AND PATTERN--SUPPLEMENTARY MATERIAL', 1, 0, NULL, 'HLD'),
        ('855', 'CAPTIONS AND PATTERN--INDEXES', 'CAPTIONS AND PATTERN--INDEXES', 1, 0, NULL, 'HLD'),
        ('856', 'ELECTRONIC LOCATION AND ACCESS', 'ELECTRONIC LOCATION AND ACCESS', 1, 0, NULL, 'HLD'),
        ('863', 'ENUMERATION AND CHRONOLOGY--BASIC BIBLIOGRAPHIC UNIT', 'ENUMERATION AND CHRONOLOGY--BASIC BIBLIOGRAPHIC UNIT', 1, 0, NULL, 'HLD'),
        ('864', 'ENUMERATION AND CHRONOLOGY--SUPPLEMENTARY MATERIAL', 'ENUMERATION AND CHRONOLOGY--SUPPLEMENTARY MATERIAL', 1, 0, NULL, 'HLD'),
        ('865', 'ENUMERATION AND CHRONOLOGY--INDEXES', 'ENUMERATION AND CHRONOLOGY--INDEXES', 1, 0, NULL, 'HLD'),
        ('866', 'TEXTUAL HOLDINGS--BASIC BIBLIOGRAPHIC UNIT', 'TEXTUAL HOLDINGS--BASIC BIBLIOGRAPHIC UNIT', 1, 0, NULL, 'HLD'),
        ('867', 'TEXTUAL HOLDINGS--SUPPLEMENTARY MATERIAL', 'TEXTUAL HOLDINGS--SUPPLEMENTARY MATERIAL', 1, 0, NULL, 'HLD'),
        ('868', 'TEXTUAL HOLDINGS--INDEXES', 'TEXTUAL HOLDINGS--INDEXES', 1, 0, NULL, 'HLD'),
        ('876', 'ITEM INFORMATION--BASIC BIBLIOGRAPHIC UNIT', 'ITEM INFORMATION--BASIC BIBLIOGRAPHIC UNIT', 1, 0, NULL, 'HLD'),
        ('877', 'ITEM INFORMATION--SUPPLEMENTARY MATERIAL', 'ITEM INFORMATION--SUPPLEMENTARY MATERIAL', 1, 0, NULL, 'HLD'),
        ('878', 'ITEM INFORMATION--INDEXES', 'ITEM INFORMATION--INDEXES', 1, 0, NULL, 'HLD');

INSERT IGNORE INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
        ('000', '@', 'fixed length control field', 'fixed length control field', 0, 1, '', 0, '', '', 'marc21_leader_holdings.pl', 0, 0, 'HLD', '', '', NULL),
        ('001', '@', 'control field', 'control field', 0, 0, '', 0, '', '', '', 0, 0, 'HLD', '', '', NULL),
        ('003', '@', 'control field', 'control field', 0, 1, '', 0, '', '', 'marc21_orgcode.pl', 0, 0, 'HLD', '', '', NULL),
        ('005', '@', 'control field', 'control field', 0, 1, '', 0, '', '', 'marc21_field_005.pl', 0, 0, 'HLD', '', '', NULL),
        ('006', '@', 'fixed length control field', 'fixed length control field', 0, 0, '', 0, '', '', 'marc21_field_006.pl', 0, -1, 'HLD', '', '', NULL),
        ('007', '@', 'fixed length control field', 'fixed length control field', 0, 0, '', 0, '', '', 'marc21_field_007.pl', 0, 0, 'HLD', '', '', NULL),
        ('008', '@', 'fixed length control field', 'fixed length control field', 0, 1, '', 0, '', '', 'marc21_field_008_holdings.pl', 0, 0, 'HLD', '', '', NULL),
        ('850', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, NULL, 8, NULL, NULL, '', NULL, 4, 'HLD', '', '', NULL),
        ('850', 'a', 'Holding institution', 'Holding institution', 1, 0, NULL, 8, NULL, NULL, '', NULL, 4, 'HLD', '', '', NULL),
        ('850', 'b', 'Holdings (NR) (MU VM SE) [OBSOLETE]', 'Holdings (NR) (MU VM SE) [OBSOLETE]', 0, 0, NULL, 8, NULL, NULL, '', NULL, 4, 'HLD', '', '', NULL),
        ('850', 'd', 'Inclusive dates (NR) (MU VM SE) [OBSOLETE]', 'Inclusive dates (NR) (MU VM SE) [OBSOLETE]', 0, 0, NULL, 8, NULL, NULL, '', NULL, 4, 'HLD', '', '', NULL),
        ('850', 'e', 'Retention statement (NR) (CF MU VM SE) [OBSOLETE]', 'Retention statement (NR) (CF MU VM SE) [OBSOLETE]', 0, 0, NULL, 8, NULL, NULL, '', NULL, 4, 'HLD', '', '', NULL),
        ('852', '2', 'Source of classification or shelving scheme', 'Source of classification or shelving scheme', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', '3', 'Materials specified', 'Materials specified', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', '8', 'Sequence number', 'Sequence number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'a', 'Location', 'Location', 0, 0, 'holdings.holdingbranch', 8, 'branches', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'b', 'Sublocation or collection', 'Sublocation or collection', 1, 0, 'holdings.location', 8, 'LOC', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'c', 'Shelving location', 'Shelving location', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'd', 'Former shelving location', 'Former shelving location', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'e', 'Address', 'Address', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'f', 'Coded location qualifier', 'Coded location qualifier', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'g', 'Non-coded location qualifier', 'Non-coded location qualifier', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'h', 'Classification part', 'Classification part', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'i', 'Item part', 'Item part', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'j', 'Shelving control number', 'Shelving control number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'k', 'Call number prefix', 'Call number prefix', 1, 0, 'holdings.callnumber', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'l', 'Shelving form of title', 'Shelving form of title', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'm', 'Call number suffix', 'Call number suffix', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'n', 'Country code', 'Country code', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'p', 'Piece designation', 'Piece designation', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'q', 'Piece physical condition', 'Piece physical condition', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 's', 'Copyright article-fee code', 'Copyright article-fee code', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 't', 'Copy number', 'Copy number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, '', 8, '', '', '', 1, 4, 'HLD', '', '', NULL),
        ('852', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('852', 'z', 'Public note', 'Public note', 1, 0, 'holdings.public_note', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', '3', 'Materials specified', 'Materials specified', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'a', 'First level of enumeration', 'First level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'b', 'Second level of enumeration', 'Second level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'c', 'Third level of enumeration', 'Third level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'd', 'Fourth level of enumeration', 'Fourth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'e', 'Fifth level of enumeration', 'Fifth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'f', 'Sixth level of enumeration', 'Sixth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'g', 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'h', 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'i', 'First level of chronology', 'First level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'j', 'Second level of chronology', 'Second level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'k', 'Third level of chronology', 'Third level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'l', 'Fourth level of chronology', 'Fourth level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'm', 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'n', 'Pattern note', 'Pattern note', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'p', 'Number of pieces per issuance', 'Number of pieces per issuance', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 't', 'Copy', 'Copy', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'u', 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'v', 'Numbering continuity', 'Numbering continuity', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'w', 'Frequency', 'Frequency', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'x', 'Calendar change', 'Calendar change', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'y', 'Regularity pattern', 'Regularity pattern', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('853', 'z', 'Numbering scheme', 'Numbering scheme', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', '3', 'Materials specified', 'Materials specified', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'a', 'First level of enumeration', 'First level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'b', 'Second level of enumeration', 'Second level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'c', 'Third level of enumeration', 'Third level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'd', 'Fourth level of enumeration', 'Fourth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'e', 'Fifth level of enumeration', 'Fifth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'f', 'Sixth level of enumeration', 'Sixth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'g', 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'h', 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'i', 'First level of chronology', 'First level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'j', 'Second level of chronology', 'Second level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'k', 'Third level of chronology', 'Third level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'l', 'Fourth level of chronology', 'Fourth level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'm', 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'n', 'Pattern note', 'Pattern note', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'p', 'Number of pieces per issuance', 'Number of pieces per issuance', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 't', 'Copy', 'Copy', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'u', 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'v', 'Numbering continuity', 'Numbering continuity', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'w', 'Frequency', 'Frequency', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'x', 'Calendar change', 'Calendar change', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'y', 'Regularity pattern', 'Regularity pattern', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('854', 'z', 'Numbering scheme', 'Numbering scheme', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', '3', 'Materials specified', 'Materials specified', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'a', 'First level of enumeration', 'First level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'b', 'Second level of enumeration', 'Second level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'c', 'Third level of enumeration', 'Third level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'd', 'Fourth level of enumeration', 'Fourth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'e', 'Fifth level of enumeration', 'Fifth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'f', 'Sixth level of enumeration', 'Sixth level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'g', 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'h', 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'i', 'First level of chronology', 'First level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'j', 'Second level of chronology', 'Second level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'k', 'Third level of chronology', 'Third level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'l', 'Fourth level of chronology', 'Fourth level of chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'm', 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'n', 'Pattern note', 'Pattern note', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'p', 'Number of pieces per issuance', 'Number of pieces per issuance', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 't', 'Copy', 'Copy', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'u', 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'v', 'Numbering continuity', 'Numbering continuity', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'w', 'Frequency', 'Frequency', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'x', 'Calendar change', 'Calendar change', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'y', 'Regularity pattern', 'Regularity pattern', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('855', 'z', 'Numbering scheme', 'Numbering scheme', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('856', '2', 'Access method', 'Access method', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', '3', 'Materials specified', 'Materials specified', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'a', 'Host name', 'Host name', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'b', 'Access number', 'Access number', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'c', 'Compression information', 'Compression information', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'd', 'Path', 'Path', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'f', 'Electronic name', 'Electronic name', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'h', 'Processor of request', 'Processor of request', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'i', 'Instruction', 'Instruction', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'j', 'Bits per second', 'Bits per second', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'k', 'Password', 'Password', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'l', 'Logon', 'Logon', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'm', 'Contact for access assistance', 'Contact for access assistance', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'n', 'Name of location of host', 'Name of location of host', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'o', 'Operating system', 'Operating system', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'p', 'Port', 'Port', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'q', 'Electronic format type', 'Electronic format type', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'r', 'Settings', 'Settings', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 's', 'File size', 'File size', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 't', 'Terminal emulation', 'Terminal emulation', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, 'biblioitems.url', 8, '', '', '', 1, 4, 'HLD', '', '', NULL),
        ('856', 'v', 'Hours access method available', 'Hours access method available', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'w', 'Record control number', 'Record control number', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'y', 'Link text', 'Link text', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('856', 'z', 'Public note', 'Public note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('863', '8', 'Field link and sequence number', 'Field link and sequence number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('863', 'a', 'First level of enumeration', 'First level of enumeration', 0, 0, 'holdings.summary', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'b', 'Second level of enumeration', 'Second level of enumeration', 0, 0, 'holdings.summary', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'c', 'Third level of enumeration', 'Third level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'd', 'Fourth level of enumeration', 'Fourth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'e', 'Fifth level of enumeration', 'Fifth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'f', 'Sixth level of enumeration', 'Sixth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'g', 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'h', 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'i', 'First level of chronology', 'First level of chronology', 0, 0, 'holdings.summary', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'j', 'Second level of chronology', 'Second level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'k', 'Third level of chronology', 'Third level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'l', 'Fourth level of chronology', 'Fourth level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'm', 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'n', 'Converted Gregorian year', 'Converted Gregorian year', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'o', 'Type of unit', 'Type of unit', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'p', 'Piece designation', 'Piece designation', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'q', 'Piece physical condition', 'Piece physical condition', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 's', 'Copyright article-fee code', 'Copyright article-fee code', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 't', 'Copy number', 'Copy number', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'v', 'Issuing date', 'Issuing date', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'w', 'Break indicator', 'Break indicator', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('863', 'z', 'Public note', 'Public note', 1, 0, 'holdings.summary', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('864', '8', 'Field link and sequence number', 'Field link and sequence number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('864', 'a', 'First level of enumeration', 'First level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'b', 'Second level of enumeration', 'Second level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'c', 'Third level of enumeration', 'Third level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'd', 'Fourth level of enumeration', 'Fourth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'e', 'Fifth level of enumeration', 'Fifth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'f', 'Sixth level of enumeration', 'Sixth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'g', 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'h', 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'i', 'First level of chronology', 'First level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'j', 'Second level of chronology', 'Second level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'k', 'Third level of chronology', 'Third level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'l', 'Fourth level of chronology', 'Fourth level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'm', 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'n', 'Converted Gregorian year', 'Converted Gregorian year', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'o', 'Type of unit', 'Type of unit', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'p', 'Piece designation', 'Piece designation', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'q', 'Piece physical condition', 'Piece physical condition', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 's', 'Copyright article-fee code', 'Copyright article-fee code', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 't', 'Copy number', 'Copy number', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'v', 'Issuing date', 'Issuing date', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'w', 'Break indicator', 'Break indicator', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('864', 'z', 'Public note', 'Public note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('865', '8', 'Field link and sequence number', 'Field link and sequence number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('865', 'a', 'First level of enumeration', 'First level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'b', 'Second level of enumeration', 'Second level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'c', 'Third level of enumeration', 'Third level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'd', 'Fourth level of enumeration', 'Fourth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'e', 'Fifth level of enumeration', 'Fifth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'f', 'Sixth level of enumeration', 'Sixth level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'g', 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'h', 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'i', 'First level of chronology', 'First level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'j', 'Second level of chronology', 'Second level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'k', 'Third level of chronology', 'Third level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'l', 'Fourth level of chronology', 'Fourth level of chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'm', 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'n', 'Converted Gregorian year', 'Converted Gregorian year', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'o', 'Type of unit', 'Type of unit', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'p', 'Piece designation', 'Piece designation', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'q', 'Piece physical condition', 'Piece physical condition', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 's', 'Copyright article-fee code', 'Copyright article-fee code', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 't', 'Copy number', 'Copy number', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'v', 'Issuing date', 'Issuing date', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'w', 'Break indicator', 'Break indicator', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('865', 'z', 'Public note', 'Public note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('866', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('866', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('866', 'a', 'Textual string', 'Textual string', 0, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('866', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('866', 'z', 'Public note', 'Public note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('867', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('867', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('867', 'a', 'Textual string', 'Textual string', 0, 0, 'holdings.supplements', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('867', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('867', 'z', 'Public note', 'Public note', 1, 0, 'holdings.supplements', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('868', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('868', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('868', 'a', 'Textual string', 'Textual string', 0, 0, 'holdings.indexes', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('868', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('868', 'z', 'Public note', 'Public note', 1, 0, 'holdings.indexes', 8, '', '', '', 0, 4, 'HLD', '', '', NULL),
        ('876', '3', 'Materials specified', 'Materials specified', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', '8', 'Sequence number', 'Sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'a', 'Internal item number', 'Internal item number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'b', 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'c', 'Cost', 'Cost', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'd', 'Date acquired', 'Date acquired', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'h', 'Use restrictions', 'Use restrictions', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'j', 'Item status', 'Item status', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'l', 'Temporary location', 'Temporary location', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'p', 'Piece designation', 'Piece designation', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'r', 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 't', 'Copy number', 'Copy number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('876', 'z', 'Public note', 'Public note', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', '3', 'Materials specified', 'Materials specified', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', '8', 'Sequence number', 'Sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'a', 'Internal item number', 'Internal item number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'b', 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'c', 'Cost', 'Cost', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'd', 'Date acquired', 'Date acquired', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'h', 'Use restrictions', 'Use restrictions', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'j', 'Item status', 'Item status', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'l', 'Temporary location', 'Temporary location', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'p', 'Piece designation', 'Piece designation', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'r', 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 't', 'Copy number', 'Copy number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('877', 'z', 'Public note', 'Public note', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', '3', 'Materials specified', 'Materials specified', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', '8', 'Sequence number', 'Sequence number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'a', 'Internal item number', 'Internal item number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'b', 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'c', 'Cost', 'Cost', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'd', 'Date acquired', 'Date acquired', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'e', 'Source of acquisition', 'Source of acquisition', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'h', 'Use restrictions', 'Use restrictions', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'j', 'Item status', 'Item status', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'l', 'Temporary location', 'Temporary location', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'p', 'Piece designation', 'Piece designation', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'r', 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 't', 'Copy number', 'Copy number', 0, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL),
        ('878', 'z', 'Public note', 'Public note', 1, 0, '', 8, '', '', '', NULL, 4, 'HLD', '', '', NULL);
