use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39171",
    description => "Rename ElasticsearchMARCFormat system preference options",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ UPDATE systempreferences SET options = 'base64ISO2709|ARRAY' WHERE variable = 'ElasticsearchMARCFormat' }
        );
        $dbh->do(
            q{ UPDATE systempreferences SET value = 'base64ISO2709' WHERE variable = 'ElasticsearchMARCFormat' AND value = 'ISO2709' }
        );
        say_success( $out, "Renamed options for 'ElasticsearchMARCFormat' system preference" );
    },
    }
