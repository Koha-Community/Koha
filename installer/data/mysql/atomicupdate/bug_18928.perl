$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if ( column_exists( 'default_circ_rules', 'holdallowed' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, NULL, 'holdallowed', holdallowed
            FROM default_circ_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, NULL, 'hold_fulfillment_policy', hold_fulfillment_policy
            FROM default_circ_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, NULL, 'returnbranch', returnbranch
            FROM default_circ_rules
        ");
        $dbh->do("DROP TABLE default_circ_rules");
    }

    if ( column_exists( 'default_branch_circ_rules', 'holdallowed' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, branchcode, NULL, 'holdallowed', holdallowed
            FROM default_branch_circ_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, branchcode, NULL, 'hold_fulfillment_policy', hold_fulfillment_policy
            FROM default_branch_circ_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, branchcode, NULL, 'returnbranch', returnbranch
            FROM default_branch_circ_rules
        ");
        $dbh->do("DROP TABLE default_branch_circ_rules");
    }

    if ( column_exists( 'branch_item_rules', 'holdallowed' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, branchcode, itemtype, 'holdallowed', holdallowed
            FROM branch_item_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, branchcode, itemtype, 'hold_fulfillment_policy', hold_fulfillment_policy
            FROM branch_item_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, branchcode, itemtype, 'returnbranch', returnbranch
            FROM branch_item_rules
        ");
        $dbh->do("DROP TABLE branch_item_rules");
    }

    if ( column_exists( 'default_branch_item_rules', 'holdallowed' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, itemtype, 'holdallowed', holdallowed
            FROM default_branch_item_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, itemtype, 'hold_fulfillment_policy', hold_fulfillment_policy
            FROM default_branch_item_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, itemtype, 'returnbranch', returnbranch
            FROM default_branch_item_rules
        ");
        $dbh->do("DROP TABLE default_branch_item_rules");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18928 - Move holdallowed, hold_fulfillment_policy, returnbranch to circulation_rules)\n";
}
