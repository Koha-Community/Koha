SET FOREIGN_KEY_CHECKS=0;

-- To manage Yes/No
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('YES_NO','0','No','No');
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('YES_NO','1','Si','Si');

-- Reasons for acceptance or rejection of suggestions in acquisitions
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','BSELL','Bestseller');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','SCD','Copia a scaffale danneggiata');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','LCL','Copia della biblioteca persa');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','AVILL','Disponibile via prestito ILL');

-- availability statuses
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOST','0','Non persa');
INSERT INTO authorised_values  (category, authorised_value, lib) VALUES ('LOST','2','Lungo ritardo (persa)');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOST','1','Persa');
INSERT INTO authorised_values  (category, authorised_value, lib ) VALUES ('LOST','3','Persa e pagata da');
INSERT INTO authorised_values  (category, authorised_value, lib )VALUES ('LOST','4','Mancante');

-- damaged status of an item
INSERT INTO authorised_values  (category, authorised_value, lib) VALUES ('DAMAGED','0','Non danneggiata');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('DAMAGED','1','Danneggiata');

-- location qualification for an item, departments are linked by default to items.location
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOC','FIC','Fiction');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOC','CHILD','Area bambini');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOC','DISPLAY','A scaffale aperto');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOC','NEW','Scaffale novità');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOC','STAFF','Ufficio staff');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOC','GEN','Sezione generale');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOC','AV','Audiovideo');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOC','REF','Strumenti di reference');

-- collection codes for an item
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('CCODE','FIC','Fiction');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('CCODE','REF','Strumenti di reference');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('CCODE','NFIC','Non Fiction');

-- withdrawn status of an item, linked to items.wthdrawn
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('WITHDRAWN','0','Non ritirata');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('WITHDRAWN','1','Ritirata dalla circolazione');

-- loanability status of an item, linked to items.notforloan
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('NOT_LOAN','-1','Ordinato');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('NOT_LOAN','0','Per il prestito');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('NOT_LOAN','1','Non per il prestito');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('NOT_LOAN','2','Uso interno');

-- restricted status of an item, linked to items.restricted
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('RESTRICTED','0','Nessuna restrizione');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('RESTRICTED','1','Accesso limitato');

-- manual invoice types
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('MANUAL_INV','Costo fotocopie','.25');

-- custom borrower notes
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('BOR_NOTES','ADDR','Indirizzo (Nota)');

-- OPAC Suggestions reasons
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('OPAC_SUG','damaged','La copia disponibile è danneggiata','La copia disponibile è danneggiata');
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('OPAC_SUG','bestseller','Titolo in arrivo di autore famoso','Titolo in arrivo di autore famoso');

-- Codici dei Paesi (COUNTRY)
INSERT INTO authorised_values (category, authorised_value, lib) VALUES
('COUNTRY', 'IT', 'Italia'),
('COUNTRY', 'US', 'Stati Uniti'),
('COUNTRY', 'GB', 'Regno Unito - UK '),
('COUNTRY', 'DE', 'Germania'),
('COUNTRY', 'FR', 'Francia'),
('COUNTRY', 'VA', 'Vaticano'),
('COUNTRY', 'CN', 'Cina'),
('COUNTRY', 'IN', 'India');

-- Codici delle lingue (LANG)
INSERT INTO authorised_values (category, authorised_value, lib) VALUES
('LANG', 'ita', 'italiano'),
('LANG', 'eng', 'inglese'),
('LANG', 'ger', 'tedesco'),
('LANG', 'fre', 'francese'),
('LANG', 'lat', 'latino');

-- Raggruppamenti di esempio per i reports
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'CIRC', 'Circulation');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'CAT', 'Catalog');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'PAT', 'Patrons');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'ACQ', 'Acquisitions');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('REPORT_GROUP', 'ACC', 'Accounts');

SET FOREIGN_KEY_CHECKS=1;
