$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'issues', 'unseen_renewals' ) ) {
        $dbh->do( q| ALTER TABLE issues ADD unseen_renewals TINYINT(4) DEFAULT 0 NOT NULL AFTER renewals | );
    }
    if( !column_exists( 'old_issues', 'unseen_renewals' ) ) {
        $dbh->do( q| ALTER TABLE old_issues ADD unseen_renewals TINYINT(4) DEFAULT 0 NOT NULL AFTER renewals | );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24083 - Add issues.unseen_renewals & old_issues.unseen_renewals)\n";
}
