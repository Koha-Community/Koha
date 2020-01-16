$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add stockrotation states to reason enum
    $dbh->do(
        qq{
            ALTER TABLE
                `branchtransfers`
            MODIFY COLUMN
                `reason` enum(
                    'Manual',
                    'StockrotationAdvance',
                    'StockrotationRepatriation'
                )
            AFTER `comments`
          }
    );

    # Move stockrotation states to reason field
    $dbh->do(
        qq{
            UPDATE
              `branchtransfers`
            SET
              `reason` = 'StockrotationAdvance',
              `comments` = NULL
            WHERE
              `comments` = 'StockrotationAdvance'
          }
    );
    $dbh->do(
        qq{
            UPDATE
              `branchtransfers`
            SET
              `reason` = 'StockrotationRepatriation',
              `comments` = NULL
            WHERE
              `comments` = 'StockrotationRepatriation'
          }
    );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24296 - Update stockrotation to use 'reason' field in transfers table)\n";
}
