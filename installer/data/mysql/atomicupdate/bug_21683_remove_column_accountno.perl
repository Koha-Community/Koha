$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( column_exists( 'accountlines', 'accountno' ) ) {
        $dbh->do( "ALTER TABLE accountlines DROP COLUMN accountno" );
    }

    if( column_exists( 'statistics', 'proccode' ) ) {
        $dbh->do( "ALTER TABLE statistics DROP COLUMN proccode" );
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21683 - Remove accountlines.accountno and statistics.proccode fields)\n";
}
