$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( "INSERT INTO `borrower_attribute_types` (`code`, `description`, `opac_display`, `authorised_value_category`) VALUES ('SST&C','Self-service terms and conditions accepted',1,'YES_NO')" );

    $dbh->do( "INSERT INTO `borrower_attribute_types` (`code`, `description`, `opac_display`, `authorised_value_category`) VALUES ('SSBAN','Self-service usage revoked', 1, 'YES_NO')" );

    $dbh->do( "INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('OpeningHours','','70|10','Define opening hours YAML','Textarea')" );

    $dbh->do( "INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('SSRules','0:PT S ST',NULL,'Self-service access rules, age limit + whitelisted borrower categories, eg. 15:ST S PT','text')" );

    $dbh->do( "INSERT INTO permissions (module, code, description) VALUES ( 'borrowers', 'get_self_service_status', 'Allow the user to get the self-service status of a borrower. Eg. can the borrower access self-service resources')" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1159 - Self-service permission API.)\n";
}
