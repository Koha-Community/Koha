$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( "DELETE l1 FROM label_sheets l1, label_sheets l2 WHERE l1.version < l2.version AND l1.id = l2.id;" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-613-2 - Remove unused label rows from database)\n";
}
