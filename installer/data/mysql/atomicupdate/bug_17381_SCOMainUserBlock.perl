$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` ) VALUES ('SCOMainUserBlock','','70|10','Add a block of HTML that will display on the self checkout screen','Textarea')" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17381 - Add system preference SCOMainUserBlock)\n";
}
