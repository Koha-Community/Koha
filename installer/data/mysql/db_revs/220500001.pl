use Modern::Perl;

return {
    bug_number => "23659",
    description => "Add DefaultHoldPickupLocation syspref",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('DefaultHoldPickupLocation','loggedinlibrary','loggedinlibrary|homebranch|holdingbranch','Which branch should a hold pickup location default to. ','choice')
        });
        # Print useful stuff here
        say $out "Added DefaultHoldPickupLocation syspref";
    },
};
