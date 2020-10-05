$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $count_missing_budget = $dbh->selectrow_arrayref(q|
        SELECT COUNT(*) FROM aqbudgets ab WHERE NOT EXISTS
            (SELECT * FROM aqbudgetperiods abp WHERE abp.budget_period_id = ab.budget_period_id)
            AND budget_period_id IS NOT NULL;

    |);

    my $message = "";
    if($count_missing_budget->[0] > 0) {
        $dbh->do(q|
            CREATE TABLE _bug_18050_aqbudgets AS
            SELECT * FROM aqbudgets ab WHERE NOT EXISTS
                (SELECT * FROM aqbudgetperiods abp WHERE abp.budget_period_id = ab.budget_period_id)
        |);

        $dbh->do(q|
            UPDATE aqbudgets ab SET budget_period_id = NULL
            WHERE NOT EXISTS
                (SELECT * FROM aqbudgetperiods abp WHERE abp.budget_period_id = ab.budget_period_id)
        |);
        $message = ". There are $count_missing_budget->[0] funds in your database that are not linked
        to a valid budget. Setting invalid budget id (budget_period_id) to null. The table _bug_18050_aqbudgets
        was created with original data. Please check that table and place valid ids in aqbudget table as soon as possible."

    }

    if ( !foreign_key_exists( 'aqbudgets', 'aqbudgetperiods_ibfk_1' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbudgets ADD CONSTRAINT `aqbudgetperiods_ibfk_1` FOREIGN KEY (`budget_period_id`) REFERENCES `aqbudgetperiods` (`budget_period_id`) ON UPDATE CASCADE ON DELETE CASCADE
        |);
        NewVersion( $DBversion, 18050, "Add FK constraint on aqbudgets.budget_period_id$message");
    } else {
        NewVersion( $DBversion, 18050, "FK constraint on aqbudgets.budget already exists");
    }

}
