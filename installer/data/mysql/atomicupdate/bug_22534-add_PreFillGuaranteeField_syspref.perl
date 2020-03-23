$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('PrefillGuaranteeField', 'phone,email,streetnumber,address,city,state,zipcode,country', NULL, 'Prefill these fields in guarantee member entry form from guarantor patron record', 'Multiple') });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
