$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Standard Tibetan
    $dbh->do("UPDATE borrower_message_preferences SET days_in_advance=NULL WHERE days_in_advance IS NOT NULL AND message_attribute_id IN (SELECT message_attribute_id FROM message_attributes WHERE takes_days=0)");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18595-1 - Validate days_in_advance values in borrower_message_preferences table)\n";
}
