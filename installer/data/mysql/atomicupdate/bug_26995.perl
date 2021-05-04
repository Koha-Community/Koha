$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if ( column_exists( 'borrowers', 'relationship' ) ) {
        $dbh->do(q{
            ALTER TABLE borrowers DROP COLUMN relationship
        });
    }

    if ( column_exists( 'deletedborrowers', 'relationship' ) ) {
        $dbh->do(q{
            ALTER TABLE deletedborrowers DROP COLUMN relationship
        });
    }

    if ( column_exists( 'borrower_modifications', 'relationship' ) ) {
        $dbh->do(q{
            ALTER TABLE borrower_modifications DROP COLUMN relationship
        });
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 26995, "Drop column relationship from borrower tables");
}
