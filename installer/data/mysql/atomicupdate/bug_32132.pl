use Modern::Perl;

return {
    bug_number  => "32132",
    description => "Set aqbudgets.budget_period_id as NOT NULL",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(q{ALTER TABLE aqbudgets MODIFY COLUMN `budget_period_id` INT(11) NOT NULL});

        # Print useful stuff here
        # tables
        say $out "Change aqbudgets.budget_period_id to NOT accept NULL values.";
    },
};
