$DBversion = "16.06.00.XXX";
if ( CheckVersion($DBversion) ) {

    # If index issn_idx still exists, we assume that dbrev 3.15.00.049 failed,
    # and we repeat it (partially).
    # Note: the db rev only pertains to biblioitems and is not needed for
    # deletedbiblioitems.

    my $temp = $dbh->selectall_arrayref( "SHOW INDEXES FROM biblioitems WHERE key_name = 'issn_idx'" );

    if( @$temp > 0 ) {
        $dbh->do( "ALTER TABLE biblioitems DROP INDEX isbn" );
        $dbh->do( "ALTER TABLE biblioitems DROP INDEX issn" );
        $dbh->do( "ALTER TABLE biblioitems DROP INDEX issn_idx" );
        $dbh->do( "ALTER TABLE biblioitems CHANGE isbn isbn MEDIUMTEXT NULL DEFAULT NULL, CHANGE issn issn MEDIUMTEXT NULL DEFAULT NULL" );
        $dbh->do( "ALTER TABLE biblioitems ADD INDEX isbn ( isbn ( 255 ) ), ADD INDEX issn ( issn ( 255 ) )" );
        print "Upgrade to $DBversion done (Bug 8835). Removed issn_idx.\n";
    } else {
        print "Upgrade to $DBversion done (Bug 8835). Everything is fine.\n";
    }

    SetVersion($DBversion);
}
