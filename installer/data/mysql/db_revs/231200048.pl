use Modern::Perl;

return {
    bug_number  => "33134",
    description => "Add some 76 missing languages",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('grc', 'language', 'Ancient Greek (to 1453)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('grc', 'grc') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('grc', 'language', 'en', 'Greek, Ancient (to 1453)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('grc', 'language', 'pl', 'Grecki starożytny (do 1453)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('syr', 'language', 'Syriac', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('syr', 'syr') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('syr', 'language', 'en', 'Syriac, Modern') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('syr', 'language', 'pl', 'Syryjski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cu', 'language', 'Church Slavic', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cu', 'chu') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cu', 'language', 'en', 'Church Slavic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cu', 'language', 'pl', 'Staro-cerkiewno-słowiański') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cop', 'language', 'Coptic', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cop', 'cop') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cop', 'language', 'en', 'Coptic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cop', 'language', 'pl', 'Koptyjski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('arc', 'language', 'Official Aramaic (700-300 BCE)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('arc', 'arc') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('arc', 'language', 'en', 'Aramaic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('arc', 'language', 'pl', 'Aramejski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ang', 'language', 'Old English (ca. 450-1100)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ang', 'ang') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ang', 'language', 'en', 'English, Old (ca. 450-1100)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ang', 'language', 'pl', 'Staroangielski (ok. 450-1100)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('eo', 'language', 'Esperanto', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('eo', 'epo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('eo', 'language', 'en', 'Esperanto') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('eo', 'language', 'pl', 'Esperanto') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('syc', 'language', 'Classical Syriac', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('syc', 'syc') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('syc', 'language', 'en', 'Syriac') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('syc', 'language', 'pl', 'Syryjski klasyczny') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gez', 'language', 'Geez', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gez', 'gez') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gez', 'language', 'en', 'Ethiopic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gez', 'language', 'pl', 'Ge''ez (gyyz)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sla', 'language', 'Slavic languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sla', 'sla') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sla', 'language', 'en', 'Slavic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sla', 'language', 'pl', 'Słowiańskie (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sa', 'language', 'Sanskrit', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sa', 'san') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sa', 'language', 'en', 'Sanskrit') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sa', 'language', 'pl', 'Sanskryt') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('csb', 'language', 'Kashubian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('csb', 'csb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('csb', 'language', 'en', 'Kashubian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('csb', 'language', 'pl', 'Kaszubski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('akk', 'language', 'Akkadian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('akk', 'akk') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('akk', 'language', 'en', 'Akkadian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('akk', 'language', 'pl', 'Akadyjski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gmh', 'language', 'Middle High German (ca. 1050-1500)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gmh', 'gmh') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gmh', 'language', 'en', 'German, Middle High (ca. 1050-1500)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gmh', 'language', 'pl', 'Średnio-wysoko-niemiecki (ok. 1050-1500)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('egy', 'language', 'Egyptian (Ancient)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('egy', 'egy') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('egy', 'language', 'en', 'Egyptian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('egy', 'language', 'pl', 'Egipski starożytny') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('wen', 'language', 'Sorbian languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('wen', 'wen') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('wen', 'language', 'en', 'Sorbian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('wen', 'language', 'pl', 'Łużyckie (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ga', 'language', 'Irish', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ga', 'gle') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ga', 'language', 'en', 'Irish') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ga', 'language', 'pl', 'Irlandzki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fro', 'language', 'Old French (842-ca. 1400)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fro', 'fro') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fro', 'language', 'en', 'French, Old (ca. 842-1300)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fro', 'language', 'pl', 'Starofrancuski (ok. 842-1300)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('rom', 'language', 'Romany', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('rom', 'rom') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rom', 'language', 'en', 'Romani') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rom', 'language', 'pl', 'Romani (cygański)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mk', 'language', 'Macedonian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mk', 'mac') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mk', 'language', 'en', 'Macedonian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mk', 'language', 'pl', 'Macedoński') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ml', 'language', 'Malayalam', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ml', 'mal') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ml', 'language', 'en', 'Malayalam') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ml', 'language', 'pl', 'Malajalam') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('uga', 'language', 'Ugaritic', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('uga', 'uga') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('uga', 'language', 'en', 'Ugaritic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('uga', 'language', 'pl', 'Ugarycki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mis', 'language', 'Uncoded languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mis', 'mis') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mis', 'language', 'en', 'Miscellaneous languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mis', 'language', 'pl', 'Różne języki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sem', 'language', 'Semitic languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sem', 'sem') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sem', 'language', 'en', 'Semitic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sem', 'language', 'pl', 'Semickie (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sux', 'language', 'Sumerian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sux', 'sux') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sux', 'language', 'en', 'Sumerian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sux', 'language', 'pl', 'Sumeryjski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('pi', 'language', 'Pali', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('pi', 'pli') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pi', 'language', 'en', 'Pali') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pi', 'language', 'pl', 'Pali') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bs', 'language', 'Bosnian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bs', 'bos') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bs', 'language', 'en', 'Bosnian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bs', 'language', 'pl', 'Bośniacki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ce', 'language', 'Chechen', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ce', 'che') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ce', 'language', 'en', 'Chechen') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ce', 'language', 'pl', 'Czeczeński') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dum', 'language', 'Middle Dutch (ca. 1050-1350)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dum', 'dum') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dum', 'language', 'en', 'Dutch, Middle (ca. 1050-1350)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dum', 'language', 'pl', 'Średnioniderlandzki (ok. 1050-1350)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kk', 'language', 'Kazakh', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kk', 'kaz') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kk', 'language', 'en', 'Kazakh') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kk', 'language', 'pl', 'Kazachski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bo', 'language', 'Tibetan', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bo', 'tib') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bo', 'language', 'en', 'Tibetan') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bo', 'language', 'pl', 'Tybetański') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('enm', 'language', 'Middle English (1100-1500)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('enm', 'enm') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('enm', 'language', 'en', 'English, Middle (1100-1500)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('enm', 'language', 'pl', 'Średnioangielski (1100-1500)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('frm', 'language', 'Middle French (ca. 1400-1600)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('frm', 'frm') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('frm', 'language', 'en', 'French, Middle (ca. 1300-1600)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('frm', 'language', 'pl', 'Średniofrancuski (ok. 1300-1600)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mt', 'language', 'Maltese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mt', 'mlt') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mt', 'language', 'en', 'Maltese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mt', 'language', 'pl', 'Maltański') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('got', 'language', 'Gothic', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('got', 'got') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('got', 'language', 'en', 'Gothic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('got', 'language', 'pl', 'Gocki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nds', 'language', 'Low German', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nds', 'nds') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nds', 'language', 'en', 'Low German') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nds', 'language', 'pl', 'Dolnoniemiecki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ira', 'language', 'Iranian languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ira', 'ira') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ira', 'language', 'en', 'Iranian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ira', 'language', 'pl', 'Irańskie (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ln', 'language', 'Lingala', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ln', 'lin') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ln', 'language', 'en', 'Lingala') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ln', 'language', 'pl', 'Lingala') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('uz', 'language', 'Uzbek', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('uz', 'uzb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('uz', 'language', 'en', 'Uzbek') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('uz', 'language', 'pl', 'Uzbecki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ae', 'language', 'Avestan', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ae', 'ave') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ae', 'language', 'en', 'Avestan') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ae', 'language', 'pl', 'Awestyjski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cho', 'language', 'Choctaw', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cho', 'cho') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cho', 'language', 'en', 'Choctaw') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cho', 'language', 'pl', 'Choctaw') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('jrb', 'language', 'Judeo-Arabic', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('jrb', 'jrb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('jrb', 'language', 'en', 'Judeo-Arabic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('jrb', 'language', 'pl', 'Judeo-arabski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bnt', 'language', 'Bantu languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bnt', 'bnt') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bnt', 'language', 'en', 'Bantu (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bnt', 'language', 'pl', 'Bantu (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('pal', 'language', 'Pahlavi', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('pal', 'pal') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pal', 'language', 'en', 'Pahlavi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pal', 'language', 'pl', 'Pahlawi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tut', 'language', 'Altaic languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tut', 'tut') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tut', 'language', 'en', 'Altaic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tut', 'language', 'pl', 'Ałtajskie (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('goh', 'language', 'Old High German (ca. 750-1050)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('goh', 'goh') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('goh', 'language', 'en', 'German, Old High (ca. 750-1050)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('goh', 'language', 'pl', 'Staro-wysoko-niemiecki (ok.750-1050)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('hsb', 'language', 'Upper Sorbian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('hsb', 'hsb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('hsb', 'language', 'en', 'Upper Sorbian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('hsb', 'language', 'pl', 'Górnołużycki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('inc', 'language', 'Indic languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('inc', 'inc') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('inc', 'language', 'en', 'Indic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mg', 'language', 'Malagasy', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mg', 'mlg') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mg', 'language', 'en', 'Malagasy') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mg', 'language', 'pl', 'Malgaski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('roa', 'language', 'Romance languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('roa', 'roa') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('roa', 'language', 'en', 'Romance (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('roa', 'language', 'pl', 'Romańskie (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cel', 'language', 'Celtic languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cel', 'cel') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cel', 'language', 'en', 'Celtic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cel', 'language', 'pl', 'Celtyckie (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sam', 'language', 'Samaritan Aramaic', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sam', 'sam') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sam', 'language', 'en', 'Samaritan Aramaic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sam', 'language', 'pl', 'Samarytański') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bem', 'language', 'Bemba (Zambia)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bem', 'bem') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bem', 'language', 'en', 'Bemba') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bem', 'language', 'pl', 'Bemba') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fur', 'language', 'Friulian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fur', 'fur') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fur', 'language', 'en', 'Friulian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fur', 'language', 'pl', 'Friulski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gem', 'language', 'Germanic languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gem', 'gem') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gem', 'language', 'en', 'Germanic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gem', 'language', 'pl', 'Germańskie (inne)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('hit', 'language', 'Hittite', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('hit', 'hit') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('hit', 'language', 'en', 'Hittite') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('hit', 'language', 'pl', 'Hetycki') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lad', 'language', 'Ladino', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lad', 'lad') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lad', 'language', 'en', 'Ladino') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lad', 'language', 'pl', 'Ladino') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nah', 'language', 'Nahuatl languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nah', 'nah') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nah', 'language', 'en', 'Nahuatl') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nah', 'language', 'pl', 'Nahuatl') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ota', 'language', 'Ottoman Turkish (1500-1928)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ota', 'ota') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ota', 'language', 'en', 'Turkish, Ottoman') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ota', 'language', 'pl', 'Turecko-osmański (1500-1928)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('peo', 'language', 'Old Persian (ca. 600-400 B.C.)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('peo', 'peo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('peo', 'language', 'en', 'Old Persian (ca. 600-400 B.C.)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('peo', 'language', 'pl', 'Staroperski (ok. 600-400 p.n.e.)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('pro', 'language', 'Old Provençal (to 1500)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('pro', 'pro') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pro', 'language', 'en', 'Provençal (to 1500)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pro', 'language', 'pl', 'Staroprowansalski (do1500)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tt', 'language', 'Tatar', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tt', 'tat') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tt', 'language', 'en', 'Tatar') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tt', 'language', 'pl', 'Tatarski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cy', 'language', 'Welsh', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cy', 'wel') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cy', 'language', 'en', 'Welsh') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cy', 'language', 'pl', 'Walijski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('yo', 'language', 'Yoruba', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('yo', 'yor') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('yo', 'language', 'en', 'Yoruba') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('yo', 'language', 'pl', 'Joruba') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bra', 'language', 'Braj', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bra', 'bra') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bra', 'language', 'en', 'Braj') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bra', 'language', 'pl', 'Bradź') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('den', 'language', 'Slave (Athapascan)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('den', 'den') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('den', 'language', 'en', 'Slavey') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('den', 'language', 'pl', 'Niewolnicze (atapaskańskie)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ha', 'language', 'Hausa', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ha', 'hau') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ha', 'language', 'en', 'Hausa') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ha', 'language', 'pl', 'Hausa') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('hz', 'language', 'Herero', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('hz', 'her') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('hz', 'language', 'en', 'Herero') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('hz', 'language', 'pl', 'Herero') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ks', 'language', 'Kashmiri', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ks', 'kas') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ks', 'language', 'en', 'Kashmiri') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ks', 'language', 'pl', 'Kaszmirski') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mga', 'language', 'Middle Irish (900-1200)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mga', 'mga') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mga', 'language', 'en', 'Irish, Middle (ca. 1100-1550)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mga', 'language', 'pl', 'Średnioirlandzki (1100-1550)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('myn', 'language', 'Mayan languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('myn', 'myn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('myn', 'language', 'en', 'Mayan languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('myn', 'language', 'pl', 'Majańskie') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ny', 'language', 'Nyanja', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ny', 'nya') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ny', 'language', 'en', 'Nyanja') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ny', 'language', 'pl', 'Nyanja') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('pra', 'language', 'Prakrit languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('pra', 'pra') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pra', 'language', 'en', 'Prakrit languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pra', 'language', 'pl', 'Prakryty') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('qu', 'language', 'Quechua', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('qu', 'que') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('qu', 'language', 'en', 'Quechua') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('qu', 'language', 'pl', 'Keczua') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ti', 'language', 'Tigrinya', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ti', 'tir') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ti', 'language', 'en', 'Tigrinya') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ti', 'language', 'pl', 'Tigrinia') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tk', 'language', 'Turkmen', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tk', 'tuk') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tk', 'language', 'en', 'Turkmen') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tk', 'language', 'pl', 'Turkmeński') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gwi', 'language', 'Gwichʼin', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gwi', 'gwi') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gwi', 'language', 'en', 'Gwichʼin') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gwi', 'language', 'pl', 'Gwichʼin') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dgr', 'language', 'Dogrib', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dgr', 'dgr') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dgr', 'language', 'en', 'Dogrib') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dgr', 'language', 'pl', 'Dogrib') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('chp', 'language', 'Chipewyan', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('chp', 'chp') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chp', 'language', 'en', 'Chipewyan') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chp', 'language', 'pl', 'Chipewyan') }
        );

        # Print useful stuff here
        say $out "Added 76 new languages";
    },
};
