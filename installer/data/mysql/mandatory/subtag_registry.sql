-- http://www.w3.org/International/articles/language-tags/

-- BIDI Stuff, Arabic and Hebrew
INSERT INTO language_script_bidi(rfc4646_subtag,bidi)
VALUES ( 'Arab', 'rtl');
INSERT INTO language_script_bidi(rfc4646_subtag,bidi)
VALUES ( 'Hebr', 'rtl');

-- Default mappings between script and language subcodes
INSERT INTO language_script_mapping(language_subtag,script_subtag)
VALUES ( 'ar', 'Arab');
INSERT INTO language_script_mapping(language_subtag,script_subtag)
VALUES ( 'he', 'Hebr');

-- EXTENSIONS
-- Interface (i)
-- SELECT * FROM language_subtag_registry WHERE type='i';
-- OPAC
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'opac', 'i', 'OPAC','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'opac', 'i', 'en', 'OPAC');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'opac', 'i', 'fr', 'OPAC');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'opac', 'i', 'de', 'OPAC');

-- Staff Client
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'intranet', 'i', 'Staff Client','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'intranet', 'i', 'en', 'Staff Client');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'intranet', 'i', 'fr', 'Client personnel');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'intranet', 'i', 'de', 'Dienstoberfläche');

-- Theme (t)
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'prog', 't', 'Prog','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'prog', 't', 'en', 'Prog');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'prog', 't', 'fr', 'Prog');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'prog', 't', 'de', 'Prog');

-- LANGUAGES

-- Amharic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'am', 'language', 'Amharic','2014-10-29');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'am','amh');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'am', 'language', 'am', 'አማርኛ');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'am', 'language', 'en', 'Amharic');

-- Arabic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ar', 'language', 'Arabic','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ar','ara');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ar', 'language', 'ar', 'لعربية');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ar', 'language', 'en', 'Arabic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ar', 'language', 'fr', 'Arabe');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ar', 'language', 'de', 'Arabisch');

-- Azerbaijani
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'az', 'language', 'Azerbaijani','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'az','aze');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'az', 'language', 'az', 'Azərbaycan dili');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'az', 'language', 'en', 'Azerbaijani');

-- Byelorussian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'be', 'language', 'Byelorussian','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'be','bel');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'be', 'language', 'be', 'Беларуская мова');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'be', 'language', 'en', 'Byelorussian');

-- Bengali
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'bn', 'language', 'Bengali','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'bn','ben');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bn', 'language', 'bn', 'বাংলা');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bn', 'language', 'en', 'Bengali');

-- Bulgarian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'bg', 'language', 'Bulgarian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'bg','bul');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bg', 'language', 'bg', 'Български');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bg', 'language', 'en', 'Bulgarian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bg', 'language', 'fr', 'Bulgare');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bg', 'language', 'de', 'Bulgarisch');

-- Standard Tibetan
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'bo', 'language', 'Standard Tibetan', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'bo', 'tib');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bo', 'language', 'en', 'Standard Tibetan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bo', 'language', 'bo', 'ལྷ་སའི་སྐད་');

-- Bosnian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'bs', 'language', 'Bosnian', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'bs', 'bos');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bs', 'language', 'en', 'Bosnian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bs', 'language', 'bn', 'Bosanski');

-- Catalan
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ca', 'language', 'Catalan','2013-01-12' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ca','cat');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ca', 'language', 'es', 'Catalán');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ca', 'language', 'en', 'Catalan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ca', 'language', 'fr', 'Catalan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ca', 'language', 'ca', 'Català');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ca', 'language', 'de', 'Katalanisch');

-- Czech
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'cs', 'language', 'Czech','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'cs','cze');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'cs', 'language', 'cs', 'Čeština');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'cs', 'language', 'en', 'Czech');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'cs', 'language', 'fr', 'Tchèque');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'cs', 'language', 'de', 'Tschechisch');

-- Welsh
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'cy', 'language', 'Welsh', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'cy', 'wel');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'cy', 'language', 'en', 'Welsh');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'cy', 'language', 'cy', 'Cymraeg');

-- Danish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'da', 'language', 'Danish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'da','dan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'da', 'language', 'da', 'Dansk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'da', 'language', 'en', 'Danish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'da', 'language', 'fr', 'Danois');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'da', 'language', 'de', 'Dänisch');

-- German
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'de', 'language', 'German','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'de','ger');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'de', 'language', 'de', 'Deutsch');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'de', 'language', 'en', 'German');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'de', 'language', 'fr', 'Allemand');

