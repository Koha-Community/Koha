$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );
    $dbh->do(q{
        INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('SkipHoldTrapOnNotForLoanValue','',NULL,'If set, Koha will never trap items for hold with this notforloan value','Integer')
    });

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 25184, "Items with a negative notforloan status should not be captured for holds");
}
