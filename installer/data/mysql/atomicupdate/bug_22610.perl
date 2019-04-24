$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
        INSERT INTO
          authorised_values (category,authorised_value,lib)
        VALUES
          ('PAYMENT_TYPE','SIP00','Cash via SIP2'),
          ('PAYMENT_TYPE','SIP01','VISA via SIP2'),
          ('PAYMENT_TYPE','SIP02','Creditcard via SIP2')
    });

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype  = 'Pay',
          payment_type = 'SIP00'
        WHERE
          accounttype = 'Pay00';
    });

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype  = 'Pay',
          payment_type = 'SIP01'
        WHERE
          accounttype = 'Pay01';
    });

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype  = 'Pay',
          payment_type = 'SIP02'
        WHERE
          accounttype = 'Pay02';
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22610 - Fix accounttypes for SIP2 payments)\n";
}
