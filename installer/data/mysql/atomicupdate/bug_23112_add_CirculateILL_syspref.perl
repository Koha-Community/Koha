$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('CirculateILL', '0', 'If enabled, it is possible to circulate ILL requested items from within ILL', '', 'YesNo'); | );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23112  - Add CirculateILL syspref)\n";
}
