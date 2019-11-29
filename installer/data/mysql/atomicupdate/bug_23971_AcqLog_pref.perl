$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('AcqLog', '0', 'If enabled, log acquisition activity', '', 'YesNo'); | );

    NewVersion( $DBversion, 23971, "Add AcqLog syspref");
}