-- Greek
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'el', 'language', 'Greek, Modern [1453- ]','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'el','gre');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'el', 'language', 'el', 'Eλληνικά');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'el', 'language', 'en', 'Greek, Modern [1453- ]');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'el', 'language', 'fr', 'Grec Moderne (Après 1453)');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'el', 'language', 'de', 'Griechisch (Moern [1453- ]');

-- English
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'en', 'language', 'English','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'en','eng');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'en', 'language', 'en', 'English');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'en', 'language', 'fr', 'Anglais');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'en', 'language', 'de', 'Englisch');

-- Esperanto
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'eo', 'language', 'Esperanto', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'eo', 'epo');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'eo', 'language', 'en', 'Esperanto');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'eo', 'language', 'eo', 'Esperanto');

-- Spanish, Castilian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'es', 'language', 'Spanish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'es','spa');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'es', 'language', 'es', 'Español');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'es', 'language', 'en', 'Spanish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'es', 'language', 'fr', 'Espagnol');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'es', 'language', 'de', 'Spanisch');

-- Estonian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'et', 'language', 'Estonian', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'et', 'est');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'et', 'language', 'et', 'Eesti');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'et', 'language', 'en', 'Estonian');

-- Basque
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'eu', 'language', 'Basque','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'eu','eus');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'eu', 'language', 'eu', 'Euskera');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'eu', 'language', 'en', 'Basque');

-- Persian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'fa', 'language', 'Persian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'fa','per');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fa', 'language', 'fa', 'فارسى');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fa', 'language', 'en', 'Persian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fa', 'language', 'fr', 'Persan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fa', 'language', 'de', 'Persisch');

-- Finnish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'fi', 'language', 'Finnish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'fi','fin');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fi', 'language', 'fi', 'Suomi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fi', 'language', 'en', 'Finnish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fi', 'language', 'de', 'Finnisch');

-- Faroese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'fo', 'language', 'Faroese','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'fo','fao');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fo', 'language', 'fo', 'Føroyskt');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fo', 'language', 'en', 'Faroese');

-- French
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'fr', 'language', 'French','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'fr','fre');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fr', 'language', 'en', 'French');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fr', 'language', 'fr', 'Français');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'fr', 'language', 'de', 'Französisch');

-- Irish Gaelic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ga', 'language', 'Irish', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ga', 'gle');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ga', 'language', 'en', 'Irish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ga', 'language', 'ga', 'Gaeilge');

-- Scottish Gaelic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'gd', 'language', 'Scottish Gaelic', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'gd', 'gla');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'gd', 'language', 'en', 'Scottish Gaelic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'gd', 'language', 'gd', 'Gàidhlig');

-- Galician
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'gl', 'language', 'Galician','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'gl','glg');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'gl', 'language', 'gl', 'Galego');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'gl', 'language', 'en', 'Galician');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'gl', 'language', 'fr', 'Galicien');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'gl', 'language', 'de', 'Galicisch');

-- Ancient Greek
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'grc', 'language', 'Greek, Ancient', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'grc', 'grc');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'grc', 'language', 'en', 'Greek, Ancient');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'grc', 'language', 'grc', 'Ἑλληνική');

-- Hebrew
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'he', 'language', 'Hebrew','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'he','heb');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'he', 'language', 'he', 'עִבְרִית');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'he', 'language', 'en', 'Hebrew');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'he', 'language', 'fr', 'Hébreu');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'he', 'language', 'de', 'Hebräisch');

-- Hindi
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'hi', 'language', 'Hindi','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'hi','hin');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hi', 'language', 'hi', 'हिन्दी');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hi', 'language', 'en', 'Hindi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hi', 'language', 'fr', 'Hindi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hi', 'language', 'de', 'Hindi');

-- Croatian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'hr', 'language', 'Croatian','2014-07-24' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'hr','hrv');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hr', 'language', 'hr', 'Hrvatski');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hr', 'language', 'en', 'Croatian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hr', 'language', 'fr', 'Croate');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hr', 'language', 'de', 'Kroatisch');

-- Hungarian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'hu', 'language', 'Hungarian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'hu','hun');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hu', 'language', 'hu', 'Magyar');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hu', 'language', 'en', 'Hungarian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hu', 'language', 'fr', 'Hongrois');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hu', 'language', 'de', 'Ungarisch');

