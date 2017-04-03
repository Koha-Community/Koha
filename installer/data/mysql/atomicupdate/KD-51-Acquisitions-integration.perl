$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)
             VALUES('VaaraAcqVendorConfigurations','','70|10','Define vendor integration rules:','Textarea');");
	print "Upgrade to VAARA (KD-51: Acquisition integration) done!\n";

	$dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)
             VALUES('ArvoDiscounts','','70|10','Define Arvo 1.0 discounts:','Textarea');");
	print "Upgrade to KohaSuomi (Lumme#388: Arvo 1.0. Send XML files to BTJ by email) done!\n";

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-51 - Acquisition integration)\n";
}