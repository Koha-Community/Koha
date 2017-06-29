$DBversion = 'XXX';
if ( CheckVersion($DBversion) ) {
    if ( !column_exists( 'statistics', 'location' ) ) {
        $dbh->do('ALTER TABLE statistics ADD COLUMN location VARCHAR(80) default NULL AFTER itemtype');
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 18882 - Add location code to statistics table for checkouts and renewals)\n";
}
