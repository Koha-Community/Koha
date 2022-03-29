use Modern::Perl;

return {
    bug_number => "30403",
    description => "A single line description",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES ('UpdateNotForLoanStatusOnCheckin', '', 'NULL', 'This is a list of value pairs. When an item is checked in, if the not for loan value on the left matches the items not for loan value it will be updated to the right-hand value. E.g. ''-1: 0'' will cause an item that was set to ''Ordered'' to now be available for loan. Each pair of values should be on a separate line.', 'Free')});
        # Print useful stuff here
        say $out "Update is going well so far";
    },
};
