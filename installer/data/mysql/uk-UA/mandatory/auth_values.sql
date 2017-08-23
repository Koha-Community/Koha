-- DELETE FROM authorised_values WHERE category='YES_NO';

-- default Koha system authorised values

-- To manage Yes/No
INSERT INTO `authorised_values` (category, authorised_value, lib, lib_opac) VALUES
 ('YES_NO', '0',  'Ні',  'Ні'),
 ('YES_NO', '1',  'Так', 'Так');

-- Housebound
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES
 ('HSBND_FREQ','EW','Кожного тижня');
