$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    # Add constraint for suggestedby
    unless ( foreign_key_exists( 'suggestions', 'suggestions_ibfk_suggestedby' ) )
    {
        $dbh->do(
"ALTER TABLE suggestions CHANGE COLUMN suggestedby suggestedby INT(11) NULL DEFAULT NULL;"
        );
        $dbh->do(
"UPDATE suggestions LEFT JOIN borrowers ON (suggestions.suggestedby = borrowers.borrowernumber) SET suggestedby = null WHERE borrowernumber IS null"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_suggestedby` FOREIGN KEY (`suggestedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for managedby
    unless ( foreign_key_exists( 'suggestions', 'suggestions_ibfk_managedby' ) )
    {
        $dbh->do(
"UPDATE suggestions LEFT JOIN borrowers ON (suggestions.managedby = borrowers.borrowernumber) SET managedby = null WHERE borrowernumber IS NULL"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_managedby` FOREIGN KEY (`managedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for acceptedby
    unless (
        foreign_key_exists( 'suggestions', 'suggestions_ibfk_acceptedby' ) )
    {
        $dbh->do(
"UPDATE suggestions LEFT JOIN borrowers ON (suggestions.acceptedby = borrowers.borrowernumber) SET acceptedby = null WHERE borrowernumber IS NULL"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_acceptedby` FOREIGN KEY (`acceptedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for rejectedby
    unless (
        foreign_key_exists( 'suggestions', 'suggestions_ibfk_rejectedby' ) )
    {
        $dbh->do(
"UPDATE suggestions LEFT JOIN borrowers ON (suggestions.rejectedby = borrowers.borrowernumber) SET rejectedby = null WHERE borrowernumber IS null"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_rejectedby` FOREIGN KEY (`rejectedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for biblionumber
    unless (
        foreign_key_exists( 'suggestions', 'suggestions_ibfk_biblionumber' ) )
    {
        $dbh->do(
"UPDATE suggestions s LEFT JOIN biblio b ON (s.biblionumber = b.biblionumber) SET s.biblionumber = null WHERE b.biblionumber IS null"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_biblionumber` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for branchcode
    unless (
        foreign_key_exists( 'suggestions', 'suggestions_ibfk_branchcode' ) )
    {
        $dbh->do(
"UPDATE suggestions s LEFT JOIN branches b ON (s.branchcode = b.branchcode) SET s.branchcode = null WHERE b.branchcode IS null"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_branchcode` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    SetVersion($DBversion);
    print
"Upgrade to $DBversion done (Bug 22368 - Add missing constraints to suggestions)\n";
}
