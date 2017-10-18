$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'search_field', 'mandatory' ) ) {
        $dbh->do( "ALTER TABLE search_field ADD COLUMN mandatory tinyint(1) NULL DEFAULT NULL" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19482 - Add mandatory column to search_field for ES mapping)\n";
}
