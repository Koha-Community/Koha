$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # insert the authorized_value_category for CONTROL_NUM_SEQUENCE
    $dbh->do( "INSERT IGNORE INTO authorised_value_categories values ('CONTROL_NUM_SEQUENCE');" );


    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19263 - Advanced Editor - Rancor - Add auto control number (001) widget)\n";
}
