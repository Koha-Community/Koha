$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET value = 'default' WHERE variable = 'XSLTDetailsDisplay' AND value = ''" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 29891 - Remove non-XSLT detail view in the staff client)\n";
}
