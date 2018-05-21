$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'search_field', 'weight' ) ) {
        $dbh->do( "ALTER TABLE `search_field` ADD COLUMN `weight` decimal(5,2) DEFAULT NULL" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18316 - Add column search_field.weight)\n";
}
