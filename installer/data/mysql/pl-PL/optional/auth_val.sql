-- Reasons for acceptance or rejection of suggestions in acquisitions
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','BSELL','Bestseller');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','SCD','Shelf Copy Damaged');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','LCL','Library Copy Lost');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','AVILL','Available via ILL');

-- availability statuses
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('LOST','2','Długo przetrzymywany (Zagubiony)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','1','Zagubiony');
INSERT INTO `authorised_values`  (category, authorised_value, lib ) VALUES ('LOST','3','Zagubiony i opłacony');
INSERT INTO `authorised_values`  (category, authorised_value, lib )VALUES ('LOST','4','Zaginiony');

-- damaged status of an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('DAMAGED','1','Uszkodzony');

-- location qualification for an item, departments are linked by default to items.location
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CHILD','Children\'s Area');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','DISPLAY','On Display');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','NEW','New Materials Shelf');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','STAFF','Staff Office');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','GEN','General Stacks');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','AV','Audio Visual');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','REF','Reference');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CART','Book Cart');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','PROC','Processing Center');

-- collection codes for an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','REF','Reference');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','NFIC','Non-fiction');

-- withdrawn status of an item, linked to items.withdrawn
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','1','Wycofany');

-- loanability status of an item, linked to items.notforloan
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','-1','Zamówiony');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','1','Nie do wypożyczenia');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','2','Zasób pracowniczy');

-- restricted status of an item, linked to items.restricted
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','1','Ograniczony dostęp');

-- manual invoice types
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('MANUAL_INV','Opłata za ksero','.25');

-- custom borrower notes
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('BOR_NOTES','ADDR','Uwagi do adresu');

-- OPAC Suggestions reasons
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('OPAC_SUG','damaged','The copy on the shelf is damaged','The copy on the shelf is damaged');
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('OPAC_SUG','bestseller','Upcoming title by popular author','Upcoming title by popular author');

-- Report groups
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'CIRC', 'Udostępnianie');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'CAT', 'Katalog');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'PAT', 'Uzytkownicy');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'ACQ', 'Gromadzenie');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'ACC', 'Konta');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'SER', 'Serials');

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

-- order cancellation reasons
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('ORDER_CANCELLATION_REASON', 0, 'No reason provided');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('ORDER_CANCELLATION_REASON', 1, 'Out of stock');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('ORDER_CANCELLATION_REASON', 2, 'Restocking');

-- Desired formats for requesting new materials
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'BOOK', 'Book', 'Book');
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'LP', 'Large print', 'Large print');
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'EBOOK', 'EBook', 'Ebook');
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'AUDIOBOOK', 'Audiobook', 'Audiobook');
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'DVD', 'DVD', 'DVD');
