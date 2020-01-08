$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
        UPDATE borrowers SET relationship = NULL
        WHERE relationship = ""
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24215 - Replace relationship with NULL when empty string)\n";
}
