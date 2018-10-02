$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable, value, explanation, type) VALUES ('IllLog', 0, 'If ON, log information about ILL requests', 'YesNo')" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20750 - Allow timestamped auditing of ILL request events)\n";
}
