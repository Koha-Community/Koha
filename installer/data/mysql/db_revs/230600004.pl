use Modern::Perl;

return {
    bug_number => "33945",
    description => "Add system preference LoadCheckoutsTableDelay",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('LoadCheckoutsTableDelay','0','','Delay before auto-loading checkouts table on checkouts screen','Integer')
        });
    },
};
