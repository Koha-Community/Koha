$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(
        "INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('AnonymizeOthernames', '0', null, 'If set, anonymize borrowers holds identifiers when adding new borrowers', 'YesNo');"
    );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1452 - Syspref for anonymous holds identifiers)\n";
}
