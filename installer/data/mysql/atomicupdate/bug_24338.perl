$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $exists;
    eval { $exists = $dbh->do("SELECT 1 FROM authorised_values WHERE category = 'PAYMENT_TYPE' AND authorised_value = 'CASH'"); };
    if ( $exists == 0 ) {
        $dbh->do(qq{
            INSERT INTO
              authorised_values (category,authorised_value,lib, lib_opac)
            VALUES
              ('PAYMENT_TYPE','CASH','Cash','Cash')
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24338 - Add 'CASH' to default 'PAYMENT_TYPE')\n";
}
