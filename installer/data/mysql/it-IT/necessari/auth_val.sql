SET FOREIGN_KEY_CHECKS=0;

-- Reasons for acceptance or rejection of suggestions in acquisitions
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','BSELL','Bestseller');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','SCD','Copia a scaffale danneggiata');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','LCL','Copia della biblioteca persa');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','AVILL','Disponibile via prestito ILL');

-- availability statuses
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','0','Non persa');
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('LOST','2','Lungo ritardo (persa)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','1','Persa');
INSERT INTO `authorised_values`  (category, authorised_value, lib ) VALUES ('LOST','3','Persa e pagata da');
INSERT INTO `authorised_values`  (category, authorised_value, lib )VALUES ('LOST','4','Mancante');

-- damaged status of an item
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('DAMAGED','0','Non danneggiata');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('DAMAGED','1','Danneggiata');

-- location qualification for an item, departments are linked by default to items.location
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CHILD','Area bambini');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','DISPLAY','A scaffale aperto');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','NEW','Scaffale novità');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','STAFF','Ufficio staff');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','GEN','Sezione generale');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','AV','Audiovideo');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','REF','Strumenti di reference');

-- collection codes for an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','REF','Strumenti di reference');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','NFIC','Non Fiction');

-- withdrawn status of an item, linked to items.wthdrawn
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','0','Non ritirata');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','1','Ritirata dalla circolazione');

-- loanability status of an item, linked to items.notforloan
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','-1','Ordinato');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','0','Per il prestito');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','1','Non per il prestito');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','2','Uso interno');

-- restricted status of an item, linked to items.restricted
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','0','Nessuna restrizione');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','1','Accesso limitato');

-- manual invoice types
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('MANUAL_INV','Costo fotocopie','.25');

-- custom borrower notes
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('BOR_NOTES','ADDR','Indirizzo (Nota)');

-- Qualifiche per gli autori

INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES 
('qualif', '570', 'Altro'),
('qualif', '205', 'Collaboratore'),
('qualif', '210', 'Commentatore'),
('qualif', '571', 'Coordinatore'),
('qualif', '573', 'Diffusore'),
('qualif', '651', 'Direttore editoriale'),
('qualif', '650', 'Editore'),
('qualif', '440', 'Illustratore'),
('qualif', '075', 'Postfatore'),
('qualif', '080', 'Prefatore'),
('qualif', '574', 'Presentatore'),
('qualif', '710', 'Redattore'),
('qualif', '575', 'Responsabile'),
('qualif', '730', 'Traduttore'),
('qualif', '020', 'Chiosatore'),
('qualif', '723', 'Sponsor'),
('qualif', '675', 'Recensore'),
('qualif', '600', 'Fotografo'),
('qualif', '370', 'Film editor'),
('qualif', '673', 'Direttore'),
('qualif', '605', 'Presentatore'),
('qualif', '557', 'Organizzatore del congresso'),
('qualif', '340', 'Editor'),
('qualif', '727', 'Relatore di tesi'),
('qualif', '220', 'Compilatore'),
('qualif', '395', 'Fondatore'),
('qualif', '100', 'Autore dell''opere che è stata adattata'),
('qualif', '230', 'Compositore'),
('qualif', '520', 'Paroliere'),
('qualif', '295', 'Istituzione garante della tesi'),
('qualif', '010', 'Adattarore');

-- Codici dei Paesi (COUNTRY)
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES
('COUNTRY', 'IT', 'Italia'),
('COUNTRY', 'US', 'Stati Uniti'),
('COUNTRY', 'GB', 'Regno Unito - UK '),
('COUNTRY', 'DE', 'Germania'),
('COUNTRY', 'FR', 'Francia'),
('COUNTRY', 'VA', 'Vaticano'),
('COUNTRY', 'CN', 'Cina'),
('COUNTRY', 'IN', 'India');

-- Codici delle lingue (LANG)
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES
('LANG', 'ita', 'italiano'),
('LANG', 'eng', 'inglese'),
('LANG', 'ger', 'tedesco'),
('LANG', 'fre', 'francese'),
('LANG', 'lat', 'latino');

SET FOREIGN_KEY_CHECKS=1;

