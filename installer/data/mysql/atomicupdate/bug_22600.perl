$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    if ( !column_exists( 'accountlines', 'interface' ) ) {
        $dbh->do(
            qq{
            ALTER TABLE `accountlines`
            ADD
              `interface` varchar(16)
            AFTER
              `manager_id`;
          }
        );
    }

    $dbh->do(qq{
        UPDATE
          `accountlines`
        SET
          interface = 'opac'
        WHERE
          borrowernumber = manager_id;
    });

    $dbh->do(qq{
        UPDATE
          `accountlines`
        SET
          interface = 'cron'
        WHERE
          manager_id IS NULL
        AND
          branchcode IS NULL;
    });

    $dbh->do(qq{
        UPDATE
          `accountlines`
        SET
          interface = 'intranet'
        WHERE
          interface IS NULL;
    });

    $dbh->do(qq{
        ALTER TABLE `accountlines`
        MODIFY COLUMN `interface` varchar(16) NOT NULL;
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22600 - Add interface to accountlines)\n";
}
