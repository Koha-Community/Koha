$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( "INSERT INTO permissions (module, code, description) VALUES ( 'borrowers', 'get_password_reset_uuid', 'Allow the user to get password reset uuid when recovering passwords. Useful for third party service integrations that wish to do something with the uuid, such as handle emails themselves instead of Koha.')" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19133 - Add permission get_password_reset_uuid.)\n";
}
