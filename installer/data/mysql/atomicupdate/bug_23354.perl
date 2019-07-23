$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ( 'Purchase' );
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23354 - Add 'Purchase' account offset type)\n";
}
