$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q{INSERT IGNORE INTO account_offset_types ( type ) VALUES ('Void Payment')} );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18790 - Add ability to void payment)\n";
}
