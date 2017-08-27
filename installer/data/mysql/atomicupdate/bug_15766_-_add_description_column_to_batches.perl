$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'creator_batches', 'description' ) ) {
        $dbh->do(q|ALTER TABLE creator_batches ADD description mediumtext default NULL AFTER batch_id|);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15766: Add column creator_batches.description)\n";
}
