$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('UnseenRenewals', '0', 'If enabled, a renewal can be recorded as "unseen" by the library and count against the borrowers unseen renewals limit', '', 'YesNo'); | );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24083 - Add UnseenRenewals syspref)\n";
}
