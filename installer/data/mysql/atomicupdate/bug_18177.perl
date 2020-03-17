$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    for my $column ( qw(othersupplier booksellerfax booksellerurl bookselleremail currency) ) {
        if( column_exists( 'aqbooksellers', $column ) ) {
            $dbh->do(qq|
                ALTER TABLE aqbooksellers
                DROP COLUMN $column
            |);
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18177 - Remove some unused columns from aqbooksellers)\n";
}
