$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('AdvancedSearchLanguagesSort', '0', NULL, 'Use AdvancedSearchLanguages to sort the drop-down list. The leftmost language has the highest priority and appears on top of the drop-down.', 'YesNo')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14912 - Sort Advanced Search languages by priority)\n";
}
