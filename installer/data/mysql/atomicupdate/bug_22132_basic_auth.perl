$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences
            (variable, value, options, explanation, type )
        VALUES
            ('RESTBasicAuth','0',NULL,'If enabled, Basic authentication is enabled for the REST API.','YesNo')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22132 - Add Basic authentication)\n";
}
