use Modern::Perl;

return {
    bug_number  => "31631",
    description => "Allow choosing for tax-exclusive values to be used for calculating fund values (spent, ordered)",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('CalculateFundValuesIncludingTax', '1', NULL, 'Include tax in the calculated fund values (spent, ordered) for all supplier configurations', 'YesNo')}
        );

        say $out "Added new system preference 'CalculateFundValuesIncludingTax'";
    },
};
