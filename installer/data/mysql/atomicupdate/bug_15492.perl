$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInModule', 0, NULL, 'Enable the standalone self-checkin module.', 'YesNo');
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15492: Add a standalone self-checkin module)\n";
}
