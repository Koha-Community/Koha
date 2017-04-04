$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
        (4, 'edit_borrowers', 'Add, modify and view patron information'),
        (4, 'view_borrower_infos_from_any_libraries', 'View patron infos from any libraries');
    |);

    # We are lucky here, there is nothing else to do: flags 4-borrowers did not contain sub permissions

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add the view_borrower_infos_from_any_libraries permission )\n";
}
