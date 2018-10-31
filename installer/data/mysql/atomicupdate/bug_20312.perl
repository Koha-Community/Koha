$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # System preferences
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (`variable`,`value`,`explanation`,`options`,`type`)
        VALUES ('showLastPatron','0','','If ON, enables the last patron feature in the intranet','YesNo');
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20312 - Add showLastPatron systempreference)\n";
}
