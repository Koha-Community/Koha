$DBversion = 'XXX'; # will be replaced by the RM

if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('OPACDetailQRCode','0','','Enable the display of a QR Code on the OPAC detail page','YesNo');
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23566 - Add OPACDetailQRCode system preference)\n";
}
