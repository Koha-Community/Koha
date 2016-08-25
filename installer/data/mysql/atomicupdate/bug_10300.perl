$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        SELECT 'IndependentBranchesTransfers', value, NULL, 'Allow non-superlibrarians to transfer items between libraries','YesNo'
        FROM systempreferences WHERE variable = 'IndependentBranches'
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 10300 - Allow transferring of items to be have separate IndependentBranches syspref)\n";
}
