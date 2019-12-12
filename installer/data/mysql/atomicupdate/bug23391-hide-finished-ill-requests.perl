$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
            INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
            VALUES ('ILLHiddenRequestStatuses',NULL,NULL,'ILL statuses that are considered finished and should not be displayed in the ILL module','multiple')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23391 - Hide finished ILL requests)\n";
}
