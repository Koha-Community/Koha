$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( TableExists( 'aqorders_claims' ) ) {
        $dbh->do(q|
            CREATE TABLE aqorders_claims (
                id int(11) AUTO_INCREMENT,
                ordernumber INT(11) NOT NULL,
                claimed_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (id),
                CONSTRAINT aqorders_claims_ibfk_1 FOREIGN KEY (ordernumber) REFERENCES aqorders (ordernumber) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci
        |);

        my $orders = $dbh->selectall_arrayref(q|
            SELECT ordernumber, claims_count, claimed_date
            FROM aqorders
            WHERE claims_count > 0
        |, { Slice => {} });
        my $insert_claim_sth = $dbh->prepare(q|
            INSERT INTO aqorders_claims (ordernumber, claimed_on)
            VALUES (?,?)
        |);

        for my $order ( @$orders ) {
            for my $claim (1..$order->{claims_count}) {
                $insert_claim_sth->execute($order->{ordernumber}, $order->{claimed_on});
            }
        }

        $dbh->do(q|ALTER TABLE aqorders DROP COLUMN claims_count, DROP COLUMN claimed_date|);
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24161 - Add new join table aqorders_claims to keep track of claims)\n";
}
