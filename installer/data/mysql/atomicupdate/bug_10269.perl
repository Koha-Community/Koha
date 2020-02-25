$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if (!column_exists('message_queue', 'reply_address')) {
        $dbh->do('ALTER TABLE message_queue ADD COLUMN reply_address LONGTEXT AFTER from_address');
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22821 - Add reply_address to message_queue)\n";
}
