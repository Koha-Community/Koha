$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );
    $dbh->do(q{
        INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('TrapHoldsOnOrder','1',NULL,'If enabled, Koha will trap holds for on order items ( notforloan < 0 )','YesNo't c)
    });

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 25184, "Items with a negative notforloan status should not be captured for holds");
}
