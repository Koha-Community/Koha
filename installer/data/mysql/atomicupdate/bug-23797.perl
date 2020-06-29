$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE opac_news CHANGE lang lang VARCHAR(50)" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23797: Extend the opac_news lang column to accommodate longer values)\n";
}
