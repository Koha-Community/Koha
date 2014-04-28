-- Reasons for acceptance or rejection of suggestions in acquisitions
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','BSELL','Bestseller');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','SCD','Vorhandenes Exemplar beschädigt');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','LCL','Bibliotheksexemplar vermisst');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','AVILL','Über Fernleihe bestellbar');

-- availability statuses
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('LOST','2','Lange überfällig (Verloren)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','1','Verloren');
INSERT INTO `authorised_values`  (category, authorised_value, lib ) VALUES ('LOST','3','Verloren und Buchersatz bezahlt');
INSERT INTO `authorised_values`  (category, authorised_value, lib )VALUES ('LOST','4','Vermisst');

-- damaged status of an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('DAMAGED','1','Beschädigt');

-- location qualification for an item, departments are linked by default to items.location
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','FIC','Belletristik');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CHILD','Kinderbibliothek');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','DISPLAY','Medienausstellung');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','NEW','Neuerwerbungsregal');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','STAFF','Mitarbeiterbüro');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','GEN','Magazin');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','AV','AV-Mediensammlung');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','REF','Nachschlagewerke');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CART','Einstellwagen');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','PROC','In Bearbeitung');

-- collection codes for an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','FIC','Belletristik');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','REF','Nachschlagewerke');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','NFIC','Sachliteratur');

-- withdrawn status of an item, linked to items.withdrawn
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','1','Ausgeschieden');

-- loanability status of an item, linked to items.notforloan
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','-1','Bestellt');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','1','Nicht entleihbar');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','2','Mitarbeiterbibliothek');

-- restricted status of an item, linked to items.restricted
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','1','Eingeschränkt zugänglich');

-- manual invoice types
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('MANUAL_INV','Kopiergebühren','.25');

-- custom borrower notes
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('BOR_NOTES','ADDR','Adresse kontrollieren');

-- OPAC Suggestions reasons
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('OPAC_SUG','damaged','Vorhandenes Exemplar ist beschädigt','Vorhandenes Exemplar ist beschädigt');
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('OPAC_SUG','bestseller','Neuerscheinung von bekanntem Verfasser','Neuerscheinung von bekanntem Verfasser');

-- Report groups
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'CIRC', 'Ausleihe');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'CAT', 'Katalog');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'PAT', 'Benutzer');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'ACQ', 'Erwerbung');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'ACC', 'Gebühren');

-- SIP2 media types
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '000', 'Other');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '001', 'Book');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '002', 'Magazine');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '003', 'Bound journal');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '004', 'Audio tape');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '005', 'Video tape');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '006', 'CD/CDROM');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '007', 'Diskette');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '008', 'Book with diskette');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '009', 'Book with CD');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '010', 'Book with audio tape');
