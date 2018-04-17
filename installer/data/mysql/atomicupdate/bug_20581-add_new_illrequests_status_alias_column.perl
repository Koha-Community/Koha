$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if ( !column_exists( 'illrequests', 'status_alias' ) ) {
        $dbh->do( "ALTER TABLE illrequests ADD COLUMN status_alias integer DEFAULT NULL AFTER status" );
    }
    if ( !foreign_key_exists( 'illrequests', 'illrequests_safk' ) ) {
        $dbh->do( "ALTER TABLE illrequests ADD CONSTRAINT illrequests_safk FOREIGN KEY (status_alias) REFERENCES authorised_values(id) ON UPDATE CASCADE ON DELETE SET NULL" );
    }
    $dbh->do( "INSERT IGNORE INTO authorised_value_categories SET category_name = 'ILLSTATUS'");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20581 - Allow manual selection of custom ILL request statuses)\n";
}
