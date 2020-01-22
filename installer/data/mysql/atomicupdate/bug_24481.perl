$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(qq{
        UPDATE
          `permissions`
        SET
          `module_bit` = 3
        WHERE
          `code` = 'manage_cash_registers'
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24481 - Move permission to correct module_bit)\n";
}
