$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'library_groups', 'ft_local_hold_group' ) ) {
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_local_hold_group tinyint(1) NOT NULL DEFAULT 0 AFTER ft_search_groups_staff" );
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22284 - Add ft_local_hold_group column to library_groups)\n";
}
