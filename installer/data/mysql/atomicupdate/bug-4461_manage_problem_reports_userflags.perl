$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton) VALUES (26, 'problem_reports', 'Manage problem reports', 0) });
    $dbh->do(q{INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (26, 'manage_problem_reports', 'Manage OPAC problem reports') });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 4461 - Add user permissions for managing OPAC problem reports)\n";
}
