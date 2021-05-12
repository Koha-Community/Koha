$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('NewsLog', '0', 'If enabled, log OPAC News changes', '', 'YesNo'); | );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 26205, "Log OPAC News changes");
}
