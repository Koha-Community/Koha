$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE borrowers ADD COLUMN flgAnonymized tinyint DEFAULT 0" );
    $dbh->do( "ALTER TABLE deletedborrowers ADD COLUMN flgAnonymized tinyint DEFAULT 0" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21336 - Add field flgAnonymized)\n";
}
