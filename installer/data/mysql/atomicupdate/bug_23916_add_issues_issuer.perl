$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'issues', 'issuer' ) ) {
        $dbh->do( q| ALTER TABLE issues ADD issuer INT(11) AFTER borrowernumber | );
    }
    if (!foreign_key_exists( 'issues', 'issues_ibfk_borrowers_borrowernumber' )) {
        $dbh->do( q| ALTER TABLE issues ADD CONSTRAINT `issues_ibfk_borrowers_borrowernumber` FOREIGN KEY (`issuer`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE | );
    }
    if( !column_exists( 'old_issues', 'issuer' ) ) {
        $dbh->do( q| ALTER TABLE old_issues ADD issuer INT(11) AFTER borrowernumber | );
    }
    if (!foreign_key_exists( 'old_issues', 'old_issues_ibfk_borrowers_borrowernumber' )) {
        $dbh->do( q| ALTER TABLE old_issues ADD CONSTRAINT `old_issues_ibfk_borrowers_borrowernumber` FOREIGN KEY (`issuer`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE | );
    }

    # Now attempt to migrate previously action logged issues into issues.issuer
    # We assume that an item issued to a borrower on the same day is the same issue
    #
    # Get existing action logs
    # - user = issuer
    # - object = borrowernumber
    # - info = itemnumber
    my $action_logs = $dbh->selectall_arrayref("SELECT DATE(timestamp) AS dt, user, object, info FROM action_logs WHERE module='CIRCULATION' and action='ISSUE'", { Slice => {} });

    foreach my $log( @{$action_logs} ) {
        # Look for an issue of this item, to this borrower, on this day
        # We're doing DATE comparison in the database to avoid invoking
        # DateTime and it's performance sapping ways...
        #
        # If we're dealing with an actual borrower
        if ($log->{user} != 0) {
            my $done_issue = $dbh->do(
                "UPDATE issues SET issuer = ? WHERE DATE(timestamp) = ? AND borrowernumber = ? AND itemnumber = ?",
                undef,
                ( $log->{user}, $log->{dt}, $log->{object}, $log->{info} )
            );
            # If we didn't find the issue in 'issues', look in 'old_issues'
            if (!$done_issue) {
                $dbh->do(
                    "UPDATE old_issues SET issuer = ? WHERE DATE(timestamp) = ? AND borrowernumber = ? AND itemnumber = ?",
                    undef,
                    ( $log->{user}, $log->{dt}, $log->{object}, $log->{info} )
                );
            }
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23916 - Add issues.issuer)\n";
}
