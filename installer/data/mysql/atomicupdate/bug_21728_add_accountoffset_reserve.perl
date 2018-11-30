$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ( 'Reserve Fee' );
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21728 - Add 'Reserve Fee' to the account_offset_types table if missing)\n";
}
