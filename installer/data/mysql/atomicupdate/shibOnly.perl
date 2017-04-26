$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('opacShibOnly','0','If ON enables shibboleth only authentication for the opac','','YesNo'),('staffShibOnly','0','If ON enables shibboleth only authentication for the staff client','','YesNo')" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - shibOnly preferences)\n";
}
