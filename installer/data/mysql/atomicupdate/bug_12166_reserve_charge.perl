$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("UPDATE accountlines SET description = REPLACE(description, 'Reserve Charge - ', '') WHERE description LIKE 'Reserve Charge - %'");
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12166 - Remove 'Reserve Charge' text from accountlines description)\n";
}
