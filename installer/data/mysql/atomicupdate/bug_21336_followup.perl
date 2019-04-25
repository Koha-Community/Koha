$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if ( column_exists( 'borrowers', 'flgAnonymized' ) ) {
        $dbh->do(q{
            UPDATE borrowers SET flgAnonymized = 0 WHERE flgAnonymized IS NULL
        });
        $dbh->do(q{
            ALTER TABLE borrowers
                CHANGE `flgAnonymized` `anonymized` TINYINT(1) NOT NULL DEFAULT 0
        });
    }

    if ( column_exists( 'deletedborrowers', 'flgAnonymized' ) ) {
        $dbh->do(q{
            UPDATE deletedborrowers SET flgAnonymized = 0 WHERE flgAnonymized IS NULL
        });
        $dbh->do(q{
            ALTER TABLE deletedborrowers
                CHANGE `flgAnonymized` `anonymized` TINYINT(1) NOT NULL DEFAULT 0
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21336 - (follow-up) Rename flgAnonymized column)\n";
}
