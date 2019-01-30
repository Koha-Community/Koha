$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    if ( !column_exists( 'itemtypes', 'rentalcharge_daily' ) ) {
        $dbh->do("ALTER TABLE `itemtypes` ADD COLUMN `rentalcharge_daily` decimal(28,6) default NULL AFTER `rentalcharge`");
    }

    if ( column_exists( 'itemtypes', 'rental_charge_daily' ) ) {
        $dbh->do("UPDATE `itemtypes` SET `rentalcharge_daily` = `rental_charge_daily`");
        $dbh->do("ALTER TABLE `itemtypes` DROP COLUMN `rental_charge_daily`");
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 20912 - Support granular rental charges)\n";
}
