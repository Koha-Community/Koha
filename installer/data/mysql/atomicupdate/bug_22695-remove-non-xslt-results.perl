$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET value = 'default' WHERE variable = 'XSLTResultsDisplay' AND value = ''" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22695 - Remove non-XSLT search results view from the staff client)\n";
}