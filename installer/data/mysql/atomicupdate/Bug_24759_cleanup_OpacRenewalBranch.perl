$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET options = 'itemhomebranch|patronhomebranch|checkoutbranch|none' WHERE variable='OpacRenewalBranch'
    });
    $dbh->do(q{
        UPDATE systempreferences SET value = "none" WHERE variable='OpacRenewalBranch'
        AND value = 'NULL'
    });
    $dbh->do(q{
        UPDATE systempreferences SET value = 'opacrenew' WHERE variable='OpacRenewalBranch'
        AND value NOT IN ('checkoutbranch','itemhomebranch','opacrenew','patronhomebranch','none')
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24759 - cleanup OpacRenewalBranch)\n";
}
