$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    $dbh->do( "INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('ItemsDeniedRenewal','','','This syspref allows to define custom rules for denying renewal of specific items.','Textarea')" );

    # or perform some test and warn
    # if( !column_exists( 'biblio', 'biblionumber' ) ) {
    #    warn "There is something wrong";
    # }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15494 - Block renewals by arbitrary item values)\n";
}
