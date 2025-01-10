use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38794",
    description => "Update description of authorized value AggregatedFullText",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{update authorised_values set lib = "Aggregated full text" where category = "ERM_PACKAGE_CONTENT_TYPE" and authorised_value = "AggregatedFullText" and lib = "Aggregated full"}
        );

        say_success( $out, "Updated description of authorized value AggregatedFullText" );

    },
};
