$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE quotes MODIFY timestamp datetime NULL" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24640 - Allow quotes.timestamp to be NULL)\n";
}
