CREATE TABLE biblio_metadata (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `biblionumber` INT(11) NOT NULL,
    `format` VARCHAR(16) NOT NULL,
    `marcflavour` VARCHAR(16) NOT NULL,
    `metadata` LONGTEXT NOT NULL,
    PRIMARY KEY(id),
    UNIQUE KEY `biblio_metadata_uniq_key` (`biblionumber`,`format`,`marcflavour`),
    CONSTRAINT `biblio_metadata_fk_1` FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE deletedbiblio_metadata (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `biblionumber` INT(11) NOT NULL,
    `format` VARCHAR(16) NOT NULL,
    `marcflavour` VARCHAR(16) NOT NULL,
    `metadata` LONGTEXT NOT NULL,
    PRIMARY KEY(id),
    UNIQUE KEY `deletedbiblio_metadata_uniq_key` (`biblionumber`,`format`,`marcflavour`),
    CONSTRAINT `deletedbiblio_metadata_fk_1` FOREIGN KEY (biblionumber) REFERENCES deletedbiblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


INSERT INTO biblio_metadata ( biblionumber, format, marcflavour, metadata ) SELECT biblionumber, 'marcxml', 'CHANGEME', marcxml FROM biblioitems;
INSERT INTO deletedbiblio_metadata ( biblionumber, format, marcflavour, metadata ) SELECT biblionumber, 'marcxml', 'CHANGEME', marcxml FROM deletedbiblioitems;
UPDATE biblio_metadata SET marcflavour = (SELECT value FROM systempreferences WHERE variable="marcflavour");
UPDATE deletedbiblio_metadata SET marcflavour = (SELECT value FROM systempreferences WHERE variable="marcflavour");
ALTER TABLE biblioitems DROP COLUMN marcxml;
ALTER TABLE deletedbiblioitems DROP COLUMN marcxml;
