$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        ALTER TABLE serial
        MODIFY COLUMN biblionumber INT(11) NOT NULL
    |);

    unless ( foreign_key_exists( 'serial', 'serial_ibfk_1' ) ) {
        $dbh->do(q|
            ALTER TABLE serial
            ADD CONSTRAINT serial_ibfk_1 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    $dbh->do(q|
        ALTER TABLE serial
        MODIFY COLUMN subscriptionid INT(11) NOT NULL
    |);

    unless ( foreign_key_exists( 'serial', 'serial_ibfk_2' ) ) {
        $dbh->do(q|
            ALTER TABLE serial
            ADD CONSTRAINT serial_ibfk_2 FOREIGN KEY (subscriptionid) REFERENCES subscription (subscriptionid) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    $dbh->do(q|
        ALTER TABLE subscriptionhistory
        MODIFY COLUMN biblionumber int(11),
        MODIFY COLUMN subscriptionid int(11)
    |);

    unless ( foreign_key_exists( 'subscriptionhistory', 'subscription_history_ibfk_1' ) ) {
        $dbh->do(q|
            ALTER TABLE subscriptionhistory
            ADD CONSTRAINT subscription_history_ibfk_1 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    unless ( foreign_key_exists( 'subscriptionhistory', 'subscription_history_ibfk_2' ) ) {
        $dbh->do(q|
            ALTER TABLE subscriptionhistory
            ADD CONSTRAINT subscription_history_ibfk_2 FOREIGN KEY (subscriptionid) REFERENCES subscription (subscriptionid) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    $dbh->do(q|
        ALTER TABLE subscription
        MODIFY COLUMN biblionumber int(11)
    |);

    unless ( foreign_key_exists( 'subscription', 'subscription_ibfk_3' ) ) {
        $dbh->do(q|
            ALTER TABLE subscription
            ADD CONSTRAINT subscription_ibfk_3 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21901 - Add foreign key constraints on serial)\n";
}
