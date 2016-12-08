$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'letter', 'lang' ) ) {
        $dbh->do( "ALTER TABLE letter ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER message_transport_type" );
    }

    if( !column_exists( 'borrowers', 'lang' ) ) {
        $dbh->do( "ALTER TABLE borrowers ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER lastseen" );
        $dbh->do( "ALTER TABLE deletedborrowers ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER lastseen" );
    }

    # Add test on existene of this key
    $dbh->do( "ALTER TABLE message_transports DROP FOREIGN KEY message_transports_ibfk_3 ");
    $dbh->do( "ALTER TABLE letter DROP PRIMARY KEY ");
    $dbh->do( "ALTER TABLE letter ADD PRIMARY KEY (`module`, `code`, `branchcode`, `message_transport_type`, `lang`) ");

    $dbh->do( "INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('TranslateNotices',  '0',  NULL,  'Allow notices to be translated',  'YesNo') ");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add columns letter.lang and borrowers.lang to allow translation of notices)\n";
}
