$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add constraint for manager_id
    unless( foreign_key_exists( 'accountlines', 'accountlines_ibfk_borrowers_2' ) ) {
        $dbh->do("ALTER TABLE accountlines CHANGE COLUMN manager_id manager_id INT(11) NULL DEFAULT NULL");
        $dbh->do("UPDATE accountlines a LEFT JOIN borrowers b ON ( a.manager_id = b.borrowernumber) SET a.manager_id = NULL WHERE b.borrowernumber IS NULL");
        $dbh->do("ALTER TABLE accountlines ADD CONSTRAINT `accountlines_ibfk_borrowers_2` FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE");
    }

    # Rename accountlines_ibfk_2 to accountlines_ibfk_items
    if ( foreign_key_exists( 'accountlines', 'accountlines_ibfk_2' ) && !foreign_key_exists( 'accountlines', 'accountlines_ibfk_items' ) ) {
        $dbh->do("ALTER TABLE accountlines DROP FOREIGN KEY accountlines_ibfk_2");
        $dbh->do("ALTER TABLE accountlines ADD CONSTRAINT `accountlines_ibfk_items` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE CASCADE");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22008 - Add missing constraints for accountlines.manager_id)\n";
}
