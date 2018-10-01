$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE borrowers SET login_attempts = ? WHERE login_attempts > ?", undef, C4::Context->preference('FailedLoginAttempts'), C4::Context->preference('FailedLoginAttempts') );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21336 - Reset login_attempts)\n";
}
