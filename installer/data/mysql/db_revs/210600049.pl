use Modern::Perl;

return {
    bug_number  => "5229",
    description => "Remove system preference 'OPACItemsResultsDisplay'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(q{DELETE FROM systempreferences WHERE variable='OPACItemsResultsDisplay'});
    },
    }
