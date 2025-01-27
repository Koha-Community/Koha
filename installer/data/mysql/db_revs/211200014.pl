use Modern::Perl;

return {
    bug_number  => "29596",
    description => "Add Yiddish language",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added)
            VALUES ( 'yi', 'language', 'Yiddish', NOW() );
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
            VALUES ( 'yi','yid');
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'yi', 'language', 'de', 'Jiddisch');
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'yi', 'language', 'en', 'Yiddish');
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'yi', 'language', 'es', 'Yidis');
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'yi', 'language', 'fr', 'Yiddish');
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'yi', 'language', 'yi', 'יידיש');
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO language_script_mapping(language_subtag,script_subtag)
            VALUES ( 'yi', 'Hebr');
        }
        );
    },
};
