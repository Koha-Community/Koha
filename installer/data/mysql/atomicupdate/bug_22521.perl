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

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'OVERDUE',
          status = 'UNRETURNED'
        WHERE
          accounttype = 'FU';
    });

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'OVERDUE',
          status = 'FORGIVEN'
        WHERE
          accounttype = 'FFOR';
    });

    $dbh->do(qq{
        UPDATE
          accountlines
        SET
          accounttype = 'OVERDUE',
          status = 'RETURNED'
        WHERE
          accounttype = 'F';
    });
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22521 - Update accountlines.accounttype to varchar(16), and map new statuses)\n";
}
