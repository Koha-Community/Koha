$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences
            ( variable, value, options, explanation, type )
        VALUES
            ('RESTPublicAPI','1',NULL,'If enabled, the REST API will expose the /public endpoints.','YesNo')
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22061 - Add a /public namespace that can be switched on/off)\n";
}
