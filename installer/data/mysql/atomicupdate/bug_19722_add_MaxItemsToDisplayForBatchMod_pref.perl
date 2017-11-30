$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
               VALUES ('MaxItemsToDisplayForBatchMod','1000',NULL,'Display up to a given number of items in a single item modification batch.','Integer')"
            );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19722 - Add a MaxItemsToDisplayForBatchMod preference)\n";
}
