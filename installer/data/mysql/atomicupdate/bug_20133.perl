$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'library_groups', 'ft_hide_patron_info' ) ) {
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_hide_patron_info tinyint(1) NOT NULL DEFAULT 0 AFTER description" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add library_groups.ft_hide_patron_info)\n";
}
