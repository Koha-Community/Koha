$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    # Add constraint for suggestedby
    my $sth = $dbh->prepare(
q|SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='suggestions_ibfk_suggestedby'|
    );
    $sth->execute;
    unless ( $sth->fetchrow_hashref ) {
        $dbh->do("ALTER TABLE suggestions CHANGE COLUMN suggestedby suggestedby INT(11) NULL DEFAULT NULL;");
        $dbh->do(
"UPDATE suggestions SET suggestedby = NULL where suggestedby NOT IN (SELECT borrowernumber FROM borrowers)"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_suggestedby` FOREIGN KEY (`suggestedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for managedby
    $sth = $dbh->prepare(
q|SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='suggestions_ibfk_managedby'|
    );
    $sth->execute;
    unless ( $sth->fetchrow_hashref ) {
        $dbh->do(
"UPDATE suggestions SET managedby = NULL where managedby NOT IN (SELECT borrowernumber FROM borrowers)"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_managedby` FOREIGN KEY (`managedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for acceptedby
    $sth = $dbh->prepare(
q|SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='suggestions_ibfk_acceptedby'|
    );
    $sth->execute;
    unless ( $sth->fetchrow_hashref ) {
        $dbh->do(
"UPDATE suggestions SET acceptedby = NULL where acceptedby NOT IN (SELECT borrowernumber FROM borrowers)"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_acceptedby` FOREIGN KEY (`acceptedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for rejectedby
    $sth = $dbh->prepare(
q|SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='suggestions_ibfk_rejectedby'|
    );
    $sth->execute;
    unless ( $sth->fetchrow_hashref ) {
        $dbh->do(
"UPDATE suggestions SET rejectedby = NULL where rejectedby NOT IN (SELECT borrowernumber FROM borrowers)"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_rejectedby` FOREIGN KEY (`rejectedby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for biblionumber
    $sth = $dbh->prepare(
q|SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='suggestions_ibfk_biblionumber'|
    );
    $sth->execute;
    unless ( $sth->fetchrow_hashref ) {
        $dbh->do(
"UPDATE suggestions SET biblionumber = NULL where biblionumber NOT IN (SELECT biblionumber FROM biblio)"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_biblionumber` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    # Add constraint for branchcode
    $sth = $dbh->prepare(
q|SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='suggestions_ibfk_branchcode'|
    );
    $sth->execute;
    unless ( $sth->fetchrow_hashref ) {
        $dbh->do(
"UPDATE suggestions SET branchcode = NULL where branchcode NOT IN (SELECT branchcode FROM branches)"
        );
        $dbh->do(
"ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_branchcode` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE"
        );
    }

    SetVersion($DBversion);
    print
"Upgrade to $DBversion done (Bug 22368 - Add missing constraints to suggestions)\n";
}
