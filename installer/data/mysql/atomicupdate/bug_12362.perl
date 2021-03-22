$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # Add reserve reasons enum
    $dbh->do(
        qq{
            ALTER TABLE
                `branchtransfers`
            MODIFY COLUMN
                `reason` enum(
                    'Manual',
                    'StockrotationAdvance',
                    'StockrotationRepatriation',
                    'ReturnToHome',
                    'ReturnToHolding',
                    'RotatingCollection',
                    'Reserve',
                    'LostReserve',
                    'CancelReserve',
                    'TransferCancellation'
                )
            AFTER `comments`
          }
    );

    NewVersion( $DBversion, 12362, "Add 'TransferCancellion' reason to branchtransfers enum");
}
