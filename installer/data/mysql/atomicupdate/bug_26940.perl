$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $debar = $dbh->selectall_arrayref(q|
        SELECT d.borrowernumber, GROUP_CONCAT(comment SEPARATOR '\n') AS comment
        FROM borrower_debarments d
        LEFT JOIN borrowers b ON b.borrowernumber=d.borrowernumber
        WHERE b.debarredcomment IS NULL AND ( expiration > CURRENT_DATE() OR expiration IS NULL )
        GROUP BY d.borrowernumber
    |, { Slice => {} });


    my $update_sth = $dbh->prepare(q|
        UPDATE borrowers
        SET debarredcomment=?
        WHERE borrowernumber=?
    |);
    for my $d ( @$debar ) {
        $update_sth->execute($d->{comment}, $d->{borrowernumber});
    }

    NewVersion( $DBversion, 26940, "Put in sync borrowers.debarredcomment with comments from borrower_debarments");
}
