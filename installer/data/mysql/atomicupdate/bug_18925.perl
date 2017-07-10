$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if ( column_exists( 'branch_borrower_circ_rules', 'maxissueqty' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT categorycode, branchcode, NULL, 'maxissueqty', maxissueqty
            FROM branch_borrower_circ_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT categorycode, branchcode, NULL, 'maxonsiteissueqty', maxonsiteissueqty
            FROM branch_borrower_circ_rules
        ");
        $dbh->do("DROP TABLE branch_borrower_circ_rules");
    }

    if ( column_exists( 'default_borrower_circ_rules', 'maxissueqty' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT categorycode, NULL, NULL, 'maxissueqty', maxissueqty
            FROM default_borrower_circ_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT categorycode, NULL, NULL, 'maxonsiteissueqty', maxonsiteissueqty
            FROM default_borrower_circ_rules
        ");
        $dbh->do("DROP TABLE default_borrower_circ_rules");
    }

    if ( column_exists( 'default_circ_rules', 'maxissueqty' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, NULL, 'maxissueqty', maxissueqty
            FROM default_circ_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, NULL, 'maxonsiteissueqty', maxonsiteissueqty
            FROM default_circ_rules
        ");
        $dbh->do("ALTER TABLE default_circ_rules DROP COLUMN maxissueqty, DROP COLUMN maxonsiteissueqty");
    }

    if ( column_exists( 'default_branch_circ_rules', 'maxissueqty' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, branchcode, NULL, 'maxissueqty', maxissueqty
            FROM default_branch_circ_rules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, NULL, NULL, 'maxonsiteissueqty', maxonsiteissueqty
            FROM default_branch_circ_rules
        ");
        $dbh->do("ALTER TABLE default_branch_circ_rules DROP COLUMN maxissueqty, DROP COLUMN maxonsiteissueqty");
    }

    if ( column_exists( 'issuingrules', 'maxissueqty' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT categorycode, branchcode, itemtype, 'maxissueqty', maxissueqty
            FROM issuingrules
        ");
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT categorycode, branchcode, itemtype, 'maxonsiteissueqty', maxonsiteissueqty
            FROM issuingrules
        ");
        $dbh->do("ALTER TABLE issuingrules DROP COLUMN maxissueqty, DROP COLUMN maxonsiteissueqty");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18925 - Move maxissueqty and maxonsiteissueqty to circulation_rules)\n";
}
