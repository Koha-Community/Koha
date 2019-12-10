$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
        (11, 'reopen_closed_invoices', 'Reopen closed invoices')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24157: Add new permission reopen_closed_invoices)\n";
}
