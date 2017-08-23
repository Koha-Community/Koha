-- DELETE FROM authorised_values WHERE category='SUGGEST_FORMAT';

-- Desired formats for requesting new materials
INSERT INTO authorised_values (category, authorised_value, lib, lib_opac) VALUES
 ('SUGGEST_FORMAT', 'BOOK',      'Книга',            'Книга'),
 ('SUGGEST_FORMAT', 'LP',        'Великий друк',     'Великий друк'),
 ('SUGGEST_FORMAT', 'EBOOK',     'Електронна книга', 'Електронна книга'),
 ('SUGGEST_FORMAT', 'AUDIOBOOK', 'Звукова книга',    'Аудіокнига'),
 ('SUGGEST_FORMAT', 'DVD',       'DVD-диск',         'DVD-диск');
