$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add 'LostItem' to reserves cancellation_reason enum
    $dbh->do(
        qq{
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
                    'ItemLost'
                )
            AFTER `comments`
          }
    );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 27281, "Add 'ItemLost' to cancellation_reason enum");
}
