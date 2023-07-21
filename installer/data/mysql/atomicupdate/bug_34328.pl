use Modern::Perl;

return {
    bug_number  => "34328",
    description => "Add Scottish Gaelic to recognised languages",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
            VALUES ( 'gd','gla' )
        });

        $dbh->do(q{
            INSERT INTO language_subtag_registry( subtag, type, description, added)
            VALUES ( 'gd', 'language', 'Scottish Gaelic', NOW() )
        });

        $dbh->do(q{
            INSERT INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'gd', 'language', 'en', 'Scottish Gaelic')
        });

        $dbh->do(q{
            INSERT INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'gd', 'language', 'en_GB', 'Scottish Gaelic')
        });

        $dbh->do(q{
            INSERT INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'gd', 'language', 'gd', 'Gàidhlig')
        });

        $dbh->do(q{
            INSERT INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'gd', 'language', 'fr', 'Gaélique écossais')
        });

        $dbh->do(q{
            INSERT INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'gd', 'language', 'de', 'Schottisch-Gälisch')
        });

        $dbh->do(q{
            INSERT INTO language_descriptions(subtag, type, lang, description)
            VALUES ( 'gd', 'language', 'pl', 'Język szkocki gaelicki')
        });

        say $out "Added new language 'Scottish Gaelic'";
    },
};
