$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( column_exists( 'accountlines', 'accountno' ) ) {
        $dbh->do( "ALTER TABLE accountlines DROP COLUMN accountno" );
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
