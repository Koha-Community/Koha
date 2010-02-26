DELETE FROM authorised_values WHERE category='CCODE';

INSERT INTO `authorised_values` (category, authorised_value, lib, imageurl) VALUES 
('CCODE','FIC', 'Художня література', NULL),
('CCODE','REF', 'Довідник'          , NULL),
('CCODE','NFIC','Наукова література', NULL);