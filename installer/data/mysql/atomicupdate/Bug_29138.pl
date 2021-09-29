use Modern::Perl;

return {
    bug_number => "29138",
    description => "Use a zero instead of a no in LoadSearchHistoryToTheFirstLoggedUser",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
                UPDATE systempreferences SET value= IF(value='no',0,1)
                WHERE variable = 'LoadSearchHistoryToTheFirstLoggedUser';
                });
        # Print useful stuff here
        say $out "LoadSearchHistoryToTheFirstLoggedUser updated";
    },
}
