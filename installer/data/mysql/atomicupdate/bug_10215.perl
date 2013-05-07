$DBversion = 'XXX';
if ( CheckVersion($DBversion) ) {

    $dbh->do(q{ALTER TABLE subscriptionhistory CHANGE opacnote opacnote LONGTEXT NULL});
    $dbh->do(q{ALTER TABLE subscriptionhistory CHANGE librariannote librariannote LONGTEXT NULL});

    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 10215 - Increase the size of opacnote and librariannote for table subscriptionhistory)\n";
}
