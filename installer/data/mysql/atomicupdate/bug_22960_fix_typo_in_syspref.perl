$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET explanation = REPLACE(explanation,'locaiton','location') WHERE variable = 'UpdateItemLocationOnCheckin'" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22960: Fix typo in syspref description)\n";
}
