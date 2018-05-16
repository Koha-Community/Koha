$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('LogInterfaceURL',NULL,NULL,'Define URL for fetching JSON log data with AJAX.', 'Free')");
    $dbh->do("INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('PersonalInterfaceURL',NULL,NULL,'Define URL for fetching JSON personal data with AJAX.', 'Free')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-3040 - Showing patron's logging data)\n";
}