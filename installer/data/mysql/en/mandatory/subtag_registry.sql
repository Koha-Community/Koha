-- http://www.w3.org/International/articles/language-tags/

-- BIDI Stuff, Arabic and Hebrew
INSERT INTO language_script_bidi(rfc4646_subtag,bidi)
VALUES( 'Arab', 'rtl');
INSERT INTO language_script_bidi(rfc4646_subtag,bidi)
VALUES( 'Hebr', 'rtl');

-- Default mappings between script and language subcodes
INSERT INTO language_script_mapping(language_subtag,script_subtag)
VALUES( 'ar', 'Arab');
INSERT INTO language_script_mapping(language_subtag,script_subtag)
VALUES( 'he', 'Hebr');

-- EXTENSIONS
-- Interface (i)
-- SELECT * FROM language_subtag_registry WHERE type='i';
-- OPAC
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'opac', 'i', 'OPAC','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'opac', 'i', 'en', 'OPAC');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'opac', 'i', 'fr', 'OPAC');

-- Staff Client
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'intranet', 'i', 'Staff Client','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'intranet', 'i', 'en', 'Staff Client');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'intranet', 'i', 'fr', '????');

-- Theme (t)
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'prog', 't', 'Prog','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'prog', 't', 'en', 'Prog');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'prog', 't', 'fr', 'Prog');

-- LANGUAGES

-- Arabic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ar', 'language', 'Arabic','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'ar','ara');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ar', 'language', 'ar', '&#1575;&#1604;&#1593;&#1585;&#1576;&#1610;&#1577;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ar', 'language', 'en', 'Arabic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ar', 'language', 'fr', 'Arabe');

-- Armenian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'hy', 'language', 'Armenian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'hy','hy');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'hy', 'language', 'hy', '&#1344;&#1377;&#1397;&#1381;&#1408;&#1383;&#1398;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'hy', 'language', 'en', 'Armenian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'hy', 'language', 'fr', 'Armenian');

-- Bulgarian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'bg', 'language', 'Bulgarian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'bg','bul');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'bg', 'language', 'bg', '&#1041;&#1098;&#1083;&#1075;&#1072;&#1088;&#1089;&#1082;&#1080;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'bg', 'language', 'en', 'Bulgarian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'bg', 'language', 'fr', 'Bulgare');

-- Chinese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'zh', 'language', 'Chinese','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'zh','chi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'zh', 'language', 'zh', '&#20013;&#25991;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'zh', 'language', 'en', 'Chinese');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'zh', 'language', 'fr', 'Chinois');

-- Czech
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'cs', 'language', 'Czech','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'cs','cze');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'cs', 'language', 'cs', '&#x010D;e&#353;tina');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'cs', 'language', 'en', 'Czech');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'cs', 'language', 'fr', 'Tchèque');

-- Danish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'da', 'language', 'Danish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'da','dan');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'da', 'language', 'da', 'D&aelig;nsk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'da', 'language', 'en', 'Danish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'da', 'language', 'fr', 'Danois');

-- Dutch, Flemish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'nl', 'language', 'Dutch','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'nl','dut');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'nl', 'language', 'nl', 'ned&#601;rl&#593;ns');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'nl', 'language', 'en', 'Dutch');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'nl', 'language', 'fr', 'Néerlandais');

-- English
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'en', 'language', 'English','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'en','en');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'en', 'language', 'en', 'English');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'en', 'language', 'fr', 'Anglais');

-- English
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'fi', 'language', 'Finnish','2005-10-16' );

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'fi', 'language', 'fi', 'suomi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'fi', 'language', 'en', 'Finnish');

-- French
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'fr', 'language', 'French','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'fr','fr');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'fr', 'language', 'en', 'French');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'fr', 'language', 'fr', 'Fran&ccedil;ais');

-- INSERT INTO language_descriptions(subtag, type, lang, description)
-- VALUES( 'fr-CA', 'language', 'fr-CA', 'fran&ccedil;ais');

-- Lao
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'lo', 'language', 'Lao','2005-10-16' );

--INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
--VALUES( 'lo','nor'); ???

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'lo', 'language', 'lo', '&#3742;&#3762;&#3754;&#3762;&#3749;&#3762;&#3751;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'lo', 'language', 'en', 'Lao');

