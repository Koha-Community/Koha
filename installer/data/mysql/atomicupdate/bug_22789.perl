$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    # or perform some test and warn
    if( !column_exists( 'reserves', 'non_priority' ) ) {
        $dbh->do("ALTER TABLE reserves ADD COLUMN `non_priority` tinyint(1) NOT NULL DEFAULT 0 AFTER `item_level_hold` -- Is this a non priority hold");
        $dbh->do("ALTER TABLE old_reserves ADD COLUMN `non_priority` tinyint(1) NOT NULL DEFAULT 0 AFTER `item_level_hold` -- Is this a non priority hold");
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 22789, "Add non_priority column on reserves and old_reserves tables");
}
