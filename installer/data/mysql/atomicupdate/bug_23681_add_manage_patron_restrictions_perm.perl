$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
           ( 3, 'manage_patron_restrictions', 'Manage patron restrictions')
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23681 - Add manage_patron_restrictions_permission)\n";
}
