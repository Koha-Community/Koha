$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES('AuthorityMergeMode','loose','loose|strict','Authority merge mode','Choice')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17913 - AuthorityMergeMode)\n";
}
