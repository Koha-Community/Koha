$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(
        "INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('OpacResetPasswordHostWhitelist', '', '', 'Whitelist external host names for password reset in third party service. Separate list by whitespace, comma or |', 'free')"
    );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19133 - Password recovery via REST API - whitelist custom links)\n";
}
