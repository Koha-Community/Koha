$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'accountlines', 'branchcode' ) ) {
        $dbh->do("ALTER TABLE accountlines ADD branchcode VARCHAR( 10 ) NULL DEFAULT NULL AFTER manager_id");
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19066 - Add branchcode to accountlines)\n";
}
