$DBversion = 'XXX'; # will be replaced by the RM
if ( CheckVersion( $DBversion ) ) {
    if ( !column_exists( 'reserves', 'cancellation_reason' ) ) {
        $dbh->do(q{
            ALTER TABLE reserves ADD COLUMN `cancellation_reason` varchar(80) default NULL AFTER cancellationdate;
        });
    }

    if ( !column_exists( 'old_reserves', 'cancellation_reason' ) ) {
        $dbh->do(q{
            ALTER TABLE old_reserves ADD COLUMN `cancellation_reason` varchar(80) default NULL AFTER cancellationdate;
        });
    }

    NewVersion( $DBversion, 25534, "Add ability to send an email specifying a reason when canceling a hold");
}
