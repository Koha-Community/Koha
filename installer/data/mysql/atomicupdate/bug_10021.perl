$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|DROP TABLE IF EXISTS notifys|);

    if( column_exists( 'accountlines', 'notify_id' ) ) {
        $dbh->do(q|ALTER TABLE accountlines DROP COLUMN notify_id|);
        $dbh->do(q|ALTER TABLE accountlines DROP COLUMN notify_level|);
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 10021 - Drop notifys-related table and columns)\n";
}
