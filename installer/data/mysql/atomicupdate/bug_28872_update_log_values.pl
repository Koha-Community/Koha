use Modern::Perl;

{
    bug_number => "28872",
    description => "update values from on and off to 1 and 0",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{update systempreferences set value=1 where variable in ('AcquisitionLog', 'NewsLog', 'NoticesLog') and value='on'});
        $dbh->do(q{update systempreferences set value=0 where variable in ('AcquisitionLog', 'NewsLog', 'NoticesLog') and value='off'});

        # Print useful stuff here
        say $out "Update is going well so far";
    },
}
