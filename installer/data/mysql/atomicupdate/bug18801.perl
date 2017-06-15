$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # Fetch all auth types
    my $authtypes = $dbh->selectcol_arrayref( q|SELECT authtypecode FROM auth_types| );

    if( grep { $_ eq 'Default' } @$authtypes ) {
        # If this exists as an authtypecode, we don't do anything
    } else {
        # Replace the incorrect Default by empty string
        $dbh->do( q|UPDATE auth_header SET authtypecode='' WHERE authtypecode='Default'| );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18801 - Update incorrect Default auth type codes)\n";
}
