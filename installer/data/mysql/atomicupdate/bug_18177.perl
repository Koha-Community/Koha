$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    for my $column ( qw(othersupplier booksellerfax booksellerurl bookselleremail currency) ) {
        if( column_exists( 'aqbooksellers', $column ) ) {
            my ($count) = $dbh->selectrow_array(qq|
                SELECT COUNT(*)
                FROM aqbooksellers
                WHERE $column IS NOT NULL AND $column <> ""
            |);
            if ( $count ) {
                warn "Warning - Cannot remove column aqbooksellers.$column. At least one value exists";
            } else {
                $dbh->do(qq|
                    ALTER TABLE aqbooksellers
                    DROP COLUMN $column
                |);
            }
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18177 - Remove some unused columns from aqbooksellers)\n";
}
