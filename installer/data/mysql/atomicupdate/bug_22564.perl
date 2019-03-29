$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    my $rows = $dbh->do(
        qq{
        UPDATE `accountlines`
        SET
          `accounttype` = 'L',
          `status`      = 'REPLACED'
        WHERE
          `accounttype` = 'Rep'
      }
    );

    SetVersion($DBversion);
    printf "Upgrade to $DBversion done (Bug 22564 - Fix accounttype 'O' to 'FU' - %d updated)\n", $rows;
}
