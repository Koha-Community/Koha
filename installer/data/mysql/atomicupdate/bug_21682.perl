$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( "ALTER TABLE stockrotationrotas CHANGE COLUMN description description text" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21682 - Remove default on stockrotationrotas.description)\n";
}
