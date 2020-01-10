$DBversion = 'XXX'; # will be replaced by the RM
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('NoIssuesChargeGuarantorsWithGuarantees','','','Define maximum amount withstanding before checkouts are blocked including guarantors and their other guarantees','Integer');
    });

    print "Upgrade to $DBversion done (Bug 19382 - Add ability to block guarantees based on fees owed by guarantor and other guarantees)\n";
    SetVersion($DBversion);
}
