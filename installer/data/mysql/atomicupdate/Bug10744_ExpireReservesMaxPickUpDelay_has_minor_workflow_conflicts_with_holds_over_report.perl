$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("ALTER TABLE reserves ADD `pickupexpired` DATE DEFAULT NULL AFTER `expirationdate`");
    $dbh->do("ALTER TABLE reserves ADD KEY `reserves_pickupexpired` (`pickupexpired`)");
    $dbh->do("ALTER TABLE old_reserves ADD `pickupexpired` DATE DEFAULT NULL AFTER `expirationdate`");
    $dbh->do("ALTER TABLE old_reserves ADD KEY `old_reserves_pickupexpired` (`pickupexpired`)");

    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('PickupExpiredHoldsOverReportDuration','1',NULL,\"For how many days holds expired by the 'ExpireReservesMaxPickUpDelay'-syspref are visible in the 'Hold Over'-tab in /circ/waitingreserves.pl ?\",'Integer')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade done (Bug 10744 - ExpireReservesMaxPickUpDelay has minor workflow conflicts with hold(s) over report)\n";
}
