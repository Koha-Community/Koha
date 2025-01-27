use Modern::Perl;

return {
    bug_number  => "23659",
    description => "Allow hold pickup location to default to item home branch for item-level holds",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('DefaultHoldPickupLocation','loggedinlibrary','loggedinlibrary|homebranch|holdingbranch','Which branch should a hold pickup location default to. ','choice')
        }
        );

        say $out "Added new system preference 'DefaultHoldPickupLocation'";
    },
};
