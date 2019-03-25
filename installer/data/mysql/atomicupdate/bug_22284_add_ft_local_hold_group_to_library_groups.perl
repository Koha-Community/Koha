$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'library_groups', 'ft_local_hold_group' ) ) {
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_local_hold_group tinyint(1) NOT NULL DEFAULT 0 AFTER ft_search_groups_staff" );
    }

    $dbh->do("ALTER TABLE default_branch_circ_rules MODIFY hold_fulfillment_policy ENUM('any', 'holdgroup', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any'");
    $dbh->do("ALTER TABLE default_circ_rules MODIFY hold_fulfillment_policy ENUM('any', 'holdgroup', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any'");
    $dbh->do("ALTER TABLE default_branch_item_rules MODIFY hold_fulfillment_policy ENUM('any', 'holdgroup', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any'");
    $dbh->do("ALTER TABLE branch_item_rules MODIFY hold_fulfillment_policy ENUM('any', 'holdgroup', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any'");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22284 - Add ft_local_hold_group column to library_groups and alter hold_fulfillment_policy in rules tables)\n";
}