-- Armenian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'hy', 'language', 'Armenian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'hy','arm');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hy', 'language', 'hy', 'Հայերեն');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hy', 'language', 'en', 'Armenian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hy', 'language', 'fr', 'Armenian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hy', 'language', 'de', 'Armenisch');

-- Indonesian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'id', 'language', 'Indonesian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'id','ind');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'id', 'language', 'id', 'Bahasa Indonesia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'id', 'language', 'en', 'Indonesian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'id', 'language', 'fr', 'Indonésien');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'id', 'language', 'de', 'Indonesisch');

-- Icelandic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'is', 'language', 'Icelandic','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'is','ice');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'is', 'language', 'is', 'Íslenska');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'is', 'language', 'en', 'Icelandic');

-- Italian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'it', 'language', 'Italian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'it','ita');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'it', 'language', 'it', 'Italiano');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'it', 'language', 'en', 'Italian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'it', 'language', 'fr', 'Italien');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'it', 'language', 'de', 'Italienisch');

-- Japanese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ja', 'language', 'Japanese','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ja','jpn');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ja', 'language', 'ja', '日本語');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ja', 'language', 'en', 'Japanese');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ja', 'language', 'fr', 'Japonais');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ja', 'language', 'de', 'Japanisch');

-- Georgian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ka', 'language', 'Georgian','2015-04-20');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ka', 'geo');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ka', 'language', 'ka', 'ქართული');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ka', 'language', 'en', 'Georgian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ka', 'language', 'fr', 'Géorgien');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ka', 'language', 'de', 'Georgisch');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ka', 'language', 'es', 'Georgiano');

-- Kazakh
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'kk', 'language', 'Kazakh', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'kk', 'kaz');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kk', 'language', 'en', 'Kazakh');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kk', 'language', 'kk', 'қазақ тілі');

-- Greenlandic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'kl', 'language', 'Greenlandic', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'kl', 'kal');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kl', 'language', 'en', 'Greenlandic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kl', 'language', 'kl', 'Kalaallisut');

-- Kannada
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'kn', 'language', 'Kannada','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'kn', 'kan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kn', 'language', 'kn', 'ಕನ್ನಡ');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kn', 'language', 'en', 'Kannada');

-- Khmer
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'km', 'language', 'Khmer','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'km','khm');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'km', 'language', 'km', 'ភាសាខ្មែរ');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'km', 'language', 'en', 'Khmer');

-- Korean
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ko', 'language', 'Korean','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ko','kor');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ko', 'language', 'ko', '한국어');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ko', 'language', 'en', 'Korean');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ko', 'language', 'fr', 'Coréen');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ko', 'language', 'de', 'Koreanisch');

-- Karelian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'krl', 'language', 'Karelian', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'krl', 'krl');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'krl', 'language', 'en', 'Karelian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'krl', 'language', 'krl', 'Karjala');

-- Kurdish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ku', 'language', 'Kurdish','2014-05-13');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ku','kur');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ku', 'language', 'ku', 'کوردی');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ku', 'language', 'en', 'Kurdish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ku', 'language', 'fr', 'Kurde');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ku', 'language', 'de', 'Kurdisch');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ku', 'language', 'es', 'Kurdo');

-- Cornish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'kw', 'language', 'Cornish', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'kw', 'cor');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kw', 'language', 'en', 'Cornish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kw', 'language', 'kw', 'Kernowek');

-- Latin
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'la', 'language', 'Latin','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'la','lat');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'la', 'language', 'la', 'Latina');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'la', 'language', 'en', 'Latin');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'la', 'language', 'fr', 'Latin');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'la', 'language', 'de', 'Latein');

-- Lao
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'lo', 'language', 'Lao','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'lo','lao');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'lo', 'language', 'lo', 'ພາສາລາວ');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'lo', 'language', 'en', 'Lao');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'lo', 'language', 'fr', 'Laotien');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'lo', 'language', 'de', 'Laotisch');

-- Lithuanian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'lt', 'language', 'Lithuanian', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'lt', 'lit');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'lt', 'language', 'en', 'Lithuanian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'lt', 'language', 'lt', 'lietuvių kalba');

-- Latvian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'lv', 'language', 'Latvian', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'lv', 'lav');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'lv', 'language', 'en', 'Latvian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'lv', 'language', 'lv', 'Latviešu valoda');

-- Maori
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'mi', 'language', 'Maori','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'mi','mri');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'mi', 'language', 'mi', 'Te Reo Māori');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'mi', 'language', 'en', 'Maori');

