$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('Upload_PurgeTemporaryFiles_Days','',NULL,'If not empty, number of days used when automatically deleting temporary uploads','integer');
    |);

    my ( $cnt ) = $dbh->selectrow_array( "SELECT COUNT(*) FROM uploaded_files WHERE permanent IS NULL or permanent=0" );
    if( $cnt ) {
        print "NOTE: You have $cnt temporary uploads. You could benefit from setting pref Upload_PurgeTemporaryFiles_Days now to automatically delete them.\n";
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17669 - Introduce preference for deleting temporary uploads)\n";
}
