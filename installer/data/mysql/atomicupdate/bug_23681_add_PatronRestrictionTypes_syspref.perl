$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('PatronRestrictionTypes', '0', 'If enabled, it is possible to specify the "type" of patron restriction being applied.', '', 'YesNo'); | );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23681 - Add PatronRestrictionTypes syspref)\n";
}
