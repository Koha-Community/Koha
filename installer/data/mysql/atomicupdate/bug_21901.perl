$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        UPDATE
          serial
        SET
          planneddate = NULL
        WHERE
          planneddate = '0000-00-00'
    |);

    $dbh->do(q|
        UPDATE
          serial
        SET
          publisheddate = NULL
        WHERE
          publisheddate = '0000-00-00'
    |);

    $dbh->do(q|
        UPDATE
          serial
        SET
          claimdate = NULL
        WHERE
          claimdate = '0000-00-00'
    |);

    $dbh->do(q|
        ALTER TABLE serial
        MODIFY COLUMN biblionumber INT(11) NOT NULL
    |);

    unless ( foreign_key_exists( 'serial', 'serial_ibfk_1' ) ) {
        my $serials = $dbh->selectall_arrayref(q|
            SELECT serialid FROM serial WHERE biblionumber NOT IN (SELECT biblionumber FROM biblio)
        |, { Slice => {} });
        if ( @$serials ) {
            warn q|WARNING - The following serials are deleted, they were not attached to an existing bibliographic record (serialid): | . join ", ", map { $_->{serialid} } @$serials;
            $dbh->do(q|
                DELETE FROM serial WHERE biblionumber NOT IN (SELECT biblionumber FROM biblio)
            |);
        }
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
        my $serials = $dbh->selectall_arrayref(q|
            SELECT serialid FROM serial WHERE subscriptionid NOT IN (SELECT subscriptionid FROM subscription)
        |, { Slice => {} });
        if ( @$serials ) {
            warn q|WARNING - The following serials are deleted, they were not attached to an existing subscription (serialid): | . join ", ", map { $_->{serialid} } @$serials;
            $dbh->do(q|
                DELETE FROM serial WHERE subscriptionid NOT IN (SELECT subscriptionid FROM subscription)
            |);
        }
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
            DELETE FROM subscriptionhistory WHERE biblionumber NOT IN (SELECT biblionumber FROM biblio)
        |);
        $dbh->do(q|
            ALTER TABLE subscriptionhistory
            ADD CONSTRAINT subscription_history_ibfk_1 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    unless ( foreign_key_exists( 'subscriptionhistory', 'subscription_history_ibfk_2' ) ) {
        $dbh->do(q|
            DELETE FROM subscriptionhistory WHERE subscriptionid NOT IN (SELECT subscriptionid FROM subscription)
        |);
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
        my $subscriptions = $dbh->selectall_arrayref(q|
            SELECT subscriptionid FROM subscription WHERE biblionumber NOT IN (SELECT biblionumber FROM biblio)
        |, { Slice => {} });
        if ( @$subscriptions ) {
            warn q|WARNING - The following subscriptions are deleted, they were not attached to an existing bibliographic record (subscriptionid): | . join ", ", map { $_->{subscriptionid} } @$subscriptions;

            $dbh->do(q|
                DELETE FROM subscription WHERE biblionumber NOT IN (SELECT biblionumber FROM biblio)
            |);
        }
        $dbh->do(q|
            ALTER TABLE subscription
            ADD CONSTRAINT subscription_ibfk_3 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21901 - Add foreign key constraints on serial)\n";
}
