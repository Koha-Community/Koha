$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q| INSERT IGNORE INTO circulation_rules (rule_name) VALUES ('unseen_renewals_allowed') | );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24083 - Add circulation_rules 'unseen_renewals_allowed' rule)\n";
}
