DELETE FROM authorised_values WHERE category='CCODE';

INSERT INTO `authorised_values` (category, authorised_value, lib, imageurl) VALUES 
('CCODE','FIC', 'Художественная литература', NULL),
('CCODE','REF', 'Справочник'               , NULL),
('CCODE','NFIC','Научная литература'       , NULL);