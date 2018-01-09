$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("UPDATE serial SET serialseq_x=pattern_x");
    $dbh->do("UPDATE serial SET serialseq_y=pattern_y");
    $dbh->do("UPDATE serial SET serialseq_z=pattern_z");

    $dbh->do("ALTER TABLE serial DROP COLUMN pattern_x");
    $dbh->do("ALTER TABLE serial DROP COLUMN pattern_y");
    $dbh->do("ALTER TABLE serial DROP COLUMN pattern_z");

    $dbh->do("ALTER TABLE serial ADD INDEX (serialseq_x)");
    $dbh->do("ALTER TABLE serial ADD INDEX (serialseq_y)");
    $dbh->do("ALTER TABLE serial ADD INDEX (serialseq_z)");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15191 - Serials display improvements - Move pattern_xyz to serialseq_xyz.)\n";
}
