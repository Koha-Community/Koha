$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'letter', 'lang' ) ) {
        $dbh->do( "ALTER TABLE letter ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER message_transport_type" );
    }

    if( !column_exists( 'borrowers', 'lang' ) ) {
        $dbh->do( "ALTER TABLE borrowers ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER lastseen" );
        $dbh->do( "ALTER TABLE deletedborrowers ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER lastseen" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add columns letter.lang and borrowers.lang to allow translation of notices)\n";
}
