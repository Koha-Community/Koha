$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
        DELETE FROM systempreferences WHERE variable="UseQueryParser"
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Remove UseQueryParser system preference)\n";
}
