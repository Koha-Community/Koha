$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "DELETE FROM systempreferences WHERE variable = 'RotationPreventTransfers'" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22653 - Remove unimplemented RotationPreventTransfers system preference)\n";
}
