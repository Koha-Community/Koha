use Modern::Perl;

return {
    bug_number  => "26302",
    description => "Add system preferences OPACResultsMaxItems and OPACResultsMaxItemsUnavailable",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q|
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
                ('OPACResultsMaxItems','1','','Maximum number of available items displayed in search results','Integer'),
                ('OPACResultsMaxItemsUnavailable','0','','Maximum number of unavailable items displayed in search results','Integer')
        |
        );
    },
    }
