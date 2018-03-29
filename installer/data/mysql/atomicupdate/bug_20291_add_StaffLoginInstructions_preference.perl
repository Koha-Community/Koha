$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('StaffLoginInstructions','','HTML to go into the login box for the staff client',NULL,'Free')");
    $dbh->do("UPDATE systempreferences SET variable = 'OpacLoginInstructions' WHERE variable = 'NoLoginInstructions'");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20291 - Add StaffLoginInstructions system preference)\n";
}
