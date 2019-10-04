$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences
        (variable,value,explanation,options,type)
        VALUES
        ('RoundFinesAtPayment','0','If enabled any fines with fractions of a cent will be rounded to the nearest cent when payments are collected. e.g. 1.004 will be paid off by a 1.00 payment','0','YesNo')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17140 - Add pref to allow rounding fines at payment)\n";
}
