$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("ALTER TABLE message_queue MODIFY time_queued timestamp NULL");

    if( !column_exists( 'message_queue', 'updated_on' ) ) {
        $dbh->do("ALTER TABLE message_queue ADD COLUMN updated_on timestamp NOT NULL default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER time_queued");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23673 - modify time_queued and add updated_on to message_queue)\n";
}
