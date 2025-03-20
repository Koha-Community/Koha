use Modern::Perl;

return {
    bug_number  => "32132",
    description => "Set aqbudgets.budget_period_id as NOT NULL",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        my $count_sql =
            q{SELECT COUNT(*) FROM aqbudgets WHERE budget_period_id IS NULL OR budget_period_id NOT IN(SELECT budget_period_id FROM aqbudgetperiods)};
        my ($count) = $dbh->selectrow_array($count_sql);
        if ($count) {
            $dbh->do(
                q{INSERT IGNORE INTO aqbudgetperiods (budget_period_startdate, budget_period_enddate, budget_period_active, budget_period_description, budget_period_locked) VALUES (curdate(), curdate(), 0, "Budget for funds without budget", 1)}
            );
            say $out "Added dummy budget period";

            my $aqbp_sql =
                q{SELECT budget_period_id FROM aqbudgetperiods WHERE budget_period_description = "Budget for funds without budget"};
            my ($aqbp_id) = $dbh->selectrow_array($aqbp_sql);

            $dbh->do(
                q{UPDATE aqbudgets SET budget_period_id = ? WHERE budget_period_id IS NULL OR budget_period_id NOT IN(SELECT budget_period_id FROM aqbudgetperiods)},
                undef, $aqbp_id
            );
            say $out "Updated columns aqbudgets.budget_period_id with value NULL";
            say $out
                "There were $count budget(s) without budget_period_id. They all have been updated to be under budget called 'Budget for funds without budget' (id $aqbp_id).";
        }

        if ( foreign_key_exists( 'aqbudgets', 'aqbudgetperiods_ibfk_1' ) ) {
            $dbh->do(q{ALTER TABLE aqbudgets DROP FOREIGN KEY aqbudgetperiods_ibfk_1});
            say $out "Dropped foreign key aqbudgetperiods_ibfk_1";
        }

        $dbh->do(q{ALTER TABLE aqbudgets MODIFY COLUMN `budget_period_id` INT(11) NOT NULL});
        say $out "Updated aqbudgets.budget_period_id to NOT accept NULL values";

        $dbh->do(
            q{ALTER TABLE aqbudgets ADD CONSTRAINT `aqbudgetperiods_ibfk_1` FOREIGN KEY (`budget_period_id`) REFERENCES aqbudgetperiods(`budget_period_id`) ON DELETE CASCADE ON UPDATE CASCADE}
        );
        say $out "Read foreign key aqbudgetperiods_ibfk_1";
    },
};
