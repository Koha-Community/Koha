$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do("ALTER TABLE deletedborrowers DROP COLUMN flags");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14540-2 - Drop deletedborrowers.flags column.)\n";
}