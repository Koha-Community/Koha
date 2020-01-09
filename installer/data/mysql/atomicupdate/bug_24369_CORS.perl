$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences`
            (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES
            ('AccessControlAllowOrigin', '', NULL, 'Set the Access-Control-Allow-Origin header to the specified value', 'Free');
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24369 - Add CORS support to Koha)\n";
}
