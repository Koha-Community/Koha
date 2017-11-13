$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('RemoveFineOnReturn', '', '', 'Choose which fines will be removed on item return', 'Choice');");

    $dbh->do("INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES ('PDFBILL', 'PDF-laskutus', 'Luo PDF-laskuja tulostettaviksi', 'properties');");

	$dbh->do("INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES ('SAPERP', 'Sap-laskutus', 'Lähettää laskuja KuntaErpiin SAPilla', 'properties');");

	$dbh->do("CREATE TABLE `overduebills` (
		`bill_id` int(11) NOT NULL AUTO_INCREMENT,
		`issue_id` int(11) NOT NULL,
		`timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		`billingdate` datetime DEFAULT NULL,
		PRIMARY KEY (`bill_id`),
		KEY `issue_id` (`issue_id`)
		) DEFAULT CHARSET=utf8;
		");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1092: Migrate KuntaErp and PDF-billing to a new Koha version)\n";
}
