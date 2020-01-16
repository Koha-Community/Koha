$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add return reasons to enum
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
                    'ReturnToHolding'
                )
            AFTER `comments`
          }
    );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24296 - Add 'return' reasons to branchtransfers enum)\n";
}
