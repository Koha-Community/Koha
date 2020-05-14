$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("ALTER TABLE message_queue ADD delivery_note mediumtext AFTER content_type");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14723 - Additional delivery notes to messages)\n";
}
