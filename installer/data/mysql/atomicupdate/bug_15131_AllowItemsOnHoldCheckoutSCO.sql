INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
    SELECT 'AllowItemsOnHoldCheckoutSCO',
         COALESCE(value,0),
         '',
         'Do not generate RESERVE_WAITING and RESERVED warning in the SCO module when checking out items reserved to someone else. This allows self checkouts for those items.',
         'YesNo'
    FROM systempreferences WHERE variable='AllowItemsOnHoldCheckout';

-- $DBversion = '16.06.00.XXX';
-- if ( CheckVersion($DBversion) ) {
--     $dbh->do(q{
--         INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
--          SELECT 'AllowItemsOnHoldCheckoutSCO',COALESCE(value,0),'','Do not generate RESERVE_WAITING and RESERVED warning in the SCO module when checking out items reserved to someone else. This allows self checkouts for those items.','YesNo'
--          FROM systempreferences WHERE variable='AllowItemsOnHoldCheckout';
--     });

--     print "Upgrade to $DBversion done (Bug 15131: Give SCO separate control for AllowItemsOnHoldCheckout)\n";
--     SetVersion($DBversion);
-- }
