$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    my $types_map = {
        'Writeoff'      => 'W',
        'Payment'       => 'Pay',
        'List Item'     => 'CR',
        'Manual Credit' => 'C',
        'Forgiven'      => 'FOR'
    };

    my $sth = $dbh->prepare( "SELECT accountlines_id FROM accountlines WHERE accounttype = 'VOID'" );
    my $sth2 = $dbh->prepare( "SELECT type FROM account_offsets WHERE credit_id = ? ORDER BY created_on LIMIT 1" );
    my $sth3 = $dbh->prepare( "UPDATE accountlines SET accounttype = ?, status = 'VOID' WHERE accountlines_id = ?" );
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        $sth2->execute($row->{accountlines_id});
        my $result = $sth2->fetchrow;
        my $type = $types_map->{$result->{'type'}} // 'Pay';
        $sth3->execute($type,$row->{accountlines_id});
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22511 - Update existing VOID accountlines)\n";
}
