$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( 'UPDATE systempreferences SET options = "Calendar|Days|Datedue|Dayweek", explanation = "Choose the method for calculating due date: select Calendar, Datedue or Dayweek to use the holidays module, and Days to ignore the holidays module" WHERE variable = "useDaysMode"' );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15260 - Option for extended loan with useDaysMode)\n";
}
