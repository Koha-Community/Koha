$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    if ( !index_exists( 'biblioitems', 'timestamp' ) ) {
        $dbh->do("ALTER TABLE biblioitems ADD KEY `timestamp` (`timestamp`);");
    }
    if ( !index_exists( 'deletedbiblioitems', 'timestamp' ) ) {
        $dbh->do("ALTER TABLE deletedbiblioitems ADD KEY `timestamp` (`timestamp`);");
    }
    if ( !index_exists( 'items', 'timestamp' ) ) {
        $dbh->do("ALTER TABLE items ADD KEY `timestamp` (`timestamp`);");
    }
    if ( !index_exists( 'deleteditems', 'timestamp' ) ) {
        $dbh->do("ALTER TABLE deleteditems ADD KEY `timestamp` (`timestamp`);");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15108: OAI-PMH provider improvements)\n";
}
