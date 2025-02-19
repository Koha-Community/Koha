use Modern::Perl;

return {
    bug_number  => "39171",
    description => "Rename ElasticsearchMARCFormat syspref options",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ UPDATE systempreferences SET options = 'base64ISO2709|ARRAY' WHERE variable = 'ElasticsearchMARCFormat' }
        );
        $dbh->do(
            q{ UPDATE systempreferences SET value = 'base64ISO2709' WHERE variable = 'ElasticsearchMARCFormat' AND value = 'ISO2709' }
        );
        say $out "Renamed options for 'ElasticsearchMARCFormat' system preference";
    },
    }
