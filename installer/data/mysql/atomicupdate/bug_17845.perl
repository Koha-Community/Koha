$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "DROP TABLE IF EXISTS printers" );

    if( column_exists( 'branches', 'branchprinter' ) ) {
        $dbh->do( "ALTER TABLE branches DROP COLUMN branchprinter" );
    }

    $dbh->do(qq{ DELETE FROM systempreferences WHERE variable = "printcirculationslips"} );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17845 - Drop unused table printers and branchprinter column)\n";
}
