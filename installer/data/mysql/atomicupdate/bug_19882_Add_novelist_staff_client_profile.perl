$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('NovelistSelectStaffProfile',NULL,'Novelist staff client user Profile',NULL,'free')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19882 - Add Novelist Staff Client Profile)\n";
}
