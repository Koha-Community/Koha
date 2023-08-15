$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
$dbh->do(q{
INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('IntranetAuthoritiesHomeHTML', '', 'Show the following HTML in a div on the bottom of the authorities home page', NULL, 'Free'), ('IntranetCatalogingHomeHTML', '', 'Show the following HTML in a div on the bottom of the cataloging home page', NULL, 'Free'), ('IntranetListsHomeHTML', '', 'Show the following HTML in a div on the bottom of the lists home page', NULL, 'Free'), ('IntranetPatronsHomeHTML', '', 'Show the following HTML in a div on the bottom of the patrons home page', NULL, 'Free'), ('IntranetPOSHomeHTML', '', 'Show the following HTML in a div on the bottom of the point of sale home page', NULL, 'Free'), ('IntranetSerialsHomeHTML', '', 'Show the following HTML in a div on the bottom of the serials home page', NULL, 'Free')});

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 6419 - Add customizable areas to intranet start pages)\n";
}
