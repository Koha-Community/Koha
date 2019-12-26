$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !foreign_key_exists( 'repeatable_holidays', 'repeatable_holidays_ibfk_1' ) ) {
        $dbh->do(q|
            DELETE h
            FROM repeatable_holidays h
            LEFT JOIN branches b ON h.branchcode=b.branchcode
            WHERE b.branchcode IS NULL;
        |);
        $dbh->do(q|
            ALTER TABLE repeatable_holidays
            ADD FOREIGN KEY repeatable_holidays_ibfk_1 (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    if( !foreign_key_exists( 'special_holidays', 'special_holidays_ibfk_1' ) ) {
        $dbh->do(q|
            DELETE h
            FROM special_holidays h
            LEFT JOIN branches b ON h.branchcode=b.branchcode
            WHERE b.branchcode IS NULL;
        |);
        $dbh->do(q|
            ALTER TABLE special_holidays
            ADD FOREIGN KEY special_holidays_ibfk_1 (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24289 - Adding foreign keys on *_holidays.branchcode tables)\n";
}
