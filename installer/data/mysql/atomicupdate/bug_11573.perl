$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'RENT_RENEW'
        WHERE
          accounttype = 'Rent'
        AND
          description LIKE 'Renewal of Rental Item%';
    });

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'RENT'
        WHERE
          accounttype = 'Rent';
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 11573 - Fix accounttypes for 'Rent')\n";
}
