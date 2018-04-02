$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my ( $original_value ) = $dbh->selectrow_array(q|
        SELECT value FROM systempreferences WHERE variable="MarkLostItemsAsReturned"
    |);
    if ( $original_value and $original_value eq '1' ) {
        $dbh->do(q{
            UPDATE systempreferences
            SET type="multiple",
                options="batchmod|moredetail|cronjob|additem",
                value="batchmod|moredetail|cronjob|additem"
            WHERE variable="MarkLostItemsAsReturned"
        });
    } else {
        $dbh->do(q{
            UPDATE systempreferences
            SET type="multiple",
                options="batchmod|moredetail|cronjob|additem",
                value=""
            WHERE variable="MarkLostItemsAsReturned"
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19974 - Make MarkLostItemsAsReturned multiple)\n";
}
