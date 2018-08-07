$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO permission_modules (module, description) VALUES ('privacy','Permission regarding patrons privacy data')");
    $dbh->do("INSERT INTO permissions (module, code, description) VALUES ( 'privacy','patron_data', 'Allows to print or send patrons data');");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-3040-1 - Own permission for data access)\n";
}