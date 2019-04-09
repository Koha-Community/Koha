$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {
    $dbh->do("UPDATE accountlines SET description = REPLACE(description, 'Lost Item ', '') WHERE description LIKE 'Lost Item %'");
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 21953 - Remove 'Lost Item' text from accountlines description)\n";
}
