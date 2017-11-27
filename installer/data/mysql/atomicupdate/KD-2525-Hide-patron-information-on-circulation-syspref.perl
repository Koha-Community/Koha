$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(
        "INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('ReducePatronInformationOnCirculation', '1', null, 'Hide identifiable user information on checkin/checkout', 'YesNo');"
    );
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-2525-Hide-patron-information-on-circulation-syspref)\n";
}
