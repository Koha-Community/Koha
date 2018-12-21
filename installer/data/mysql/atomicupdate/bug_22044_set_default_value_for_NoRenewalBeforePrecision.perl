$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('NoRenewalBeforePrecision', 'exact_time', 'Calculate "No renewal before" based on date or exact time. Only relevant for loans calculated in days, hourly loans are not affected.', 'date|exact_time', 'Choice');
    });
    $dbh->do("UPDATE systempreferences SET value='exact_time' WHERE variable='NoRenewalBeforePrecision' AND value IS NULL;" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22044 - Set a default value for NoRenewalBeforePrecision)\n";
}
