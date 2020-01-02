$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE action_logs MODIFY COLUMN `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24329 - Do not update action_log.timestamp)\n";
}
