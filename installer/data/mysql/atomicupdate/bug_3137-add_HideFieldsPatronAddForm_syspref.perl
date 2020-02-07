$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('HideFieldsPatronAddForm','',NULL,'Hide these fields by default when adding a new patron. These fields can still be expanded.','Multiple') });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
