$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET
        variable = 'AllowItemsOnHoldCheckoutSIP',
        explanation = 'Do not generate RESERVE_WAITING and RESERVED warning when checking out items reserved to someone else via SIP. This allows self checkouts for those items.'
        WHERE variable = 'AllowItemsOnHoldCheckout'
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23233 - Rename AllowItemsOnHoldCheckout syspref)\n";
}
