use Modern::Perl;

return {
    bug_number  => "14783",
    description => "Allow patrons to change pickup location for non-waiting holds",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES ('OPACAllowUserToChangeBranch','','Pending, In-Transit, Suspended','Allow users to change the library to pick up a hold for these statuses:','multiple');
        }
        );

        say $out "Added new system preference 'OPACAllowUserToChangeBranch'";

        my ($value) = $dbh->selectrow_array(
            q{
            SELECT CASE WHEN value=1 THEN 'intransit' ELSE '' END
            FROM systempreferences
            WHERE variable='OPACInTransitHoldPickupLocationChange'
        }
        );

        $dbh->do(
            q{
            UPDATE systempreferences
            SET value=(?)
            WHERE variable='OPACAllowUserToChangeBranch'
        }, undef, $value
        );

        $dbh->do(
            q{
            DELETE FROM systempreferences
            WHERE variable = 'OPACInTransitHoldPickupLocationChange'
        }
        );

        say $out "Removed system preference 'OPACInTransitHoldPickupLocationChange'";
    },
};
