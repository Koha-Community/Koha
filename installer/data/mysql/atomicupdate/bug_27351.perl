$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{UPDATE systempreferences SET `type` = 'Choice' WHERE `variable` = 'UsageStatsCountry'});
    NewVersion( $DBversion, 27351, "Set type for UsageStatsCountry to Choice");
}
