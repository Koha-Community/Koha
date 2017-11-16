$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('FinnaBaseURL','','','YAML configuration for Finna base URL.','Textarea')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
