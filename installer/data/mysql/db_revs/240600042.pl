use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37969",
    description => "Add nor language code",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'nb', 'language', 'no', 'Norsk bokmål'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'nn', 'language', 'no', 'Norsk nynorsk'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'no', 'language', 'Norwegian','2024-09-19' ); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'no','nor'); });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'no', 'language', 'nb', 'Norsk'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'no', 'language', 'nn', 'Norsk'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'no', 'language', 'no', 'Norsk'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'no', 'language', 'en', 'Norwegian'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'no', 'language', 'fr', 'Norvégien'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'no', 'language', 'de', 'Norwegisch'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'no', 'language', 'pl', 'Norweski'); }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'NO', 'region', 'no', 'Noreg'); }
        );

        say_success( $out, "Added nor language code" );
    },
};
