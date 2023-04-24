use Modern::Perl;

return {
    bug_number => "33128",
    description => "Add missing Polish (pl) language translations",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'af', 'language', 'pl', 'Afrikaans') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sq', 'language', 'pl', 'Albański') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'am', 'language', 'pl', 'Amharski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ar', 'language', 'pl', 'Arabski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'hy', 'language', 'pl', 'Ormiański') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'az', 'language', 'pl', 'Azerbejdżański') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'eu', 'language', 'pl', 'Baskijski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'bn', 'language', 'pl', 'Bengalski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'bg', 'language', 'pl', 'Bułgarski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'be', 'language', 'pl', 'Białoruski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ca', 'language', 'pl', 'Kataloński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'zh', 'language', 'pl', 'Chiński (mandaryński)') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'cr', 'language', 'pl', 'Kri') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'hr', 'language', 'pl', 'Chorwacki') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'cs', 'language', 'pl', 'Czeski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'da', 'language', 'pl', 'Duński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'nl', 'language', 'pl', 'Niderlandzki') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'en', 'language', 'pl', 'Angielski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'et', 'language', 'pl', 'Estoński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'fo', 'language', 'pl', 'Farerski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'fi', 'language', 'pl', 'Fiński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'fr', 'language', 'pl', 'Francuski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'gl', 'language', 'pl', 'Galicyjski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ka', 'language', 'pl', 'Gruziński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'de', 'language', 'pl', 'Niemiecki') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'grc', 'language', 'pl', 'Grecki starożytny (do 1453)') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'el', 'language', 'pl', 'Grecki nowożytny (po 1453)') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'he', 'language', 'pl', 'Hebrajski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'hi', 'language', 'pl', 'Indoaryjskie (inne)') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'hu', 'language', 'pl', 'Wegierski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'is', 'language', 'pl', 'Islandzki') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'id', 'language', 'pl', 'Indonezyjski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'iu', 'language', 'pl', 'Inuktitut') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ik', 'language', 'pl', 'Inupiak') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'it', 'language', 'pl', 'Włoski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ja', 'language', 'pl', 'Japoński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'kn', 'language', 'pl', 'Kannada') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'km', 'language', 'pl', 'Khmerski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'rw', 'language', 'pl', 'Kinyarwanda') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ko', 'language', 'pl', 'Koreański') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ku', 'language', 'pl', 'Kurdyjski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'lo', 'language', 'pl', 'Laotański') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'la', 'language', 'pl', 'Łaciński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'lv', 'language', 'pl', 'Łotewski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'lt', 'language', 'pl', 'Litewski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ms', 'language', 'pl', 'Malajski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mi', 'language', 'pl', 'Maoryjski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mr', 'language', 'pl', 'Marathi') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mn', 'language', 'pl', 'Mongolski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mul', 'language', 'pl', 'Wiele języków') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ne', 'language', 'pl', 'Nepalski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'zxx', 'language', 'pl', 'Dokument nietekstowy') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'nb', 'language', 'pl', 'Norweski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'nn', 'language', 'pl', 'Norweski nynorsk') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'fa', 'language', 'pl', 'Perski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'pt', 'language', 'pl', 'Portugalski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ro', 'language', 'pl', 'Rumuński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ru', 'language', 'pl', 'Rosyjski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sr', 'language', 'pl', 'Serbski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sd', 'language', 'pl', 'Sindhi') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sk', 'language', 'pl', 'Słowacki') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sl', 'language', 'pl', 'Słoweński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'es', 'language', 'pl', 'Hiszpański') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sw', 'language', 'pl', 'Suahili') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sv', 'language', 'pl', 'Szwedzki') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'tl', 'language', 'pl', 'Tagalog (tagalski)') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ta', 'language', 'pl', 'Tamilski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'tet', 'language', 'pl', 'Tetum') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'th', 'language', 'pl', 'Tajski (syjamski)') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'tr', 'language', 'pl', 'Turecki') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'uk', 'language', 'pl', 'Ukraiński') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'und', 'language', 'pl', 'Nieokreślony') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ur', 'language', 'pl', 'Urdu') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'vi', 'language', 'pl', 'Wietnamski') });
        $dbh->do(q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'yi', 'language', 'pl', 'Jidysz') });

        # Print useful stuff here
        say $out "Polish (pl) translations were added";
    },
};
