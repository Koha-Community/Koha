UPDATE language_subtag_registry SET subtag = 'kn' WHERE subtag = 'ka' AND description = 'Kannada';

UPDATE language_rfc4646_to_iso639 SET rfc4646_subtag = 'kn' WHERE rfc4646_subtag = 'ka' AND iso639_2_code = 'kan';

UPDATE language_descriptions SET subtag = 'kn', lang = 'kn' WHERE subtag = 'ka' AND lang = 'ka' AND description = 'ಕನ್ನಡ';

UPDATE language_descriptions SET subtag = 'kn' WHERE subtag = 'ka' AND description = 'Kannada';

INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ka', 'language', 'Georgian','2015-04-20');
DELETE FROM language_subtag_registry
       WHERE NOT id IN
         (SELECT id FROM
           (SELECT MIN(id) as id,subtag,type,description,added
            FROM language_subtag_registry
            GROUP BY subtag,type,description,added)
           AS subtable);


INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ka', 'geo');
DELETE FROM language_rfc4646_to_iso639
       WHERE NOT id IN
         (SELECT id FROM
           (SELECT MIN(id) as id,rfc4646_subtag,iso639_2_code
            FROM language_rfc4646_to_iso639
            GROUP BY rfc4646_subtag,iso639_2_code)
           AS subtable);

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'ka', 'ქართული');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'en', 'Georgian');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'fr', 'Géorgien');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'de', 'Georgisch');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'es', 'Georgiano');

DELETE FROM language_descriptions
       WHERE NOT id IN
         (SELECT id FROM
           (SELECT MIN(id) as id,subtag,type,lang,description
            FROM language_descriptions GROUP BY subtag,type,lang,description)
           AS subtable);
