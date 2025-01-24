use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38794",
    description => "Update description of authorized value AggregatedFullText",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE authorised_values
            SET lib = "Aggregated full text"
            WHERE category = "ERM_PACKAGE_CONTENT_TYPE"
                AND authorised_value = "AggregatedFullText"
                AND lib = "Aggregated full"
            }
        ) == 1 && say_success( $out, "Updated description of authorized value AggregatedFullText" );

    },
};
