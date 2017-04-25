$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists( 'borrowers', 'date_renewed' ) ) {
        $dbh->do(q{
            ALTER TABLE borrowers ADD COLUMN date_renewed DATE NULL DEFAULT NULL AFTER dateexpiry;
        });
    }

    unless ( column_exists( 'deletedborrowers', 'date_renewed' ) ) {
        $dbh->do(q{
            ALTER TABLE deletedborrowers ADD COLUMN date_renewed DATE NULL DEFAULT NULL AFTER dateexpiry;
        });
    }

    unless ( column_exists( 'borrower_modifications', 'date_renewed' ) ) {
        $dbh->do(q{
            ALTER TABLE borrower_modifications ADD COLUMN date_renewed DATE NULL DEFAULT NULL AFTER dateexpiry;
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 6758 - Capture membership renewal date for reporting purposes)\n";
}
