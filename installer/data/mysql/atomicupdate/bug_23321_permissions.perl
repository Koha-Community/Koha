$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
        INSERT IGNORE INTO `userflags` (`bit`, `flag`, `flagdesc`, `defaulton`)
        VALUES (25, 'cash_management', 'Cash management', 0)
    });

    $dbh->do(qq{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (25, 'manage_cash_registers', 'Add and remove cash registers')
    });


    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23321 - Add cash register permissions)\n";
}
