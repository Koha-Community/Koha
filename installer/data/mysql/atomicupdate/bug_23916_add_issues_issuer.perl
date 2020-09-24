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

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23916 - Add issues.issuer)\n";
}
