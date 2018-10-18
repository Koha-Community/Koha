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
    `ccode` varchar(80) default NULL, -- authorized value for the collection code associated with this item (MARC21 852$g)
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

CREATE TABLE `holdings_metadata` (
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
