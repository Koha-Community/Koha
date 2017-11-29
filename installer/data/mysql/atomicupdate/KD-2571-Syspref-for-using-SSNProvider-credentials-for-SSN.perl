$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(
        "INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('LoginWithSSNProviderCredentials', '0', null, 'Use configured SSNProvider for logging in to SSN-service when adding/checking SSNs', 'YesNo');"
    );
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-2571-Syspref-for-using-SSNProvider-credentials-for-SSN)\n";
}
