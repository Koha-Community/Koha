$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # $dbh->do( "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OrderPriceRounding',NULL,'Local preference for rounding orders before calculations to ensure correct calculations','|nearest_cent','Choice')" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18736 - Add syspref to control order rounding)\n";
}
