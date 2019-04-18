$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    # Find and correct pathological cases of LR becoming a credit
    my $sth = $dbh->prepare( "SELECT accountlines_id, issue_id, borrowernumber, itemnumber, amount, manager_id FROM accountlines WHERE accounttype = 'LR' AND amount < 0" );
    $sth->execute();
    while ( my $row = $sth->fetchrow_hashref ) {
        $dbh->do(
            "INSERT INTO accountlines (accounttype, issue_id, borrowernumber, itemnumber, amount, manager_id) VALUES ( ?, ?, ?, ?, ?, ? );",
            {},
            (
                'CR',                   $row->{issue_id},
                $row->{borrowernumber}, $row->{itemnumber},
                $row->{amount},         $row->{manager_id}
            )
        );
        my $credit_id = $dbh->last_insert_id();
        my $amount = $row->{amount} * -1;
        $dbh->do("INSERT INTO account_offsets (credit_id, debit_id, type, amount) VALUES (?,?,?,?);",{},($credit_id, $row->{accountlines_id}, 'Lost Item', $amount));
        $dbh->do("UPDATE accountlines SET amount = '$amount' WHERE accountlines_id = '$row->{accountlines_id}';");
    }

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'LOST',
          status = 'RETURNED'
        WHERE
          accounttype = 'LR';
    });

    # Find and correct pathalogical cases of L having been converted to W
    $sth = $dbh->prepare( "SELECT accountlines_id, issue_id, borrowernumber, itemnumber, amount, manager_id FROM accountlines WHERE accounttype = 'W' AND itemnumber IS NOT NULL" );
    $sth->execute();
    while ( my $row = $sth->fetchrow_hashref ) {
        my $amount = $row->{amount} * -1;
        $dbh->do(
            "INSERT INTO accountlines (accounttype, issue_id, borrowernumber, itemnumber, amount, manager_id) VALUES ( ?, ?, ?, ?, ?, ? );",
            {},
            (
                'LOST', $row->{issue_id}, $row->{borrowernumber},
                $row->{itemnumber}, $amount, $row->{manager_id}
            )
        );
        my $debit_id = $dbh->last_insert_id();
        $dbh->do("INSERT INTO account_offsets (credit_id, debit_id, type, amount) VALUES (?,?,?,?);",{},($row->{accountlines_id}, $debit_id, 'Lost Item Returned', $amount));
    }

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'LOST',
        WHERE
          accounttype = 'L';
    });

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'LOST_RETURNED',
        WHERE
          accounttype = 'CR';
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22563 - Fix accounttypes for 'L', 'LR' and 'CR')\n";
}
