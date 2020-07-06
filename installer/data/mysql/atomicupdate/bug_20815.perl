$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('NoRefundOnLostReturnedItemsAge','','','Do not refund lost item fees if item is lost for more than this number of days','Integer')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20815: Add NoRefundOnLostReturnedItemsAge system preference)\n";
}
