$DBversion = 'XXX'; # will be replaced by the RM
if ( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('EdifactInvoiceImport', 'automatic', 'automatic|manual', "If on, don't auto-import EDI invoices, just keep them in the database with the status 'new'", 'Choice')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
