$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('RenewAccruingItemWhenPaid', '0', 'If enabled, when the fines on an item accruing is paid off, attempt to renew that item. If the syspref "RenewalPeriodBase" is set to "due date", renewed items may still be overdue', '', 'YesNo'); | );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23051 - Add RenewAccruingItemWhenPaid syspref)\n";
}
