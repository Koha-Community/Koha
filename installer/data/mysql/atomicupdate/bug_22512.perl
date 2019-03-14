$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    if ( !column_exists( 'accountlines', 'status' ) ) {
        $dbh->do(
            qq{
            ALTER TABLE `accountlines`
            ADD
              `status` varchar(16) DEFAULT NULL
            AFTER
              `accounttype`
          }
        );
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22512 - Add status to accountlines)\n";
}
