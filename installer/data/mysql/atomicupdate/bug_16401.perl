$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET value = CONCAT('http://', value) WHERE variable = 'staffClientBaseURL' AND value <> '' AND value NOT LIKE 'http%'" );

    my ( $staffClientBaseURL_used_in_notices ) = $dbh->selectrow_array(q|
        SELECT COUNT(*) FROM letter where content like "%staffClientBaseURL%"
    |);
    if ( $staffClientBaseURL_used_in_notices ) {
        warn "\tYou may need to update one or more notice templates if they contain 'staffClientBaseURL'\n";
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16401 - fix potentialy bad set staffClientBaseURL preference)\n";
}
