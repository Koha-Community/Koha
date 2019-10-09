$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('RenewAccruingItemInOpac', '0', 'If enabled, when the fines on an item accruing is paid off in the OPAC via a payment plugin, attempt to renew that item. If the syspref "RenewalPeriodBase" is set to "due date", renewed items may still be overdue', '', 'YesNo'); | );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23051 - Add RenewAccruingItemInOpac syspref)\n";
}
