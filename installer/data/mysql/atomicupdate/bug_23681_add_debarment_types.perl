$DBversion = 'XXX';

if ( CheckVersion( $DBversion ) ) {

    if ( !TableExists( 'debarment_types' ) ) {
        $dbh->do( q|
            CREATE TABLE debarment_types (
                code varchar(50) NOT NULL PRIMARY KEY,
                display_text text NOT NULL,
                ronly tinyint(1) NOT NULL DEFAULT 0,
                dflt tinyint(1) NOT NULL DEFAULT 0
            ) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        | );
        $dbh->do( q|
            INSERT INTO debarment_types (code, display_text, ronly, dflt) VALUES
            ('MANUAL', 'Manual', 1, 1),
            ('OVERDUES', 'Overdues', 1, 0),
            ('SUSPENSION', 'Suspension', 1, 0),
            ('DISCHARGE', 'Discharge', 1, 0);
        |);
    }
    $dbh->do( q|
        ALTER TABLE borrower_debarments
        MODIFY COLUMN type varchar(50) NOT NULL
    | );
    $dbh->do( q|
        ALTER TABLE borrower_debarments
        ADD CONSTRAINT borrower_debarments_ibfk_2 FOREIGN KEY (type) REFERENCES debarment_types(code) ON DELETE NO ACTION ON UPDATE CASCADE;
    | );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23681 - Add debarment_types)\n";
}
