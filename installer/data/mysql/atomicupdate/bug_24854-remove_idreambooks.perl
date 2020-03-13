$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "DELETE FROM systempreferences WHERE variable in ('IDreamBooksReadometer','IDreamBooksResults','IDreamBooksReviews')" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24854 - Remove IDreamBooks* system preferences)\n";
}