-- Mongolian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'mn', 'language', 'Mongolian','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'mn','mon');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'mn', 'language', 'mn', 'Mонгол');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'mn', 'language', 'en', 'Mongolian');

-- Marathi
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'mr', 'language', 'Marathi','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'mr','mar');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'mr', 'language', 'mr', 'मराठी');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'mr', 'language', 'en', 'Marathi');

-- Malay
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ms', 'language', 'Malay','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ms','may');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ms', 'language', 'ms', 'Bahasa melayu');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ms', 'language', 'en', 'Malay');

-- Burmese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'my', 'language', 'Burmese', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'my', 'bur');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'my', 'language', 'en', 'Burmese');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'my', 'language', 'my', 'မြန်မာစာ');

-- Norwegian (bokmål)
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'nb', 'language', 'Norwegian bokmål','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'nb','nob');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nb', 'language', 'nb', 'Norsk bokmål');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nb', 'language', 'en', 'Norwegian bokmål');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nb', 'language', 'fr', 'Norvégien bokmål');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nb', 'language', 'de', 'Norwegisch bokmål');

-- Nepali
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ne', 'language', 'Nepali','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ne','nep');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ne', 'language', 'ne', 'नेपाली');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ne', 'language', 'en', 'Nepali');

-- Dutch
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'nl', 'language', 'Dutch','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'nl','dut');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nl', 'language', 'nl', 'Nederlands');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nl', 'language', 'en', 'Dutch');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nl', 'language', 'fr', 'Néerlandais');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nl', 'language', 'de', 'Niederländisch');

-- Norwegian (nynorsk)
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'nn', 'language', 'Norwegian nynorsk','2011-02-14' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'nn','nno');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nn', 'language', 'nb', 'Norsk nynorsk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nn', 'language', 'nn', 'Norsk nynorsk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nn', 'language', 'en', 'Norwegian nynorsk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nn', 'language', 'fr', 'Norvégien nynorsk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nn', 'language', 'de', 'Norwegisch nynorsk');

-- Punjabi
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'pa', 'language', 'Punjabi', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'pa', 'pan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pa', 'language', 'en', 'Punjabi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pa', 'language', 'pa', 'پنجابی');

-- Pangwa
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'pbr', 'language', 'Pangwa','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'pbr','pbr');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pbr', 'language', 'pbr', 'Ekipangwa');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pbr', 'language', 'en', 'Pangwa');

-- Polish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'pl', 'language', 'Polish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'pl','pol');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pl', 'language', 'pl', 'Polski');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pl', 'language', 'en', 'Polish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pl', 'language', 'fr', 'Polonais');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pl', 'language', 'de', 'Polnisch');

-- Dari
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'prs', 'language', 'Dari','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'prs','prs');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'prs', 'language', 'prs', 'درى');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'prs', 'language', 'en', 'Dari');

-- Pashto
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ps', 'language', 'Pashto', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ps', 'pus');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ps', 'language', 'en', 'Pashto');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ps', 'language', 'ps', 'پښتو');

-- Portuguese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'pt', 'language', 'Portuguese','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'pt','por');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pt', 'language', 'pt', 'Português');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pt', 'language', 'en', 'Portuguese');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pt', 'language', 'fr', 'Portugais');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pt', 'language', 'de', 'Portugiesisch');

-- Finnish Kalo
INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'rmf', 'rmf');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'rmf', 'language', 'en', 'Finnish Kalo');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'rmf', 'language', 'fi', 'Suomen romanikieli');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'rmf', 'language', 'rmf', 'Fíntika Rómma');

-- Romanian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ro', 'language', 'Romanian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ro','rum');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ro', 'language', 'ro', 'Română');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ro', 'language', 'en', 'Romanian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ro', 'language', 'fr', 'Roumain');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ro', 'language', 'de', 'Rumänisch');

-- Russian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ru', 'language', 'Russian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ru','rus');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ru', 'language', 'ru', 'Русский');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ru', 'language', 'en', 'Russian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ru', 'language', 'fr', 'Russe');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ru', 'language', 'de', 'Russisch');

-- Kinyarwanda
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'rw', 'language', 'Kinyarwanda','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'rw','kin');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'rw', 'language', 'rw', 'Ikinyarwanda');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'rw', 'language', 'en', 'Kinyarwanda');

-- Sanskrit
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sa', 'language', 'Sanskrit', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sa', 'san');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sa', 'language', 'en', 'Sanskrit');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sa', 'language', 'sa', 'saṃskṛtam');

