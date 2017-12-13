$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'issuingrules', 'suspension_chargeperiod' ) ) {
        $dbh->do(q|
            ALTER TABLE issuingrules ADD COLUMN suspension_chargeperiod int(11) DEFAULT '1' AFTER maxsuspensiondays;
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19804: Add issuingrules.suspension_chargeperiod)\n";
}
