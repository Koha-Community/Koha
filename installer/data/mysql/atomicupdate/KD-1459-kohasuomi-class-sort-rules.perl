$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO class_sort_rules (class_sort_rule, description, sort_routine) VALUES ('outi', 'Outi järjestelysääntö', 'OUTI');");
    $dbh->do("INSERT INTO class_sort_rules (class_sort_rule, description, sort_routine) VALUES ('lumme', 'Lumme järjestelysääntö', 'LUMME');");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1459-kohasuomi-class-sort-rules)\n";
}
