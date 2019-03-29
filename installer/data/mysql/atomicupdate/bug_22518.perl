$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    my $rows = $dbh->do(
        qq{
        UPDATE `accountlines`
        SET
          `accounttype` = 'FU'
        WHERE
          `accounttype` = 'O'
      }
    );

    SetVersion($DBversion);
    printf "Upgrade to $DBversion done (Bug 22518 - Fix accounttype 'O' to 'FU' - %d updated)\n", $rows;
}
