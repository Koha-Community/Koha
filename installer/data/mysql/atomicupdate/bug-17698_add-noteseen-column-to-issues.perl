$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'issues', 'noteseen' ) ) {
        $dbh->do(q|ALTER TABLE issues ADD COLUMN noteseen int(1) default NULL AFTER notedate|);
    }

    unless( column_exists( 'old_issues', 'noteseen' ) ) {
        $dbh->do(q|ALTER TABLE old_issues ADD COLUMN noteseen int(1) default NULL AFTER notedate|);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17698: Add column issues.noteseen and old_issues.noteseen)\n";
}