-- Sindhi
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sd', 'language', 'Sindhi','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sd','snd');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sd', 'language', 'sd', 'سنڌي');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sd', 'language', 'en', 'Sindhi');

-- Slovak
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sk', 'language', 'Slovak','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sk','slk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sk', 'language', 'sk', 'Slovenčina');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sk', 'language', 'en', 'Slovak');

-- Slovene
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sl', 'language', 'Slovene','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sl','slv');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sl', 'language', 'sl', 'Slovenščina');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sl', 'language', 'en', 'Slovene');

-- Akkala Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sia', 'language', 'Akkala Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sia', 'sia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sia', 'language', 'en', 'Akkala Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sia', 'language', 'sia', 'ču´kksuâlis');

-- Kildin Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sjd', 'language', 'Kildin Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sjd', 'sjd');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjd', 'language', 'en', 'Kildin Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjd', 'language', 'sjd', 'Кӣллт са̄мь кӣлл');

-- Ter Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sjt', 'language', 'Ter Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sjt', 'sjt');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjt', 'language', 'en', 'Ter Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjt', 'language', 'sjt', 'saa´mekiill');

-- Pite Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sje', 'language', 'Pite Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sje', 'sje');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sje', 'language', 'en', 'Pite Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sje', 'language', 'sje', 'Bidumsámegiella');

-- Kemi Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sjk', 'language', 'Kemi Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sjk', 'sjk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjk', 'language', 'en', 'Kemi Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjk', 'language', 'sjk', 'samääškiela');

-- Ume Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sju', 'language', 'Ume Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sju', 'sju');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sju', 'language', 'en', 'Ume Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sju', 'language', 'sju', 'Ubmejensámien giella');

-- Southern Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sma', 'language', 'Southern Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sma', 'sma');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sma', 'language', 'en', 'Southern Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sma', 'language', 'sma', 'Åarjelsaemien gïele');

-- Northern Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sme', 'language', 'Northern Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sme', 'sme');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sme', 'language', 'en', 'Northern Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sme', 'language', 'fi', 'pohjoissaame');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sme', 'language', 'sv', 'Nordsamiska');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sme', 'language', 'sme', 'davvisámegiella');

-- Sami languages
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'smi', 'language', 'Sami languages', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'smi', 'smi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smi', 'language', 'en', 'Sami languages');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smi', 'language', 'fi', 'saamelaiskielet');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smi', 'language', 'sv', 'Samiska');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smi', 'language', 'smi', 'Saami');

-- Lule Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'smj', 'language', 'Lule Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'smj', 'smj');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smj', 'language', 'en', 'Lule Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smj', 'language', 'smj', 'julevsámegiella');

-- Inari Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'smn', 'language', 'Inari Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'smn', 'smn');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smn', 'language', 'en', 'Inari Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smn', 'language', 'smn', 'anarâškielâ');

-- Skolt Sami
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sms', 'language', 'Skolt Sami', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sms', 'sms');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sms', 'language', 'en', 'Skolt Sami');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sms', 'language', 'sms', 'sääʹmǩiõll');

-- Somali
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'so', 'language', 'Somali', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'so', 'som');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'so', 'language', 'en', 'Somali');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'so', 'language', 'so', 'Af-Soomaali');

-- Albanian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sq', 'language', 'Albanian','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sq','sqi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sq', 'language', 'sq', 'Shqip');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sq', 'language', 'en', 'Albanian');

-- Serbian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sr', 'language', 'Serbian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sr','srp');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sr', 'language', 'sr', 'Cрпски');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sr', 'language', 'en', 'Serbian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sr', 'language', 'fr', 'Serbe');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sr', 'language', 'de', 'Serbisch');

-- Sotho
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'st', 'language', 'Sotho', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'st', 'sot');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'st', 'language', 'en', 'Sotho');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'st', 'language', 'st', 'Sesotho');

-- Swedish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sv', 'language', 'Swedish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sv','swe');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sv', 'language', 'sv', 'Svenska');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sv', 'language', 'en', 'Swedish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sv', 'language', 'fr', 'Suédois');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sv', 'language', 'de', 'Schwedisch');

-- Swahili
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sw', 'language', 'Swahili','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'sw','swa');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sw', 'language', 'sw', 'Kiswahili');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sw', 'language', 'en', 'Swahili');

-- Tamil
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ta', 'language', 'Tamil','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ta','tam');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ta', 'language', 'ta', 'தமிழ்');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ta', 'language', 'en', 'Tamil');

