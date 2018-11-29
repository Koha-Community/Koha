$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
        ('AccountAutoReconcile','0','If enabled, patron balances will get reconciled automatically on each transaction.',NULL,'YesNo');
    });
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 21915 - Add a way to automatically reconcile balance for patrons)\n";
}
