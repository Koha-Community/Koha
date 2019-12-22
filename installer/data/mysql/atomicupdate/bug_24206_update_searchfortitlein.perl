$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( 'UPDATE systempreferences SET value = REPLACE(value, "http://worldcat.org", "https://worldcat.org") WHERE variable = "OPACSearchForTitleIn"' );
    $dbh->do( 'UPDATE systempreferences SET value = REPLACE(value, "http://www.bookfinder.com", "https://www.bookfinder.com") WHERE variable = "OPACSearchForTitleIn"' );
    $dbh->do( 'UPDATE systempreferences SET value = REPLACE(value, "https://openlibrary.org/search/?", "https://openlibrary.org/search?") WHERE variable = "OPACSearchForTitleIn"' );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Update OpacSearchForTitleIn system preference)\n";
}
