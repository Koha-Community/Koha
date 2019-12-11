$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !index_exists( 'library_groups', 'library_groups_uniq_2' ) ) {
        $dbh->do(q|
            ALTER TABLE library_groups
            ADD UNIQUE KEY library_groups_uniq_2 (parent_id, branchcode)
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21674 - Add unique key (parent_id, branchcode) to library_group)\n";
}
