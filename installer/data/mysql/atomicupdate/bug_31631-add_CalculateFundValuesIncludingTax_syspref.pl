use Modern::Perl;

return {
    bug_number => "31631",
    description => "Add new system preference CalculateFundValuesIncludingTax",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('CalculateFundValuesIncludingTax', '1', NULL, 'Include tax in the calculated fund values (spent, ordered) for all supplier configurations', 'YesNo')});
    },
};
