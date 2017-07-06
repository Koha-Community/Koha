$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE search_field SET facet_order=10 WHERE name='ln'" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18213 - Add language facets to Elasticsearch)\n";
}
