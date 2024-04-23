use Modern::Perl;

return {
    bug_number  => "32132",
    description => "Update NULL values on aqbudgets.budget_period_id",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        my $count_sql = q{SELECT COUNT(*) FROM aqbudgets WHERE budget_period_id IS NULL};
        my ($count) = $dbh->selectrow_array($count_sql);
        if ($count) {
            $dbh->do(
                q{INSERT IGNORE INTO aqbudgetperiods (budget_period_startdate, budget_period_enddate, budget_period_active, budget_period_description, budget_period_locked) VALUES (curdate(), curdate(), 0, "Budget for funds without budget", 1)}
            );
            say $out "Added dummy budget period";

            my $aqbp_sql =
                q{SELECT budget_period_id FROM aqbudgetperiods WHERE budget_period_description = "Budget for funds without budget"};
            my ($aqbp_id) = $dbh->selectrow_array($aqbp_sql);

            $dbh->do( q{UPDATE aqbudgets SET budget_period_id = ? WHERE budget_period_id IS NULL}, undef, $aqbp_id );
            say $out "Updated columns aqbudgets.budget_period_id with value NULL";
            say $out
                "There were $count budget(s) without budget_period_id. They all have been updated to be under budget called 'Budget for funds without budget' (id $aqbp_id).";
        } else {
            say $out "No budget without budget_period_id found.";
        }
    },
};