-- German
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'de', 'language', 'German','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'de','ger');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'de', 'language', 'de', 'Deutsch');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'de', 'language', 'en', 'German');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'de', 'language', 'fr', 'Allemand');

-- Greek
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'el', 'language', 'Greek, Modern [1453- ]','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'el','gre');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'el', 'language', 'el', '&#949;&#955;&#955;&#951;&#957;&#953;&#954;&#940;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'el', 'language', 'en', 'Greek, Modern [1453- ]');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'el', 'language', 'fr', 'Grec Moderne (Après 1453)');

-- Hebrew
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'he', 'language', 'Hebrew','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'he','heb');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'he', 'language', 'he', '&#1506;&#1489;&#1512;&#1497;&#1514;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'he', 'language', 'en', 'Hebrew');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'he', 'language', 'fr', 'Hébreu');

-- Hindi
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'hi', 'language', 'Hindi','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'hi','hin');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'hi', 'language', 'hi', '&#2361;&#2367;&#2344;&#2381;&#2342;&#2368;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'hi', 'language', 'en', 'Hindi');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'hi', 'language', 'fr', 'Hindi');

-- Hungarian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'hu', 'language', 'Hungarian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'hu','hun');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'hu', 'language', 'hu', 'Magyar');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'hu', 'language', 'en', 'Hungarian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'hu', 'language', 'fr', 'Hongrois');

-- Indonesian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'id', 'language', 'Indonesian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'id','ind');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'id', 'language', 'id', 'Bahasa Indonesia');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'id', 'language', 'en', 'Indonesian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'id', 'language', 'fr', 'Indonésien');

-- Italian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'it', 'language', 'Italian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'it','ind');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'it', 'language', 'it', 'Italiano');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'it', 'language', 'en', 'Italian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'it', 'language', 'fr', 'Italien');

-- Japanese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ja', 'language', 'Japanese','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'ja','jpn');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ja', 'language', 'ja', '&#26085;&#26412;&#35486;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ja', 'language', 'en', 'Japanese');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ja', 'language', 'fr', 'Japonais');

-- Korean
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ko', 'language', 'Korean','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'ko','kor');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ko', 'language', 'ko', '&#54620;&#44397;&#50612;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ko', 'language', 'en', 'Korean');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ko', 'language', 'fr', 'Coréen');

-- Latin
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'la', 'language', 'Latin','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'la','lat');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'la', 'language', 'la', 'Latina');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'la', 'language', 'en', 'Latin');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'la', 'language', 'fr', 'Latin');

-- Galacian

INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'gl', 'language', 'Galician','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'gl','glg');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'gl', 'language', 'gl', 'Galego');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'gl', 'language', 'en', 'Galician');

-- Norwegian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'nb', 'language', 'Norwegian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'nb','nor');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'nb', 'language', 'nb', 'Norsk');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'nb', 'language', 'en', 'Norwegian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'nb', 'language', 'fr', 'Norvégien');

-- Persian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'fa', 'language', 'Persian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'fa','per');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'fa', 'language', 'fa', '&#1601;&#1575;&#1585;&#1587;&#1609;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'fa', 'language', 'en', 'Persian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'fa', 'language', 'fr', 'Persan');

-- Polish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'pl', 'language', 'Polish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'pl','pol');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'pl', 'language', 'pl', 'Polski');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'pl', 'language', 'en', 'Polish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'pl', 'language', 'fr', 'Polonais');

-- Portuguese
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'pt', 'language', 'Portuguese','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'pt','pol');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'pt', 'language', 'pt', 'Portugu&ecirc;s');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'pt', 'language', 'en', 'Portuguese');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'pt', 'language', 'fr', 'Portugais');

-- Romanian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ro', 'language', 'Romanian','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'ro','rum');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ro', 'language', 'ro', 'Rom&acirc;n&#259;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ro', 'language', 'en', 'Romanian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ro', 'language', 'fr', 'Roumain');

-- Russian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ru', 'language', 'Russian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'ru','rus');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ru', 'language', 'ru', '&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ru', 'language', 'en', 'Russian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ru', 'language', 'fr', 'Russe');

-- Serbian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sr', 'language', 'Serbian','2005-10-16' );

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'sr', 'language', 'sr', '&#1089;&#1088;&#1087;&#1089;&#1082;&#1080;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'sr', 'language', 'en', 'Serbian');

