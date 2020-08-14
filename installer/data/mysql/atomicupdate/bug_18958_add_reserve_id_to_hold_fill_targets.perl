$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'hold_fill_targets', 'reserve_id' ) ) {
        $dbh->do( "ALTER TABLE hold_fill_targets ADD COLUMN reserve_id int(11) DEFAULT NULL AFTER item_level_request" );
    }

    NewVersion( $DBversion, 18958, "Add reserve_id to hold_fill_targets");
}
