$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
	my @columns = qw(
		restrictedtype
		rentaldiscount
		fine
		finedays
		maxsuspensiondays
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
		overduefinescap
		cap_fine_to_replacement_price
		onshelfholds
		opacitemholds
		article_requests
	);

    if ( column_exists( 'issuingrules', 'categorycode' ) ) {
		foreach my $column ( @columns ) {
			$dbh->do("
				INSERT INTO circulation_rules ( categorycode, branchcode, itemtype, rule_name, rule_value )
				SELECT categorycode, branchcode, itemtype, 'column', $column
				FROM issuingrules
			");
		}
        $dbh->do("DROP TABLE issuingrules");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18930 - Move lost item refund rules to circulation_rules table)\n";
}
