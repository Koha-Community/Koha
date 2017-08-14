$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("ALTER TABLE issuingrules
        ADD COLUMN hold_max_pickup_delay SMALLINT(6) DEFAULT NULL AFTER `holds_per_record`,
        ADD COLUMN hold_expiration_charge DECIMAL(28,6) DEFAULT NULL AFTER `hold_max_pickup_delay`
    ");
    $dbh->do("UPDATE issuingrules SET
        hold_max_pickup_delay=(SELECT value FROM systempreferences WHERE variable='ReservesMaxPickUpDelay'),
        hold_expiration_charge=(SELECT value FROM systempreferences WHERE variable='ExpireReservesMaxPickUpDelayCharge')
    ");
    $dbh->do("DELETE FROM systempreferences
        WHERE variable='ReservesMaxPickUpDelay'
        OR    variable='ExpireReservesMaxPickUpDelayCharge'
    ");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1939-2 - Circulation rules matrix modifications - Add hold expiration charge and hold max pickup delay)\n";
}
