use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37661",
    description => "Add a way to enable/disable bookings",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('EnableBooking','1',NULL,'If enabled, activate every functionalities related with Bookings module','YesNo')}
        );

        say_success( $out, "Added new system preference 'EnableBooking'" );
    },
};
