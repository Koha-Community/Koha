use Modern::Perl;

return {
    bug_number  => "31715",
    description => "Add missing German (de) language translations",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'am', 'language', 'de', 'Amharisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'az', 'language', 'de', 'Aserbaidschanisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'be', 'language', 'de', 'Belarussisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'bn', 'language', 'de', 'Bengalisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'eu', 'language', 'de', 'Baskisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'fo', 'language', 'de', 'Färöisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'is', 'language', 'de', 'Isländisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mi', 'language', 'de', 'Maorisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mi', 'language', 'de', 'Maorisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mn', 'language', 'de', 'Mongolisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mr', 'language', 'de', 'Marathi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ms', 'language', 'de', 'Malaiisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ne', 'language', 'de', 'Nepali') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'pbr', 'language', 'de', 'Pangwa') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'prs', 'language', 'de', 'Dari') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'rw', 'language', 'de', 'Kinyarwanda') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sd', 'language', 'de', 'Sindhi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sk', 'language', 'de', 'Slowakisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sl', 'language', 'de', 'Slowenisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sq', 'language', 'de', 'Albanisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'sw', 'language', 'de', 'Swahili') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'ta', 'language', 'de', 'Tamil') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'tl', 'language', 'de', 'Tagalog') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUEs ( 'Armn', 'script', 'de', 'Armenisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUEs ( 'Ethi', 'script', 'en', 'Äthiopisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUEs ( 'Jpan', 'script', 'de', 'Japanisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUEs ( 'Knda', 'script', 'de', 'Kannada') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUEs ( 'Kore', 'script', 'de', 'Koreanisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('et', 'language', 'de', 'Estnisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lv', 'language', 'de', 'Lettisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lt', 'language', 'de', 'Litauisch') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('iu', 'language', 'de', 'Inuktitut') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ik', 'language', 'de', 'Inupiaq') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'cr', 'language', 'de', 'Cree') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'af', 'language', 'de', 'Afrikaans') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'mul', 'language', 'de', 'Mehrsprachig') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'und', 'language', 'de', 'Unbestimmt') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ( 'zxx', 'language', 'de', 'Kein sprachlicher Inhalt') }
        );

        # Print useful stuff here
        say $out "German (de) translations were added";
    },
};
