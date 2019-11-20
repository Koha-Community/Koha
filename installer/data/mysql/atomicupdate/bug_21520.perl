$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE oai_sets_mappings ADD COLUMN rule_order INT AFTER set_id, ADD COLUMN rule_operator VARCHAR(3) AFTER rule_order" );
    $dbh->do( "UPDATE oai_sets_mappings SET rule_operator='or'" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21520 - Add rule_order and rule_operator fields to oai_sets_mappings table)\n";
}
