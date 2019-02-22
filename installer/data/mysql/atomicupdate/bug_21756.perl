$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ( 'Account Fee' );
    });

    $dbh->do(q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ( 'Hold Expired' );
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21756 - Add 'Account Fee' and 'Hold Expired' to the account_offset_types table if missing)\n";
}
