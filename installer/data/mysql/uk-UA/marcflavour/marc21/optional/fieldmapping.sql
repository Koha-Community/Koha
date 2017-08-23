-- koha to keyword mapping
--  id            -- unique identifier assigned by Koha (auto_increment)
--  field         -- keyword to be mapped to (ex. subtitle)
--  frameworkcode -- foreign key from the biblio_framework table to link this mapping to a specific framework (default '')
--  fieldcode     -- marc field number to map to this keyword
--  subfieldcode  -- marc subfield associated with the fieldcode to map to this keyword
INSERT INTO fieldmapping
 ( field,     frameworkcode,  fieldcode, subfieldcode) VALUES
 ('subtitle', 'CF',           '245',     'p'),
 ('subtitle', 'SER',          '490',     'v');
