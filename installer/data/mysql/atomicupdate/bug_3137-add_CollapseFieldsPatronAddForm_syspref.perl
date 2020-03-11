$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('CollapseFieldsPatronAddForm','',NULL,'Collapse these fields by default when adding a new patron. These fields can still be expanded.','Multiple') });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 4461 - Add CollapseFieldsPatronAddForm system preference)\n";
}
