$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('AuthFailureLog','','If enabled, log authentication failures',NULL,'YesNo'), ('AuthSuccessLog','','If enabled, log successful authentications',NULL,'YesNo' )
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21190 - Add prefs AuthFailureLog and AuthSuccessLog)\n";
}
