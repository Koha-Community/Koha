-- Estonian

INSERT INTO language_subtag_registry (subtag, type, description, added) VALUES ('et', 'language', 'Estonian', now());
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('et', 'language', 'en', 'Estonian');
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('et', 'language', 'et', 'Eesti');
INSERT INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('et', 'est');

-- Latvian

INSERT INTO language_subtag_registry (subtag, type, description, added) VALUES ('lv', 'language', 'Latvian', now());
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('lv', 'language', 'en', 'Latvian');
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('lv', 'language', 'lv', 'Latvija');
INSERT INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lv', 'lav');

-- Lithuanian

INSERT INTO language_subtag_registry (subtag, type, description, added) VALUES ('lt', 'language', 'Lithuanian', now());
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('lt', 'language', 'en', 'Lithuanian');
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('lt', 'language', 'lt', 'Lietuvių');
INSERT INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lt', 'lit');

-- Inuktitut

INSERT INTO language_subtag_registry (subtag, type, description, added) VALUES ('iu', 'language', 'Inuktitut', now());
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('iu', 'language', 'en', 'Inuktitut');
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('iu', 'language', 'iu', 'ᐃᓄᒃᑎᑐᑦ');
INSERT INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('iu', 'iku');

-- Inupiaq

INSERT INTO language_subtag_registry (subtag, type, description, added) VALUES ('ik', 'language', 'Inupiaq', now());
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('ik', 'language', 'en', 'Inupiaq');
INSERT INTO language_descriptions (subtag, type, lang, description) VALUES ('ik', 'language', 'ik', 'Iñupiaq');
INSERT INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ik', 'ipk');
