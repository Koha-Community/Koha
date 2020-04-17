$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET variable = 'SCOAllowCheckin' WHERE variable = 'AllowSelfCheckReturns'" );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 25147, "Rename AllowSelfCheckReturns to SCOAllowCheckin for consistency");
}
