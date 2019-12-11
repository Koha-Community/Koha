$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
        (11, 'reopen_closed_invoices', 'Reopen closed invoices')
    |);

    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
        (11, 'edit_invoices', 'Edit invoices')
    |);


    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
        (11, 'delete_invoices', 'Delete invoices')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24157: Add new permissions reopen_closed_invoices, edit_invoices delete_invoices)\n";
}
