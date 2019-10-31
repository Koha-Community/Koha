$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('RecordIssuer', '0', 'If enabled, when an item is issued, the user who issued the item is recorded', '', 'YesNo'); | );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23916 - Add RecordIssuer syspref)\n";
}
