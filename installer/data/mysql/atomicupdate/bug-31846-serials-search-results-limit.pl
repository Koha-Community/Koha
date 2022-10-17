use Modern::Perl;

return {
    bug_number => "31846",
    description => "Add SerialsSearchResultsLimit syspref",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES ('SerialsSearchResultsLimit', NULL, NULL, 'Serials search results limit', 'integer')
        });
        # Print useful stuff here
        say $out "SerialsSearchResultsLimit syspref added";
    },
};
