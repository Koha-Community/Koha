$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( column_exists( 'reserves', 'item_level_hold' ) ) {
        $dbh->do( "ALTER TABLE reserves ADD COLUMN item_level_hold BOOLEAN NOT NULL DEFAULT 0 AFTER itemtype" );
    }
    unless ( column_exists( 'old_reserves', 'item_level_hold' ) ) {
        $dbh->do( "ALTER TABLE old_reserves ADD COLUMN item_level_hold BOOLEAN NOT NULL DEFAULT 0 AFTER itemtype" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 9834 - Add the reserves.item_level_hold column)\n";
}
