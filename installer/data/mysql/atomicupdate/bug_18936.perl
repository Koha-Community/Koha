$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my @columns = qw(
        restrictedtype
        rentaldiscount
        fine
        finedays
        maxsuspensiondays
        suspension_chargeperiod
        firstremind
        chargeperiod
        chargeperiod_charge_at
        accountsent
        issuelength
        lengthunit
        hardduedate
        hardduedatecompare
        renewalsallowed
        renewalperiod
        norenewalbefore
        auto_renew
        no_auto_renewal_after
        no_auto_renewal_after_hard_limit
        reservesallowed
        holds_per_record
        holds_per_day
        onshelfholds
        opacitemholds
        overduefinescap
        cap_fine_to_replacement_price
        article_requests
        note
    );

    if ( column_exists( 'issuingrules', 'categorycode' ) ) {
        foreach my $column ( @columns ) {
            $dbh->do("
                INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
                SELECT IF(categorycode='*', NULL, categorycode), IF(branchcode='*', NULL, branchcode), IF(itemtype='*', NULL, itemtype), \'$column\', COALESCE( $column, '' )
                FROM issuingrules
            ");
        }
        $dbh->do("DROP TABLE issuingrules");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18936: Convert issuingrules fields to circulation_rules)\n";
}
