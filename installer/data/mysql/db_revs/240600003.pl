use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "34597",
    description => "Update BlockExpiredPatronOpacActions to include ill_request",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            "UPDATE systempreferences SET options='hold,renew,ill_request' WHERE variable='BlockExpiredPatronOpacActions'"
            ) == 1
            and say_success( $out, "BlockExpiredPatronOpacActions system updated to include ill_request." );
    },
};
