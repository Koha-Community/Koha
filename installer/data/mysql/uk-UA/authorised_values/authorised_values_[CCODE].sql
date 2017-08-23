-- DELETE FROM authorised_values WHERE category='CCODE';

-- collection codes for an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES
 ('CCODE','FIC', 'Художня література'),
 ('CCODE','REF', 'Довідник'),
 ('CCODE','NFIC','Наукова література');

