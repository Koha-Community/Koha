UPDATE language_subtag_registry SET subtag = 'kn' WHERE subtag = 'ka' AND description = 'Kannada';

UPDATE language_rfc4646_to_iso639 SET rfc4646_subtag = 'kn' WHERE rfc4646_subtag = 'ka' AND iso639_2_code = 'kan';

UPDATE language_descriptions SET subtag = 'kn', lang = 'kn' WHERE subtag = 'ka' AND lang = 'ka' AND description = 'ಕನ್ನಡ';

UPDATE language_descriptions SET subtag = 'kn' WHERE subtag = 'ka' AND description = 'Kannada';

INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ka', 'language', 'Georgian','2015-04-20');

INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ka', 'geo');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'ka', 'ქართული');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'en', 'Georgian');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'fr', 'Géorgien');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'de', 'Georgische');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'es', 'Georgiano');
