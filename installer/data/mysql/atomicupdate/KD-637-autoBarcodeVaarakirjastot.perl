$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do(
        'UPDATE systempreferences SET options = CONCAT(options, "|vaarakirjastot") WHERE variable = "autoBarcode";'
    );
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-637: Add 'vaarakirjastot' to 'autoBarcode'-syspref)\n";
}
