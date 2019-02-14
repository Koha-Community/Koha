$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless( foreign_key_exists( 'messages', 'messages_borrowernumber' ) ) {
        $dbh->do(q|
            DELETE m FROM messages m
            LEFT JOIN borrowers b ON m.borrowernumber=b.borrowernumber
            WHERE b.borrowernumber IS NULL
        |);

        $dbh->do(q|
            ALTER TABLE messages
            ADD CONSTRAINT messages_borrowernumber
            FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 13515 - Add a FOREIGN KEY constaint on messages.borrowernumber)\n";
}
