$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES ('PayPalReturnURL','BaseURL','BaseURL|OPACAlias','Specify whether PayPal will return to the url specified in the OPACBaseURL option or to the OPAC\'s alias url.','Choice')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21701 - PayPal return URL option)\n";
}
