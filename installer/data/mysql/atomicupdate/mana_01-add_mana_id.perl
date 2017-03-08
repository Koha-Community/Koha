$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'subscription', 'mana_id' ) ) {
        $dbh->do( "ALTER TABLE subscription ADD mana_id int(11) NULL DEFAULT NULL" );
    }

    if( !column_exists( 'saved_sql', 'mana_id' ) ) {
        $dbh->do( "ALTER TABLE saved_sql ADD mana_id int(11) NULL DEFAULT NULL" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17047 - Add column mana_id in subscription and saved_sql tables)\n";
}
