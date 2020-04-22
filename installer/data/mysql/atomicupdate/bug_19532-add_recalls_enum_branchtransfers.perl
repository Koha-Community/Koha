$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{ ALTER TABLE branchtransfers MODIFY COLUMN reason ENUM('Manual', 'StockrotationAdvance', 'StockrotationRepatriation', 'ReturnToHome', 'ReturnToHolding', 'RotatingCollection', 'Reserve', 'LostReserve', 'CancelReserve', 'Recall', 'CancelRecall') });

    NewVersion( $DBversion, 19532, "Add Recall and CancelReserve ENUM options to branchtransfers.reason" );
}
