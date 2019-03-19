$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    if ( column_exists( 'accountlines', 'accounttype' ) ) {
        $dbh->do(
            qq{
            ALTER TABLE `accountlines`
            CHANGE COLUMN `accounttype`
              `accounttype` varchar(16) DEFAULT NULL;
          }
        );
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22521 - Update accountlines.accounttype to varchar(16))\n";
}
