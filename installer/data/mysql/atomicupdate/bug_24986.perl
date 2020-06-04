$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    for my $f (qw( streetnumber streettype zipcode mobile B_streetnumber B_streettype B_zipcode ) ) {
        $dbh->do(qq|
            ALTER TABLE borrowers MODIFY $f TINYTEXT DEFAULT NULL
        |);
        $dbh->do(qq|
            ALTER TABLE deletedborrowers MODIFY $f TINYTEXT DEFAULT NULL
        |);
    }
    for my $f ( qw( B_address altcontactfirstname altcontactsurname altcontactaddress1 altcontactaddress2 altcontactaddress3 altcontactzipcode altcontactphone ) ) {
        $dbh->do(qq|
            ALTER TABLE borrowers MODIFY $f MEDIUMTEXT DEFAULT NULL
        |);
        $dbh->do(qq|
            ALTER TABLE deletedborrowers MODIFY $f MEDIUMTEXT DEFAULT NULL
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24986 - Switch borrowers address related fields to TINYTEXT or MEDIUMTEXT)\n";
}
