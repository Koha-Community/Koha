$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES
            ('RESTdefaultPageSize','20','','Set the default number of results returned by the REST API endpoints','Integer')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19278: Add a configurable default page size for REST endpoints)\n";
}
