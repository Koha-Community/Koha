$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( "INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('casServerVersion', '2', '2|3', 'Version of the CAS server Koha will connect to.', 'Choice');");

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 20854, "Adds a casServerVersion system preference");
}
