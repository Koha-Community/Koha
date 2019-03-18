$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( column_exists( 'import_records', 'z3950random' ) ) {
        $dbh->do( "ALTER TABLE import_records DROP COLUMN z3950random" );
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22532 - Remove import_records z3950random column)\n";
}