-- Tetum
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'tet', 'language', 'Tetum','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'tet','tet');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tet', 'language', 'tet', 'Tetun');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tet', 'language', 'en', 'Tetum');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tet', 'language', 'fr', 'Tétoum');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tet', 'language', 'de', 'Tetum');

-- Thai
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'th', 'language', 'Thai','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'th','tha');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'th', 'language', 'th', 'ภาษาไทย');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'th', 'language', 'en', 'Thai');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'th', 'language', 'fr', 'Thaï');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'th', 'language', 'de', 'Thailändisch');

-- Tagalog
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'tl', 'language', 'Tagalog','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'tl','tgl');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tl', 'language', 'tl', 'Tagalog');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tl', 'language', 'en', 'Tagalog');

-- Turkish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'tr', 'language', 'Turkish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'tr','tur');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tr', 'language', 'tr', 'Türkçe');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tr', 'language', 'en', 'Turkish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tr', 'language', 'fr', 'Turc');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'tr', 'language', 'de', 'Türkisch');

-- Ukranian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'uk', 'language', 'Ukranian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'uk','ukr');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'uk', 'language', 'uk', 'Українська');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'uk', 'language', 'en', 'Ukranian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'uk', 'language', 'fr', 'Ukrainien');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'uk', 'language', 'de', 'Ukrainisch');

-- Urdu
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ur', 'language', 'Urdu','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'ur','urd');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ur', 'language', 'en', 'Urdu');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ur', 'language', 'ur', 'اردو');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ur', 'language', 'fr', 'Ourdou');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ur', 'language', 'de', 'Urdu');

-- Vietnamese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'vi', 'language', 'Vietnamese','2014-10-30');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'vi','vie');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'vi', 'language', 'vi', '㗂越');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'vi', 'language', 'en', 'Vietnamese');

-- Votic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'vot', 'language', 'Votic', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'vot', 'vot');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'vot', 'language', 'en', 'Votic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'vot', 'language', 'vot', 'vađđa ceeli');

-- Yiddish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'yi', 'language', 'Yiddish', '2017-04-21');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'yi', 'yid');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'yi', 'language', 'en', 'Yiddish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'yi', 'language', 'yi', 'יידיש');

-- Chinese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'zh', 'language', 'Chinese','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES ( 'zh','chi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'zh', 'language', 'zh', '中文');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'zh', 'language', 'en', 'Chinese');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'zh', 'language', 'fr', 'Chinois');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'zh', 'language', 'de', 'Chinesisch');

-- SCRIPTS
-- Arabic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Arab', 'script', 'Arabic','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Arab','script', 'Arab', 'العربية');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Arab', 'script','en', 'Arabic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Arab', 'script','fr', 'Arabic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Arab', 'script', 'de', 'Arabisch');

-- Armenian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Armn', 'script', 'Armenian','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Armn', 'script', 'Armn', 'Հայոց այբուբեն');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Armn', 'script', 'en', 'Armenian');

-- Cyrillic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Cyrl', 'script', 'Cyrillic','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Cyrl', 'script', 'Cyrl', 'Кирилица');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Cyrl', 'script', 'en', 'Cyrillic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Cyrl', 'script', 'fr', 'Cyrillic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Cyrl', 'script', 'de', 'Kyrillisch');

-- Ethiopic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Ethi', 'script', 'Ethiopic','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Ethi', 'script', 'Ethi', 'ግዕዝ');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Ethi', 'script', 'en', 'Ethiopic');

-- Greek
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Grek', 'script', 'Greek','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Grek', 'script', 'Grek', 'Ελληνικό αλφάβητο');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Grek', 'script', 'en', 'Greek');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Grek', 'script', 'fr', 'Greek');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Grek', 'script', 'de', 'Griechisch');


-- Han - Simplified
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Hans', 'script', 'Han (Simplified variant)','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hans', 'script', 'Hans', '简体字');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hans', 'script', 'en', 'Han (Simplified variant)');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hans', 'script', 'fr', 'Han (Simplified variant)');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hans', 'script', 'de', 'Han (Vereinfachte Variante)');


-- Han - Traditional
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Hant', 'script', 'Han (Traditional variant)','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hant', 'script', 'Hant', '繁體字');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hant', 'script', 'en', 'Han (Traditional variant)');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hant', 'script', 'de', 'Han (Traditionelle Variante)');

