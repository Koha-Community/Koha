$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add 'WrongTransfer' to branchtransfers cancellation_reason enum
    $dbh->do(
        q{
            ALTER TABLE
                `branchtransfers`
            MODIFY COLUMN
                `cancellation_reason` enum(
                    'Manual',
                    'StockrotationAdvance',
                    'StockrotationRepatriation',
                    'ReturnToHome',
                    'ReturnToHolding',
                    'RotatingCollection',
                    'Reserve',
                    'LostReserve',
                    'CancelReserve',
                    'ItemLost',
                    'WrongTransfer'
                )
            AFTER `comments`
          }
    );

    NewVersion( $DBversion, 24434, "Add 'WrongTransfer' to branchtransfers.cancellation_reason enum");
}
