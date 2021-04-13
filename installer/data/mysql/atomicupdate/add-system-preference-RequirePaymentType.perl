$DBversion = 'XXX';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
        VALUES ('RequirePaymentType','0','','Require staff to select a payment type when a payment is made','YesNo')
    });

    NewVersion( $DBversion, '28138', 'Add system preference RequirePaymentType');
}
