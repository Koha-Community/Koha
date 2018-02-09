$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'library_groups', 'ft_search_groups_opac' ) ) {
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_search_groups_opac tinyint(1) NOT NULL DEFAULT 0 AFTER ft_hide_patron_info" );
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_search_groups_staff tinyint(1) NOT NULL DEFAULT 0 AFTER ft_search_groups_opac" );
        $dbh->do( "UPDATE library_groups SET ft_search_groups_staff = 1 AND ft_search_groups_opac = 1 WHERE title = '__SEARCH_GROUPS__'" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20157 - Use group 'features' to decide which groups to use for group searching functionality)\n";
}
