$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES
        ('SelfCheckoutByLogin','0',NULL,'Have patrons login into the web-based self checkout system with their username/password or their cardnumber','YesNo')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19186 - Insert system preference SelfCheckoutByLogin if missing)\n";
}
