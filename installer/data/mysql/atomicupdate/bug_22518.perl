$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

        $dbh->do(
            qq{
            UPDATE `accountlines`
            SET
              `accounttype` = 'FU'
            WHERE
              `accounttype` = 'O'
          }
        );

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22518 - Fix accounttype 'O' to 'FU')\n";
}
