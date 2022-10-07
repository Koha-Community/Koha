

$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('OPACAllowUserToChangeBranch','','Pending, In-Transit, Suspended','Allow users to change the library to pick up a hold for these statuses:','multiple');" );
    $dbh->do( "UPDATE systempreferences set value = (SELECT CASE WHEN value = 1 THEN 'intransit' ELSE '' END FROM systempreferences WHERE variable = 'OPACInTransitHoldPickupLocationChange')");
    $dbh->do( "DELETE FROM systempreferences WHERE variable = 'OPACInTransitHoldPickupLocationChange' ");
    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 14783, "Allow patrons to change pickup location for non-waiting holds");
}
