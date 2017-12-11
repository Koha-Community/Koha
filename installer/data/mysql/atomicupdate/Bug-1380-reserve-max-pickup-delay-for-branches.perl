$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('ReservesMaxPickUpDelayBranch', '', '', 'Add reserve max pickup delay for individual branches.', 'Textarea')");
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 1380 - Add reserve max pickup delay for individual branches.)\n";
}