-- Spanish, Castilian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'es', 'language', 'Spanish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'es','rus');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'es', 'language', 'es', 'Espa&ntilde;ol');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'es', 'language', 'en', 'Spanish');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'es', 'language', 'fr', 'Espagnol');

-- Swedish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'sv', 'language', 'Swedish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'sv','swe');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'sv', 'language', 'sv', 'Svenska');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'sv', 'language', 'en', 'Swedish');   

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'sv', 'language', 'fr', 'Suédois');

-- Tetum
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'tet', 'language', 'Tetum','2005-10-16' );

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'tet', 'language', 'tet', 'tetun');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'tet', 'language', 'en', 'Tetum');

-- Thai
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'th', 'language', 'Thai','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'th','tha');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'th', 'language', 'th', '&#3616;&#3634;&#3625;&#3634;&#3652;&#3607;&#3618;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'th', 'language', 'en', 'Thai');   

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'th', 'language', 'fr', 'Thaï');

-- Turkish
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'tr', 'language', 'Turkish','2005-10-16' );

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'tr','tur');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'tr', 'language', 'tr', 'T&uuml;rk&ccedil;e');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'tr', 'language', 'en', 'Turkish');   

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'tr', 'language', 'fr', 'Turc');


-- Ukranian
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'uk', 'language', 'Ukranian','2005-10-16');

INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
VALUES( 'uk','ukr');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'uk', 'language', 'uk', '&#1059;&#1082;&#1088;&#1072;&#1111;&#1085;&#1089;&#1100;&#1082;&#1072;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'uk', 'language', 'en', 'Ukranian');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'uk', 'language', 'fr', 'Ukrainien');

-- English
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'ur', 'language', 'Urdu','2005-10-16' );

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ur', 'language', 'en', 'Urdu');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'ur', 'language', 'ur', '&#1575;&#1585;&#1583;&#1608;');

-- SCRIPTS
-- Arabic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Arab', 'script', 'Arabic','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Arab','script', 'Arab', '&#1575;&#1604;&#1593;&#1585;&#1576;&#1610;&#1577;');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Arab', 'script','en', 'Arabic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Arab', 'script','fr', 'Arabic');

-- Cyrillic
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Cyrl', 'script', 'Cyrillic','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Cyrl', 'script', 'Cyrl', '????');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Cyrl', 'script', 'en', 'Cyrillic');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Cyrl', 'script', 'fr', 'Cyrillic');

-- Greek
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Grek', 'script', 'Greek','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Grek', 'script', 'Grek', '????');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Grek', 'script', 'en', 'Greek');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Grek', 'script', 'fr', 'Greek');

-- Han - Simplified
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Hans', 'script', 'Han (Simplified variant)','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hans', 'script', 'Hans', 'Han (Simplified variant)');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Hans', 'script', 'en', 'Han (Simplified variant)');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Hans', 'script', 'fr', 'Han (Simplified variant)');

-- Han - Traditional
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Hant', 'script', 'Han (Traditional variant)','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hant', 'script', 'Hant', 'Han (Traditional variant)');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Hant', 'script', 'en', 'Han (Traditional variant)');

-- Hebrew
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Hebr', 'script', 'Hebrew','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Hebr', 'script', 'Hebr', 'Hebrew');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Hebr', 'script', 'en', 'Hebrew');

-- Lao
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'Laoo', 'script', 'Lao','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'Laoo', 'script', 'lo', 'Lao');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'Laoo', 'script', 'en', 'Lao');

-- REGIONS
-- Canada
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'CA', 'region', 'Canada','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'CA', 'region', 'en', 'Canada');

-- Denmark
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'DK', 'region', 'Denmark','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'DK', 'region', 'dk', 'Danmark');

-- France
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'FR', 'region', 'France','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'FR', 'region', 'fr', 'France');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'FR', 'region', 'en', 'France');

-- New Zealand
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'NZ', 'region', 'New Zealand','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'NZ', 'region', 'en', 'New Zealand');

-- United Kingdom
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'GB', 'region', 'United Kingdom','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'GB', 'region', 'en', 'United Kingdom');

-- United States
INSERT INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'US', 'region', 'United States','2005-10-16');

INSERT INTO language_descriptions(subtag, type, lang, description)
VALUES( 'US', 'region', 'en', 'United States');
