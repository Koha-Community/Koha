$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( "UPDATE itemtypes SET imageurl = REPLACE (imageurl, '.gif', '.png') WHERE imageurl LIKE 'bridge/%'" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23148: Replace Bridge icons with transparent PNG files)\n";
}
