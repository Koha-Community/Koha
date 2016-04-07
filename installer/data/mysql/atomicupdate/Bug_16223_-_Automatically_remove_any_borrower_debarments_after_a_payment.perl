$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type)
             VALUES ('DebarmentsToLiftAfterPayment', '', '', 'Lift these debarments after Borrower has paid his/her fees', 'textarea')");
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16623: Automatically remove any borrower debarments after a payment)\n";
}
