UPDATE systempreferences SET value = 'Père|Mère|grand-parent|Tuteur légal|Autre' WHERE variable = 'borrowerRelationship';
UPDATE systempreferences SET value = 'M|Mme|Mlle' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = '676a' WHERE variable = 'itemcallnumber';
UPDATE systempreferences SET value = 'fr-FR' WHERE variable = 'StaffInterfaceLanguages';
UPDATE systempreferences SET value = 'Ma bibliothèque' WHERE variable = 'LibraryName';
UPDATE systempreferences SET value = 'fr-FR' WHERE variable = 'OPACLanguages';
UPDATE systempreferences SET value = 1 WHERE variable = 'opaclanguagesdisplay';
UPDATE systempreferences SET value = 'bibtex,dc,marcxml,marc8,utf8,marcstd,ris' WHERE variable = 'OpacExportOptions';

INSERT IGNORE INTO `z3950servers`
(`host`, `port`, `db`, `userid`, `password`, `servername`, `id`, `checked`, `rank`, `syntax`, `servertype`, `encoding`) VALUES
('z3950.bnf.fr', 2211, 'TOUT-UTF8', 'Z3950', 'Z3950_BNF', 'BNF2', 2, 1, 2, 'UNIMARC', 'zed', 'utf8');

DELETE FROM `itemtypes`;
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('LIVR', ' Livre', 0.0000, 0, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('BD', 'BD', 0.0000, 0, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('LOC', 'Fonds Local', 0.0000, 0, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('PERI', 'Périodique', 0.0000, 0, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('USUE', 'Usuel', 0.0000, 1, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('ARTI', 'Article', 0.0000, 1, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('CD', 'CD musique', 0.0000, 0, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('CDR', 'CD-ROM', 0.0000, 0, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('DVD', 'DVD', 0.0000, 0, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('WEB', 'Ressource Web', 0.0000, 1, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('ADAP', 'Document Adapté', 0.0000, 0, '', '');
INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES ('VHS', 'VHS', 0.0000, 0, '', '');
