$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET value = 'off'
        WHERE variable = 'finesMode' AND (value <> 'production' OR value IS NULL)
    });
    $dbh->do(q{
        UPDATE systempreferences SET options = 'off|production',
        explanation = "Choose the fines mode, 'off' (do not accrue fines) or 'production' (accrue overdue fines).  Requires accruefines cronjob or CalculateFinesOnReturn system preference."
        WHERE variable = 'finesMode'
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21633  - Remove finesMode 'test')\n";
}
