$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('BiblioItemtypeInfo', '0','Control whether biblio level itemtype image displays','0','YesNo')" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 8732: Add new BiblioItemtypeInfo to system preferences)\n";
}
