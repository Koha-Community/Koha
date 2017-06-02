$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES  ('StaffLangSelectorMode','footer','top|both|footer','Select the location to display the language selector in staff client','Choice')" );

    # or perform some test and warn
    # if( !column_exists( 'biblio', 'biblionumber' ) ) {
    #    warn "There is something wrong";
    # }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18718 - Language selector in staff header menu similar to OPAC )\n";
}
