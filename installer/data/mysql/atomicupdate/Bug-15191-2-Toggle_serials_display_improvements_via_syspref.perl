$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('SerialsDisplayTree','0',NULL,'Use serials display improvements and the hold picker','YesNo')");
    $dbh->do("UPDATE `systempreferences` SET value=(SELECT value FROM (SELECT * FROM systempreferences) as sysprefs WHERE variable='UseBetaFeatures') WHERE variable='SerialsDisplayTree'");
    $dbh->do("DELETE FROM `systempreferences` WHERE variable='UseBetaFeatures'");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15191 - Toggle serials display improvements)\n";
}
