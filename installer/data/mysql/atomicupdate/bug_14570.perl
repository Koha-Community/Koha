$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );
    unless (TableExists('borrower_relationships')){
        $dbh->do(q{
            CREATE TABLE `borrower_relationships` (
                  id INT(11) NOT NULL AUTO_INCREMENT,
                  guarantor_id INT(11) NOT NULL,
                  guarantee_id INT(11) NOT NULL,
                  relationship VARCHAR(100) NOT NULL,
                  PRIMARY KEY (id),
                  CONSTRAINT r_guarantor FOREIGN KEY ( guarantor_id ) REFERENCES borrowers ( borrowernumber ) ON UPDATE CASCADE ON DELETE CASCADE,
                  CONSTRAINT r_guarantee FOREIGN KEY ( guarantee_id ) REFERENCES borrowers ( borrowernumber ) ON UPDATE CASCADE ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        });

        $dbh->do(q{
            UPDATE borrowers
            LEFT JOIN borrowers guarantor ON ( borrowers.guarantorid = guarantor.borrowernumber )
            SET borrowers.guarantorid = NULL WHERE guarantor.borrowernumber IS NULL;
        });

        $dbh->do(q{
            INSERT INTO borrower_relationships ( guarantor_id, guarantee_id, relationship )
            SELECT guarantorid, borrowernumber, relationship FROM borrowers WHERE guarantorid IS NOT NULL;
        });

    }

     if( column_exists( 'borrowers', 'guarantorid' ) ) {
        $dbh->do(q{
            ALTER TABLE borrowers DROP guarantorid;
        });
     }

     if( column_exists( 'deletedborrowers', 'guarantorid' ) ) {
        $dbh->do(q{
            ALTER TABLE deletedborrowers DROP guarantorid;
        });
     }

     if( column_exists( 'borrower_modifications', 'guarantorid' ) ) {
        $dbh->do(q{
            ALTER TABLE borrower_modifications DROP guarantorid;
        });
     }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14570 - Make it possible to add multiple guarantors to a record)\n";
}
