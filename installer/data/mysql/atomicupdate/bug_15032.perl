$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    unless ( TableExists('background_jobs') ) {
        $dbh->do(q|
            CREATE TABLE background_jobs (
                id INT(11) NOT NULL AUTO_INCREMENT,
                status VARCHAR(32),
                progress INT(11),
                size INT(11),
                borrowernumber INT(11),
                type VARCHAR(64),
                data TEXT,
                enqueued_on DATETIME DEFAULT NULL,
                started_on DATETIME DEFAULT NULL,
                ended_on DATETIME DEFAULT NULL,
                PRIMARY KEY (id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15032 - Add new table background_jobs)\n";
}
