$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET value = '2' WHERE value = '0' AND variable = 'UsageStats'" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23866 - Set HEA syspref to prompt for review)\n";
}
