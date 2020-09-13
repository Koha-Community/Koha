$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $count_missing_budget = $dbh->selectrow_arrayref(q|
        SELECT COUNT(*) FROM aqbudgets ab WHERE NOT EXISTS
            (SELECT * FROM aqbudgetperiods abp WHERE abp.budget_period_id = ab.budget_period_id)

    |);

    if ( !foreign_key_exists( 'aqbudgets', 'aqbudgetperiods_ibfk_1' ) && $count_missing_budget->[0] == 0 ) {
        $dbh->do(q|
            ALTER TABLE aqbudgets ADD CONSTRAINT `aqbudgetperiods_ibfk_1` FOREIGN KEY (`budget_period_id`) REFERENCES `aqbudgetperiods` (`budget_period_id`) ON UPDATE CASCADE ON DELETE CASCADE
        |);
        NewVersion( $DBversion, 18050, "Add FK constraint on aqbudgets.budget_period_id");
    } elsif ( $count_missing_budget->[0] > 0 )  {
        NewVersion( $DBversion, 18050, "FK constraint on aqbudgets.budget_period_id couldn't be added. There are $count_missing_budget->[0] funds in your database that are not linked to a valid budget.");
    } else {
        NewVersion( $DBversion, 18050, "FK constraint on aqbudgets.budget already exists");
    }

}
