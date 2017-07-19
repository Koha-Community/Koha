$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE items ADD COLUMN damaged_on DATETIME NULL AFTER damaged");
    $dbh->do( "ALTER TABLE deleteditems ADD COLUMN damaged_on DATETIME NULL AFTER damaged");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17672: Add damaged_on to items and deleteditems tables)\n";
}
