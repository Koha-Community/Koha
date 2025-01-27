use Modern::Perl;

return {
    bug_number  => "28831",
    description => "Add system preferences OPACResultsUnavailableGroupingBy",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q|
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
                ('OPACResultsUnavailableGroupingBy','branch','branch\|substatus','Group OPAC XSLT results by branch or substatus','Choice')
        |
        );
    },
    }
