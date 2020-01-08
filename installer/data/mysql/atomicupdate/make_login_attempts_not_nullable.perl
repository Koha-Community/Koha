if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE borrowers SET login_attempts=0 WHERE login_attempts IS NULL" );
    $dbh->do( "ALTER TABLE borrowers MODIFY COLUMN login_attempts int(4) NOT NULL DEFAULT 0" );
    $dbh->do( "UPDATE deletedborrowers SET login_attempts=0 WHERE login_attempts IS NULL" );
    $dbh->do( "ALTER TABLE deletedborrowers MODIFY COLUMN login_attempts int(4) NOT NULL DEFAULT 0" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Set login_attempts NOT NULL)\n";
}
