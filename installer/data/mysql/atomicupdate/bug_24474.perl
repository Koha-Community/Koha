$DBversion = 'XXX'; # will be replaced by the RM
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE
          systempreferences
        SET
          options = "batchmod|moredetail|cronjob|additem|pendingreserves|onpayment"
        WHERE
          variable = "MarkLostItemsAsReturned"
    });

    my $lost_item_returned = C4::Context->preference("MarkLostItemsAsReturned");
    my @set = split( ",", $lost_item_returned );
    push @set, 'onpayment';
    $lost_item_returned = join( ",", @set );

    $dbh->do(qq{
        UPDATE
          systempreferences
        SET
          value = "$lost_item_returned"
        WHERE
          variable = "MarkLostItemsAsReturned"
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 24474 - Add `onpayment` option to MarkLostItemsAsReturned)\n";
}
