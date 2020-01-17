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
                    'CancelReserve'
                )
            AFTER `comments`
          }
    );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24299 - Add 'reserve' reasons to branchtransfers enum)\n";
}
