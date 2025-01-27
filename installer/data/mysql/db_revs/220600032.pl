use Modern::Perl;

return {
    bug_number  => "30500",
    description => "Add option to allow user to change the pickup location while a hold is in transit",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES
            ('OPACInTransitHoldPickupLocationChange','0',NULL,'Allow user to change the pickup location while a hold is in transit','YesNo')
        }
        );

        say $out "Added new system preference 'OPACInTransitHoldPickupLocationChange'";
    },
    }
