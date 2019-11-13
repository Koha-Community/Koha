$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'suggestions', 'lastmodificationby' ) ) {
        $dbh->do(q|
            ALTER TABLE suggestions ADD COLUMN lastmodificationby INT(11) DEFAULT NULL AFTER rejecteddate
        |);

        $dbh->do(q|
            ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_lastmodificationby` FOREIGN KEY (`lastmodificationby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
        |);
    }
    if( !column_exists( 'suggestions', 'lastmodificationdate' ) ) {
        $dbh->do(q|
            ALTER TABLE suggestions ADD COLUMN lastmodificationdate DATE DEFAULT NULL
        |);
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23590 - Add lastmodificationby and lastmodificationdate to the suggestions table)\n";
}
