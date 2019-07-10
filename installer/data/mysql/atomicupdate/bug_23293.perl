$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
            INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
            ('OPACFineNoRenewalsIncludeCredits','1',NULL,'If enabled the value specified in OPACFineNoRenewals should include any unapplied account credits in the calculation','YesNo')
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23293 - Add 'OPACFineNoRenewalsIncludeCredits' system preference)\n";
}
