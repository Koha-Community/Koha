-- Reasons for acceptance or rejection of suggestions in acquisitions
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','BSELL','Suosittu teos');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','SCD','Vahingoittunut');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','LCL','Kirjaston nide kadonnut');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','AVILL','Saatavilla kaukopalvelussa');

-- Desired formats for requesting new materials
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'BOOK', 'Kirja', 'Kirja');
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'LP', 'Isotekstinen', 'Isotekstinen');
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'EBOOK', 'E-kirja', 'E-kirja');
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'AUDIOBOOK', 'Äänikirja', 'Äänikirja');
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES ('SUGGEST_FORMAT', 'DVD', 'DVD', 'DVD');

-- availability statuses
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('LOST','2','Palauttamatta (Kadonnut)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','1','Kadonnut');
INSERT INTO `authorised_values`  (category, authorised_value, lib ) VALUES ('LOST','3','Kadonnut ja maksettu');
INSERT INTO `authorised_values`  (category, authorised_value, lib )VALUES ('LOST','4','Puuttuva');

-- damaged status of an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('DAMAGED','1','Vahingoittunut');

-- location qualification for an item, departments are linked by default to items.location
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','FIC','Fiktio');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CHILD','Lapset');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','DISPLAY','Näyteikkuna');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','NEW','Uutuushylly');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','STAFF','Henkilökunta');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','GEN','Yleinen');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','AV','Audiovisuaalinen');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','REF','Käsikirjasto');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CART','Kärry');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','PROC','Käsittelykeskus');

-- collection codes for an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','FIC','Fiktio');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','REF','Käsikirjasto');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','NFIC','Tietokirjallisuus');

-- withdrawn status of an item, linked to items.withdrawn
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','1','Pois kierrosta');

-- loanability status of an item, linked to items.notforloan
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','-1','Tilattu');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','1','Ei lainata');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','2','Henkilökunnan kokoelmassa');

-- restricted status of an item, linked to items.restricted
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','1','Rajoitettu oikeus');

-- manual invoice types
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('MANUAL_INV','Kopiokonemaksu','.25');

-- custom borrower notes
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('BOR_NOTES','ADDR','Osoitteen lisätiedot');

-- OPAC Suggestions reasons
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('OPAC_SUG','damaged','Nide on vahingoittunut','Nide on vahingoittunut');
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('OPAC_SUG','bestseller','Suositun tekijän uutuusteos','Suositun tekijän uutuusteos');

-- Report groups
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'CIRC', 'Lainaus');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'CAT', 'Luettelo');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'PAT', 'Asiakkaat');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'ACQ', 'Hankinta');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'ACC', 'Maksut');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'SER', 'Lehdet');

-- SIP2 media types
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '000', 'Muu');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '001', 'Kirja');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '002', 'Lehti');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '003', 'Bound journal');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '004', 'Audio');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '005', 'Video');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '006', 'CD/CDROM');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '007', 'Disketti');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '008', 'Kirja jossa disketti');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '009', 'Kirja jossa CD');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SIP_MEDIA_TYPE', '010', 'Kirja jossa audionauha');

-- order cancellation reasons
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('ORDER_CANCELLATION_REASON', 0, 'Ei syytä');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('ORDER_CANCELLATION_REASON', 1, 'Loppu varastosta');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('ORDER_CANCELLATION_REASON', 2, 'Varastoa täydennetään');
