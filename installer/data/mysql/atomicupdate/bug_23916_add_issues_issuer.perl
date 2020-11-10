$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'issues', 'issuer' ) ) {
        $dbh->do( q| ALTER TABLE issues ADD issuer_id INT(11) DEFAULT NULL AFTER borrowernumber | );
    }
    if (!foreign_key_exists( 'issues', 'issues_ibfk_borrowers_borrowernumber' )) {
        $dbh->do( q| ALTER TABLE issues ADD CONSTRAINT `issues_ibfk_borrowers_borrowernumber` FOREIGN KEY (`issuer_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE | );
    }
    if( !column_exists( 'old_issues', 'issuer' ) ) {
        $dbh->do( q| ALTER TABLE old_issues ADD issuer_id INT(11) DEFAULT NULL AFTER borrowernumber | );
    }
    if (!foreign_key_exists( 'old_issues', 'old_issues_ibfk_borrowers_borrowernumber' )) {
        $dbh->do( q| ALTER TABLE old_issues ADD CONSTRAINT `old_issues_ibfk_borrowers_borrowernumber` FOREIGN KEY (`issuer_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE | );
    }

    NewVersion( $DBversion, 23916, "Add issues.issuer";
}
