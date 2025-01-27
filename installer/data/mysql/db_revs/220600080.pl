use Modern::Perl;

return {
    bug_number  => "30880",
    description => "Add branchonly option to OPACResultsUnavailableGroupingBy syspref",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ UPDATE systempreferences SET options = 'branch|substatus|branchonly', explanation = 'Group OPAC XSLT results by branch and substatus, or substatus only, or branch only' WHERE variable = 'OPACResultsUnavailableGroupingBy' }
        );
    },
};
