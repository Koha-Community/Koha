$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'ACCOUNT'
        WHERE
          accounttype = 'A';
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 11573 - Fix accounttypes for 'A')\n";
}
