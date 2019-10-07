$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET variable='PatronAutoComplete' WHERE variable='CircAutocompl' LIMIT 1" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23697 - Rename CircAutocompl system preference to PatronAutoComplete)\n";
}
