use Modern::Perl;

return {
    bug_number => "32799",
    description => "Rename ILLSTATUS authorised value category",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{UPDATE authorised_value_categories SET category_name = "ILL_STATUS_ALIAS" WHERE category_name = "ILLSTATUS"});
        # Print useful stuff here
        say $out "Renamed authorised value category 'ILLSTATUS' to 'ILL_STATUS_ALIAS'";;
    },
};
