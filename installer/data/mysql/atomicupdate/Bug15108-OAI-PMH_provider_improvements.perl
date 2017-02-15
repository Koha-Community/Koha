$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("ALTER TABLE biblioitems ADD KEY `timestamp` (`timestamp`);");
    $dbh->do("ALTER TABLE deletedbiblioitems ADD KEY `timestamp` (`timestamp`);");
    $dbh->do("ALTER TABLE items ADD KEY `timestamp` (`timestamp`);");
    $dbh->do("ALTER TABLE deleteditems ADD KEY `timestamp` (`timestamp`);");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15108 - OAI-PMH provider improvements)\n";
}
