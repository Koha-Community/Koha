$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET options = "claim_returned|batchmod|moredetail|cronjob|additem|pendingreserves|onpayment" WHERE variable = "MarkLostItemsAsReturned";
    });
    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 25552, "Add missing Claims Returned option to MarkLostItemsAsReturned");
}
