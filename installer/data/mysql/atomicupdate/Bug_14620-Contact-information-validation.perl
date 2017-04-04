$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('ValidatePhoneNumber','','','Regex for validation of patron phone numbers.','Textarea')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14620 - description)\n";
}
