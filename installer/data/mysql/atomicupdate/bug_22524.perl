$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE `search_field` SET `name` = 'date-time-last-modified', `label` = 'date-time-last-modified' WHERE `name` = 'date/time-last-modified'" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22524 - Fix date/time-last-modified search with Elasticsearch)\n";
}