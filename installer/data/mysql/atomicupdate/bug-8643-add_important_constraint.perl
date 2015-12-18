$DBversion = "XXX";
if ( CheckVersion($DBversion) ) {
    if ( !column_exists( 'marc_subfield_structure', 'important') ){
        $dbh->do("ALTER TABLE marc_subfield_structure ADD COLUMN important TINYINT(4) NOT NULL DEFAULT 0  AFTER mandatory");
    }
    if ( !column_exists( 'marc_tag_structure', 'important') ){
        $dbh->do("ALTER TABLE marc_tag_structure ADD COLUMN important TINYINT(4) NOT NULL DEFAULT 0  AFTER mandatory");
    }
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 8643 - Add important constraint to marc subfields)\n";
}
