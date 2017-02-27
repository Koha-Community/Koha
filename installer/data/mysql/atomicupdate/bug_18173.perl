$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    if ( column_exists( 'issues', 'return' ) ) {
        $dbh->do(q|ALTER TABLE issues DROP column `return`|);
    }

    if ( column_exists( 'old_issues', 'return' ) ) {
        $dbh->do(q|ALTER TABLE old_issues DROP column `return`|);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18173 - Remove issues.return DB field)\n";
}