-- Hebrew
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Hebr', 'script', 'Hebrew','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hebr', 'script', 'Hebr', 'אָלֶף־בֵּית עִבְרִי');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hebr', 'script', 'en', 'Hebrew');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hebr', 'script', 'de', 'Hebräisch');

-- Japanese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Jpan', 'script', 'Japanese','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Jpan', 'script', 'Jpan', '漢字');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Jpan', 'script', 'en', 'Japanese');

-- Kannada
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Knda', 'script', 'Kannada','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Knda', 'script', 'Knda', 'ಕನ್ನಡ ಲಿಪಿ');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Knda', 'script', 'en', 'Kannada');

-- Korean
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Kore', 'script', 'Korean','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Kore', 'script', 'Kore', '한글');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Kore', 'script', 'en', 'Korean');

-- Lao
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Laoo', 'script', 'Lao','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Laoo', 'script', 'Laoo', 'ອັກສອນລາວ');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Laoo', 'script', 'en', 'Lao');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Laoo', 'script', 'de', 'Laotisch');


-- REGIONS - Order by country code
-- Albania
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'AL', 'region', 'Albania','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'AL', 'region', 'en', 'Albania');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'AL', 'region', 'sq', 'Shqipërisë');

-- Azerbaijan
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'AZ', 'region', 'Azerbaijan','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'AZ', 'region', 'en', 'Azerbaijan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'AZ', 'region', 'az', 'Azərbaycan');

-- Belgium
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'BE', 'region', 'Belgium','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'BE', 'region', 'en', 'Belgium');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'BE', 'region', 'nl', 'België');

-- Brazil
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'BR', 'region', 'Brazil','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'BR', 'region', 'en', 'Brazil');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'BR', 'region', 'pt', 'Brasil');

-- Belarus
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'BY', 'region', 'Belarus','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'BY', 'region', 'en', 'Belarus');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'BY', 'region', 'be', 'Беларусь');

-- Canada
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'CA', 'region', 'Canada','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'CA', 'region', 'en', 'Canada');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'CA', 'region', 'fr', 'Canada');

-- Switzerland
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'CH', 'region', 'Switzerland','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'CH', 'region', 'en', 'Switzerland');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'CH', 'region', 'de', 'Schweiz');

-- China
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'CN', 'region', 'China','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'CN', 'region', 'en', 'China');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'CN', 'region', 'zh', '中国');

-- Czech Republic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'CZ', 'region', 'Czech Republic','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'CZ', 'region', 'en', 'Czech Republic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'CZ', 'region', 'cs', 'Česká republika');

-- Germany
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'DE', 'region', 'Germany','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'DE', 'region', 'en', 'Germany');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'DE', 'region', 'de', 'Deutschland');

-- Denmark
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'DK', 'region', 'Denmark','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'DK', 'region', 'en', 'Denmark');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'DK', 'region', 'dk', 'Danmark');

-- Spain
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ES', 'region', 'Spain','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ES', 'region', 'en', 'Spain');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ES', 'region', 'es', 'España');

-- Finland
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'FI', 'region', 'Finland','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'FI', 'region', 'en', 'Finland');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'FI', 'region', 'fi', 'Suomi');

-- Faroe Islands
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'FO', 'region', 'Faroe Islands','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'FO', 'region', 'en', 'Faroe Islands');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'FO', 'region', 'fo', 'Føroyar');

-- France
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'FR', 'region', 'France','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'FR', 'region', 'en', 'France');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'FR', 'region', 'fr', 'France');

-- United Kingdom
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'GB', 'region', 'United Kingdom','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'GB', 'region', 'en', 'United Kingdom');

-- Greece
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'GR', 'region', 'Greece','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'GR', 'region', 'en', 'Greece');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'GR', 'region', 'el', 'Ελλάδα');

-- Croatia
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'HR', 'region', 'Croatia','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'HR', 'region', 'en', 'Croatia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'HR', 'region', 'hr', 'Hrvatska');

-- Hungary
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'HU', 'region', 'Hungary','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'HU', 'region', 'en', 'Hungary');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'HU', 'region', 'hu', 'Magyarország');

-- Indonesia
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ID', 'region', 'Indonesia','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ID', 'region', 'en', 'Indonesia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ID', 'region', 'id', 'Indonesia');

-- India
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'IN', 'region', 'India','2015-05-28');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'IN', 'region', 'en', 'India');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'IN', 'region', 'bn', 'ভারত');

-- Iceland
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'IS', 'region', 'Iceland','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'IS', 'region', 'en', 'Iceland');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'IS', 'region', 'is', 'Ísland');

