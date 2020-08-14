$DBversion = "XXX";
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'hold_fill_targets', 'reserve_id' ) ) {
        $dbh->do( "ALTER TABLE hold_fill_targets ADD COLUMN reserve_id int(11) DEFAULT NULL AFTER item_level_request" );
    }

    print "Upgrade to $DBversion done (Bug 18958 - Add reserve_id to hold_fill_targets)\n";
    SetVersion( $DBversion );
}
