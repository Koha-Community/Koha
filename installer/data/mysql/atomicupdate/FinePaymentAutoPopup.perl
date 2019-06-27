$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do({
        INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('FinePaymentAutoPopup','0',NULL,'If enabled, automatically display a print dialog for a payment receipt when making a payment.','YesNo')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23228 - Add option to automatically display payment receipt for printing after making a payment)\n";
}
