$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if ( column_exists('message_queue', 'delivery_note') ) {
        $dbh->do(q{
            ALTER TABLE message_queue CHANGE COLUMN delivery_note failure_code MEDIUMTEXT;
        });
    }

    if( !column_exists( 'message_queue', 'failure_code' ) ) {
        $dbh->do(q{
            ALTER TABLE message_queue ADD failure_code mediumtext AFTER content_type
        });
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 28813, "Update delivery_note to failure_code in message_queue");
}
