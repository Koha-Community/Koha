$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'branch_borrower_circ_rules', 'max_holds' ) ) {
        $dbh->do(q{
            ALTER TABLE branch_borrower_circ_rules ADD COLUMN max_holds INT(4) NULL DEFAULT NULL AFTER maxonsiteissueqty
        });
    }

    if( !column_exists( 'default_borrower_circ_rules', 'max_holds' ) ) {
        $dbh->do(q{
            ALTER TABLE default_borrower_circ_rules ADD COLUMN max_holds INT(4) NULL DEFAULT NULL AFTER maxonsiteissueqty
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15524 - Set limit on maximum possible holds per patron by category)\n";
}
