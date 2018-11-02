$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( column_exists( 'issuingrules', 'chargename' ) ) {
        $dbh->do( "ALTER TABLE issuingrules DROP chargename" );
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21753: Drop chargename from issuingrules )\n";
}
