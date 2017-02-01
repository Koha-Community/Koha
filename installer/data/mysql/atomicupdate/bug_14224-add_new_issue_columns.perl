$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'issues', 'note' ) ) {
        $dbh->do(q|ALTER TABLE issues ADD note mediumtext default NULL AFTER onsite_checkout|);
    }
    unless( column_exists( 'issues', 'notedate' ) ) {
        $dbh->do(q|ALTER TABLE issues ADD notedate datetime default NULL AFTER note|);
    }
    unless( column_exists( 'old_issues', 'note' ) ) {
        $dbh->do(q|ALTER TABLE old_issues ADD note mediumtext default NULL AFTER onsite_checkout|);
    }
    unless( column_exists( 'old_issues', 'notedate' ) ) {
        $dbh->do(q|ALTER TABLE old_issues ADD notedate datetime default NULL AFTER note|);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14224: Add column issues.note and issues.notedate)\n";
}