-- Italy
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'IT', 'region', 'Italy','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'IT', 'region', 'en', 'Italy');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'IT', 'region', 'it', 'Italia');

-- Japan
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'JP', 'region', 'Japan','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'JP', 'region', 'en', 'Japan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'JP', 'region', 'ja', '日本');

-- Kenya
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'KE', 'region', 'Kenya','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'KE', 'region', 'en', 'Kenya');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'KE', 'region', 'rw', 'Kenya');

-- Cambodia
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'KH', 'region', 'Cambodia','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'KH', 'region', 'en', 'Cambodia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'KH', 'region', 'km', 'កម្ពុជា');

-- North Korea
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'KP', 'region', 'North Korea','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'KP', 'region', 'en', 'North Korea');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'KP', 'region', 'ko', '조선민주주의인민공화국');

-- Sri Lanka
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'LK', 'region', 'Sri Lanka','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'LK', 'region', 'en', 'Sri Lanka');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'LK', 'region', 'ta', 'இலங்கை');

-- Malaysia
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'MY', 'region', 'Malaysia','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'MY', 'region', 'en', 'Malaysia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'MY', 'region', 'ms', 'Malaysia');

-- Niger
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'NE', 'region', 'Niger','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'NE', 'region', 'en', 'Niger');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'NE', 'region', 'ne', 'Niger');

-- Netherlands
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'NL', 'region', 'Netherlands','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'NL', 'region', 'en', 'Netherlands');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'NL', 'region', 'nl', 'Nederland');

-- Norway
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'NO', 'region', 'Norway','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'NO', 'region', 'en', 'Norway');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'NO', 'region', 'ne', 'Noreg');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'NO', 'region', 'nn', 'Noreg');

-- New Zealand
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'NZ', 'region', 'New Zealand','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'NZ', 'region', 'en', 'New Zealand');

-- Philippines
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'PH', 'region', 'Philippines','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'PH', 'region', 'en', 'Philippines');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'PH', 'region', 'tl', 'Pilipinas');

-- Pakistan
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'PK', 'region', 'Pakistan','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'PK', 'region', 'en', 'Pakistan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'PK', 'region', 'sd', 'پاكستان');

-- Poland
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'PL', 'region', 'Poland','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'PL', 'region', 'en', 'Poland');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'PL', 'region', 'pl', 'Polska');

-- Portugal
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'PT', 'region', 'Portugal','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'PT', 'region', 'en', 'Portugal');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'PT', 'region', 'pt', 'Portugal');

-- Romania
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'RO', 'region', 'Romania','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'RO', 'region', 'en', 'Romania');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'RO', 'region', 'ro', 'România');

-- Russia
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'RU', 'region', 'Russia','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'RU', 'region', 'en', 'Russia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'RU', 'region', 'ru', 'Россия');

-- Rwanda
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'RW', 'region', 'Rwanda','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'RW', 'region', 'en', 'Rwanda');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'RW', 'region', 'rw', 'Rwanda');

-- Sweden
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'SE', 'region', 'Sweden','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'SE', 'region', 'en', 'Sweden');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'SE', 'region', 'sv', 'Sverige');

-- Slovenia
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'SI', 'region', 'Slovenia','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'SI', 'region', 'en', 'Slovenia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'SI', 'region', 'sl', 'Slovenija');

-- Slovakia
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'SK', 'region', 'Slovakia','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'SK', 'region', 'en', 'Slovakia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'SK', 'region', 'sk', 'Slovensko');

-- Thailand
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'TH', 'region', 'Thailand','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'TH', 'region', 'en', 'Thailand');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'TH', 'region', 'th', 'ประเทศไทย');

-- Turkey
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'TR', 'region', 'Turkey','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'TR', 'region', 'en', 'Turkey');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'TR', 'region', 'tr', 'Türkiye');

-- Taiwan
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'TW', 'region', 'Taiwan','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'TW', 'region', 'en', 'Taiwan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'TW', 'region', 'zh', '台灣');

-- Ukraine
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'UA', 'region', 'Ukraine','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'UA', 'region', 'en', 'Ukraine');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'UA', 'region', 'uk', 'Україна');

-- United States
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'US', 'region', 'United States','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'US', 'region', 'en', 'United States');

-- Vietnam
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'VN', 'region', 'Vietnam','2014-10-30');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'VN', 'region', 'en', 'Vietnam');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'VN', 'region', 'vi', 'Việt Nam');
