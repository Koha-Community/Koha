$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)
    VALUES ('MARC21FormatWarningsIgnoreFields', '', NULL,
            'Fields not to check for MARC21 format errors when saving a biblio. eg. \"090,9xx,100a,028.ind1\"', 'free')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-3223: Add MARC21 Format error checking when saving a biblio)\n";
}

