$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("ALTER TABLE overduerules ADD COLUMN fine1 FLOAT NULL DEFAULT 0 AFTER debarred1");
    $dbh->do("ALTER TABLE overduerules ADD COLUMN fine2 FLOAT NULL DEFAULT 0 AFTER letter2");
    $dbh->do("ALTER TABLE overduerules ADD COLUMN fine3 FLOAT NULL DEFAULT 0 AFTER debarred3");
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 13816 - Set Overdue letter fine to the overduerules)\n";
}
