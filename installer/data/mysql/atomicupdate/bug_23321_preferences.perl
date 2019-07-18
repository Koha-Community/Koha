$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
        ('UseCashRegisters','0','','Use cash registers with the accounting system and assign patron transactions to them.','YesNo')
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23321 - Add cash register system preference)\n";
}
