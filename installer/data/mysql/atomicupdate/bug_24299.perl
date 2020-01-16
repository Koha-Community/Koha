$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add rotating collection states to reason enum
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
                    'RotatingCollection'
                )
            AFTER `comments`
          }
    );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24299 - Add 'collection' reasons to branchtransfers enum)\n";
}
