$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('ShowComponentRecords', 'nowhere', 'nowhere|staff|opac|both','In which record detail pages to show list of the component records, as linked via 773','Choice')");

    $dbh->do("INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('MaxComponentRecords', '300', '','Max number of component records to display','Integer')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 11175: Show component records in detail views)\n";
}
