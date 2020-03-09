$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'itemtypes', 'rentalcharge_daily_calendar' ) ) {
        $dbh->do(q{
            ALTER TABLE itemtypes ADD COLUMN
            rentalcharge_daily_calendar tinyint(1) NOT NULL DEFAULT 1
            AFTER rentalcharge_daily;
        });
    }

    if( !column_exists( 'itemtypes', 'rentalcharge_hourly_calendar' ) ) {
        $dbh->do(q{
            ALTER TABLE itemtypes ADD COLUMN
            rentalcharge_hourly_calendar tinyint(1) NOT NULL DEFAULT 1
            AFTER rentalcharge_hourly;
        });
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21443: Add ability to exclude holidays when calculating rentals fees by time period)\n";
}
