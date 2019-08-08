$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        ALTER TABLE marc_subfield_structure CHANGE COLUMN hidden hidden TINYINT(1) DEFAULT 8 NOT NULL;
    |);
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23309 - Can't add new subfields to bibliographic frameworks in strict mode)\n";
}
