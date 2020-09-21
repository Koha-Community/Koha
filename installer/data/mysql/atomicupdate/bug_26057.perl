$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'branchtransfers', 'datecancelled' ) ) {
        $dbh->do( "ALTER TABLE `branchtransfers` ADD COLUMN `datecancelled` datetime default NULL AFTER `datearrived`" );
    }

    if( !column_exists( 'branchtransfers', 'cancellation_reason' ) ) {
        $dbh->do( "ALTER TABLE `branchtransfers` ADD COLUMN `cancellation_reason` ENUM('Manual', 'StockrotationAdvance', 'StockrotationRepatriation', 'ReturnToHome', 'ReturnToHolding', 'RotatingCollection', 'Reserve', 'LostReserve', 'CancelReserve') DEFAULT NULL AFTER `reason`" );
    }

    NewVersion( $DBversion, 26057, "Add datecancelled field to branchtransfers");
}
