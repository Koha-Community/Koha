use Modern::Perl;

return {
    bug_number  => "31846",
    description => "Allow setting serials search results limit",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES ('SerialsSearchResultsLimit', NULL, NULL, 'Serials search results limit', 'integer')
        }
        );

        say $out "Added new system preference 'SerialsSearchResultsLimit'";
    },
};
