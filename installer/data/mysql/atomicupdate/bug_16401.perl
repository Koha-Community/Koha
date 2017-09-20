$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET value = CONCAT('http://', value) WHERE variable = 'staffClientBaseURL' AND value <> '' AND value NOT LIKE 'http%'" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16401 - fix potentialy bad set staffClientBaseURL preference)\n";
}
