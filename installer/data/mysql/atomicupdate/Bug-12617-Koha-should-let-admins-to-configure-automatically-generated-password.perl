$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("ALTER TABLE categories ADD COLUMN passwordpolicy VARCHAR(40) DEFAULT NULL");

    $dbh->do(
        "INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('minAlnumPasswordLength', '10', null, 'Specify the minimum length for alphanumeric passwords', 'free')"
    );
    $dbh->do(
        "INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('minComplexPasswordLength', '10', null, 'Specify the minimum length for complex passwords', 'free')"
    );
    $dbh->do(
        "UPDATE systempreferences set explanation='Specify the minimum length for simplenumeric passwords' where variable='minPasswordLength'"
    );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12617 - Koha should let admins to configure automatically generated password complexity/difficulty)\n";
}