$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if ( column_exists( 'refund_lost_item_fee_rules', 'refund' ) ) {
        $dbh->do("
            INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
            SELECT NULL, branchcode, NULL, 'refund', refund
            FROM refund_lost_item_fee_rules
        ");
        $dbh->do("DROP TABLE refund_lost_item_fee_rules");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18930 - Move lost item refund rules to circulation_rules table)\n";
}
