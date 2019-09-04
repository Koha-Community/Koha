$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{ALTER TABLE accountlines CHANGE COLUMN accounttype accounttype varchar(80) default NULL});

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23539 - accountlines.accounttype should match authorised_values.authorised_value in size)\n";
}
