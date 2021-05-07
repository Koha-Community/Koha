$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( column_exists('message_queue', 'delivery_note') ) {
        $dbh->do("ALTER TABLE message_queue ADD delivery_note mediumtext AFTER content_type");
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14723 - Additional delivery notes to messages)\n";
}
