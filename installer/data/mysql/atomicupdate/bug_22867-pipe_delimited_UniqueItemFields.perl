$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{UPDATE systempreferences SET value = REPLACE( value, ' ', '|' ) WHERE variable = 'UniqueItemFields'; });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22867 - UniqueItemFields preference value should be pipe-delimited)\n";
}
