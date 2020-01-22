$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
        ('EnablePointOfSale','0',NULL,'Enable the point of sale feature to allow anonymous transactions with the accounting system. (Requires UseCashRegisters)','YesNo')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24478 - Add `EnablePointOfSale` system preference to allow disabling the point of sale feature)\n";
}
